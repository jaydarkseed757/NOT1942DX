; =============================================================================
; sfx.asm - scripted sound effects (data in data/sfx.asm)
; =============================================================================
;
; An effect is a list of timed "booms" (+boom lines, 7 bytes each):
;   frame, voice, waveform, frequency high byte, AD, SR, slide
; On its frame, the voice gets a fresh sound (envelope restarted), and its
; frequency high byte then falls by -slide every frame until it reaches 0.
; Several booms may share a frame. The list ends with +sfx_end FRAME: on that
; frame the effect is over (sounds still ringing are left to fade).
;
; VOICES  In-game effects use only voice 3 (index 2): while one plays, the
; music keeps going on voices 1-2 and voice 3's drums drop out, then come
; back in time (see "sharing voice 3" in music.asm). Effects that use voices
; 1-2 as well must only start with the music stopped: the boss explosion
; starts right after boss_hit has stopped the music.
;
; PRIORITY  One effect plays at a time. A new effect replaces the current
; one unless the current one is more important (sfx_table_prio), so a
; boss hit click can't cut off the player's death.
;
; music_start / music_stop cancel a running effect.
;
; Runs from the raster IRQ after music_play.
; TIMING: ~60 cycles per frame, ~80 more for each boom triggered, ~70 at the
; end of an effect (music_voice3_back).
; =============================================================================

SFX_STOP  = $ff                 ; voice byte of the +sfx_end record
SFX_LEN   = 7                   ; bytes per boom

!zone sfx_start
; -----------------------------------------------------------------------------
; sfx_start: play effect A (SFX_* in data/sfx.asm) from its first frame,
; unless a more important effect is playing. Safe while the IRQ runs.
; Preserves X and Y (it is called from collision code). Clobbers A.
; -----------------------------------------------------------------------------
sfx_start
        php
        sei
        sta music_tmp           ; (IRQ scratch: safe, the IRQ is masked)
        txa
        pha
        ldx music_tmp
        lda sfx_on
        beq .go
        lda sfx_table_prio,x
        cmp sfx_prio
        bcc .out                ; something more important is playing
.go     lda sfx_table_prio,x
        sta sfx_prio
        lda sfx_table_lo,x
        sta sfx_ptr
        lda sfx_table_hi,x
        sta sfx_ptr+1
        lda #0
        sta sfx_frame
        sta sfx_slide
        sta sfx_slide+1
        sta sfx_slide+2
        lda #VOICE_MUTED        ; voice 3 is ours: the music's writes to it
        sta voice_reg+2         ;   go nowhere until the effect ends
        lda #$0f                ; full volume (music_stop clears the SID)
        sta SID_VOLUME
        lda #1
        sta sfx_on
.out    pla
        tax
        plp
        rts

!zone sfx_tick
; -----------------------------------------------------------------------------
; sfx_tick: one frame of the current effect. IRQ context: uses only its own
; zero page (sfx_*). Clobbers A, X, Y.
; -----------------------------------------------------------------------------
sfx_tick
        lda sfx_on
        bne .events
        rts

.events ldy #0                  ; trigger every boom due on this frame
        lda (sfx_ptr),y         ; its frame
        cmp sfx_frame
        bne .slides             ; the next boom is later
        iny
        lda (sfx_ptr),y         ; voice 0-2, or SFX_STOP
        cmp #SFX_STOP
        bne +
        lda #0                  ; +sfx_end: the effect is over
        sta sfx_on
        jmp music_voice3_back
+       tax
        ldy #6
        lda (sfx_ptr),y         ; slide per frame (0 or negative)
        sta sfx_slide,x
        ldy #3
        lda (sfx_ptr),y         ; frequency high byte (shadowed for the slide)
        sta sfx_freqh,x
        lda sfx_voice_reg,x
        tax                     ; X = the voice's SID register offset
        lda #0
        sta SID_FREQ_LO,x
        lda (sfx_ptr),y         ; (Y is still 3)
        sta SID_FREQ_HI,x
        ldy #4
        lda (sfx_ptr),y
        sta SID_AD,x
        iny
        lda (sfx_ptr),y
        sta SID_SR,x
        ldy #2
        lda (sfx_ptr),y         ; waveform, gate off...
        sta SID_CTRL,x
        ora #1                  ; ...then gate on: a rising gate restarts
        sta SID_CTRL,x          ;   the envelope even if the voice was busy
        clc
        lda sfx_ptr             ; on to the next boom
        adc #SFX_LEN
        sta sfx_ptr
        bcc .events
        inc sfx_ptr+1
        jmp .events

.slides ldx #2                  ; pitch falls on every voice still sliding
-       lda sfx_slide,x
        beq .next
        clc
        adc sfx_freqh,x         ; adding a negative: carry set = still >= 0
        bcc .stop
        sta sfx_freqh,x
        ldy sfx_voice_reg,x
        sta SID_FREQ_HI,y
        jmp .next
.stop   lda #0                  ; reached the bottom: stop sliding
        sta sfx_slide,x
.next   dex
        bpl -
        inc sfx_frame
        rts

; The real SID offsets (music.asm's voice_reg may point voice 3 elsewhere).
sfx_voice_reg   !byte 0, 7, VOICE3_REG
