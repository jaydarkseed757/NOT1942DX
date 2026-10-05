; =============================================================================
; data/level3.asm - level 3 "SUNSET STRAIT": row patterns and level stream
; Uses tileset tiles_strait (data/tiles_strait.asm). Pure data, no code.
; =============================================================================
;
; Open sunset water, then cliffs close in from both sides into a narrow,
; winding strait (never narrower than 12 columns) with a lighthouse, wrecks,
; buoys and sea stacks, before it opens out again for the boss.
; Stream format, macros and rules: see data/level1.asm.
;
; Row patterns are numbered (L3_nnn); every stream line shows its row as a
; comment, so the stream reads as the map (upside down: time order).
; Tiles: R/Q rock, e/n/u left cliff edge and diagonals, E/N/U right cliff,
;        L lighthouse, W/X wreck, i buoy, o sea stack, ~ ` sun glints.
; =============================================================================

level3_rowpats
L3_000  = (* - level3_rowpats) / COLS
        +rowpat "              `                ~      o "
L3_001  = (* - level3_rowpats) / COLS
        +rowpat "                    ~                   "
L3_002  = (* - level3_rowpats) / COLS
        +rowpat "     ~                `          o      "
L3_003  = (* - level3_rowpats) / COLS
        +rowpat "           `                ~           "
L3_004  = (* - level3_rowpats) / COLS
        +rowpat "  o              ~                  `   "
L3_005  = (* - level3_rowpats) / COLS
        +rowpat "        ~                o              "
L3_006  = (* - level3_rowpats) / COLS
        +rowpat "u                                       "
L3_007  = (* - level3_rowpats) / COLS
        +rowpat "e                                       "
L3_008  = (* - level3_rowpats) / COLS
        +rowpat "Qu                                      "
L3_009  = (* - level3_rowpats) / COLS
        +rowpat "Re                                      "
L3_010  = (* - level3_rowpats) / COLS
        +rowpat "QRu                                     "
L3_011  = (* - level3_rowpats) / COLS
        +rowpat "RQe                                     "
L3_012  = (* - level3_rowpats) / COLS
        +rowpat "QRQu                                    "
L3_013  = (* - level3_rowpats) / COLS
        +rowpat "RQRe                                    "
L3_014  = (* - level3_rowpats) / COLS
        +rowpat "QRQRu                                  U"
L3_015  = (* - level3_rowpats) / COLS
        +rowpat "RQRQe                                  E"
L3_016  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQu                                UR"
L3_017  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                                EQ"
L3_018  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                               UQR"
L3_019  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                               ERQ"
L3_020  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                              URQR"
L3_021  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                              EQRQ"
L3_022  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                             UQRQR"
L3_023  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                             ERQRQ"
L3_024  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                             EQRQR"
L3_025  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQn                             EQRQR"
L3_026  = (* - level3_rowpats) / COLS
        +rowpat "RQRQe                              ERQRQ"
L3_027  = (* - level3_rowpats) / COLS
        +rowpat "QRQRe                              EQRQR"
L3_028  = (* - level3_rowpats) / COLS
        +rowpat "RQLQe                              ERQRQ"
L3_029  = (* - level3_rowpats) / COLS
        +rowpat "QRLRe                              EQRQR"
L3_030  = (* - level3_rowpats) / COLS
        +rowpat "QRQRe                             URQRQR"
L3_031  = (* - level3_rowpats) / COLS
        +rowpat "RQRQe                             EQRQRQ"
L3_032  = (* - level3_rowpats) / COLS
        +rowpat "QRQRe                             ERQRQR"
L3_033  = (* - level3_rowpats) / COLS
        +rowpat "RQRQe                            URQRQRQ"
L3_034  = (* - level3_rowpats) / COLS
        +rowpat "QRQRe                            EQRQRQR"
L3_035  = (* - level3_rowpats) / COLS
        +rowpat "RQRQe                            ERQRQRQ"
L3_036  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRu                           ERQRQRQ"
L3_037  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                           EQRQRQR"
L3_038  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                           ERQRQRQ"
L3_039  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRu                          EQRQRQR"
L3_040  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQe                          ERQRQRQ"
L3_041  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRe                          EQRQRQR"
L3_042  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRu                         ERQRQRQ"
L3_043  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQe                         EQRQRQR"
L3_044  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRe                         ERQRQRQ"
L3_045  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQe                        URQRQRQR"
L3_046  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRe                        EQRQRQRQ"
L3_047  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRu                       ERQRQRQR"
L3_048  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQe                      URQRQRQRQ"
L3_049  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRe                      EQRQRQRQR"
L3_050  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRu                     ERQRQRQRQ"
L3_051  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                    URQRQRQRQR"
L3_052  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                    EQRQRQRQRQ"
L3_053  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRu                   ERQRQRQRQR"
L3_054  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQe                   EQRQRQRQRQ"
L3_055  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRe                   ERQRQRQRQR"
L3_056  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRu                  EQRQRQRQRQ"
L3_057  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQe                  ERQRQRQRQR"
L3_058  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRe        WX        EQRQRQRQRQ"
L3_059  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRe                  EQRQRQRQRQ"
L3_060  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRe  i            i  EQRQRQRQRQ"
L3_061  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRu                 ERQRQRQRQR"
L3_062  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQe                 EQRQRQRQRQ"
L3_063  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRe                 ERQRQRQRQR"
L3_064  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRu                NQRQRQRQRQ"
L3_065  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQe                 EQRQRQRQR"
L3_066  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRe           o     ERQRQRQRQ"
L3_067  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRu                NQRQRQRQR"
L3_068  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQe                 EQRQRQRQ"
L3_069  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRe                 ERQRQRQR"
L3_070  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQRu                NQRQRQRQ"
L3_071  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRQe                 EQRQRQR"
L3_072  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQRe                 ERQRQRQ"
L3_073  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRQe                 NQRQRQR"
L3_074  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQRe                  EQRQRQ"
L3_075  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRQe                  ERQRQR"
L3_076  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQRe        WX        EQRQRQ"
L3_077  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRQn                  ERQRQR"
L3_078  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQe                   EQRQRQ"
L3_079  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQRe                   ERQRQR"
L3_080  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRQn                  URQRQRQ"
L3_081  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQe                   EQRQRQR"
L3_082  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQRe                   ERQRQRQ"
L3_083  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRQn                  URQRQRQR"
L3_084  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQe                   EQRQRQRQ"
L3_085  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQRe                   ERQRQRQR"
L3_086  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRQn                  URQRQRQRQ"
L3_087  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQe                   EQRQRQRQR"
L3_088  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQRe                   ERQRQRQRQ"
L3_089  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQRQn                  URQRQRQRQR"
L3_090  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRQn                  URQRQRQRQRQ"
L3_091  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                   EQRQRQRQRQR"
L3_092  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                   ERQRQRQRQRQ"
L3_093  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQn                  URQRQRQRQRQR"
L3_094  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQe                   EQRQRQRQRQRQ"
L3_095  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRe                   ERQRQRQRQRQR"
L3_096  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQn                  URQRQRQRQRQRQ"
L3_097  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQe                   EQRQRQRQRQRQR"
L3_098  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRe  i             i  ERQRQRQRQRQRQ"
L3_099  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQn                  URQRQRQRQRQRQR"
L3_100  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQe                   EQRQRQRQRQRQRQ"
L3_101  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRe                   ERQRQRQRQRQRQR"
L3_102  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQn  i             i URQRQRQRQRQRQRQ"
L3_103  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                   EQRQRQRQRQRQRQR"
L3_104  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                   ERQRQRQRQRQRQRQ"
L3_105  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                  URQRQRQRQRQRQRQR"
L3_106  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                  EQRQRQRQRQRQRQRQ"
L3_107  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                  ERQRQRQRQRQRQRQR"
L3_108  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe            o     EQRQRQRQRQRQRQRQ"
L3_109  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRu                 ERQRQRQRQRQRQRQR"
L3_110  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQe                 EQRQRQRQRQRQRQRQ"
L3_111  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRe                 ERQRQRQRQRQRQRQR"
L3_112  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRu                EQRQRQRQRQRQRQRQ"
L3_113  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQe                ERQRQRQRQRQRQRQR"
L3_114  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRe                NQRQRQRQRQRQRQRQ"
L3_115  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRu                EQRQRQRQRQRQRQR"
L3_116  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQe                ERQRQRQRQRQRQRQ"
L3_117  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRe                NQRQRQRQRQRQRQR"
L3_118  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRu                EQRQRQRQRQRQRQ"
L3_119  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQLQe                ERQRQRQRQRQRQR"
L3_120  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                NQRQRQRQRQRQRQ"
L3_121  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                 EQRQRQRQRQRQR"
L3_122  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                 ERQRQRQRQRQRQ"
L3_123  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                 NQRQRQRQRQRQR"
L3_124  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                  EQRQRQRQRQRQ"
L3_125  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                  ERQRQRQRQRQR"
L3_126  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                  NQRQRQRQRQRQ"
L3_127  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                   NQRQRQRQRQR"
L3_128  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                    ERQRQRQRQR"
L3_129  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe         WX         NQRQRQRQRQ"
L3_130  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                     EQRQRQRQR"
L3_131  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                     ERQRQRQRQ"
L3_132  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                     NQRQRQRQR"
L3_133  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQRe                      EQRQRQRQ"
L3_134  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQe                      ERQRQRQR"
L3_135  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRQn                      ERQRQRQR"
L3_136  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQe                       EQRQRQRQ"
L3_137  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQRe                       ERQRQRQR"
L3_138  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQRQn                       EQRQRQRQ"
L3_139  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQe                        ERQRQRQR"
L3_140  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRQn                        ERQRQRQR"
L3_141  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQe               o         EQRQRQRQ"
L3_142  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQRe                         ERQRQRQR"
L3_143  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRQn                         EQRQRQRQ"
L3_144  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQe                          ERQRQRQR"
L3_145  = (* - level3_rowpats) / COLS
        +rowpat "RQRQRe                          EQRQRQRQ"
L3_146  = (* - level3_rowpats) / COLS
        +rowpat "QRQRQn                          ERQRQRQR"
L3_147  = (* - level3_rowpats) / COLS
        +rowpat "RQRQe                           EQRQRQRQ"
L3_148  = (* - level3_rowpats) / COLS
        +rowpat "QRQRe                           ERQRQRQR"
L3_149  = (* - level3_rowpats) / COLS
        +rowpat "RQRQn                           EQRQRQRQ"
L3_150  = (* - level3_rowpats) / COLS
        +rowpat "QRQe                            ERQRQRQR"
L3_151  = (* - level3_rowpats) / COLS
        +rowpat "RQRe                            EQRQRQRQ"
L3_152  = (* - level3_rowpats) / COLS
        +rowpat "QRQn                            ERQRQRQR"
L3_153  = (* - level3_rowpats) / COLS
        +rowpat "RQe                             EQRQRQRQ"
L3_154  = (* - level3_rowpats) / COLS
        +rowpat "QRe                             ERQRQRQR"
L3_155  = (* - level3_rowpats) / COLS
        +rowpat "RQn                             NQRQRQRQ"
L3_156  = (* - level3_rowpats) / COLS
        +rowpat "Qe                               EQRQRQR"
L3_157  = (* - level3_rowpats) / COLS
        +rowpat "Re                               ERQRQRQ"
L3_158  = (* - level3_rowpats) / COLS
        +rowpat "Qn                               NQRQRQR"
L3_159  = (* - level3_rowpats) / COLS
        +rowpat "e                                 EQRQRQ"
L3_160  = (* - level3_rowpats) / COLS
        +rowpat "e                                 ERQRQR"
L3_161  = (* - level3_rowpats) / COLS
        +rowpat "n                                 NQRQRQ"
L3_162  = (* - level3_rowpats) / COLS
        +rowpat "                                   EQRQR"
L3_163  = (* - level3_rowpats) / COLS
        +rowpat "                                   ERQRQ"
L3_164  = (* - level3_rowpats) / COLS
        +rowpat "                                   NQRQR"
L3_165  = (* - level3_rowpats) / COLS
        +rowpat "                                    EQRQ"
L3_166  = (* - level3_rowpats) / COLS
        +rowpat "                                    ERQR"
L3_167  = (* - level3_rowpats) / COLS
        +rowpat "                                    NQRQ"
L3_168  = (* - level3_rowpats) / COLS
        +rowpat "                                     EQR"
L3_169  = (* - level3_rowpats) / COLS
        +rowpat "                                     ERQ"
L3_170  = (* - level3_rowpats) / COLS
        +rowpat "                                     NQR"
L3_171  = (* - level3_rowpats) / COLS
        +rowpat "                                      EQ"
L3_172  = (* - level3_rowpats) / COLS
        +rowpat "                                      ER"
L3_173  = (* - level3_rowpats) / COLS
        +rowpat "                                      NQ"
L3_174  = (* - level3_rowpats) / COLS
        +rowpat "                                       E"
L3_175  = (* - level3_rowpats) / COLS
        +rowpat "                                       N"
level3_rowpats_end

!set ROWPAT_COUNT = (level3_rowpats_end - level3_rowpats) / COLS
!if ROWPAT_COUNT > MAX_ROWPATS { !error "too many row patterns (max 253)" }

; =============================================================================
; LEVEL STREAM. 360 rows of waves (~86 s), then the boss.
; Sections: A rows 0-110 the cliffs close in, B 110-200 the narrows,
;           C 200-280 the winding strait, D 280-360 out into open water.
; =============================================================================
level3_stream
; DX STRETCH: tools/stretch_level.py added one plain copy row per two records
; (2:3) for DX's 8-frame rows, so the "rN" comments count NOT 1942's
; records; multiply by 1.5 for DX records. See data/level1.asm.
        +level_start

; --- records 0-23: starting screen (open water). No spawns. ---
        +row L3_000           ; |              `                ~      o |
        +row L3_000
        +row L3_001           ; |                    ~                   |
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005

; ===== section A: the cliffs close in (r0) =====
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
; r4: a diver dive-bombs
        +row_spawn L3_000, 1  ; |              `                ~      o |
        +spawn E_DIVER, 86, P_DIVEBOMB
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
; r14: fighters weave in
        +row_spawn L3_004, 2  ; |  o              ~                  `   |
        +spawn E_FIGHTER, 40, P_WEAVE
        +spawn E_FIGHTER, 120, P_WEAVE
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_006           ; |u                                       |
        +row L3_006
        +row L3_007           ; |e                                       |
        +row L3_007
        +row L3_008           ; |Qu                                      |
        +row L3_009           ; |Re                                      |
        +row L3_009
        +row L3_010           ; |QRu                                     |
        +row L3_011           ; |RQe                                     |
        +row L3_011
        +row L3_012           ; |QRQu                                    |
        +row L3_013           ; |RQRe                                    |
        +row L3_013
        +row L3_014           ; |QRQRu                                  U|
; r30: divers, one each side
        +row_spawn L3_015, 1  ; |RQRQe                                  E|
        +spawn E_DIVER, 50, P_DIVEBOMB
        +row L3_015
        +row L3_016           ; |QRQRQu                                UR|
; r32: divers, one each side
        +row_spawn L3_017, 1  ; |RQRQRe                                EQ|
        +spawn E_DIVER, 120, P_DIVEBOMB
        +row L3_017
        +row L3_018           ; |QRQRQe                               UQR|
        +row L3_019           ; |RQRQRe                               ERQ|
        +row L3_019
        +row L3_020           ; |QRQRQe                              URQR|
        +row L3_021           ; |RQRQRe                              EQRQ|
        +row L3_021
        +row L3_022           ; |QRQRQe                             UQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
; r44: raiders sweep from the corners
        +row_spawn L3_023, 2  ; |RQRQRe                             ERQRQ|
        +spawn E_RAIDER, 20, P_DIAG_R
        +spawn E_RAIDER, 150, P_DIAG_L
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_024           ; |QRQRQe                             EQRQR|
        +row L3_023           ; |RQRQRe                             ERQRQ|
        +row L3_023
        +row L3_025           ; |QRQRQn                             EQRQR|
        +row L3_026           ; |RQRQe                              ERQRQ|
        +row L3_026
        +row L3_027           ; |QRQRe                              EQRQR|
        +row L3_026           ; |RQRQe                              ERQRQ|
        +row L3_026
        +row L3_027           ; |QRQRe                              EQRQR|
; r58: leaders swoop out (medals!)
        +row_spawn L3_028, 2  ; |RQLQe                              ERQRQ|
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +row L3_028
        +row L3_029           ; |QRLRe                              EQRQR|
        +row L3_028           ; |RQLQe                              ERQRQ|
        +row L3_028
        +row L3_027           ; |QRQRe                              EQRQR|
        +row L3_026           ; |RQRQe                              ERQRQ|
        +row L3_026
        +row L3_030           ; |QRQRe                             URQRQR|
        +row L3_031           ; |RQRQe                             EQRQRQ|
        +row L3_031
        +row L3_032           ; |QRQRe                             ERQRQR|
        +row L3_033           ; |RQRQe                            URQRQRQ|
        +row L3_034           ; |QRQRe                            EQRQRQR|
        +row L3_034
        +row L3_035           ; |RQRQe                            ERQRQRQ|
        +row L3_035
        +row L3_034           ; |QRQRe                            EQRQRQR|
        +row L3_036           ; |RQRQRu                           ERQRQRQ|
        +row L3_037           ; |QRQRQe                           EQRQRQR|
        +row L3_037
        +row L3_038           ; |RQRQRe                           ERQRQRQ|
        +row L3_038
        +row L3_039           ; |QRQRQRu                          EQRQRQR|
; r74: dive-bomber trio
        +row_spawn L3_040, 3  ; |RQRQRQe                          ERQRQRQ|
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 86, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB
        +row L3_040
        +row L3_041           ; |QRQRQRe                          EQRQRQR|
        +row L3_042           ; |RQRQRQRu                         ERQRQRQ|
        +row L3_043           ; |QRQRQRQe                         EQRQRQR|
        +row L3_043
        +row L3_044           ; |RQRQRQRe                         ERQRQRQ|
        +row L3_044
        +row L3_043           ; |QRQRQRQe                         EQRQRQR|
        +row L3_044           ; |RQRQRQRe                         ERQRQRQ|
        +row L3_044
        +row L3_043           ; |QRQRQRQe                         EQRQRQR|
        +row L3_044           ; |RQRQRQRe                         ERQRQRQ|
        +row L3_044
        +row L3_043           ; |QRQRQRQe                         EQRQRQR|
        +row L3_044           ; |RQRQRQRe                         ERQRQRQ|
        +row L3_044
        +row L3_043           ; |QRQRQRQe                         EQRQRQR|
; r86: a gunship hovers
        +row_spawn L3_044, 1  ; |RQRQRQRe                         ERQRQRQ|
        +spawn E_GUNSHIP, 86, P_HOVER
        +row L3_044
        +row L3_045           ; |QRQRQRQe                        URQRQRQR|
        +row L3_046           ; |RQRQRQRe                        EQRQRQRQ|
        +row L3_046
        +row L3_047           ; |QRQRQRQRu                       ERQRQRQR|
        +row L3_048           ; |RQRQRQRQe                      URQRQRQRQ|
        +row L3_049           ; |QRQRQRQRe                      EQRQRQRQR|
        +row L3_049
        +row L3_050           ; |RQRQRQRQRu                     ERQRQRQRQ|
        +row L3_050
        +row L3_051           ; |QRQRQRQRQe                    URQRQRQRQR|
        +row L3_052           ; |RQRQRQRQRe                    EQRQRQRQRQ|
        +row L3_052
        +row L3_053           ; |QRQRQRQRQRu                   ERQRQRQRQR|
        +row L3_054           ; |RQRQRQRQRQe                   EQRQRQRQRQ|
        +row L3_054
        +row L3_055           ; |QRQRQRQRQRe                   ERQRQRQRQR|
; r98: fighter loops
        +row_spawn L3_056, 2  ; |RQRQRQRQRQRu                  EQRQRQRQRQ|
        +spawn E_FIGHTER, 100, P_LOOP_L
        +spawn E_FIGHTER, 60, P_LOOP_R
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_057
        +row L3_058           ; |RQRQRQRQRQRe        WX        EQRQRQRQRQ|
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_057
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|

; ===== section B: the narrows (r110) =====
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
; r118: weaving divers (1/3)
        +row_spawn L3_059, 1  ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +spawn E_DIVER, 40, P_WEAVE
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
; r120: weaving divers (2/3)
        +row_spawn L3_059, 1  ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +spawn E_DIVER, 86, P_WEAVE
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
; r122: weaving divers (3/3)
        +row_spawn L3_059, 1  ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +spawn E_DIVER, 132, P_WEAVE
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_060           ; |RQRQRQRQRQRe  i            i  EQRQRQRQRQ|
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_057
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_060           ; |RQRQRQRQRQRe  i            i  EQRQRQRQRQ|
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_057
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
        +row L3_059           ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +row L3_059
        +row L3_057           ; |QRQRQRQRQRQe                  ERQRQRQRQR|
; r140: leader hovers, a raider climbs from behind
        +row_spawn L3_059, 2  ; |RQRQRQRQRQRe                  EQRQRQRQRQ|
        +spawn E_LEADER, 86, P_HOVER
        +spawn E_RAIDER_UP, 30, P_RISE
        +row L3_059
        +row L3_061           ; |QRQRQRQRQRQRu                 ERQRQRQRQR|
        +row L3_062           ; |RQRQRQRQRQRQe                 EQRQRQRQRQ|
        +row L3_062
        +row L3_063           ; |QRQRQRQRQRQRe                 ERQRQRQRQR|
        +row L3_064           ; |RQRQRQRQRQRQRu                NQRQRQRQRQ|
        +row L3_065           ; |QRQRQRQRQRQRQe                 EQRQRQRQR|
        +row L3_065
        +row L3_066           ; |RQRQRQRQRQRQRe           o     ERQRQRQRQ|
        +row L3_066
        +row L3_067           ; |QRQRQRQRQRQRQRu                NQRQRQRQR|
        +row L3_068           ; |RQRQRQRQRQRQRQe                 EQRQRQRQ|
        +row L3_068
        +row L3_069           ; |QRQRQRQRQRQRQRe                 ERQRQRQR|
        +row L3_070           ; |RQRQRQRQRQRQRQRu                NQRQRQRQ|
        +row L3_071           ; |QRQRQRQRQRQRQRQe                 EQRQRQR|
        +row L3_071
        +row L3_072           ; |RQRQRQRQRQRQRQRe                 ERQRQRQ|
        +row L3_072
        +row L3_073           ; |QRQRQRQRQRQRQRQe                 NQRQRQR|
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
; r156: raider crossfire
        +row_spawn L3_074, 2  ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +spawn E_RAIDER, 0, P_CROSS_R
        +spawn E_RAIDER, 171, P_CROSS_L
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_076           ; |RQRQRQRQRQRQRQRe        WX        EQRQRQ|
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_075
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
; r170: two divers and a fighter
        +row_spawn L3_074, 3  ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +spawn E_DIVER, 40, P_DIVEBOMB
        +spawn E_DIVER, 132, P_DIVEBOMB
        +spawn E_FIGHTER, 86, P_DIVE
        +row L3_074
        +row L3_075           ; |QRQRQRQRQRQRQRQe                  ERQRQR|
        +row L3_074           ; |RQRQRQRQRQRQRQRe                  EQRQRQ|
        +row L3_074
        +row L3_077           ; |QRQRQRQRQRQRQRQn                  ERQRQR|
        +row L3_078           ; |RQRQRQRQRQRQRQe                   EQRQRQ|
        +row L3_078
        +row L3_079           ; |QRQRQRQRQRQRQRe                   ERQRQR|
        +row L3_080           ; |RQRQRQRQRQRQRQn                  URQRQRQ|
        +row L3_081           ; |QRQRQRQRQRQRQe                   EQRQRQR|
        +row L3_081
        +row L3_082           ; |RQRQRQRQRQRQRe                   ERQRQRQ|
        +row L3_082
        +row L3_083           ; |QRQRQRQRQRQRQn                  URQRQRQR|
        +row L3_084           ; |RQRQRQRQRQRQe                   EQRQRQRQ|
        +row L3_084
        +row L3_085           ; |QRQRQRQRQRQRe                   ERQRQRQR|
        +row L3_086           ; |RQRQRQRQRQRQn                  URQRQRQRQ|
        +row L3_087           ; |QRQRQRQRQRQe                   EQRQRQRQR|
        +row L3_087
; r184: gunship zigzag
        +row_spawn L3_088, 1  ; |RQRQRQRQRQRe                   ERQRQRQRQ|
        +spawn E_GUNSHIP, 86, P_ZIGZAG
        +row L3_088
        +row L3_089           ; |QRQRQRQRQRQn                  URQRQRQRQR|
        +row L3_054           ; |RQRQRQRQRQe                   EQRQRQRQRQ|
        +row L3_054
        +row L3_055           ; |QRQRQRQRQRe                   ERQRQRQRQR|
        +row L3_090           ; |RQRQRQRQRQn                  URQRQRQRQRQ|
        +row L3_091           ; |QRQRQRQRQe                   EQRQRQRQRQR|
        +row L3_091
        +row L3_092           ; |RQRQRQRQRe                   ERQRQRQRQRQ|
        +row L3_092
        +row L3_093           ; |QRQRQRQRQn                  URQRQRQRQRQR|
        +row L3_094           ; |RQRQRQRQe                   EQRQRQRQRQRQ|
        +row L3_094
        +row L3_095           ; |QRQRQRQRe                   ERQRQRQRQRQR|
; r194: climbers from behind
        +row_spawn L3_096, 2  ; |RQRQRQRQn                  URQRQRQRQRQRQ|
        +spawn E_RAIDER_UP, 30, P_RISE_R
        +spawn E_RAIDER_UP, 140, P_RISE_L
        +row L3_097           ; |QRQRQRQe                   EQRQRQRQRQRQR|
        +row L3_097
        +row L3_098           ; |RQRQRQRe  i             i  ERQRQRQRQRQRQ|
        +row L3_098
        +row L3_099           ; |QRQRQRQn                  URQRQRQRQRQRQR|
        +row L3_100           ; |RQRQRQe                   EQRQRQRQRQRQRQ|
        +row L3_100
        +row L3_101           ; |QRQRQRe                   ERQRQRQRQRQRQR|

; ===== section C: the winding strait (r200) =====
        +row L3_102           ; |RQRQRQn  i             i URQRQRQRQRQRQRQ|
        +row L3_103           ; |QRQRQe                   EQRQRQRQRQRQRQR|
        +row L3_103
        +row L3_104           ; |RQRQRe                   ERQRQRQRQRQRQRQ|
        +row L3_104
        +row L3_105           ; |QRQRQe                  URQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
; r210: dive-bomb stream (1/3)
        +row_spawn L3_106, 1  ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +spawn E_DIVER, 30, P_DIVEBOMB
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
; r212: dive-bomb stream (2/3)
        +row_spawn L3_106, 1  ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +spawn E_DIVER, 60, P_DIVEBOMB
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
; r214: dive-bomb stream (3/3)
        +row_spawn L3_106, 1  ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +spawn E_DIVER, 90, P_DIVEBOMB
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_108           ; |RQRQRe            o     EQRQRQRQRQRQRQRQ|
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_107
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_107           ; |QRQRQe                  ERQRQRQRQRQRQRQR|
        +row L3_106           ; |RQRQRe                  EQRQRQRQRQRQRQRQ|
        +row L3_106
        +row L3_109           ; |QRQRQRu                 ERQRQRQRQRQRQRQR|
; r228: leader loops (medals!)
        +row_spawn L3_110, 2  ; |RQRQRQe                 EQRQRQRQRQRQRQRQ|
        +spawn E_LEADER, 120, P_LOOP_L
        +spawn E_LEADER, 50, P_LOOP_R
        +row L3_110
        +row L3_111           ; |QRQRQRe                 ERQRQRQRQRQRQRQR|
        +row L3_112           ; |RQRQRQRu                EQRQRQRQRQRQRQRQ|
        +row L3_113           ; |QRQRQRQe                ERQRQRQRQRQRQRQR|
        +row L3_113
        +row L3_114           ; |RQRQRQRe                NQRQRQRQRQRQRQRQ|
        +row L3_114
        +row L3_115           ; |QRQRQRQRu                EQRQRQRQRQRQRQR|
        +row L3_116           ; |RQRQRQRQe                ERQRQRQRQRQRQRQ|
        +row L3_116
        +row L3_117           ; |QRQRQRQRe                NQRQRQRQRQRQRQR|
        +row L3_118           ; |RQRQRQRQRu                EQRQRQRQRQRQRQ|
        +row L3_119           ; |QRQRQRQLQe                ERQRQRQRQRQRQR|
        +row L3_119
        +row L3_120           ; |RQRQRQRQRe                NQRQRQRQRQRQRQ|
        +row L3_121           ; |QRQRQRQRQe                 EQRQRQRQRQRQR|
        +row L3_121
        +row L3_122           ; |RQRQRQRQRe                 ERQRQRQRQRQRQ|
        +row L3_122
        +row L3_123           ; |QRQRQRQRQe                 NQRQRQRQRQRQR|
        +row L3_124           ; |RQRQRQRQRe                  EQRQRQRQRQRQ|
        +row L3_124
        +row L3_125           ; |QRQRQRQRQe                  ERQRQRQRQRQR|
        +row L3_126           ; |RQRQRQRQRe                  NQRQRQRQRQRQ|
        +row L3_091           ; |QRQRQRQRQe                   EQRQRQRQRQR|
        +row L3_091
        +row L3_092           ; |RQRQRQRQRe                   ERQRQRQRQRQ|
        +row L3_092
        +row L3_127           ; |QRQRQRQRQe                   NQRQRQRQRQR|
        +row L3_052           ; |RQRQRQRQRe                    EQRQRQRQRQ|
        +row L3_052
        +row L3_128           ; |QRQRQRQRQe                    ERQRQRQRQR|
; r250: fast gunship trio
        +row_spawn L3_129, 3  ; |RQRQRQRQRe         WX         NQRQRQRQRQ|
        +spawn E_GUNSHIP, 30, P_DIVE_FAST
        +spawn E_GUNSHIP, 86, P_DIVE_FAST
        +spawn E_GUNSHIP, 142, P_DIVE_FAST
        +row L3_130           ; |QRQRQRQRQe                     EQRQRQRQR|
        +row L3_130
        +row L3_131           ; |RQRQRQRQRe                     ERQRQRQRQ|
        +row L3_131
        +row L3_132           ; |QRQRQRQRQe                     NQRQRQRQR|
        +row L3_133           ; |RQRQRQRQRe                      EQRQRQRQ|
        +row L3_133
        +row L3_134           ; |QRQRQRQRQe                      ERQRQRQR|
        +row L3_133           ; |RQRQRQRQRe                      EQRQRQRQ|
        +row L3_133
        +row L3_134           ; |QRQRQRQRQe                      ERQRQRQR|
        +row L3_133           ; |RQRQRQRQRe                      EQRQRQRQ|
        +row L3_133
        +row L3_135           ; |QRQRQRQRQn                      ERQRQRQR|
        +row L3_136           ; |RQRQRQRQe                       EQRQRQRQ|
        +row L3_136
        +row L3_137           ; |QRQRQRQRe                       ERQRQRQR|
        +row L3_138           ; |RQRQRQRQn                       EQRQRQRQ|
        +row L3_139           ; |QRQRQRQe                        ERQRQRQR|
        +row L3_139
; r264: weaving divers and a diving leader
        +row_spawn L3_046, 3  ; |RQRQRQRe                        EQRQRQRQ|
        +spawn E_DIVER, 40, P_WEAVE
        +spawn E_DIVER, 120, P_WEAVE
        +spawn E_LEADER, 86, P_DIVE
        +row L3_046
        +row L3_140           ; |QRQRQRQn                        ERQRQRQR|
        +row L3_141           ; |RQRQRQe               o         EQRQRQRQ|
        +row L3_142           ; |QRQRQRe                         ERQRQRQR|
        +row L3_142
        +row L3_143           ; |RQRQRQn                         EQRQRQRQ|
        +row L3_144           ; |QRQRQe                          ERQRQRQR|
        +row L3_144
        +row L3_145           ; |RQRQRe                          EQRQRQRQ|
        +row L3_145
        +row L3_146           ; |QRQRQn                          ERQRQRQR|
        +row L3_147           ; |RQRQe                           EQRQRQRQ|
        +row L3_147
        +row L3_148           ; |QRQRe                           ERQRQRQR|
        +row L3_149           ; |RQRQn                           EQRQRQRQ|
        +row L3_150           ; |QRQe                            ERQRQRQR|
        +row L3_150
        +row L3_151           ; |RQRe                            EQRQRQRQ|
        +row L3_151
        +row L3_152           ; |QRQn                            ERQRQRQR|
        +row L3_153           ; |RQe                             EQRQRQRQ|
        +row L3_153
        +row L3_154           ; |QRe                             ERQRQRQR|

; ===== section D: out into open water (r280) =====
        +row L3_155           ; |RQn                             NQRQRQRQ|
        +row L3_156           ; |Qe                               EQRQRQR|
        +row L3_156
; r282: rear attack, three abreast
        +row_spawn L3_157, 3  ; |Re                               ERQRQRQ|
        +spawn E_RAIDER_UP, 30, P_RISE
        +spawn E_RAIDER_UP, 86, P_RISE
        +spawn E_RAIDER_UP, 142, P_RISE
        +row L3_157
        +row L3_158           ; |Qn                               NQRQRQR|
        +row L3_159           ; |e                                 EQRQRQ|
        +row L3_159
        +row L3_160           ; |e                                 ERQRQR|
        +row L3_161           ; |n                                 NQRQRQ|
        +row L3_162           ; |                                   EQRQR|
        +row L3_162
        +row L3_163           ; |                                   ERQRQ|
        +row L3_163
        +row L3_164           ; |                                   NQRQR|
        +row L3_165           ; |                                    EQRQ|
        +row L3_165
        +row L3_166           ; |                                    ERQR|
        +row L3_167           ; |                                    NQRQ|
        +row L3_168           ; |                                     EQR|
        +row L3_168
        +row L3_169           ; |                                     ERQ|
        +row L3_169
        +row L3_170           ; |                                     NQR|
        +row L3_171           ; |                                      EQ|
        +row L3_171
        +row L3_172           ; |                                      ER|
; r298: gunship crossfire
        +row_spawn L3_173, 2  ; |                                      NQ|
        +spawn E_GUNSHIP, 0, P_CROSS_R
        +spawn E_GUNSHIP, 171, P_CROSS_L
        +row L3_174           ; |                                       E|
        +row L3_174
        +row L3_174           ; |                                       E|
        +row L3_174
        +row L3_175           ; |                                       N|
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
; r310: dive-bomber trio
        +row_spawn L3_000, 3  ; |              `                ~      o |
        +spawn E_DIVER, 30, P_DIVEBOMB
        +spawn E_DIVER, 86, P_DIVEBOMB
        +spawn E_DIVER, 142, P_DIVEBOMB
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
; r324: leaders swoop, a gunship hovers
        +row_spawn L3_002, 3  ; |     ~                `          o      |
        +spawn E_LEADER, 130, P_SWOOP_L
        +spawn E_LEADER, 30, P_SWOOP_R
        +spawn E_GUNSHIP, 86, P_HOVER
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
; r342: last stand: weaving fighters
        +row_spawn L3_002, 3  ; |     ~                `          o      |
        +spawn E_FIGHTER, 40, P_WEAVE
        +spawn E_FIGHTER, 86, P_WEAVE
        +spawn E_FIGHTER, 132, P_WEAVE
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001

; --- boss fight: open water loops until the boss is destroyed ---
        +boss_here
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005
        +row L3_000           ; |              `                ~      o |
        +row L3_001           ; |                    ~                   |
        +row L3_001
        +row L3_002           ; |     ~                `          o      |
        +row L3_003           ; |           `                ~           |
        +row L3_003
        +row L3_004           ; |  o              ~                  `   |
        +row L3_005           ; |        ~                o              |
        +row L3_005

        +level_end
