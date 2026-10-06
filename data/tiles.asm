; =============================================================================
; data/tiles.asm - the title logo's chars
; Chars 0-63 are the ROM font (copied at boot), and 64-255 the current
; level's chars (unpacked at level start). These 16 chars are copied to
; codes 128-143 for the title and the text screens (restore_quads), over
; whatever the last level left there.
; =============================================================================
QUAD_CHARS = 16
quad_chars

; -----------------------------------------------------------------------------
; QUAD_BASE (128) .. +15: hires 2x2 "quadrant" blocks for the title logo.
; Char QUAD_BASE + q: bit 3 = top-left 4x4, 2 = top-right, 1 = bottom-left,
; 0 = bottom-right. Shown in hires (colour RAM < 8), so each bit is a pixel.
; -----------------------------------------------------------------------------
!for .q, 0, 15 {
        !for .r, 0, 3 {
                !byte ((.q >> 3) & 1) * $f0 | ((.q >> 2) & 1) * $0f
        }
        !for .r, 0, 3 {
                !byte ((.q >> 1) & 1) * $f0 | (.q & 1) * $0f
        }
}
quad_chars_end
!if quad_chars_end - quad_chars != QUAD_CHARS * 8 { !error "quad chars size" }
