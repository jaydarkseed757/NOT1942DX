# NOT 1942 DX: resource budgets

Measured on 2026-10-05 after DX milestone M6 (smooth scroll, sprite multiplexer, sprite HUD, streamed level maps, effects; level 1 remastered with new art, sprites, a 4-sprite boss and 89-enemy waves; levels 2-4 still NOT 1942's pictures stretched 2:3). Target: a stock PAL C64 at 1 MHz.

## CPU

One PAL frame is 312 lines × 63 cycles = **19,656 cycles**. The game does one frame of work per frame (50 Hz).

The table shows the worst frame in each part of the game, counted from the start of the raster IRQ (line 251) to the end of that frame's work. It includes the IRQs (the frame IRQ and the multiplexer's), the border work and the game logic. In play it stops before `scroll_colour` (see "Colour chase" below). Measure it with `python3 tools/profile.py`.

| Part | Worst frame (cycles) | Share of the frame | After M5 | After M4 | NOT 1942 1.1 |
|---|---:|---:|---:|---:|---:|
| Title screen | (not re-measured) | | | | 2,276 |
| Level 1 | 17,895 | 91% | 17,668 | 17,447 | 6,507 |
| Level 2 | 15,967 | 81% | 16,063 | 15,960 | 6,588 |
| Level 3 | 14,874 | 76% | 14,724 | 14,640 | 5,995 |
| Level 4 | 17,845 | 91% | 16,698 | 17,486 | 7,080 |
| Victory screen | 1,977 | 10% | 1,986 | 1,985 | 1,382 |
| Credits roll | 6,143 | 31% | 6,145 | 6,148 | 5,314 |
| Finale scroller | 11,840 | 60% | 11,847 | 11,849 | 10,956 |

Since M6 the profile counts the player's collision checks (`INVINCIBLE` now only skips the dying), which is most of level 4's rise; the M5 figures left them out.

- **No dropped frames** in gameplay or the ending: zero play overruns in all four levels, and no sprite was ever dropped (up to 18 on screen). The only frames that run long are the deliberate screen builds with the display off.
- **Headroom is about 1,800 cycles in the busiest frames** (a 4-row slice, 8 map chars unpacked, 17-18 sprites). Starting boss 1 straight away (`--boss`, so it meets the level-start fade) reaches 18,673 (95%); the fight in a normal run stays at the figure above.
- **Sprites are the price of everything.** Each sprite on screen costs ~300 cycles a frame: ~150 in `mux_build` (keys, sort, list entry), ~100-150 in the multiplexer's IRQs, plus its own logic and collision tests. M6 had to pay for its bigger waves and boss: the score redraws at most one digit a frame (~360 cycles each), the collision loops test the boxes inline against a per-bullet top and left (~35 cycles a pair apart vertically), and boss 1 is 4 sprites, not 6 (everything but its tail fits the lower sprite row). A 6-part boss with 6 shots out overran.
- **Formations and the 8-per-line limit:** a line abreast of 4 that fires together puts 4 planes and 4 shots in one 21-line band, plus the player's shots: more than 8, so sprites drop. Level 1's waves use echelons and spread V's instead (two rows between ranks). A boss's lower sprite row must start below line 68: the 4 HUD sprites hold their hardware sprites until line 65, and a reused one needs 3 lines (`MUX_SETUP`); `data/bosses.asm` checks this at assembly.
- **M5's effects** cost little: animated chars ~150 cycles per char rewritten (at most 2 a frame), the fade ~200 on a step frame, the shake ~30 in the frame IRQ.
- **The map stream** costs ~45 cycles per char: 8 chars (~360) on each of f = 1-5. f = 0 does the wave and the colour RAM rows 23-24 (~1,000); f = 7 has no slice, so the colour chase starts early (late chases: 4-40 per level).
- **The frame IRQ** takes about 2,500 cycles at worst: the first 8 display-list entries (always including the 4 pinned HUD entries, which is why the static screens went up by ~500), music and a sound effect starting.
- **The scroller's slices** on f = 1-6 copy 4 or 5 rows (~3,400 / ~4,200 cycles).
- **Colour chase:** on the flip frame, straight-line code (generated into BSS at boot) copies colour RAM rows 0-22 just behind the raster, 8 cycles per byte (~7,600 in all), mostly in time the frame would otherwise spend waiting. When it can't keep up (sprites on every line steal bus cycles) it ends after the next IRQ; that's harmless, and f = 0 has room for it.
- **Caveats:** the figures come from an auto-fire run with `INVINCIBLE` (the player is never hit, but its collision checks run). They include about 100-300 cycles of measuring overhead.

## Memory

| Region | Size | Used | Free |
|---|---:|---:|---:|
| Zero page `$02-$FF` | 254 B | see `src/zp.asm` | **~42 B** (`$38-$40`, `$71-$84`, `$89`, `$CE`, `$FD-$FF`) |
| Code `$0810-$3FFF` | 14.3 KB | 12.3 KB (`code_end` = `$37DC`) | **2.0 KB** (M6 moved the aim tables and the ending's data out to `$8000-$CFFF`) |
| Sprite shapes `$5000-$6FFF` | 128 shapes | 37 (29 + 8 for the HUD; `sprites_end` = `$5940`) | **91 shapes** |
| Map ring `$7000-$7FFF` | 4 KB | the level map's last 4 KB, unpacked at run time | (fixed) |
| Music, effects, title, waves, bosses, level packs, aim tables, the ending's data: `$8000-$CFFF` | 20 KB | to `$C2C8` (`data2_end`) | **3.3 KB** (levels 2-4 will need about 3 KB each beyond today's packs: see below) |
| Character set `$4800-$4FFF` | 256 chars | font 0-63, a level's chars from 64 | **up to 192 chars per level** |
| Low RAM `$0200-$07FF` | 1.5 KB | `HUD_BUF` (40 B), `CHAR_COL` (256 B), `CRAM_SHADOW` (1000 B) | **240 B** (`$0228-$02FF`, `$07E8-$07FF`) |
| RAM under I/O and KERNAL, `$D000-$FFF9` | ~12 KB | BSS `$E000-$FBB6` (`bss_end`: tables 1.5 KB + the generated colour chase 5.5 KB), IRQ vectors | **~0.8 KB** BSS (`$FBB7-$FEFF`) + `$D000-$DFFF` under I/O (4 KB) |
| Disk (compressed program) | 664 blocks | 74 | 590 |
| Cartridge (Magic Desk, uncompressed game) | 7 banks (57,088 B of game; ACME's 64 KB output limit) | 6 (47,815 B) | **9 KB** |

Today's level packs (level 1 remastered; 2-4 still from NOT 1942's pictures):

| Level | Chars | Chars + colours packed | Map packed | Boss loop packed | Waves |
|---|---:|---:|---:|---:|---:|
| 1 | 89 | 613 B | 4,124 B | 66 B | 476 B |
| 2 | 16 | 136 B | 1,722 B | 69 B | 233 B |
| 3 | 16 | 135 B | 1,743 B | 69 B | 245 B |
| 4 | 18 | 148 B | 1,198 B | 64 B | 260 B |

Level 1's new art (islands, surf, wave texture, 16 clouds; 14 animations, 505 B) costs about 5.3 KB with its waves, against 2.1 KB before. Its clouds alone cost ~1 KB (each breaks the ocean texture's long matches for its rows, ~40 B, plus ~50 chars). That leaves levels 2-4 about 3 KB each beyond what they use today, ~4.5-5 KB a level in all, unless more room is found (`$D000-$DFFF` under I/O, or moving the title or ending data).

The character set is laid out as follows:

| Chars | Contents |
|---|---|
| 0-63 | Font, copied from the character ROM at boot |
| 64-255 | In play: the level's chars (unpacked at level start, up to 192) |
| 128-143 | On the title and text screens: the logo's 2×2 block quadrants (`restore_quads`) |
| 144-223 | In the ending: its big scroller strip |

**`$D000-$FFF9`** is the place to grow into if the other regions fill up. Run-time tables already live at `$E000-` (BSS, `src/bss.asm`): they need no loading, only clearing at boot. A normal `LOAD` can't fill this area with data, because the I/O registers sit at `$D000`.

`build/not1942dx-dev.sym` holds the current end addresses: `code_end`, `sprites_end`, `data2_end` and `bss_end`. The `!error` guards in `src/main.asm`, `src/bss.asm` and `data/levels.asm` stop the build if a region overflows.

## Fixed limits

| Resource | Limit | In use |
|---|---|---|
| Virtual sprite slots | 26 (`NUM_SLOTS`; display lists hold up to 32) | 26, incl. 8 for the HUD. Most on screen at once so far: 18 |
| Hardware sprites | 8, multiplexed (`src/mux.asm`) | 8 |
| Enemies alive at once | 8 (`ENEMY_COUNT`) | Level 1 peaks at 6 (kept there to leave room for medals, which `check_waves.py` doesn't count); levels 2-4 at 3 |
| Player bullets / enemy bullets | 3 / 6 | |
| Boss parts | 6 expanded sprites (`BOSS_MAX_PARTS`) | Boss 1: 4 (144x84 px); bosses 2-4: 3. 6 parts proved too many for the CPU with shots out |
| SID voices | 3 | 3. Sound effects borrow voice 3, the drums, while they play |
| Chars per level | 192 (codes 64-255) | L1 89, L2 16, L3 16, L4 18 |
| Map back-reference reach | 4 KB (the ring) | `png2level.py` packs within it |
| Songs | Table-driven | 6 (title, 4 levels, boss) |
| Instruments | Table-driven | 10 |
| Sound effects | Table-driven | 5 (boss explosion, enemy explosion, player death, medal, boss hit) |

A level costs its packs (about 1.4-2 KB for today's pictures; richer art packs larger) plus its waves (3 bytes per wave + 3 per enemy). A new song costs about 1.5 KB.

## Re-measuring

**CPU:** run `python3 tools/profile.py` (add `--level N` to start later, `--boss` for the boss fights straight away). It builds a PROFILE test build into a temp folder, runs the whole game headless in x64sc at warp speed, and reads the profiler at each level change through VICE's remote monitor. It needs `acme` and `x64sc` on the PATH and takes about 20 seconds.

The PROFILE build also shows its worst cases, in hex, in the HUD row of the text screens (in play the HUD isn't on screen):

| HUD columns | Value |
|---|---|
| 20-21 | Most sprites in one frame's display list |
| 22-23 | Sprites the multiplexer dropped (low byte of the total) |
| 25-28 | IRQ start to the end of the frame's work |
| 30-32 | The IRQ alone |
| 34-35 | Number of frames that overran |
| 38-39 | `game_mode` / `lvl_state` at the last overrun |

The counts reset at each level start, the victory screen, the credits roll and the finale.

**Memory:** run `make` and read `code_end`, `sprites_end`, `data2_end` and `bss_end` in `build/not1942dx-dev.sym`; `make gen` prints each level pack's size.
