; =============================================================================
; macros.asm - assemble-time helpers for authoring data in data/
; These generate bytes and check data at assemble time. No runtime code.
; =============================================================================

; -----------------------------------------------------------------------------
; Level waves (data/levelN_waves.asm). The level's art is a picture
; (data/levels/levelN.png, tools/png2level.py); a waves file says which
; enemies come when. Rows count char rows from the bottom of the picture, in
; the order they scroll in.
;   +waves_start BOSS_ROW       begin. The boss comes when BOSS_ROW scrolls
;                               in; the rows from there up loop meanwhile.
;   +wave ROW, N                N spawns when ROW scrolls in, each a line of
;   +spawn TYPE, X, PATH        an enemy: type, X (half-X, 0-171), path
;   +waves_end
; Format: per wave, ROW (16 bits), N, then N x (type, x, path); the list ends
; with row $FFFF. The macros check that rows go up, that none is in the
; first SCROLL_ROWS (drawn at once at the start) or at/after the boss row,
; and that every wave has its N spawns.
; -----------------------------------------------------------------------------
SPAWN_LEN = 3                   ; bytes per spawn entry: type, x, path
WAVE_HEAD = 3                   ; bytes before a wave's entries: row, count
WAVE_END  = $ffff
MAX_SPAWNS_PER_ROW = ENEMY_COUNT

!macro waves_start .boss {
        !if (.boss < SCROLL_ROWS) | (.boss >= WAVE_END) { !error "+waves_start: the boss row must come after the first screen" }
        !set WAVE_BOSS = .boss
        !set WAVE_LAST = -1
        !set WAVE_LEFT = 0
}

!macro wave .row, .n {
        !if WAVE_LEFT != 0 { !error "previous +wave is missing +spawn lines" }
        !if .row < SCROLL_ROWS { !error "+wave: no spawns in the first 25 rows (they're on screen at the start)" }
        !if .row <= WAVE_LAST { !error "+wave: rows must go up" }
        !if .row >= WAVE_BOSS { !error "+wave: no spawns from the boss row on (the boss owns the enemy slots)" }
        !if (.n < 1) | (.n > MAX_SPAWNS_PER_ROW) { !error "+wave: 1 to ENEMY_COUNT spawns" }
        !word .row
        !byte .n
        !set WAVE_LAST = .row
        !set WAVE_LEFT = .n
}

; +spawn TYPE, X, PATH : one enemy. X is half-X (0-171): 12-160 is fully on
; screen, 0 / 171 start just off the left / right edge (for side-entry paths).
!macro spawn .type, .x, .path {
        !if WAVE_LEFT <= 0 { !error "+spawn without a matching +wave count" }
        !if .type >= ENEMY_TYPES { !error "+spawn: unknown enemy type" }
        !if .x > ENEMY_X_KILL - 1 { !error "+spawn: x must be 0-171 (half-X)" }
        !if .path >= PATH_COUNT { !error "+spawn: unknown path" }
        !byte .type, .x, .path
        !set WAVE_LEFT = WAVE_LEFT - 1
}

!macro waves_end {
        !if WAVE_LEFT != 0 { !error "the last +wave is missing +spawn lines" }
        !word WAVE_END
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
