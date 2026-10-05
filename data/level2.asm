; =============================================================================
; data/level2.asm - level 2 "JUNGLE COAST": row patterns and level stream
; Uses tileset tiles_jungle (data/tiles_jungle.asm). Pure data, no code.
; =============================================================================
;
; The coast comes in from the left, widens into deep jungle with a village,
; two river mouths and an enemy airstrip, then falls back to open water for
; the boss. Stream format, macros and rules: see data/level1.asm.
;
; Row patterns are numbered (L2_nnn); every stream line shows its row as a
; comment, so the stream reads as the map (upside down: time order, so the
; first line is the first row to scroll in at the top).
; Tiles: J/K jungle, e shore, n/u shore diagonals, S sand, p palm, H hut,
;        B/T river banks, W/X airstrip, D hangar, o rock, ~ ` sun glints.
; =============================================================================

level2_rowpats
L2_000  = (* - level2_rowpats) / COLS
        +rowpat "              `                ~      o "
L2_001  = (* - level2_rowpats) / COLS
        +rowpat "                    ~                   "
L2_002  = (* - level2_rowpats) / COLS
        +rowpat "     ~                `          o      "
L2_003  = (* - level2_rowpats) / COLS
        +rowpat "           `                ~           "
L2_004  = (* - level2_rowpats) / COLS
        +rowpat "  o              ~                  `   "
L2_005  = (* - level2_rowpats) / COLS
        +rowpat "        ~                o              "
L2_006  = (* - level2_rowpats) / COLS
        +rowpat "u                                       "
L2_007  = (* - level2_rowpats) / COLS
        +rowpat "Ju                                      "
L2_008  = (* - level2_rowpats) / COLS
        +rowpat "KJu                                     "
L2_009  = (* - level2_rowpats) / COLS
        +rowpat "JKJu                                    "
L2_010  = (* - level2_rowpats) / COLS
        +rowpat "KJKJu                                   "
L2_011  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJu                                  "
L2_012  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJu                                 "
L2_013  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJu                                "
L2_014  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJu                               "
L2_015  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJu                              "
L2_016  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKe                              "
L2_017  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKSe                              "
L2_018  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJSe                              "
L2_019  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKpe                              "
L2_020  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJu                             "
L2_021  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJSe                             "
L2_022  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKpe                             "
L2_023  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJu                            "
L2_024  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJSe                            "
L2_025  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKSe                            "
L2_026  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKpe                            "
L2_027  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJpe                            "
L2_028  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKn                            "
L2_029  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJpe                             "
L2_030  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKSe                             "
L2_031  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKu                            "
L2_032  = (* - level2_rowpats) / COLS
        +rowpat "BBBBBBBBBBBB                            "
L2_033  = (* - level2_rowpats) / COLS
        +rowpat "                                        "
L2_034  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJu                           "
L2_035  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKe                           "
L2_036  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJe                           "
L2_037  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJu                          "
L2_038  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKe                          "
L2_039  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJe                          "
L2_040  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJu                         "
L2_041  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKe                         "
L2_042  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJe                         "
L2_043  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJu                        "
L2_044  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKe                        "
L2_045  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJe                        "
L2_046  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJu                       "
L2_047  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKe                       "
L2_048  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJe                       "
L2_049  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJu                      "
L2_050  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKe                      "
L2_051  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJe                      "
L2_052  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKSHSSSe                      "
L2_053  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJSSSHSe                      "
L2_054  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKSSSSSe                      "
L2_055  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJSHSSSe                      "
L2_056  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKSSSHSe                      "
L2_057  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJu                     "
L2_058  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJSHSSSe                     "
L2_059  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKSSSHSe                     "
L2_060  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJu                    "
L2_061  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJSHSSSe                    "
L2_062  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKSSSHSe                    "
L2_063  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJSSSSSe                    "
L2_064  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKSHSSSe                    "
L2_065  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJSSSHSe                    "
L2_066  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKSSSSSe                    "
L2_067  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKe                    "
L2_068  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJe                    "
L2_069  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJu                   "
L2_070  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKe                   "
L2_071  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJe                   "
L2_072  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJu                  "
L2_073  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKe                  "
L2_074  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJe                  "
L2_075  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJu                 "
L2_076  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKe                 "
L2_077  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJe                 "
L2_078  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJu                "
L2_079  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKe                "
L2_080  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJe                "
L2_081  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJu               "
L2_082  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKe               "
L2_083  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJe               "
L2_084  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJu              "
L2_085  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKe              "
L2_086  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJe              "
L2_087  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJu             "
L2_088  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKe             "
L2_089  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJe             "
L2_090  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJu            "
L2_091  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKe            "
L2_092  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJe            "
L2_093  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKWXJDJKJKJKJKJKJKJKJe            "
L2_094  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJu           "
L2_095  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKWXJKJKJKJKJKJKJKJKJKe           "
L2_096  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJWXKJKJKJKJKJKJKJKJKJe           "
L2_097  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJKJu          "
L2_098  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJWXKJKJKJKJKJKJKJKJKJKe          "
L2_099  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKWXJKJKJKJKJKJKJKJKJKJe          "
L2_100  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJKJu         "
L2_101  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKe         "
L2_102  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJe         "
L2_103  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJKJKJu        "
L2_104  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        "
L2_105  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        "
L2_106  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKJe        "
L2_107  = (* - level2_rowpats) / COLS
        +rowpat "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        "
L2_108  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJKJKn        "
L2_109  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJKJKe         "
L2_110  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJKJn         "
L2_111  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJKJe          "
L2_112  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJKe          "
L2_113  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJKn          "
L2_114  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJKe           "
L2_115  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKJe           "
L2_116  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKJKn           "
L2_117  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKJKn            "
L2_118  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKJKn             "
L2_119  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKJKn              "
L2_120  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKJKn               "
L2_121  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKJKn                "
L2_122  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKJKn                 "
L2_123  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKJKn                  "
L2_124  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKJKn                   "
L2_125  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJKn                    "
L2_126  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKe                     "
L2_127  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKJe                     "
L2_128  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKJKn                     "
L2_129  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKJKn                      "
L2_130  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKJKn                       "
L2_131  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKJKn                        "
L2_132  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKJKn                         "
L2_133  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKJKn                          "
L2_134  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJKn                           "
L2_135  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJKe                            "
L2_136  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKJe                            "
L2_137  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKe                             "
L2_138  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKJe                             "
L2_139  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJKn                             "
L2_140  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKJe                              "
L2_141  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJKn                              "
L2_142  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKe                               "
L2_143  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKJe                               "
L2_144  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJKn                               "
L2_145  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKe                                "
L2_146  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKJe                                "
L2_147  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJKn                                "
L2_148  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKe                                 "
L2_149  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKJe                                 "
L2_150  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJKn                                 "
L2_151  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKe                                  "
L2_152  = (* - level2_rowpats) / COLS
        +rowpat "JKJKJe                                  "
L2_153  = (* - level2_rowpats) / COLS
        +rowpat "KJKJKn                                  "
L2_154  = (* - level2_rowpats) / COLS
        +rowpat "JKJKe                                   "
L2_155  = (* - level2_rowpats) / COLS
        +rowpat "KJKJn                                   "
L2_156  = (* - level2_rowpats) / COLS
        +rowpat "JKJe                                    "
L2_157  = (* - level2_rowpats) / COLS
        +rowpat "KJKn                                    "
L2_158  = (* - level2_rowpats) / COLS
        +rowpat "JKe                                     "
L2_159  = (* - level2_rowpats) / COLS
        +rowpat "KJn                                     "
L2_160  = (* - level2_rowpats) / COLS
        +rowpat "Je                                      "
L2_161  = (* - level2_rowpats) / COLS
        +rowpat "Kn                                      "
L2_162  = (* - level2_rowpats) / COLS
        +rowpat "e                                       "
L2_163  = (* - level2_rowpats) / COLS
        +rowpat "n                                       "
level2_rowpats_end

!set ROWPAT_COUNT = (level2_rowpats_end - level2_rowpats) / COLS
!if ROWPAT_COUNT > MAX_ROWPATS { !error "too many row patterns (max 253)" }

; =============================================================================
; LEVEL STREAM. ~360 rows of waves (~86 s), then the boss.
; Sections: A rows 0-110 shallows and beach, B 110-195 village and rivers,
;           C 195-275 the airstrip, D 275-360 the coast falls away.
; =============================================================================
level2_stream
; DX STRETCH: tools/stretch_level.py added one plain copy row per two records
; (2:3) for DX's 8-frame rows, so the "rN" comments count NOT 1942's
; records; multiply by 1.5 for DX records. See data/level1.asm.
        +level_start

; --- records 0-23: starting screen (open shallows). No spawns. ---
        +row L2_000           ; |              `                ~      o |
        +row L2_000
        +row L2_001           ; |                    ~                   |
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005

; ===== section A: shallows and beach (r0) =====
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
; r4: a lone raider dives
        +row_spawn L2_000, 1  ; |              `                ~      o |
        +spawn E_RAIDER, 86, P_DIVE
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
; r14: raiders sweep in from both corners
        +row_spawn L2_004, 2  ; |  o              ~                  `   |
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_006           ; |u                                       |
        +row L2_006
; r28: a gunship hovers and fires twice
        +row_spawn L2_007, 1  ; |Ju                                      |
        +spawn E_GUNSHIP, 86, P_HOVER
        +row L2_007
        +row L2_008           ; |KJu                                     |
        +row L2_009           ; |JKJu                                    |
        +row L2_009
        +row L2_010           ; |KJKJu                                   |
        +row L2_011           ; |JKJKJu                                  |
        +row L2_011
        +row L2_012           ; |KJKJKJu                                 |
        +row L2_013           ; |JKJKJKJu                                |
        +row L2_013
        +row L2_014           ; |KJKJKJKJu                               |
        +row L2_015           ; |JKJKJKJKJu                              |
        +row L2_016           ; |KJKJKJKJKe                              |
        +row L2_016
        +row L2_017           ; |JKJKJKJKSe                              |
        +row L2_017
        +row L2_018           ; |KJKJKJKJSe                              |
        +row L2_019           ; |JKJKJKJKpe                              |
        +row L2_018           ; |KJKJKJKJSe                              |
        +row L2_018
        +row L2_017           ; |JKJKJKJKSe                              |
        +row L2_017
        +row L2_020           ; |KJKJKJKJKJu                             |
; r44: ATTACK FROM BEHIND: a raider climbs up from the bottom
        +row_spawn L2_021, 1  ; |JKJKJKJKJSe                             |
        +spawn E_RAIDER_UP, 40, P_RISE
        +row L2_021
        +row L2_022           ; |KJKJKJKJKpe                             |
        +row L2_023           ; |JKJKJKJKJKJu                            |
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_024
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_026           ; |JKJKJKJKJKpe                            |
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_024
; r52: ...and another on the other side
        +row_spawn L2_025, 1  ; |JKJKJKJKJKSe                            |
        +spawn E_RAIDER_UP, 132, P_RISE
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_027           ; |KJKJKJKJKJpe                            |
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_028           ; |KJKJKJKJKJKn                            |
        +row L2_029           ; |JKJKJKJKJpe                             |
        +row L2_030           ; |KJKJKJKJKSe                             |
        +row L2_030
; r62: leaders swoop out both ways
        +row_spawn L2_021, 2  ; |JKJKJKJKJSe                             |
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R
        +row L2_021
        +row L2_030           ; |KJKJKJKJKSe                             |
        +row L2_021           ; |JKJKJKJKJSe                             |
        +row L2_021
        +row L2_022           ; |KJKJKJKJKpe                             |
        +row L2_021           ; |JKJKJKJKJSe                             |
        +row L2_021
        +row L2_030           ; |KJKJKJKJKSe                             |
        +row L2_021           ; |JKJKJKJKJSe                             |
        +row L2_021
        +row L2_031           ; |KJKJKJKJKJKu                            |
        +row L2_026           ; |JKJKJKJKJKpe                            |
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_024
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_027           ; |KJKJKJKJKJpe                            |
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
; r78: fast raider trio
        +row_spawn L2_025, 3  ; |JKJKJKJKJKSe                            |
        +spawn E_RAIDER, 30, P_DIVE_FAST
        +spawn E_RAIDER, 86, P_DIVE_FAST
        +spawn E_RAIDER, 142, P_DIVE_FAST
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_026           ; |JKJKJKJKJKpe                            |
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_024
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_024           ; |KJKJKJKJKJSe                            |
        +row L2_025           ; |JKJKJKJKJKSe                            |
        +row L2_025
        +row L2_027           ; |KJKJKJKJKJpe                            |
        +row L2_032           ; |BBBBBBBBBBBB                            |
        +row L2_033           ; |                                        |
        +row L2_033
        +row L2_033           ; |                                        |
        +row L2_033
        +row L2_034           ; |KJKJKJKJKJKJu                           |
; r90: a gunship crosses from the right
        +row_spawn L2_035, 1  ; |JKJKJKJKJKJKe                           |
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +row L2_035
        +row L2_036           ; |KJKJKJKJKJKJe                           |
        +row L2_037           ; |JKJKJKJKJKJKJu                          |
        +row L2_038           ; |KJKJKJKJKJKJKe                          |
        +row L2_038
        +row L2_039           ; |JKJKJKJKJKJKJe                          |
        +row L2_039
        +row L2_040           ; |KJKJKJKJKJKJKJu                         |
        +row L2_041           ; |JKJKJKJKJKJKJKe                         |
        +row L2_041
        +row L2_042           ; |KJKJKJKJKJKJKJe                         |
        +row L2_043           ; |JKJKJKJKJKJKJKJu                        |
        +row L2_044           ; |KJKJKJKJKJKJKJKe                        |
        +row L2_044
; r100: raider loop
        +row_spawn L2_045, 1  ; |JKJKJKJKJKJKJKJe                        |
        +spawn E_RAIDER, 100, P_LOOP_L
        +row L2_045
        +row L2_046           ; |KJKJKJKJKJKJKJKJu                       |
        +row L2_047           ; |JKJKJKJKJKJKJKJKe                       |
        +row L2_047
        +row L2_048           ; |KJKJKJKJKJKJKJKJe                       |
        +row L2_049           ; |JKJKJKJKJKJKJKJKJu                      |
        +row L2_050           ; |KJKJKJKJKJKJKJKJKe                      |
        +row L2_050
        +row L2_051           ; |JKJKJKJKJKJKJKJKJe                      |
        +row L2_051
        +row L2_050           ; |KJKJKJKJKJKJKJKJKe                      |
        +row L2_051           ; |JKJKJKJKJKJKJKJKJe                      |
        +row L2_051
        +row L2_050           ; |KJKJKJKJKJKJKJKJKe                      |

; ===== section B: village and rivers (r110) =====
        +row L2_051           ; |JKJKJKJKJKJKJKJKJe                      |
        +row L2_051
        +row L2_050           ; |KJKJKJKJKJKJKJKJKe                      |
; r112: climbers drift across from behind
        +row_spawn L2_051, 2  ; |JKJKJKJKJKJKJKJKJe                      |
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +row L2_051
        +row L2_050           ; |KJKJKJKJKJKJKJKJKe                      |
        +row L2_052           ; |JKJKJKJKJKJKSHSSSe                      |
        +row L2_053           ; |KJKJKJKJKJKJSSSHSe                      |
        +row L2_053
        +row L2_054           ; |JKJKJKJKJKJKSSSSSe                      |
        +row L2_054
        +row L2_055           ; |KJKJKJKJKJKJSHSSSe                      |
        +row L2_056           ; |JKJKJKJKJKJKSSSHSe                      |
        +row L2_056
        +row L2_057           ; |KJKJKJKJKJKJKJKJKJu                     |
        +row L2_058           ; |JKJKJKJKJKJKJSHSSSe                     |
        +row L2_058
        +row L2_059           ; |KJKJKJKJKJKJKSSSHSe                     |
        +row L2_060           ; |JKJKJKJKJKJKJKJKJKJu                    |
        +row L2_061           ; |KJKJKJKJKJKJKJSHSSSe                    |
        +row L2_061
        +row L2_062           ; |JKJKJKJKJKJKJKSSSHSe                    |
        +row L2_063           ; |KJKJKJKJKJKJKJSSSSSe                    |
        +row L2_063
; r126: gunship zigzag with a raider escort
        +row_spawn L2_064, 2  ; |JKJKJKJKJKJKJKSHSSSe                    |
        +spawn E_GUNSHIP, 86, P_ZIGZAG
        +spawn E_RAIDER, 30, P_DIVE
        +row L2_064
        +row L2_065           ; |KJKJKJKJKJKJKJSSSHSe                    |
        +row L2_066           ; |JKJKJKJKJKJKJKSSSSSe                    |
        +row L2_066
        +row L2_061           ; |KJKJKJKJKJKJKJSHSSSe                    |
        +row L2_062           ; |JKJKJKJKJKJKJKSSSHSe                    |
        +row L2_063           ; |KJKJKJKJKJKJKJSSSSSe                    |
        +row L2_063
        +row L2_064           ; |JKJKJKJKJKJKJKSHSSSe                    |
        +row L2_064
        +row L2_065           ; |KJKJKJKJKJKJKJSSSHSe                    |
        +row L2_066           ; |JKJKJKJKJKJKJKSSSSSe                    |
        +row L2_066
        +row L2_061           ; |KJKJKJKJKJKJKJSHSSSe                    |
        +row L2_062           ; |JKJKJKJKJKJKJKSSSHSe                    |
        +row L2_063           ; |KJKJKJKJKJKJKJSSSSSe                    |
        +row L2_063
        +row L2_064           ; |JKJKJKJKJKJKJKSHSSSe                    |
        +row L2_064
        +row L2_065           ; |KJKJKJKJKJKJKJSSSHSe                    |
        +row L2_066           ; |JKJKJKJKJKJKJKSSSSSe                    |
        +row L2_066
        +row L2_067           ; |KJKJKJKJKJKJKJKJKJKe                    |
        +row L2_068           ; |JKJKJKJKJKJKJKJKJKJe                    |
        +row L2_068
        +row L2_069           ; |KJKJKJKJKJKJKJKJKJKJu                   |
; r144: raider sweep stream (1/3)
        +row_spawn L2_070, 1  ; |JKJKJKJKJKJKJKJKJKJKe                   |
        +spawn E_RAIDER, 20, P_DIAG_R
        +row L2_070
        +row L2_071           ; |KJKJKJKJKJKJKJKJKJKJe                   |
; r146: raider sweep stream (2/3)
        +row_spawn L2_072, 1  ; |JKJKJKJKJKJKJKJKJKJKJu                  |
        +spawn E_RAIDER, 50, P_DIAG_R
        +row L2_073           ; |KJKJKJKJKJKJKJKJKJKJKe                  |
        +row L2_073
; r148: raider sweep stream (3/3)
        +row_spawn L2_074, 1  ; |JKJKJKJKJKJKJKJKJKJKJe                  |
        +spawn E_RAIDER, 80, P_DIAG_R
        +row L2_074
        +row L2_075           ; |KJKJKJKJKJKJKJKJKJKJKJu                 |
        +row L2_076           ; |JKJKJKJKJKJKJKJKJKJKJKe                 |
        +row L2_076
        +row L2_077           ; |KJKJKJKJKJKJKJKJKJKJKJe                 |
        +row L2_078           ; |JKJKJKJKJKJKJKJKJKJKJKJu                |
        +row L2_079           ; |KJKJKJKJKJKJKJKJKJKJKJKe                |
        +row L2_079
        +row L2_080           ; |JKJKJKJKJKJKJKJKJKJKJKJe                |
        +row L2_080
        +row L2_081           ; |KJKJKJKJKJKJKJKJKJKJKJKJu               |
        +row L2_082           ; |JKJKJKJKJKJKJKJKJKJKJKJKe               |
        +row L2_082
        +row L2_083           ; |KJKJKJKJKJKJKJKJKJKJKJKJe               |
        +row L2_084           ; |JKJKJKJKJKJKJKJKJKJKJKJKJu              |
        +row L2_085           ; |KJKJKJKJKJKJKJKJKJKJKJKJKe              |
        +row L2_085
        +row L2_086           ; |JKJKJKJKJKJKJKJKJKJKJKJKJe              |
        +row L2_086
        +row L2_087           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJu             |
; r162: rear attack trio (1/3)
        +row_spawn L2_088, 1  ; |JKJKJKJKJKJKJKJKJKJKJKJKJKe             |
        +spawn E_RAIDER_UP, 30, P_RISE
        +row L2_088
        +row L2_089           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJe             |
; r164: rear attack trio (2/3)
        +row_spawn L2_090, 1  ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJu            |
        +spawn E_RAIDER_UP, 86, P_RISE
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_091
; r166: rear attack trio (3/3)
        +row_spawn L2_092, 1  ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJe            |
        +spawn E_RAIDER_UP, 142, P_RISE
        +row L2_092
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_092           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJe            |
        +row L2_092
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_092           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJe            |
        +row L2_092
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_092           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJe            |
        +row L2_092
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_092           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJe            |
        +row L2_092
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_093           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJe            |
        +row L2_093
        +row L2_094           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJu           |
        +row L2_095           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKe           |
        +row L2_095
        +row L2_096           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJe           |
; r180: twin hover gunships
        +row_spawn L2_097, 2  ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJu          |
        +spawn E_GUNSHIP, 50, P_HOVER
        +spawn E_GUNSHIP, 120, P_HOVER
        +row L2_098           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKe          |
        +row L2_098
        +row L2_099           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJe          |
        +row L2_099
        +row L2_100           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKJu         |
        +row L2_101           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKe         |
        +row L2_101
        +row L2_102           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJe         |
        +row L2_103           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJKJu        |
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_104
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_106           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKJe        |
        +row L2_106
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105

; ===== section C: the airstrip (r195) =====
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
; r198: leaders loop both ways
        +row_spawn L2_105, 2  ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_106           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKJe        |
        +row L2_106
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_106           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKJe        |
        +row L2_106
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_106           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKJe        |
        +row L2_106
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
; r218: raider crossfire
        +row_spawn L2_105, 2  ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +spawn E_RAIDER, 0, P_CROSS_R
        +spawn E_RAIDER, 171, P_CROSS_L
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_106           ; |JKJKJKJKWXJDJKJKJKJKJKJKJKJKJKJe        |
        +row L2_106
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_105           ; |JKJKJKJKWXJKJKJKJKJKJKJKJKJKJKJe        |
        +row L2_105
        +row L2_104           ; |KJKJKJKJWXKJKJKJKJKJKJKJKJKJKJKe        |
        +row L2_107           ; |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        |
        +row L2_033           ; |                                        |
        +row L2_033
; r230: gunship trio, fast
        +row_spawn L2_033, 3  ; |                                        |
        +spawn E_GUNSHIP, 30, P_DIVE_FAST
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +spawn E_GUNSHIP, 142, P_DIVE_FAST
        +row L2_033
        +row L2_108           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKJKn        |
        +row L2_109           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJKe         |
        +row L2_109
        +row L2_110           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKJn         |
        +row L2_111           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJe          |
        +row L2_111
        +row L2_112           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKe          |
        +row L2_111           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJe          |
        +row L2_111
        +row L2_112           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKe          |
        +row L2_111           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJe          |
        +row L2_111
        +row L2_112           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKe          |
        +row L2_111           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJe          |
        +row L2_111
        +row L2_112           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKe          |
; r242: climbers both ways and a gunship hover
        +row_spawn L2_111, 3  ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKJe          |
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +spawn E_GUNSHIP, 86, P_HOVER
        +row L2_111
        +row L2_113           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJKn          |
        +row L2_114           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKe           |
        +row L2_114
        +row L2_115           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKJe           |
        +row L2_116           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJKn           |
        +row L2_091           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKe            |
        +row L2_091
        +row L2_092           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKJe            |
        +row L2_092
        +row L2_117           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJKn            |
        +row L2_088           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKe             |
        +row L2_088
        +row L2_089           ; |KJKJKJKJKJKJKJKJKJKJKJKJKJe             |
        +row L2_118           ; |JKJKJKJKJKJKJKJKJKJKJKJKJKn             |
        +row L2_085           ; |KJKJKJKJKJKJKJKJKJKJKJKJKe              |
        +row L2_085
        +row L2_086           ; |JKJKJKJKJKJKJKJKJKJKJKJKJe              |
        +row L2_086
        +row L2_119           ; |KJKJKJKJKJKJKJKJKJKJKJKJKn              |
        +row L2_082           ; |JKJKJKJKJKJKJKJKJKJKJKJKe               |
        +row L2_082
        +row L2_083           ; |KJKJKJKJKJKJKJKJKJKJKJKJe               |
        +row L2_120           ; |JKJKJKJKJKJKJKJKJKJKJKJKn               |
        +row L2_079           ; |KJKJKJKJKJKJKJKJKJKJKJKe                |
        +row L2_079
; r260: raider zigzag squad (1/3)
        +row_spawn L2_080, 1  ; |JKJKJKJKJKJKJKJKJKJKJKJe                |
        +spawn E_RAIDER, 40, P_ZIGZAG
        +row L2_080
        +row L2_121           ; |KJKJKJKJKJKJKJKJKJKJKJKn                |
; r262: raider zigzag squad (2/3)
        +row_spawn L2_076, 1  ; |JKJKJKJKJKJKJKJKJKJKJKe                 |
        +spawn E_RAIDER, 86, P_ZIGZAG
        +row L2_076
        +row L2_077           ; |KJKJKJKJKJKJKJKJKJKJKJe                 |
; r264: raider zigzag squad (3/3)
        +row_spawn L2_122, 1  ; |JKJKJKJKJKJKJKJKJKJKJKn                 |
        +spawn E_RAIDER, 132, P_ZIGZAG
        +row L2_073           ; |KJKJKJKJKJKJKJKJKJKJKe                  |
        +row L2_073
        +row L2_074           ; |JKJKJKJKJKJKJKJKJKJKJe                  |
        +row L2_074
        +row L2_123           ; |KJKJKJKJKJKJKJKJKJKJKn                  |
        +row L2_070           ; |JKJKJKJKJKJKJKJKJKJKe                   |
        +row L2_070
        +row L2_071           ; |KJKJKJKJKJKJKJKJKJKJe                   |
        +row L2_124           ; |JKJKJKJKJKJKJKJKJKJKn                   |
        +row L2_067           ; |KJKJKJKJKJKJKJKJKJKe                    |
        +row L2_067
        +row L2_068           ; |JKJKJKJKJKJKJKJKJKJe                    |
        +row L2_068
        +row L2_125           ; |KJKJKJKJKJKJKJKJKJKn                    |
        +row L2_126           ; |JKJKJKJKJKJKJKJKJKe                     |
        +row L2_126

; ===== section D: the coast falls away (r275) =====
        +row L2_127           ; |KJKJKJKJKJKJKJKJKJe                     |
        +row L2_128           ; |JKJKJKJKJKJKJKJKJKn                     |
        +row L2_050           ; |KJKJKJKJKJKJKJKJKe                      |
        +row L2_050
        +row L2_051           ; |JKJKJKJKJKJKJKJKJe                      |
        +row L2_051
        +row L2_129           ; |KJKJKJKJKJKJKJKJKn                      |
        +row L2_047           ; |JKJKJKJKJKJKJKJKe                       |
        +row L2_047
        +row L2_048           ; |KJKJKJKJKJKJKJKJe                       |
; r282: gunship crossfire
        +row_spawn L2_130, 2  ; |JKJKJKJKJKJKJKJKn                       |
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +row L2_044           ; |KJKJKJKJKJKJKJKe                        |
        +row L2_044
        +row L2_045           ; |JKJKJKJKJKJKJKJe                        |
        +row L2_045
        +row L2_131           ; |KJKJKJKJKJKJKJKn                        |
        +row L2_041           ; |JKJKJKJKJKJKJKe                         |
        +row L2_041
        +row L2_042           ; |KJKJKJKJKJKJKJe                         |
        +row L2_132           ; |JKJKJKJKJKJKJKn                         |
        +row L2_038           ; |KJKJKJKJKJKJKe                          |
        +row L2_038
        +row L2_039           ; |JKJKJKJKJKJKJe                          |
        +row L2_039
        +row L2_133           ; |KJKJKJKJKJKJKn                          |
        +row L2_035           ; |JKJKJKJKJKJKe                           |
        +row L2_035
        +row L2_036           ; |KJKJKJKJKJKJe                           |
; r294: interlocking raider loops
        +row_spawn L2_134, 2  ; |JKJKJKJKJKJKn                           |
        +spawn E_RAIDER, 90, P_LOOP_L
        +spawn E_RAIDER, 70, P_LOOP_R
        +row L2_135           ; |KJKJKJKJKJKe                            |
        +row L2_135
        +row L2_136           ; |JKJKJKJKJKJe                            |
        +row L2_136
        +row L2_028           ; |KJKJKJKJKJKn                            |
        +row L2_137           ; |JKJKJKJKJKe                             |
        +row L2_137
        +row L2_138           ; |KJKJKJKJKJe                             |
        +row L2_139           ; |JKJKJKJKJKn                             |
        +row L2_016           ; |KJKJKJKJKe                              |
        +row L2_016
        +row L2_140           ; |JKJKJKJKJe                              |
        +row L2_140
        +row L2_141           ; |KJKJKJKJKn                              |
        +row L2_142           ; |JKJKJKJKe                               |
        +row L2_142
        +row L2_143           ; |KJKJKJKJe                               |
        +row L2_144           ; |JKJKJKJKn                               |
        +row L2_145           ; |KJKJKJKe                                |
        +row L2_145
        +row L2_146           ; |JKJKJKJe                                |
        +row L2_146
        +row L2_147           ; |KJKJKJKn                                |
        +row L2_148           ; |JKJKJKe                                 |
        +row L2_148
        +row L2_149           ; |KJKJKJe                                 |
        +row L2_150           ; |JKJKJKn                                 |
        +row L2_151           ; |KJKJKe                                  |
        +row L2_151
; r314: rear attack, three abreast
        +row_spawn L2_152, 3  ; |JKJKJe                                  |
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 86, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE
        +row L2_152
        +row L2_151           ; |KJKJKe                                  |
        +row L2_152           ; |JKJKJe                                  |
        +row L2_152
        +row L2_151           ; |KJKJKe                                  |
        +row L2_152           ; |JKJKJe                                  |
        +row L2_152
        +row L2_151           ; |KJKJKe                                  |
        +row L2_152           ; |JKJKJe                                  |
        +row L2_152
        +row L2_153           ; |KJKJKn                                  |
        +row L2_154           ; |JKJKe                                   |
        +row L2_154
        +row L2_155           ; |KJKJn                                   |
        +row L2_156           ; |JKJe                                    |
        +row L2_156
        +row L2_157           ; |KJKn                                    |
        +row L2_158           ; |JKe                                     |
        +row L2_158
        +row L2_159           ; |KJn                                     |
; r328: last stand: leaders swoop, gunship dives
        +row_spawn L2_160, 3  ; |Je                                      |
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +row L2_160
        +row L2_161           ; |Kn                                      |
        +row L2_162           ; |e                                       |
        +row L2_162
        +row L2_163           ; |n                                       |
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001

; --- boss fight: open water loops until the boss is destroyed ---
        +boss_here
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005
        +row L2_000           ; |              `                ~      o |
        +row L2_001           ; |                    ~                   |
        +row L2_001
        +row L2_002           ; |     ~                `          o      |
        +row L2_003           ; |           `                ~           |
        +row L2_003
        +row L2_004           ; |  o              ~                  `   |
        +row L2_005           ; |        ~                o              |
        +row L2_005

        +level_end
