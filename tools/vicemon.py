"""vicemon.py - drive a headless x64sc through its text remote monitor.

Used by tools/profile.py. Start the emulator with start(), then connect with
Mon(): the first command stops the emulation and enters the monitor; "x"
continues until the next breakpoint.
"""
import os, re, socket, subprocess, time

PORT = 6510
PROMPT = re.compile(rb"\(C:\$[0-9a-f]{4}\) $")


def start(prg, extra=(), port=PORT):
    """Run x64sc (PAL, warp, no sound output) with the remote monitor on."""
    return subprocess.Popen(
        ["x64sc", "-default", "-pal", "-warp", "-sound", "-sounddev", "dummy",
         "+confirmonexit", "-autostartprgmode", "1",
         "-remotemonitor", "-remotemonitoraddress", f"ip4://127.0.0.1:{port}",
         *extra, "-autostart", prg],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def symbols(path):
    """ACME symbol list (-l) -> {name: address}."""
    sym = {}
    for line in open(path):
        m = re.match(r"\s*(\w+)\s*=\s*\$([0-9a-f]+)", line)
        if m:
            sym[m.group(1)] = int(m.group(2), 16)
    return sym


class Mon:
    def __init__(self, port=PORT, timeout=300):
        for _ in range(200):
            try:
                self.s = socket.create_connection(("127.0.0.1", port), timeout=timeout)
                break
            except OSError:
                time.sleep(0.05)
        else:
            raise RuntimeError("no remote monitor on port %d" % port)
        self.timeout = timeout
        # Entering the monitor can print an extra prompt: read the answer to
        # a first command, then drain until quiet.
        self.s.sendall(b"r\n")
        self.read()
        self.s.settimeout(0.3)
        try:
            while self.s.recv(65536):
                pass
        except socket.timeout:
            pass
        self.s.settimeout(timeout)

    def read(self):
        buf = b""
        while not PROMPT.search(buf):
            chunk = self.s.recv(65536)
            if not chunk:
                break
            buf += chunk
        return buf.decode("latin1")

    def cmd(self, c):
        self.s.sendall((c + "\n").encode())
        return self.read()

    def peek(self, addr, n=1):
        out = self.cmd(f"m {addr:04x} {addr + n - 1:04x}")
        vals = []
        for line in out.splitlines():
            m = re.search(r">C:[0-9a-f]{4}\s+((?:[0-9a-f]{2}\s+)+)", line)
            if m:
                vals += [int(v, 16) for v in m.group(1).split()]
        return vals[:n]

    def word(self, addr):
        lo, hi = self.peek(addr, 2)
        return lo | hi << 8

    def quit(self):
        try:
            self.s.sendall(b"quit\n")
        except OSError:
            pass
