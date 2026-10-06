; =============================================================================
; unpack.asm - LZ unpacker for the level packs (format: tools/c64gfx.py)
; =============================================================================
;
;   $00-$7F  t       literal run: the next t + 1 bytes are copied (1-128)
;   $80-$FE  t lo hi match: copy (t & $7F) + 3 bytes (3-129) from
;                    hi * 256 + lo bytes back in the output (forwards, so an
;                    overlapping copy repeats a pattern)
;   $FF              end of stream
;
; TIMING: about 15 cycles per byte written plus ~40 per token; a level's
; three packs (up to ~6.5 KB unpacked) take a few frames, with the display
; off (level_begin).
; =============================================================================

!zone unpack
; -----------------------------------------------------------------------------
; unpack: unpack the stream at zp_ptr0 to zp_ptr1. Leaves zp_ptr0 just past
; the end marker and zp_ptr1 just past the output. Clobbers A, X, Y, lz_mp.
; -----------------------------------------------------------------------------
unpack
.token  ldy #0
        lda (zp_ptr0),y
        inc zp_ptr0
        bne +
        inc zp_ptr0+1
+       cmp #$ff
        beq .done
        cmp #$80
        bcs .match
        tax                     ; literal run of A + 1 bytes
        inx
-       lda (zp_ptr0),y
        sta (zp_ptr1),y
        iny
        dex
        bne -
        tya                     ; source += run
        clc
        adc zp_ptr0
        sta zp_ptr0
        bcc .dst
        inc zp_ptr0+1
        bcs .dst                ; (always)

.match  and #$7f                ; length - 3
        clc
        adc #3
        tax
        lda zp_ptr1             ; lz_mp = destination - distance
        sec
        sbc (zp_ptr0),y
        sta lz_mp
        iny
        lda zp_ptr1+1
        sbc (zp_ptr0),y
        sta lz_mp+1
        lda zp_ptr0             ; source += 2
        clc
        adc #2
        sta zp_ptr0
        bcc +
        inc zp_ptr0+1
+       ldy #0
-       lda (lz_mp),y
        sta (zp_ptr1),y
        iny
        dex
        bne -

.dst    tya                     ; destination += bytes written
        clc
        adc zp_ptr1
        sta zp_ptr1
        bcc .token
        inc zp_ptr1+1
        bcs .token              ; (always)
.done   rts
