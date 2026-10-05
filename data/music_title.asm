; =============================================================================
; data/music_title.asm - title screen song (original composition)
; =============================================================================
;
; "Wings Over the Pacific": a broad, heroic anthem in F major (the relative
; major of the game song's D minor), 16 bars at ~107 BPM, ~36 s loop.
;   voice 1  brass  sawtooth lead with a slow attack
;   voice 2  arp    pulse arpeggios, up and down the chord in 16ths
;   voice 3  bass   triangle: root, root, fifth
; No drums, so it sits apart from the in-game march.
; Form: A (bars 1-8)  F C Dm Bb  F C Bb C
;       B (bars 9-16) Dm Bb F C  Dm Bb C C
; =============================================================================

        +tempo 7                ; 16th = 7 frames -> 28 per beat = ~107 BPM

; ---- VOICE 1: brass lead ----
tpat_lead_a
        +pat_start
        +ins INS_BRASS
        ; bar 1 (F)
        +n "C-5", L4D
        +n "F-5", L8
        +n "F-5", L2
        +bar
        ; bar 2 (C)
        +n "E-5", L4
        +n "D-5", L8
        +n "C-5", L8
        +n "G-5", L2
        +bar
        ; bar 3 (Dm)
        +n "A-5", L4D
        +n "G-5", L8
        +n "F-5", L4
        +n "E-5", L4
        +bar
        ; bar 4 (Bb)
        +n "D-5", L2D
        +n "C-5", L4
        +bar
        ; bar 5 (F)
        +n "C-5", L4D
        +n "F-5", L8
        +n "A-5", L2
        +bar
        ; bar 6 (C)
        +n "G-5", L4
        +n "E-5", L8
        +n "F-5", L8
        +n "G-5", L2
        +bar
        ; bar 7 (Bb)
        +n "A#5", L4D
        +n "A-5", L8
        +n "G-5", L4
        +n "F-5", L4
        +bar
        ; bar 8 (C)
        +n "G-5", L1
        +bar
        +pat_end
TPAT_LEAD_A_TICKS = PAT_TICKS

tpat_lead_b
        +pat_start
        +ins INS_BRASS
        ; bar 9 (Dm)
        +n "A-5", L4
        +n "F-5", L4
        +n "D-5", L2
        +bar
        ; bar 10 (Bb)
        +n "F-5", L4
        +n "D-5", L4
        +n "A#4", L2
        +bar
        ; bar 11 (F)
        +n "C-5", L4D
        +n "F-5", L8
        +n "A-5", L4
        +n "C-6", L4
        +bar
        ; bar 12 (C)
        +n "A#5", L4D
        +n "A-5", L8
        +n "G-5", L2
        +bar
        ; bar 13 (Dm)
        +n "A-5", L4
        +n "D-6", L4
        +n "C-6", L4
        +n "A-5", L4
        +bar
        ; bar 14 (Bb)
        +n "A#5", L4
        +n "A-5", L8
        +n "G-5", L8
        +n "F-5", L2
        +bar
        ; bar 15 (C)
        +n "E-5", L4
        +n "F-5", L8
        +n "G-5", L8
        +n "A-5", L4
        +n "A#5", L4
        +bar
        ; bar 16 (C)
        +n "C-6", L2D
        +r L4
        +bar
        +pat_end
TPAT_LEAD_B_TICKS = PAT_TICKS

; ---- VOICE 2: arpeggios (one bar per pattern) ----
tpat_arp_f                  ; F: up-down 16ths through the chord
        +pat_start
        +ins INS_ARP
        +n "F-4", L16
        +n "A-4", L16
        +n "C-5", L16
        +n "F-5", L16
        +n "C-5", L16
        +n "A-4", L16
        +n "F-4", L16
        +n "A-4", L16
        +n "C-5", L16
        +n "F-5", L16
        +n "C-5", L16
        +n "A-4", L16
        +n "F-4", L16
        +n "A-4", L16
        +n "C-5", L16
        +n "F-5", L16
        +pat_end
TPAT_ARP_F_TICKS = PAT_TICKS

tpat_arp_c                  ; C: up-down 16ths through the chord
        +pat_start
        +ins INS_ARP
        +n "C-4", L16
        +n "E-4", L16
        +n "G-4", L16
        +n "C-5", L16
        +n "G-4", L16
        +n "E-4", L16
        +n "C-4", L16
        +n "E-4", L16
        +n "G-4", L16
        +n "C-5", L16
        +n "G-4", L16
        +n "E-4", L16
        +n "C-4", L16
        +n "E-4", L16
        +n "G-4", L16
        +n "C-5", L16
        +pat_end
TPAT_ARP_C_TICKS = PAT_TICKS

tpat_arp_dm                  ; Dm: up-down 16ths through the chord
        +pat_start
        +ins INS_ARP
        +n "D-4", L16
        +n "F-4", L16
        +n "A-4", L16
        +n "D-5", L16
        +n "A-4", L16
        +n "F-4", L16
        +n "D-4", L16
        +n "F-4", L16
        +n "A-4", L16
        +n "D-5", L16
        +n "A-4", L16
        +n "F-4", L16
        +n "D-4", L16
        +n "F-4", L16
        +n "A-4", L16
        +n "D-5", L16
        +pat_end
TPAT_ARP_DM_TICKS = PAT_TICKS

tpat_arp_bb                  ; Bb: up-down 16ths through the chord
        +pat_start
        +ins INS_ARP
        +n "A#3", L16
        +n "D-4", L16
        +n "F-4", L16
        +n "A#4", L16
        +n "F-4", L16
        +n "D-4", L16
        +n "A#3", L16
        +n "D-4", L16
        +n "F-4", L16
        +n "A#4", L16
        +n "F-4", L16
        +n "D-4", L16
        +n "A#3", L16
        +n "D-4", L16
        +n "F-4", L16
        +n "A#4", L16
        +pat_end
TPAT_ARP_BB_TICKS = PAT_TICKS

; ---- VOICE 3: triangle bass (one bar per pattern) ----
tpat_bass_f                 ; F: root, root, fifth
        +pat_start
        +ins INS_TBASS
        +n "F-2", L4D
        +n "F-2", L8
        +n "C-3", L2
        +pat_end
TPAT_BASS_F_TICKS = PAT_TICKS

tpat_bass_c                 ; C: root, root, fifth
        +pat_start
        +ins INS_TBASS
        +n "C-2", L4D
        +n "C-2", L8
        +n "G-2", L2
        +pat_end
TPAT_BASS_C_TICKS = PAT_TICKS

tpat_bass_dm                 ; Dm: root, root, fifth
        +pat_start
        +ins INS_TBASS
        +n "D-2", L4D
        +n "D-2", L8
        +n "A-2", L2
        +pat_end
TPAT_BASS_DM_TICKS = PAT_TICKS

tpat_bass_bb                 ; Bb: root, root, fifth
        +pat_start
        +ins INS_TBASS
        +n "A#1", L4D
        +n "A#1", L8
        +n "F-2", L2
        +pat_end
TPAT_BASS_BB_TICKS = PAT_TICKS

; ---- order lists ----
torder_v1
        +ord_start
        +ord tpat_lead_a, TPAT_LEAD_A_TICKS
        +ord tpat_lead_b, TPAT_LEAD_B_TICKS
        +ord_loop
TV1_TICKS = ORD_TICKS

torder_v2
        +ord_start
        +ord tpat_arp_f, TPAT_ARP_F_TICKS
        +ord tpat_arp_c, TPAT_ARP_C_TICKS
        +ord tpat_arp_dm, TPAT_ARP_DM_TICKS
        +ord tpat_arp_bb, TPAT_ARP_BB_TICKS
        +ord tpat_arp_f, TPAT_ARP_F_TICKS
        +ord tpat_arp_c, TPAT_ARP_C_TICKS
        +ord tpat_arp_bb, TPAT_ARP_BB_TICKS
        +ord tpat_arp_c, TPAT_ARP_C_TICKS
        ; B section
        +ord tpat_arp_dm, TPAT_ARP_DM_TICKS
        +ord tpat_arp_bb, TPAT_ARP_BB_TICKS
        +ord tpat_arp_f, TPAT_ARP_F_TICKS
        +ord tpat_arp_c, TPAT_ARP_C_TICKS
        +ord tpat_arp_dm, TPAT_ARP_DM_TICKS
        +ord tpat_arp_bb, TPAT_ARP_BB_TICKS
        +ord tpat_arp_c, TPAT_ARP_C_TICKS
        +ord tpat_arp_c, TPAT_ARP_C_TICKS
        +ord_loop
TV2_TICKS = ORD_TICKS

torder_v3
        +ord_start
        +ord tpat_bass_f, TPAT_BASS_F_TICKS
        +ord tpat_bass_c, TPAT_BASS_C_TICKS
        +ord tpat_bass_dm, TPAT_BASS_DM_TICKS
        +ord tpat_bass_bb, TPAT_BASS_BB_TICKS
        +ord tpat_bass_f, TPAT_BASS_F_TICKS
        +ord tpat_bass_c, TPAT_BASS_C_TICKS
        +ord tpat_bass_bb, TPAT_BASS_BB_TICKS
        +ord tpat_bass_c, TPAT_BASS_C_TICKS
        ; B section
        +ord tpat_bass_dm, TPAT_BASS_DM_TICKS
        +ord tpat_bass_bb, TPAT_BASS_BB_TICKS
        +ord tpat_bass_f, TPAT_BASS_F_TICKS
        +ord tpat_bass_c, TPAT_BASS_C_TICKS
        +ord tpat_bass_dm, TPAT_BASS_DM_TICKS
        +ord tpat_bass_bb, TPAT_BASS_BB_TICKS
        +ord tpat_bass_c, TPAT_BASS_C_TICKS
        +ord tpat_bass_c, TPAT_BASS_C_TICKS
        +ord_loop
TV3_TICKS = ORD_TICKS

!if (TV1_TICKS != TV2_TICKS) | (TV2_TICKS != TV3_TICKS) {
        !error "title song: the three voices have different loop lengths"
}
