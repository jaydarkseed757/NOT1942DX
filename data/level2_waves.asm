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
; DX retunes NOT 1942's waves for 8 enemy slots, as in level 1: the same
; moves flown as formations (no more than 3 planes on one row; echelons and
; strings one or two rows apart), at most 6 alive.
; ENEMY BUDGET: run python3 tools/check_waves.py on this file after edits.
; =============================================================================

level2_waves
        +waves_start LEVEL2_BOSS_ROW


; a lone raider dives
        +wave 42, 1
        +spawn E_RAIDER, 86, P_DIVE

; turbo build: a pair (raider_up, rise)
        +wave_turbo 49, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

; raiders sweep in from both corners
        +wave 57, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L

; turbo build: a pair (raider, dive)
        +wave_turbo 64, 2
        +spawn_turbo E_RAIDER, 56, P_DIVE
        +spawn_turbo E_RAIDER, 116, P_DIVE

; a gunship hovers and fires twice; two raiders dive past it
        +wave 78, 1
        +spawn E_GUNSHIP, 86, P_HOVER
        +wave 81, 2
        +spawn E_RAIDER, 50, P_DIVE
        +spawn E_RAIDER, 122, P_DIVE

; turbo build: a pair (raider_up, rise_r)
        +wave_turbo 88, 2
        +spawn_turbo E_RAIDER_UP, 30, P_RISE_R
        +spawn_turbo E_RAIDER_UP, 50, P_RISE_R

; ATTACK FROM BEHIND: raiders climb up from the bottom, in pairs
        +wave 102, 1
        +spawn E_RAIDER_UP, 40, P_RISE
        +wave 104, 1
        +spawn E_RAIDER_UP, 58, P_RISE

; turbo build: a pair (raider, diag_l)
        +wave_turbo 109, 2
        +spawn_turbo E_RAIDER, 150, P_DIAG_L
        +spawn_turbo E_RAIDER, 130, P_DIAG_L
        +wave 116, 1
        +spawn E_RAIDER_UP, 132, P_RISE
        +wave 118, 1
        +spawn E_RAIDER_UP, 114, P_RISE

; turbo build: a pair (raider_up, rise)
        +wave_turbo 124, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

; leaders swoop out both ways, each with a wingman
        +wave 132, 2
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R
        +wave 133, 2
        +spawn E_RAIDER, 140, P_SWOOP_L
        +spawn E_RAIDER, 20, P_SWOOP_R

; turbo build: a pair (raider, dive)
        +wave_turbo 139, 2
        +spawn_turbo E_RAIDER, 56, P_DIVE
        +spawn_turbo E_RAIDER, 116, P_DIVE

; fast raider echelon of four
        +wave 156, 1
        +spawn E_RAIDER, 30, P_DIVE_FAST
        +wave 158, 1
        +spawn E_RAIDER, 66, P_DIVE_FAST
        +wave 160, 1
        +spawn E_RAIDER, 102, P_DIVE_FAST
        +wave 162, 1
        +spawn E_RAIDER, 138, P_DIVE_FAST

; turbo build: a pair (raider_up, rise_r)
        +wave_turbo 169, 2
        +spawn_turbo E_RAIDER_UP, 30, P_RISE_R
        +spawn_turbo E_RAIDER_UP, 50, P_RISE_R

; a gunship crosses from the right, raiders from the left
        +wave 174, 1
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +wave 176, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 177, 1
        +spawn E_RAIDER, 0, P_CROSS_R

; turbo build: a pair (raider, diag_l)
        +wave_turbo 184, 2
        +spawn_turbo E_RAIDER, 150, P_DIAG_L
        +spawn_turbo E_RAIDER, 130, P_DIAG_L

; a string of raiders loops
        +wave 190, 1
        +spawn E_RAIDER, 100, P_LOOP_L
        +wave 191, 1
        +spawn E_RAIDER, 100, P_LOOP_L
        +wave 192, 1
        +spawn E_RAIDER, 100, P_LOOP_L

; turbo build: a pair (raider_up, rise)
        +wave_turbo 199, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

; climbers drift across from behind, two each way
        +wave 212, 2
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +wave 215, 2
        +spawn E_RAIDER_UP, 46, P_RISE_R
        +spawn E_RAIDER_UP, 124, P_RISE_L

; turbo build: a pair (raider, dive)
        +wave_turbo 220, 2
        +spawn_turbo E_RAIDER, 56, P_DIVE
        +spawn_turbo E_RAIDER, 116, P_DIVE

; gunship zigzag with a raider escort
        +wave 230, 3
        +spawn E_GUNSHIP, 86, P_ZIGZAG
        +spawn E_RAIDER, 30, P_DIVE
        +spawn E_RAIDER, 142, P_DIVE
        +wave 233, 2
        +spawn E_RAIDER, 58, P_DIVE
        +spawn E_RAIDER, 114, P_DIVE

; turbo build: a pair (raider_up, rise_r)
        +wave_turbo 241, 2
        +spawn_turbo E_RAIDER_UP, 30, P_RISE_R
        +spawn_turbo E_RAIDER_UP, 50, P_RISE_R

; raider sweep stream of five, each further in
        +wave 256, 1
        +spawn E_RAIDER, 20, P_DIAG_R
        +wave 258, 1
        +spawn E_RAIDER, 35, P_DIAG_R
        +wave 260, 1
        +spawn E_RAIDER, 50, P_DIAG_R
        +wave 262, 1
        +spawn E_RAIDER, 65, P_DIAG_R
        +wave 264, 1
        +spawn E_RAIDER, 80, P_DIAG_R

; turbo build: a pair (raider, diag_l)
        +wave_turbo 271, 2
        +spawn_turbo E_RAIDER, 150, P_DIAG_L
        +spawn_turbo E_RAIDER, 130, P_DIAG_L

; rear attack: an echelon of five climbs from behind
        +wave 282, 1
        +spawn E_RAIDER_UP, 30, P_RISE
        +wave 284, 1
        +spawn E_RAIDER_UP, 58, P_RISE
        +wave 286, 1
        +spawn E_RAIDER_UP, 86, P_RISE
        +wave 288, 1
        +spawn E_RAIDER_UP, 114, P_RISE
        +wave 290, 1
        +spawn E_RAIDER_UP, 142, P_RISE

; turbo build: a pair (raider_up, rise)
        +wave_turbo 295, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

; twin hover gunships; a raider dives between them
        +wave 306, 1
        +spawn E_GUNSHIP, 50, P_HOVER
        +wave 309, 1
        +spawn E_GUNSHIP, 120, P_HOVER
        +wave 312, 1
        +spawn E_RAIDER, 86, P_DIVE

; turbo build: a pair (raider, dive)
        +wave_turbo 319, 2
        +spawn_turbo E_RAIDER, 56, P_DIVE
        +spawn_turbo E_RAIDER, 116, P_DIVE

; turbo build: a pair (raider_up, rise_r)
        +wave_turbo 331, 2
        +spawn_turbo E_RAIDER_UP, 30, P_RISE_R
        +spawn_turbo E_RAIDER_UP, 50, P_RISE_R

; leaders loop both ways, each with a wingman
        +wave 336, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +wave 342, 2
        +spawn E_RAIDER, 120, P_LOOP_L
        +spawn E_RAIDER, 50, P_LOOP_R

; turbo build: a pair (raider, diag_l)
        +wave_turbo 349, 2
        +spawn_turbo E_RAIDER, 150, P_DIAG_L
        +spawn_turbo E_RAIDER, 130, P_DIAG_L

; raider crossfire: strings from both sides
        +wave 370, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 371, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 372, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 374, 1
        +spawn E_RAIDER, 171, P_CROSS_L
        +wave 375, 1
        +spawn E_RAIDER, 171, P_CROSS_L
        +wave 376, 1
        +spawn E_RAIDER, 171, P_CROSS_L

; a V of fast gunships
        +wave 388, 1
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +wave 390, 2
        +spawn E_GUNSHIP, 56, P_DIVE_FAST
        +spawn E_GUNSHIP, 116, P_DIVE_FAST

; turbo build: a pair (raider_up, rise)
        +wave_turbo 397, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

; climbers both ways around a hovering gunship
        +wave 402, 3
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +spawn E_GUNSHIP, 86, P_HOVER
        +wave 405, 2
        +spawn E_RAIDER_UP, 46, P_RISE_R
        +spawn E_RAIDER_UP, 124, P_RISE_L

; turbo build: a pair (raider, dive)
        +wave_turbo 412, 2
        +spawn_turbo E_RAIDER, 56, P_DIVE
        +spawn_turbo E_RAIDER, 116, P_DIVE

; raider zigzag squad of five
        +wave 428, 1
        +spawn E_RAIDER, 30, P_ZIGZAG
        +wave 430, 1
        +spawn E_RAIDER, 58, P_ZIGZAG
        +wave 432, 1
        +spawn E_RAIDER, 86, P_ZIGZAG
        +wave 434, 1
        +spawn E_RAIDER, 114, P_ZIGZAG
        +wave 436, 1
        +spawn E_RAIDER, 142, P_ZIGZAG

; turbo build: a pair (raider_up, rise_r)
        +wave_turbo 442, 2
        +spawn_turbo E_RAIDER_UP, 30, P_RISE_R
        +spawn_turbo E_RAIDER_UP, 50, P_RISE_R

; turbo build: a pair (raider, diag_l)
        +wave_turbo 454, 2
        +spawn_turbo E_RAIDER, 150, P_DIAG_L
        +spawn_turbo E_RAIDER, 130, P_DIAG_L

; gunship crossfire; raiders follow from the left
        +wave 462, 2
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +wave 464, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 465, 1
        +spawn E_RAIDER, 0, P_CROSS_R

; interlocking raider loop strings
        +wave 478, 1
        +spawn E_RAIDER, 90, P_LOOP_L
        +wave 479, 1
        +spawn E_RAIDER, 90, P_LOOP_L
        +wave 483, 1
        +spawn E_RAIDER, 70, P_LOOP_R
        +wave 484, 1
        +spawn E_RAIDER, 70, P_LOOP_R

; turbo build: a pair (raider_up, rise)
        +wave_turbo 490, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

; turbo build: a pair (raider, dive)
        +wave_turbo 502, 2
        +spawn_turbo E_RAIDER, 56, P_DIVE
        +spawn_turbo E_RAIDER, 116, P_DIVE

; rear attack: five climb from behind, staggered
        +wave 510, 1
        +spawn E_RAIDER_UP, 30, P_RISE
        +wave 512, 1
        +spawn E_RAIDER_UP, 86, P_RISE
        +wave 514, 1
        +spawn E_RAIDER_UP, 142, P_RISE
        +wave 516, 1
        +spawn E_RAIDER_UP, 58, P_RISE
        +wave 518, 1
        +spawn E_RAIDER_UP, 114, P_RISE

; turbo build: a pair (raider_up, rise_r)
        +wave_turbo 523, 2
        +spawn_turbo E_RAIDER_UP, 30, P_RISE_R
        +spawn_turbo E_RAIDER_UP, 50, P_RISE_R

; last stand: leaders swoop out, then a V of gunships dives
        +wave 530, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R

; turbo build: a pair (raider, diag_l)
        +wave_turbo 535, 2
        +spawn_turbo E_RAIDER, 150, P_DIAG_L
        +spawn_turbo E_RAIDER, 130, P_DIAG_L
        +wave 540, 1
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +wave 542, 2
        +spawn E_GUNSHIP, 58, P_DIVE_FAST
        +spawn E_GUNSHIP, 114, P_DIVE_FAST

; a last V of raiders, fast
        +wave 556, 1
        +spawn E_RAIDER, 86, P_DIVE_FAST
        +wave 558, 2
        +spawn E_RAIDER, 66, P_DIVE_FAST
        +spawn E_RAIDER, 106, P_DIVE_FAST

; turbo build: a pair (raider_up, rise)
        +wave_turbo 565, 2
        +spawn_turbo E_RAIDER_UP, 46, P_RISE
        +spawn_turbo E_RAIDER_UP, 126, P_RISE

        +waves_end
