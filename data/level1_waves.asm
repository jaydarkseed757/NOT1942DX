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
; DX retunes NOT 1942's waves for 8 enemy slots: the same moves, flown as
; formations. A V or a line abreast spawns on one row (the V's wings a row
; later, so they trail); a string flies one path, one row (8 frames) apart.
; Peaks stay at 6 alive, leaving room for medals (check_waves doesn't count
; them).
; ENEMY BUDGET: run python3 tools/check_waves.py on this file after edits.
; =============================================================================

level1_waves
        +waves_start LEVEL1_BOSS_ROW


; lone fighter dives
        +wave 42, 1
        +spawn E_FIGHTER, 86, P_DIVE

; a pair dives
        +wave 57, 2
        +spawn E_FIGHTER, 50, P_DIVE
        +spawn E_FIGHTER, 122, P_DIVE

; V of three: the point first
        +wave 72, 1
        +spawn E_FIGHTER, 86, P_DIVE
        +wave 73, 2
        +spawn E_FIGHTER, 66, P_DIVE
        +spawn E_FIGHTER, 106, P_DIVE

; string of three sweeps from the upper left
        +wave 88, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +wave 89, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +wave 90, 1
        +spawn E_FIGHTER, 20, P_DIAG_R

; string of three sweeps from the upper right
        +wave 103, 1
        +spawn E_FIGHTER, 150, P_DIAG_L
        +wave 104, 1
        +spawn E_FIGHTER, 150, P_DIAG_L
        +wave 105, 1
        +spawn E_FIGHTER, 150, P_DIAG_L

; leader swoops away left, escorts on its wings
        +wave 120, 1
        +spawn E_LEADER, 130, P_SWOOP_L
        +wave 121, 2
        +spawn E_FIGHTER, 110, P_SWOOP_L
        +spawn E_FIGHTER, 150, P_SWOOP_L

; leader swoops away right, escorts on its wings
        +wave 135, 1
        +spawn E_LEADER, 40, P_SWOOP_R
        +wave 136, 2
        +spawn E_FIGHTER, 20, P_SWOOP_R
        +spawn E_FIGHTER, 60, P_SWOOP_R

; fast echelon of four, from the left
        +wave 160, 1
        +spawn E_FIGHTER, 34, P_DIVE_FAST
        +wave 162, 1
        +spawn E_FIGHTER, 68, P_DIVE_FAST
        +wave 164, 1
        +spawn E_FIGHTER, 102, P_DIVE_FAST
        +wave 166, 1
        +spawn E_FIGHTER, 136, P_DIVE_FAST

; string of three crosses from the left
        +wave 176, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +wave 177, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +wave 178, 1
        +spawn E_FIGHTER, 0, P_CROSS_R

; loops, left and right
        +wave 186, 1
        +spawn E_FIGHTER, 100, P_LOOP_L
        +wave 189, 1
        +spawn E_FIGHTER, 70, P_LOOP_R

; echelon of four, from the right
        +wave 206, 1
        +spawn E_FIGHTER, 136, P_DIVE
        +wave 208, 1
        +spawn E_FIGHTER, 102, P_DIVE
        +wave 210, 1
        +spawn E_FIGHTER, 68, P_DIVE
        +wave 212, 1
        +spawn E_FIGHTER, 34, P_DIVE

; leader hovers and fires; two fighters dive past it
        +wave 226, 1
        +spawn E_LEADER, 86, P_HOVER
        +wave 229, 2
        +spawn E_FIGHTER, 40, P_DIVE
        +spawn E_FIGHTER, 132, P_DIVE

; crossed strings: sweeps from both upper corners, two each
        +wave 250, 1
        +spawn E_FIGHTER, 30, P_DIAG_R
        +wave 251, 1
        +spawn E_FIGHTER, 140, P_DIAG_L
        +wave 253, 1
        +spawn E_FIGHTER, 30, P_DIAG_R
        +wave 254, 1
        +spawn E_FIGHTER, 140, P_DIAG_L

; zigzag squad
        +wave 272, 1
        +spawn E_FIGHTER, 40, P_ZIGZAG
        +wave 274, 1
        +spawn E_FIGHTER, 86, P_ZIGZAG
        +wave 276, 1
        +spawn E_FIGHTER, 132, P_ZIGZAG

; crossfire: a leader from the right, a string from the left
        +wave 300, 1
        +spawn E_LEADER, 171, P_CROSS_L
        +wave 302, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +wave 303, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +wave 304, 1
        +spawn E_FIGHTER, 0, P_CROSS_R

; strings loop both ways
        +wave 312, 1
        +spawn E_FIGHTER, 60, P_LOOP_R
        +wave 313, 1
        +spawn E_FIGHTER, 60, P_LOOP_R
        +wave 318, 1
        +spawn E_FIGHTER, 110, P_LOOP_L
        +wave 319, 1
        +spawn E_FIGHTER, 110, P_LOOP_L

; leaders swoop out both ways, each with a wingman
        +wave 342, 2
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R
        +wave 343, 2
        +spawn E_FIGHTER, 140, P_SWOOP_L
        +spawn E_FIGHTER, 20, P_SWOOP_R

; fast trio, two more behind the gaps
        +wave 366, 3
        +spawn E_FIGHTER, 30, P_DIVE_FAST
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +spawn E_FIGHTER, 142, P_DIVE_FAST
        +wave 368, 2
        +spawn E_FIGHTER, 58, P_DIVE_FAST
        +spawn E_FIGHTER, 114, P_DIVE_FAST

; twin hover gunners
        +wave 381, 1
        +spawn E_LEADER, 50, P_HOVER
        +wave 384, 1
        +spawn E_LEADER, 120, P_HOVER

; interlocking loop strings
        +wave 408, 1
        +spawn E_FIGHTER, 90, P_LOOP_L
        +wave 409, 1
        +spawn E_FIGHTER, 90, P_LOOP_L
        +wave 413, 1
        +spawn E_FIGHTER, 70, P_LOOP_R
        +wave 414, 1
        +spawn E_FIGHTER, 70, P_LOOP_R

; sweep stream of five, each further in
        +wave 441, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +wave 443, 1
        +spawn E_FIGHTER, 35, P_DIAG_R
        +wave 445, 1
        +spawn E_FIGHTER, 50, P_DIAG_R
        +wave 447, 1
        +spawn E_FIGHTER, 65, P_DIAG_R
        +wave 449, 1
        +spawn E_FIGHTER, 80, P_DIAG_R

; zigzag leader with a dive escort of four
        +wave 471, 3
        +spawn E_LEADER, 86, P_ZIGZAG
        +spawn E_FIGHTER, 30, P_DIVE
        +spawn E_FIGHTER, 142, P_DIVE
        +wave 474, 2
        +spawn E_FIGHTER, 58, P_DIVE
        +spawn E_FIGHTER, 114, P_DIVE

; crossfire, both ways at once
        +wave 495, 2
        +spawn E_FIGHTER, 0, P_CROSS_R
        +spawn E_LEADER, 171, P_CROSS_L
        +wave 497, 2
        +spawn E_FIGHTER, 0, P_CROSS_R
        +spawn E_FIGHTER, 171, P_CROSS_L

; leaders loop both ways; a fighter dives between
        +wave 508, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +wave 512, 1
        +spawn E_FIGHTER, 86, P_DIVE

; big V of five, fast, its wings well spread
        +wave 540, 1
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +wave 542, 2
        +spawn E_FIGHTER, 66, P_DIVE_FAST
        +spawn E_FIGHTER, 106, P_DIVE_FAST
        +wave 544, 2
        +spawn E_FIGHTER, 46, P_DIVE_FAST
        +spawn E_FIGHTER, 126, P_DIVE_FAST

; last stand: leaders swoop out, a fast dive between
        +wave 558, 3
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_FIGHTER, 86, P_DIVE_FAST

        +waves_end
