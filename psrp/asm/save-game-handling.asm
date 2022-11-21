; Savegame name entry screen

.enum $c784 export ; cursor memory, original game uses 10B but it seems we may use up to 16B
  CursorMemoryStart .db
  CursorX db
  CursorY db
  CurrentIndex db
  PreviousSelectionPointer dw
  KeyRepeatCounter db
  CursorSpriteCount db
  PreviouslyPointedValue dw
  CurrentSelectionPointer dw
.ende

.define NAME_TILEMAP_Y 6
.define NAME_TILEMAP_X (32 - SAVE_NAME_WIDTH) / 2
.define NAME_TILEMAP_POS TileMapWriteAddress(NAME_TILEMAP_X, NAME_TILEMAP_Y)

; We relocate the code and data to paged banks, freeing up a few hundred bytes in banks 0 and 1...

.bank 0 slot 0
.orga $3fdd
.section "Name entry per-frame handler trampoline" force
  ld a,:NameEntryPerFrame
  ld (PAGING_SLOT_2),a
  call NameEntryPerFrame
  ld a,2
  ld (PAGING_SLOT_2),a
  ret
.ends

.slot 2
.section "Name entry per-frame handler" superfree
NameEntryPerFrame:
  ; From the priginal...
  ld a,($c212) ; PauseFlag
  or a
  call nz,$011D ; DoPause
  ld a,8 ; VBlankFunction_Menu
  call $0056 ; ExecuteFunctionIndexAInNextVBlank

  ld hl,(PreviousSelectionPointer)
  ld a,h
  or l
  jr nz,+
  ; On first run, we want to draw the cursors
  ; We need to set this to something valid...
  call _getPointedTileAddress
  ld (PreviousSelectionPointer),hl
  ld (CurrentSelectionPointer),hl
  call _drawCursors
  ; then carry on

+:
NameEntryInputs:
  ; Get inputs
  ld a,($c205) ; buttons newly pressed
  and %00110000 ; button 1 or 2
  jp z,_noButtons
  and %00010000 ; button 1
  jp nz,_button1

_button2:
  ; Get pointed character
  ld hl,(CurrentSelectionPointer)
  ld a,(hl)
  cp $c0
  jr c,_controlCharacter
  ; We get the tilemap word to de
  ld e,a
  inc hl
  ld d,(hl)
  ; Then write it to the current cursor position
  call _writeTilemapEntry
  ; Increment index
  jr _next

_controlCharacter:
  cp 'B'
  jr z,_back
  cp 'N'
  jr z,_next
  cp 'S'
  jr z,_space
  cp 'V'
  jr z,_save
  ret

_button1:
  ; Move left
  call _back
  ; Blank char
  ld de,$00c0
  jp _writeTilemapEntry ; and ret

_back:
  ld a,(CurrentIndex)
  dec a
  ret m
  ld (CurrentIndex),a
  jp _drawCursors ; and ret

_next:
  ld a,(CurrentIndex)
  inc a
  cp SAVE_NAME_WIDTH
  ret z
  ld (CurrentIndex),a
  jp _drawCursors ; and ret

_space:
  ld de,$00c0
  call _writeTilemapEntry
  jr _next ; and ret

_save:
  ; get name from VRAM to RAM
  ld de,NAME_TILEMAP_POS - $4000
  rst $8
  ; read to $d000, slowly
  ld hl,$d000
  ld b,SAVE_NAME_WIDTH*2
  ld c,PORT_VDP_DATA
  di
-:  ini
    push ix
    pop ix
    jr nz,-
  ei
  ; Compute the destination address
  ld hl,(NumberToShowInText) ; is the save index
  add hl,hl
  ld de,_SaveGameNameLocations-2 ; as it's a 1-based index
  add hl,de
  ld e,(hl)
  inc hl
  ld d,(hl)
  ; Set the source and length
  ld hl,$d000
  ld bc,SAVE_NAME_WIDTH*2
  ; then jump to a low-ROM helper
  jp SaveNameToSaveRam
  ret

_SaveGameNameLocations:
.define SaveFirstNameOffset SaveTilemap + (SAVE_NAME_WIDTH+4+3)*2 ; equivalent for new menu
.define SaveNameDelta (SAVE_NAME_WIDTH+4)*2
.repeat SAVE_SLOT_COUNT index count
.dw SaveFirstNameOffset + SaveNameDelta * count
.endr

_writeTilemapEntry:
  ; We do this in VRAM only...
  ld a,(CurrentIndex)
  ; Offset tilemap address
  push de
    add a,a
    ld e,a
    ld d,0
    ld hl,NAME_TILEMAP_POS
    add hl,de
    ex de,hl
    rst $8 ; set address
  pop de
  ; write it
  di
    ld a,e
    out (PORT_VDP_DATA),a
    push ix
    pop ix
    ld a,d
    out (PORT_VDP_DATA),a
  ei
  ret

; Direction auto-repeat timings
.define NameEntryRepeatInitialFrames 24
.define NameEntryRepeatFrames 5

_noButtons:
  ; check for new key presses
  ld a,($c205)
  rra
  jr c,_UpNew
  rra
  jr c,_DownNew
  rra
  jr c,_LeftNew
  rra
  jr c,_RightNew
  ld a,($c204)
  rra
  jr c,_UpHeld
  rra
  jr c,_DownHeld
  rra
  jr c,_LeftHeld
  rra
  ret nc
  ; fall through
_RightHeld:
  call _DecrementKeyRepeatCounter
  ret nz
  ; Move cursor right
-:ld b,NameEntryMaxX ; max value
  ld c,+1 ; delta
  ld iy,CursorX ; value to change
  jr _DirectionPressed
_RightNew:
  ld a,NameEntryRepeatInitialFrames ; initial repeat timer
  ld (KeyRepeatCounter),a
  jr -

_UpHeld:
  call _DecrementKeyRepeatCounter
  ret nz
-:ld b,NameEntryMinY
  ld c,-2
  ld iy,CursorY
  jr _DirectionPressed
_UpNew:
  ld a,NameEntryRepeatInitialFrames
  ld (KeyRepeatCounter),a
  jr -

_DownHeld:
  call _DecrementKeyRepeatCounter
  ret nz
-:ld b,NameEntryMaxY
  ld c,+2
  ld iy,CursorY
  jr _DirectionPressed
_DownNew:
  ld a,NameEntryRepeatInitialFrames
  ld (KeyRepeatCounter),a
  jr -

_LeftHeld:
  call _DecrementKeyRepeatCounter
  ret nz
-:ld b,NameEntryMinX
  ld c,-1
  ld iy,CursorX
  jr _DirectionPressed
_LeftNew:
  ld a,NameEntryRepeatInitialFrames
  ld (KeyRepeatCounter),a
  jr -

_DecrementKeyRepeatCounter:
  ld hl,KeyRepeatCounter
  dec (hl)
  ret nz
  ld (hl),NameEntryRepeatFrames ; reset counter -> repeat every 5 frames, 30/s
  ret

_DirectionPressed:
  ; Get the currently pointed value
  ld hl,(CurrentSelectionPointer)
  ld a,(hl)
  ld (PreviouslyPointedValue),a
  inc hl
  ld a,(hl)
  ld (PreviouslyPointedValue+1),a

  ; Get the current X or Y value
-:ld a,(iy+0)
  cp b ; see if already at the limit
  jr z,+
  add c
  ld (iy+0),a
  ; Next check if we are pointing at a valid entry
  call _getPointedTileAddress
  ld a,(hl)
  cp $c0 ; space
  ; If space, repeat
  jr z,-
  ; If the same as we are already pointing, continue
  push af
    ld a,(PreviouslyPointedValue)
    ld d,a
    ld a,(PreviouslyPointedValue+1)
    ld e,a
  pop af
  cp d
  jr nz,+ ; different
  inc hl
  ld a,(hl)
  cp e
  jr z,- ; same, repeat movement
+:; If the pointed value is a control word, we want to move to its left
  call _getPointedTileAddress
  ld a,(hl)
  cp $c0 ; space
  jr z,_spaceAtLimit
  ld (CurrentSelectionPointer),hl
  jp nc,_drawCursors ; and ret

  ; It is a control word... scan left until we find a space
  ld b,-1
-:inc b
  dec hl
  dec hl
  ld a,(hl)
  cp $c0
  jr nz,-
  ; b is the amount to move left
  ld a,(CursorX)
  sub b
  ld (CursorX),a
  inc hl
  inc hl
  ld (CurrentSelectionPointer),hl
  jp _drawCursors ; and ret

_spaceAtLimit:
  ; If we run into a blank at the limit then we want to go down/right until we find something.
  ; We don't want to repeat the action that got us here, so we only try a direction that is not already at the limit.
  ld iy,CursorX
  ld b,NameEntryMaxX
  ld c,+1
  ld a,(iy+0)
  cp b
  call nz,_DirectionPressed
  ld iy,CursorY
  ld b,NameEntryMaxY
  ld c,+2
  ld a,(iy+0)
  cp b
  call nz,_DirectionPressed ; and ret
  ret

_getPointedTileAddress:
  ; Compute the tilemap address of the pointed item.
  ; Compute Y*32
  ld a,(CursorY)
  ld l,a
  ld h,0
  ld d,h
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  ; add the x
  ld a,(CursorX)
  ld e,a
  add hl,de
  ; Multiply by 2
  add hl,hl
  ; Now it's an offset into TileMapData. We look up the value...
  ld de,$d000
  add hl,de
  ret ; in hl

_drawCursors:
  ; This used to draw cursors using sprites. We now draw it using tiles to avoid the sprite limit.
  ; This means we need to draw into the name table to both clear the previous cursor and draw the new one.

  ; First for the entry point
  ld a,(CurrentIndex)
  ; Offset tilemap address
  add a,a
  ld e,a
  ld d,0
  ld hl,NAME_TILEMAP_POS + 32*2 - 2 ; -2 so we start one tile to the left
  add hl,de
  ex de,hl
  rst $8 ; set address
  ; write it
  di
    ld hl,$00c0 ; blank
    call _emit
    ld hl,$0900 ; cursor
    call _emit
    ld hl,$00c0 ; blank
    call _emit
  ei

  ; Next for the selection cursor
  ld hl,(PreviousSelectionPointer)
  ld de,$00c0
  call _drawSelectionCursor
  ld hl,(CurrentSelectionPointer)
  ld (PreviousSelectionPointer),hl
  ld de,$0900
  ; fall through

_drawSelectionCursor:
  ; How wide is it?
  ld a,(hl)
  cp $c0 ; space
  ld b,1 ; for non-word rows
  jr nc,+

  ; Count how many we move right before seeing a space
  push hl
    ld b,-1
-:  inc b
    ld a,(hl)
    inc hl
    inc hl
    cp $c0
    jr nz,-
  pop hl

+:; hl is a RAM address, convert to a VRAM address
  push de
    ld de, $7800-$d000+32*2 ; RAM base is $d000, VRAM base is $7800. Add 32*2 to get one row down.
    add hl,de
  pop de
  ex de,hl
  rst $8 ; set address
  di
-:  call _emit
    djnz -
  ei
  ret

_emit:
  ld a,l
  out (PORT_VDP_DATA),a
  push ix
  pop ix
  ld a,h
  out (PORT_VDP_DATA),a
  ret
.ends

.bank 0 slot 0
.section "Save name writer" free
SaveNameToSaveRam:
  ; Page it in
  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a
  ; Copy
  ldir
  ; Page out again
  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a

  ; Copied from original
  ld a,($c316)
  cp $0b
  ld a,$0a
  jr z,+
  ld a,$0c
+:ld (FunctionLookupIndex),a
  ret

.ends

.bank 1 slot 1
.orga $4183
.section "Draw name entry screen trampoline" force
  call $7da8 ; FadeOutFullPalette
  ld a,:DrawNameEntryScreen
  ld (PAGING_SLOT_2),a
  call DrawNameEntryScreen
  ld a,2
  ld (PAGING_SLOT_2),a
  ret
.ends

.slot 2
.section "Draw name entry screen" superfree
; This is called once to set up the name entry screen.
; A lot of this code is copied from the original, but with customisations...
DrawNameEntryScreen:
  ; Increment FunctionLookupIndex to go to the per-frame handler next
  ld hl,FunctionLookupIndex
  inc (hl)

  ; Draw the name entry screen into TileMapData
  ; first blank it out
  ld hl,$d000
  ld de,$d002
  ld bc,32*24*2-1
  ld (hl),$c0 ; space
  inc hl
  ld (hl),$00
  dec hl
  ldir

  ; Then draw text
  ld hl,_NameEntryItems
  ld b,(hl)
  inc hl
-:push bc
    ; read dest pointer to de
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ; read length
    ld c,(hl)
    inc hl
    ld b,0
    ; copy
    ldir
  pop bc
  djnz -

  ; For the box we do some loops to save space compared to storing it all raw...
  ; Top
  ld hl,TileMapCacheAddress(2,3)
  ld de,TileMapCacheAddress(3,3)
  ld bc,54
  ldir
  ; Bottom
  ld hl,TileMapCacheAddress(2,23)
  ld de,TileMapCacheAddress(3,23)
  ld bc,54
  ldir
  ; Left
  ld hl,TileMapCacheAddress(1,4)
  ld de,$11f3 ; left edge tile
  call _side
  ld hl,TileMapCacheAddress(30,4)
  ld de,$13f3 ; left edge tile
  call _side

  ; Select the right palette
  ld hl,TitleScreenPalette
  ld de,$c240 ; TargetPalette
  ld bc,32
  ldir

  di
    ; Draw the tilemap to VRAM
    ld hl,TileMapCacheAddress(0,0)
    ld de,TileMapWriteAddress(0,0)
    ld bc,32*24*2
    call $03de ; OutputToVRAM
    ; Load the cursor sprite
    ld hl,$6000 ; tile $100
    ld de,_CursorSprite
    call LoadTiles
  ei

  ; init the cursor memory
  ld de,CursorMemoryStart
  ld hl,_CursorMemoryInitialValues
  ld bc,_sizeof__CursorMemoryInitialValues
  ldir

  ; Update the tilemap in memory with the control words
  ld hl,_NameEntryLookup
  ; Get count
  ld b,(hl)
  inc hl
-:push bc
    ; Get position
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ; Get count
    ld c,(hl)
    inc hl
    ; Get value
    ld a,(hl)
    inc hl
--  ld (de),a
    inc de
    dec c
    jr nz,--
  pop bc
  djnz -

  ; zero some stuff
  xor a
  ld ($c304),a ; VScroll
  ld ($c300),a ; HScroll
  ld ($c2d3),a ; TextBox20x6Open

  jp $0344 ; ClearSpriteTableAndFadeInWholePalette ; and ret

_side:
  ld b,19
-:ld (hl),e
  inc hl
  ld (hl),d
  push de
    ld de,ONE_ROW-1
    add hl,de
  pop de
  djnz -
  ret

_CursorSprite:
.incbin "generated/name-entry-cursor.psgcompr"

.macro NameEntryText args x,y,text
.dw TileMapCacheAddress(x, y) ; destination
.db _NameEntryText\@end - CADDR - 1
.stringmap tilemap text
_NameEntryText\@end:
.endm

.macro NameEntryMask args x,y,count,text
.dw TileMapCacheAddress(x, y) ; destination
.db count*2, text
.endm

.include {"{LANGUAGE}/name-entry-data.asm"}

_CursorMemoryInitialValues:
.db 3, 11, 0 ; X, Y, index into drawn name
.dw $0000 ; Previous selection pointer. 0 is used to trigger the intial cursor draw.

.ends

.bank 0 slot 0
.section "Default tilemap" free
  ; We want to emit this:
  ; ┌────────────────────╖
  ; │1                   ║ ; <- number, then SAVE_NAME_WIDTH+1 spaces
  ; │2                   ║
  ; │3                   ║
  ; │4                   ║
  ; │5                   ║
  ; │6                   ║
  ; │7                   ║
  ; ╘════════════════════╝
BlankSaveTilemap:
  ld de,SaveTilemap
  ld hl,_top
  call _process
  ld c,$c2 ; '1'
-:ld a,c
  inc c
  ld (de),a
  inc de
  ld a,$10
  ld (de),a
  inc de
  ld hl,_blank
  call _process
  ld a,$c2 + SAVE_SLOT_COUNT
  cp c
  jr nz,-
  ; undo 2
  dec de
  dec de
  ld hl,_bottom
  ; fall through

_process:
--:
  ld a,(hl)
  or a
  ret z
  ld b,a
  inc hl
  inc hl
  inc hl
-:dec hl
  dec hl
  push bc
    ldi
    ldi
  pop bc
  djnz -
  jr --

.macro element args value, count
  .db count
  .stringmap tilemap value
.endm

_top:
  element "┌" 1
  element "─" SAVE_NAME_WIDTH+2
  element "╖" 1
  element "│" 1
  .db 0
_blank:
  element " " SAVE_NAME_WIDTH+1
  element "║" 1
  element "│" 1
  .db 0
_bottom:
  element "╘" 1
  element "═" SAVE_NAME_WIDTH+2
  element "╝" 1
  .db 0

.ends

  ; SRAM initialisation
  ROMPosition $9af
.section "Save RAM init" overwrite
  call BlankSaveTilemap
  JR_TO $09ba
.ends

; When loading an existing save game, we want to "fix" the data if it's from the older layout
  PatchW $3aea SaveDataPatch

.bank 0 slot 0
.section "Save data patch" free
.define Temp         $9800
SaveDataPatch:
  ld a,(SaveTilemapOld + $12)
  cp $f3 ; old data
  jp nz,$3b8f ; what we stole to get here

  push hl
  push de
  push bc
    ; We copy the data higher in RAM...
    ld hl,SaveTilemapOld
    ld de,Temp
    ld bc,216 ; size of old data
    ldir
    ; ...then re-initialise it...
    call BlankSaveTilemap

    ; ...then copy the names. This could be smaller but it's not worth the effort...
    .define OLD_START ((9*2)+3)*2 ; offset from start to first name - 9 tiles per row
    .define OLD_STEP 9*2*2 ; step between names
    .define NAME_LENGTH 5*2
    ld hl,Temp + OLD_START + OLD_STEP * 0
    ld de,SaveFirstNameOffset + SaveNameDelta * 0
    ld bc,NAME_LENGTH
    ldir
    ld hl,Temp + OLD_START + OLD_STEP * 1
    ld de,SaveFirstNameOffset + SaveNameDelta * 1
    ld bc,NAME_LENGTH
    ldir
    ld hl,Temp + OLD_START + OLD_STEP * 2
    ld de,SaveFirstNameOffset + SaveNameDelta * 2
    ld bc,NAME_LENGTH
    ldir
    ld hl,Temp + OLD_START + OLD_STEP * 3
    ld de,SaveFirstNameOffset + SaveNameDelta * 3
    ld bc,NAME_LENGTH
    ldir
    ld hl,Temp + OLD_START + OLD_STEP * 4
    ld de,SaveFirstNameOffset + SaveNameDelta * 4
    ld bc,NAME_LENGTH
    ldir
  pop bc
  pop de
  pop hl
  jp $3b8f ; what we stole to get here
.ends

