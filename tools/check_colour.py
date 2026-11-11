#!/usr/bin/env python3
"""check_colour.py - check the scrolled screen's colour RAM against its chars.

    python3 tools/check_colour.py [-D NAME=VALUE ...] [--emu xscpu64] [--level N] [--frames N]

Runs a test build headless (AUTOSTART, INVINCIBLE, auto-fire) and, every 37
frames of play, compares each colour RAM cell with CHAR_COL of the char on
screen there (the front buffer). Only on frames where colour RAM is whole:
not on the flip frame or the one after it (the chase, then cram_late). In
the turbo build the parallax cloud's cells (chars PARA_CODE and up) are
skipped. Exit status 1 on any mismatch.
"""
import argparse, os, re, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vicemon

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-D", action="append", default=[])
    ap.add_argument("--emu", default="x64sc")
    ap.add_argument("--level", type=int, default=1)
    ap.add_argument("--frames", type=int, default=6500)
    a = ap.parse_args()
    tmp = tempfile.mkdtemp(prefix="dxcol")
    prg, sym = os.path.join(tmp, "c.prg"), os.path.join(tmp, "c.sym")
    defs = ["AUTOSTART=1", "INVINCIBLE=1", "FORCE_TAP=4", f"START_LEVEL={a.level}"] + a.D
    subprocess.run(["acme", "-f", "cbm", *[f"-D{d}" for d in defs], "-l", sym, "-o", prg, "src/main.asm"],
                   cwd=ROOT, check=True)
    s = vicemon.symbols(sym)
    turbo = any(d.startswith("TURBO") for d in a.D)
    p = vicemon.start(prg, emu=a.emu, port=6610)
    m = vicemon.Mon(port=6610)
    bad = checked = 0
    try:
        bp = re.search(r"BREAK: (\d+)", m.cmd(f"break {s['main_loop']:04x}")).group(1)
        f = 0
        while f < a.frames:
            m.cmd(f"ignore {bp} {36:x}"); m.cmd("x"); f += 37
            b = lambda n: m.peek(s[n])[0]
            if b("game_mode") != 0 or b("level") != a.level - 1:
                if b("level") != a.level - 1: break
                continue
            # colour RAM is whole from the frame after f = 0's cram_late until
            # the flip: scroll_fine (the frame being built next) 2-7, no pause
            # text (paused), no flip pending
            if not 2 <= b("scroll_fine") <= 7 or b("flip_pending") or b("paused"):
                continue
            scr = m.peek(0x4400 if b("front_buf") else 0x4000, 1000)
            col = m.peek(0xd800, 1000)
            cc = m.peek(s["CHAR_COL"], 256)
            checked += 1
            for i, ch in enumerate(scr):
                if turbo and ch >= 232:
                    continue
                if (col[i] & 15) != (cc[ch] & 15):
                    bad += 1
                    if bad <= 5:
                        print(f"frame {f}: row {i // 40} col {i % 40}: char {ch} wants colour {cc[ch] & 15}, colour RAM has {col[i] & 15}")
    finally:
        m.quit(); p.kill()
    print(f"level {a.level}: {checked} screens checked, {bad} wrong cells: {'OK' if not bad and checked else 'FAILED'}")
    sys.exit(0 if not bad and checked else 1)

if __name__ == "__main__":
    main()
