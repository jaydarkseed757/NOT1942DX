; =============================================================================
; data/levels.asm - the level table
; =============================================================================
;
; One column per level. Everything a level needs to start:
;   stream    level stream (data/levelN.asm)
;   rowpats   its row pattern table (index * 40)
;   tiles     tileset copied to char codes 64-127 (data/tiles_*.asm)
;   bg/mc1/mc2/cram  palette: $D021, $D022, $D023, and the colour RAM colour
;             for pixel %11 (0-7 only; it sets the playfield's colour RAM)
;   song      SONG_* from data/songs.asm
;   boss      boss number (data/bosses.asm)
;   name      shown on the "LEVEL n" intro screen
; =============================================================================

LEVEL_COUNT = 4

;                   level 1          level 2          level 3          level 4
lvl_t_stream_lo !byte <level1_stream,  <level2_stream,  <level3_stream,  <level4_stream
lvl_t_stream_hi !byte >level1_stream,  >level2_stream,  >level3_stream,  >level4_stream
lvl_t_rowpat_lo !byte <level1_rowpats, <level2_rowpats, <level3_rowpats, <level4_rowpats
lvl_t_rowpat_hi !byte >level1_rowpats, >level2_rowpats, >level3_rowpats, >level4_rowpats
lvl_t_tiles_lo  !byte <tiles_ocean,    <tiles_jungle,   <tiles_strait,   <tiles_fleet
lvl_t_tiles_hi  !byte >tiles_ocean,    >tiles_jungle,   >tiles_strait,   >tiles_fleet
lvl_t_bg        !byte COL_BLUE,        COL_LBLUE,       COL_PURPLE,      COL_DGREY
lvl_t_mc1       !byte COL_LGREEN,      COL_GREEN,       COL_BROWN,       COL_BLACK
lvl_t_mc2       !byte COL_BROWN,       COL_LGREEN,      COL_ORANGE,      COL_GREY
lvl_t_cram      !byte COL_CYAN,        COL_YELLOW,      COL_YELLOW,      COL_WHITE
lvl_t_song      !byte SONG_GAME,       SONG_LEVEL2,     SONG_LEVEL3,     SONG_LEVEL4
lvl_t_boss      !byte 0,               1,               2,               3
lvl_t_name_lo   !byte <lvl_name1,      <lvl_name2,      <lvl_name3,      <lvl_name4
lvl_t_name_hi   !byte >lvl_name1,      >lvl_name2,      >lvl_name3,      >lvl_name4

; Level names: 13 characters each, padded with spaces (screen codes).
LVL_NAME_LEN = 13
lvl_name1 !scr "  open ocean "
lvl_name2 !scr " jungle coast"
lvl_name3 !scr "sunset strait"
lvl_name4 !scr " enemy fleet "
