; =============================================================================
; music.asm - 3-voice SID music player (data in data/music.asm)
; =============================================================================
;
; Called once per frame from the raster IRQ (system.asm), so the tempo stays
; exact even if the main loop overruns a frame.
; TIMING: ~150 cycles on quiet frames; ~1000 at worst, when all three voices
; start notes with instrument changes at pattern ends (measured with the
; PROFILE test build). It runs at line 251 before the main loop's border
; work, which therefore starts up to ~25 raster lines later; sprites_draw
; still finishes by ~2900 cycles after the IRQ, against ~7000 until the
; first visible line (line 51).
;
; DATA MODEL
;   Each voice has an ORDER LIST: a list of pattern addresses, ended by a 0
;   word that loops back to the start. A PATTERN is a byte stream of events:
;     0-93          note number (C-0 = 0), then a length byte (frames)
;     EV_REST       then a length byte: silence
;     EV_INS        then an instrument number: affects following notes
;     EV_END        end of pattern: continue with the next order entry
;   A note is gated on when it starts and gated off one frame before its
;   length runs out, so the next note always retriggers the envelope.
;
; INSTRUMENTS (parallel tables in data/music.asm): waveform, AD, SR, pulse
; width, pulse-width sweep per frame (signed) and pitch slide per frame
; (signed, added to the frequency high byte; used for the kick drum).
;
; SID registers are write-only, so the frequency high byte and pulse width
; are shadowed here for the sweep/slide effects.
;
; SHARING VOICE 3 WITH SOUND EFFECTS (sfx.asm)
;   In every in-game song voice 3 is the drums. While an effect plays it owns
;   voice 3: sfx_start points voice_reg+2 at VOICE_MUTED, so the player keeps
;   reading voice 3's events and timing (it stays in sync) but its register
;   writes land on SID registers that ignore writes. When the effect ends,
;   music_voice3_back rewrites voice 3 from the shadows below (instrument,
;   pulse width, frequency, gate), so a drum hit the effect covered still
;   sounds, just late.
; =============================================================================

SID         = $d400
SID_FREQ_LO = SID + 0           ; per voice, + 7 * voice
SID_FREQ_HI = SID + 1
SID_PW_LO   = SID + 2
SID_PW_HI   = SID + 3
SID_CTRL    = SID + 4           ; waveform bits 4-7, gate = bit 0
SID_AD      = SID + 5
SID_SR      = SID + 6
SID_VOLUME  = SID + $18         ; low nibble = master volume

EV_REST = $60
EV_INS  = $61
EV_END  = $ff
MAX_NOTE = 94                   ; A#7 (3729 Hz = 63500); B-7 would overflow 16 bits

VOICE3_REG  = 14                ; voice 3's SID register offset
VOICE_MUTED = $19               ; offset whose 7 registers ($D419-$D41F) are
                                ;   read-only or unused: writes have no effect

!zone music_init
; -----------------------------------------------------------------------------
; music_init: silence the SID, player idle. Call once at boot, before cli.
; -----------------------------------------------------------------------------
music_init
        lda #0
        sta music_on
        sta sfx_on
        ldx #$18
-       sta SID,x               ; clear all voice and filter registers
        dex
        bpl -
        rts

!zone music_stop
; music_stop: silence. Safe while the IRQ runs. Clobbers A, X.
music_stop
        lda #0
        sta music_on            ; the IRQ stops calling the voices first...
        sta sfx_on              ;   (and any sound effect)
        lda #VOICE3_REG         ; voice 3 belongs to the music again
        sta voice_reg+2
        lda #0
        ldx #$18
-       sta SID,x               ; ...then the SID is cleared
        dex
        bpl -
        rts

!zone music_start
; -----------------------------------------------------------------------------
; music_start: start song A (SONG_* in data/songs.asm) from the beginning.
; Safe to call while the IRQ is running: it masks interrupts while it
; rewrites the player state, then restores the caller's I flag.
; Clobbers A, X, Y.
; -----------------------------------------------------------------------------
music_start
        php
        sei
        sta music_tmp
        asl                     ; song * 3 = index of its voice-1 order list
        clc
        adc music_tmp
        sta music_tmp
        lda #0
        sta music_on
        sta sfx_on              ; a new song ends any sound effect
        lda #VOICE3_REG
        sta voice_reg+2
        lda #0
        ldx #$18                ; silence everything left from the last song
-       sta SID,x
        dex
        bpl -
        ldx #2
-       txa
        clc
        adc music_tmp
        tay                     ; Y = song * 3 + voice
        lda music_order_lo,y
        sta mv_ordl,x
        sta mv_ord0l,x
        lda music_order_hi,y
        sta mv_ordh,x
        sta mv_ord0h,x
        lda #0
        sta mv_timer,x          ; 0 = fetch on the first tick
        sta mv_wave,x
        sta mv_slide,x
        sta mv_pwadd,x
        jsr music_load_pattern  ; first pattern from the order list
        dex
        bpl -
        lda #$0f                ; full volume, no filter
        sta SID_VOLUME
        lda music_off           ; music switched off on the title screen: the
        bne +                   ;   player stays idle (effects still play)
        lda #1
        sta music_on
+       plp
        rts

!zone music_play
; -----------------------------------------------------------------------------
; music_play: one tick (one frame) for all three voices. IRQ context: uses
; only its own zero page (mv_*, music_ptr, music_tmp). Clobbers A, X, Y.
; -----------------------------------------------------------------------------
music_play
        lda music_on
        bne +
        rts
+       ldx #2
.voice
!ifdef MUSIC_SOLO {
        cpx #MUSIC_SOLO - 1     ; test hook (acme -DMUSIC_SOLO=n): only voice n
        beq +
        jmp .next
+
}
        lda mv_timer,x
        beq .fetch              ; nothing playing yet
        dec mv_timer,x
        beq .fetch              ; current event finished
        lda mv_timer,x
        cmp #1
        bne .fx
        ldy voice_reg,x         ; one frame left: gate off (release), so the
        lda mv_wave,x           ;   next note retriggers the envelope
        sta SID_CTRL,y
        sta mv_ctrl,x
        jmp .fx
.fetch  jsr music_event
.fx     ; --- pitch slide (kick drum): freq hi += slide (signed) ---
        ; Stops at the ends of the range instead of wrapping.
        lda mv_slide,x
        beq .pw
        bmi .down
        clc
        adc mv_freqh,x
        bcs .pw                 ; would pass $ff: hold
        bcc .setf
.down   clc                     ; adding a negative: carry set = still >= 0
        adc mv_freqh,x
        bcc .pw                 ; would pass 0: hold
.setf   sta mv_freqh,x
        ldy voice_reg,x
        sta SID_FREQ_HI,y

.pw     ; --- pulse-width sweep: pw += pwadd (signed), 12-bit wrap ---
        ldy #0                  ; Y = sign extension of pwadd
        lda mv_pwadd,x
        beq .next
        bpl +
        dey
+       clc
        adc mv_pwl,x
        sta mv_pwl,x
        tya
        adc mv_pwh,x
        and #$0f
        sta mv_pwh,x
        ldy voice_reg,x
        sta SID_PW_HI,y
        lda mv_pwl,x
        sta SID_PW_LO,y
.next   dex
        bpl .voice
        rts

!zone music_event
; -----------------------------------------------------------------------------
; music_event: read events for voice X until one takes time (note or rest).
; Preserves X. Clobbers A, Y.
; -----------------------------------------------------------------------------
music_event
        lda mv_patl,x
        sta music_ptr
        lda mv_path,x
        sta music_ptr+1
.read   ldy #0
        lda (music_ptr),y
        cmp #EV_END
        bne .notend
        jsr music_next_pattern
        jmp music_event         ; (reloads music_ptr)
.notend cmp #EV_INS
        bne .notins
        iny
        lda (music_ptr),y       ; instrument number
        tay
        sta mv_ins,x
        lda ins_wave,y
        sta mv_wave,x
        lda ins_slide,y
        sta mv_slide,x
        lda ins_pwadd,y
        sta mv_pwadd,x
        lda ins_pwlo,y
        sta mv_pwl,x
        lda ins_pwhi,y
        sta mv_pwh,x
        lda ins_ad,y
        pha
        lda ins_sr,y
        ldy voice_reg,x
        sta SID_SR,y
        pla
        sta SID_AD,y
        lda mv_pwl,x
        sta SID_PW_LO,y
        lda mv_pwh,x
        sta SID_PW_HI,y
        jsr .skip2
        jmp .read
.notins cmp #EV_REST
        bne .note
        ldy voice_reg,x         ; rest: gate off
        lda mv_wave,x
        sta SID_CTRL,y
        sta mv_ctrl,x
        jmp .len
.note   sta music_tmp           ; note number -> frequency
        tay
        lda note_freq_lo,y
        pha
        lda note_freq_hi,y
        sta mv_freqh,x
        ldy voice_reg,x
        sta SID_FREQ_HI,y
        pla
        sta SID_FREQ_LO,y
        sta mv_freql,x
        lda mv_wave,x
        ora #1                  ; gate on: start the envelope
        sta SID_CTRL,y
        sta mv_ctrl,x
.len    ldy #1
        lda (music_ptr),y       ; length in frames
        sta mv_timer,x
.skip2  clc                     ; advance past the 2-byte event
        lda music_ptr
        adc #2
        sta music_ptr
        sta mv_patl,x
        lda music_ptr+1
        adc #0
        sta music_ptr+1
        sta mv_path,x
        rts

!zone music_next_pattern
; -----------------------------------------------------------------------------
; music_next_pattern: advance voice X to the next order entry (looping on a
; 0 word) and load that pattern. Preserves X. Clobbers A, Y.
; -----------------------------------------------------------------------------
music_next_pattern
        clc
        lda mv_ordl,x
        adc #2
        sta mv_ordl,x
        bcc music_load_pattern
        inc mv_ordh,x
        ; fall through

; music_load_pattern: mv_pat = the word at the order pointer; a 0 word means
; "loop": restart the order list. Preserves X. Clobbers A, Y.
music_load_pattern
        lda mv_ordl,x
        sta music_ptr
        lda mv_ordh,x
        sta music_ptr+1
        ldy #1
        lda (music_ptr),y       ; hi byte; patterns never live in page 0,
        bne +                   ;   so 0 = end of order list
        lda mv_ord0l,x
        sta mv_ordl,x
        lda mv_ord0h,x
        sta mv_ordh,x
        jmp music_load_pattern
+       sta mv_path,x
        dey
        lda (music_ptr),y
        sta mv_patl,x
        rts

!zone music_voice3_back
; -----------------------------------------------------------------------------
; music_voice3_back: a sound effect has finished with voice 3; hand it back to
; the music. Called from sfx_tick (IRQ context). Clobbers A, Y.
; TIMING: ~70 cycles.
; -----------------------------------------------------------------------------
music_voice3_back
        lda #VOICE3_REG
        sta voice_reg+2
        lda music_on
        beq .out                ; no music: nothing to restore
        ldy mv_ins+2            ; the drum instrument now in use
        lda ins_ad,y
        sta SID_AD + VOICE3_REG
        lda ins_sr,y
        sta SID_SR + VOICE3_REG
        lda mv_pwl+2
        sta SID_PW_LO + VOICE3_REG
        lda mv_pwh+2
        sta SID_PW_HI + VOICE3_REG
        lda mv_freql+2
        sta SID_FREQ_LO + VOICE3_REG
        lda mv_freqh+2
        sta SID_FREQ_HI + VOICE3_REG
        lda mv_wave+2           ; gate off, then the music's gate: a note that
        sta SID_CTRL + VOICE3_REG ; is still on restarts, so a drum hit the
        lda mv_ctrl+2           ;   effect covered sounds late, not never
        sta SID_CTRL + VOICE3_REG
.out    rts

; SID register offset per voice. Voice 3's entry is VOICE_MUTED while a sound
; effect owns that voice (sfx.asm), so the program must run from RAM.
voice_reg       !byte 0, 7, VOICE3_REG

; More per-voice shadows, kept only so music_voice3_back can rebuild voice 3.
; IRQ-only, like the mv_* zero page (which is full).
mv_ins          !byte 0, 0, 0   ; instrument number
mv_freql        !byte 0, 0, 0   ; frequency low byte (mv_freqh is the high)
mv_ctrl         !byte 0, 0, 0   ; last control register value (wave + gate)

; Note frequencies for a PAL C64 (SID clock 985248 Hz), equal temperament,
; A-4 = 440 Hz. Note n: C-0 = 0 ... A#7 = 94. Built at assemble time.
!macro note_freq_table .shift {
        !for .n, 0, MAX_NOTE {
                !byte (int(440.0 * 2.0 ^ ((float(.n) - 57.0) / 12.0) * 16777216.0 / 985248.0 + 0.5) >> .shift) & $ff
        }
}
note_freq_lo    +note_freq_table 0
note_freq_hi    +note_freq_table 8
