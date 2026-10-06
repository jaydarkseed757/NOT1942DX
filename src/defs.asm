; =============================================================================
; defs.asm - hardware registers, memory map, and global constants
; =============================================================================
;
; MEMORY MAP (stock C64, BASIC + KERNAL banked out after init, $01 = $35)
; -----------------------------------------------------------------------------
;   $0002-$00FF  zero page: game variables (see zp.asm). KERNAL is banked out,
;                so we own all of it except $00/$01 (CPU port).
;   $0100-$01FF  6502 stack
;   $0801-$080C  BASIC stub "10 SYS 2064"
;   $0200-$07FF  low RAM (the KERNAL work areas and default screen are unused):
;   $0200-$0227  HUD_BUF   - the HUD's 40 screen codes (hud.asm)
;   $0300-$03FF  CHAR_COL  - colour RAM value for each char code (scroll.asm)
;   $0400-$07E7  CRAM_SHADOW - colour RAM for the screen being built
;                (scroll.asm)
;   $0810-$3FFF  code, plus the ending text (code_end in build/not1942dx-dev.sym)
;
;   ---- VIC bank 1 ($4000-$7FFF): no character-ROM shadow in this bank ----
;   $4000-$43FF  SCREEN_A  - screen buffer A (+ sprite pointers at $43F8)
;   $4400-$47FF  SCREEN_B  - screen buffer B (+ sprite pointers at $47F8)
;                Double-buffered: the scroller builds the hidden buffer and
;                the raster IRQ flips $D018 during the lower border.
;   $4800-$4FFF  CHARSET   - 256 chars:
;                  chars   0-63  : font, copied from character ROM at boot
;                  chars  64-255 : in play, the level's chars (unpacked at
;                                  level start, up to 192)
;                  chars 128-143 : on the title and text screens, the logo's
;                                  2x2 block quadrants (restore_quads)
;                  chars 144-223 : in the ending, its big scroller strip
;   $5000-$5FFF  SPRITES   - 64 sprite shapes x 64 bytes (pointers $40-$7F)
;   $6000-$6FFF  DATA3     - music, songs, sound effects, title screen data,
;                            the ending's text, the aiming tables: data that
;                            doesn't grow (the VIC never looks there)
;   $7000-$7FFF  RING      - the level map's last 4 KB, unpacked a row at a
;                            time as it scrolls in (CPU-only; not loaded)
;
;   $8000-$CFFF  DATA2     - waves, bosses, the level packs (20 KB)
;   $D000-$DFFF  I/O (VIC, SID, colour RAM, CIAs)
;   $E000-$FFFF  RAM under KERNAL; we put our IRQ/NMI vectors at $FFFA-$FFFF.
;   $E000-       BSS: run-time tables (sprite slots, multiplexer lists,
;                enemies, bullets, the generated colour-chase code;
;                src/bss.asm). Nothing is loaded there: init_system clears
;                it at boot. A plain LOAD can't fill
;                $D000-$FFF9 (I/O sits at $D000), but the exomizer unpacker
;                could.
;
; COLOUR RAM
;   Colour RAM ($D800) can't be double-buffered. In play it scrolls with the
;   screen anyway: every char code has its own colour RAM value (CHAR_COL),
;   the scroller builds the next screen's colours in CRAM_SHADOW alongside
;   the hidden screen buffer, and copies them into $D800 row by row just
;   behind the raster on the last frame before the flip (scroll.asm).
;   Playfield chars are multicolour: two colours come from $D022 and $D023
;   (shared), plus each char's own colour RAM colour (0-7).
;   The static screens (title, intro, GAME OVER, ending) set colour RAM
;   directly; their row 0 is the HUD in hires chars (colour RAM < 8).
; =============================================================================

; ---- VIC-II ----
SPR0_X      = $d000         ; sprite n X = $d000 + 2n, Y = $d001 + 2n
SPR0_Y      = $d001
SPR_XMSB    = $d010
VIC_CTRL1   = $d011         ; bit7 = raster bit 8, bit4 = screen on, bits0-2 yscroll
VIC_RASTER  = $d012
VIC_D030    = $d030         ; MiSTer C128 turbo mode: bit 0 = turbo (turbo.asm)
SPR_ENABLE  = $d015
VIC_CTRL2   = $d016         ; bit4 = multicolour, bit3 = 40 columns
SPR_YEXP    = $d017
VIC_MEM     = $d018         ; screen / charset pointers inside the VIC bank
VIC_IRQ     = $d019         ; IRQ latch (write 1 to ack)
VIC_IRQEN   = $d01a
SPR_PRIO    = $d01b
SPR_MCOL    = $d01c
SPR_XEXP    = $d01d
SPR_SPRCOLL = $d01e         ; sprite-sprite collision latch (cleared on read)
SPR_BGCOLL  = $d01f
BORDER      = $d020
BGCOL0      = $d021
BGCOL1      = $d022         ; multicolour char colour %01
BGCOL2      = $d023         ; multicolour char colour %10
SPR_MC0     = $d025
SPR_MC1     = $d026
SPR0_COL    = $d027

COLRAM      = $d800

; ---- CIA 1 (keyboard / joystick / IRQ) ----
CIA1_PRA    = $dc00         ; joystick port 2 (read) / keyboard column select
CIA1_PRB    = $dc01         ; keyboard row read / joystick port 1
CIA1_DDRA   = $dc02
CIA1_DDRB   = $dc03
CIA1_TALO   = $dc04         ; timer A (counts down; only the PROFILE test
CIA1_TAHI   = $dc05         ;   hook uses it)
CIA1_ICR    = $dc0d
CIA1_CRA    = $dc0e

; ---- CIA 2 (VIC bank select / NMI) ----
CIA2_PRA    = $dd00         ; bits0-1: VIC bank (inverted)
CIA2_DDRA   = $dd02
CIA2_ICR    = $dd0d

; ---- program layout (shared by main.asm and the cartridge, crt.asm) ----
PRG_LOAD    = $0801         ; load address: BASIC stub "10 SYS 2064"
GAME_ENTRY  = $0810         ; = 2064, where the stub's SYS jumps

; ---- CPU port ----
CPU_DDR     = $00
CPU_PORT    = $01
MAP_ALLRAM_IO = $35         ; RAM everywhere except I/O at $D000
MAP_CHARROM   = $33         ; BASIC + KERNAL + char ROM at $D000 (boot only)

; ---- memory layout (see map above) ----
VIC_BASE    = $4000
SCREEN_A    = $4000
SCREEN_B    = $4400
CHARSET     = $4800
SPRITES     = $5000
SPRITES_END = $6000         ; 64 shapes; the rest of the bank's free RAM is
DATA3_BASE  = $6000         ;   DATA3
RING        = $7000         ; 4 KB aligned: the unpacker wraps on the high byte
RING_SIZE   = $1000
DATA2_BASE  = $8000
DATA2_END   = $d000             ; I/O starts here; a PRG can't load past it

SPRPTR_OFS  = $03f8                     ; sprite pointers live at screen + $3F8
SPR_PTR0    = (SPRITES - VIC_BASE) / 64 ; first sprite pointer value ($40)

FIRST_TILE  = 64                        ; first level char (after the font)
CHAR_BLANK  = 32                        ; ROM font space = all zero bits

; $DD00 value bits 0-1 for VIC bank 1 ($4000): %10
VIC_BANK_BITS = %00000010

; $D018 values: bits 7-4 screen offset / $400, bits 3-1 charset offset / $800
D018_A = (((SCREEN_A - VIC_BASE) / $400) << 4) | (((CHARSET - VIC_BASE) / $800) << 1)
D018_B = (((SCREEN_B - VIC_BASE) / $400) << 4) | (((CHARSET - VIC_BASE) / $800) << 1)

; ---- screen geometry ----
COLS        = 40
ROWS        = 25
HUD_ROW     = 0             ; static screens: row 0 shows the HUD (hud_flush)
PLAY_TOP    = 1             ; static screens: rows 1-24 below the HUD
PLAY_ROWS   = 24
SCROLL_ROWS = ROWS          ; in play all 25 rows scroll (24-row window)
CHASE_ROWS  = SCROLL_ROWS - 2   ; colour rows the chase copies (scroll.asm);
                                ;   rows 23-24 wait for the next frame
CHASE_CODE_SIZE = CHASE_ROWS * (5 + COLS * 6) + 1 ; its generated code

; ---- RAM under the KERNAL: run-time tables (src/bss.asm), never loaded ----
BSS         = $e000
BSS_END     = $fffa         ; the CPU vectors start here

; ---- low RAM (see the memory map) ----
HUD_BUF     = $0200
CHAR_COL    = $0300         ; page aligned: CHAR_COL,x never crosses a page
CRAM_SHADOW = $0400

; ---- colours ----
COL_BLACK   = 0
COL_WHITE   = 1
COL_RED     = 2
COL_CYAN    = 3
COL_PURPLE  = 4
COL_GREEN   = 5
COL_BLUE    = 6
COL_YELLOW  = 7
COL_ORANGE  = 8
COL_BROWN   = 9
COL_LRED    = 10
COL_DGREY   = 11
COL_GREY    = 12
COL_LGREEN  = 13
COL_LBLUE   = 14
COL_LGREY   = 15

; The title screen's palette (each level's is in data/levels/levelN.json):
; $D021, $D022, $D023. Every char has its own colour RAM colour (CHAR_COL).
PAL_OCEAN   = COL_BLUE
PAL_MC1     = COL_LGREEN
PAL_MC2     = COL_BROWN
CRAM_HUD    = COL_WHITE     ; < 8 = hires char

; ---- raster timing (PAL: 312 lines, 63 cycles/line, 19656 cycles/frame) ----
; TIMING: static screens show 25 rows (lines 51-250, yscroll 3). Play uses
; the 24-row window (lines 55-246) with yscroll 0-7 (scroll.asm). Line 251
; is below both, so the frame IRQ fires there. We flip $D018, set the fine
; scroll and start the frame's work in the lower border, before the next
; frame's first visible line. That gives about 112 lines (~7000 cycles) of
; off-screen time.
IRQ_LINE    = 251

; $D011 values
D011_TEXT   = %00011011     ; display on, 25 rows, yscroll 3 (static screens)
D011_OFF    = %00001011     ; display off, otherwise as D011_TEXT
D011_PLAY   = %00010000     ; display on, 24 rows; OR in the fine scroll 0-7

; ---- game modes ----
GM_PLAY       = 0
GM_OVER       = 1
GM_TITLE      = 2
GM_INTRO      = 3               ; "LEVEL n / GET READY"
GM_VICTORY    = 4               ; ending, part 1 (ending.asm)
GM_ROLL       = 5               ; ending, part 2: credits roll
GM_FINALE     = 6               ; ending, part 3: big scroll text

; ---- virtual sprite slots (src/mux.asm shows them on the 8 hardware sprites) ----
; Each slot belongs to one kind of object and is never shared (exceptions:
; medals and boss parts live in enemy slots). A slot is drawn when its
; spr_on byte is non-zero.
SLOT_PLAYER   = 0
SLOT_PBULLET0 = 1           ; player bullets: slots 1-3
PBULLET_COUNT = 3
SLOT_ENEMY0   = SLOT_PBULLET0 + PBULLET_COUNT   ; enemies / boss parts: 4-11
ENEMY_COUNT   = 8
SLOT_EBULLET0 = SLOT_ENEMY0 + ENEMY_COUNT       ; enemy bullets: 12-17
EBULLET_COUNT = 6
SLOT_HUD0     = SLOT_EBULLET0 + EBULLET_COUNT   ; the sprite HUD: 18-25
SLOT_HUD_SCORE = SLOT_HUD0                      ;   score, 2 sprites
SLOT_HUD_LIVES = SLOT_HUD0 + 2                  ;   lives
SLOT_HUD_BAR  = SLOT_HUD0 + 3                   ;   boss health bar
SLOT_HUD_MSG  = SLOT_HUD0 + 4                   ;   message, 4 sprites
HUD_SLOTS     = 8
NUM_SLOTS     = SLOT_HUD0 + HUD_SLOTS           ; 26
ANIM_MAX      = 16          ; animated chars per level (anim.asm)
MUX_PIN       = 4           ; the top HUD (score, lives, bar): pinned
                            ;   entries 0-3 of the multiplexer's lists
!if SLOT_HUD_BAR != SLOT_HUD0 + 3 | SLOT_HUD_MSG != SLOT_HUD0 + MUX_PIN { !error "the pinned HUD slots must be SLOT_HUD0..+3" }
MUX_LIST      = 32          ; display list entries per buffer (>= NUM_SLOTS,
                            ;   a multiple of 8: entry k uses hw sprite k & 7)
BOSS_MAX_PARTS = 6          ; a boss is up to 6 sprites (in the enemy slots)
!if MUX_LIST < NUM_SLOTS | MUX_LIST % 8 != 0 { !error "MUX_LIST must be >= NUM_SLOTS and a multiple of 8" }
!if BOSS_MAX_PARTS > ENEMY_COUNT { !error "boss parts live in the enemy slots" }

; Shared sprite multicolours (every multicolour sprite uses these two)
SPR_SHARED1   = COL_WHITE   ; pixel 'w' -> $D025
SPR_SHARED2   = COL_DGREY   ; pixel 'd' -> $D026
COL_PLAYER    = COL_LGREY   ; pixel 'i' for the player ship
COL_PBULLET   = COL_YELLOW  ; pixel 'i' for player bullets
                            ; enemy colours: etype_col in data/waves.asm
COL_EBULLET   = COL_LRED    ; pixel 'i' for enemy bullets
COL_EXPLOSION = COL_YELLOW  ; pixel 'i' for explosions (enemies and player)
COL_MEDAL     = COL_YELLOW  ; pixel 'i' for the bonus medal (gold)

; ---- coordinate system ----
; All object X positions are stored in 2-pixel units ("half-X", one byte).
; Hardware X = half-X * 2, and the carry from that ASL becomes the $D010 bit.
; MC sprite pixels are 2 pixels wide anyway, so nothing is lost.
; Y is the raster line of the sprite's top row (1-pixel units).
;
; TIMING/GEOMETRY (PAL, 24-row window, 40 cols): the visible playfield is
; hardware X 24-343, Y 55-246.
SCREEN_X_MIN  = 24 / 2      ; half-X of the left edge of the text area (12)
SCREEN_X_MAX  = 344 / 2     ; half-X just past the right edge (172)
PLAY_Y_MIN    = 55          ; first visible playfield raster line
PLAY_Y_END    = 247         ; first raster line below the playfield
