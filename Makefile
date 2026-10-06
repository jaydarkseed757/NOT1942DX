# NOT 1942 DX by JDC - 1942-style vertical shmup for the C64 (smooth-scroll remake)
#
#   make          build build/not1942dx-dev.prg (uncompressed, for development)
#   make crunch   build build/not1942dx.prg: the same program compressed with
#                 exomizer into one self-extracting file (~4x smaller)
#   make d64      build build/not1942dx.d64 with the compressed program
#                 (file "NOT 1942 DX")
#   make run      build and autostart the uncompressed PRG in x64sc
#                 (PAL, no warp, injected straight into RAM: fastest)
#   make run-d64  build the disk image and boot it like a real C64:
#                 LOAD"*",8,1 from the emulated 1541, unpack, run
#   make crt      build build/not1942dx.crt: a Magic Desk cartridge image
#                 with the uncompressed game (src/crt.asm)
#   make run-crt  build the cartridge and boot x64sc with it plugged in
#   make release  build everything that ships: the .d64, the compressed
#                 .prg and the .crt
#   make turbo    the MiSTer turbo build (-DTURBO=1, src/turbo.asm): the same
#                 three files as release, named not1942dx-turbo.*
#   make turbo-profile  build/not1942dx-turbo-profile.d64: the turbo build
#                 with the PROFILE test hook, for measuring on a MiSTer: the
#                 text screens show the worst-case cycle counts in hex (see
#                 MISTER-TEST.md)
#   make run-turbo  build the turbo PRG and run it in xscpu64, VICE's SuperCPU:
#                 a 20 MHz CPU with the C64's VIC, SID and CIAs, the nearest
#                 VICE has to the MiSTer's turbo (which it can't emulate: its
#                 2x-4x and C128-mode register need the real core). Real time
#                 (PAL, no warp), injected straight into RAM
#   make gen      only build the level packs (build/gen/), for test builds
#   make clean    remove build outputs
#
#   make DEBUG=1 ...   enable raster-time bars in the border

ACME  ?= acme
X64   ?= x64sc
XSCPU ?= xscpu64
C1541 ?= c1541
EXOMIZER ?= exomizer

PRG  := build/not1942dx-dev.prg
CRUNCHED := build/not1942dx.prg
D64  := build/not1942dx.d64
CRT  := build/not1942dx.crt
SYM  := build/not1942dx-dev.sym
LST  := build/not1942dx-dev.lst

# The MiSTer turbo build: the same game with turbo detection at boot.
TPRG := build/not1942dx-turbo-dev.prg
TCRUNCHED := build/not1942dx-turbo.prg
TD64 := build/not1942dx-turbo.d64
TCRT := build/not1942dx-turbo.crt
TSYM := build/not1942dx-turbo-dev.sym
TPPRG := build/not1942dx-turbo-profile-dev.prg
TPD64 := build/not1942dx-turbo-profile.d64

PYTHON ?= python3

# The game's sources. src/crt.asm is the cartridge wrapper, a separate ACME
# entry point that only the .crt depends on.
SRC  := $(filter-out src/crt.asm,$(wildcard src/*.asm)) $(wildcard data/*.asm)

# Level packs: each level's picture (data/levels/levelN.png + .json) becomes
# build/gen/levelN.asm (tools/png2level.py, needs Python 3 with Pillow).
LEVELS := 1 2 3 4
GEN  := $(foreach n,$(LEVELS),build/gen/level$(n).asm)

ACMEFLAGS := -f cbm --cpu 6502 -v1 -l $(SYM) -r $(LST)
ifdef DEBUG
ACMEFLAGS += -DDEBUG=1
endif

.PHONY: all gen crunch d64 crt release turbo turbo-profile run run-d64 run-crt run-turbo clean

all: $(PRG)

$(PRG): $(SRC) $(GEN) Makefile | build
	$(ACME) $(ACMEFLAGS) -o $@ src/main.asm

build/gen/level%.asm: data/levels/level%.png data/levels/level%.json tools/png2level.py tools/c64gfx.py
	$(PYTHON) tools/png2level.py data/levels/level$*.json $@

# Test builds (acme on the command line) need the packs too: make gen
gen: $(GEN)

crunch: $(CRUNCHED)

# sfx sys: a self-extracting PRG that finds our "SYS 2064" line and jumps
# there after unpacking. -x1: flash the border while it unpacks (~5 s).
# The unpacker handles the RAM under the BASIC ROM ($A000-) itself.
$(CRUNCHED): $(PRG)
	$(EXOMIZER) sfx sys -x1 -q -o $@ $<

d64: $(D64)

$(D64): $(CRUNCHED)
	rm -f $@
	$(C1541) -format "not 1942 dx,jd" d64 $@ -write $(CRUNCHED) "not 1942 dx"

crt: $(CRT)

# The wrapper reads build/not1942dx-dev.prg with !binary and needs its size.
$(CRT): $(PRG) src/crt.asm src/defs.asm
	$(ACME) -f plain -DPRG_SIZE=$$(wc -c < $(PRG) | tr -d ' ') -o $@ src/crt.asm

release: $(D64) $(CRUNCHED) $(CRT)

turbo: $(TD64) $(TCRUNCHED) $(TCRT)

$(TPRG): $(SRC) $(GEN) Makefile | build
	$(ACME) -f cbm --cpu 6502 -v1 -DTURBO=1 -l $(TSYM) -o $@ src/main.asm

$(TCRUNCHED): $(TPRG)
	$(EXOMIZER) sfx sys -x1 -q -o $@ $<

$(TD64): $(TCRUNCHED)
	rm -f $@
	$(C1541) -format "not 1942 dx t,jd" d64 $@ -write $(TCRUNCHED) "not 1942 dx t"

turbo-profile: $(TPD64)

$(TPPRG): $(SRC) $(GEN) Makefile | build
	$(ACME) -f cbm --cpu 6502 -v1 -DTURBO=1 -DPROFILE=1 -o $@ src/main.asm

$(TPD64): $(TPPRG)
	$(EXOMIZER) sfx sys -x1 -q -o build/not1942dx-turbo-profile.prg $<
	rm -f $@
	$(C1541) -format "not 1942 dx tp,jd" d64 $@ -write build/not1942dx-turbo-profile.prg "not 1942 dx tp"

$(TCRT): $(TPRG) src/crt.asm src/defs.asm
	$(ACME) -f plain -DTURBO=1 -DPRG_SIZE=$$(wc -c < $(TPRG) | tr -d ' ') -o $@ src/crt.asm

# -pal: force PAL machine. +warp: make sure warp/turbo is off.
# -autostartprgmode 1: inject the PRG straight into RAM (skips the slow
# emulated disk load; the game itself still runs at real 1 MHz speed).
run: $(PRG)
	$(X64) -pal +warp -autostartprgmode 1 -autostart $(PRG)

run-d64: $(D64)
	$(X64) -pal +warp -autostart $(D64)

run-crt: $(CRT)
	$(X64) -pal +warp -cartcrt $(CRT)

# -speedswitch: the SuperCPU at 20 MHz (it would wait at the "set turbo"
# screen at 1 MHz). -speed 100: emulate in real time.
run-turbo: $(TPRG)
	$(XSCPU) -pal +warp -speed 100 -speedswitch -autostartprgmode 1 -autostart $(TPRG)

build:
	mkdir -p build

clean:
	rm -rf build
