; =============================================================================
; ending.asm - after the final boss: victory screen, credits roll, and the
; final screen with a big looping scroll text
; =============================================================================
;
; FLOW  level 4 cleared --> victory_enter (VICTORY! / FINAL SCORE, 4 s)
;       --> roll_enter: data/ending.asm's credits roll up the screen
;       --> finale_enter: final score + the scroll text in 16x16 letters,
;           rainbow colours, looping; "press fire" after a delay --> title
; The title anthem plays throughout (started by victory_enter).
;
; The ending screens use plain hires text ($D016 multicolour off), so colour
; RAM can use all 16 colours. title_enter -> init_video restores everything.
; =============================================================================

VICTORY_FRAMES = 200            ; 4 s on the victory screen
ROLL_STEP      = 16             ; frames per text row in the roll (1 px / 2 frames)
ROLL_SLICES    = 4              ; back-buffer copy spread over frames 1-4
ROLL_ROWS_OUT  = ROWS           ; blank rows after the text: rolls it all off
ROLL_D011      = %00010111      ; display on, 24 rows (hides the scroll seam), yscroll 7
FINALE_D011    = %00011011      ; display on, 25 rows, yscroll 3 (normal)
SCROLL_ROW     = 11             ; big scroller: screen rows 11-12
SCORE_ROW      = 6
PRESS_ROW      = 18
STRIP_TOP      = 144            ; char codes of the scroller strip: 144-183 on
STRIP_BOT      = STRIP_TOP + COLS ;   row 11, 184-223 on row 12 (after the
                                ;   tileset 64-127 and the logo chars 128-143)

!if STRIP_BOT + COLS > 256 { !error "scroller strip chars don't fit in the charset" }

!zone victory_enter
; -----------------------------------------------------------------------------
; victory_enter: all four levels cleared (called by level_next).
; -----------------------------------------------------------------------------
victory_enter
!ifdef PROFILE {
        jsr prof_reset          ; test hook: measure the ending on its own
}
        jsr hud_clear_mid       ; no "level clear" left in the HUD
        jsr textscreen_enter
        lda #COL_BLACK          ; a night sky: black, hires text
        sta BORDER
        sta BGCOL0
        lda #%00001000
        sta VIC_CTRL2
        +print_both TXT_ROW_A, (COLS - .title_len) / 2, .title, .title_len
        +print_both TXT_ROW_B, (COLS - .sub_len) / 2, .sub, .sub_len
        jsr print_final_score
        jsr fx_init             ; fireworks, stars, and a victory pass
        lda #<fx_victory_rows   ;   (ending_fx.asm)
        ldx #>fx_victory_rows
        jsr fx_stars
        jsr fx_ship_start
        lda #VICTORY_FRAMES
        sta end_timer
        lda #GM_VICTORY
        sta game_mode
        lda #SONG_TITLE         ; the heroic anthem, all through the ending
        jsr music_start
        jmp video_on

.title  !scr "victory!"
.title_len = * - .title
.sub    !scr "all four levels cleared"
.sub_len = * - .sub

; victory_update: hold the victory screen, then start the credits roll.
victory_update
        jsr fx_ship
        jsr fx_fireworks        ; (and mux_build)
        jsr fx_twinkle
        dec end_timer
        bne +
        jmp roll_enter
+       rts

!zone ending_screen
; -----------------------------------------------------------------------------
; ending_screen: common set-up for the roll and the final screen. Display
; off, sprites off, black screen, both buffers blank, plain hires text,
; SCREEN_A shown. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
ending_screen
        jsr video_off
        lda #0
        sta flip_pending
        jsr sprites_off
        lda #COL_BLACK
        sta BORDER
        sta BGCOL0
        lda #%00001000          ; hires (multicolour off), 40 columns, xscroll 0
        sta VIC_CTRL2
        lda #CHAR_BLANK         ; clear both buffers, all 25 rows
        ldx #0
-       sta SCREEN_A+$000,x
        sta SCREEN_A+$100,x
        sta SCREEN_A+$200,x
        sta SCREEN_A+$2e8,x
        sta SCREEN_B+$000,x
        sta SCREEN_B+$100,x
        sta SCREEN_B+$200,x
        sta SCREEN_B+$2e8,x
        inx
        bne -
        lda #D018_A
        sta VIC_MEM
        lda #0
        sta front_buf
        rts

!zone roll_enter
; -----------------------------------------------------------------------------
; roll_enter: start the credits roll. Colour RAM is a fixed gradient by row,
; so the text fades in at the bottom and out at the top as it passes.
; -----------------------------------------------------------------------------
roll_enter
        jsr ending_screen
!ifdef PROFILE {
        jsr prof_reset          ; test hook: measure this part on its own
}
        ldx #ROWS - 1           ; colour RAM: gradient per row
-       lda roll_colours,x
        sta zp_tmp0
        txa
        pha
        jsr colram_row          ; row X -> zp_ptr0
        lda zp_tmp0
        ldy #COLS - 1
--      sta (zp_ptr0),y
        dey
        bpl --
        pla
        tax
        dex
        bpl -
        jsr fx_init             ; the star chars; six P-38s escort the text
        jsr fx_escort_start
        lda #<credits
        sta roll_ptr
        lda #>credits
        sta roll_ptr+1
        lda #0
        sta roll_line
        sta roll_k
        lda #GM_ROLL
        sta game_mode
        lda #ROLL_D011
        sta VIC_CTRL1           ; display on
        rts

; colram_row: zp_ptr0 = COLRAM + X * 40. Clobbers A.
colram_row
        lda #<COLRAM
        sta zp_ptr0
        lda #>COLRAM
        sta zp_ptr0+1
        cpx #0
        beq +++
        txa
        pha
-       clc
        lda zp_ptr0
        adc #COLS
        sta zp_ptr0
        bcc +
        inc zp_ptr0+1
+       dex
        bne -
        pla
        tax
+++     rts

; Row colours, top to bottom: fade in from the bottom, out at the top.
roll_colours
        !byte COL_DGREY, COL_DGREY, COL_GREY, COL_GREY, COL_LGREY, COL_LGREY
        !fill ROWS - 12, COL_WHITE
        !byte COL_LGREY, COL_LGREY, COL_GREY, COL_GREY, COL_DGREY, COL_DGREY

!zone roll_update
; -----------------------------------------------------------------------------
; roll_update: once per frame (lower border). The text moves up one pixel
; every 2 frames: $D011's fine scroll counts 7 down to 0 over a 16-frame step;
; meanwhile the hidden buffer gets everything one row higher plus the next
; line at the bottom; at the end of the step the IRQ shows it and puts the
; fine scroll back to 7 in the same instant (next_d011), so it never jumps.
; TIMING: ~4000 cycles on copy frames, otherwise tiny.
; -----------------------------------------------------------------------------
roll_update
        jsr fx_escort           ; the P-38s (and mux_build)
        lda roll_k              ; fine scroll = 7 - roll_k / 2
        lsr
        eor #%00000111
        ora #ROLL_D011 & %11111000
        sta VIC_CTRL1
        ldx roll_k
        beq .next
        cpx #ROLL_SLICES + 1
        bcs .notcopy
        dex                     ; frames 1-4: copy slice 0-3
        jsr roll_copy_slice
        jmp .next
.notcopy
        cpx #ROLL_SLICES + 1
        bne .notline
        jsr roll_new_line       ; frame 5: the new bottom line
        jmp .next
.notline
        cpx #ROLL_STEP - 1
        bne .next
        lda front_buf           ; last frame: swap at the next IRQ
        eor #1
        sta front_buf
        tax
        lda d018_tab,x
        sta next_d018
        lda #ROLL_D011
        sta next_d011
        lda #1
        sta flip_pending
        lda roll_line           ; all rolled off the top?
        cmp #CREDIT_LINES + ROLL_ROWS_OUT
        bcc .next
        lda #0
        sta next_d011
        jmp finale_enter
.next   inc roll_k
        lda roll_k
        cmp #ROLL_STEP
        bcc +
        lda #0
        sta roll_k
+       rts

; roll_copy_slice: hidden buffer rows 6X..6X+5 <- shown buffer rows +1.
roll_copy_slice
        lda #0
        sta zp_ptr0+1
        txa                     ; offset = X * 6 rows * 40 = X * 240
        beq +
        lda #0
-       clc
        adc #240
        bcc ++
        inc zp_ptr0+1
++      dex
        bne -
+       sta zp_ptr0             ; zp_ptr0 = offset (16-bit)
        lda front_buf
        bne .ba
        clc                     ; A shown: src A + COLS, dst B
        lda zp_ptr0
        adc #<(SCREEN_B)
        sta zp_ptr1
        lda zp_ptr0+1
        adc #>(SCREEN_B)
        sta zp_ptr1+1
        clc
        lda zp_ptr0
        adc #<(SCREEN_A + COLS)
        sta zp_ptr0
        lda zp_ptr0+1
        adc #>(SCREEN_A + COLS)
        sta zp_ptr0+1
        jmp .copy
.ba     clc                     ; B shown: src B + COLS, dst A
        lda zp_ptr0
        adc #<(SCREEN_A)
        sta zp_ptr1
        lda zp_ptr0+1
        adc #>(SCREEN_A)
        sta zp_ptr1+1
        clc
        lda zp_ptr0
        adc #<(SCREEN_B + COLS)
        sta zp_ptr0
        lda zp_ptr0+1
        adc #>(SCREEN_B + COLS)
        sta zp_ptr0+1
.copy   ldy #0
-       lda (zp_ptr0),y
        sta (zp_ptr1),y
        iny
        cpy #6 * COLS
        bne -
        rts

; roll_new_line: the hidden buffer's bottom row gets the next credits line,
; or blanks once the text has run out.
roll_new_line
        ldx front_buf           ; hidden buffer's last row
        lda .bot_lo,x
        sta zp_ptr1
        lda .bot_hi,x
        sta zp_ptr1+1
        ldy #COLS - 1
        lda roll_line
        cmp #CREDIT_LINES
        bcs .blank
-       lda (roll_ptr),y
        cmp #CHAR_BLANK
        bne +
        jsr fx_roll_cell        ; blank: maybe a star
+       sta (zp_ptr1),y
        dey
        bpl -
        clc
        lda roll_ptr
        adc #COLS
        sta roll_ptr
        bcc +
        inc roll_ptr+1
+       inc roll_line
        rts
.blank
-       jsr fx_roll_cell        ; blank, with stars
        sta (zp_ptr1),y
        dey
        bpl -
        inc roll_line
        rts
.bot_lo !byte <(SCREEN_B + (ROWS-1)*COLS), <(SCREEN_A + (ROWS-1)*COLS)
.bot_hi !byte >(SCREEN_B + (ROWS-1)*COLS), >(SCREEN_A + (ROWS-1)*COLS)

!zone finale_enter
; -----------------------------------------------------------------------------
; finale_enter: the final screen: final score, the big scroller, then
; "press fire" -> title.
; -----------------------------------------------------------------------------
finale_enter
        jsr ending_screen
!ifdef PROFILE {
        jsr prof_reset          ; test hook: measure this part on its own
}
        lda #COL_WHITE          ; colour RAM: white (the strip rows are
        ldx #0                  ;   recoloured every frame)
-       sta COLRAM+$000,x
        sta COLRAM+$100,x
        sta COLRAM+$200,x
        sta COLRAM+$2e8,x
        inx
        bne -
        +print_both SCORE_ROW, (COLS - .label_len - 6) / 2, .label, .label_len
        jsr score_to_digits
        +print_both SCORE_ROW, (COLS - .label_len - 6) / 2 + .label_len, score_digits, 6
        ldx #COLS - 1           ; the strip: its own 80 chars
-       txa
        clc
        adc #STRIP_TOP
        sta SCREEN_A + SCROLL_ROW*COLS,x
        sta SCREEN_B + SCROLL_ROW*COLS,x
        adc #COLS
        sta SCREEN_A + (SCROLL_ROW+1)*COLS,x
        sta SCREEN_B + (SCROLL_ROW+1)*COLS,x
        dex
        bpl -
        lda #0                  ; blank the strip's char data (640 bytes)
        ldx #0
-       sta CHARSET + STRIP_TOP*8,x
        sta CHARSET + STRIP_TOP*8 + $100,x
        sta CHARSET + STRIP_TOP*8 + $180,x
        inx
        bne -
        lda #<scroll_text
        sta sc_ptr
        lda #>scroll_text
        sta sc_ptr+1
        jsr scroll_next_char
        lda #GO_DELAY
        sta end_timer
        jsr fx_init             ; fireworks and stars (ending_fx.asm)
        lda #<fx_finale_rows
        ldx #>fx_finale_rows
        jsr fx_stars
        lda #GM_FINALE
        sta game_mode
        lda #FINALE_D011
        sta VIC_CTRL1
        rts
.label  !scr "final score "
.label_len = * - .label

!zone finale_update
; -----------------------------------------------------------------------------
; finale_update: once per frame. Scroll 2 pixels, cycle the strip colours,
; then wait for fire.
; TIMING: ~8500 cycles (two 1-pixel shifts of the 640-byte strip).
; -----------------------------------------------------------------------------
finale_update
        jsr fx_fireworks        ; (and mux_build)
        jsr fx_twinkle
        jsr scroll_shift
        jsr scroll_shift
        inc col_phase           ; rainbow ripples to the left
        ldy #COLS - 1
-       tya
        clc
        adc col_phase
        lsr                     ; 2 columns per colour
        and #%00001111
        tax
        lda rainbow,x
        sta COLRAM + SCROLL_ROW*COLS,y
        sta COLRAM + (SCROLL_ROW+1)*COLS,y
        dey
        bpl -
        lda end_timer
        beq .ready
        dec end_timer
        bne .wait
        +print_both PRESS_ROW, (COLS - .press_len) / 2, .press, .press_len
.wait   rts
.ready  jsr read_input
        lda input_new
        and #INP_FIRE
        beq .wait
        jmp title_enter
.press  !scr "press fire"
.press_len = * - .press

rainbow !byte COL_RED, COL_LRED, COL_ORANGE, COL_YELLOW, COL_LGREEN, COL_GREEN
        !byte COL_CYAN, COL_LBLUE, COL_BLUE, COL_PURPLE, COL_LBLUE, COL_CYAN
        !byte COL_GREEN, COL_LGREEN, COL_YELLOW, COL_ORANGE

!zone scroll_shift
; -----------------------------------------------------------------------------
; scroll_shift: move the big scroll text one pixel left. The strip is 40
; chars x 16 pixel rows; each pixel row is a 40-byte chain shifted with ROL
; from the right end, with the next pixel of the current letter rolled in.
; Letters are the ROM font doubled (16x16): glyph row r feeds pixel rows 2r
; and 2r+1, and each glyph column is fed for 2 shifts.
; TIMING: ~4200 cycles (640 ROLs, fully unrolled).
; -----------------------------------------------------------------------------
!macro strip_row .p {
        !if .p < 8 {
                !set .base = CHARSET + STRIP_TOP * 8 + .p
        } else {
                !set .base = CHARSET + STRIP_BOT * 8 + .p - 8
        }
        lda sc_bits + (.p >> 1) ; this glyph row's next pixel -> carry
        asl
        !for .i, 0, COLS - 1 {
                rol .base + (COLS - 1 - .i) * 8
        }
}
scroll_shift
!for .p, 0, 15 {
        +strip_row .p
}
        inc sc_col              ; feed each glyph column for 2 shifts
        lda sc_col
        and #1
        bne +
        !for .r, 0, 7 {
        asl sc_bits + .r        ; next glyph column
        }
        lda sc_col
        cmp #16
        bne +
        jmp scroll_next_char
+       rts

; scroll_next_char: load the next letter of the scroll text into sc_bits.
scroll_next_char
        ldy #0
        lda (sc_ptr),y
        cmp #SCROLL_END
        bne +
        lda #<scroll_text       ; loop
        sta sc_ptr
        lda #>scroll_text
        sta sc_ptr+1
        lda (sc_ptr),y
+       sta zp_ptr0             ; glyph = CHARSET + code * 8 (ROM font copy)
        lda #0
        sta zp_ptr0+1
        asl zp_ptr0
        rol zp_ptr0+1
        asl zp_ptr0
        rol zp_ptr0+1
        asl zp_ptr0
        rol zp_ptr0+1
        clc
        lda zp_ptr0
        adc #<CHARSET
        sta zp_ptr0
        lda zp_ptr0+1
        adc #>CHARSET
        sta zp_ptr0+1
        ldy #7
-       lda (zp_ptr0),y
        sta sc_bits,y
        dey
        bpl -
        lda #0
        sta sc_col
        inc sc_ptr
        bne +
        inc sc_ptr+1
+       rts
