; =============================================================================
; data/level2_waves.asm - level 2: enemy waves and the boss row
; =============================================================================
;
; The level's picture is data/levels/level2.png (see tools/png2level.py).
; Rows count char rows from the BOTTOM of the picture, in the order they
; scroll in: row 0 is the bottom row, which starts on the screen's bottom
; row. The first 25 rows are on screen at the start and can't spawn.
;
;   +waves_start BOSS_ROW         begin. The boss row is set in
;                                 data/levels/levelN.json ("boss_row"); the
;                                 rows from there up loop during the boss
;                                 fight, and no spawns are allowed there
;   +wave ROW, N                  N spawns when ROW scrolls in (rows must
;                                 go up), each a line of:
;   +spawn E_TYPE, X, P_PATH      (types and paths: data/waves.asm)
;   +waves_end
;
; The "rN" comments are NOT 1942's record numbers, before DX's 2:3 stretch.
; ENEMY BUDGET: run python3 tools/check_waves.py on this file after edits.
; =============================================================================

level2_waves
        +waves_start LEVEL2_BOSS_ROW

; r4: a lone raider dives
        +wave 42, 1
        +spawn E_RAIDER, 86, P_DIVE

; r14: raiders sweep in from both corners
        +wave 57, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L

; r28: a gunship hovers and fires twice
        +wave 78, 1
        +spawn E_GUNSHIP, 86, P_HOVER

; r44: ATTACK FROM BEHIND: a raider climbs up from the bottom
        +wave 102, 1
        +spawn E_RAIDER_UP, 40, P_RISE

; r52: ...and another on the other side
        +wave 114, 1
        +spawn E_RAIDER_UP, 132, P_RISE

; r62: leaders swoop out both ways
        +wave 129, 2
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R

; r78: fast raider trio
        +wave 153, 3
        +spawn E_RAIDER, 30, P_DIVE_FAST
        +spawn E_RAIDER, 86, P_DIVE_FAST
        +spawn E_RAIDER, 142, P_DIVE_FAST

; r90: a gunship crosses from the right
        +wave 171, 1
        +spawn E_GUNSHIP, 171, P_CROSS_L

; r100: raider loop
        +wave 186, 1
        +spawn E_RAIDER, 100, P_LOOP_L

; r112: climbers drift across from behind
        +wave 204, 2
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L

; r126: gunship zigzag with a raider escort
        +wave 225, 2
        +spawn E_GUNSHIP, 86, P_ZIGZAG
        +spawn E_RAIDER, 30, P_DIVE

; r144: raider sweep stream (1/3)
        +wave 252, 1
        +spawn E_RAIDER, 20, P_DIAG_R

; r146: raider sweep stream (2/3)
        +wave 255, 1
        +spawn E_RAIDER, 50, P_DIAG_R

; r148: raider sweep stream (3/3)
        +wave 258, 1
        +spawn E_RAIDER, 80, P_DIAG_R

; r162: rear attack trio (1/3)
        +wave 279, 1
        +spawn E_RAIDER_UP, 30, P_RISE

; r164: rear attack trio (2/3)
        +wave 282, 1
        +spawn E_RAIDER_UP, 86, P_RISE

; r166: rear attack trio (3/3)
        +wave 285, 1
        +spawn E_RAIDER_UP, 142, P_RISE

; r180: twin hover gunships
        +wave 306, 2
        +spawn E_GUNSHIP, 50, P_HOVER
        +spawn E_GUNSHIP, 120, P_HOVER

; r198: leaders loop both ways
        +wave 333, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R

; r218: raider crossfire
        +wave 363, 2
        +spawn E_RAIDER, 0, P_CROSS_R
        +spawn E_RAIDER, 171, P_CROSS_L

; r230: gunship trio, fast
        +wave 381, 3
        +spawn E_GUNSHIP, 30, P_DIVE_FAST
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +spawn E_GUNSHIP, 142, P_DIVE_FAST

; r242: climbers both ways and a gunship hover
        +wave 399, 3
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +spawn E_GUNSHIP, 86, P_HOVER

; r260: raider zigzag squad (1/3)
        +wave 426, 1
        +spawn E_RAIDER, 40, P_ZIGZAG

; r262: raider zigzag squad (2/3)
        +wave 429, 1
        +spawn E_RAIDER, 86, P_ZIGZAG

; r264: raider zigzag squad (3/3)
        +wave 432, 1
        +spawn E_RAIDER, 132, P_ZIGZAG

; r282: gunship crossfire
        +wave 459, 2
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L

; r294: interlocking raider loops
        +wave 477, 2
        +spawn E_RAIDER, 90, P_LOOP_L
        +spawn E_RAIDER, 70, P_LOOP_R

; r314: rear attack, three abreast
        +wave 507, 3
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 86, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE

; r328: last stand: leaders swoop, gunship dives
        +wave 528, 3
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_GUNSHIP, 86, P_DIVE_FAST

        +waves_end
