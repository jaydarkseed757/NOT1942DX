; =============================================================================
; data/tiles_jungle.asm - tileset 2 "jungle": coastline, jungle, rivers,
; village and an enemy airstrip
; Copied to char codes 64-127 when a level that uses it starts. Each tile's
; char code is the ASCII code of the letter used for it in row patterns.
;
; Pixels and the colours they get from level 2's palette (data/levels.asm):
;   .  BGCOL0  shallow sea / river water (light blue)
;   g  BGCOL1  jungle (green)
;   b  BGCOL2  canopy highlights, thatch (light green)
;   c  colour RAM: sand, concrete (yellow)
;
; COASTLINE: land is on the left. In a row whose coast is at column x, the
; columns left of x are jungle (J/K) and column x is the shore 'e'
; (sand edge, water to its right). Where the coast moves by one column
; between rows, the in-between row uses a diagonal instead:
;   'u' at column x: coast at x above, at x-1 below (land shrinks going down)
;   'n' at column x: coast at x-1 above, at x below (land grows going down)
;
; Must stay in ascending char-code order. If you add a tile, also add its
; letter to TILE_CHARS just below.
; =============================================================================

!set TILE_CHARS = " BDHJKSTWX`enopu~"

tiles_jungle
        +tileset_start

; 'B' (66) river, bottom bank: water above, sand, jungle below
        +tile 'B'
        +mc "...."
        +mc "...."
        +mc "cc.c"
        +mc "cccc"
        +mc "cccc"
        +mc "gggg"
        +mc "gbgg"
        +mc "ggbg"

; 'D' (68) hangar / depot: concrete roof with a dark outline, on jungle
        +tile 'D'
        +mc "gggg"
        +mc "gccg"
        +mc "cccc"
        +mc "cbbc"
        +mc "cccc"
        +mc "gccg"
        +mc "gggg"
        +mc "gbgg"

; 'H' (72) hut: thatched roof on a sandy clearing
        +tile 'H'
        +mc "cccc"
        +mc "cbbc"
        +mc "bbbb"
        +mc "gbbg"
        +mc "cggc"
        +mc "cgcc"
        +mc "cccc"
        +mc "cccc"

; 'J' (74) jungle canopy, texture A
        +tile 'J'
        +mc "gbgg"
        +mc "bbbg"
        +mc "gbgg"
        +mc "ggbg"
        +mc "gbbb"
        +mc "ggbg"
        +mc "bggg"
        +mc "gggb"

; 'K' (75) jungle canopy, texture B (alternates with J so it doesn't tile)
        +tile 'K'
        +mc "ggbg"
        +mc "gbbb"
        +mc "ggbg"
        +mc "bggg"
        +mc "bbgg"
        +mc "bggb"
        +mc "ggbb"
        +mc "gggb"

; 'S' (83) sand: beach strip or clearing
        +tile 'S'
        +mc "cccc"
        +mc "cgcc"
        +mc "cccc"
        +mc "cccg"
        +mc "cccc"
        +mc "cccc"
        +mc "gccc"
        +mc "cccc"

; 'T' (84) river, top bank: jungle above, sand, water below
        +tile 'T'
        +mc "gbgg"
        +mc "ggbg"
        +mc "gggg"
        +mc "cccc"
        +mc "cccc"
        +mc "c.cc"
        +mc "...."
        +mc "...."

; 'W' (87) airstrip, left half: grass verge, concrete, centre-line dashes
        +tile 'W'
        +mc "gccc"
        +mc "gcc."
        +mc "gcc."
        +mc "gccc"
        +mc "gccc"
        +mc "gcc."
        +mc "gcc."
        +mc "gccc"

; 'X' (88) airstrip, right half
        +tile 'X'
        +mc "cccg"
        +mc ".ccg"
        +mc ".ccg"
        +mc "cccg"
        +mc "cccg"
        +mc ".ccg"
        +mc ".ccg"
        +mc "cccg"

; '`' (96) sun glint on the water, low in the cell
        +tile '`'
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "..c."
        +mc ".ccc"
        +mc "..c."
        +mc "...."

; 'e' (101) shore: jungle, sand, water to the right (rugged edge)
        +tile 'e'
        +mc "ggcc"
        +mc "gcc."
        +mc "gccc"
        +mc "ggcc"
        +mc "gcc."
        +mc "ggcc"
        +mc "gccc"
        +mc "gcc."

; 'n' (110) shore diagonal: land grows to the right going down
        +tile 'n'
        +mc "c..."
        +mc "c..."
        +mc "cc.."
        +mc "cc.."
        +mc "gcc."
        +mc "gcc."
        +mc "ggcc"
        +mc "ggcc"

; 'o' (111) rock / sandbar in the shallows
        +tile 'o'
        +mc "...."
        +mc ".cc."
        +mc "cccc"
        +mc "cgcc"
        +mc "cccc"
        +mc ".cc."
        +mc "...."
        +mc "...."

; 'p' (112) palm tree on sand
        +tile 'p'
        +mc "bcbc"
        +mc "cbbc"
        +mc "bbbb"
        +mc "cbgc"
        +mc "ccgc"
        +mc "ccgc"
        +mc "cgcc"
        +mc "cccc"

; 'u' (117) shore diagonal: land shrinks to the left going down
        +tile 'u'
        +mc "ggcc"
        +mc "ggcc"
        +mc "gcc."
        +mc "gcc."
        +mc "cc.."
        +mc "cc.."
        +mc "c..."
        +mc "...."

; '~' (126) sun glint on the water, high in the cell
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
