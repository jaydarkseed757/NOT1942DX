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
;       back row 0      <- new row pattern from the level stream
;       back row r+1    <- front row r        (r = 0..23)
;
;   With yscroll 0-7 and the 24-row window, the 25 rows always cover the
;   whole window, so the top and bottom edges never show a gap.
;
;   The hidden (back) buffer is built in 7 slices, one per frame (f = 1-7).
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
;   f = 0        colour RAM rows 23-24, fetch record + spawns. No slice: on
;                a busy screen the colour chase can spill into this frame
;   f = 1-7      slices 0-6
;   f = 7        also: request the flip (buffer swap + yscroll 0 at the next
;                IRQ), then, after the frame's logic, the colour RAM chase
;
; TIMING: a slice copies 3-4 rows and builds their colours: 20 cycles per
; char plus loop overhead, about 3400 cycles for 4 rows (2600 for 3). The
; colour chase copies at 8 cycles per byte (~340 per row with its wait,
; ~7800 in all), but it mostly fills time the frame would otherwise spend
; waiting for the IRQ.
; =============================================================================

FINE_STEPS = 8                  ; frames per char row: 1 pixel per frame
SLICES     = 7                  ; build frames per step (f = 1-7)
CHASE_LINE0 = 48 + (FINE_STEPS-1) + 1 ; first line after row 0's badline at yscroll 7

; Slice row ranges (copy_ab_n / copy_ba_n): 0-3, 4-7, 8-11, 12-15, 16-18,
; 19-21, 22-24 (the 3-row ones last: f = 7 also has the colour chase).
!if SCROLL_ROWS != 25 { !error "the slice row ranges assume 25 scroll rows" }

!zone scroll_init
; -----------------------------------------------------------------------------
; scroll_init: point at the level start and draw the first SCROLL_ROWS
; records straight into SCREEN_A, colour RAM and CRAM_SHADOW (record 0 at
; the bottom). Runs with the display off. CHAR_COL must be set up.
; Leaves SCREEN_A in front, yscroll 0, at the start of a step.
; -----------------------------------------------------------------------------
PREFILL_OFS = (SCROLL_ROWS - 1) * COLS  ; offset of the bottom row

scroll_init
        lda lvl_start           ; current level's stream (level_load)
        sta level_ptr
        lda lvl_start+1
        sta level_ptr+1
        lda #0
        sta lvl_loop+1          ; no boss loop point yet

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
        sta zp_tmp1             ; records left
.rec    jsr fetch_record        ; row_ptr -> this record's pattern
        ldy #COLS-1
-       lda (row_ptr),y         ; screen and colour RAM
        sta (zp_ptr0),y
        tax
        lda CHAR_COL,x
        sta (zp_ptr1),y
        dey
        bpl -
        lda zp_ptr1+1           ; the same colours into CRAM_SHADOW (row 24
        pha                     ;   is read from there at the first f = 0)
        sec
        sbc #>(COLRAM - CRAM_SHADOW)
        sta zp_ptr1+1
        ldy #COLS-1
-       lda (row_ptr),y
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
        jsr fetch_record        ; read this step's level record (row_ptr:
        jsr enemies_spawn       ;   slice 0 draws it) and launch its enemies
        jmp .next               ;   (spawn = scroll position)

.slice  ldx scroll_slice
        cpx #SLICES
        bcs .next
        jsr run_slice           ; f = 1-7: build slice f - 1
        inc scroll_slice

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
.flip   lda front_buf
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
; fetch_record: read the next level stream record.
;   out: row_ptr -> 40-byte row pattern for the new top row (from the
;          current level's table, lvl_rowpats)
;        rec_ptr / rec_spawns = this record and its spawn count (for
;          enemies_spawn; the prefill ignores them)
;        level_ptr advanced past the record
; LVL_BOSS (+boss_here) takes no scroll step: it records the loop point, sets
; boss_flag for level_update, and the next record is read instead.
; LVL_END jumps back to the loop point (or the stream start if none).
; Clobbers A, Y, zp_tmp0.
; -----------------------------------------------------------------------------
fetch_record
.again  ldy #0
        lda (level_ptr),y
        cmp #LVL_END
        bne .notend
        lda lvl_loop+1          ; end of stream: back to the boss loop point
        beq .tostart
        sta level_ptr+1
        lda lvl_loop
        sta level_ptr
        jmp .again
.tostart
        lda lvl_start           ; (no boss marker: loop the whole level)
        sta level_ptr
        lda lvl_start+1
        sta level_ptr+1
        jmp .again
.notend cmp #LVL_BOSS
        bne .have
        inc level_ptr           ; skip the 1-byte marker
        bne +
        inc level_ptr+1
+       lda level_ptr           ; the loop body starts here
        sta lvl_loop
        lda level_ptr+1
        sta lvl_loop+1
        lda #1
        sta boss_flag
        jmp .again

.have   ; row_ptr = lvl_rowpats + index * 40, all in 16 bits (index 0-253)
        sta zp_tmp0
        lda #0
        sta row_ptr+1
        lda zp_tmp0
        asl                     ; *2
        rol row_ptr+1
        asl                     ; *4
        rol row_ptr+1
        clc
        adc zp_tmp0             ; *5
        bcc +
        inc row_ptr+1
+       asl                     ; *10
        rol row_ptr+1
        asl                     ; *20
        rol row_ptr+1
        asl                     ; *40
        rol row_ptr+1
        clc
        adc lvl_rowpats
        sta row_ptr
        lda row_ptr+1
        adc lvl_rowpats+1
        sta row_ptr+1

        ; remember the record for enemies_spawn
        lda level_ptr
        sta rec_ptr
        lda level_ptr+1
        sta rec_ptr+1

        ; advance level_ptr by 2 + 3 * spawn_count
        iny
        lda (level_ptr),y       ; spawn count (0-3)
        sta rec_spawns
        sta zp_tmp0
        asl                     ; *2 (carry clear: count <= 3)
        adc zp_tmp0             ; *3
        adc #2                  ; + header (carry still clear)
        clc
        adc level_ptr
        sta level_ptr
        bcc +
        inc level_ptr+1
+       rts

!zone run_slice
; -----------------------------------------------------------------------------
; run_slice: build slice X (0-6) of the back buffer from the front buffer.
; Dispatches to one of 14 unrolled routines (2 directions x 7 slices).
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
        !word copy_ab_4, copy_ab_5, copy_ab_6
        !word copy_ba_0, copy_ba_1, copy_ba_2, copy_ba_3   ; front = B
        !word copy_ba_4, copy_ba_5, copy_ba_6

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
        lda (row_ptr),y
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
copy_ab_4       +slice SCREEN_A, SCREEN_B, 16, 18
copy_ab_5       +slice SCREEN_A, SCREEN_B, 19, 21
copy_ab_6       +slice SCREEN_A, SCREEN_B, 22, 24
copy_ba_0       +slice SCREEN_B, SCREEN_A, 0, 3
copy_ba_1       +slice SCREEN_B, SCREEN_A, 4, 7
copy_ba_2       +slice SCREEN_B, SCREEN_A, 8, 11
copy_ba_3       +slice SCREEN_B, SCREEN_A, 12, 15
copy_ba_4       +slice SCREEN_B, SCREEN_A, 16, 18
copy_ba_5       +slice SCREEN_B, SCREEN_A, 19, 21
copy_ba_6       +slice SCREEN_B, SCREEN_A, 22, 24
