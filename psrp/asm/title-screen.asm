; New title screen ------------------------
  PatchB $2fdb 191    ; cursor tile index for title screen

; The artwork is over 256 tiles so we load it in two chunks.

.slot 2
.section "Replacement title screen" superfree
TitleScreenTilesLow:
.incbin {"generated/{LANGUAGE}/titlescreen.tiles.low.psgcompr"}
.ends

.section "Replacement title screen part 2" superfree
TitleScreenTilesHigh:
.incbin {"generated/{LANGUAGE}/titlescreen.tiles.high.psgcompr"}
.ends

.section "Title screen name table" superfree
TitleScreenTilemap:
.incbin {"generated/{LANGUAGE}/titlescreen.tilemap.pscompr"}
.ends

; The cursor is invariant to the language so it's loaded separately
.section "Replacement title screen part 3" superfree
TitleScreenCursor:
.incbin {"generated/titlescreen-cursor.psgcompr"}
.ends


  ROMPosition $00925
.section "Title screen palette" force ; not movable
TitleScreenPalette:
.incbin {"generated/{LANGUAGE}/title-pal.bin"}
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
  LoadPagedTiles TitleScreenTilesLow TileWriteAddress(0)

  ld hl,PAGING_SLOT_2
  ld (hl),:TitleScreenTilemap
  ld hl,TitleScreenTilemap
  call TitleScreenExtra
  ; Size matches original
.ends

.section "Title screen extra tile load" free
TitleScreenExtra:
  call DecompressToTileMapData ; what we stole to get here

  ; Now we load the top half
  LoadPagedTiles TitleScreenCursor TileWriteAddress(191)
  LoadPagedTiles TitleScreenTilesHigh TileWriteAddress(256)

  call SettingsFromSRAM ; Load settings from SRAM

  jp LoadFonts ; and ret
.ends

