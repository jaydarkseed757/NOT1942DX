#!/usr/bin/env python3
"""level1_art.py - draws data/levels/level1.png (+ level1_anim.png, .json):
"Open Ocean", tropical islands on a deep blue sea.

    python3 tools/art/level1_art.py [seed]

A starting point for the art, not its master copy: the PNG is the source of
truth, so hand edits to it are lost if this is run again.

How it draws:
  - Islands are noisy blobs on the char-corner grid. Each corner is water,
    sand or grass (grass always inside sand). Inside a char cell the pixel
    colour comes from the corners, blended bilinearly: grass, then sand,
    then a ring of cyan surf on the water side. Shared corners make the
    coast continuous from cell to cell, and the corner states keep the
    number of different chars small.
  - Island interiors get grass texture and 2x2-char palm trees.
  - Open sea gets a few wave marks, in several variants, laid out as one
    OCEAN_PERIOD-row texture repeated up the level: the map packer then
    finds it again and again (random waves everywhere would pack ~4x worse).
  - Clouds: a few cumulus shapes (white, dithered edges), stamped over open
    sea between the islands, never over land. Reusing whole shapes at char
    positions keeps their chars shared.
  - The top ROWS - BOSS_ROW rows are open sea only: they loop during the
    boss fight.
  - Animations: the waves roll, and the surf on the commonest coast chars
    pulses (the surf ring's width goes in and out).
Colours: bg blue, mc1 light green (grass), mc2 yellow (sand); each char may
add one of cyan (surf, waves), green (palm leaves, grass texture) or white
(wave crests).
"""
import json, os, random, sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "levels")
sys.path.insert(0, os.path.join(ROOT, "tools"))
from c64gfx import PEPTO

W, ROWS, BOSS_ROW = 40, 588, 576
OCEAN_PERIOD = 48                       # rows: well inside the 4 KB packing window
BG, MC1, MC2 = 6, 13, 7                 # blue, light green, yellow
CYAN, GREEN, WHITE = 3, 5, 1
WATER, SAND, GRASS = 0, 1, 2
SURF = (0.30, 0.50)                     # blended sand value: surf ring on the water side

rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 else 1942)


def islands():
    """Corner grid [ROWS + 1][W + 1] of WATER / SAND / GRASS."""
    g = [[WATER] * (W + 1) for _ in range(ROWS + 1)]
    r = 30                                       # time rows from the bottom
    while r < BOSS_ROW - 20:
        cx = rng.uniform(4, W - 4)
        rx = rng.uniform(3.5, 9.0)
        ry = rx * rng.uniform(0.75, 1.15)       # chars are 8x8 px: round is rx = ry
        cy = r + ry + 1
        if cy + ry + 2 >= BOSS_ROW - 4:
            break
        bumps = [(rng.uniform(0, 6.28), rng.uniform(0.0, 0.14), rng.randint(2, 3)) for _ in range(2)]
        import math
        for y in range(int(cy - ry - 2), int(cy + ry + 3)):
            for x in range(W + 1):
                dx, dy = (x - cx) / rx, (y - cy) / ry
                d = math.hypot(dx, dy)
                ang = math.atan2(dy, dx)
                wob = 1 + sum(a * math.sin(k * ang + p) for p, a, k in bumps)
                if 0 <= y <= ROWS:
                    if d < 0.62 * wob:
                        g[y][x] = GRASS
                    elif d < 1.0 * wob and g[y][x] == WATER:
                        g[y][x] = SAND
        r = int(cy + ry) + rng.randint(18, 40)  # open sea between: islands are
        if rng.random() < 0.3:                  #   the costly part of a pack
            r -= int(ry * 2) + 2                # (sometimes two side by side)
    return g


CLOUD_SHAPES = 3


def cloud_shape(w, h):
    """A cumulus, w x h chars: [h * 8][w * 4] of None / WHITE / CYAN / BG.
    Built in screen pixels (a fat pixel is 2 wide): a flat base with round
    ends, and 2-3 round lobes on top. The rim is dithered. The bottom char
    row is the shaded underside: own colour cyan instead of white (one own
    colour per char), with a dithered line where it meets the white."""
    import math
    W2, H2 = w * 8, h * 8                         # screen pixels
    base = H2 - 1.0
    rb = H2 * 0.30                                # the base: a capsule
    bx0, bx1, by = rb + 1, W2 - rb - 1, base - rb
    lobes = []
    n = 3 if w >= 9 else 2
    for k in range(n):
        t = (k + 0.5) / n
        r = H2 * rng.uniform(0.34, 0.44) * (1.15 if k == n // 2 else 1.0)
        x = W2 * (0.18 + 0.64 * t) + rng.uniform(-3, 3)
        x = min(max(x, r + 1), W2 - r - 1)
        y = max(r + 1, by - r * rng.uniform(0.3, 0.7))
        lobes.append((x, y, r))
    def depth(sx, sy):                            # > 0 inside, in pixels
        if sy > base:
            return -1
        px = min(max(sx, bx0), bx1)               # capsule: distance to its spine
        d = rb - math.hypot(sx - px, sy - by)
        if bx0 <= sx <= bx1 and sy >= by:
            d = max(d, base - sy + 1.0)           # flat underneath
        return max([d] + [r - math.hypot(sx - x, sy - y) for x, y, r in lobes])
    under = H2 - 8                                # first pixel row of the underside
    out = []
    for y in range(H2):
        row = []
        for fx in range(w * 4):
            d = depth(fx * 2 + 1, y + 0.5)
            col = CYAN if y >= under else WHITE
            if d <= 0:
                row.append(None)
            elif d < 1.8 or y == under - 1:       # rim, and the shading line
                row.append(col if (fx + y) % 2 == 0 else BG)
            else:
                row.append(col)
        out.append(row)
    return out


def cell_pixels(c, surf=SURF):
    """4x8 colour indices for one cell from its corners (tl, tr, bl, br)."""
    tl, tr, bl, br = c
    sand = [1.0 if v >= SAND else 0.0 for v in c]
    grass = [1.0 if v >= GRASS else 0.0 for v in c]
    out = []
    for y in range(8):
        fy = (y + 0.5) / 8
        row = []
        for x in range(4):
            fx = (x + 0.5) / 4
            def bil(v):
                return (v[0] * (1 - fx) * (1 - fy) + v[1] * fx * (1 - fy) +
                        v[2] * (1 - fx) * fy + v[3] * fx * fy)
            s, gr = bil(sand), bil(grass)
            if gr > 0.5:
                row.append(MC1)
            elif s > 0.5:
                row.append(MC2)
            elif s > surf[0]:
                row.append(CYAN)
            else:
                row.append(BG)
        out.append(row)
    return out


GRASS_TEX = [  # 4x8 masks: 'g' = texture pixel (own green) on light green
    ["....", "..g.", "....", "....", "g...", "....", "...g", "...."],
    ["....", "....", ".g..", "....", "....", "..g.", "....", "...."],
    ["....", "....", "....", "....", "....", "....", "....", "...."],
]
PALM = [  # 8x16 (2x2 chars): 'G' green leaves, 'y' sand trunk, '.' grass
    "..GG....", ".GGGG.G.", "GG.GGGGG", "G.GGGG.G", "..GGGG..", ".G.yy.G.", "...y....", "...y....",
    "....y...", "....y...", "....y...", "...y....", "...y....", "..yyy...", "........", "........",
]
WAVES = [  # 4x8: 'c' cyan crest, 'w' white cap
    ["....", ".cc.", "c..c", "....", "....", "....", "....", "...."],
    ["....", "....", "....", "....", ".cc.", "c..c", "....", "...."],
    ["....", "....", ".ww.", "w..w", "....", "....", "....", "...."],
    ["....", "....", "....", "....", "....", ".cc.", "c..c", "...."],
]
WAVE_COL = {"c": CYAN, "w": WHITE}


def main():
    g = islands()
    img = [[BG] * 160 for _ in range(ROWS * 8)]      # image rows, top = last time row
    def put(r, cx, pix):                             # time row r, char column cx
        iy = (ROWS - 1 - r) * 8
        for y in range(8):
            for x in range(4):
                img[iy + y][cx * 4 + x] = pix[y][x]
    used = set()
    ocean = [[(rng.choice(WAVES) if rng.random() < 0.07 else None) for _ in range(W)]
             for _ in range(OCEAN_PERIOD)]
    # cells: corners of time row r are g[r] (bottom) and g[r + 1] (top)
    for r in range(ROWS):
        for cx in range(W):
            c = (g[r + 1][cx], g[r + 1][cx + 1], g[r][cx], g[r][cx + 1])
            if all(v == WATER for v in c):
                wv = ocean[r % OCEAN_PERIOD][cx] if r < BOSS_ROW else ocean[(r - BOSS_ROW) % 6][cx]
                if wv:
                    put(r, cx, [[WAVE_COL.get(ch, BG) for ch in row] for row in wv])
                continue
            if all(v == GRASS for v in c):
                tex = GRASS_TEX[(cx + 2 * r) % 3]   # a pattern, not random: it packs
                put(r, cx, [[GREEN if ch == "g" else MC1 for ch in row] for row in tex])
                continue
            put(r, cx, cell_pixels(c))
    # palms: 2x2 chars on all-grass cells
    for r in range(1, ROWS - 1):
        for cx in range(0, W - 1):
            if rng.random() > 0.35:
                continue
            ok = all(all(v == GRASS for v in (g[rr + 1][xx], g[rr + 1][xx + 1], g[rr][xx], g[rr][xx + 1]))
                     for rr in (r, r - 1) for xx in (cx, cx + 1))
            if not ok or (r, cx) in used or (r, cx + 1) in used or (r - 1, cx) in used or (r - 1, cx + 1) in used:
                continue
            for rr, half in ((r, 0), (r - 1, 1)):            # r = the palm's top char row
                for xx, hx in ((cx, 0), (cx + 1, 1)):
                    pix = [[{"G": GREEN, "y": MC2}.get(PALM[half * 8 + y][hx * 4 + x], MC1)
                            for x in range(4)] for y in range(8)]
                    put(rr, xx, pix)
                    used.add((rr, xx))
    # clouds: whole shapes over open sea (cells all water, with a margin)
    shapes = [cloud_shape(w, h) for w, h in ((10, 4), (7, 3), (12, 5))[:CLOUD_SHAPES]]
    def sea(r0, r1, c0, c1):
        return all(g[y][x] == WATER for y in range(max(r0, 0), min(r1, ROWS) + 1)
                   for x in range(max(c0, 0), min(c1, W) + 1))
    clouds, r = 0, 34
    while r < BOSS_ROW - 12:
        sh = rng.choice(shapes)
        h, w = len(sh) // 8, len(sh[0]) // 4
        for _ in range(12):
            cx0 = rng.randint(-w // 3, W - w + w // 3)
            if sea(r - 1, r + h + 1, cx0 - 1, cx0 + w + 1):
                break
        else:
            r += 3
            continue
        for j in range(h):                           # shape row j: time row r + h - 1 - j
            for i in range(w):
                cx = cx0 + i
                if not 0 <= cx < W:
                    continue
                pix = [[sh[j * 8 + y][i * 4 + x] for x in range(4)] for y in range(8)]
                if any(p is not None for row in pix for p in row):
                    put(r + h - 1 - j, cx, [[BG if p is None else p for p in row] for row in pix])
        clouds += 1
        r += h + rng.randint(22, 40)
    # write the picture
    im = Image.new("RGB", (160, ROWS * 8))
    px = im.load()
    for y in range(ROWS * 8):
        for x in range(160):
            px[x, y] = PEPTO[img[y][x]]
    im.save(os.path.join(OUT, "level1.png"))

    # animation strip: waves roll, and the commonest coast chars' surf pulses
    def cell_of(r, cx):
        iy = (ROWS - 1 - r) * 8
        return tuple(tuple(img[iy + y][cx * 4 + x] for x in range(4)) for y in range(8))
    counts = {}
    corners_of = {}
    for r in range(ROWS):
        for cx in range(W):
            c = (g[r + 1][cx], g[r + 1][cx + 1], g[r][cx], g[r][cx + 1])
            if len(set(c)) > 1:
                key = cell_of(r, cx)
                if CYAN in [p for row in key for p in row]:
                    counts[key] = counts.get(key, 0) + 1
                    corners_of[key] = c
    rows, specs = [], []
    for wv in WAVES[:2]:
        base = [[WAVE_COL.get(ch, BG) for ch in row] for row in wv]
        ys = [y for y, row in enumerate(base) if any(p != BG for p in row)]
        a, b = ys[0], ys[-1]
        flat = [list(row) for row in base]
        flat[a] = [BG] * 4
        flat[b] = [BG, CYAN, CYAN, BG]
        trough = [list(row) for row in base]
        trough[a], trough[b] = base[b], base[a]
        rows.append([base, flat, trough, flat])
        specs.append({"frames": 4, "delay": 11 + len(rows)})
    for key, _ in sorted(counts.items(), key=lambda kv: -kv[1])[:16 - len(rows)]:
        c = corners_of[key]
        frames = [cell_pixels(c, (s, 0.5)) for s in (0.30, 0.24, 0.30, 0.38)]
        rows.append(frames)
        specs.append({"frames": 4, "delay": 7})
    strip = Image.new("RGB", (160, 8 * len(rows)), PEPTO[BG])
    sp = strip.load()
    for r, frames in enumerate(rows):
        for k, f in enumerate(frames):
            for y in range(8):
                for x in range(4):
                    sp[k * 4 + x, r * 8 + y] = PEPTO[f[y][x]]
    strip.save(os.path.join(OUT, "level1_anim.png"))
    cfg = {"png": "level1.png", "label": "level1", "bg": "blue", "mc1": "lgreen", "mc2": "yellow",
           "boss_row": BOSS_ROW, "anim": {"png": "level1_anim.png", "rows": specs}}
    json.dump(cfg, open(os.path.join(OUT, "level1.json"), "w"), indent=1)
    print(f"level1_art: {clouds} clouds, {len(rows)} animations")


if __name__ == "__main__":
    main()
