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
; level_load: copy the current level's table entry into zero page.
; Clobbers A, X.
; -----------------------------------------------------------------------------
level_load
        ldx level
        lda lvl_t_stream_lo,x
        sta lvl_start
        lda lvl_t_stream_hi,x
        sta lvl_start+1
        lda lvl_t_rowpat_lo,x
        sta lvl_rowpats
        lda lvl_t_rowpat_hi,x
        sta lvl_rowpats+1
        lda lvl_t_bg,x
        sta pal_bg
        lda lvl_t_mc1,x
        sta pal_mc1
        lda lvl_t_mc2,x
        sta pal_mc2
        lda lvl_t_cram,x
        sta pal_cram
        rts

!zone copy_tileset
; -----------------------------------------------------------------------------
; copy_tileset: the current level's 512-byte tileset -> char codes 64-127.
; Display must be off (or the change would show mid-frame). Clobbers A, X, Y,
; zp_ptr0, zp_ptr1.
; -----------------------------------------------------------------------------
copy_tileset
        ldx level
        lda lvl_t_tiles_lo,x
        sta zp_ptr0
        lda lvl_t_tiles_hi,x
        sta zp_ptr0+1
        lda #<(CHARSET + FIRST_TILE * 8)
        sta zp_ptr1
        lda #>(CHARSET + FIRST_TILE * 8)
        sta zp_ptr1+1
        ldx #TILESET_SIZE / 256
        ldy #0
-       lda (zp_ptr0),y
        sta (zp_ptr1),y
        iny
        bne -
        inc zp_ptr0+1
        inc zp_ptr1+1
        dex
        bne -
        rts

!if (CHARSET + FIRST_TILE * 8) & $ff { !error "tileset target must be page aligned" }
!if TILESET_SIZE & $ff { !error "tileset size must be whole pages" }

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

!zone level_begin
; -----------------------------------------------------------------------------
; level_begin: build the current level and start playing it.
; TIMING: a few frames with the display off (tileset copy + 25-row prefill).
; -----------------------------------------------------------------------------
level_begin
!ifdef PROFILE {
        jsr prof_reset          ; test hook: measure each level on its own
}
        jsr level_load
        jsr init_video          ; display off, clean screens, level palette
        jsr copy_tileset
        jsr init_char_col       ; colour RAM value of every char
        jsr scroll_init         ; pre-draw the first screen of the level
        jsr init_input          ; a held fire button won't shoot at once
        jsr init_sprites
        jsr hud_init            ; the sprite HUD's slots
        jsr player_place
        lda #0
        sta invuln_timer
        sta paused
        sta boss_flag
        sta boss_state
!ifdef BOSS_TEST {
        lda #1                  ; test hook (acme -DBOSS_TEST): the boss comes
        sta boss_flag           ;   straight away (stream spawns are dropped)
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
        bne .done
        lda #LS_NEXT            ; main loop switches level next frame
        sta lvl_state
.done   rts

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
