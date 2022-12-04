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
  .unbackground $00486 $004b2 ; Old tile decoder 1
  .unbackground $004b3 $004e1 ; Old tile decoder 2
  .unbackground $0073f $00750 ; Title screen menu
  .unbackground $0079e $008a3 ; Continue/Delete screen/menus
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
  .unbackground $0ff98 $0ffff ; Ending sequence movement script + unused space
; Bank 6
  .unbackground $1bb80 $1bfff ; Person tiles, unused space
; Bank 9
  .unbackground $27130 $2778a ; Dungeon room tiles/tilemap
  ; Mansion tilemap is in this gap, could relocate to make space more usable
  .unbackground $27b14 $27fff ; Mansion tiles and palette + unused space
; Bank 10 - entire bank
  .unbackground $28000 $2bfff ; Enemy tiles, unused space
; Bank 11 - entire bank
  .unbackground $2c000 $2caea ; Gold Dragon tiles and palette
  .unbackground $2caeb $2d900 ; Gold Dragon head tiles
  .unbackground $2d901 $2dcd9 ; Attack/magic sprites
  .unbackground $2dcda $2ffff ; Enemy tiles, unused space
; Bank 14
  .unbackground $3bc68 $3bfff ; Title screen tilemap + unused space
; Bank 15
  .unbackground $3fdee $3ffff ; Credits font + unused space
; Bank 16
  .unbackground $40000 $428f5 ; Scene tiles and palettes (part 1)
  .unbackground $433f6 $43fff ; Scene tiles and palettes (part 2) + unused space
; Bank 17
  .unbackground $44640 $47949 ; Palettes and tiles
  .unbackground $4794a $47fff ; Tarzimal tiles, unused space
; Bank 18
  .unbackground $49c00 $4b387 ; Attack/magic sprites
  .unbackground $4b388 $4bfff ; Lutz portrait palette and tiles, unused space
; Bank 19 - entire bank
  .unbackground $4c000 $4cdbd ; Dark Force tiles and palette
  .unbackground $4cdbe $4ffff ; Enemy tiles, unused space
; Bank 20 - entire bank
  .unbackground $50000 $50fea ; Treasure chest palette, tiles
  .unbackground $50feb $524d9 ; Enemy tiles
  .unbackground $524da $52ba1 ; Lassic room tiles and palette
  .unbackground $52ba2 $53dbb ; Enemy tiles
  .unbackground $53dbc $53fff ; Credits data, unused space
; Bank 21
  .unbackground $57a97 $57fff ; Person tiles, unused space
; Bank 22
  .unbackground $58570 $5ac8c ; Tiles for town
  .unbackground $5ac7d $5b9d6 ; Tiles, palette for air castle
  .unbackground $5b9d7 $5bc31 ; Myau flight sprites
; Bank 23
  .unbackground $5ea9f $5f766 ; Building interior tiles, palettes
  .unbackground $5f778 $5ffff ; Space graphics, unused space
; Bank 24
  .unbackground $62484 $625df ; Picture frame
; Bank 25 - entire bank
  .unbackground $64000 $67fff ; Enemy tiles
; Bank 26 - entire bank
  .unbackground $68000 $6bfff ; Enemy tiles, unused space
; Bank 27
  .unbackground $6c000 $6f40a ; Person tiles
  .unbackground $6f40b $6fd62 ; Menu tilemaps
; Bank 29
  .unbackground $747b8 $77629 ; landscapes (world 1)
  .unbackground $7762a $77fff ; Tairon portrait palette and tiles, unused space
; Bank 30 - entire bank
  .unbackground $78000 $7bfff ; Various portrait palette and tiles, unused space
; Bank 31 - entire bank
  .unbackground $7c000 $7d675 ; Nero death part 1, Myau palette and tiles
  .unbackground $7d676 $7e8bc ; Ending picture palette, tiles
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

.function TileMapWriteAddress(x, y) ($3800 + (y*32+x)*2) | $4000
.function TileMapCacheAddress(x, y) ($d000 + (y*32+x)*2)
.function TileWriteAddress(n) (n * 32) | $4000

; This string mapping is for raw (16-bit) tilemap data. It sets the priority bit on every tile.
.stringmaptable tilemap {"{LANGUAGE}/tilemap.tbl"}

; This one is for script text and item names (8-bit). It includes control codes but not dictionary words.
.stringmaptable script {"{LANGUAGE}/script.tbl"}


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
    PSGaiden_vram_ptr dw
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
  SpellsMenuVRAMLocation dw ; We draw at variable locations so we store the value here for restore

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

.include {"{LANGUAGE}/stats-hp-mp.asm"}

.unbackground $3592 $35ee
  ROMPosition $3592
.section "Spell selection finder" force ; not movable
DrawSpellsMenu:
  ; Original offsets:
  ; 3595: RAM address for reading in backup 
  ; 3598: VRAM address for reading in backup 
  ; 359b: VRAM dims for reading in backup
  ; 35b0: pointer to start of data in ROM, replaced with table below
  ; 35e4: RAM address for restoring backup
  ; 35e7: VRAM address for restoring backup
  ; 35ea: VRAM dims for restoring backup
  ; 1b6a: pointer VRAM location for battle
  ; 1ee1: pointer VRAM location for overworld
  ; b = spell count to draw, a = index of spell data to draw (0..5)
  ; Original code handles b = 0, we don't as the game can't reach that state
  push bc
    ; We want to compute hl = a'th spells menu data, de = VRAM address
    ld hl,SPELLS
    ld de,MENU_VRAM + BattleMenu_width * 2
    ; if a > 2 then it is the world menu, else the battle menu
    cp 3
    jr c,+
    ld de,MENU_VRAM + WorldMenu_width * 2
    ; We save this address for later
+:  ld (SpellsMenuVRAMLocation),de
    ld bc,SPELLS_dims
    push af
      call InputTilemapRect
    pop af
  pop bc
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

  ROMPosition $35e3
.section "CloseSpellsMenu" force ; not movable?
CloseSpellsMenu:
  ld hl,SPELLS
  ld de,(SpellsMenuVRAMLocation)
  ; We are short of space by one byte, so we trampoline to some free space.
  ; We could rewire calls to this function to save a few bytes.
  jp CloseSpellsMenu_helper
.ends
.section "CloseSpellsMenu helper" free
CloseSpellsMenu_helper:
  ld bc,SPELLS_dims
  jp OutputTilemapBoxWipePaging
.ends

  PatchW $1b6a MENU_VRAM + BattleMenu_width * 2 + ONE_ROW ; pointer VRAM location for battle
  PatchW $1ee1 MENU_VRAM + WorldMenu_width * 2 + ONE_ROW ; pointer VRAM location for overworld

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
MST:      .stringmap tilemap "│Meseta         " ; Spaces for padding; this needs to be big enough for all languages' stats windows
.ends

.slot 1
.section "Stats window drawing" superfree
.include {"{LANGUAGE}/stats-window.asm"}

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

.slot 2
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
.include {"{LANGUAGE}/lists.asm"}
.include "item-drawing.asm"
.include "window-ram-management.asm"
.include "save-game-handling.asm"

