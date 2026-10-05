#!/usr/bin/env python3
"""profile.py - measure the frame budget of every level, headless.

Builds a PROFILE test build (auto-start, invincible, tapping fire), runs it in
x64sc at warp speed, and stops at each prof_reset (the start of every level,
the victory screen, the credits roll and the finale). There it reads the
profiler's worst cases for the part that just ended. All figures are exact
CPU cycles (CIA timer), counted from the frame IRQ (line 251).

  play       worst play frame: IRQ start to the end of the frame's work
             (before the colour chase, which waits for the raster on purpose)
  any        worst frame of any kind, including the display-off screen
             build that ends a level (that one may run long)
  irq        worst frame IRQ alone (first 8 sprites, music, sound effects)
  over       frames that ran into the next frame (screen builds included)
  play_over  of those, frames during play: must be 0
  late       colour chases that ended after the next IRQ (harmless: the
             flip has happened, and the rest of the copy stays ahead of the
             raster; see scroll_colour in src/scroll.asm)
  spr        most sprites in one frame's display list (src/mux.asm)
  drops      sprites the multiplexer couldn't place, summed over frames

Usage:  python3 tools/profile.py [--level N] [--boss] [-D NAME=VALUE ...]
Needs acme and x64sc on the PATH. Run from anywhere; builds go to a temp dir.
"""
import argparse, os, subprocess, sys, tempfile, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vicemon import Mon, start, symbols

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GM_PLAY, GM_INTRO, GM_VICTORY, GM_ROLL = 0, 3, 4, 5   # src/defs.asm


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--level", type=int, default=1, help="start level (1-4)")
    ap.add_argument("--boss", action="store_true", help="BOSS_TEST: bosses at once")
    ap.add_argument("-D", action="append", default=[], help="extra ACME define")
    ap.add_argument("--finale-frames", type=int, default=90,
                    help="frames to run the finale before reading it (fire is "
                         "accepted after GO_DELAY = 100 frames and restarts the game)")
    args = ap.parse_args()

    tmp = tempfile.mkdtemp(prefix="dxprof")
    prg, sym = os.path.join(tmp, "prof.prg"), os.path.join(tmp, "prof.sym")
    defs = ["PROFILE=1", "AUTOSTART=1", "INVINCIBLE=1", "FORCE_TAP=4",
            f"START_LEVEL={args.level}"] + (["BOSS_TEST=1"] if args.boss else []) + args.D
    subprocess.run(["acme", "-f", "cbm", *[f"-D{d}" for d in defs], "-l", sym,
                    "-o", prg, "src/main.asm"], cwd=ROOT, check=True)
    s = symbols(sym)

    emu = start(prg)
    mon = Mon()
    try:
        mon.cmd(f"break {s['prof_reset']:04x}")
        print(f"{'part':14} {'play':>6} {'any':>6} {'irq':>5} "
              f"{'over':>5} {'play_over':>9} {'late':>5} {'spr':>4} {'drops':>6}")
        w, b = (lambda n: mon.word(s[n])), (lambda n: mon.peek(s[n])[0])

        def row(name):
            print(f"{name:14} {w('prof_play'):6} {w('prof_main'):6} "
                  f"{w('prof_irq'):5} {b('prof_over'):5} {b('prof_over_play'):9} "
                  f"{b('prof_late'):5} {b('prof_maxspr'):4} {w('prof_drops'):6}", flush=True)

        # Each stop is at prof_reset: name the part that just ended from the
        # game state (see the callers of prof_reset).
        while True:
            mon.cmd("x")
            gm, lvl = b("game_mode"), b("level")
            if gm == GM_INTRO and lvl + 1 > args.level:
                row(f"level {lvl}")             # level_begin of the next level
            elif gm == GM_PLAY and lvl == 4:
                row("level 4")                  # victory_enter
            elif gm == GM_VICTORY:
                row("victory")                  # roll_enter
            elif gm == GM_ROLL:
                row("credits roll")             # finale_enter
                break
            # (otherwise: boot, or the first level starting)
        # the finale never ends: let it run, then read it
        mon.cmd("delete")
        mon.cmd(f"break {s['main_loop']:04x}")
        for _ in range(args.finale_frames):
            mon.cmd("x")
        row("finale")
    finally:
        mon.quit()
        time.sleep(0.3)
        emu.kill()


if __name__ == "__main__":
    main()
