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
; Boss 2 guns: gondola (cols 13-20, centre 16-17, bottom row 15) -> DX 27, DY 32
;              engine pods (cols 5-9 and 24-28, centres 7 / 26, row 14)
;              -> DX 9 / 47, DY 30
; Boss 3 guns: bow (cols 16-19, centre 17-18, row 16) -> DX 29, DY 34
;              propellers (row 11) at cols 6 / 12 / 23 / 29 -> DX 6 / 18 / 40 / 52,
;              DY 24
; Boss 4 guns: turrets (row 7) A col 10 / B col 15 / X col 27 -> DX 14 / 24 / 48,
;              DY 16; bridge (col 20, row 9) -> DX 34, DY 20
; =============================================================================

BOSS_COUNT = 4
BOSS_X_MID = (SCREEN_X_MIN + SCREEN_X_MAX - 72) / 2

;                       boss 1 "thunder"   boss 2 "leviathan"  boss 3 "albatross"  boss 4 "kraken"
boss_t_parts_lo   !byte <boss1_parts,    <boss2_parts,       <boss3_parts,       <boss4_parts
boss_t_parts_hi   !byte >boss1_parts,    >boss2_parts,       >boss3_parts,       >boss4_parts
boss_t_w          !byte 72,              72,                 72,                 72
boss_t_col        !byte COL_GREEN,       COL_LGREY,          COL_CYAN,           COL_LGREY
boss_t_x          !byte BOSS_X_MID,      BOSS_X_MID,         BOSS_X_MID,         BOSS_X_MID
boss_t_hp         !byte 30,              42,                 50,                 64
boss_t_hp_block   !byte 5,               7,                  9,                  11
boss_t_phase2     !byte 15,              21,                 25,                 32
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
boss2_parts
        +boss_parts 3
        +boss_part PTR_BOSS2_L, 0, 0
        +boss_part PTR_BOSS2_M, 24, 0
        +boss_part PTR_BOSS2_R, 48, 0
boss3_parts
        +boss_parts 3
        +boss_part PTR_BOSS3_L, 0, 0
        +boss_part PTR_BOSS3_M, 24, 0
        +boss_part PTR_BOSS3_R, 48, 0
boss4_parts
        +boss_parts 3
        +boss_part PTR_BOSS4_L, 0, 0
        +boss_part PTR_BOSS4_M, 24, 0
        +boss_part PTR_BOSS4_R, 48, 0

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
; gondola gun aims at you; the engine pods fire spreads.
boss2_script
        +path_start 8
        +seg 0, 0.75, 72                ; slow descent to Y 62
boss2_loop
        +seg 0.375, 0.125, 48           ; drift right, sinking a little
        +boss_fire 27, 32               ; gondola, aimed
        +seg 0.375, -0.125, 48          ; ...and rising back
        +boss_spread 47, 30             ; right engine pod
        +seg -0.375, 0.125, 48
        +boss_fire 27, 32
        +seg -0.375, -0.125, 48
        +boss_spread 9, 30              ; left engine pod
        +seg -0.375, 0.125, 48
        +boss_fire 27, 32
        +seg -0.375, -0.125, 48
        +seg 0.375, 0.125, 48           ; back to the middle
        +boss_spread 27, 32
        +seg 0.375, -0.125, 48
        +seg_loop boss2_loop

; Phase 2 (HP at half): it vents gas and turns aggressive: a lower, faster
; sweep with a spread from every gun in turn.
boss2_script2
        +seg 0, 0.5, 24                 ; drops 12 px, closer to the player
boss2_loop2
        +seg 0.75, 0, 24
        +boss_spread 9, 30
        +seg 0.75, 0, 24
        +boss_fire 27, 32
        +seg -0.75, 0, 24
        +boss_spread 47, 30
        +seg -0.75, 0, 24
        +boss_fire 27, 32
        +seg -0.75, 0, 24
        +boss_spread 27, 32
        +seg 0.75, 0, 24
        +seg_loop boss2_loop2

; -----------------------------------------------------------------------------
; Boss 3 "Albatross"
; -----------------------------------------------------------------------------
; Phase 1: patrols high, then DIVES at you (down to Y ~120, its hull reaching
; the middle of the screen), fires a spread from the bow at the bottom of the
; dive, and climbs back. Between dives: spreads from the outer engines.
boss3_script
        +path_start 8
        +seg 0, 1, 52                   ; descend to Y 60
boss3_loop
        +seg 0.5, 0, 40                 ; patrol right
        +boss_fire 29, 34               ; bow gun, aimed
        +seg -0.5, 0, 40                ; back to the middle
        +seg 0, 2, 30                   ; DIVE to Y 120
        +boss_spread 29, 34             ; bow spread at the bottom
        +seg 0, 0, 12                   ; hang there...
        +boss_fire 18, 24               ; ...inner engine guns
        +seg 0, -1.5, 40                ; climb back to Y 60
        +seg -0.5, 0, 40                ; patrol left
        +boss_spread 6, 24              ; left outer engine
        +seg 0.5, 0, 40
        +boss_spread 52, 24             ; right outer engine
        +seg_loop boss3_loop

; Phase 2 (HP at half): constant slanting dives, left and right, firing at
; the bottom of every one.
boss3_script2
        +seg 0.75, 1.5, 24              ; dive down-right
        +boss_spread 29, 34
        +seg 0.75, -1.5, 24             ; climb
        +seg -0.75, 1.5, 24             ; dive down-left
        +boss_fire 6, 24
        +seg -0.75, -1.5, 24
        +seg -0.75, 1.5, 24
        +boss_spread 29, 34
        +seg -0.75, -1.5, 24
        +seg 0.75, 1.5, 24
        +boss_fire 52, 24
        +seg 0.75, -1.5, 24
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
        +boss_fire 14, 16               ;   turret A
        +seg 0.25, 0, 24
        +boss_fire 24, 16               ;   turret B
        +seg 0.25, 0, 24
        +boss_fire 48, 16               ;   turret X
        +seg -0.25, 0, 48               ; ...and back
        +boss_spread 34, 20             ;   bridge flak
        +seg -0.25, 0, 48
        +seg -0.25, 0, 48               ; creep left...
        +boss_fire 48, 16
        +seg -0.25, 0, 24
        +boss_fire 24, 16
        +seg -0.25, 0, 24
        +boss_fire 14, 16
        +seg 0.25, 0, 48                ; ...and back
        +boss_spread 34, 20
        +seg 0.25, 0, 48
        +seg_loop boss4_loop

; Phase 2 (HP at half): it closes in and every gun fires: faster sweeps,
; alternating spreads and aimed shots from all three turrets.
boss4_script2
        +seg 0, 0.5, 32                 ; 16 px closer
boss4_loop2
        +seg 0.5, 0, 24
        +boss_spread 14, 16
        +seg 0.5, 0, 24
        +boss_fire 48, 16
        +seg -0.5, 0, 24
        +boss_spread 34, 20
        +seg -0.5, 0, 24
        +boss_fire 24, 16
        +seg -0.5, 0, 24
        +boss_spread 48, 16
        +seg -0.5, 0, 24
        +boss_fire 14, 16
        +seg 0.5, 0, 24
        +boss_spread 24, 16
        +seg 0.5, 0, 24
        +seg_loop boss4_loop2
