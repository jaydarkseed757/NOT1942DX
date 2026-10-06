; =============================================================================
; data/sprites.asm - sprite shapes (multicolour, 12x21 double-wide pixels)
; Assembled at SPRITES ($5000). Each shape is 64 bytes; its pointer value is
; SPR_PTR0 + index. Pixels:
;   .  transparent
;   w  shared colour 1  ($D025, SPR_SHARED1 in defs.asm)
;   i  sprite's own colour ($D027+n)
;   d  shared colour 2  ($D026, SPR_SHARED2)
; =============================================================================

; -----------------------------------------------------------------------------
; Player ship: a P-38, twin booms, nose up, lit from the top left. Drawn in
; rows 0-16; its hitbox is only the pod, engines and wing roots (collide.asm).
; -----------------------------------------------------------------------------
spr_ship
PTR_SHIP = SPR_PTR0 + (spr_ship - SPRITES) / 64
        +spr_begin
        +spr "..d......d.."     ;  0
        +spr ".ddd.dd.ddd."     ;  1
        +spr "..w..ii..w.."     ;  2
        +spr ".wid.ii.wid."     ;  3
        +spr ".iid.ww.iid."     ;  4
        +spr ".iid.wd.iid."     ;  5
        +spr ".wwwwiiwwww."     ;  6
        +spr "iiiiiiiiiiii"     ;  7
        +spr "iiiiiiiiiiid"     ;  8
        +spr ".diddddddid."     ;  9
        +spr "..i..ii..i.."     ; 10
        +spr "..i..dd..i.."     ; 11
        +spr "..i......i.."     ; 12
        +spr "..i......i.."     ; 13
        +spr ".wid....wid."     ; 14
        +spr ".wiiiiiiiid."     ; 15
        +spr "..dddddddd.."     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Player bullet: twin streaks fired from the nose. Drawn in rows 0-5, at MC
; columns 4 and 7, so with the same half-X as the ship it sits centred on the
; nose. Hitbox about 4x6 MC pixels (8x6 screen pixels).
; -----------------------------------------------------------------------------
spr_pbullet
PTR_PBULLET = SPR_PTR0 + (spr_pbullet - SPRITES) / 64
        +spr_begin
        +spr "....w..w...."     ;  0  tips
        +spr "....w..w...."     ;  1
        +spr "....i..i...."     ;  2
        +spr "....i..i...."     ;  3
        +spr "....i..i...."     ;  4
        +spr "....d..d...."     ;  5  tail
        +spr "............"     ;  6
        +spr "............"     ;  7
        +spr "............"     ;  8
        +spr "............"     ;  9
        +spr "............"     ; 10
        +spr "............"     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Enemy fighter: single engine, nose DOWN (flying toward the player).
; Drawn in rows 0-14, so ENEMY_H = 15.
; -----------------------------------------------------------------------------
spr_fighter
PTR_FIGHTER = SPR_PTR0 + (spr_fighter - SPRITES) / 64
        +spr_begin
        +spr "...dwwwd...."     ;  0
        +spr ".....ii....."     ;  1
        +spr ".....ii....."     ;  2
        +spr ".....ii....."     ;  3
        +spr ".....ii....."     ;  4
        +spr "....dwid...."     ;  5
        +spr ".wwwwiiwwww."     ;  6
        +spr "iiiiiiiiiiii"     ;  7
        +spr "iiiiiiiiiiid"     ;  8
        +spr ".ddiiiiiidd."     ;  9
        +spr ".....ii....."     ; 10
        +spr "....wiid...."     ; 11
        +spr "....iiid...."     ; 12
        +spr "...dddddd..."     ; 13
        +spr "....d..d...."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Enemy leader: twin engine, nose DOWN. Drawn in rows 0-14 (ENEMY_H = 15).
; -----------------------------------------------------------------------------
spr_leader
PTR_LEADER = SPR_PTR0 + (spr_leader - SPRITES) / 64
        +spr_begin
        +spr "..dwwwwwwd.."     ;  0
        +spr "...diiiid..."     ;  1
        +spr ".....ii....."     ;  2
        +spr ".....ii....."     ;  3
        +spr ".....ii....."     ;  4
        +spr ".....ii....."     ;  5
        +spr "....dwid...."     ;  6
        +spr ".wwwwiiwwww."     ;  7
        +spr "iiiiiiiiiiii"     ;  8
        +spr "iiiiiiiiiiid"     ;  9
        +spr "diiddiiddiid"     ; 10
        +spr ".wid.ii.wid."     ; 11
        +spr ".iid.ii.iid."     ; 12
        +spr "dddd.wd.dddd"     ; 13
        +spr ".....dd....."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Enemy bullet: small round shot, centred like the enemy art (same half-X).
; Drawn in rows 0-3 (EB_H = 4). Hitbox about 4x4 MC pixels (8x4 screen pixels).
; -----------------------------------------------------------------------------
spr_ebullet
PTR_EBULLET = SPR_PTR0 + (spr_ebullet - SPRITES) / 64
        +spr_begin
        +spr ".....ii....."     ;  0
        +spr "....iwwi...."     ;  1  white-hot core
        +spr "....iwwi...."     ;  2
        +spr ".....ii....."     ;  3
        +spr "............"     ;  4
        +spr "............"     ;  5
        +spr "............"     ;  6
        +spr "............"     ;  7
        +spr "............"     ;  8
        +spr "............"     ;  9
        +spr "............"     ; 10
        +spr "............"     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Explosion, second shape: wider fireball breaking up into smoke.
; -----------------------------------------------------------------------------
spr_expl_b
PTR_EXPL_B = SPR_PTR0 + (spr_expl_b - SPRITES) / 64
        +spr_begin
        +spr "..d...d...d."     ;  0
        +spr "...i..i..i.."     ;  1
        +spr ".d..iiii..d."     ;  2
        +spr "...iiwwii..."     ;  3
        +spr "diiiwwwwiiid"     ;  4
        +spr "...iiwwii..."     ;  5
        +spr "...iiwwii..."     ;  6
        +spr "diiiwwwwiiid"     ;  7
        +spr "...iiwwii..."     ;  8
        +spr ".d..iiii..d."     ;  9
        +spr "...i..i..i.."     ; 10
        +spr "..d...d...d."     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Boss 1 "Thunder": a four-engine heavy bomber, nose DOWN, lit from the top
; left: 144x84 px from 4 X+Y expanded sprites. Drawn as one 36x42-pixel
; picture (made with a script, then kept here as the master copy) on a grid
; of 3 x 2 sprites; everything but the tail sits in the lower row, so the
; top row is only its middle sprite (boss1_tm) and the boss costs the
; multiplexer 4 sprites, not 6.
;
;   .................wd.................
;   .................wi.................
;   .............wwwwiiwwwd.............
;   ............wiiiiiiiiiid............
;   ............diiiiiiiiiid............
;   .............ddddiidddd.............
;   .................id.................
;   .................id.................
;   ................wiid................
;   ................iiid................
;   ................iiid................
;   ................iiid................
;   ................iiid................
;   ................iiid................
;   ................iiid................
;   ................iiid................
;   ...............wiiiid...............
;   ...............iiiiid...............
;   ...............iiiiid...............
;   ...............iiiiid...............
;   ...............iiiiid...............
;   ..............wiiiiiid..............
;   ....wwwwwwwwwwiiiiiiiiwwwwwwwwwd....
;   .wwwiiiiiiiiiiiiiiiiiiiiiiiiiiiiwwd.
;   wiiiiiidiiiiidiiiiiiiiiidiiiiidiiiid
;   diiiiiidiiiiidiiiwwiiiiidiiiiidiiiid
;   .diiiiidiiiiidiiiddiiiiidiiiiidiiid.
;   ..dddiidiiiiidiiiiiiiiiidiiiiidddd..
;   .....widdddiidiiiiiiiiiiddddwid.....
;   .....wid...iiddiiiiiidiid...wid.....
;   .....wid...wid.iiiiid.wid...wid.....
;   .....wid...wid.iiiiid.wid...wid.....
;   ......w....wid.idwwdd.wid....w......
;   ....ddddd..wid.idwwdd.wid..ddddd....
;   ............w..iiiiid..w............
;   ..........dddddiiiiiiddddd..........
;   ...............diiiid...............
;   ................iwid................
;   ................wwwd................
;   ................dwwd................
;   .................dd.................
;   ....................................
; -----------------------------------------------------------------------------
spr_boss1_tm
PTR_BOSS1_TM = SPR_PTR0 + (spr_boss1_tm - SPRITES) / 64
        +spr_begin
        +spr ".....wd....."     ;  0
        +spr ".....wi....."     ;  1
        +spr ".wwwwiiwwwd."     ;  2
        +spr "wiiiiiiiiiid"     ;  3
        +spr "diiiiiiiiiid"     ;  4
        +spr ".ddddiidddd."     ;  5
        +spr ".....id....."     ;  6
        +spr ".....id....."     ;  7
        +spr "....wiid...."     ;  8
        +spr "....iiid...."     ;  9
        +spr "....iiid...."     ; 10
        +spr "....iiid...."     ; 11
        +spr "....iiid...."     ; 12
        +spr "....iiid...."     ; 13
        +spr "....iiid...."     ; 14
        +spr "....iiid...."     ; 15
        +spr "...wiiiid..."     ; 16
        +spr "...iiiiid..."     ; 17
        +spr "...iiiiid..."     ; 18
        +spr "...iiiiid..."     ; 19
        +spr "...iiiiid..."     ; 20
        +spr_end

spr_boss1_bl
PTR_BOSS1_BL = SPR_PTR0 + (spr_boss1_bl - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "....wwwwwwww"     ;  1
        +spr ".wwwiiiiiiii"     ;  2
        +spr "wiiiiiidiiii"     ;  3
        +spr "diiiiiidiiii"     ;  4
        +spr ".diiiiidiiii"     ;  5
        +spr "..dddiidiiii"     ;  6
        +spr ".....widdddi"     ;  7
        +spr ".....wid...i"     ;  8
        +spr ".....wid...w"     ;  9
        +spr ".....wid...w"     ; 10
        +spr "......w....w"     ; 11
        +spr "....ddddd..w"     ; 12
        +spr "............"     ; 13
        +spr "..........dd"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss1_bm
PTR_BOSS1_BM = SPR_PTR0 + (spr_boss1_bm - SPRITES) / 64
        +spr_begin
        +spr "..wiiiiiid.."     ;  0
        +spr "wwiiiiiiiiww"     ;  1
        +spr "iiiiiiiiiiii"     ;  2
        +spr "idiiiiiiiiii"     ;  3
        +spr "idiiiwwiiiii"     ;  4
        +spr "idiiiddiiiii"     ;  5
        +spr "idiiiiiiiiii"     ;  6
        +spr "idiiiiiiiiii"     ;  7
        +spr "iddiiiiiidii"     ;  8
        +spr "id.iiiiid.wi"     ;  9
        +spr "id.iiiiid.wi"     ; 10
        +spr "id.idwwdd.wi"     ; 11
        +spr "id.idwwdd.wi"     ; 12
        +spr "w..iiiiid..w"     ; 13
        +spr "dddiiiiiiddd"     ; 14
        +spr "...diiiid..."     ; 15
        +spr "....iwid...."     ; 16
        +spr "....wwwd...."     ; 17
        +spr "....dwwd...."     ; 18
        +spr ".....dd....."     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss1_br
PTR_BOSS1_BR = SPR_PTR0 + (spr_boss1_br - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "wwwwwwwd...."     ;  1
        +spr "iiiiiiiiwwd."     ;  2
        +spr "diiiiidiiiid"     ;  3
        +spr "diiiiidiiiid"     ;  4
        +spr "diiiiidiiid."     ;  5
        +spr "diiiiidddd.."     ;  6
        +spr "ddddwid....."     ;  7
        +spr "d...wid....."     ;  8
        +spr "d...wid....."     ;  9
        +spr "d...wid....."     ; 10
        +spr "d....w......"     ; 11
        +spr "d..ddddd...."     ; 12
        +spr "............"     ; 13
        +spr "dd.........."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Boss 2 "Leviathan": an armoured airship seen from above, nose LEFT, lit
; from the top left: ring frames, three gun turrets on its back, four engine
; pods on outriggers, swept tail fins. Three X+Y expanded sprites side by
; side (144x42 px), drawn as one 36x21-pixel picture (made with a script,
; then kept here as the master copy). Not 4 across: with the bullets that fly
; through it, that would need more than 8 sprites on its lines.
;
;   ....................................
;   ........dwwwd.....dwwwd..........wd.
;   ........ddddd.....diiid........wwid.
;   ............wwwwwwiiid.......wwiiid.
;   .......wwwwwiiiiiiiiiiwd...wwiiiiid.
;   .....wwdiiiidiiiidiiiidiwd.dddddddd.
;   ...wwwwwwwwwwwwwwwwwwwwwwwd.........
;   ..wiiiidiiiidiiiidiiiidiiiiwd.......
;   .wiiiiiiiiiiiiiiiiiiiiiiiiiiiwd.....
;   .wiiiiididdidiiiiddiiidiidddiiiwd...
;   .wiiiiiidwwdiiiidwwdiiiidwwdiiiid...
;   .wiiiiididdidiiiiddiiidiidddiiidd...
;   .diiiiiiiiiiiiiiiiiiiiiiiiiiidd.....
;   ..diiiidiiiidiiiidiiiidiiiidd.......
;   ...dddddddddddddddddddddddd.........
;   .....dddiiiidiiiidiiiididd.wwwwwwwd.
;   .......dddidiiiiiiiiiidd...ddiiiiid.
;   ..........d.wdddddiiid.......ddiiid.
;   ........dwiwd.....diiid........ddid.
;   ........ddddd.....ddddd..........dd.
;   ....................................
; -----------------------------------------------------------------------------
spr_boss2_l
PTR_BOSS2_L = SPR_PTR0 + (spr_boss2_l - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "........dwww"     ;  1
        +spr "........dddd"     ;  2
        +spr "............"     ;  3
        +spr ".......wwwww"     ;  4
        +spr ".....wwdiiii"     ;  5
        +spr "...wwwwwwwww"     ;  6
        +spr "..wiiiidiiii"     ;  7
        +spr ".wiiiiiiiiii"     ;  8
        +spr ".wiiiiididdi"     ;  9
        +spr ".wiiiiiidwwd"     ; 10
        +spr ".wiiiiididdi"     ; 11
        +spr ".diiiiiiiiii"     ; 12
        +spr "..diiiidiiii"     ; 13
        +spr "...ddddddddd"     ; 14
        +spr ".....dddiiii"     ; 15
        +spr ".......dddid"     ; 16
        +spr "..........d."     ; 17
        +spr "........dwiw"     ; 18
        +spr "........dddd"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss2_m
PTR_BOSS2_M = SPR_PTR0 + (spr_boss2_m - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "d.....dwwwd."     ;  1
        +spr "d.....diiid."     ;  2
        +spr "wwwwwwiiid.."     ;  3
        +spr "iiiiiiiiiiwd"     ;  4
        +spr "diiiidiiiidi"     ;  5
        +spr "wwwwwwwwwwww"     ;  6
        +spr "diiiidiiiidi"     ;  7
        +spr "iiiiiiiiiiii"     ;  8
        +spr "diiiiddiiidi"     ;  9
        +spr "iiiidwwdiiii"     ; 10
        +spr "diiiiddiiidi"     ; 11
        +spr "iiiiiiiiiiii"     ; 12
        +spr "diiiidiiiidi"     ; 13
        +spr "dddddddddddd"     ; 14
        +spr "diiiidiiiidi"     ; 15
        +spr "iiiiiiiiiidd"     ; 16
        +spr "wdddddiiid.."     ; 17
        +spr "d.....diiid."     ; 18
        +spr "d.....ddddd."     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss2_r
PTR_BOSS2_R = SPR_PTR0 + (spr_boss2_r - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr ".........wd."     ;  1
        +spr ".......wwid."     ;  2
        +spr ".....wwiiid."     ;  3
        +spr "...wwiiiiid."     ;  4
        +spr "wd.dddddddd."     ;  5
        +spr "wwd........."     ;  6
        +spr "iiiwd......."     ;  7
        +spr "iiiiiwd....."     ;  8
        +spr "idddiiiwd..."     ;  9
        +spr "dwwdiiiid..."     ; 10
        +spr "idddiiidd..."     ; 11
        +spr "iiiiidd....."     ; 12
        +spr "iiidd......."     ; 13
        +spr "ddd........."     ; 14
        +spr "dd.wwwwwwwd."     ; 15
        +spr "...ddiiiiid."     ; 16
        +spr ".....ddiiid."     ; 17
        +spr ".......ddid."     ; 18
        +spr ".........dd."     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Raider: twin-tail fighter, nose DOWN, lit from the top left. Rows 0-14 (ENEMY_H).
; -----------------------------------------------------------------------------
spr_raider
PTR_RAIDER = SPR_PTR0 + (spr_raider - SPRITES) / 64
        +spr_begin
        +spr "..dw....wd.."     ;  0
        +spr "..di....id.."     ;  1
        +spr "..wiiiiiid.."     ;  2
        +spr "....diid...."     ;  3
        +spr ".....ii....."     ;  4
        +spr ".....ii....."     ;  5
        +spr "....dwid...."     ;  6
        +spr "dwwwwiiwwwwd"     ;  7
        +spr "iiiiiiiiiiii"     ;  8
        +spr ".iiiiiiiiid."     ;  9
        +spr "..ddiiiidd.."     ; 10
        +spr ".....ii....."     ; 11
        +spr "....wiid...."     ; 12
        +spr "...dddddd..."     ; 13
        +spr "....d..d...."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Raider climbing from behind: the same plane flipped, nose UP. Rows 0-14.
; -----------------------------------------------------------------------------
spr_raider_up
PTR_RAIDER_UP = SPR_PTR0 + (spr_raider_up - SPRITES) / 64
        +spr_begin
        +spr "....d..d...."     ;  0
        +spr "...dddddd..."     ;  1
        +spr "....wiid...."     ;  2
        +spr ".....ii....."     ;  3
        +spr "..ddiiiidd.."     ;  4
        +spr ".iiiiiiiiid."     ;  5
        +spr "iiiiiiiiiiii"     ;  6
        +spr "dwwwwiiwwwwd"     ;  7
        +spr "....dwid...."     ;  8
        +spr ".....ii....."     ;  9
        +spr ".....ii....."     ; 10
        +spr "....diid...."     ; 11
        +spr "..wiiiiiid.."     ; 12
        +spr "..di....id.."     ; 13
        +spr "..dw....wd.."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Gunship: heavy twin-engine fighter with twin fins, nose DOWN. Rows 0-14.
; White: its shading is the dark grey outline.
; -----------------------------------------------------------------------------
spr_gunship
PTR_GUNSHIP = SPR_PTR0 + (spr_gunship - SPRITES) / 64
        +spr_begin
        +spr "..dd....dd.."     ;  0
        +spr "..di....id.."     ;  1
        +spr ".diiiiiiiid."     ;  2
        +spr "....diid...."     ;  3
        +spr ".....ii....."     ;  4
        +spr "....diid...."     ;  5
        +spr "....dwwd...."     ;  6
        +spr ".diiiiiiiid."     ;  7
        +spr "iiiiiiiiiiii"     ;  8
        +spr "iiiiiiiiiiid"     ;  9
        +spr "ddiddiiddidd"     ; 10
        +spr ".iid.ii.iid."     ; 11
        +spr ".iid.dd.iid."     ; 12
        +spr "dddd.dd.dddd"     ; 13
        +spr ".....dd....."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Gold medal: dropped by a shot red leader, worth MEDAL_PTS. Drawn in rows
; 0-11, inside the 12x12 enemy box (it lives in an enemy slot).
; -----------------------------------------------------------------------------
spr_medal
PTR_MEDAL = SPR_PTR0 + (spr_medal - SPRITES) / 64
        +spr_begin
        +spr "...dd..dd..."     ;  0  ribbon
        +spr "....d..d...."     ;  1
        +spr ".....dd....."     ;  2  ribbon knot
        +spr "....diid...."     ;  3  gold disc: 12x10 px,
        +spr "...diwiid..."     ;  4    round on screen
        +spr "...dwiiid..."     ;  5    (MC pixels are 2 wide)
        +spr "...diiiid..."     ;  6
        +spr "...diiiid..."     ;  7
        +spr "...diiiid..."     ;  8
        +spr "...diiiid..."     ;  9
        +spr "....diid...."     ; 10
        +spr ".....dd....."     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Boss 3 "Albatross": a giant four-engine flying boat, nose DOWN, lit from the
; top left: a wide boat hull with a keel line, a T-tail, a gull wing with
; wingtip floats. 144x84 px from 4 X+Y expanded sprites, laid out like boss
; 1 (a 3 x 2 grid whose top row is only the tail, boss3_tm). Drawn as one
; 36x42-pixel picture (made with a script, then kept here as the master copy).
;
;   ....................................
;   .................wd.................
;   .............wwwwiiwwwd.............
;   ............wiiiiiiiiiid............
;   ............ddiiiiiiiidd............
;   ..............ddiiiidd..............
;   ................iiid................
;   ................iiid................
;   ................iwid................
;   ................iwid................
;   ................iwid................
;   ................iwid................
;   ................iwid................
;   ................iwid................
;   ...............wiwiid...............
;   ...............iiwiid...............
;   ...............iiwiid...............
;   ...............iiwiid...............
;   ...............iiwiid...............
;   ...............iiwiid...............
;   ...............iiwiid...............
;   ..............wiiwiiid..............
;   ..............iiiwiiid..............
;   .............wiiiwiiiid.............
;   wwwwwwwwwwwwwiiiiwiiiiiwwwwwwwwwwwwd
;   iiiiiiiiiidiiiidiwiiiidiiiidiiiiiiid
;   ddiiiiiiiidiiiidiwiiiidiiiidiiiiiidd
;   ..iidddddidiiiidiwiiiidiiiidddddid..
;   .wid.....idddiidiwiiiidddiid....iid.
;   .iid....wid..widiwiiwid..wid....iid.
;   .iid....wid..widiwiiwid..wid....iid.
;   .did....wid..widdwwdwid..wid....did.
;   ..d......w....widwwdiw....w......d..
;   .......ddddddddddwidddddddddd.......
;   ..............iiiwiiid..............
;   ..............iiiwiiid..............
;   ..............diiwiiid..............
;   ...............iwwwdd...............
;   ...............diwdid...............
;   ................dddd................
;   .................dd.................
;   ....................................
; -----------------------------------------------------------------------------
spr_boss3_tm
PTR_BOSS3_TM = SPR_PTR0 + (spr_boss3_tm - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr ".....wd....."     ;  1
        +spr ".wwwwiiwwwd."     ;  2
        +spr "wiiiiiiiiiid"     ;  3
        +spr "ddiiiiiiiidd"     ;  4
        +spr "..ddiiiidd.."     ;  5
        +spr "....iiid...."     ;  6
        +spr "....iiid...."     ;  7
        +spr "....iwid...."     ;  8
        +spr "....iwid...."     ;  9
        +spr "....iwid...."     ; 10
        +spr "....iwid...."     ; 11
        +spr "....iwid...."     ; 12
        +spr "....iwid...."     ; 13
        +spr "...wiwiid..."     ; 14
        +spr "...iiwiid..."     ; 15
        +spr "...iiwiid..."     ; 16
        +spr "...iiwiid..."     ; 17
        +spr "...iiwiid..."     ; 18
        +spr "...iiwiid..."     ; 19
        +spr "...iiwiid..."     ; 20
        +spr_end

spr_boss3_bl
PTR_BOSS3_BL = SPR_PTR0 + (spr_boss3_bl - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr "wwwwwwwwwwww"     ;  3
        +spr "iiiiiiiiiidi"     ;  4
        +spr "ddiiiiiiiidi"     ;  5
        +spr "..iidddddidi"     ;  6
        +spr ".wid.....idd"     ;  7
        +spr ".iid....wid."     ;  8
        +spr ".iid....wid."     ;  9
        +spr ".did....wid."     ; 10
        +spr "..d......w.."     ; 11
        +spr ".......ddddd"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss3_bm
PTR_BOSS3_BM = SPR_PTR0 + (spr_boss3_bm - SPRITES) / 64
        +spr_begin
        +spr "..wiiwiiid.."     ;  0
        +spr "..iiiwiiid.."     ;  1
        +spr ".wiiiwiiiid."     ;  2
        +spr "wiiiiwiiiiiw"     ;  3
        +spr "iiidiwiiiidi"     ;  4
        +spr "iiidiwiiiidi"     ;  5
        +spr "iiidiwiiiidi"     ;  6
        +spr "diidiwiiiidd"     ;  7
        +spr ".widiwiiwid."     ;  8
        +spr ".widiwiiwid."     ;  9
        +spr ".widdwwdwid."     ; 10
        +spr "..widwwdiw.."     ; 11
        +spr "dddddwiddddd"     ; 12
        +spr "..iiiwiiid.."     ; 13
        +spr "..iiiwiiid.."     ; 14
        +spr "..diiwiiid.."     ; 15
        +spr "...iwwwdd..."     ; 16
        +spr "...diwdid..."     ; 17
        +spr "....dddd...."     ; 18
        +spr ".....dd....."     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss3_br
PTR_BOSS3_BR = SPR_PTR0 + (spr_boss3_br - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr "wwwwwwwwwwwd"     ;  3
        +spr "iiidiiiiiiid"     ;  4
        +spr "iiidiiiiiidd"     ;  5
        +spr "iiidddddid.."     ;  6
        +spr "diid....iid."     ;  7
        +spr ".wid....iid."     ;  8
        +spr ".wid....iid."     ;  9
        +spr ".wid....did."     ; 10
        +spr "..w......d.."     ; 11
        +spr "ddddd......."     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Diver: gull-winged dive bomber with fixed landing gear, nose DOWN, lit
; from the top left. Rows 0-14 (ENEMY_H).
; -----------------------------------------------------------------------------
spr_diver
PTR_DIVER = SPR_PTR0 + (spr_diver - SPRITES) / 64
        +spr_begin
        +spr "...dwwwd...."     ;  0
        +spr ".....ii....."     ;  1
        +spr ".....ii....."     ;  2
        +spr ".....ii....."     ;  3
        +spr "....dwwd...."     ;  4
        +spr "....dwid...."     ;  5
        +spr "dw...ii...wd"     ;  6
        +spr "iiw.iiii.wii"     ;  7
        +spr "iiiiiiiiiiid"     ;  8
        +spr ".ddiiiiiidd."     ;  9
        +spr "..d.wiid.d.."     ; 10
        +spr "..d.iiid.d.."     ; 11
        +spr "....iiid...."     ; 12
        +spr "...dddddd..."     ; 13
        +spr "....d..d...."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Boss 4 "Kraken": the enemy flagship, a battleship seen from above, bow LEFT,
; lit from the top left: three twin-gun turrets (A and B forward, X aft),
; the bridge tower and funnel amidships, secondary guns along the sides, a
; bow wave. Three X+Y expanded sprites side by side (144x42 px), drawn as one
; 36x21-pixel picture (made with a script, then kept here as the master copy).
;
;   ....................................
;   ....................................
;   ........wwwwwwwwwwwwwwwwwwwwwwwwd...
;   .......wiiiiiiiiiiiiiiiiiiiiiiiiid..
;   ......dwiiiidwiiiiidwiiiiiiiidwiiid.
;   .....wiiiiiiiiiiiiiiiiiiiiiiiiiiiid.
;   ....wiiiiiiiiiiiiiiiiiwwdiiiiiiiiid.
;   w.wwiiiiiiiiiiiiiiiiiiwidiiiiiiiiidw
;   .wwiiiiiiiiddiiiiiddiiwdddiiddiiiidw
;   .wiiiddddidwddddidwiiiwiddidwiiidddd
;   diiiiiiiidwiiididwiiidwididwiiidiiid
;   .diiiddddididdddidiidiwdddidiididddd
;   .wdiiiiiiiiddiiiiiddiiwiddiiddiiiiid
;   w.wdiiiiiiiiiiiiiiiiiiwdddiiiiiiiid.
;   ....diiiiiiiiiiiiiiiiiwidiiiiiiiiid.
;   .....diiiiiiiiiiiiiiiiwddiiiiiiiiid.
;   ......ddiiiiddiiiiiddiiiiiiiiddiiid.
;   .......diiiiiiiiiiiiiiiiiiiiiiiiid..
;   ........ddddddddddddddddddddddddd...
;   ....................................
;   ....................................
; -----------------------------------------------------------------------------
spr_boss4_l
PTR_BOSS4_L = SPR_PTR0 + (spr_boss4_l - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "........wwww"     ;  2
        +spr ".......wiiii"     ;  3
        +spr "......dwiiii"     ;  4
        +spr ".....wiiiiii"     ;  5
        +spr "....wiiiiiii"     ;  6
        +spr "w.wwiiiiiiii"     ;  7
        +spr ".wwiiiiiiiid"     ;  8
        +spr ".wiiiddddidw"     ;  9
        +spr "diiiiiiiidwi"     ; 10
        +spr ".diiiddddidi"     ; 11
        +spr ".wdiiiiiiiid"     ; 12
        +spr "w.wdiiiiiiii"     ; 13
        +spr "....diiiiiii"     ; 14
        +spr ".....diiiiii"     ; 15
        +spr "......ddiiii"     ; 16
        +spr ".......diiii"     ; 17
        +spr "........dddd"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss4_m
PTR_BOSS4_M = SPR_PTR0 + (spr_boss4_m - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "wwwwwwwwwwww"     ;  2
        +spr "iiiiiiiiiiii"     ;  3
        +spr "dwiiiiidwiii"     ;  4
        +spr "iiiiiiiiiiii"     ;  5
        +spr "iiiiiiiiiiww"     ;  6
        +spr "iiiiiiiiiiwi"     ;  7
        +spr "diiiiiddiiwd"     ;  8
        +spr "ddddidwiiiwi"     ;  9
        +spr "iididwiiidwi"     ; 10
        +spr "ddddidiidiwd"     ; 11
        +spr "diiiiiddiiwi"     ; 12
        +spr "iiiiiiiiiiwd"     ; 13
        +spr "iiiiiiiiiiwi"     ; 14
        +spr "iiiiiiiiiiwd"     ; 15
        +spr "ddiiiiiddiii"     ; 16
        +spr "iiiiiiiiiiii"     ; 17
        +spr "dddddddddddd"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss4_r
PTR_BOSS4_R = SPR_PTR0 + (spr_boss4_r - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "wwwwwwwwd..."     ;  2
        +spr "iiiiiiiiid.."     ;  3
        +spr "iiiiidwiiid."     ;  4
        +spr "iiiiiiiiiid."     ;  5
        +spr "diiiiiiiiid."     ;  6
        +spr "diiiiiiiiidw"     ;  7
        +spr "ddiiddiiiidw"     ;  8
        +spr "ddidwiiidddd"     ;  9
        +spr "didwiiidiiid"     ; 10
        +spr "ddidiididddd"     ; 11
        +spr "ddiiddiiiiid"     ; 12
        +spr "ddiiiiiiiid."     ; 13
        +spr "diiiiiiiiid."     ; 14
        +spr "diiiiiiiiid."     ; 15
        +spr "iiiiiddiiid."     ; 16
        +spr "iiiiiiiiid.."     ; 17
        +spr "ddddddddd..."     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Ace (level 4): a late-war fighter, nose DOWN: a long nose, clipped wings,
; a big propeller. Lit from the top left. Rows 0-14 (ENEMY_H).
; -----------------------------------------------------------------------------
spr_ace
PTR_ACE = SPR_PTR0 + (spr_ace - SPRITES) / 64
        +spr_begin
        +spr "....dwwd...."     ;  0
        +spr ".....ii....."     ;  1
        +spr ".....ii....."     ;  2
        +spr ".....ii....."     ;  3
        +spr "....dwwd...."     ;  4
        +spr "....dwid...."     ;  5
        +spr "dwwwwiiwwwwd"     ;  6
        +spr "diiiiiiiiiid"     ;  7
        +spr ".dddiiiiddd."     ;  8
        +spr ".....ii....."     ;  9
        +spr ".....ii....."     ; 10
        +spr "....wiid...."     ; 11
        +spr "....wiid...."     ; 12
        +spr "..dddddddd.."     ; 13
        +spr ".....dd....."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Explosion sequence (enemies, the player, boss parts): 1 flash, 2 fireball,
; 3 = expl_b (the big ring), 4 breaking up into smoke, 5 smoke puffs, 6 the
; last wisps. Its 'i' colour goes yellow -> orange -> red (expl_cols in
; src/enemies.asm). Drawn in rows 0-11 (the planes reach row 14, so a
; fireball sits 1-2 pixels above a plane's centre).
; -----------------------------------------------------------------------------
spr_expl_1
PTR_EXPL_1 = SPR_PTR0 + (spr_expl_1 - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr ".....ww....."     ;  2
        +spr "....wwww...."     ;  3
        +spr "...wwiiww..."     ;  4
        +spr "...wiiiiw..."     ;  5
        +spr "...wiiiiw..."     ;  6
        +spr "...wwiiww..."     ;  7
        +spr "....wwww...."     ;  8
        +spr ".....ww....."     ;  9
        +spr "............"     ; 10
        +spr "............"     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end
spr_expl_2
PTR_EXPL_2 = SPR_PTR0 + (spr_expl_2 - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "....i..i...."     ;  1
        +spr "...iiwwii..."     ;  2
        +spr "..iiwwwwii.."     ;  3
        +spr ".iiwwwwwwii."     ;  4
        +spr "..iwwwwwwi.."     ;  5
        +spr "..iwwwwwwi.."     ;  6
        +spr ".iiwwwwwwii."     ;  7
        +spr "..iiwwwwii.."     ;  8
        +spr "...iiwwii..."     ;  9
        +spr "....i..i...."     ; 10
        +spr "............"     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end
spr_expl_4
PTR_EXPL_4 = SPR_PTR0 + (spr_expl_4 - SPRITES) / 64
        +spr_begin
        +spr ".d...ii...d."     ;  0
        +spr "...ii..ii..."     ;  1
        +spr "..i.dddd.i.."     ;  2
        +spr ".i.dd..dd.i."     ;  3
        +spr "i.dd.ii.dd.i"     ;  4
        +spr ".dd.i..i.dd."     ;  5
        +spr ".dd.i..i.dd."     ;  6
        +spr "i.dd.ii.dd.i"     ;  7
        +spr ".i.dd..dd.i."     ;  8
        +spr "..i.dddd.i.."     ;  9
        +spr "...ii..ii..."     ; 10
        +spr ".d...ii...d."     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end
spr_expl_5
PTR_EXPL_5 = SPR_PTR0 + (spr_expl_5 - SPRITES) / 64
        +spr_begin
        +spr "..dd....dd.."     ;  0
        +spr ".d..d..d..d."     ;  1
        +spr ".d..d..d..d."     ;  2
        +spr "..dd.dd.dd.."     ;  3
        +spr "....d..d...."     ;  4
        +spr ".dd.d..d.dd."     ;  5
        +spr "d..d.dd.d..d"     ;  6
        +spr "d..d....d..d"     ;  7
        +spr ".dd..dd..dd."     ;  8
        +spr "....d..d...."     ;  9
        +spr "....d..d...."     ; 10
        +spr ".....dd....."     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end
spr_expl_6
PTR_EXPL_6 = SPR_PTR0 + (spr_expl_6 - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "..d......d.."     ;  1
        +spr "............"     ;  2
        +spr ".....d......"     ;  3
        +spr "...d....d..."     ;  4
        +spr "............"     ;  5
        +spr "............"     ;  6
        +spr "..d..d.....d"     ;  7
        +spr "............"     ;  8
        +spr "......d....."     ;  9
        +spr ".d........d."     ; 10
        +spr "............"     ; 11
        +spr "............"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; HUD shapes: 8 blank sprites that src/hud.asm draws into at run time (hires,
; glyphs copied from the charset): score (2), lives, boss bar, message (4).
; -----------------------------------------------------------------------------
hud_shapes
PTR_HUD = SPR_PTR0 + (hud_shapes - SPRITES) / 64
        !fill HUD_SLOTS * 64, 0

sprites_end
