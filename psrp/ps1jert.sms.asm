; This unifies all the work done for the PS1JERT into a single WLA DX files,
; using WLA DX to do the assembly and insertion of code and data.
; We use WLA DX features (and macros) to implement some of the data transformation.

.memorymap
slotsize $4000
slot 0 $0000
slot 1 $4000
slot 2 $8000
defaultslot 2
.endme

.rombankmap
bankstotal 32
banksize $4000
banks 32
.endro

.define ORIGINAL_ROM "PS1-J.SMS"

.background ORIGINAL_ROM

.emptyfill $ff

; Bank 0
  .unbackground $0000f $00037 ; Unused space
  .unbackground $00056 $00065 ; ExecuteFunctionIndexAInNextVBlank followed by unused space
  .unbackground $00486 $004b2 ; Old tile decoder
  .unbackground $0073f $00750 ; Title screen menu
  .unbackground $0079e $008a3 ; Continue/Delete screen/menus
  .unbackground $007c9 $007df ; Load game font loader
  .unbackground $008f3 $0090b ; Title screen graphics loading
  .unbackground $00925 $00944 ; Title screen palette
  .unbackground $010e3 $010f9 ; Dungeon font loader
  .unbackground $033da $033f3 ; Draw item name
  .unbackground $033aa $033c3 ; Draw character name
  .unbackground $033c8 $033d5 ; Draw enemy name
  .unbackground $033f6 $03493 ; Draw number
  .unbackground $03494 $034a4 ; Draw characters from buffer
  .unbackground $034f2 $03545 ; Draw one character to tilemap
  .unbackground $035c5 $035d9 ; Spell menu blank space filling
  .unbackground $03907 $0397f ; Stats window drawing
  .unbackground $03982 $039dd ; Stats window tilemap data
  .unbackground $039f6 $03ac2 ; Shop window drawing
  .unbackground $03b22 $03b39 ; Shop MST window drawing
  .unbackground $03be8 $03cbf ; Save menu blank tilemap
  .unbackground $03dde $03df4 ; Dungeon font loader
  .unbackground $03eca $03fc1 ; background graphics lookup table
  .unbackground $03fc2 $03fd1 ; Sky Castle reveal palette
; Bank 1
  .unbackground $03fdd $04509 ; Name entry code/data
  .unbackground $045a4 $045c3 ; tile loading for intro
  .unbackground $059ba $059c9 ; Draw text box 20x6 (dialogue)
  .unbackground $05de9 $05e02 ; Party overworld sprite handling
  .unbackground $07fe5 $07fff ; Unused space + header
; Bank 2
  .unbackground $08000 $080b1 ; font tile lookup
  .unbackground $080b2 $0bd93 ; script
  .unbackground $0bd94 $0bf9b ; item names
  .unbackground $0bf9c $0bfdb ; item metadata
  .unbackground $0bfdc $0bfff ; blank
; Bank 3
  .unbackground $0feb2 $0ff01 ; Hapsby travel menu
  .unbackground $0ff02 $0ff97 ; Opening cinema text box
; Bank 9
  .unbackground $27b14 $27fff ; Mansion tiles and palette + unused space
; Bank 11
  .unbackground $2c000 $2caea ; Gold Dragon tiles and palette
  .unbackground $2fe3e $2ffff ; Unused space
; Bank 14
  .unbackground $3bc68 $3bfff ; Title screen tilemap + unused space
; Bank 15
  .unbackground $3fdee $3ffff ; Credits font
; Bank 16
  .unbackground $40000 $428f5 ; Scene tiles and palettes (part 1)
  .unbackground $433f6 $43fff ; Scene tiles and palettes (part 2) + unused space
; Bank 17
  .unbackground $44640 $47949 ; Palettes and tiles
  ; Tajim's tiles live in this space. We used to relocate them but it's not needed any more.
  .unbackground $47fe5 $47fff ; Unused space
; Bank 18
  .unbackground $4be84 $4bfff ; Unused space
; Bank 19
  .unbackground $4c000 $4cdbd ; Dark Force tiles and palette
  .unbackground $4ff59 $4ffff ; Unused space
; Bank 20
  .unbackground $524da $52ba1 ; Lassic room tiles and palette
  .unbackground $53dbc $53fff ; Credits data, unused space
; Bank 22
  .unbackground $58570 $5ac8c ; Tiles for town
  .unbackground $5ac7d $5b9d6 ; Tiles, palette for air castle
; Bank 23
  .unbackground $5ea9f $5f766 ; Building interior tiles, palettes
; Bank 27
  .unbackground $6f40b $6fd62 ; Menu tilemaps
; Bank 29
  .unbackground $747b8 $77629 ; landscapes (world 1)
; Bank 31
  .unbackground $7e8bd $7ffff ; Title screen tiles

; Macros

; Some data is relocated unmodified from the original ROM; this macro helps with that
.macro CopyFromOriginal args _offset, _size
.incbin ORIGINAL_ROM skip _offset read _size
.endm

; Sets the assembler to the given output address (and optionally non-default slot)
.macro ROMPosition args _address, _slot
.if NARGS == 1
  .if _address < $4000
    .bank 0 slot 0                    ; Slot 0 for <$4000
  .else
    .if _address < $8000
      .bank 1 slot 1                  ; Slot 1 for <$8000
    .else
      .bank (_address / $4000) slot 2 ; Slot 2 otherwise
    .endif
  .endif
.else
  .bank (_address / $4000) slot _slot ; Slot is given
.endif
.org _address # $4000 ; modulo
.endm

; Patches a byte at the given ROM address
.macro PatchB args _address, _value
  ROMPosition _address
.section "Auto patch @ \1" overwrite
PatchAt\1:
  .db _value
.ends
.endm

; Patches a word at the given ROM address
.macro PatchW args _address, _value
  ROMPosition _address
.section "Auto patch @ \1" overwrite
PatchAt\1:
  .dw _value
.ends
.endm

; Allows us to "jr" to an absolute address
.macro JR_TO
  jr \1-CADDR-1
.endm

; Macro to load tiles from the given label
.macro LoadPagedTiles args address, dest
LoadPagedTiles\1:
  ; Common pattern used to load tiles in the original code
  ld hl,PAGING_SLOT_2
  ld (hl),:address
  ld hl,dest
  ld de,address
  call LoadTiles
.endm

.function TileMapWriteAddress(x, y) ($3800 + (y*32+x)*2) | $4000
.function TileMapCacheAddress(x, y) ($d000 + (y*32+x)*2)

; This string mapping is for raw (16-bit) tilemap data. It sets the priority bit on every tile.
.stringmaptable tilemap {"tilemap.{LANGUAGE}.tbl"}

; This one is for script text and item names (8-bit). It includes control codes but not dictionary words.
.stringmaptable script {"script.{LANGUAGE}.tbl"}


.macro String args s
; Item names are length-prefixed. We create two labels to correctly measure this (as WLA DX computes length as the distance to the next label).
.db _sizeof__script\@
_script\@:
.stringmap script s
_script\@_end:
.endm

.define PAGING_SRAM $fffc
.define PAGING_SLOT_1 $fffe
.define PAGING_SLOT_2 $ffff
.define PORT_VDP_DATA $be
.define PORT_FM_CONTROL $f2
.define PORT_MEMORY_CONTROL $3e
.define SRAMPagingOn $08
.define SRAMPagingOff $80

; RAM used by the game, referenced here
.define UseFM               $c000 ; b 01 if YM2413 detected, 00 otherwise
.define NewMusic            $c004 ; b Which music to start playing
.define VBlankFunctionIndex $c208 ; b Index of function to execute in VBlank
.define FunctionLookupIndex $c202 ; b Index of "game phase" function
.define MovementFrameCounter $c265 ; Number of frames for each movement step
.define CursorEnabled       $c268 ; b $ff when in "cursor mode"
.define CursorTileMapAddress $c269 ; w Tilemap address of top option
.define CursorPos           $c26b ; b Cursor index
.define OldCursorPos        $c26c ; b Previous value of above
.define CursorMax           $c26e ; b Maximum index for menu selection (0-based)
.define NameIndex           $c2c2 ; b Index into Names
.define ItemIndex           $c2c4 ; b Index into Items
.define RoomIndex           $c2db ; b Index for various room-related lookups, notably shops.
.define ItemTableIndex      $c2c4 ; b Index of the "current" item
.define NumberToShowInText  $c2c5 ; w Number to show in text. Sometimes assumed to be 8-bit.
.define EnemyIndex          $c2e6 ; b Index into Enemies
.define VehicleType         $c30e ; b Zero when walking
.define IntroState          $c600 ; b $ff when intro starts
.define SaveTilemapOld      $8100 ; Tilemap data for save - original
.define SaveTilemap         $8040 ; Tilemap data for save - new - moved to make more space

; RAM used by the hack. The original game doesn't venture higher than $de96, we use even less... so it's safe to use this chunk up high (so long as we don't hit $dffc+).

.enum $dfa0 export
  .union
    PSGaiden_decomp_buffer    dsb 32 ; buffer for tile decoding
  .nextu
    ; Script decoding
    ; Buffer for item name strings, shared with PSGaiden_decomp_buffer as we don't need both at the same time.
    ; It is prepended with articles so we need to make sure there is space before it for the longest article
    ; (Brazilian Portuguese "de una " = 7) and after it for the longest item name (27)
    ArticleSpace    dsb 16
    TEMP_STR        dsb 32
  .endu
  STR             dw   ; pointer to WRAM string - will be in ArticleSpace if an article was prepended
  LEN             db   ; length of substring in WRAM
  POST_LEN        db   ; post-string hint (ex. <Herb>...)
  LINE_NUM        db   ; # of lines drawn
  FLAG            db   ; auto-wait flag
  ARTICLE         db   ; article category #
  SUFFIX          db   ; suffix flag
  HLIMIT          db   ; horizontal chars left
  VLIMIT          db   ; vertical line limit
  SCRIPT          dw   ; pointer to script
  BARREL          db   ; current Huffman encoding barrel
  TREE            db   ; current Huffman tree
  VRAM_PTR        dw   ; VRAM address
  SKIP_BITMASK    db   ; for bracket-based skipping. If a skip region's code AND this is 0, we skip it.
  HasFM             db   ; copy of FM detection result
  MusicSelection    db ; music test last selected song
  ShopInventoryWidth db ; for elastic window size
  ScriptBCStateBackup dw ; w Used for retaining state in tricky script situations
  TextDrawingCharacterCounter db ; Counts the number of chars to draw per frame

  SettingsStart: .db

  MovementSpeedUp db ; non-zero for speedup
  ExpMultiplier  db ; b Experience scaling
  MoneyMultiplier  db ; b Money pickups scaling
  FewerBattles db ; b 1 to halve battle probability
  BrunetteAlisa db ; 1 to enable brown hair
  Font db ; 1 for the "alternate" font
  FadeSpeed db ; 0 is "normal", 1 is "fast"
  TextSpeed db ; Counter for text speed, in additional chars per frame so 0 = normal

  SettingsEnd: .db

  Port3EValue db  ; Value left at $c000 by the BIOS
.ende

; Functions in the original game we make use of
.define VBlankHandler $0127
.define OutputTilemapRawDataBox $0428
.define IsSlotUsed $08a4
.define DoYesNoMenu $2e75
.define WaitForMenuSelection $2eb9
.define MenuWaitForButton $2e81
.define Pause256Frames $2eaf
.define DrawTextAndNumberA $3140
.define DrawTextAndNumberBC $319e
.define TextBox $333a
.define TextBoxEnd $357e
.define DrawMeseta $36d9
.define OutputDigit $3762 ; Draws a to current VRAM address, except 0 uses tile in bc
.define GetSavegameSelection $3adb
.define OutputTilemapBoxWipePaging $3b81
.define InputTilemapRect $3bca
.define DecompressToTileMapData $6e05
.define Multiply16 $0505 ; dehl = de * bc
.define GetRandomNumber $066a ; returns in a

; Save slots are $400 bytes so we have room for 7.
; Names could go up to 24 characters... but we limit to 18 because that fits nicely on the screen.
.define SAVE_NAME_WIDTH 18
.define SAVE_SLOT_COUNT 7



  ROMPosition $0003f
.section "VBlank intercept" overwrite ; not movable
VBlankIntercept:
  jp VBlankPageSave
.ends

  ROMPosition $00494
.section "VBlank page saving" free
VBlankPageSave:
  ; We wrap the handler to select page 1 in slot 1 and then restore it
  ld a,(PAGING_SLOT_1)    ; Save page 1
  push af

    ld a,1    ; Regular page 1
    ld (PAGING_SLOT_1),a

    call VBlankHandler ; Resume old code

  pop af
  ld (PAGING_SLOT_1),a    ; Put back page 1

  pop af      ; Leave ISR manually
  ei
  ret
.ends

  ROMPosition $182
.section "Original VBlank handler no ei/reti patch" overwrite ; not movable
OriginalVBlankHandlerPatch:
  ret
.ends


  ROMPosition $59ba
.section "Index table remap" force ; not movable
IndexTableRemap:
  jp TextBox
.ends

; Menus

.slot 2
.section "Menu data" superfree
.block "Menus"
MenuData:
.include {"generated/menus.{LANGUAGE}.asm"}
.endb
.ends

.include {"generated/menu-patches.{LANGUAGE}.asm"}

  PatchB $3b58 :MenuData ; HapsbyTravelMenu only
  PatchB $3b82 :MenuData ; OutputTilemapBoxWipePaging
  PatchB $3bab :MenuData ; OutputTilemapRect
  PatchB $45d7 :MenuData ; for opening cinema only

  ROMPosition $3211
.section "HP letters" size 4 overwrite ; not movable
.if LANGUAGE == "en" || LANGUAGE == "literal"
.stringmap tilemap "HP"
.endif
.if LANGUAGE == "fr"
.stringmap tilemap "HP"
.endif
.if LANGUAGE == "pt-br"
.stringmap tilemap "PV"
.endif
.if LANGUAGE == "ca"
.stringmap tilemap "PV"
.endif
.if LANGUAGE == "es"
.stringmap tilemap "PV"
.endif
.if LANGUAGE == "de"
.stringmap tilemap "LP"
.endif
.ends

  ROMPosition $3219
.section "MP letters" size 4 overwrite ; not movable
.if LANGUAGE == "en" || LANGUAGE == "literal"
.stringmap tilemap "MP"
.endif
.if LANGUAGE == "fr"
.stringmap tilemap "MP"
.endif
.if LANGUAGE == "pt-br"
.stringmap tilemap "PM"
.endif
.if LANGUAGE == "ca"
.stringmap tilemap "PM"
.endif
.if LANGUAGE == "es"
.stringmap tilemap "PM"
.endif
.if LANGUAGE == "de"
.stringmap tilemap "MP"
.endif
.ends

.unbackground $35a2 $35d7
  ROMPosition $35a2
.section "Spell selection finder" force ; not movable
DrawSpellsMenu:
  ; We want to compute hl = a'th spells menu data
  ; de = dest VRAM address
  ; b = spell count to draw
  push de
    add a,a
    ld e,a
    ld d,0
    ld hl,_magicmenutable
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
  pop de
  ; Next we want to check if b = 0
  ld a,b
  or a
  jp z,$35da
  ; Now we want to compute b = row count, c = column count  * 2
  inc b
  ld c,SpellMenuBottom_width*2
  call OutputTilemapBoxWipePaging

  ; Then we draw the bottom row directly after it
  ld hl,SpellMenuBottom
  ld bc,(1<<8) + SpellMenuBottom_width*2  ; width of line
  jp OutputTilemapBoxWipePaging ; draw and exit
_magicmenutable:
.dw BattleSpellsAlisa, BattleSpellsMyau, BattleSpellsLutz
.dw OverworldSpellsAlisa, OverworldSpellsMyau, OverworldSpellsLutz
.ends


  ROMPosition $3907
.section "Stats window" force
stats:
  ; ix = player stats
  ; We can assume slot 1 needs to be restored to 1
  ld a,:statsImpl
  ld (PAGING_SLOT_1),a
  call statsImpl
Slot1TrampolineEnd:
  ld a,1
  ld (PAGING_SLOT_1),a
  ret
.ends

  ROMPosition $39f6
.section "Shop inventory window" force
ShopInventory:
  ; We trampoline to the same area as the stats drawing
  ld a,:shop
  ld (PAGING_SLOT_1),a
  call shop
  jp Slot1TrampolineEnd
.ends

  ROMPosition $3b22
.section "Shop MST window" force
ShopMST:
  ; We trampoline to the same area as the stats drawing
  ld a,:shopMSTImpl
  ld (PAGING_SLOT_1),a
  call shopMSTImpl
  call Slot1TrampolineEnd
  JR_TO $3b3a
.ends

; This one needs to go in low ROM as it's accessed from multiple places (stats, shop, inventory)
.bank 0 slot 0
.section "Meseta tilemap data" free
MST:      .stringmap tilemap "│Meseta         "   ; 5 digit number but also used for shop so extra spaces needed
.ends

.slot 1
.section "Stats window drawing" superfree
; The width of these is important
.if LANGUAGE == "en" || LANGUAGE == "literal"
StatsBorderTop:     .stringmap tilemap "┌────────────────╖"
Level:              .stringmap tilemap "│Level        " ; 3 digit number
EXP:                .stringmap tilemap "│Experience "   ; 5 digit number
Attack:             .stringmap tilemap "│Attack       " ; 3 digit numbers
Defense:            .stringmap tilemap "│Defense      "
MaxMP:              .stringmap tilemap "│Maximum MP   "
MaxHP:              .stringmap tilemap "│Maximum HP   "
StatsBorderBottom:  .stringmap tilemap "╘════════════════╝"
.endif
.if LANGUAGE == "fr"
StatsBorderTop:     .stringmap tilemap "┌────────────────╖"
Level:              .stringmap tilemap "│Niveau       " ; 3 digit number
EXP:                .stringmap tilemap "│Expérience "   ; 5 digit number
Attack:             .stringmap tilemap "│Attaque      " ; 3 digit numbers
Defense:            .stringmap tilemap "│Défense      "
MaxMP:              .stringmap tilemap "│MP maximum   "
MaxHP:              .stringmap tilemap "│HP maximum   "
StatsBorderBottom:  .stringmap tilemap "╘════════════════╝"
.endif
.if LANGUAGE == "pt-br"
StatsBorderTop:     .stringmap tilemap "┌─────────────────╖"
Level:              .stringmap tilemap "│Nível         " ; 3 digit number
EXP:                .stringmap tilemap "│Experiência "   ; 5 digit number
Attack:             .stringmap tilemap "│Ataque        " ; 3 digit numbers
Defense:            .stringmap tilemap "│Defesa        "
MaxMP:              .stringmap tilemap "│PM máximo     "
MaxHP:              .stringmap tilemap "│PV máximo     "
StatsBorderBottom:  .stringmap tilemap "╘═════════════════╝"
.endif
.if LANGUAGE == "ca"
StatsBorderTop:     .stringmap tilemap "┌─────────────────╖"
Level:              .stringmap tilemap "│Nivell        " ; 3 digit number
EXP:                .stringmap tilemap "│Experiència "   ; 5 digit number
Attack:             .stringmap tilemap "│Atac          " ; 3 digit numbers
Defense:            .stringmap tilemap "│Defensa       "
MaxMP:              .stringmap tilemap "│PM màxim      "
MaxHP:              .stringmap tilemap "│PV màxim      "
StatsBorderBottom:  .stringmap tilemap "╘═════════════════╝"
.endif
.if LANGUAGE == "es"
StatsBorderTop:     .stringmap tilemap "┌─────────────────╖"
Level:              .stringmap tilemap "│Nivel         " ; 3 digit number
EXP:                .stringmap tilemap "│Experiéncia "   ; 5 digit number
Attack:             .stringmap tilemap "│Ataque        " ; 3 digit numbers
Defense:            .stringmap tilemap "│Defensa       "
MaxMP:              .stringmap tilemap "│PM máximo     "
MaxHP:              .stringmap tilemap "│PV máximo     "
StatsBorderBottom:  .stringmap tilemap "╘═════════════════╝"
.endif
.if LANGUAGE == "de"
StatsBorderTop:     .stringmap tilemap "┌───────────────╖"
Level:              .stringmap tilemap "│Stufe       " ; 3 digit number
EXP:                .stringmap tilemap "│Erfahrung "   ; 5 digit number
Attack:             .stringmap tilemap "│Stärke      " ; 3 digit numbers
Defense:            .stringmap tilemap "│Abwehr      "
MaxMP:              .stringmap tilemap "│LP-Maximum  "
MaxHP:              .stringmap tilemap "│MP-Maximum  "
StatsBorderBottom:  .stringmap tilemap "╘═══════════════╝"
.endif

statsImpl:
  call _borderTop
  ld hl,Level
  ld a,(ix+5)
  call DrawTextAndNumberA
  ld hl,EXP
  ld c,(ix+3)
  ld b,(ix+4)
  call DrawTextAndNumberBC
  ld hl,Attack
  ld a,(ix+8)
  call DrawTextAndNumberA
  ld hl,Defense
  ld a,(ix+9)
  call DrawTextAndNumberA
  ld hl,MaxHP
  ld a,(ix+6)
  call DrawTextAndNumberA
  ld hl,MaxMP
  ld a,(ix+7)
  call DrawTextAndNumberA
_mesetaAndEnd:
  call DrawMeseta
  ld hl,StatsBorderBottom
  ld bc,(1<<8) + _sizeof_StatsBorderTop ; size
  jp OutputTilemapBoxWipePaging ; draw and exit

_borderTop:
  ld hl,StatsBorderTop
  ld bc,(1<<8) + _sizeof_StatsBorderTop ; size
  jp OutputTilemapBoxWipePaging ; draw and exit

shopMSTImpl: ; same section to share data
  ; Need to set de as this is also used to update things.
  ; It's unnecessary for the initial draw as de is set from the copy to RAM.
  ld de,SHOP_MST_VRAM
  call _borderTop
  jp _mesetaAndEnd
.ends

; Patch in string lengths to places called above
  PatchB $31a3 _sizeof_EXP ; in DrawTextAndNumberBC
  PatchB $36dd _sizeof_EXP
  PatchB $3145 _sizeof_Attack ; in DrawTextAndNumberA
  PatchW $36e7 MST ; in DrawMeseta
  PatchB $36e5 TopBorder10_width*2-12

.section "Newline patch" free
; Originally tx1.asm
; Text window drawer multi-line handler

newline:
    ld b,NARRATIVE_WIDTH ; reset x counter
    inc hl   ; move pointer to next byte
    ld a,c   ; get line counter
    or a     ; test for c==0
    jr nz,_not_zero
    ; zero: draw on 2nd line
    ld de,NARRATIVE_SCROLL_VRAM + ONE_ROW ; VRAM address
_inc_and_finish:
    inc c
    jp InGameTextDecoder
_not_zero:
    dec a    ; test for c==1
    jr nz,+
    ; one: draw on 3rd
_draw_3rd_line:
    ld de,NARRATIVE_SCROLL_VRAM + ONE_ROW * 2 ; VRAM address
    jr _inc_and_finish
+:  dec a    ; test for c==2
    jr nz,+
    ; two: draw on 4th
_draw_4th_line:
    ld de,NARRATIVE_SCROLL_VRAM + ONE_ROW * 3
    jr _inc_and_finish
+:  ; three: scroll, draw on 4th line
    call $3546 ; _ScrollTextBoxUp2Lines (patch reduces it to one)
    dec c      ; cancel increment
    jr _draw_4th_line
.ends

  ROMPosition $3397
.section "Newline patch trampoline" overwrite
  jp newline
.ends

  ROMPosition $354c
.section "nop out 2nd line scroll" overwrite
.repeat 3
  nop
.endr
.ends

/*

; Cheats

; Cheat: all characters start at LV 20
  PatchB $1854 20
; Cheat: collect any money to get 65535
  PatchW $2adb 0
; cheat: HP rolls over 0->255 (nop out overflow handler setting it to 0)
  PatchB $1723 0
; cheat: free magic
  PatchB $1cf8 0
*/

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
  ld hl,NameEntryLookup
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

_NameEntryItems:
.if LANGUAGE == "en" || LANGUAGE == "literal"
.db 10
  NameEntryText  8,  1, "Enter your name:"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "0123456789"
  NameEntryText 21, 15,                   ".,:-!?‘’"
  NameEntryText  3, 17, "Back  Next  Space     Save"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 4, "B" ; X, Y, length, type (Back)
  NameEntryMask  9, 17, 4, "N" ; Next
  NameEntryMask 15, 17, 5, "S" ; Space
  NameEntryMask 25, 17, 4, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 17
.endif
.if LANGUAGE == "fr"
.db 14
  NameEntryText  8,  1,      "Entrez votre nom"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "àéêèçù"
  NameEntryText 11, 15,        "0123456789"
  NameEntryText 22, 15,                   ".,-!?‘’"
  NameEntryText  3, 17, "Précédent"
  NameEntryText 22, 17,                    "Suivant"
  NameEntryText  3, 19, "Espace"
  NameEntryText 23, 19,                     "Sauver"
  NameEntryText  1,  3, "┌─"
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 9, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 17, 7, "N" ; Next
  NameEntryMask  3, 19, 6, "S" ; Space
  NameEntryMask 23, 19, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19
.endif
.if LANGUAGE == "pt-br"
.db 14
  NameEntryText  8,  1,      "Digite seu nome"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "áâãçéêíóôõú"
  NameEntryText  3, 17, "0123456789"
  NameEntryText 22, 17,                   ".,-!?‘’"
  NameEntryText  3, 19, "Voltar"
  NameEntryText 22, 19,                    "Próximo"
  NameEntryText  3, 21, "Espaço"
  NameEntryText 23, 21,                     "Salvar"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
NameEntryLookup:
.db 4
  NameEntryMask  3, 19, 6, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 19, 7, "N" ; Next
  NameEntryMask  3, 21, 6, "S" ; Space
  NameEntryMask 23, 21, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 21
.endif
.if LANGUAGE == "ca"
.db 14
  NameEntryText  4,  1,  "Introdueixi el seu nom"
  NameEntryText  3, 11, "ABCDEFGHIJ LMNOPQRSTUV"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuv xyz"
  NameEntryText  3, 15, "àçéèíóòú"
  NameEntryText  3, 17, "0123456789"
  NameEntryText 22, 17,                   ".,-!?‘’"
  NameEntryText  3, 19, "Enrera"
  NameEntryText 22, 19,                    "Següent"
  NameEntryText  3, 21, "Espai"
  NameEntryText 22, 21,                    "Guardar"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
NameEntryLookup:
.db 4
  NameEntryMask  3, 19, 6, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 19, 7, "N" ; Next
  NameEntryMask  3, 21, 5, "S" ; Space
  NameEntryMask 22, 21, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 21
.endif
.if LANGUAGE == "es"
.db 12
  NameEntryText  6,  1,    "Introduzca su nombre"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "áéíóúñ 0123456789  .,-!?‘’"
  NameEntryText  3, 17, "Atrás"
  NameEntryText 20, 17,                  "Siguiente"
  NameEntryText  3, 19, "Espacio"
  NameEntryText 22, 19,                    "Guardar"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 5, "B" ; X, Y, length, type (Back)
  NameEntryMask 20, 17, 9, "N" ; Next
  NameEntryMask  3, 19, 7, "S" ; Space
  NameEntryMask 22, 19, 7, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19
.endif
.if LANGUAGE == "de"
.db 10
  NameEntryText  6,  1,    "Gib einen Namen ein"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "äöüß  0123456789  .,-!?’„“"
  NameEntryText  3, 17, "Links  Rechts  Leerzeichen"
  NameEntryText 23, 19,                     "Fertig"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
NameEntryLookup:
.db 4
  NameEntryMask  3, 17,  5, "B" ; X, Y, length, type (Back)
  NameEntryMask 10, 17,  6, "N" ; Next
  NameEntryMask 18, 17, 11, "S" ; Space
  NameEntryMask 23, 19,  6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19
.endif

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

  ROMPosition $00056
.section "HALT on idle polling loop" force ; not movable
ExecuteFunctionIndexAInNextVBlank ; $0056
; Was:
;  ld (VBlankFunctionIndex),a
;-:ld a,(VBlankFunctionIndex)
;  or a               ; Wait for it to be zero
;  jr nz,-
;  ret
; ...followed by some blank space
  ld (VBlankFunctionIndex),a
-:halt
  ld a,(VBlankFunctionIndex)
  or a
  jr nz,-
  ret
.ends

; Remove waits for button press --------------------
  PatchW $1808 0
  PatchB $180a 0 ; found treasure chest/display/wait/do you want to open it?

.slot 2

.section "Font lookup" align 256 superfree ; alignment simplifies code...
FontLookup:
; This is used to convert text from the game's encoding (indexing into this area) to name table entries. More space can be used but check SymbolStart which needs to be one past the end of this table. These must be in the order given in script.<language>.tbl.
.include {"generated/font-lookup.{LANGUAGE}.asm"}
.ends

; We locate the Huffman trees in a different slot to the script so we can access them at the same time
.slot 1
.section "Huffman trees" superfree
.block "Huffman trees"
HuffmanTrees:
.include {"generated/tree.{LANGUAGE}.asm"}
.endb
.ends

; ...but the script still needs to go in slot 2.
.bank 2 slot 2
.section "Script" free
.block "Script"
.include {"generated/script.{LANGUAGE}.asm"}
.endb
.ends

.bank 0 slot 0
.section "Decoder init" free
DecoderInit:
; Semi-adaptive Huffman decoder
; - Init decoder
; This is called from various places where the game wants to draw text. We:
; - page some code into slot 1
; - init the Huffman decoding state
; - determine which place we were called from and implement the patched-over code,
;   plus some context-specific state.
; - call into the code following the patch point, which will call into other text-decoding functions
; - then restore slot 1

  push af     ; Save routine selection

    ld a,:AdditionalScriptingCodes
    ld (PAGING_SLOT_1),a

    ld a,SymbolEnd    ; Starting tree symbol
    ld (TREE),a

    ld a,1<<7    ; Initial tree barrel
    ld (BARREL),a

    ld (SCRIPT),hl    ; Beginning script offset

    xor a     ; A = $00
    ld (POST_LEN),a   ; No post hints
    ld (LINE_NUM),a   ; No lines drawn
    ld (FLAG),a       ; No wait flag
    ld (ARTICLE),a    ; No article usage
    ld (SUFFIX),a     ; No suffix flag
    ld (SKIP_BITMASK),a ; No (){}[] etc

  pop af

  ; Now we detect what we need to do to recover from the patch to get here...
  or a
  jr nz,+

CutsceneClear:
  ; a = 0: Cutscene handler
  ; Patched-over code
  ld de,$7c42   ; VRAM address - modified
  ld bc,$0000
  ; Context-specific state
  ld a,6        ; Line count
  ld (VLIMIT),a
  ; Call back to patch location
  xor a ; unnecessary?
  call CutsceneNarrativeInitOriginalCode
  jr ++

+:; a = 1: in-game dialog
  ; Context-specific state
  ld a,4        ; Line count
  ld (VLIMIT),a
  ; Patched-over code
  ld a,($c2d3)  ; Old code (checking if the text window is already open)
  or a          ; Done second as the flags from this test are what matters
  ; Call back to patch location
  call InGameNarrativeInitOriginalCode

++:
  ld a,1    ; Restore slot 1
  ld (PAGING_SLOT_1),a

  ret

.ends

.bank 0 slot 0
.section "SFG decoder" free
SFGDecoder:
; Originally t4a.asm
; Semi-adaptive Huffman decoder
; - Shining Force Gaiden: Final Conflict

; Start of decoder

; Note:
; The Z80 uses one set of registers for decoding the Huffman input data
; The other context is used to traverse the Huffman tree itself

; Encoded Huffman data is in slot 2
; Huffman tree data is in slot 1
; The symbols for the tree are stored in backwards linear order

  push hl
    ld a,:HuffmanTrees
    ld (PAGING_SLOT_1),a

    ld hl,(SCRIPT)    ; Set Huffman data location
    ld a,(BARREL)   ; Load Huffman barrel

    ex af,af'   ; Context switch to tree mode
    exx
      ld a',(TREE)   ; Load in tree / last symbol

      push af'
        ld bc',HuffmanTrees    ; Set physical address of tree data
        ld h',0      ; 8 -> 16
        ld l',a'
        add hl',hl'   ; 2-byte indices
        add hl',bc'   ; add offset

        ld a',(hl')   ; grab final offset
        inc hl'
        ld h',(hl')
        ld l',a'
      pop af'

      ld a',$80    ; Initialise the tree barrel data
      ld d',h'      ; Point to symbol data
      ld e',l'
      dec de'      ; Symbol data starts one behind the tree

      jr _Tree_Shift1    ; Grab first bit

_Tree_Mode1:
    ex af,af'   ; Context switch to tree mode
    exx

_Tree_Shift1:
      add a',a'     ; Shift out next tree bit to carry flag
      jr nz,+     ; Check for empty tree barrel

      ld a',(hl')   ; Shift out next tree bit to carry flag
      inc hl'      ; Bump tree pointer

      adc a',a'     ; Note: We actually shift in a '1' by doing this! Clever trick to use all 8 bits for tree codes

+:    jr c,_Decode_Done ; 0 -> tree node = continue looking
                        ; 1 -> root node = symbol found

    ex af,af'   ; Switch to Huffman data processing = full context switch
    exx

    add a,a     ; Read in Huffman bit
    jr nz,_Check_Huffman1  ; Check Huffman barrel status

    ld a,(hl)   ; Reload 8-bit Huffman barrel
    inc hl      ; Bump Huffman data pointer
    adc a,a     ; Re-grab bit

_Check_Huffman1:
    jr nc,_Tree_Mode1  ; 0 -> travel left, 1 -> travel right

    ex af,af'   ; Switch back to tree mode
    exx

      ld c',1    ; Start counting how many symbols to skip in the linear list since we are traversing the right sub-tree

_Tree_Shift2:
      add a',a'     ; Check if tree data needs refreshing
      jr nz,_Check_Tree2

      ld a',(hl')   ; Refresh tree barrel again
      inc hl'      ; Bump tree pointer
      adc a',a'     ; Grab new tree bit

_Check_Tree2:
      jr c,_Bump_Symbol  ; 0 -> tree, 1 -> symbol

      inc c'     ; Need to bypass one more node
      jr _Tree_Shift2    ; Keep bypassing symbols

_Bump_Symbol:
      dec de'      ; Bump pointer in symbol list backwards
      dec c'     ; One less node/symbol to skip

      jr nz,_Tree_Shift2 ; Check for full exhaustion of left subtree nodes

      jr _Tree_Shift1    ; Need status of termination

_Decode_Done:
      ld a',(de')   ; Find symbol
      ld (TREE),a'   ; Save decoded byte

    ex af,af'   ; Go to Huffman mode
    exx
    ld (SCRIPT),hl    ; Save script pointer
    ld (BARREL),a   ; Save Huffman barrel
    ld a,:AdditionalScriptingCodes ; restore paging
    ld (PAGING_SLOT_1),a
    ex af,af'   ; Go to Tree mode
    ; no need to exx again

  pop hl      ; Restore stack and exit
  ret
.ends

.include {"generated/script-patches.{LANGUAGE}.asm"}

  ROMPosition $2fe2
.section "Cursor row count hack" overwrite
  call CalculateCursorPos
  JR_TO $2feb
.ends

  ROMPosition $2ff8
.section "Cursor row count hack 2" overwrite
  call CalculateCursorPos
  JR_TO $3001
.ends

.slot 0
.section "Compute cursor position" free
CalculateCursorPos:
  ld e,0
  srl a
  rr e
  srl a
  rr e
  ld d,a
  add hl,de
  ex de,hl
  ret
.ends

.smsheader
   productcode 00, 95, 0 ; 9500
   version 3 ; 1.03 :)
   regioncode 4
   reservedspace $ff, $ff
.endsms

; Relocating item metadata to increase script space

.bank 31 slot 2
.section "Item metadata" superfree
ItemMetaData:
  CopyFromOriginal $0bf9c $40
.ends

  PatchB $2828 :ItemMetaData
  PatchW $282d ItemMetaData
  PatchB $28b2 :ItemMetaData
  PatchW $28b7 ItemMetaData
  PatchB $294c :ItemMetaData
  PatchW $2951 ItemMetaData

  ROMPosition $2874
.section "Equipping bug fix hook" overwrite
  call GetItemType
.ends

.section "Equipping bug fix" free
GetItemType:
  ; We need to page in the item metadata again
  ld a,:ItemMetaData
  ld (PAGING_SLOT_2),a
  ; What we replaced to get here
  ld a,(hl)
  and 3
  ret
.ends

.include "original-game-bug-fixes.asm"
.include "game-enhancements.asm"
.include "shop-equip-prompt.asm"
.include "soft-lock-fixes.asm"
.include "credits.asm"
.include "graphics-recompression.asm"
.include "title-screen.asm"
.include "text-renderer.asm"
.include "lists.asm"
.include "item-drawing.asm"
.include "window-ram-management.asm"
