; =============================================================================
; boss.asm - end-of-level boss: up to 6 expanded sprites in the enemy slots
; =============================================================================
;
; LOOK   A boss is a list of parts (data/bosses.asm): each part is an X+Y
;        expanded sprite (48x42 px) at an offset from the first part, the
;        "body". Parts live in the first boss_parts enemy slots. The body
;        flies the script; the others follow it every frame (boss_follow).
;        Today's bosses are 3 parts side by side, 144x42 px.
; MOVES  A boss script is an enemy path (data/bosses.asm): +path_start, +seg,
;        +boss_fire / +boss_spread (guns), +seg_loop. It runs on slot 3 with
;        the normal path engine (enemy_step), but without the off-screen
;        removal; X is clamped so the boss always stays on screen.
; HITS   Each player bullet hit: HP-1, white flash, 10 points. At HP <=
;        boss_t_phase2 the boss switches to its second (angrier) script.
;        Touching the boss destroys the player, not the boss.
; DEATH  HP 0: BOSS_DIE_FRAMES of flickering explosions, BOSS_SCORE points,
;        then boss_state = BS_DONE and level.asm moves on to LEVEL CLEAR.
;        The music stops and the SFX_BOSS_BOOM explosion plays (sfx.asm).
;
; boss_state: BS_IDLE (none yet), BS_FIGHT, BS_DYING, BS_DONE.
; While boss_state != BS_IDLE, enemies_update leaves the enemy slots alone.
; =============================================================================

BS_IDLE  = 0
BS_FIGHT = 1
BS_DYING = 2
BS_DONE  = 3

BOSS_PART_W     = 24            ; half-X per expanded sprite (48 px)
BOSS_H          = 42            ; expanded sprite height (21 rows x 2)
BOSS_X_MIN      = SCREEN_X_MIN  ; (the right limit, boss_xmax, is per boss)
BOSS_FLASH      = 3             ; frames of white after each hit
BOSS_DIE_FRAMES = 100           ; 2 s of explosions
BAR_BLOCKS      = 6             ; HP bar length in the HUD

boss_slot = SLOT_ENEMY0         ; the body (runs the script)

!zone boss_start
; -----------------------------------------------------------------------------
; boss_start: bring in boss number A (0-3). The enemy slots must be free.
; -----------------------------------------------------------------------------
boss_start
        sta boss_idx
        tay
        lda boss_t_hp,y
        sta boss_hp
        lda boss_t_col,y
        sta boss_col
        lda #0
        sta boss_flash
        sta boss_phase
        ldx #boss_slot
        lda boss_t_x,y
        sta spr_xh,x
        lda boss_t_script_lo,y  ; script: start Y, then segments
        sta zp_ptr0
        lda boss_t_script_hi,y
        sta zp_ptr0+1
        ldy #0
        lda (zp_ptr0),y
        sta spr_y,x
        clc
        lda zp_ptr0
        adc #1
        jsr boss_set_script     ; A/zp_ptr0+1 = segment pointer
        ; parts: shapes and offsets, expanded, on
        ldy boss_idx
        lda #SCREEN_X_MAX       ; keep its whole width on screen
        sec
        sbc boss_t_w,y
        sta boss_xmax
        lda boss_t_parts_lo,y
        sta zp_ptr1
        lda boss_t_parts_hi,y
        sta zp_ptr1+1
        ldy #0
        lda (zp_ptr1),y         ; part count
        sta boss_parts
        ldx #0
-       iny
        lda (zp_ptr1),y
        sta spr_ptr + SLOT_ENEMY0,x
        iny
        lda (zp_ptr1),y
        sta boss_pdx,x
        iny
        lda (zp_ptr1),y
        sta boss_pdy,x
        lda #$ff
        sta spr_on + SLOT_ENEMY0,x
        sta spr_exp + SLOT_ENEMY0,x
        lda #0                  ; every part is a live target: a stale
        sta en_state,x          ;   en_state (e.g. EN_MEDAL from a medal that
                                ;   fell off screen) would make collisions
                                ;   skip that part, or "collect" it as a medal
        inx
        cpx boss_parts
        bne -
        jsr boss_colour
        jsr boss_follow
        jsr collide_boss_boxes
        lda #BS_FIGHT
        sta boss_state
        jsr hud_draw_boss_hp
        lda #SONG_BOSS
        jmp music_start

; boss_set_script: point slot 3's path at the segment address in
; A (lo) / zp_ptr0+1 + carry (hi), clear its velocity and read the first
; segment. Clobbers A, Y, zp_ptr0.
boss_set_script
        ldx #boss_slot
        sta en_segl_s,x
        lda zp_ptr0+1
        adc #0
        sta en_segh_s,x
        lda #0
        sta en_xfrac_s,x
        sta en_yfrac_s,x
        sta en_dxl_s,x
        sta en_dxh_s,x
        sta en_dyl_s,x
        sta en_dyh_s,x
        sta en_state_s,x
        jmp load_seg

!zone boss_update
; -----------------------------------------------------------------------------
; boss_update: once per frame in play (logic phase).
; -----------------------------------------------------------------------------
boss_update
        lda boss_state
        cmp #BS_FIGHT
        beq .fight
        cmp #BS_DYING
        beq .dying
        rts

.fight  ldx #boss_slot
        jsr enemy_step          ; script: move, maybe fire
        lda spr_xh,x            ; keep the whole boss on screen
        cmp #BOSS_X_MIN
        bcs +
        lda #BOSS_X_MIN
+       cmp boss_xmax
        bcc +
        beq +
        lda boss_xmax
+       sta spr_xh,x
        jsr boss_follow
        lda boss_flash          ; hit flash
        beq +
        dec boss_flash
        jsr boss_colour
+       rts

.dying  dec boss_timer
        beq .gone
        lda boss_timer          ; flicker: explosion shapes in turn on
        lsr                     ;   neighbouring parts, swapped every 4 frames
        lsr
        and #1
        sta zp_tmp0
        ldx boss_parts
        dex
-       txa
        eor zp_tmp0
        and #1
        tay
        lda .expl,y
        sta spr_ptr + SLOT_ENEMY0,x
        dex
        bpl -
        rts
.expl   !byte PTR_EXPL_A, PTR_EXPL_B
.gone   ldx boss_parts          ; boss gone: slots free and normal size again
        dex
        lda #0
-       sta spr_on + SLOT_ENEMY0,x
        sta spr_exp + SLOT_ENEMY0,x
        dex
        bpl -
        jsr collide_enemy_boxes
        lda #BS_DONE
        sta boss_state
        rts

; boss_follow: the other parts at their offsets from the body.
; Clobbers A, X.
boss_follow
        ldx boss_parts
        dex
        beq +
-       lda spr_xh + boss_slot
        clc
        adc boss_pdx,x
        sta spr_xh + boss_slot,x
        lda spr_y + boss_slot
        clc
        adc boss_pdy,x
        sta spr_y + boss_slot,x
        dex
        bne -
+       rts

; boss_colour: white while flashing, else the boss colour. Clobbers A, X.
boss_colour
        lda boss_flash
        beq +
        lda #COL_WHITE
        bne ++
+       lda boss_col
++      ldx boss_parts
        dex
-       sta spr_col + SLOT_ENEMY0,x
        dex
        bpl -
        rts

!zone boss_hit
; -----------------------------------------------------------------------------
; boss_hit: a player bullet hit the boss. Called from collisions.
; Preserves X and Y.
; -----------------------------------------------------------------------------
boss_hit
        txa
        pha
        tya
        pha
        lda #BOSS_FLASH
        sta boss_flash
        jsr boss_colour
        lda #SFX_BOSS_HIT       ; (the explosion replaces it on the last hit)
        jsr sfx_start
        lda #$10                ; 10 points per hit (BCD)
        ldy #$00
        jsr score_add_bcd
        dec boss_hp
        beq .die
        ; phase 2 when HP falls to the threshold (once)
        lda boss_phase
        bne .bar
        ldy boss_idx
        lda boss_hp
        cmp boss_t_phase2,y
        bcs .bar
        lda #1
        sta boss_phase
        lda boss_t_script2_lo,y
        sta zp_ptr0
        lda boss_t_script2_hi,y
        sta zp_ptr0+1
        lda zp_ptr0
        clc
        jsr boss_set_script     ; (phase 2 scripts have no start Y)
.bar    jsr hud_draw_boss_hp
        jmp .out

.die    lda #BS_DYING
        sta boss_state
        lda #BOSS_DIE_FRAMES
        sta boss_timer
        lda #COL_EXPLOSION
        sta boss_col
        lda #0
        sta boss_flash
        jsr boss_colour
        lda #$00                ; BOSS_SCORE = 5000 (BCD "50" in the middle)
        ldy #$50
        jsr score_add_bcd
        jsr hud_draw_boss_hp    ; empty bar
        jsr music_stop          ; frees all three voices...
        lda #SFX_BOSS_BOOM      ; ...for the explosion
        jsr sfx_start
.out    pla
        tay
        pla
        tax
        rts
