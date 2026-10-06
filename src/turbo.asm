; =============================================================================
; turbo.asm - the MiSTer turbo build (acme -DTURBO=1): detect turbo at boot
; =============================================================================
;
; The MiSTer C64 core's OSD has "Turbo mode: Off / C128 / Smart" and "Turbo
; speed: 2x / 3x / 4x" (see CLAUDE.md, "MiSTer turbo"). Software can't pick
; the speed, and only RAM cycles get faster: I/O (VIC, SID, CIAs, colour RAM)
; still runs at 1 MHz, and badlines and sprite DMA still stall the CPU.
;
; turbo_detect, once at boot (before the IRQs start):
;   1. C128 mode: $D030 bit 0 switches turbo on and off, and reads back
;      ($FE | bit 0); a stock C64 reads $FF whatever is written. Write 0 and
;      read it back: bit 0 = 0 means the register is there, so turn turbo on.
;   2. Measure: time TURBO_CYCLES of RAM-only loop against CIA1 timer A,
;      which counts at 1 MHz whatever the CPU does. turbo_speed = the ratio,
;      rounded (1 on a stock C64). This also finds Smart mode, where $D030
;      reads $FF and only the timing tells.
;   3. Below TURBO_MIN: a screen says how to set turbo in the OSD, and the
;      check repeats about once a second until it's on (in either mode).
; The title shows the speed found ("turbo 3x").
;
; Not for a real C128: its 2 MHz mode ($D030 bit 0 too) passes the test,
; but its VIC shows no picture at 2 MHz.
; =============================================================================

TURBO_MIN    = 2                ; the least speed the turbo build accepts
TURBO_OUTER  = 16               ; the timed loop: TURBO_OUTER x 256 dex/bne
TURBO_CYCLES = TURBO_OUTER * 1286 + 1 + 24  ; its cycles at 1 MHz (+ the reads)
TURBO_ROW    = 3                ; the message screen's first row

turbo_speed !byte 1             ; the speed found (1 = a stock C64)

!zone turbo_detect
; -----------------------------------------------------------------------------
; turbo_detect: see the top. Interrupts off. Leaves turbo_speed set, and the
; speed digit in the title's version text. Clobbers A, X, Y, zp_tmp0,
; zp_tmp1, zp_ptr0.
; -----------------------------------------------------------------------------
turbo_detect
        jsr turbo_c128          ; C128 mode: switch it on
        jsr turbo_measure
        cmp #TURBO_MIN
        bcs .ok
        jsr turbo_screen        ; waits until turbo is on
.ok     lda turbo_speed         ; the title's "turbo ?x"
        cmp #10
        bcc +
        lda #'+' - '0'          ; 10x and faster (a SuperCPU, say): "+x"
+       clc
        adc #'0'
        sta title_speed
        rts

; turbo_c128: if $D030 is a turbo register (C128 mode), switch turbo on.
; Clobbers A.
turbo_c128
        lda #0
        sta VIC_D030
        lda VIC_D030
        lsr                     ; bit 0 -> carry
        bcs +                   ; 1: no register (stock, or Smart mode)
        lda #1
        sta VIC_D030            ; turbo on
+       rts

; turbo_measure: A = turbo_speed = TURBO_CYCLES / (CIA ticks the loop took),
; rounded. TIMING: the loop is RAM only (code, X, Y); the timer reads are
; I/O and run at 1 MHz in any mode. Badlines would slow it by ~8% with the
; display on, which the rounding absorbs. Clobbers A, X, Y, zp_tmp0,
; zp_tmp1, zp_ptr0.
turbo_measure
        lda #$ff                ; CIA1 timer A: free-running from $FFFF
        sta CIA1_TALO
        sta CIA1_TAHI
        lda #%00010001          ; start, continuous, load now, count phi2
        sta CIA1_CRA
        jsr .read
        stx zp_ptr0             ; t0 (lo)
        sta zp_ptr0+1           ;    (hi)
        ldy #TURBO_OUTER        ; --- the timed loop ---
-       ldx #0
--      dex
        bne --
        dey
        bne -
        jsr .read               ; t1 in A:X
        stx zp_tmp0
        sta zp_tmp1
        lda #0
        sta CIA1_CRA            ; stop the timer
        lda zp_ptr0             ; ticks = t0 - t1 (it counts down)
        sec
        sbc zp_tmp0
        sta zp_tmp0
        lda zp_ptr0+1
        sbc zp_tmp1
        sta zp_tmp1
        ; speed = (TURBO_CYCLES + ticks / 2) / ticks, by repeated
        ; subtraction (a few dozen at most)
        lda zp_tmp1
        lsr
        sta zp_ptr0+1
        lda zp_tmp0
        ror
        clc
        adc #<TURBO_CYCLES
        sta zp_ptr0
        lda zp_ptr0+1
        adc #>TURBO_CYCLES
        sta zp_ptr0+1           ; zp_ptr0 = the dividend
        ldx #0
.div    lda zp_ptr0
        sec
        sbc zp_tmp0
        tay
        lda zp_ptr0+1
        sbc zp_tmp1
        bcc .done               ; it doesn't fit again
        sta zp_ptr0+1
        sty zp_ptr0
        inx
        bne .div                ; (255 at most)
        dex
.done   stx turbo_speed
        txa
        rts
; .read: CIA1 timer A in A (hi) : X (lo), the two bytes from one moment.
.read   lda CIA1_TAHI
        ldx CIA1_TALO
        cmp CIA1_TAHI
        bne .read               ; the low byte wrapped between the reads
        rts

!zone turbo_screen
; -----------------------------------------------------------------------------
; turbo_screen: "set turbo in the OSD", then wait (re-checking about once a
; second, both modes) until the speed is at least TURBO_MIN. Interrupts off.
; -----------------------------------------------------------------------------
.SPEED_ROW = 15                 ; (rows from TURBO_ROW)
.LAST_ROW  = 18
turbo_screen
        jsr set_title_palette
        jsr init_video          ; display off, clean screens
        +print_both TURBO_ROW + 0,  (COLS - .l0) / 2, .t0, .l0
        +print_both TURBO_ROW + 3,  (COLS - .l1) / 2, .t1, .l1
        +print_both TURBO_ROW + 4,  (COLS - .l2) / 2, .t2, .l2
        +print_both TURBO_ROW + 7,  (COLS - .l3) / 2, .t3, .l3
        +print_both TURBO_ROW + 9,  (COLS - .l4) / 2, .t4, .l4
        +print_both TURBO_ROW + 10, (COLS - .l4) / 2, .t5, .l5
        +print_both TURBO_ROW + 13, (COLS - .l6) / 2, .t6, .l6
        +print_both TURBO_ROW + .SPEED_ROW, (COLS - .l7) / 2, .t7, .l7
        +print_both TURBO_ROW + .LAST_ROW, (COLS - .l8) / 2, .t8, .l8
        ldx #COLS - 1           ; white text; the title and the last line cyan
-       lda #COL_WHITE
        !for .r, 1, .LAST_ROW - 1 { sta COLRAM + (TURBO_ROW + .r) * COLS,x }
        lda #COL_CYAN
        sta COLRAM + TURBO_ROW * COLS,x
        sta COLRAM + (TURBO_ROW + .LAST_ROW) * COLS,x
        dex
        bpl -
        jsr video_on
.again  ldx #50                 ; about a second
-       lda VIC_RASTER          ; wait for line 250 ...
        cmp #250
        bne -
--      lda VIC_RASTER          ; ... and for it to pass
        cmp #250
        beq --
        dex
        bne -
        jsr turbo_c128          ; (switched to C128 mode in the OSD meanwhile?)
        jsr turbo_measure
        clc                     ; "measured speed: ?x"
        adc #'0'
        cmp #'9' + 1
        bcc +
        lda #'+'
+       sta SCREEN_A + (TURBO_ROW + .SPEED_ROW) * COLS + (COLS - .l7) / 2 + .l7 - 2
        lda turbo_speed
        cmp #TURBO_MIN
        bcc .again
        jmp video_off           ; on: the title takes over

.t0 !scr "not 1942 dx - turbo version"
.l0 = * - .t0
.t1 !scr "this version needs the turbo mode"
.l1 = * - .t1
.t2 !scr "of the mister c64 core."
.l2 = * - .t2
.t3 !scr "open the osd (f12) and set"
.l3 = * - .t3
.t4 !scr "turbo mode:  c128 or smart"
.l4 = * - .t4
.t5 !scr "turbo speed: 2x, 3x or 4x "
.l5 = * - .t5
.t6 !scr "the game starts once turbo is on."
.l6 = * - .t6
.t7 !scr "measured speed:  x"
.l7 = * - .t7
.t8 !scr "the standard version runs on any pal c64"
.l8 = * - .t8
!if .l8 > COLS { !error "turbo_screen: a line is too long" }
