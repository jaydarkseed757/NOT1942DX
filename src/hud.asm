; =============================================================================
; hud.asm - the status line: score, lives, boss bar, messages
; =============================================================================
;
; Two views of the same information:
;   HUD_BUF   40 screen codes, shown in row 0 of the static text screens
;             (level intro, GAME OVER, victory) by hud_flush.
;   sprites   in play, a floating sprite HUD (multiplexed like everything
;             else): the score top left and the ships left top right, the
;             boss's health bar top centre during a fight, and big messages
;             ("BOSS!", "LEVEL CLEAR") in the middle of the screen. All are
;             hires sprites whose shapes are drawn here, from the charset's
;             font (data/sprites.asm reserves 8 blank shapes, PTR_HUD+).
; The hud_draw_* / hud_show_* calls update HUD_BUF and mark the sprite
; shapes to redraw (hud_dirty); hud_update redraws them once per frame,
; before mux_build.
;
; HUD_BUF layout (columns): 0-11 "score 000000", 14-24 "level n" / "boss" /
;                   "level clear", 31-37 "lives n", 39 DEBUG
;                   dropped-spawn digit
;
; TIMING: a score digit costs ~120 cycles to draw, and only digits that
; changed are drawn; the boss bar ~250, only when a block goes; a message
; ~300 to set up, then one char (~120) per frame, typewriter style. An idle
; frame costs ~40.
; =============================================================================

HUD_SCORE_COL = 0
HUD_MID_COL   = 14              ; 11 columns for the level / status text
HUD_LIVES_COL = 31

HUD_D_SCORE   = 1               ; hud_dirty bits
HUD_D_LIVES   = 2
HUD_D_BAR     = 4
HUD_D_MSG     = 8
HUD_MSG_BOSS  = 1               ; hud_msg
HUD_MSG_CLEAR = 2

; Sprite HUD geometry. The top sprites hold their glyphs in rows 13-20, so
; at HUD_Y they show on lines 57-64 while their 21 lines end early (line
; 65), freeing the hardware sprites for whatever comes next.
HUD_GLYPH_ROW = 13
HUD_Y         = PLAY_Y_MIN + 2 - HUD_GLYPH_ROW
HUD_MSG_Y     = 128             ; message: glyphs in rows 0-7
HUD_MSG_MAX   = 12              ; chars (3 per sprite, 4 sprites)
HUD_BOSS_FRAMES = 100           ; "BOSS!" shows for 2 s
PTR_HUD_SCORE = PTR_HUD
PTR_HUD_LIVES = PTR_HUD + 2
PTR_HUD_BAR   = PTR_HUD + 3
PTR_HUD_MSG   = PTR_HUD + 4
SHAPE_ADDR    = SPRITES + (PTR_HUD - SPR_PTR0) * 64   ; first HUD shape
COL_HUD       = COL_WHITE
COL_HUD_LIVES = COL_LGREY
COL_HUD_BAR   = COL_LRED

; +print_both ROW, COL, TEXT, LEN : copy LEN screen codes to both buffers.
; Clobbers A, X.
!macro print_both .row, .col, .text, .len {
        ldx #.len - 1
-       lda .text,x
        sta SCREEN_A + .row*COLS + .col,x
        sta SCREEN_B + .row*COLS + .col,x
        dex
        bpl -
}

; +print_hud COL, TEXT, LEN : copy LEN screen codes into HUD_BUF.
; Clobbers A, X.
!macro print_hud .col, .text, .len {
        ldx #.len - 1
-       lda .text,x
        sta HUD_BUF + .col,x
        dex
        bpl -
}

!zone hud_flush
; -----------------------------------------------------------------------------
; hud_flush: show HUD_BUF in row 0 of both buffers, white hires text.
; For static screens only. Clobbers A, X.
; -----------------------------------------------------------------------------
hud_flush
        ldx #COLS-1
-       lda HUD_BUF,x
        sta SCREEN_A + HUD_ROW*COLS,x
        sta SCREEN_B + HUD_ROW*COLS,x
        lda #CRAM_HUD
        sta COLRAM + HUD_ROW*COLS,x
        dex
        bpl -
        rts

; hud_clear: blank the whole HUD (boot). Clobbers A, X.
hud_clear
        lda #CHAR_BLANK
        ldx #COLS-1
-       sta HUD_BUF,x
        dex
        bpl -
        rts

!zone hud_draw_score
; -----------------------------------------------------------------------------
; hud_draw_score: "score 000000". Clobbers A, X, Y.
; -----------------------------------------------------------------------------
hud_draw_score
        +print_hud HUD_SCORE_COL, .label, 6
        jsr score_to_digits
        +print_hud HUD_SCORE_COL + 6, score_digits, 6
        lda #HUD_D_SCORE
        jmp hud_mark
.label  !scr "score "

!zone hud_draw_lives
; -----------------------------------------------------------------------------
; hud_draw_lives: "lives n", n = ships left including the one in play.
; Clobbers A, X.
; -----------------------------------------------------------------------------
hud_draw_lives
        +print_hud HUD_LIVES_COL, .label, 6
        lda lives
        ora #'0'                ; screen codes for digits are $30-$39
        sta HUD_BUF + HUD_LIVES_COL + 6
        lda #HUD_D_LIVES
        jmp hud_mark
.label  !scr "lives "

!zone hud_draw_level
; hud_draw_level: "  level n  " in the middle of the HUD. Clobbers A, X.
hud_draw_level
        +print_hud HUD_MID_COL, .label, 11
        lda level
        clc
        adc #'1'
        sta HUD_BUF + HUD_MID_COL + 8
        rts
.label  !scr "  level    "

; hud_show_boss / hud_show_clear: status text in the middle of the HUD,
; and the matching message in play. hud_clear_mid: neither, and no bar.
; Clobbers A, X.
hud_show_boss
        +print_hud HUD_MID_COL, .boss, 11
        lda #HUD_BOSS_FRAMES    ; shown for a while, even if the boss (and
        sta hud_msg_timer       ;   its health bar) is there at once
        lda #HUD_MSG_BOSS
        bne hud_message
.boss   !scr "   boss!   "
hud_show_clear
        +print_hud HUD_MID_COL, .clear, 11
        jsr mux_pins_changed
        lda #0                  ; the bar goes, the message comes and stays
        sta spr_on + SLOT_HUD_BAR
        sta hud_msg_timer
        lda #HUD_MSG_CLEAR
        bne hud_message
.clear  !scr "level clear"
hud_clear_mid
        +print_hud HUD_MID_COL, .blank, 11
        jsr mux_pins_changed
        lda #0
        sta spr_on + SLOT_HUD_BAR
        sta hud_msg_timer
        ; (fall through: no message)
hud_message
        sta hud_msg
        lda #HUD_D_MSG
        ; (fall through)
hud_mark
        ora hud_dirty
        sta hud_dirty
        rts
.blank  !scr "           "

!zone hud_draw_boss_hp
; -----------------------------------------------------------------------------
; hud_draw_boss_hp: "boss " + a bar of BAR_BLOCKS blocks in the middle of
; the HUD; in play, the bar sprite (and no message). Blocks = HP /
; boss_t_hp_block, rounded up (repeated subtraction; HP is small).
; Clobbers A, X, Y.
; -----------------------------------------------------------------------------
hud_draw_boss_hp
        +print_hud HUD_MID_COL, .label, 5
        ldy boss_idx
        lda boss_hp
        ldx #0                  ; X = blocks
-       cmp #1
        bcc +                   ; nothing left
        inx
        sec
        sbc boss_t_hp_block,y
        bcs -                   ; (borrow = went below zero: done)
+       stx zp_tmp0
        lda spr_on + SLOT_HUD_BAR
        bne +
        lda #1                  ; the bar comes on (a pinned slot)
        sta spr_on + SLOT_HUD_BAR
        jsr mux_pins_changed
+       cpx hud_bar_n           ; redraw the bar only when a block goes
        beq +
        stx hud_bar_n
        lda #HUD_D_BAR
        jsr hud_mark
+
        ldx #0
-       lda #QUAD_BASE + 15     ; solid block
        cpx zp_tmp0
        bcc +
        lda #CHAR_BLANK
+       sta HUD_BUF + HUD_MID_COL + 5,x
        inx
        cpx #BAR_BLOCKS
        bne -
        rts
.label  !scr "boss "

!zone hud_init
; -----------------------------------------------------------------------------
; hud_init: place the sprite HUD for a level (after init_sprites) and mark
; everything to draw. Score and lives on, bar and message off.
; Clobbers A, X.
; -----------------------------------------------------------------------------
hud_init
        ldx #HUD_SLOTS - 1
-       lda #0                  ; hires
        sta spr_mc + SLOT_HUD0,x
        lda .ptr,x
        sta spr_ptr + SLOT_HUD0,x
        lda .x,x
        sta spr_xh + SLOT_HUD0,x
        lda .y,x
        sta spr_y + SLOT_HUD0,x
        lda .col,x
        sta spr_col + SLOT_HUD0,x
        lda .on,x
        sta spr_on + SLOT_HUD0,x
        dex
        bpl -
        jsr mux_pins_changed
        lda #0
        sta hud_msg
        sta hud_msg_timer
        lda #$ff                ; draw everything: no score digit and no bar
        sta hud_dirty           ;   is shown yet
        sta hud_bar_n
        ldx #5
-       sta hud_prev,x
        dex
        bpl -
        rts

; per HUD slot: score 0-1, lives, bar, message 0-3 (message X is set when
; its text is drawn)
.ptr    !byte PTR_HUD_SCORE, PTR_HUD_SCORE + 1, PTR_HUD_LIVES, PTR_HUD_BAR
        !byte PTR_HUD_MSG, PTR_HUD_MSG + 1, PTR_HUD_MSG + 2, PTR_HUD_MSG + 3
.x      !byte SCREEN_X_MIN + 1, SCREEN_X_MIN + 13
        !byte SCREEN_X_MAX - 12 - 1
        !byte (SCREEN_X_MIN + SCREEN_X_MAX - 12) / 2
        !byte 0, 0, 0, 0
.y      !byte HUD_Y, HUD_Y, HUD_Y, HUD_Y
        !byte HUD_MSG_Y, HUD_MSG_Y, HUD_MSG_Y, HUD_MSG_Y
.col    !byte COL_HUD, COL_HUD, COL_HUD_LIVES, COL_HUD_BAR
        !byte COL_YELLOW, COL_YELLOW, COL_YELLOW, COL_YELLOW
.on     !byte 1, 1, 1, 0, 0, 0, 0, 0

!zone hud_update
; -----------------------------------------------------------------------------
; hud_update: once per play frame, before mux_build. Redraws the shapes that
; changed and cycles the message colours. Clobbers A, X, Y, zp_ptr0, zp_ptr1.
; -----------------------------------------------------------------------------
hud_update
        lda hud_msg_timer       ; a timed message runs out?
        beq +
        dec hud_msg_timer
        bne +
        lda #0
        jsr hud_message
+       lda hud_dirty
        bne +
        jmp .type
+       lsr hud_dirty           ; HUD_D_SCORE
        bcc .lives
        ; --- score: 6 digits, 3 per sprite; only the ones that changed ---
        lda #<(SHAPE_ADDR + 0*64 + HUD_GLYPH_ROW*3)
        sta zp_ptr0
        lda #>(SHAPE_ADDR + 0*64 + HUD_GLYPH_ROW*3)
        sta zp_ptr0+1
        lda #<score_digits
        sta zp_ptr1
        lda #>score_digits
        sta zp_ptr1+1
        ldx #5
-       lda score_digits,x
        cmp hud_prev,x
        beq +
        sta hud_prev,x
        txa
        pha
        jsr hud_text_at
        pla
        tax
+       dex
        bpl -

.lives  lsr hud_dirty           ; HUD_D_LIVES
        bcc .bar
        ; --- lives: one ship icon per ship left, up to 3 ---
        ldx #0                  ; X = icon (byte column)
-       ldy #0                  ; Y = glyph row
        txa
        clc
        adc #HUD_GLYPH_ROW*3
        sta hud_off
--      lda #0
        cpx lives
        bcs +
        lda .ship,y
+       sty hud_i
        ldy hud_off
        sta SHAPE_ADDR + 2*64,y
        iny
        iny
        iny
        sty hud_off
        ldy hud_i
        iny
        cpy #8
        bne --
        inx
        cpx #3
        bne -

.bar    lsr hud_dirty           ; HUD_D_BAR
        bcc .msg
        ; --- boss bar: BAR_BLOCKS blocks of 4 pixels (%1110), 2 per byte.
        ; Its top and bottom rows are always solid; the 4 rows between show
        ; empty blocks hollow (%1010). ---
        ldx #2                  ; X = byte: blocks 2X (left) and 2X+1
-       txa
        asl
        tay
        lda #$a0
        cpy hud_bar_n
        bcs +
        lda #$e0
+       sta hud_i
        iny
        lda #$0a
        cpy hud_bar_n
        bcs +
        lda #$0e
+       ora hud_i
        sta hud_gl,x
        dex
        bpl -
        ldx #2
-       lda #$ee
        sta SHAPE_ADDR + 3*64 + (HUD_GLYPH_ROW+1)*3,x
        sta SHAPE_ADDR + 3*64 + (HUD_GLYPH_ROW+6)*3,x
        lda hud_gl,x
        sta SHAPE_ADDR + 3*64 + (HUD_GLYPH_ROW+2)*3,x
        sta SHAPE_ADDR + 3*64 + (HUD_GLYPH_ROW+3)*3,x
        sta SHAPE_ADDR + 3*64 + (HUD_GLYPH_ROW+4)*3,x
        sta SHAPE_ADDR + 3*64 + (HUD_GLYPH_ROW+5)*3,x
        dex
        bpl -

.msg    lsr hud_dirty           ; HUD_D_MSG
        bcc .done
        ; --- message: clear the 4 shapes' rows 0-7, draw it centred ---
        lda #0
        ldx #3*8 - 1
-       sta SHAPE_ADDR + 4*64 + 0*64,x
        sta SHAPE_ADDR + 4*64 + 1*64,x
        sta SHAPE_ADDR + 4*64 + 2*64,x
        sta SHAPE_ADDR + 4*64 + 3*64,x
        dex
        bpl -
        ldx #3                  ; all message sprites off ...
-       sta spr_on + SLOT_HUD_MSG,x
        dex
        bpl -
        sta hud_msg_len         ; (nothing to type yet)
        ldx hud_msg
        beq .done               ; ... and none to show
        lda .msg_lo - 1,x
        sta zp_ptr1
        lda .msg_hi - 1,x
        sta zp_ptr1+1
        lda .msg_len - 1,x
        sta hud_n
        clc                     ; sprites needed = (len + 2) / 3
        adc #2
        ldy #0
-       cmp #3
        bcc +
        sbc #3                  ; (carry set)
        iny
        bne -
+       sty hud_off
        lda hud_n               ; centred: len * 8 px = len * 4 half-X, so
        asl                     ;   the first sprite starts len * 2 left of
        sta hud_i               ;   the middle
        lda #(SCREEN_X_MIN + SCREEN_X_MAX) / 2
        sec
        sbc hud_i
        ldx #0
-       sta spr_xh + SLOT_HUD_MSG,x
        tay
        lda #1
        sta spr_on + SLOT_HUD_MSG,x
        tya
        clc
        adc #12                 ; next sprite, 24 px to the right
        inx
        cpx hud_off
        bne -
        lda #0                  ; typed out one char per frame (below)
        sta hud_msg_pos
        lda hud_n
        sta hud_msg_len
.done   lda #0
        sta hud_dirty

.type   lda hud_msg_pos         ; message chars still to type?
        cmp hud_msg_len
        bcs .colour
        ldx hud_msg
        lda .msg_lo - 1,x
        sta zp_ptr1
        lda .msg_hi - 1,x
        sta zp_ptr1+1
        lda #<(SHAPE_ADDR + 4*64)
        sta zp_ptr0
        lda #>(SHAPE_ADDR + 4*64)
        sta zp_ptr0+1
        ldx hud_msg_pos
        inc hud_msg_pos
        jsr hud_text_at

.colour lda hud_msg             ; message colours cycle every 4 frames
        beq .out
        lda frame_count
        lsr
        lsr
        and #7
        tax
        lda .cycle,x
        ldx #3
-       sta spr_col + SLOT_HUD_MSG,x
        dex
        bpl -
.out    rts

.ship   !byte %00011000         ; a mini twin-boom fighter, nose up
        !byte %00011000
        !byte %10111101
        !byte %11111111
        !byte %10100101
        !byte %10100101
        !byte %11100111
        !byte %00000000

.cycle  !byte COL_YELLOW, COL_WHITE, COL_YELLOW, COL_ORANGE
        !byte COL_RED, COL_ORANGE, COL_YELLOW, COL_WHITE
.msg_lo !byte <.t_boss, <.t_clear
.msg_hi !byte >.t_boss, >.t_clear
.msg_len !byte .t_boss_len, .t_clear_len
.t_boss  !scr "boss!"
.t_boss_len = * - .t_boss
.t_clear !scr "level clear"
.t_clear_len = * - .t_clear
!if .t_clear_len > HUD_MSG_MAX { !error "HUD message too long" }

!zone hud_text
; -----------------------------------------------------------------------------
; hud_text: draw X chars (screen codes at zp_ptr1) into hires sprite
; shapes: char i goes to shape i / 3, byte column i % 3, 8 rows from
; zp_ptr0 (the first shape's address + its first glyph row * 3). The glyphs
; come from the charset (font in chars 0-63). Clobbers A, X, Y.
; -----------------------------------------------------------------------------
hud_text
        stx hud_n
        ldx #0
        beq .char
; hud_text_at: the same for char X alone. Clobbers A, X, Y.
hud_text_at
        stx hud_n
        inc hud_n
.char   stx hud_i
        txa
        tay
        lda (zp_ptr1),y         ; screen code -> CHARSET + code * 8
        sta hud_src
        lda #0
        asl hud_src
        rol
        asl hud_src
        rol
        asl hud_src
        rol
        adc #>CHARSET           ; (carry clear; CHARSET is page aligned)
        sta hud_src+1
        ldy #7
-       lda (hud_src),y
        sta hud_gl,y
        dey
        bpl -
        ldx hud_i
        ldy .cell,x
        ldx #0
-       lda hud_gl,x
        sta (zp_ptr0),y
        iny
        iny
        iny
        inx
        cpx #8
        bne -
        ldx hud_i
        inx
        cpx hud_n
        bne .char
        rts
.cell   !for .i, 0, HUD_MSG_MAX - 1 { !byte (.i / 3) * 64 + .i % 3 }

!if <CHARSET != 0 { !error "hud_text: CHARSET must be page aligned" }
