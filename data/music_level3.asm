; =============================================================================
; data/music_level3.asm - level 3 song "Sunset Strait" (original composition)
; =============================================================================
;
; A slower, wistful G-minor piece, 16 bars at ~107 BPM, ~36 s loop.
;   voice 1  lead   pulse with the slow pulse-width sweep
;   voice 2  bass   triangle, a dotted rhythm: root, root, fifth, octave
;   voice 3  drums  half-time: kick on 1, snare on 3, hi-hat eighths
; Form: A (bars 1-8)  Gm Eb Bb F  Gm Eb Cm D
;       B (bars 9-16) Eb F  Gm Gm Eb F  D  D
; =============================================================================

        +tempo 7                ; 16th = 7 frames -> ~107 BPM

; ---- VOICE 1: lead ----
spat_lead_a
        +pat_start
        +ins INS_LEAD
        ; bar 1 (Gm)
        +n "D-5", L4D
        +n "C-5", L8
        +n "A#4", L4
        +n "G-4", L4
        +bar
        ; bar 2 (Eb)
        +n "G-4", L4
        +n "A#4", L4
        +n "D#5", L2
        +bar
        ; bar 3 (Bb)
        +n "D-5", L4D
        +n "F-5", L8
        +n "D-5", L4
        +n "A#4", L4
        +bar
        ; bar 4 (F)
        +n "C-5", L2D
        +n "A-4", L4
        +bar
        ; bar 5 (Gm)
        +n "D-5", L4D
        +n "C-5", L8
        +n "A#4", L4
        +n "D-5", L4
        +bar
        ; bar 6 (Eb)
        +n "G-5", L4
        +n "F-5", L4
        +n "D#5", L4
        +n "D-5", L4
        +bar
        ; bar 7 (Cm)
        +n "C-5", L4D
        +n "D-5", L8
        +n "D#5", L4
        +n "G-5", L4
        +bar
        ; bar 8 (D)
        +n "F#5", L2D
        +n "D-5", L4
        +bar
        +pat_end
SPAT_LEAD_A_TICKS = PAT_TICKS

spat_lead_b
        +pat_start
        +ins INS_LEAD
        ; bar 9 (Eb)
        +n "G-5", L4D
        +n "F-5", L8
        +n "D#5", L2
        +bar
        ; bar 10 (F)
        +n "F-5", L4D
        +n "D#5", L8
        +n "D-5", L2
        +bar
        ; bar 11 (Gm)
        +n "D-5", L4
        +n "G-5", L4
        +n "A#5", L4
        +n "A-5", L4
        +bar
        ; bar 12 (Gm)
        +n "G-5", L1
        +bar
        ; bar 13 (Eb)
        +n "A#5", L4D
        +n "G-5", L8
        +n "D#5", L4
        +n "G-5", L4
        +bar
        ; bar 14 (F)
        +n "A-5", L4D
        +n "F-5", L8
        +n "C-5", L4
        +n "F-5", L4
        +bar
        ; bar 15 (D)
        +n "F#5", L4
        +n "A-5", L4
        +n "D-6", L4
        +n "C-6", L4
        +bar
        ; bar 16 (D)
        +n "A#5", L4
        +n "A-5", L4
        +n "F#5", L2
        +bar
        +pat_end
SPAT_LEAD_B_TICKS = PAT_TICKS

; ---- VOICE 2: triangle bass, one bar per chord ----
spat_bass_gm                  ; Gm
        +pat_start
        +ins INS_TBASS
        +n "G-2", L4D
        +n "G-2", L8
        +n "D-3", L4
        +n "G-3", L4
        +pat_end
SPAT_BASS_GM_TICKS = PAT_TICKS

spat_bass_eb                  ; Eb
        +pat_start
        +ins INS_TBASS
        +n "D#2", L4D
        +n "D#2", L8
        +n "A#2", L4
        +n "D#3", L4
        +pat_end
SPAT_BASS_EB_TICKS = PAT_TICKS

spat_bass_bb                  ; Bb
        +pat_start
        +ins INS_TBASS
        +n "A#1", L4D
        +n "A#1", L8
        +n "F-2", L4
        +n "A#2", L4
        +pat_end
SPAT_BASS_BB_TICKS = PAT_TICKS

spat_bass_f                  ; F
        +pat_start
        +ins INS_TBASS
        +n "F-2", L4D
        +n "F-2", L8
        +n "C-3", L4
        +n "F-3", L4
        +pat_end
SPAT_BASS_F_TICKS = PAT_TICKS

spat_bass_cm                  ; Cm
        +pat_start
        +ins INS_TBASS
        +n "C-2", L4D
        +n "C-2", L8
        +n "G-2", L4
        +n "C-3", L4
        +pat_end
SPAT_BASS_CM_TICKS = PAT_TICKS

spat_bass_d                  ; D
        +pat_start
        +ins INS_TBASS
        +n "D-2", L4D
        +n "D-2", L8
        +n "A-2", L4
        +n "D-3", L4
        +pat_end
SPAT_BASS_D_TICKS = PAT_TICKS

; ---- VOICE 3: drums (eighths), half-time ----
spat_drums                   ; K H H H S H K H
        +pat_start
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +pat_end
SPAT_DRUMS_TICKS = PAT_TICKS

spat_drums_fill                   ; K H S H S S S S (end of a section)
        +pat_start
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +pat_end
SPAT_DRUMS_FILL_TICKS = PAT_TICKS

; ---- order lists ----
sorder_v1
        +ord_start
        +ord spat_lead_a, SPAT_LEAD_A_TICKS
        +ord spat_lead_b, SPAT_LEAD_B_TICKS
        +ord_loop
SV1_TICKS = ORD_TICKS

sorder_v2
        +ord_start
        +ord spat_bass_gm, SPAT_BASS_GM_TICKS
        +ord spat_bass_eb, SPAT_BASS_EB_TICKS
        +ord spat_bass_bb, SPAT_BASS_BB_TICKS
        +ord spat_bass_f, SPAT_BASS_F_TICKS
        +ord spat_bass_gm, SPAT_BASS_GM_TICKS
        +ord spat_bass_eb, SPAT_BASS_EB_TICKS
        +ord spat_bass_cm, SPAT_BASS_CM_TICKS
        +ord spat_bass_d, SPAT_BASS_D_TICKS
        ; B section
        +ord spat_bass_eb, SPAT_BASS_EB_TICKS
        +ord spat_bass_f, SPAT_BASS_F_TICKS
        +ord spat_bass_gm, SPAT_BASS_GM_TICKS
        +ord spat_bass_gm, SPAT_BASS_GM_TICKS
        +ord spat_bass_eb, SPAT_BASS_EB_TICKS
        +ord spat_bass_f, SPAT_BASS_F_TICKS
        +ord spat_bass_d, SPAT_BASS_D_TICKS
        +ord spat_bass_d, SPAT_BASS_D_TICKS
        +ord_loop
SV2_TICKS = ORD_TICKS

sorder_v3
        +ord_start
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums_fill, SPAT_DRUMS_FILL_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums, SPAT_DRUMS_TICKS
        +ord spat_drums_fill, SPAT_DRUMS_FILL_TICKS
        +ord_loop
SV3_TICKS = ORD_TICKS

!if (SV1_TICKS != SV2_TICKS) | (SV2_TICKS != SV3_TICKS) {
        !error "level 3 song: the three voices have different loop lengths"
}
