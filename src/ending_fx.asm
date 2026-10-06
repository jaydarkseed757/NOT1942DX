; =============================================================================
; ending_fx.asm - the ending's show: fireworks, stars, and the P-38s
; =============================================================================
;
; Decoration only: the ending's text (data/ending.asm) is unchanged.
;   fireworks  rockets (the enemy-shot sprite) climb from the bottom and
;              burst into the explosion sequence, X+Y expanded, in one bright
;              colour each, on a fixed schedule (fw_*_t). Victory screen and
;              final screen. They use the enemy slots: the ending has none.
;   stars      two tiny hires chars (STAR_CHAR, STAR_CHAR + 1) scattered over
;              the victory and final screens, twinkling (their colour RAM
;              cycles); on the credits roll they scroll up with the text and
;              fade with its row colours (roll_new_line puts them in the blank
;              cells of each new line)
;   the P-38   on the victory screen it weaves up the middle and away; on the
;              roll six of them escort the text, three each side
; Nothing is random: the "random" positions come from an 8-bit LFSR with a
; fixed seed.
; TIMING: fireworks ~60 cycles a slot, stars ~25 a star, plus mux_build.
; =============================================================================

STAR_CHAR  = 224                ; 224-225: after the scroller's strip (144-223)
STARS      = 24                 ; twinkling stars on a static screen
FW_SLOTS   = 5                  ; fireworks at once (enemy slots 0-4)
FW_EVERY   = 14                 ; frames between launches
FW_RISE    = 4                  ; a rocket's climb, pixels a frame
FW_START_Y = 250                ; it starts at the bottom
FW_SHAPE   = 4                  ; frames per explosion shape
FW_BURST   = EXPL_SHAPES * FW_SHAPE
SHIP_SLOT  = SLOT_PLAYER
ESCORTS    = 6                  ; the roll's P-38s (enemy slots 0-5)

!if STAR_CHAR + 2 > 256 { !error "star chars don't fit in the charset" }
!if FW_SLOTS > ENEMY_COUNT | ESCORTS > ENEMY_COUNT { !error "ending_fx: more sprites than enemy slots" }
!if STARS != FX_STARS { !error "ending_fx: FX_STARS in bss.asm must be STARS" }

fx_lfsr   !byte $5a             ; the pseudo-random byte
fx_frame  !byte 0
fw_next   !byte 0               ; the next schedule entry
fw_wait   !byte 0               ; frames to the next launch

!zone fx_init
; -----------------------------------------------------------------------------
; fx_init: sprites on, nothing flying yet, the star chars defined. For a
; static ending screen, before video_on. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
fx_init
        jsr init_sprites
        ldx #ENEMY_COUNT - 1
        lda #0
-       sta fw_state,x
        dex
        bpl -
        sta fx_frame
        sta fw_next
        lda #20                 ; the first rocket soon
        sta fw_wait
        ldx #15                 ; the two star chars (hires)
-       lda .star_bits,x
        sta CHARSET + STAR_CHAR * 8,x
        dex
        bpl -
        rts
.star_bits
        !byte %00000000, %00000000, %00000000, %00011000   ; a dot
        !byte %00011000, %00000000, %00000000, %00000000
        !byte %00000000, %00001000, %00011100, %00001000   ; a small cross
        !byte %00000000, %00000000, %00000000, %00000000

; fx_lfsr_next: A = the next pseudo-random byte (Galois LFSR). Clobbers A.
fx_lfsr_next
        lda fx_lfsr
        lsr
        bcc +
        eor #$b8
+       sta fx_lfsr
        rts

!zone fx_stars
; -----------------------------------------------------------------------------
; fx_stars: scatter STARS stars over both buffers of a static screen, clear
; of the rows listed at (A low, X high: row numbers, $FF-ended) and of any
; text. Clobbers A, X, Y, zp_ptr0.
; -----------------------------------------------------------------------------
fx_stars
        sta .rows+1
        stx .rows+2
        lda #0
        sta zp_tmp1             ; stars placed
.try    jsr fx_lfsr_next        ; row: 1-24
        and #%00011111
        cmp #ROWS
        bcs .try
        cmp #PLAY_TOP
        bcc .try
        sta zp_tmp0
        ldx #0                  ; a text row?
.rows   lda $ffff,x             ; (self-modified: the row list)
        cmp #$ff
        beq .rowok
        cmp zp_tmp0
        beq .try
        inx
        bne .rows
.rowok  jsr fx_lfsr_next        ; column: 0-39
        and #%00111111
        cmp #COLS
        bcs .rowok
        ldx zp_tmp0             ; cell = row * 40 + column
        clc
        adc fx_row_lo,x
        sta zp_ptr0
        lda fx_row_hi,x
        adc #0
        sta zp_ptr0+1
        ldx zp_tmp1
        lda zp_ptr0
        sta fx_star_lo,x
        lda zp_ptr0+1
        sta fx_star_hi,x
        txa                     ; each its own twinkle phase
        asl
        asl
        asl
        sta fx_star_ph,x
        lda zp_ptr0+1           ; into both buffers (if the cell is blank)
        clc
        adc #>SCREEN_A
        sta zp_ptr0+1
        ldy #0
        lda (zp_ptr0),y
        cmp #CHAR_BLANK
        bne .try                ; text there: try again
        txa
        and #1
        clc
        adc #STAR_CHAR
        sta (zp_ptr0),y
        pha
        lda zp_ptr0+1
        clc
        adc #>(SCREEN_B - SCREEN_A)
        sta zp_ptr0+1
        pla
        sta (zp_ptr0),y
        inc zp_tmp1
        lda zp_tmp1
        cmp #STARS
        bne .try
        rts

; fx_twinkle: once a frame on a static screen: each star's colour RAM steps
; through fx_twinkle_t at its own phase. Clobbers A, X, Y, zp_ptr0.
fx_twinkle
        ldx #STARS - 1
-       lda fx_star_lo,x
        sta zp_ptr0
        lda fx_star_hi,x
        clc
        adc #>COLRAM
        sta zp_ptr0+1
        inc fx_star_ph,x
        lda fx_star_ph,x
        lsr
        lsr
        and #%00001111
        tay
        lda fx_twinkle_t,y
        ldy #0
        sta (zp_ptr0),y
        dex
        bpl -
        rts

!zone fx_fireworks
; -----------------------------------------------------------------------------
; fx_fireworks: once a frame: launch on schedule, climb, burst. Then
; mux_build. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
fx_fireworks
        inc fx_frame
        dec fw_wait             ; --- a launch due? into the first free slot
        bne .slots
        lda #FW_EVERY
        sta fw_wait
        ldx #FW_SLOTS - 1
-       lda fw_state,x
        beq .launch
        dex
        bpl -
        bmi .slots              ; all busy: this one's skipped
.launch ldy fw_next
        lda fw_x_t,y
        sta spr_xh + SLOT_ENEMY0,x
        lda fw_y_t,y
        sta fw_top,x
        lda fw_col_t,y
        sta fw_col,x
        lda #FW_START_Y
        sta spr_y + SLOT_ENEMY0,x
        lda #PTR_EBULLET        ; the rocket
        sta spr_ptr + SLOT_ENEMY0,x
        lda #COL_WHITE
        sta spr_col + SLOT_ENEMY0,x
        lda #0
        sta spr_exp + SLOT_ENEMY0,x
        lda #1
        sta fw_state,x
        sta spr_on + SLOT_ENEMY0,x
        iny
        cpy #FW_SCHEDULE
        bcc +
        ldy #0
+       sty fw_next
.slots  ldx #FW_SLOTS - 1       ; --- each slot ---
.slot   lda fw_state,x
        beq .next
        cmp #1
        bne .burst
        lda spr_y + SLOT_ENEMY0,x       ; climbing
        sec
        sbc #FW_RISE
        sta spr_y + SLOT_ENEMY0,x
        cmp fw_top,x
        bcs .next
        lda #2                  ; up there: burst, centred on the rocket
        sta fw_state,x
        lda #FW_BURST
        sta fw_timer,x
        lda #$ff
        sta spr_exp + SLOT_ENEMY0,x
        lda spr_xh + SLOT_ENEMY0,x
        sec
        sbc #6
        sta spr_xh + SLOT_ENEMY0,x
        lda spr_y + SLOT_ENEMY0,x
        sec
        sbc #12
        sta spr_y + SLOT_ENEMY0,x
.burst  dec fw_timer,x          ; the explosion sequence, its own colour (a
        beq .done               ;   white flash first)
        lda fw_timer,x
        eor #$ff
        clc
        adc #FW_BURST + 1       ; frames into the burst: 0..FW_BURST - 1
        lsr
        lsr                     ; / FW_SHAPE
        tay
        lda expl_ptr,y
        sta spr_ptr + SLOT_ENEMY0,x
        lda fw_col,x
        cpy #0
        bne +
        lda #COL_WHITE
+       sta spr_col + SLOT_ENEMY0,x
        jmp .next
.done   lda #0
        sta fw_state,x
        sta spr_on + SLOT_ENEMY0,x
        sta spr_exp + SLOT_ENEMY0,x
.next   dex
        bpl .slot
        jmp mux_build
!if FW_SHAPE != 4 { !error "fx_fireworks: the shape step assumes 4 frames a shape" }

!zone fx_ship
; -----------------------------------------------------------------------------
; fx_ship_start / fx_ship: the victory pass: the P-38 weaves up the middle of
; the screen and away. Clobbers A, X.
; -----------------------------------------------------------------------------
fx_ship_start
        lda #PTR_SHIP
        sta spr_ptr + SHIP_SLOT
        lda #COL_PLAYER
        sta spr_col + SHIP_SLOT
        lda #255
        sta spr_y + SHIP_SLOT
        lda #1
        sta spr_on + SHIP_SLOT
        rts
fx_ship
        lda spr_on + SHIP_SLOT
        beq .out
        lda fx_frame            ; up 5 pixels every 4 frames
        and #%00000011
        bne +
        lda spr_y + SHIP_SLOT
        sec
        sbc #5
        sta spr_y + SHIP_SLOT
        bcs +
        lda #0                  ; gone over the top
        sta spr_on + SHIP_SLOT
+       lda fx_frame            ; weaving: a 64-frame sway
        lsr
        lsr
        and #%00001111
        tax
        lda fx_sway,x
        clc
        adc #(SCREEN_X_MIN + SCREEN_X_MAX - 12) / 2
        sta spr_xh + SHIP_SLOT
.out    rts
fx_sway !for .i, 0, 15 { !byte int(16 * sin(float(.i) * 22.5 * 3.14159265358979 / 180)) & $ff }

!zone fx_escort
; -----------------------------------------------------------------------------
; fx_escort_start / fx_escort: the roll's P-38s, three each side of the text,
; climb into place from below, then bob gently. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
fx_escort_start
        jsr init_sprites
        lda #0
        sta fx_frame
        ldx #ESCORTS - 1
-       lda fx_esc_x,x
        sta spr_xh + SLOT_ENEMY0,x
        lda #FW_START_Y         ; below the screen at first
        sta spr_y + SLOT_ENEMY0,x
        lda #PTR_SHIP
        sta spr_ptr + SLOT_ENEMY0,x
        lda #COL_PLAYER
        sta spr_col + SLOT_ENEMY0,x
        lda #1
        sta spr_on + SLOT_ENEMY0,x
        dex
        bpl -
        rts
fx_escort
        inc fx_frame
        ldx #ESCORTS - 1
-       lda fx_frame            ; bob: its own phase
        lsr
        lsr
        clc
        adc fx_esc_ph,x
        and #%00001111
        tay
        lda fx_bob,y
        clc
        adc fx_esc_y,x
        sta zp_tmp0             ; where it wants to be
        lda spr_y + SLOT_ENEMY0,x
        cmp zp_tmp0
        beq +
        bcc ++                  ; (on station: just bob)
        sec                     ; still climbing into place
        sbc #2
        cmp zp_tmp0
        bcs +++
++      lda zp_tmp0
+++     sta spr_y + SLOT_ENEMY0,x
+       dex
        bpl -
        jmp mux_build
fx_esc_x  !byte 12, 20, 12, 148, 140, 148   ; clear of the centred text
fx_esc_y  !byte 70, 110, 150, 90, 130, 170
fx_esc_ph !byte 0, 5, 10, 3, 8, 13
fx_bob    !for .i, 0, 15 { !byte int(3 * sin(float(.i) * 22.5 * 3.14159265358979 / 180) + 3) }

; fx_roll_cell: A = a blank cell for the credits roll: mostly CHAR_BLANK,
; sometimes a star (~1 in 32). Clobbers A.
fx_roll_cell
        jsr fx_lfsr_next
        cmp #8
        bcs +
        and #1
        adc #STAR_CHAR          ; (carry clear)
        rts
+       lda #CHAR_BLANK
        rts

; The rows each static screen keeps clear of stars (its text), $FF-ended.
fx_victory_rows !byte HUD_ROW, TXT_ROW_A, TXT_ROW_B, TXT_ROW_C, $ff
fx_finale_rows  !byte SCORE_ROW, SCROLL_ROW, SCROLL_ROW + 1, PRESS_ROW, $ff

; --- tables ---
fx_row_lo !for .r, 0, ROWS - 1 { !byte <(.r * COLS) }
fx_row_hi !for .r, 0, ROWS - 1 { !byte >(.r * COLS) }
fx_twinkle_t !byte COL_WHITE, COL_WHITE, COL_LGREY, COL_GREY, COL_DGREY, COL_BLACK, COL_BLACK, COL_DGREY
             !byte COL_GREY, COL_LGREY, COL_WHITE, COL_LGREY, COL_GREY, COL_GREY, COL_LGREY, COL_WHITE

; The fireworks' schedule: where each goes up, how high it bursts, its
; colour. Bursts keep above and below the screens' text.
fw_x_t   !byte 30, 120, 70, 150, 40, 100, 140, 20, 90, 60, 130, 50, 110, 25, 80, 145
fw_y_t   !byte 72, 205, 62, 218, 82, 195, 66, 225, 76, 208, 58, 198, 86, 214, 68, 202
fw_col_t !byte COL_RED, COL_YELLOW, COL_CYAN, COL_LGREEN, COL_PURPLE, COL_WHITE, COL_ORANGE, COL_LBLUE
         !byte COL_LRED, COL_YELLOW, COL_GREEN, COL_CYAN, COL_LGREEN, COL_PURPLE, COL_ORANGE, COL_WHITE
FW_SCHEDULE = fw_y_t - fw_x_t
!if fw_col_t - fw_y_t != FW_SCHEDULE { !error "ending_fx: the schedule tables differ in length" }
