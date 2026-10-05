; =============================================================================
; data/ending.asm - the ending: credits roll text and the scroll text
; Text by JDC. Screen codes: write in lowercase, it shows in capitals (the
; C64 font has capitals, digits and punctuation only).
; =============================================================================

; -----------------------------------------------------------------------------
; CREDITS ROLL: one +credit per screen line (up to 40 characters, centred
; automatically). +credit "" is a blank line. The lines roll up from the
; bottom of the screen and off the top, then the final screen appears.
; -----------------------------------------------------------------------------
credits
        +credit "thanks to"
        +credit ""
        +credit "jacq,"
        +credit ""
        +credit "bobby,"
        +credit ""
        +credit "and claude."
        +credit ""
        +credit ""
        +credit ""
        +credit "vote blue this election."
credits_end
CREDIT_LINES = (credits_end - credits) / COLS

; -----------------------------------------------------------------------------
; SCROLL TEXT: loops on the final screen in big 16x16 letters. The spaces at
; the end separate one pass from the next. Ends with SCROLL_END.
; -----------------------------------------------------------------------------
scroll_text
        !scr "not 1942 by jdc        "
        !byte SCROLL_END
