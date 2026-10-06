; =============================================================================
; video.asm - VIC-II setup, screen buffers, colour RAM
; =============================================================================

!zone init_video
; -----------------------------------------------------------------------------
; init_video: select VIC bank 1, multicolour text mode, clear both buffers,
; set the palette from pal_* and fill colour RAM to match (see the colour
; RAM note in defs.asm). Stops the play scroller.
; -----------------------------------------------------------------------------
init_video
        lda #0
        sta scroll_d011         ; the IRQ stops writing $D011 (and so can't
        sta flip_pending        ;   switch the display back on) ...
        sta scroll_chase
        lda #D011_OFF           ; display OFF (bit4 = 0) until video_on, so
        sta VIC_CTRL1           ;   leftover RAM and the prefill never show
        lda #0
        sta SPR_ENABLE          ; sprites off until init_sprites
        lda #COL_BLACK
        sta BORDER
        lda pal_bg
        sta BGCOL0
        lda pal_mc1
        sta BGCOL1
        lda pal_mc2
        sta BGCOL2

        ; --- VIC bank 1: $DD00 bits 0-1 = %10 (values are inverted) ---
        lda CIA2_DDRA
        ora #%00000011          ; make sure bank-select bits are outputs
        sta CIA2_DDRA
        lda CIA2_PRA
        and #%11111100
        ora #VIC_BANK_BITS
        sta CIA2_PRA

        lda #D018_A             ; show SCREEN_A, charset at $4800
        sta VIC_MEM
        lda #0
        sta front_buf

        lda #%00011000          ; multicolour on, 40 columns, xscroll 0
        sta VIC_CTRL2

        ; --- clear both screen buffers (2 KB) to the blank char ---
        ; This also sets the sprite pointers ($x3F8-$x3FF) to CHAR_BLANK ($20),
        ; which is harmless while sprites are off. Real pointers are set in M3.
        lda #CHAR_BLANK
        ldx #0
.clr    sta SCREEN_A+$000,x
        sta SCREEN_A+$100,x
        sta SCREEN_A+$200,x
        sta SCREEN_A+$300,x
        sta SCREEN_B+$000,x
        sta SCREEN_B+$100,x
        sta SCREEN_B+$200,x
        sta SCREEN_B+$300,x
        inx
        bne .clr

        ; --- colour RAM: whole screen black multicolour, then the HUD row
        ; (play rebuilds it from CHAR_COL; static screens set their rows) ---
        lda #%00001000
        ldx #0
.cram   sta COLRAM+$000,x
        sta COLRAM+$100,x
        sta COLRAM+$200,x
        sta COLRAM+$2e8,x       ; overlaps; ends exactly at $DBE7
        inx
        bne .cram

        lda #CRAM_HUD
        ldx #COLS-1
.hudc   sta COLRAM+HUD_ROW*COLS,x
        dex
        bpl .hudc

        rts

!zone video_on
; -----------------------------------------------------------------------------
; video_on: enable the display once everything is drawn.
; -----------------------------------------------------------------------------
; (static screens; play turns the display on through scroll_d011)
video_on
        lda #D011_TEXT          ; display ON, 25 rows, yscroll 3, raster bit8 = 0
        sta VIC_CTRL1
        rts

; video_off: blank the display (border colour everywhere) while redrawing.
; Stops the play scroller first, or the IRQ would switch the display back on.
video_off
        lda #0
        sta scroll_d011
        lda #D011_OFF           ; display OFF, otherwise as video_on
        sta VIC_CTRL1
        rts

!zone init_char_col
; -----------------------------------------------------------------------------
; init_char_col: every char's colour RAM value to a default (black,
; multicolour); level_unpack then fills in the level's chars. With the test
; hook TEST_CHAR_COL every char gets (code & 7) + multicolour instead, and
; level_unpack keeps it. Clobbers A, X.
; -----------------------------------------------------------------------------
init_char_col
!ifdef TEST_CHAR_COL {
        ldx #0                  ; test hook (acme -DTEST_CHAR_COL=1): colour
-       txa                     ;   = char code & 7, so a colour RAM row that
        and #%00000111          ;   doesn't match its screen row shows at once
        ora #%00001000
        sta CHAR_COL,x
        inx
        bne -
        rts
} else {
        lda #%00001000          ; black, multicolour
        ldx #0
-       sta CHAR_COL,x
        inx
        bne -
        rts
}

; set_title_palette: the colours used by the title screen.
set_title_palette
        lda #PAL_OCEAN
        sta pal_bg
        lda #PAL_MC1
        sta pal_mc1
        lda #PAL_MC2
        sta pal_mc2
        rts
