# NOT 1942 DX by JDC

**NOT 1942 DX** (by JDC) is a remake of NOT 1942 (v1.1, repo `~/projects/shooter64`), a 1942-style vertically scrolling shoot-'em-up for the Commodore 64, written in 6502 assembly with ACME. DX keeps the game (4 levels, bosses, waves, music, controls) and replaces the engine: smooth 1-pixel scrolling, a sprite multiplexer, scrolling colour RAM and much richer graphics.

There are two build targets:
- **Stock** (the main build): a stock PAL C64 at 1 MHz (312 lines × 63 cycles = 19656 cycles per frame). Never rely on warp or turbo.
- **Turbo** (Phase 3, later): `-DTURBO=1`, for the MiSTer C64 core's turbo modes. See "MiSTer turbo" below.

The approved plan, with the milestones, is in `PLAN.md`.

## Build and run

```bash
make            # build/not1942dx-dev.prg (+ .sym symbols, .lst listing), uncompressed
make crunch     # build/not1942dx.prg: exomizer self-extracting version
make d64        # build/not1942dx.d64 with the compressed program (file "NOT 1942 DX")
make run        # x64sc, PAL, warp off, uncompressed PRG injected into RAM
make run-d64    # boot the disk image like a real C64 (load, unpack, run)
make crt        # build/not1942dx.crt: Magic Desk cartridge image (src/crt.asm)
make run-crt    # boot x64sc with the cartridge plugged in
make release    # everything that ships: .d64, compressed .prg, .crt
make gen        # just the level packs (build/gen/levelN.asm), e.g. before a test build
make turbo      # the MiSTer turbo build: build/not1942dx-turbo.{prg,d64,crt}
make run-turbo  # the turbo build in xscpu64 (VICE's 20 MHz SuperCPU), real time
make turbo-profile  # build/not1942dx-turbo-profile.d64: the turbo build with PROFILE, for the MiSTer (MISTER-TEST.md)
make DEBUG=1 run  # red border bar = time spent in the main loop
make clean
```

Tools come from Homebrew: `acme` (0.97), `vice` (x64sc, c1541) and `exomizer` (3.1.2), plus Python 3 with Pillow for the asset tools. The level packs are generated from the level pictures into `build/gen/` by the Makefile; a test build straight from `acme` needs them there, so run `make gen` (or `make`) first. Releases are always the compressed program. Development and the headless tests use the uncompressed one: it's quicker, and its symbols match the listing. The uncompressed program is 49 KB and compresses to about 24 KB (95 blocks), which unpacks in about 5 s on a C64. To check a compressed build, `exomizer desfx` unpacks it in exomizer's own 6502 emulator, and the result must match `build/not1942dx-dev.prg` byte for byte. `src/main.asm` is the game's only ACME entry point. It `!source`s everything else, with paths relative to the repo root. `src/crt.asm` is a second, separate entry point that wraps the finished `build/not1942dx-dev.prg` in a cartridge image.

The cartridge is **Magic Desk** (CRT type 19): 8 KB ROM banks at `$8000`, selected through `$DE00`; writing `$80` there switches the cartridge off.
- **Boot:** bank 0's boot page runs the KERNAL's I/O and screen set-up (`IOINIT`, `RESTOR`, `CINT`), which the game relies on; it never sets `$00` itself. Then a copier in the cassette buffer (`$0340`) copies the uncompressed game page by page to `PRG_LOAD`, switches the cartridge off and jumps to `GAME_ENTRY`. It reaches the title about 1.5 s after power-on.
- **Size:** ACME writes at most 64 KB, which allows 7 banks (57,088 bytes of game). The game uses 7 of them today (49,971 bytes, 7 KB to spare). `crt.asm` stops the build with an error if the game outgrows them.
- **Shared addresses:** `PRG_LOAD` and `GAME_ENTRY` live in `src/defs.asm`, shared by both entry points.
- **Testing a test build as a cartridge:** make a scratch folder with `src` and `data` symlinked to the repo and the test PRG at `build/not1942dx-dev.prg`. Run `acme -f plain -DPRG_SIZE=<bytes> -o t.crt src/crt.asm` there, then `x64sc -cartcrt t.crt`.

## Working agreement

DX is built in milestones (details in `PLAN.md`):
- **Phase 0:** setup (done).
- **Phase 1, the engine:**
  - M1: smooth scroll core (done)
  - M2: sprite multiplexer and software collision (done)
  - M3: floating sprite HUD (done)
  - M4: PNG level pipeline, streamed compressed level maps, sprite sheets (done)
  - M5: graphics effects (done)
- **Phase 2, the content remaster:** M6-M9 for levels 1-4, M10 for balancing and release.
  - M6: level 1 (done): new art with clouds, new player/fighter/leader sprites, boss 1 as a 4-sprite bomber, waves for 6 alive
  - M7: level 2 (done): jungle-coast art, new raider/gunship sprites, boss 2 as a top-view airship, waves for 6 alive; data that doesn't grow moved to DATA3 (`$6000-$6FFF`)
  - M8: level 3 (done): sunset-strait art (cliffs, boats, a lighthouse, gun pits, sunset clouds), new diver sprite, boss 3 as a 4-sprite flying boat, waves for 6 alive
  - M9: level 4 (done): the enemy fleet on a storm sea that moves faster than the ships (`scroll_down` animations), the ace's own sprite, boss 4 as a top-view battleship, waves for 6 alive
  - M10: balancing and release (done): boss HP about 2.7x (14-32 s of steady fire), version DX 1.0, the itch.io page rewritten for DX, release images checked (the compressed PRG unpacks to the dev build byte for byte; the disk image and the cartridge boot to the title)
- **Phase 3, the MiSTer turbo build:** M11-M13.
  - M11: detection and build (done): `make turbo`, turbo detection at boot (`src/turbo.asm`), a "set turbo in the OSD" screen below 2x, the speed on the title
  - M12: turbo features (done): 30-40 extra enemies a level, boss bullet patterns (sweeps, bursts), 10 enemy-bullet slots; the stock build is byte for byte unchanged
  - M13: testing (done): the user checked everything in `MISTER-TEST.md` on a MiSTer (detection in Off / Smart / C128 mode, play at 2x-4x); the turbo build stops with a message on a real C128 (its `$D02F` reads back)
  - M14: parallax clouds (done, checked on the user's MiSTer): a cloud layer drawn with chars, drifting at twice the map's speed (`src/parallax.asm`), turbo build only

After each milestone, make sure it assembles with no errors or warnings, then stop and tell the user what to test in VICE, with likely bugs ranked by severity. Don't start the next milestone until the user says so. Commit only when the user asks.

Until a milestone replaces it, the inherited NOT 1942 code still works as described in the sections below. Update this file as each milestone lands.

### DX design points (decided with the user; ask before changing any of them)

- **Smooth scroll at 1 pixel per frame** (50 px/s, `src/scroll.asm`): the whole screen scrolls, using all 25 screen rows in the 24-row window (lines 55-246) with `$D011` YSCROLL 0-7, so no split is needed. A coarse character-row step every 8 frames flips the A/B double buffer (`$D018`, set by the IRQ together with YSCROLL 0). The back buffer is built in 7 slices (frames f = 1-7; f = 0 only fetches the record, so it can absorb a late colour chase). Colour RAM can't be double-buffered: on the flip frame (f = 7) `scroll_colour` copies `CRAM_SHADOW` into `$D800` row by row just behind the raster (a row's colours are read only on its badline), and rows 23-24 follow right after the flip (`cram_late`). The chase is straight-line code that `chase_gen` writes into BSS at boot. The background is still visual only, with no terrain collision.
- **Colour RAM scrolls**, and each character has its own colour RAM value (`CHAR_COL`, 0-7 + multicolour bit). That gives 3 shared colours plus 1 per character. (M1 fills `CHAR_COL` with the level's single colour; per-character colours arrive with the M4 level format. `-DTEST_CHAR_COL=1` colours chars by code to test the colour scroll.)
- **Sprite multiplexer** (`src/mux.asm`, M2): `NUM_SLOTS` (26; 30 in the turbo build) virtual sprite slots in BSS: `spr_xh`, `spr_y`, `spr_ptr`, `spr_col`, `spr_on` (non-zero = drawn), and the masks `spr_exp` (`$FF` = X+Y expanded) and `spr_mc` (`$FF` = multicolour, 0 = hires). Slots: player 0, player bullets 1-3, enemies and boss parts 4-11, enemy bullets 12-17 (turbo: 12-21), HUD 18-25 (turbo: 22-29) (`SLOT_*`, `*_COUNT` in `src/defs.asm`); slots are never shared, except that medals and boss parts live in enemy slots. Game code writes the slots and never touches the VIC. `mux_build` (end of the frame's logic) sorts them by Y and commits a double-buffered display list; slots wholly in the top border are left out. The frame IRQ writes its first 8 entries and arms raster IRQs (`mux_irq`) for the rest; entry k uses hardware sprite k & 7 and may only reuse it after entry k-8 has finished (else it is dropped that frame). While paused the IRQ keeps showing the last list.
- **Collision is software box tests** (`src/collide.asm`): per-slot boxes (`box_ox/oy/w/h`), tested after all movement, so they match the positions the next frame shows. The player's box is its fuselage and wing roots (smaller than the art); enemy boxes are generous. `$D01E` isn't used.
- **HUD** (`src/hud.asm`, M3): a floating sprite HUD of hires sprites drawn from the charset's font: the score (2 sprites) top left, the ships left as mini icons (1 sprite) top right, the boss's health bar (1 sprite) top centre during a fight, and messages ("BOSS!" for 2 s, "LEVEL CLEAR"; up to 4 sprites, colour-cycling, typed one char per frame) at line 150, below where the bosses fly. The `hud_draw_*`/`hud_show_*` calls write `HUD_BUF` (the text-screen HUD row) and mark shapes dirty; `hud_update` redraws only what changed (at most one score digit a frame, the bar when a block goes). The 8 HUD shapes are blank in `data/sprites.asm` (`PTR_HUD`+). Decided with the user after M1's check: opening the lower border also opens the top one, and a character HUD row beside the fine scroll needs a cycle-exact split that sprite DMA breaks.
- **Levels** are the same 4 as in NOT 1942, remastered. A level is a picture (`data/levels/levelN.png`, see Data authoring); `tools/png2level.py` turns it into packed chars, per-char colours and an LZ-packed char map. The map is unpacked a row at a time as it scrolls in, through a 4 KB ring (`RING`, `src/scroll.asm`), so its length and detail are limited only by 192 chars per level and the packed size. (Planned as 4x4-char blocks; blocks proved too tight for varied art, and the streamed char map packs smaller.) One row is 8 frames, so a level of about 88 s is about 550 rows. The current pictures are NOT 1942's levels, stretched 2:3, which keeps their timing.
- **Effects** (M5): animated level chars and parallax chars (`src/anim.asm`, from each level's animation strip; M9 added chars that scroll faster than the map, for level 4's moving sea), a 6-shape explosion sequence (`expl_ptr`/`expl_col` in `src/enemies.asm`; the player's is X+Y expanded), screen shake (`shake_timer`: the frame IRQ jitters `$D016` xscroll; boss death and player death), fades of the shared colours at level start and end (`src/level.asm`: `fade_*`), and a title with the logo, a "DX" under it (static colours, at the user's request) and an air show of formations flying past (`data/title_shows.asm`). No plane shadows: every shadow is another sprite, and hardware sprite priority would sometimes draw it over its plane.
- **Kept from NOT 1942:**
  - A level is one data stream, and spawns are tied to scroll position. Nothing is random.
  - Bonus medals from shot red leaders.
  - Joystick in port 2 plus WASD and Space, P or RUN/STOP to pause, M on the title for music.
  - 3 lives, one hit kills, 2 s of blinking invulnerability after a respawn, GAME OVER with no continue.
  - A boss at the end of every level, with the shared boss theme.
  - The ending sequence. Its text is the user's own and changes only on request.
- **PAL only.**

### MiSTer turbo (Phase 3)

Taken from the C64_MiSTer core's source (`rtl/fpga64_sid_iec.vhd`, `rtl/video_vicII_656x.vhd`, `c64.sv`):
- **OSD settings:** "Turbo mode: Off / C128 / Smart" and "Turbo speed: 2x / 3x / 4x". Software can't choose the speed.
- **C128 mode:** `$D030` bit 0 switches turbo on and off. Reading `$D030` gives `$FE | bit0`; a stock C64 reads `$FF`.
- **Smart mode:** turbo is always on (except during disk access), and `$D030` reads `$FF`, so only timing can detect it.
- **Only RAM cycles are faster.** I/O accesses (VIC, SID, CIA and **colour RAM**) run at 1 MHz, and badlines and sprite DMA still stall the CPU.

The turbo build must therefore:
- use no cycle-counted code (raster IRQs and polling only)
- keep I/O out of hot loops
- detect turbo at boot (`$D030` probe, then a timed RAM loop), and refuse to start below 2x with a message to set turbo in the OSD

It is not meant for a real C128, whose VIC display breaks at 2 MHz.

How the turbo build does it (M11, `src/turbo.asm`, only assembled with `-DTURBO=1`; the stock build is byte for byte the same without it):
- `turbo_detect` runs at boot, before the IRQs start. First it checks for a real C128 (in C64 mode), whose 2 MHz would pass the test but blank its VIC: its `$D02F` (extra keyboard lines) reads back the low 3 bits written, where a C64 reads `$FF`. On a C128 it shows "use the standard version" and stops, before touching `$D030` (checked in VICE's x128 with `-go64`). Then it writes 0 to `$D030` and reads it back; bit 0 = 0 means the C128-mode register is there, so it writes 1 (turbo on). Then `turbo_measure` times a RAM-only loop (`TURBO_CYCLES`) against CIA1 timer A, which counts at 1 MHz in every mode, and rounds the ratio into `turbo_speed` (1 on a stock C64, 20 on VICE's SuperCPU).
- Below `TURBO_MIN` (2) it shows a screen saying how to set turbo in the OSD, and re-checks both modes about once a second until turbo is on. The title's version text shows the speed ("dx 1.0 turbo 3x"; 10x and up show as "+x").
- The game itself needs no changes to run in turbo: it waits for frames, the multiplexer and the colour chase follow the raster, and nothing counts cycles.
- What the spare time buys (M12). The VIC still shows 8 sprites a line, so the extras spread out down the screen rather than adding to a line:
  - more enemies: `+spawn_turbo` lines and `+wave_turbo` waves in the waves files (see Data authoring), 30-40 a level (119, 124, 121 and 136 in all), at most 7 alive (`check_waves.py --turbo`)
  - boss bullet patterns: `+boss_sweep` (7 shots fanned across, 6 frames apart) and `+boss_burst` (4 aimed shots, 6 frames apart), run by `boss_pat_update` in `src/boss.asm`
  - 10 enemy-bullet slots instead of 6 (`EBULLET_COUNT`), so 30 sprite slots
  - parallax clouds (M14, `src/parallax.asm`): one cloud at a time drifts down at 2 pixels a frame, twice the map's speed, over everything but the sprites. It is drawn with chars, not sprites: 24 chars at the top of the charset (`PARA_CODE`-255; `data/levels.asm` checks no level reaches them) are rebuilt every frame as the map char under each cell ORed with the cloud's pixels (`data/parallax.asm`, from `tools/art/parallax_cloud.py`; its pixels are only '11', its cells' colour RAM white, yellow in level 3). Each frame, first in the border (right after the frame IRQ, so it's done before the raster reaches the picture): `para_restore` puts back the map chars and colours under last frame's cloud (not after a flip: the new front buffer and colour RAM are clean), `para_update` moves it and draws it into the buffer on screen, saving each covered cell. The scroller's slices then copy the cloud chars into the back buffer with the rest of the front, so `para_fixup` (after each slice) puts the saved map chars and their shadow colours back there. TIMING: ~300 cycles a cell drawn, ~20 cells: ~7,600 cycles at 1 MHz, ~3,900 at 2x, done by about line 25 at 2x. Paused, the cloud just stays.
  - Not done: extra particles (more sprites, against the 8-per-line limit).
- Every turbo difference is under `!ifdef TURBO` or `IS_TURBO` (1 in the turbo build), and the stock build must stay byte for byte the same: check it against the last release commit after any turbo change. `python3 tools/check_map.py -D TURBO=1 --emu xscpu64` checks the turbo build's scrolling with the cloud on (it puts the cloud's saved map chars back in its copy before comparing).
- Turbo memory: the code area has ~900 B left, DATA3 28 B (the cloud's strips are there), DATA2 0.5 KB. `src/turbo.asm` (the boot check and its screens) is assembled into the map ring (`RING`, `$7000-$7422`): it runs once at boot, and the first level's map overwrites it.

## Code conventions

These conventions are inherited from NOT 1942 and still hold unless a DX design point above overrides them.


- Annotate the assembly inline, at the density of the existing files. Mark every raster or cycle-budget assumption with `TIMING:`.
- All level, wave, tile and sprite data lives in `data/`, never in `src/`.
- The memory map is the comment block at the top of `src/defs.asm`. Code must stay below `$4000`; the VIC bank is `$4000-$7FFF` (screens, charset, sprites `$5000-$5FFF`, DATA3 `$6000-$6FFF`, and the map's ring buffer `$7000-$7FFF`). Data that doesn't grow (music, sound effects, title, the ending's text, the aim tables) goes in DATA3; waves, bosses and the level packs at `$8000-$CFFF` (DATA2); run-time tables in BSS at `$E000-`. ACME `!if`/`!error` guards in `main.asm` enforce the region limits. Add a guard for any new region.
- The KERNAL and BASIC are banked out (`$01 = $35`). Our IRQ, NMI and BRK vectors sit at `$FFFA-$FFFF`. A flashing border means `brk_trap` caught a stray BRK.
- All object X positions are one byte in 2-pixel units ("half-X"). Only `mux_build` converts them to hardware X and the `$D010` bit. Game code writes the sprite slot tables in BSS (`spr_xh`, `spr_y`, `spr_ptr`, `spr_col`, `spr_exp`, `spr_on`), never the VIC directly.
- The main loop has seven modes (`game_mode`, `GM_*` in `src/defs.asm`): title, level intro, play, GAME OVER, and the ending's victory screen, credits roll and finale. The flow is title → `new_game` → `level_intro_enter` → `level_begin` → play → the boss row → boss → LEVEL CLEAR → next level intro, and after the last level `victory_enter` → roll → finale → title. Losing the last life goes to `gameover_enter` → title. Keys 1-4 on the title start a game at that level with its boss straight away (`new_game_at` with `boss_now` set; `level_begin` clears it, so later levels play normally). Once `boss_flag` is set, `scroll_update` launches no more waves, or the early boss would leave the level's waves frozen in its spare slots: boss practice, and a quick way to check a boss. Pause is a flag (`paused`) inside play, not a mode.
- Per-game state (score, lives, level number) is reset in `new_game`. Per-level state (tiles, palette, sprites, bullets, enemies, stream) is reset in `level_begin`.
- The ending (`src/ending.asm`) uses modes GM_VICTORY, GM_ROLL and GM_FINALE. Its screens are plain hires text ($D016 multicolour off), so colour RAM can use all 16 colours. The credits roll moves with $D011 fine scroll plus the double buffer; the IRQ writes `next_d011` together with the $D018 flip, so the fine-scroll reset and the swap happen in the same instant. `next_d011` must stay 0 everywhere else. The big scroller is a bit-scroller in chars 144-223.
- The ending's show (`src/ending_fx.asm`; decoration only, the text is unchanged): fireworks (rockets in the enemy slots that burst into the explosion sequence, X+Y expanded, one colour each, on a fixed schedule) on the victory and final screens, twinkling stars there (two hires chars, `STAR_CHAR` 224-225, colour RAM cycling), stars scrolling up with the credits roll (`fx_roll_cell` puts them in the blank cells of each new line), the P-38's victory pass, and six P-38s escorting the roll. The victory screen is now black with hires text, like the rest of the ending. `src/ending_fx.asm` is assembled after the sprite shapes, in spare shape space (the code area below `$4000` is full in the turbo build): code may live there, before `SPRITES_END`.
- Mode switches happen at the top of the main loop, in the lower border: player game over, and `lvl_state = LS_NEXT`. Screens that rewrite both buffers turn the display off while they do it.
- The score is 3 BCD bytes (`score_hi`/`mid`/`lo`, adjacent). Adds run with `SED`, which is why the IRQ handler starts with `CLD`.
- The main loop does border work first, right after the IRQ at line 251: `scroll_update`. Then the logic, which only touches shadow state: input, player, bullets, enemies, boss, enemy bullets, `collisions`, `level_update`, `hud_update`, and last `mux_build`. The frame ends with `scroll_colour` (the colour chase on flip frames, which waits for the raster on purpose); it also runs after `pause_enter`.
- The RAM under the KERNAL (`$E000-`) holds run-time tables (BSS, `src/bss.asm`): sprite slots, multiplexer lists, enemies, enemy bullets, boss parts, and the generated colour-chase code. Nothing is loaded there; `init_system` clears it. Declare new tables there with `name = BSS_PTR : +bss SIZE`. IRQ code (frame IRQ, `mux_irq`, music, effects) uses only its own zero page (`mux_s_*`, `mux_next`, `mux_d010`, ...), never `zp_tmp*`/`zp_ptr*`.
- A slot is active exactly when its `spr_on` byte is non-zero. Whatever frees an enemy slot must also leave its `en_state` at 0. A stale `EN_MEDAL` once let shots pass through boss parts.
- Screen buffers A and B are double-buffered, and the IRQ flips `$D018`. In play every row scrolls; sprite pointers (`$x3F8`, outside the 25 rows) go into both buffers. Static screens use row 0 for the text HUD (`hud_flush`); in play the sprite HUD shows the same information. Pause prints "PAUSED" straight into the front buffer and restores the chars and colours on resume (`src/pause.asm`).
- `$D011` in play belongs to the IRQ: it writes `scroll_d011` every frame while that is non-zero. `video_off` and `init_video` zero it first, or the IRQ would switch the display back on. Static screens use `D011_TEXT` (25 rows, yscroll 3).
- Low RAM `$0200-$07FF` holds `HUD_BUF`, `CHAR_COL` and `CRAM_SHADOW` (memory map in `src/defs.asm`).

## Data authoring

Macros in `src/macros.asm` turn readable text into bytes and check it at assemble time; the asset tools in `tools/` turn pictures into data.
- **Level pictures** are `data/levels/levelN.png` with `levelN.json` (`png`, `label`, the shared colours `bg`/`mc1`/`mc2` by name or number, and `boss_row`). A picture is multicolour, 160 pixels wide (or 320 with every pixel doubled; each pixel is one double-wide C64 pixel), and any whole number of char rows tall. It is the level as you see it: the game starts at the BOTTOM and scrolls up, so char row 0 is the bottom row. When `boss_row` scrolls in the boss comes, and the rows from there to the top repeat until it is beaten, so that part must join up with itself. Each 4x8-pixel char cell may use bg, mc1, mc2 and ONE colour of its own, 0-7 (colour RAM); at most 192 different cells per level. `tools/png2level.py` checks all this and names the offending cell. The Makefile runs it into `build/gen/levelN.asm` (`levelN_chars_lz`, `_cols_lz`, `_map_lz`, `_loop_lz` and `LEVELN_ROWS`, `_BOSS_ROW`, `_BG`, `_MC1`, `_MC2`). All four levels' pictures, animation strips and JSON were drawn by `tools/art/level1_art.py` to `level4_art.py` (a starting point: the PNG is the master copy, and running the script again overwrites hand edits). Packed size is the art's real limit: repeat things (a periodic texture, the same cloud shapes at char positions) so the LZ packer finds them again.
- **Animation strips** (optional): `data/levels/levelN_anim.png`, named in the JSON as `"anim": {"png": ..., "rows": [{"frames": N, "delay": D}, {"mode": "scroll", "delay": D}, ...]}`. Strip row r is animation r: cell 0 must be a char of the level picture, cells 1.. are its other frames (same width and colour rules; all frames of one char share its own colour). The game rewrites that char every D frames, so every copy of it on screen animates at once; `scroll` instead rotates its rows up one pixel every D frames (D = 1 holds the texture still on screen, D = 2 moves it at half the map's speed: parallax), and `scroll_down` rotates them down (D = 2: 1.5 pixels a frame, faster than the map, so things drawn on the map seem to move forward through it). Scrolling chars all start in step; a texture made of several must have no more of them than are rewritten per frame (2), or it tears. Up to 16 per level; at most 2 are rewritten per frame.
- **The level table** is `data/levels.asm`: one column per level, giving its packs, rows, boss row, waves, palette, song, boss and name.
- **Waves** are `data/levelN_waves.asm`: `+waves_start LEVELN_BOSS_ROW`, then `+wave ROW, N` followed by N lines of `+spawn E_TYPE, X, P_PATH`, then `+waves_end`. ROW counts char rows of the picture from the bottom (the order they scroll in); the first 25 are on screen at the start and can't spawn, rows must go up, and nothing may spawn from the boss row on. The macros enforce all of this. The "rN" comments are NOT 1942's record numbers.
- **Checking a level:** `python3 tools/check_map.py [N]` runs the game headless and compares the scrolled screen with the picture, row by row, into the boss loop. `python3 tools/check_waves.py data/levelN_waves.asm` checks the enemy budget (it reads the boss row from the JSON).
- **Packing:** the LZ format is documented in `tools/c64gfx.py` (`lz_pack`, and the Python `lz_unpack` every pack is checked against); `src/unpack.asm` unpacks the chars and colours at level start, and `st_byte` in `src/scroll.asm` streams the map.
- **Turbo extras** in a waves file: `+wave_t ROW, N, NT` is a wave of N `+spawn` lines plus NT `+spawn_turbo` lines (the extra ones only in the turbo build); `+wave_turbo ROW, N` is a wave of N `+spawn_turbo` lines that exists only in the turbo build. The turbo build may peak at 7 alive; check it with `python3 tools/check_waves.py --turbo data/levelN_waves.asm`, then with a DEBUG turbo build on xscpu64 (spawn_drops 0) and `tools/profile.py -D TURBO=1 --emu xscpu64` (drops 0). Boss scripts' `+boss_sweep` / `+boss_burst` are the turbo patterns (stock: `+boss_spread` / `+boss_fire`); `IS_TURBO` lets a gun or a count differ by build.
- **Enemy budget:** at most `ENEMY_COUNT` (8) enemies may be alive at once; NOT 1942's waves peak at 3, remastered levels at 6. Keep peaks at 6: `check_waves.py` doesn't count medals (they take enemy slots too), and more enemies cost CPU (~300 cycles a sprite, see `BUDGET.MD`). Formations: don't put 4 or more planes on the same lines (a line abreast): with their shots and the player's that is more than 8 sprites in one band, and the multiplexer drops some. Use echelons, strings (one path, one row apart) and V's with two rows between ranks. Planes enter at the top, beside the HUD, which holds 3 hardware sprites there (4 in a boss fight): no more than 4 planes should enter together (a player bullet often flies up there too). When all slots are busy, a spawn is dropped, and the waves would then depend on the player's kill speed. After editing any wave or path, run `python3 tools/check_waves.py data/levelN.asm`. It replays every path exactly like `enemies.asm` and fails if a spawn would need more slots (each enemy counts 12 extra frames, for an explosion). Then confirm with a DEBUG build and no firing (`-DDEBUG -DAUTOSTART -DINVINCIBLE`): `spawn_drops` must stay 0 until the boss arrives (read it with the remote monitor, see below; it also shows as the hex digit at the right end of the HUD on the next text screen).
- **Level length:** one row is 8 frames. All four levels are 588 rows (551 rows of waves, about 88 s; 89, 90, 83 and 96 enemies), followed by their boss. A full playthrough is about 7 minutes.
- **Memory:** the PRG loads up to `$CBxx` (past `$A000`, under BASIC ROM), which works with `LOAD` and `RUN`. Compressed, the game is about 95 blocks. A level costs its packed chars, colours and map (4.8 KB for remastered level 1, 4.1 KB for level 2, 4.0 KB for level 3, 2.1 KB for level 4, whose sea rows are all the same) plus its waves (~0.5 KB); a song about 0.4 KB. Keep an eye on `code_end`, `data2_end` and `bss_end` in `build/not1942dx-dev.sym`. `BUDGET.MD` has the measured CPU, memory and data budgets, and how to re-measure them; update it when a change moves them noticeably. As of M9, about 1.9 KB is free after the code, 1.2 KB in DATA2, 0.3 KB in DATA3, 0.8 KB of BSS, and 25 sprite shapes (64 in all).
- **Bosses** are listed in `data/bosses.asm`, with columns for a part list, colour, width, start X, HP, HP per HUD bar block, phase-2 HP threshold, and two scripts. A part list is `+boss_parts N` then N lines of `+boss_part SHAPE, DX, DY` (up to `BOSS_MAX_PARTS` = 6 X+Y expanded sprites, each 24 half-X x 42 px, at offsets from part 0, which may be negative; e.g. a 2x3 grid uses DY 0 and 42). A part is hit anywhere in its sprite; `+boss_part_box SHAPE, DX, DY, OX, OY, W, H` gives a mostly empty part a smaller hit box instead. Part 0 flies the script, so script Y, guns and the X clamp are all measured from its top-left: make it the part at the picture's left edge. Every part costs ~300 cycles a frame: boss 1 is a 3x2 picture whose top row holds only the tail, so it is 4 sprites (6 overran with shots out). A boss's lower sprite row must start below line 68, where the HUD's 4 hardware sprites are free again (boss 1's script checks this at assembly). Scripts use the path format (below) plus `+boss_fire DX, DY` (an aimed shot) and `+boss_spread DX, DY` (a V of two shots), where DX/DY is the gun's offset from part 0's top-left. Expanded art pixel (column c, row r) sits at (2c, 2r); a gun under column c is DX = 2c - 6. Phase-2 scripts have no `+path_start`. `lvl_t_boss` in `data/levels.asm` picks each level's boss.
- **Boss engine** (`src/boss.asm`): part 0 (enemy slot 0) runs the script through `enemy_step`; the other parts follow at their offsets (`boss_follow`). X is clamped to keep the boss's width (`boss_t_w`) on screen. While `boss_state` is non-zero, `enemies_update` leaves the enemy slots alone. When a boss dies, all enemy shots vanish (`init_ebullets`). During the fight, `collide_boss_boxes` gives the parts expanded-size boxes.
- **Enemy types and paths** live in `data/waves.asm`. The climbing paths (`P_RISE`, `_R`, `_L`) start at line 244, just inside the bottom of the window: an enemy at `PLAY_Y_END` (247) or below is removed, so a path that starts lower never flies (before this was fixed, the attacks from behind never appeared). A path is `+path_start Y`, then `+seg DX, DY, FRAMES` lines, ending in `+seg_end` (hold the last velocity) or `+seg_loop LABEL`. `+seg_fire` between segments fires one shot aimed at the player; the shot is skipped if both enemy-bullet slots are busy or the enemy is off screen. DX is in half-X units per frame; fractions are stored as 8.8 fixed point.
- **Explosions** run the 6-shape sequence (`spr_expl_1`, `_2`, `expl_b`, `_4`, `_5`, `_6` in `data/sprites.asm`; colours in `expl_col`): enemies 3 frames a shape (`EXPL_FRAMES` = 18, which `tools/check_waves.py` counts as `MARGIN`), the player 4, boss parts 4 with each part two shapes on from its neighbour.
- **Sprites** use 21 rows of `+spr "............"`, wrapped in `+spr_begin` and `+spr_end` (`data/sprites.asm`; up to 64 shapes, `$5000-$5FFF`). `tools/png2sprites.py sheet.json out.asm` turns a sprite sheet PNG (12x21-pixel cells; transparent, white, dark grey and one own colour per sprite) into that format, and `--export data/sprites.asm sheet.png sheet.json` makes a sheet of the existing sprites to repaint.
- **Title air show** in `data/title_shows.asm`: formations fly past the title on the game's own paths, one display after another, looping. `+title_wave WAIT, N` then N `+spawn` lines: the group spawns WAIT frames after the previous one (a V's wings a few frames behind its point, a string one plane after another; a long WAIT starts the next display). `title_flyby` (`src/title.asm`) hands each group to `enemies_spawn` and flies them with `enemies_update`; enemies don't fire outside play (`enemy_fire_at`, `enemy_spread`). `E_P38` is a friendly P-38 for the show. At most `ENEMY_COUNT` planes may be up at once.
- **Title logo** in `data/title.asm` is pixel art, one `+logo_px "#..#"` per pixel row. Every two rows become one screen row of 2x2 block characters (codes 128-143, defined in `data/tiles.asm`). `LOGO_H` in `src/title.asm` must match the row count / 2.
- **Music** lives in `data/music.asm`, played by `src/music.asm` from the frame IRQ (one tick per frame), so the main code must never touch the `mv_*`/`music_*` zero page.
  - There are six songs: the title song (`data/music_title.asm`), one per level (`data/music.asm` for level 1, `data/music_level2.asm` to `music_level4.asm`) and the boss theme (`data/music_boss.asm`). `data/songs.asm` holds the song table, and `lvl_t_song` picks each level's song. `music_start` with `SONG_*` in A switches songs; it's safe while the IRQ runs. Instruments are shared, in `data/music.asm`.
  - Each song begins with `+tempo F` (frames per 16th note), which sets the `L*` lengths and `BAR` for that song.
  - Notes are written tracker-style: `+n "A#4", L8`. Use sharps only.
  - Patterns sit between `+pat_start` and `+pat_end`, with `+bar` after each bar. Voices play order lists of `+ord PATTERN, PATTERN_TICKS`.
  - The assembler rejects bad note names, bars that don't add up, and voices with different loop lengths.
  - Sound effects are in `data/sfx.asm`, played by `src/sfx.asm` from the same IRQ. An effect is a list of `+boom FRAME, VOICE, WAVE, FREQ, AD, SR, SLIDE` lines. In-game effects use only voice 3, which is the drums in every in-game song. While one plays, `voice_reg+2` points at `VOICE_MUTED` (SID registers that ignore writes), so the music keeps its timing on voice 3 without sounding. `+sfx_end FRAME` ends the effect, and `music_voice3_back` rebuilds voice 3 from shadows, so a covered drum hit plays late rather than never. Keep in-game effects short, since the drums are out meanwhile. Effects that use voices 1-2 as well (only the boss explosion) must start with the music stopped. One effect plays at a time; `sfx_table_prio` decides whether a new one may replace it. `music_start`/`music_stop` cancel a running effect. To check an effect alone, build with `-DTEST_SFX=n` (plays effect n every 64 frames during play) and `-DMUSIC_SOLO=4` (no voice matches, so the music is silent but still running), and record a WAV.
  - To check a song's notes, record it, align on all notes (not just the first few: a few frames off makes notes a semitone apart look wrong) and pitch-check each note. `-DMUSIC_SOLO=n` plays only voice n, to tell a wrong note from a masked one.
  - To verify headless, record with `-sounddev wav -soundarg <file> +warp`. VICE writes no audio in warp mode.

## Verifying without the user

**Turbo stand-in:** VICE's SuperCPU emulator, `xscpu64` (a 20 MHz CPU with the C64's VIC, SID and CIAs, so like the MiSTer's turbo, only faster), runs the turbo build: `tools/vicemon.py`'s `start(prg, emu="xscpu64")`, and `python3 tools/profile.py -D TURBO=1 --emu xscpu64`. The MiSTer's C128-mode register can't be tried in VICE; that, and the real speeds, are for the user's hardware.

**Profiling:** `python3 tools/profile.py [--level N] [--boss]` builds a PROFILE test build, runs the whole game headless and prints, per level and ending part, the worst play frame, the worst frame of any kind, the frame IRQ, overruns (`play_over` must be 0), late colour chases (harmless), the most sprites in one frame and dropped sprites (must be 0). It stops at each `prof_reset` through VICE's remote monitor (`tools/vicemon.py`), so it needs no screenshot timing.

**Frame-exact screenshots:** separate VICE runs are *not* frame-deterministic (autostart timing varies), so screenshots from two runs can't be compared. To compare frames, use one run and the remote monitor: `tools/vicemon.py` (`start()`, `Mon().cmd(...)`) can set `break` on a symbol from the ACME `-l` list, continue with `x`, and save `screenshot "file.png" 2`. A breakpoint on `irq_handler` stops once per frame; break on `main_loop`, not on `wait_frame` (its first instruction is the polling loop). Peek memory with `Mon().peek(addr, n)`.

VICE can also run headless and save one screenshot at exit:

```bash
x64sc -default -pal -warp -sound +confirmonexit -autostartprgmode 1 \
  -limitcycles 8000000 -exitscreenshot <scratch>/shot.png -autostart build/not1942dx-dev.prg
```

Exit code 1 ("cycle limit reached") is expected. PAL runs at 985248 cycles per second, so two shots one second apart check timing.

Test builds use options that are only ever passed to ACME on the command line, from the repo root. For example: `acme -f cbm -DFORCE_INPUT=<bits> -o <scratch>/t.prg src/main.asm`. Every option needs a value: write `-DBOSS_TEST=1`, not `-DBOSS_TEST`. Keep test builds out of `build/`, and never set any of these options in the Makefile.
- **Input:**
  - `FORCE_INPUT=bits` holds inputs down forever. The bits use the joystick layout: 1 up, 2 down, 4 left, 8 right, 16 fire. Fire triggers on the press, so holding it fires nothing.
  - `FORCE_TAP=mask` presses fire whenever `frame_count & mask` is non-zero; `4` taps every 8 frames.
  - `TEST_KEYS=bits` with `TEST_KEYS_MASK=mask` does the same for any input bits, so they are pressed once every 2 × mask frames: 32 is pause, 64 is M.
- **Flow:**
  - `AUTOSTART` skips the title screen. Without it, a test build needs `FORCE_TAP` to get past the title.
  - `START_LEVEL=n` starts at level n (1-4).
  - `BOSS_TEST` brings the boss straight away when a level starts.
  - `INVINCIBLE` means the player is never hit, for running through levels. Its collision tests still run, so profiles count them; touching a medal collects it.
- **Bug reproductions:**
  - `TEST_STALE_MEDAL`: enemy slots start as stale medals; pair it with `BOSS_TEST`.
  - `TEST_DIE_ON_CLEAR=n`: the player is shot down with n ships left, 40 frames before LEVEL CLEAR ends.
- **Sound:** `TEST_SFX=n` plays effect n every 64 frames during play. `MUSIC_SOLO=n` plays only music voice n; 4 silences the music while it keeps running.
- **Turbo:** `TURBO_MIN_TEST=1` (with `TURBO=1`) lets the turbo build run at 1 MHz, in x64sc, to time it there (it overruns: the timings are for scaling).
- **Timing:**
  - `DEBUG` adds a red border bar for main-loop time, plus the dropped-spawn digit.
  - `PROFILE` shows exact worst-case cycle counts in the HUD, from CIA1 timer A, all in hex:

    | HUD columns | Value |
    |---|---|
    | 20-21 | Most sprites in one frame's display list |
    | 22-23 | Sprites the multiplexer dropped (low byte of the total) |
    | 25-28 | IRQ start to the end of the frame's work |
    | 30-32 | The IRQ alone |
    | 34-35 | Number of overrun frames |
    | 38-39 | `game_mode`/`lvl_state` at the last overrun |

    The counts reset at each level, the victory screen, the roll and the finale. In play the HUD isn't on screen, so the digits show on the next text screen; `tools/profile.py` reads them (and `prof_play`, `prof_over_play`, `prof_late`) directly. See `BUDGET.MD`.
- **Colour:** `TEST_CHAR_COL` gives each char the colour RAM value (code & 7) + multicolour, so a colour RAM row that doesn't match its screen row shows at once.
