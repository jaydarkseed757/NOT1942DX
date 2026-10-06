#!/usr/bin/env python3
"""level2_art.py - draws data/levels/level2.png (+ level2_anim.png, .json):
"Jungle Coast", a jungle shore with rivers, an airstrip and a village.

    python3 tools/art/level2_art.py [seed]

A starting point for the art, not its master copy: the PNG is the source of
truth, so hand edits to it are lost if this is run again.

How it draws:
  - The land is a corner grid (like level1_art.py): each char corner is sea,
    beach or jungle, and a cell's pixels blend its four corners, so coasts
    and river banks run on smoothly from cell to cell.
  - The coast runs up the level on the left; the jungle gets two rivers
    across it, an airstrip and a village clearing.
  - The jungle canopy is a periodic texture of round tree crowns (light
    green tops, black shadows) repeating every CANOPY_W x CANOPY_H chars,
    so the map packer finds it again and again. Cells on a coast or bank
    use one plain variant instead: textured coasts multiply the chars.
  - The sea gets a periodic texture of wave marks and a few clouds.
  - The top ROWS - BOSS_ROW rows are open sea only: they loop during the
    boss fight.
  - One own colour per char: where a cell would need two (sand next to
    surf, say), the less important one gives way (OWN_RANK).
Colours: bg light blue (sea), mc1 green, mc2 light green (jungle); own
colours yellow (sand), white (surf, waves, clouds), black (shadows, parked
planes), red (roofs), cyan (cloud undersides, wave troughs).
"""
import json, math, os, random, sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "levels")
sys.path.insert(0, os.path.join(ROOT, "tools"))
from c64gfx import PEPTO

W, ROWS, BOSS_ROW = 40, 588, 576
SEA_PERIOD = 48                         # rows: inside the 4 KB packing window
CANOPY_W, CANOPY_H = 4, 2               # chars: the canopy texture's period
BG, MC1, MC2 = 14, 5, 13                # light blue, green, light green
BLACK, WHITE, RED, CYAN, YELLOW = 0, 1, 2, 3, 7
SEA, BEACH, JUNGLE = 0, 1, 2
SURF = 0.30                             # blended beach value: surf on the sea side
OWN_RANK = [YELLOW, RED, WHITE, CYAN, BLACK]   # who keeps a contested cell
GIVE_WAY = {BLACK: MC1, WHITE: BG, CYAN: BG, RED: MC1, YELLOW: MC2}

rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 1943)


# ---------------------------------------------------------------- the land
def coast_x(r):
    """The coastline's column at time row r (fractional): narrow at the
    start and the end, wide in the middle."""
    t = r / BOSS_ROW
    body = 6 + 24 * math.sin(math.pi * min(1.0, t * 1.15)) ** 0.8
    body -= max(0, r - 470) * 0.14          # bends away left before the boss
    return body + 3.0 * math.sin(r / 31.0 + 1.0)   # slow bends: rows repeat


def land():
    """Corner grid [ROWS + 1][W + 1] of SEA / BEACH / JUNGLE, and the
    features: rivers [(row, ...)], the airstrip and the village."""
    g = [[SEA] * (W + 1) for _ in range(ROWS + 1)]
    for r in range(ROWS + 1):
        if r >= BOSS_ROW - 6:
            continue
        cx = coast_x(r)
        for x in range(W + 1):
            if x < cx - 1.0:
                g[r][x] = JUNGLE
            elif x < cx + 0.6:
                g[r][x] = BEACH
    # rivers: winding bands of sea from the left edge to the coast, with
    # sand banks
    rivers = []
    for r0, amp in ((168, 3.0), (432, 4.0)):
        rivers.append(r0)
        for x in range(W + 1):
            mid = r0 + amp * math.sin(x / 5.0) + 0.06 * x * x / 10
            for r in range(int(mid - 4), int(mid + 5)):
                if not 0 <= r <= ROWS or g[r][x] == SEA:
                    continue
                d = abs(r - mid)
                if d < 1.3:
                    g[r][x] = SEA
                elif d < 2.4 and g[r][x] == JUNGLE:
                    g[r][x] = BEACH
    return g, rivers


def cell_kind(g, r, cx):
    return (g[r + 1][cx], g[r + 1][cx + 1], g[r][cx], g[r][cx + 1])


def blend(c):
    """4x8 terrain values for a cell from its corners (tl, tr, bl, br):
    'j' jungle, 's' sand, 'f' surf, '.' sea."""
    beach = [1.0 if v >= BEACH else 0.0 for v in c]
    jung = [1.0 if v >= JUNGLE else 0.0 for v in c]
    out = []
    for y in range(8):
        fy = (y + 0.5) / 8
        row = ""
        for x in range(4):
            fx = (x + 0.5) / 4
            bil = lambda v: (v[0] * (1 - fx) * (1 - fy) + v[1] * fx * (1 - fy) +
                             v[2] * (1 - fx) * fy + v[3] * fx * fy)
            b, j = bil(beach), bil(jung)
            row += "j" if j > 0.5 else "s" if b > 0.5 else "f" if b > SURF else "."
        out.append(row)
    return out


# ---------------------------------------------------------------- textures
CROWNS = [  # 8x8 fat pixels each: 'l' light green, 'g' green, 'b' black
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


def canopy_texture():
    """The canopy tile: CANOPY_W x CANOPY_H chars of tree crowns, as colour
    indices [CANOPY_H * 8][CANOPY_W * 4]: two rows of crowns, the second
    shifted half a crown, lit from the top left."""
    H, Wd = CANOPY_H * 8, CANOPY_W * 4
    col = {"l": MC2, "g": MC1, "b": BLACK}
    tex = [[BLACK] * Wd for _ in range(H)]
    for band in range(H // 8):
        shift = 4 * band
        for k in range(Wd // 8):
            crown = CROWNS[(k + band) % len(CROWNS)]
            for y in range(8):
                for x in range(8):
                    tex[band * 8 + y][(k * 8 + x + shift) % Wd] = col[crown[y][x]]
    return tex


CANOPY = canopy_texture()

WAVES = [  # 4x8: 'w' white crest, 'c' cyan trough (dark side)
    ["....", ".ww.", "w..w", "....", "....", "....", "....", "...."],
    ["....", "....", "....", "....", ".ww.", "w..w", "....", "...."],
    ["....", "....", ".cc.", "c..c", "....", "....", "....", "...."],
]
WAVE_COL = {"w": WHITE, "c": CYAN}

HUT = [  # 8x16 (2 chars wide, 2 rows): a red roof, its black shadow below
    "........",
    "...rr...",
    "..rrrr..",
    ".rrrrrr.",
    "rrrrrrrr",
    "rrrrrrrr",
    "rrrrrrrr",
    "........",
    "bbbbbbbb",
    ".bbbbbb.",
    "........",
    "........",
    "........",
    "........",
    "........",
    "........",
]
PLANE = [  # 8x16 (2 chars wide, 2 rows): a parked plane, nose up, in black
    "...bb...",
    "...bb...",
    "...bb...",
    "bbbbbbbb",
    "bbbbbbbb",
    "...bb...",
    "...bb...",
    "...bb...",
    "..bbbb..",
    "........",
    "........",
    "........",
    "........",
    "........",
    "........",
    "........",
]


def stamp(put, r, cx, art, cols):
    """Draw art (8 * 2 wide x 8 * n tall, its top on time row r) over grass."""
    for j in range(len(art) // 8):
        for half in (0, 1):
            put(r - j, cx + half, [[cols.get(art[j * 8 + y][half * 4 + x], MC2)
                                   for x in range(4)] for y in range(8)])


def cloud_shape(w, h):
    """A cumulus, w x h chars, like level 1's: None / WHITE / CYAN / BG."""
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
            col = CYAN if y >= under else WHITE
            if d <= 0:
                row.append(None)
            elif d < 1.8 or y == under - 1:
                row.append(col if (fx + y) % 2 == 0 else BG)
            else:
                row.append(col)
        out.append(row)
    return out


# ---------------------------------------------------------------- drawing
def main():
    g, rivers = land()
    img = [[BG] * 160 for _ in range(ROWS * 8)]
    def put(r, cx, pix):                     # time row r, char column cx
        iy = (ROWS - 1 - r) * 8
        for y in range(8):
            for x in range(4):
                img[iy + y][cx * 4 + x] = pix[y][x]
    def canopy_cell(r, cx, plain=False):
        if plain:                            # one variant for coasts and banks
            return [[MC1 if (x + y) % 5 else MC2 for x in range(4)] for y in range(8)]
        ty = (CANOPY_H - 1 - r % CANOPY_H) * 8   # time rows run up the image
        tx = (cx % CANOPY_W) * 4
        return [[CANOPY[ty + y][tx + x] for x in range(4)] for y in range(8)]
    sea_tex = [[(rng.choice(WAVES) if rng.random() < 0.035 else None) for _ in range(W)]
               for _ in range(SEA_PERIOD)]

    for r in range(ROWS):
        for cx in range(W):
            c = cell_kind(g, r, cx)
            if all(v == SEA for v in c):
                wv = sea_tex[r % SEA_PERIOD][cx] if r < BOSS_ROW else sea_tex[(r - BOSS_ROW) % 6][cx]
                if wv:
                    put(r, cx, [[WAVE_COL.get(ch, BG) for ch in row] for row in wv])
                continue
            if all(v == JUNGLE for v in c):
                put(r, cx, canopy_cell(r, cx))
                continue
            tv = blend(c)
            jung = canopy_cell(r, cx, plain=True)
            put(r, cx, [[{"j": jung[y][x], "s": YELLOW, "f": WHITE, ".": BG}[tv[y][x]]
                         for x in range(4)] for y in range(8)])

    def jungle_rect(r0, r1, c0, c1):
        return all(g[r][x] == JUNGLE for r in range(r0, r1 + 1) for x in range(c0, c1 + 1))

    # the airstrip: a sand strip up the jungle with a dashed centre line,
    # a grass apron on its left with planes parked on it
    strip = None
    for c0 in sorted(range(3, 16), key=lambda c: abs(c - 8)):
        if jungle_rect(232, 352, c0 - 1, c0 + 6):
            strip = c0
            break
    if strip is not None:
        for r in range(236, 348):
            for cx in (strip, strip + 1, strip + 4):   # apron, shoulder
                put(r, cx, [[MC2] * 4 for _ in range(8)])
            for cx in (strip + 2, strip + 3):
                dash = r % 3 == 0
                edge = 3 if cx == strip + 2 else 0      # the centre line
                put(r, cx, [[MC1 if dash and x == edge else YELLOW
                             for x in range(4)] for y in range(8)])
        for r in range(258, 340, 20):
            stamp(put, r, strip, PLANE, {"b": BLACK})

    # the village: a clearing (rounded) with huts and a gun pit
    village = None
    for c0 in sorted(range(3, 16), key=lambda c: abs(c - 8)):
        if jungle_rect(372, 392, c0 - 2, c0 + 11):
            village = c0
            break
    if village is not None:
        for r in range(374, 391):
            for cx in range(village, village + 9):
                corner = (r in (374, 390)) and cx in (village, village + 8)
                if not corner:
                    put(r, cx, [[MC2] * 4 for _ in range(8)])
        for r, cx in ((388, village + 1), (387, village + 5), (382, village + 2),
                      (381, village + 6), (377, village + 4)):
            stamp(put, r, cx, HUT, {"r": RED, "b": BLACK})
        put(377, village + 1, [[BLACK if 1 <= x <= 2 and 2 <= y <= 5 else MC2
                                for x in range(4)] for y in range(8)])   # gun pit

    # clouds: whole shapes over open sea
    shapes = [cloud_shape(w, h) for w, h in ((9, 4), (7, 3))]
    def open_sea(r0, r1, c0, c1):
        return all(g[y][x] == SEA for y in range(max(r0, 0), min(r1, ROWS) + 1)
                   for x in range(max(c0, 0), min(c1, W) + 1))
    clouds, r = 0, 40
    while r < BOSS_ROW - 12:
        sh = rng.choice(shapes)
        h, w = len(sh) // 8, len(sh[0]) // 4
        for _ in range(12):
            cx0 = rng.randint(0, W - w + w // 3)
            if open_sea(r - 1, r + h + 1, cx0 - 1, cx0 + w + 1):
                break
        else:
            r += 4
            continue
        for j in range(h):
            for i in range(w):
                cx = cx0 + i
                if not 0 <= cx < W:
                    continue
                pix = [[sh[j * 8 + y][i * 4 + x] for x in range(4)] for y in range(8)]
                if any(p is not None for row in pix for p in row):
                    put(r + h - 1 - j, cx, [[BG if p is None else p for p in row] for row in pix])
        clouds += 1
        r += h + rng.randint(40, 70)

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
    im.save(os.path.join(OUT, "level2.png"))

    # animation strip: the white wave crests roll; the commonest coast
    # chars' surf pulses
    def cell_of(r, cx):
        iy = (ROWS - 1 - r) * 8
        return tuple(tuple(img[iy + y][cx * 4 + x] for x in range(4)) for y in range(8))
    rows, specs = [], []
    for wv in WAVES[:2]:
        base = [[WAVE_COL.get(ch, BG) for ch in row] for row in wv]
        ys = [y for y, row in enumerate(base) if any(p != BG for p in row)]
        a, b = ys[0], ys[-1]
        flat = [list(row) for row in base]
        flat[a] = [BG] * 4
        flat[b] = [BG, WHITE, WHITE, BG]
        trough = [list(row) for row in base]
        trough[a], trough[b] = base[b], base[a]
        rows.append([base, flat, trough, flat])
        specs.append({"frames": 4, "delay": 11 + len(rows)})
    counts = {}
    for r in range(ROWS):
        for cx in range(W):
            key = cell_of(r, cx)
            flat = [p for row in key for p in row]
            if WHITE in flat and YELLOW not in flat and (BG in flat) and (MC1 in flat or MC2 in flat):
                counts[key] = counts.get(key, 0) + 1
    for key, _ in sorted(counts.items(), key=lambda kv: -kv[1])[:16 - len(rows)]:
        base = [list(row) for row in key]
        thin = [[BG if p == WHITE and (x + y) % 2 else p for x, p in enumerate(row)]
                for y, row in enumerate(base)]
        rows.append([base, thin, base, [[p for p in row] for row in base]])
        specs.append({"frames": 4, "delay": 9})
    strip_im = Image.new("RGB", (160, 8 * len(rows)), PEPTO[BG])
    sp = strip_im.load()
    for r, frames in enumerate(rows):
        for k, f in enumerate(frames):
            for y in range(8):
                for x in range(4):
                    sp[k * 4 + x, r * 8 + y] = PEPTO[f[y][x]]
    strip_im.save(os.path.join(OUT, "level2_anim.png"))
    cfg = {"png": "level2.png", "label": "level2", "bg": "lblue", "mc1": "green", "mc2": "lgreen",
           "boss_row": BOSS_ROW, "anim": {"png": "level2_anim.png", "rows": specs}}
    json.dump(cfg, open(os.path.join(OUT, "level2.json"), "w"), indent=1)
    print(f"level2_art: rivers at {rivers}, airstrip col {strip}, village col {village}, "
          f"{clouds} clouds, {len(rows)} animations")


if __name__ == "__main__":
    main()
