; =============================================================================
; pause.asm - pause during play (P or RUN/STOP toggles it)
; =============================================================================
;
; While paused, the main loop only runs pause_update: no border work, no
; logic, so every object, timer and the scroll hold still. The IRQ keeps
; running (frame sync, the same $D011 every frame) but skips the music and
; effect players, and the SID volume is 0, so notes that were ringing are
; silent and resume exactly where they were.
;
; "PAUSED" is printed straight into the front buffer, in the middle of the
; screen, on the first paused frame (paused = 1 -> 2): by then any pending
; flip has happened, so the front buffer is the one on screen. The chars and
; colours it covers are saved and put back on resume. The scroller doesn't
; run while paused, so nothing else touches that row in the meantime.
;
; $D01E keeps latching while paused; the sprites don't move, so the first
; frame after the pause sees the same overlaps it would have seen anyway.
; =============================================================================

PAUSE_ROW = 12
PAUSE_LEN = 8
PAUSE_COL = (COLS - PAUSE_LEN) / 2
PAUSE_OFS = PAUSE_ROW * COLS + PAUSE_COL

!zone pause_enter
; pause_enter: called from the main loop on a pause press. Clobbers A.
pause_enter
        lda #1
        sta paused              ; the IRQ stops calling the players first...
        lda #0
        sta SID_VOLUME          ; ...then silence (no filter is ever used)
        rts

!zone pause_update
; -----------------------------------------------------------------------------
; pause_update: the main loop's whole frame while paused. Draws the text on
; the first paused frame, then watches for the pause key.
; Clobbers A, X, Y, zp_ptr0.
; -----------------------------------------------------------------------------
pause_update
        lda paused
        cmp #2
        beq +
        jsr pause_draw
        lda #2
        sta paused
+       jsr read_input
        lda input_new
        and #INP_PAUSE
        beq +
        jmp pause_exit
+       rts

; pause_ptr: zp_ptr0 = the front buffer's text position. Clobbers A, X.
pause_ptr
        lda #<(SCREEN_A + PAUSE_OFS)
        sta zp_ptr0
        lda #>(SCREEN_A + PAUSE_OFS)
        ldx front_buf
        beq +
        lda #>(SCREEN_B + PAUSE_OFS)
+       sta zp_ptr0+1
        rts

!if <(SCREEN_A + PAUSE_OFS) != <(SCREEN_B + PAUSE_OFS) { !error "pause_ptr: buffers must differ in the high byte only" }

pause_draw
        lda scroll_slice        ; paused on a flip frame: the new screen's
        bne +                   ;   colour RAM rows 23-24 may still be to do
        jsr cram_late           ;   (f = 0; harmless if done already)
+       jsr pause_ptr
        ldy #PAUSE_LEN - 1
-       lda (zp_ptr0),y
        sta pause_save,y
        lda pause_text,y
        sta (zp_ptr0),y
        lda #COL_WHITE          ; hires text
        sta COLRAM + PAUSE_OFS,y
        dey
        bpl -
        rts

!zone pause_exit
; pause_exit: put the covered chars and colours back, sound on.
; Clobbers A, X, Y, zp_ptr0.
pause_exit
        jsr pause_ptr
        ldy #PAUSE_LEN - 1
-       lda pause_save,y
        sta (zp_ptr0),y
        tax
        lda CHAR_COL,x
        sta COLRAM + PAUSE_OFS,y
        dey
        bpl -
        lda #$0f                ; full volume, as music_start / sfx_start set
        sta SID_VOLUME
        lda #0
        sta paused
        rts

pause_text  !scr " paused "
pause_save  !fill PAUSE_LEN, 0
!if pause_save - pause_text != PAUSE_LEN { !error "pause text length" }
