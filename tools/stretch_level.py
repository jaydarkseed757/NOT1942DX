#!/usr/bin/env python3
"""stretch_level.py - stretch a NOT 1942 level stream 2:3 for DX's scroll speed.

NOT 1942 scrolled one char row every 12 frames; DX scrolls one pixel per
frame, a row every 8. To keep each level's length and its spawn timing, every
pair of records gets one extra record: a plain copy (no spawns) of whichever
of the two rows is least likely to look wrong when doubled. A row's score is
the number of columns where it differs from both its neighbours, so island
edges (which differ from both) score high and island interiors or open sea
score low. The copy goes right after the row it copies.

Spawns stay on their own records, so a spawn on old record r lands on new
record 1.5 r (+-1): the same time in frames. Records after +boss_here (the
boss loop) are stretched the same way.

Usage:  python3 tools/stretch_level.py data/level1.asm [more levels...]
Rewrites each file in place. Run it once per level: running it again
stretches again. Then check: python3 tools/check_waves.py data/levelN.asm
"""
import re, sys

ROW = re.compile(r"^(\s+)\+row\s+(\w+)\s*(;.*)?$")
ROW_SPAWN = re.compile(r"^(\s+)\+row_spawn\s+(\w+),\s*(\d+)")
SPAWN = re.compile(r"^\s+\+spawn\s")
PATDEF = re.compile(r"^(\w+)\s*=\s*\(\*\s*-\s*\w+\)\s*/\s*COLS")
ROWPAT = re.compile(r'^\s+\+rowpat\s+"(.*)"')

def stretch(path):
    lines = open(path).read().split("\n")

    # row pattern texts by name
    pats, name = {}, None
    for line in lines:
        m = PATDEF.match(line)
        if m:
            name = m.group(1)
            continue
        m = ROWPAT.match(line)
        if m and name:
            pats[name] = m.group(1)
            name = None

    start = next(i for i, l in enumerate(lines) if re.match(r"^\s+\+level_start", l))
    end = next(i for i, l in enumerate(lines) if re.match(r"^\s+\+level_end", l))

    # records: (first line, last line, pattern name, indent)
    recs, i = [], start + 1
    while i < end:
        m = ROW.match(lines[i])
        if m:
            recs.append((i, i, m.group(2), m.group(1)))
            i += 1
            continue
        m = ROW_SPAWN.match(lines[i])
        if m:
            n, j = int(m.group(3)), i + 1
            while n:
                if SPAWN.match(lines[j]):
                    n -= 1
                j += 1
            recs.append((i, j - 1, m.group(2), m.group(1)))
            i = j
            continue
        i += 1

    def score(k):
        txt = pats[recs[k][2]]
        prev = pats[recs[k - 1][2]] if k > 0 else txt
        nxt = pats[recs[k + 1][2]] if k + 1 < len(recs) else txt
        return sum(1 for c in range(len(txt)) if txt[c] != prev[c] and txt[c] != nxt[c])

    # after which source line to insert a copy of which pattern
    inserts = {}
    for k in range(0, len(recs), 2):
        pick = k
        if k + 1 < len(recs) and score(k + 1) < score(k):
            pick = k + 1
        first, last, pat, indent = recs[pick]
        inserts[last] = f"{indent}+row {pat}"

    out = []
    for n, line in enumerate(lines):
        out.append(line)
        if n in inserts:
            out.append(inserts[n])
    open(path, "w").write("\n".join(out))
    print(f"{path}: {len(recs)} records -> {len(recs) + len(inserts)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    for f in sys.argv[1:]:
        stretch(f)
