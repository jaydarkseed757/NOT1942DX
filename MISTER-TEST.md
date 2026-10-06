# Testing NOT 1942 DX on a MiSTer (M13)

What can't be tested in VICE: the C64 core's own turbo modes. VICE has no
C128-mode `$D030` register, and its only fast CPU (the SuperCPU, `make
run-turbo`) runs at 20 MHz, not 2x-4x. This is the checklist for the real
core.

Build the disks with `make release turbo turbo-profile`:

| File | What it is |
|---|---|
| `build/not1942dx.d64` | the standard version (1 MHz) |
| `build/not1942dx-turbo.d64` | the turbo version (file `NOT 1942 DX T`) |
| `build/not1942dx-turbo-profile.d64` | the turbo version with the profiler (file `NOT 1942 DX TP`) |

## 1. Detection

Load `not1942dx-turbo.d64` (`LOAD"*",8,1` then `RUN`).

- [ ] **Turbo off** (OSD: Turbo mode Off): the "set turbo" screen appears and
      shows `MEASURED SPEED: 1X`.
- [ ] **Smart mode**, switched on in the OSD while that screen is up: within
      about a second the title appears, with `DX 1.0 TURBO 2X` (or 3X/4X, as
      set) at the top right.
- [ ] **C128 mode** (OSD: Turbo mode C128, then reboot and load): the title
      appears straight away, with the speed set in the OSD.
- [ ] The speed on the title matches the OSD's Turbo speed at 2x, 3x and 4x.
- [ ] If the screen says **"this machine is a Commodore 128"**, the core
      answers like a real C128 at `$D02F`: tell me, the check is wrong there.

## 2. Playing (at 2x, then 3x and 4x)

Press **1-4** on the title to start at a level's boss, or play from level 1.

- [ ] The scroll is smooth (1 pixel a frame) and the colours of the land are
      right while it scrolls (no rows with the wrong colours for a moment).
- [ ] No flicker or sprites vanishing, in the busy waves and in boss phase 2
      (the sweeps and bursts).
- [ ] Music and sound effects play at normal speed (the game runs at 50 Hz
      whatever the CPU speed).
- [ ] Level 4: the sea moves past the ships.
- [ ] Turbo version: every few seconds a cloud drifts down over everything,
      twice as fast as the land (yellow in level 3). It should look solid,
      with no flicker, no torn edges, and nothing left behind where it was,
      even at its top when it enters at the top of the screen (watch 2x most).
- [ ] The standard version (`not1942dx.d64`) also plays normally with turbo
      on: it doesn't need it, but shouldn't mind it.

## 3. Measuring (the profiler disk)

Load `not1942dx-turbo-profile.d64` and play. After a level, the next level's
intro screen (or GAME OVER, or the victory screen) shows the worst case of
the level just played, in hex, in the top text row:

| Columns | Value | Stock C64, for comparison |
|---|---|---|
| 20-21 | most sprites in one frame | up to `11` (17) |
| 22-23 | sprites dropped | `00` |
| 25-28 | the worst frame of any kind, in 1 MHz cycles (a frame is `4CC8`); at high speeds this can be a level's set-up (about `16EE`) rather than play | about `47xx` (play) |
| 30-32 | the IRQ alone | about `960` |
| 34-35 | frames that overran | `00` or `01` (a level's set-up) |

- [ ] Note columns 25-28 and 34-35 after each level, at 2x, 3x and 4x (a
      photo of the screen is fine). Columns 22-23 should stay `00`. The text
      that was in that row ("LEVEL", "LIVES") shows through between the
      numbers: that's expected.
- [ ] On VICE's SuperCPU (20 MHz) the play frames take about `04D0`; at 2x
      expect somewhere under `3000`.
