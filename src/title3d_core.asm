; =============================================================================
; title3d_core.asm - the Ultimate build's 3D logo renderer (acme -DULTIMATE=1)
; =============================================================================
;
; Assembled to run at T3_BASE ($D000, the RAM under the I/O area: title3d.asm
; copies it there at boot) and called with the I/O switched out ($01 = $34),
; so it only ever touches RAM: the bitmap, its own tables, zero page.
;
; THE LOGO is boxes (data/logo3d.asm, from the title's pixel art): extruded
; letters T3_ZHALF * 2 units deep. It swings about the vertical axis by up
; to ~44 degrees, seen in perspective from T3_DIST units away.
;
; EACH FRAME (t3_render):
;   1. clear the bitmap band (rows 0-11, 3840 bytes)
;   2. project every column edge x of the logo, at the front (z = -ZHALF)
;      and the back (z = +ZHALF): rotated X, depth D (sums, no multiplies),
;      the perspective scale S (pixels per unit, a table by depth) and the
;      screen column SX = CX + X * S. A box face is then a trapezoid with
;      vertical sides: its edges' tops and bottoms are y * S at each side.
;   3. draw the visible side faces (dithered), far ones first, then every
;      front face (solid) over them: no depth sorting beyond that, since all
;      fronts lie in one plane and cover the sides behind them.
; Faces are filled a scanline at a time, straight into the hires bitmap, a
; byte (8 pixels) at a time between masked ends.
; TIMING (measured on a C64 Ultimate at 64x, from line 146): the clear ~5
; lines, the projection ~25, the sides ~40-60, the fronts ~70: done by line
; 17 of the next frame at worst, against line 51, where the band starts. So
; the 3D title needs about 54x; t3_install times a frame at boot to decide
; (title3d.asm). VICE's SuperCPU can't show this: it stores to C64 memory at
; 1 MHz.
; =============================================================================

T3_CX     = 160                 ; screen centre of the logo (pixels)
T3_CY     = 46                  ;   (in the 96-line band)
T3_BAND_H = 96                  ; rows 0-11

; zero page (free while the title shows: the ending's, $fd-$ff, and the
; turbo build's parallax pointers, used only in play)
t3_ptr    = $ee                 ; 16-bit: bitmap byte
t3_xl     = $f0                 ; 16-bit signed: a face's left column
t3_w      = $f2                 ; its width (1-255)
t3_tl     = $f3                 ; top / bottom rows at its left and right
t3_tr     = $f4                 ;   (signed: may lie outside the band)
t3_bl     = $f5
t3_br     = $e6
t3_y      = $e7                 ; scanline
t3_yend   = $e8
t3_tu     = $e9                 ; 16-bit 8.8: the top edge's crossing column
t3_bu     = $eb                 ; 16-bit 8.8: the bottom edge's
t3_tstep  = $71                 ; 16-bit 8.8 steps per scanline
t3_bstep  = $73
t3_left   = $75                 ; this scanline's span, columns from t3_xl
t3_right  = $76
t3_tmode  = $77                 ; 0 none, 1 limits the right, 2 the left
t3_bmode  = $78
t3_pat    = $79                 ; 0: solid, else dithered
t3_k      = $7a                 ; box index
t3_sl     = $fd                 ; 16-bit: the scale at the face's left
t3_m      = zp_ptr0             ; 16-bit multiply / divide scratch
t3_n      = zp_ptr1

!zone t3_render
; -----------------------------------------------------------------------------
; t3_render: one frame of the logo. I/O must be out ($01 = $34).
; Clobbers A, X, Y and the zero page above.
; -----------------------------------------------------------------------------
t3_render
        jsr t3_clear
        inc t3_t                ; the swing: angle = sin(t) / 4, about 44
        ldx t3_t                ;   degrees each way, every 256 frames
        lda t3_sin,x
        cmp #$80
        ror
        cmp #$80
        ror
        tax                     ; X = the angle (0-255 = a full turn)
        lda t3_sin,x
        sta t3_s                ; s = sin(angle), c = cos(angle), 1.7
        txa
        clc
        adc #64
        tax
        lda t3_sin,x
        sta t3_c
        ldx #0                  ; the front (z = -ZHALF), then the back
        jsr t3_project
        ldx #1
        jsr t3_project
        jmp t3_draw

t3_t    !byte 0
T3_WIDEST = 64                  ; t3_t at the widest swing (sin peaks at 64)
t3_s    !byte 0
t3_c    !byte 0

; t3_setup: from t3_enter (I/O out): the bitmap's colour per char row into
; SCREEN_A's rows 0-11 (the first 480 bytes), and a clear band.
; Clobbers A, X, Y.
t3_setup
        lda #<SCREEN_A
        sta t3_ptr
        lda #>SCREEN_A
        sta t3_ptr+1
        ldx #0                  ; char row
.row    lda t3_rowcol,x
        ldy #COLS - 1
-       sta (t3_ptr),y
        dey
        bpl -
        lda t3_ptr              ; next row: + 40
        clc
        adc #COLS
        sta t3_ptr
        bcc +
        inc t3_ptr+1
+       inx
        cpx #12
        bne .row
        jmp t3_clear

; bitmap colours per char row: '1' pixels (the logo) in the high nibble,
; '0' (the background) in the low: hot white to red, then DX in cool blues;
; row 11 holds no logo (the split comes in it)
t3_rowcol
        !byte COL_WHITE << 4 | PAL_OCEAN, COL_WHITE << 4 | PAL_OCEAN
        !byte COL_YELLOW << 4 | PAL_OCEAN, COL_YELLOW << 4 | PAL_OCEAN
        !byte COL_ORANGE << 4 | PAL_OCEAN, COL_LRED << 4 | PAL_OCEAN
        !byte COL_RED << 4 | PAL_OCEAN, COL_CYAN << 4 | PAL_OCEAN
        !byte COL_CYAN << 4 | PAL_OCEAN, COL_LBLUE << 4 | PAL_OCEAN
        !byte COL_LBLUE << 4 | PAL_OCEAN, PAL_OCEAN << 4 | PAL_OCEAN

; t3_clear: the band, 15 pages, to 0 (the background colour). Clobbers A, X.
t3_clear
        lda #0
        tax
-
!for .p, 0, 14 {
        sta T3_BITMAP + .p * 256,x
}
        inx
        bne -
        rts
!if T3_BAND_H * 40 != 15 * 256 { !error "t3_clear: the band is 15 pages" }

!zone t3_project
; -----------------------------------------------------------------------------
; t3_project: X = 0 (front) or 1 (back). For every column edge i (x =
; T3_XMIN + i): the rotated X = x c + z s and depth D = -x s + z c (units *
; 128, summed along x), the scale S = t3_stab[D / 64 + MID] and the screen
; column SX = CX + X S / 32768. Into t3_sx*/t3_sc* of that plane.
; -----------------------------------------------------------------------------
t3_project
        stx t3_plane
        ; c and s, sign-extended to 16 bits
        lda t3_c
        sta .c
        ldy #0
        cmp #$80
        bcc +
        dey
+       sty .c+1
        lda t3_s
        sta .s
        ldy #0
        cmp #$80
        bcc +
        dey
+       sty .s+1
        ; z = -ZHALF (front) or +ZHALF (back): z c and z s, ZHALF = 2
        lda .c                  ; zc = 2c, zs = 2s
        asl
        sta .zc
        lda .c+1
        rol
        sta .zc+1
        lda .s
        asl
        sta .zs
        lda .s+1
        rol
        sta .zs+1
        cpx #0
        bne +
        lda #0                  ; the front: negate them
        sec
        sbc .zc
        sta .zc
        lda #0
        sbc .zc+1
        sta .zc+1
        lda #0
        sec
        sbc .zs
        sta .zs
        lda #0
        sbc .zs+1
        sta .zs+1
+       ; X0 = XMIN c + z s = -34 c + zs ; D0 = -XMIN s + z c = 34 s + zc
        lda .c                  ; 34 c = 32 c + 2 c
        sta .t
        lda .c+1
        sta .t+1
        ldy #4
-       asl .t
        rol .t+1
        dey
        bne -                   ; .t = 16 c
        lda .t                  ; + c ... 34 c = 2 * (16 c + c)
        clc
        adc .c
        sta .t
        lda .t+1
        adc .c+1
        sta .t+1
        asl .t
        rol .t+1
        lda .zs                 ; X = zs - 34 c
        sec
        sbc .t
        sta .x
        lda .zs+1
        sbc .t+1
        sta .x+1
        lda .s                  ; 34 s, the same way
        sta .t
        lda .s+1
        sta .t+1
        ldy #4
-       asl .t
        rol .t+1
        dey
        bne -
        lda .t
        clc
        adc .s
        sta .t
        lda .t+1
        adc .s+1
        sta .t+1
        asl .t
        rol .t+1
        lda .t                  ; D = 34 s + zc
        clc
        adc .zc
        sta .d
        lda .t+1
        adc .zc+1
        sta .d+1

        ldx #0                  ; --- each column edge ---
.col    lda .d+1                ; scale index: D / 64 + MID (D: +-4572,
        sta .t                  ;   so -72..+71: a signed byte)
        lda .d
        asl
        rol .t
        asl
        rol .t                  ; .t = D >> 6 (bits 6-13)
        lda .t
        clc
        adc #T3_STABMID
        tay
        lda t3_stab_lo,y
        sta t3_m
        lda t3_stab_hi,y
        sta t3_m+1              ; S (8.8 pixels per unit)
        ldy t3_plane
        bne +
        sta t3_scf_hi,x
        lda t3_m
        sta t3_scf_lo,x
        jmp ++
+       sta t3_scb_hi,x
        lda t3_m
        sta t3_scb_lo,x
++      ; SX = CX + X * S / 32768 = CX + |X| * (S / 8) / 4096, sign after
        lda .x
        sta t3_n
        lda .x+1
        sta t3_n+1
        php                     ; (N: X's sign)
        bpl +
        lda #0
        sec
        sbc t3_n
        sta t3_n
        lda #0
        sbc t3_n+1
        sta t3_n+1
+       lsr t3_m+1              ; S / 8: 8 bits (S < 2048)
        ror t3_m
        lsr t3_m+1
        ror t3_m
        lsr t3_m+1
        ror t3_m
        jsr t3_mul              ; t3_acc = t3_n * t3_m (24 bits)
        lda t3_acc+2            ; / 4096: bits 12-20
        sta .t+1
        lda t3_acc+1
        ldy #4
-       lsr .t+1
        ror
        dey
        bne -
        sta .t                  ; .t = |X| S / 32768 (0-511)
        plp
        bpl +
        lda #<T3_CX             ; SX = CX - .t
        sec
        sbc .t
        sta .t
        lda #>T3_CX
        sbc .t+1
        jmp ++
+       lda .t                  ; SX = CX + .t
        clc
        adc #<T3_CX
        sta .t
        lda .t+1
        adc #>T3_CX
++      ldy t3_plane
        bne +
        sta t3_sxf_hi,x
        lda .t
        sta t3_sxf_lo,x
        jmp ++
+       sta t3_sxb_hi,x
        lda .t
        sta t3_sxb_lo,x
++      lda .x                  ; next edge: X += c, D -= s
        clc
        adc .c
        sta .x
        lda .x+1
        adc .c+1
        sta .x+1
        lda .d
        sec
        sbc .s
        sta .d
        lda .d+1
        sbc .s+1
        sta .d+1
        inx
        cpx #T3_XCOUNT
        beq +
        jmp .col
+       rts

t3_plane !byte 0
.c      !word 0
.s      !word 0
.zc     !word 0
.zs     !word 0
.x      !word 0
.d      !word 0
.t      !word 0

; t3_mul: t3_acc (24 bits) = t3_n (16) * t3_m (8 bits; t3_m+1 = 0).
; Stops when t3_m runs out of bits. Clobbers A, t3_m, t3_n.
t3_mul
        lda #0
        sta t3_acc
        sta t3_acc+1
        sta t3_acc+2
        sta .n2                 ; (t3_n's third byte, as it shifts up)
-       lsr t3_m
        bcc +
        lda t3_acc
        clc
        adc t3_n
        sta t3_acc
        lda t3_acc+1
        adc t3_n+1
        sta t3_acc+1
        lda t3_acc+2
        adc .n2
        sta t3_acc+2
+       lda t3_m                ; no bits left: done
        beq +
        asl t3_n
        rol t3_n+1
        rol .n2
        jmp -
+       rts
.n2     !byte 0
t3_acc  !fill 3, 0              ; the product (24 bits)

!zone t3_draw
; -----------------------------------------------------------------------------
; t3_draw: the side faces that show, far ones first (the boxes are sorted by
; their left edge: with s >= 0 the left end of the logo is the far end), then
; every front face.
; -----------------------------------------------------------------------------
t3_draw
        lda #1
        sta t3_pat              ; sides: dithered
        lda t3_s
        bmi .backward
        ldx #0
-       stx t3_k
        jsr t3_sides
        ldx t3_k
        inx
        cpx #T3_BOXES
        bne -
        beq .fronts
.backward
        ldx #T3_BOXES - 1
-       stx t3_k
        jsr t3_sides
        ldx t3_k
        dex
        bpl -
.fronts lda #0
        sta t3_pat              ; fronts: solid
        ldx #0
-       stx t3_k
        lda t3_bx0,x            ; left edge: the front plane at bx0
        tay
        lda t3_bx1,x
        tax
        jsr t3_front
        ldx t3_k
        inx
        cpx #T3_BOXES
        bne -
        rts

; t3_front: the front face between column edges Y (left) and X (right).
t3_front
        lda t3_sxf_lo,x         ; right column, its scale
        sta .xr
        lda t3_sxf_hi,x
        sta .xr+1
        lda t3_scf_lo,x
        sta .sr
        lda t3_scf_hi,x
        sta .sr+1
        lda t3_sxf_lo,y         ; left column, its scale
        sta t3_xl
        lda t3_sxf_hi,y
        sta t3_xl+1
        lda t3_scf_lo,y
        sta t3_sl
        lda t3_scf_hi,y
        sta t3_sl+1
        jmp t3_face

; t3_sides: box t3_k's left and right side faces, where they show: a side
; shows when its back edge lies outside its front edge.
t3_sides
        ldx t3_k
        lda t3_bx1,x            ; right side, at edge bx1
        tax
        lda t3_sxb_lo,x         ; back > front?
        cmp t3_sxf_lo,x
        lda t3_sxb_hi,x
        sbc t3_sxf_hi,x
        bvc +
        eor #$80
+       bmi .left               ; (equal: no width, t3_face skips it)
        lda t3_sxf_lo,x         ; left = the front, right = the back
        sta t3_xl
        lda t3_sxf_hi,x
        sta t3_xl+1
        lda t3_scf_lo,x
        sta t3_sl
        lda t3_scf_hi,x
        sta t3_sl+1
        lda t3_sxb_lo,x
        sta .xr
        lda t3_sxb_hi,x
        sta .xr+1
        lda t3_scb_lo,x
        sta .sr
        lda t3_scb_hi,x
        sta .sr+1
        jsr t3_face
.left   ldx t3_k
        lda t3_bx0,x            ; left side, at edge bx0
        tax
        lda t3_sxf_lo,x         ; front > back?
        cmp t3_sxb_lo,x
        lda t3_sxf_hi,x
        sbc t3_sxb_hi,x
        bvc +
        eor #$80
+       bmi .none
        lda t3_sxb_lo,x         ; left = the back, right = the front
        sta t3_xl
        lda t3_sxb_hi,x
        sta t3_xl+1
        lda t3_scb_lo,x
        sta t3_sl
        lda t3_scb_hi,x
        sta t3_sl+1
        lda t3_sxf_lo,x
        sta .xr
        lda t3_sxf_hi,x
        sta .xr+1
        lda t3_scf_lo,x
        sta .sr
        lda t3_scf_hi,x
        sta .sr+1
        jmp t3_face
.none   rts

.xr     !word 0                 ; the face's right column and its scale
.sr     !word 0
t3_face_xr = .xr
t3_face_sr = .sr

!zone t3_face
; -----------------------------------------------------------------------------
; t3_face: a trapezoid with vertical sides: left column t3_xl (scale t3_sl),
; right column t3_face_xr (scale t3_face_sr), box t3_k's rows by0..by1.
; Each side's top and bottom = CY + y * its scale. t3_pat: solid / dithered.
; -----------------------------------------------------------------------------
t3_face
        lda t3_face_xr          ; width (1-255; nothing if 0 or less)
        sec
        sbc t3_xl
        sta t3_w
        lda t3_face_xr+1
        sbc t3_xl+1
        beq +
        rts                     ; (negative, or 256 and more: no face)
+       lda t3_w
        bne +
        rts
+       ldx t3_k                ; the rows at each side
        lda t3_by0,x
        ldx #0
        jsr .rowl
        sta t3_tl
        ldx t3_k
        lda t3_by1,x
        ldx #0
        jsr .rowl
        sta t3_bl
        ldx t3_k
        lda t3_by0,x
        ldx #1
        jsr .rowl
        sta t3_tr
        ldx t3_k
        lda t3_by1,x
        ldx #1
        jsr .rowl
        sta t3_br
        jmp t3_scan

; .rowl: A = the signed unit row, X = 0 (left side) / 1 (right side) -> A =
; CY + row * scale / 256 (signed). Clobbers A, X, Y, t3_m, t3_n.
.rowl   sta .row
        cmp #$80                ; |row|
        bcc +
        eor #$ff
        adc #0                  ; (carry set: + 1)
+       sta t3_n                ; |row| (0-15)
        cpx #0
        bne +
        lda t3_sl
        sta t3_m
        lda t3_sl+1
        sta t3_m+1
        jmp ++
+       lda t3_face_sr
        sta t3_m
        lda t3_face_sr+1
        sta t3_m+1
++      lda #0                  ; |row| * scale: 4 bits of |row|
        sta .p
        sta .p+1
        ldy #4
-       lsr t3_n
        bcc +
        lda .p
        clc
        adc t3_m
        sta .p
        lda .p+1
        adc t3_m+1
        sta .p+1
+       asl t3_m
        rol t3_m+1
        dey
        bne -
        lda .p+1                ; / 256
        ldy .row
        bpl +
        eor #$ff                ; negative row: - that
        clc
        adc #1
+       clc
        adc #T3_CY
        rts
.row    !byte 0
.p      !word 0

!zone t3_scan
; -----------------------------------------------------------------------------
; t3_scan: fill the trapezoid (left column t3_xl, width t3_w, rows tl/bl at
; its left and tr/br at its right; bottoms exclusive) a byte column (8
; pixels) at a time: hires bitmap bytes for 8 lines of a char cell follow
; each other, so a column is `sta (ptr),y` / `iny`. Each column's top and
; bottom are the edges' rows at its centre (walked: + 8 slopes a column),
; the columns at the face's sides are masked to its exact pixels. The top
; and bottom edges barely slope (a pixel or two across a face), so taking
; them a byte column at a time doesn't show.
; TIMING: ~16 cycles a line in a full solid column, ~35 masked or dithered,
; plus ~150 a column and ~600 a face.
; -----------------------------------------------------------------------------
.out    rts                     ; (an early way out, in branch range)
t3_scan
        ; the face's columns, clipped to the screen: x0..x1 (exclusive)
        lda t3_xl
        sta .x0
        lda t3_xl+1
        sta .x0+1
        bpl +
        lda #0                  ; x0 = max(xl, 0)
        sta .x0
        sta .x0+1
+       lda t3_xl               ; x1 = min(xl + w, 320)
        clc
        adc t3_w
        sta .x1
        lda t3_xl+1
        adc #0
        sta .x1+1
        bmi .out                ; (all left of the screen)
        lda .x1
        cmp #<320
        lda .x1+1
        sbc #>320
        bcc +
        lda #<320
        sta .x1
        lda #>320
        sta .x1+1
+       lda .x0                 ; anything left?
        cmp .x1
        lda .x0+1
        sbc .x1+1
        bcs .out
        ; the first and last byte columns
        lda .x0+1
        lsr
        lda .x0
        ror
        lsr
        lsr
        sta .c                  ; c0 = x0 / 8
        sta .c0
        lda .x1                 ; c1 = (x1 - 1) / 8
        sec
        sbc #1
        sta .t
        lda .x1+1
        sbc #0
        lsr
        lda .t
        ror
        lsr
        lsr
        sta .c1
        ; the edges' slopes (8.8 rows a pixel) and their rows at the first
        ; column's centre, u0 = 8 c0 + 4 - xl (pixels into the face)
        lda .c
        asl
        asl
        asl
        sta .t
        lda #0
        rol                     ; (c0 * 8 > 255: c0 >= 32)
        sta .t+1
        lda .t
        clc
        adc #4
        sec
        sbc t3_xl
        sta .u0
        lda .t+1
        sbc t3_xl+1
        bpl +
        lda #0                  ; (left of the face: take its edge)
        sta .u0
+       lda t3_tl
        ldx t3_tr
        jsr .edge
        sta .tv
        stx .tv+1
        lda .s8
        sta .ts8
        lda .s8+1
        sta .ts8+1
        lda t3_bl
        ldx t3_br
        jsr .edge
        sta .bv
        stx .bv+1
        lda .s8
        sta .bs8
        lda .s8+1
        sta .bs8+1
        ; the patterns: solid, or a checkerboard by row
        lda t3_pat
        beq +
        lda #$aa                ; dithered: even rows $AA, odd $55
        ldx #$55
        bne ++
+       lda #$ff
        tax
++      sta .pe
        stx .po

.col    ; this column's rows: top = tv / 256, bottom = bv / 256 (signed,
        ; rounded: the values carry + 128), clipped to the band
        lda .tv+1
        bpl +
        lda #0
+       sta .top
        lda .bv+1
        bmi .skip               ; (bottom above the band)
        cmp #T3_BAND_H
        bcc +
        lda #T3_BAND_H
+       sta .bot
        lda .top
        cmp #T3_BAND_H
        bcs .skip
        cmp .bot
        bcs .skip
        ; its mask: the face's first and last columns cover part of it
        ldx #$ff
        lda .c
        cmp .c0
        bne +
        lda .x0
        and #7
        tay
        ldx t3_lmask,y
+       stx .m
        lda .c
        cmp .c1
        bne +
        lda .x1
        sec
        sbc #1
        and #7
        tay
        lda t3_rmask,y
        and .m
        sta .m
+       jsr .fill
.skip   lda .c                  ; next column
        cmp .c1
        beq .ret
        inc .c
        lda .tv                 ; the edges move 8 pixels' worth
        clc
        adc .ts8
        sta .tv
        lda .tv+1
        adc .ts8+1
        sta .tv+1
        lda .bv
        clc
        adc .bs8
        sta .bv
        lda .bv+1
        adc .bs8+1
        sta .bv+1
        jmp .col
.ret    rts

; .edge: A = the edge's row at the face's left, X = at its right (signed).
; -> A/X = its row at u0, 8.8 + 128 (for rounding), .s8 = 8 * its slope.
; Clobbers Y.
.edge   sta .el
        stx .er
        txa                     ; d = right - left
        sec
        sbc .el
        bne +
        lda #0                  ; flat: the slope is 0
        sta .s8
        sta .s8+1
        lda #$80
        ldx .el
        rts
+       sta .d
        bpl +
        eor #$ff                ; |d|
        clc
        adc #1
+       sta .uu                 ; the slope (8.8) = |d| * 256 / w =
        ldy t3_w                ;   |d| * (65536 / w) / 256
        lda t3_rec_lo,y
        sta .q
        lda t3_rec_hi,y
        sta .q+1
        jsr .mul                ; .p = |d| * 65536 / w (24 bits)
        lda .p+1
        sta t3_n
        lda .p+2
        sta t3_n+1              ; the slope, 8.8
        ; the row at u0: left + slope * u0 (u0 is 0-4 for a face on
        ; screen; .mul stops when it runs out of bits)
        lda .u0
        sta .uu
        lda t3_n
        sta .q
        lda t3_n+1
        sta .q+1
        jsr .mul
        lda t3_n                ; 8 * slope
        sta .s8
        lda t3_n+1
        ldy #3
-       asl .s8
        rol
        dey
        bne -
        sta .s8+1
        lda .d                  ; negative slope: negate both
        bpl +
        lda #0
        sec
        sbc .s8
        sta .s8
        lda #0
        sbc .s8+1
        sta .s8+1
        lda #0
        sec
        sbc .p
        sta .p
        lda #0
        sbc .p+1
        sta .p+1
+       lda .p                  ; row = left + p (8.8: p's low two bytes;
        clc                     ;   the row stays within a signed byte)
        adc #$80                ;   + 128, for rounding
        pha
        lda .p+1
        adc .el
        tax
        pla
        rts

; .mul: .p (24 bits) = .q (16) * .uu (8). Stops when .uu runs out of
; bits. Clobbers A, .q, .uu.
.mul    lda #0
        sta .p
        sta .p+1
        sta .p+2
        sta .q+2
-       lsr .uu
        bcc +
        lda .p
        clc
        adc .q
        sta .p
        lda .p+1
        adc .q+1
        sta .p+1
        lda .p+2
        adc .q+2
        sta .p+2
+       lda .uu
        beq +
        asl .q
        rol .q+1
        rol .q+2
        jmp -
+       rts

; .fill: column .c, rows .top..bot - 1, mask .m, patterns .pe / .po.
.fill   lda .c                  ; the address: the char row's base + c * 8
        asl
        asl
        asl
        sta .co
        lda #0
        rol
        sta .co+1
        lda .top
        lsr
        lsr
        lsr
        tax
        lda t3_cell_lo,x
        clc
        adc .co
        sta t3_ptr
        lda t3_cell_hi,x
        adc .co+1
        sta t3_ptr+1
        lda .bot                ; how many lines
        sec
        sbc .top
        tax
        lda .top                ; the first line's pattern, masked; and
        and #1                  ;   what turns it into the next line's
        tay
        lda .pe,y
        and .m
        sta .pv
        lda .pe
        eor .po
        and .m
        sta .pt
        lda .top
        and #7
        tay
        lda .m                  ; a whole solid byte column: plain stores
        cmp #$ff
        bne .rmw
        lda .pt
        bne .rmw
        lda #$ff
-       sta (t3_ptr),y
        iny
        cpy #8
        beq .solidnext
        dex
        bne -
        rts
.solidnext
        jsr .down
        lda #$ff
        dex
        bne -
        rts
.rmw    lda .m                  ; byte & ~m | pattern & m
        eor #$ff
        sta .nm
-       lda (t3_ptr),y
        and .nm
        ora .pv
        sta (t3_ptr),y
        lda .pv                 ; (the other row's pattern)
        eor .pt
        sta .pv
        iny
        cpy #8
        bne +
        jsr .down
+       dex
        bne -
        rts
.down   ldy #0                  ; the next char row: + 320
        lda t3_ptr
        clc
        adc #<320
        sta t3_ptr
        lda t3_ptr+1
        adc #>320
        sta t3_ptr+1
        rts

.x0     !word 0
.x1     !word 0
.c      !byte 0
.c0     !byte 0                 ; (the first column: its mask)
.c1     !byte 0
.t      !word 0
.u0     !byte 0
.uu     !byte 0
.tv     !word 0                 ; top edge's row, 8.8 (+ 128)
.bv     !word 0                 ; bottom edge's row
.ts8    !word 0                 ; 8 * slopes
.bs8    !word 0
.s8     !word 0
.el     !byte 0
.er     !byte 0
.d      !byte 0
.p      !fill 3, 0
.q      !fill 3, 0
.top    !byte 0
.bot    !byte 0
.m      !byte 0
.nm     !byte 0
.co     !word 0
.pe     !byte 0                 ; even and odd rows' patterns (adjacent)
.po     !byte 0
.pv     !byte 0
.pt     !byte 0

!zone t3_init
; -----------------------------------------------------------------------------
; t3_init: once, at boot (t3_install, I/O out): the reciprocal table
; t3_rec[w] = 65535 / w (w = 1-255), so a face's edge slope is a multiply.
; Clobbers A, X, Y, t3_n.
; -----------------------------------------------------------------------------
t3_init ldy #1
.w      lda #$ff                ; the dividend $FFFF
        sta t3_n
        sta t3_n+1
        lda #0                  ; remainder
        ldx #16
-       asl t3_n
        rol t3_n+1
        rol
        bcs +                   ; (remainder past 8 bits: it fits, subtract)
        sty .dv
        cmp .dv
        bcc ++
+       sty .dv
        sbc .dv
        inc t3_n
++      dex
        bne -
        lda t3_n
        sta t3_rec_lo,y
        lda t3_n+1
        sta t3_rec_hi,y
        iny
        bne .w
        rts
.dv     !byte 0

; the band's char rows: T3_BITMAP + r * 320
t3_cell_lo !for .r, 0, 11 { !byte <(T3_BITMAP + .r * 320) }
t3_cell_hi !for .r, 0, 11 { !byte >(T3_BITMAP + .r * 320) }

t3_lmask !byte $ff, $7f, $3f, $1f, $0f, $07, $03, $01      ; from bit x & 7 on
t3_rmask !byte $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff      ; up to bit x & 7

; the logo and its tables (tools/art/logo3d.py)
!source "data/logo3d.asm"
!if T3_XCOUNT > 68 { !error "t3: the column tables hold 68 edges" }
!if T3_XMIN != -34 | T3_ZHALF != 2 { !error "t3_project: the setup assumes XMIN -34, ZHALF 2" }

; per-frame tables (not stored: after the code, up to T3_BASE + $1000)
t3_core_end
t3_sxf_lo = t3_core_end         ; screen columns of the front edges
t3_sxf_hi = t3_sxf_lo + T3_XCOUNT
t3_sxb_lo = t3_sxf_hi + T3_XCOUNT   ; ...the back edges
t3_sxb_hi = t3_sxb_lo + T3_XCOUNT
t3_scf_lo = t3_sxb_hi + T3_XCOUNT   ; scales (8.8 px / unit), front
t3_scf_hi = t3_scf_lo + T3_XCOUNT
t3_scb_lo = t3_scf_hi + T3_XCOUNT   ; ...back
t3_scb_hi = t3_scb_lo + T3_XCOUNT
t3_rec_lo = t3_scb_hi + T3_XCOUNT  ; 65535 / w (t3_init)
t3_rec_hi = t3_rec_lo + 256
t3_tables_end = t3_rec_hi + 256
