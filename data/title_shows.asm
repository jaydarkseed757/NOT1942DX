; =============================================================================
; data/title_shows.asm - the title screen's air show (src/title.asm)
; =============================================================================
;
; Formations fly past the title on the game's own paths (data/waves.asm),
; one display after another, then round again. They don't fire. Each
; +title_wave spawns its +spawn lines WAIT frames after the previous group:
; a formation is a few groups (a V's wings a little behind its point; a
; string one plane after another), and a longer WAIT starts the next
; display. At most ENEMY_COUNT planes may be up at once.
; =============================================================================

!set WAVE_LEFT = 0               ; (+spawn's count check)
title_shows
; a leader swoops away left, two wingmen on his wings (the wait is the gap
; after the last display, when the show goes round again; the first time,
; title.asm waits TITLE_FLY_FIRST)
        +title_wave 200, 1
        +spawn E_LEADER, 130, P_SWOOP_L
        +title_wave 8, 2
        +spawn E_FIGHTER, 110, P_SWOOP_L
        +spawn E_FIGHTER, 150, P_SWOOP_L

; a string of five sweeps across from the upper left
        +title_wave 150, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +title_wave 10, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +title_wave 10, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +title_wave 10, 1
        +spawn E_FIGHTER, 20, P_DIAG_R
        +title_wave 10, 1
        +spawn E_FIGHTER, 20, P_DIAG_R

; our side: a V of five P-38s climbs past from below
        +title_wave 150, 1
        +spawn E_P38, 86, P_RISE
        +title_wave 12, 2
        +spawn E_P38, 66, P_RISE
        +spawn E_P38, 106, P_RISE
        +title_wave 12, 2
        +spawn E_P38, 46, P_RISE
        +spawn E_P38, 126, P_RISE

; aces: a fast V of five dives through
        +title_wave 160, 1
        +spawn E_ACE, 86, P_DIVE_FAST
        +title_wave 16, 2
        +spawn E_ACE, 66, P_DIVE_FAST
        +spawn E_ACE, 106, P_DIVE_FAST
        +title_wave 16, 2
        +spawn E_ACE, 46, P_DIVE_FAST
        +spawn E_ACE, 126, P_DIVE_FAST

; two strings loop, one each way
        +title_wave 140, 1
        +spawn E_FIGHTER, 100, P_LOOP_L
        +title_wave 8, 1
        +spawn E_FIGHTER, 100, P_LOOP_L
        +title_wave 8, 1
        +spawn E_FIGHTER, 100, P_LOOP_L
        +title_wave 20, 1
        +spawn E_FIGHTER, 70, P_LOOP_R
        +title_wave 8, 1
        +spawn E_FIGHTER, 70, P_LOOP_R
        +title_wave 8, 1
        +spawn E_FIGHTER, 70, P_LOOP_R

; crossfire: strings from both sides
        +title_wave 220, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +title_wave 6, 1
        +spawn E_RAIDER, 171, P_CROSS_L
        +title_wave 6, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +title_wave 6, 1
        +spawn E_RAIDER, 171, P_CROSS_L
        +title_wave 6, 1
        +spawn E_RAIDER, 0, P_CROSS_R
        +title_wave 6, 1
        +spawn E_RAIDER, 171, P_CROSS_L

; two leaders split away, each with a wingman
        +title_wave 150, 2
        +spawn E_LEADER, 120, P_SWOOP_L
        +spawn E_LEADER, 40, P_SWOOP_R
        +title_wave 8, 2
        +spawn E_FIGHTER, 140, P_SWOOP_L
        +spawn E_FIGHTER, 20, P_SWOOP_R

; dive bombers: a V
        +title_wave 160, 1
        +spawn E_DIVER, 86, P_DIVEBOMB
        +title_wave 12, 2
        +spawn E_DIVER, 56, P_DIVEBOMB
        +spawn E_DIVER, 116, P_DIVEBOMB

; a zigzag squad of five raiders
        +title_wave 150, 1
        +spawn E_RAIDER, 30, P_ZIGZAG
        +title_wave 6, 1
        +spawn E_RAIDER, 58, P_ZIGZAG
        +title_wave 6, 1
        +spawn E_RAIDER, 86, P_ZIGZAG
        +title_wave 6, 1
        +spawn E_RAIDER, 114, P_ZIGZAG
        +title_wave 6, 1
        +spawn E_RAIDER, 142, P_ZIGZAG

        +title_shows_end
