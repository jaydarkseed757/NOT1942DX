; =============================================================================
; crt.asm - NOT 1942 DX as a cartridge image (build/not1942dx.crt, "make crt")
; =============================================================================
;
; A second ACME entry point, assembled after main.asm. It wraps the finished
; game, build/not1942dx-dev.prg, in a VICE .crt file for a MAGIC DESK cartridge
; (CRT hardware type 19): 8 KB ROM banks at $8000-$9FFF, picked by writing
; the bank number to $DE00; writing $80 there switches the cartridge off
; (EXROM goes high), leaving a plain 64 KB C64.
;
; BOOT  On reset the KERNAL finds "CBM80" at $8004 and jumps through $8000
; to boot below (bank 0), before any of its own set-up. boot does the I/O
; and screen set-up a normal power-on would (the game relies on it: it
; never sets the CPU port's direction register $00, for one), then copies
; the copier into RAM and runs it. The copier moves the uncompressed game
; from the ROM banks to PRG_LOAD, a page at a time, switches the cartridge
; off and jumps to GAME_ENTRY, exactly where "RUN" would land.
; TIMING: ~16 cycles per byte, ~0.8 s for the whole game; no unpacking.
;
; LAYOUT  Bank 0: boot code in its first page, then the game from $8100.
; Banks 1 on: the rest of the game, 8 KB each, the last one padded with $FF.
; As few banks as the game needs (7 today, 56 KB); EPROM tools pad to the
; chip size. ACME's output is limited to 64 KB, which allows at most 7 banks
; (57,088 bytes of game); more would need two ACME runs joined by cat.
;
; The game's size comes from the Makefile: -DPRG_SIZE=<bytes in not1942dx-dev.prg>.
; Build: acme -f plain -DPRG_SIZE=... -o build/not1942dx.crt src/crt.asm
; =============================================================================

!cpu 6502
!source "src/defs.asm"

!ifndef PRG_SIZE { !error "pass -DPRG_SIZE=<size of build/not1942dx-dev.prg>" }

GAME_LEN   = PRG_SIZE - 2           ; without the 2-byte load address
BANK_SIZE  = $2000
BANK0_GAME = BANK_SIZE - $100       ; bank 0 holds the boot page first
BANKS      = 1 + (GAME_LEN - BANK0_GAME + BANK_SIZE - 1) / BANK_SIZE
MD_BANK    = $de00                  ; Magic Desk: bank number / $80 = off
ROML       = $8000

COPIER     = $0340                  ; in the cassette buffer: the game never
                                    ;   uses $0200-$07FF (defs.asm)
SRC        = $fb                    ; zero page the KERNAL leaves free
DST        = $fd

IOINIT     = $fda3                  ; KERNAL: CIAs, SID, CPU port ($00/$01)
RESTOR     = $fd15                  ; KERNAL: RAM vectors (NMI during boot)
CINT       = $ff5b                  ; KERNAL: VIC and screen editor
HIBASE     = $0288                  ; screen page CINT clears (RAMTAS sets it)

!if BANKS > 7 {
        !error "the game needs ", BANKS, " banks; ACME can only write 7 (see LAYOUT)"
}
; The copier copies whole pages, so up to 255 bytes past the end of the game
; get junk. That must stay below the I/O area.
!if PRG_LOAD + ((GAME_LEN + 255) & $ff00) > $d000 {
        !error "page-rounded copy would reach the I/O area at $D000"
}

; -----------------------------------------------------------------------------
; CRT file header (big-endian fields)
; -----------------------------------------------------------------------------
* = 0                               ; file offsets; the ROM code uses !pseudopc
        !text "C64 CARTRIDGE   "
        !be32 $40                   ; header length
        !be16 $0100                 ; CRT version 1.0
        !be16 19                    ; hardware type: Magic Desk
        !byte 0                     ; EXROM active (low) at power-on...
        !byte 1                     ; ...GAME inactive: 8 KB mode
        !fill 6, 0                  ; revision + reserved
.name   !text "NOT 1942 DX"
        !fill 32 - (* - .name), 0

!macro chip .bank {
        !text "CHIP"
        !be32 $10 + BANK_SIZE       ; packet length
        !be16 0                     ; ROM
        !be16 .bank
        !be16 ROML                  ; load address
        !be16 BANK_SIZE
}

; -----------------------------------------------------------------------------
; Bank 0: boot page + the start of the game
; -----------------------------------------------------------------------------
        +chip 0
.bank0
!pseudopc ROML {
        !word boot                  ; cold start (reset)
        !word boot                  ; warm start (RESTORE): boot again
        !byte $c3, $c2, $cd, $38, $30  ; "CBM80" signature

boot    sei
        ldx #$ff
        txs
        cld
        jsr IOINIT
        jsr RESTOR
        lda #$04                    ; (RAMTAS would set this; we skip its slow
        sta HIBASE                  ;   RAM test: the game clears what it uses)
        jsr CINT
        ldx #copier_end - copier - 1
-       lda copier,x                ; the copier must run from RAM: it switches
        sta COPIER,x                ;   the ROM bank it would be running from
        dex
        bpl -
        jmp COPIER

copier
!pseudopc COPIER {
        lda #<(ROML + $100)         ; source: bank 0, after this boot page
        sta SRC
        lda #>(ROML + $100)
        sta SRC+1
        lda #<PRG_LOAD
        sta DST
        lda #>PRG_LOAD
        sta DST+1
        ldx #0                      ; X = bank
        ldy #0
.page   lda (SRC),y                 ; one page; (DST),y crosses into the next
        sta (DST),y                 ;   RAM page itself (PRG_LOAD isn't
        iny                         ;   page aligned). Writes under the ROM
        bne .page                   ;   at $8000-$BFFF go to RAM.
        inc DST+1
        inc SRC+1
        lda SRC+1
        cmp #>(ROML + BANK_SIZE)
        bne +
        lda #>ROML                  ; end of this bank: on to the next
        sta SRC+1
        inx
        stx MD_BANK
+       lda DST+1
        cmp #>(PRG_LOAD + ((GAME_LEN + 255) & $ff00))
        bne .page
        lda #$80                    ; cartridge off: a plain C64 from here on
        sta MD_BANK
        jmp GAME_ENTRY              ; as if "RUN" had run the SYS line
}
copier_end
}
!if * - .bank0 > $100 { !error "boot code is over one page" }
        !fill $100 - (* - .bank0), $ff
        !binary "build/not1942dx-dev.prg", BANK0_GAME, 2

; -----------------------------------------------------------------------------
; Banks 1 on: the rest of the game, the last one padded with $FF
; -----------------------------------------------------------------------------
!for .b, 1, BANKS - 1 {
        +chip .b
        !set .start = BANK0_GAME + (.b - 1) * BANK_SIZE    ; offset in the game
        !if GAME_LEN - .start >= BANK_SIZE {
                !binary "build/not1942dx-dev.prg", BANK_SIZE, 2 + .start
        } else {
                !binary "build/not1942dx-dev.prg", GAME_LEN - .start, 2 + .start
                !fill BANK_SIZE - (GAME_LEN - .start), $ff
        }
}
