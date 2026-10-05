; =============================================================================
; data/tiles_fleet.asm - tileset 4 "fleet": stormy sea and enemy warships
; (destroyers, cruisers, a carrier) seen from above, bows up, with wakes
; Copied to char codes 64-127 when a level that uses it starts. Each tile's
; char code is the ASCII code of the letter used for it in row patterns.
;
; Pixels and the colours they get from level 4's palette (data/levels.asm):
;   .  BGCOL0  storm sea (dark grey)
;   g  BGCOL1  hull outlines, funnels (black)
;   b  BGCOL2  decks (grey; not light grey, so the player's ship stays visible)
;   c  colour RAM: wakes, whitecaps, deck markings (white)
;
; Ships are built from these tiles in data/level4.asm. Mirrored pairs (A/B,
; H/I, J/K, V/W) are generated as exact mirrors. Ships are scenery only: the
; background never collides.
;
; Must stay in ascending char-code order. If you add a tile, also add its
; letter to TILE_CHARS just below.
; =============================================================================

!set TILE_CHARS = " ABDFHIJKPQSTVWY`~"

tiles_fleet
        +tileset_start

; 'A' (65) bow, left half (the hull narrows to the tip)
        +tile 'A'
        +mc "...."
        +mc "...g"
        +mc "...g"
        +mc "..gb"
        +mc "..gb"
        +mc ".gbb"
        +mc ".gbb"
        +mc "gbbb"

; 'B' (66) bow, right half (mirror of A)
        +tile 'B'
        +mc "...."
        +mc "g..."
        +mc "g..."
        +mc "bg.."
        +mc "bg.."
        +mc "bbg."
        +mc "bbg."
        +mc "bbbg"

; 'D' (68) deck
        +tile 'D'
        +mc "bbbb"
        +mc "bgbb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbgb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"

; 'F' (70) funnel
        +tile 'F'
        +mc "bbbb"
        +mc "bggb"
        +mc "gggg"
        +mc "gccg"
        +mc "gggg"
        +mc "gggg"
        +mc "bggb"
        +mc "bbbb"

; 'H' (72) hull side, left (dark hull edge, deck)
        +tile 'H'
        +mc "gbbb"
        +mc "gbbb"
        +mc "gbbb"
        +mc "gbcb"
        +mc "gbbb"
        +mc "gbbb"
        +mc "gbbb"
        +mc "gbcb"

; 'I' (73) hull side, right (mirror of H)
        +tile 'I'
        +mc "bbbg"
        +mc "bbbg"
        +mc "bbbg"
        +mc "bcbg"
        +mc "bbbg"
        +mc "bbbg"
        +mc "bbbg"
        +mc "bcbg"

; 'J' (74) stern, left half (narrows, wake starts)
        +tile 'J'
        +mc "gbbb"
        +mc "gbbb"
        +mc ".gbb"
        +mc ".gbb"
        +mc "..gb"
        +mc "..gg"
        +mc "...c"
        +mc "..cc"

; 'K' (75) stern, right half (mirror of J)
        +tile 'K'
        +mc "bbbg"
        +mc "bbbg"
        +mc "bbg."
        +mc "bbg."
        +mc "bg.."
        +mc "gg.."
        +mc "c..."
        +mc "cc.."

; 'P' (80) carrier flight deck
        +tile 'P'
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"

; 'Q' (81) carrier deck with a parked plane
        +tile 'Q'
        +mc "bbcb"
        +mc "bccc"
        +mc "bbcb"
        +mc "bbcb"
        +mc "bccc"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbbb"

; 'S' (83) superstructure / bridge / carrier island
        +tile 'S'
        +mc "bbbb"
        +mc "bccb"
        +mc "bccb"
        +mc "cggc"
        +mc "cccc"
        +mc "bggb"
        +mc "bccb"
        +mc "bbbb"

; 'T' (84) gun turret, barrels forward
        +tile 'T'
        +mc "bbgb"
        +mc "bbgb"
        +mc "bggg"
        +mc "gccg"
        +mc "gccg"
        +mc "bggg"
        +mc "bbbb"
        +mc "bbbb"

; 'V' (86) wake, left half (white V behind the stern)
        +tile 'V'
        +mc "..cc"
        +mc ".c.c"
        +mc ".c.."
        +mc "c..."
        +mc "c..."
        +mc "...."
        +mc "c..."
        +mc "...."

; 'W' (87) wake, right half (mirror of V)
        +tile 'W'
        +mc "cc.."
        +mc "c.c."
        +mc "..c."
        +mc "...c"
        +mc "...c"
        +mc "...."
        +mc "...c"
        +mc "...."

; 'Y' (89) carrier deck centre line
        +tile 'Y'
        +mc "bbcb"
        +mc "bbcb"
        +mc "bbbb"
        +mc "bbbb"
        +mc "bbcb"
        +mc "bbcb"
        +mc "bbbb"
        +mc "bbbb"

; '`' (96) whitecap, low in the cell
        +tile '`'
        +mc "...."
        +mc "...."
        +mc "...."
        +mc "...."
        +mc ".cc."
        +mc "c..c"
        +mc "...."
        +mc "...."

; '~' (126) whitecap, high in the cell
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
