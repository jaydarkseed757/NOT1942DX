; =============================================================================
; data/tiles_ocean.asm - tileset 1 "ocean": sea, waves and tropical islands
; Copied to char codes 64-127 when a level that uses it starts. Each tile's
; char code is the ASCII code of the letter used for it in row patterns, so
; level rows read as text art.
;
; Pixels (each is 2 bits, double width, 4 per row). The actual colours come
; from the level's palette (data/levels.asm):
;   .  BGCOL0 (ocean)    g  BGCOL1 (grass)
;   b  BGCOL2 (beach)    c  colour RAM (surf)
;
; Must stay in ascending char-code order. If you add a tile, also add its
; letter to TILE_CHARS just below.
; =============================================================================

!set TILE_CHARS = " ~`[]^_bdgopqt"

tiles_ocean
        +tileset_start

; '[' (91) island left edge: surf + beach on the left, grass on the right
        +tile '['
        +mc "cbgg"
        +mc ".bgg"
        +mc ".bgg"
        +mc "cbgg"
        +mc ".bgg"
        +mc "cbgg"
        +mc ".bgg"
        +mc ".bgg"

; ']' (93) island right edge
        +tile ']'
        +mc "ggbc"
        +mc "ggb."
        +mc "ggbc"
        +mc "ggb."
        +mc "ggb."
        +mc "ggbc"
        +mc "ggb."
        +mc "ggbc"

; '^' (94) island top edge: water and surf above, beach, then grass
        +tile '^'
        +mc "...."
        +mc ".c.c"
        +mc "c.c."
        +mc "bbbb"
        +mc "bbbb"
        +mc "gbgg"
        +mc "gggg"
        +mc "gggg"

; '_' (95) island bottom edge
        +tile '_'
        +mc "gggg"
        +mc "gggg"
        +mc "ggbg"
        +mc "bbbb"
        +mc "bbbb"
        +mc "c.c."
        +mc ".c.c"
        +mc "...."

; '`' (96) small wave, low in the cell (pairs with '~', which sits high)
        +tile '`'
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +mc ".cc."
        +mc "c..c"
        +mc "...."
        +mc "...."

; 'b' (98) island bottom-left corner
        +tile 'b'
        +mc "cbgg"
        +mc ".bgg"
        +mc "cbgg"
        +mc ".bbb"
        +mc ".cbb"
        +mc "..c."
        +mc "...c"
        +mc "...."

; 'd' (100) island bottom-right corner
        +tile 'd'
        +mc "ggbc"
        +mc "ggb."
        +mc "ggbc"
        +mc "bbb."
        +mc "bbc."
        +mc ".c.."
        +mc "c..."
        +mc "...."

; 'g' (103) grass interior
        +tile 'g'
        +mc "gggg"
        +mc "gggg"
        +mc "gbgg"
        +mc "gggg"
        +mc "gggg"
        +mc "gggg"
        +mc "gggb"
        +mc "gggg"

; 'o' (111) one-cell islet / rock
        +tile 'o'
        +mc "...."
        +mc ".cc."
        +mc "cbbc"
        +mc "bggb"
        +mc "bggb"
        +mc "cbbc"
        +mc ".cc."
        +mc "...."

; 'p' (112) island top-right corner
        +tile 'p'
        +mc "...."
        +mc "c..."
        +mc ".c.."
        +mc "bbc."
        +mc "bbb."
        +mc "ggbc"
        +mc "ggb."
        +mc "ggbc"

; 'q' (113) island top-left corner
        +tile 'q'
        +mc "...."
        +mc "...c"
        +mc "..c."
        +mc ".cbb"
        +mc ".bbb"
        +mc "cbgg"
        +mc ".bgg"
        +mc "cbgg"

; 't' (116) tree (round canopy, beach-coloured outline on grass)
        +tile 't'
        +mc "gggg"
        +mc "gbbg"
        +mc "bggb"
        +mc "bggb"
        +mc "gbbg"
        +mc "ggbg"
        +mc "ggbg"
        +mc "gggg"

; '~' (126) small wave, high in the cell
        +tile '~'
        +mc "...."
        +mc ".cc."
        +mc "c..c"
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +tileset_end
