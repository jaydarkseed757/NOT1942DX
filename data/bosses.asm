; =============================================================================
; data/bosses.asm - boss table and attack scripts
; =============================================================================
;
; One column per boss. A boss is a list of up to BOSS_MAX_PARTS X+Y expanded
; sprites (48x42 px each), placed at offsets from the first part, which
; flies the script (see bossN_parts below).
;   parts      the part list          col     body colour (pixel 'i')
;   w          width in half-X (the X clamp keeps x + w <= 172)
;   x          start X (half-X, left edge; must keep x + w <= 172)
;   hp         hits to destroy        hp_block  HP per block of the HUD bar
;              (M10: about 15-30 s of steady fire at 6 shots a second, boss 1
;              to 4; every shot hits bosses this big. HP <= 255; hp_block =
;              HP / BAR_BLOCKS, rounded up, so the bar starts full)
;   phase2     switch to script 2 when HP falls below this
;   script     path: +path_start Y, then segments (data/waves.asm format)
;   script2    phase-2 segments (no start Y: it continues from where it is)
;
; GUN OFFSETS for +boss_fire / +boss_spread are measured from the boss's
; top-left (half-X, pixels). Expanded pixels are 2 half-X wide and 2 pixels
; tall, so art column c, row r is at (2c, 2r). A bullet's own art is centred
; 6 half-X in, so a gun under art column c uses DX = 2c - 6 (+1 to centre on
; a 2-wide feature).
; Boss 1 guns: its part 0 is the lower-left sprite (the art's row 21), so
;              DY = 2 * (row - 21):
;              nose (cols 17-18, row 40) -> DX 29, DY 38
;              inner engines (cols 12 and 23, propellers on row 35)
;              -> DX 19 / 41, DY 28 (a 1-wide feature: DX = 2c - 5)
;              outer engines (cols 6 and 29, row 33) -> DX 7 / 53, DY 24
; Boss 2 guns: turrets (2 wide at cols 9, 17, 25, row 10) -> DX 13 / 29 / 45,
;              DY 20; lower engine pods (cols 10-11 and 20-21, row 19)
;              -> DX 15 / 35, DY 38
; Boss 3 guns: like boss 1, part 0 is the lower-left sprite (art row 21):
;              bow (cols 17-18, row 39) -> DX 29, DY 36
;              propellers (row 33) at cols 9 / 14 / 21 / 26 -> DX 13 / 23 / 37 / 47,
;              DY 24
; Boss 4 guns: turrets (centres at row 10) A cols 11-12 / B 18-19 / X 28-29
;              -> DX 17 / 31 / 51, DY 20; bridge top (col 23, row 6)
;              -> DX 41, DY 12
; =============================================================================

BOSS_COUNT = 4
BOSS_X_MID = (SCREEN_X_MIN + SCREEN_X_MAX - 72) / 2

;                       boss 1 "thunder"   boss 2 "leviathan"  boss 3 "albatross"  boss 4 "kraken"
boss_t_parts_lo   !byte <boss1_parts,    <boss2_parts,       <boss3_parts,       <boss4_parts
boss_t_parts_hi   !byte >boss1_parts,    >boss2_parts,       >boss3_parts,       >boss4_parts
boss_t_w          !byte 72,              72,                 72,                 72
boss_t_col        !byte COL_GREEN,       COL_LGREY,          COL_CYAN,           COL_LGREY
boss_t_x          !byte BOSS_X_MID,      BOSS_X_MID,         BOSS_X_MID,         BOSS_X_MID
boss_t_hp         !byte 80,              110,                136,                180
boss_t_hp_block   !byte 14,              19,                 23,                 30
boss_t_phase2     !byte 40,              55,                 68,                 90
boss_t_script_lo  !byte <boss1_script,   <boss2_script,      <boss3_script,      <boss4_script
boss_t_script_hi  !byte >boss1_script,   >boss2_script,      >boss3_script,      >boss4_script
boss_t_script2_lo !byte <boss1_script2,  <boss2_script2,     <boss3_script2,     <boss4_script2
boss_t_script2_hi !byte >boss1_script2,  >boss2_script2,     >boss3_script2,     >boss4_script2

; Part lists: +boss_parts N, then N lines of +boss_part SHAPE, DX, DY (offset
; from the first part in half-X / pixels; an expanded sprite is 24 x 42).
; The first part (0, 0) flies the script; its hits and guns are measured
; from its top-left, as before.
boss1_parts                             ; the lower row (wings, engines, nose)
        +boss_parts 4                   ;   and the tail above its middle;
        +boss_part_box PTR_BOSS1_BL, 0, 0, 0, 2, 24, 28    ;   boxes fit the art
        +boss_part_box PTR_BOSS1_BM, 24, 0, 0, 0, 24, 40
        +boss_part_box PTR_BOSS1_BR, 48, 0, 0, 2, 24, 28
        +boss_part_box PTR_BOSS1_TM, 24, -42, 6, 0, 12, 42 ; (Y wraps: 42 up)
boss2_parts                             ; the hull is hit; the pods above and
        +boss_parts 3                   ;   below it aren't; the tail's fins are
        +boss_part_box PTR_BOSS2_L, 0, 0, 0, 6, 24, 30
        +boss_part_box PTR_BOSS2_M, 24, 0, 0, 6, 24, 30
        +boss_part_box PTR_BOSS2_R, 48, 0, 0, 2, 24, 38
boss3_parts                             ; the lower row (wings, engines, hull)
        +boss_parts 4                   ;   and the tail above its middle;
        +boss_part_box PTR_BOSS3_BL, 0, 0, 0, 6, 24, 20    ;   boxes fit the art
        +boss_part_box PTR_BOSS3_BM, 24, 0, 0, 0, 24, 40
        +boss_part_box PTR_BOSS3_BR, 48, 0, 0, 6, 24, 20
        +boss_part_box PTR_BOSS3_TM, 24, -42, 6, 2, 12, 40 ; (Y wraps: 42 up)
boss4_parts                             ; the hull is hit (rows 2-18), not
        +boss_parts 3                   ;   the water around it
        +boss_part_box PTR_BOSS4_L, 0, 0, 0, 4, 24, 34
        +boss_part_box PTR_BOSS4_M, 24, 0, 0, 4, 24, 34
        +boss_part_box PTR_BOSS4_R, 48, 0, 0, 4, 24, 34

; -----------------------------------------------------------------------------
; Boss 1 "Thunder"
; -----------------------------------------------------------------------------
; Phase 1: glides in from behind the top border, then patrols left and right
; above the player, alternating an aimed nose shot with engine spreads.
BOSS1_Y0 = 28 + 42                      ; its lower row (part 0): the tail
!if BOSS1_Y0 < HUD_Y + SPR_HEIGHT + MUX_SETUP { ;   above it is hidden in the
        ; the lower row needs hardware sprites the HUD holds until then
        !error "boss 1 starts too high: the multiplexer would drop its lower row"
}                                       ;   top border at first
boss1_script
        +path_start BOSS1_Y0
        +seg 0, 1, 92 - BOSS1_Y0        ; descend: tail at Y 50, nose at 130
boss1_loop
        +seg 0.5, 0, 36                 ; drift right
        +boss_fire 29, 38               ; nose gun, aimed
        +seg 0.5, 0, 36
        +boss_spread 19, 28             ; left inner engine: V of two shots
        +seg -0.5, 0, 72                ; back across to the left
        +boss_fire 29, 38
        +seg -0.5, 0, 36
        +boss_spread 41, 28             ; right inner engine
        +seg 0.5, 0, 36                 ; return to the middle
        +seg_loop boss1_loop

; Phase 2 (HP below half): faster, bobbing, and firing twice as often.
boss1_script2
        +seg 0.75, 0.25, 24
        +boss_spread 29, 38
        +seg 0.75, -0.25, 24
        +boss_fire 7, 24                ; outer engines, aimed
        +seg -0.75, 0.25, 24
        +boss_fire 53, 24
        +seg -0.75, -0.25, 24
        +boss_spread 29, 38
        +seg -0.75, 0.25, 24
        +boss_fire 19, 28
        +seg -0.75, -0.25, 24
        +boss_fire 41, 28
        +seg 0.75, 0.25, 24
        +boss_spread 29, 38
        +seg 0.75, -0.25, 24
        +seg_loop boss1_script2

; -----------------------------------------------------------------------------
; Boss 2 "Leviathan"
; -----------------------------------------------------------------------------
; Phase 1: sinks slowly into view, then drifts lazily from side to side. The
; turrets aim at you; the lower engine pods fire spreads.
boss2_script
        +path_start 8
        +seg 0, 0.75, 72                ; slow descent to Y 62
boss2_loop
        +seg 0.375, 0.125, 48           ; drift right, sinking a little
        +boss_fire 29, 20               ; middle turret, aimed
        +seg 0.375, -0.125, 48          ; ...and rising back
        +boss_spread 35, 38             ; right lower engine pod
        +seg -0.375, 0.125, 48
        +boss_fire 29, 20
        +seg -0.375, -0.125, 48
        +boss_spread 15, 38             ; left lower engine pod
        +seg -0.375, 0.125, 48
        +boss_fire 29, 20
        +seg -0.375, -0.125, 48
        +seg 0.375, 0.125, 48           ; back to the middle
        +boss_spread 29, 20
        +seg 0.375, -0.125, 48
        +seg_loop boss2_loop

; Phase 2 (HP at half): it vents gas and turns aggressive: a lower, faster
; sweep with a spread from every gun in turn.
boss2_script2
        +seg 0, 0.5, 24                 ; drops 12 px, closer to the player
boss2_loop2
        +seg 0.75, 0, 24
        +boss_spread 15, 38
        +seg 0.75, 0, 24
        +boss_fire 13, 20               ; left turret
        +seg -0.75, 0, 24
        +boss_spread 35, 38
        +seg -0.75, 0, 24
        +boss_fire 45, 20               ; right turret
        +seg -0.75, 0, 24
        +boss_spread 29, 20
        +seg 0.75, 0, 24
        +seg_loop boss2_loop2

; -----------------------------------------------------------------------------
; Boss 3 "Albatross"
; -----------------------------------------------------------------------------
; Phase 1: patrols high, then DIVES at you (40 px: its bow reaches Y ~170),
; fires a spread from the bow at the bottom of the dive, and climbs back.
; Between dives: spreads from the outer engines.
BOSS3_Y0 = 28 + 42                      ; its lower row (part 0): the tail
!if BOSS3_Y0 < HUD_Y + SPR_HEIGHT + MUX_SETUP { ;   above it is hidden in the
        ; the lower row needs hardware sprites the HUD holds until then
        !error "boss 3 starts too high: the multiplexer would drop its lower row"
}                                       ;   top border at first
boss3_script
        +path_start BOSS3_Y0
        +seg 0, 1, 92 - BOSS3_Y0        ; descend: tail at Y 50, bow at 130
boss3_loop
        +seg 0.5, 0, 40                 ; patrol right
        +boss_fire 29, 36               ; bow gun, aimed
        +seg -0.5, 0, 40                ; back to the middle
        +seg 0, 2, 20                   ; DIVE 40 px
        +boss_spread 29, 36             ; bow spread at the bottom
        +seg 0, 0, 12                   ; hang there...
        +boss_fire 23, 24               ; ...inner engine guns
        +seg 0, -1, 40                  ; climb back
        +seg -0.5, 0, 40                ; patrol left
        +boss_spread 13, 24             ; left outer engine
        +seg 0.5, 0, 40
        +boss_spread 47, 24             ; right outer engine
        +seg_loop boss3_loop

; Phase 2 (HP at half): constant slanting dives, left and right, firing at
; the bottom of every one. 24 px each: phase 2 may start at the bottom of a
; dive, and its swing is around that height (the bow stays above Y ~195).
boss3_script2
        +seg 0.75, 1, 24              ; dive down-right
        +boss_spread 29, 36
        +seg 0.75, -1, 24             ; climb
        +seg -0.75, 1, 24             ; dive down-left
        +boss_fire 13, 24
        +seg -0.75, -1, 24
        +seg -0.75, 1, 24
        +boss_spread 29, 36
        +seg -0.75, -1, 24
        +seg 0.75, 1, 24
        +boss_fire 47, 24
        +seg 0.75, -1, 24
        +seg_loop boss3_script2

; -----------------------------------------------------------------------------
; Boss 4 "Kraken" - the final boss
; -----------------------------------------------------------------------------
; Phase 1: steams slowly into view and creeps from side to side, its three
; turrets firing in turn, with flak spreads from the bridge in between.
boss4_script
        +path_start 8
        +seg 0, 0.5, 96                 ; into view, Y 56
boss4_loop
        +seg 0.25, 0, 48                ; creep right...
        +boss_fire 17, 20               ;   turret A
        +seg 0.25, 0, 24
        +boss_fire 31, 20               ;   turret B
        +seg 0.25, 0, 24
        +boss_fire 51, 20               ;   turret X
        +seg -0.25, 0, 48               ; ...and back
        +boss_spread 41, 12             ;   bridge flak
        +seg -0.25, 0, 48
        +seg -0.25, 0, 48               ; creep left...
        +boss_fire 51, 20
        +seg -0.25, 0, 24
        +boss_fire 31, 20
        +seg -0.25, 0, 24
        +boss_fire 17, 20
        +seg 0.25, 0, 48                ; ...and back
        +boss_spread 41, 12
        +seg 0.25, 0, 48
        +seg_loop boss4_loop

; Phase 2 (HP at half): it closes in and every gun fires: faster sweeps,
; alternating spreads and aimed shots from all three turrets.
boss4_script2
        +seg 0, 0.5, 32                 ; 16 px closer
boss4_loop2
        +seg 0.5, 0, 24
        +boss_spread 17, 20
        +seg 0.5, 0, 24
        +boss_fire 51, 20
        +seg -0.5, 0, 24
        +boss_spread 41, 12
        +seg -0.5, 0, 24
        +boss_fire 31, 20
        +seg -0.5, 0, 24
        +boss_spread 51, 20
        +seg -0.5, 0, 24
        +boss_fire 17, 20
        +seg 0.5, 0, 24
        +boss_spread 31, 20
        +seg 0.5, 0, 24
        +seg_loop boss4_loop2
