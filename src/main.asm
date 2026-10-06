; =============================================================================
; NOT 1942 by JDC - 1942-style vertical shoot-'em-up for the Commodore 64
; Assembler: ACME. Target: stock PAL C64 at 1 MHz (x64sc).
;
; main.asm is the only file passed to ACME. It pulls in everything else.
; =============================================================================

!cpu 6502

!source "src/defs.asm"
!source "src/zp.asm"
!source "src/bss.asm"
!source "src/macros.asm"

; -----------------------------------------------------------------------------
; BASIC stub: 10 SYS 2064  ($0810)
; -----------------------------------------------------------------------------
* = PRG_LOAD
        !word .basic_end        ; link to next line
        !word 10                ; line number
        !byte $9e               ; SYS token
        !text "2064"            ; (GAME_ENTRY in decimal)
!if GAME_ENTRY != 2064 { !error "the SYS line must match GAME_ENTRY" }
        !byte 0                 ; end of line
.basic_end
        !word 0                 ; end of program

; -----------------------------------------------------------------------------
; Entry point
; -----------------------------------------------------------------------------
* = GAME_ENTRY
entry
        sei
        cld
        ldx #$ff
        txs                     ; we never return to BASIC; reset the stack

        jsr init_system         ; CIAs off, char ROM copy, ROMs out, vectors
        jsr hud_clear           ; HUD_BUF is plain RAM: start it blank
        jsr mux_init            ; (before cli: the frame IRQ shows sprites)
        jsr chase_gen           ; the colour RAM chase code (scroll.asm)
        jsr music_init          ; (before cli: the IRQ calls the player)
        jsr init_irq            ; raster IRQ at IRQ_LINE
!ifdef PROFILE {
        jsr prof_reset          ; test hook: start the CIA timer
}
        cli
        jsr title_enter
        jmp main_loop

; -----------------------------------------------------------------------------
; new_game: score 0, 3 lives, first level. Called from the title screen.
; Each level is then built by level_begin (level.asm), so any per-level state
; must be reset there, and per-game state here.
; Test hook: acme -DSTART_LEVEL=n starts at level n (1-4).
; -----------------------------------------------------------------------------
new_game
        lda #START_LIVES
        sta lives
        jsr init_score
!ifdef START_LEVEL {
        lda #START_LEVEL - 1
} else {
        lda #0
}
        sta level
        jmp level_intro_enter

; -----------------------------------------------------------------------------
; Main loop: one iteration per PAL frame (50 Hz), synced to the raster IRQ.
; TIMING: everything here must finish in under one frame (~19000 cycles minus
; badline and sprite DMA steals) or the game slows to 25 Hz.
; -----------------------------------------------------------------------------
main_loop
!ifdef PROFILE {
        jsr prof_frame          ; test hook: worst-case frame time in the HUD
}
        jsr wait_frame

        lda game_mode
        beq .play               ; GM_PLAY
        cmp #GM_TITLE
        bne +
        jsr title_update        ; title screen
        jmp main_loop
+       cmp #GM_INTRO
        bne +
        jsr intro_update        ; "LEVEL n / GET READY"
        jmp main_loop
+       cmp #GM_VICTORY
        bne +
        jsr victory_update      ; ending 1: victory screen
        jmp main_loop
+       cmp #GM_ROLL
        bne +
        jsr roll_update         ; ending 2: credits roll (lower border)
        jmp main_loop
+       cmp #GM_FINALE
        bne +
        jsr finale_update       ; ending 3: big scroll text
        jmp main_loop
+       jsr read_input          ; GAME OVER: wait for fire
        jsr press_fire_update
        jmp main_loop

        ; --- mode switches happen here, in the lower border ---
.play   lda player_state        ; last ship's explosion finished?
        cmp #PS_GAMEOVER
        bne +
        jsr gameover_enter
        jmp main_loop
+       lda lvl_state           ; level cleared and its message shown?
        cmp #LS_NEXT
        bne +
        jsr level_next
        jmp main_loop
+       lda paused              ; paused: only the pause text and key
        beq +
        jsr pause_update
        jmp main_loop
+

!ifdef DEBUG {
        lda #COL_RED            ; raster bar: red = game logic running
        sta BORDER
}

        ; --- lower-border work first ---
        jsr scroll_update       ; smooth scroll: build a slice, next yscroll
        jsr anim_update         ; animated chars (before the raster reaches them)
        jsr fade_update         ; level start / end fades

        ; --- game logic: only touches shadow state, safe mid-screen ---
        jsr read_input
        lda input_new           ; pause pressed: this frame's logic is skipped,
        and #INP_PAUSE          ;   so everything holds still from here
        beq +
        jsr pause_enter
        jmp .end
+       jsr player_update
        jsr pbullets_update     ; move/expire bullets, then fire on press
        jsr enemies_update      ; fly paths (and fire), free slots off screen
        jsr boss_update         ; boss script / death (when there is one)
        jsr ebullets_update     ; move enemy shots, free slots off screen
        jsr collisions          ; box tests at the new positions
        jsr level_update        ; boss / level clear / next level
        jsr hud_update          ; redraw the sprite HUD's changed shapes
        jsr mux_build           ; sort the sprites; shown from the next frame
.end
!ifdef DEBUG {
        lda #COL_BLACK
        sta BORDER
        ; HUD column 39 = dropped-spawn count (hex). Must stay 0: anything
        ; else means the level data schedules more live enemies than
        ; there are enemy slots (ENEMY_COUNT).
        ; (Shown on the next text screen: intro, GAME OVER.)
        lda spawn_drops
        and #$0f
        tax
        lda debug_hex,x
        sta HUD_BUF + COLS-1
}
!ifdef PROFILE {
        jsr prof_end            ; test hook: the frame's work ends here
}
        ; --- flip frame only: colour RAM, just behind the raster ---
        ; (also after pause_enter: the flip is already requested)
        jsr scroll_colour
        jmp main_loop

!ifdef DEBUG {
debug_hex
        !scr "0123456789abcdef"
}

; -----------------------------------------------------------------------------
; Modules
; -----------------------------------------------------------------------------
!source "src/system.asm"
!source "src/video.asm"
!source "src/scroll.asm"
!source "src/mux.asm"
!source "src/input.asm"
!source "src/player.asm"
!source "src/pbullets.asm"
!source "src/enemies.asm"
!source "src/ebullets.asm"
!source "src/collide.asm"
!source "src/hud.asm"
!source "src/score.asm"
!source "src/gameover.asm"
!source "src/music.asm"
!source "src/sfx.asm"
!source "src/title.asm"
!source "src/pause.asm"
!source "src/level.asm"
!source "src/boss.asm"
!source "src/unpack.asm"
!source "src/anim.asm"
!source "src/ending.asm"

code_end
!if code_end > VIC_BASE {
        !error "code overflows into VIC bank 1 ($4000)"
}

; -----------------------------------------------------------------------------
; Data (assembled at fixed addresses; memory map in src/defs.asm)
; -----------------------------------------------------------------------------
!zone data
* = SPRITES                     ; sprite shapes
!source "data/sprites.asm"
!if * > RING {
        !error "sprites overflow into the map ring"
}
                                ; RING: the level map, unpacked at run time
                                ;   (nothing is loaded there)

* = DATA2_BASE                  ; music, title, waves, bosses, level packs
!source "data/music.asm"
!source "data/music_title.asm"
!source "data/music_boss.asm"
!source "data/music_level2.asm"
!source "data/music_level3.asm"
!source "data/music_level4.asm"
!source "data/songs.asm"
!source "data/sfx.asm"
!source "data/title.asm"
!source "data/ending.asm"       ; the ending's text
!source "data/aim.asm"          ; the enemy shots' aiming table
!source "data/tiles.asm"        ; the title logo's quadrant chars (a copy)
!source "data/waves.asm"        ; enemy types + paths (levels refer to them)
!source "data/bosses.asm"
!source "build/gen/level1.asm"  ; level packs, made from data/levels/*.png
!source "build/gen/level2.asm"  ;   by tools/png2level.py (see the Makefile)
!source "build/gen/level3.asm"  ;   (before the waves: they use its boss row)
!source "build/gen/level4.asm"
!source "data/level1_waves.asm"
!source "data/level2_waves.asm"
!source "data/level3_waves.asm"
!source "data/level4_waves.asm"
!source "data/levels.asm"
data2_end
!if data2_end > DATA2_END {
        !error "DATA2 overflows into I/O ($D000)"
}
