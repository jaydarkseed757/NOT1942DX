; =============================================================================
; data/level3_waves.asm - level 3: enemy waves and the boss row
; =============================================================================
;
; The level's picture is data/levels/level3.png (see tools/png2level.py).
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
; DX retunes NOT 1942's waves for 8 enemy slots, as in levels 1-2: the same
; moves flown as formations (no more than 3 planes on one row; echelons and
; strings one or two rows apart), at most 6 alive.
; ENEMY BUDGET: run python3 tools/check_waves.py on this file after edits.
; =============================================================================

level3_waves
        +waves_start LEVEL3_BOSS_ROW


; a diver dive-bombs
        +wave 42, 1
        +spawn E_DIVER, 86, P_DIVEBOMB

; fighters weave in
        +wave 57, 2
        +spawn E_FIGHTER, 40, P_WEAVE
        +spawn E_FIGHTER, 120, P_WEAVE

; divers in echelon, from the left
        +wave 78, 1
        +spawn E_DIVER, 40, P_DIVEBOMB
        +wave 80, 1
        +spawn E_DIVER, 72, P_DIVEBOMB
        +wave 82, 1
        +spawn E_DIVER, 104, P_DIVEBOMB

; raiders sweep from the corners, two each
        +wave 100, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L
        +wave 102, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L

; leaders swoop out (medals!), each with a wingman
        +wave 122, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +wave 126, 2
        +spawn E_FIGHTER, 150, P_SWOOP_L
        +spawn E_FIGHTER, 10, P_SWOOP_R

; a V of dive-bombers
        +wave 146, 1
        +spawn E_DIVER, 86, P_DIVEBOMB
        +wave 148, 2
        +spawn E_DIVER, 56, P_DIVEBOMB
        +spawn E_DIVER, 116, P_DIVEBOMB

; a gunship hovers; divers come down either side
        +wave 166, 1
        +spawn E_GUNSHIP, 86, P_HOVER
        +wave 170, 2
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB

; fighter loops, both ways
        +wave 188, 2
        +spawn E_FIGHTER, 100, P_LOOP_L
        +spawn E_FIGHTER, 60, P_LOOP_R
        +wave 190, 2
        +spawn E_FIGHTER, 100, P_LOOP_L
        +spawn E_FIGHTER, 60, P_LOOP_R

; weaving divers
        +wave 214, 1
        +spawn E_DIVER, 40, P_WEAVE
        +wave 217, 1
        +spawn E_DIVER, 86, P_WEAVE
        +wave 220, 1
        +spawn E_DIVER, 132, P_WEAVE

; leader hovers; raiders climb from behind
        +wave 240, 1
        +spawn E_LEADER, 86, P_HOVER
        +wave 242, 1
        +spawn E_RAIDER_UP, 30, P_RISE
        +wave 245, 1
        +spawn E_RAIDER_UP, 142, P_RISE

; raider crossfire: strings from both sides
        +wave 264, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 265, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 266, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +wave 268, 1
        +spawn E_RAIDER, 171, P_CROSS_L
        +wave 269, 1
        +spawn E_RAIDER, 171, P_CROSS_L
        +wave 270, 1
        +spawn E_RAIDER, 171, P_CROSS_L

; two divers and a fighter, then two more divers
        +wave 286, 3
        +spawn E_DIVER, 40, P_DIVEBOMB
        +spawn E_DIVER, 132, P_DIVEBOMB
        +spawn E_FIGHTER, 86, P_DIVE
        +wave 290, 2
        +spawn E_DIVER, 66, P_DIVEBOMB
        +spawn E_DIVER, 106, P_DIVEBOMB

; gunship zigzag, raiders sweeping in behind it
        +wave 310, 1
        +spawn E_GUNSHIP, 86, P_ZIGZAG
        +wave 314, 1
        +spawn E_RAIDER, 20, P_DIAG_R
        +wave 316, 1
        +spawn E_RAIDER, 150, P_DIAG_L

; climbers from behind, two each way
        +wave 332, 2
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +wave 335, 2
        +spawn E_RAIDER_UP, 46, P_RISE_R
        +spawn E_RAIDER_UP, 124, P_RISE_L

; dive-bomb stream of five across the strait
        +wave 354, 1
        +spawn E_DIVER, 30, P_DIVEBOMB
        +wave 356, 1
        +spawn E_DIVER, 60, P_DIVEBOMB
        +wave 358, 1
        +spawn E_DIVER, 90, P_DIVEBOMB
        +wave 360, 1
        +spawn E_DIVER, 120, P_DIVEBOMB
        +wave 362, 1
        +spawn E_DIVER, 150, P_DIVEBOMB

; leader loops (medals!) with wingmen
        +wave 380, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +wave 384, 2
        +spawn E_FIGHTER, 120, P_LOOP_L
        +spawn E_FIGHTER, 50, P_LOOP_R

; a V of fast gunships
        +wave 412, 1
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +wave 414, 2
        +spawn E_GUNSHIP, 56, P_DIVE_FAST
        +spawn E_GUNSHIP, 116, P_DIVE_FAST

; weaving divers and a diving leader
        +wave 432, 2
        +spawn E_DIVER, 40, P_WEAVE
        +spawn E_DIVER, 120, P_WEAVE
        +wave 436, 1
        +spawn E_LEADER, 86, P_DIVE

; rear attack: five climb from behind, staggered
        +wave 458, 1
        +spawn E_RAIDER_UP, 30, P_RISE
        +wave 460, 1
        +spawn E_RAIDER_UP, 86, P_RISE
        +wave 462, 1
        +spawn E_RAIDER_UP, 142, P_RISE
        +wave 464, 1
        +spawn E_RAIDER_UP, 58, P_RISE
        +wave 466, 1
        +spawn E_RAIDER_UP, 114, P_RISE

; gunship crossfire; fighters follow from the left
        +wave 482, 2
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +wave 484, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +wave 485, 1
        +spawn E_FIGHTER, 0, P_CROSS_R

; dive-bombers: a V, then an echelon
        +wave 500, 1
        +spawn E_DIVER, 86, P_DIVEBOMB
        +wave 502, 2
        +spawn E_DIVER, 56, P_DIVEBOMB
        +spawn E_DIVER, 116, P_DIVEBOMB
        +wave 508, 1
        +spawn E_DIVER, 30, P_DIVEBOMB
        +wave 510, 1
        +spawn E_DIVER, 142, P_DIVEBOMB

; leaders swoop out; a gunship hovers
        +wave 524, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +wave 528, 1
        +spawn E_GUNSHIP, 86, P_HOVER

; last stand: weaving fighters
        +wave 548, 3
        +spawn E_FIGHTER, 40, P_WEAVE
        +spawn E_FIGHTER, 86, P_WEAVE
        +spawn E_FIGHTER, 132, P_WEAVE

        +waves_end
