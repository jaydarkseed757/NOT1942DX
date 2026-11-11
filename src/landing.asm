; =============================================================================
; landing.asm - after each boss, the ship lands on an aircraft carrier
; =============================================================================
;
; LEVEL CLEAR (lvl_state = LS_CLEAR, level.asm) runs this sequence, once the
; boss is gone (boss_state = BS_DONE: enemies_update stands still, so the
; enemy slots are ours):
;   LP_WAIT      a ship shot down as the boss died respawns first. Then the
;                controls lock and the carrier appears, its stern first,
;                above the top of the screen.
;   LP_APPROACH  the carrier sails into view, down the screen at half the
;                map's speed (it steams north, slower than the ship flies);
;                the ship steers itself over its deck (LAND_X, LAND_Y).
;   LP_DESCEND   once the deck is under the whole ship, it comes down onto
;                it: 48 frames, shrinking a little (data/sprites.asm:
;                spr_ship_s1, _s2).
;   LP_TAXI      down on the stern: the fanfare starts (SONG_CLEAR,
;                data/music_clear.asm), and it taxis forward to park
;                amidships, beside the island (PARK_REL).
;   LP_RIDE      parked: it rides the deck, moving with the carrier, which
;                eases to a stop on screen (RIDE_EASE), while "LEVEL CLEAR"
;                shows, until the fanfare is over; then level.asm's
;                countdown and fade (lvl_timer) as before.
; The carrier is three X+Y expanded sprites in enemy slots 0-2, one above
; the other (48x126 px), left of centre, clear of the LEVEL CLEAR message.
; Their en_state is 1 ("exploding"), so collisions pass them by. A slot is
; shown only while its part's top is on lines 0-255 (car_y is signed 16-bit).
; Nothing can hit the ship now: the boss's death cleared the enemy shots.
; In front: where two sprites overlap the VIC draws the lower hardware sprite
; on top, and the multiplexer hands them out top to bottom, so the carrier
; (its part always starts above the ship) would cover the ship. So while it
; lands the ship is drawn in the boss bar's slot instead (SLOT_HUD_BAR: a
; pinned entry, hardware sprite 3, ahead of every sorted one; the bar is gone
; with the boss). The player's slot is off meanwhile; player_xh / player_y
; still hold the position. level_begin's hud_init puts the bar slot back.
; The parts are sorted entries, and entries 8 and up get hardware sprites
; 0-2 again, in front of the ship. Over the stern (descent, taxi) there are
; only the three parts, entries 4-6. Parked, the ship is on the middle part,
; the second sorted entry (5) while that part starts above the LEVEL CLEAR
; message (4 sprites, at line 150, shown only then): the carrier stops on
; screen soon after parking for this (PARKED_MAX checks it at assembly). The
; stern part may be entry 10 then.
; =============================================================================

LP_WAIT     = 0
LP_APPROACH = 1
LP_DESCEND  = 2
LP_TAXI     = 3
LP_RIDE     = 4

CAR_SLOT    = SLOT_ENEMY0       ; its three parts: enemy slots 0-2
CAR_PARTS   = 3
CAR_PART_H  = 42                ; an expanded sprite's height
CAR_H       = CAR_PARTS * CAR_PART_H
CAR_X       = SCREEN_X_MIN + 28 ; screen pixels 56-103 (half-X 40-63)
CAR_Y0      = 50 - CAR_H        ; its first top: the stern just above line 50
COL_CARRIER = COL_BROWN         ; the deck (pixel 'i'): wooden planking
LAND_X      = CAR_X + 6         ; the ship (12 half-X) on the deck's middle
LAND_Y      = 110               ; where it waits for the deck
LAND_DECK   = LAND_Y + PLAYER_H - CAR_H  ; car_y with the deck under the ship
DESCEND_FRAMES = 48             ; 16 frames a shape
PARK_REL    = 48                ; parked: the ship's top this far below the
                                ;   carrier's (on the middle part, 42-83)
TAXI_FRAMES = LAND_Y - LAND_DECK - DESCEND_FRAMES / 2 - PARK_REL
                                ; (touchdown to parked: 1 pixel a frame along
                                ;   the deck; the carrier moved half a pixel a
                                ;   frame during the descent)
RIDE_FRAMES = CLEAR_TUNE_FRAMES - TAXI_FRAMES + 25
                                ; parked: to the fanfare's end and half a
                                ;   second more (the fade is the last 16)
                                ; (data/music_clear.asm checks it fits
                                ;   lvl_timer: the fanfare comes later)
RIDE_EASE   = 32                ; parked: frames the carrier slows down for
PARKED_MAX  = LAND_DECK + DESCEND_FRAMES / 2 + (TAXI_FRAMES + 1) / 2 + RIDE_EASE / 4 + 1
                                ; (car_y at most, once stopped)
!if PARKED_MAX + CAR_PART_H >= HUD_MSG_Y { !error "landing: the middle part must stop above the LEVEL CLEAR message's line" }

!if LAND_DECK < 0 { !error "landing: the deck must reach the ship below the top" }
!if PARK_REL < CAR_PART_H | PARK_REL + PLAYER_H > 2 * CAR_PART_H { !error "landing: park the ship on the middle part" }
!if CAR_SLOT + CAR_PARTS > SLOT_ENEMY0 + ENEMY_COUNT { !error "landing: the carrier needs enemy slots" }

land_phase !byte 0              ; LP_*
land_timer !byte 0              ; frames into the descent
land_moved !byte 0              ; the carrier moved a pixel this frame
land_off   !byte 0              ; (land_steer: an axis still to go)
car_y      !word 0              ; the carrier's top (part 0), screen Y, signed

!zone land_update
; -----------------------------------------------------------------------------
; land_update: once per frame in LS_CLEAR, from level_update (after the
; player, so the ship's position here is what the next frame shows; before
; mux_build). level.asm counts down LEVEL CLEAR once land_phase = LP_RIDE.
; Clobbers A, X.
; TIMING: ~150 cycles, plus ~400 in mux_build for the pinned entries on the
; frames the ship moves; the carrier's three sprites replace the boss's four.
; -----------------------------------------------------------------------------
land_update
        lda land_phase
        bne .going
        lda player_state        ; LP_WAIT: a ship shot down as the boss died
        beq +                   ;   respawns first
        rts
+       lda #0
        sta invuln_timer        ; (a respawned ship stops blinking)
        sta spr_on + SLOT_PLAYER ; (the ship is drawn in the bar's slot)
        lda #$ff
        sta spr_mc + SLOT_HUD_BAR ; (the bar is hires; the ship multicolour)
        lda #COL_PLAYER
        sta spr_col + SLOT_HUD_BAR
        lda #PTR_SHIP
        sta spr_ptr + SLOT_HUD_BAR
        ldx #CAR_PARTS - 1      ; the carrier, above the top of the screen
-       txa
        clc
        adc #PTR_CARRIER        ; (its shapes follow each other)
        sta spr_ptr + CAR_SLOT,x
        lda #COL_CARRIER
        sta spr_col + CAR_SLOT,x
        lda #$ff
        sta spr_exp + CAR_SLOT,x
        sta spr_mc + CAR_SLOT,x
        lda #CAR_X
        sta spr_xh + CAR_SLOT,x
        lda #1                  ; "exploding": collisions pass it by
        sta en_state,x
        dex
        bpl -
        lda #<CAR_Y0
        sta car_y
        lda #>CAR_Y0
        sta car_y+1
        lda #LP_APPROACH
        sta land_phase
        bne .place              ; (always)

.going  lda land_phase          ; the carrier: down a pixel every other
        cmp #LP_RIDE            ;   frame; parked, it eases to a stop
        bne .half               ;   (a quarter pixel a frame for the first
        lda lvl_timer           ;   RIDE_EASE frames, then still: the view
        cmp #RIDE_FRAMES - RIDE_EASE + 1 ;   follows it, and the middle
        bcc .still              ;   part stays above the message's line)
        lda frame_count
        and #3
        beq .move
.still  lda #0
        beq .moved1             ; (always)
.half   lda frame_count
        and #1
        beq .moved1
.move   inc car_y
        bne +
        inc car_y+1
+       lda #1
.moved1 sta land_moved
        lda land_phase
        cmp #LP_APPROACH
        bne .descend
        jsr land_steer          ; the ship over the deck's landing spot
        bcs .place              ; (not there yet)
        lda car_y+1             ; the deck under the whole ship yet?
        bmi .place
        lda car_y
        cmp #LAND_DECK
        bcc .place
        lda #LP_DESCEND
        sta land_phase
        lda #0
        sta land_timer
.place  jmp car_place           ; (in branch range of the code above)

.descend
        cmp #LP_DESCEND
        bne .taxi
        inc land_timer          ; coming down: a little smaller every 16
        lda land_timer          ;   frames
        lsr
        lsr
        lsr
        lsr
        tax
        cpx #DESCEND_FRAMES / 16
        bcs .down
        lda land_shapes,x
        cmp spr_ptr + SLOT_HUD_BAR
        beq car_place           ; (the same shape)
        sta spr_ptr + SLOT_HUD_BAR
        jsr mux_pins_changed    ; (a pinned entry: written only when asked)
        jmp car_place
.down   lda #LP_TAXI            ; down on the stern: the fanfare
        sta land_phase
        lda #SONG_CLEAR
        jsr music_start
        jmp car_place

.taxi   cmp #LP_TAXI
        bne .ride
        lda land_moved          ; forward along the deck, 1 pixel a frame
        bne +                   ;   against it: up a pixel on the frames
        dec player_y            ;   the carrier doesn't move
+       lda player_y            ; parked yet? (ship's top - carrier's top;
        sec                     ;   the carrier is below line 0 by now)
        sbc car_y
        cmp #PARK_REL + 1
        bcs car_place
        lda #LP_RIDE            ; parked: LEVEL CLEAR
        sta land_phase
        lda #RIDE_FRAMES
        sta lvl_timer
        jsr hud_show_clear      ; (it switches the bar's slot off: car_place
        jmp car_place           ;   switches it on again, with the ship)

.ride   jsr land_fade
        lda land_moved          ; parked: it moves with the carrier
        beq car_place
        inc player_y
        ; (fall through)

; car_place: each carrier part's Y from car_y; a part is shown while its
; top is on lines 0-255 (above the window it is hidden by the border, or
; left out by mux_build). Then the ship, in the bar's pinned slot, where
; player_xh / player_y say: a pinned entry is written only when
; mux_pins_changed asks, so it asks when the ship has moved or the slot was
; off (hud_show_clear switches it off). Clobbers A, X.
car_place
        lda player_xh
        cmp spr_xh + SLOT_HUD_BAR
        bne .moved
        lda player_y
        cmp spr_y + SLOT_HUD_BAR
        bne .moved
        lda spr_on + SLOT_HUD_BAR
        bne .parts              ; on, and where it was: nothing to redo
.moved  lda player_xh
        sta spr_xh + SLOT_HUD_BAR
        lda player_y
        sta spr_y + SLOT_HUD_BAR
        lda #1
        sta spr_on + SLOT_HUD_BAR
        jsr mux_pins_changed
.parts
        ldx #CAR_PARTS - 1
-       lda car_y
        clc
        adc .car_dy,x
        sta spr_y + CAR_SLOT,x
        lda car_y+1
        adc #0
        bne +                   ; negative, or past line 255: off
        lda #1
        bne ++
+       lda #0
++      sta spr_on + CAR_SLOT,x
        dex
        bpl -
        rts
.car_dy !byte 0 * CAR_PART_H, 1 * CAR_PART_H, 2 * CAR_PART_H
!if CAR_PARTS != 3 { !error "car_place: .car_dy lists three parts" }

; land_fade: while the level fades out (fade_dir = 1, level.asm) the carrier
; and the ship darken with it, a step per fade_k: their own colours and the
; sprites' two shared ones ($D025 / $D026; init_sprites sets them again).
; The message goes when the fade starts. Clobbers A, X.
land_fade
        lda fade_dir
        cmp #1
        bne ++
        lda lvl_timer           ; the fade's first frame: no message
        cmp #FADE_FRAMES
        bne +
        lda #0
        jsr hud_message
+       ldx fade_k
        lda .fcar,x
        sta spr_col + CAR_SLOT
        sta spr_col + CAR_SLOT + 1
        sta spr_col + CAR_SLOT + 2
        lda .fship,x
        sta spr_col + SLOT_HUD_BAR
        jsr mux_pins_changed    ; (a pinned entry: its colour too)
        lda .fmc0,x
        sta SPR_MC0
        lda .fmc1,x
        sta SPR_MC1
++      rts
.fcar   !byte COL_CARRIER, COL_CARRIER, COL_CARRIER, COL_BLACK, COL_BLACK
.fship  !byte COL_PLAYER, COL_GREY, COL_DGREY, COL_BLACK, COL_BLACK
.fmc0   !byte SPR_SHARED1, COL_LGREY, COL_GREY, COL_DGREY, COL_BLACK
.fmc1   !byte SPR_SHARED2, COL_DGREY, COL_DGREY, COL_BLACK, COL_BLACK
!if FADE_STEPS != 4 { !error "land_fade: its tables have FADE_STEPS + 1 entries" }

land_shapes !byte PTR_SHIP, PTR_SHIP_S1, PTR_SHIP_S2
!if DESCEND_FRAMES / 16 != 3 { !error "land_update: three shapes, 16 frames each" }

; land_steer: move the ship a step (1 half-X, 1 pixel) towards LAND_X,
; LAND_Y. C set while it isn't there yet. Clobbers A.
land_steer
        lda #0
        sta land_off
        lda player_xh
        cmp #LAND_X
        beq ++
        inc land_off            ; (keeps C)
        bcc +
        dec player_xh
        bcs ++                  ; (always: C still set)
+       inc player_xh
++      lda player_y
        cmp #LAND_Y
        beq ++
        inc land_off
        bcc +
        dec player_y
        bcs ++
+       inc player_y
++      lda land_off
        cmp #1                  ; C = an axis still to go
        rts
