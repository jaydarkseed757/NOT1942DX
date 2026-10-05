; =============================================================================
; data/level4.asm - level 4 "ENEMY FLEET": row patterns and level stream
; Uses tileset tiles_fleet (data/tiles_fleet.asm). Pure data, no code.
; =============================================================================
;
; A stormy sea; the enemy fleet steams past underneath you: destroyers,
; cruisers and an aircraft carrier with planes on deck, all with wakes.
; Ships are scenery only. Then the flagship "Kraken" (boss 4, the final boss).
; Stream format, macros and rules: see data/level1.asm.
;
; Ships appear wake first and bow last in the stream (time order), so on
; screen they point up the page, bows towards the top. Each stream line shows
; its row as a comment, so the stream reads as the map (upside down).
; Tiles: A/B bow, H/I hull sides, D deck, T turret, S superstructure,
;        F funnel, J/K stern, V/W wake, P/Y/Q carrier deck, ~ ` whitecaps.
; =============================================================================

level4_rowpats
L4_000  = (* - level4_rowpats) / COLS
        +rowpat "     ~                `                 "
L4_001  = (* - level4_rowpats) / COLS
        +rowpat "           `                ~       ~   "
L4_002  = (* - level4_rowpats) / COLS
        +rowpat "                 ~               `      "
L4_003  = (* - level4_rowpats) / COLS
        +rowpat "  `                      ~              "
L4_004  = (* - level4_rowpats) / COLS
        +rowpat "        ~                     `         "
L4_005  = (* - level4_rowpats) / COLS
        +rowpat "              `                      ~  "
L4_006  = (* - level4_rowpats) / COLS
        +rowpat "      V  W                              "
L4_007  = (* - level4_rowpats) / COLS
        +rowpat "       VW                               "
L4_008  = (* - level4_rowpats) / COLS
        +rowpat "      JDDK                              "
L4_009  = (* - level4_rowpats) / COLS
        +rowpat "      HTDI                              "
L4_010  = (* - level4_rowpats) / COLS
        +rowpat "      HDDI                              "
L4_011  = (* - level4_rowpats) / COLS
        +rowpat "      HSFI                              "
L4_012  = (* - level4_rowpats) / COLS
        +rowpat "      ADDB                              "
L4_013  = (* - level4_rowpats) / COLS
        +rowpat "       AB                               "
L4_014  = (* - level4_rowpats) / COLS
        +rowpat "                              V  W      "
L4_015  = (* - level4_rowpats) / COLS
        +rowpat "                               VW       "
L4_016  = (* - level4_rowpats) / COLS
        +rowpat "                              JDDK      "
L4_017  = (* - level4_rowpats) / COLS
        +rowpat "                              HTDI      "
L4_018  = (* - level4_rowpats) / COLS
        +rowpat "                              HDDI      "
L4_019  = (* - level4_rowpats) / COLS
        +rowpat "                              HSFI      "
L4_020  = (* - level4_rowpats) / COLS
        +rowpat "                              ADDB      "
L4_021  = (* - level4_rowpats) / COLS
        +rowpat "                               AB       "
L4_022  = (* - level4_rowpats) / COLS
        +rowpat "        V  W                            "
L4_023  = (* - level4_rowpats) / COLS
        +rowpat "         VW                             "
L4_024  = (* - level4_rowpats) / COLS
        +rowpat "        JDDK                            "
L4_025  = (* - level4_rowpats) / COLS
        +rowpat "        HDTI                            "
L4_026  = (* - level4_rowpats) / COLS
        +rowpat "        HDDI                            "
L4_027  = (* - level4_rowpats) / COLS
        +rowpat "        HFDI                            "
L4_028  = (* - level4_rowpats) / COLS
        +rowpat "        HSDI                            "
L4_029  = (* - level4_rowpats) / COLS
        +rowpat "        HTDI                            "
L4_030  = (* - level4_rowpats) / COLS
        +rowpat "        ADDB                            "
L4_031  = (* - level4_rowpats) / COLS
        +rowpat "         AB                             "
L4_032  = (* - level4_rowpats) / COLS
        +rowpat "                  V  W                  "
L4_033  = (* - level4_rowpats) / COLS
        +rowpat "                   VW                   "
L4_034  = (* - level4_rowpats) / COLS
        +rowpat "                  JDDK                  "
L4_035  = (* - level4_rowpats) / COLS
        +rowpat "                  HTDI                  "
L4_036  = (* - level4_rowpats) / COLS
        +rowpat "                  HDDI                  "
L4_037  = (* - level4_rowpats) / COLS
        +rowpat "                  HSFI                  "
L4_038  = (* - level4_rowpats) / COLS
        +rowpat "                  ADDB                  "
L4_039  = (* - level4_rowpats) / COLS
        +rowpat "                   AB                   "
L4_040  = (* - level4_rowpats) / COLS
        +rowpat "      V  W                    V  W      "
L4_041  = (* - level4_rowpats) / COLS
        +rowpat "       VW                      VW       "
L4_042  = (* - level4_rowpats) / COLS
        +rowpat "      JDDK                    JDDK      "
L4_043  = (* - level4_rowpats) / COLS
        +rowpat "      HTDI                    HTDI      "
L4_044  = (* - level4_rowpats) / COLS
        +rowpat "      HDDI                    HDDI      "
L4_045  = (* - level4_rowpats) / COLS
        +rowpat "      HSFI                    HSFI      "
L4_046  = (* - level4_rowpats) / COLS
        +rowpat "      ADDB                    ADDB      "
L4_047  = (* - level4_rowpats) / COLS
        +rowpat "       AB                      AB       "
L4_048  = (* - level4_rowpats) / COLS
        +rowpat "                          V  W          "
L4_049  = (* - level4_rowpats) / COLS
        +rowpat "                           VW           "
L4_050  = (* - level4_rowpats) / COLS
        +rowpat "                          JDDK          "
L4_051  = (* - level4_rowpats) / COLS
        +rowpat "                          HDTI          "
L4_052  = (* - level4_rowpats) / COLS
        +rowpat "                          HDDI          "
L4_053  = (* - level4_rowpats) / COLS
        +rowpat "                          HFDI          "
L4_054  = (* - level4_rowpats) / COLS
        +rowpat "                          HSDI          "
L4_055  = (* - level4_rowpats) / COLS
        +rowpat "                          HTDI          "
L4_056  = (* - level4_rowpats) / COLS
        +rowpat "                          ADDB          "
L4_057  = (* - level4_rowpats) / COLS
        +rowpat "                           AB           "
L4_058  = (* - level4_rowpats) / COLS
        +rowpat "      HDDI       V    W                 "
L4_059  = (* - level4_rowpats) / COLS
        +rowpat "      HSFI        V  W                  "
L4_060  = (* - level4_rowpats) / COLS
        +rowpat "      HTDI       JPYPPK                 "
L4_061  = (* - level4_rowpats) / COLS
        +rowpat "      ADDB       HPYPPI                 "
L4_062  = (* - level4_rowpats) / COLS
        +rowpat "       AB        HPYPPI                 "
L4_063  = (* - level4_rowpats) / COLS
        +rowpat "                 HQYPQI                 "
L4_064  = (* - level4_rowpats) / COLS
        +rowpat "                 HPYPPI                 "
L4_065  = (* - level4_rowpats) / COLS
        +rowpat "                 HQYQPI                 "
L4_066  = (* - level4_rowpats) / COLS
        +rowpat "                 HQYPSI                 "
L4_067  = (* - level4_rowpats) / COLS
        +rowpat "                 HPYQSI       V  W      "
L4_068  = (* - level4_rowpats) / COLS
        +rowpat "                 HQYPSI        VW       "
L4_069  = (* - level4_rowpats) / COLS
        +rowpat "                 HPYPPI       JDDK      "
L4_070  = (* - level4_rowpats) / COLS
        +rowpat "                 APYPPB       HTDI      "
L4_071  = (* - level4_rowpats) / COLS
        +rowpat "      V  W                    HTDI      "
L4_072  = (* - level4_rowpats) / COLS
        +rowpat "       VW                     ADDB      "
L4_073  = (* - level4_rowpats) / COLS
        +rowpat "      JDDK                     AB       "
level4_rowpats_end

!set ROWPAT_COUNT = (level4_rowpats_end - level4_rowpats) / COLS
!if ROWPAT_COUNT > MAX_ROWPATS { !error "too many row patterns (max 253)" }

; =============================================================================
; LEVEL STREAM. 360 rows of waves (~86 s), then the final boss.
; Sections: A rows 0-95 the outer screen, B 95-180 destroyer lines,
;           C 180-265 the carrier group, D 265-360 the last escorts.
; =============================================================================
level4_stream
; DX STRETCH: tools/stretch_level.py added one plain copy row per two records
; (2:3) for DX's 8-frame rows, so the "rN" comments count NOT 1942's
; records; multiply by 1.5 for DX records. See data/level1.asm.
        +level_start

; --- records 0-23: starting screen (storm sea). No spawns. ---
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |

; ===== section A: the outer screen (r0) =====
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
; r4: aces dive in a pair
        +row_spawn L4_004, 2  ; |        ~                     `         |
        +spawn E_ACE, 50, P_DIVE_FAST
        +spawn E_ACE, 122, P_DIVE_FAST
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
; r14: a gunship hovers over the fleet
        +row_spawn L4_002, 1  ; |                 ~               `      |
        +spawn E_GUNSHIP, 86, P_HOVER
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_006           ; |      V  W                              |
        +row L4_006
        +row L4_007           ; |       VW                               |
        +row L4_008           ; |      JDDK                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_010           ; |      HDDI                              |
        +row L4_010
        +row L4_011           ; |      HSFI                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_012           ; |      ADDB                              |
        +row L4_013           ; |       AB                               |
        +row L4_013
        +row L4_001           ; |           `                ~       ~   |
; r26: dive-bombers from both sides
        +row_spawn L4_002, 2  ; |                 ~               `      |
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
; r40: aces loop
        +row_spawn L4_014, 2  ; |                              V  W      |
        +spawn E_ACE, 100, P_LOOP_L
        +spawn E_ACE, 60, P_LOOP_R
        +row L4_014
        +row L4_015           ; |                               VW       |
        +row L4_016           ; |                              JDDK      |
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_018           ; |                              HDDI      |
        +row L4_018
        +row L4_019           ; |                              HSFI      |
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_020           ; |                              ADDB      |
        +row L4_021           ; |                               AB       |
        +row L4_021
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
; r60: leaders swoop (medals!)
        +row_spawn L4_000, 2  ; |     ~                `                 |
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_022           ; |        V  W                            |
        +row L4_022
        +row L4_023           ; |         VW                             |
        +row L4_024           ; |        JDDK                            |
        +row L4_025           ; |        HDTI                            |
        +row L4_025
        +row L4_026           ; |        HDDI                            |
        +row L4_026
        +row L4_027           ; |        HFDI                            |
        +row L4_028           ; |        HSDI                            |
        +row L4_028
        +row L4_026           ; |        HDDI                            |
        +row L4_029           ; |        HTDI                            |
        +row L4_029
        +row L4_029           ; |        HTDI                            |
        +row L4_030           ; |        ADDB                            |
        +row L4_031           ; |         AB                             |
        +row L4_031
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
; r76: rear attack trio
        +row_spawn L4_004, 3  ; |        ~                     `         |
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 86, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_032           ; |                  V  W                  |
        +row L4_032
        +row L4_033           ; |                   VW                   |
        +row L4_034           ; |                  JDDK                  |
        +row L4_035           ; |                  HTDI                  |
        +row L4_035
        +row L4_036           ; |                  HDDI                  |
        +row L4_036
        +row L4_037           ; |                  HSFI                  |
; r90: ace crossfire
        +row_spawn L4_035, 2  ; |                  HTDI                  |
        +spawn E_ACE, 0, P_CROSS_R
        +spawn E_ACE, 171, P_CROSS_L
        +row L4_035
        +row L4_038           ; |                  ADDB                  |
        +row L4_039           ; |                   AB                   |
        +row L4_039
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004

; ===== section B: destroyer lines (r95) =====
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_040           ; |      V  W                    V  W      |
        +row L4_040
        +row L4_041           ; |       VW                      VW       |
; r102: weaving gunships
        +row_spawn L4_042, 2  ; |      JDDK                    JDDK      |
        +spawn E_GUNSHIP, 40, P_WEAVE
        +spawn E_GUNSHIP, 120, P_WEAVE
        +row L4_043           ; |      HTDI                    HTDI      |
        +row L4_043
        +row L4_044           ; |      HDDI                    HDDI      |
        +row L4_044
        +row L4_045           ; |      HSFI                    HSFI      |
        +row L4_043           ; |      HTDI                    HTDI      |
        +row L4_043
        +row L4_046           ; |      ADDB                    ADDB      |
        +row L4_047           ; |       AB                      AB       |
        +row L4_001           ; |           `                ~       ~   |
        +row L4_001
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_048           ; |                          V  W          |
        +row L4_048
        +row L4_049           ; |                           VW           |
; r118: fast ace trio
        +row_spawn L4_050, 3  ; |                          JDDK          |
        +spawn E_ACE, 30, P_DIVE_FAST
        +spawn E_ACE, 86, P_DIVE_FAST
        +spawn E_ACE, 142, P_DIVE_FAST
        +row L4_051           ; |                          HDTI          |
        +row L4_051
        +row L4_052           ; |                          HDDI          |
        +row L4_052
        +row L4_053           ; |                          HFDI          |
        +row L4_054           ; |                          HSDI          |
        +row L4_054
        +row L4_052           ; |                          HDDI          |
        +row L4_055           ; |                          HTDI          |
        +row L4_055
        +row L4_055           ; |                          HTDI          |
        +row L4_056           ; |                          ADDB          |
        +row L4_057           ; |                           AB           |
        +row L4_057
; r128: divers and a hovering leader
        +row_spawn L4_002, 3  ; |                 ~               `      |
        +spawn E_DIVER, 40, P_DIVEBOMB
        +spawn E_DIVER, 132, P_DIVEBOMB
        +spawn E_LEADER, 86, P_HOVER
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_006           ; |      V  W                              |
        +row L4_006
        +row L4_007           ; |       VW                               |
        +row L4_008           ; |      JDDK                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_010           ; |      HDDI                              |
        +row L4_010
        +row L4_011           ; |      HSFI                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_012           ; |      ADDB                              |
        +row L4_013           ; |       AB                               |
        +row L4_013
        +row L4_005           ; |              `                      ~  |
; r144: raiders sweep the corners
        +row_spawn L4_000, 2  ; |     ~                `                 |
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_014           ; |                              V  W      |
        +row L4_014
        +row L4_015           ; |                               VW       |
        +row L4_016           ; |                              JDDK      |
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_018           ; |                              HDDI      |
        +row L4_018
        +row L4_019           ; |                              HSFI      |
; r156: ace zigzag squad (1/3)
        +row_spawn L4_017, 1  ; |                              HTDI      |
        +spawn E_ACE, 40, P_ZIGZAG
        +row L4_017
        +row L4_020           ; |                              ADDB      |
; r158: ace zigzag squad (2/3)
        +row_spawn L4_021, 1  ; |                               AB       |
        +spawn E_ACE, 86, P_ZIGZAG
        +row L4_021
        +row L4_003           ; |  `                      ~              |
; r160: ace zigzag squad (3/3)
        +row_spawn L4_004, 1  ; |        ~                     `         |
        +spawn E_ACE, 132, P_ZIGZAG
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_022           ; |        V  W                            |
        +row L4_022
        +row L4_023           ; |         VW                             |
        +row L4_024           ; |        JDDK                            |
        +row L4_025           ; |        HDTI                            |
        +row L4_025
        +row L4_026           ; |        HDDI                            |
        +row L4_026
        +row L4_027           ; |        HFDI                            |
        +row L4_028           ; |        HSDI                            |
        +row L4_028
        +row L4_026           ; |        HDDI                            |
        +row L4_029           ; |        HTDI                            |
        +row L4_029
        +row L4_029           ; |        HTDI                            |
        +row L4_030           ; |        ADDB                            |
        +row L4_031           ; |         AB                             |
        +row L4_031
; r176: climbers from behind
        +row_spawn L4_002, 2  ; |                 ~               `      |
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |

; ===== section C: the carrier group (r180) =====
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_006           ; |      V  W                              |
        +row L4_006
        +row L4_007           ; |       VW                               |
        +row L4_008           ; |      JDDK                              |
; r189: carrier launch: fighters loop
        +row_spawn L4_009, 2  ; |      HTDI                              |
        +spawn E_FIGHTER, 90, P_LOOP_L
        +spawn E_FIGHTER, 70, P_LOOP_R
        +row L4_009
        +row L4_058           ; |      HDDI       V    W                 |
        +row L4_058
        +row L4_059           ; |      HSFI        V  W                  |
        +row L4_060           ; |      HTDI       JPYPPK                 |
        +row L4_060
        +row L4_061           ; |      ADDB       HPYPPI                 |
        +row L4_062           ; |       AB        HPYPPI                 |
        +row L4_062
        +row L4_063           ; |                 HQYPQI                 |
        +row L4_064           ; |                 HPYPPI                 |
        +row L4_064
        +row L4_065           ; |                 HQYQPI                 |
        +row L4_064           ; |                 HPYPPI                 |
        +row L4_064
        +row L4_066           ; |                 HQYPSI                 |
        +row L4_067           ; |                 HPYQSI       V  W      |
        +row L4_067
        +row L4_068           ; |                 HQYPSI        VW       |
        +row L4_069           ; |                 HPYPPI       JDDK      |
        +row L4_069
        +row L4_070           ; |                 APYPPB       HTDI      |
        +row L4_018           ; |                              HDDI      |
        +row L4_018
        +row L4_019           ; |                              HSFI      |
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_020           ; |                              ADDB      |
        +row L4_021           ; |                               AB       |
        +row L4_021
; r209: gunship crossfire
        +row_spawn L4_005, 2  ; |              `                      ~  |
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
; r221: dive-bomb stream (1/3)
        +row_spawn L4_005, 1  ; |              `                      ~  |
        +spawn E_DIVER, 30, P_DIVEBOMB
        +row L4_048           ; |                          V  W          |
        +row L4_048
; r223: dive-bomb stream (2/3)
        +row_spawn L4_049, 1  ; |                           VW           |
        +spawn E_DIVER, 60, P_DIVEBOMB
        +row L4_050           ; |                          JDDK          |
; r225: dive-bomb stream (3/3)
        +row_spawn L4_051, 1  ; |                          HDTI          |
        +spawn E_DIVER, 90, P_DIVEBOMB
        +row L4_051
        +row L4_052           ; |                          HDDI          |
        +row L4_052
        +row L4_053           ; |                          HFDI          |
        +row L4_054           ; |                          HSDI          |
        +row L4_054
        +row L4_052           ; |                          HDDI          |
        +row L4_055           ; |                          HTDI          |
        +row L4_055
        +row L4_055           ; |                          HTDI          |
        +row L4_056           ; |                          ADDB          |
        +row L4_057           ; |                           AB           |
        +row L4_057
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
; r237: leaders loop (medals!)
        +row_spawn L4_003, 2  ; |  `                      ~              |
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_006           ; |      V  W                              |
        +row L4_006
        +row L4_007           ; |       VW                               |
        +row L4_008           ; |      JDDK                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_010           ; |      HDDI                              |
        +row L4_010
        +row L4_011           ; |      HSFI                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_012           ; |      ADDB                              |
        +row L4_013           ; |       AB                               |
        +row L4_013
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_014           ; |                              V  W      |
        +row L4_014
; r257: fast ace trio
        +row_spawn L4_015, 3  ; |                               VW       |
        +spawn E_ACE, 30, P_DIVE_FAST
        +spawn E_ACE, 86, P_DIVE_FAST
        +spawn E_ACE, 142, P_DIVE_FAST
        +row L4_016           ; |                              JDDK      |
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_018           ; |                              HDDI      |
        +row L4_018
        +row L4_019           ; |                              HSFI      |
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_020           ; |                              ADDB      |
        +row L4_021           ; |                               AB       |
        +row L4_021

; ===== section D: the last escorts (r265) =====
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
; r267: rear attack and a gunship hover
        +row_spawn L4_003, 3  ; |  `                      ~              |
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE
        +spawn E_GUNSHIP, 86, P_HOVER
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_022           ; |        V  W                            |
        +row L4_022
        +row L4_023           ; |         VW                             |
        +row L4_024           ; |        JDDK                            |
        +row L4_025           ; |        HDTI                            |
        +row L4_025
        +row L4_026           ; |        HDDI                            |
        +row L4_026
        +row L4_027           ; |        HFDI                            |
        +row L4_028           ; |        HSDI                            |
        +row L4_028
; r283: weaving aces
        +row_spawn L4_026, 3  ; |        HDDI                            |
        +spawn E_ACE, 40, P_WEAVE
        +spawn E_ACE, 86, P_WEAVE
        +spawn E_ACE, 132, P_WEAVE
        +row L4_029           ; |        HTDI                            |
        +row L4_029
        +row L4_029           ; |        HTDI                            |
        +row L4_030           ; |        ADDB                            |
        +row L4_031           ; |         AB                             |
        +row L4_031
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_032           ; |                  V  W                  |
        +row L4_032
        +row L4_033           ; |                   VW                   |
        +row L4_034           ; |                  JDDK                  |
        +row L4_035           ; |                  HTDI                  |
        +row L4_035
        +row L4_036           ; |                  HDDI                  |
        +row L4_036
        +row L4_037           ; |                  HSFI                  |
        +row L4_035           ; |                  HTDI                  |
        +row L4_035
; r303: ace crossfire
        +row_spawn L4_038, 2  ; |                  ADDB                  |
        +spawn E_ACE, 0, P_CROSS_R
        +spawn E_ACE, 171, P_CROSS_L
        +row L4_039           ; |                   AB                   |
        +row L4_039
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_014           ; |                              V  W      |
        +row L4_014
        +row L4_015           ; |                               VW       |
; r314: dive-bomber trio
        +row_spawn L4_016, 3  ; |                              JDDK      |
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 86, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB
        +row L4_017           ; |                              HTDI      |
        +row L4_017
        +row L4_018           ; |                              HDDI      |
        +row L4_018
        +row L4_019           ; |                              HSFI      |
        +row L4_071           ; |      V  W                    HTDI      |
        +row L4_071
        +row L4_072           ; |       VW                     ADDB      |
        +row L4_073           ; |      JDDK                     AB       |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_010           ; |      HDDI                              |
        +row L4_010
        +row L4_011           ; |      HSFI                              |
        +row L4_009           ; |      HTDI                              |
        +row L4_009
        +row L4_012           ; |      ADDB                              |
        +row L4_013           ; |       AB                               |
        +row L4_013
        +row L4_003           ; |  `                      ~              |
; r328: leaders swoop, a gunship dives (medals!)
        +row_spawn L4_004, 3  ; |        ~                     `         |
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
; r346: last stand: fast aces
        +row_spawn L4_004, 3  ; |        ~                     `         |
        +spawn E_ACE, 40, P_DIVE_FAST
        +spawn E_ACE, 86, P_DIVE_FAST
        +spawn E_ACE, 132, P_DIVE_FAST
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |

; --- final boss: the storm sea loops until the Kraken is sunk ---
        +boss_here
        +row L4_000           ; |     ~                `                 |
        +row L4_000
        +row L4_001           ; |           `                ~       ~   |
        +row L4_002           ; |                 ~               `      |
        +row L4_002
        +row L4_003           ; |  `                      ~              |
        +row L4_004           ; |        ~                     `         |
        +row L4_004
        +row L4_005           ; |              `                      ~  |
        +row L4_000           ; |     ~                `                 |
        +row L4_001           ; |           `                ~       ~   |
        +row L4_001

        +level_end
