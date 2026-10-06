; =============================================================================
; data/waves.asm - enemy types and movement paths
; Assembled in the level area, before the level stream that refers to them.
; =============================================================================

; -----------------------------------------------------------------------------
; ENEMY TYPES: the look of an enemy. Its movement comes from the path given
; in the +spawn line, so any type can fly any path.
; -----------------------------------------------------------------------------
E_FIGHTER   = 0                 ; green single-engine fighter
E_LEADER    = 1                 ; red twin-engine leader
E_RAIDER    = 2                 ; orange twin-tail fighter (level 2)
E_RAIDER_UP = 3                 ; the same, nose up: for attacks from behind
E_GUNSHIP   = 4                 ; white heavy twin-engine fighter (level 2)
E_DIVER     = 5                 ; cyan gull-winged dive bomber (level 3)
E_ACE       = 6                 ; yellow fighter: an ace (level 4)
ENEMY_TYPES = 7

;                fighter      leader      raider       raider_up       gunship      diver      ace
etype_ptr   !byte PTR_FIGHTER, PTR_LEADER, PTR_RAIDER,  PTR_RAIDER_UP,  PTR_GUNSHIP, PTR_DIVER, PTR_ACE
etype_col   !byte COL_GREEN,   COL_RED,    COL_ORANGE,  COL_ORANGE,     COL_WHITE,   COL_CYAN,  COL_YELLOW

; Points for shooting one down, as BCD digits "MMLL" of the 6-digit score:
; fighter 100, leader 300, raider 150, gunship 400, diver 200, ace 250
etype_pts_mid !byte $01,       $03,        $01,         $01,            $04,         $02,       $02
etype_pts_lo  !byte $00,       $00,        $50,         $50,            $00,         $00,       $50

; 1 = shooting one down drops a gold medal (src/enemies.asm). Only the red
; leaders do. Crashing into one doesn't drop anything.
etype_drop    !byte 0,         1,          0,           0,              0,           0,         0

; The medal: points for collecting it (BCD "MMLL": 500 = $05,$00) and how
; fast it drifts down: 1 pixel per frame, the background's scroll speed,
; so it looks carried along by the map.
MEDAL_PTS_MID = $05
MEDAL_PTS_LO  = $00
MEDAL_DY      = 1.0               ; pixels per frame (8.8 fixed point)

; -----------------------------------------------------------------------------
; PATHS
;   +path_start Y, then +seg DX, DY, FRAMES lines, then +seg_end or +seg_loop.
;   +seg_fire anywhere in between fires one shot aimed at the player.
;   DX is in half-X units per frame (1.0 = 2 pixels), DY in pixels per frame.
;   Positive DY = down the screen. Fractions are fine (8.8 fixed point).
;
; Spawn Y 30 is above the HUD, inside the top border: the enemy slides into
; view from behind the border. Enemies are removed once fully off screen:
; past the bottom (Y >= 251), above Y 20, or off either side.
;
; Rough lifetimes, useful for keeping within ENEMY_COUNT live enemies (one
; scroll row = 8 frames): dive ~148 frames (19 rows), swoop ~165 (21), zigzag
; ~177 (22), cross ~115 (14).
; -----------------------------------------------------------------------------

; Straight down the screen, firing once at about Y 90.
path_dive
        +path_start 30
        +seg 0, 1.5, 40
        +seg_fire
        +seg 0, 1.5, 1
        +seg_end

; Dive, then curve away to the LEFT and leave by the left edge.
; Spawn on the right half.
path_swoop_l
        +path_start 30
        +seg 0,     1.75, 60
        +seg_fire               ; fire at the bottom of the dive (Y ~135)
        +seg -0.25, 1.5,  12
        +seg -0.5,  1.0,  12
        +seg -0.75, 0.5,  12
        +seg -1.5,  0,    1
        +seg_end

; Mirror of path_swoop_l: curve away to the RIGHT. Spawn on the left half.
path_swoop_r
        +path_start 30
        +seg 0,    1.75, 60
        +seg_fire
        +seg 0.25, 1.5,  12
        +seg 0.5,  1.0,  12
        +seg 0.75, 0.5,  12
        +seg 1.5,  0,    1
        +seg_end

; Weave left and right while descending. Swings 18 half-X (36 pixels) each
; way, so spawn at x 30-142 to stay on screen.
path_zigzag
        +path_start 30
path_zigzag_loop
        +seg 0.75,  1.25, 24
        +seg_fire               ; once per weave, at the right-hand turn
        +seg -0.75, 1.25, 24
        +seg_loop path_zigzag_loop

; Fly in from the LEFT edge and cross to the right. Spawn at x = 0.
path_cross_r
        +path_start 70
        +seg 1.5, 0.25, 50
        +seg_fire               ; mid-screen
        +seg 1.5, 0.25, 1
        +seg_end

; Fly in from the RIGHT edge and cross to the left. Spawn at x = 171.
path_cross_l
        +path_start 100
        +seg -1.5, 0.25, 50
        +seg_fire
        +seg -1.5, 0.25, 1
        +seg_end

; Fast dive: straight down at 2.25, firing once at about Y 100.
path_dive_fast
        +path_start 30
        +seg 0, 2.25, 32
        +seg_fire
        +seg 0, 2.25, 1
        +seg_end

; Hover gunner: drops in quickly, stops to fire twice, then dives away.
path_hover
        +path_start 30
        +seg 0, 2, 30                   ; to Y ~90
        +seg 0, 0.25, 20                ; brake
        +seg_fire
        +seg 0, 0, 30                   ; hold...
        +seg_fire
        +seg 0, 2.25, 1                 ; ...and go
        +seg_end

; Loop to the LEFT: dive, fly a full loop (8 headings, 45 degrees each),
; then fire and dive away. The loop is ~34 px across; spawn at x 30-142.
path_loop_l
        +path_start 30
        +seg 0, 1.5, 40                 ; dive to Y ~90
        +seg -0.53125, 1.0625, 9
        +seg -0.75, 0, 9
        +seg -0.53125, -1.0625, 9
        +seg 0, -1.5, 9
        +seg 0.53125, -1.0625, 9
        +seg 0.75, 0, 9
        +seg 0.53125, 1.0625, 9
        +seg 0, 1.5, 9
        +seg_fire                       ; out of the loop: fire
        +seg 0, 1.5, 1                  ; and dive away
        +seg_end

; Loop to the RIGHT: mirror of path_loop_l.
path_loop_r
        +path_start 30
        +seg 0, 1.5, 40                 ; dive to Y ~90
        +seg 0.53125, 1.0625, 9
        +seg 0.75, 0, 9
        +seg 0.53125, -1.0625, 9
        +seg 0, -1.5, 9
        +seg -0.53125, -1.0625, 9
        +seg -0.75, 0, 9
        +seg -0.53125, 1.0625, 9
        +seg 0, 1.5, 9
        +seg_fire                       ; out of the loop: fire
        +seg 0, 1.5, 1                  ; and dive away
        +seg_end

; Diagonal sweep from the upper LEFT towards the lower right. Spawn x 12-60.
path_diag_r
        +path_start 30
        +seg 0.75, 1.5, 40
        +seg_fire
        +seg 0.75, 1.5, 1
        +seg_end

; Diagonal sweep from the upper RIGHT towards the lower left. Spawn x 100-150.
path_diag_l
        +path_start 30
        +seg -0.75, 1.5, 40
        +seg_fire
        +seg -0.75, 1.5, 1
        +seg_end

; Attack from behind: climbs up from the bottom border (use E_RAIDER_UP,
; drawn nose up), fires once at about Y 145, and leaves over the top.
path_rise
        +path_start 250
        +seg 0, -1.75, 60
        +seg_fire
        +seg 0, -1.75, 1
        +seg_end

; The same, drifting to the RIGHT as it climbs. Spawn x 20-100.
path_rise_r
        +path_start 250
        +seg 0.375, -1.75, 60
        +seg_fire
        +seg 0.375, -1.75, 1
        +seg_end

; The same, drifting to the LEFT as it climbs. Spawn x 70-150.
path_rise_l
        +path_start 250
        +seg -0.375, -1.75, 60
        +seg_fire
        +seg -0.375, -1.75, 1
        +seg_end

; Dive-bomb: a steep dive, a shot at the bottom (Y ~140), then it pulls up
; and climbs away over the top. Use E_DIVER.
path_divebomb
        +path_start 30
        +seg 0, 2.5, 44
        +seg_fire
        +seg 0, 1.5, 8                  ; pulling out...
        +seg 0, 0.5, 8
        +seg 0, -0.5, 8
        +seg 0, -1.5, 8                 ; ...and climbing
        +seg 0, -2.5, 1
        +seg_end

; Weave: a smooth S-curve down the screen (8 headings per sway, 64 frames),
; firing once per sway. It ranges from 7 half-X left of the spawn x to 17
; right of it (14-34 px), so spawn at x 20-140.
path_weave
        +path_start 30
path_weave_loop
        +seg 1.25, 1.25, 8
        +seg_fire
        +seg 0.882812, 1.25, 8
        +seg 0, 1.25, 8
        +seg -0.882812, 1.25, 8
        +seg -1.25, 1.25, 8
        +seg -0.882812, 1.25, 8
        +seg 0, 1.25, 8
        +seg 0.882812, 1.25, 8
        +seg_loop path_weave_loop

; Path IDs for +spawn. Keep in the same order as the tables below.
P_DIVE      = 0
P_SWOOP_L   = 1
P_SWOOP_R   = 2
P_ZIGZAG    = 3
P_CROSS_R   = 4
P_CROSS_L   = 5
P_DIVE_FAST = 6
P_HOVER     = 7
P_LOOP_L    = 8
P_LOOP_R    = 9
P_DIAG_R    = 10
P_DIAG_L    = 11
P_RISE      = 12
P_RISE_R    = 13
P_RISE_L    = 14
P_DIVEBOMB  = 15
P_WEAVE     = 16
PATH_COUNT  = 17

path_lo     !byte <path_dive, <path_swoop_l, <path_swoop_r, <path_zigzag, <path_cross_r, <path_cross_l
            !byte <path_dive_fast, <path_hover, <path_loop_l, <path_loop_r, <path_diag_r, <path_diag_l
            !byte <path_rise, <path_rise_r, <path_rise_l, <path_divebomb, <path_weave
path_hi     !byte >path_dive, >path_swoop_l, >path_swoop_r, >path_zigzag, >path_cross_r, >path_cross_l
            !byte >path_dive_fast, >path_hover, >path_loop_l, >path_loop_r, >path_diag_r, >path_diag_l
            !byte >path_rise, >path_rise_r, >path_rise_l, >path_divebomb, >path_weave
