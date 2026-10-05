; =============================================================================
; data/music_level4.asm - level 4 song "Enemy Fleet" (original composition)
; =============================================================================
;
; A martial C-minor piece, 16 bars at 125 BPM, ~31 s loop.
;   voice 1  brass  sawtooth lead, climbing to a high G in the last phrase
;   voice 2  bass   pulse, pumping root-octave eighths
;   voice 3  drums  a march: kick, hi-hat and double snares
; Form: A (bars 1-8)  Cm Cm Ab Bb  Cm Cm Fm G
;       B (bars 9-16) Ab Bb Cm Cm  Ab Bb G  G
; =============================================================================

        +tempo 6                ; 16th = 6 frames -> 125 BPM

; ---- VOICE 1: brass lead ----
fpat_lead_a
        +pat_start
        +ins INS_BRASS
        ; bar 1 (Cm)
        +n "G-4", L8
        +n "C-5", L8
        +n "D#5", L8
        +n "G-5", L8
        +n "F-5", L4
        +n "D#5", L4
        +bar
        ; bar 2 (Cm)
        +n "D-5", L8
        +n "D#5", L8
        +n "C-5", L4
        +n "G-4", L2
        +bar
        ; bar 3 (Ab)
        +n "G#4", L8
        +n "C-5", L8
        +n "D#5", L8
        +n "G#5", L8
        +n "G-5", L4
        +n "F-5", L4
        +bar
        ; bar 4 (Bb)
        +n "F-5", L4D
        +n "D-5", L8
        +n "A#4", L2
        +bar
        ; bar 5 (Cm)
        +n "G-4", L8
        +n "C-5", L8
        +n "D#5", L8
        +n "G-5", L8
        +n "C-6", L4
        +n "A#5", L4
        +bar
        ; bar 6 (Cm)
        +n "G-5", L8
        +n "F-5", L8
        +n "D#5", L8
        +n "D-5", L8
        +n "C-5", L2
        +bar
        ; bar 7 (Fm)
        +n "F-5", L8
        +n "G#5", L8
        +n "C-6", L8
        +n "G#5", L8
        +n "F-5", L4
        +n "D#5", L4
        +bar
        ; bar 8 (G)
        +n "D-5", L4D
        +n "B-4", L8
        +n "G-4", L2
        +bar
        +pat_end
FPAT_LEAD_A_TICKS = PAT_TICKS

fpat_lead_b
        +pat_start
        +ins INS_BRASS
        ; bar 9 (Ab)
        +n "C-6", L4D
        +n "A#5", L8
        +n "G#5", L4
        +n "G-5", L4
        +bar
        ; bar 10 (Bb)
        +n "F-5", L4D
        +n "G-5", L8
        +n "A#5", L2
        +bar
        ; bar 11 (Cm)
        +n "C-6", L4
        +n "G-5", L4
        +n "D#5", L4
        +n "G-5", L4
        +bar
        ; bar 12 (Cm)
        +n "C-6", L1
        +bar
        ; bar 13 (Ab)
        +n "D#6", L4D
        +n "C-6", L8
        +n "G#5", L4
        +n "C-6", L4
        +bar
        ; bar 14 (Bb)
        +n "D-6", L4D
        +n "A#5", L8
        +n "F-5", L4
        +n "A#5", L4
        +bar
        ; bar 15 (G)
        +n "B-5", L8
        +n "D-6", L8
        +n "G-6", L4
        +n "F-6", L8
        +n "D-6", L8
        +n "B-5", L4
        +bar
        ; bar 16 (G)
        +n "G-5", L4
        +n "B-5", L4
        +n "D-6", L2
        +bar
        +pat_end
FPAT_LEAD_B_TICKS = PAT_TICKS

; ---- VOICE 2: bass, one bar per chord (root/octave eighths) ----
fpat_bass_cm                  ; Cm
        +pat_start
        +ins INS_BASS
        +n "C-2", L8
        +n "C-2", L8
        +n "C-3", L8
        +n "C-2", L8
        +n "C-2", L8
        +n "C-3", L8
        +n "C-2", L8
        +n "C-3", L8
        +pat_end
FPAT_BASS_CM_TICKS = PAT_TICKS

fpat_bass_ab                  ; Ab
        +pat_start
        +ins INS_BASS
        +n "G#1", L8
        +n "G#1", L8
        +n "G#2", L8
        +n "G#1", L8
        +n "G#1", L8
        +n "G#2", L8
        +n "G#1", L8
        +n "G#2", L8
        +pat_end
FPAT_BASS_AB_TICKS = PAT_TICKS

fpat_bass_bb                  ; Bb
        +pat_start
        +ins INS_BASS
        +n "A#1", L8
        +n "A#1", L8
        +n "A#2", L8
        +n "A#1", L8
        +n "A#1", L8
        +n "A#2", L8
        +n "A#1", L8
        +n "A#2", L8
        +pat_end
FPAT_BASS_BB_TICKS = PAT_TICKS

fpat_bass_fm                  ; Fm
        +pat_start
        +ins INS_BASS
        +n "F-2", L8
        +n "F-2", L8
        +n "F-3", L8
        +n "F-2", L8
        +n "F-2", L8
        +n "F-3", L8
        +n "F-2", L8
        +n "F-3", L8
        +pat_end
FPAT_BASS_FM_TICKS = PAT_TICKS

fpat_bass_g                  ; G
        +pat_start
        +ins INS_BASS
        +n "G-2", L8
        +n "G-2", L8
        +n "G-3", L8
        +n "G-2", L8
        +n "G-2", L8
        +n "G-3", L8
        +n "G-2", L8
        +n "G-3", L8
        +pat_end
FPAT_BASS_G_TICKS = PAT_TICKS

; ---- VOICE 3: drums (eighths), a march ----
fpat_drums                   ; K H S H K S S H
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
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +pat_end
FPAT_DRUMS_TICKS = PAT_TICKS

fpat_drums_fill                   ; S K S S K S S S (end of a section)
        +pat_start
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_SNARE
        +n "C-6", L8
        +pat_end
FPAT_DRUMS_FILL_TICKS = PAT_TICKS

; ---- order lists ----
forder_v1
        +ord_start
        +ord fpat_lead_a, FPAT_LEAD_A_TICKS
        +ord fpat_lead_b, FPAT_LEAD_B_TICKS
        +ord_loop
FV1_TICKS = ORD_TICKS

forder_v2
        +ord_start
        +ord fpat_bass_cm, FPAT_BASS_CM_TICKS
        +ord fpat_bass_cm, FPAT_BASS_CM_TICKS
        +ord fpat_bass_ab, FPAT_BASS_AB_TICKS
        +ord fpat_bass_bb, FPAT_BASS_BB_TICKS
        +ord fpat_bass_cm, FPAT_BASS_CM_TICKS
        +ord fpat_bass_cm, FPAT_BASS_CM_TICKS
        +ord fpat_bass_fm, FPAT_BASS_FM_TICKS
        +ord fpat_bass_g, FPAT_BASS_G_TICKS
        ; B section
        +ord fpat_bass_ab, FPAT_BASS_AB_TICKS
        +ord fpat_bass_bb, FPAT_BASS_BB_TICKS
        +ord fpat_bass_cm, FPAT_BASS_CM_TICKS
        +ord fpat_bass_cm, FPAT_BASS_CM_TICKS
        +ord fpat_bass_ab, FPAT_BASS_AB_TICKS
        +ord fpat_bass_bb, FPAT_BASS_BB_TICKS
        +ord fpat_bass_g, FPAT_BASS_G_TICKS
        +ord fpat_bass_g, FPAT_BASS_G_TICKS
        +ord_loop
FV2_TICKS = ORD_TICKS

forder_v3
        +ord_start
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums_fill, FPAT_DRUMS_FILL_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums, FPAT_DRUMS_TICKS
        +ord fpat_drums_fill, FPAT_DRUMS_FILL_TICKS
        +ord_loop
FV3_TICKS = ORD_TICKS

!if (FV1_TICKS != FV2_TICKS) | (FV2_TICKS != FV3_TICKS) {
        !error "level 4 song: the three voices have different loop lengths"
}
