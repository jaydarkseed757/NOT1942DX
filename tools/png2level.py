#!/usr/bin/env python3
"""png2level.py - turn a level picture into level pack data for the game.

Usage:  python3 tools/png2level.py data/levels/levelN.json build/gen/levelN.asm

The JSON names the picture, its shared colours and its boss row:
    {"png": "level1.png", "label": "level1",
     "bg": "blue", "mc1": "lgreen", "mc2": "brown", "boss_row": 576}
(colours by name, see tools/c64gfx.py, or 0-15).

THE PICTURE
  - Multicolour, 160 pixels wide (or 320 with every pixel doubled), each
    pixel one double-wide C64 pixel; any height that is a whole number of
    char rows (8 pixels).
  - It is the whole level as you see it, top to bottom: the game starts at
    the BOTTOM of the picture and scrolls up through it (row 0 = the bottom
    char row). When row boss_row scrolls in the boss comes, and the rows
    from boss_row to the top then repeat until it is beaten, so that part
    should join up seamlessly with itself.
  - Every 4x8-pixel char cell may use the three shared colours (bg = $D021,
    mc1 = $D022, mc2 = $D023) plus ONE more colour, 0-7 (colour RAM).
  - At most 192 different char cells (codes 64-255).

THE OUTPUT (ACME source; LZ streams in the format of tools/c64gfx.py)
  <label>_chars_lz  char bitmaps, unpacked to char codes 64 and up
  <label>_cols_lz   each char's colour RAM value (colour | 8 = multicolour)
  <label>_map_lz    the char map, 40 codes per row, bottom row first; the game
                    unpacks it a row at a time through a 4 KB ring buffer,
                    so its matches reach back at most RING_SIZE - 1 bytes
  <label>_loop_lz   rows boss_row to the top again, packed on their own: the
                    unpacker carries on with it after the map, and over again
  and constants <LABEL>_CHARS, _ROWS (char rows), _BOSS_ROW, _BG, _MC1, _MC2.
Fails with a message naming the cell if the picture breaks the C64's limits.
"""
import json, os, sys
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c64gfx import ColourMatcher, colour_index, lz_pack, lz_unpack, asm_bytes, NAMES

FIRST_CHAR = 64
MAX_CHARS = 256 - FIRST_CHAR
COLS = 40
RING_SIZE = 4096                         # src/scroll.asm: the map's ring buffer
MAX_ANIMS = 16                           # src/anim.asm: ANIM_MAX


def fail(msg):
    sys.exit("png2level: " + msg)


def load_pixels(path, match):
    im = Image.open(path).convert("RGB")
    w, h = im.size
    px = im.load()
    if w == 320:
        for y in range(h):
            for x in range(0, 320, 2):
                if px[x, y] != px[x + 1, y]:
                    fail(f"{path}: 320-wide pictures need every pixel doubled (x {x}, y {y})")
        get = lambda x, y: match(px[2 * x, y])
    elif w == 160:
        get = lambda x, y: match(px[x, y])
    else:
        fail(f"{path}: must be 160 (or 320, doubled) pixels wide, not {w}")
    if h % 8:
        fail(f"{path}: height {h} isn't a whole number of char rows (8 pixels)")
    return [[get(x, y) for x in range(160)] for y in range(h)]


def read_cell(pix, cx, cy, shared, where):
    """The char cell at column cx, char row cy -> (8 bitmap bytes, own colour).
    The own colour is 0 when the cell has no %11 pixels."""
    extra, bits = set(), []
    for y in range(8):
        v = 0
        for x in range(4):
            c = pix[cy * 8 + y][cx * 4 + x]
            if c in shared:
                p = shared[c]
            else:
                extra.add(c)
                p = 3
            v = v << 2 | p
        bits.append(v)
    if len(extra) > 1:
        fail(f"{where}char cell at column {cx}, char row {cy} (pixel {cx*4},{cy*8}) uses "
             f"{len(extra)} colours besides bg/mc1/mc2: "
             + ", ".join(NAMES[c] for c in sorted(extra)) + " (only one allowed)")
    colour = extra.pop() if extra else 0
    if colour > 7:
        fail(f"{where}char cell at column {cx}, char row {cy} (pixel {cx*4},{cy*8}): its own "
             f"colour {NAMES[colour]} must be one of the first 8 (black..yellow)")
    return (tuple(bits), colour)


def read_anims(cfg, base, shared, match, char_index, chars):
    """The optional animation strip (cfg["anim"]) -> [(code, mode, delay, frames)].
    Row r of the strip is animation r: cell 0 is a char of the level, cells
    1.. its other frames (cfg["anims"][r]: frames, delay, mode)."""
    anim = cfg.get("anim")
    if not anim:
        return []
    pix = load_pixels(os.path.join(base, anim["png"]), match)
    out = []
    for r, spec in enumerate(anim["rows"]):
        where = f"{anim['png']}: "
        first = read_cell(pix, 0, r, shared, where)
        if first not in char_index:
            fail(f"{where}row {r}: its first cell isn't a char of the level picture")
        code = char_index[first]
        mode = spec.get("mode", "frames")
        delay = int(spec.get("delay", 8))
        if not 1 <= delay <= 255:
            fail(f"{where}row {r}: delay must be 1-255 frames")
        if mode in ("scroll", "scroll_down"):
            frames = [first]
        elif mode == "frames":
            n = int(spec["frames"])
            if not 2 <= n <= COLS:
                fail(f"{where}row {r}: 2-{COLS} frames")
            frames = [read_cell(pix, k, r, shared, where) for k in range(n)]
        else:
            fail(f"{where}row {r}: mode must be frames, scroll or scroll_down")
        own = {c for bits, c in frames if any((b >> s) & 3 == 3 for b in bits for s in (0, 2, 4, 6))}
        if len(own) > 1:
            fail(f"{where}row {r}: its frames use different own colours (one char, one colour RAM colour)")
        if own:                          # the char's colour RAM colour must suit all frames
            colour = own.pop()
            bits0, c0 = chars[code - FIRST_CHAR]
            if any((b >> s) & 3 == 3 for b in bits0 for s in (0, 2, 4, 6)) and c0 != colour:
                fail(f"{where}row {r}: its frames' own colour differs from the char's")
            chars[code - FIRST_CHAR] = (bits0, colour)
        out.append((code, {"frames": 0, "scroll": 1, "scroll_down": 2}[mode], delay,
                    [bits for bits, _ in frames]))
    if len(out) > MAX_ANIMS:
        fail(f"{len(out)} animations; a level can have at most {MAX_ANIMS}")
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    cfg_path, out_path = sys.argv[1:]
    cfg = json.load(open(cfg_path))
    base = os.path.dirname(cfg_path)
    label = cfg["label"]
    shared = {colour_index(cfg["bg"]): 0, colour_index(cfg["mc1"]): 1, colour_index(cfg["mc2"]): 2}
    if len(shared) != 3:
        fail(f"{cfg_path}: bg, mc1 and mc2 must be three different colours")
    match = ColourMatcher()
    pix = load_pixels(os.path.join(base, cfg["png"]), match)
    for rgb, c in match.far.items():
        print(f"png2level: warning: colour {rgb} is far from any C64 colour, using {NAMES[c]}",
              file=sys.stderr)
    h = len(pix)
    rows = h // 8

    # --- cells -> chars (bitmap, colour), deduplicated ---
    char_index, chars = {}, []           # key -> code
    grid = []                            # [image row][col] -> char code
    for cy in range(rows):
        line = []
        for cx in range(COLS):
            key = read_cell(pix, cx, cy, shared, "")
            if key not in char_index:
                char_index[key] = FIRST_CHAR + len(chars)
                chars.append(key)
            line.append(char_index[key])
        grid.append(line)
    if len(chars) > MAX_CHARS:
        fail(f"{len(chars)} different chars; a level can have at most {MAX_CHARS}")

    anims = read_anims(cfg, base, shared, match, char_index, chars)

    # --- the char map in time order (bottom row first), and its loop ---
    boss = int(cfg["boss_row"])
    if not 0 < boss < rows:
        fail(f"{cfg_path}: boss_row {boss} must be inside the picture (1-{rows - 1})")
    order = [grid[rows - 1 - r] for r in range(rows)]
    map_raw = bytes(c for line in order for c in line)
    loop_raw = bytes(c for line in order[boss:] for c in line)

    chars_raw = bytes(b for bits, _ in chars for b in bits)
    cols_raw = bytes((c | 8) for _, c in chars)
    packs = {}
    for name, raw, window in (("chars", chars_raw, 65535), ("cols", cols_raw, 65535),
                              ("map", map_raw, RING_SIZE - 1), ("loop", loop_raw, RING_SIZE - 1)):
        packed = lz_pack(raw, window=window)
        assert lz_unpack(packed) == raw, name
        packs[name] = (raw, packed)

    up = label.upper()
    out = [f"; {out_path}: generated by tools/png2level.py from {cfg_path}. Don't edit.",
           f"{up}_CHARS    = {len(chars)}",
           f"{up}_ROWS     = {rows}",
           f"{up}_BOSS_ROW = {boss}",
           f"{up}_BG       = {colour_index(cfg['bg'])}",
           f"{up}_MC1      = {colour_index(cfg['mc1'])}",
           f"{up}_MC2      = {colour_index(cfg['mc2'])}"]
    for name in ("chars", "cols", "map", "loop"):
        raw, packed = packs[name]
        out.append(f"\n{label}_{name}_lz     ; {len(raw)} bytes, packed {len(packed)}")
        out.append(asm_bytes(packed))
    # animations (src/anim.asm): count, then per animation: char code, mode
    # (0 = frames, 1 = scroll, 2 = scroll_down), delay, frame count, frames x
    # 8 bitmap bytes
    out.append(f"\n{label}_anims      ; {len(anims)} animated chars")
    out.append(f"        !byte {len(anims)}")
    for code, mode, delay, frames in anims:
        out.append(f"        !byte {code}, {mode}, {delay}, {len(frames)}")
        out.append(asm_bytes(bytes(b for f in frames for b in f)))
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    open(out_path, "w").write("\n".join(out) + "\n")
    total = sum(len(p) for _, p in packs.values())
    print(f"png2level: {label}: {rows} rows, {len(chars)} chars, {len(anims)} animated, "
          f"packed {total} bytes (map {len(packs['map'][1])}, loop {len(packs['loop'][1])})")


if __name__ == "__main__":
    main()
