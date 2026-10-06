#!/usr/bin/env python3
"""level3_art.py - draws data/levels/level3.png (+ level3_anim.png, .json):
"Sunset Strait", a winding strait between sunlit cliffs.

    python3 tools/art/level3_art.py [seed]

A starting point for the art, not its master copy: the PNG is the source of
truth, so hand edits to it are lost if this is run again.

How it draws:
  - The land is a corner grid (like level1_art.py and level2_art.py): each
    char corner is sea or rock, and a cell's pixels blend its four corners,
    so the shores run on smoothly, with a ring of surf on the water side.
  - Open sea at the start; cliffs close in from both sides into a winding
    strait; it opens out again before the boss. The shores bend slowly, so
    rows repeat and the map packs small.
  - The cliffs are a periodic rock texture (sunlit orange tops, brown faces,
    black cracks) repeating every ROCK_W x ROCK_H chars; shore cells use one
    plain variant instead.
  - The water gets sun glints (periodic), anchored boats, and a few clouds
    lit by the sunset; a lighthouse blinks on a headland and gun pits sit on
    the right-hand cliffs.
  - The top ROWS - BOSS_ROW rows are open sea only: they loop during the
    boss fight.
  - One own colour per char: where a cell would need two, the less
    important one gives way (OWN_RANK).
Colours: bg purple (the sunset sea), mc1 brown, mc2 orange (rock); own
colours white (surf, sparkles), yellow (sun glints, lamps, cloud tops),
black (cracks, hulls, gun pits).
"""
import json, math, os, random, sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "levels")
sys.path.insert(0, os.path.join(ROOT, "tools"))
from c64gfx import PEPTO

W, ROWS, BOSS_ROW = 40, 588, 576
SEA_PERIOD = 48                         # rows: inside the 4 KB packing window
ROCK_W, ROCK_H = 4, 2                   # chars: the rock texture's period
BG, MC1, MC2 = 4, 9, 8                  # purple, brown, orange
BLACK, WHITE, YELLOW = 0, 1, 7
SEA, ROCK = 0, 1
OWN_RANK = [YELLOW, WHITE, BLACK]       # who keeps a contested cell
GIVE_WAY = {BLACK: MC1, WHITE: BG, YELLOW: MC2}

rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 1944)


# ---------------------------------------------------------------- the land
def shores(r):
    """The left and right shore columns at time row r (fractional)."""
    def smooth(a, b, x):                 # 0 before a, 1 after b
        t = min(1.0, max(0.0, (x - a) / (b - a)))
        return t * t * (3 - 2 * t)
    f = smooth(24, 90, r) * (1 - smooth(500, 556, r))   # how closed the strait is
    c = 20 + 5.5 * math.sin(r / 70.0) + 2.0 * math.sin(r / 29.0 + 1.0)
    w = 9.5 + 3.0 * math.sin(r / 47.0 + 2.0)
    return f * (c - w) + (1 - f) * -8, f * (c + w) + (1 - f) * 48


def land():
    g = [[SEA] * (W + 1) for _ in range(ROWS + 1)]
    for r in range(ROWS + 1):
        lx, rx = shores(r)
        for x in range(W + 1):
            if x < lx or x > rx:
                g[r][x] = ROCK
    return g


def cell_kind(g, r, cx):
    return (g[r + 1][cx], g[r + 1][cx + 1], g[r][cx], g[r][cx + 1])


def blend(c):
    """4x8 terrain for a cell from its corners: 'r' rock, 'f' surf, '.' sea."""
    out = []
    for y in range(8):
        fy = (y + 0.5) / 8
        row = ""
        for x in range(4):
            fx = (x + 0.5) / 4
            v = (c[0] * (1 - fx) * (1 - fy) + c[1] * fx * (1 - fy) +
                 c[2] * (1 - fx) * fy + c[3] * fx * fy)
            row += "r" if v > 0.5 else "f" if v > 0.3 else "."
        out.append(row)
    return out


# ---------------------------------------------------------------- textures
LUMPS = [  # 8x8 fat pixels each: 'l' sunlit orange, 'g' brown, 'b' black crack
    ["bbllggbb",
     "bllllggb",
     "llllgggg",
     "lllggggg",
     "llgggggb",
     "gggggggb",
     "bggggbbb",
     "bbgbbbbb"],
    ["bblllgbb",
     "bllllggb",
     "lllllggb",
     "lllggggg",
     "lggggggg",
     "bgggggbb",
     "bbgggbbb",
     "bbbgbbbb"],
]


def rock_texture():
    """The rock tile: ROCK_W x ROCK_H chars of lumpy boulders lit from the
    top left (the same layout as level 2's tree crowns, in rock colours)."""
    H, Wd = ROCK_H * 8, ROCK_W * 4
    col = {"l": MC2, "g": MC1, "b": BLACK}
    tex = [[BLACK] * Wd for _ in range(H)]
    for band in range(H // 8):
        shift = 4 * band
        for k in range(Wd // 8):
            lump = LUMPS[(k + band) % len(LUMPS)]
            for y in range(8):
                for x in range(8):
                    tex[band * 8 + y][(k * 8 + x + shift) % Wd] = col[lump[y][x]]
    return tex


ROCKTEX = rock_texture()

GLINTS = [  # 4x8: 'y' yellow sun glint, 'o' orange ripple, 'w' white sparkle
    ["....", ".yy.", "....", "....", "....", "....", "....", "...."],
    ["....", "....", "....", "....", "yyy.", "....", "....", "...."],
    ["....", "....", ".oo.", "o..o", "....", "....", "....", "...."],
    ["....", "....", "....", "....", "....", ".w..", "....", "...."],
]
GLINT_COL = {"y": YELLOW, "o": MC2, "w": WHITE}

BOAT = [  # 8x16 (2 chars wide, 2 rows): an anchored boat, bow up
    "...bb...",
    "..bOOb..",
    "..bOOb..",
    ".bOggOb.",
    ".bOggOb.",
    ".bOggOb.",
    ".bOggOb.",
    ".bOOOOb.",
    "..bOOb..",
    "...bb...",
    "........",
    "........",
    "........",
    "........",
    "........",
    "........",
]
LAMP_ON = [  # 4x8: the lighthouse from above: a round tower, its lamp lit
    ".gg.",
    "gOOg",
    "OyyO",
    "OyyO",
    "OyyO",
    "OyyO",
    "gOOg",
    ".gg.",
]
GUN_PIT = [  # 4x8: a gun pit on the cliff top
    "....",
    ".bb.",
    "bggb",
    "bgbb",
    "bbgb",
    "bggb",
    ".bb.",
    "....",
]
ART_COL = {"b": BLACK, "O": MC2, "g": MC1, "y": YELLOW, "w": WHITE}


def cloud_shape(w, h):
    """A cumulus lit by the sunset, w x h chars: None / colour. Orange body,
    yellow sunlit rim, brown underside (one own colour: yellow)."""
    W2, H2 = w * 8, h * 8
    base = H2 - 1.0
    rb = H2 * 0.30
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
    def depth(sx, sy):
        if sy > base:
            return -1
        px = min(max(sx, bx0), bx1)
        d = rb - math.hypot(sx - px, sy - by)
        if bx0 <= sx <= bx1 and sy >= by:
            d = max(d, base - sy + 1.0)
        return max([d] + [r - math.hypot(sx - x, sy - y) for x, y, r in lobes])
    under = H2 - 8
    out = []
    for y in range(H2):
        row = []
        for fx in range(w * 4):
            d = depth(fx * 2 + 1, y + 0.5)
            if d <= 0:
                row.append(None)
            elif y >= under:
                row.append(MC1 if d >= 1.8 or (fx + y) % 2 == 0 else BG)
            elif d < 1.8:
                row.append(YELLOW if (fx + y) % 2 == 0 else BG)   # lit rim
            else:
                row.append(MC2)
        out.append(row)
    return out


# ---------------------------------------------------------------- drawing
def main():
    g = land()
    img = [[BG] * 160 for _ in range(ROWS * 8)]
    def put(r, cx, pix):                     # time row r, char column cx
        iy = (ROWS - 1 - r) * 8
        for y in range(8):
            for x in range(4):
                img[iy + y][cx * 4 + x] = pix[y][x]
    def rock_cell(r, cx, plain=False):
        if plain:                            # one variant for shores
            return [[MC1 if (x + y) % 5 else MC2 for x in range(4)] for y in range(8)]
        ty = (ROCK_H - 1 - r % ROCK_H) * 8   # time rows run up the image
        tx = (cx % ROCK_W) * 4
        return [[ROCKTEX[ty + y][tx + x] for x in range(4)] for y in range(8)]
    def art(rows, h, w):
        return [[ART_COL.get(rows[h * 8 + y][w * 4 + x], BG) for x in range(4)] for y in range(8)]
    sea_tex = [[(rng.choice(GLINTS) if rng.random() < 0.04 else None) for _ in range(W)]
               for _ in range(SEA_PERIOD)]

    for r in range(ROWS):
        for cx in range(W):
            c = cell_kind(g, r, cx)
            if all(v == SEA for v in c):
                gl = sea_tex[r % SEA_PERIOD][cx] if r < BOSS_ROW else sea_tex[(r - BOSS_ROW) % 6][cx]
                if gl:
                    put(r, cx, [[GLINT_COL.get(ch, BG) for ch in row] for row in gl])
                continue
            if all(v == ROCK for v in c):
                put(r, cx, rock_cell(r, cx))
                continue
            tv = blend(c)
            rk = rock_cell(r, cx, plain=True)
            put(r, cx, [[{"r": rk[y][x], "f": WHITE, ".": BG}[tv[y][x]]
                         for x in range(4)] for y in range(8)])

    def all_kind(kind, r0, r1, c0, c1):
        return all(0 <= x <= W and g[r][x] == kind for r in range(r0, r1 + 1) for x in range(c0, c1 + 1))

    # anchored boats in the strait, away from the shores
    boats = []
    for r0 in (128, 236, 318, 404, 470):
        lx, rx = shores(r0)
        for cx in sorted(range(int(lx) + 3, int(rx) - 3), key=lambda c: abs(c - (lx + rx) / 2 + 3)):
            if all_kind(SEA, r0 - 3, r0 + 1, cx - 1, cx + 3):
                for h in (0, 1):
                    for w in (0, 1):
                        put(r0 - h, cx + w, art(BOAT, h, w))
                boats.append((r0, cx))
                break

    # the lighthouse on the left shore, near the water; gun pits on the right
    lamp = None
    for r0 in range(206, 240):
        lx, _ = shores(r0)
        cx = int(lx) - 3
        if cx >= 1 and all_kind(ROCK, r0 - 1, r0 + 2, cx - 1, cx + 2):
            put(r0, cx, [[ART_COL.get(ch, MC1) for ch in row] for row in LAMP_ON])
            lamp = (r0, cx)
            break
    pits = 0
    for r0 in (334, 338, 342):
        _, rx = shores(r0)
        cx = int(rx) + 3
        if cx <= W - 2 and all_kind(ROCK, r0 - 1, r0 + 1, cx - 1, cx + 2):
            put(r0, cx, [[ART_COL.get(ch, MC1) for ch in row] for row in GUN_PIT])
            pits += 1

    # clouds: whole shapes over open water
    shapes = [cloud_shape(w, h) for w, h in ((9, 4), (7, 3))]
    clouds, r = 0, 40
    while r < BOSS_ROW - 12:
        sh = rng.choice(shapes)
        h, w = len(sh) // 8, len(sh[0]) // 4
        for _ in range(12):
            cx0 = rng.randint(0, W - w)
            if all_kind(SEA, r - 1, r + h + 1, cx0 - 1, cx0 + w + 1):
                break
        else:
            r += 4
            continue
        for j in range(h):
            for i in range(w):
                pix = [[sh[j * 8 + y][i * 4 + x] for x in range(4)] for y in range(8)]
                if any(p is not None for row in pix for p in row):
                    put(r + h - 1 - j, cx0 + i, [[BG if p is None else p for p in row] for row in pix])
        clouds += 1
        r += h + rng.randint(45, 75)

    # one own colour per cell: the less important ones give way
    shared = {BG, MC1, MC2}
    for cy in range(ROWS):
        for cx in range(W):
            own = {img[cy * 8 + y][cx * 4 + x] for y in range(8) for x in range(4)} - shared
            if len(own) < 2:
                continue
            keep = min(own, key=OWN_RANK.index)
            for y in range(8):
                for x in range(4):
                    p = img[cy * 8 + y][cx * 4 + x]
                    if p not in shared and p != keep:
                        img[cy * 8 + y][cx * 4 + x] = GIVE_WAY[p]

    im = Image.new("RGB", (160, ROWS * 8))
    px = im.load()
    for y in range(ROWS * 8):
        for x in range(160):
            px[x, y] = PEPTO[img[y][x]]
    im.save(os.path.join(OUT, "level3.png"))

    # animation strip: the glints shimmer, the lighthouse blinks, and the
    # commonest shore chars' surf pulses
    def cell_of(r, cx):
        iy = (ROWS - 1 - r) * 8
        return [[img[iy + y][cx * 4 + x] for x in range(4)] for y in range(8)]
    rows, specs = [], []
    for gl in GLINTS[:2]:
        base = [[GLINT_COL.get(ch, BG) for ch in row] for row in gl]
        dim = [[MC2 if p == YELLOW else p for p in row] for row in base]
        off = [[BG for p in row] for row in base]
        rows.append([base, dim, off, dim])
        specs.append({"frames": 4, "delay": 9 + len(rows)})
    if lamp:
        on = cell_of(*lamp)
        dark = [[MC1 if p == YELLOW else p for p in row] for row in on]
        rows.append([on, on, dark, dark])
        specs.append({"frames": 4, "delay": 12})
    counts = {}
    for r in range(ROWS):
        for cx in range(W):
            key = tuple(tuple(row) for row in cell_of(r, cx))
            flat = [p for row in key for p in row]
            if WHITE in flat and BG in flat and (MC1 in flat or MC2 in flat):
                counts[key] = counts.get(key, 0) + 1
    for key, _ in sorted(counts.items(), key=lambda kv: -kv[1])[:16 - len(rows)]:
        base = [list(row) for row in key]
        thin = [[BG if p == WHITE and (x + y) % 2 else p for x, p in enumerate(row)]
                for y, row in enumerate(base)]
        rows.append([base, thin, base, base])
        specs.append({"frames": 4, "delay": 8})
    strip = Image.new("RGB", (160, 8 * len(rows)), PEPTO[BG])
    sp = strip.load()
    for r, frames in enumerate(rows):
        for k, f in enumerate(frames):
            for y in range(8):
                for x in range(4):
                    sp[k * 4 + x, r * 8 + y] = PEPTO[f[y][x]]
    strip.save(os.path.join(OUT, "level3_anim.png"))
    cfg = {"png": "level3.png", "label": "level3", "bg": "purple", "mc1": "brown", "mc2": "orange",
           "boss_row": BOSS_ROW, "anim": {"png": "level3_anim.png", "rows": specs}}
    json.dump(cfg, open(os.path.join(OUT, "level3.json"), "w"), indent=1)
    print(f"level3_art: {len(boats)} boats, lighthouse {lamp}, {pits} gun pits, "
          f"{clouds} clouds, {len(rows)} animations")


if __name__ == "__main__":
    main()
