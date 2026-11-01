; =============================================================================
; data/music_clear.asm - the level-clear fanfare (original composition)
; =============================================================================
;
; "Flight Deck": a bright D-major fanfare, 4 bars at 187 BPM (~5 s), played
; once when the ship touches down on the carrier after a boss
; (src/landing.asm). Then the song rests until the next level's song starts
; (level_intro_enter stops it; after level 4 the ending starts its own).
;   voice 1  brass  sawtooth: a rising call, answered, then up to the top D
;   voice 2  bass   pulse, octave-bouncing eighths
;   voice 3  drums  kick, snare and hat; a snare roll into the last chord
; Chords: D | G A | D A | D
; Assembled after the code (src/main.asm): the turbo build's DATA3 is full,
; and its DATA2 must leave room for the cartridge's page copier.
; =============================================================================

        +tempo 4                ; 16th = 4 frames -> 16 per beat = 187 BPM

; ---- VOICE 1: lead ----
cpat_lead
        +pat_start
        +ins INS_BRASS
        ; bar 1 (D)
        +n "A-4", L8
        +n "D-5", L8
        +n "F#5", L8
        +n "A-5", L8
        +n "A-5", L4
        +n "F#5", L8
        +n "A-5", L8
        +bar
        ; bar 2 (G, A)
        +n "B-5", L4
        +n "A-5", L8
        +n "G-5", L8
        +n "F#5", L8
        +n "E-5", L8
        +n "G-5", L8
        +n "E-5", L8
        +bar
        ; bar 3 (D, A)
        +n "F#5", L8
        +n "A-5", L8
        +n "D-6", L4
        +n "C#6", L8
        +n "B-5", L8
        +n "C#6", L4
        +bar
        ; bar 4 (D): the top D, held
        +n "D-6", L2D
        +r L4
        +pat_end
CPAT_LEAD_TICKS = PAT_TICKS

; ---- VOICE 2: bass ----
cpat_bass
        +pat_start
        +ins INS_BASS
        ; bar 1 (D)
!for .i, 1, 4 {
        +n "D-3", L8
        +n "D-4", L8
}
        +bar
        ; bar 2 (G, A)
!for .i, 1, 2 {
        +n "G-2", L8
        +n "G-3", L8
}
!for .i, 1, 2 {
        +n "A-2", L8
        +n "A-3", L8
}
        +bar
        ; bar 3 (D, A)
!for .i, 1, 2 {
        +n "D-3", L8
        +n "D-4", L8
}
!for .i, 1, 2 {
        +n "A-2", L8
        +n "A-3", L8
}
        +bar
        ; bar 4 (D)
        +n "D-3", L2D
        +r L4
        +pat_end
CPAT_BASS_TICKS = PAT_TICKS

; ---- VOICE 3: drums ----
cpat_drums                      ; bars 1-3 (played three times): K H S H K K S H
        +pat_start
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_KICK
        +n "D-3", L8
        +n "D-3", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +pat_end
CPAT_DRUMS_TICKS = PAT_TICKS

cpat_roll                       ; bar 4: a snare roll into the last chord
        +pat_start
        +ins INS_SNARE
        +n "C-6", L16
        +n "C-6", L16
        +n "C-6", L16
        +n "C-6", L16
        +ins INS_KICK
        +n "D-3", L4
        +r L2
        +pat_end
CPAT_ROLL_TICKS = PAT_TICKS

; ---- after it: rest until the next song (all three voices) ----
cpat_rest
        +pat_start
        +r L1
        +r L1
        +pat_end
CPAT_REST_TICKS = PAT_TICKS

; ---- order lists ----
corder_v1
        +ord_start
        +ord cpat_lead, CPAT_LEAD_TICKS
        +ord cpat_rest, CPAT_REST_TICKS
        +ord_loop
CV1_TICKS = ORD_TICKS

corder_v2
        +ord_start
        +ord cpat_bass, CPAT_BASS_TICKS
        +ord cpat_rest, CPAT_REST_TICKS
        +ord_loop
CV2_TICKS = ORD_TICKS

corder_v3
        +ord_start
        +ord cpat_drums, CPAT_DRUMS_TICKS
        +ord cpat_drums, CPAT_DRUMS_TICKS
        +ord cpat_drums, CPAT_DRUMS_TICKS
        +ord cpat_roll, CPAT_ROLL_TICKS
        +ord cpat_rest, CPAT_REST_TICKS
        +ord_loop
CV3_TICKS = ORD_TICKS

!if (CV1_TICKS != CV2_TICKS) | (CV2_TICKS != CV3_TICKS) {
        !error "music_clear: the three voices must loop together"
}
CLEAR_TUNE_FRAMES = CPAT_LEAD_TICKS     ; the fanfare itself (landing.asm)
!set clear_ride = CLEAR_TUNE_FRAMES - TAXI_FRAMES + 25 ; (landing.asm's RIDE_FRAMES)
!if clear_ride > 255 | clear_ride < 50 { !error "music_clear: the landing's ride (RIDE_FRAMES, from this fanfare's length) must be 50-255 frames (lvl_timer)" }
