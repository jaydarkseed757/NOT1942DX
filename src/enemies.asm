; =============================================================================
; enemies.asm - enemies (sprite slots SLOT_ENEMY0..+2): spawning and paths
; =============================================================================
;
; SPAWNING
;   Each level record can carry up to 3 spawn entries (type, x, path). When
;   the scroller fetches a record it calls enemies_spawn, so spawns are locked
;   to scroll position. Each spawn takes the first free enemy slot. If all
;   ENEMY_COUNT are busy the spawn is DROPPED and spawn_drops is incremented:
;   the level data must never schedule more live enemies than that (DEBUG
;   builds show the drop count as a hex digit at the right end of the HUD).
;
; MOVEMENT
;   A path is a start Y followed by segments (data/waves.asm). Each segment
;   sets a velocity (signed 8.8 fixed point, X in half-X units) for N frames.
;   Position = integer part in the sprite shadow (spr_xh / spr_y) plus a
;   fraction byte here (en_xfrac / en_yfrac), so it is a 16-bit 8.8 value.
;   An enemy is removed (slot freed) once fully off screen.
;
; MEDALS
;   A shot red leader (etype_drop = 1) explodes, then turns into a gold medal
;   in the same slot. The medal drifts down at scroll speed until it is
;   collected (collide.asm) or leaves the bottom of the screen. Medals give
;   way: if a spawn finds no free slot it takes a medal's slot, so medals
;   never change the scripted waves (tools/check_waves.py stays valid).
;
; en_state per slot:
;   0              flying its path
;   1-EXPL_FRAMES  exploding (frames left), + EN_DROP if it drops a medal
;   EN_MEDAL       a bonus medal
;
; Per-enemy arrays (BSS) hold ENEMY_COUNT bytes each. The *_s aliases are
; offset by -SLOT_ENEMY0 so they can be indexed directly by the sprite slot.
; =============================================================================

ENEMY_H          = 15           ; drawn rows 0-14 of the fighter, leader, raiders
                                ;   and gunship
                                ;   (the other planes: 0-11)
EXPL_SHAPES      = 6            ; the explosion sequence (data/sprites.asm)
EXPL_STEP        = 3            ; enemy explosion: frames per shape
EXPL_FRAMES      = EXPL_SHAPES * EXPL_STEP
ENEMY_Y_KILL_TOP = 20           ; above this = flew off the top (spawns at 30)
ENEMY_X_KILL     = SCREEN_X_MAX ; half-X >= 172: off the right edge, or
                                ;   wrapped below 0 off the left edge

en_xfrac_s = en_xfrac - SLOT_ENEMY0
en_yfrac_s = en_yfrac - SLOT_ENEMY0
en_dxl_s   = en_dxl   - SLOT_ENEMY0
en_dxh_s   = en_dxh   - SLOT_ENEMY0
en_dyl_s   = en_dyl   - SLOT_ENEMY0
en_dyh_s   = en_dyh   - SLOT_ENEMY0
en_timer_s = en_timer - SLOT_ENEMY0
en_segl_s  = en_segl  - SLOT_ENEMY0
en_segh_s  = en_segh  - SLOT_ENEMY0
en_type_s  = en_type  - SLOT_ENEMY0
en_state_s = en_state - SLOT_ENEMY0     ; see "en_state per slot" above

EN_DROP  = $40                  ; exploding and will drop a medal
EN_MEDAL = $80                  ; is a medal
EN_COUNT = $3f                  ; explosion frames left

!zone init_enemies
init_enemies
        lda #0
        ldx #ENEMY_COUNT - 1
-       sta spr_on + SLOT_ENEMY0,x  ; all enemy slots free...
        sta spr_exp + SLOT_ENEMY0,x ;   normal size...
        sta en_state,x          ;   ...and clean (a freed slot has en_state 0)
        dex
        bpl -
        sta rec_spawns
        sta spawn_drops
        rts

!zone enemies_spawn
; -----------------------------------------------------------------------------
; enemies_spawn: spawn the entries of the record fetch_record just read
; (rec_ptr / rec_spawns). Called by scroll_update; not during the prefill.
; Clobbers A, X, Y, zp_ptr0, zp_ptr1, zp_tmp1.
; -----------------------------------------------------------------------------
enemies_spawn
        lda rec_spawns
        bne +
        rts                     ; nothing to spawn on this row
+       sta zp_tmp1             ; entries left
        clc
        lda rec_ptr             ; entries start after the wave's header
        adc #WAVE_HEAD
        sta zp_ptr1
        lda rec_ptr+1
        adc #0
        sta zp_ptr1+1

.entry  ldx #SLOT_ENEMY0        ; find a free enemy slot
.find   lda spr_on,x
        beq .free
        inx
        cpx #SLOT_ENEMY0 + ENEMY_COUNT
        bne .find
        ldx #SLOT_ENEMY0        ; none free: a medal gives way
.medal  lda en_state_s,x
        bmi .free               ; (the spawn simply overwrites it)
        inx
        cpx #SLOT_ENEMY0 + ENEMY_COUNT
        bne .medal
        inc spawn_drops         ; all busy: level data asked for too many
        jmp .advance

.free   ldy #0                  ; type -> shape and colour
        lda (zp_ptr1),y
        sta en_type_s,x
        tay
        lda etype_ptr,y
        sta spr_ptr,x
        lda etype_col,y
        sta spr_col,x
        ldy #1                  ; x (half-X)
        lda (zp_ptr1),y
        sta spr_xh,x
        ldy #2                  ; path -> start Y, first segment
        lda (zp_ptr1),y
        tay
        lda path_lo,y
        sta zp_ptr0
        lda path_hi,y
        sta zp_ptr0+1
        ldy #0
        lda (zp_ptr0),y
        sta spr_y,x
        clc
        lda zp_ptr0
        adc #1                  ; segments follow the 1-byte start Y
        sta en_segl_s,x
        lda zp_ptr0+1
        adc #0
        sta en_segh_s,x
        lda #0
        sta en_state_s,x        ; flying
        sta en_xfrac_s,x
        sta en_yfrac_s,x
        sta en_dxl_s,x
        sta en_dxh_s,x
        sta en_dyl_s,x
        sta en_dyh_s,x
        jsr load_seg            ; first segment's velocity and timer
        lda #1
        sta spr_on,x

.advance
        clc
        lda zp_ptr1
        adc #SPAWN_LEN
        sta zp_ptr1
        bcc +
        inc zp_ptr1+1
+       dec zp_tmp1
        beq +
        jmp .entry              ; (too far for a branch)
+       lda #0
        sta rec_spawns          ; consumed
.done   rts

!zone load_seg
; -----------------------------------------------------------------------------
; load_seg: read the next path segment for enemy slot X.
;   normal   : set velocity + timer, advance the segment pointer
;   SEG_END  : timer = 0 = keep the current velocity until off screen
;   SEG_LOOP : continue reading at the loop target
;   SEG_FIRE : fire an aimed shot (enemy_fire), continue with the next byte
;   SEG_FIREAT / SEG_SPREAD dx, dy : aimed shot / spread from a gun offset
; At most 4 control bytes (loop/fire) are followed per call; after that the
; enemy just holds its velocity. That stops a bad loop (e.g. a loop whose
; target is itself, or fire+loop with no +seg) from hanging the game.
; Preserves X. Clobbers A, Y, zp_ptr0, zp_tmp2, aim_*.
; -----------------------------------------------------------------------------
load_seg
        lda en_segl_s,x
        sta zp_ptr0
        lda en_segh_s,x
        sta zp_ptr0+1
        lda #4
        sta zp_tmp2             ; control-byte budget
.read   ldy #0
        lda (zp_ptr0),y
        cmp #SEG_LOOP
        bne .notloop
        iny
        lda (zp_ptr0),y         ; loop target lo
        pha
        iny
        lda (zp_ptr0),y         ; loop target hi
        sta zp_ptr0+1
        pla
        sta zp_ptr0
        jmp .control
.notloop
        cmp #SEG_FIRE
        bne .notfire1
        jsr enemy_fire          ; preserves X, zp_ptr0, zp_tmp2
        lda #1                  ; skip the 1-byte marker
        bne .skip
.notfire1
        cmp #SEG_FIREAT
        beq .gun
        cmp #SEG_SPREAD
        bne .notfire
.gun    pha                     ; which gun command
        iny
        lda (zp_ptr0),y
        sta aim_offx
        iny
        lda (zp_ptr0),y
        sta aim_offy
        pla
        cmp #SEG_FIREAT
        bne +
        jsr enemy_fire_at
        jmp ++
+       jsr enemy_spread
++      lda #3                  ; skip command + 2 offset bytes
.skip   clc
        adc zp_ptr0
        sta zp_ptr0
        bcc .control
        inc zp_ptr0+1
.control
        dec zp_tmp2
        bne .read
        beq .end                ; budget used up: hold
.notfire
        cmp #SEG_END
        beq .end
        sta en_timer_s,x        ; frames
        iny
        lda (zp_ptr0),y
        sta en_dxl_s,x
        iny
        lda (zp_ptr0),y
        sta en_dxh_s,x
        iny
        lda (zp_ptr0),y
        sta en_dyl_s,x
        iny
        lda (zp_ptr0),y
        sta en_dyh_s,x
        clc
        lda zp_ptr0
        adc #SEG_LEN
        sta en_segl_s,x
        lda zp_ptr0+1
        adc #0
        sta en_segh_s,x
        rts
.end    lda #0
        sta en_timer_s,x        ; 0 = hold velocity forever
        rts

!zone enemy_explode
; -----------------------------------------------------------------------------
; enemy_explode: enemy in slot Y was hit. It stops, shows the explosion for
; EXPL_FRAMES, then its slot is freed (enemies_update). While exploding it
; can't fire, move or collide. Preserves X and Y. Clobbers A.
; -----------------------------------------------------------------------------
enemy_explode
        lda #EXPL_FRAMES
        sta en_state_s,y
        lda expl_ptr            ; the sequence's first shape
        sta spr_ptr,y
        lda expl_col
        sta spr_col,y
        lda #SFX_ENEMY_BOOM
        jmp sfx_start           ; (preserves X and Y)

; The explosion sequence: shapes and their 'i' colours (yellow -> orange
; -> red, as the fire turns to smoke), shared by enemies, the player and
; boss parts. expl_by_left: an enemy's frames left -> shape number.
expl_ptr     !byte PTR_EXPL_1, PTR_EXPL_2, PTR_EXPL_B, PTR_EXPL_4, PTR_EXPL_5, PTR_EXPL_6
expl_col     !byte COL_YELLOW, COL_YELLOW, COL_ORANGE, COL_RED, COL_RED, COL_RED
expl_by_left !for .c, 0, EXPL_FRAMES {
                !if .c = 0 { !byte EXPL_SHAPES - 1 } else { !byte (EXPL_FRAMES - .c) / EXPL_STEP }
             }
!if expl_col - expl_ptr != EXPL_SHAPES { !error "expl_ptr: one shape per step" }

!zone enemy_step
; -----------------------------------------------------------------------------
; enemy_step: one frame along the path for slot X: run the segment timer
; (reading the next segment, which may fire, when it runs out), then add
; the 8.8 velocity to the position. Used by enemies and the boss.
; Preserves X. Clobbers A, Y, zp_ptr0, zp_tmp2, aim_*.
; -----------------------------------------------------------------------------
enemy_step
        lda en_timer_s,x        ; 0 = holding the final velocity
        beq .move
        dec en_timer_s,x
        bne .move
        jsr load_seg            ; segment finished: read the next one
.move   clc                     ; X += dx (8.8)
        lda en_xfrac_s,x
        adc en_dxl_s,x
        sta en_xfrac_s,x
        lda spr_xh,x
        adc en_dxh_s,x
        sta spr_xh,x
        clc                     ; Y += dy (8.8)
        lda en_yfrac_s,x
        adc en_dyl_s,x
        sta en_yfrac_s,x
        lda spr_y,x
        adc en_dyh_s,x
        sta spr_y,x
        rts

!zone enemy_mark_drop
; -----------------------------------------------------------------------------
; enemy_mark_drop: the enemy in slot Y was just shot down (enemy_explode
; already called). Mark it to drop a medal if its type does.
; Preserves X and Y. Clobbers A.
; -----------------------------------------------------------------------------
enemy_mark_drop
        txa
        pha
        lda en_type_s,y
        tax
        lda etype_drop,x
        beq +
        lda en_state_s,y
        ora #EN_DROP
        sta en_state_s,y
+       pla
        tax
        rts

; enemy_to_medal: turn the finished explosion in slot X into a medal.
enemy_to_medal
        lda #EN_MEDAL
        sta en_state_s,x
        lda #PTR_MEDAL
        sta spr_ptr,x
        lda #COL_MEDAL
        sta spr_col,x
        lda #0
        sta en_timer_s,x        ; 0 = no path: just keep this velocity
        sta en_dxl_s,x
        sta en_dxh_s,x
        lda #<int(MEDAL_DY * 256)
        sta en_dyl_s,x
        lda #>int(MEDAL_DY * 256)
        sta en_dyh_s,x
        rts

; medal_collect: the player touched the medal in slot Y. Score, slot freed.
; Preserves X and Y.
medal_collect
        txa
        pha
        tya
        pha
        lda #0
        sta en_state_s,y
        lda #0
        sta spr_on,y
        lda #MEDAL_PTS_LO
        ldy #MEDAL_PTS_MID
        jsr score_add_bcd
        lda #SFX_MEDAL
        jsr sfx_start
        pla
        tay
        pla
        tax
        rts

!zone enemies_update
; -----------------------------------------------------------------------------
; enemies_update: once per frame. Advance each live enemy along its path and
; free its slot once it is fully off screen.
; TIMING: ~70 cycles per live enemy, plus ~60 when a segment changes.
; Clobbers A, X, Y, zp_ptr0.
; -----------------------------------------------------------------------------
enemies_update
        lda boss_state          ; during a boss fight the enemy slots belong
        beq +                   ;   to the boss (boss_update moves them)
        rts
+       ldx #SLOT_ENEMY0
.loop   lda spr_on,x
        beq .next

        lda en_state_s,x
        beq .flying             ; flying its path
        bmi .flying             ; a medal: drifts down (timer 0 = no path)
        dec en_state_s,x        ; exploding: stays put, no path, no firing
        lda en_state_s,x
        and #EN_COUNT
        beq .exploded
        tay                     ; frames left -> the sequence's shape
        lda expl_by_left,y
        tay
        lda expl_ptr,y
        sta spr_ptr,x
        lda expl_col,y
        sta spr_col,x
        jmp .next

.exploded
        lda en_state_s,x        ; EN_DROP left = shot down and drops a medal
        beq .kill               ; (otherwise free the slot)
        jsr enemy_to_medal
        jmp .next

.flying jsr enemy_step
        lda spr_y,x
        cmp #PLAY_Y_END         ; off the bottom (or wrapped from the top)
        bcs .kill
        cmp #ENEMY_Y_KILL_TOP   ; off the top
        bcc .kill
        lda spr_xh,x
        cmp #ENEMY_X_KILL       ; off the right, or wrapped off the left
        bcc .next

.kill   lda #0
        sta spr_on,x
        lda #0                  ; a freed slot always has en_state 0, so a
        sta en_state_s,x        ;   medal that fell off can't leave EN_MEDAL

.next   inx
        cpx #SLOT_ENEMY0 + ENEMY_COUNT
        bne .loop
        rts
