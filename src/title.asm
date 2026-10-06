; =============================================================================
; title.asm - title screen (game_mode = GM_TITLE)
; =============================================================================
;
; Shown at boot and after GAME OVER. Plays the title song. A fire PRESS
; starts a new game (new_game switches to the game song).
;
; Layout (screen rows): 0 version (top right), 3-7 logo, 8-10 "DX", 12 "by jdc", ship bobbing around row 14, 19 "press fire to
; start" (blinking), 22 controls, 24 "m: music on/off" and "p: pause".
; Every TITLE_FLYBY frames a V of three fighters dives across the screen. M switches the music on or off for
; the whole session (music_off); sound effects play either way. Keys 1-4
; start a game at that level with its boss straight away (practice).
; Text is hires, so its colour RAM is set here; new_game -> init_video
; restores colour RAM for play.
; =============================================================================

LOGO_H          = 5             ; logo height in screen rows (data/title.asm
                                ;   is checked against this; the drawing loop
                                ;   needs it before the data is assembled)
DX_H            = 3             ; "DX" height in screen rows (data/title.asm)
TITLE_LOGO_ROW  = 3
TITLE_DX_ROW    = TITLE_LOGO_ROW + LOGO_H
TITLE_BY_ROW    = 12
TITLE_FLYBY     = 250           ; frames between flybys
TITLE_FLY_FIRST = 50            ; ...and before the first
TITLE_FLY_DY    = 2             ; their speed, pixels per frame
TITLE_PRESS_ROW = 19
TITLE_HELP_ROW  = 22
TITLE_KEYS_ROW  = 24
TITLE_MUSIC_COL = (COLS - TITLE_MUSIC_LEN - 3 - TITLE_PAUSE_LEN) / 2
TITLE_PAUSE_COL = TITLE_MUSIC_COL + TITLE_MUSIC_LEN + 3
TITLE_SHIP_Y    = 51 + 8 * 14   ; raster line: top of the ship near row 14
TITLE_BLINK     = %00010000     ; "press fire" on/off every 16 frames

!zone title_enter
; -----------------------------------------------------------------------------
; title_enter: build the title screen in both buffers and start its music.
; Called from the main loop's border phase (or at boot). Clobbers A, X, Y.
; -----------------------------------------------------------------------------
title_enter
        jsr set_title_palette
        jsr init_video          ; display off, clean screens, VIC set up
        jsr restore_quads       ; the logo's chars (a level may have used them)
        jsr init_input          ; a held fire button must be released first
        jsr init_sprites

        ; --- logo and DX rows, one colour each ---
!for .r, 0, LOGO_H - 1 {
        +print_both TITLE_LOGO_ROW + .r, (COLS - LOGO_W) / 2, title_logo + .r * LOGO_W, LOGO_W
        lda title_logo_cols + .r
        ldx #COLS - 1
-       sta COLRAM + (TITLE_LOGO_ROW + .r) * COLS,x
        dex
        bpl -
}
!for .r, 0, DX_H - 1 {
        +print_both TITLE_DX_ROW + .r, (COLS - DX_W) / 2, title_dx + .r * DX_W, DX_W
        lda title_dx_cols + .r
        ldx #COLS - 1
-       sta COLRAM + (TITLE_DX_ROW + .r) * COLS,x
        dex
        bpl -
}
        lda #TITLE_FLY_FIRST
        sta title_fly_timer
        ; --- text lines ---
        +print_both TITLE_BY_ROW, (COLS - TITLE_BY_LEN) / 2, title_by, TITLE_BY_LEN
        +print_both TITLE_PRESS_ROW, (COLS - TITLE_PRESS_LEN) / 2, title_press, TITLE_PRESS_LEN
        +print_both TITLE_HELP_ROW, (COLS - TITLE_HELP_LEN) / 2, title_help, TITLE_HELP_LEN
        +print_both TITLE_KEYS_ROW, TITLE_PAUSE_COL, title_pause, TITLE_PAUSE_LEN
        +print_both HUD_ROW, COLS - TITLE_VERSION_LEN, title_version, TITLE_VERSION_LEN
        jsr title_music_text
        ldx #COLS - 1
-       lda #COL_CYAN
        sta COLRAM + TITLE_BY_ROW * COLS,x
        sta COLRAM + HUD_ROW * COLS,x
        lda #COL_WHITE
        sta COLRAM + TITLE_PRESS_ROW * COLS,x
        lda #COL_GREEN
        sta COLRAM + TITLE_HELP_ROW * COLS,x
        lda #COL_YELLOW
        sta COLRAM + TITLE_KEYS_ROW * COLS,x
        dex
        bpl -

        ; --- the player's ship, centred under the logo ---
        lda #PLAYER_START_X
        sta player_xh
        lda #TITLE_SHIP_Y
        sta player_y
        lda #PTR_SHIP
        sta spr_ptr + SLOT_PLAYER
        lda #COL_PLAYER
        sta spr_col + SLOT_PLAYER
        lda #1
        sta spr_on + SLOT_PLAYER
        jsr mux_build

        lda #GM_TITLE
        sta game_mode
        lda #SONG_TITLE
        jsr music_start
        jmp video_on

!zone title_update
; -----------------------------------------------------------------------------
; title_update: once per frame on the title screen (border phase).
; Bob the ship, blink "press fire", start a game on a fire press.
; -----------------------------------------------------------------------------
title_update
!ifdef AUTOSTART {
        jmp new_game            ; test hook (acme -DAUTOSTART): skip the title
}
        jsr mux_build           ; last frame's positions, shown next frame
        jsr title_flyby

        lda frame_count         ; ship bobs gently: 16-step sine, 4 frames/step
        lsr
        lsr
        and #$0f
        tax
        lda title_bob,x
        clc
        adc #TITLE_SHIP_Y
        sta player_y

        lda frame_count         ; blink by switching the row's colour between
        and #TITLE_BLINK        ;   white and the ocean blue
        beq +
        lda #PAL_OCEAN
        bne ++
+       lda #COL_WHITE
++      ldx #TITLE_PRESS_LEN - 1
-       sta COLRAM + TITLE_PRESS_ROW * COLS + (COLS - TITLE_PRESS_LEN) / 2,x
        dex
        bpl -

        jsr read_input
        lda input_new
        and #INP_FIRE
        beq +
        jmp new_game
+       jsr read_level_key      ; 1-4: straight to that level's boss
        beq +
        sta boss_now            ; (non-zero)
        sec
        sbc #1
        jmp new_game_at
+       lda input_new
        and #INP_MUSIC
        beq +
        lda music_off           ; M: music on <-> off
        eor #1
        sta music_off
        jsr title_music_text
        lda #SONG_TITLE         ; on: the title song from the top; off:
        jmp music_start         ;   music_start leaves the player idle
+       rts

; title_flyby: three fighters in a V dive down the screen every TITLE_FLYBY
; frames, using the first three enemy slots. Clobbers A, X.
title_fly_timer !byte 1
title_flyby
        dec title_fly_timer
        bne +
        lda #TITLE_FLYBY
        sta title_fly_timer
        ldx #2                  ; launch the V just above the screen
-       lda .fly_x,x
        sta spr_xh + SLOT_ENEMY0,x
        lda .fly_y,x
        sta spr_y + SLOT_ENEMY0,x
        lda #PTR_FIGHTER
        sta spr_ptr + SLOT_ENEMY0,x
        lda #COL_GREEN
        sta spr_col + SLOT_ENEMY0,x
        lda #1
        sta spr_on + SLOT_ENEMY0,x
        dex
        bpl -
+       ldx #2
-       lda spr_on + SLOT_ENEMY0,x
        beq +
        lda spr_y + SLOT_ENEMY0,x
        clc
        adc #TITLE_FLY_DY
        sta spr_y + SLOT_ENEMY0,x
        cmp #PLAY_Y_END + 4     ; off the bottom
        bcc +
        lda #0
        sta spr_on + SLOT_ENEMY0,x
+       dex
        bpl -
        rts
.fly_x  !byte (SCREEN_X_MIN + SCREEN_X_MAX - 12) / 2 - 20
        !byte (SCREEN_X_MIN + SCREEN_X_MAX - 12) / 2
        !byte (SCREEN_X_MIN + SCREEN_X_MAX - 12) / 2 + 20
.fly_y  !byte 18, 30, 18        ; the leader in front

; title_music_text: "m: music on" / "m: music off" on the title screen.
; Clobbers A, X.
title_music_text
        lda music_off
        bne +
        +print_both TITLE_KEYS_ROW, TITLE_MUSIC_COL, title_music_on, TITLE_MUSIC_LEN
        rts
+       +print_both TITLE_KEYS_ROW, TITLE_MUSIC_COL, title_music_off, TITLE_MUSIC_LEN
        rts

; Ship bob offsets: round(3 * sin(i * 22.5 deg)) + 3, so 0..6 pixels.
title_bob
!for .i, 0, 15 {
        !byte int(3.0 * sin(float(.i) * 22.5 * 3.14159265358979 / 180) + 3.5)
}
