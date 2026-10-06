; =============================================================================
; level.asm - level flow: intro screen, level start, boss/clear, victory
; =============================================================================
;
; FLOW   title --fire--> new_game --> level intro ("LEVEL n", 2.5 s)
;        --> play --(stream reaches +boss_here)--> boss --> LEVEL CLEAR (3 s)
;        --> next level intro ... after level 4: the ending (ending.asm)
; Score and lives carry over between levels. Losing the last life at any
; point goes to GAME OVER as before.
;
; lvl_state (during GM_PLAY):
;   LS_PLAY   waves from the level stream
;   LS_BOSS   the stream hit +boss_here: no more spawns, background loops.
;             Once the last regular enemies have left the enemy slots the
;             level's boss flies in (boss.asm); when it is destroyed
;             (boss_state = BS_DONE) the level is clear.
;   LS_CLEAR  "LEVEL CLEAR" in the HUD; scrolling and flying continue
;   LS_NEXT   set when LS_CLEAR runs out; the main loop switches level at the
;             start of the next frame (lower border), like gameover_enter
; =============================================================================

INTRO_FRAMES        = 125       ; 2.5 s "LEVEL n / GET READY"
CLEAR_FRAMES        = 150       ; 3 s "LEVEL CLEAR" before the next level

LS_PLAY  = 0
LS_BOSS  = 1
LS_CLEAR = 2
LS_NEXT  = 3


!zone level_load
; -----------------------------------------------------------------------------
; level_load: the current level's palette, size, boss row and first wave
; from the level table (data/levels.asm). Clobbers A, X.
; -----------------------------------------------------------------------------
level_load
        ldx level
        lda lvl_t_bg,x
        sta pal_bg
        lda lvl_t_mc1,x
        sta pal_mc1
        lda lvl_t_mc2,x
        sta pal_mc2
        lda lvl_t_rows_lo,x
        sta lvl_rows
        lda lvl_t_rows_hi,x
        sta lvl_rows+1
        lda lvl_t_boss_lo,x
        sta lvl_boss
        lda lvl_t_boss_hi,x
        sta lvl_boss+1
        lda lvl_t_waves_lo,x
        sta wave_ptr
        lda lvl_t_waves_hi,x
        sta wave_ptr+1
        rts

!zone level_unpack
; -----------------------------------------------------------------------------
; level_unpack: unpack the current level's chars (to the charset, codes 64
; and up) and their colours (CHAR_COL; chars 0-63 get the default), and
; start its map stream (scroll.asm unpacks that a row at a time). Display
; must be off. TIMING: a frame or so (~15 cycles per byte unpacked).
; Clobbers A, X, Y, zp_ptr0, zp_ptr1, lz_mp.
; -----------------------------------------------------------------------------
level_unpack
        jsr init_char_col       ; defaults (and the TEST_CHAR_COL colours)
        ldx level
        lda lvl_t_chars_lo,x
        sta zp_ptr0
        lda lvl_t_chars_hi,x
        sta zp_ptr0+1
        lda #<(CHARSET + FIRST_TILE * 8)
        sta zp_ptr1
        lda #>(CHARSET + FIRST_TILE * 8)
        sta zp_ptr1+1
        jsr unpack
!ifndef TEST_CHAR_COL {
        ldx level
        lda lvl_t_cols_lo,x
        sta zp_ptr0
        lda lvl_t_cols_hi,x
        sta zp_ptr0+1
        lda #<(CHAR_COL + FIRST_TILE)
        sta zp_ptr1
        lda #>(CHAR_COL + FIRST_TILE)
        sta zp_ptr1+1
        jsr unpack
}
        ldx level               ; the map stream, from its start
        lda lvl_t_map_lo,x
        sta st_src
        lda lvl_t_map_hi,x
        sta st_src+1
        lda lvl_t_loop_lo,x
        sta st_loop
        lda lvl_t_loop_hi,x
        sta st_loop+1
        lda #<RING
        sta st_wp
        lda #>RING
        sta st_wp+1
        lda #0
        sta st_left
        sta st_out
        rts

!if (CHARSET + FIRST_TILE * 8) & $ff { !error "level chars must start on a page" }

; restore_quads: put the title logo's quadrant chars (128-143, data/tiles.asm)
; back into the charset; a level's chars overwrite them. Clobbers A, X.
restore_quads
        ldx #QUAD_CHARS * 8 - 1
-       lda quad_chars,x
        sta CHARSET + QUAD_BASE * 8,x
        dex
        bpl -
        rts

!zone level_intro_enter
; -----------------------------------------------------------------------------
; level_intro_enter: "LEVEL n / name / GET READY" on the level's colours.
; Music is silent here; the level's song starts with the level.
; -----------------------------------------------------------------------------
level_intro_enter
        jsr level_load
        jsr init_video          ; display off, clean screens, level palette
        jsr hud_draw_score
        jsr hud_draw_lives
        jsr hud_draw_level
        jsr textscreen_enter
        +print_both TXT_ROW_A, (COLS - 7) / 2, .level, 6
        lda level
        clc
        adc #'1'                ; screen code of the level digit
        sta SCREEN_A + TXT_ROW_A * COLS + (COLS - 7) / 2 + 6
        sta SCREEN_B + TXT_ROW_A * COLS + (COLS - 7) / 2 + 6
        ldx level               ; level name
        lda lvl_t_name_lo,x
        sta zp_ptr0
        lda lvl_t_name_hi,x
        sta zp_ptr0+1
        ldy #LVL_NAME_LEN - 1
-       lda (zp_ptr0),y
        sta SCREEN_A + TXT_ROW_B * COLS + (COLS - LVL_NAME_LEN) / 2,y
        sta SCREEN_B + TXT_ROW_B * COLS + (COLS - LVL_NAME_LEN) / 2,y
        dey
        bpl -
        +print_both TXT_ROW_D, (COLS - .ready_len) / 2, .ready, .ready_len
        jsr music_stop
        lda #INTRO_FRAMES
        sta intro_timer
        lda #GM_INTRO
        sta game_mode
        jmp video_on

.level  !scr "level "
.ready  !scr "get ready"
.ready_len = * - .ready

!zone intro_update
; intro_update: once per frame on the intro screen.
intro_update
        dec intro_timer
        bne +
        jmp level_begin
+       rts

boss_now !byte 0                ; non-zero: the next level_begin starts with
                                ;   its boss (the title's keys 1-4)

!zone level_begin
; -----------------------------------------------------------------------------
; level_begin: build the current level and start playing it.
; TIMING: a few frames with the display off (unpacking + 25-row prefill).
; -----------------------------------------------------------------------------
level_begin
!ifdef PROFILE {
        jsr prof_reset          ; test hook: measure each level on its own
}
        jsr level_load
        jsr init_video          ; display off, clean screens, level palette
        jsr level_unpack        ; its chars, colours and map stream
        jsr anim_init           ; its animated chars
        jsr scroll_init         ; pre-draw the first screen of the level
        jsr init_input          ; a held fire button won't shoot at once
        jsr init_sprites
        jsr hud_init            ; the sprite HUD's slots
!ifdef TURBO {
        jsr para_reset          ; no parallax cloud yet
}
        jsr player_place
        lda #0
        sta invuln_timer
        sta paused
        sta boss_flag
        sta boss_state
        lda boss_now            ; the title's keys 1-4: this level's boss
        beq +                   ;   comes straight away, once (the levels
        sta boss_flag           ;   after it play normally)
        lda #0
        sta boss_now
+
!ifdef BOSS_TEST {
        lda #1                  ; test hook (acme -DBOSS_TEST): the boss comes
        sta boss_flag           ;   straight away (the waves are skipped)
}
        jsr init_pbullets
        jsr init_enemies
!ifdef TEST_STALE_MEDAL {
        lda #EN_MEDAL           ; test hook (acme -DTEST_STALE_MEDAL=1): leave
        ldx #ENEMY_COUNT - 1    ;   the enemy slots looking like medals that
-       sta en_state,x          ;   fell off screen, to check the boss (and
        dex                     ;   anything else) clears them
        bpl -
}
        jsr init_ebullets
        jsr init_collide
        jsr hud_draw_score
        jsr hud_draw_lives
        jsr hud_draw_level
        jsr hud_update          ; draw its shapes
        jsr mux_build           ; sprites from the first frame on
        jsr fade_in_start       ; it starts dark and lights up
        lda #LS_PLAY
        sta lvl_state
        lda #GM_PLAY
        sta game_mode
        ldx level
        lda lvl_t_song,x
        jsr music_start
        lda #D011_PLAY          ; display on: 24 rows, yscroll 0. From now on
        sta scroll_d011         ;   the IRQ sets $D011 every frame
        sta VIC_CTRL1
        rts

!zone level_update
; -----------------------------------------------------------------------------
; level_update: once per frame in play, after the other logic.
; -----------------------------------------------------------------------------
level_update
!ifdef TEST_SFX {
        lda frame_count         ; test hook (acme -DTEST_SFX=n): play effect n
        and #63                 ;   every 64 frames, for recording
        bne +
        lda #TEST_SFX
        jsr sfx_start
+
}
        lda lvl_state
        cmp #LS_PLAY
        bne .notplay
        lda boss_flag           ; set by fetch_record at +boss_here
        beq .done
        lda #LS_BOSS
        sta lvl_state
        jmp hud_show_boss

.notplay
        cmp #LS_BOSS
        bne .notboss
        lda boss_state
        cmp #BS_IDLE
        bne .started
        ldx #ENEMY_COUNT - 1    ; wait for the last regular enemies (and
-       lda spr_on + SLOT_ENEMY0,x ; their explosions) to free the slots
        bne .done
        dex
        bpl -
        ldx level
        lda lvl_t_boss,x
        jmp boss_start
.started
        cmp #BS_DONE
        bne .done
        lda #LS_CLEAR
        sta lvl_state
        lda #CLEAR_FRAMES
        sta lvl_timer
        jmp hud_show_clear

.notboss
        cmp #LS_CLEAR
        bne .done
        lda player_state        ; shot down during LEVEL CLEAR: hold the
        bne .done               ;   countdown until the respawn. On the last
                                ;   ship PS_GAMEOVER ends the game instead
                                ;   (main loop), so lives can't go 0 -> $FF.
        dec lvl_timer
!ifdef TEST_DIE_ON_CLEAR {
        lda lvl_timer           ; test hook (acme -DTEST_DIE_ON_CLEAR=n): with
        cmp #40                 ;   40 frames of LEVEL CLEAR left (less than
        bne +                   ;   the death animation) the player, down to
        lda #TEST_DIE_ON_CLEAR  ;   n ships, is shot down
        sta lives
        jsr player_die
+       lda lvl_timer
}
        beq +
        lda lvl_timer           ; the last FADE_FRAMES: fade out
        cmp #FADE_FRAMES
        bne .done
        lda #1
        sta fade_dir
        lda #0
        sta fade_k
        beq .done               ; (always)
+       lda #LS_NEXT            ; main loop switches level next frame
        sta lvl_state
.done   rts

!zone fade
; -----------------------------------------------------------------------------
; Fades: the shared colours ($D021-$D023, from pal_*) step through
; fade_darker, FADE_STEPS steps FADE_EVERY frames apart (the last is black). Chars' own colours (colour RAM) stay as they are,
; so a level seems to light up from its details. fade_dir: 0 = none, $FF =
; fading in (fade_k counts down to 0), 1 = fading out (up to FADE_STEPS).
; fade_update runs in the border work. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
FADE_STEPS  = 4
FADE_EVERY  = 4
FADE_FRAMES = FADE_STEPS * FADE_EVERY

; fade_in_start: the level starts dark (call before the display goes on).
fade_in_start
        lda #$ff
        sta fade_dir
        lda #FADE_STEPS
        sta fade_k
        jmp fade_apply

fade_update
        lda fade_dir
        beq .out
        lda frame_count
        and #FADE_EVERY - 1
        bne .out
        lda fade_dir
        bmi .in
        lda fade_k              ; out: one step darker, until black
        cmp #FADE_STEPS
        bcs .out
        inc fade_k
        bne fade_apply          ; (always)
.in     dec fade_k              ; in: one step brighter, then done
        bne fade_apply
        lda #0
        sta fade_dir
        ; (fall through: full colours)
fade_apply
        ldy #2
.col    ldx pal_bg,y            ; (pal_bg, pal_mc1, pal_mc2 are adjacent)
        lda fade_k
        beq .set                ; full colour
        cmp #FADE_STEPS
        bcc +
        ldx #COL_BLACK          ; the last step is black, whatever the colour
        bcs .set
+       sta zp_tmp0
.dark   lda fade_darker,x       ; fade_k steps darker
        tax
        dec zp_tmp0
        bne .dark
.set    txa
        sta BGCOL0,y
        dey
        bpl .col
.out    rts

; the next darker colour, keeping its hue where the C64 has one (black
; stays black; at most 4 steps from white to black):
;   white > light grey > grey > dark grey > black,  light green > green >
;   dark grey,  yellow > orange > brown,  light red > red > brown,  cyan >
;   light blue > blue,  purple > blue
fade_darker
        !byte COL_BLACK, COL_LGREY, COL_BROWN, COL_LBLUE      ; 0-3
        !byte COL_BLUE, COL_DGREY, COL_BLACK, COL_ORANGE      ; 4-7
        !byte COL_BROWN, COL_BLACK, COL_RED, COL_BLACK        ; 8-11
        !byte COL_DGREY, COL_GREEN, COL_BLUE, COL_GREY        ; 12-15
!if pal_mc1 != pal_bg + 1 | pal_mc2 != pal_bg + 2 { !error "fade_apply: pal_* must be adjacent" }
!if BGCOL1 != BGCOL0 + 1 | BGCOL2 != BGCOL0 + 2 { !error "fade_apply: colour registers" }

!zone level_next
; -----------------------------------------------------------------------------
; level_next: called by the main loop (lower border) in LS_NEXT.
; -----------------------------------------------------------------------------
level_next
        inc level
        lda level
        cmp #LEVEL_COUNT
        bcc +
        jmp victory_enter
+       jmp level_intro_enter
