; =============================================================================
; data/aim.asm - the aiming table for enemy shots (src/ebullets.asm)
; Generated at assemble time; kept out of the code area, which is tight.
; =============================================================================

; Octant angle table: round(atan(S / L) / 11.25 deg), for L = 16..31 and
; S = 0..31. Entries with S > L never occur (S <= L) and are filled with 4.
!macro atan_rows .l0 {
        !for .l, .l0, .l0 + 7 {
                !for .s, 0, 31 {
                        !if .s > .l {
                                !byte 4
                        } else {
                                !byte int(arctan(float(.s) / float(.l)) / DEG / STEP + 0.5)
                        }
                }
        }
}
atan_lo +atan_rows 16           ; 256 bytes
atan_hi +atan_rows 24           ; 256 bytes

