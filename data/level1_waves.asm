; =============================================================================
; data/level1_waves.asm - level 1: enemy waves and the boss row
; =============================================================================
;
; The level's picture is data/levels/level1.png (see tools/png2level.py).
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

level1_waves
        +waves_start LEVEL1_BOSS_ROW

; r4: lone fighter dives
        +wave 42, 1
        +spawn E_FIGHTER, 86, P_DIVE

; r14: a pair dives
        +wave 57, 2
        +spawn E_FIGHTER, 50, P_DIVE
        +spawn E_FIGHTER, 122, P_DIVE

; r28: sweep from the upper left
        +wave 78, 1
        +spawn E_FIGHTER, 20, P_DIAG_R

; r36: sweep from the upper right
        +wave 90, 1
        +spawn E_FIGHTER, 150, P_DIAG_L

; r46: leader swoops away left
        +wave 105, 1
        +spawn E_LEADER, 130, P_SWOOP_L

; r56: leader swoops away right
        +wave 120, 1
        +spawn E_LEADER, 30, P_SWOOP_R

; r64: fast pair
        +wave 132, 2
        +spawn E_FIGHTER, 40, P_DIVE_FAST
        +spawn E_FIGHTER, 132, P_DIVE_FAST

; r74: fighter crosses from the left
        +wave 147, 1
        +spawn E_FIGHTER, 0, P_CROSS_R

; r84: first loop
        +wave 162, 1
        +spawn E_FIGHTER, 100, P_LOOP_L

; r104: three in line abreast
        +wave 192, 3
        +spawn E_FIGHTER, 60, P_DIVE
        +spawn E_FIGHTER, 86, P_DIVE
        +spawn E_FIGHTER, 112, P_DIVE

; r118: leader hovers and fires twice
        +wave 213, 1
        +spawn E_LEADER, 86, P_HOVER

; r124: crossed sweeps
        +wave 222, 2
        +spawn E_FIGHTER, 30, P_DIAG_R
        +spawn E_FIGHTER, 140, P_DIAG_L

; r138: zigzag squad (1/3)
        +wave 243, 1
        +spawn E_FIGHTER, 40, P_ZIGZAG

; r140: zigzag squad (2/3)
        +wave 246, 1
        +spawn E_FIGHTER, 86, P_ZIGZAG

; r142: zigzag squad (3/3)
        +wave 249, 1
        +spawn E_FIGHTER, 132, P_ZIGZAG

; r160: crossfire
        +wave 276, 1
        +spawn E_LEADER, 171, P_CROSS_L

; r163: crossfire
        +wave 281, 1
        +spawn E_FIGHTER, 0, P_CROSS_R

; -- twin --
; r174: loops left and right
        +wave 297, 1
        +spawn E_FIGHTER, 60, P_LOOP_R

; r178: loops left and right
        +wave 303, 1
        +spawn E_FIGHTER, 110, P_LOOP_L

; r198: leaders swoop out both ways
        +wave 333, 2
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R

; r218: fast trio
        +wave 363, 3
        +spawn E_FIGHTER, 30, P_DIVE_FAST
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +spawn E_FIGHTER, 142, P_DIVE_FAST

; r228: twin hover gunners
        +wave 378, 1
        +spawn E_LEADER, 50, P_HOVER

; r230: twin hover gunners
        +wave 381, 1
        +spawn E_LEADER, 120, P_HOVER

; r246: interlocking loops
        +wave 405, 1
        +spawn E_FIGHTER, 90, P_LOOP_L

; r249: interlocking loops
        +wave 410, 1
        +spawn E_FIGHTER, 70, P_LOOP_R

; r270: sweep stream (1/3)
        +wave 441, 1
        +spawn E_FIGHTER, 20, P_DIAG_R

; r272: sweep stream (2/3)
        +wave 444, 1
        +spawn E_FIGHTER, 50, P_DIAG_R

; r274: sweep stream (3/3)
        +wave 447, 1
        +spawn E_FIGHTER, 80, P_DIAG_R

; r290: zigzag leader with dive escort
        +wave 471, 3
        +spawn E_LEADER, 86, P_ZIGZAG
        +spawn E_FIGHTER, 30, P_DIVE
        +spawn E_FIGHTER, 142, P_DIVE

; r306: crossfire, both at once
        +wave 495, 2
        +spawn E_FIGHTER, 0, P_CROSS_R
        +spawn E_LEADER, 171, P_CROSS_L

; r318: leader loops, both ways
        +wave 513, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R

; r338: fast trio
        +wave 543, 3
        +spawn E_FIGHTER, 40, P_DIVE_FAST
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +spawn E_FIGHTER, 132, P_DIVE_FAST

; r348: last stand: swoops and a fast dive
        +wave 558, 3
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_FIGHTER, 86, P_DIVE_FAST

        +waves_end
