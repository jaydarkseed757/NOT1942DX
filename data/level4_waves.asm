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
; DX retunes NOT 1942's waves for 8 enemy slots, as in levels 1-3: the same
; moves flown as formations (no more than 3 planes on one row; echelons and
; strings one or two rows apart), at most 6 alive. The carriers in the
; picture (rows 196 and 378) launch fighters as they pass.
; ENEMY BUDGET: run python3 tools/check_waves.py on this file after edits.
; =============================================================================

level4_waves
        +waves_start LEVEL4_BOSS_ROW


; aces dive in a pair
        +wave 42, 2
        +spawn E_ACE, 50, P_DIVE_FAST
        +spawn E_ACE, 122, P_DIVE_FAST

; turbo build: a pair (ace, dive_fast)
        +wave_turbo 49, 2
        +spawn_turbo E_ACE, 46, P_DIVE_FAST
        +spawn_turbo E_ACE, 126, P_DIVE_FAST

; a gunship hovers over the fleet; aces dive past it
        +wave 58, 1
        +spawn E_GUNSHIP, 86, P_HOVER
        +wave 61, 2
        +spawn E_ACE, 40, P_DIVE
        +spawn E_ACE, 132, P_DIVE

; dive-bombers from both sides, in pairs
        +wave 78, 2
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB
        +wave 81, 2
        +spawn E_DIVER, 58, P_DIVEBOMB
        +spawn E_DIVER, 114, P_DIVEBOMB

; turbo build: a pair (ace, diag_r)
        +wave_turbo 88, 2
        +spawn_turbo E_ACE, 20, P_DIAG_R
        +spawn_turbo E_ACE, 40, P_DIAG_R

; aces loop, two each way
        +wave 100, 2
        +spawn E_ACE, 100, P_LOOP_L
        +spawn E_ACE, 60, P_LOOP_R
        +wave 102, 2
        +spawn E_ACE, 100, P_LOOP_L
        +spawn E_ACE, 60, P_LOOP_R

; turbo build: a pair (diver, divebomb)
        +wave_turbo 109, 2
        +spawn_turbo E_DIVER, 58, P_DIVEBOMB
        +spawn_turbo E_DIVER, 114, P_DIVEBOMB

; leaders swoop (medals!), each with an ace on its wing
        +wave 128, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +wave 132, 2
        +spawn E_ACE, 150, P_SWOOP_L
        +spawn E_ACE, 10, P_SWOOP_R

; turbo build: a pair (ace, diag_l)
        +wave_turbo 139, 2
        +spawn_turbo E_ACE, 150, P_DIAG_L
        +spawn_turbo E_ACE, 130, P_DIAG_L

; rear attack: five climb from behind, staggered
        +wave 150, 1
        +spawn E_RAIDER_UP, 30, P_RISE
        +wave 152, 1
        +spawn E_RAIDER_UP, 86, P_RISE
        +wave 154, 1
        +spawn E_RAIDER_UP, 142, P_RISE
        +wave 156, 1
        +spawn E_RAIDER_UP, 58, P_RISE
        +wave 158, 1
        +spawn E_RAIDER_UP, 114, P_RISE

; turbo build: a pair (ace, dive_fast)
        +wave_turbo 163, 2
        +spawn_turbo E_ACE, 46, P_DIVE_FAST
        +spawn_turbo E_ACE, 126, P_DIVE_FAST

; ace crossfire: strings from both sides
        +wave 172, 1
        +spawn E_ACE, 0, P_CROSS_R
        +wave 173, 1
        +spawn E_ACE, 0, P_CROSS_R
        +wave 174, 1
        +spawn E_ACE, 0, P_CROSS_R
        +wave 176, 1
        +spawn E_ACE, 171, P_CROSS_L
        +wave 177, 1
        +spawn E_ACE, 171, P_CROSS_L
        +wave 178, 1
        +spawn E_ACE, 171, P_CROSS_L

; carrier launch: fighters loop up from the carrier
        +wave 194, 2
        +spawn E_FIGHTER, 90, P_LOOP_L
        +spawn E_FIGHTER, 70, P_LOOP_R
        +wave 196, 2
        +spawn E_FIGHTER, 90, P_LOOP_L
        +spawn E_FIGHTER, 70, P_LOOP_R
        +wave 198, 1
        +spawn E_FIGHTER, 90, P_LOOP_L

; turbo build: a pair (ace, diag_r)
        +wave_turbo 205, 2
        +spawn_turbo E_ACE, 20, P_DIAG_R
        +spawn_turbo E_ACE, 40, P_DIAG_R

; weaving gunships, an ace diving between
        +wave 228, 2
        +spawn E_GUNSHIP, 40, P_WEAVE
        +spawn E_GUNSHIP, 120, P_WEAVE
        +wave 232, 1
        +spawn E_ACE, 86, P_DIVE_FAST

; turbo build: a pair (diver, divebomb)
        +wave_turbo 238, 2
        +spawn_turbo E_DIVER, 58, P_DIVEBOMB
        +spawn_turbo E_DIVER, 114, P_DIVEBOMB

; fast ace echelon
        +wave 250, 1
        +spawn E_ACE, 30, P_DIVE_FAST
        +wave 252, 1
        +spawn E_ACE, 66, P_DIVE_FAST
        +wave 254, 1
        +spawn E_ACE, 102, P_DIVE_FAST
        +wave 256, 1
        +spawn E_ACE, 138, P_DIVE_FAST

; turbo build: a pair (ace, diag_l)
        +wave_turbo 262, 2
        +spawn_turbo E_ACE, 150, P_DIAG_L
        +spawn_turbo E_ACE, 130, P_DIAG_L

; divers and a hovering leader
        +wave 268, 3
        +spawn E_DIVER, 40, P_DIVEBOMB
        +spawn E_DIVER, 132, P_DIVEBOMB
        +spawn E_LEADER, 86, P_HOVER
        +wave 271, 2
        +spawn E_DIVER, 66, P_DIVEBOMB
        +spawn E_DIVER, 106, P_DIVEBOMB

; turbo build: a pair (ace, dive_fast)
        +wave_turbo 283, 2
        +spawn_turbo E_ACE, 46, P_DIVE_FAST
        +spawn_turbo E_ACE, 126, P_DIVE_FAST

; raiders sweep the corners, two each
        +wave 290, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L
        +wave 292, 2
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L

; turbo build: a pair (ace, diag_r)
        +wave_turbo 298, 2
        +spawn_turbo E_ACE, 20, P_DIAG_R
        +spawn_turbo E_ACE, 40, P_DIAG_R

; ace zigzag squad of five
        +wave 310, 1
        +spawn E_ACE, 30, P_ZIGZAG
        +wave 312, 1
        +spawn E_ACE, 58, P_ZIGZAG
        +wave 314, 1
        +spawn E_ACE, 86, P_ZIGZAG
        +wave 316, 1
        +spawn E_ACE, 114, P_ZIGZAG
        +wave 318, 1
        +spawn E_ACE, 142, P_ZIGZAG


; climbers from behind, two each way
        +wave 338, 2
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +wave 341, 2
        +spawn E_RAIDER_UP, 46, P_RISE_R
        +spawn E_RAIDER_UP, 124, P_RISE_L

; turbo build: a pair (ace, diag_l)
        +wave_turbo 346, 2
        +spawn_turbo E_ACE, 150, P_DIAG_L
        +spawn_turbo E_ACE, 130, P_DIAG_L

; gunship crossfire
        +wave 360, 2
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L

; turbo build: a pair (ace, dive_fast)
        +wave_turbo 367, 2
        +spawn_turbo E_ACE, 46, P_DIVE_FAST
        +spawn_turbo E_ACE, 126, P_DIVE_FAST

; carrier launch: a string of fighters loops each way
        +wave 376, 1
        +spawn E_FIGHTER, 90, P_LOOP_L
        +wave 377, 1
        +spawn E_FIGHTER, 90, P_LOOP_L
        +wave 381, 1
        +spawn E_FIGHTER, 70, P_LOOP_R
        +wave 382, 1
        +spawn E_FIGHTER, 70, P_LOOP_R

; turbo build: a pair (ace, diag_r)
        +wave_turbo 388, 2
        +spawn_turbo E_ACE, 20, P_DIAG_R
        +spawn_turbo E_ACE, 40, P_DIAG_R

; dive-bomb stream of five
        +wave 406, 1
        +spawn E_DIVER, 30, P_DIVEBOMB
        +wave 408, 1
        +spawn E_DIVER, 60, P_DIVEBOMB
        +wave 410, 1
        +spawn E_DIVER, 90, P_DIVEBOMB
        +wave 412, 1
        +spawn E_DIVER, 120, P_DIVEBOMB
        +wave 414, 1
        +spawn E_DIVER, 150, P_DIVEBOMB

; turbo build: a pair (diver, divebomb)
        +wave_turbo 421, 2
        +spawn_turbo E_DIVER, 58, P_DIVEBOMB
        +spawn_turbo E_DIVER, 114, P_DIVEBOMB

; leaders loop (medals!) with ace wingmen
        +wave 428, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +wave 432, 2
        +spawn E_ACE, 120, P_LOOP_L
        +spawn E_ACE, 50, P_LOOP_R

; turbo build: a pair (ace, diag_l)
        +wave_turbo 439, 2
        +spawn_turbo E_ACE, 150, P_DIAG_L
        +spawn_turbo E_ACE, 130, P_DIAG_L

; rear attack around a hovering gunship
        +wave 458, 3
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE
        +spawn E_GUNSHIP, 86, P_HOVER
        +wave 461, 2
        +spawn E_RAIDER_UP, 58, P_RISE
        +spawn E_RAIDER_UP, 114, P_RISE

; turbo build: a pair (ace, dive_fast)
        +wave_turbo 466, 2
        +spawn_turbo E_ACE, 46, P_DIVE_FAST
        +spawn_turbo E_ACE, 126, P_DIVE_FAST

; weaving aces
        +wave 480, 3
        +spawn E_ACE, 40, P_WEAVE
        +spawn E_ACE, 86, P_WEAVE
        +spawn E_ACE, 132, P_WEAVE

; turbo build: a pair (ace, diag_r)
        +wave_turbo 487, 2
        +spawn_turbo E_ACE, 20, P_DIAG_R
        +spawn_turbo E_ACE, 40, P_DIAG_R

; turbo build: a pair (diver, divebomb)
        +wave_turbo 499, 2
        +spawn_turbo E_DIVER, 58, P_DIVEBOMB
        +spawn_turbo E_DIVER, 114, P_DIVEBOMB

; ace crossfire
        +wave 508, 1
        +spawn E_ACE, 0, P_CROSS_R
        +wave 509, 1
        +spawn E_ACE, 0, P_CROSS_R
        +wave 511, 1
        +spawn E_ACE, 171, P_CROSS_L
        +wave 512, 1
        +spawn E_ACE, 171, P_CROSS_L

; turbo build: a pair (ace, diag_l)
        +wave_turbo 517, 2
        +spawn_turbo E_ACE, 150, P_DIAG_L
        +spawn_turbo E_ACE, 130, P_DIAG_L

; dive-bombers: a V
        +wave 526, 1
        +spawn E_DIVER, 86, P_DIVEBOMB
        +wave 528, 2
        +spawn E_DIVER, 56, P_DIVEBOMB
        +spawn E_DIVER, 116, P_DIVEBOMB

; leaders swoop out (medals!), then gunships dive
        +wave 532, 2
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R

; turbo build: a pair (ace, dive_fast)
        +wave_turbo 538, 2
        +spawn_turbo E_ACE, 46, P_DIVE_FAST
        +spawn_turbo E_ACE, 126, P_DIVE_FAST
        +wave 548, 1
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +wave 550, 2
        +spawn E_GUNSHIP, 58, P_DIVE_FAST
        +spawn E_GUNSHIP, 114, P_DIVE_FAST

; turbo build: a pair (ace, diag_r)
        +wave_turbo 556, 2
        +spawn_turbo E_ACE, 20, P_DIAG_R
        +spawn_turbo E_ACE, 40, P_DIAG_R

; last stand: a V of fast aces
        +wave 562, 1
        +spawn E_ACE, 86, P_DIVE_FAST
        +wave 564, 2
        +spawn E_ACE, 66, P_DIVE_FAST
        +spawn E_ACE, 106, P_DIVE_FAST

        +waves_end
