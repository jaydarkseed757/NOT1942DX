; =============================================================================
; gameover.asm - text screens (GAME OVER, victory, level intro) and GAME OVER
; =============================================================================
;
; All three text screens share one layout on a cleared playfield, with the
; HUD (HUD_BUF: score / lives) in row 0. Text rows are hires white, so their
; colour RAM is set here; level_begin rebuilds colour RAM for play.
;
; When the last ship's explosion has played (player_state = PS_GAMEOVER) the
; main loop calls gameover_enter. After GO_DELAY frames "press fire" appears,
; and a fire PRESS returns to the title screen. No continue, no high scores.
; =============================================================================

GO_DELAY  = 100                 ; 2 s before fire is accepted, so a press made
                                ;   while dying can't skip the screen
TXT_ROW_A = 9                   ; heading
TXT_ROW_B = 11                  ; sub-heading
TXT_ROW_C = 13                  ; final score
TXT_ROW_D = 17                  ; "press fire" / "get ready"

!zone textscreen_enter
; -----------------------------------------------------------------------------
; textscreen_enter: stop the world, clear the playfield of both buffers,
; show the HUD in row 0 and colour the four text rows. Leaves the display
; OFF: the caller prints its text, then calls video_on.
; TIMING: rewriting both buffers takes more than a frame, hence display off.
; Clobbers A, X, Y.
; -----------------------------------------------------------------------------
textscreen_enter
        lda #0
        sta flip_pending        ; no scrolling from now on
        jsr sprites_off         ; all sprites off from the next frame
        jsr video_off

        lda #CHAR_BLANK
        ldx #PLAY_ROWS*COLS/4 - 1
-       sta SCREEN_A + PLAY_TOP*COLS + 0*PLAY_ROWS*COLS/4,x
        sta SCREEN_A + PLAY_TOP*COLS + 1*PLAY_ROWS*COLS/4,x
        sta SCREEN_A + PLAY_TOP*COLS + 2*PLAY_ROWS*COLS/4,x
        sta SCREEN_A + PLAY_TOP*COLS + 3*PLAY_ROWS*COLS/4,x
        sta SCREEN_B + PLAY_TOP*COLS + 0*PLAY_ROWS*COLS/4,x
        sta SCREEN_B + PLAY_TOP*COLS + 1*PLAY_ROWS*COLS/4,x
        sta SCREEN_B + PLAY_TOP*COLS + 2*PLAY_ROWS*COLS/4,x
        sta SCREEN_B + PLAY_TOP*COLS + 3*PLAY_ROWS*COLS/4,x
        dex
        cpx #$ff
        bne -

        lda #COL_WHITE
        ldx #COLS-1
-       sta COLRAM + TXT_ROW_A*COLS,x
        sta COLRAM + TXT_ROW_B*COLS,x
        sta COLRAM + TXT_ROW_C*COLS,x
        sta COLRAM + TXT_ROW_D*COLS,x
        dex
        bpl -
        jmp hud_flush           ; row 0 still holds playfield chars

!zone print_final_score
; print_final_score: "final score nnnnnn" centred on TXT_ROW_C.
print_final_score
        +print_both TXT_ROW_C, (COLS - .label_len - 6) / 2, .label, .label_len
        jsr score_to_digits
        +print_both TXT_ROW_C, (COLS - .label_len - 6) / 2 + .label_len, score_digits, 6
        rts
.label  !scr "final score "
.label_len = * - .label

!zone gameover_enter
; -----------------------------------------------------------------------------
; gameover_enter: switch to the GAME OVER screen (lower border).
; -----------------------------------------------------------------------------
gameover_enter
        lda #GM_OVER
        sta game_mode
        lda #GO_DELAY
        sta go_timer
        jsr hud_clear_mid       ; no "level clear" (or "boss") left in the HUD
        jsr textscreen_enter
        +print_both TXT_ROW_A, (COLS - .title_len) / 2, .title, .title_len
        jsr print_final_score
        jmp video_on

.title  !scr "game over"
.title_len = * - .title

!zone press_fire_update
; -----------------------------------------------------------------------------
; press_fire_update: GAME OVER and victory screens. After GO_DELAY frames
; show "press fire"; then a fire press returns to the title screen.
; -----------------------------------------------------------------------------
press_fire_update
        lda go_timer
        beq .ready
        dec go_timer
        bne .wait
        +print_both TXT_ROW_D, (COLS - .press_len) / 2, .press, .press_len
.wait   rts
.ready  lda input_new
        and #INP_FIRE
        beq .wait
        jmp title_enter

.press  !scr "press fire"
.press_len = * - .press
