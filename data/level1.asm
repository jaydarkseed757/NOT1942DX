; =============================================================================
; data/level1.asm - level 1 "OPEN OCEAN": row patterns and level stream
; Uses tileset tiles_ocean. Pure data, no code.
; =============================================================================
;
; ROW PATTERNS
; -----------------------------------------------------------------------------
; Each pattern is one 40-char screen row written as text. Each character is a
; tile (see data/tiles.asm). Legend:
;   ' ' ocean   '~' '`' waves   'o' islet
;   q ^ p       island top-left / top / top-right
;   [ g t ]     island left edge / grass / tree / right edge
;   b _ d       island bottom-left / bottom / bottom-right
; Up to 253 patterns per level.
;
; LEVEL STREAM FORMAT (one record per char row scrolled in = 8 frames)
; -----------------------------------------------------------------------------
;   byte 0        row pattern index (0-253); $FE = boss marker (1 byte);
;                 $FF = end of stream (loops back to after the boss marker)
;   byte 1        spawn count N (0-3)
;   N x 3 bytes   spawn entries: type, x (half-X), path
;
; Write records with the macros, never raw bytes:
;   +row RP_X                      plain row
;   +row_spawn RP_X, N             row with N spawns, followed by N lines of
;   +spawn E_TYPE, X, P_PATH         (types and paths: data/waves.asm)
;   +boss_here                     waves over: the boss fight starts
;   +level_end                     the rows between +boss_here and here loop
;                                  as the background until the boss dies
;
; The playfield scrolls DOWN, and each record becomes the new TOP row
; (screen row 0). The stream is in time order, so the map reads upside down:
; list an island's bottom edge first and its top edge last.
;
; The first 25 records are drawn instantly at level start to fill the screen.
; Record 0 ends up on the bottom row. Don't put spawns in those 25 records.
; After +boss_here no spawns are allowed: the boss owns the enemy slots.
;
; Enemies spawn when their row's record is consumed, so spawn timing is
; locked to the scroll position. Nothing is randomised.
;
; ENEMY BUDGET: at most ENEMY_COUNT (8 in DX; 3 in NOT 1942, which these
; waves were written for) enemies may be alive at once. A spawn
; with no free slot is dropped, which would make the waves depend on how fast
; the player kills things. Space waves using the path lifetimes listed in
; data/waves.asm (one record = 8 frames), and check with a DEBUG build: the
; hex digit at the right end of the HUD counts dropped spawns and must stay 0.
;
; DX STRETCH: NOT 1942 scrolled a row every 12 frames. tools/stretch_level.py
; added one plain copy row per two records (2:3) to keep the timing, so the
; "wave rN" comments count NOT 1942's records (after its 24 pre-drawn ones);
; multiply by 1.5 for DX records.
; =============================================================================

level1_rowpats
RP_SEA_A    = (* - level1_rowpats) / COLS
        +rowpat "   ~             ~           ~          "
RP_SEA_B    = (* - level1_rowpats) / COLS
        +rowpat "         `              `           `   "
RP_SEA_C    = (* - level1_rowpats) / COLS
        +rowpat " `           ~                   ~      "
RP_SEA_D    = (* - level1_rowpats) / COLS
        +rowpat "      `             `                 ~ "
RP_SEA_E    = (* - level1_rowpats) / COLS
        +rowpat "                          ~             "
RP_ISLET_L  = (* - level1_rowpats) / COLS
        +rowpat "        o                     ~         "
RP_ISLET_R  = (* - level1_rowpats) / COLS
        +rowpat "            `                  o        "
RP_SMALL_T  = (* - level1_rowpats) / COLS
        +rowpat "     q^^^^p              ~              "
RP_SMALL_1  = (* - level1_rowpats) / COLS
        +rowpat "     [gtgg]                      `      "
RP_SMALL_2  = (* - level1_rowpats) / COLS
        +rowpat "     [ggtg]        ~                    "
RP_SMALL_B  = (* - level1_rowpats) / COLS
        +rowpat "     b____d                 `           "
RP_LARGE_T  = (* - level1_rowpats) / COLS
        +rowpat "    ~                  q^^^^^^^^^^p     "
RP_LARGE_1  = (* - level1_rowpats) / COLS
        +rowpat "           `           [ggtggggtgg]     "
RP_LARGE_2  = (* - level1_rowpats) / COLS
        +rowpat "  ~                    [gttggtgggg]     "
RP_LARGE_3  = (* - level1_rowpats) / COLS
        +rowpat "               `       [ggggtttggg]     "
RP_LARGE_B  = (* - level1_rowpats) / COLS
        +rowpat "        ~              b__________d     "
RP_TWIN_T   = (* - level1_rowpats) / COLS
        +rowpat "  q^^^^p                    q^^^^^^p    "
RP_TWIN_1   = (* - level1_rowpats) / COLS
        +rowpat "  [gtgg]        ~           [ggtggg]    "
RP_TWIN_2   = (* - level1_rowpats) / COLS
        +rowpat "  [ggtg]                    [gtgggt]    "
RP_TWIN_B   = (* - level1_rowpats) / COLS
        +rowpat "  b____d          `         b______d    "
RP_MID_T    = (* - level1_rowpats) / COLS
        +rowpat "              q^^^^^^^^^^p          `   "
RP_MID_1    = (* - level1_rowpats) / COLS
        +rowpat "   ~          [ggtggggtgg]              "
RP_MID_2    = (* - level1_rowpats) / COLS
        +rowpat "              [gttggtgggg]     ~        "
RP_MID_B    = (* - level1_rowpats) / COLS
        +rowpat "              b__________d        ~     "
RP_REEF_A   = (* - level1_rowpats) / COLS
        +rowpat "    o          o      `    o        o   "
RP_REEF_B   = (* - level1_rowpats) / COLS
        +rowpat "  ~      o           o           o      "
RP_WIDE_T   = (* - level1_rowpats) / COLS
        +rowpat "   q^^^^^^^^^^^^^^^^^^p        ~        "
RP_WIDE_1   = (* - level1_rowpats) / COLS
        +rowpat "   [ggtggggtgggtggggtg]            `    "
RP_WIDE_2   = (* - level1_rowpats) / COLS
        +rowpat "   [gttgggggtggtgggtgg]     ~           "
RP_WIDE_B   = (* - level1_rowpats) / COLS
        +rowpat "   b__________________d          ~      "
RP_TALL_T   = (* - level1_rowpats) / COLS
        +rowpat "        `                  q^^^^^^^^p   "
RP_TALL_1   = (* - level1_rowpats) / COLS
        +rowpat "    ~                      [ggtgggtg]   "
RP_TALL_2   = (* - level1_rowpats) / COLS
        +rowpat "              `            [gtggtggg]   "
RP_TALL_B   = (* - level1_rowpats) / COLS
        +rowpat "          ~                b________d   "
level1_rowpats_end

!set ROWPAT_COUNT = (level1_rowpats_end - level1_rowpats) / COLS
!if ROWPAT_COUNT > MAX_ROWPATS { !error "too many row patterns (max 253)" }

; =============================================================================
; LEVEL STREAM (time order: first record = first row to scroll in)
; =============================================================================
; ~540 rows of waves (~88 s at 8 frames per row), then the boss.
; Sections: A rows 0-110 warm-up, B 110-210 squads and crossfire,
;           C 210-300 loops, hover gunners and streams, D 300-360 finale.
; Wave rows (r) count NOT 1942 records (see DX STRETCH above).
; =============================================================================
level1_stream
        +level_start

; --- records 0-23: starting screen (record 0 = bottom row). No spawns. ---
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B

; ===== section A: warm-up (r0) =====
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
; r4: lone fighter dives
        +row_spawn RP_SEA_E, 1
        +spawn E_FIGHTER, 86, P_DIVE
        +row RP_SEA_E
        +row RP_ISLET_L
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
; -- small --
        +row RP_SMALL_B
        +row RP_SMALL_2
        +row RP_SMALL_2
        +row RP_SMALL_1
        +row RP_SMALL_2
        +row RP_SMALL_2
; r14: a pair dives
        +row_spawn RP_SMALL_T, 2
        +spawn E_FIGHTER, 50, P_DIVE
        +spawn E_FIGHTER, 122, P_DIVE
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
; -- reef a --
        +row RP_REEF_A
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_ISLET_L
        +row RP_ISLET_L
; r28: sweep from the upper left
        +row_spawn RP_SEA_C, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +row RP_SEA_C
        +row RP_SEA_D
; -- large --
        +row RP_LARGE_B
        +row RP_LARGE_3
        +row RP_LARGE_3
        +row RP_LARGE_2
        +row RP_LARGE_2
        +row RP_LARGE_1
        +row RP_LARGE_3
        +row RP_LARGE_3
        +row RP_LARGE_2
; r36: sweep from the upper right
        +row_spawn RP_LARGE_T, 1
        +spawn E_FIGHTER, 150, P_DIAG_L
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; r46: leader swoops away left
        +row_spawn RP_SEA_D, 1
        +spawn E_LEADER, 130, P_SWOOP_L
        +row RP_SEA_D
; -- twin --
        +row RP_TWIN_B
        +row RP_TWIN_2
        +row RP_TWIN_2
        +row RP_TWIN_1
        +row RP_TWIN_2
        +row RP_TWIN_2
        +row RP_TWIN_T
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_ISLET_L
        +row RP_ISLET_L
; r56: leader swoops away right
        +row_spawn RP_SEA_D, 1
        +spawn E_LEADER, 30, P_SWOOP_R
        +row RP_SEA_E
        +row RP_SEA_E
; -- reef b --
        +row RP_REEF_B
        +row RP_REEF_B
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_ISLET_R
        +row RP_ISLET_R
; r64: fast pair
        +row_spawn RP_SEA_A, 2
        +spawn E_FIGHTER, 40, P_DIVE_FAST
        +spawn E_FIGHTER, 132, P_DIVE_FAST
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
; -- wide --
        +row RP_WIDE_B
        +row RP_WIDE_2
        +row RP_WIDE_2
        +row RP_WIDE_1
        +row RP_WIDE_2
        +row RP_WIDE_1
        +row RP_WIDE_1
        +row RP_WIDE_T
        +row RP_SEA_D
        +row RP_SEA_D
; r74: fighter crosses from the left
        +row_spawn RP_SEA_E, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_ISLET_L
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
; -- mid --
        +row RP_MID_B
; r84: first loop
        +row_spawn RP_MID_2, 1
        +spawn E_FIGHTER, 100, P_LOOP_L
        +row RP_MID_2
        +row RP_MID_1
        +row RP_MID_2
        +row RP_MID_2
        +row RP_MID_1
        +row RP_MID_2
        +row RP_MID_2
        +row RP_MID_T
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
; -- reef a --
        +row RP_REEF_A
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
; r104: three in line abreast
        +row_spawn RP_SEA_B, 3
        +spawn E_FIGHTER, 60, P_DIVE
        +spawn E_FIGHTER, 86, P_DIVE
        +spawn E_FIGHTER, 112, P_DIVE
        +row RP_SEA_B
; -- tall --
        +row RP_TALL_B
        +row RP_TALL_1
        +row RP_TALL_1
        +row RP_TALL_2
        +row RP_TALL_1
        +row RP_TALL_1
        +row RP_TALL_2

; ===== section B: squads and crossfire (r110) =====
        +row RP_TALL_1
        +row RP_TALL_2
        +row RP_TALL_2
        +row RP_TALL_T
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
; r118: leader hovers and fires twice
        +row_spawn RP_ISLET_L, 1
        +spawn E_LEADER, 86, P_HOVER
        +row RP_ISLET_L
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
; -- small --
        +row RP_SMALL_B
; r124: crossed sweeps
        +row_spawn RP_SMALL_2, 2
        +spawn E_FIGHTER, 30, P_DIAG_R
        +spawn E_FIGHTER, 140, P_DIAG_L
        +row RP_SMALL_2
        +row RP_SMALL_1
        +row RP_SMALL_2
        +row RP_SMALL_2
        +row RP_SMALL_T
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_ISLET_L
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; -- reef b --
        +row RP_REEF_B
        +row RP_SEA_D
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
; r138: zigzag squad (1/3)
        +row_spawn RP_SEA_B, 1
        +spawn E_FIGHTER, 40, P_ZIGZAG
        +row RP_ISLET_R
        +row RP_ISLET_R
; r140: zigzag squad (2/3)
        +row_spawn RP_SEA_D, 1
        +spawn E_FIGHTER, 86, P_ZIGZAG
        +row RP_SEA_E
        +row RP_SEA_E
; r142: zigzag squad (3/3)
        +row_spawn RP_SEA_A, 1
        +spawn E_FIGHTER, 132, P_ZIGZAG
        +row RP_SEA_A
; -- large --
        +row RP_LARGE_B
        +row RP_LARGE_3
        +row RP_LARGE_2
        +row RP_LARGE_2
        +row RP_LARGE_1
        +row RP_LARGE_1
        +row RP_LARGE_3
        +row RP_LARGE_2
        +row RP_LARGE_2
        +row RP_LARGE_T
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
; -- wide --
        +row RP_WIDE_B
        +row RP_WIDE_2
        +row RP_WIDE_2
; r160: crossfire
        +row_spawn RP_WIDE_1, 1
        +spawn E_LEADER, 171, P_CROSS_L
        +row RP_WIDE_1
        +row RP_WIDE_2
        +row RP_WIDE_1
        +row RP_WIDE_1
; r163: crossfire
        +row_spawn RP_WIDE_T, 1
        +spawn E_FIGHTER, 0, P_CROSS_R
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
; -- twin --
; r174: loops left and right
        +row_spawn RP_TWIN_B, 1
        +spawn E_FIGHTER, 60, P_LOOP_R
        +row RP_TWIN_2
        +row RP_TWIN_2
        +row RP_TWIN_1
        +row RP_TWIN_2
        +row RP_TWIN_2
; r178: loops left and right
        +row_spawn RP_TWIN_T, 1
        +spawn E_FIGHTER, 110, P_LOOP_L
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
; -- reef a --
        +row RP_REEF_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; -- mid --
        +row RP_MID_B
        +row RP_MID_2
        +row RP_MID_2
        +row RP_MID_1
        +row RP_MID_1
        +row RP_MID_2
; r198: leaders swoop out both ways
        +row_spawn RP_MID_1, 2
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R
        +row RP_MID_2
        +row RP_MID_2
        +row RP_MID_T
        +row RP_SEA_D
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_ISLET_L
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B

; ===== section C: loops, hover gunners and streams (r210) =====
        +row RP_SEA_C
        +row RP_SEA_C
; -- tall --
        +row RP_TALL_B
        +row RP_TALL_1
        +row RP_TALL_1
        +row RP_TALL_2
        +row RP_TALL_1
        +row RP_TALL_1
        +row RP_TALL_2
        +row RP_TALL_1
        +row RP_TALL_2
        +row RP_TALL_2
; r218: fast trio
        +row_spawn RP_TALL_T, 3
        +spawn E_FIGHTER, 30, P_DIVE_FAST
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +spawn E_FIGHTER, 142, P_DIVE_FAST
        +row RP_SEA_D
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
; -- reef b --
        +row RP_REEF_B
; r228: twin hover gunners
        +row_spawn RP_SEA_B, 1
        +spawn E_LEADER, 50, P_HOVER
        +row RP_SEA_C
        +row RP_SEA_C
; r230: twin hover gunners
        +row_spawn RP_SEA_D, 1
        +spawn E_LEADER, 120, P_HOVER
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
; -- wide --
        +row RP_WIDE_B
        +row RP_WIDE_2
        +row RP_WIDE_2
        +row RP_WIDE_1
        +row RP_WIDE_1
        +row RP_WIDE_2
        +row RP_WIDE_1
        +row RP_WIDE_1
        +row RP_WIDE_T
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; r246: interlocking loops
        +row_spawn RP_SEA_D, 1
        +spawn E_FIGHTER, 90, P_LOOP_L
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_A
        +row RP_SEA_A
; r249: interlocking loops
        +row_spawn RP_SEA_B, 1
        +spawn E_FIGHTER, 70, P_LOOP_R
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
; -- small --
        +row RP_SMALL_B
        +row RP_SMALL_2
        +row RP_SMALL_2
        +row RP_SMALL_1
        +row RP_SMALL_2
        +row RP_SMALL_2
        +row RP_SMALL_T
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
; -- large --
        +row RP_LARGE_B
        +row RP_LARGE_3
        +row RP_LARGE_2
        +row RP_LARGE_2
        +row RP_LARGE_1
        +row RP_LARGE_1
        +row RP_LARGE_3
; r270: sweep stream (1/3)
        +row_spawn RP_LARGE_2, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +row RP_LARGE_2
        +row RP_LARGE_T
; r272: sweep stream (2/3)
        +row_spawn RP_SEA_C, 1
        +spawn E_FIGHTER, 50, P_DIAG_R
        +row RP_SEA_C
        +row RP_SEA_D
; r274: sweep stream (3/3)
        +row_spawn RP_SEA_E, 1
        +spawn E_FIGHTER, 80, P_DIAG_R
        +row RP_SEA_E
        +row RP_ISLET_L
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
; r290: zigzag leader with dive escort
        +row_spawn RP_SEA_A, 3
        +spawn E_LEADER, 86, P_ZIGZAG
        +spawn E_FIGHTER, 30, P_DIVE
        +spawn E_FIGHTER, 142, P_DIVE
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E

; ===== section D: finale (r300) =====
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
; r306: crossfire, both at once
        +row_spawn RP_SEA_B, 2
        +spawn E_FIGHTER, 0, P_CROSS_R
        +spawn E_LEADER, 171, P_CROSS_L
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; r318: leader loops, both ways
        +row_spawn RP_SEA_D, 2
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +row RP_ISLET_L
        +row RP_ISLET_L
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; r338: fast trio
        +row_spawn RP_SEA_D, 3
        +spawn E_FIGHTER, 40, P_DIVE_FAST
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +spawn E_FIGHTER, 132, P_DIVE_FAST
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
; r348: last stand: swoops and a fast dive
        +row_spawn RP_SEA_D, 3
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_FIGHTER, 86, P_DIVE_FAST
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E

; --- boss fight: open sea loops until the boss is destroyed ---
        +boss_here
        +row RP_SEA_B
        +row RP_SEA_B
        +row RP_SEA_C
        +row RP_ISLET_R
        +row RP_ISLET_R
        +row RP_SEA_D
        +row RP_SEA_E
        +row RP_SEA_E
        +row RP_SEA_A
        +row RP_REEF_A
        +row RP_SEA_B
        +row RP_SEA_B

        +level_end
