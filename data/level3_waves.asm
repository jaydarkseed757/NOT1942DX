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
; The "rN" comments are NOT 1942's record numbers, before DX's 2:3 stretch.
; ENEMY BUDGET: run python3 tools/check_waves.py on this file after edits.
; =============================================================================

level3_waves
        +waves_start LEVEL3_BOSS_ROW

; r4: a diver dive-bombs
        +wave 42, 1
        +spawn E_DIVER, 86, P_DIVEBOMB

; r14: fighters weave in
        +wave 57, 2
        +spawn E_FIGHTER, 40, P_WEAVE
        +spawn E_FIGHTER, 120, P_WEAVE

; r30: divers, one each side
        +wave 81, 1
        +spawn E_DIVER, 50, P_DIVEBOMB

; r32: divers, one each side
        +wave 84, 1
        +spawn E_DIVER, 120, P_DIVEBOMB

; r44: raiders sweep from the corners
        +wave 102, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L

; r58: leaders swoop out (medals!)
        +wave 123, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R

; r74: dive-bomber trio
        +wave 147, 3
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 86, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB

; r86: a gunship hovers
        +wave 165, 1
        +spawn E_GUNSHIP, 86, P_HOVER

; r98: fighter loops
        +wave 183, 2
        +spawn E_FIGHTER, 100, P_LOOP_L
        +spawn E_FIGHTER, 60, P_LOOP_R

; r118: weaving divers (1/3)
        +wave 213, 1
        +spawn E_DIVER, 40, P_WEAVE

; r120: weaving divers (2/3)
        +wave 216, 1
        +spawn E_DIVER, 86, P_WEAVE

; r122: weaving divers (3/3)
        +wave 219, 1
        +spawn E_DIVER, 132, P_WEAVE

; r140: leader hovers, a raider climbs from behind
        +wave 246, 2
        +spawn E_LEADER, 86, P_HOVER
        +spawn E_RAIDER_UP, 30, P_RISE

; r156: raider crossfire
        +wave 270, 2
        +spawn E_RAIDER, 0, P_CROSS_R
        +spawn E_RAIDER, 171, P_CROSS_L

; r170: two divers and a fighter
        +wave 291, 3
        +spawn E_DIVER, 40, P_DIVEBOMB
        +spawn E_DIVER, 132, P_DIVEBOMB
        +spawn E_FIGHTER, 86, P_DIVE

; r184: gunship zigzag
        +wave 312, 1
        +spawn E_GUNSHIP, 86, P_ZIGZAG

; r194: climbers from behind
        +wave 327, 2
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L

; r210: dive-bomb stream (1/3)
        +wave 351, 1
        +spawn E_DIVER, 30, P_DIVEBOMB

; r212: dive-bomb stream (2/3)
        +wave 354, 1
        +spawn E_DIVER, 60, P_DIVEBOMB

; r214: dive-bomb stream (3/3)
        +wave 357, 1
        +spawn E_DIVER, 90, P_DIVEBOMB

; r228: leader loops (medals!)
        +wave 378, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R

; r250: fast gunship trio
        +wave 411, 3
        +spawn E_GUNSHIP, 30, P_DIVE_FAST
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +spawn E_GUNSHIP, 142, P_DIVE_FAST

; r264: weaving divers and a diving leader
        +wave 432, 3
        +spawn E_DIVER, 40, P_WEAVE
        +spawn E_DIVER, 120, P_WEAVE
        +spawn E_LEADER, 86, P_DIVE

; r282: rear attack, three abreast
        +wave 459, 3
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 86, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE

; r298: gunship crossfire
        +wave 483, 2
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L

; r310: dive-bomber trio
        +wave 501, 3
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 86, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB

; r324: leaders swoop, a gunship hovers
        +wave 522, 3
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_GUNSHIP, 86, P_HOVER

; r342: last stand: weaving fighters
        +wave 549, 3
        +spawn E_FIGHTER, 40, P_WEAVE
        +spawn E_FIGHTER, 86, P_WEAVE
        +spawn E_FIGHTER, 132, P_WEAVE

        +waves_end
