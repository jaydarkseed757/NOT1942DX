; =============================================================================
; zp.asm - zero-page variable allocation
; KERNAL and BASIC are banked out after init, so $02-$FF is ours.
; =============================================================================

frame_flag    = $02     ; set to 1 by the raster IRQ, cleared by wait_frame
frame_count   = $03     ; free-running frame counter (wraps every 256 frames)
flip_pending  = $04     ; non-zero: IRQ writes next_d018 to $D018 this frame
next_d018     = $05     ; $D018 value to switch to on the next flip
front_buf     = $06     ; 0 = SCREEN_A is front, 1 = SCREEN_B is front
                        ;   ("front" = shown, or about to be shown at the
                        ;   next flip if flip_pending is set)

; ---- scroller (scroll.asm) ----
st_src        = $07     ; 16-bit: the map stream: next packed byte (scroll.asm)
lvl_row       = $09     ; 16-bit: the next char row to scroll in (0 = bottom
                        ;   of the level's picture)
scroll_fine   = $0b     ; fine scroll (yscroll) of the frame being shown, 0-7
scroll_slice  = $0c     ; next copy slice (0-5), 6 = all done this step

; ---- input (input.asm) ----
input_bits    = $0d     ; active-high: up/down/left/right/fire (joy layout)
input_prev    = $0e     ; input_bits from the previous frame
input_new     = $0f     ; bits that went down this frame (press edges)

zp_ptr0       = $10     ; general 16-bit pointers (lo/hi pairs)
zp_ptr1       = $12
zp_tmp0       = $14
zp_tmp1       = $15

; ---- level record handoff: scroller -> enemies ----
rec_ptr       = $16     ; 16-bit: start of the record fetch_record just read
rec_spawns    = $18     ; its spawn count, cleared once spawned
spawn_drops   = $19     ; spawns dropped because all 3 enemy slots were busy
zp_tmp2       = $1a     ; load_seg's control-byte budget

; ---- enemy_fire aiming scratch (ebullets.asm) ----
aim_slot      = $1b     ; saved enemy slot (X)
aim_bslot     = $1c     ; bullet slot being launched
aim_x         = $1d     ; |dx|, half-X units
aim_y         = $1e     ; |dy| / 2
aim_sx        = $1f     ; bit 7 = dx >= 0
aim_sy        = $41     ; bit 7 = dy >= 0
aim_l         = $42     ; larger of aim_x / aim_y
aim_s         = $43     ; smaller
aim_xmaj      = $44     ; 1 = horizontal-major
aim_t         = $45     ; temp

; ---- multiplexer (mux.asm). mux_s_* / mux_next are IRQ-owned ----
; Sprite slot tables (spr_xh, spr_y, ...) live in BSS (bss.asm).
mux_commit    = $20     ; 1 = a new display list is waiting for the IRQ
mux_p_base    = $21     ; the waiting list: first entry (0 or MUX_LIST)
mux_p_end     = $22     ;   one past its last entry
mux_p_en      = $23     ;   $D015 for its first 8 entries
mux_p_msb     = $24     ;   $D010 for its first 8 entries
mux_p_exp     = $25     ;   $D017/$D01D for its first 8 entries
mux_s_base    = $26     ; the list being shown (same layout)
mux_s_end     = $27
mux_s_en      = $28
mux_s_msb     = $29
mux_s_exp     = $2a
mux_next      = $2b     ; IRQ: next entry to write
mux_d010      = $2c     ; IRQ: $D010 as last written
mux_d017      = $2d     ; IRQ: $D017/$D01D as last written
mux_ti        = $2e     ; mux_build scratch: sort position
mux_tkey      = $2f     ;   key being inserted
mux_tv        = $30     ;   slot being inserted
mux_ty        = $31     ;   Y of the slot being placed
mux_te        = $32     ;   end line of the previous user of its hw sprite
mux_drops     = $33     ; sprites mux_build couldn't place (this frame)
mux_p_mc      = $35     ; waiting list: $D01C for its first 8 entries
mux_s_mc      = $36     ; list being shown: the same
mux_d01c      = $37     ; IRQ: $D01C as last written

; (enemy and enemy-bullet arrays live in BSS: bss.asm)
boss_xmax     = $34     ; boss.asm: rightmost X of the body (keeps it on screen)

; ---- sprite HUD (hud.asm) ----
hud_dirty     = $46     ; HUD_D_* bits: sprite shapes to redraw
hud_msg       = $47     ; message shown: HUD_MSG_* (0 = none)
hud_bar_n     = $48     ; boss bar: blocks filled
hud_src       = $49     ; 16-bit: glyph being drawn
hud_off       = $4b     ; its first byte in the shapes
hud_i         = $4c     ; char index
hud_n         = $4d     ; chars to draw
hud_gl        = $4e     ; $4e-$55: the glyph's 8 rows
hud_msg_timer = $56     ; frames until the message goes (0 = it stays)
hud_prev      = $57     ; $57-$5c: the score digits the sprites show
hud_msg_pos   = $5d     ; message chars typed so far
hud_msg_len   = $5e     ; ...out of this many

; ---- the level map stream (scroll.asm) and unpacking (unpack.asm) ----
st_loop       = $5f     ; 16-bit: the level's boss-loop stream (after the map)
st_wp         = $61     ; 16-bit: ring write pointer (RING..RING+RING_SIZE-1)
st_rp         = $63     ; 16-bit: ring read pointer of the match being copied
st_left       = $65     ; bytes left in the current literal run / match
st_mode       = $66     ; 0 = literal run, 1 = match
lz_mp         = $67     ; 16-bit: unpack's match source
st_out        = $69     ; chars of the next row in row_buf so far (0-40)
st_lim        = $6a     ; decode_some: stop at this count
mux_pin_dirty = $6b     ; mux.asm: display lists still to get new pinned entries
mux_pin_msb   = $6c     ;   the pinned entries' $D010 bits
mux_pin_mc    = $6d     ;   ...and $D01C bits
shake_timer   = $6e     ; frames of screen shake left (the IRQ counts it down)
fade_dir      = $6f     ; level.asm fades: 0 none, $FF in, 1 out
fade_k        = $70     ;   steps darker than the palette (0 = full colour)
; $38-$40, $71-$84 and $89 are free

; ---- player state (player.asm) ----
player_state  = $85     ; PS_ALIVE / PS_DEAD / PS_GAMEOVER
player_timer  = $86     ; PS_DEAD: frames until respawn / game over
invuln_timer  = $87     ; >0: blinking, collisions with the player skipped
lives         = $88     ; ships left, including the one in play

; ---- score (score.asm): BCD, high byte first, must stay adjacent ----
score_hi      = $8a     ; digits 1-2 (HH....)
score_mid     = $8b     ; digits 3-4 (..MM..)
score_lo      = $8c     ; digits 5-6 (....LL)
score_digits  = $8d     ; $8d-$92 six screen codes for printing

; ---- game mode (gameover.asm) ----
game_mode     = $93     ; GM_* (defs.asm): play, over, title, intro, ending
go_timer      = $94     ; GAME OVER: frames until fire is accepted

; ---- music player (music.asm). IRQ-only: main code must not touch these ----
music_on      = $95     ; 0 = player idle
music_ptr     = $96     ; 16-bit pattern read pointer
music_tmp     = $98
mv_ordl       = $99     ; $99-$9b order list pointer per voice (lo)
mv_ordh       = $9c     ; $9c-$9e                              (hi)
mv_ord0l      = $9f     ; $9f-$a1 order list start (for looping)
mv_ord0h      = $a2     ; $a2-$a4
mv_patl       = $a5     ; $a5-$a7 next event in the pattern (lo)
mv_path       = $a8     ; $a8-$aa                          (hi)
mv_timer      = $ab     ; $ab-$ad frames left in the current note/rest
mv_wave       = $ae     ; $ae-$b0 waveform bits (gate off)
mv_slide      = $b1     ; $b1-$b3 pitch slide per frame
mv_freqh      = $b4     ; $b4-$b6 frequency high byte shadow
mv_pwl        = $b7     ; $b7-$b9 pulse width shadow (lo)
mv_pwh        = $ba     ; $ba-$bc                    (hi)
mv_pwadd      = $bd     ; $bd-$bf pulse-width sweep per frame

; ---- level (level.asm) ----
level         = $c0     ; 0-3 current level
lvl_state     = $c1     ; LS_PLAY / LS_BOSS / LS_CLEAR / LS_NEXT
lvl_timer     = $c2
lvl_rows      = $c3     ; 16-bit: char rows in this level's picture
lvl_boss      = $c5     ; 16-bit: its boss row (the boss loop starts there)
wave_ptr      = $c7     ; 16-bit: the next wave (data/levelN_waves.asm)
boss_flag     = $c9     ; set by fetch_record when it passes +boss_here
intro_timer   = $ca
pal_bg        = $cb     ; current palette, used by init_video
pal_mc1       = $cc
pal_mc2       = $cd
                        ; $ce is free

; ---- boss (boss.asm) ----
boss_state    = $cf     ; BS_IDLE / BS_FIGHT / BS_DYING / BS_DONE
boss_idx      = $d0     ; which boss (0-3)
boss_hp       = $d1
boss_flash    = $d2     ; frames of hit flash left
boss_timer    = $d3     ; BS_DYING: frames left
boss_phase    = $d4     ; 0 = first script, 1 = phase-2 script
boss_col      = $d5     ; current body colour
boss_parts    = $d6     ; number of sprites in this boss (boss.asm)

; ---- gun position for enemy/boss shots (ebullets.asm) ----
aim_offx      = $d7     ; gun offset from the shooter (half-X)
aim_offy      = $d8     ; (pixels)
aim_gx        = $d9     ; gun position
aim_gy        = $da

; ---- sound effects (sfx.asm). IRQ-only, like the music player ----
sfx_on        = $db     ; 0 = no effect playing
sfx_frame     = $dc     ; frames since the effect started
sfx_ptr       = $dd     ; 16-bit: next boom in the list
sfx_slide     = $df     ; $df-$e1 pitch slide per voice (0 = none)
sfx_freqh     = $e2     ; $e2-$e4 frequency high byte shadow per voice
sfx_prio      = $f7     ; priority of the effect playing (sfx_table_prio)

; ---- ending (ending.asm) ----
next_d011     = $e5     ; $D011 value the IRQ writes with a flip (0 = none)
end_timer     = $e6
roll_k        = $e7     ; frame within a 16-frame roll step
roll_line     = $e8     ; text rows fed into the roll so far
roll_ptr      = $e9     ; 16-bit: next credits line
sc_ptr        = $eb     ; 16-bit: next letter of the scroll text
sc_col        = $ed     ; shifts done on the current letter (0-15)
sc_bits       = $ee     ; $ee-$f5 the current letter's 8 glyph rows
col_phase     = $f6     ; rainbow position
paused        = $f8     ; 1 = game paused (pause.asm); the IRQ holds the music
music_off     = $f9     ; 1 = music switched off on the title screen (M)
scroll_d011   = $fa     ; $D011 the IRQ writes every frame in play (0 = none)
chase_line    = $fb     ; scroll.asm: raster line the colour chase waits for
scroll_chase  = $fc     ; 1 = the colour RAM chase runs at the end of this frame
                        ; $fd = next free
