; =============================================================================
; data/tiles.asm - fixed chars assembled straight into the charset
; Chars 0-63 are the ROM font (copied at boot), 64-127 the current level's
; tileset (copied at level start, see data/tiles_*.asm), and these are the
; chars from 128 up, which never change.
; =============================================================================

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
fixed_chars_end
