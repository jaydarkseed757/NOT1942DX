; =============================================================================
; bss.asm - run-time tables in the RAM under the KERNAL ($E000-, BSS)
; =============================================================================
;
; Nothing is assembled here: these are addresses only. The RAM under the
; KERNAL is plain RAM for the CPU while $01 = $35, but a PRG can't load into
; it (I/O sits at $D000), so everything here starts undefined and bss_init
; (system.asm) clears it at boot. The owners set their tables up as before
; (init_sprites, init_enemies, ...).
;
; Arrays indexed by virtual sprite slot have NUM_SLOTS bytes. The enemy and
; enemy-bullet arrays have one byte per object; their *_s aliases (in
; enemies.asm / ebullets.asm) let code index them by slot number.
; abs,X costs the same as zp,X for loads (one cycle more for stores, and one
; more when an index crosses a page).
; =============================================================================

!set BSS_PTR = BSS

; +bss SIZE : the next SIZE bytes. Use as:  name = BSS_PTR : +bss SIZE
!macro bss .size {
        !set BSS_PTR = BSS_PTR + .size
}

; ---- sprite slots (game code writes these; mux.asm reads them) ----
spr_xh      = BSS_PTR : +bss NUM_SLOTS  ; X in half-pixels (hardware X = value * 2)
spr_y       = BSS_PTR : +bss NUM_SLOTS  ; Y (raster line of the sprite's top row)
spr_ptr     = BSS_PTR : +bss NUM_SLOTS  ; shape pointer
spr_col     = BSS_PTR : +bss NUM_SLOTS  ; colour (pixel 'i') -> $D027+n
spr_on      = BSS_PTR : +bss NUM_SLOTS  ; non-zero = drawn (the slot is in use)
spr_exp     = BSS_PTR : +bss NUM_SLOTS  ; $FF = X and Y expanded (bosses), 0 = normal
spr_mc      = BSS_PTR : +bss NUM_SLOTS  ; $FF = multicolour (default), 0 = hires (HUD)

; ---- collision boxes per slot (collide.asm) ----
box_ox      = BSS_PTR : +bss NUM_SLOTS  ; left offset (half-X) from spr_xh
box_oy      = BSS_PTR : +bss NUM_SLOTS  ; top offset (pixels) from spr_y
box_w       = BSS_PTR : +bss NUM_SLOTS  ; width (half-X)
box_h       = BSS_PTR : +bss NUM_SLOTS  ; height (pixels)

; ---- multiplexer (mux.asm) ----
mux_key     = BSS_PTR : +bss NUM_SLOTS  ; sort key per slot: Y, or $FF = not drawn
mux_order   = BSS_PTR : +bss NUM_SLOTS  ; slots sorted by key (kept between frames)
; Display lists: two buffers of MUX_LIST entries (base 0 and MUX_LIST), so
; entry k uses hardware sprite k & 7 in either buffer.
l_x         = BSS_PTR : +bss 2*MUX_LIST ; hardware X, low 8 bits
l_msb       = BSS_PTR : +bss 2*MUX_LIST ; its $D010 bit (or 0)
l_y         = BSS_PTR : +bss 2*MUX_LIST
l_ptr       = BSS_PTR : +bss 2*MUX_LIST
l_col       = BSS_PTR : +bss 2*MUX_LIST
l_exp       = BSS_PTR : +bss 2*MUX_LIST ; its $D017/$D01D bit (or 0)
l_mc        = BSS_PTR : +bss 2*MUX_LIST ; its $D01C bit (or 0 = hires)
l_line      = BSS_PTR : +bss 2*MUX_LIST ; raster line of its IRQ (entries 8+)
l_end       = BSS_PTR : +bss 2*MUX_LIST ; first line after it (build only)
hw2_of      = BSS_PTR : +bss 2*MUX_LIST ; constant: (k & 7) * 2
bit_of      = BSS_PTR : +bss 2*MUX_LIST ; constant: 1 << (k & 7)
nbit_of     = BSS_PTR : +bss 2*MUX_LIST ; constant: ~(1 << (k & 7))

; ---- enemies (enemies.asm), one byte per enemy slot ----
en_xfrac    = BSS_PTR : +bss ENEMY_COUNT ; X fraction (8.8 position = spr_xh . en_xfrac)
en_yfrac    = BSS_PTR : +bss ENEMY_COUNT ; Y fraction
en_dxl      = BSS_PTR : +bss ENEMY_COUNT ; velocity X, 8.8 signed (lo / hi)
en_dxh      = BSS_PTR : +bss ENEMY_COUNT
en_dyl      = BSS_PTR : +bss ENEMY_COUNT ; velocity Y, 8.8 signed (lo / hi)
en_dyh      = BSS_PTR : +bss ENEMY_COUNT
en_timer    = BSS_PTR : +bss ENEMY_COUNT ; frames left in segment, 0 = hold velocity
en_segl     = BSS_PTR : +bss ENEMY_COUNT ; 16-bit pointer to the next path segment
en_segh     = BSS_PTR : +bss ENEMY_COUNT
en_type     = BSS_PTR : +bss ENEMY_COUNT ; enemy type (scoring, medal drops)
en_state    = BSS_PTR : +bss ENEMY_COUNT ; 0 flying, 1-12 exploding (+EN_DROP), EN_MEDAL medal

; ---- enemy bullets (ebullets.asm), one byte per bullet ----
eb_xfrac    = BSS_PTR : +bss EBULLET_COUNT
eb_yfrac    = BSS_PTR : +bss EBULLET_COUNT
eb_dxl      = BSS_PTR : +bss EBULLET_COUNT ; velocity X, 8.8 signed (lo / hi)
eb_dxh      = BSS_PTR : +bss EBULLET_COUNT
eb_dyl      = BSS_PTR : +bss EBULLET_COUNT ; velocity Y, 8.8 signed (lo / hi)
eb_dyh      = BSS_PTR : +bss EBULLET_COUNT

; ---- boss parts (boss.asm): offsets from the body (part 0) ----
boss_pdx    = BSS_PTR : +bss BOSS_MAX_PARTS ; half-X
boss_pdy    = BSS_PTR : +bss BOSS_MAX_PARTS ; pixels

; ---- generated code (scroll.asm: chase_gen) ----
chase_code  = BSS_PTR : +bss CHASE_CODE_SIZE ; the colour RAM chase, unrolled

bss_end = BSS_PTR
!if bss_end > $ff00 { !error "BSS too big: bss_init clears whole pages, up to the CPU vectors" }
