; =============================================================================
; title3d.asm - the Ultimate build's 3D title (acme -DTURBO=1 -DULTIMATE=1)
; =============================================================================
;
; On a fast enough machine the title's block logo becomes "NOT 1942 DX" in
; solid extruded letters, swinging in perspective, drawn every frame into a
; hires bitmap; the air show flies over it. "Fast enough" is measured, not
; guessed: at boot t3_install draws one frame at the widest angle and times
; it in raster lines; within T3_LINES the 3D title is on. (turbo_speed is
; too rough for this: on the C64 Ultimate it read 55x on one boot and 64x on
; another; and its CIA timers don't count C64 cycles in turbo mode, so they
; can't time this either.) Slower machines, like a MiSTer at 2x-4x, get the
; normal title.
;
; THE SCREEN: char rows 0-11 (lines 51-146) show a hires bitmap at T3_BITMAP
; ($6000: in this build the map RING, free on the title); rows 12-24 stay
; text. The frame IRQ (line 251) switches bitmap mode on; t3_frame, which
; waits for the beam to leave the logo anyway, switches back to text at line
; T3_SPLIT (139) by polling the raster: no raster IRQ of its own, so the
; multiplexer keeps the raster IRQ for the air show's sprites. Row 11 of the
; band (lines 139-146) is always background (the logo ends above it), so a
; multiplexer IRQ delaying the switch by a line or two shows nothing. The
; bitmap's colours come from SCREEN_A's rows 0-11 (the logo's colour per char
; row); colour RAM rows 0-11 are the background colour.
;
; THE RENDERER (title3d_core.asm) runs from the RAM under the I/O area
; (T3_BASE, $D000): t3_install copies it there at boot from the RING, where
; it was loaded behind turbo.asm. It runs with the I/O out ($01 = $34); every
; IRQ handler switches the I/O back in for itself (+irq_io_in, system.asm).
; TIMING: each frame t3_frame waits for the split (the beam in row 11) and
; draws then, so the band is finished before the beam is back at line 51:
; 224 lines. At 64x it takes ~180 (title3d_core.asm). Test hook T3_TIMING=1
; records where each render ends (t3_dbg_line / _hi / _frames).
; =============================================================================

T3_BASE   = $d000               ; the RAM under the I/O area
T3_BITMAP = RING                ; $6000 in this build (defs.asm)
T3_SPLIT  = 139                 ; the split: the first line of char row 11
T3_LINES  = 196                 ; a frame's drawing must take no more raster
                                ;   lines: the window from line 139 to 51 is
                                ;   224, so this keeps ~12% spare
D011_BMP  = D011_TEXT | %00100000   ; bitmap mode, display on, yscroll 3
D018_BMP  = (((SCREEN_A - VIC_BASE) / $400) << 4) | (((T3_BITMAP - VIC_BASE) / $2000) << 3)
MAP_ALLRAM = $34                ; RAM everywhere, I/O out

!ifdef PROFILE { !error "the Ultimate build doesn't fit with PROFILE: profile the turbo build (its game is the same)" }
!if T3_BITMAP != VIC_BASE + $2000 { !error "title3d: the bitmap must be at the VIC bank's $2000" }
!if T3_SPLIT < 51 + 11 * 8 | T3_SPLIT > 51 + 12 * 8 - 1 { !error "title3d: the split must fall in char row 11" }

t3_ok     !byte 0               ; 1: fast enough for the 3D title
t3_on     !byte 0               ; 1: the 3D title is showing

!zone t3_install
; -----------------------------------------------------------------------------
; t3_install: at boot, after turbo_detect, IRQs off: fast enough? Copy the
; renderer to T3_BASE either way (the RING is about to be overwritten).
; Clobbers A, X, Y, zp_ptr0, zp_ptr1.
; -----------------------------------------------------------------------------
t3_install
        lda #<t3_stage
        sta zp_ptr0
        lda #>t3_stage
        sta zp_ptr0+1
        lda #<T3_BASE
        sta zp_ptr1
        lda #>T3_BASE
        sta zp_ptr1+1
        lda #MAP_ALLRAM         ; the RAM under the I/O area
        sta CPU_PORT
        ldx #>(t3_stage_end - t3_stage + 255)
        ldy #0
-       lda (zp_ptr0),y
        sta (zp_ptr1),y
        iny
        bne -
        inc zp_ptr0+1
        inc zp_ptr1+1
        dex
        bne -
        jsr t3_init             ; (its tables, at T3_BASE, with the I/O out)
        lda #T3_WIDEST - 1      ; time one frame at the widest swing (the
        sta t3_t                ;   most side faces), into the band, in
        lda #MAP_ALLRAM_IO      ;   raster lines from line 0
        sta CPU_PORT
        lda VIC_CTRL1           ; the raster compare at line 0: its flag in
        and #%01111111          ;   $D019 then tells if the beam came round
        sta VIC_CTRL1           ;   again (IRQs are off: only the flag)
        lda #0
        sta VIC_RASTER
-       lda VIC_RASTER          ; wait for line 0
        bne -
        lda VIC_CTRL1
        bmi -
        lda #1
        sta VIC_IRQ             ; (its flag, cleared)
        lda #MAP_ALLRAM
        sta CPU_PORT
        jsr t3_render
        lda #MAP_ALLRAM_IO
        sta CPU_PORT
        lda VIC_RASTER          ; lines taken (under 256 to pass at all)
        sta t3_lines
        ldx #0                  ; too slow: a whole frame, or past line 255,
        lda VIC_IRQ             ;   or past T3_LINES
        lsr
        bcs +
        lda VIC_CTRL1
        bmi +
        lda t3_lines
        cmp #T3_LINES + 1
        bcs +
        inx                     ; fast enough
+       lda #1
        sta VIC_IRQ             ; (the flag, cleared again)
!ifdef T3_FORCE {
        ldx #1                  ; test hook (acme -DT3_FORCE=1): on anyway
}                               ;   (VICE's SuperCPU stores to C64 memory
        stx t3_ok               ;   at 1 MHz: too slow to pass)
        rts
t3_lines !byte 0                ; (the test frame's lines: kept for testing)

!zone t3_enter
; -----------------------------------------------------------------------------
; t3_enter: from title_enter, with the display off: if fast enough, set up
; the 3D title (the colour rows, a clear band, hires) and
; switch it on. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
t3_enter
        lda t3_ok
        bne +
        rts
+       lda #PAL_OCEAN          ; colour RAM rows 0-11: the background (480
        ldx #240 - 1            ;   bytes)
-       sta COLRAM,x
        sta COLRAM + 240,x
        dex
        cpx #$ff
        bne -
        ; the version, which row 0 can't show now: centred under "by jdc",
        ; in its cyan
        +print_both TITLE_BY_ROW + 1, (COLS - TITLE_VERSION_LEN) / 2, title_version, TITLE_VERSION_LEN
        lda #COL_CYAN
        ldx #COLS - 1
-       sta COLRAM + (TITLE_BY_ROW + 1) * COLS,x
        dex
        bpl -
        lda #%00001000          ; hires (no multicolour), 40 columns
        sta VIC_CTRL2
        lda #MAP_ALLRAM
        sta CPU_PORT
        jsr t3_setup            ; the bitmap's colour rows, a clear band
        lda #MAP_ALLRAM_IO
        sta CPU_PORT
        lda #1
        sta t3_on
        rts

!zone t3_frame
; -----------------------------------------------------------------------------
; t3_frame: from title_update, once a frame: wait for the beam to leave the
; band (line T3_SPLIT), switch to text there, then draw the logo.
; Clobbers A, X, Y, zp_ptr*, zp_tmp*.
; -----------------------------------------------------------------------------
t3_frame
-       lda VIC_CTRL1           ; first out of lines T3_SPLIT-255 of this
        bmi +                   ;   frame (the frame IRQ was at 251)...
        lda VIC_RASTER
        cmp #T3_SPLIT
        bcs -
+
-       lda VIC_CTRL1           ; ...then into the next frame's T3_SPLIT
        bmi -
        lda VIC_RASTER
        cmp #T3_SPLIT
        bcc -
        lda #D011_TEXT          ; the split: text from row 12 on
        sta VIC_CTRL1
        lda #D018_A
        sta VIC_MEM
!ifdef T3_TIMING {
        lda frame_count
        sta t3_dbg_f0
}
        lda #MAP_ALLRAM
        sta CPU_PORT
        jsr t3_render
        lda #MAP_ALLRAM_IO
        sta CPU_PORT
t3_rendered                     ; (a frame is drawn: tests break here)
!ifdef T3_TIMING {
        lda VIC_RASTER          ; test hook (acme -DT3_TIMING=1): the line
        sta t3_dbg_line         ;   the render ended on (and bit 8), and the
        lda VIC_CTRL1           ;   frames it spanned
        sta t3_dbg_hi
        lda frame_count
        sec
        sbc t3_dbg_f0
        sta t3_dbg_frames
}
        rts
!ifdef T3_TIMING {
t3_dbg_line   !byte 0
t3_dbg_hi     !byte 0
t3_dbg_frames !byte 0
t3_dbg_f0     !byte 0
}

; t3_irq_frame: from the frame IRQ while t3_on: bitmap mode for the band
; (t3_frame switches back to text at T3_SPLIT). Clobbers A.
t3_irq_frame
        lda #D011_BMP
        sta VIC_CTRL1
        lda #D018_BMP
        sta VIC_MEM
        rts

; t3_off: leaving the title (level_intro_enter); init_video then sets the
; screen. Clobbers A.
t3_off
        lda #0
        sta t3_on
        rts
