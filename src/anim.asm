; =============================================================================
; anim.asm - animated level chars (water, surf, lights) and parallax chars
; =============================================================================
;
; A level may animate up to ANIM_MAX of its chars (data/levels/levelN_anim.png,
; tools/png2level.py). Each animation rewrites one char's 8 bitmap bytes in
; the charset every `delay` frames, so every copy of that char on screen
; changes at once:
;   frames  show the next of its frames (they cycle)
;   scroll  rotate the char's rows up one pixel: its texture moves against
;           the map. The map scrolls down a pixel a frame, so delay 1 holds
;           the texture still on screen (very far away), delay 2 moves it at
;           half speed: parallax
;   scroll_down  rotate them down one pixel: the texture moves faster than
;           the map (delay 2: 1.5 pixels a frame), so things drawn on the map
;           seem to move forward through it (level 4's ships under way)
;
; TIMING: ~150 cycles per char rewritten. anim_update rewrites at most
; ANIM_PER_FRAME chars a frame (any others that are due wait a frame), in
; the border work, so a char never changes halfway down the screen.
; =============================================================================

ANIM_PER_FRAME = 2              ; (ANIM_MAX: src/defs.asm)

!zone anim_init
; -----------------------------------------------------------------------------
; anim_init: read the current level's animation list (lvl_t_anims). Call
; after level_unpack (frame 0 of each is the char as unpacked).
; Timers start staggered, so the animations don't all fire together.
; Clobbers A, X, Y, zp_ptr0, zp_tmp0, zp_tmp1.
; -----------------------------------------------------------------------------
anim_init
        ldx level
        lda lvl_t_anims_lo,x
        sta zp_ptr0
        lda lvl_t_anims_hi,x
        sta zp_ptr0+1
        ldy #0
        lda (zp_ptr0),y         ; count
        sta anim_count
        inc zp_ptr0             ; zp_ptr0 = the first animation
        bne +
        inc zp_ptr0+1
+       ldx #0
.next   cpx anim_count          ; (the table is longer than 256 bytes: the
        beq .done               ;   pointer moves on, Y only reads a header)
        ldy #0
        lda (zp_ptr0),y         ; char code -> its address in the charset
        pha
        asl
        asl
        asl
        sta anim_clo,x
        pla
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc #>CHARSET
        sta anim_chi,x
        iny
        lda (zp_ptr0),y
        sta anim_mode,x
        iny
        lda (zp_ptr0),y
        sta anim_delay,x
        iny
        lda (zp_ptr0),y
        sta anim_n,x
        lda anim_mode,x         ; scrolling chars all start together: a
        bne +                   ;   texture made of several of them must
        txa                     ;   move as one (ANIM_PER_FRAME of them)
        clc                     ; frames: staggered, animation i first fires
        adc #1                  ;   at frame i + 1
        bne ++
+       lda #1
++      sta anim_t,x
        lda #0
        sta anim_f,x
        lda zp_ptr0             ; its frames start after the 4-byte header
        clc
        adc #4
        sta anim_bl,x
        sta anim_pl,x
        lda zp_ptr0+1
        adc #0
        sta anim_bh,x
        sta anim_ph,x
        lda anim_n,x            ; the next animation: after its n * 8 bytes
        asl
        asl
        asl
        sta zp_tmp0             ; (n * 8) & $FF
        lda anim_n,x
        lsr
        lsr
        lsr
        lsr
        lsr
        sta zp_tmp1             ; (n * 8) >> 8
        lda anim_bl,x
        clc
        adc zp_tmp0
        sta zp_ptr0
        lda anim_bh,x
        adc zp_tmp1
        sta zp_ptr0+1
        inx
        jmp .next
.done   rts

!zone anim_update
; -----------------------------------------------------------------------------
; anim_update: once per play frame, in the border work. Clobbers A, X, Y,
; zp_ptr0, zp_ptr1, zp_tmp0.
; -----------------------------------------------------------------------------
anim_update
        lda #ANIM_PER_FRAME
        sta zp_tmp0             ; rewrites left this frame
        ldx anim_count
        beq .out
        dex
.loop   dec anim_t,x
        bne .skip
        lda zp_tmp0             ; due: but no rewrites left? wait a frame
        bne +
        inc anim_t,x
        bne .skip               ; (always)
+       dec zp_tmp0
        lda anim_delay,x
        sta anim_t,x
        lda anim_clo,x          ; zp_ptr1 = the char's 8 bytes
        sta zp_ptr1
        lda anim_chi,x
        sta zp_ptr1+1
        lda anim_mode,x
        beq .frame
        jsr anim_rotate         ; scroll / scroll_down
        jmp .skip
.frame
        ; --- next frame: copy its 8 bytes, advance (or wrap) ---
        inc anim_f,x
        lda anim_f,x
        cmp anim_n,x
        bcc +
        lda #0
        sta anim_f,x
        lda anim_bl,x           ; back to frame 0
        sta anim_pl,x
        lda anim_bh,x
        sta anim_ph,x
        jmp ++
+       lda anim_pl,x           ; on to the next frame
        clc
        adc #8
        sta anim_pl,x
        bcc ++
        inc anim_ph,x
++      lda anim_pl,x
        sta zp_ptr0
        lda anim_ph,x
        sta zp_ptr0+1
        ldy #7
-       lda (zp_ptr0),y
        sta (zp_ptr1),y
        dey
        bpl -
.skip   dex
        bpl .loop
.out    rts

; anim_rotate: rotate the char at zp_ptr1 one pixel row; A = its mode, 1
; (scroll: up) or 2 (scroll_down: down). Clobbers A, Y.
anim_rotate
        cmp #2
        beq .down
        ldy #0                  ; up: row 0 goes to the bottom
        lda (zp_ptr1),y
        pha
-       iny
        lda (zp_ptr1),y
        dey
        sta (zp_ptr1),y
        iny
        cpy #7
        bne -
        pla
        sta (zp_ptr1),y
        rts
.down   ldy #7                  ; down: row 7 goes to the top
        lda (zp_ptr1),y
        pha
-       dey
        lda (zp_ptr1),y
        iny
        sta (zp_ptr1),y
        dey
        bne -
        pla
        sta (zp_ptr1),y         ; (Y = 0)
        rts
