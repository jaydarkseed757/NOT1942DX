; =============================================================================
; input.asm - joystick port 2 + keyboard, merged into one input byte
; =============================================================================
;
; input_bits (active HIGH, same bit layout as the joystick):
;   bit 0 up   bit 1 down   bit 2 left   bit 3 right   bit 4 fire
;   bit 5 pause (P or RUN/STOP)   bit 6 music on/off (M; title screen)
; input_new has the same layout but only the bits that went down this frame,
; so a held button counts once (fire is press-to-shoot, not auto-fire).
;
; Keyboard: W A S D = up/left/down/right, SPACE = fire.
; The KERNAL is banked out, so we scan the CIA1 matrix ourselves:
;   write a row-select mask (0 = selected) to $DC00, read columns from $DC01.
;     W     = row 1, col 1      A = row 1, col 2      S = row 1, col 5
;     D     = row 2, col 2      SPACE = row 7, col 4
;     P     = row 5, col 1      RUN/STOP = row 7, col 7     M = row 4, col 4
;     1     = row 7, col 0      2 = row 7, col 3    (read_level_key, title only)
;     3     = row 1, col 0      4 = row 1, col 3
;
; HARDWARE LIMITATION: joystick 2 shares $DC00 with the keyboard row select.
; Holding the stick while pressing keys can select extra rows and give false
; key reads (ghosting). We only test five keys, and in practice the result is
; at worst an extra direction while both are used at once. P, RUN/STOP and M
; can only be faked by also pressing keys next to them in the matrix.
; A joystick in port 1 drives $DC01 and would read as key presses; port 1 is
; not supported.
; =============================================================================

INP_UP    = %00000001
INP_DOWN  = %00000010
INP_LEFT  = %00000100
INP_RIGHT = %00001000
INP_FIRE  = %00010000
INP_PAUSE = %00100000           ; keyboard only
INP_MUSIC = %01000000           ; keyboard only

!zone init_input
init_input
        lda #$ff
        sta CIA1_DDRA           ; port A = outputs (row select)
        sta CIA1_PRA            ; no rows selected
        lda #$00
        sta CIA1_DDRB           ; port B = inputs (columns)
        sta input_new
        lda #$ff                ; pretend everything was held at boot, so a
        sta input_bits          ;   button held during load doesn't fire
        sta input_prev          ;   (read_input copies input_bits -> input_prev)
        rts

!zone read_level_key
; -----------------------------------------------------------------------------
; read_level_key: the title screen's keys 1-4 (go straight to that level's
; boss). A = 1-4 for the lowest one held, else 0 (Z set). Clobbers A,
; zp_tmp0, zp_tmp1.
; -----------------------------------------------------------------------------
read_level_key
        lda #%01111111          ; row 7: 1 (col 0), 2 (col 3)
        sta CIA1_PRA
        lda CIA1_PRB
        eor #$ff                ; pressed = 1
        sta zp_tmp0
        lda #%11111101          ; row 1: 3 (col 0), 4 (col 3)
        sta CIA1_PRA
        lda CIA1_PRB
        eor #$ff
        sta zp_tmp1
        lda #$ff
        sta CIA1_PRA            ; leave no rows selected
        lda zp_tmp0
        lsr
        bcs .one
        and #%00000100          ; (col 3, shifted)
        bne .two
        lda zp_tmp1
        lsr
        bcs .three
        and #%00000100
        bne .four
        lda #0
        rts
.one    lda #1
        rts
.two    lda #2
        rts
.three  lda #3
        rts
.four   lda #4
        rts

!zone read_input
; -----------------------------------------------------------------------------
; read_input: once per frame. Result in input_bits. Clobbers A.
; -----------------------------------------------------------------------------
read_input
        lda input_bits
        sta input_prev

        ; --- joystick port 2 (active low on $DC00 bits 0-4) ---
        lda #$ff
        sta CIA1_PRA            ; deselect all rows first, or our own row
        lda CIA1_PRA            ;   select bits would read as stick presses
        eor #$ff
        and #%00011111
        sta input_bits

        ; --- row 1: W (col 1), A (col 2), S (col 5) ---
        lda #%11111101
        sta CIA1_PRA
        lda CIA1_PRB
        eor #$ff                ; pressed = 1
        sta zp_tmp0
        and #%00000010          ; W -> up
        beq +
        lda input_bits
        ora #INP_UP
        sta input_bits
+       lda zp_tmp0
        and #%00000100          ; A -> left
        beq +
        lda input_bits
        ora #INP_LEFT
        sta input_bits
+       lda zp_tmp0
        and #%00100000          ; S -> down
        beq +
        lda input_bits
        ora #INP_DOWN
        sta input_bits

        ; --- row 2: D (col 2) ---
+       lda #%11111011
        sta CIA1_PRA
        lda CIA1_PRB
        and #%00000100          ; active low
        bne +
        lda input_bits
        ora #INP_RIGHT
        sta input_bits

        ; --- row 7: SPACE (col 4), RUN/STOP (col 7) ---
+       lda #%01111111
        sta CIA1_PRA
        lda CIA1_PRB
        eor #$ff                ; pressed = 1
        sta zp_tmp0
        and #%00010000          ; SPACE -> fire
        beq +
        lda input_bits
        ora #INP_FIRE
        sta input_bits
+       lda zp_tmp0
        and #%10000000          ; RUN/STOP -> pause
        beq +
        lda input_bits
        ora #INP_PAUSE
        sta input_bits

        ; --- row 5: P (col 1) -> pause ---
+       lda #%11011111
        sta CIA1_PRA
        lda CIA1_PRB
        and #%00000010          ; active low
        bne +
        lda input_bits
        ora #INP_PAUSE
        sta input_bits

        ; --- row 4: M (col 4) -> music on/off ---
+       lda #%11101111
        sta CIA1_PRA
        lda CIA1_PRB
        and #%00010000
        bne +
        lda input_bits
        ora #INP_MUSIC
        sta input_bits

+       lda #$ff
        sta CIA1_PRA            ; leave no rows selected

!ifdef FORCE_INPUT {
        ; Test hook: acme -DFORCE_INPUT=<bits> holds those inputs down forever.
        ; Used for headless VICE checks; never defined by the Makefile.
        lda input_bits
        ora #FORCE_INPUT
        sta input_bits
}
!ifdef FORCE_TAP {
        ; Test hook: acme -DFORCE_TAP=<mask> presses fire whenever
        ; (frame_count AND mask) != 0, e.g. 4 = tap every 8 frames.
        lda frame_count
        and #FORCE_TAP
        beq +
        lda input_bits
        ora #INP_FIRE
        sta input_bits
+
}
!ifdef TEST_KEYS {
        ; Test hook: acme -DTEST_KEYS=<bits> -DTEST_KEYS_MASK=<mask> holds
        ; those input bits whenever (frame_count AND mask) != 0, so they are
        ; pressed once every 2 * mask frames. E.g. TEST_KEYS=32 (pause) with
        ; mask 128 pauses / unpauses every 256 frames; 64 is M (music).
        lda frame_count
        and #TEST_KEYS_MASK
        beq +
        lda input_bits
        ora #TEST_KEYS
        sta input_bits
+
}
        ; --- press edges: down now AND up last frame ---
        lda input_prev
        eor #$ff
        and input_bits
        sta input_new
        rts
