; =============================================================================
; score.asm - 6-digit BCD score
; =============================================================================
;
; score_hi / score_mid / score_lo hold 2 BCD digits each: "HHMMLL". Points per
; enemy type are BCD too (etype_pts_* in data/waves.asm). Only bullet kills
; score; crashing into an enemy destroys it but gives nothing. The score stops
; at 999999.
;
; TIMING/IRQ: the add runs with the decimal flag set (SED). The 6502 does not
; clear D on an interrupt, so the IRQ handler clears it itself (system.asm).
; =============================================================================

!zone init_score
init_score
        lda #0
        sta score_lo
        sta score_mid
        sta score_hi
        jmp hud_draw_score

!zone score_add_enemy
; -----------------------------------------------------------------------------
; score_add_enemy: add the points for the enemy in slot Y, update the HUD.
; Preserves X and Y. Clobbers A.
; -----------------------------------------------------------------------------
score_add_enemy
        txa
        pha
        tya
        pha
        lda en_type_s,y
        tax
        ldy etype_pts_mid,x
        lda etype_pts_lo,x
        jsr score_add_bcd
        pla
        tay
        pla
        tax
        rts

!zone score_add_bcd
; -----------------------------------------------------------------------------
; score_add_bcd: add BCD points (A = last two digits, Y = middle two) and
; redraw the HUD. Clobbers A, X, Y.
; -----------------------------------------------------------------------------
score_add_bcd
        sty zp_tmp0
        sed
        clc
        adc score_lo
        sta score_lo
        lda score_mid
        adc zp_tmp0
        sta score_mid
        lda score_hi
        adc #0
        sta score_hi
        cld
        bcc +
        lda #$99                ; carried past 999999: hold at the maximum
        sta score_lo
        sta score_mid
        sta score_hi
+       jmp hud_draw_score

!zone score_to_digits
; -----------------------------------------------------------------------------
; score_to_digits: score -> 6 screen-code digits in score_digits.
; Clobbers A, X, Y.
; -----------------------------------------------------------------------------
score_to_digits
        ldx #0
        ldy #0
-       lda score_hi,x          ; score_hi, score_mid, score_lo are adjacent
        pha                     ;   (high first, see zp.asm)
        lsr
        lsr
        lsr
        lsr
        ora #'0'                ; screen codes for digits are $30-$39
        sta score_digits,y
        iny
        pla
        and #$0f
        ora #'0'
        sta score_digits,y
        iny
        inx
        cpx #3
        bne -
        rts
