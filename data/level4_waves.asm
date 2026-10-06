; =============================================================================
; data/level4_waves.asm - level 4: enemy waves and the boss row
; =============================================================================
;
; The level's picture is data/levels/level4.png (see tools/png2level.py).
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

level4_waves
        +waves_start LEVEL4_BOSS_ROW

; r4: aces dive in a pair
        +wave 42, 2
        +spawn E_ACE, 50, P_DIVE_FAST
        +spawn E_ACE, 122, P_DIVE_FAST

; r14: a gunship hovers over the fleet
        +wave 57, 1
        +spawn E_GUNSHIP, 86, P_HOVER

; r26: dive-bombers from both sides
        +wave 75, 2
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB

; r40: aces loop
        +wave 96, 2
        +spawn E_ACE, 100, P_LOOP_L
        +spawn E_ACE, 60, P_LOOP_R

; r60: leaders swoop (medals!)
        +wave 126, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R

; r76: rear attack trio
        +wave 150, 3
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 86, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE

; r90: ace crossfire
        +wave 171, 2
        +spawn E_ACE, 0, P_CROSS_R
        +spawn E_ACE, 171, P_CROSS_L

; r102: weaving gunships
        +wave 189, 2
        +spawn E_GUNSHIP, 40, P_WEAVE
        +spawn E_GUNSHIP, 120, P_WEAVE

; r118: fast ace trio
        +wave 213, 3
        +spawn E_ACE, 30, P_DIVE_FAST
        +spawn E_ACE, 86, P_DIVE_FAST
        +spawn E_ACE, 142, P_DIVE_FAST

; r128: divers and a hovering leader
        +wave 228, 3
        +spawn E_DIVER, 40, P_DIVEBOMB
        +spawn E_DIVER, 132, P_DIVEBOMB
        +spawn E_LEADER, 86, P_HOVER

; r144: raiders sweep the corners
        +wave 252, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L

; r156: ace zigzag squad (1/3)
        +wave 270, 1
        +spawn E_ACE, 40, P_ZIGZAG

; r158: ace zigzag squad (2/3)
        +wave 273, 1
        +spawn E_ACE, 86, P_ZIGZAG

; r160: ace zigzag squad (3/3)
        +wave 276, 1
        +spawn E_ACE, 132, P_ZIGZAG

; r176: climbers from behind
        +wave 300, 2
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L

; r189: carrier launch: fighters loop
        +wave 319, 2
        +spawn E_FIGHTER, 90, P_LOOP_L
        +spawn E_FIGHTER, 70, P_LOOP_R

; r209: gunship crossfire
        +wave 350, 2
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L

; r221: dive-bomb stream (1/3)
        +wave 368, 1
        +spawn E_DIVER, 30, P_DIVEBOMB

; r223: dive-bomb stream (2/3)
        +wave 371, 1
        +spawn E_DIVER, 60, P_DIVEBOMB

; r225: dive-bomb stream (3/3)
        +wave 373, 1
        +spawn E_DIVER, 90, P_DIVEBOMB

; r237: leaders loop (medals!)
        +wave 392, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R

; r257: fast ace trio
        +wave 422, 3
        +spawn E_ACE, 30, P_DIVE_FAST
        +spawn E_ACE, 86, P_DIVE_FAST
        +spawn E_ACE, 142, P_DIVE_FAST

; r267: rear attack and a gunship hover
        +wave 437, 3
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE
        +spawn E_GUNSHIP, 86, P_HOVER

; r283: weaving aces
        +wave 461, 3
        +spawn E_ACE, 40, P_WEAVE
        +spawn E_ACE, 86, P_WEAVE
        +spawn E_ACE, 132, P_WEAVE

; r303: ace crossfire
        +wave 491, 2
        +spawn E_ACE, 0, P_CROSS_R
        +spawn E_ACE, 171, P_CROSS_L

; r314: dive-bomber trio
        +wave 507, 3
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 86, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB

; r328: leaders swoop, a gunship dives (medals!)
        +wave 528, 3
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_GUNSHIP, 86, P_DIVE_FAST

; r346: last stand: fast aces
        +wave 555, 3
        +spawn E_ACE, 40, P_DIVE_FAST
        +spawn E_ACE, 86, P_DIVE_FAST
        +spawn E_ACE, 132, P_DIVE_FAST

        +waves_end
