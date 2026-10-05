; =============================================================================
; data/sfx.asm - sound effects (played by src/sfx.asm)
; =============================================================================
;
;   +sfx_start
;   +boom FRAME, VOICE, WAVE, FREQ, AD, SR, SLIDE
;     FRAME  frame number from the start of the effect (ascending)
;     VOICE  0-2. In-game effects use only voice 2 (SID voice 3, which the
;            music lends out); 0-1 only with the music stopped (boss boom)
;     WAVE   SFX_NOISE, SFX_TRI or SFX_SAW
;     FREQ   frequency high byte: low = deep rumble, high = sharp crack.
;            For a tone, note frequency (Hz) * 17.03 / 256 (PAL)
;     AD/SR  SID envelope: attack 0 + a long decay, sustain 0, makes a boom
;            (decay 2 = 48 ms, 6 = 0.2 s, 8 = 0.3 s, 9 = 0.75 s, 10 = 1.5 s,
;            11 = 2.4 s)
;     SLIDE  0 or negative: added to FREQ every frame (pitch falls)
;   +sfx_end FRAME   the effect is over; voice 3 goes back to the drums.
;                    Keep in-game effects short: the drums are out meanwhile.
; =============================================================================

SFX_NOISE = $80
SFX_TRI   = $10
SFX_SAW   = $20

SFX_BOSS_BOOM  = 0
SFX_ENEMY_BOOM = 1
SFX_PLAYER_DIE = 2
SFX_MEDAL      = 3
SFX_BOSS_HIT   = 4
SFX_COUNT      = 5

sfx_table_lo   !byte <sfx_boss_boom, <sfx_enemy_boom, <sfx_player_die, <sfx_medal, <sfx_boss_hit
sfx_table_hi   !byte >sfx_boss_boom, >sfx_enemy_boom, >sfx_player_die, >sfx_medal, >sfx_boss_hit
; Priority: a new effect doesn't interrupt a more important one.
sfx_table_prio !byte 4,              1,               3,               2,          0

; -----------------------------------------------------------------------------
; Boss destroyed: matches the 100-frame explosion flicker in boss.asm.
; A huge blast with a sub-bass rumble, five smaller blasts as the parts break
; up, then a final blast with another rumble.
; -----------------------------------------------------------------------------
sfx_boss_boom
        +sfx_start
        +boom  0, 0, SFX_NOISE, $18, $0b, $00, -1   ; first blast, falling
        +boom  0, 1, SFX_TRI,   $03, $0a, $00,  0   ; sub-bass rumble
        +boom 12, 2, SFX_NOISE, $30, $08, $00, -2   ; secondary blasts...
        +boom 28, 2, SFX_NOISE, $24, $08, $00, -2
        +boom 40, 0, SFX_NOISE, $20, $09, $00, -1
        +boom 56, 2, SFX_NOISE, $2c, $08, $00, -2
        +boom 70, 2, SFX_NOISE, $1c, $08, $00, -2
        +boom 86, 0, SFX_NOISE, $28, $0c, $00, -1   ; final blast (long tail)
        +boom 86, 1, SFX_TRI,   $02, $0c, $00,  0   ; and a last deep rumble
        +sfx_end 130

; -----------------------------------------------------------------------------
; Enemy destroyed (shot down, or rammed): a short crack with a falling pitch.
; -----------------------------------------------------------------------------
sfx_enemy_boom
        +sfx_start
        +boom  0, 2, SFX_NOISE, $28, $08, $00, -2
        +sfx_end 18

; -----------------------------------------------------------------------------
; Player shot down: a longer, lower blast, then a second one as the ship
; breaks up. Ends with the 75-frame explosion (DEATH_FRAMES).
; -----------------------------------------------------------------------------
sfx_player_die
        +sfx_start
        +boom  0, 2, SFX_NOISE, $1c, $0a, $00, -1
        +boom 20, 2, SFX_NOISE, $14, $0a, $00, -1
        +sfx_end 72

; -----------------------------------------------------------------------------
; Medal collected: a bright two-note chime, B-5 then E-6 (sawtooth).
; -----------------------------------------------------------------------------
sfx_medal
        +sfx_start
        +boom  0, 2, SFX_SAW,   $42, $06, $00,  0   ; B-5 (988 Hz)
        +boom  5, 2, SFX_SAW,   $58, $09, $00,  0   ; E-6 (1319 Hz), rings out
        +sfx_end 36

; -----------------------------------------------------------------------------
; Boss hit by a bullet: a tiny click, so hits register. Very short, because
; hits come several times a second and each one mutes the drums.
; -----------------------------------------------------------------------------
sfx_boss_hit
        +sfx_start
        +boom  0, 2, SFX_NOISE, $50, $02, $00,  0
        +sfx_end 3
