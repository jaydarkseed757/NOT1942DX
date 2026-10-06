; =============================================================================
; parallax.asm - the turbo build's parallax cloud layer (acme -DTURBO=1)
; =============================================================================
;
; A cloud (data/parallax.asm, PARA_W x PARA_H chars) drifts down the screen
; at PARA_SPEED pixels a frame, twice the map's speed, so it reads as a layer
; above the land. It is drawn with chars, not sprites (the VIC's 8 sprites a
; line stay for the planes): PARA_CELLS chars at the top of the charset
; (PARA_CODE..255, which no level uses) are rewritten every frame, each one
; the map char under it with the cloud's pixels ORed over it, shifted by the
; cloud's position within its char row. The cloud's pixels are '11', so its
; cells' colour RAM is the cloud colour (white; yellow at sunset).
;
; Every frame, first in the border work (TIMING: right after the frame IRQ,
; so it's done before the raster reaches the top of the picture and nothing
; tears; ~5500 cycles at 1 MHz at worst, half that at 2x):
;   para_restore  put back the map chars and colours under last frame's
;                 cloud. Not after a flip: the new front buffer is clean
;                 (see para_fixup), and the colour chase has just rewritten
;                 colour RAM from the clean shadow.
;   para_update   move the cloud, then draw
;                 it into the buffer on screen: save each covered cell's
;                 char, build its pool char, write the pool char and the
;                 colour.
;   para_fixup    (after each of the scroller's slices) the slice copied the
;                 cloud's chars into the back buffer with the rest of the
;                 front: put the map chars back there, and their colours in
;                 the shadow, so the back buffer is clean when it's flipped
;                 in.
; Cells with no cloud pixels at the cloud's current offset are left alone.
; TIMING: ~260 cycles a cell drawn (most of it the 8 bytes, unrolled), up to
; PARA_CELLS of them; cells with no cloud at the current offset are skipped
; by table (para_ne).
;
; One cloud at a time, on a fixed schedule (para_x_t, para_wait_t): nothing
; is random. Sprites stay in front of it.
; =============================================================================

PARA_W      = 6                 ; the cloud, in chars (tools/art/parallax_cloud.py)
PARA_H      = 3
PARA_ROWS   = PARA_H + 1        ; char rows it can touch (it sits between rows)
PARA_CELLS  = PARA_W * PARA_ROWS
PARA_CODE   = 256 - PARA_CELLS  ; its pool of chars: PARA_CODE..255
PARA_SPEED  = 2                 ; pixels a frame on screen (the map: 1)
PARA_TOP    = -PARA_H * 8       ; where a cloud starts: just above row 0
PARA_GONE   = SCROLL_ROWS * 8   ; ...and where it has left the bottom
PARA_FIRST  = 150               ; frames into a level before the first one
!if PARA_CELLS != PARA_SAVE { !error "parallax: PARA_SAVE in bss.asm must be PARA_CELLS" }

para_up = $71                   ; zero page (free in the memory map): the
para_sp = $73                   ;   map char under a cell, its cloud strip,
para_dp = $75                   ;   its pool char,
para_cp = $77                   ;   the screen row (+ the cloud's column),
para_cl = $79                   ;   and its colour RAM

para_on    !byte 0              ; a cloud is on its way down
para_y     !word 0              ; its top, in pixels from row 0 at yscroll 0
para_x     !byte 0              ; its left column
para_wait  !byte 0              ; frames until the next one
para_n     !byte 0              ; the next schedule entry
para_count !byte 0              ; cells drawn (saved below)
para_buf   !byte 0              ; the front buffer they were drawn into
para_col   !byte 0              ; this level's cloud colour (colour RAM value)
para_sub   !byte 0              ; (para_update's working values)
para_row   !byte 0
para_cr    !byte 0
para_k     !byte 0
para_bits  !byte 0
para_so    !byte 0
para_ro    !word 0

!zone para_reset
; -----------------------------------------------------------------------------
; para_reset: no cloud yet, at level start (level_begin). Clobbers A, X.
; -----------------------------------------------------------------------------
para_reset
        lda #0
        sta para_on
        sta para_count
        sta para_n
        lda #PARA_FIRST
        sta para_wait
        ldx level
        lda para_col_t,x
        sta para_col
        rts

!zone para_restore
; -----------------------------------------------------------------------------
; para_restore: put back the map chars and colours under last frame's cloud.
; Border work, before scroll_update. Clobbers A, X, Y, para_cp.
; -----------------------------------------------------------------------------
para_restore
        ldx para_count
        beq .out
        lda front_buf           ; the buffer on screen (front_buf changes at
        eor flip_pending        ;   the flip request; the IRQ flips later)
        cmp para_buf
        bne .forget             ; flipped since: the screen is clean already
        dex
.cell   lda para_idx_lo,x       ; the cell: its offset 0-999 ...
        sta para_cp
        lda para_idx_hi,x
        clc
        adc para_buf_hi
        sta para_cp+1           ; ... in the front buffer
        ldy #0
        lda para_code,x
        sta (para_cp),y         ; its map char back
        tay
        lda para_idx_hi,x       ; and its colour (colour RAM: the same offset)
        clc
        adc #>COLRAM
        sta para_cp+1
        lda CHAR_COL,y
        ldy #0
        sta (para_cp),y
        dex
        bpl .cell
.forget lda #0
        sta para_count
.out    rts

!zone para_update
; -----------------------------------------------------------------------------
; para_update: move the cloud and draw it. Border work, after scroll_update
; and anim_update. Clobbers A, X, Y, the para_* pointers.
; -----------------------------------------------------------------------------
para_update
        lda para_on
        bne .move
        dec para_wait           ; no cloud: wait for the next
        bne .out
        ldx para_n              ; a new one, just above the top
        lda para_x_t,x
        sta para_x
        lda #<PARA_TOP
        sta para_y
        lda #>PARA_TOP
        sta para_y+1
        lda #1
        sta para_on
        bne .draw               ; (always)
.move   lda para_y              ; down PARA_SPEED pixels
        clc
        adc #PARA_SPEED
        sta para_y
        bcc +
        inc para_y+1
+       lda para_y+1            ; gone past the bottom?
        bmi .draw
        bne .gone
        lda para_y
        cmp #PARA_GONE
        bcc .draw
.gone   lda #0
        sta para_on
        ldx para_n              ; the schedule: the next one's wait
        lda para_wait_t,x
        sta para_wait
        inx
        cpx #PARA_SCHEDULE
        bcc +
        ldx #0
+       stx para_n
.out    rts

        ; --- where it sits in the char grid: rel = y - yscroll ---
.draw   lda front_buf           ; the buffer on screen (no flip is pending at
        eor flip_pending        ;   this point of the frame, but be sure)
        tay
        lda .base_hi,y
        sta para_buf_hi
        sty para_buf
        lda VIC_CTRL1           ; this frame's yscroll (the IRQ has set it)
        and #%00000111
        sta para_sub
        lda para_y              ; rel + 32 = y - yscroll + 32: 1..231, so its
        clc                     ;   low byte is all of it (y is -24..199)
        adc #32
        sec
        sbc para_sub
        tax
        and #%00000111
        sta para_sub            ; the pixel offset in its char row
        txa
        lsr
        lsr
        lsr
        sec
        sbc #4                  ; the char row of its top: -4..24
        sta para_row
        lda #0
        sta para_cr
        sta para_k
.crow   lda para_row            ; --- one char row of the cloud ---
        clc
        adc para_cr
        bpl +
        jmp .skiprow            ; above row 0
+       cmp #SCROLL_ROWS
        bcc +
        rts                     ; below the last
+       tax
        lda .row_lo,x           ; the row's offset + the cloud's column
        clc
        adc para_x
        sta para_ro
        sta para_cp
        sta para_cl
        lda .row_hi,x
        adc #0
        sta para_ro+1
        adc para_buf_hi         ; (carry clear) the screen cells
        sta para_cp+1
        lda para_ro+1
        clc
        adc #>COLRAM
        sta para_cl+1           ; and their colour RAM
        lda para_cr             ; which cells show cloud at this offset
        asl
        asl
        asl
        ora para_sub
        tax
        lda para_ne,x
        sta para_bits
        lda para_cr             ; the strip rows: 8 + 8 * cr - sub
        asl
        asl
        asl
        clc
        adc #8
        sec
        sbc para_sub
        sta para_so
        ldx #0                  ; X = the column in the cloud
.cell   lsr para_bits
        bcs +
        jmp .nextcell           ; no cloud in this one
+       txa
        tay
        lda (para_cp),y         ; the map char there
        ldy para_count          ; save it, and where it was
        sta para_code,y
        sta para_up
        txa
        clc
        adc para_ro
        sta para_idx_lo,y
        lda para_ro+1
        adc #0
        sta para_idx_hi,y
        inc para_count
        lda #0                  ; its bitmap: CHARSET + code * 8
        asl para_up
        rol
        asl para_up
        rol
        asl para_up
        rol
        adc #>CHARSET           ; (carry clear; CHARSET is page aligned)
        sta para_up+1
        txa                     ; the pool char and the cloud colour into
        tay                     ;   the screen cell (border time: nothing
        lda para_k              ;   tears)
        clc
        adc #PARA_CODE
        sta (para_cp),y
        lda para_col
        sta (para_cl),y
        ldy para_k              ; the pool char's bitmap
        lda .pool_lo,y
        sta para_dp
        lda .pool_hi,y
        sta para_dp+1
        lda .strip_lo,x         ; the column's strip, at this row's rows
        clc
        adc para_so
        sta para_sp
        lda .strip_hi,x
        adc #0
        sta para_sp+1
        !for .b, 0, 7 {         ; map char | cloud (its pixels are '11')
        ldy #.b
        lda (para_up),y
        ora (para_sp),y
        sta (para_dp),y
        }
.nextcell
        inc para_k
        inx
        cpx #PARA_W
        beq +
        jmp .cell
+       inc para_cr
        lda para_cr
        cmp #PARA_ROWS
        beq .done
        jmp .crow
.skiprow
        lda para_k              ; (skip the row's pool chars too)
        clc
        adc #PARA_W
        sta para_k
        inc para_cr
        lda para_cr
        cmp #PARA_ROWS
        beq .done
        jmp .crow
.done   rts

.base_hi  !byte >SCREEN_A, >SCREEN_B
.row_lo   !for .r, 0, SCROLL_ROWS - 1 { !byte <(.r * COLS) }
.row_hi   !for .r, 0, SCROLL_ROWS - 1 { !byte >(.r * COLS) }
.strip_lo !for .c, 0, PARA_W - 1 { !byte <(para_strips + .c * PARA_STRIP) }
.strip_hi !for .c, 0, PARA_W - 1 { !byte >(para_strips + .c * PARA_STRIP) }
.pool_lo  !for .k, 0, PARA_CELLS - 1 { !byte <(CHARSET + (PARA_CODE + .k) * 8) }
.pool_hi  !for .k, 0, PARA_CELLS - 1 { !byte >(CHARSET + (PARA_CODE + .k) * 8) }
para_buf_hi !byte >SCREEN_A     ; the front buffer's page, as drawn

!zone para_fixup
; -----------------------------------------------------------------------------
; para_fixup: the scroller's slice X (0-5) has just copied front rows into
; the back buffer (back row r = front row r - 1), cloud chars and all: put
; the map chars and their colours back there. Clobbers A, X, Y, para_dp.
; TIMING: ~40 cycles a cloud cell.
; -----------------------------------------------------------------------------
para_fixup
        lda para_count
        beq .out
        lda .first_lo,x         ; the slice's rows, as offsets: [first, end)
        sta para_dp
        lda .first_hi,x
        sta para_dp+1
        lda .end_lo,x
        sta .el+1
        lda .end_hi,x
        sta .eh+1
        lda front_buf           ; the back buffer's page
        eor #1
        tay
        lda .base_hi,y
        sta .bh+1
        ldx para_count
        dex
.cell   lda para_idx_lo,x       ; its copy: one row down
        clc
        adc #COLS
        sta .lo+1
        lda para_idx_hi,x
        adc #0
        sta .hi+1
        cmp para_dp+1           ; at or after the slice's first row?
        bcc .next
        bne +
        lda .lo+1
        cmp para_dp
        bcc .next
+       lda .hi+1               ; and before its end?
.eh     cmp #0                  ; (self-modified: the end's high byte)
        bcc .in
        bne .next
        lda .lo+1
.el     cmp #0                  ; (the end's low byte)
        bcs .next
.in     ldy para_code,x
.lo     lda #0                  ; (self-modified: the offset)
        sta .back+1
        sta .shadow+1
.hi     lda #0
        clc
.bh     adc #0                  ; (+ the back buffer's page)
        sta .back+2
        lda .hi+1
        clc
        adc #>CRAM_SHADOW
        sta .shadow+2
        tya
.back   sta $ffff               ; (self-modified) the map char back
        lda CHAR_COL,y
.shadow sta $ffff               ; (self-modified) and its colour
.next   dex
        bpl .cell
.out    rts
.first_lo !byte <(0 * COLS), <(4 * COLS), <(8 * COLS), <(12 * COLS), <(16 * COLS), <(20 * COLS)
.first_hi !byte >(0 * COLS), >(4 * COLS), >(8 * COLS), >(12 * COLS), >(16 * COLS), >(20 * COLS)
.end_lo   !byte <(4 * COLS), <(8 * COLS), <(12 * COLS), <(16 * COLS), <(20 * COLS), <(25 * COLS)
.end_hi   !byte >(4 * COLS), >(8 * COLS), >(12 * COLS), >(16 * COLS), >(20 * COLS), >(25 * COLS)
.base_hi  !byte >SCREEN_A, >SCREEN_B
!if SLICES != 6 { !error "para_fixup: its row table assumes the scroller's 6 slices" }
!if <CRAM_SHADOW != 0 { !error "para_fixup: CRAM_SHADOW must be page aligned" }

; The schedule: where each cloud comes in, and the wait after it (frames).
para_x_t    !byte 4, 22, 12, 30, 8, 26, 16, 2
para_wait_t !byte 120, 160, 90, 200, 140, 110, 180, 100
PARA_SCHEDULE = * - para_wait_t
!if para_wait_t - para_x_t != PARA_SCHEDULE { !error "para: the schedule's tables differ in length" }
; The cloud's colour RAM value, by level: multicolour + white, or yellow at
; the sunset strait.
para_col_t  !byte 8 + COL_WHITE, 8 + COL_WHITE, 8 + COL_YELLOW, 8 + COL_WHITE

!if <CHARSET != 0 { !error "parallax: CHARSET must be page aligned" }
