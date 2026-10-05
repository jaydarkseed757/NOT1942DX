; =============================================================================
; system.asm - machine setup, raster IRQ, frame sync
; =============================================================================

!zone init_system
; -----------------------------------------------------------------------------
; init_system: take over the machine.
;   - silence CIA interrupts (KERNAL keyboard IRQ, CIA2 NMIs)
;   - copy the ROM font (chars 0-63) into our charset while char ROM is visible
;   - install our IRQ/NMI vectors in the RAM under KERNAL
;   - bank out BASIC and KERNAL ($01 = $35)
;   - clear the BSS (bss.asm) and zero page
; Must be called with interrupts disabled.
; -----------------------------------------------------------------------------
init_system
        lda #$7f
        sta CIA1_ICR            ; disable all CIA1 interrupt sources
        sta CIA2_ICR            ; disable all CIA2 NMI sources
        lda CIA1_ICR            ; ack anything already pending
        lda CIA2_ICR

        ; --- copy chars 0-63 (512 bytes) from char ROM to CHARSET ---
        lda #MAP_CHARROM        ; char ROM appears at $D000 (I/O hidden)
        sta CPU_PORT
        ldx #0
.font   lda $d000,x             ; uppercase/graphics set, screen codes 0-63
        sta CHARSET,x           ;   (@, A-Z, [, ], arrows, space, !"#.. 0-9 ...)
        lda $d100,x
        sta CHARSET+$100,x
        inx
        bne .font

        ; --- hardware vectors in RAM under KERNAL ---
        ; CPU writes always go to RAM, even while ROM is mapped in.
        lda #<irq_handler
        sta $fffe
        lda #>irq_handler
        sta $ffff
        lda #<nmi_handler
        sta $fffa
        lda #>nmi_handler
        sta $fffb

        lda #MAP_ALLRAM_IO      ; BASIC/KERNAL out, I/O in
        sta CPU_PORT

        ; --- clear the BSS tables in the RAM under the KERNAL (bss.asm) ---
        lda #<BSS
        sta zp_ptr0
        lda #>BSS
        sta zp_ptr0+1
        ldy #0
        tya
-       sta (zp_ptr0),y
        iny
        bne -
        inc zp_ptr0+1
        ldx zp_ptr0+1
        cpx #>(bss_end + 255)
        bne -

        ; --- clear our zero page variables ---
        lda #0
        ldx #$02
.zp     sta $00,x
        inx
        bne .zp
        rts

!zone init_irq
; -----------------------------------------------------------------------------
; init_irq: one raster IRQ per frame at IRQ_LINE (below the text area).
; -----------------------------------------------------------------------------
init_irq
        lda #IRQ_LINE
        sta VIC_RASTER
        lda VIC_CTRL1
        and #%01111111          ; raster compare bit 8 = 0 (line < 256)
        sta VIC_CTRL1
        lda #%00000001          ; enable raster IRQ only
        sta VIC_IRQEN
        sta VIC_IRQ             ; ack any stale raster IRQ
        rts

!zone irq
; -----------------------------------------------------------------------------
; irq_handler: frame IRQ at raster line IRQ_LINE (lower border).
; KERNAL is banked out, so this is entered directly from $FFFE. We save
; registers ourselves.
; TIMING: keep this short. It runs once per frame. The $D018 flip and the
; play fine scroll ($D011) land in the border, so a frame never tears.
; -----------------------------------------------------------------------------
irq_handler
        pha
        txa
        pha
        tya
        pha
        cld                     ; the 6502 keeps D on interrupt; the main code
                                ;   may be mid-BCD add (score.asm). RTI restores P.
!ifdef PROFILE {
        jsr prof_time           ; test hook: the IRQ's start time
        sta prof_t0+1
        stx prof_t0
}

        ; BRK shares the $FFFE vector. Stack now holds Y,X,A,P (P at $0104+SP).
        ; If B is set we got here by executing a BRK (usually a $00 byte from
        ; jumping into bad memory): halt visibly instead of faking a frame.
        tsx
        lda $0104,x
        and #%00010000          ; B flag
        bne brk_trap

irq_frame                       ; (mux_irq jumps here if it ran past line 251)
        lda #%00000001
        sta VIC_IRQ             ; ack raster IRQ

        lda flip_pending        ; scroller asked for a buffer swap?
        beq +
        lda next_d018
        sta VIC_MEM             ; show the newly built buffer
        lda next_d011           ; ...and, if set, a new $D011 at the same
        beq ++                  ;   moment (the credits roll resets its fine
        sta VIC_CTRL1           ;   scroll together with the swap). 0 = none.
++      lda #0
        sta flip_pending
+       lda scroll_d011         ; in play: yscroll and the 24-row window for
        beq +                   ;   the coming frame (scroll.asm), every frame
        sta VIC_CTRL1
+       jsr mux_frame           ; sprites: the first 8, and the IRQs for the
                                ;   rest (mux.asm)
        inc frame_count
        lda #1
        sta frame_flag          ; release the main loop

        lda paused              ; paused (pause.asm): music and effects hold
        bne +                   ;   still
        jsr music_play          ; TIMING: see music.asm. The music measures
        jsr sfx_tick            ;   at most ~1100 cycles alone and ~1600 with
                                ;   an effect starting; mux_frame adds ~500
+
!ifdef PROFILE {
        jsr prof_time           ; test hook: cycles this IRQ took
        jsr prof_since
        cmp prof_irq+1
        bcc ++
        bne +
        cpx prof_irq
        bcc ++
+       sta prof_irq+1
        stx prof_irq
++
}

irq_exit                        ; (also mux_irq's way out)
        pla
        tay
        pla
        tax
        pla
nmi_handler                     ; RESTORE key (NMI) lands here and is ignored
        rti

; brk_trap: a BRK was executed. Flash the border forever. In the VICE monitor
; (Alt+H) look at the stack: the bytes at $0105-$0106+SP are the return
; address (BRK address + 2).
brk_trap
-       inc BORDER
        jmp -

!ifdef PROFILE {
!zone prof_frame
; -----------------------------------------------------------------------------
; Frame profiler (test hook, acme -DPROFILE=1). Times with CIA1 timer A,
; free-running from $FFFF (the game doesn't use the CIA timers), so the
; numbers are exact cycles, including badline and sprite DMA steals.
;   prof_main   worst cycles from the frame IRQ's start to the end of the
;               frame's work (IRQ + main loop), any frame. Must stay under
;               19656 (one PAL frame), except screen builds
;   prof_play   the same, play frames only. Play frames are timed by
;               prof_end, before scroll_colour: on a flip frame the colour
;               chase waits for the raster on purpose, which isn't work
;   prof_irq    worst cycles of the frame IRQ alone (sprites, music, effects)
;   prof_over   frames whose work ran into the next IRQ (not counted in
;               prof_main); prof_ovmode = game_mode * 16 + lvl_state then
;   prof_over_play / prof_ovplay  the same in play only (must stay 0);
;               prof_ovplay = boss_state * 16 + yscroll at the last one
;   prof_late   colour chases that ended after the next IRQ (harmless)
;   prof_maxspr / prof_drops  most sprites in one display list, and sprites
;               the multiplexer had to drop (prof_mux)
; HUD columns 20-21 most sprites, 22-23 drops (low byte), 25-28 main, 30-32
; IRQ, 34-35 overruns, 38-39 overrun mode (all hex). In play the HUD isn't
; on screen, so the digits go to HUD_BUF only and show on the next text
; screen (level intro, GAME OVER, ending); on other screens they are written
; to row 0 as well. tools/profile.py reads them all through VICE's monitor.
; prof_reset (level_begin, victory_enter, roll, finale) restarts the counts
; and skips the next two frames: screen builds legitimately take several.
; -----------------------------------------------------------------------------
prof_frame
        lda prof_skip
        beq +
        dec prof_skip
        lda #0                  ; (and forget an overrun from the build)
        sta frame_flag
        sta prof_ended
        jmp .show
+       lda prof_ended          ; play frame: timed (or counted) by prof_end
        beq .other
        ldx #0
        stx prof_ended
        cmp #1
        bne .show               ; 2: its overrun is already counted
        lda frame_flag          ; the work was on time, but the colour chase
        beq .show               ;   ended after the next IRQ: harmless (the
        inc prof_late           ;   flip has happened; see scroll_colour)
        jmp .show
.other  lda frame_flag          ; the next IRQ already happened: overrun
        beq .time
        inc prof_over
        lda game_mode
        asl
        asl
        asl
        asl
        ora lvl_state
        sta prof_ovmode
        jmp .show
.time   jsr prof_time
        jsr prof_since          ; A:X = cycles since this frame's IRQ began
        cmp prof_main+1
        bcc .show
        bne +
        cpx prof_main
        bcc .show
+       sta prof_main+1
        stx prof_main
.show   lda game_mode           ; in play the digits aren't on screen: keep
        bne +                   ;   HUD_BUF fresh every 16 frames only, so
        lda frame_count         ;   measuring costs the play frames little
        and #15
        beq +
        rts
+       lda prof_maxspr
        ldy #20
        jsr .hex2
        lda prof_drops
        jsr .hex2
        lda prof_main+1
        ldy #25
        jsr .hex2
        lda prof_main
        jsr .hex2
        lda prof_irq+1
        ldy #30
        jsr .hex1
        lda prof_irq
        jsr .hex2
        lda prof_over
        ldy #34
        jsr .hex2
        lda prof_ovmode
        ldy #38
        jmp .hex2

.hex2   pha                     ; A as two hex digits at HUD column Y, Y += 2
        lsr
        lsr
        lsr
        lsr
        jsr .hex1
        pla
.hex1   and #$0f                ; one hex digit at HUD column Y, Y += 1
        tax
        lda .digits,x
        sta HUD_BUF,y
        ldx game_mode           ; GM_PLAY = 0: row 0 is playfield
        beq +
        sta SCREEN_A + HUD_ROW*COLS,y
        sta SCREEN_B + HUD_ROW*COLS,y
+       iny
        rts

; prof_end: a play frame's work is done (main loop, before scroll_colour,
; whose waiting for the raster isn't work). An overrun here is a real one:
; the frame's work ran into the next frame.
prof_end
        lda frame_flag
        beq +
        inc prof_over
        inc prof_over_play
        lda lvl_state           ; game_mode is GM_PLAY (0)
        sta prof_ovmode
        lda boss_state          ; boss state * 16 + the yscroll the frame set
        asl
        asl
        asl
        asl
        ora scroll_fine
        sta prof_ovplay
        lda #2
        sta prof_ended
        rts
+       jsr prof_time
        jsr prof_since
        cmp prof_play+1         ; worst play frame alone (prof_main also
        bcc +++                 ;   sees the screen builds between levels)
        bne +
        cpx prof_play
        bcc +++
+       sta prof_play+1
        stx prof_play
+++     cmp prof_main+1
        bcc ++
        bne +
        cpx prof_main
        bcc ++
+       sta prof_main+1
        stx prof_main
++      lda #1
        sta prof_ended
        jmp prof_mux

.digits !scr "0123456789abcdef"

; prof_time: CIA1 timer A now, A = hi, X = lo (read so the two bytes match).
prof_time
-       lda CIA1_TAHI
        ldx CIA1_TALO
        cmp CIA1_TAHI
        bne -
        rts

; prof_since: A:X = prof_t0 - A:X (the timer counts down).
prof_since
        sta prof_tmp
        stx prof_tmp+1
        lda prof_t0
        sec
        sbc prof_tmp+1
        tax
        lda prof_t0+1
        sbc prof_tmp
        rts

; prof_mux: multiplexer statistics for a play frame (from prof_end): the
; most sprites in one display list, and the sprites dropped (16-bit total).
; HUD columns 20-21 and 22-23.
prof_mux
        lda mux_p_end
        sec
        sbc mux_p_base
        cmp prof_maxspr
        bcc +
        sta prof_maxspr
+       lda prof_drops
        clc
        adc mux_drops
        sta prof_drops
        bcc +
        inc prof_drops+1
+       rts

prof_reset
        lda #$ff                ; timer A: free-running from $FFFF
        sta CIA1_TALO
        sta CIA1_TAHI
        lda #%00010001          ; force load + start, continuous, phi2 clock
        sta CIA1_CRA
        lda #0
        sta prof_main
        sta prof_main+1
        sta prof_irq
        sta prof_irq+1
        sta prof_over
        sta prof_ovmode
        sta prof_over_play
        sta prof_ovplay
        sta prof_late
        sta prof_play
        sta prof_play+1
        sta prof_maxspr
        sta prof_drops
        sta prof_drops+1
        lda #2
        sta prof_skip
        rts

prof_main   !word 0
prof_drops  !word 0
prof_maxspr !byte 0
prof_irq    !word 0
prof_t0     !word 0
prof_tmp    !word 0
prof_over   !byte 0
prof_ovmode !byte 0
prof_skip   !byte 0
prof_ended  !byte 0
prof_over_play !byte 0
prof_ovplay !byte 0
prof_late   !byte 0
prof_play   !word 0
}

!zone wait_frame
; -----------------------------------------------------------------------------
; wait_frame: block until the next frame IRQ, then consume the flag.
; If the previous frame overran, the flag is already set and we return at once
; instead of losing a frame.
; -----------------------------------------------------------------------------
wait_frame
-       lda frame_flag
        beq -
        lda #0
        sta frame_flag
        rts
