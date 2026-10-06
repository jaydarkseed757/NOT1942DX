#!/usr/bin/env python3
"""check_waves.py - check a level's enemy budget before running it.

Reads the enemy paths from data/waves.asm and a level's waves from
data/levelN_waves.asm, replays every path exactly like src/enemies.asm (8.8 fixed
point, the segment timer, the off-screen removal rules), and checks that no
spawn ever needs more than SLOTS enemy slots. Each enemy counts as alive for MARGIN
extra frames, covering an explosion if it is shot just before it would have
left the screen.

Usage:  python3 tools/check_waves.py data/level1_waves.asm [more levels...]
Exit status 1 if any level breaks the budget.

The waves file stays the source of truth; this only reads it. A DEBUG build
(spawn_drops, see CLAUDE.md) remains the final check.
"""
import json, re, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WAVES = os.path.join(ROOT, "data", "waves.asm")
FRAMES_PER_ROW = 8      # FINE_STEPS in src/scroll.asm (1 pixel per frame)
PREDRAWN = 25           # SCROLL_ROWS: rows drawn instantly at level start
SLOTS = 8               # ENEMY_COUNT (src/defs.asm)
MARGIN = 18             # EXPL_FRAMES in src/enemies.asm
Y_END, Y_TOP, X_KILL = 247, 20, 172   # removal rules in enemies_update (PLAY_Y_END)

def strip(line):
    return line.split(";")[0].rstrip()

def load_paths():
    txt = open(WAVES).read()
    labels, prog = {}, []
    for raw in txt.split("\n"):
        code = strip(raw)
        if re.match(r"^\w+\s*$", code):
            labels[code.strip()] = len(prog)
            continue
        m = re.match(r"^\s+\+path_start\s+(\S+)", code)
        if m:
            prog.append(("start", int(m.group(1), 0)))
            continue
        m = re.match(r"^\s+\+seg\s+([-\d.]+),\s*([-\d.]+),\s*(\d+)", code)
        if m:
            fx = lambda v: int(float(v) * 256) & 0xFFFF
            prog.append(("seg", fx(m.group(1)), fx(m.group(2)), int(m.group(3))))
            continue
        if re.match(r"^\s+\+seg_end", code):
            prog.append(("end",))
        elif re.match(r"^\s+\+(seg_fire|boss_fire|boss_spread)", code):
            prog.append(("fire",))
        else:
            m = re.match(r"^\s+\+seg_loop\s+(\w+)", code)
            if m:
                prog.append(("loop", m.group(1)))
    ids = {m.group(1): int(m.group(2)) for m in re.finditer(r"^(P_\w+)\s*=\s*(\d+)", txt, re.M)}
    lo = re.search(r"path_lo\s+!byte(.*?)\npath_hi", txt, re.S).group(1)
    order = re.findall(r"<(\w+)", lo)
    return labels, prog, ids, order

LABELS, PROG, IDS, ORDER = load_paths()

def lifetime(path_id, x):
    """Frames from spawn until enemies_update removes the enemy."""
    pc = LABELS[ORDER[path_id]]
    y = PROG[pc][1] << 8
    xx = x << 8
    pc += 1
    st = {"pc": pc, "dx": 0, "dy": 0, "timer": 0}
    def load_seg():
        budget = 4
        while True:
            op = PROG[st["pc"]]
            if op[0] == "loop":
                st["pc"] = LABELS[op[1]]
            elif op[0] == "fire":
                st["pc"] += 1
            elif op[0] == "end":
                st["timer"] = 0
                return
            else:
                st["timer"], st["dx"], st["dy"] = op[3], op[1], op[2]
                st["pc"] += 1
                return
            budget -= 1
            if budget == 0:
                st["timer"] = 0
                return
    load_seg()
    for frame in range(1, 10000):
        if st["timer"]:
            st["timer"] -= 1
            if st["timer"] == 0:
                load_seg()
        xx = (xx + st["dx"]) & 0xFFFF
        y = (y + st["dy"]) & 0xFFFF
        if (y >> 8) >= Y_END or (y >> 8) < Y_TOP or (xx >> 8) >= X_KILL:
            return frame
    return 10000

def check(level_file):
    spawns, boss = [], None          # spawns: (row, path, x, line)
    row = None
    # the boss row is in the level's JSON: data/levelN_waves.asm -> data/levels/levelN.json
    m = re.search(r"level(\d+)_waves\.asm$", level_file)
    if m:
        cfg = os.path.join(os.path.dirname(level_file), "levels", f"level{m.group(1)}.json")
        if os.path.exists(cfg):
            boss = json.load(open(cfg))["boss_row"]
    for n, raw in enumerate(open(level_file), 1):
        code = strip(raw)
        m = re.match(r"^\s+\+wave\s+(\d+)", code)
        if m:
            row = int(m.group(1))
        m = re.match(r"^\s+\+spawn\s+(\w+),\s*(\w+),\s*(\w+)", code)
        if m:
            spawns.append((row, m.group(3), int(m.group(2), 0), n))
    if not spawns:
        print(f"{level_file}: no +wave lines (not a waves file), skipped")
        return True
    records = boss if boss is not None else spawns[-1][0] + 1
    alive, peak, ok = [], 0, True
    for rec, path, x, line in spawns:
        t = 1 + FRAMES_PER_ROW * (rec - PREDRAWN)
        alive = [d for d in alive if d >= t]
        if len(alive) >= SLOTS:
            ok = False
            print(f"  {level_file}:{line}: row {rec} needs enemy slot {SLOTS + 1} "
                  f"(busy until rows {', '.join('%.1f' % (PREDRAWN + (d - 1) / FRAMES_PER_ROW) for d in sorted(alive))})")
        alive.append(t + lifetime(IDS[path], x) + MARGIN)
        peak = max(peak, len(alive))
    waves = records - PREDRAWN
    secs = waves * FRAMES_PER_ROW / (985248 / 19656)
    print(f"{level_file}: {waves} rows of waves ({secs:.0f} s), {len(spawns)} enemies, "
          f"peak {peak} alive: {'OK' if ok else 'BUDGET BROKEN'}")
    return ok

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    results = [check(f) for f in sys.argv[1:]]
    sys.exit(0 if all(results) else 1)
