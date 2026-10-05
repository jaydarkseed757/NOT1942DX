; =============================================================================
; data/songs.asm - song table: order lists for voices 1-3 of each song
; =============================================================================

SONG_TITLE = 0                  ; data/music_title.asm
SONG_GAME  = 1                  ; data/music.asm (level 1)
SONG_BOSS  = 2                  ; data/music_boss.asm (all bosses)
SONG_LEVEL2 = 3                 ; data/music_level2.asm
SONG_LEVEL3 = 4                 ; data/music_level3.asm
SONG_LEVEL4 = 5                 ; data/music_level4.asm
SONG_COUNT = 6

music_order_lo  !byte <torder_v1, <torder_v2, <torder_v3     ; SONG_TITLE
                !byte <order_v1,  <order_v2,  <order_v3      ; SONG_GAME
                !byte <border_v1, <border_v2, <border_v3     ; SONG_BOSS
                !byte <jorder_v1, <jorder_v2, <jorder_v3     ; SONG_LEVEL2
                !byte <sorder_v1, <sorder_v2, <sorder_v3     ; SONG_LEVEL3
                !byte <forder_v1, <forder_v2, <forder_v3     ; SONG_LEVEL4
music_order_hi  !byte >torder_v1, >torder_v2, >torder_v3
                !byte >order_v1,  >order_v2,  >order_v3
                !byte >border_v1, >border_v2, >border_v3
                !byte >jorder_v1, >jorder_v2, >jorder_v3
                !byte >sorder_v1, >sorder_v2, >sorder_v3
                !byte >forder_v1, >forder_v2, >forder_v3
