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
  .unbackground $00745 $00750 ; Title screen menu
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
  .unbackground $03be8 $03cbf ; Save menu blank tilemap
  .unbackground $03dde $03df4 ; Dungeon font loader
  .unbackground $03eca $03fc1 ; background graphics lookup table
  .unbackground $03fc2 $03fd1 ; Sky Castle reveal palette
; Bank 1
  .unbackground $04059 $0407a ; password entered (unused)
  .unbackground $04091 $040a9 ; Save name entry
  .unbackground $040be $040c7 ; Save game pointer table
  .unbackground $04160 $0417a ; name entry screen special item handler
  .unbackground $04237 $04260 ; name entry screen cursor handling
  .unbackground $0429b $042b4 ; draw to tilemap during entry
  .unbackground $042b5 $042cb ; draw to RAM during entry
  .unbackground $04261 $04277 ; password population (unused)
  .unbackground $04396 $043e5 ; password lookup data (unused)
  .unbackground $043e6 $04405 ; text for "please enter your name"
  .unbackground $04406 $0448b ; tilemap for name entry
  .unbackground $0448c $04509 ; data for lookup table during entry
  .unbackground $045a4 $045c3 ; tile loading for intro
  .unbackground $059ba $059c9 ; Draw text box 20x6 (dialogue)
  .unbackground $05de9 $05e02 ; Party overworld sprite handling
  .unbackground $07fe5 $07fff ; Unused space + header
; Bank 2
  .unbackground $08000 $080b1 ; font tile lookup
  .unbackground $080b2 $0bd93 ; script
  .unbackground $0bd94 $0bf9b ; item names
  .unbackground $0bed0 $0bf9b ; item names - now SFG decoder
  .unbackground $0bf50 $0bf9b ; item names - now Huffman decoder init
  .unbackground $0bf9c $0bfdb ; item metadata
  .unbackground $0bfdc $0bfff ; blank
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
  .unbackground $44640 $47fff ; Palettes and tiles + unused space
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

; Filter macro for turning text into 16-bit tilemap entries.
; Sets the high priority bit on all tiles.
.macro TextToTilemap
.redefine _out 0
; This is like a 16-bit version of .asciitable. It's quite messy though...
.if \1 == ' '
  .redefine _out $10c0
.else
.if \1 == '.'
  .redefine _out $10ff
.else
.if \1 == ','
  .redefine _out $17f5 ; vflipped '
.else
.if \1 == '|'
  .redefine _out $11f3
.else
.if \1 == ':'
  .redefine _out $11f4
.else
.if \1 == '`'
  .redefine _out $11f5
.else
.if \1 == '?'
  .redefine _out $11f6
.else
.if \1 == $27 ; '\''
  .redefine _out $11f7
.else
.if \1 == '-'
  .redefine _out $11fa
.else
.if \1 == '!'
  .redefine _out $11fb
.else
.if \1 >= '0'
  .if \1 <= '9'
    .redefine _out $10c1 + \1 - '0'
  .else
  .if \1 >= 'A'
    .if \1 <= 'Z'
      .redefine _out $10cb + \1 - 'A'
    .else
    .if \1 >= 'a'
      .if \1 <= 'z'
        .redefine _out $10e5 + \1 - 'a'
      .endif
    .endif
  .endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.endif
.if _out == 0
  .printt "Unhandled character '"
  .printt "\1"
  .printt "' in TextToTilemap macro\n"
  .fail
.endif
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

.macro DefineVRAMAddress args name, x, y
.define \1 $7800 + ((y * 32) + x) * 2
.endm

.asciitable
; Matches the .tbl file used for items. Some values have different meanings in the main script.
map " " = $00
map "0" to "9" = $01
map "A" to "Z" = $0b
map "a" to "z" = $25
; Punctuation
map "." = $3F
map ":" = $40
;map "‘" = $41 ; UTF-8 not working :(
;map "’" = $42
map "'" = $42
map "," = $43
map "-" = $44
map "!" = $45
map "?" = $46
; Scripting codes
map "+" = $4F ; Conditional space (soft wrap point)
map "@" = $50 ; Newline (when in a menu)
map "%" = $51 ; Hyphen (when wrapped)
map "[" = $52 ; [] = do not draw in menus, only during narratives
map "]" = $53
; Articles
map "~" = $54 ; a
map "#" = $55 ; an
map "^" = $56 ; the
.enda

.define LETTER_S  $37   ; suffix letter ('s')

.macro String args s
.db s.length
.asc s
.endm

.define PAGING_SRAM $fffc
.define PAGING_SLOT_1 $fffe
.define PAGING_SLOT_2 $ffff
.define PORT_VDP_DATA $be
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
.define NumberToShowInText  $c2c5 ; b Number to show in text
.define EnemyIndex          $c2e6 ; b Index into Enemies
.define VehicleType         $c30e ; b Zero when walking
.define IntroState          $c600 ; b $ff when intro starts
.define SaveTilemapOld      $8100 ; Tilemap data for save - original
.define SaveTilemap         $8040 ; Tilemap data for save - new - moved to make more space

; RAM used by the hack. The original game doesn't venture higher than $de96, we use even less... so it's safe to use this chunk up high (so long as we don't hit $dffc+).

.enum $df00 export
  ; Script decoding
  STR       dw   ; pointer to WRAM string
  LEN       db   ; length of substring in WRAM
  POST_LEN  db   ; post-string hint (ex. <Herb>...)
  LINE_NUM  db   ; # of lines drawn
  FLAG      db   ; auto-wait flag
  ARTICLE   db   ; article category #
  SUFFIX    db   ; suffix flag
  HLIMIT    db   ; horizontal chars left
  VLIMIT    db   ; vertical line limit
  SCRIPT    dw   ; pointer to script
  BANK      db   ; bank holding script
  BARREL    db   ; current Huffman encoding barrel
  TREE      db   ; current Huffman tree
  VRAM_PTR  dw   ; VRAM address
  FULL_STR  dw   ; pointer backup
  TEMP_STR  .db  ; buffer for strings, shared with following
  PSGaiden_decomp_buffer    dsb 32 ; buffer for tile decoding
  HasFM     db   ; copy of FM detection result
  MusicSelection db ; music test last selected song
  
  SettingsStart: .db
  MovementSpeedUp db ; non-zero for speedup
  ExpMultiplier  db ; b Experience scaling
  MoneyMultiplier  db ; b Money pickups scaling
  FewerBattles db ; b 1 to halve battle probability
  BrunetteAlisa db ; 1 to enable brown hair
  Font db ; 1 for the "alternate" font

  SettingsEnd: .db

  Port3EValue db  ; Value left at $c000 by the BIOS
.ende

; Functions in the original game we make use if
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

.slot 1

.include "PSGaiden_tile_decomp.inc"

  ROMPosition $00486
.section "Trampoline to new bitmap decoder" force ; not movable
; RLE/LZ bitmap decoder
; - support mapper

; Redirects calls to LoadTiles4BitRLENoDI@$0486 (decompress graphics, interrupt-unsafe version)
; to a ripped decompressor from Phantasy Star Gaiden
LoadTiles:
  ld a,:PSGaiden_tile_decompr
  ld (PAGING_SLOT_1),a
  
  call PSGaiden_tile_decompr

  ld a,1
  ld (PAGING_SLOT_1),a

  ret
.ends

; New title screen ------------------------
  PatchB $2fdb $6d    ; cursor tile index for title screen

.slot 2
.section "Replacement title screen" superfree
TitleScreenTiles:
.incbin "new_graphics/title.psgcompr"
.ends

.section "Title screen name table" superfree
TitleScreenTilemap:
.incbin "new_graphics/title-nt.pscompr"
.ends

.section "Replacement title screen part 2" superfree
TitleScreenLogoTiles:
.incbin "new_graphics/logo.psgcompr"
.ends

.section "Title screen name table for logo" superfree
TitleScreenLogoTilemap:
.incbin "new_graphics/logo-nt.bin"
.ends

  ROMPosition $00925
.section "Title screen palette" force ; not movable
TitleScreenPalette:
.incbin "new_graphics/title-pal.bin"
.dsb 18 0 ; black background
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
  LoadPagedTiles TitleScreenTiles $4000

  ld hl,PAGING_SLOT_2
  ld (hl),:TitleScreenTilemap
  ld hl,TitleScreenTilemap
  call TitleScreenExtra
  ; Size matches original
.ends

.section "Title screen extra tile load" free
TitleScreenExtra:
  call DecompressToTileMapData ; what we stole to get here
  
  LoadPagedTiles TitleScreenLogoTiles $6000

  ld a,:TitleScreenLogoTilemap
  ld (PAGING_SLOT_2),a
  
  ; We want to emit a tilemap sub-area. There isn't a function in the game to do this...
  ld hl,TitleScreenLogoTilemap ; source
  ld de,$d000 + (32 * 2 + 4) * 2 ; destination
  ld b,13 ; rows
-:push bc 
    ld bc,17*2 ; bytes per row
    ldir
    ; next row
    ld a,64-17*2
    add a,e
    ld e,a
    adc a,d
    sub e
    ld d,a
  pop bc
  djnz -
  
  call SettingsFromSRAM ; Load settings from SRAM

  jp LoadFonts ; and ret
.ends

  ROMPosition $00ce4
.section "BG loader patch 1" size 14 overwrite ; not movable
  LoadPagedTiles OutsideTiles $4000
.ends

.slot 2
.section "Outside tiles" superfree
OutsideTiles:
.incbin "new_graphics/world1.psgcompr"
.ends

.section "Town tiles" superfree
TownTiles:
.incbin "new_graphics/world2.psgcompr"
.ends

  ROMPosition $00cf4
.section "BG loader patch 2" size 14 overwrite ; not movable
  LoadPagedTiles TownTiles $4000
.ends

; Other backgrounds
; These are referenced by a structure originally at $3eca... but it is now moved.

 ROMPosition $3e8e
.section "Patch scene struct 1" size 3 overwrite ; not movable
PatchSceneStruct1:
  ld de,SceneData-8
.ends

  ROMPosition $3e64
.section "Patch scene struct 2" size 3 overwrite ; not movable
PatchSceneStruct2:
  ld de,SceneData-3
.ends

.bank 1 slot 1
.section "Scene data lookup" free ; (can be bank 0 or 1)
.struct Scene
  PaletteTilesBank  db
  Palette           dw
  Tiles             dw
  TilemapBank       db
  Tilemap           dw
.endst

.macro SceneDataStruct ; structure holding scene data (palette, tiles and tilemap offsets)
; One scene has the palette unpaged, all others require it to be in the same bank as the tiles
.dstruct Scene_\1_\3 instanceof Scene data :Tiles\2, Palette\1, Tiles\2, :Tilemap\3, Tilemap\3
.endm

SceneData:
 SceneDataStruct PalmaOpen         ,PalmaAndDezorisOpen,PalmaOpen
 SceneDataStruct PalmaForest       ,PalmaForest        ,PalmaForest
 SceneDataStruct PalmaSea          ,PalmaSea           ,PalmaSea
 SceneDataStruct PalmaSea          ,PalmaSea           ,PalmaCoast
 SceneDataStruct MotabiaOpen       ,MotabiaOpen        ,MotabiaOpen
 SceneDataStruct DezorisOpen       ,PalmaAndDezorisOpen,DezorisOpen
 SceneDataStruct PalmaOpen         ,PalmaAndDezorisOpen,PalmaLavapit
 SceneDataStruct PalmaTown         ,PalmaTown          ,PalmaTown
 SceneDataStruct PalmaVillage      ,PalmaVillage       ,PalmaVillage
 SceneDataStruct Spaceport         ,Spaceport          ,Spaceport
 SceneDataStruct DeadTrees         ,DeadTrees          ,DeadTrees
 SceneDataStruct DezorisForest     ,PalmaForest        ,PalmaForest
 SceneDataStruct AirCastle         ,AirCastle          ,AirCastle
 SceneDataStruct GoldDragon        ,GoldDragon         ,GoldDragon
 SceneDataStruct AirCastleFull     ,AirCastle          ,AirCastle
 SceneDataStruct BuildingEmpty     ,Building           ,BuildingEmpty
 SceneDataStruct BuildingWindows   ,Building           ,BuildingWindows
 SceneDataStruct BuildingHospital1 ,Building           ,BuildingHospital1
 SceneDataStruct BuildingHospital2 ,Building           ,BuildingHospital2
 SceneDataStruct BuildingChurch1   ,Building           ,BuildingChurch1
 SceneDataStruct BuildingChurch2   ,Building           ,BuildingChurch2
 SceneDataStruct BuildingArmoury1  ,Building           ,BuildingArmoury1
 SceneDataStruct BuildingArmoury2  ,Building           ,BuildingArmoury2
 SceneDataStruct BuildingShop1     ,Building           ,BuildingShop1
 SceneDataStruct BuildingShop2     ,Building           ,BuildingShop2
 SceneDataStruct BuildingShop3     ,Building           ,BuildingShop3
 SceneDataStruct BuildingShop4     ,Building           ,BuildingShop4
 SceneDataStruct BuildingDestroyed ,Building           ,BuildingDestroyed
 SceneDataStruct Mansion           ,Mansion            ,Mansion
 SceneDataStruct LassicRoom        ,LassicRoom         ,LassicRoom
 SceneDataStruct DarkForce         ,DarkForce          ,DarkForce

.ends

; Some palettes are referenced elsewhere too
  PatchB $4750 :PaletteGoldDragon
  PatchW $4752 PaletteGoldDragon
  PatchB $588d :PaletteDarkForce
  PatchW $588f PaletteDarkForce

.bank 2 slot 2

.section "Palma and Dezoris open area graphics" superfree
PalettePalmaOpen:      CopyFromOriginal $40000 16
PaletteDezorisOpen:    CopyFromOriginal $40010 16
TilesPalmaAndDezorisOpen: .incbin "new_graphics/bg1.psgcompr"
.ends

.section "Forest graphics" superfree
PalettePalmaForest:    CopyFromOriginal $40f16 16
PaletteDezorisForest:  CopyFromOriginal $40f26 16
TilesPalmaForest:     .incbin "new_graphics/bg2.psgcompr"
.ends

.section "Palma sea graphics" superfree
PalettePalmaSea:       CopyFromOriginal $41c72 16
TilesPalmaSea: .incbin "new_graphics/bg3.psgcompr"
.ends

.section "Motabia open graphics" superfree
PaletteMotabiaOpen: CopyFromOriginal $433f6 16
TilesMotabiaOpen: .incbin "new_graphics/bg5.psgcompr"
.ends

.section "Palma town graphics" superfree
PalettePalmaTown:     CopyFromOriginal $44640 16
TilesPalmaTown: .incbin "new_graphics/bg8.psgcompr"
.ends

.section "Palma village graphics" superfree
PalettePalmaVillage:  CopyFromOriginal $457c4 16
TilesPalmaVillage: .incbin "new_graphics/bg9.psgcompr"
.ends

.section "Spaceport graphics" superfree
PaletteSpaceport:     CopyFromOriginal $464b1 16
TilesSpaceport: .incbin "new_graphics/bg10.psgcompr"
.ends

.section "Dead trees graphics" superfree
PaletteDeadTrees:     CopyFromOriginal $46f58 16
TilesDeadTrees: .incbin "new_graphics/bg11.psgcompr"
.ends

.section "Air castle graphics" superfree
PaletteAirCastle:     CopyFromOriginal $5ac7d 16
PaletteAirCastleFull: CopyFromOriginal $03fc2 16
TilesAirCastle: .incbin "new_graphics/bg13.psgcompr"
.ends

.section "Gold dragon graphics" superfree
PaletteGoldDragon: CopyFromOriginal $2c000 16
TilesGoldDragon: .incbin "new_graphics/bg14.psgcompr"
.ends

.section "Building graphics" superfree
PaletteBuildingEmpty:     CopyFromOriginal $5ea9f 16
PaletteBuildingWindows:   CopyFromOriginal $5eaaf 16
PaletteBuildingHospital1: CopyFromOriginal $5eabf 16
PaletteBuildingHospital2: CopyFromOriginal $5eacf 16
PaletteBuildingChurch1:   CopyFromOriginal $5eadf 16
PaletteBuildingChurch2:   CopyFromOriginal $5eaef 16
PaletteBuildingArmoury1:  CopyFromOriginal $5eaff 16
PaletteBuildingArmoury2:  CopyFromOriginal $5eb0f 16
PaletteBuildingShop1:     CopyFromOriginal $5eb1f 16
PaletteBuildingShop2:     CopyFromOriginal $5eb2f 16
PaletteBuildingShop3:     CopyFromOriginal $5eb3f 16
PaletteBuildingShop4:     CopyFromOriginal $5eb4f 16
PaletteBuildingDestroyed: CopyFromOriginal $5eb5f 16
TilesBuilding: .incbin "new_graphics/bg16.psgcompr"
.ends

.section "Mansion graphics" superfree
PaletteMansion: CopyFromOriginal $27b14 16
TilesMansion: .incbin "new_graphics/bg29.psgcompr"
.ends

.section "Lassic graphics" superfree
PaletteLassicRoom: CopyFromOriginal $524da 16
TilesLassicRoom: .incbin "new_graphics/bg30.psgcompr"
.ends

.section "Dark Force graphics" superfree
PaletteDarkForce: CopyFromOriginal $4c000 16
TilesDarkForce: .incbin "new_graphics/bg31.psgcompr"
.ends

  ; We also need the non-relocated tilemap and palette addresses to populate the table...
.macro LabelAtPosition
  ROMPosition \1
  \2:
.endm

  LabelAtPosition $3c000 TilemapPalmaOpen
  LabelAtPosition $3c333 TilemapPalmaForest
  LabelAtPosition $3c6e9 TilemapPalmaSea
  LabelAtPosition $3c9a0 TilemapPalmaCoast
  LabelAtPosition $3cc80 TilemapMotabiaOpen
  LabelAtPosition $3ce46 TilemapDezorisOpen
  LabelAtPosition $3d116 TilemapPalmaLavapit
  LabelAtPosition $3d47b TilemapPalmaTown
  LabelAtPosition $3d70a TilemapPalmaVillage
  LabelAtPosition $3da2c TilemapSpaceport
  LabelAtPosition $3dc11 TilemapDeadTrees
  LabelAtPosition $5bc32 TilemapAirCastle
  LabelAtPosition $5be2a TilemapGoldDragon
  LabelAtPosition $5c000 TilemapBuildingEmpty
  LabelAtPosition $5c31e TilemapBuildingWindows
  LabelAtPosition $5c654 TilemapBuildingHospital1
  LabelAtPosition $5c8dd TilemapBuildingHospital2
  LabelAtPosition $5cba6 TilemapBuildingChurch1
  LabelAtPosition $5cf8e TilemapBuildingChurch2
  LabelAtPosition $5d2ed TilemapBuildingArmoury1
  LabelAtPosition $5d61b TilemapBuildingArmoury2
  LabelAtPosition $5d949 TilemapBuildingShop1
  LabelAtPosition $5dca3 TilemapBuildingShop2
  LabelAtPosition $5dfe3 TilemapBuildingShop3
  LabelAtPosition $5e310 TilemapBuildingShop4
  LabelAtPosition $5e64c TilemapBuildingDestroyed
  LabelAtPosition $2778b TilemapMansion
  LabelAtPosition $6fd63 TilemapLassicRoom
  LabelAtPosition $37db1 TilemapDarkForce


  ROMPosition $03eb0
.section "Background scene loader tile loader patch" size 8 overwrite ; not movable
BackgroundSceneLoaderTileLoaderPatch:
; Original code:
; ld h,(hl)
; ld l,a         ; hl = offset
; ld de,$4000
; call LoadTiles4BitRLE
  ld d,(hl)
  ld e,a
  ld hl,$4000
  call LoadTiles
.ends

; Font

.slot 2
.section "Font part 1" superfree
FONT1: .incbin "new_graphics/font1.psgcompr"
FONT2: .incbin "new_graphics/font2.psgcompr"
FONT1a: .incbin "new_graphics/font1a.psgcompr"
FONT2a: .incbin "new_graphics/font2a.psgcompr"
LoadFontsImpl:
    ld hl,Font1VRAMAddress
    ld de,FONT1
    ld a,(Font)
    or a
    jr z,+
    ld de,FONT1a
+:  call LoadTiles
    ; then fall through into the following

LoadUpperFontImpl:
    ld hl,Font2VRAMAddress
    ld de,FONT2
    ld a,(Font)
    or a
    jr z,+
    ld de,FONT2a
+:  jp LoadTiles ; and ret
.ends

.define Font1VRAMAddress $5800
.define Font2VRAMAddress $7e00

.bank 0 slot 0
.section "Load font to VRAM" free
LoadFonts:
  ld a,(PAGING_SLOT_2)
  push af
    ld a,:LoadFontsImpl
    ld (PAGING_SLOT_2),a
    call LoadFontsImpl
  pop af
  ld (PAGING_SLOT_2),a
  ret

LoadUpperFont:
  ld a,(PAGING_SLOT_2)
  push af
    ld a,:LoadUpperFontImpl
    ld (PAGING_SLOT_2),a
    call LoadUpperFontImpl
  pop af
  ld (PAGING_SLOT_2),a
  ret
.ends

; We use a macro to patch out all the places the font is laoded...
.macro PatchFontLoader args function, start, end
  .unbackground start end-1
  ROMPosition start
  .section "Font patch \@" force
    call function
    JR_TO end
  .ends
.endm

  PatchFontLoader LoadFonts $45a4 $45c4 ; Intro
  PatchFontLoader LoadFonts $10e3 $10fa ; Dungeon
  PatchFontLoader LoadFonts $3dde $3df5 ; Overworld
  PatchFontLoader LoadFonts $48da $48f1 ; Cutscene
  PatchFontLoader LoadUpperFont $6971 $697f ; After dungeon pitfall - scrolling overwrites the "font2" section but we need to not load the "main" font because during the ending it's non-standard

; Text renderer

  ROMPosition $34f2
.section "Character drawing" force ; not movable
; Originally t0d.asm
CharacterDrawing:
; Replacing draw-one-character function from $34f2-3545
; drawing 2 tilemap chars, with conditional mirroring, and a scrolling handler,
; with a new one from $3f42-3f66 that draws a single char using a 2-byte lookup
; and leaves the scrolling to be handled by the word-wrapping code elsewhere

  cp SymbolNewLine
  jr nz,+
  xor a ; set to 0 for newlines to avoid drawing junk
+:
  di            ; prepare VRAM output

  push af
    rst $08      ; Set address
  pop af
  
  call EmitCharacter
  
  ; Bump VRAM address
  inc de
  inc de

  ei               ; Wait for VBlank
  ld a,10          ; Trigger a name table refresh
  call ExecuteFunctionIndexAInNextVBlank

  dec b             ; Shrink window width
  ret
.ends

.section "Font lookup helper" free
EmitCharacter:
  ; Short of space in bank 0, we trampoline...
  push hl
    ; We need to stash a, we also double it here...
    add a,a
    ld l,a
    ld a,(PAGING_SLOT_1)
    push af
      ld a,:EmitCharacterImpl
      ld (PAGING_SLOT_1),a
      call EmitCharacterImpl
    pop af
    ld (PAGING_SLOT_1),a
  pop hl
  ret
.ends

.bank 1 slot 1
.section "Font lookup helper part 2" superfree
EmitCharacterImpl:
  ; We look up the two-byte tile data for character index a, 
  ; and emit to the VDP
  ld h,>FontLookup ; Aligned table

  ld a,(PAGING_SLOT_2)
  push af
    ld a,:FontLookup
    ld (PAGING_SLOT_2),a
    ld a,(hl)
    out (PORT_VDP_DATA),a
    push af       ; VRAM wait
    pop af  
    inc hl
    ld a,(hl)
    out (PORT_VDP_DATA),a
  pop af
  ld (PAGING_SLOT_2),a
  ret
.ends

.bank 0 slot 0 ; Dictionary lookup must be in slot 0 as the others are being mapped.

.section "Dictionary lookup" free
  ; HL = Table offset

DictionaryLookup:
  push af
    ld a,:Lists ; Load normal lists
    ld (PAGING_SLOT_2),a
    jr +

DictionaryLookup_Substring:
  push af
    ld a,:Words ; Load dictionary
    ld (PAGING_SLOT_2),a

+:pop af      ; Restore index #
  ld b,0      ; 0-255 indices

-:ld c,(hl)   ; Grab string length
  or a        ; Check for zero strings left
  jr z,_Copy  ; _Stop if found

  inc hl      ; Bypass length byte
  add hl,bc   ; Bypass physical string
  dec a       ; One less item to look at
  jr -        ; Keep searching

_Copy:
  ld a,c      ; Transfer length
  ld (LEN),a    ; Save length
  inc hl      ; Skip length byte

  ld de,TEMP_STR    ; Copy to work RAM
  ld (STR),de   ; Save pointer location
  ldir
  ld a,2    ; Normal page
  ld (PAGING_SLOT_2),a

  ret
.ends

.slot 1
.section "Additional scripting codes" superfree
AdditionalScriptingCodes:
; Originally t4a_2.asm
; Narrative formatter
; - Extra scripting codes

_Start:
  call SubstringFormatter    ; Check substring RAM

  cp SymbolNewLine
  jr z,+

  cp SymbolEnd      ; Look for decode flag
  jp nz,_Done

_Decode:
  call SFGDecoder    ; Regular decode

+:cp SymbolPostHint
  jr nz,+   ; Check next code

  call SFGDecoder    ; Grab length
  ld (POST_LEN),A   ; Cache it
  jr _Decode   ; Immediately grab next code

+:cp $00      ; Whitespace
  jr nz,+   ; Check next code

  push hl
    ld (TEMP_STR),a   ; Store WS, $00
    inc a             ; A = $01
    ld (LEN),a        ; Store length
    ld hl,TEMP_STR    ; Load string location
    ld (STR),hl       ; Store string pointer
  pop hl

  call SubstringFormatter    ; Our new dictionary lookup code will do auto-formatting

  ; Intentional fall-through

+:cp SymbolWaitMore
  jr nz,+

_Reset_Lines:
  push af
    xor a

_Set_Lines:
    ld (LINE_NUM),a   ; Clear # lines used
  pop af

  jp _Done

+:cp SymbolNewLine
  jr nz,+   ; Next code
  push hl     ; Automatic narrative waiting

    ld hl,LINE_NUM    ; Grab # lines drawn
    inc (hl)    ; One more line _Break
    ld l,(hl)   ; Load current value

    ld a,(VLIMIT)   ; Read vertical limit
    cp l      ; Check if limit reached
    jr z,_WAIT

_NO_WAIT:
    ld a,SymbolNewLine  ; Reload newline
    jr ++

_WAIT:
    ld a,SymbolWaitMore ; wait more
    ld (FLAG),a   ; Raise flag
    ld hl,LINE_NUM

_Wait_Clear:
    dec (hl)    ; Keep shrinking # lines drawn
    jr nz,_Wait_Clear  ; to save 1 byte of space

++:
  pop hl      ; Restore stack
  jr _Done

+:cp WordListStart
  jr c,+    ; Control codes, don't interfere

  sub WordListStart     ; Subtract offset

  push hl
  push de
  push bc

    ld hl,Words
    call DictionaryLookup_Substring   ; Relocate substring entry and copy

  pop bc
  pop de
  pop hl

  jp _Start    ; Our new dictionary lookup code

+:cp SymbolArticle
  jr nz,+

  call SFGDecoder    ; Grab #
  ld (ARTICLE),a
  jp _Decode

+:cp SymbolSuffix
  jr nz,+

  ld a,(SUFFIX)   ; Check flag
  or a
  jp z,_Decode   ; No 's' needed

  ld a,LETTER_S   ; add 's'

+:

_Done:
  cp SymbolWait ; Old code
  ret     ; Go to remaining text handler

.enum $4f ; Scripting codes. The start value must be greater than the highest index character.
  SymbolStart     .db
  SymbolPlayer    db ; $4f,
  SymbolMonster   db ; $50,
  SymbolItem      db ; $51,
  SymbolNumber    db ; $52,
  SymbolUnused    db ; no $53
  SymbolNewLine   db ; $54,
  SymbolWaitMore  db ; $55,
  SymbolEnd       db ; $56,
  SymbolDelay     db ; $57,
  SymbolWait      db ; $58,
  SymbolPostHint  db ; $59,
  SymbolArticle   db ; $5a,
  SymbolSuffix    db ; $5b,
  WordListStart   db ; $5c
.ende

SubstringFormatter:
; Needs to be in the same bank as AdditionalScriptingCodes
; Originally t4a_3.asm
; Narrative formatter
; - Dictionary processing

; substring inserter
; b = space left on line
; (STR)w = pointer to string
; (LEN)b = length
; returns tile index to be drawn in a,
; or a newline if a new line is needed for this insertion

_Lookup:
  ld a,(LEN)    ; Grab length of string
  or a      ; Check for zero-length
  ld a,SymbolEnd    ; Load 'abort' flag
  ret z     ; Return if NULL

_Substring:
  ld a,b      ; Save width
  ld (HLIMIT),a

  push hl     ; Stack registers
  push bc

    ld bc,(STR)   ; Grab raw text location
    ld hl,LEN   ; Grab address of length

    ; ------------------------------------------------------
    ; Article (The, An, A) handler

    push de     ; init

      ld a,(ARTICLE)    ; Check for article usage
      or a
      jr z,_Art_Exit   ; article = none

      ld de,ArticlesLower
      cp $01      ; article = a,an,the
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      ; a = $02 = article = A,An,The

_Start_Art:
      ld a,(bc)   ; Grab index
      sub $54     ; Remap index range
      jr c,_Art_Done ; if there is a letter there, it'll be 0..$40ish. So do nothing.
      add a,a     ; Multiply by two
      add a,e     ; Add offset
      ld e,a      ; (note: be careful we don't byte-wrap)

      ld a,(de)   ; Grab final string offset
      inc de
      push af
        ld a,(de)
        ld d,a
      pop af
      ld e,a

_Add_Art:
      ld a,(de)   ; grab font #
      cp SymbolEnd
      jr z,_Art_Done

      dec bc      ; bump dst pointer
      ld (bc),a   ; add tile
      inc de      ; bump src
      inc (hl)    ; bump length
      jr _Add_Art

_Art_Done:
      ld (STR),bc   ; store new text pointer
      xor a
      ld (ARTICLE),a    ; lower flag

_Art_Exit:
    pop de      ; now proceed normally
    ld bc,(STR)   ; Grab raw text location (again)
    jr _Initial_Codes

; Articles are stored backwards
.macro Article
  .asc \1
  .db SymbolEnd
.endm

ArticlesLower: ; Note: code assumes this is not over a 256b boundary. We don't enforce that here...
.dw +, ++, +++
+:    Article " a"
++:   Article " na"
+++:  Article " eht"

ArticlesInitialUpper:
.dw +, ++, +++
+:    Article " A"
++:   Article " nA"
+++:  Article " ehT"

_Initial_Codes:
    ld a,(bc)   ; Grab character
    cp SymbolStart      ; Skip initial codes
    jr c,_Begin_Scan   ; Look for first real font tile

    ; Initial code skipper:
    inc bc      ; Bump pointer
    ld (STR),bc   ; Save pointer
    dec (hl)    ; Shrink length
    jr nz,_Initial_Codes ; Loop if still alive

_Begin_Scan:
    push hl     ; Save new current length
    push bc     ; Save new text pointer

      ld h,(hl)   ; Init string counter
      ld l,0      ; Current length is zero

      call _One_Font   ; get length up to next whitespace in l

      ld a,(HLIMIT)   ; Remaining width
      sub l     ; Remove characters used

      jr nc,_No_Spill    ; No text spillage

_Text_Spill:
    pop bc      ; Restore old text pointer
    pop hl      ; Reload length pointer

    ld a,(bc)   ; Reload first scanned character
    or a      ; Check for whitespace ($00)
    jr nz,_Text_Spill_Line ; Don't eat non-WS

_Text_Spill_WS:
    inc bc      ; Bump text pointer
    ld (STR),bc   ; Store new location

    dec (hl)    ; Shrink length

_Text_Spill_Line:
    ld a,SymbolNewLine    ; newline

  pop bc      ; Stack registers
  pop hl
  ret     ; exit

_No_Spill:
    pop bc      ; Restore original text pointer
    pop hl      ; Restore length pointer

    dec (hl)    ; Shrink text length

    ld a,(bc)   ; Read in text character
    inc bc      ; Bump text pointer
    ld (STR),bc   ; Store new location

  pop bc      ; Stack registers
  pop hl
  ret

; Note: Treat first character as a regular tile, regardless of WS

_Scan_String:
  inc bc      ; Bump text cursor
  dec h     ; Shrink text
  jr z,_Stop   ; Length exhausted == 0

  ld a,(bc)   ; Grab character
  or a      ; Check for whitespace
  jr z,_Break    ; If char == 0, _Stop

  cp SymbolStart      ; Control codes
  jr nc,_Scan_String ; Ignore special script values

_One_Font:
  inc l     ; One font drawn
  jr _Scan_String

_Stop:
  ld bc,POST_LEN    ; Load post-hint address
  ld a,(bc)   ; Load post-hint value
  add a,l     ; Tack on length BUG?: two-word substitutions get the extra added to the first word
  ld l,a      ; Store for return

  xor a
  ld (bc),a   ; Clear post-hint value

_Break:
  ret
.ends

  ROMPosition $34aa
.section "Cutscene narrative init patch" overwrite ; not movable
CutsceneNarrativeInit:
  ; This code deliberately fills 6 bytes to patch over the original code:
; ld de,$7c0c
; ld bc,$0000
  ld a,0 ; method selection (0)
  call DecoderInit
  ret
  ; DecoderInit will call this label:
CutsceneNarrativeInitOriginalCode:
.ends

  ROMPosition $34b4
.section "Cutscene text decoder patch" overwrite ; not movable
CutsceneTextDecoder:
  ; This patches later in the same function as above. Original code:
; ld a,(hl)
; cp $57
; jr z,$34ed ; exit after pause
; cp $58
; jr z,$34e8 ; exit after button
  call AdditionalScriptingCodes ; handle extra narrative codes, performs comparison to $58 before returning
  jr z,ExitAfterButton
  cp $57
  jr z,ExitAfterPause
.ends

  ROMPosition $34e5
.section "Cutscene $55 clear code patch" overwrite ; not movable
CutsceneClearCode:
  jp CutsceneClear

  ; The rest is the same as the original code, but we want to get the labels for above
ExitAfterButton:
  call MenuWaitForButton
  pop de
  ret

ExitAfterPause:
  call Pause256Frames
  pop de
  ret
.ends

  ROMPosition $333f
.section "In-game narrative init patch" overwrite ; not movable
InGameNarrativeInit:
; Original code:
; ld a,(TextBox20x6Open)
; or a
  ; Patch is identical size
  dec a ; method selection (1) ; a is 2 due to existing code
  jp DecoderInit
  ; DecoderInit will call this label:
InGameNarrativeInitOriginalCode:
.ends

  ROMPosition $3365
.section "In-game text decoder" overwrite ; not movable
InGameTextDecoder:
  call AdditionalScriptingCodes
.ends


; Narrative scripting

  ROMPosition $33da
.section "Item lookup patch" force ; not movable
ItemLookup:
; Originally t1c_1.asm
; Item lookup
; Original code:
; push hl
;   ld a,(ItemIndex)
;   ld l,a
;   ld h,0
;   add hl,hl
;   add hl,hl
;   add hl,hl
;   push bc
;     ld bc,ItemTextTable
;     add hl,bc  ; hl = ItemTextTable
;   pop bc         ;    + ItemIndex * 8
;   ld a,8
;   call _DrawALetters
; pop hl
; inc hl
; jp _ReadData
; 26 bytes

  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,(ItemIndex)
    ld hl,Items

LookupItem:
    call DictionaryLookup

  pop bc
  pop de
  pop hl
  jp InGameTextDecoder    ; Decode next byte
  ; 18 bytes
.ends

  ROMPosition $33aa
.section "Player lookup patch" force ; not movable
PlayerLookup:
; Originally t1c_2.asm
; Player lookup
; Original code:
; push hl
;   ld a,(TextCharacterNumber)
;   and $03        ; just low 2 bits
;   add a,a        ; multiply by 4
;   add a,a
;   ld hl,_CharacterNames
;   add a,l
;   ld l,a
;   adc a,h
;   sub l          ; hl = _CharacterNames
;   ld h,a         ; + 4*TextCharacterNumber
;   ld a,4
;   call _DrawALetters
; pop hl
; inc hl             ; next data
; jp _ReadData
; 25 bytes

  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,(NameIndex)
    and 3 ; I guess it uses the other bits for something?
    ld hl,Names
    jp LookupItem
  ; 13 bytes
.ends

  ROMPosition $33c8
.section "Enemy lookup patch" force ; not movable
EnemyLookup:
; Enemy lookup
; Original code:
; push hl
;   ld hl,EnemyName
;   ld a,8
;   call _DrawALetters
; pop hl
; inc hl
; jp _ReadData
; 12 bytes
  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp
    ld a,(EnemyIndex)
    ld hl,Enemies
    jp LookupItem
  ; 10 bytes
.ends

  ROMPosition $33f6
.section "Number lookup patch" force ; not movable
NumberLookup:
; Originally t1b.asm
; Narrative number BCD creater
; in-line number display
; Old: inline looping (costs space), simple, direct output
; New: renders string to a temp buffer for wrapping,
;      stores a flag to tell if it was singular or plural,
;      pulls digit calculation out to save space
;      105 bytes
  jr z,_DRAW_NUMBER ; draw number if z
  call CharacterDrawing ; else draw a regular letter
  jp InGameTextDecoder         ; and loop

_DRAW_NUMBER:
  push hl      ; Save string ptr
  push bc      ; Width, temp
  push ix      ; Temp

    ld hl,(NumberToShowInText)    ; Load 16-bit parameter
    ld ix,TEMP_STR   ; Decode to buffer

    ld bc,10000    ; # 10000's
    call _BCD_Digit
    ld (ix+0),a

    ld bc,1000     ; # 1000's
    call _BCD_Digit
    ld (ix+1),a

    ld bc,100      ; # 100's
    call _BCD_Digit
    ld (ix+2),a

    ld bc,10       ; # 10's
    call _BCD_Digit
    ld (ix+3),a

    ld a,l      ; # 1's (_BCD_Digit has made it only possible to be in the range 0..9)
    add a,1     ; add 1 because result = digit+1
    ld (ix+4),a


    ; scan the resultant string to see where the first non-zero digit is
    ; but we want to show the last digit even if it is zero
    ld b,4      ; look at 4 digits max
    ld hl,TEMP_STR    ; scan value

_Scan:
    ld a,(hl)    ; load digit
    cp $01      ; check for '0'
    jr nz,_Done
    inc hl      ; bump pointer
    djnz _Scan

_Done:
    ld a,b
    inc a         ; 1 <= length <= 5
    ld (STR),hl   ; save ptr to number string
    ld (LEN),a    ; save length

    ; length != 1 -> must be plural
    cp 1
    jr nz,_Plural  ; length must be 1

    ; else check for '1'
    ld a,(hl)
    cp $02      ; last digit = '1'
    jr nz,_Plural

_Singular:
    xor a      ; Clear flag

_Plural:
    ; a is non-zero on jumps to this point
    ; and zero for the singular case
    ld (SUFFIX),a    ; 'x' mesata(s)

  pop ix      ; Restore stack
  pop bc
  pop hl

  inc hl      ; Process next script
  jp InGameTextDecoder

_BCD_Digit:
  xor a ; clear carry flag, a = 0

; subtract bc from hl until it overflows, then add it on again
; return a = number of subtractions done until overflow occurred,
;        hl = hl % bc
; so a = hl / bc + 1 (integer division + 1)
; eg. hl =  9999, bc = 10000, a = 1
; eg. hl = 10000, bc = 10000, a = 2
-:sbc hl,bc    ; Divide by subtraction
  inc a        ; Bump place marker
  jr nc,-      ; No underflow

  add hl,bc    ; Restore value from underflowed subtraction
  ret
.ends

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

; Lists

.slot 2
.section "Enemy, name, item lists" superfree
Lists:
; Order is important!
Items:
  ; Max width 18 excluding control characters and [...] parts
  String " " ; empty item (blank)
; weapons: 01-0f
  String "~Wood Cane"
  String "~Short Sword"
  String "#Iron Sword"
  String "~Psycho Wand"
  String "~Saber Claw"
  String "#Iron Axe"
  String "~Titanium Sword"
  String "~Ceramic Sword"
  String "~Needle Gun"
  String "~Silver Tusk"
  String "~Heat Gun"
  String "~Light Saber"
  String "~Laser Gun"
  String "~Laconian Sword"
  String "~Laconian Axe"
; armour: 10-18
  String "~Leather Clothes"
  String "~White Cloak"
  String "~Light Suit"
  String "#Iron Armor"
  String "~Spiky [Squirrel ]Fur"
  String "~Zirconian Mail"
  String "~Diamond Armor"
  String "~Laconian Armor"
  String "^Frad Cloak"
; shields: 19-20
  String "~Leather Shield"
  String "~Bronze Shield"
  String "#Iron Shield"
  String "~Ceramic Shield"
  String "#Animal Glove"
  String "~Laser Barrier"
  String "^Shield of Perseus"
  String "~Laconian Shield"
; vehicles: 21-23
  String "^LandMaster"
  String "^FlowMover"
  String "^IceDecker"
; items: 24+
  String "~PelorieMate"
  String "~Ruoginin"
  String "^Soothe Flute"
  String "~Searchlight"
  String "#Escape Cloth"
  String "~TranCarpet"
  String "~Magic Hat"
  String "#Alsuline"
  String "~Polymeteral"
  String "~Dungeon Key"
  String "~Telepathy Ball"
  String "^Eclipse Torch"
  String "^Aeroprism" ; $30
  String "^Laerma Berries"
  String "Hapsby"
  String "~Road Pass"
  String "~Passport"
  String "~Compass"
  String "~Shortcake"
  String "^Governor[-General]'s Letter"
  String "~Laconian Pot"
  String "^Light Pendant"
  String "^Carbuncle Eye"
  String "~GasClear"
  String "Damoa's Crystal"
  String "~Master System"
  String "^Miracle Key"
  String "Zillion"
  String "~Secret Thing"

Names:
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"

Enemies:
  String " " ; Empty
  String "^Monster Fly"
  String "^Green Slime"
  String "^Wing Eye"
  String "^Maneater"
  String "^Scorpius"
  String "^Giant Naiad"
  String "^Blue Slime"
  String "^Motavian Peasant"
  String "^Devil Bat"
  String "^Killer Plant"
  String "^Biting Fly"
  String "^Motavian Teaser"
  String "^Herex"
  String "^Sandworm"
  String "^Motavian Maniac"
  String "^Gold Lens" ; $10
  String "^Red Slime"
  String "^Bat Man"
  String "^Horseshoe Crab"
  String "^Shark King"
  String "^Lich"
  String "^Tarantula"
  String "^Manticort"
  String "^Skeleton"
  String "^Ant-lion"
  String "^Marshes"
  String "^Dezorian"
  String "^Desert Leech"
  String "^Cryon"
  String "^Big Nose"
  String "^Ghoul"
  String "^Ammonite" ; $20
  String "^Executor"
  String "^Wight"
  String "^Skull Soldier"
  String "^Snail"
  String "^Manticore"
  String "^Serpent"
  String "^Leviathan"
  String "^Dorouge"
  String "^Octopus"
  String "^Mad Stalker"
  String "^Dezorian Head"
  String "^Zombie"
  String "^Living Dead"
  String "^Robot Police"
  String "^Cyborg Mage"
  String "^Flame Lizard" ; $30
  String "Tajim"
  String "^Gaia"
  String "^Machine Guard"
  String "^Big Eater"
  String "^Talos"
  String "^Snake Lord"
  String "^Death Bearer"
  String "^Chaos Sorcerer"
  String "^Centaur"
  String "^Ice Man"
  String "^Vulcan"
  String "^Red Dragon"
  String "^Green Dragon"
  String "LaShiec"
  String "^Mammoth"
  String "^King Saber"
  String "^Dark Marauder"
  String "^Golem"
  String "Medusa"
  String "^Frost Dragon"
  String "Dragon Wise"
  String "Gold Drake"
  String "Mad Doctor"
  String "LaShiec"
  String "Dark Force"
  String "Nightmare"
; Terminator
.db $df
.ends

.section "Static dictionary" superfree
.block "Words"
; Note that the number of words we add here has a complicated effect on the data size.
; Adding more words costs space here (in a paged bank), but saves space in bank 2 - mostly,
; because it also increases the complexity of the Huffman trees.
; If our goal is to maximise script space then we should maximise the word count.
; The limit is 164 ($100 - WordListStart).
; If our goal is to minimise total space used across both the script and word list then the
; best number has to be found by brute force; for the 1.02 (English) script this was at 79.
Words:
.include "substring_formatter/words.asm"
; Terminator
.db $df
.endb
.ends

; English script

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
.include "menu_creater/menus.asm"
.endb
.ends

.include "menu_creater/menu-patches.asm"

  PatchB $3b58 :MenuData
  PatchB $3b82 :MenuData
  PatchB $3bab :MenuData

  ROMPosition $3211
.section "HP letters" size 4 overwrite ; not movable
.dwm TextToTilemap "HP"
.ends

  ROMPosition $3219
.section "MP letters" size 4 overwrite ; not movable
.dwm TextToTilemap "MP"
.ends

  ROMPosition $35a2
.section "Spell selection finder" overwrite ; not movable
SpellSelectionFinder:
; Originally t2b_1.asm
; Spell selection offset finder

.define MENU_SIZE (14*2)*6 ; top border + text

  ld de,MENU_SIZE   ; menu size

  inc a     ; init
  ld h,0
  ld l,h

-:dec a     ; loop
  jr z,+

  add hl,de   ; skip menu
  jr -

+:
.ends

  ROMPosition $35c5
.section "Spell blank line" size 14 force; not movable
SpellBlankLine:
; Originally t2b_2.asm
; Spell selection blank line drawer
; - support code
; Original code:
; ld     a,b      ; compute a = b * 12 (to find where to start copying the menu data)
; add    a,a      ; a=2b
; ld     l,a      ; l=2b
; add    a,a      ; a=4b
; add    a,l      ; a=6b
; add    a,a      ; a=12b
; ld     hl,$ba3f
; add    a,l
; ld     l,a
; adc    a,h
; sub    l
; ld     h,a
  ; We just don't draw "empty" spell menus...
  ld hl,SpellMenuBottom
  ld bc,1<<8 + 14*2  ; width of line
  jp $3b81 ; draw and exit
.ends

.slot 2
.section "Opening cinema" superfree
.block "Opening"
Opening:
.include "menu_creater/opening.asm"
.endb
.ends

.include "menu_creater/opening-patches.asm"

  PatchB $45d7 :Opening ; - source bank


; relocate Tarzimal's tiles

.slot 2
.section "Tarzimal tiles" superfree
TilesTarzimal: CopyFromOriginal $4794a 1691
.ends

; rewire pointer to them
  PatchB $ccaf :TilesTarzimal
  PatchW $ccb0 TilesTarzimal


.slot 1
.section "Scripting code" superfree
; Originally t2a.asm
; Item window drawer (generic)

inventory:
  ld b,8    ; 8 items total

-:push bc
  push hl

    di
      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM ; changed address
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out 2 lines of text
    call _wait_vblank

  pop hl
  pop bc

  inc hl      ; next item
  djnz -

  ret
; ________________________________________________________

shop:
  ld b,3    ; 3 items total

-:push bc
  push hl

    di
      ld a,3 ; Shop data bank
      ld (PAGING_SLOT_2),a

      ld a,(hl)   ; grab item #
      ld (FULL_STR),hl  ; save current shop ptr
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out 2 lines of text

    push hl     ; hacky workaround
    push de
      ld c,$01    ; write out price
      call _shop_price
    pop de
    pop hl
    ld a,2    ; restore page 2
    ld (PAGING_SLOT_2),a
  pop hl      ; restore old parameters
  pop bc

  inc hl      ; next item
  inc hl
  inc hl
  djnz -

  ret

enemy:
  ; Enemy name window drawing
  ; Get enemy name to TEMP_STR
  di
    ld a,:Enemies
    ld (PAGING_SLOT_2),a

    ld a,(EnemyIndex)
    ld hl,Enemies   ; table start

    push de
      call DictionaryLookup    ; copy string to RAM
    pop de
  ei

  ; compute the name length
  ; LEN contains the length including control symbols
  ld a,(LEN)
  ld hl,TEMP_STR
  ld b,a
  ld c,0
-:ld a,(hl)
  inc hl
  cp $4f
  jr nc,+
  inc c
+:djnz -
  ; now c is the real name length

  ; Compute the VRAM address
  ld hl,$7840 - 4 ; right-aligned, minus space for borders
  ld a,c
  add a,a
  neg
  ld e,a
  ld d,-1
  add hl,de
  ex de,hl

  push de
    ; Set VRAM address
    rst $08
    ; Draw top border
    ld hl,BorderTop
    call _DrawBorder
  pop de
  call _wait_vblank
  ; Next row
  ld hl,32*2
  add hl,de
  ex de,hl
  push de
    rst $08
    ld hl,BorderSides
    call _DrawOneTile
    push hl
      ; Now for the enemy name
      ld hl,TEMP_STR
      ld a,(LEN)
      ld b,a
    -:ld a,(hl)
      inc hl
      cp $4f
      call c,EmitCharacter
      djnz -
    pop hl
    call _DrawOneTile
  pop de
  call _wait_vblank
  ; Next row
  ld hl,32*2
  add hl,de
  ex de,hl
  rst $08
  ld hl,BorderBottom
  call _DrawBorder

  ; clear LEN
  xor a
  ld (LEN),a

  jp _wait_vblank ; and ret

_DrawBorder:
  ; Emit tile data from (hl) to VRAM, repeating the second word (LEN) times
  call _DrawOneTile
  ld b,c
-:call _DrawOneTile
  dec hl
  dec hl
  djnz -
  inc hl
  inc hl
_DrawOneTile:
  ld a,(hl)
  out (PORT_VDP_DATA),a
  inc hl
  ld a,(hl)
  out (PORT_VDP_DATA),a
  inc hl
  ret

; Tilemap words for the borders
BorderTop:
.dw $11f1, $11f2, $13f1
BorderSides:
.dw $11f3,        $13f3
BorderBottom:
.dw $15f1, $15f2, $17f1


equipment:
  ld b,3    ; 3 items total

-:push bc
  push hl

    di
      ld a,:Items    ; data bank
      ld (PAGING_SLOT_2),a

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out name
    call _wait_vblank
  pop hl
  pop bc

  inc hl      ; next item
  djnz -

  ret

.define ITEM_NAME_WIDTH 18 ; when drawn in menus

_start_write:
  di
    push bc
    push de
      rst $08     ; set vram address

      push af     ; Delay
      pop af
      ld a,$f3    ; border
      out ($be),a

      push af     ; Delay
      pop af
      ld a,$11    ; MSB for left border
      out ($be),a

      ld a,(LEN)    ; string length
      ld c,a
      ld b,ITEM_NAME_WIDTH

_check_length:
      ld a,c      ; check for zero string
      or a
      jr z,_blank_line

_read_byte:
      ld a,(hl)   ; read character
      inc hl      ; bump pointer
      dec c     ; shrink length

      cp $4f      ; normal text is before this
      jr c,_bump_text

_space:
      jr z,_blank_line    ; non-narrative WS

      ; These correspond to the control codes in the .asciitable, not the ones in the script.
_newline:
      cp $50      ; pad rest of line with WS
      jr nz,_hyphen

-:    xor a
      call EmitCharacter
      djnz -

      jr _right_border

_hyphen:
      cp $51      ; add '-'
      jr nz,_skip_htext
      ld a,$46
      jr _bump_text

_skip_htext:
      cp $52      ; ignore other codes
      jr nz,_check_length

_loop_hskip:
      ld a,(hl)   ; eat character
      inc hl
      dec c

      cp $53      ; check for 'end' or length done
      jr nz,_loop_hskip
      jr _check_length

_blank_line:
      xor a     ; write out WS for rest of the line

_bump_text:
      call EmitCharacter
      djnz _check_length

_right_border:
      ld a,c      ; store length
      ld (LEN),a

      push af     ; right border
      pop af
      ld a,$f3    ; border
      out ($be),a

      push af
      pop af
      ld a,$13    ; hflipped
      out ($be),a

    pop de      ; restore stack
    pop bc

    push hl
      ld hl,ITEM_NAME_WIDTH*2+2    ; left border + width
      add hl,de   ; save VRAM ptr
      ld (FULL_STR+2),hl

      ld hl,32*2  ; VRAM newline
      add hl,de
      ex de,hl
    pop hl

  ei      ; wait for vblank
  ret

_wait_vblank:
      ld a,$08    ; stable value
      call ExecuteFunctionIndexAInNextVBlank
      ret

_shop_price:
      di
        ld de,(FULL_STR+2)  ; restore VRAM ptr
        rst $08

        ld a,3    ; shop data bank
        ld (PAGING_SLOT_2),a

        ld hl,(FULL_STR)  ; shop ptr

        ld a,(hl)   ; check for blank item
        or a
        jr nz,_write_price
        ld c,0    ; no price

_write_price:
        push de     ; parameter
        push hl     ; parameter
          jp $3a9a    ; write price
.ends


  ROMPosition $3671
.section "Inventory setup patch" size 15 overwrite ; not movable
; Originally t2a_1.asm
; Item window drawer (inventory)
; - setup code

  ld a,:inventory
  ld (PAGING_SLOT_1),a

  call inventory

  ld a,1
  ld (PAGING_SLOT_1),a

  nop
  nop

  ; 0 bytes left
.ends

  ROMPosition $3a1f
.section "shop setup code" size 23 overwrite ; not movable
; Originally t2a_2.asm
; Item window drawer (shop)
; - setup code
  ld a,:shop
  ld (PAGING_SLOT_1),a

  call shop

  ld a,1    ; old page 1
  ld (PAGING_SLOT_1),a

  nop
  nop
  nop

  nop
  nop

  nop
  nop
  nop
  nop
  nop
.ends

.macro TrampolineTo args dest, start, end
  .unbackground start end-1
  ROMPosition start
  .section "Trampoline to \1 @ \2" force
  ld a,:dest
  ld (PAGING_SLOT_1),a
  call dest
  ld a,1
  ld (PAGING_SLOT_1),a
  JR_TO end
.ends
.endm

  TrampolineTo enemy $326d $3294
  TrampolineTo equipment $3850 $385f

; Extra scripting
.bank 1 slot 1
.section "Dezorian string" free
; In the native Dezorian village, a slight contextual error occurs.
;
; (West) Those guys in the village next to us are all a bunch of liars. Be careful, eh.<wait>
; (East) The neighboring villagers are all liars. Be careful.<wait>
;
; Both 'West' strings are used. No reference to the 'East' variety is made.
; A small hack is inserted to catch for 'extra' strings.
DezorianCustomStringCheck:
  cp $ff      ; custom string [1E7]
  jp nz, $59ca    ; Where the patched jump went to (shows an error message? Shows junk now...)

  ld hl,DishonestDezorianFix ; Those guys in the other village are all liars. For real.<wait>
  jp IndexTableRemap
.ends

  PatchB $eec9 $ff      ; - insert $ff scripting code into data
  PatchW $49b0 DezorianCustomStringCheck ; Patch to jump to extra code

; Window RAM cache
; When showing "windows", the game copies the tilemap data to RAM so it can restore the
; background when the window closes. The windows thus need to (1) close in reverse opening order
; and (2) use non-overlapping areas of this cache.
; The total number of windows exceeds the cache size, so it is a careful act to select the right
; addresses.
; RAM cache in the original (not to scale!):
; $d700 +---------------+ +---------------+
;       | Active player | | MST in shop   |
;       | (during       | | (10x3)        |
;       | battle)       | |               |
;       | (6x3)         | |               |
; $d724 +---------------+ |               |
; $d73c | Party stats   | +---------------+
;       | (32x6)        |
; $d8a4 +---------------+ +---------------+ +---------------+
;       | Battle menu   | | Regular menu  | | Shop items    |
;       | (6x11)        | | (6x11)        | | (16x8)        |
; $d928 +---------------+ +---------------+ |               | +---------------+
;       | Enemy name    | | Currently     | |               | | Select        |
;       | (10x4)        | | equipped      | |               | | save slot     |
; $d978 +---------------+ | items         | |               | | (9x12)        |
; $d9a4 | Enemy stats   | | (10x8)        | +---------------+ |               |
; $d9c8 | (8x10)        | +---------------+                   |               |
; $da00 |               |                                     +---------------+
; $da18 +---------------+
;       | Narrative box |
;       | (20x6)        |
; $db08 +---------------+
;       | Narrative     |
;       | scroll buffer |
;       | (18x3)        |
; $db74 +---------------+
;       | Spells        |
;       | (6x12)        |
; $dc04 +---------------+ +---------------+
;       | Inventory     | | Character     |
;       | (10x21)       | |  stats (12x14)|
; $dd54 |               | +---------------+
; $dda8 +---------------+
;       | Player select |
;       | (6x9)         |
; $de14 +---------------+ +---------------+ +---------------+ +---------------+
;       | Player select | | Use/Equip/Drop| | Buy/Sell      | | Hapsby travel |
;       | (magic) (6x9) | | (5x7)         | | (6x5)         | | (5x8)         |
; $de50 |               | |               | +---------------+ |               |
; $de5a |               | +---------------+                   |               |
; $de80 +---------------+                                     |               |
; $de64 +---------------+                                     +---------------+
;       | Yes/No        |
;       | (5x4)         |
; $de96 +---------------+
;
; In the retranslation we have some bigger windows so it's a little trickier...
;
; High pressure scenarios:
; 1. World -> status
; * Party stats
; * Menu -> Status
;     * Player select
;       * Equipped items
;       * Player stats
;       * Player spells
; 2.World -> heal
; * Party stats
; * Menu -> Magic
;   * Player select
;     * Magic list -> heal
;       * Player select 2
;         * Narrative: player healed (no scroll)
; 3. World -> equip
; * Party stats
; * Menu -> Items
;   * Inventory -> select item
;     * Use/Equip/Drop -> Use (e.g. armour)
;       * Select player
;         * Narrative: player equipped item (no scroll)
;           * Current equipment
; 4. Battle -> inventory
; * Party stats
; * Enemy name
; * Enemy stats
; * Active player
; * Battle menu-> Items
;   * Inventory (no more options here - implicit action)
; 5. Battle -> heal
; * Party stats
; * Enemy name
; * Enemy stats
; * Active player
; * Battle menu-> Magic
;   * Player select
;     * Magic list -> heal
;       * Player select 2
;         * Narrative: player healed (no scroll)
; 6. Chest -> Untrap
; * Party stats
; * Menu -> Magic
;   * Player select
;     * Magic list -> untrap
;       * Narrative: no trap, contained mesetas + item (scrolls)
; 7. Battle -> telepathy
; * Party stats
; * Enemy name
; * Enemy stats
; * Active player
; * Battle menu-> Magic
;   * Player select
;     * Magic list -> telepathy
;       * Narrative: enemy response (scrolls)
; 8. Hospital
; * Narrative
;   * Player select
;     * Meseta
;       * Yes/No

; My layout

; $d700 +---------------+ // We assume these first three are always needed (nearly true)
;       | Party stats   |
; $d880 +---------------+ +---------------+
;       | Narrative box | | Character     |
; $d9b8 +---------------+ | stats         |
; $d9c4 | Narrative     | +---------------+
;       | scroll buffer |
; $da48 +---------------+                   +---------------+ +---------------+
;       | Regular menu  |                   | Battle menu   | | Shop items    |
;       |           (W) |                   |           (B) | | (22x8)        |
; $dab8 +---------------+ +---------------+ +---------------+ |           (S) | +---------------+
;       | Currently     | | Hapsby travel | | Enemy name    | |               | | Select        |
;       | equipped      | | (8x7)     (W) | | (21x3)    (B) | |               | | save slot     |
; $db08 | items         | +---------------+ |               | |               | | (22x9)        |
; $db36 |               |                   +---------------+ |               | |               |
;       |               |                   | Enemy stats   | |               | |               |
; $db10 | (16x8)    (W) |                   | (8x10)        | +---------------+ |           (W) |
; $db80 +---------------+ +---------------+ |               |                   |               |
;       | Player select | | Buy/Sell      | |           (B) |                   |               |
;       | (8x9) (B,W,S) | | (6x5)     (S) | |               |                   |               |
; $dbb0 |               | +---------------+ |               |                   |               |
; $dbd4 +---------------+                   |               |                   |               |
; $dbd6 +---------------+ +---------------+ +---------------+ +---------------+ |               |
;       | Inventory     | | Spells        |                   | MST in shop   | |               |
; $dc44 | (16x21) (B,W) | | (12x12) (B,W) |                   | (16x3)    (S) | +---------------+
; $dc4e |               | |               |                   +---------------+
; $dc9a |               | +---------------+
;       |               | | Player select |
;       |               | | (magic) (8x9) |
;       |               | |         (B,W) |
; $dcee |               | +---------------+
; $ddb6 +---------------+ +---------------+ +---------------+
;       | Use/Equip/Drop| | Yes/No        | | Active player |
;       | (7x7)     (W) | | (5x5)         | | (during       |
; $ddde |               | +---------------+ | battle)   (B) |
; $dde0 |               |                   +---------------+
; $ddfc +---------------+

; Save data menu has to be moved to allow more slots and longer names
; Save slots are $400 bytes so we have room for 7.
; Names could go up to 24 characters... but we limit to 18 because that fits nicely on the screen.
.define SAVE_NAME_WIDTH 18
.define SAVE_SLOT_COUNT 7
; Original layout:            Expanded layout:
; $8000 +-----------------+   +-----------------+
;       | Identifier      |   | Identifier      |
; $8040 +-----------------+   +-----------------+
;                             | Menu (22x9)     |
; $8100 +-----------------+   |                 |
; $81cc | Menu (9x12)     |   +-----------------+
; $81d8 +-----------------+
;
; $8201 +-----------------+   +-----------------+
;       | Slot used flags |   | Slot used flags |
; $8205 +-----------------+   |                 |
; $8207                       +-----------------+
;
; $8210                       +-----------------+
;                             | Options         |
; $8216                       +-----------------+
;
; $8400 +-----------------+   +-----------------+
;       | Slot 1          |   | Slot 1          |
; $8800 +-----------------+   +-----------------+
;       | Slot 2          |   | Slot 2          |
; $8c00 +-----------------+   +-----------------+
;       | Slot 3          |   | Slot 3          |
; $9000 +-----------------+   +-----------------+
;       | Slot 4          |   | Slot 4          |
; $9400 +-----------------+   +-----------------+
;       | Slot 5          |   | Slot 5          |
; $9800 +-----------------+   +-----------------+
;                             | Slot 6          |
; $9c00                       +-----------------+
;                             | Slot 7          |
; $a000                       +-----------------+

.macro DefineWindow args name, start, width, height, x, y
  .define \1 start
  .define \1_size width*height*2
  .define \1_end start + width*height*2
  .define \1_dims (width << 1) | (height << 8)
  .define \1_VRAM $7800 + (y * 32 + x) * 2
  .export \1 \1_end \1_dims \1_VRAM
;  .print "\1: ", hex start, " ", hex width*height*2, " ", hex start + width*height*2, " ", hex (width << 1) | (height << 8), " ", hex $7800 + (y * 32 + x) * 2, "\n"
.endm

;              Name             RAM location           W  H  X  Y
  DefineWindow PARTYSTATS       $d700                 32  6  0 18
  DefineWindow NARRATIVE        PARTYSTATS_end        26  6  3 18
  DefineWindow NARRATIVE_SCROLL NARRATIVE_end         24  3  4 19
  DefineWindow CHARACTERSTATS   NARRATIVE             18  9 13  4
  DefineWindow MENU             NARRATIVE_SCROLL_end   8  7  1  1
  DefineWindow CURRENT_ITEMS    MENU_end              20  5 11 13
  DefineWindow PLAYER_SELECT    CURRENT_ITEMS_end      7  6  1  8
  DefineWindow INVENTORY        ENEMY_STATS_end       20 12 11  1
  DefineWindow USEEQUIPDROP     INVENTORY_end          7  5 24 13
  DefineWindow HAPSBY           MENU_end               8  5 21 13
  DefineWindow BUYSELL          CURRENT_ITEMS_end      6  4 23 14
  DefineWindow SPELLS           INVENTORY             14  7  9  1 ; Spells and inventory are mutually exclusive
  DefineWindow PLAYER_SELECT_2  SPELLS_end             7  6  9  8
  DefineWindow YESNO            USEEQUIPDROP           5  4 24 14
  DefineWindow ENEMY_NAME       MENU_end              21  3 11  0 ; max width 19 chars
  DefineWindow ENEMY_STATS      ENEMY_NAME_end         8 10 24  3
  DefineWindow ACTIVE_PLAYER    INVENTORY_end          7  3  1  8
  DefineWindow SHOP             MENU                  20  5  3  0
  DefineWindow SHOP_MST         INVENTORY             20  3  3 15 ; same width as inventory (for now)
  DefineWindow SAVE             MENU_end              SAVE_NAME_WIDTH+4 SAVE_SLOT_COUNT+2 27-SAVE_NAME_WIDTH 1
  DefineWindow SoundTestWindow  $d700                 15 23  16  0
  DefineWindow ContinueWindow   $d700                  8  4  18 16
  DefineWindow OptionsWindow    $d700                 21  8  11 16

; TODO: add rules for checking no overlap? hard

; The game puts the stack in a space from $cba0..$caff. The RAM window cache
; therefore can extend as far as $dffb (inclusive) - $dffc+ are used
; to "mirror" paging register writes. (The original game stops at $de65 inclusive.)
; However the game uses two lone bytes at $df00 (Port $3E value, typically 0)
; and $df01 (set to $ff, never read). We therefore need to move the former
; (and ignore the latter) to free up some space.
  ; See Initialisation later for the first bit
  PatchW $03a5 Port3EValue
  PatchW $03cc Port3EValue

.macro PatchWords
  PatchW \2 \1
.if nargs > 2
  PatchW \3 \1
.endif
.if nargs > 3
  PatchW \4 \1
.endif
.endm

.define ONE_ROW 32*2

  PatchWords PARTYSTATS $3042 $3220 $30fd ; Party stats

.define NARRATIVE_WIDTH 24 ; text character width
  PatchB $3364 NARRATIVE_WIDTH ; Width counter
  PatchWords NARRATIVE              $334d $3587 ; Narrative box
  PatchWords NARRATIVE_SCROLL       $3554 $3560 ; Narrative box scroll buffer
  PatchWords NARRATIVE_VRAM         $3350 $3386 $358a
  PatchWords NARRATIVE_SCROLL_VRAM  $3360 $3563
  PatchW $3557 NARRATIVE_SCROLL_VRAM + ONE_ROW
  PatchB $34c9 ONE_ROW ; cutscene text display: increment VRAM pointer by $0040 (not $0080) for newlines

  PatchWords MENU                   $322c $324a ; Battle menu
  PatchWords MENU                   $37fb $3819 ; Regular world menu

  PatchWords SHOP                   $39eb $3ac4 ; Shop items
  PatchWords SHOP_VRAM              $39ee $39fa $3ac7
  PatchW $3a40 SHOP_VRAM + ONE_ROW ; Cursor start location

  PatchWords CURRENT_ITEMS          $3826 $386b ; Currently equipped items
  PatchWords CURRENT_ITEMS_VRAM     $3835 $3829 $386e

  PatchWords SAVE                   $3ad0 $3b08 ; Select save slot
  PatchWords SAVE_VRAM              $3ad3 $3b0b $3ae4
  PatchWords SAVE_dims              $3ad6 $3b0e $3ae7
  PatchWords SaveTilemap            $3ae1
  PatchW $3af2 SAVE_VRAM + ONE_ROW
  PatchB $3af8 SAVE_SLOT_COUNT - 1 ; Cursor limit

  PatchWords ENEMY_NAME             $3256 $331b ; Enemy name
  PatchWords ENEMY_NAME_VRAM        $3259 $331e
  PatchWords ENEMY_NAME_dims        $325c $3321

  PatchWords ENEMY_STATS            $3262 $330a ; Enemy stats (up to 8)
  PatchWords ENEMY_STATS_VRAM       $3265 $329e $330d

  PatchWords HAPSBY                 $3b4c $3b73 ; Hapsby travel
  PatchWords HAPSBY_VRAM            $3b4f $3b76
  PatchW $3b63 HAPSBY_VRAM + ONE_ROW

  PatchWords SHOP_MST               $3b15 $3b3e ; MST in shop
  PatchWords SHOP_MST_VRAM          $3b18 $3b41 $3b26

  PatchWords BUYSELL                $3895 $38b5 ; Buy/Sell
  PatchWords BUYSELL_VRAM           $3898 $38b8
  PatchW $38a7 BUYSELL_VRAM + ONE_ROW

  PatchWords CHARACTERSTATS         $38fc $39df ; Character stats
  PatchWords CHARACTERSTATS_VRAM    $38ff $39e2

  PatchWords USEEQUIPDROP           $3877 $3889 ; Use, Equip, Drop
  PatchWords USEEQUIPDROP_VRAM      $387a $388c
  PatchW $2336 USEEQUIPDROP_VRAM + ONE_ROW ; cursor

  PatchWords ACTIVE_PLAYER          $3015 $3036 ; Active player (during battle)
  PatchWords ACTIVE_PLAYER_VRAM     $3018 $3039
  ROMPosition $3023
  .section "Active player data size patch" overwrite
  call GetActivePlayerTilemapData
  JR_TO $302a
  .ends

  PatchWords INVENTORY              $363c $3775 ; Inventory
  PatchWords INVENTORY_VRAM         $363f $3778 $364b
  PatchW $3617 INVENTORY_VRAM + ONE_ROW * 2 ; - VRAM cursor

  PatchWords SPELLS                 $3595 $35e4 ; Spell list
  PatchWords SPELLS_VRAM            $3598 $35b4 $35e7
  PatchB $35bb 0      ; nop - row count correction
  PatchB $35bf 14*2   ; - width*2
  PatchB $35d4 7      ; - height
  PatchW $1ee1 SPELLS_VRAM + ONE_ROW
  PatchW $1b6a SPELLS_VRAM + ONE_ROW

  PatchWords PLAYER_SELECT          $3788 $37de ; Player select
  ; a = player count, but we want n+1 rows of data for n players
  PatchB $37c5 $3c ; inc a
  PatchB $37c8 7*2 ; width*2
  PatchWords PLAYER_SELECT_VRAM     $378b $37e1
  PatchW $3797 PLAYER_SELECT_VRAM + ONE_ROW

  PatchWords YESNO                  $38c1 $38e1 ; Yes/No
  PatchWords YESNO_VRAM             $38c4 $38e4
  PatchW $38d3 YESNO_VRAM + ONE_ROW

  PatchWords PLAYER_SELECT_2        $37a5 $37ef ; Player select for magic
  PatchWords PLAYER_SELECT_2_VRAM   $37a8 $37f2
  PatchW $37b4 PLAYER_SELECT_2_VRAM + ONE_ROW

; If you try to sell an item but you don't have any to sell,
; the game acts the same as if you cancelled the selection with button 1.
; To do this it needs to have bit 4 of c set. The inventory drawing code
; leaves c in this state so it doesn't bother to set it. Our changes
; break this.
  ROMPosition $3602
.section "Sell cycle fix patch" overwrite
  jp z,NoItemsToSell
.ends

.section "Sell cycle fix" free
NoItemsToSell:
  ld c,1<<4 ; act like a cancel
  jp MenuWaitForButton ; and then do what the original code did
.ends

.bank 0 slot 0
.section "Multiply" free
GetActivePlayerTilemapData:
  ; we want a = a * ACTIVE_PLAYER_size
  ; we need to preserve de, bc
  ld h,a
  inc h
  xor a
-:add a,ACTIVE_PLAYER_size
  dec h
  jr nz,-
  sub ACTIVE_PLAYER_size
  ret
.ends

.section "Stats window data" free
; The width of these is important
Level:    .dwm TextToTilemap "|Level        " ; 3 digit number
EXP:      .dwm TextToTilemap "|Experience "   ; 5 digit number
Attack:   .dwm TextToTilemap "|Attack       " ; 3 digit numbers
Defense:  .dwm TextToTilemap "|Defense      "
MaxMP:    .dwm TextToTilemap "|Maximum MP   "
MaxHP:    .dwm TextToTilemap "|Maximum HP   "
MST:      .dwm TextToTilemap "|Meseta       "   ; 5 digit number but also used for shop so extra spaces needed
.ends

  ROMPosition $3907
.section "Stats window" force
  ; ix = player stats
stats:
  ld hl,StatsBorderTop
  ld bc,1<<8 + 18<<1 ; size
  call OutputTilemapBoxWipePaging ; draw to tilemap
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
  call DrawMeseta
  ld hl,StatsBorderBottom
  ld bc,1<<8 + 18<<1 ; size
  jp OutputTilemapBoxWipePaging ; draw and exit
.ends

; Patch in string lengths to places called above
  PatchB $31a3 _sizeof_EXP
  PatchB $36dd _sizeof_EXP
  PatchB $3145 _sizeof_Attack
  PatchW $36e7 MST
  PatchB $36e5 _sizeof_MST

.bank 0 slot 0
.section "Newline patch" free
; Originally tx1.asm
; Text window drawer multi-line handler

newline:
    ld b,NARRATIVE_WIDTH ; reset x counter
    inc hl   ; move pointer to next byte
    ld a,c   ; get line counter                             ;
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

; Walking speedup
; The game moves by 1px for 16 frames, or 2px for 8 frames, depending on whether you are in a vehicle or walking.
; We patch that to 2x8 or 4x4.

  ROMPosition $7409
.section "Walking speed patch trampoline" overwrite
  ; Max 13 bytes, using 11
  ld hl,WalkingFramesPerStep
  call GetMovementSpeedLookup
  ld (MovementFrameCounter),a
  JR_TO $7416
.ends

  ROMPosition $7416
.section "Walking speed patch trampoline 2" overwrite
  ; Max 10 bytes
  call WalkingSpeedPatch
  JR_TO $7420
.ends

.section "Walking speed patch data" free
WalkingFramesPerStep:
  .db 8-1, 16-1, 4-1, 8-1
WalkingPixelsPerFrame:
  .db 2, 1, 4, 2
.ends

.section "Walking speed patch helper" free
GetMovementSpeedLookup:
  ld a,(VehicleType) ; zero or non-zero
  sub 1 ; will carry if zero
  ld a,(MovementSpeedUp) ; 1 or 0
  adc a,a ; now it's 0-3
  ; %00 = vehicle x1
  ; %01 = walking x1
  ; $10 = vehicle x2
  ; $11 = walking x2
  ; Look up in table
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,(hl)
  ret
.ends

.section "Walking speed patch part 2" free
WalkingSpeedPatch:
  ld hl,WalkingPixelsPerFrame
  call GetMovementSpeedLookup
  ld d,0
  ld e,a
  ret
.ends

; Animation and character following is driven by a particular frame number in the sequence...
  ROMPosition $5d20
.section "Walking speed patch part 3 trampoline" overwrite
;    cp     $0f             ; 005D20 FE 0F 
;    jp     nz,$5dac        ; 005D22 C2 AC 5D 
  jp WalkingSpeedPatch3
.ends

.section "WalkingSpeedPatch3" free
WalkingSpeedPatch3:
  push bc
  ld b,a ; save counter value

  ; Walking mode, we want $f or $7
  ld a,(MovementSpeedUp)
  or a
  jr nz,+
  ld a,$f
  jr ++
+:ld a,$7
++:
  cp b
  pop bc
  jp nz,$5dac
  jp $5d25
.ends

; In the handler we then want to set an animation counter for the walking sequence
  ROMPosition $5dbb
.section "Walking speed patch part 4 trampoline" overwrite
;    ld     (iy+$0e),$07    ; 005DBB FD 36 0E 07 
  jp WalkingSpeedPatch4
.ends

.section "WalkingSpeedPatch4" free
WalkingSpeedPatch4:
  ld a,(MovementSpeedUp)
  or a
  jr nz,+
  ld (iy+$e),7
  jp $5dbf
+:ld (iy+$e),3
  jp $5dbf
.ends

  ROMPosition $5de9
.section "Sprite movement for followers hook" force
;    jp     nc,$5df7        ; 005DE9 D2 F7 5D ; horizontal
;    or     a               ; 005DEC B7
;    jr     nz,$5df0        ; 005DED 20 01 ; up => add 1 to iy+2
;    dec    a               ; 005DEF 3D ; down => add -1 to iy+2
;    add    a,(iy+$02)      ; 005DF0 FD 86 02
;    ld     (iy+$02),a      ; 005DF3 FD 77 02
;    ret                    ; 005DF6 C9
;
;    ; now 0 = left, 1 = right
;    sub    $02             ; 005DF7 D6 02
;    jr     nz,$5dfc        ; 005DF9 20 01
;    dec    a               ; 005DFB 3D ; -1 or +1 to iy+4
;    add    a,(iy+$04)      ; 005DFC FD 86 04
;    ld     (iy+$04),a      ; 005DFF FD 77 04
;    ret                    ; 005E02 C9
  ; We want to change those +/-1 to +/-2...
  jp SpriteMovementPatch
.ends

.bank 0 slot 0
.section "Sprite movement for followers" free
SpriteMovementPatch:
  jr nc,_vertical
_horizontal:
  call _getDelta
  add a,(iy+2)
  ld (iy+2),a
  ret
_vertical:
  call _getDelta
  add a,(iy+4)
  ld (iy+4),a
  ret

_getDelta:
  push hl
    push af
      ; Check which table to use
      ld a,(MovementSpeedUp)
      or a
      jr z,+
      ld hl,_table
      jr ++
+:    ld hl,_table2
++: pop af
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
  pop hl
  ret
_table:
.db -2, +2, -2, +2
_table2:
.db -1, +1, -1, +1
.ends

; Savegame name entry screen hacking ---------------------------------------------
; compressed tile data (low byte only) for name entry screen
.bank 0 slot 0
.section "Name entry tilemap data" free
NameEntryTiles:
; Custom format...
; %0nnnnnnn $xx = $xx n times
; $10nnnnnn $xx = $xx, $xx+1, $xx+2... n times
; %11nnnnnn ... = n bytes raw
; Fant is loaded at index $c0 so all chars are offset
; Nevertheless it's easier to do by hand than to generate it.
; The code generates the left and right lines, and the flips.
.define RLE %00000000
.define RUN %10000000
.define RAW %11000000
.db RAW |   2, $c0, $f1 ; " /"
.db RLE |  28, $f2      ;   "----------------------------"
.db RAW |   1, $f1      ;                               "\"
.db RLE | 127, $c0      ; "                                " ...
.db RLE | 101, $c0
.db RUN |  26, $cb      ; "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.db RLE |  38, $c0      ; (space)
.db RUN |  26, $e5      ; "abcdefghijklmnopqrstuvwxyz"
.db RLE |  38, $c0      ; (space)
.db RUN |  10, $c1      ; "1234567890"
.db RLE |  16, $c0      ;           "                " (punctuation will be patched later)
.db RLE |  38, $c0      ; (space)
.db RAW |  17, $cc $e5 $e7 $ef $c0 $c0 $d8 $e9 $fc $f8 $c0 $c0 $dd $f4 $e5 $e7 $e9; "Back  Next  Space"
.db RLE |   5, $c0      ; (space)
.db RAW |   4, $dd $e5 $fa $e9 ; "Save"
.db RLE | 127, $c0      ; (space)
.db RLE |  37, $c0
.db RAW |   1, $f1      ; "\"
.db RLE |  28, $f2      ;  "----------------------------"
.db RAW |   1, $f1      ;                              "/"
.db $00 ; Terminator
.ends

  ROMPosition $42cc
.section "Patch name entry tiles pointer" overwrite ; not movable
  ld hl,NameEntryTiles ; rewire pointer
.ends

; "Enter your name" text at the top of the screen
.bank 1 slot 1 ; can be 0 or 1
.section "Enter your name text" free
EnterYourName:
.dwm TextToTilemap "Enter your name:"
.ends

  ROMPosition $41c4
.section "Enter your name pointer patch" overwrite ; not movable
  ld hl,EnterYourName ; rewire pointer (space used for scene data lookup)
  ld ($c781),a        ; unchanged
  ld bc, $0120        ; bytes per line, number of lines
  xor a
  ld ($c210),a        ; Tilemap high byte (unchanged)
  ld de, $7850        ; where to draw (8,1)
  di
  call OutputTilemapRawDataBox ; change function call to full raw tilemap drawer
.ends

  ROMPosition $41e3
.section "Name entry punctuation hook" overwrite ; not movable
  ; We patch a call here to minimise the patch size
  call DrawExtendedCharacters
.ends

.bank 0 slot 0 ; can be 0 or 1
.section "Name entry screen extended characters" free
; Originally tx4.asm
; Name entry screen patch to draw extended characters
DrawExtendedCharacters:
    call $03de ; OutputToVRAM ; the call I stole to get here
    ld bc,$0110 ; 16 bytes per row, 1 row
    ld de,$7bea ; Tilemap location 21,15
    ld hl,_punctuation
    jp OutputTilemapRawDataBox  ; output raw tilemap data
    ; and ret

_punctuation:
.dwm TextToTilemap ".,:-!?`'"

.ends

.define NameEntryMinX $18
.define NameEntryMinY $60
.define NameEntryTableWidth 26 ; letters
.define NameEntryTableHeight 4 ; rows
.define NameEntryMaxX NameEntryMinX + (NameEntryTableWidth - 1) * 8
.define NameEntryMaxY NameEntryMinY + (NameEntryTableHeight - 1) * 16 ; double-spaced

  ROMPosition $4221
.section "Name entry cursor initial data" overwrite ; not movable
.db NameEntryMinX, NameEntryMinY ; x, y in screen coordinates
.dw $d30a ; x, y in RAM tilemap cache
.asc "A" ; pointed value
.ends

  PatchB $4130 NameEntryMinX
  PatchB $40eb NameEntryMaxX
  PatchB $4102 NameEntryMinY
  PatchB $4119 NameEntryMaxY

  PatchB $4344 NameEntryTableWidth ; width of lookup table
  PatchB $4342 4 ; height of lookup table - width*height<=126
  PatchB $434e (32*2 - NameEntryTableWidth)*2 ; width complement

.bank 1 slot 1 ; can be 0 or 1
.section "Save lookup" free
SaveLookup:
; Character found at each location in the name entry screen
.asc "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.asc "abcdefghijklmnopqrstuvwxyz"
.asc "0123456789        .,:-!?"
.db $41, $42 ; quotes, can't do with .asc
; Back, Next, Save. We extend their values to whole rows to enable "snapping" the cursor when moving down from above.
;   B   a   c   k   _   _   N   e   x   t   _   _   S   p   a   c   e   _   _   _   _   _   S   a   v   e
.db $4F $4F $4F $4F $4F $4E $4E $4E $4E $4E $4E $50 $50 $50 $50 $50 $50 $50 $50 $50 $51 $51 $51 $51 $51 $ff ; last is $ff to fix a cursor bug
.ends
  PatchW $433c SaveLookup ; rewire pointer

; Adding "space" item
  ROMPosition $4160
.section "control char trampoline" force
  jp ControlChar
.ends

.bank 0 slot 0
.section "Extra control char" free
ControlChar:
;    cp $4e                       ; 00415D FE 4E      ; check if it was a control char, in which case snap to its left char
;    ret c                        ; 00415F D8
;     ld c,$88                     ; 004160 0E 88      ; values for jump to Next ($4e)
;     ld hl,$d5a2                  ; 004162 21 A2 D5
;     jr z,+                       ; 004165 28 0C
;     cp $4f                       ; 004167 FE 4F
;     ld l,$aa                     ; 004169 2E AA      ; values for jump to Prev ($4f)
;     ld c,$a8                     ; 00416B 0E A8
;     jr z,+                       ; 00416D 28 04
;     ld c,$c8                     ; 00416F 0E C8      ; default: jump to Save
;     ld l,$b2                     ; 004171 2E B2
; +:  ld (NameEntryCursorTileMapDataAddress),hl
;     ld a,c                       ; 004176 79
;     ld (NameEntryCursorX),a      ; 004177 32 84 C7
;     ret                          ; 00417A C9
  ; a is the pointed control character
  sub $4e
  ret c
  ; Next values
  ld c,$48 ; x
  ld hl,$d496 ; data pointer
  jr z,+
  dec a
  ; Prev
  ld c,$18 ; x
  ld l,$8a ; data pointer
  jr z,+
  dec a
  ; Space
  ld c,$78
  ld l,$a2
  jr z,+
  ; Save for any other value
  ld c,$c8 ; x
  ld l,$b6 ; data pointer
+:ld ($c786),hl
  ld a,c
  ld ($c784),a
  ret
.ends

  ROMPosition $4237
.section "Cursor sprite handling" force
  ; the first two sprites ys have been set (but not the x)
  inc de
  ; the first is the "curent char", the second is the start of the "pointed item"
  ld a,($c788) ; check what we are pointing at
  cp $4e ; carry will be set if a normal letter
  ld b,1
  jr c,+
  cp $50 ; space
  ld b,5
  jr z,+
  dec b ; everything else
+:ld a,($c785) ; Y coordinate
  ld c,b
-:ld (de),a
  inc e
  djnz -
  ; terminate
  ld a,208
  ld (de),a
  ; now do the Xs
  ld e,$80
  ex de,hl ; so we can output register c
  ld (hl),e ; this is the "current char"'s X
  inc hl
  ld b,c ; get counter back
  ld c,0 ; tile index
  ld (hl),c
  inc hl
  ld a,($c784) ; X coordinate for the "pointed item"
-:ld (hl),a
  inc l
  add a,8
  ld (hl),c
  inc l
  djnz -
  ret
.ends

  ROMPosition $4028
.section "Control char handling trampoline" overwrite
  jp ControlCharCheck
.ends

.bank 1 slot 1
.section "Control char handling" free
ControlCharCheck:
  ; a = 4f (next), 51 (space) or something else
  cp $4f
  jp z,$402c ; Prev
  cp $50
  jp nz,$4053 ; Save
  ; Space
  ld a,0
  jp $4006 ; char entry
.ends

; 2. Extra x coords and tile indices
;  PatchB $4251 $05
; 3. Cursor extends right, not left, relative to the "snapped" positions
;  PatchB $425c $c6 ; sub nn -> add a,nn

; Text drawing as you enter your name
.bank 1 slot 1 ; can be 0 or 1
.section "Drawing to RAM as you enter" free
; Originally tx2.asm
; Name entry screen patch for code that writes to the in-RAM name table copy

WriteLetterIndexAToDE: ; $429b
; parameters:
; de = where to write tile data (pointing to lower tile of pair)
; a = char number (space = 0)
; returns:
; c = low byte of name table value
; a = high byte
; This part is unchanged:
  push hl
    ex de,hl
    ld hl,PAGING_SLOT_2
    ld (hl),:FontLookup
    ld hl,FontLookup
    ld c,a
    ld b,0
    add hl,bc
    add hl,bc
; Original code:
;    ld c,(hl)          ; 4E       ; get value in c,a
;    inc hl             ; 23
;    ld a,(hl)          ; 7E
;    ld (de),a          ; 12       ; write to address passed in in de
;    ld hl,-64          ; 21 C0 FF
;    add hl,de          ; 19       ; and 1 row above it
;    ld (hl),c          ; 71
; Patch:
    ld a,(hl)              ; 7E
    ld (de),a              ; 12
    ld c,a                 ; 4F
    inc hl                 ; 23
    inc de                 ; 13
    ld a,(hl)              ; 7E
    ld (de),a              ; 12
; End patch
  pop hl
  ret
.ends

  ROMPosition $42b5
.section "Drawing to screen as you enter" force ; not movable (without patching calls)
; Originally tx3.asm
; Name entry screen patch for code that writes to the in-RAM name table copy

WriteLetterToTileMapDataAndVRAM: ; $42b5
; Parameters:
; a = tile index (space = 0)
; de = where to write tiles to
; hl = cursor location (from GetCursorLocation)
    call WriteLetterIndexAToDE ; CD 9B 42
    ; c,a are the tile indices for the chosen tile
    ld b,a                ; 47
    ld a,h                ; 7C       ; get cursor location in TileMapData
    sub $58               ; D6 58    ; reduce it by $5800 to make it the VRAM address
    ld h,a                ; 67
    ex de,hl              ; EB
    rst $08               ; CF       ; SetVRAMAddressToDE
; Original code:
;    ld a,b               ; 78       ; write tiles to VRAM
;    out ($be),a          ; D3 BE
;    ld hl,-64            ; 21 C0 FF
;    add hl,de            ; 19
;    ex de,hl             ; EB
;    rst $08              ; CF
;    ld a,c               ; 79
;    out ($be),a          ; D3 BE
; Patch:
    ld a,c                ; 79
    out ($be),a           ; D3 BE
    ld a,b                ; 78
    out ($be),a           ; D3 BE
; End patch
    ret                   ; C9
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
  .dw value
.endm

_top:
  element $11f1 1
  element $11f2 SAVE_NAME_WIDTH+2
  element $13f1 1
  element $11f3 1
  .db 0
_blank:
  element $10c0 SAVE_NAME_WIDTH+1
  element $13f3 1
  element $11f3 1
  .db 0
_bottom:
  element $15f1 1
  element $15f2 SAVE_NAME_WIDTH+2
  element $17f1 1
  .db 0

.ends

  ; SRAM initialisation
  ROMPosition $9af
.section "Save RAM init" overwrite
  call BlankSaveTilemap
  JR_TO $09ba
.ends

  ; Name location pointer table
.bank 1 slot 1
.section "Save game name locations" free
SaveGameNameLocations:
.define SaveFirstNameOffset SaveTilemap + (SAVE_NAME_WIDTH+4+3)*2 ; equivalent for new menu
.define SaveNameDelta (SAVE_NAME_WIDTH+4)*2
.repeat SAVE_SLOT_COUNT index count
.dw SaveFirstNameOffset + SaveNameDelta * count
.endr
.ends
  PatchW $408b SaveGameNameLocations-2 ; 1-based lookup

  ; The code draws the password/name with spaces every 8 chars, we nobble that
  PatchB $4293 $c9 ; return earlier

  ; We set the "start point" for name entry.
  .define NameEntryStart 13 - SAVE_NAME_WIDTH/2
  PatchB $41c3 NameEntryStart
  PatchB $4035 NameEntryStart ; same as above, leftmost char index
  PatchB $401f NameEntryStart + SAVE_NAME_WIDTH - 1 ; rightmost char index (inclusive)

  ROMPosition $4091
.section "Copy entered name to save data" force
;    ld hl,$d19a                  ; 004091 21 9A D1   ; TileMapData location of (13,6) (top row of name)
;    ld bc,$000a                  ; 004094 01 0A 00   ; 10 bytes
;
;    ld a,SRAMPagingOn            ; 004097 3E 08
;    ld (SRAMPaging),a            ; 004099 32 FC FF   ; page in SRAM
;    ldir                         ; 00409C ED B0      ; copy tiles to SRAM name section
;
;    ld c,$08                     ; 00409E 0E 08      ; move dest 8 bytes on
;    ex de,hl                     ; 0040A0 EB
;    add hl,bc                    ; 0040A1 09
;    ex de,hl                     ; 0040A2 EB
;    ld c,$36                     ; 0040A3 0E 36      ; move src 54 bytes on (bottom row of name)
;    add hl,bc                    ; 0040A5 09
;    ld c,$0a                     ; 0040A6 0E 0A      ; copy another 10 bytes
;    ldir                         ; 0040A8 ED B0
  ; de points to the destination already
  ld hl,$d146 + NameEntryStart*2
  ld bc,SAVE_NAME_WIDTH*2
  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a
  ldir
  JR_TO $40aa
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


; Changed credits -------------------------
  ROMPosition $53dbc
.section "Credits" force ; not movable
CreditsData:
.dw CreditsScreen1, CreditsScreen2, CreditsScreen3, CreditsScreen4, CreditsScreen5, CreditsScreen6, CreditsScreen7, CreditsScreen8, CreditsScreen9, CreditsScreen10, CreditsScreen11, CreditsScreen12, CreditsScreen13, CreditsScreen14

.macro CreditsEntry args x, y, text
.dw $d000 + ((y * 32) + x) * 2
.db text.length, text
.endm

CreditsScreen1: .db 1 ; entry count
  CreditsEntry 13,10,"STAFF"
CreditsScreen2: .db 3
  CreditsEntry 5,5,"TOTAL"
  CreditsEntry 6,7,"PLANNING"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 5
  CreditsEntry 6,5,"SCENARIO"
  CreditsEntry 7,7,"WRITER"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 9,15,"STORY"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 4
  CreditsEntry 4,5,"ASSISTANT"
  CreditsEntry 3,7,"COORDINATORS"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 5
  CreditsEntry 3,6,"TOTAL DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"MONSTER"
  CreditsEntry 7,16,"DESIGN"
  CreditsEntry 17,15,"CHAOTIC KAZ"
CreditsScreen6: .db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"
CreditsScreen7: .db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"
CreditsScreen8: .db 4
  CreditsEntry 9,6,"SOUND"
  CreditsEntry 18,6,"BO"
  CreditsEntry 4,15,"SOFT CHECK"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 5
  CreditsEntry 3,5,"ASSISTANT"
  CreditsEntry 4,7,"PROGRAMMERS"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 2
  CreditsEntry 2,6,"MAIN PROGRAM"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 1
  CreditsEntry 9,10,"RETRANSLATION"
CreditsScreen12: .db 4
  CreditsEntry 3,6,"WORDS"
  CreditsEntry 10,10,"PAUL JENSEN"
  CreditsEntry 2,15,"FRANK CIFALDI"
  CreditsEntry 18,15,"SATSU"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z[\ GAIDEN" ; numbers are in a funny place
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER"
.ends

  ROMPosition $488a
.section "Credits hack" overwrite ; not movable
  ld (hl),:CreditsFont
  ld hl,$5820 ; VRAM address
  ld de,CreditsFont
  call LoadTiles
.ends

.slot 2
.section "Credits font" superfree
CreditsFont:
.incbin "new_graphics/font3.psgcompr"
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

; The font lookup, Huffman bits and script all share a bank as they are needed at the same time.
.bank 2 slot 2

.section "Font lookup" align 256 superfree ; alignment simplifies code...
FontLookup:
; This is used to convert text from the game's encoding (indexing into this area) to name table entries. More space can be used but check SymbolStart which needs to be one past the end of this table.
.dwm TextToTilemap " 0123456789"
.dwm TextToTilemap "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.dwm TextToTilemap "abcdefghijklmnopqrstuvwxyz"
.dwm TextToTilemap ".:`',-!?"
.ends

; We locate the Huffman trees in a different slot to the script so we can access them at the same time
.slot 1
.section "Huffman trees" superfree
.block "Huffman trees"
HuffmanTrees:
.include "script_inserter/tree.asm"
.endb
.ends

; ...but the script still needs to go in slot 2.
.bank 2 slot 2
.section "Script" free
.block "Script"
.include "script_inserter/script.asm"
.endb
.ends

.bank 2 slot 2
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
    ld (FLAG),a   ; No wait flag
    ld (ARTICLE),a    ; No article usage
    ld (SUFFIX),a   ; No suffix flag

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
  ld a,($c2d3)  ; Old code
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

.include "script_inserter/script-patches.asm"

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

; Title screen menu extension
  ROMPosition $0745
.section "Title screen extension part 1" force
;    ld     a,$01           ; 000745 3E 01
;    ld     (CursorMax),a       ; 000747 32 6E C2
;    call   $2eb9           ; 00074A CD B9 2E
;    or     a               ; 00074D B7
;    jp     nz,$079e        ; 00074E C2 9E 07
  ld a,3 ; 4 options
  ld (CursorMax),a ; CursorMax
  jp TitleScreenModTrampoline
.ends
.slot 0
.section "Title screen extension part 2" free
TitleScreenModTrampoline:
  ld a,:TitleScreenMod
  ld (PAGING_SLOT_2),a
  jp TitleScreenMod
.ends
.slot 2
.section "Title screen modification" superfree
TitleScreenMod:
  call WaitForMenuSelection
  or a
  jp z,$0751
  dec a
  jp z,Continue
  dec a
  jp z,SoundTest
  ; else fall through

_OptionsMenu:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)
  
  ; Save tilemap
  ld hl,OptionsWindow
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call InputTilemapRect

  ; Draw window
  ld hl,OptionsMenu
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call DrawTilemap

  ; Start selection
  ld hl,OptionsWindow_VRAM + ONE_ROW
  ld (CursorTileMapAddress),hl
  ld hl,$0000
  ld (CursorPos),hl  ; 0 -> CursorPos, OldCursorPos

_OptionsSelect:
  ; We draw in the numbers here
  ld de,OptionsWindow_VRAM + ONE_ROW * 1 + 2 * 19
  rst $8
  ld a,(MovementSpeedUp)
  inc a
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 2 + 2 * 19
  rst $8
  ld a,(ExpMultiplier)
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 3 + 2 * 19
  rst $8
  ld a,(MoneyMultiplier)
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 4 + 2 * 16
  rst $8
  ld a,(FewerBattles)
  or a
  ld hl,_BattlesAll
  jr z,+
  ld hl,_BattlesHalf
+:ld b,_sizeof__BattlesAll
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 5 + 2 * 15
  rst $8
  ld a,(BrunetteAlisa)
  or a
  ld hl,_Black
  jr z,+
  ld hl,_Brown
+:ld b,_sizeof__Black
  ld c,PORT_VDP_DATA
  otir
  
  ld de,OptionsWindow_VRAM + ONE_ROW * 6 + 2 * 13
  rst $8
  ld a,(Font)
  or a
  ld hl,_Font1
  jr z,+
  ld hl,_Font2
+:ld b,_sizeof__Font1
  ld c,PORT_VDP_DATA
  otir

  ld a,$ff
  ld (CursorEnabled),a ; CursorEnabled
  ld a,5 ; 6 options
  ld (CursorMax),a ; CursorMax
  call $2ec8 ; no cursor position reset
  
  ; If button 1, return
  ld b,a
  ld a,%00010000 ; Button 1
  cp c
  jr nz,+
  
_optionsReturn:
  ; Copy setting to save RAM
  ; We are in slot 2 here so we need to put this in low ROM
  call SettingsToSRAM

  ld hl,OptionsWindow
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call DrawTilemap
  ld de,$7c12 + ONE_ROW * 3
  ; fall through
  
BackToTitle:
  ; We need to hide the cursor as it resets to the top...
  rst $08
  xor a
  out ($be),a

  ; Continue the title screen VBlank handler
  ld hl,FunctionLookupIndex
  ld (hl),3 ; TitleScreen
  ret
  
+:ld a,b
  
  ; Then adjust the right thing
  or a
  jr nz,+
  
_movement:
  ; Toggle bit
  ld a,(MovementSpeedUp)
  xor 1
  ld (MovementSpeedUp),a
  jp _OptionsSelect
  
  cp 3
  jr nz,+
  ld hl,OptionsWindow
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call DrawTilemap
  ld de,$7c12 + ONE_ROW * 3
  jp BackToTitle
  
+:dec a
  jr nz,++
  
_experience:
  ld hl,ExpMultiplier
-:ld a,(hl)
  inc a
  cp 5
  jr nz,+
  ld a,1
+:ld (hl),a
  jp _OptionsSelect ; loop

++:dec a
  jr nz,+

_money:
  ld hl,MoneyMultiplier
  jr -
  
+:dec a
  jr nz,+
  
_battles:
  ld a,(FewerBattles)
  xor 1
  ld (FewerBattles),a
  jp _OptionsSelect

+:dec a
  jr nz,+
  
_hair:
  ld a,(BrunetteAlisa)
  xor 1
  ld (BrunetteAlisa),a
  jp _OptionsSelect

+:; Last option, no need for dec

_font:
  ld a,(Font)
  xor 1
  ld (Font),a
  ; We reload the font here
  call LoadFonts
  ; Then we need to wait for VBlank
  halt
  jp _OptionsSelect
  
_BattlesAll:  .dwm TextToTilemap " All"
_BattlesHalf: .dwm TextToTilemap "Half"
_Brown: .dwm TextToTilemap "Brown"
_Black: .dwm TextToTilemap "Black"
_Font1: .dwm TextToTilemap "Polaris"
_Font2: .dwm TextToTilemap " AW2284"
 

Continue:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)
  
  ld hl,ContinueWindow
  ld de,ContinueWindow_VRAM
  ld bc,ContinueWindow_dims
  call InputTilemapRect

  ld hl,ContinueMenu
  ld de,ContinueWindow_VRAM
  ld bc,ContinueWindow_dims
  call DrawTilemap

_SelectAction:
  ld hl,ContinueWindow_VRAM + ONE_ROW
  ld (CursorTileMapAddress),hl

  ld a,$ff
  ld (CursorEnabled),a ; CursorEnabled
  ld a,1 ; 2 options
  ld (CursorMax),a ; CursorMax
  call WaitForMenuSelection
  
  ; If button 1, return
  ld b,a
  ld a,%00010000 ; Button 1
  cp c
  jr nz,+

_continueReturn:
  ; return to title screen
  ld hl,ContinueWindow
  ld de,ContinueWindow_VRAM
  ld bc,ContinueWindow_dims
  call DrawTilemap
  ld de,$7c12 + ONE_ROW * 1
  jp BackToTitle

+:ld a,b

  ; remember the selection while we show the slot selection menu
  push af
    ; First check if there are any...
_checkForSaves:
    ld b,SAVE_SLOT_COUNT
    ld c,1
  -:ld a,b
    ld (NumberToShowInText),a
    call IsSlotUsed
    jp nz,+
    djnz -
    ; Nope
    call NoSavedGames
  pop af
  jr _continueDone

    ; Save tilemap
+:  ld hl,SAVE
    ld de,SAVE_VRAM
    ld bc,SAVE_dims
    call InputTilemapRect
    ; Select a savegame
-:  call GetSavegameSelection ; leaves value in NumberToShowInText
    call IsSlotUsed
    jr z,- ; repeat selection until a valid one is chosen
  pop af
  ; check for button 1 or 2
  bit 4,c
  jr nz,_closeSaveGameWindow ; back to selection on button 1
  
  
  ; now check what action
  or a
  jp z,ContinueSavedGame
  
_delete:
  call DeleteSavedGame
  
_closeSaveGameWindow:
  ; Restore tilemap
  ld hl,SAVE
  ld de,SAVE_VRAM
  ld bc,SAVE_dims
  call DrawTilemap

_continueDone:  
  ; Clear cursor tile next to "delete"
  ld de,ContinueWindow_VRAM + ONE_ROW * 2
  rst $08
  ld a,$f3  
  out ($be),a
  jr _SelectAction
  
SoundTest:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)
  
  ld hl,SoundTestWindow
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestWindow_dims
  call InputTilemapRect

  ld hl,SoundTestMenuTop
  ld de,SoundTestWindow_VRAM
  ld bc,(1<<8)|(15*2) ; top border
  call DrawTilemap
  call _chip
  ld hl,SoundTestMenu
  ld bc,SoundTestWindow_dims - $200 ; remove 2 rows
  call DrawTilemap
  ld hl,SoundTestWindow_VRAM + ONE_ROW
  ld (CursorTileMapAddress),hl

  ; We need to retain the selected music in order to restart it when the chip is changed.
  ; We start with the title screen music already playing
  ld a,$81
  ld (MusicSelection),a

  ; We hack the menu selection to retain the cursor position...
  ld hl,$0000
  ld (CursorPos),hl  ; 0 -> CursorPos, OldCursorPos

-:ld a,$ff
  ld (CursorEnabled),a ; CursorEnabled
  ld a,20 ; 21 options
  ld (CursorMax),a ; CursorMax
  call $2ec8 ; WaitForMenuSelection skipping the bit where it reset the cursor position

  ; If button 1, return
  ld b,a
  ld a,%00010000 ; Button 1
  cp c
  jr nz,+
  
_musicReturn:
  ; Return to title screen
  ; Hide the menu
  ld hl,SoundTestWindow
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestWindow_dims
  call DrawTilemap
  
  ; We need to hide the cursor as it resets to the top...
  ld de,$7c12 + ONE_ROW * 2
  jp BackToTitle

+:ld a,b

  or a
  jr nz,+
  ; Toggle FM - if allowed
  ld a,(HasFM)
  or a
  jr z,-
  ld a,(UseFM)
  xor 1
  ld (UseFM),a
  ; Restart music
  ld a,(MusicSelection)
  ld (NewMusic),a
  ; Update menu
  call _chip
  jr -

+:sub 2 ; top 2 entries are not music
  jr c,-

  ; Look up ID
  ld hl,_ids
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,(hl)

  ; Remember it
  ld (MusicSelection),a
  ; Play it
  ld (NewMusic),a

  ; Back to selection mode
  jr -

_ids:
; Music IDs matching the order in the menu
.db $81 ; Title Screen
.db $8C ; Intro
.db $87 ; Town
.db $86 ; Dungeon
.db $8E ; Shop
.db $8D ; Church
.db $82 ; Palma
.db $89 ; Battle
.db $8A ; Story
.db $88 ; Village
.db $8F ; Vehicle
.db $83 ; Motavia
.db $84 ; Dezoris
.db $90 ; Tower
.db $85 ; Final Dungeon
.db $92 ; LaShiec
.db $93 ; Dark Force
.db $8B ; Ending
.db $94 ; Game Over

_chip:
  ld de,SoundTestWindow_VRAM + ONE_ROW
  ld bc,(1<<8)|(15*2) ; one row
  ld hl,SoundTestMenuChipPSG
  ld a,(UseFM)
  or a
  jr z,+
  ld hl,SoundTestMenuChipYM2413
+:jp DrawTilemap ; and ret
.ends

.bank 1 slot 1
.section "Setting SRAM helpers" free
; We are very low on space :( so we have to split these up
SettingsToSRAM:
  ld hl,SettingsStart
  ld de,$8210 ; SRAM location
CopySettings:
  ld bc,SettingsEnd-SettingsStart
  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a
  ldir
  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a
  ret
.ends
.section "Setting SRAM helper 2" free
SettingsFromSRAM:
  ld hl,$8210
  ld de,SettingsStart
  call CopySettings
  ; If they were blank, we need to initialise the multipliers
  ld a,(ExpMultiplier)
  or a
  ret nz
  inc a
  ld (ExpMultiplier),a
  ld (MoneyMultiplier),a
  ret
.ends

; We hook the FM detection so we can cache the result
  PatchW $00cf FMDetectionHook

.slot 0
.section "FM detection hook" free
FMDetectionHook:
  call $03a4 ; do FM detection
  ld a,(UseFM)
  ld (HasFM),a
  ret
.ends

; We want to access the menu drawing code from high banks, so we make a low trampoline here that preserves the slot
.slot 0
.section "Menu drawing trampoline" free
DrawTilemap:
  ld a,(PAGING_SLOT_2)
  push af
    call OutputTilemapBoxWipePaging ; OutputTilemapBoxWipePaging
  pop af
  ld (PAGING_SLOT_2),a
  ret
.ends
  
.section "Save game deletion" free
DeleteSavedGame:
  ; We want to jump back to slot 2 when we are done
  ld hl,ScriptConfirmSlot ; Slot <n>, are you sure?
  call TextBox
  call DoYesNoMenu
  jr nz,_no
  
  ld hl,ScriptDeletingFromSlotN ; Deleting game from slot <n>.
  call TextBox

  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a

  ; We need to blank $8200 + n
  ld h,$82
  ld a,(NumberToShowInText)
  ld l,a
  xor a
  ld (hl),0

  ; compute where to write to
  ; a = 1-based index
  ; we want de = SaveTilemap + (a * (SAVE_NAME_WIDTH+4) + 2) * 2
  ld d,0
  ld e,l
  ld hl,0
  ld b,SAVE_NAME_WIDTH+4
-:add hl,de
  djnz -
  inc hl
  inc hl
  add hl,hl
  ld de,SaveTilemap
  add hl,de
  ld e,l
  ld d,h
  ; We then want to copy the blank we are pointing at to the right
  inc de
  inc de
  ld bc,SAVE_NAME_WIDTH*2
  ldir
  
  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a

_no:
  call TextBoxEnd
  
  ld a,:Continue
  ld (PAGING_SLOT_2),a
  ret
.ends

.section "Continue a saved game" free
ContinueSavedGame:
  ld a,SRAMPagingOn  ; Load game
  ld (PAGING_SRAM),a
  ld a,(NumberToShowInText) ; 1-based
  ld h,a
  ld l,0
  add hl,hl
  add hl,hl
  set 7,h            ; hl = $8000 + $400*a = slot a game data ($400 bytes)
  ld de,$c300
  ld bc,1024 ; bytes
  ldir               ; Copy
  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a

  ; This is important, not sure what it does :)
  ld a,($c316)       ; Check xc316
  cp 11
  ret nz             ; if == 11

  ld hl,FunctionLookupIndex
  ld (hl),$0a        ; Start game
  ret
.ends

  ROMPosition $00a5
.section "Initialisation hack" overwrite
;    ld     a,($c000)       ; 0000A2 3A 00 C0 
;    ld     ($df00),a       ; 0000A5 32 00 DF 
  ; This runs on startup but not at reset
  jp Initialisation
.ends

.section "Initialisation" free
Initialisation:
  ld (Port3EValue),a
  ; Back to normal
  jp $00a8
.ends

; Money is already multiplied by the enemy count, we can easily chain an extra multiplication on
  ROMPosition $6335
.section "Money multiplier trampoline" overwrite
  call MoneyHack
.ends

.bank 1 slot 1
.section "Money multiplier" free
MoneyHack:
  call Multiply16 ; What we stole to get here
  ; We want to multiply this again
  ex de,hl
  ld a,(MoneyMultiplier)
  ld c,a ; b is already 0
  jp Multiply16 ; and ret
.ends

; Experience is handled exactly the same as money
  ROMPosition $634c
.section "Experience multiplier trampoline" overwrite
  call ExperienceHack
.ends

.bank 1 slot 1
.section "Experience multiplier" free
ExperienceHack:
  call Multiply16 ; What we stole to get here
  ; We want to multiply this again
  ex de,hl
  ld a,(ExpMultiplier)
  ld c,a ; b is already 0
  jp Multiply16 ; and ret
.ends

; Enemy encounters are when a random number is less than some threshold...
  ROMPosition $10b4
.section "Battle reducer trampoline" overwrite
;    call GetRandomNumber           ; 0010B4 CD 6A 06 
  call BattleReducer
.ends

.section "BattleReducer" free
BattleReducer:
  ld a,(FewerBattles)
  or a
  jr z,+
  ; if non-zero, we halve b
  srl b
+:jp GetRandomNumber ; and return
.ends

.section "No saved games message" free
NoSavedGames:
  ld a,(PAGING_SLOT_2)
  push af
    ld hl,ScriptNoSavedGames
    call TextBox
    call TextBoxEnd
  pop af
  ld (PAGING_SLOT_2),a
  ret
.ends

.unbackground $64a5 $64c1
  ROMPosition $64a5
.section "Brunette Alisa hook" force
  jp BrunetteAlisaCheck
.ends

.bank 0 slot 0
.section "Brunette Alisa check" free
BrunetteAlisaCheck:
  ; We copy some of the code from the place we patched...
  ld e,0
  srl d
  rr e
  ld l,e
  ld h,d
  srl d
  rr e
  add hl,de
  ld de,$8000 ; source address
  
  ; Now we need the flag to replace this address...
  ld a,(BrunetteAlisa)
  or a
  jr z,+

  ld a,:BrunetteAlisaTiles
  ld (PAGING_SLOT_2),a
  ld de,BrunetteAlisaTiles

+:; Back to the original code
  add hl,de
  ld de, $7540 ; VRAM address
  rst $8
  ld c,PORT_VDP_DATA
  call $5b1a ; outi128
  call $5b9a ; outi64 ; Changed from a jp to a call
  ; Restore paging for other characters
  ld a,$1c
  ld (PAGING_SLOT_2),a
  ret
.ends

.slot 2
.section "Brunette Alisa tiles" superfree
BrunetteAlisaTiles:
.incbin "new_graphics/alisa.tiles.bin"
.ends

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