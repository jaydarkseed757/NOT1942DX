#!/usr/bin/env python3
"""level4_art.py - draws data/levels/level4.png (+ level4_anim.png, .json):
"Enemy Fleet", warships steaming north through a storm-grey sea.

    python3 tools/art/level4_art.py [seed]

A starting point for the art, not its master copy: the PNG is the source of
truth, so hand edits to it are lost if this is run again.

How it draws:
  - The sea is one texture, SEA_W chars wide and one char tall, repeated
    over every open cell: swell crests, troughs and a few white caps. Its
    chars are animated "scroll_down" (src/anim.asm), so the water moves
    faster than the map and the ships, which are drawn on the map, seem to
    steam forward through it. Every sea row is the same, so the map packs
    to almost nothing but the ships.
  - Ships (destroyers, cruisers, a carrier) are stamps, bow up, with foam
    along their hulls and a white V wake. They sit on a few even columns,
    so a class seen again at the same column packs as a copy of the rows
    already sent. Cells with a ship in them don't animate: the foam
    hides that.
  - The top ROWS - BOSS_ROW rows are open sea only: they loop during the
    boss fight.
Colours: bg dark grey (the sea), mc1 black, mc2 grey (troughs, crests,
decks); own colour white (caps, foam, wakes, bridges), one per char.
"""
import json, os, random, sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "levels")
sys.path.insert(0, os.path.join(ROOT, "tools"))
from c64gfx import PEPTO

W, ROWS, BOSS_ROW = 40, 588, 576
SEA_W = 2                               # chars: the sea texture's width (both
                                        #   chars rotate together, ANIM_PER_FRAME)
BG, MC1, MC2 = 11, 0, 12                # dark grey, black, grey
WHITE = 1

rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 1945)

# The sea tile: SEA_W chars x 1 row, as fat-pixel rows ('.' bg, 'b' trough,
# 'g' crest, 'w' cap). It wraps both ways.
SEA = [
    "........",
    ".gg.....",
    "...bb...",
    "........",
    "......w.",
    "........",
    ".....gg.",
    "b......b",
]
SEA_COL = {".": BG, "b": MC1, "g": MC2, "w": WHITE}


# ---------------------------------------------------------------- ships
def ship(w, h, kind):
    """A warship, bow up: [h * 8 rows][w * 4] of None / colour, its hull
    outlined in black, foam ('w') along the sides, a wake behind. kind is
    'destroyer', 'cruiser' or 'carrier'."""
    W4, H8 = w * 4, h * 8
    wake = 20 if kind != "carrier" else 24          # pixel rows of wake
    hull_h = H8 - wake
    g = [[None] * W4 for _ in range(H8)]
    cx = (W4 - 1) / 2.0
    half = (W4 - 4) / 2.0                           # hull half-width, fat px
    def hull_half(y):                               # pointed bow, square stern
        bow = 10 if kind != "carrier" else 6
        if y < bow:
            return half * (y + 1) / bow
        if y > hull_h - 4:
            return half - 0.5
        return half
    for y in range(hull_h):
        hw = hull_half(y)
        for x in range(W4):
            d = abs(x - cx)
            if d <= hw - 0.5:
                g[y][x] = MC2                       # deck
            elif d <= hw + 0.5:
                g[y][x] = MC1                       # hull side
            elif d <= hw + 1.5 and y > 2:
                g[y][x] = WHITE if (y + x) % 3 else None   # foam along the side
    # wake: a white V widening behind the stern
    for k in range(wake):
        y = hull_h + k
        spread = half - 1 + k * 0.35
        for x in range(W4):
            d = abs(x - cx)
            if abs(d - spread) < 0.8 and (k + x) % 2 == 0:
                g[y][x] = WHITE
            elif d < 1.0 and k < 8:
                g[y][x] = WHITE                     # the screw's churn
    def box(x0, y0, x1, y1, c):
        for y in range(y0, y1):
            for x in range(x0, x1):
                g[y][x] = c
    mid = int(cx)
    if kind == "carrier":
        box(1, 4, W4 - 1, hull_h - 2, MC2)          # the flight deck
        for y in range(6, hull_h - 4, 4):           # its centre line, dashed
            g[y][mid] = WHITE
            g[y + 1][mid] = WHITE
        box(W4 - 4, hull_h // 2 - 8, W4 - 2, hull_h // 2 + 4, MC1)   # the island
        g[hull_h // 2 - 6][W4 - 3] = WHITE
        for y0 in range(hull_h - 30, hull_h - 6, 8):   # planes parked aft
            for x0 in (2, 6):
                if x0 + 3 >= W4 - 4:
                    continue
                g[y0][x0 + 1] = MC1
                box(x0, y0 + 1, x0 + 3, y0 + 2, MC1)
                g[y0 + 2][x0 + 1] = MC1
    else:
        turrets = [10, 16] if kind == "destroyer" else [12, 19, hull_h - 12]
        for ty in turrets:                          # turrets, barrels forward
            box(mid - 1, ty, mid + 2, ty + 3, MC1)
            g[ty + 1][mid] = MC2
            g[ty - 1][mid] = MC1
            g[ty - 2][mid] = MC1
        by = turrets[-1 if kind == "destroyer" else 1] + 6
        box(mid - 1, by, mid + 2, by + 4, WHITE)    # bridge
        g[by + 1][mid] = MC1
        for fy in (by + 7, by + 12):                # funnels
            if fy + 3 < hull_h - 4:
                box(mid - 1, fy, mid + 1, fy + 3, MC1)
    return g


# ---------------------------------------------------------------- drawing
def main():
    img = [[BG] * 160 for _ in range(ROWS * 8)]
    def put(r, cx, pix):                     # time row r, char column cx
        iy = (ROWS - 1 - r) * 8
        for y in range(8):
            for x in range(4):
                img[iy + y][cx * 4 + x] = pix[y][x]
    def sea_cell(cx):
        tx = (cx % SEA_W) * 4
        return [[SEA_COL[SEA[y][tx + x]] for x in range(4)] for y in range(8)]

    for r in range(ROWS):
        for cx in range(W):
            put(r, cx, sea_cell(cx))

    classes = {"destroyer": ship(2, 9, "destroyer"), "cruiser": ship(3, 13, "cruiser"),
               "carrier": ship(4, 21, "carrier")}
    # the fleet: (bottom row, class, column); columns even (the sea's period)
    fleet = []
    taken = []
    def free(r0, h, c0, w):
        return all(r0 + h + 3 < a or a + b + 3 < r0 or c0 + w + 1 < c or c + d + 1 < c0
                   for a, b, c, d in taken)
    plan = ([("destroyer", 34), ("destroyer", 46), ("cruiser", 68), ("destroyer", 92),
             ("destroyer", 104), ("cruiser", 128), ("destroyer", 152), ("cruiser", 166),
             ("carrier", 196), ("destroyer", 200), ("destroyer", 206),   # escorts
             ("destroyer", 244), ("cruiser", 262), ("destroyer", 286), ("destroyer", 300),
             ("cruiser", 322), ("destroyer", 346), ("carrier", 378), ("destroyer", 382),
             ("destroyer", 388), ("cruiser", 424), ("destroyer", 446), ("destroyer", 460),
             ("cruiser", 482), ("destroyer", 506), ("cruiser", 524), ("destroyer", 550)])
    cols = [4, 10, 16, 22, 28, 34]
    for kind, r0 in plan:
        sh = classes[kind]
        h, w = len(sh) // 8, len(sh[0]) // 4
        if r0 + h >= BOSS_ROW - 2:
            continue
        for c0 in sorted(cols, key=lambda c: rng.random()):
            if c0 + w <= W and free(r0, h, c0, w):
                break
        else:
            continue
        taken.append((r0, h, c0, w))
        for j in range(h):                       # stamp row j: time row r0 + h - 1 - j
            for i in range(w):
                pix = [[sh[j * 8 + y][i * 4 + x] for x in range(4)] for y in range(8)]
                if any(p is not None for row in pix for p in row):
                    put(r0 + h - 1 - j, c0 + i, [[BG if p is None else p for p in row] for row in pix])
        fleet.append((kind, r0, c0))

    # storm clouds over open water: grey, black underneath, white edges
    def cloud(w, h):
        import math
        W2, H2 = w * 8, h * 8
        base = H2 - 1.0
        lobes = []
        for k in range(3):
            t = (k + 0.5) / 3
            rr = H2 * rng.uniform(0.32, 0.45)
            lobes.append((W2 * (0.2 + 0.6 * t), max(rr + 1, base - rr * 0.6), rr))
        out = []
        for y in range(H2):
            row = []
            for fx in range(w * 4):
                sx, sy = fx * 2 + 1, y + 0.5
                d = max(rr - math.hypot(sx - x, sy - yy) for x, yy, rr in lobes)
                d = min(d, base - sy + 1.0)
                if d <= 0:
                    row.append(None)
                elif d < 1.6:
                    row.append(WHITE if (fx + y) % 2 == 0 else BG)
                elif y >= H2 - 8:
                    row.append(MC1)
                else:
                    row.append(MC2)
            out.append(row)
        return out
    clouds = 0
    for r0 in (60, 140, 230, 316, 410, 500):
        sh = cloud(rng.choice((8, 10)), 4)
        h, w = len(sh) // 8, len(sh[0]) // 4
        for c0 in sorted(range(0, W - w + 1, 2), key=lambda c: rng.random()):
            if free(r0, h, c0, w):
                break
        else:
            continue
        taken.append((r0, h, c0, w))
        for j in range(h):
            for i in range(w):
                pix = [[sh[j * 8 + y][i * 4 + x] for x in range(4)] for y in range(8)]
                if any(p is not None for row in pix for p in row):
                    put(r0 + h - 1 - j, c0 + i, [[BG if p is None else p for p in row] for row in pix])
        clouds += 1

    im = Image.new("RGB", (160, ROWS * 8))
    px = im.load()
    for y in range(ROWS * 8):
        for x in range(160):
            px[x, y] = PEPTO[img[y][x]]
    im.save(os.path.join(OUT, "level4.png"))

    # animation strip: the sea's chars scroll down together, one pixel
    # every 2 frames (1.5 pixels a frame on screen: faster than the ships)
    rows, specs = [], []
    for cx in range(SEA_W):
        rows.append([sea_cell(cx)])
        specs.append({"mode": "scroll_down", "delay": 2})
    strip = Image.new("RGB", (160, 8 * len(rows)), PEPTO[BG])
    sp = strip.load()
    for r, frames in enumerate(rows):
        for k, f in enumerate(frames):
            for y in range(8):
                for x in range(4):
                    sp[k * 4 + x, r * 8 + y] = PEPTO[f[y][x]]
    strip.save(os.path.join(OUT, "level4_anim.png"))
    cfg = {"png": "level4.png", "label": "level4", "bg": "dgrey", "mc1": "black", "mc2": "grey",
           "boss_row": BOSS_ROW, "anim": {"png": "level4_anim.png", "rows": specs}}
    json.dump(cfg, open(os.path.join(OUT, "level4.json"), "w"), indent=1)
    print(f"level4_art: {len(fleet)} ships ({', '.join(k for k, _, _ in fleet)}), "
          f"{clouds} clouds, {len(rows)} animations")


if __name__ == "__main__":
    main()
