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
; Player ship: twin-boom fighter, nose up. Drawn in rows 1-13, so the hitbox
; is about 12x13 MC pixels (24x13 screen pixels). See PLAYER_H in player.asm.
; -----------------------------------------------------------------------------
spr_ship
PTR_SHIP = SPR_PTR0 + (spr_ship - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr ".....ww....."     ;  1  nose / canopy
        +spr "..d..ii..d.."     ;  2  propellers
        +spr ".wiw.ii.wiw."     ;  3  engines
        +spr ".wiw.ii.wiw."     ;  4
        +spr "iiiiiwwiiiii"     ;  5  wing
        +spr "iiiiiwwiiiii"     ;  6
        +spr "ddiddiiddidd"     ;  7  wing trailing edge
        +spr "..i..ii..i.."     ;  8  booms
        +spr "..i..dd..i.."     ;  9
        +spr "..i......i.."     ; 10
        +spr "..i......i.."     ; 11
        +spr ".wiw....wiw."     ; 12  tail fins
        +spr ".diiiiiiiid."     ; 13  tailplane
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
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
; Drawn in rows 0-11, so ENEMY_H = 12.
; -----------------------------------------------------------------------------
spr_fighter
PTR_FIGHTER = SPR_PTR0 + (spr_fighter - SPRITES) / 64
        +spr_begin
        +spr "....dddd...."     ;  0  tailplane
        +spr ".....ii....."     ;  1
        +spr ".....ii....."     ;  2  fuselage
        +spr ".....ww....."     ;  3  canopy
        +spr "iiiiiiiiiiii"     ;  4  wing
        +spr "iiwiiiiiiwii"     ;  5  roundels
        +spr ".iiiiiiiiii."     ;  6
        +spr ".....ii....."     ;  7
        +spr ".....ii....."     ;  8
        +spr "....wiiw...."     ;  9  cowling
        +spr "....dddd...."     ; 10  propeller
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
; Enemy leader: twin engine, nose DOWN. Drawn in rows 0-11, so ENEMY_H = 12.
; -----------------------------------------------------------------------------
spr_leader
PTR_LEADER = SPR_PTR0 + (spr_leader - SPRITES) / 64
        +spr_begin
        +spr "...dddddd..."     ;  0  tailplane
        +spr ".....ii....."     ;  1
        +spr ".....ii....."     ;  2  fuselage
        +spr ".....ww....."     ;  3  canopy
        +spr "iiiiiiiiiiii"     ;  4  wing
        +spr "iwiiiiiiiiwi"     ;  5
        +spr "iiiiiiiiiiii"     ;  6
        +spr ".i..wiiw..i."     ;  7  engines
        +spr ".i...ii...i."     ;  8
        +spr ".d...ii...d."     ;  9  propellers
        +spr ".....ii....."     ; 10
        +spr ".....dd....."     ; 11  nose
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
; Explosion, first shape: tight white-hot burst. Shared by enemies and the
; player (colour COL_EXPLOSION). Centred in the 12x12 area the planes use.
; -----------------------------------------------------------------------------
spr_expl_a
PTR_EXPL_A = SPR_PTR0 + (spr_expl_a - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "....w..w...."     ;  2
        +spr ".....ii....."     ;  3
        +spr "...wiwwiw..."     ;  4
        +spr "....iwwi...."     ;  5
        +spr "....iwwi...."     ;  6
        +spr "...wiwwiw..."     ;  7
        +spr ".....ii....."     ;  8
        +spr "....w..w...."     ;  9
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
; Boss 1 "Thunder": a four-engine heavy bomber, nose DOWN. Three sprites side
; by side (left, middle, right), each X+Y expanded (48x42 px), so the whole
; boss is 144x42 px. Drawn as one 36-pixel-wide picture split in three:
;
;   ...........dddddddddddddd...........
;   ...........diiiiiiiiiiiid...........
;   .............dddiiiiddd.............
;   ................diid................
;   ................diid................
;   ................diid................
;   ...............diiiid...............
;   .diiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiid.
;   diiiiwwiiiiwwiiiiiiiiiiwwiiiiwwiiiid
;   iiiiiwwiiiiwwiiiiiiiiiiwwiiiiwwiiiii
;   diiiiwwiiiiwwiiiiiiiiiiwwiiiiwwiiiid
;   ....iwwi..iwwi.iiiiii.iwwi..iwwi....
;   ....dddd..dddd.iwwwwi.dddd..dddd....
;   ................iwwi................
;   ................iiii................
;   ................diid................
;   .................dd.................
; -----------------------------------------------------------------------------
spr_boss1_l
PTR_BOSS1_L = SPR_PTR0 + (spr_boss1_l - SPRITES) / 64
        +spr_begin
        +spr "...........d"     ;  0
        +spr "...........d"     ;  1
        +spr "............"     ;  2
        +spr "............"     ;  3
        +spr "............"     ;  4
        +spr "............"     ;  5
        +spr "............"     ;  6
        +spr ".diiiiiiiiii"     ;  7
        +spr "diiiiwwiiiiw"     ;  8
        +spr "iiiiiwwiiiiw"     ;  9
        +spr "diiiiwwiiiiw"     ; 10
        +spr "....iwwi..iw"     ; 11
        +spr "....dddd..dd"     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss1_m
PTR_BOSS1_M = SPR_PTR0 + (spr_boss1_m - SPRITES) / 64
        +spr_begin
        +spr "dddddddddddd"     ;  0
        +spr "iiiiiiiiiiii"     ;  1
        +spr ".dddiiiiddd."     ;  2
        +spr "....diid...."     ;  3
        +spr "....diid...."     ;  4
        +spr "....diid...."     ;  5
        +spr "...diiiid..."     ;  6
        +spr "iiiiiiiiiiii"     ;  7
        +spr "wiiiiiiiiiiw"     ;  8
        +spr "wiiiiiiiiiiw"     ;  9
        +spr "wiiiiiiiiiiw"     ; 10
        +spr "wi.iiiiii.iw"     ; 11
        +spr "dd.iwwwwi.dd"     ; 12
        +spr "....iwwi...."     ; 13
        +spr "....iiii...."     ; 14
        +spr "....diid...."     ; 15
        +spr ".....dd....."     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss1_r
PTR_BOSS1_R = SPR_PTR0 + (spr_boss1_r - SPRITES) / 64
        +spr_begin
        +spr "d..........."     ;  0
        +spr "d..........."     ;  1
        +spr "............"     ;  2
        +spr "............"     ;  3
        +spr "............"     ;  4
        +spr "............"     ;  5
        +spr "............"     ;  6
        +spr "iiiiiiiiiid."     ;  7
        +spr "wiiiiwwiiiid"     ;  8
        +spr "wiiiiwwiiiii"     ;  9
        +spr "wiiiiwwiiiid"     ; 10
        +spr "wi..iwwi...."     ; 11
        +spr "dd..dddd...."     ; 12
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
; Boss 2 "Leviathan": an armoured airship seen broadside (nose left, fins
; right), with two engine pods and a gun gondola. Three X+Y expanded sprites,
; drawn as one 36-pixel-wide picture split in three:
;
;   ...............................ddddd
;   ..........dddddddddddddd.....ddiiiid
;   ......ddddwwwwwwwwwwwwwwdddddidddddd
;   ....ddiiiwiiwiiwiiwiiwiiiiiiid......
;   ..ddiiiiiiiiiiiiiiiiiiiiiiiiiidd....
;   .diiiiiiiiiiiiiiiiiiiiiiiiiiiiiid...
;   .diiiiiiiiiiiiiiiiiiiiiiiiiiiiiid...
;   .diiiiiiiiiiiiiiiiiiiiiiiiiiiiiid...
;   ..ddiiiiiiiiiiiiiiiiiiiiiiiiiidd....
;   ....ddiiiiiiiiiiiiiiiiiiiiiiid......
;   ......ddddiiiiiiiiiiiiiidddddidddddd
;   ..........dddddddddddddd.....ddiiiid
;   .....diiid...dddddddd...diiid..ddddd
;   .....iwwwi...diwwwwid...iwwwi.......
;   .....ddddd...diiiiiid...ddddd.......
;   ..............dddddd................
; -----------------------------------------------------------------------------
spr_boss2_l
PTR_BOSS2_L = SPR_PTR0 + (spr_boss2_l - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "..........dd"     ;  1
        +spr "......ddddww"     ;  2
        +spr "....ddiiiwii"     ;  3
        +spr "..ddiiiiiiii"     ;  4
        +spr ".diiiiiiiiii"     ;  5
        +spr ".diiiiiiiiii"     ;  6
        +spr ".diiiiiiiiii"     ;  7
        +spr "..ddiiiiiiii"     ;  8
        +spr "....ddiiiiii"     ;  9
        +spr "......ddddii"     ; 10
        +spr "..........dd"     ; 11
        +spr ".....diiid.."     ; 12
        +spr ".....iwwwi.."     ; 13
        +spr ".....ddddd.."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss2_m
PTR_BOSS2_M = SPR_PTR0 + (spr_boss2_m - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "dddddddddddd"     ;  1
        +spr "wwwwwwwwwwww"     ;  2
        +spr "wiiwiiwiiwii"     ;  3
        +spr "iiiiiiiiiiii"     ;  4
        +spr "iiiiiiiiiiii"     ;  5
        +spr "iiiiiiiiiiii"     ;  6
        +spr "iiiiiiiiiiii"     ;  7
        +spr "iiiiiiiiiiii"     ;  8
        +spr "iiiiiiiiiiii"     ;  9
        +spr "iiiiiiiiiiii"     ; 10
        +spr "dddddddddddd"     ; 11
        +spr ".dddddddd..."     ; 12
        +spr ".diwwwwid..."     ; 13
        +spr ".diiiiiid..."     ; 14
        +spr "..dddddd...."     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss2_r
PTR_BOSS2_R = SPR_PTR0 + (spr_boss2_r - SPRITES) / 64
        +spr_begin
        +spr ".......ddddd"     ;  0
        +spr ".....ddiiiid"     ;  1
        +spr "dddddidddddd"     ;  2
        +spr "iiiiid......"     ;  3
        +spr "iiiiiidd...."     ;  4
        +spr "iiiiiiiid..."     ;  5
        +spr "iiiiiiiid..."     ;  6
        +spr "iiiiiiiid..."     ;  7
        +spr "iiiiiidd...."     ;  8
        +spr "iiiiid......"     ;  9
        +spr "dddddidddddd"     ; 10
        +spr ".....ddiiiid"     ; 11
        +spr "diiid..ddddd"     ; 12
        +spr "iwwwi......."     ; 13
        +spr "ddddd......."     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

; -----------------------------------------------------------------------------
; Raider: twin-tail fighter, nose DOWN. Rows 0-11 (ENEMY_H).
; -----------------------------------------------------------------------------
spr_raider
PTR_RAIDER = SPR_PTR0 + (spr_raider - SPRITES) / 64
        +spr_begin
        +spr "..dd....dd.."     ;  0  twin tails
        +spr "..ii....ii.."     ;  1
        +spr "..iiiiiiii.."     ;  2  tailplane
        +spr ".....ii....."     ;  3
        +spr ".....ii....."     ;  4
        +spr "iiiiiiiiiiii"     ;  5  wing
        +spr "diiiiwwiiiid"     ;  6  canopy
        +spr ".diiiiiiiid."     ;  7
        +spr ".....ii....."     ;  8
        +spr "....iwwi...."     ;  9  cowling
        +spr ".....dd....."     ; 10  propeller
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
; Raider climbing from behind: the same plane, nose UP. Rows 0-11.
; -----------------------------------------------------------------------------
spr_raider_up
PTR_RAIDER_UP = SPR_PTR0 + (spr_raider_up - SPRITES) / 64
        +spr_begin
        +spr ".....dd....."     ;  0  propeller
        +spr "....iwwi...."     ;  1  cowling
        +spr ".....ii....."     ;  2
        +spr ".diiiiiiiid."     ;  3
        +spr "diiiiwwiiiid"     ;  4  canopy
        +spr "iiiiiiiiiiii"     ;  5  wing
        +spr ".....ii....."     ;  6
        +spr ".....ii....."     ;  7
        +spr "..iiiiiiii.."     ;  8  tailplane
        +spr "..ii....ii.."     ;  9
        +spr "..dd....dd.."     ; 10  twin tails
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
; Gunship: heavy twin-engine fighter, nose DOWN. Rows 0-11.
; -----------------------------------------------------------------------------
spr_gunship
PTR_GUNSHIP = SPR_PTR0 + (spr_gunship - SPRITES) / 64
        +spr_begin
        +spr "....dddd...."     ;  0  tailplane
        +spr ".....ii....."     ;  1
        +spr "..iiiiiiii.."     ;  2
        +spr ".....ii....."     ;  3
        +spr "wiiiiiiiiiiw"     ;  4  wing
        +spr "iiiiiiiiiiii"     ;  5
        +spr "idwiiwwiiwdi"     ;  6  engines + canopy
        +spr ".d.iiiiii.d."     ;  7
        +spr ".d..iwwi..d."     ;  8  nose
        +spr ".i...ii...i."     ;  9
        +spr ".d...dd...d."     ; 10  propellers
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
; Boss 3 "Albatross": a giant four-engine flying boat, nose DOWN, with a
; T-tail, a boat hull and wingtip floats. Three X+Y expanded sprites, drawn
; as one 36-pixel-wide picture split in three:
;
;   .............dddddddddd.............
;   .............diiiiiiiid.............
;   ................diid................
;   ...............diiiid...............
;   ...............diiiid...............
;   dddddddddddddddddddddddddddddddddddd
;   diiiiwwwiiiwwwiiiiiiiiwwwiiiwwwiiiid
;   iiiiiiwiiiiiwiiiiiiiiiiwiiiiiwiiiiii
;   diiiiiwiiiiiwiiiiiiiiiiwiiiiiwiiiiid
;   .ddddddddddddddiiiiiidddddddddddddd.
;   d.d..iwi...iwidiiiiiidiwi...iwi..d.d
;   did..ddd...ddddiiiiiidddd...ddd..did
;   ddd...........diiiiiid...........ddd
;   ..............diiiiiid..............
;   ..............diwwwwid..............
;   ...............diiiid...............
;   ................dddd................
; -----------------------------------------------------------------------------
spr_boss3_l
PTR_BOSS3_L = SPR_PTR0 + (spr_boss3_l - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr "............"     ;  3
        +spr "............"     ;  4
        +spr "dddddddddddd"     ;  5
        +spr "diiiiwwwiiiw"     ;  6
        +spr "iiiiiiwiiiii"     ;  7
        +spr "diiiiiwiiiii"     ;  8
        +spr ".ddddddddddd"     ;  9
        +spr "d.d..iwi...i"     ; 10
        +spr "did..ddd...d"     ; 11
        +spr "ddd........."     ; 12
        +spr "............"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss3_m
PTR_BOSS3_M = SPR_PTR0 + (spr_boss3_m - SPRITES) / 64
        +spr_begin
        +spr ".dddddddddd."     ;  0
        +spr ".diiiiiiiid."     ;  1
        +spr "....diid...."     ;  2
        +spr "...diiiid..."     ;  3
        +spr "...diiiid..."     ;  4
        +spr "dddddddddddd"     ;  5
        +spr "wwiiiiiiiiww"     ;  6
        +spr "wiiiiiiiiiiw"     ;  7
        +spr "wiiiiiiiiiiw"     ;  8
        +spr "dddiiiiiiddd"     ;  9
        +spr "widiiiiiidiw"     ; 10
        +spr "dddiiiiiiddd"     ; 11
        +spr "..diiiiiid.."     ; 12
        +spr "..diiiiiid.."     ; 13
        +spr "..diwwwwid.."     ; 14
        +spr "...diiiid..."     ; 15
        +spr "....dddd...."     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss3_r
PTR_BOSS3_R = SPR_PTR0 + (spr_boss3_r - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr "............"     ;  3
        +spr "............"     ;  4
        +spr "dddddddddddd"     ;  5
        +spr "wiiiwwwiiiid"     ;  6
        +spr "iiiiiwiiiiii"     ;  7
        +spr "iiiiiwiiiiid"     ;  8
        +spr "ddddddddddd."     ;  9
        +spr "i...iwi..d.d"     ; 10
        +spr "d...ddd..did"     ; 11
        +spr ".........ddd"     ; 12
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
; Diver: gull-winged dive bomber with fixed landing gear, nose DOWN.
; Rows 0-11 (ENEMY_H).
; -----------------------------------------------------------------------------
spr_diver
PTR_DIVER = SPR_PTR0 + (spr_diver - SPRITES) / 64
        +spr_begin
        +spr ".....dd....."     ;  0  tail fin
        +spr "...iiiiii..."     ;  1  tailplane
        +spr ".....ii....."     ;  2
        +spr ".....ii....."     ;  3
        +spr "i....ww....i"     ;  4  gull wings: tips up
        +spr "ii..iiii..ii"     ;  5
        +spr ".iiiiiiiiii."     ;  6
        +spr "..ii.ii.ii.."     ;  7  fixed gear
        +spr "..dd.ii.dd.."     ;  8  wheel spats
        +spr "....iwwi...."     ;  9  cowling
        +spr ".....dd....."     ; 10  propeller
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
; Boss 4 "Kraken": the enemy flagship, a battleship seen broadside (bow left),
; with two forward turrets, an aft turret, the bridge and funnel, and its
; bow wave and wake. Three X+Y expanded sprites, drawn as one 36-pixel-wide
; picture split in three:
;
;   .........ddddddddddddddddddddddd....
;   .......ddiiiiiiiiiiiiiiddiiiiiiidd..
;   .....ddiiiiiiiiiiidwwwdddiiiiiiiid.w
;   w..ddiiiiwwwiiwwwiwwdwwiiiwwwiiiidww
;   wwdiiidddwdwddwdwiwdddwiiiwdwdddidw.
;   w.diiiiiiwwwiiwwwiwwdwwiiiwwwiiiidww
;   ...ddiiiiiiiiiiiiidwwwdiiiiiiiiiid.w
;   .....ddiiiiiiiiiiiiiiiiddiiiiiiiid..
;   .......ddiiiiiiiiiiiiiiiiiiiiiiiid..
;   .........ddiiiiiiiiiiiiiiiiiiiiidd..
;   ...........ddddddddddddddddddddd....
; -----------------------------------------------------------------------------
spr_boss4_l
PTR_BOSS4_L = SPR_PTR0 + (spr_boss4_l - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr ".........ddd"     ;  3
        +spr ".......ddiii"     ;  4
        +spr ".....ddiiiii"     ;  5
        +spr "w..ddiiiiwww"     ;  6
        +spr "wwdiiidddwdw"     ;  7
        +spr "w.diiiiiiwww"     ;  8
        +spr "...ddiiiiiii"     ;  9
        +spr ".....ddiiiii"     ; 10
        +spr ".......ddiii"     ; 11
        +spr ".........ddi"     ; 12
        +spr "...........d"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss4_m
PTR_BOSS4_M = SPR_PTR0 + (spr_boss4_m - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr "dddddddddddd"     ;  3
        +spr "iiiiiiiiiiid"     ;  4
        +spr "iiiiiidwwwdd"     ;  5
        +spr "iiwwwiwwdwwi"     ;  6
        +spr "ddwdwiwdddwi"     ;  7
        +spr "iiwwwiwwdwwi"     ;  8
        +spr "iiiiiidwwwdi"     ;  9
        +spr "iiiiiiiiiiid"     ; 10
        +spr "iiiiiiiiiiii"     ; 11
        +spr "iiiiiiiiiiii"     ; 12
        +spr "dddddddddddd"     ; 13
        +spr "............"     ; 14
        +spr "............"     ; 15
        +spr "............"     ; 16
        +spr "............"     ; 17
        +spr "............"     ; 18
        +spr "............"     ; 19
        +spr "............"     ; 20
        +spr_end

spr_boss4_r
PTR_BOSS4_R = SPR_PTR0 + (spr_boss4_r - SPRITES) / 64
        +spr_begin
        +spr "............"     ;  0
        +spr "............"     ;  1
        +spr "............"     ;  2
        +spr "dddddddd...."     ;  3
        +spr "diiiiiiidd.."     ;  4
        +spr "diiiiiiiid.w"     ;  5
        +spr "iiwwwiiiidww"     ;  6
        +spr "iiwdwdddidw."     ;  7
        +spr "iiwwwiiiidww"     ;  8
        +spr "iiiiiiiiid.w"     ;  9
        +spr "diiiiiiiid.."     ; 10
        +spr "iiiiiiiiid.."     ; 11
        +spr "iiiiiiiidd.."     ; 12
        +spr "dddddddd...."     ; 13
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
