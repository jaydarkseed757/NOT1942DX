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
make DEBUG=1 run  # red border bar = time spent in the main loop
make clean
```

Tools come from Homebrew: `acme` (0.97), `vice` (x64sc, c1541) and `exomizer` (3.1.2). Releases are always the compressed program. Development and the headless tests use the uncompressed one: it's quicker, and its symbols match the listing. About 56% of the uncompressed file is empty space between memory regions, which is why compression gets about 5x. To check a compressed build, `exomizer desfx` unpacks it in exomizer's own 6502 emulator, and the result must match `build/not1942dx-dev.prg` byte for byte. `src/main.asm` is the game's only ACME entry point. It `!source`s everything else, with paths relative to the repo root. `src/crt.asm` is a second, separate entry point that wraps the finished `build/not1942dx-dev.prg` in a cartridge image.

The cartridge is **Magic Desk** (CRT type 19): 8 KB ROM banks at `$8000`, selected through `$DE00`; writing `$80` there switches the cartridge off.
- **Boot:** bank 0's boot page runs the KERNAL's I/O and screen set-up (`IOINIT`, `RESTOR`, `CINT`), which the game relies on; it never sets `$00` itself. Then a copier in the cassette buffer (`$0340`) copies the uncompressed game page by page to `PRG_LOAD`, switches the cartridge off and jumps to `GAME_ENTRY`. It reaches the title about 1.5 s after power-on.
- **Size:** ACME writes at most 64 KB, which allows 7 banks (57,088 bytes of game). The game uses all 7 today. `crt.asm` stops the build with an error if the game outgrows them.
- **Shared addresses:** `PRG_LOAD` and `GAME_ENTRY` live in `src/defs.asm`, shared by both entry points.
- **Testing a test build as a cartridge:** make a scratch folder with `src` and `data` symlinked to the repo and the test PRG at `build/not1942dx-dev.prg`. Run `acme -f plain -DPRG_SIZE=<bytes> -o t.crt src/crt.asm` there, then `x64sc -cartcrt t.crt`.

## Working agreement

DX is built in milestones (details in `PLAN.md`):
- **Phase 0:** setup (done).
- **Phase 1, the engine:**
  - M1: smooth scroll core (done)
  - M2: sprite multiplexer and software collision (done)
  - M3: floating sprite HUD (done, awaiting the user's test)
  - M4: block-map level format, PNG asset pipeline and compressed level packs
  - M5: graphics effects
- **Phase 2, the content remaster:** M6-M9 for levels 1-4, M10 for balancing and release.
- **Phase 3, the MiSTer turbo build:** M11-M13.

After each milestone, make sure it assembles with no errors or warnings, then stop and tell the user what to test in VICE, with likely bugs ranked by severity. Don't start the next milestone until the user says so. Commit only when the user asks.

Until a milestone replaces it, the inherited NOT 1942 code still works as described in the sections below. Update this file as each milestone lands.

### DX design points (decided with the user; ask before changing any of them)

- **Smooth scroll at 1 pixel per frame** (50 px/s, `src/scroll.asm`): the whole screen scrolls, using all 25 screen rows in the 24-row window (lines 55-246) with `$D011` YSCROLL 0-7, so no split is needed. A coarse character-row step every 8 frames flips the A/B double buffer (`$D018`, set by the IRQ together with YSCROLL 0). The back buffer is built in 7 slices (frames f = 1-7; f = 0 only fetches the record, so it can absorb a late colour chase). Colour RAM can't be double-buffered: on the flip frame (f = 7) `scroll_colour` copies `CRAM_SHADOW` into `$D800` row by row just behind the raster (a row's colours are read only on its badline), and rows 23-24 follow right after the flip (`cram_late`). The chase is straight-line code that `chase_gen` writes into BSS at boot. The background is still visual only, with no terrain collision.
- **Colour RAM scrolls**, and each character has its own colour RAM value (`CHAR_COL`, 0-7 + multicolour bit). That gives 3 shared colours plus 1 per character. (M1 fills `CHAR_COL` with the level's single colour; per-character colours arrive with the M4 level format. `-DTEST_CHAR_COL=1` colours chars by code to test the colour scroll.)
- **Sprite multiplexer** (`src/mux.asm`, M2): `NUM_SLOTS` (26) virtual sprite slots in BSS: `spr_xh`, `spr_y`, `spr_ptr`, `spr_col`, `spr_on` (non-zero = drawn), and the masks `spr_exp` (`$FF` = X+Y expanded) and `spr_mc` (`$FF` = multicolour, 0 = hires). Slots: player 0, player bullets 1-3, enemies and boss parts 4-11, enemy bullets 12-17, HUD 18-25 (`SLOT_*`, `*_COUNT` in `src/defs.asm`); slots are never shared, except that medals and boss parts live in enemy slots. Game code writes the slots and never touches the VIC. `mux_build` (end of the frame's logic) sorts them by Y and commits a double-buffered display list; slots wholly in the top border are left out. The frame IRQ writes its first 8 entries and arms raster IRQs (`mux_irq`) for the rest; entry k uses hardware sprite k & 7 and may only reuse it after entry k-8 has finished (else it is dropped that frame). While paused the IRQ keeps showing the last list.
- **Collision is software box tests** (`src/collide.asm`): per-slot boxes (`box_ox/oy/w/h`), tested after all movement, so they match the positions the next frame shows. The player's box is its fuselage and wing roots (smaller than the art); enemy boxes are generous. `$D01E` isn't used.
- **HUD** (`src/hud.asm`, M3): a floating sprite HUD of hires sprites drawn from the charset's font: the score (2 sprites) top left, the ships left as mini icons (1 sprite) top right, the boss's health bar (1 sprite) top centre during a fight, and messages ("BOSS!" for 2 s, "LEVEL CLEAR"; up to 4 sprites, colour-cycling, typed one char per frame) mid-screen. The `hud_draw_*`/`hud_show_*` calls write `HUD_BUF` (the text-screen HUD row) and mark shapes dirty; `hud_update` redraws only what changed (score digits one by one, the bar when a block goes). The 8 HUD shapes are blank in `data/sprites.asm` (`PTR_HUD`+). Decided with the user after M1's check: opening the lower border also opens the top one, and a character HUD row beside the fine scroll needs a cycle-exact split that sprite DMA breaks.
- **Levels** are the same 4 as in NOT 1942, remastered. Level art is drawn as PNG and converted (M4) into 4×4-character blocks plus a block map, stored compressed and unpacked at level start. One row is 8 frames, so a level of about 88 s is about 550 rows. Until then the NOT 1942 streams are stretched 2:3 by `tools/stretch_level.py` (one plain copy row per two records), which keeps their timing.
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

## Code conventions

These conventions are inherited from NOT 1942 and still hold unless a DX design point above overrides them.


- Annotate the assembly inline, at the density of the existing files. Mark every raster or cycle-budget assumption with `TIMING:`.
- All level, wave, tile and sprite data lives in `data/`, never in `src/`.
- The memory map is the comment block at the top of `src/defs.asm`. Code must stay below `$4000`; the VIC bank is `$4000-$7FFF`. Level data (waves, tilesets, levels) goes at `$5800-$7FFF`; music and title data at `$8000-$CFFF`. ACME `!if`/`!error` guards in `main.asm` enforce the region limits. Add a guard for any new region.
- The KERNAL and BASIC are banked out (`$01 = $35`). Our IRQ, NMI and BRK vectors sit at `$FFFA-$FFFF`. A flashing border means `brk_trap` caught a stray BRK.
- All object X positions are one byte in 2-pixel units ("half-X"). Only `mux_build` converts them to hardware X and the `$D010` bit. Game code writes the sprite slot tables in BSS (`spr_xh`, `spr_y`, `spr_ptr`, `spr_col`, `spr_exp`, `spr_on`), never the VIC directly.
- The main loop has seven modes (`game_mode`, `GM_*` in `src/defs.asm`): title, level intro, play, GAME OVER, and the ending's victory screen, credits roll and finale. The flow is title → `new_game` → `level_intro_enter` → `level_begin` → play → `+boss_here` → boss → LEVEL CLEAR → next level intro, and after the last level `victory_enter` → roll → finale → title. Losing the last life goes to `gameover_enter` → title. Pause is a flag (`paused`) inside play, not a mode.
- Per-game state (score, lives, level number) is reset in `new_game`. Per-level state (tiles, palette, sprites, bullets, enemies, stream) is reset in `level_begin`.
- The ending (`src/ending.asm`) uses modes GM_VICTORY, GM_ROLL and GM_FINALE. Its screens are plain hires text ($D016 multicolour off), so colour RAM can use all 16 colours. The credits roll moves with $D011 fine scroll plus the double buffer; the IRQ writes `next_d011` together with the $D018 flip, so the fine-scroll reset and the swap happen in the same instant. `next_d011` must stay 0 everywhere else. The big scroller is a bit-scroller in chars 144-223.
- Mode switches happen at the top of the main loop, in the lower border: player game over, and `lvl_state = LS_NEXT`. Screens that rewrite both buffers turn the display off while they do it.
- The score is 3 BCD bytes (`score_hi`/`mid`/`lo`, adjacent). Adds run with `SED`, which is why the IRQ handler starts with `CLD`.
- The main loop does border work first, right after the IRQ at line 251: `scroll_update`. Then the logic, which only touches shadow state: input, player, bullets, enemies, boss, enemy bullets, `collisions`, `level_update`, `hud_update`, and last `mux_build`. The frame ends with `scroll_colour` (the colour chase on flip frames, which waits for the raster on purpose); it also runs after `pause_enter`.
- The RAM under the KERNAL (`$E000-`) holds run-time tables (BSS, `src/bss.asm`): sprite slots, multiplexer lists, enemies, enemy bullets, boss parts, and the generated colour-chase code. Nothing is loaded there; `init_system` clears it. Declare new tables there with `name = BSS_PTR : +bss SIZE`. IRQ code (frame IRQ, `mux_irq`, music, effects) uses only its own zero page (`mux_s_*`, `mux_next`, `mux_d010`, ...), never `zp_tmp*`/`zp_ptr*`.
- A slot is active exactly when its `spr_on` byte is non-zero. Whatever frees an enemy slot must also leave its `en_state` at 0. A stale `EN_MEDAL` once let shots pass through boss parts.
- Screen buffers A and B are double-buffered, and the IRQ flips `$D018`. In play every row scrolls; sprite pointers (`$x3F8`, outside the 25 rows) go into both buffers. Static screens use row 0 for the text HUD (`hud_flush`); in play the sprite HUD shows the same information. Pause prints "PAUSED" straight into the front buffer and restores the chars and colours on resume (`src/pause.asm`).
- `$D011` in play belongs to the IRQ: it writes `scroll_d011` every frame while that is non-zero. `video_off` and `init_video` zero it first, or the IRQ would switch the display back on. Static screens use `D011_TEXT` (25 rows, yscroll 3).
- Low RAM `$0200-$07FF` holds `HUD_BUF`, `CHAR_COL` and `CRAM_SHADOW` (memory map in `src/defs.asm`).

## Data authoring

This is the NOT 1942 format, still in use until M4 introduces block maps and the PNG pipeline. Update this section then.


Macros in `src/macros.asm` turn readable text into bytes and check it at assemble time:
- **Levels** are listed in `data/levels.asm`: one column per level, giving its stream, row-pattern table, tileset, palette (bg, mc1, mc2, and a colour RAM colour 0-7), song and name.
- **Tilesets** are `data/tiles_*.asm`, 512 bytes each, covering char codes 64-127. Each is copied into the charset at level start. Write `+tileset_start`, then `+tile 'x'` with 8 rows of `+mc "pppp"` per tile (ascending codes; a tile's code is its ASCII code), then `+tileset_end`. Each tileset file sets `!set TILE_CHARS = "..."` to the letters it defines; row patterns assembled after it are checked against that list. Chars 128-143 are fixed (`data/tiles.asm`).
- **Row patterns** use `+rowpat`, a 40-character text row. Each level can have up to 253; numbers `$FE`/`$FF` are stream markers. Each pattern costs 40 bytes, so big levels go in the `$8000` area (level 2 does). In level 2 every stream line carries its row's art as a comment, so the stream reads as a map.
- **Each level file** has its own row-pattern table, ending with `!set ROWPAT_COUNT = ...`, and a stream that starts with `+level_start`. `+boss_here` ends the waves; the rows after it loop as the background until the boss is beaten, and the stream ends with `+level_end`. No spawns are allowed after `+boss_here`.
- **Level records** use `+row RP_NAME`, or `+row_spawn RP_NAME, N` followed by N lines of `+spawn E_TYPE, X, P_PATH`. The stream is in time order and new rows enter at the top, so the map reads upside down in the file: list an island's bottom edge first. The first 25 records pre-fill the starting screen and must not contain spawns. The macros enforce this, and the matching `+spawn` count. The "rN" wave comments count NOT 1942's records (before the 2:3 stretch).
- **Enemy budget:** at most `ENEMY_COUNT` (8) enemies may be alive at once; NOT 1942's waves peak at 3. When all slots are busy, a spawn is dropped, and the waves would then depend on the player's kill speed. After editing any wave or path, run `python3 tools/check_waves.py data/levelN.asm`. It replays every path exactly like `enemies.asm` and fails if a spawn would need more slots (each enemy counts 12 extra frames, for an explosion). Then confirm with a DEBUG build and no firing (`-DDEBUG -DAUTOSTART -DINVINCIBLE`): `spawn_drops` must stay 0 until the boss arrives (read it with the remote monitor, see below; it also shows as the hex digit at the right end of the HUD on the next text screen).
- **Level length:** one row is 8 frames. After the stretch all four levels are about 551 rows of waves, about 88 s (49, 48, 53 and 58 enemies), followed by their boss. A full playthrough is about 7 minutes.
- **Memory:** the PRG loads past `$A000` (under BASIC ROM), which works with `LOAD` and `RUN`. Compressed, the game is about 56 blocks: about 35 s to load on a stock 1541, plus 1-2 s to unpack. Each new level costs about 2-8 KB (40 bytes per pattern), and each song about 1.5 KB; keep an eye on `code_end`, `level_end`, `data2_end` and `bss_end` in `build/not1942dx-dev.sym`. `BUDGET.MD` has the measured CPU, memory and data budgets, and how to re-measure them; update it when a change moves them noticeably. As of M3, about 2.5 KB is free after the code, 1.0 KB in the level area, 0.5 KB in `$8000-$CFFF`, 1.3 KB of BSS, and no sprite shapes (all 32 are used; M4 makes room).
- **Bosses** are listed in `data/bosses.asm`, with columns for a part list, colour, width, start X, HP, HP per HUD bar block, phase-2 HP threshold, and two scripts. A part list is `+boss_parts N` then N lines of `+boss_part SHAPE, DX, DY` (up to `BOSS_MAX_PARTS` = 6 X+Y expanded sprites, each 24 half-X x 42 px, at offsets from part 0; e.g. a 2x3 grid uses DY 0 and 42). Scripts use the path format (below) plus `+boss_fire DX, DY` (an aimed shot) and `+boss_spread DX, DY` (a V of two shots), where DX/DY is the gun's offset from part 0's top-left. Expanded art pixel (column c, row r) sits at (2c, 2r); a gun under column c is DX = 2c - 6. Phase-2 scripts have no `+path_start`. `lvl_t_boss` in `data/levels.asm` picks each level's boss.
- **Boss engine** (`src/boss.asm`): part 0 (enemy slot 0) runs the script through `enemy_step`; the other parts follow at their offsets (`boss_follow`). X is clamped to keep the boss's width (`boss_t_w`) on screen. While `boss_state` is non-zero, `enemies_update` leaves the enemy slots alone. During the fight, `collide_boss_boxes` gives the parts expanded-size boxes.
- **Enemy types and paths** live in `data/waves.asm`. A path is `+path_start Y`, then `+seg DX, DY, FRAMES` lines, ending in `+seg_end` (hold the last velocity) or `+seg_loop LABEL`. `+seg_fire` between segments fires one shot aimed at the player; the shot is skipped if both enemy-bullet slots are busy or the enemy is off screen. DX is in half-X units per frame; fractions are stored as 8.8 fixed point.
- **Sprites** use 21 rows of `+spr "............"`, wrapped in `+spr_begin` and `+spr_end`.
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
  - `INVINCIBLE` means the player is never hit, for running through levels.
- **Bug reproductions:**
  - `TEST_STALE_MEDAL`: enemy slots start as stale medals; pair it with `BOSS_TEST`.
  - `TEST_DIE_ON_CLEAR=n`: the player is shot down with n ships left, 40 frames before LEVEL CLEAR ends.
- **Sound:** `TEST_SFX=n` plays effect n every 64 frames during play. `MUSIC_SOLO=n` plays only music voice n; 4 silences the music while it keeps running.
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
