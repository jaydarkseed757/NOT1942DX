; =============================================================================
; data/levels.asm - the level table
; =============================================================================
;
; One column per level. Everything a level needs to start:
;   chars/cols  its chars for codes 64+ and their colour RAM values,
;             packed (build/gen/levelN.asm, made from data/levels/levelN.png
;             by tools/png2level.py)
;   map/loop  its char map, packed: all of it, and the boss loop on its own
;   rows      char rows in its picture
;   boss      the row where its boss comes (levelN.json); from there to the
;             top loops during the fight
;   anims     its animated chars (levelN_anim.png, src/anim.asm)
;   waves     its wave list (data/levelN_waves.asm)
;   bg/mc1/mc2  the shared colours $D021, $D022, $D023 (levelN.json)
;   song      SONG_* from data/songs.asm
;   bossnum   boss number (data/bosses.asm)
;   name      shown on the "LEVEL n" intro screen
; =============================================================================

LEVEL_COUNT = 4

;                   level 1          level 2          level 3          level 4
lvl_t_chars_lo  !byte <level1_chars_lz, <level2_chars_lz, <level3_chars_lz, <level4_chars_lz
lvl_t_chars_hi  !byte >level1_chars_lz, >level2_chars_lz, >level3_chars_lz, >level4_chars_lz
lvl_t_cols_lo   !byte <level1_cols_lz,  <level2_cols_lz,  <level3_cols_lz,  <level4_cols_lz
lvl_t_cols_hi   !byte >level1_cols_lz,  >level2_cols_lz,  >level3_cols_lz,  >level4_cols_lz
lvl_t_map_lo    !byte <level1_map_lz,   <level2_map_lz,   <level3_map_lz,   <level4_map_lz
lvl_t_map_hi    !byte >level1_map_lz,   >level2_map_lz,   >level3_map_lz,   >level4_map_lz
lvl_t_loop_lo   !byte <level1_loop_lz,  <level2_loop_lz,  <level3_loop_lz,  <level4_loop_lz
lvl_t_loop_hi   !byte >level1_loop_lz,  >level2_loop_lz,  >level3_loop_lz,  >level4_loop_lz
lvl_t_rows_lo   !byte <LEVEL1_ROWS,     <LEVEL2_ROWS,     <LEVEL3_ROWS,     <LEVEL4_ROWS
lvl_t_rows_hi   !byte >LEVEL1_ROWS,     >LEVEL2_ROWS,     >LEVEL3_ROWS,     >LEVEL4_ROWS
lvl_t_boss_lo   !byte <LEVEL1_BOSS_ROW, <LEVEL2_BOSS_ROW, <LEVEL3_BOSS_ROW, <LEVEL4_BOSS_ROW
lvl_t_boss_hi   !byte >LEVEL1_BOSS_ROW, >LEVEL2_BOSS_ROW, >LEVEL3_BOSS_ROW, >LEVEL4_BOSS_ROW
lvl_t_anims_lo  !byte <level1_anims,    <level2_anims,    <level3_anims,    <level4_anims
lvl_t_anims_hi  !byte >level1_anims,    >level2_anims,    >level3_anims,    >level4_anims
lvl_t_waves_lo  !byte <level1_waves,    <level2_waves,    <level3_waves,    <level4_waves
lvl_t_waves_hi  !byte >level1_waves,    >level2_waves,    >level3_waves,    >level4_waves
lvl_t_bg        !byte LEVEL1_BG,        LEVEL2_BG,        LEVEL3_BG,        LEVEL4_BG
lvl_t_mc1       !byte LEVEL1_MC1,       LEVEL2_MC1,       LEVEL3_MC1,       LEVEL4_MC1
lvl_t_mc2       !byte LEVEL1_MC2,       LEVEL2_MC2,       LEVEL3_MC2,       LEVEL4_MC2
lvl_t_song      !byte SONG_GAME,        SONG_LEVEL2,      SONG_LEVEL3,      SONG_LEVEL4
lvl_t_boss      !byte 0,                1,                2,                3
lvl_t_name_lo   !byte <lvl_name1,       <lvl_name2,       <lvl_name3,       <lvl_name4
lvl_t_name_hi   !byte >lvl_name1,       >lvl_name2,       >lvl_name3,       >lvl_name4

; The screen is drawn from the first rows at once, so a level needs more.
!macro level_checks .rows, .boss {
        !if .rows <= SCROLL_ROWS { !error "a level's picture must be taller than the screen" }
        !if .boss >= .rows { !error "a level's boss row is past the top of its picture" }
}
+level_checks LEVEL1_ROWS, LEVEL1_BOSS_ROW
+level_checks LEVEL2_ROWS, LEVEL2_BOSS_ROW
+level_checks LEVEL3_ROWS, LEVEL3_BOSS_ROW
+level_checks LEVEL4_ROWS, LEVEL4_BOSS_ROW

; Level names: 13 characters each, padded with spaces (screen codes).
LVL_NAME_LEN = 13
lvl_name1 !scr "  open ocean "
lvl_name2 !scr " jungle coast"
lvl_name3 !scr "sunset strait"
lvl_name4 !scr " enemy fleet "
