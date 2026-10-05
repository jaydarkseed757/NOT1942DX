; =============================================================================
; mux.asm - sprite multiplexer: NUM_SLOTS virtual sprites on 8 hardware ones
; =============================================================================
;
; Game code never touches the VIC sprite registers. It sets up virtual
; sprite slots in BSS (spr_xh, spr_y, spr_ptr, spr_col, spr_exp, spr_mc,
; and spr_on to show one), exactly as it used to set the 8 hardware ones.
; spr_exp and spr_mc are masks, $FF or 0, so they AND straight into the
; hardware sprite's register bit.
;
; ONCE PER FRAME (mux_build, at the end of the frame's logic)
;   1. Sort the slots by Y. mux_order is kept from frame to frame, so an
;      insertion sort finds it nearly sorted (~35 cycles per slot).
;   2. Turn the sorted slots into a DISPLAY LIST. Entry k uses hardware
;      sprite k & 7, so entries k and k-8 share one. An entry may reuse it
;      only once the earlier one has finished (its last line + MUX_SETUP);
;      otherwise the slot is DROPPED for this frame (mux_drops counts them).
;      Entries 8+ get an IRQ line: MUX_LEAD lines before they start, but not
;      before the earlier user of their hardware sprite has finished.
;   3. Commit the list (mux_commit). Lists are double-buffered: the IRQs
;      show one while mux_build writes the other.
;
; THE IRQs (system.asm)
;   The frame IRQ (line 251) takes a committed list, writes its first 8
;   entries to the VIC and, if there are more, points the raster IRQ at
;   mux_irq for entry 8. mux_irq writes each entry when its line comes and
;   finally hands the raster IRQ back to the frame IRQ. The frame IRQ shows
;   the same list again until a new one is committed, so pause (no
;   mux_build) and a late frame (the old list once more) both look right.
;
; TIMING: mux_build ~600 cycles to sort + ~90 per slot drawn. The frame IRQ
; writes the first 8 entries (~70 cycles each); mux_irq costs ~80 cycles per
; entry plus ~70 per IRQ. Writes for entry k land after entry k-8's last line,
; so a hardware sprite is never changed while it is being drawn.
; KNOWN LIMIT: if several entries share nearly the same line, their writes
; queue up (~80 cycles each), and an entry written after its first line has
; passed is not shown that frame.
; =============================================================================

MUX_Y_OFF  = PLAY_Y_END         ; spr_y >= this: below the window, not drawn
MUX_LEAD   = 4                  ; IRQ this many lines before an entry starts
MUX_SETUP  = 3                  ; ...but at least this many lines are needed
SPR_HEIGHT = 21
SPR_HEIGHT_EXP = 42

!zone mux_init
; -----------------------------------------------------------------------------
; mux_init: constant tables, sort order, empty lists. Boot, before the IRQ
; is enabled (BSS is cleared already). Clobbers A, X.
; -----------------------------------------------------------------------------
mux_init
        ldx #2*MUX_LIST - 1
-       txa
        and #7
        asl
        sta hw2_of,x            ; (k & 7) * 2
        lsr
        tay
        lda .bits,y
        sta bit_of,x
        eor #$ff
        sta nbit_of,x
        dex
        bpl -
        ldx #NUM_SLOTS - 1
-       txa
        sta mux_order,x
        dex
        bpl -
        lda #0
        sta mux_commit
        sta mux_s_base
        sta mux_s_end           ; nothing to show
        sta mux_s_en
        sta mux_s_msb
        sta mux_s_exp
        sta mux_next
        rts
.bits   !byte $01, $02, $04, $08, $10, $20, $40, $80

!zone init_sprites
; -----------------------------------------------------------------------------
; init_sprites: colours, modes, every slot off and reset. Clobbers A, X.
; -----------------------------------------------------------------------------
init_sprites
        lda #0
        sta SPR_PRIO            ; sprites in front of the background
        lda #%11111111          ; all hardware sprites multicolour
        sta SPR_MCOL
        lda #SPR_SHARED1
        sta SPR_MC0
        lda #SPR_SHARED2
        sta SPR_MC1
        ldx #NUM_SLOTS - 1      ; every slot off, normal size, multicolour,
-       lda #$ff                ;   a valid shape
        sta spr_mc,x
        lda #0
        sta spr_on,x
        sta spr_exp,x
        sta spr_xh,x
        sta spr_y,x
        lda #PTR_SHIP
        sta spr_ptr,x
        lda #COL_PLAYER
        sta spr_col,x
        dex
        bpl -
        lda #COL_PBULLET
        ldx #PBULLET_COUNT - 1
-       sta spr_col + SLOT_PBULLET0,x
        dex
        bpl -
        rts

; sprites_off: hide every slot from the next frame on. Clobbers A, X, Y.
sprites_off
        lda #0
        ldx #NUM_SLOTS - 1
-       sta spr_on,x
        dex
        bpl -
        jmp mux_build

!zone mux_build
; -----------------------------------------------------------------------------
; mux_build: sort the slots and commit a new display list (see the top).
; Call once per frame after the logic, and whenever a screen changes its
; sprites. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
mux_build
        lda #0                  ; the IRQ must not take a half-built list
        sta mux_commit
        sta mux_drops

        ; --- 1. sort keys: Y, or $FF for slots that aren't drawn: off, below
        ; the window, or wholly above it (in the top border, where a sprite
        ; isn't seen but would still hold a hardware sprite)
        ldx #NUM_SLOTS - 1
.key    lda spr_on,x
        beq .off
        lda spr_y,x
        cmp #MUX_Y_OFF
        bcs .off
        cmp #PLAY_Y_MIN - SPR_HEIGHT + 1
        bcs .on                 ; reaches the window
        ldy spr_exp,x
        beq .off                ; normal height: all above the window
        cmp #PLAY_Y_MIN - SPR_HEIGHT_EXP + 1
        bcs .on                 ; expanded: reaches the window
.off    lda #$ff
.on     sta mux_key,x
        dex
        bpl .key

        ; --- 2. insertion sort of mux_order by key (stable) ---
        ldx #1
.outer  stx mux_ti
        ldy mux_order,x         ; v = the slot to insert
        lda mux_key,y
        cmp #$ff                ; not drawn: >= everything, stays put
        beq .skip
        sty mux_tv
        sta mux_tkey
.inner  ldy mux_order-1,x       ; u = the slot before it
        lda mux_key,y
        cmp mux_tkey
        bcc .place              ; key[u] <= key[v]: v goes here
        beq .place
        tya                     ; u moves up one place
        sta mux_order,x
        dex
        bne .inner
.place  lda mux_tv
        sta mux_order,x
.skip   ldx mux_ti
        inx
        cpx #NUM_SLOTS
        bne .outer

        ; --- 3. the display list, in the buffer that isn't being shown ---
        ; Entries 0-7 (the frame IRQ writes them) need no reuse check; later
        ; ones do. Their first-8 $D010/$D017/$D01C bits are gathered as we go.
        lda #0
        sta mux_p_msb
        sta mux_p_exp
        sta mux_p_mc
        lda mux_s_base
        eor #MUX_LIST
        sta mux_p_base
        tay                     ; Y = entry k (absolute index)
        clc
        adc #8
        sta mux_te              ; (first the end of entries 0-7)
        ldx #0
        stx mux_ti
.first  ldx mux_ti
        cpx #NUM_SLOTS
        beq .listed
        inc mux_ti
        lda mux_order,x
        tax                     ; X = the slot
        lda mux_key,x
        cmp #$ff
        beq .listed             ; sorted: no more slots are drawn
        sta mux_ty
        jsr .entry
        lda mux_p_msb
        ora l_msb,y
        sta mux_p_msb
        lda mux_p_exp
        ora l_exp,y
        sta mux_p_exp
        lda mux_p_mc
        ora l_mc,y
        sta mux_p_mc
        iny
        cpy mux_te
        bne .first

.slot   ldx mux_ti              ; entries 8 and up
        cpx #NUM_SLOTS
        beq .listed
        inc mux_ti
        lda mux_order,x
        tax
        lda mux_key,x
        cmp #$ff
        beq .listed
        sta mux_ty
        lda l_end-8,y           ; when the earlier user of this hw sprite ends
        sta mux_te
        lda mux_ty
        sec
        sbc mux_te              ; y - end: starts after it, with room to set up?
        bcc .drop
        cmp #MUX_SETUP
        bcc .drop
        lda mux_ty              ; IRQ line = max(end, y - MUX_LEAD)
        sbc #MUX_LEAD           ; (carry set)
        bcc +                   ; (y < MUX_LEAD: use end)
        cmp mux_te
        bcs ++
+       lda mux_te
++      sta l_line,y
        jsr .entry
        iny
        bne .slot               ; (always)
.drop   inc mux_drops
        bne .slot               ; (practically always; a wrap just counts 0)
        beq .slot

.listed sty mux_p_end
        tya                     ; $D015 for the first 8 entries
        sec
        sbc mux_p_base
        cmp #8
        bcc +
        lda #8
+       tax
        lda .enable,x
        sta mux_p_en
        lda #1
        sta mux_commit          ; the next frame IRQ takes it
        rts

; .entry: fill entry Y from slot X (Y = mux_ty). Preserves X, Y.
.entry  lda mux_ty
        sta l_y,y
        lda spr_exp,x           ; end line = y + 21, or + 42 if expanded
        and bit_of,y
        sta l_exp,y
        lda spr_exp,x
        and #SPR_HEIGHT_EXP - SPR_HEIGHT
        clc
        adc #SPR_HEIGHT
        adc mux_ty
        bcc +
        lda #$ff                ; past line 255: never reused this frame
+       sta l_end,y
        lda spr_mc,x            ; $D01C bit: multicolour unless hires
        and bit_of,y
        sta l_mc,y
        lda spr_xh,x            ; hardware X = half-X * 2, bit 8 -> $D010
        asl
        sta l_x,y
        lda #0
        bcc +
        lda bit_of,y
+       sta l_msb,y
        lda spr_ptr,x
        sta l_ptr,y
        lda spr_col,x
        sta l_col,y
        rts

.enable !byte $00, $01, $03, $07, $0f, $1f, $3f, $7f, $ff

; -----------------------------------------------------------------------------
; +mux_write : write display list entry Y to its hardware sprite (k & 7).
; IRQ only. Pointers go into both screen buffers, so a scroll flip can never
; show a stale shape. Clobbers A, X.
; -----------------------------------------------------------------------------
!macro mux_write {
        ldx hw2_of,y
        lda l_x,y
        sta SPR0_X,x
        lda l_y,y
        sta SPR0_Y,x
        txa
        lsr
        tax
        lda l_col,y
        sta SPR0_COL,x
        lda l_ptr,y
        sta SCREEN_A + SPRPTR_OFS,x
        sta SCREEN_B + SPRPTR_OFS,x
}

!zone mux_frame
; -----------------------------------------------------------------------------
; mux_frame: called by the frame IRQ (line 251). Takes a newly committed
; list, writes its first 8 entries and arms mux_irq for the rest.
; TIMING: ~100 + ~45 cycles per entry; all in the lower border. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
mux_frame
        lda mux_commit
        beq +
        lda mux_p_base          ; show the new list
        sta mux_s_base
        lda mux_p_end
        sta mux_s_end
        lda mux_p_en
        sta mux_s_en
        lda mux_p_msb
        sta mux_s_msb
        lda mux_p_exp
        sta mux_s_exp
        lda mux_p_mc
        sta mux_s_mc
        lda #0
        sta mux_commit
+       lda mux_s_en
        sta SPR_ENABLE
        lda mux_s_msb
        sta mux_d010
        sta SPR_XMSB
        lda mux_s_exp
        sta mux_d017
        sta SPR_YEXP
        sta SPR_XEXP
        lda mux_s_mc
        sta mux_d01c
        sta SPR_MCOL
        ldy mux_s_base
.first  cpy mux_s_end
        bcs .done               ; 8 or fewer: no IRQs needed
        tya
        sec
        sbc mux_s_base
        cmp #8
        bcs .arm
        +mux_write
        iny
        bne .first
.arm    sty mux_next            ; entry 8: its IRQ
        lda l_line,y
        sta VIC_RASTER
        lda #<mux_irq
        sta $fffe
        lda #>mux_irq
        sta $ffff
.done   rts

!zone mux_irq
; -----------------------------------------------------------------------------
; mux_irq: raster IRQ for display list entries 8 and up. Writes every entry
; whose line has come, then waits for the next one, or hands the raster IRQ
; back to the frame IRQ after the last.
; Re-entering is harmless: it only writes entries whose line has come.
; -----------------------------------------------------------------------------
mux_irq
        pha
        txa
        pha
        tya
        pha
        cld                     ; (the main code may be mid-BCD add)
        tsx                     ; a BRK lands here too while this vector is set
        lda $0104,x
        and #%00010000
        beq +
        jmp brk_trap
+       ldy mux_next
.loop   cpy mux_s_end
        bcs .end
        lda VIC_RASTER
        cmp l_line,y
        bcc .wait               ; its line hasn't come yet
        +mux_write
        lda mux_d010            ; $D010 / $D017 / $D01D bits of its hw sprite
        and nbit_of,y
        ora l_msb,y
        sta mux_d010
        sta SPR_XMSB
        lda mux_d017
        and nbit_of,y
        ora l_exp,y
        sta mux_d017
        sta SPR_YEXP
        sta SPR_XEXP
        lda mux_d01c
        and nbit_of,y
        ora l_mc,y
        sta mux_d01c
        sta SPR_MCOL
        iny
        jmp .loop

.wait   sty mux_next
        lda l_line,y
        sta VIC_RASTER
        lda #1
        sta VIC_IRQ             ; ack (also anything the write itself latched)
        lda VIC_RASTER          ; the raster got there meanwhile: write it now
        cmp l_line,y
        bcs .loop
        jmp irq_exit

.end    sty mux_next
        lda #<irq_handler       ; back to the frame IRQ
        sta $fffe
        lda #>irq_handler
        sta $ffff
        lda #IRQ_LINE
        sta VIC_RASTER
        lda #1
        sta VIC_IRQ
        lda VIC_CTRL1           ; TIMING: the last entries ran past line 251
        bmi +                   ;   (can't normally happen: entries end by
        lda VIC_RASTER          ;   line ~246): run the frame IRQ now, or it
        cmp #IRQ_LINE           ;   would be missed for a whole frame
        bcs +
        jmp irq_exit
+       jmp irq_frame
