# NOT 1942 DX — plan

## Context

NOT 1942 (v1.1, repo `~/projects/shooter64`) is a finished 1942-style vertical shmup for a stock PAL C64, written in 6502 assembly with ACME. `~/projects/not1942-dx` is a straight copy of its `src/`, `data/`, `tools/`, `Makefile` and `BUDGET.MD`. It is not a git repo yet and has no CLAUDE.md.

The original's look comes from design rules it chose on purpose. Each one is now a limit:
- chunky scroll: one character row every 12 frames
- exactly 8 sprites with no multiplexing, so at most 3 enemies on screen
- colour RAM that never scrolls, so the playfield has only 4 colours in total
- a HUD in character row 0
- 64 tile characters per level
- 40-byte row patterns, which use up memory fast

DX keeps the game (4 levels, bosses, waves, music, controls), redoes the engine so the screen scrolls smoothly, and gives the screen and in-game graphics a big upgrade. A later, separate build targets the MiSTer C64 core's turbo modes.

**Decisions made with the user:**
- Evolve the existing engine, don't rewrite it from scratch.
- Add a sprite multiplexer to the stock build.
- Scroll at **1 pixel every frame** (50 px/s).
- Remaster the same 4 levels first.

**Facts about MiSTer turbo** (from the core's source: `rtl/fpga64_sid_iec.vhd`, `rtl/video_vicII_656x.vhd`, `c64.sv`):
- The OSD has "Turbo mode: Off / C128 / Smart" and "Turbo speed: 2x / 3x / 4x". Software can't pick the speed.
- In **C128** mode, `$D030` bit 0 turns turbo on and off. Reading `$D030` gives `$FE | bit0`. A stock C64 reads `$FF`.
- In **Smart** mode, turbo is always on (except during disk access). `$D030` then reads `$FF`, so software can only detect it by timing.
- Turbo only speeds up **RAM** cycles. Any I/O access (VIC, SID, CIA, **colour RAM**) runs at 1 MHz. Badlines and sprite DMA still stall the CPU. So turbo speeds up game logic, sorting and char/screen work in RAM, but not VIC register writes or colour RAM copies.

## Phase 0 — Project setup

- `git init`, plus a `.gitignore` for `build/`. The first commit happens only once the user says so.
- Write `CLAUDE.md` for DX, adapted from `shooter64/CLAUDE.md`. Keep the build/test hooks, the code conventions, `TIMING:` notes and the milestone working agreement (build cleanly, then stop and tell the user what to test in VICE, ranked by severity). Replace the fixed design points that DX overturns (chunky scroll, 8 sprites, `$D01E` collision, static colour RAM, HUD on row 0) with the DX rules below.
- Rename the outputs to `build/not1942dx.*` and set the title version text (`title_version`, `data/title.asm`) to "DX 0.1".
- Baseline check: `make` builds with no warnings, and a headless VICE screenshot matches the original.

## Phase 1 — Engine (stock PAL C64, 1 MHz)

### M1. Smooth scroll core (done)
As built (`src/scroll.asm`, IRQ in `src/system.asm`, `src/video.asm`):
- **Fine scroll:** `$D011` YSCROLL goes up by 1 every frame, written by the frame IRQ (`scroll_d011`). Every 8 frames there is a coarse step. All 25 screen rows scroll inside the 24-row window, so no split is needed.
- **Screen copy:** the A/B double buffer, flipped in the IRQ together with YSCROLL 0. The back buffer and `CRAM_SHADOW` are built in 7 unrolled slices (3-4 rows each, frames f = 0-6).
- **Colour RAM scroll:** every char has its own colour RAM value (`CHAR_COL`). On the flip frame, rows 0-22 are copied from `CRAM_SHADOW` just *behind* the raster (a row's colours are only read on its badline), using time the frame would otherwise spend idle. Rows 23-24 follow right after the flip. If a frame runs late, the rest of the copy runs straight away, top to bottom, which stays ahead of the raster. (Planned as racing ahead of the beam; chasing behind it costs no extra frame time.)
- **IRQ chain:** not needed yet (one frame IRQ). It moves to M2 with the multiplexer's splits.
- **Speed and stream:** level records arrive every 8 frames instead of 12. The 4 NOT 1942 levels are stretched 2:3 by `tools/stretch_level.py` (moved here from M4) so their timing and enemy budgets stay the same.
- **Tools:** `tools/profile.py` (whole-game frame budget through VICE's remote monitor) and `tools/vicemon.py`.
- **Gate (met):** zero play overruns in all 4 levels; see `BUDGET.MD`.

### M2. Sprite multiplexer + software collision (done)
*(Order swapped with the HUD after M1: the sprite HUD needs the multiplexer.)*
As built:
- `src/mux.asm`: 18 virtual slots (player, 3 player bullets, 8 enemies / boss parts, 6 enemy bullets), with room to grow (`MUX_LIST` = 32 entries). Slot tables live in BSS in the RAM under the KERNAL (`src/bss.asm`), along with the enemy and bullet arrays. `spr_enable` became a `spr_on` byte per slot.
- `mux_build` at the end of the logic: an insertion sort by Y (order kept between frames), then a double-buffered display list; entry k uses hardware sprite k & 7 and is dropped that frame if entry k-8 hasn't finished.
- The frame IRQ shows the committed list (first 8 entries) and chains raster IRQs (`mux_irq`) for the rest; this is the IRQ chain planned for M1. Pause and late frames simply show the last list again.
- `src/collide.asm`: box tests at the new positions after all movement; a smaller player hitbox.
- Bosses are part lists (`+boss_parts` / `+boss_part`, up to 6 expanded sprites at any offsets); checked with a temporary 2x3 boss.
- More player bullets (3) and enemy bullets (6) are a difficulty change to watch in testing; `check_waves.py` now allows 8 enemies (NOT 1942's waves peak at 3).
- **Gate (met):** zero play overruns and zero dropped sprites in all 4 levels; see `BUDGET.MD`.

### M3. Floating sprite HUD (done)
*(Replaces the planned border HUD. Opening the lower border also opens the top one, and a character HUD row beside the fine scroll needs a cycle-exact split that sprite DMA breaks.)*
As built (`src/hud.asm`):
- Hires sprites drawn from the charset's font into 8 reserved shapes: score (2 sprites, top left), lives as mini ship icons (top right), the boss health bar (top centre), and mid-screen messages ("BOSS!" for 2 s, "LEVEL CLEAR"), typed one char per frame with cycling colours. Only changed score digits and changed bar blocks are redrawn.
- The multiplexer gained per-slot hires (`spr_mc`) and leaves out sprites wholly in the top border. `spr_exp`/`spr_mc` are `$FF`/0 masks.
- To keep the busiest boss frames in budget: the colour chase became generated straight-line code in BSS, the slices moved to f = 1-7 (f = 0 absorbs a late chase), and the sort skips slots that aren't drawn.
- **Gate (met):** zero play overruns and zero dropped sprites in all 4 levels, up to 16 sprites on screen; see `BUDGET.MD`.

### M4. New level format + asset pipeline
- **Map format:** 4×4-character *blocks* (16 bytes each, up to 256 per level), a map of 10 block indices per 4 character rows, and a per-character colour table. This replaces 40-byte row patterns: about 1.4 KB of map per 540-row level instead of about 21 KB.
- **Tilesets:** up to about 190 characters per level (64-255, minus the fixed characters). The font shrinks to the glyphs that are actually used.
- **Spawns:** keep the stream semantics. Spawns are keyed to map rows, `+boss_here` stays, and the existing macros keep checking the data at assemble time.
- **`tools/png2level.py` (Pillow is installed):** reads a level drawn as a 160×N multicolour PNG and enforces the C64 limits (3 shared colours plus 1 colour from 0-7 per character). It removes duplicate characters and blocks, then writes ACME data. Each level's spawn script stays in hand-written `.asm` beside it.
- **`tools/png2sprites.py`:** sprite sheets go from PNG to `+spr`-compatible data.
- **Level conversion:** already done in M1 (`tools/stretch_level.py`); the new art replaces the stretched NOT 1942 maps.
- **Memory:** level packs are stored compressed (exomizer raw mode). They are unpacked at level start into a fixed level work area by exomizer's 6502 decruncher, ported to ACME syntax and fetched from exomizer's own source distribution. The VIC bank gets bigger sprite space (`$5000-$7FFF`, about 190 shapes). Rewrite the memory map at the top of `src/defs.asm` and add `!error` guards for every new region. Dev builds also go through exomizer when data lives under I/O (`$D000-$FFFF`).

### M5. Graphics FX
- Animated tiles: water, surf and fires, by rewriting a few characters every N frames.
- A cloud layer: characters redefined at a different scroll rate, for cheap parallax.
- Multi-frame explosions with debris, and screen shake through XSCROLL.
- 1942-style shadows for the player and the larger planes, if the multiplexer budget allows.
- Level intro and outro with fades, done with colour-table steps.
- A new title screen: a multicolour character logo with colour cycling, and a sprite plane flyby.

Each effect goes into `BUDGET.MD` with its measured cost.

## Phase 2 — Content remaster

M6-M9 cover levels 1-4, one per milestone:
- new PNG art (ocean, jungle, strait, fleet)
- new enemy and player sprites
- an upgraded boss for each level
- waves re-tuned for the higher enemy cap, still deterministic

Level 4's "Kraken" can be a character-based battleship that scrolls in with the background. Music, SFX and the ending text are reused (the ending text changes only on request).

M10 is balancing and release: `.d64`, a compressed `.prg` and a `.crt`. The cartridge outgrows ACME's 64 KB limit, so a Python CRT packer builds a larger Magic Desk or EasyFlash image. Update `itch-description.html` and `BUDGET.MD`.

## Phase 3 — MiSTer turbo build (later)

### M11. Detection and build
- `make turbo` builds with `-DTURBO=1` and produces `not1942dx-turbo.prg` and `.crt`.
- **Detection at boot:** write 0 to `$D030` and read it back. If bit 0 is 0, the C128 turbo register is there: set `$D030 = 1`. Then measure a RAM-only loop between two raster lines; this catches Smart mode, and also reports the actual speed multiplier.
- If the speed is below 2×, show "set Turbo in the MiSTer OSD (C128 or Smart)" and don't start the game.
- Document that the turbo build is not meant for a real C128, whose VIC screen breaks at 2 MHz.

### M12. Turbo features
These assume at least 2× speed and are scaled by compile-time knobs:
- a larger multiplexer (about 32 virtual sprites)
- bullet-pattern bosses
- extra spawns marked `+spawn_turbo` in the wave data
- per-frame screen rebuild instead of spreading it over 8 frames, plus a full-frame parallax layer
- more particles

**Rules:** no cycle-counted code (raster IRQs and polling only), and minimal I/O access in the hot loops, since I/O runs at 1 MHz.

### M13. Testing
Proxy testing in VICE `xscpu64`: a fast CPU with a normal-speed VIC, and the timing-based detection works there. The user tests on real MiSTer hardware at 2×, 3× and 4×.

## Files touched (representative)

- **Rewritten:** `src/scroll.asm`, `src/sprites.asm` → `src/mux.asm`, `src/collide.asm`, `src/hud.asm`, `src/system.asm` (IRQ chain), `src/defs.asm` (memory map, slots), `src/level.asm` (block maps, unpacking), `src/macros.asm` (level/map macros), `Makefile` (new targets: crunch-always dev build, turbo, CRT packer).
- **Kept largely as is:** `src/music.asm`, `src/sfx.asm`, `data/music*.asm`, `data/sfx.asm`, `src/input.asm`, `src/pause.asm`, the path engine in `src/enemies.asm`, `src/boss.asm` scripts, `data/waves.asm` paths, `src/ending.asm`.
- **New tools:** `tools/png2level.py`, `tools/png2sprites.py`, `tools/stretch_level.py`, `tools/mkcrt.py`. Update `tools/check_waves.py`.

## Verification (each milestone)

- `make` assembles with no errors or warnings, and all `!error` region guards pass.
- **Headless VICE:** `x64sc -default -pal -warp ... -limitcycles N -exitscreenshot` (as in the original CLAUDE.md). For smooth scroll, take screenshots exactly 19,656 cycles (one frame) apart and diff them: expect a 1-pixel shift and no tearing at the coarse step.
- **PROFILE build** (`-DPROFILE=1 -DAUTOSTART=1 -DINVINCIBLE=1 -DFORCE_TAP=4`): zero overruns in every level, with the colour-RAM frame and the multiplexer peaks recorded in `BUDGET.MD`.
- `python3 tools/check_waves.py data/levelN.asm` passes for every level. A DEBUG build shows no dropped spawns.
- The user plays each milestone in VICE (`make run`), and later on MiSTer. The turbo build is checked in `xscpu64`, then on MiSTer at 2×, 3× and 4×.
