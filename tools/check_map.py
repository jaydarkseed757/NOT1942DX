#!/usr/bin/env python3
"""check_map.py - check that the game scrolls a level's picture exactly.

Builds a test build that starts at level N (invincible, not firing, so the
boss never dies and its loop keeps going), runs it headless in x64sc, and at
every few scroll steps compares all 25 rows of the screen buffer being shown
with the char rows of data/levels/levelN.png, as tools/png2level.py numbers
the chars. It runs past the top of the picture into the boss loop.

Usage:  python3 tools/check_map.py [N ...]      (default: all four levels)
        [--steps 700] [--every 7]
Needs acme, x64sc and Pillow. Exit status 1 on any mismatch.
"""
import argparse, json, os, subprocess, sys, tempfile, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image
from c64gfx import ColourMatcher, colour_index
from vicemon import Mon, start, symbols

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCROLL_ROWS = 25
SCREEN = (0x4000, 0x4400)            # SCREEN_A, SCREEN_B


def char_grid(n):
    """The level picture's char codes per row, numbered like png2level.py."""
    cfg = json.load(open(f"{ROOT}/data/levels/level{n}.json"))
    shared = {colour_index(cfg["bg"]): 0, colour_index(cfg["mc1"]): 1, colour_index(cfg["mc2"]): 2}
    im = Image.open(f"{ROOT}/data/levels/{cfg['png']}").convert("RGB")
    px, match = im.load(), ColourMatcher()
    if im.size[0] == 320:
        get = lambda x, y: match(px[2 * x, y])
    else:
        get = lambda x, y: match(px[x, y])
    rows, index, grid = im.size[1] // 8, {}, []
    for cy in range(rows):
        line = []
        for cx in range(40):
            bits, extra = [], set()
            for y in range(8):
                v = 0
                for x in range(4):
                    c = get(cx * 4 + x, cy * 8 + y)
                    if c in shared:
                        p = shared[c]
                    else:
                        extra.add(c)
                        p = 3
                    v = v << 2 | p
                bits.append(v)
            key = (tuple(bits), extra.pop() if extra else 0)
            index.setdefault(key, 64 + len(index))
            line.append(index[key])
        grid.append(line)
    return grid, rows, cfg["boss_row"]


def check(n, steps, every):
    grid, rows, boss = char_grid(n)
    record = lambda t: t if t < rows else boss + (t - boss) % (rows - boss)
    tmp = tempfile.mkdtemp(prefix="dxmap")
    prg, sym = os.path.join(tmp, "m.prg"), os.path.join(tmp, "m.sym")
    subprocess.run(["acme", "-f", "cbm", "-DAUTOSTART=1", "-DINVINCIBLE=1", f"-DSTART_LEVEL={n}",
                    "-l", sym, "-o", prg, "src/main.asm"], cwd=ROOT, check=True)
    s = symbols(sym)
    emu = start(prg)
    mon = Mon()
    checked = bad = 0
    try:
        mon.cmd(f"break {s['next_record']:04x}")     # the prefill, then once per step (f = 0)
        for t in range(SCROLL_ROWS + steps):
            mon.cmd("x")
            if t < SCROLL_ROWS or t % every:
                continue
            row = mon.word(s["lvl_row"])
            if row != record(t):
                print(f"level {n}: step {t}: lvl_row is {row}, expected {record(t)}")
                bad += 1
            scr = mon.peek(SCREEN[mon.peek(s["front_buf"])[0]], SCROLL_ROWS * 40)
            for k in range(SCROLL_ROWS):          # screen row k = the row before it in time
                want = grid[rows - 1 - record(t - 1 - k)]
                checked += 1
                if list(scr[k * 40:(k + 1) * 40]) != want:
                    bad += 1
                    if bad <= 3:
                        print(f"level {n}: step {t}: screen row {k} isn't picture row {record(t - 1 - k)}")
    finally:
        mon.quit()
        time.sleep(0.3)
        emu.kill()
    print(f"level {n}: {checked} screen rows checked up to step {SCROLL_ROWS + steps - 1} "
          f"({rows} rows, boss loop from {boss}): {'OK' if not bad else f'{bad} MISMATCHES'}")
    return bad == 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("levels", nargs="*", type=int, default=[1, 2, 3, 4])
    ap.add_argument("--steps", type=int, default=700, help="scroll steps to run")
    ap.add_argument("--every", type=int, default=7, help="check every Nth step")
    a = ap.parse_args()
    subprocess.run(["make", "gen"], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    ok = all([check(n, a.steps, a.every) for n in a.levels])
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
