; =============================================================================
; scroll.asm - smooth (1 pixel per frame) double-buffered vertical scroller
; =============================================================================
;
; HOW IT WORKS
;   The playfield uses the 24-row window (raster lines 55-246) and all 25
;   screen rows. Every frame the fine scroll ($D011 yscroll, scroll_fine)
;   goes up by one, moving the picture down a pixel. After 8 frames the
;   picture has moved a whole char row, and we show the other screen buffer,
;   in which everything sits one row lower, with the fine scroll back at 0:
;
;       back row 0      <- the next char row of the level map
;       back row r+1    <- front row r        (r = 0..23)
;
;   With yscroll 0-7 and the 24-row window, the 25 rows always cover the
;   whole window, so the top and bottom edges never show a gap.
;
;   The hidden (back) buffer is built in 6 slices, one per frame (f = 1-6).
;   The same slices build CRAM_SHADOW, the colour RAM the back buffer needs:
;   each char code has its own colour RAM value (CHAR_COL).
;
; COLOUR RAM
;   Colour RAM can't be double-buffered, so on the last frame before the
;   flip (yscroll 7) scroll_colour copies CRAM_SHADOW into $D800 one row at
;   a time, just BEHIND the raster: the VIC reads a row's colours only on
;   that row's badline, so once the badline has passed, the row's colour RAM
;   is free until the next frame. Rows 0-22 are done that way. Rows 23-24
;   are copied right after the flip (cram_late), long before their badlines
;   (lines 232 and 240): row 23's badline at yscroll 7 is line 239, and its
;   copy would end too close to the frame IRQ.
;   If a frame runs late and the flip happens first, scroll_colour stops
;   waiting and copies the remaining rows straight away, top to bottom,
;   which still stays ahead of the raster (see TIMING at scroll_colour).
;   The copier is fully unrolled code, generated at boot into BSS
;   (chase_gen), so it costs no program space.
;
; STEP TIMELINE (8 frames; f = the yscroll shown this frame)
;   f = 0        colour RAM rows 23-24, this step's wave (spawns), step on
;                to the next row (next_record). No slice: on a busy screen
;                the colour chase can spill into this frame
;   f = 1-6      slices 0-5 (slice 0 draws row_buf as the new top row)
;   f = 1-5      also: unpack 8 chars of the next step's row into row_buf
;   f = 7        request the flip (buffer swap + yscroll 0 at the next IRQ),
;                then, after the frame's logic, the colour RAM chase. No
;                slice, so the chase can start early
;
; THE LEVEL MAP is a char map, 40 codes per row, bottom row first, LZ
; packed (tools/png2level.py). It is unpacked a row at a time as it scrolls
; in, through RING, a 4 KB ring buffer that holds what back-references need.
; After the map's last row the unpacker carries on with the level's loop
; stream (the rows from the boss row up, packed on their own), and again
; after each pass, so the boss loop just keeps coming.
;
; TIMING: a slice copies 4-5 rows and builds their colours: 20 cycles per
; char plus loop overhead, about 3400 cycles for 4 rows (4200 for 5). The
; colour chase copies at 8 cycles per byte (~340 per row with its wait,
; ~7800 in all), but it mostly fills time the frame would otherwise spend
; waiting for the IRQ.
; =============================================================================

FINE_STEPS = 8                  ; frames per char row: 1 pixel per frame
SLICES     = 6                  ; build frames per step (f = 1-6)
CHASE_LINE0 = 48 + (FINE_STEPS-1) + 1 ; first line after row 0's badline at yscroll 7

; Slice row ranges (copy_ab_n / copy_ba_n): 0-3, 4-7, 8-11, 12-15, 16-19,
; 20-24.
!if SCROLL_ROWS != 25 { !error "the slice row ranges assume 25 scroll rows" }

!zone scroll_init
; -----------------------------------------------------------------------------
; scroll_init: start the level map at row 0 and draw its first SCROLL_ROWS
; rows straight into SCREEN_A, colour RAM and CRAM_SHADOW (row 0 at the
; bottom). Runs with the display off; level_begin has unpacked the level
; and set up CHAR_COL. Leaves SCREEN_A in front, yscroll 0, at the start of
; a step.
; -----------------------------------------------------------------------------
PREFILL_OFS = (SCROLL_ROWS - 1) * COLS  ; offset of the bottom row

scroll_init
        lda #0
        sta lvl_row
        sta lvl_row+1           ; (wave_ptr: level_load; the map stream:
                                ;   level_unpack)

        ; SCREEN_A, COLRAM and CRAM_SHADOW all start on a page boundary, so
        ; one row offset serves all three: only the high bytes differ.
        lda #<(SCREEN_A + PREFILL_OFS)
        sta zp_ptr0
        sta zp_ptr1
        lda #>(SCREEN_A + PREFILL_OFS)
        sta zp_ptr0+1
        lda #>(COLRAM + PREFILL_OFS)
        sta zp_ptr1+1
        lda #SCROLL_ROWS
        sta zp_tmp1             ; rows left
.rec    jsr fetch_record        ; row_buf = the next row
        ldy #COLS-1
-       lda row_buf,y           ; screen and colour RAM
        sta (zp_ptr0),y
        tax
        lda CHAR_COL,x
        sta (zp_ptr1),y
        dey
        bpl -
        lda zp_ptr1+1           ; the same colours into CRAM_SHADOW (rows
        pha                     ;   23-24 are read from there at the first
        sec                     ;   f = 0)
        sbc #>(COLRAM - CRAM_SHADOW)
        sta zp_ptr1+1
        ldy #COLS-1
-       lda row_buf,y
        tax
        lda CHAR_COL,x
        sta (zp_ptr1),y
        dey
        bpl -
        pla
        sta zp_ptr1+1
        lda zp_ptr0             ; up one row
        sec
        sbc #COLS
        sta zp_ptr0
        sta zp_ptr1
        bcs +
        dec zp_ptr0+1
        dec zp_ptr1+1
+       dec zp_tmp1
        bne .rec
        jsr decode_row          ; the first step's row (later f = 1-5 do it)

!if (<COLRAM != <SCREEN_A) | (<CRAM_SHADOW != <SCREEN_A) { !error "prefill needs page-aligned buffers" }

        lda #0
        sta front_buf
        sta scroll_fine
        sta scroll_slice
        sta flip_pending
        sta scroll_chase
        sta rec_spawns          ; prefill records never spawn (macros enforce)
        lda #D018_A
        sta VIC_MEM
        rts

!zone scroll_update
; -----------------------------------------------------------------------------
; scroll_update: call once per frame from the main loop's border work.
; Builds a slice of the back buffer and sets the next frame's yscroll.
; -----------------------------------------------------------------------------
scroll_update
        lda flip_pending        ; the last flip hasn't happened yet (can't
        bne .done               ;   normally happen): hold everything

        lda scroll_fine
        bne .slice
        ; f = 0: the IRQ just showed the new buffer
        jsr cram_late           ; its last two colour RAM rows
        jsr next_record         ; this step's row (in row_buf since f = 5,
        lda boss_flag           ;   slice 0 draws it): launch its wave, if
        bne .next               ;   any (spawn = scroll position), step on.
        jsr enemies_spawn       ;   Not once the boss is due: the title's
        jmp .next               ;   keys 1-4 bring it at the level's start,
                                ;   with all its waves still to come, and
                                ;   they'd sit frozen in the boss's spare
                                ;   slots (enemies_update stands still)

.slice  ldx scroll_slice
        cpx #SLICES
        bcs .next
        jsr run_slice           ; f = 1-6: build slice f - 1
!ifdef TURBO {
        ldx scroll_slice        ; the turbo build's cloud was copied too: put
        jsr para_fixup          ;   the map back under it (parallax.asm)
}
        inc scroll_slice
        lda scroll_fine
        cmp #1                  ; f = 1: slice 0 has drawn row_buf, so the
        bne +                   ;   next row can start
        lda #0
        sta st_out
+       lda scroll_fine
        cmp #6                  ; f = 1-5: 8 more of its chars
        bcs .next
        jsr decode_some

.next   lda scroll_fine         ; next frame's yscroll
        cmp #FINE_STEPS - 1
        beq .flip
        clc
        adc #1
        sta scroll_fine
        ora #D011_PLAY
        sta scroll_d011         ; (one store: the IRQ sees old or new, both fine)
.done   rts

        ; f = 7: the back buffer is complete. Swap at the next IRQ, with yscroll
        ; 0 in the same instant, and copy the colours this frame.
.flip   jsr decode_rest         ; (normally done already)
        lda front_buf
        eor #1
        sta front_buf
        tax
        lda d018_tab,x
        sta next_d018
        lda #0
        sta scroll_fine
        sta scroll_slice
        sei                     ; the IRQ must see both or neither
        lda #D011_PLAY
        sta scroll_d011
        lda #1
        sta flip_pending
        cli
        sta scroll_chase        ; scroll_colour runs at the end of this frame
        rts

!zone scroll_colour
; -----------------------------------------------------------------------------
; scroll_colour: the colour RAM chase. Call at the end of every play frame,
; after the logic; it does nothing unless scroll_update requested a flip in
; this frame. Copies CRAM_SHADOW rows 0-22 into colour RAM, each one just
; after the raster has passed that row's badline (yscroll 7: line 55 + 8r).
;
; TIMING: each row takes about 410 cycles (6.5 lines; more with sprites on
; those lines), less than the 8 lines the raster needs per row, so the copy
; keeps catching up and waiting. Row 22's badline is line 231, so the copy
; ends near line 240, well before the next frame IRQ (251).
; If the IRQ has already fired (frame_flag set: this frame ran long, and the
; flip has happened), every remaining row is copied at once, top to bottom.
; The new frame shows row r at line 48 + 8r, and the copy started in the
; lower border, about 5000 cycles ahead of row 0, gaining ~50 cycles a row.
; Clobbers A, X.
; -----------------------------------------------------------------------------
scroll_colour
        lda scroll_chase
        bne +
        rts
+       lda #0
        sta scroll_chase
        jmp chase_code          ; (generated by chase_gen; its RTS returns)

!zone chase_gen
; -----------------------------------------------------------------------------
; chase_gen: write the colour chase as straight-line code into chase_code
; (BSS), once at boot. For each row r = 0..CHASE_ROWS-1:
;       lda #CHASE_LINE0 + 8r
;       jsr chase_wait
;       lda CRAM_SHADOW + r*40 + c  /  sta COLRAM + r*40 + c   (c = 0..39)
; then RTS. 8 cycles per byte, with no loop overhead.
; Clobbers A, X, Y, zp_ptr0, zp_ptr1, zp_tmp0, zp_tmp1.
; -----------------------------------------------------------------------------

chase_gen
        lda #<chase_code
        sta zp_ptr0
        lda #>chase_code
        sta zp_ptr0+1
        lda #<CRAM_SHADOW       ; the running source address (the colour RAM
        sta zp_ptr1             ;   address has the same low byte)
        lda #>CRAM_SHADOW
        sta zp_ptr1+1
        lda #CHASE_LINE0
        sta zp_tmp0
        lda #CHASE_ROWS
        sta zp_tmp1
.row    lda #$a9                ; lda #line
        jsr .emit
        lda zp_tmp0
        jsr .emit
        clc
        adc #8
        sta zp_tmp0
        lda #$20                ; jsr chase_wait
        jsr .emit
        lda #<chase_wait
        jsr .emit
        lda #>chase_wait
        jsr .emit
        ldx #COLS
.col    lda #$ad                ; lda abs
        jsr .emit
        lda zp_ptr1
        jsr .emit
        lda zp_ptr1+1
        jsr .emit
        lda #$8d                ; sta abs
        jsr .emit
        lda zp_ptr1
        jsr .emit
        lda zp_ptr1+1
        clc
        adc #>(COLRAM - CRAM_SHADOW)
        jsr .emit
        inc zp_ptr1
        bne +
        inc zp_ptr1+1
+       dex
        bne .col
        dec zp_tmp1
        bne .row
        lda #$60                ; rts
        ; (fall through)
.emit   ldy #0
        sta (zp_ptr0),y
        inc zp_ptr0
        bne +
        inc zp_ptr0+1
+       rts

!if <COLRAM != <CRAM_SHADOW { !error "chase_gen: shadow and colour RAM must share the low byte" }

; chase_wait: return once the raster is at line A or below it in the frame
; being shown, or at once if the next frame IRQ has already fired.
; Lines 251-311 (and 0 up to A) still count as before it.
chase_wait
        sta chase_line
-       lda frame_flag          ; the flip happened: no more waiting
        bne +
        lda VIC_CTRL1
        bmi -                   ; lines 256-311: previous frame's lower border
        lda VIC_RASTER
        cmp #IRQ_LINE
        bcs -                   ; lines 251-255: the same
        cmp chase_line
        bcc -
+       rts

; cram_late: CRAM_SHADOW rows 23-24 -> colour RAM (f = 0, and pause.asm).
; TIMING: ~820 cycles, done in the lower border; the first of these badlines
; is line 232.
cram_late
        ldx #COLS/4 - 1
-       !for .r, CHASE_ROWS, SCROLL_ROWS - 1 {
        !for .q, 0, 3 {
        lda CRAM_SHADOW + .r*COLS + .q*COLS/4,x
        sta COLRAM      + .r*COLS + .q*COLS/4,x
        }
        }
        dex
        bpl -
        rts
!if COLS % 4 != 0 { !error "colour copies assume COLS divisible by 4" }

!zone fetch_record
; -----------------------------------------------------------------------------
; Row lvl_row is the next char row to scroll in; row_buf holds it once it
; has been unpacked from the map stream (st_byte).
;
; fetch_record (the prefill): decode_row, then next_record.
; next_record: row lvl_row's wave, then on to the next row.
;   out: rec_ptr / rec_spawns = the wave and its spawn count (0 = none), for
;          enemies_spawn (the prefill ignores them)
;        boss_flag = 1 once the boss row has come
;   After the picture's top row lvl_row goes back to the boss row (the map
;   stream follows by itself).
; Clobbers A, X, Y, zp_tmp0.
; -----------------------------------------------------------------------------
fetch_record
        jsr decode_row
        ; (fall through)
next_record
        lda lvl_row             ; the boss row: the fight starts
        cmp lvl_boss
        bne +
        lda lvl_row+1
        cmp lvl_boss+1
        bne +
        lda #1
        sta boss_flag
+
        ; --- its wave? (waves are in row order; the list ends with $FFFF) ---
        lda #0
        sta rec_spawns
        ldy #0
        lda (wave_ptr),y
        cmp lvl_row
        bne .step
        iny
        lda (wave_ptr),y
        cmp lvl_row+1
        bne .step
        iny
        lda (wave_ptr),y        ; spawn count
        sta rec_spawns
        sta zp_tmp0
        lda wave_ptr
        sta rec_ptr
        lda wave_ptr+1
        sta rec_ptr+1
        lda zp_tmp0             ; wave_ptr += 3 + 3 * count
        asl
        adc zp_tmp0             ; (count <= 8: no carry)
        adc #WAVE_HEAD
        adc wave_ptr
        sta wave_ptr
        bcc .step
        inc wave_ptr+1

.step   inc lvl_row             ; next row; past the top of the picture,
        bne +                   ;   back to the boss row
        inc lvl_row+1
+       lda lvl_row
        cmp lvl_rows
        bne +
        lda lvl_row+1
        cmp lvl_rows+1
        bne +
        lda lvl_boss
        sta lvl_row
        lda lvl_boss+1
        sta lvl_row+1
+       rts

!zone decode_row
; -----------------------------------------------------------------------------
; decode_row: unpack a whole row into row_buf. decode_rest: the rest of it.
; decode_some: up to 8 more of its chars. (st_out counts them.)
; TIMING: ~45 cycles per char. Clobber A, X, Y.
; -----------------------------------------------------------------------------
decode_row
        lda #0
        sta st_out
decode_rest
        lda #COLS
        bne +
decode_some
        lda st_out
        clc
        adc #8
        cmp #COLS
        bcc +
        lda #COLS
+       sta st_lim
        ldx st_out
-       cpx st_lim
        bcs +
        jsr st_byte
        sta row_buf,x
        inx
        bne -
+       stx st_out
        rts

!zone st_byte
; -----------------------------------------------------------------------------
; st_byte: the map stream's next char code -> A, also written into RING
; (back-references copy from there). LZ format: src/unpack.asm. At the end
; marker the stream carries on with the level's loop stream (st_loop).
; Preserves X. Clobbers Y.
; -----------------------------------------------------------------------------
st_byte
        ldy #0
        lda st_left
        bne .have
.token  lda (st_src),y
        inc st_src
        bne +
        inc st_src+1
+       cmp #$ff
        bne +
        lda st_loop             ; end of a stream: the boss loop (again)
        sta st_src
        lda st_loop+1
        sta st_src+1
        jmp .token
+       cmp #$80
        bcs .match
        adc #1                  ; literal run of A + 1 (carry clear)
        sta st_left
        lda #0
        sta st_mode
        beq .have               ; (always)
.match  and #$7f
        adc #3 - 1              ; length (carry set: + 1)
        sta st_left
        lda st_wp               ; st_rp = st_wp - distance, inside the ring
        sec
        sbc (st_src),y
        sta st_rp
        iny
        lda st_wp+1
        sbc (st_src),y
        cmp #>RING
        bcs +
        adc #>RING_SIZE         ; (carry clear) wrap round the ring
+       sta st_rp+1
        ldy #0
        lda st_src              ; skip the 2 distance bytes
        clc
        adc #2
        sta st_src
        bcc +
        inc st_src+1
+       lda #1
        sta st_mode
.have   dec st_left
        lda st_mode
        bne .copy
        lda (st_src),y          ; a literal byte
        inc st_src
        bne .put
        inc st_src+1
        bne .put                ; (always)
.copy   lda (st_rp),y           ; a byte of the match
        inc st_rp
        bne .put
        inc st_rp+1
        pha
        lda st_rp+1
        cmp #>(RING + RING_SIZE)
        bne +
        lda #>RING
        sta st_rp+1
+       pla
.put    sta (st_wp),y
        inc st_wp
        bne +
        inc st_wp+1
        pha
        lda st_wp+1
        cmp #>(RING + RING_SIZE)
        bne ++
        lda #>RING
        sta st_wp+1
++      pla
+       rts

!if <RING != 0 | <RING_SIZE != 0 | RING + RING_SIZE > $10000 { !error "RING must be whole pages" }

!zone run_slice
; -----------------------------------------------------------------------------
; run_slice: build slice X (0-5) of the back buffer from the front buffer.
; Dispatches to one of 12 unrolled routines (2 directions x 6 slices).
; Clobbers A, X, Y, zp_ptr0.
; -----------------------------------------------------------------------------
run_slice
        txa
        ldy front_buf
        clc
        adc slice_base,y        ; + 0 (front = A) or 7 (front = B)
        asl                     ; * 2 bytes per vector
        tay
        lda slice_vectors,y
        sta zp_ptr0
        lda slice_vectors+1,y
        sta zp_ptr0+1
        jmp (zp_ptr0)           ; the slice routine's RTS returns to our caller

slice_base
        !byte 0, SLICES

slice_vectors
        !word copy_ab_0, copy_ab_1, copy_ab_2, copy_ab_3   ; front = A
        !word copy_ab_4, copy_ab_5
        !word copy_ba_0, copy_ba_1, copy_ba_2, copy_ba_3   ; front = B
        !word copy_ba_4, copy_ba_5

d018_tab
        !byte D018_A, D018_B

; -----------------------------------------------------------------------------
; Unrolled slice builders, one column (Y) per loop pass. For each row r of
; the slice: dst row r <- src row r-1 (row 0: the new pattern), and
; CRAM_SHADOW row r <- CHAR_COL of that char.
; TIMING: 20 cycles per char (21 for row 0) + 5 per column.
; -----------------------------------------------------------------------------
!macro slice .src, .dst, .first, .last {
        ldy #COLS-1
-       !for .r, .first, .last {
        !if .r = 0 {
        lda row_buf,y
        } else {
        lda .src + (.r-1)*COLS,y
        }
        sta .dst + .r*COLS,y
        tax
        lda CHAR_COL,x
        sta CRAM_SHADOW + .r*COLS,y
        }
        dey
        bpl -
        rts
}

copy_ab_0       +slice SCREEN_A, SCREEN_B, 0, 3
copy_ab_1       +slice SCREEN_A, SCREEN_B, 4, 7
copy_ab_2       +slice SCREEN_A, SCREEN_B, 8, 11
copy_ab_3       +slice SCREEN_A, SCREEN_B, 12, 15
copy_ab_4       +slice SCREEN_A, SCREEN_B, 16, 19
copy_ab_5       +slice SCREEN_A, SCREEN_B, 20, 24
copy_ba_0       +slice SCREEN_B, SCREEN_A, 0, 3
copy_ba_1       +slice SCREEN_B, SCREEN_A, 4, 7
copy_ba_2       +slice SCREEN_B, SCREEN_A, 8, 11
copy_ba_3       +slice SCREEN_B, SCREEN_A, 12, 15
copy_ba_4       +slice SCREEN_B, SCREEN_A, 16, 19
copy_ba_5       +slice SCREEN_B, SCREEN_A, 20, 24
