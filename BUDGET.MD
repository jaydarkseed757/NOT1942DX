# NOT 1942 DX: resource budgets

Measured on 2026-10-05 after DX milestone M3 (smooth scroll, sprite multiplexer, sprite HUD, NOT 1942 levels stretched 2:3). Target: a stock PAL C64 at 1 MHz.

## CPU

One PAL frame is 312 lines × 63 cycles = **19,656 cycles**. The game does one frame of work per frame (50 Hz).

The table shows the worst frame in each part of the game, counted from the start of the raster IRQ (line 251) to the end of that frame's work. It includes the IRQs (the frame IRQ and the multiplexer's), the border work and the game logic. In play it stops before `scroll_colour` (see "Colour chase" below). Measure it with `python3 tools/profile.py`.

| Part | Worst frame (cycles) | Share of the frame | After M2 | After M1 | NOT 1942 1.1 |
|---|---:|---:|---:|---:|---:|
| Title screen | (not re-measured) | | | | 2,276 |
| Level 1 | 17,695 | 90% | 12,766 | 8,766 | 6,507 |
| Level 2 | 16,296 | 83% | 12,386 | 8,592 | 6,588 |
| Level 3 | 15,949 | 81% | 11,106 | 8,941 | 5,995 |
| Level 4 | 17,303 | 88% | 12,405 | 9,553 | 7,080 |
| Victory screen | 1,467 | 7% | 1,458 | 1,396 | 1,382 |
| Credits roll | 5,402 | 27% | 5,388 | 5,328 | 5,314 |
| Finale scroller | 11,043 | 56% | 11,030 | 10,973 | 10,956 |

- **No dropped frames** in gameplay or the ending: zero play overruns in all four levels (`play_over` in `tools/profile.py`), and no sprite was ever dropped (up to 16 on screen). The only frames that run long are the deliberate screen builds with the display off: level start, intro, GAME OVER, and the switches between the ending's screens.
- **Headroom is about 2,000 cycles in the busiest boss frames.** Those combine a 4-row scroll slice (~3,400), `mux_build` with 16 sprites (~4,500: keys ~550, sort ~900, list ~3,000), the multiplexer IRQs (~1,200), the frame IRQ (~2,300) and the boss fight's logic and box tests. `mux_build` is the first thing to slim if M5 needs room (snapshot only X/Y in the list and let the IRQs read shape and colour from the slots; precompute the HUD's fixed entries).
- **The sprite HUD** costs ~40 cycles on an idle frame. Only changed score digits (~120 each) and changed boss-bar blocks (~250) are redrawn; messages are typed one char per frame (~120). Its 4 top sprites sit in the top band (lines 44-65), so they also add to the multiplexer's sort and IRQs.
- **The scroller:** slices on f = 1-7 copy 4 or 3 rows (~3,400 / ~2,600 cycles). f = 0 only copies colour RAM rows 23-24 (~820) and fetches the record, because a late colour chase spills into it.
- **Colour chase:** on the flip frame (1 in 8), `scroll_colour` runs straight-line code (generated into BSS at boot) that copies colour RAM rows 0-22 just behind the raster, 8 cycles per byte (~7,600 in all). It mostly fills time the frame would otherwise spend waiting. On busy screens (8 sprites per line steal bus cycles, and the multiplexer IRQs interrupt it) it can fall behind the raster and end after the next IRQ (`late`: 50-230 times per level). That's harmless: the flip has already happened, the rest is copied ahead of the raster, and f = 0 has room for it.
- **The frame IRQ** takes about 2,300 cycles at worst: the first 8 sprites (~500), music, and a sound effect starting. These figures are already included in the table.
- **Caveats:** the figures come from an auto-fire run with `INVINCIBLE`, which skips the player's collision checks, so a real game adds a little (up to ~500 cycles). They also include about 100-300 cycles of measuring overhead.

## Memory

| Region | Size | Used | Free |
|---|---:|---:|---:|
| Zero page `$02-$FF` | 254 B | see `src/zp.asm` | **~51 B** (`$38-$40`, `$5F-$84`, `$89`, `$FD-$FF`) |
| Code `$0810-$3FFF` | 14.3 KB | 11.8 KB (`code_end` = `$35F5`) | **2.5 KB** |
| Level data `$5800-$7FFF` | 10 KB | to `$7BDA` | **1.0 KB** |
| Music, effects, title, levels 2-3: `$8000-$CFFF` | 20 KB | to `$CDE0` | **0.5 KB** |
| Sprite shapes `$5000-$57FF` | 32 shapes | 32 (24 + 8 for the sprite HUD) | **none** (M4 moves level data out to make room) |
| Character set `$4800-$4FFF` | 256 chars | 224 | **32 chars** (224-255) |
| Low RAM `$0200-$07FF` | 1.5 KB | `HUD_BUF` (40 B), `CHAR_COL` (256 B), `CRAM_SHADOW` (1000 B) | **240 B** (`$0228-$02FF`, `$07E8-$07FF`) |
| RAM under I/O and KERNAL, `$D000-$FFF9` | ~12 KB | BSS `$E000-$FADD` (6.7 KB, `bss_end`: tables 1.2 KB + the generated colour chase 5.5 KB), IRQ vectors | **~1.3 KB** BSS (`$FADE-$FEFF`) + `$D000-$DFFF` under I/O (4 KB, see below) |
| Disk (compressed program) | 664 blocks | 56 | 608 |
| Cartridge (Magic Desk, uncompressed game) | 7 banks (57,088 B of game; ACME's 64 KB output limit) | 7 (50,655 B) | **6.4 KB** |

The character set is laid out as follows:

| Chars | Contents |
|---|---|
| 0-63 | Font, copied from the character ROM at boot |
| 64-127 | The level's tileset, copied at level start |
| 128-143 | The title logo's 2×2 block quadrants |
| 144-223 | The ending's big scroller strip |
| 224-255 | Free |

**`$D000-$FFF9`** is the place to grow into if the other regions fill up. Run-time tables already live at `$E000-` (BSS, `src/bss.asm`): they need no loading, only clearing at boot. A normal `LOAD` can't fill this area with data, because the I/O registers sit at `$D000`. The exomizer unpacker could, but then the uncompressed development build would no longer `LOAD` and `RUN` on a real machine.

`build/not1942dx-dev.sym` holds the current end addresses: `code_end`, `level_end` and `data2_end`. The `!error` guards in `src/main.asm` stop the build if a region overflows.

## Fixed limits

| Resource | Limit | In use |
|---|---|---|
| Virtual sprite slots | 26 (`NUM_SLOTS`; display lists hold up to 32) | 26, incl. 8 for the HUD. Most on screen at once so far: 16 |
| Hardware sprites | 8, multiplexed (`src/mux.asm`) | 8 |
| Enemies alive at once | 8 (`ENEMY_COUNT`) | All four levels peak at 3 (`tools/check_waves.py`) |
| Player bullets / enemy bullets | 3 / 6 | |
| Boss parts | 6 expanded sprites (`BOSS_MAX_PARTS`) | 3 |
| SID voices | 3 | 3. Sound effects borrow voice 3, the drums, while they play |
| Row patterns per level | 253 | L1 34, L2 164, L3 176, L4 74 |
| Songs | Table-driven | 6 (title, 4 levels, boss) |
| Instruments | Table-driven | 10 |
| Sound effects | Table-driven | 5 (boss explosion, enemy explosion, player death, medal, boss hit) |

Each row pattern costs 40 bytes, so big levels go in the `$8000` area. Each stream record costs 2 bytes (+3 per spawn); the 2:3 stretch added 196 records (392 B) per level. A new song costs about 1.5 KB.

## Re-measuring

**CPU:** run `python3 tools/profile.py` (add `--level N` to start later, `--boss` for the boss fights straight away). It builds a PROFILE test build into a temp folder, runs the whole game headless in x64sc at warp speed, and reads the profiler at each level change through VICE's remote monitor. It needs `acme` and `x64sc` on the PATH and takes about 20 seconds.

The PROFILE build also shows its worst cases, in hex, in the HUD row of the text screens (in play the HUD isn't on screen):

| HUD columns | Value |
|---|---|
| 20-23 | IRQ start to the end of `sprites_draw` (sprite deadline) |
| 25-28 | IRQ start to the end of the frame's work |
| 30-32 | The IRQ alone |
| 34-35 | Number of frames that overran |
| 38-39 | `game_mode` / `lvl_state` at the last overrun |

The counts reset at each level start, the victory screen, the credits roll and the finale.

**Memory:** run `make` and read `code_end`, `level_end` and `data2_end` in `build/not1942dx-dev.sym`.
