; =============================================================================
; macros.asm - assemble-time helpers for authoring data in data/
; These generate bytes and check data at assemble time. No runtime code.
; =============================================================================

; Each level has a TILESET: the 64 chars with codes 64-127, copied into the
; charset when the level starts. A tile's char code IS its ASCII code, so row
; patterns can be written as plain text. Space (32) is the ROM-font blank.
; Each tileset file sets TILE_CHARS (with !set) to the letters it defines, and
; +rowpat checks rows against the most recent TILE_CHARS.
TILESET_SIZE = 64 * 8           ; bytes copied per level: char codes 64-127

; -----------------------------------------------------------------------------
; +mc "pppp" : one multicolour char row = 4 double-wide pixels -> 1 byte
;   '.' = %00  ocean   (BGCOL0)
;   'g' = %01  grass   (BGCOL1)
;   'b' = %10  beach   (BGCOL2)
;   'c' = %11  surf    (colour RAM, fixed for the whole playfield)
; -----------------------------------------------------------------------------
!macro mc .s {
        !if len(.s) != 4 { !error "+mc needs exactly 4 pixels" }
        !set .v = 0
        !for .i, 0, 3 {
                !set .c = .s[.i]
                !set .p = -1
                !if .c = '.' { !set .p = 0 }
                !if .c = 'g' { !set .p = 1 }
                !if .c = 'b' { !set .p = 2 }
                !if .c = 'c' { !set .p = 3 }
                !if .p < 0 { !error "+mc: pixel must be one of . g b c" }
                !set .v = (.v << 2) | .p
        }
        !byte .v
}

; -----------------------------------------------------------------------------
; +tileset_start : begin a tileset (char codes 64-127) at the current address.
; +tile 'x'      : move to the slot for char code 'x' (zero-filling gaps).
;                  Tiles must be in ascending char-code order, codes 64-127.
; +tileset_end   : pad to the full 512 bytes (unused codes are blank).
; -----------------------------------------------------------------------------
!macro tileset_start {
        !set TS_BASE = * - FIRST_TILE * 8
}

!macro tile .code {
        !if .code < FIRST_TILE { !error "+tile: code is inside the font range" }
        !if .code > 127 { !error "+tile: tiles use codes 64-127 (128+ are fixed chars)" }
        !if * > TS_BASE + .code * 8 { !error "+tile: tiles out of order or overlapping" }
        !if * < TS_BASE + .code * 8 {
                !fill TS_BASE + .code * 8 - *, 0
        }
}

!macro tileset_end {
        !if * < TS_BASE + 128 * 8 {
                !fill TS_BASE + 128 * 8 - *, 0
        }
}

; -----------------------------------------------------------------------------
; +rowpat "<40 chars>" : one background row pattern. Checks length and that
; every char is a defined tile (a typo would otherwise show as plain ocean).
; -----------------------------------------------------------------------------
!macro rowpat .txt {
        !if len(.txt) != COLS { !error "+rowpat: row must be exactly 40 chars" }
        !for .i, 0, COLS - 1 {
                !set .ok = 0
                !for .j, 0, len(TILE_CHARS) - 1 {
                        !if .txt[.i] = TILE_CHARS[.j] { !set .ok = 1 }
                }
                !if .ok = 0 { !error "+rowpat: unknown tile char (see TILE_CHARS)" }
        }
        !text .txt
}

; -----------------------------------------------------------------------------
; Level stream records (format in data/level1.asm)
; These keep assemble-time counters so mistakes fail the build:
;   LVL_RECORDS     records so far (the first SCROLL_ROWS must have no spawns)
;   LVL_SPAWNS_LEFT +spawn lines still owed by the last +row_spawn
;   LVL_BOSS_ROWS   records after +boss_here (-1 = no boss marker yet)
; Each level's row patterns end with  !set ROWPAT_COUNT = ...
; Each level stream starts with +level_start and ends with +level_end.
; -----------------------------------------------------------------------------
LVL_END   = $ff
LVL_BOSS  = $fe                 ; boss marker (1 byte, takes no scroll step)
SPAWN_LEN = 3                   ; bytes per spawn entry: type, x, path
MAX_SPAWNS_PER_ROW = 3          ; the record format's limit (well below ENEMY_COUNT)

!set LVL_RECORDS = 0
!set LVL_SPAWNS_LEFT = 0
!set LVL_BOSS_ROWS = -1

; +level_start : reset the per-level counters
!macro level_start {
        !set LVL_RECORDS = 0
        !set LVL_SPAWNS_LEFT = 0
        !set LVL_BOSS_ROWS = -1
}

!macro lvl_check_spawns_done {
        !if LVL_SPAWNS_LEFT != 0 { !error "previous +row_spawn is missing +spawn lines" }
}

; +row PAT : a row with no enemy spawns
MAX_ROWPATS = LVL_BOSS          ; pattern numbers 0-253 ($FE/$FF are markers)

!macro row .pat {
        +lvl_check_spawns_done
        !if .pat >= ROWPAT_COUNT { !error "+row: row pattern index out of range" }
        !byte .pat, 0
        !set LVL_RECORDS = LVL_RECORDS + 1
        !if LVL_BOSS_ROWS >= 0 { !set LVL_BOSS_ROWS = LVL_BOSS_ROWS + 1 }
}

; +row_spawn PAT, N : a row that spawns N enemies; follow with N +spawn lines
!macro row_spawn .pat, .n {
        +lvl_check_spawns_done
        !if .pat >= ROWPAT_COUNT { !error "+row_spawn: row pattern index out of range" }
        !if (.n < 1) | (.n > MAX_SPAWNS_PER_ROW) { !error "+row_spawn: spawn count must be 1-3" }
        !if LVL_RECORDS < SCROLL_ROWS { !error "+row_spawn: no spawns allowed in the first 25 (pre-drawn) records" }
        !if LVL_BOSS_ROWS >= 0 { !error "+row_spawn: no spawns after +boss_here (the boss owns the enemy slots)" }
        !byte .pat, .n
        !set LVL_SPAWNS_LEFT = .n
        !set LVL_RECORDS = LVL_RECORDS + 1
}

; +spawn TYPE, X, PATH : one enemy. X is half-X (0-171): 12-160 is fully on
; screen, 0 / 171 start just off the left / right edge (for side-entry paths).
!macro spawn .type, .x, .path {
        !if LVL_SPAWNS_LEFT <= 0 { !error "+spawn without a matching +row_spawn count" }
        !if .type >= ENEMY_TYPES { !error "+spawn: unknown enemy type" }
        !if .x > ENEMY_X_KILL - 1 { !error "+spawn: x must be 0-171 (half-X)" }
        !if .path >= PATH_COUNT { !error "+spawn: unknown path" }
        !byte .type, .x, .path
        !set LVL_SPAWNS_LEFT = LVL_SPAWNS_LEFT - 1
}

; +boss_here : the waves are over; the boss fight starts. The records after
; this marker are the background that loops for the rest of the level.
!macro boss_here {
        +lvl_check_spawns_done
        !if LVL_RECORDS < SCROLL_ROWS { !error "+boss_here: not inside the 25 pre-drawn records" }
        !if LVL_BOSS_ROWS >= 0 { !error "+boss_here: only one boss per level" }
        !byte LVL_BOSS
        !set LVL_BOSS_ROWS = 0
}

; +level_end : end of stream. The scroller loops back to just after
; +boss_here (or to the start if there is no boss marker).
!macro level_end {
        +lvl_check_spawns_done
        !if LVL_BOSS_ROWS = 0 { !error "+level_end: the boss loop needs at least one row" }
        !byte LVL_END
}

; -----------------------------------------------------------------------------
; Boss part lists (data/bosses.asm)
;   +boss_parts N                 count byte (1..BOSS_MAX_PARTS)
;   +boss_part SHAPE, DX, DY      one expanded sprite at (DX, DY) from part 0
; -----------------------------------------------------------------------------
!macro boss_parts .n {
        !if (.n < 1) | (.n > BOSS_MAX_PARTS) { !error "+boss_parts: 1 to BOSS_MAX_PARTS parts" }
        !byte .n
}
!macro boss_part .ptr, .dx, .dy {
        !byte .ptr, .dx, .dy
}

; -----------------------------------------------------------------------------
; Enemy paths (data/waves.asm)
;   +path_start Y            first byte of a path: the spawn Y (raster line)
;   +seg DX, DY, FRAMES      move by DX half-X and DY pixels per frame for
;                            FRAMES frames (1-254). DX/DY may be fractional:
;                            stored as signed 8.8 fixed point.
;   +seg_end                 keep the last velocity until off screen
;   +seg_loop LABEL          continue from LABEL (a +seg line, not a path start)
;   +seg_fire                fire one shot aimed at the player, then carry on
;                            with the next line (skipped if both enemy-bullet
;                            slots are busy or the enemy is off screen)
;   +boss_fire DX, DY        aimed shot from a gun at (DX half-X, DY pixels)
;                            from the top-left of the boss (or enemy)
;   +boss_spread DX, DY      two shots from that gun, fanned 22.5 degrees
;                            left and right of straight down
; -----------------------------------------------------------------------------
SEG_END    = 0
SEG_SPREAD = $fc
SEG_FIREAT = $fd
SEG_FIRE   = $fe
SEG_LOOP   = $ff
SEG_MAX_FRAMES = SEG_SPREAD - 1 ; frame counts share the byte with commands
SEG_LEN  = 5                    ; frames, dx lo/hi, dy lo/hi

!macro path_start .y {
        !byte .y
}

!macro seg .dx, .dy, .frames {
        !if (.frames < 1) | (.frames > SEG_MAX_FRAMES) { !error "+seg: frames must be 1-251" }
        !if (.dx <= -128) | (.dx >= 128) | (.dy <= -128) | (.dy >= 128) { !error "+seg: speed out of range" }
        !byte .frames
        !word int(.dx * 256) & $ffff
        !word int(.dy * 256) & $ffff
}

!macro seg_end {
        !byte SEG_END
}

!macro seg_fire {
        !byte SEG_FIRE
}

!macro boss_fire .dx, .dy {
        !if (.dx < 0) | (.dx > 255) | (.dy < 0) | (.dy > 255) { !error "+boss_fire: gun offset must be 0-255" }
        !byte SEG_FIREAT, .dx, .dy
}

!macro boss_spread .dx, .dy {
        !if (.dx < 0) | (.dx > 255) | (.dy < 0) | (.dy > 255) { !error "+boss_spread: gun offset must be 0-255" }
        !byte SEG_SPREAD, .dx, .dy
}

!macro seg_loop .target {
        !byte SEG_LOOP
        !word .target
}

; -----------------------------------------------------------------------------
; Sprites (data/sprites.asm). Multicolour sprite: 12 double-wide pixels/row.
;   '.' = %00  transparent
;   'w' = %01  shared colour 1 ($D025)
;   'i' = %10  this sprite's own colour ($D027+n)
;   'd' = %11  shared colour 2 ($D026)
; Write 21 rows of +spr, then +spr_end (adds the 64th pad byte).
; -----------------------------------------------------------------------------
!macro spr .s {
        !if len(.s) != 12 { !error "+spr needs exactly 12 pixels" }
        !for .b, 0, 2 {
                !set .v = 0
                !for .i, 0, 3 {
                        !set .c = .s[.b * 4 + .i]
                        !set .p = -1
                        !if .c = '.' { !set .p = 0 }
                        !if .c = 'w' { !set .p = 1 }
                        !if .c = 'i' { !set .p = 2 }
                        !if .c = 'd' { !set .p = 3 }
                        !if .p < 0 { !error "+spr: pixel must be one of . w i d" }
                        !set .v = (.v << 2) | .p
                }
                !byte .v
        }
}

; +spr_begin : must start on a 64-byte boundary inside the sprite area
!macro spr_begin {
        !if (* - SPRITES) % 64 != 0 { !error "sprite does not start on a 64-byte boundary" }
}

; +spr_end : check that exactly 21 rows were given, then pad to 64 bytes
!macro spr_end {
        !if (* - SPRITES) % 64 != 63 { !error "sprite must have exactly 21 rows" }
        !byte 0
}

; -----------------------------------------------------------------------------
; Music (data/music.asm). Lengths are in frames (50 per second).
;   +pat_start                 begin a pattern (resets the tick count)
;   +n "C#4", LEN              note: letter C D E F G A B, '-' or '#', octave
;   +r LEN                     rest
;   +ins N                     switch instrument
;   +bar                       assert the pattern so far is whole bars
;   +pat_end                   end; then define NAME_TICKS = PAT_TICKS
;   +ord_start / +ord PAT, TICKS / +ord_loop  order list for one voice;
;                              after +ord_loop, ORD_TICKS = the loop length
; -----------------------------------------------------------------------------
!set PAT_TICKS = 0
!set ORD_TICKS = 0

; +tempo F : set note lengths for the song that follows. F = frames per 16th
; note (6 -> 125 BPM, 7 -> 107 BPM). Defines L16 L8 L8D L4 L4D L2 L2D L1 and
; BAR (one 4/4 bar), which +bar checks against.
!macro tempo .f {
        !set L16 = .f
        !set L8  = .f * 2
        !set L8D = .f * 3
        !set L4  = .f * 4
        !set L4D = .f * 6
        !set L2  = .f * 8
        !set L2D = .f * 12
        !set L1  = .f * 16
        !set BAR = L1
        !if L1 > 255 { !error "+tempo: a whole note must fit in 255 frames" }
}

!macro pat_start {
        !set PAT_TICKS = 0
}

!macro n .s, .len {
        !if len(.s) != 3 { !error "+n: note must be 3 characters, like C-4 or F#3" }
        !set .semi = -1
        !if .s[0] = 'C' { !set .semi = 0 }
        !if .s[0] = 'D' { !set .semi = 2 }
        !if .s[0] = 'E' { !set .semi = 4 }
        !if .s[0] = 'F' { !set .semi = 5 }
        !if .s[0] = 'G' { !set .semi = 7 }
        !if .s[0] = 'A' { !set .semi = 9 }
        !if .s[0] = 'B' { !set .semi = 11 }
        !if .semi < 0 { !error "+n: note letter must be C D E F G A or B" }
        !if .s[1] = '#' {
                !set .semi = .semi + 1
        } else {
                !if .s[1] != '-' { !error "+n: second character must be - or #" }
        }
        !if (.s[2] < '0') | (.s[2] > '7') { !error "+n: octave must be 0-7" }
        !set .note = (.s[2] - '0') * 12 + .semi
        !if .note > MAX_NOTE { !error "+n: note above A#7" }
        !if (.len < 2) | (.len > 255) { !error "+n: length must be 2-255 frames" }
        !byte .note, .len
        !set PAT_TICKS = PAT_TICKS + .len
}

!macro r .len {
        !if (.len < 1) | (.len > 255) { !error "+r: length must be 1-255 frames" }
        !byte EV_REST, .len
        !set PAT_TICKS = PAT_TICKS + .len
}

!macro ins .i {
        !if .i >= INS_COUNT { !error "+ins: unknown instrument" }
        !byte EV_INS, .i
}

!macro bar {
        !if PAT_TICKS % BAR != 0 { !error "+bar: notes in this bar don't add up to a whole bar" }
}

!macro pat_end {
        !if PAT_TICKS = 0 { !error "+pat_end: empty pattern (would hang the player)" }
        +bar
        !byte EV_END
}

!macro ord_start {
        !set ORD_TICKS = 0
}

!macro ord .pat, .ticks {
        !word .pat
        !set ORD_TICKS = ORD_TICKS + .ticks
}

!macro ord_loop {
        !word 0
}

; -----------------------------------------------------------------------------
; Big title logo (data/title.asm). Each screen character shows a 2x2 block of
; logo pixels using the 16 "quadrant" chars QUAD_BASE..QUAD_BASE+15 defined
; in data/tiles.asm (bit 3 = top-left, 2 = top-right, 1 = bottom-left,
; 0 = bottom-right).
;   +logo_px "<pixel row>"   one row of pixels ('#' = set, '.' = clear).
;                            Rows pair up: every second call emits one
;                            screen row of len/2 character codes.
;   +logo_end                checks the row count was even.
; -----------------------------------------------------------------------------
QUAD_BASE = 128
!set LOGO_PENDING = 0           ; 1 = holding a top row in LOGO_TOP

!macro logo_px .row {
        !if LOGO_PENDING = 0 {
                !set LOGO_TOP = .row
                !set LOGO_PENDING = 1
        } else {
                +logo_rows LOGO_TOP, .row
                !set LOGO_PENDING = 0
        }
}

!macro logo_end {
        !if LOGO_PENDING != 0 { !error "+logo_end: odd number of logo pixel rows" }
}

!macro logo_rows .top, .bot {
        !if len(.top) != len(.bot) { !error "+logo_rows: rows differ in length" }
        !if len(.top) % 2 != 0 { !error "+logo_rows: width must be even" }
        !for .i, 0, len(.top) / 2 - 1 {
                !set .q = 0
                !if .top[.i * 2]     = '#' { !set .q = .q | 8 }
                !if .top[.i * 2 + 1] = '#' { !set .q = .q | 4 }
                !if .bot[.i * 2]     = '#' { !set .q = .q | 2 }
                !if .bot[.i * 2 + 1] = '#' { !set .q = .q | 1 }
                !byte QUAD_BASE + .q
        }
}

; -----------------------------------------------------------------------------
; Sound effects (data/sfx.asm)
;   +sfx_start                                   begin an effect
;   +boom FRAME, VOICE, WAVE, FREQ, AD, SR, SLIDE  one sound (see data/sfx.asm)
;   +sfx_end FRAME                               the effect is over (voice 3
;                                                goes back to the music)
; -----------------------------------------------------------------------------
!macro sfx_start {
        !set SFX_LAST_FRAME = 0
}

!macro boom .frame, .voice, .wave, .freq, .ad, .sr, .slide {
        !if (.frame < SFX_LAST_FRAME) | (.frame > 254) { !error "+boom: frames must ascend, 0-254" }
        !if (.voice < 0) | (.voice > 2) { !error "+boom: voice must be 0-2" }
        !if (.slide > 0) | (.slide < -128) { !error "+boom: slide must be 0 or negative" }
        !byte .frame, .voice, .wave, .freq, .ad, .sr, .slide & $ff
        !set SFX_LAST_FRAME = .frame
}

!macro sfx_end .frame {
        !if (.frame < SFX_LAST_FRAME) | (.frame > 254) { !error "+sfx_end: frame must be at or after the last boom, 0-254" }
        !byte .frame, SFX_STOP
}

; -----------------------------------------------------------------------------
; Ending (data/ending.asm)
;   +credit "text"   one 40-column line of the credits roll, centred
; -----------------------------------------------------------------------------
SCROLL_END = $ff

!macro credit .s {
        !if len(.s) > COLS { !error "+credit: a line can be at most 40 characters" }
        !set .pad = (COLS - len(.s)) / 2
        !if .pad > 0 {
                !fill .pad, CHAR_BLANK
        }
        !if len(.s) > 0 {
                !scr .s
        }
        !if COLS - .pad - len(.s) > 0 {
                !fill COLS - .pad - len(.s), CHAR_BLANK
        }
}
