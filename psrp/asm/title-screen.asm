; New title screen ------------------------
  PatchB $2fdb $2b    ; cursor tile index for title screen

; The artwork is over 256 tiles so we load it in two chunks. This is handy as we can also localise the bottom half.

.slot 2
.section "Replacement title screen" semisuperfree banks 3-31
TitleScreenTilesBottom:
.incbin {"generated/title.bottom.{LANGUAGE}.psgcompr"}
.ends

.section "Title screen name table" semisuperfree banks 3-31
TitleScreenTilemapBottom:
.incbin {"generated/title.bottom.{LANGUAGE}.tilemap.pscompr"}
.ends

.section "Replacement title screen part 2" semisuperfree banks 3-31
TitleScreenTilesTop:
.incbin "generated/title.top.psgcompr"
.ends

.section "Title screen name table for logo" semisuperfree banks 3-31
TitleScreenTilemapTop:
.incbin "generated/title.top.tilemap.pscompr"
.ends


  ROMPosition $00925
.section "Title screen palette" force ; not movable
TitleScreenPalette:
.incbin "generated/title-pal.bin"
.db 0, 0 ; last two entries unused
.db 0 ; background colour
.db 0,0,$3c ; cursor for name entry screen
.dsb 12 0 ; leave rest black
.ends

  ROMPosition $008f3
.section "Title screen patch" force ; not movable
TitleScreenPatch:
; Original code:
;  ld hl,$ffff        ; Page in tiles
;  ld (hl),$1f
;  ld hl,$a8bd        ; Source
;  ld de,$4000        ; Dest
;  call $0486         ; Load
;  ld hl,$ffff        ; Page in tilemap
;  ld (hl),$0e
;  ld hl,$bc68        ; Source
;  call $6e05         ; Load  
  LoadPagedTiles TitleScreenTilesBottom $6000

  ld hl,PAGING_SLOT_2
  ld (hl),:TitleScreenTilemapBottom
  ld hl,TitleScreenTilemapBottom
  call TitleScreenExtra
  ; Size matches original
.ends

.section "Title screen extra tile load" free
TitleScreenExtra:
  call DecompressToTileMapData ; what we stole to get here
  ; Then copy down...
  ld hl,TileMapCacheAddress(0,0)
  ld de,TileMapCacheAddress(0,12)
  ld bc,12 * 32 * 2
  ldir

  ; Now we load the top half
  LoadPagedTiles TitleScreenTilesTop TileWriteAddress(0)

  ld a,:TitleScreenTilemapTop
  ld (PAGING_SLOT_2),a
  ld hl,TitleScreenTilemapTop
  call DecompressToTileMapData

  call SettingsFromSRAM ; Load settings from SRAM

  jp LoadFonts ; and ret
.ends

