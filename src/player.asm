; =============================================================================
; player.asm - player ship (sprite slot 0): movement, lives, death, respawn
; =============================================================================
;
; Position lives directly in the sprite shadow registers for slot 0:
;   player_xh = spr_xh+SLOT_PLAYER (half-X), player_y = spr_y+SLOT_PLAYER
;
; STATES (player_state)
;   PS_ALIVE    flying. If invuln_timer > 0 the ship blinks and collisions
;               with it are skipped (collide.asm checks invuln_timer).
;   PS_DEAD     exploding, then hidden; when player_timer runs out the ship
;               respawns (lives left) or the game is over.
;   PS_GAMEOVER the last life is gone; the ship stays hidden.
; Lives: 3 ships, one hit kills, no bonus lives. The HUD shows the ships left,
; including the one in play.
; =============================================================================

player_xh = spr_xh + SLOT_PLAYER
player_y  = spr_y  + SLOT_PLAYER

PLAYER_W      = 12              ; width in half-X units (24 screen pixels)
PLAYER_H      = 14              ; drawn rows 0-13 of the sprite
PLAYER_SPEED_X = 1              ; half-X units/frame = 2 pixels/frame
PLAYER_SPEED_Y = 2              ; pixels/frame

; Clamp bounds: keep the whole ship inside the playfield window.
PLAYER_X_MIN  = SCREEN_X_MIN
PLAYER_X_MAX  = SCREEN_X_MAX - PLAYER_W
PLAYER_Y_MIN  = PLAY_Y_MIN - 1  ; sprite row 0 is blank, so the nose sits on row 1
PLAYER_Y_MAX  = PLAY_Y_END - PLAYER_H

PLAYER_START_X = (SCREEN_X_MIN + SCREEN_X_MAX - PLAYER_W) / 2
PLAYER_START_Y = 210

START_LIVES    = 3
INVULN_FRAMES  = 100            ; 2 seconds at 50 Hz after a respawn
BLINK_MASK     = %00000100      ; ship shown while (invuln_timer & mask) = 0:
                                ;   4 frames on, 4 frames off
DEATH_FRAMES   = 75             ; 1.5 s from the hit to the respawn
DEATH_ANIM     = EXPL_SHAPES * 4 ; the explosion (expanded: 48 px wide) shows
                                ;   for the first 24 frames, 4 per shape
SHAKE_DEATH    = 20             ; frames of screen shake when the ship goes

PS_ALIVE    = 0
PS_DEAD     = 1
PS_GAMEOVER = 2

; The clamp code below relies on these never wrapping past 0 or 255.
!if PLAYER_X_MIN < PLAYER_SPEED_X { !error "X clamp would wrap" }
!if PLAYER_Y_MAX + PLAYER_SPEED_Y > 255 { !error "Y clamp would wrap" }

!zone player_place
; -----------------------------------------------------------------------------
; player_place: put a fresh ship at the start position, alive and visible.
; Used at each level start and on respawn. (Lives are set by new_game.)
; -----------------------------------------------------------------------------
player_place
        lda #PS_ALIVE
        sta player_state
        lda #PLAYER_START_X
        sta player_xh
        lda #PLAYER_START_Y
        sta player_y
        lda #PTR_SHIP
        sta spr_ptr + SLOT_PLAYER
        lda #COL_PLAYER
        sta spr_col + SLOT_PLAYER
        lda #0
        sta spr_exp + SLOT_PLAYER       ; (the explosion was expanded)
        lda #1
        sta spr_on + SLOT_PLAYER
        rts

!zone player_die
; -----------------------------------------------------------------------------
; player_die: called by collide.asm when the ship is hit. Lose a life, start
; the explosion. The respawn or game over comes when player_timer runs out.
; -----------------------------------------------------------------------------
player_die
        lda #PS_DEAD
        sta player_state
        lda #DEATH_FRAMES
        sta player_timer
        lda #0
        sta invuln_timer
        dec lives
        jsr hud_draw_lives
        lda #SFX_PLAYER_DIE
        jsr sfx_start
        lda expl_ptr            ; the explosion sequence, X+Y expanded and
        sta spr_ptr + SLOT_PLAYER ; centred on the ship (art 12x12 at 2x =
        lda expl_col            ;   24 half-X x 24 px, round the ship's
        sta spr_col + SLOT_PLAYER ; centre at +6, +7)
        lda #$ff
        sta spr_exp + SLOT_PLAYER
        lda player_xh
        sec
        sbc #6
        sta player_xh
        lda player_y
        sec
        sbc #5
        sta player_y
        lda #SHAKE_DEATH
        sta shake_timer
        lda #1                  ; make sure the explosion is visible even if
        sta spr_on + SLOT_PLAYER ;  the hit came mid-blink
        rts

!zone player_update
; -----------------------------------------------------------------------------
; player_update: once per frame.
;   PS_ALIVE: move from input_bits, clamp to the playfield, run the
;             invulnerability blink.
;   PS_DEAD : run the explosion, then respawn or end the game.
; Opposite directions pressed together cancel out (up then down).
; Diagonals move at full speed on both axes (classic arcade feel).
; -----------------------------------------------------------------------------
player_update
        lda player_state
        beq .alive
        cmp #PS_DEAD
        beq .dead
        rts                     ; PS_GAMEOVER: nothing to do

.dead   dec player_timer
        beq .respawn
        lda player_timer
        cmp #DEATH_FRAMES - DEATH_ANIM
        bcc .hide               ; explosion over: hidden until respawn
        lda #DEATH_FRAMES       ; frames since the hit / 4 = the shape
        sec
        sbc player_timer
        lsr
        lsr
        cmp #EXPL_SHAPES
        bcc +
        lda #EXPL_SHAPES - 1
+       tay
        lda expl_ptr,y
        sta spr_ptr + SLOT_PLAYER
        lda expl_col,y
        sta spr_col + SLOT_PLAYER
        rts
.hide   lda #0
        sta spr_on + SLOT_PLAYER
        sta spr_exp + SLOT_PLAYER
        rts
.respawn
        lda lives
        beq .gameover
        jsr player_place
        lda #INVULN_FRAMES
        sta invuln_timer
        rts
.gameover
        lda #PS_GAMEOVER        ; main loop switches to the GAME OVER screen
        sta player_state
        rts

.alive  jsr .blink
        lda input_bits
        and #INP_UP
        beq .no_up
        lda player_y
        sec
        sbc #PLAYER_SPEED_Y
        cmp #PLAYER_Y_MIN
        bcs +
        lda #PLAYER_Y_MIN
+       sta player_y
.no_up
        lda input_bits
        and #INP_DOWN
        beq .no_down
        lda player_y
        clc
        adc #PLAYER_SPEED_Y
        cmp #PLAYER_Y_MAX + 1
        bcc +
        lda #PLAYER_Y_MAX
+       sta player_y
.no_down
        lda input_bits
        and #INP_LEFT
        beq .no_left
        lda player_xh
        sec
        sbc #PLAYER_SPEED_X
        cmp #PLAYER_X_MIN
        bcs +
        lda #PLAYER_X_MIN
+       sta player_xh
.no_left
        lda input_bits
        and #INP_RIGHT
        beq .no_right
        lda player_xh
        clc
        adc #PLAYER_SPEED_X
        cmp #PLAYER_X_MAX + 1
        bcc +
        lda #PLAYER_X_MAX
+       sta player_xh
.no_right
        rts

; Invulnerability: count down, and show the ship only on "on" phases.
.blink  lda invuln_timer
        beq .done
        dec invuln_timer
        beq .show               ; protection over: make sure it's visible
        lda invuln_timer
        and #BLINK_MASK
        beq .show
        lda #0
        sta spr_on + SLOT_PLAYER
        rts
.show   lda #1
        sta spr_on + SLOT_PLAYER
.done   rts
