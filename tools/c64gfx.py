"""c64gfx.py - shared helpers for the asset tools.

- C64 colours: names, the Pepto PAL palette used when we write PNGs, and
  colour matching for PNGs drawn with other common palettes.
- lz_pack: the level pack compressor. src/unpack.asm is its 6502 unpacker.

LZ FORMAT (byte stream, unpacked front to back):
  $00-$7F  t       literal run: the next t + 1 bytes are copied (1-128)
  $80-$FE  t lo hi match: copy (t & $7F) + 3 bytes (3-129) from
                   `distance` = hi * 256 + lo bytes back in the output
                   (overlapping copies repeat, as in LZ77)
  $FF              end of stream
"""

NAMES = ["black", "white", "red", "cyan", "purple", "green", "blue", "yellow",
         "orange", "brown", "lred", "dgrey", "grey", "lgreen", "lblue", "lgrey"]

# Pepto's PAL palette (VICE pepto-pal.vpl): what the tools write.
PEPTO = [
    (0x00, 0x00, 0x00), (0xFF, 0xFF, 0xFF), (0x68, 0x37, 0x2B), (0x70, 0xA4, 0xB2),
    (0x6F, 0x3D, 0x86), (0x58, 0x8D, 0x43), (0x35, 0x28, 0x79), (0xB8, 0xC7, 0x6F),
    (0x6F, 0x4F, 0x25), (0x43, 0x39, 0x00), (0x9A, 0x67, 0x59), (0x44, 0x44, 0x44),
    (0x6C, 0x6C, 0x6C), (0x9A, 0xD2, 0x84), (0x6C, 0x5E, 0xB5), (0x95, 0x95, 0x95),
]
# Colodore (VICE colodore.vpl), another common choice in paint programs.
COLODORE = [
    (0x00, 0x00, 0x00), (0xFF, 0xFF, 0xFF), (0x81, 0x33, 0x38), (0x75, 0xCE, 0xC8),
    (0x8E, 0x3C, 0x97), (0x56, 0xAC, 0x4D), (0x2E, 0x2C, 0x9B), (0xED, 0xF1, 0x71),
    (0x8E, 0x50, 0x29), (0x55, 0x38, 0x00), (0xC4, 0x6C, 0x71), (0x4A, 0x4A, 0x4A),
    (0x7B, 0x7B, 0x7B), (0xA9, 0xFF, 0x9F), (0x70, 0x6D, 0xEB), (0xB2, 0xB2, 0xB2),
]
PALETTES = [PEPTO, COLODORE]


def colour_index(name_or_number):
    """'lgreen' or 13 or '13' -> 13."""
    if isinstance(name_or_number, int):
        return name_or_number
    s = str(name_or_number).strip().lower()
    if s.isdigit():
        return int(s)
    return NAMES.index(s)


class ColourMatcher:
    """RGB -> C64 colour 0-15. Exact matches in any known palette first,
    then the nearest Pepto colour; far-off colours are reported."""

    def __init__(self, tolerance=40):
        self.exact = {}
        for pal in PALETTES:
            for i, rgb in enumerate(pal):
                self.exact.setdefault(rgb, i)
        self.cache = {}
        self.tolerance = tolerance
        self.far = {}

    def __call__(self, rgb):
        rgb = tuple(rgb[:3])
        if rgb in self.cache:
            return self.cache[rgb]
        if rgb in self.exact:
            c = self.exact[rgb]
        else:
            best = None
            for pal in PALETTES:
                for i, p in enumerate(pal):
                    d = sum((a - b) ** 2 for a, b in zip(rgb, p)) ** 0.5
                    if best is None or d < best[0]:
                        best = (d, i)
            c = best[1]
            if best[0] > self.tolerance:
                self.far[rgb] = c
        self.cache[rgb] = c
        return c


def lz_pack(data, window=65535, max_len=129, min_len=3):
    """Compress bytes into the LZ format above (greedy, with one step of
    lazy matching). Matches reach back at most `window` bytes (the level
    maps are unpacked through a 4 KB ring, so they use 4095). Data is small,
    so a hash chain is plenty."""
    data = bytes(data)
    n = len(data)
    out = bytearray()
    lit = bytearray()
    chains = {}

    def flush():
        while lit:
            chunk = lit[:128]
            out.append(len(chunk) - 1)
            out.extend(chunk)
            del lit[:128]

    def longest(i):
        best_len, best_dist = 0, 0
        if i + min_len > n:
            return 0, 0
        key = data[i:i + min_len]
        for j in reversed(chains.get(key, [])[-64:]):
            dist = i - j
            if dist > window:
                break
            k = 0
            while k < max_len and i + k < n and data[j + k] == data[i + k]:
                k += 1
            if k > best_len:
                best_len, best_dist = k, dist
                if k == max_len:
                    break
        return best_len, best_dist

    def add(i):
        if i + min_len <= n:
            chains.setdefault(data[i:i + min_len], []).append(i)

    i = 0
    while i < n:
        length, dist = longest(i)
        if length >= min_len:
            nlen, _ = longest(i + 1) if i + 1 < n else (0, 0)
            if nlen > length + 1:          # lazy: a literal now buys a longer match
                lit.append(data[i])
                add(i)
                i += 1
                continue
            flush()
            out.append(0x80 + length - 3)
            out.append(dist & 0xFF)
            out.append(dist >> 8)
            for k in range(length):
                add(i + k)
            i += length
        else:
            lit.append(data[i])
            add(i)
            i += 1
    flush()
    out.append(0xFF)
    return bytes(out)


def lz_unpack(packed):
    """Reference unpacker (the tools check every pack against it)."""
    out = bytearray()
    i = 0
    while True:
        t = packed[i]
        i += 1
        if t == 0xFF:
            return bytes(out)
        if t < 0x80:
            out.extend(packed[i:i + t + 1])
            i += t + 1
        else:
            length = (t & 0x7F) + 3
            dist = packed[i] | packed[i + 1] << 8
            i += 2
            for _ in range(length):
                out.append(out[-dist])


def asm_bytes(data, indent="        ", per_line=16):
    """Bytes as ACME !byte lines."""
    lines = []
    for k in range(0, len(data), per_line):
        lines.append(indent + "!byte " + ", ".join("$%02x" % b for b in data[k:k + per_line]))
    return "\n".join(lines)
