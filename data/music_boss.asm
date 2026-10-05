; =============================================================================
; data/music_boss.asm - boss fight theme, shared by all four bosses
; (original composition)
; =============================================================================
;
; "Iron Wings": a tense, fast E-minor piece, 8 bars at 150 BPM, ~13 s loop.
;   voice 1  brass  sawtooth lead: chromatic motif, climbing each phrase
;   voice 2  bass   pulse, relentless 16th-note ostinato
;   voice 3  drums  driving eighths with a double kick
; Chords: Em Em C B | Em Em F B  (the F is a jolt: the flat second)
; =============================================================================

        +tempo 5                ; 16th = 5 frames -> 20 per beat = 150 BPM

; ---- VOICE 1: lead ----
bpat_lead
        +pat_start
        +ins INS_BRASS
        ; bar 1 (Em)
        +n "B-4", L4
        +n "C-5", L4
        +n "B-4", L4
        +n "A#4", L4
        +bar
        ; bar 2 (Em)
        +n "B-4", L4D
        +n "G-4", L8
        +n "E-4", L2
        +bar
        ; bar 3 (C)
        +n "C-5", L4
        +n "D-5", L4
        +n "E-5", L4
        +n "G-5", L4
        +bar
        ; bar 4 (B)
        +n "F#5", L2
        +n "D#5", L4
        +n "B-4", L4
        +bar
        ; bar 5 (Em)
        +n "E-5", L4
        +n "D#5", L4
        +n "E-5", L4
        +n "G-5", L4
        +bar
        ; bar 6 (Em)
        +n "F#5", L4D
        +n "E-5", L8
        +n "B-4", L2
        +bar
        ; bar 7 (F)
        +n "A-5", L4
        +n "G-5", L4
        +n "F-5", L4
        +n "C-5", L4
        +bar
        ; bar 8 (B)
        +n "D#5", L4
        +n "F#5", L4
        +n "B-5", L2
        +bar
        +pat_end
BPAT_LEAD_TICKS = PAT_TICKS

; ---- VOICE 2: bass, one bar of 16ths per chord (R = root, O = octave) ----
bpat_bass_em                  ; Em
        +pat_start
        +ins INS_BASS
        +n "E-2", L16
        +n "E-2", L16
        +n "E-3", L16
        +n "E-2", L16
        +n "E-2", L16
        +n "E-2", L16
        +n "E-3", L16
        +n "E-2", L16
        +n "E-2", L16
        +n "E-2", L16
        +n "E-3", L16
        +n "E-2", L16
        +n "E-2", L16
        +n "E-3", L16
        +n "E-2", L16
        +n "E-3", L16
        +pat_end
BPAT_BASS_EM_TICKS = PAT_TICKS

bpat_bass_c                  ; C
        +pat_start
        +ins INS_BASS
        +n "C-2", L16
        +n "C-2", L16
        +n "C-3", L16
        +n "C-2", L16
        +n "C-2", L16
        +n "C-2", L16
        +n "C-3", L16
        +n "C-2", L16
        +n "C-2", L16
        +n "C-2", L16
        +n "C-3", L16
        +n "C-2", L16
        +n "C-2", L16
        +n "C-3", L16
        +n "C-2", L16
        +n "C-3", L16
        +pat_end
BPAT_BASS_C_TICKS = PAT_TICKS

bpat_bass_b                  ; B
        +pat_start
        +ins INS_BASS
        +n "B-1", L16
        +n "B-1", L16
        +n "B-2", L16
        +n "B-1", L16
        +n "B-1", L16
        +n "B-1", L16
        +n "B-2", L16
        +n "B-1", L16
        +n "B-1", L16
        +n "B-1", L16
        +n "B-2", L16
        +n "B-1", L16
        +n "B-1", L16
        +n "B-2", L16
        +n "B-1", L16
        +n "B-2", L16
        +pat_end
BPAT_BASS_B_TICKS = PAT_TICKS

bpat_bass_f                  ; F
        +pat_start
        +ins INS_BASS
        +n "F-2", L16
        +n "F-2", L16
        +n "F-3", L16
        +n "F-2", L16
        +n "F-2", L16
        +n "F-2", L16
        +n "F-3", L16
        +n "F-2", L16
        +n "F-2", L16
        +n "F-2", L16
        +n "F-3", L16
        +n "F-2", L16
        +n "F-2", L16
        +n "F-3", L16
        +n "F-2", L16
        +n "F-3", L16
        +pat_end
BPAT_BASS_F_TICKS = PAT_TICKS

; ---- VOICE 3: drums (eighths) ----
bpat_drums                   ; K H S H K K S H
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
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +pat_end
BPAT_DRUMS_TICKS = PAT_TICKS

bpat_drums_fill                   ; K S K S K S S S (end of the loop)
        +pat_start
        +ins INS_KICK
        +n "D-3", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_KICK
        +n "D-3", L8
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
BPAT_DRUMS_FILL_TICKS = PAT_TICKS

; ---- order lists ----
border_v1
        +ord_start
        +ord bpat_lead, BPAT_LEAD_TICKS
        +ord_loop
BV1_TICKS = ORD_TICKS

border_v2
        +ord_start
        +ord bpat_bass_em, BPAT_BASS_EM_TICKS
        +ord bpat_bass_em, BPAT_BASS_EM_TICKS
        +ord bpat_bass_c, BPAT_BASS_C_TICKS
        +ord bpat_bass_b, BPAT_BASS_B_TICKS
        +ord bpat_bass_em, BPAT_BASS_EM_TICKS
        +ord bpat_bass_em, BPAT_BASS_EM_TICKS
        +ord bpat_bass_f, BPAT_BASS_F_TICKS
        +ord bpat_bass_b, BPAT_BASS_B_TICKS
        +ord_loop
BV2_TICKS = ORD_TICKS

border_v3
        +ord_start
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums, BPAT_DRUMS_TICKS
        +ord bpat_drums_fill, BPAT_DRUMS_FILL_TICKS
        +ord_loop
BV3_TICKS = ORD_TICKS

!if (BV1_TICKS != BV2_TICKS) | (BV2_TICKS != BV3_TICKS) {
        !error "boss song: the three voices have different loop lengths"
}
