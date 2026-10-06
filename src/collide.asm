; =============================================================================
; collide.asm - collision by bounding boxes (software only)
; =============================================================================
;
; With the multiplexer, $D01E can't say which virtual sprites touched, so
; every check is a box test. Each slot has a box (box_ox / box_oy / box_w /
; box_h, set by init_collide) measured from its spr_xh / spr_y. The pairs:
;   player bullet  vs enemy (or boss part)
;   player         vs enemy, enemy bullet   (skipped while invulnerable)
;   player         vs medal: collects it    (also skipped while invulnerable)
; Enemy-enemy, bullet-bullet and anything vs an exploding enemy are ignored.
; The background never collides.
;
; The player's box is its fuselage and wing roots, smaller than the art, so
; a shot that only clips a wing tip misses. Enemy boxes are generous, so
; player bullets hit what they seem to hit.
;
; TIMING: runs in the logic phase, after everything has moved, so the boxes
; are where the next frame will show the sprites. Most pairs fail on Y at
; once (~30 cycles); worst case ~1500 cycles (3 bullets x 8 enemies, plus the
; player vs 14).
; =============================================================================

!zone init_collide
; -----------------------------------------------------------------------------
; init_collide: every slot's box from its kind's defaults. Clobbers A, X.
; -----------------------------------------------------------------------------
init_collide
        lda #PLAYER_BOX_OX
        sta box_ox + SLOT_PLAYER
        lda #PLAYER_BOX_OY
        sta box_oy + SLOT_PLAYER
        lda #PLAYER_BOX_W
        sta box_w + SLOT_PLAYER
        lda #PLAYER_BOX_H
        sta box_h + SLOT_PLAYER
        ldx #PBULLET_COUNT - 1
-       lda #PB_BOX_OX
        sta box_ox + SLOT_PBULLET0,x
        lda #0
        sta box_oy + SLOT_PBULLET0,x
        lda #PB_BOX_W
        sta box_w + SLOT_PBULLET0,x
        lda #PB_H
        sta box_h + SLOT_PBULLET0,x
        dex
        bpl -
        ldx #EBULLET_COUNT - 1
-       lda #EB_BOX_OX
        sta box_ox + SLOT_EBULLET0,x
        lda #0
        sta box_oy + SLOT_EBULLET0,x
        lda #EB_BOX_W
        sta box_w + SLOT_EBULLET0,x
        lda #EB_H
        sta box_h + SLOT_EBULLET0,x
        dex
        bpl -
        ; fall through: normal enemy boxes

; collide_enemy_boxes: the enemy slots get plane-sized boxes (again, after a
; boss). Clobbers A, X.
collide_enemy_boxes
        ldx #ENEMY_COUNT - 1
-       lda #ENEMY_BOX_OX
        sta box_ox + SLOT_ENEMY0,x
        lda #0
        sta box_oy + SLOT_ENEMY0,x
        lda #ENEMY_BOX_W
        sta box_w + SLOT_ENEMY0,x
        lda #ENEMY_H
        sta box_h + SLOT_ENEMY0,x
        dex
        bpl -
        rts

; Boxes in half-X (X) and pixels (Y), from the sprite's top-left.
PLAYER_BOX_OX = 3               ; art cols 3-8, rows 2-11: fuselage, engines
PLAYER_BOX_OY = 2               ;   and wing roots (24x17 art; see sprites)
PLAYER_BOX_W  = 6
PLAYER_BOX_H  = 10
PB_BOX_OX     = 4               ; the twin streaks, cols 4-7
PB_BOX_W      = 4
EB_BOX_OX     = 4               ; the round shot, cols 4-7
EB_BOX_W      = 4
ENEMY_BOX_OX  = 1               ; planes: cols 1-10, rows 0-14 (ENEMY_H)
ENEMY_BOX_W   = 10

; +y_apart LABEL: go to LABEL if the boxes of slots X and Y can't meet
; vertically; zp_tmp1 = the top of X's box. The same test as boxes_overlap.
!macro y_apart .far {
        lda spr_y,y
        clc
        adc box_oy,y            ; b = top of Y's box
        sec
        sbc zp_tmp1             ; b - a
        bcs .below
        eor #$ff                ; a - b (carry is clear)
        adc #1
        cmp box_h,y
        bcs .far
        bcc .near
.below  cmp box_h,x
        bcs .far
.near
}

; +x_apart LABEL: the same across, with zp_tmp0 = the left of X's box.
!macro x_apart .far {
        lda spr_xh,y
        clc
        adc box_ox,y            ; b = left of Y's box
        sec
        sbc zp_tmp0             ; b - a
        bcs .right
        eor #$ff                ; a - b (carry is clear)
        adc #1
        cmp box_w,y
        bcs .far
        bcc .near
.right  cmp box_w,x
        bcs .far
.near
}

!zone collisions
; -----------------------------------------------------------------------------
; collisions: once per frame, after all movement. Clobbers A, X, Y, zp_tmp0,
; zp_tmp1.
; TIMING: the inner loops test the boxes themselves, against the bullet's
; (or the player's) box top and left, worked out once in zp_tmp1 / zp_tmp0:
; ~35 cycles for a pair apart vertically, ~70 for one that isn't.
; -----------------------------------------------------------------------------
collisions
        ; --- player bullets vs enemies ---
        lda boss_state          ; a dying boss can't be hit any more
        cmp #BS_DYING
        bne +
        jmp .player
+       ldx #SLOT_PBULLET0
.pb     lda spr_on,x
        beq .pbnext
        lda spr_y,x
        clc
        adc box_oy,x
        sta zp_tmp1             ; the bullet's box top
        lda spr_xh,x
        clc
        adc box_ox,x
        sta zp_tmp0             ; ... and left
        ldy #SLOT_ENEMY0
.en     lda spr_on,y
        beq .ennext
        lda en_state_s,y        ; exploding or a medal: bullets pass through
        bne .ennext
        +y_apart .ennext
        +x_apart .ennext
        lda #0                  ; hit: bullet gone
        sta spr_on,x
        lda boss_state
        beq +
        jsr boss_hit            ; boss: lose HP (one bullet, one hit)
        jmp .pbnext
+       jsr enemy_explode       ; enemy in slot Y explodes
        jsr enemy_mark_drop     ; red leaders will drop a medal
        jsr score_add_enemy     ; bullet kills score (crashes don't)
        jmp .pbnext             ; one bullet destroys one enemy
.ennext iny
        cpy #SLOT_ENEMY0 + ENEMY_COUNT
        bne .en
.pbnext inx
        cpx #SLOT_PBULLET0 + PBULLET_COUNT
        bne .pb

        ; --- player vs enemies and enemy bullets ---
.player
        lda player_state
        cmp #PS_ALIVE
        bne .none
        lda invuln_timer        ; design rule: no player check while the
        beq +                   ;   invulnerability timer runs
.none   rts
+
        ldx #SLOT_PLAYER
        ldy #SLOT_ENEMY0        ; enemies, then enemy bullets (they follow)
.pltop  lda spr_y + SLOT_PLAYER
        clc
        adc box_oy + SLOT_PLAYER
        sta zp_tmp1             ; the player's box top
        lda spr_xh + SLOT_PLAYER
        clc
        adc box_ox + SLOT_PLAYER
        sta zp_tmp0             ; ... and left
.pl     lda spr_on,y
        beq .plnext
        cpy #SLOT_EBULLET0
        bcs +                   ; bullets have no explode state
        lda boss_state          ; a dying boss is harmless
        cmp #BS_DYING
        beq .plnext
        lda en_state_s,y
        bmi .medal              ; a medal: collect it
        bne .plnext             ; an exploding enemy is harmless
+       +y_apart .plnext
        +x_apart .plnext
!ifdef INVINCIBLE {
        jmp .plnext             ; test hook (acme -DINVINCIBLE): never hit,
}                               ;   but the tests run (the profiler sees them)
        cpy #SLOT_EBULLET0      ; hit by...
        bcs .shot
        lda boss_state          ;   the boss: only the player dies
        bne +
        jsr enemy_explode       ;   an enemy: it explodes too
+       jmp player_die
.shot   lda #0                  ;   a bullet: it is used up
        sta spr_on,y
        jmp player_die
.plnext iny
        cpy #SLOT_EBULLET0 + EBULLET_COUNT
        bne .pl
.done   rts

.medal  jsr boxes_overlap       ; touching a medal collects it
        bcc .plnext
        jsr medal_collect
        ldx #SLOT_PLAYER        ; (it may clobber them)
        iny
        cpy #SLOT_EBULLET0 + EBULLET_COUNT
        beq +
        jmp .pltop              ; (and zp_tmp0 / zp_tmp1)
+       rts


!if SLOT_EBULLET0 != SLOT_ENEMY0 + ENEMY_COUNT {
        !error "collisions: enemy bullets must follow the enemies"
}

!zone boxes_overlap
; -----------------------------------------------------------------------------
; boxes_overlap: do the boxes of slots X and Y overlap? C=1 if they do.
; Preserves X and Y. Uses differences, not end points, so nothing wraps:
;   a = X's box start, b = Y's box start (on one axis)
;   overlap iff  0 <= b - a < size[X]   or   0 < a - b < size[Y]
; Y first: most pairs are far apart vertically.
; Clobbers A, zp_tmp0.
; -----------------------------------------------------------------------------
boxes_overlap
        lda spr_y,x
        clc
        adc box_oy,x
        sta zp_tmp0             ; a = top of X's box
        lda spr_y,y
        clc
        adc box_oy,y            ; b = top of Y's box
        sec
        sbc zp_tmp0             ; b - a
        bcs +
        eor #$ff                ; a - b (carry is clear)
        adc #1
        cmp box_h,y
        bcs .no
        bcc .xaxis
+       cmp box_h,x
        bcs .no
.xaxis  lda spr_xh,x
        clc
        adc box_ox,x
        sta zp_tmp0             ; a = left of X's box
        lda spr_xh,y
        clc
        adc box_ox,y            ; b = left of Y's box
        sec
        sbc zp_tmp0
        bcs +
        eor #$ff
        adc #1
        cmp box_w,y
        bcs .no
        sec
        rts
+       cmp box_w,x
        bcs .no
        sec
        rts
.no     clc
        rts
