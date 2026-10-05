; =============================================================================
; data/tiles_strait.asm - tileset 3 "strait": cliffs on both sides, sea
; stacks, a lighthouse, a wreck and buoys, at sunset
; Copied to char codes 64-127 when a level that uses it starts. Each tile's
; char code is the ASCII code of the letter used for it in row patterns.
;
; Pixels and the colours they get from level 3's palette (data/levels.asm):
;   .  BGCOL0  water at sunset (purple)
;   g  BGCOL1  cliff rock (brown)
;   b  BGCOL2  sunlit rock (orange)
;   c  colour RAM: foam, glints, lamp light (yellow)
;
; CLIFFS: the left cliff works like the level 2 coast: columns left of the
; edge are rock (R/Q), the edge is 'e', and 'n'/'u' are the diagonals where
; it moves by a column. The right cliff is the mirror image: rock to the
; right of 'E', with diagonals 'N' (grows going down) and 'U' (shrinks).
; The right-hand tiles are generated as exact mirrors of the left-hand ones.
;
; Must stay in ascending char-code order. If you add a tile, also add its
; letter to TILE_CHARS just below.
; =============================================================================

!set TILE_CHARS = " ELNQRUWX`einou~"

tiles_strait
        +tileset_start

; 'E' (69) right cliff edge (mirror of e)
        +tile 'E'
        +mc ".cbg"
        +mc "ccbg"
        +mc ".cbg"
        +mc "cbgg"
        +mc ".cbg"
        +mc "ccbg"
        +mc ".cbg"
        +mc "cbgg"

; 'L' (76) lighthouse on the cliff top: lamp, tower, rock
        +tile 'L'
        +mc "gcgg"
        +mc "ccc."
        +mc "gcgg"
        +mc "gbgg"
        +mc "gbgg"
        +mc "gbgg"
        +mc "bbbg"
        +mc "gggg"

; 'N' (78) right cliff diagonal (mirror of n)
        +tile 'N'
        +mc "...c"
        +mc "..cb"
        +mc "..cb"
        +mc ".cbg"
        +mc ".cbg"
        +mc "cbgg"
        +mc "cbgg"
        +mc "bggg"

; 'Q' (81) rock, texture B (alternates with R)
        +tile 'Q'
        +mc "gggg"
        +mc "bggg"
        +mc "gbgb"
        +mc "gggg"
        +mc "ggbg"
        +mc "gggg"
        +mc "bggg"
        +mc "ggbg"

; 'R' (82) rock, texture A
        +tile 'R'
        +mc "gbgg"
        +mc "ggbg"
        +mc "gggg"
        +mc "bggb"
        +mc "gggg"
        +mc "ggbg"
        +mc "gbgg"
        +mc "gggg"

; 'U' (85) right cliff diagonal (mirror of u)
        +tile 'U'
        +mc "bggg"
        +mc "cbgg"
        +mc "cbgg"
        +mc ".cbg"
        +mc ".cbg"
        +mc "..cb"
        +mc "..cb"
        +mc "...c"

; 'W' (87) wreck, bow half (a sunken hull, rusty)
        +tile 'W'
        +mc "...."
        +mc "..gg"
        +mc ".gbg"
        +mc "gbbg"
        +mc "gbgg"
        +mc ".ggc"
        +mc "..cc"
        +mc "...."

; 'X' (88) wreck, stern half
        +tile 'X'
        +mc "...."
        +mc "g..."
        +mc "bg.."
        +mc "bgg."
        +mc "ggb."
        +mc "cgg."
        +mc "cc.."
        +mc "...."

; '`' (96) sun glint, low in the cell
        +tile '`'
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "..c."
        +mc ".ccc"
        +mc "..c."
        +mc "...."

; 'e' (101) left cliff edge: rock, sunlit rim, foam, water to the right
        +tile 'e'
        +mc "gbc."
        +mc "gbcc"
        +mc "gbc."
        +mc "ggbc"
        +mc "gbc."
        +mc "gbcc"
        +mc "gbc."
        +mc "ggbc"

; 'i' (105) buoy: a small float with a light
        +tile 'i'
        +mc "...."
        +mc "...."
        +mc ".c.."
        +mc "cbc."
        +mc ".g.."
        +mc "c.c."
        +mc "...."
        +mc "...."

; 'n' (110) left cliff diagonal: land grows to the right going down
        +tile 'n'
        +mc "c..."
        +mc "bc.."
        +mc "bc.."
        +mc "gbc."
        +mc "gbc."
        +mc "ggbc"
        +mc "ggbc"
        +mc "gggb"

; 'o' (111) sea stack: a rock pillar ringed with foam
        +tile 'o'
        +mc "...."
        +mc ".cc."
        +mc "cbbc"
        +mc "cbgc"
        +mc "cggc"
        +mc "cbgc"
        +mc ".cc."
        +mc "...."

; 'u' (117) left cliff diagonal: land shrinks to the left going down
        +tile 'u'
        +mc "gggb"
        +mc "ggbc"
        +mc "ggbc"
        +mc "gbc."
        +mc "gbc."
        +mc "bc.."
        +mc "bc.."
        +mc "c..."

; '~' (126) sun glint, high in the cell
        +tile '~'
        +mc "...."
        +mc "..c."
        +mc ".ccc"
        +mc "..c."
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +tileset_end
