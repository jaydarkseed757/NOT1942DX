; =============================================================================
; data/music.asm - instruments + the in-game song (original composition)
; Played by src/music.asm, one tick per frame (50 Hz PAL). The title song is
; in data/music_title.asm, the song table in data/songs.asm.
; =============================================================================
;
; "Pacific Patrol": a driving minor-key march, 16 bars at 125 BPM, ~31 s loop.
;   voice 1  lead   pulse wave with a slow pulse-width sweep
;   voice 2  bass   pulse wave, octave-bouncing eighth notes
;   voice 3  drums  kick (triangle + pitch drop), snare and hi-hat (noise)
; Form: A (bars 1-8)  Dm Dm Bb C  Dm Dm Bb A
;       B (bars 9-16) Gm Gm Dm Dm Bb C  Dm A
;
; HOW TO WRITE MUSIC HERE
;   Notes are tracker-style: "C-4", "F#3" (sharps only: write Bb as "A#").
;   Lengths are in frames; use the L* lengths set by +tempo at the song start.
;   Each voice's ORDER LIST plays patterns in turn and loops at +ord_loop.
;   The assembler checks: valid note names, every +bar line lands on a whole
;   bar, and all three voices loop after the same number of frames (so they
;   can never drift apart).
; =============================================================================


; ---- instruments (one column each) ----
;  wave: $11 triangle, $21 sawtooth, $41 pulse, $81 noise (bit 0 = gate,
;        set by the player).  AD/SR: SID envelope nibbles.
;  pw:   pulse width (12-bit), pwadd: added every frame (signed, wraps).
;  slide: added to the frequency high byte every frame (signed).
INS_LEAD   = 0                  ; game song
INS_BASS   = 1
INS_KICK   = 2
INS_SNARE  = 3
INS_HAT    = 4
INS_BRASS  = 5                  ; title song (and boss theme)
INS_ARP    = 6
INS_TBASS  = 7
INS_FLUTE  = 8                  ; level 2 song
INS_TOM    = 9
INS_COUNT  = 10
;                lead  bass  kick  snare hat   brass arp   tbass flute tom
ins_wave  !byte  $40,  $40,  $10,  $80,  $80,  $20,  $40,  $10,  $10,  $10
ins_ad    !byte  $0a,  $08,  $06,  $05,  $01,  $28,  $03,  $08,  $26,  $07
ins_sr    !byte  $a6,  $60,  $00,  $00,  $00,  $a8,  $00,  $c8,  $a6,  $00
ins_pwlo  !byte  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00,  $00
ins_pwhi  !byte  $03,  $04,  $08,  $08,  $08,  $08,  $06,  $08,  $08,  $08
ins_pwadd !byte  6,    0,    0,    0,    0,    0,    3,    0,    0,    0
ins_slide !byte  0,    0,    -2 & $ff, 0, 0,   0,    0,    0,    0,    -1 & $ff

; =============================================================================
; GAME SONG
; =============================================================================
        +tempo 6                ; 16th = 6 frames -> 125 BPM

; ---- VOICE 1: lead ----
pat_lead_a
        +pat_start
        +ins INS_LEAD
        ; bar 1 (Dm)
        +n "A-4", L8
        +n "D-5", L8
        +n "D-5", L8
        +n "E-5", L8
        +n "F-5", L4
        +n "E-5", L8
        +n "D-5", L8
        +bar
        ; bar 2 (Dm)
        +n "C-5", L8
        +n "D-5", L8
        +n "A-4", L4
        +n "A-4", L2
        +bar
        ; bar 3 (Bb)
        +n "A#4", L8
        +n "D-5", L8
        +n "F-5", L8
        +n "D-5", L8
        +n "A#4", L4
        +n "A-4", L8
        +n "A#4", L8
        +bar
        ; bar 4 (C)
        +n "C-5", L4D
        +n "E-5", L8
        +n "G-5", L4
        +n "E-5", L4
        +bar
        ; bar 5 (Dm)
        +n "A-4", L8
        +n "D-5", L8
        +n "D-5", L8
        +n "E-5", L8
        +n "F-5", L8
        +n "G-5", L8
        +n "A-5", L4
        +bar
        ; bar 6 (Dm)
        +n "G-5", L8
        +n "F-5", L8
        +n "E-5", L8
        +n "D-5", L8
        +n "F-5", L4
        +n "D-5", L4
        +bar
        ; bar 7 (Bb)
        +n "D-5", L8
        +n "C-5", L8
        +n "A#4", L8
        +n "A-4", L8
        +n "A#4", L4
        +n "D-5", L4
        +bar
        ; bar 8 (A)
        +n "C#5", L4D
        +n "E-5", L8
        +n "A-4", L2
        +bar
        +pat_end
PAT_LEAD_A_TICKS = PAT_TICKS

pat_lead_b
        +pat_start
        +ins INS_LEAD
        ; bar 9 (Gm)
        +n "G-4", L8
        +n "A#4", L8
        +n "D-5", L8
        +n "G-5", L8
        +n "F-5", L4
        +n "D-5", L4
        +bar
        ; bar 10 (Gm)
        +n "D-5", L8
        +n "C-5", L8
        +n "A#4", L4
        +n "G-4", L2
        +bar
        ; bar 11 (Dm)
        +n "F-4", L8
        +n "A-4", L8
        +n "D-5", L8
        +n "F-5", L8
        +n "A-5", L4
        +n "F-5", L4
        +bar
        ; bar 12 (Dm)
        +n "E-5", L8
        +n "F-5", L8
        +n "E-5", L8
        +n "D-5", L8
        +n "A-4", L2
        +bar
        ; bar 13 (Bb)
        +n "F-5", L4
        +n "D-5", L8
        +n "F-5", L8
        +n "A#5", L4
        +n "A-5", L4
        +bar
        ; bar 14 (C)
        +n "G-5", L4
        +n "E-5", L8
        +n "G-5", L8
        +n "C-6", L4
        +n "A#5", L8
        +n "G-5", L8
        +bar
        ; bar 15 (Dm)
        +n "A-5", L4D
        +n "F-5", L8
        +n "D-5", L4
        +n "F-5", L4
        +bar
        ; bar 16 (A)
        +n "E-5", L8
        +n "C#5", L8
        +n "A-4", L8
        +n "C#5", L8
        +n "E-5", L4
        +n "A-5", L4
        +bar
        +pat_end
PAT_LEAD_B_TICKS = PAT_TICKS

; ---- VOICE 2: bass (one bar per pattern) ----
pat_bass_d                    ; one bar of Dm
        +pat_start
        +ins INS_BASS
        +n "D-2", L8
        +n "D-2", L8
        +n "D-3", L8
        +n "D-2", L8
        +n "D-2", L8
        +n "D-2", L8
        +n "D-3", L8
        +n "D-3", L8
        +pat_end
PAT_BASS_D_TICKS = PAT_TICKS

pat_bass_as                    ; one bar of Bb
        +pat_start
        +ins INS_BASS
        +n "A#1", L8
        +n "A#1", L8
        +n "A#2", L8
        +n "A#1", L8
        +n "A#1", L8
        +n "A#1", L8
        +n "A#2", L8
        +n "A#2", L8
        +pat_end
PAT_BASS_AS_TICKS = PAT_TICKS

pat_bass_c                    ; one bar of C
        +pat_start
        +ins INS_BASS
        +n "C-2", L8
        +n "C-2", L8
        +n "C-3", L8
        +n "C-2", L8
        +n "C-2", L8
        +n "C-2", L8
        +n "C-3", L8
        +n "C-3", L8
        +pat_end
PAT_BASS_C_TICKS = PAT_TICKS

pat_bass_a                    ; one bar of A
        +pat_start
        +ins INS_BASS
        +n "A-1", L8
        +n "A-1", L8
        +n "A-2", L8
        +n "A-1", L8
        +n "A-1", L8
        +n "A-1", L8
        +n "A-2", L8
        +n "A-2", L8
        +pat_end
PAT_BASS_A_TICKS = PAT_TICKS

pat_bass_g                    ; one bar of Gm
        +pat_start
        +ins INS_BASS
        +n "G-1", L8
        +n "G-1", L8
        +n "G-2", L8
        +n "G-1", L8
        +n "G-1", L8
        +n "G-1", L8
        +n "G-2", L8
        +n "G-2", L8
        +pat_end
PAT_BASS_G_TICKS = PAT_TICKS

; ---- VOICE 3: drums (one bar per pattern). K = kick, S = snare, H = hi-hat ----
pat_drums                   ; K H S H K H S H
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
        +ins INS_HAT
        +n "A#7", L8
        +ins INS_SNARE
        +n "C-6", L8
        +ins INS_HAT
        +n "A#7", L8
        +pat_end
PAT_DRUMS_TICKS = PAT_TICKS

pat_drums_fill                   ; K H S H K S S S (end of a section)
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
        +ins INS_SNARE
        +n "C-6", L8
        +pat_end
PAT_DRUMS_FILL_TICKS = PAT_TICKS

; ---- order lists ----
order_v1
        +ord_start
        +ord pat_lead_a, PAT_LEAD_A_TICKS
        +ord pat_lead_b, PAT_LEAD_B_TICKS
        +ord_loop
V1_TICKS = ORD_TICKS

order_v2
        +ord_start
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_as, PAT_BASS_AS_TICKS
        +ord pat_bass_c, PAT_BASS_C_TICKS
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_as, PAT_BASS_AS_TICKS
        +ord pat_bass_a, PAT_BASS_A_TICKS
        ; B section
        +ord pat_bass_g, PAT_BASS_G_TICKS
        +ord pat_bass_g, PAT_BASS_G_TICKS
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_as, PAT_BASS_AS_TICKS
        +ord pat_bass_c, PAT_BASS_C_TICKS
        +ord pat_bass_d, PAT_BASS_D_TICKS
        +ord pat_bass_a, PAT_BASS_A_TICKS
        +ord_loop
V2_TICKS = ORD_TICKS

order_v3
        +ord_start
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums_fill, PAT_DRUMS_FILL_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums, PAT_DRUMS_TICKS
        +ord pat_drums_fill, PAT_DRUMS_FILL_TICKS
        +ord_loop
V3_TICKS = ORD_TICKS

!if (V1_TICKS != V2_TICKS) | (V2_TICKS != V3_TICKS) {
        !error "game song: the three voices have different loop lengths"
}
