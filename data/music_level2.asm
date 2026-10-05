; =============================================================================
; data/music_level2.asm - level 2 song "Jungle Coast" (original composition)
; =============================================================================
;
; A syncopated A-minor groove, 16 bars at 125 BPM, ~31 s loop.
;   voice 1  flute  triangle lead, pentatonic with a harmonic-minor G#
;   voice 2  bass   pulse, a 3-3-2 (tresillo) rhythm: root, root, octave,
;                   root, fifth, octave
;   voice 3  drums  kick, hi-hat and two tuned toms (triangle + pitch drop)
; Form: A (bars 1-8)  Am Am F G  Am Am Dm E
;       B (bars 9-16) F  G  Am Am F  G  E  E
; =============================================================================

        +tempo 6                ; 16th = 6 frames -> 125 BPM

; ---- VOICE 1: flute lead ----
jpat_lead_a
        +pat_start
        +ins INS_FLUTE
        ; bar 1 (Am)
        +n "E-5", L8
        +n "A-5", L8
        +n "G-5", L8
        +n "E-5", L8
        +n "D-5", L4
        +n "E-5", L4
        +bar
        ; bar 2 (Am)
        +n "C-5", L8
        +n "D-5", L8
        +n "E-5", L4
        +n "A-4", L2
        +bar
        ; bar 3 (F)
        +n "C-5", L8
        +n "F-5", L8
        +n "E-5", L8
        +n "C-5", L8
        +n "A-4", L4
        +n "C-5", L4
        +bar
        ; bar 4 (G)
        +n "D-5", L4D
        +n "E-5", L8
        +n "G-5", L2
        +bar
        ; bar 5 (Am)
        +n "E-5", L8
        +n "A-5", L8
        +n "G-5", L8
        +n "E-5", L8
        +n "A-5", L4
        +n "C-6", L4
        +bar
        ; bar 6 (Am)
        +n "B-5", L8
        +n "A-5", L8
        +n "G-5", L8
        +n "E-5", L8
        +n "A-5", L2
        +bar
        ; bar 7 (Dm)
        +n "F-5", L8
        +n "E-5", L8
        +n "D-5", L8
        +n "F-5", L8
        +n "A-5", L4
        +n "F-5", L4
        +bar
        ; bar 8 (E)
        +n "G#5", L4D
        +n "F-5", L8
        +n "E-5", L2
        +bar
        +pat_end
JPAT_LEAD_A_TICKS = PAT_TICKS

jpat_lead_b
        +pat_start
        +ins INS_FLUTE
        ; bar 9 (F)
        +n "A-5", L4
        +n "C-6", L4
        +n "A-5", L8
        +n "G-5", L8
        +n "F-5", L4
        +bar
        ; bar 10 (G)
        +n "G-5", L4D
        +n "D-5", L8
        +n "G-5", L2
        +bar
        ; bar 11 (Am)
        +n "E-5", L8
        +n "D-5", L8
        +n "C-5", L8
        +n "D-5", L8
        +n "E-5", L4
        +n "A-5", L4
        +bar
        ; bar 12 (Am)
        +n "G-5", L8
        +n "E-5", L8
        +n "D-5", L8
        +n "C-5", L8
        +n "A-4", L2
        +bar
        ; bar 13 (F)
        +n "F-5", L8
        +n "A-5", L8
        +n "C-6", L8
        +n "A-5", L8
        +n "D-6", L4
        +n "C-6", L4
        +bar
        ; bar 14 (G)
        +n "B-5", L4D
        +n "A-5", L8
        +n "G-5", L2
        +bar
        ; bar 15 (E)
        +n "G#5", L8
        +n "B-5", L8
        +n "E-6", L4
        +n "D-6", L8
        +n "B-5", L8
        +n "G#5", L4
        +bar
        ; bar 16 (E)
        +n "E-5", L2
        +r L4
        +n "E-4", L4
        +bar
        +pat_end
JPAT_LEAD_B_TICKS = PAT_TICKS

; ---- VOICE 2: bass, one bar per chord (3-3-2 rhythm) ----
jpat_bass_am                  ; Am
        +pat_start
        +ins INS_BASS
        +n "A-2", L8D
        +n "A-2", L8D
        +n "A-3", L8
        +n "A-2", L8D
        +n "E-3", L8D
        +n "A-3", L8
        +pat_end
JPAT_BASS_AM_TICKS = PAT_TICKS

jpat_bass_f                  ; F
        +pat_start
        +ins INS_BASS
        +n "F-2", L8D
        +n "F-2", L8D
        +n "F-3", L8
        +n "F-2", L8D
        +n "C-3", L8D
        +n "F-3", L8
        +pat_end
JPAT_BASS_F_TICKS = PAT_TICKS

jpat_bass_g                  ; G
        +pat_start
        +ins INS_BASS
        +n "G-2", L8D
        +n "G-2", L8D
        +n "G-3", L8
        +n "G-2", L8D
        +n "D-3", L8D
        +n "G-3", L8
        +pat_end
JPAT_BASS_G_TICKS = PAT_TICKS

jpat_bass_dm                  ; Dm
        +pat_start
        +ins INS_BASS
        +n "D-2", L8D
        +n "D-2", L8D
        +n "D-3", L8
        +n "D-2", L8D
        +n "A-2", L8D
        +n "D-3", L8
        +pat_end
JPAT_BASS_DM_TICKS = PAT_TICKS

jpat_bass_e                  ; E
        +pat_start
        +ins INS_BASS
        +n "E-2", L8D
        +n "E-2", L8D
        +n "E-3", L8
        +n "E-2", L8D
        +n "B-2", L8D
        +n "E-3", L8
        +pat_end
JPAT_BASS_E_TICKS = PAT_TICKS

; ---- VOICE 3: drums (eighths). K kick, H hat, T high tom, t low tom ----
jpat_drums                   ; K H T H K t T H
        +pat_start
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_TOM
        +n "A-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_TOM
        +n "E-3", L8
        +ins INS_TOM
        +n "A-3", L8
        +ins INS_HAT
        +n "A#7", L8
        +pat_end
JPAT_DRUMS_TICKS = PAT_TICKS

jpat_drums_fill                   ; T T t t K T t K (end of a section)
        +pat_start
        +ins INS_TOM
        +n "A-3", L8
        +ins INS_TOM
        +n "A-3", L8
        +ins INS_TOM
        +n "E-3", L8
        +ins INS_TOM
        +n "E-3", L8
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_TOM
        +n "A-3", L8
        +ins INS_TOM
        +n "E-3", L8
        +ins INS_KICK
        +n "D-3", L8
        +pat_end
JPAT_DRUMS_FILL_TICKS = PAT_TICKS

; ---- order lists ----
jorder_v1
        +ord_start
        +ord jpat_lead_a, JPAT_LEAD_A_TICKS
        +ord jpat_lead_b, JPAT_LEAD_B_TICKS
        +ord_loop
JV1_TICKS = ORD_TICKS

jorder_v2
        +ord_start
        +ord jpat_bass_am, JPAT_BASS_AM_TICKS
        +ord jpat_bass_am, JPAT_BASS_AM_TICKS
        +ord jpat_bass_f, JPAT_BASS_F_TICKS
        +ord jpat_bass_g, JPAT_BASS_G_TICKS
        +ord jpat_bass_am, JPAT_BASS_AM_TICKS
        +ord jpat_bass_am, JPAT_BASS_AM_TICKS
        +ord jpat_bass_dm, JPAT_BASS_DM_TICKS
        +ord jpat_bass_e, JPAT_BASS_E_TICKS
        ; B section
        +ord jpat_bass_f, JPAT_BASS_F_TICKS
        +ord jpat_bass_g, JPAT_BASS_G_TICKS
        +ord jpat_bass_am, JPAT_BASS_AM_TICKS
        +ord jpat_bass_am, JPAT_BASS_AM_TICKS
        +ord jpat_bass_f, JPAT_BASS_F_TICKS
        +ord jpat_bass_g, JPAT_BASS_G_TICKS
        +ord jpat_bass_e, JPAT_BASS_E_TICKS
        +ord jpat_bass_e, JPAT_BASS_E_TICKS
        +ord_loop
JV2_TICKS = ORD_TICKS

jorder_v3
        +ord_start
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums_fill, JPAT_DRUMS_FILL_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums, JPAT_DRUMS_TICKS
        +ord jpat_drums_fill, JPAT_DRUMS_FILL_TICKS
        +ord_loop
JV3_TICKS = ORD_TICKS

!if (JV1_TICKS != JV2_TICKS) | (JV2_TICKS != JV3_TICKS) {
        !error "level 2 song: the three voices have different loop lengths"
}
