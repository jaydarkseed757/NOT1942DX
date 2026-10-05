; =============================================================================
; data/title.asm - title screen: logo, text and colours
; =============================================================================
;
; The logo is pixel art: '#' = set. Every two +logo_px rows become one screen
; row of 2x2 block characters (see macros.asm), so this 68x10 pixel logo is
; 34 characters wide and 5 rows tall.
; =============================================================================

; LOGO_H (screen rows, set in src/title.asm) must match the rows here.
title_logo
        +logo_px "##...##...#####...#######...........##.....#####.......###...#####.."
        +logo_px "###..##..#######..#######..........###....#######.....####..#######."
        +logo_px "###..##..##...##....###...........####....##...##....##.##..##...##."
        +logo_px "####.##..##...##....###.............##....##...##...##..##.......##."
        +logo_px "##.####..##...##....###.............##....#######..##...##......###."
        +logo_px "##.####..##...##....###.............##.....######..#######....####.."
        +logo_px "##..###..##...##....###.............##.........##..#######...###...."
        +logo_px "##..###..##...##....###.............##.........##.......##..###....."
        +logo_px "##...##..#######....###...........######..######........##..#######."
        +logo_px "##...##...#####.....###...........######..#####.........##..#######."
        +logo_end
title_logo_end
LOGO_W = (title_logo_end - title_logo) / LOGO_H
!if LOGO_W * LOGO_H != title_logo_end - title_logo { !error "logo rows differ in width" }
!if LOGO_W > COLS { !error "logo is wider than the screen" }

; Logo colour per screen row (top to bottom). The logo is hires, so colour
; RAM values must be 0-7: a white-hot top fading through yellow to red.
title_logo_cols
        !byte COL_WHITE, COL_YELLOW, COL_YELLOW, COL_RED, COL_RED

; Text lines (screen codes: lowercase in the source shows as capitals).
title_by        !scr "by jdc"
TITLE_BY_LEN    = * - title_by
title_press     !scr "press fire to start"
TITLE_PRESS_LEN = * - title_press
title_help      !scr "joystick port 2 or wasd + space"
TITLE_HELP_LEN  = * - title_help
title_music_on  !scr "m: music on "
TITLE_MUSIC_LEN = * - title_music_on
title_music_off !scr "m: music off"
!if * - title_music_off != TITLE_MUSIC_LEN { !error "music on/off texts differ in length" }
title_pause     !scr "p: pause"
TITLE_PAUSE_LEN = * - title_pause

; Version, top right of the title screen. Change it for each release.
title_version   !scr "dx 0.1"
TITLE_VERSION_LEN = * - title_version
