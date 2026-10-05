; =============================================================================
; ebullets.asm - enemy bullets (sprite slots SLOT_EBULLET0..+EBULLET_COUNT-1)
; =============================================================================
;
; FIRING is scripted: a +seg_fire marker in a path (data/waves.asm) makes the
; enemy fire once when it reaches that point. load_seg calls enemy_fire. If
; every bullet slot is busy, or the enemy isn't safely on screen, the shot is
; skipped. Nothing is random.
;
; AIMING: each shot is aimed at the player when it is fired, then flies in a
; straight line. The direction is snapped to one of 32 (11.25 degree steps)
; with a table lookup instead of a divide:
;   X' = |dx| in half-X units, Y' = |dy| / 2 (also 2-pixel units)
;   L = max(X', Y'), S = min(X', Y'), scaled together until 16 <= L < 32
;   atan_tab[L][S] = round(atan(S/L) / 11.25 deg) = 0..4 (angle off the
;                    major axis), built at assemble time with ACME's arctan()
;   k = angle from vertical in 11.25 degree steps: the table value if the
;       vertical axis is major, 8 minus it if horizontal is major (0..8)
; The sign of dx/dy picks the quadrant. Worst-case error is about 5.6 deg plus
; ~2 deg from scaling, so a shot fired from 150 px away lands within ~20 px.
;
; Position is 8.8 like the enemies: integer in spr_xh/spr_y, fraction here.
; =============================================================================

EB_SPEED      = 2.25            ; pixels per frame, any direction
EB_H          = 4               ; drawn rows 0-3
EB_SPAWN_DY   = ENEMY_H - 2     ; just under the enemy's nose
EB_FIRE_Y_MAX = 200             ; don't fire from lower than this (shot would
                                ;   leave the screen almost at once)
EB_SPREAD_K   = 2               ; spread shots: 22.5 degrees off vertical

eb_xfrac_s = eb_xfrac - SLOT_EBULLET0
eb_yfrac_s = eb_yfrac - SLOT_EBULLET0
eb_dxl_s   = eb_dxl   - SLOT_EBULLET0
eb_dxh_s   = eb_dxh   - SLOT_EBULLET0
eb_dyl_s   = eb_dyl   - SLOT_EBULLET0
eb_dyh_s   = eb_dyh   - SLOT_EBULLET0

!zone init_ebullets
init_ebullets
        ldx #EBULLET_COUNT - 1
-       lda #0
        sta spr_on + SLOT_EBULLET0,x    ; all slots idle
        lda #COL_EBULLET
        sta spr_col + SLOT_EBULLET0,x
        lda #PTR_EBULLET
        sta spr_ptr + SLOT_EBULLET0,x
        dex
        bpl -
        rts

!zone enemy_fire
; -----------------------------------------------------------------------------
; Firing. All shots start at a GUN position (aim_gx half-X, aim_gy raster
; line), which is checked to be sensibly on screen first.
;   enemy_fire     enemy in slot X fires an aimed shot from under its nose
;                  (+seg_fire)
;   enemy_fire_at  aimed shot from slot X's position + (aim_offx, aim_offy)
;                  (+boss_fire DX, DY)
;   enemy_spread   two shots from slot X + offsets, fanned 22.5 degrees left
;                  and right of straight down (+boss_spread DX, DY)
; A shot is skipped if no enemy-bullet slot is free.
; All preserve X, zp_ptr0 and zp_tmp2 (load_seg's state). Clobber A, Y, aim_*.
; TIMING: ~180 cycles for an aimed shot, ~150 for a spread.
; -----------------------------------------------------------------------------
enemy_fire
        lda #0
        sta aim_offx
        lda #EB_SPAWN_DY
        sta aim_offy
enemy_fire_at
        jsr gun_position
        bcs +
        rts                     ; gun off screen
+       jsr eb_free_slot        ; -> Y, or C=0 if none
        bcs +
        rts                     ; no free bullet slot
+       stx aim_slot            ; X is needed for table lookups below
        sty aim_bslot
        jsr eb_place

        ; --- dx = player - bullet (half-X). Ship and bullet art are both
        ; centred, so comparing left edges compares centres. Carry from the
        ; subtraction is the sign (C=1: player is to the right or level).
        lda player_xh
        sec
        sbc spr_xh,y
        bcs +
        eor #$ff                ; |dx| = -A (|dx| <= 172 fits in 8 bits)
        adc #1                  ; carry is clear here
        clc                     ; C=0 = negative
+       ror aim_sx              ; bit 7 = 1 if dx >= 0
        sta aim_x

        ; --- dy = player centre - bullet centre (pixels) ---
        ; ship centre = player_y + 7, bullet centre = bullet_y + 2
        lda player_y
        clc
        adc #7 - 2              ; player_y <= 237, so no overflow
        sec
        sbc spr_y,y
        bcs +
        eor #$ff
        adc #1
        clc
+       ror aim_sy              ; bit 7 = 1 if dy >= 0 (shoot downward)
        lsr                     ; |dy| / 2 -> same 2-pixel units as X
        sta aim_y

        ; --- L = larger, S = smaller; remember which axis is major ---
        lda aim_x
        cmp aim_y
        bcs .xmaj               ; |X| >= |Y|: horizontal-major
        ldx aim_y               ; vertical-major: L = Y, S = X
        stx aim_l
        sta aim_s
        lda #0
        beq .norm
.xmaj   sta aim_l               ; L = X
        lda aim_y
        sta aim_s               ; S = Y
        lda #1
.norm   sta aim_xmaj

        ; --- scale S and L together so 16 <= L < 32 (S <= L keeps S < 32) ---
        lda aim_l
        bne .down
        ldx #0                  ; on top of the player: shoot straight down
        beq .haveoct
.down   cmp #32
        bcc .up
        lsr aim_l
        lsr aim_s
        lda aim_l
        jmp .down
.up     cmp #16
        bcs .look
        asl aim_l
        asl aim_s
        lda aim_l
        jmp .up

        ; --- octant angle 0..4 from the table: rows L = 16..23 in atan_lo,
        ; rows L = 24..31 in atan_hi; index = (L & 7) * 32 + S
.look   and #%00000111
        asl
        asl
        asl
        asl
        asl
        ora aim_s
        tax
        lda aim_l
        and #%00001000
        bne +
        lda atan_lo,x
        jmp ++
+       lda atan_hi,x
++      tax
.haveoct
        ; --- k = angle from vertical: oct if vertical-major, 8-oct if not
        lda aim_xmaj
        beq +
        stx aim_t
        lda #8
        sec
        sbc aim_t
        tax
+
        ldy aim_bslot
        jsr eb_launch
        ldx aim_slot
        rts

!zone enemy_spread
enemy_spread
        jsr gun_position
        bcc .done
        stx aim_slot
        lda #$80                ; both shots go downward
        sta aim_sy
        lda #0                  ; first shot: to the left (sign bit clear)
        sta aim_sx
.shot   jsr eb_free_slot
        bcc .out
        sty aim_bslot
        jsr eb_place
        ldx #EB_SPREAD_K
        jsr eb_launch
        lda aim_sx
        bmi .out                ; second shot done
        lda #$80                ; second shot: to the right
        sta aim_sx
        jmp .shot
.out    ldx aim_slot
.done   rts

!zone gun_position
; -----------------------------------------------------------------------------
; gun_position: aim_gx/gy = slot X's position + aim_offx/aim_offy.
; Returns C=1 if the gun is on screen and high enough to fire from.
; -----------------------------------------------------------------------------
gun_position
        lda spr_xh,x
        clc
        adc aim_offx
        sta aim_gx
        lda spr_y,x
        clc
        adc aim_offy
        sta aim_gy
        bcs .no                 ; wrapped past 255: far off the bottom
        cmp #PLAY_Y_MIN
        bcc .no
        cmp #EB_FIRE_Y_MAX
        bcs .no
        lda aim_gx
        cmp #SCREEN_X_MIN
        bcc .no
        cmp #SCREEN_X_MAX - 12
        bcs .no
        sec
        rts
.no     clc
        rts

; eb_free_slot: first free enemy-bullet slot -> Y with C=1; C=0 if none.
eb_free_slot
        ldy #SLOT_EBULLET0
-       lda spr_on,y
        beq +
        iny
        cpy #SLOT_EBULLET0 + EBULLET_COUNT
        bne -
        clc
        rts
+       sec
        rts

; eb_place: put bullet slot Y at the gun position, fractions cleared.
eb_place
        lda aim_gx
        sta spr_xh,y
        lda aim_gy
        sta spr_y,y
        lda #0
        sta eb_xfrac_s,y
        sta eb_yfrac_s,y
        rts

!zone eb_launch
; -----------------------------------------------------------------------------
; eb_launch: give bullet slot Y the velocity for direction k = X (0..8,
; 11.25-degree steps from straight down), with signs from aim_sx / aim_sy
; (bit 7 set = positive), and switch it on. Clobbers A.
; -----------------------------------------------------------------------------
eb_launch
        lda eb_vx_lo,x
        sta eb_dxl_s,y
        lda eb_vx_hi,x
        sta eb_dxh_s,y
        bit aim_sx
        bmi +                   ; dx >= 0: keep positive
        lda #0                  ; negate 16-bit
        sec
        sbc eb_dxl_s,y
        sta eb_dxl_s,y
        lda #0
        sbc eb_dxh_s,y
        sta eb_dxh_s,y
+       lda eb_vy_lo,x
        sta eb_dyl_s,y
        lda eb_vy_hi,x
        sta eb_dyh_s,y
        bit aim_sy
        bmi +                   ; dy >= 0: downward, keep positive
        lda #0
        sec
        sbc eb_dyl_s,y
        sta eb_dyl_s,y
        lda #0
        sbc eb_dyh_s,y
        sta eb_dyh_s,y
+       lda #1
        sta spr_on,y
        rts

; Velocity for k = 0..8 (0 to 90 degrees from straight down, 11.25 steps).
; X is in half-X units (pixels / 2), Y in pixels. 8.8 fixed point.
DEG  = 3.14159265358979 / 180
STEP = 11.25
eb_vx_lo !for .k, 0, 8 { !byte <int(EB_SPEED * sin(float(.k) * STEP * DEG) / 2 * 256) }
eb_vx_hi !for .k, 0, 8 { !byte >int(EB_SPEED * sin(float(.k) * STEP * DEG) / 2 * 256) }
eb_vy_lo !for .k, 0, 8 { !byte <int(EB_SPEED * cos(float(.k) * STEP * DEG) * 256) }
eb_vy_hi !for .k, 0, 8 { !byte >int(EB_SPEED * cos(float(.k) * STEP * DEG) * 256) }

; Octant angle table: round(atan(S / L) / 11.25 deg), for L = 16..31 and
; S = 0..31. Entries with S > L never occur (S <= L) and are filled with 4.
!macro atan_rows .l0 {
        !for .l, .l0, .l0 + 7 {
                !for .s, 0, 31 {
                        !if .s > .l {
                                !byte 4
                        } else {
                                !byte int(arctan(float(.s) / float(.l)) / DEG / STEP + 0.5)
                        }
                }
        }
}
atan_lo +atan_rows 16           ; 256 bytes
atan_hi +atan_rows 24           ; 256 bytes

!zone ebullets_update
; -----------------------------------------------------------------------------
; ebullets_update: once per frame. Move live bullets; free a slot when its
; bullet leaves the playfield (never drawn over the HUD row).
; TIMING: ~60 cycles per live bullet.
; -----------------------------------------------------------------------------
ebullets_update
        ldx #SLOT_EBULLET0
.loop   lda spr_on,x
        beq .next
        clc
        lda eb_xfrac_s,x
        adc eb_dxl_s,x
        sta eb_xfrac_s,x
        lda spr_xh,x
        adc eb_dxh_s,x
        sta spr_xh,x
        clc
        lda eb_yfrac_s,x
        adc eb_dyl_s,x
        sta eb_yfrac_s,x
        lda spr_y,x
        adc eb_dyh_s,x
        sta spr_y,x
        cmp #PLAY_Y_END         ; off the bottom
        bcs .kill
        cmp #PLAY_Y_MIN         ; off the top
        bcc .kill
        lda spr_xh,x
        cmp #SCREEN_X_MAX       ; off the right, or wrapped off the left
        bcc .next
.kill   lda #0
        sta spr_on,x
.next   inx
        cpx #SLOT_EBULLET0 + EBULLET_COUNT
        bne .loop
        rts
