; =============================================================================
; pbullets.asm - player bullets (sprite slots SLOT_PBULLET0..+PBULLET_COUNT-1)
; =============================================================================
;
; PBULLET_COUNT fixed slots, never shared. A slot is in flight exactly when
; its spr_on is set (no separate "active" flag to keep in sync). A bullet
; flies straight up and is removed when it leaves the top of the playfield.
;
; Fire is edge-triggered (input_new): one press = one shot. If every slot is
; in flight the press is ignored, so the fire rate is limited by how fast
; bullets leave the screen.
; =============================================================================

PB_SPEED    = 6                 ; pixels/frame upward
PB_H        = 6                 ; drawn rows 0-5 of the sprite

; Spawn so the bullet's bottom row sits just above the ship's nose. The nose
; is sprite row 1 (raster player_y + 1), so bullet top = player_y + 1 - PB_H.
PB_SPAWN_DY = PB_H - 1

!zone init_pbullets
init_pbullets
        lda #0
        ldx #PBULLET_COUNT - 1
-       sta spr_on + SLOT_PBULLET0,x    ; all slots idle
        dex
        bpl -
        rts

!zone pbullets_update
; -----------------------------------------------------------------------------
; pbullets_update: once per frame, after player_update.
;   1. move each live bullet up; expire it at the top of the playfield
;   2. on a fire press, launch from the nose into the first free slot
; A bullet launched this frame is first drawn at its spawn position next
; frame, then moves.
; Clobbers A, X, zp_tmp0.
; -----------------------------------------------------------------------------
pbullets_update
        ldx #SLOT_PBULLET0
.move   lda spr_on,x
        beq .next               ; slot idle
        lda spr_y,x
        sec
        sbc #PB_SPEED
        bcc .kill               ; wrapped past 0 (can't happen today; cheap guard)
        cmp #PLAY_Y_MIN
        bcc .kill               ; off the top
        sta spr_y,x
        jmp .next
.kill   lda #0
        sta spr_on,x
.next   inx
        cpx #SLOT_PBULLET0 + PBULLET_COUNT
        bne .move

        ; --- fire (only with a live ship) ---
        lda player_state
        cmp #PS_ALIVE
        bne .done
        lda input_new
        and #INP_FIRE
        beq .done
        lda player_y
        sec
        sbc #PB_SPAWN_DY
        ; KNOWN LIMIT: with the ship in its top 6 pixels of travel the spawn
        ; point would be above the playfield, so the shot is skipped.
        cmp #PLAY_Y_MIN
        bcc .done
        sta zp_tmp0             ; spawn Y

        ldx #SLOT_PBULLET0
.find   lda spr_on,x
        beq .launch
        inx
        cpx #SLOT_PBULLET0 + PBULLET_COUNT
        bne .find
        rts                     ; all in flight: press ignored

.launch lda zp_tmp0
        sta spr_y,x
        lda player_xh           ; bullet art is centred to match the ship
        sta spr_xh,x
        lda #PTR_PBULLET
        sta spr_ptr,x
        lda #1
        sta spr_on,x
.done   rts
