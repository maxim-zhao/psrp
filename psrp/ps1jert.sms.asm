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

.if LANGUAGE == "en" || LANGUAGE == "literal"
; This string mapping is for raw (16-bit) tilemap data. It sets the priority bit on every tile.
.stringmaptable tilemap "tilemap.en.tbl"

; This one is for script text and item names (8-bit). It includes control codes but not dictionary words.
.stringmaptable script "script.en.tbl"

.define LETTER_S  $37   ; suffix letter ('s')
.endif

.if LANGUAGE == "fr"
.stringmaptable tilemap "tilemap.fr.tbl"
.stringmaptable script "script.fr.tbl"
.define LETTER_S  $37   ; suffix letter ('s')
.endif

.if LANGUAGE == "pt-br"
.stringmaptable tilemap "tilemap.pt-br.tbl"
.stringmaptable script "script.pt-br.tbl"
.define LETTER_S  $37   ; suffix letter ('s')
.endif

.if LANGUAGE == "ca"
.stringmaptable tilemap "tilemap.ca.tbl"
.stringmaptable script "script.ca.tbl"
.define LETTER_S  $33   ; suffix letter ('s')
.endif

.if LANGUAGE == "es"
.stringmaptable tilemap "tilemap.es.tbl"
.stringmaptable script "script.es.tbl"
.define LETTER_S  $37   ; suffix letter ('s')
.endif

.if LANGUAGE == "de"
.stringmaptable tilemap "tilemap.de.tbl"
.stringmaptable script "script.de.tbl"
.define LETTER_S  $29   ; suffix letter ('e') only used in "Punkte"
.endif


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

.slot 1

; The tile decoder needs to be in a low bank as it operates on data in slot 2.
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
  PatchB $2fdb $2b    ; cursor tile index for title screen

.slot 2
.section "Replacement title screen" superfree
TitleScreenTilesBottom:
.incbin {"generated/title.bottom.{LANGUAGE}.psgcompr"}
.ends

.section "Title screen name table" superfree
TitleScreenTilemapBottom:
.incbin {"generated/title.bottom.{LANGUAGE}.tilemap.pscompr"}
.ends

.section "Replacement title screen part 2" superfree
TitleScreenTilesTop:
.incbin "generated/title.top.psgcompr"
.ends

.section "Title screen name table for logo" superfree
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
  ld hl,$d000
  ld de,$d000 + 12 * 32 * 2
  ld bc,12 * 32 * 2
  ldir

  ; Now we load the top half
  LoadPagedTiles TitleScreenTilesTop $4000

  ld a,:TitleScreenTilemapTop
  ld (PAGING_SLOT_2),a
  ld hl,TitleScreenTilemapTop
  call DecompressToTileMapData

  call SettingsFromSRAM ; Load settings from SRAM

  jp LoadFonts ; and ret
.ends

.slot 2
.section "Outside tiles" superfree
OutsideTiles:
.incbin "generated/747b8.psgcompr"
.ends

.section "Town tiles" superfree
TownTiles:
.incbin {"generated/world2.{LANGUAGE}.psgcompr"}
.ends

  ROMPosition $00ce4
.section "BG loader patch 1" size 14 overwrite ; not movable
  LoadPagedTiles OutsideTiles $4000
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

.slot 2

.section "Palma and Dezoris open area graphics" superfree
PalettePalmaOpen:      CopyFromOriginal $40000 16
PaletteDezorisOpen:    CopyFromOriginal $40010 16
TilesPalmaAndDezorisOpen: .incbin "generated/40020.psgcompr"
.ends

.section "Forest graphics" superfree
PalettePalmaForest:    CopyFromOriginal $40f16 16
PaletteDezorisForest:  CopyFromOriginal $40f26 16
TilesPalmaForest:     .incbin "generated/40f36.psgcompr"
.ends

.section "Palma sea graphics" superfree
PalettePalmaSea:       CopyFromOriginal $41c72 16
TilesPalmaSea: .incbin "generated/41c82.psgcompr"
.ends

.section "Motabia open graphics" superfree
PaletteMotabiaOpen: CopyFromOriginal $433f6 16
TilesMotabiaOpen: .incbin "generated/43406.psgcompr"
.ends

.section "Palma town graphics" superfree
PalettePalmaTown:     CopyFromOriginal $44640 16
TilesPalmaTown: .incbin "generated/44650.psgcompr"
.ends

.section "Palma village graphics" superfree
PalettePalmaVillage:  CopyFromOriginal $457c4 16
TilesPalmaVillage: .incbin "generated/457d4.psgcompr"
.ends

.section "Spaceport graphics" superfree
PaletteSpaceport:     CopyFromOriginal $464b1 16
TilesSpaceport: .incbin "generated/464c1.psgcompr"
.ends

.section "Dead trees graphics" superfree
PaletteDeadTrees:     CopyFromOriginal $46f58 16
TilesDeadTrees: .incbin "generated/46f68.psgcompr"
.ends

.section "Air castle graphics" superfree
PaletteAirCastle:     CopyFromOriginal $5ac7d 16
PaletteAirCastleFull: CopyFromOriginal $03fc2 16
TilesAirCastle: .incbin "generated/5ac8d.psgcompr"
.ends

.section "Gold dragon graphics" superfree
PaletteGoldDragon: CopyFromOriginal $2c000 16
TilesGoldDragon: .incbin "generated/2c010.psgcompr"
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
TilesBuilding: .incbin "generated/5eb6f.psgcompr"
.ends

.section "Mansion graphics" superfree
PaletteMansion: CopyFromOriginal $27b14 16
TilesMansion: .incbin "generated/27b24.psgcompr"
.ends

.section "Lassic graphics" superfree
PaletteLassicRoom: CopyFromOriginal $524da 16
TilesLassicRoom: .incbin "generated/524ea.psgcompr"
.ends

.section "Dark Force graphics" superfree
PaletteDarkForce: CopyFromOriginal $4c000 16
TilesDarkForce: .incbin "generated/4c010.psgcompr"
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
FONT1: .incbin {"generated/font-polaris-part1.{LANGUAGE}.psgcompr"}
FONT2: .incbin {"generated/font-polaris-part2.{LANGUAGE}.psgcompr"}
FONT1a: .incbin {"generated/font-aw2284-part1.{LANGUAGE}.psgcompr"}
FONT2a: .incbin {"generated/font-aw2284-part2.{LANGUAGE}.psgcompr"}
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
  ; A = item index
  ; We skip over the elements sequentially rather than have an index.
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
  ld b,0      ; String lengths are always <256

-:ld c,(hl)   ; Grab string length
  or a        ; Check for zero strings left
  jr z,@Copy  ; _Stop if found

  inc hl      ; Bypass length byte
  add hl,bc   ; Bypass physical string
  dec a       ; One less item to look at
  jr -        ; Keep searching

@Copy:
  ; Apply bracketed parts skipping here.
  ; This code is used for all item lookups.
  ; hl = source
  ld de,TEMP_STR ; destination
  ld (STR),de ; set pointer to it
  ld b,(hl) ; Get byte length in b
  inc hl
_NextByte:
  ; Read a byte
  ld a,(hl)
  inc hl
  cp $62 ; bracket start
  jr z,_bracket
  cp $63 ; bracket end
  jr nz,+
_SkipEndBracket:
  djnz _NextByte
  jr _Done

+:; Copy the byte
  ld (de),a
  inc de
  djnz _NextByte ; Loop until counter reaches zero

_Done:
  ; Compute the actual length
  ld hl,$10000 - TEMP_STR
  add hl,de
  ld a,l
  ld (LEN),a
  ld a,2    ; Normal page
  ld (PAGING_SLOT_2),a
  ret

_bracket:
  ; get the skip type
  ld a,(hl)
  inc hl
  dec b ; Two bytes of the string have been consumed
  dec b
  push hl
    ld hl,SKIP_BITMASK
    and (hl)
  pop hl
  ; if non-zero, carry on consuming the bracket contents
  jr nz,_NextByte
  ; We discard bytes until we see a $63. We assume we won't have unbalanced brackets.
-:ld a,(hl)
  inc hl
  cp $63
  jr z,_SkipEndBracket
  djnz -
  jr _Done
.ends

.enum $5f ; Scripting codes. These correspond to codes used by the original game, plus some extensions.
; If changing the value here, you must also change the symbols range in tools.py
; and values used for articles and name block removal ([...]) in script.<xx>.tbl
; and values in the code below to handle these
  SymbolStart     .db
  SymbolPlayer    db ; $5f, Handled by the original engine
  SymbolMonster   db ; $60,
  SymbolItem      db ; $61,
  SymbolNumber    db ; $62,
  SymbolBlank     db ; $63, ; Unused
  SymbolNewLine   db ; $64,
  SymbolWaitMore  db ; $65,
  SymbolEnd       db ; $66,
  SymbolDelay     db ; $67,
  SymbolWait      db ; $68,
  SymbolPostHint  db ; $69, ; New codes
  SymbolArticle   db ; $6a,
  SymbolSuffix    db ; $6b,
  SymbolPronoun   db ; $6c,
  WordListStart   db ; $6d
.ende

; We patch the usages of these codes so we can relocate them.
; Narrative:
  PatchB $3366+1 SymbolWait
  PatchB $336b+1 SymbolEnd
  PatchB $336e+1 SymbolDelay
  PatchB $3373+1 SymbolWaitMore
  PatchB $337d+1 SymbolBlank
  PatchB $3393+1 SymbolNewLine
  PatchB $33a6+1 SymbolPlayer
  PatchB $33c4+1 SymbolMonster
  PatchB $33d6+1 SymbolItem
  PatchB $33f4+1 SymbolNumber
; Cutscenes:
  ; PatchB $34b5+1 SymbolDelay ; First two are patched over below, see "Cutscene text decoder patch"
  ; PatchB $34b9+1 SymbolWait
  PatchB $34bd+1 SymbolWaitMore
  PatchB $34c1+1 SymbolNewLine


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
.if LANGUAGE == "de"
  ; Set SKIP_BITMASK accordingly
  ; 1 => %01000 (nominative, select «» brackets only)
  ; 2 => %01010 (genitive, select «» and {} brackets)
  ; 3 => %11100 (dative, select «», ‹› and () brackets)
  ; 4 => %01100 (accusative, select «» and () brackets)
  push hl
  push de
    ld d,0
    ld hl,_SkipBitmaskLookup - 1 ; index 0 is unused
    ld e,a
    add hl,de
    ld a,(hl)
    ld (SKIP_BITMASK),a
  pop de
  pop hl
  jp _Decode
_SkipBitmaskLookup: .db %01000, %01010, %11100, %01100 ; see above
.else
  ; Select all bracketed parts
  ld a,$ff
  ld (SKIP_BITMASK),a
  jp _Decode
.endif

+:cp SymbolSuffix
  jr nz,+

  ld a,(SUFFIX)   ; Check flag
  or a
  jp z,_Decode   ; No 's' needed

  ld a,LETTER_S   ; add 's'
  jr _Done

+:cp SymbolPronoun
  jr z,_Pronoun

_Done:
  cp SymbolWait ; Old code
  ret     ; Go to remaining text handler

_Pronoun:
  call SFGDecoder    ; Grab #
  push hl
  push de
  push bc
    push af
      ; Look up character
      ld a,(NameIndex)
      and 3
      add a,a
      ; Look up in table
      ld hl,_Pronouns
      ld d,0
      ld e,a
      add hl,de
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
    pop af
    ; Then look up the pronoun index
    add a,a
    ld e,a
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ; Finally we want to emit this text. We call into the dictionary lookup code to copy it to RAM and point to it...
    call DictionaryLookup_Substring@Copy
  pop bc
  pop de
  pop hl
  ; Then we jump to here. This makes the copy above get drawn before continuing.
  jp _Start

_Pronouns: ; Lookup by character index: Alisa, Myau, Tyron, Lutz
.if LANGUAGE == "en"
.dw _PronounsF, _PronounsM, _PronounsM, _PronounsM
; Values by index:
; 0 = he/she
; 1 = his/her
_PronounsF:
.dw _PronounShe, _PronounHer
_PronounShe: String "she"
_PronounHer: String "her"
_PronounsM:
.dw _PronounHe, _PronounHis
_PronounHe: String "he"
_PronounHis: String "his"
.endif
.if LANGUAGE == "fr"
; No pronouns yet
.endif
.if LANGUAGE == "pt-br"
.dw _PronounsF, _PronounsM, _PronounsM, _PronounsM
; Values by index:
; 0 = ele/ela
; No others needed (yet)
_PronounsF:
.dw _PronounElaLower
_PronounElaLower: String "ela"
_PronounsM:
.dw _PronounEleLower
_PronounEleLower: String "ele"
.endif
.if LANGUAGE == "ca"
; No pronouns yet
.endif
.if LANGUAGE == "es"
; No pronouns yet
.endif
.if LANGUAGE == "de"
.dw _PronounsF, _PronounsM, _PronounsM, _PronounsM
; Values by index:
; 0 = Sie/Er
; 1 = sie/er
_PronounsF:
.dw _PronounSieUpper, _PronounSieLower
_PronounSieUpper: String "Sie"
_PronounSieLower: String "sie"
_PronounsM:
.dw _PronounErUpper, _PronounErLower
_PronounErUpper: String "Er"
_PronounErLower: String "er"
.endif

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

.if LANGUAGE == "en" || LANGUAGE == "literal"
      ld de,ArticlesLower
      cp $01      ; article = a,an,the
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      ; a = $02 = article = A,An,The
      ; fall through
.endif
.if LANGUAGE == "fr"
      ld de,ArticlesLower
      cp $01      ; article = l', le, la, les,
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = L', Le, La, ,
      jr z,_Start_Art

      ld de,ArticlesPossessive
      cp $03      ; article = de l', du, de la, d' ,de
      jr z,_Start_Art

      ld de,ArticlesDirective
      ; fall through
.endif
.if LANGUAGE == "pt-br"
      ld de,ArticlesLower
      cp $01      ; article = l', le, la, les,
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = L', Le, La, ,
      jr z,_Start_Art

      ld de,ArticlesPossessive
      ; fall through
.endif
.if LANGUAGE == "ca"
      ld de,ArticlesLower
      cp $01      ; article = l', el, la, els, les,
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = L', El, La, ,
      jr z,_Start_Art

      ; article = de l', du, de la, d' ,de
      ld de,ArticlesPossessive
      ; fall through
.endif
.if LANGUAGE == "es"
      ld de,ArticlesLower
      cp $01      ; article = el, la, los, las,
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = El, La, ,
      jr z,_Start_Art

      ; article = de l', du, de la, d' ,de
      ld de,ArticlesPossessive
      ; fall through
.endif
.if LANGUAGE == "de"
      ld de,ArticlesUpperNominative
      cp $01      ; article = Der, Die, Das, Ein, Eine, Ein
      jr z,_Start_Art

      ld de,ArticlesLowerGenitive
      cp $02      ; article = des, der, des, eines, einer, eines
      jr z,_Start_Art

      ; article = dem, der, dem, einem, einer, einem
      ld de,ArticlesLowerDative
      cp $03
      jr z,_Start_Art

      ; article = den, die, das, einen, eine, ein
      ld de,ArticlesLowerAccusative
      ; fall through
.endif

_Start_Art:
      ld a,(bc)   ; Grab index
      sub $64     ; Remap index range ($64 is the lowest article index)
      jr c,_Art_Done ; if there is a letter there, it'll be 0..$40ish. So do nothing.
      add a,a     ; Multiply by two
      add a,e     ; Add offset
      ld e,a
      adc a,d
      sub e
      ld d,a

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
      ld (SKIP_BITMASK),a ; and clear this too

_Art_Exit:
    pop de      ; now proceed normally
    ld bc,(STR)   ; Grab raw text location (again)
    jp _Initial_Codes

; Articles are stored backwards
.macro Article
  .stringmap script \1
  .db SymbolEnd
.endm

.if LANGUAGE == "en" || LANGUAGE == "literal"
; Order is:
; - Indefinite (starting with consonant)
; - Indefinite (starting with vowel)
; - Definite
ArticlesLower:        .dw _a, _an, _the
ArticlesInitialUpper: .dw _A, _An, _The
_a:   Article " a"
_an:  Article " na"
_the: Article " eht"
_A:   Article " A"
_An:  Article " nA"
_The: Article " ehT"
.endif
.if LANGUAGE == "fr"
; Order is:
; - Start with vowel
; - Feminine
; - Masculine
; - Plural
; - Name (so no article) - starting with vowel
; - Name (so no article) - starting with consonant
ArticlesLower:        .dw _l,     _le, _la,     _les, _blank, _blank
ArticlesInitialUpper: .dw _L,     _Le, _La,     _Les, _blank, _blank
ArticlesPossessive:   .dw _de_l,  _du, _de_la,  _des, _d,     _de
ArticlesDirective:    .dw _a_l,   _au, _a_la,   _aux, _a,     _a
_l:     Article "'l"
_le:    Article " el"
_la:    Article " al"
_les:   Article " sel"
_blank: Article ""
_L:     Article "'L"
_Le:    Article " eL"
_La:    Article " aL"
_Les:   Article " seL"
_de_l:  Article "'l ed"
_du:    Article " ud"
_de_la: Article " al ed"
_des:   Article " sed"
_d:     Article "'d"
_de:    Article " ed"
_a_l:   Article "'l à"
_au:    Article " ua"
_a_la:  Article " al à"
_aux:   Article " xua"
_a:     Article " à"
.endif
.if LANGUAGE == "pt-br"
; Order is:
; - Masculine single indefinite
; - Feminine single indefinite
; - Masculine single definite
; - Masculine plural definite
; - Feminine plural definite
; - Name without article (use de for possessive)
; Other combinations are not used in the script so we omit them here.
ArticlesLower:       .dw _um, _uma, _o,  _a,   _as,  _blank
ArticlesInitialUpper:.dw _Um, _Uma, _O,  _A,   _As,  _blank
ArticlesPossessive:  .dw _do, _dos, _do, _da,  _das, _de
_um:    Article " mu"
_uma:   Article " amu"
_o:     Article " o"
_a:     Article " a"
_as:    Article " sa"
_blank: Article ""
_Um:    Article " mU"
_Uma:   Article " amU"
_O:     Article " O"
_A:     Article " A"
_As:    Article " sA"
_do:    Article " od"
_dos:   Article " sod"
_da:    Article " ad"
_das:   Article " sad"
_de:    Article " ed"
.endif
.if LANGUAGE == "ca"
; Order is:
; - Masculine single indefinite
; - Feminine single indefinite
; - Start with vowel
; - Masculine single definite
; - Feminine single definite
; - Masculine plural definite
; - Masculine name
; - Feminine name
ArticlesLower:        .dw _un,    _una,     _l,     _el,  _la,    _els,   _en,    _na
ArticlesInitialUpper: .dw _Un,    _Una,     _L,     _El,  _La,    _Els,   _En,    _Na
ArticlesPossessive:   .dw _de_un, _de_una,  _de_l,  _del, _de_la, _dels,  _d_en,  _de_na
_un:      Article " nu"
_una:     Article " anu"
_l:       Article "’l"
_el:      Article " le"
_la:      Article " al"
_els:     Article " sle"
_en:      Article " ne"
_na:      Article " an"
_Un:      Article " nU"
_Una:     Article " anU"
_L:       Article "’L"
_El:      Article " lE"
_La:      Article " aL"
_Els:     Article " slE"
_En:      Article " nE"
_Na:      Article " aN"
_de_un:   Article " nu ed"
_de_una:  Article " anu ed"
_de_l:    Article "’l ed"
_del:     Article " led"
_de_la:   Article " al ed"
_dels:    Article " sled"
_d_en:    Article " ne'd"
_de_na:   Article " an ed"
.endif
.if LANGUAGE == "es"
; Order is:
; - Masculine single indefinite
; - Feminine single indefinite
; - Masculine single definite
; - Feminine single definite
; - Masculine plural definite
ArticlesLower:        .dw _un,    _una,     _el,  _la,    _los
ArticlesInitialUpper: .dw _Un,    _Una,     _El,  _La,    _Los
ArticlesPossessive:   .dw _de_un, _de_una,  _del, _de_la, _de_los
_un:      Article " nu"
_una:     Article " anu"
_el:      Article " le"
_la:      Article " al"
_los:     Article " sol"
_Un:      Article " nU"
_Una:     Article " anU"
_El:      Article " lE"
_La:      Article " aL"
_Los:     Article " soL"
_de_un:   Article " nu ed"
_de_una:  Article " anu ed"
_del:     Article " led"
_de_la:   Article " al ed"
_de_los:  Article " sol ed"
.endif
.if LANGUAGE == "de"
; Order is:
; - Definite masculine singular
; - Definite feminine singular
; - Definite neuter singular
; - Indefinite masculine singular
; - Indefinite feminine singular
; - Indefinite neuter singular
ArticlesUpperNominative:  .dw _Der, _Die, _Das, _Ein,   _Eine,  _Ein
ArticlesLowerGenitive:    .dw _des, _der, _des, _eines, _einer, _eines
ArticlesLowerDative:      .dw _dem, _der, _dem, _einem, _einer, _einem
ArticlesLowerAccusative:  .dw _den, _die, _das, _einen, _eine,  _ein

_Der:   Article " reD"
_Die:   Article " eiD"
_Das:   Article " saD"
_Ein:   Article " niE"
_Eine:  Article " eniE"
_des:   Article " sed"
_der:   Article " red"
_eines: Article " senie"
_einer: Article " renie"
_dem:   Article " med"
_einem: Article " menie"
_den:   Article " ned"
_die:   Article " eid"
_das:   Article " sad"
_einen: Article " nenie"
_eine:  Article " enie"
_ein:   Article " nie"
.endif

_Initial_Codes:
    ld a,(bc)   ; Grab character
    cp SymbolStart      ; Skip initial codes
    jr c,_Begin_Scan   ; Look for first real font tile

    ; Initial code skipper:
    inc bc      ; Bump pointer
    ld (STR),bc   ; Save pointer
    dec (hl)    ; Shrink length
    jr nz,_Initial_Codes ; Loop if still alive
    ; terminate if we got to the end
    ld a,SymbolEnd
    jr +

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
+:
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
  cp SymbolDelay
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
  jr z,+ ; draw number if z
  call CharacterDrawing ; else draw a regular letter
  jp InGameTextDecoder         ; and loop
+:call DrawNumberToTempStr
  inc hl      ; Process next script
  jp InGameTextDecoder

DrawNumberToTempStr:
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
    inc a       ; add 1 because result = digit+1
    ld (ix+4),a


    ; scan the resultant string to see where the first non-zero digit is
    ; but we want to show the last digit even if it is zero
    ld b,4      ; look at 4 digits max
    ld hl,TEMP_STR    ; scan value

_Scan:
    ld a,(hl)    ; load digit
    cp $01      ; check for '0'
    jr nz,_Done
    xor a       ; blank
    ld (hl),a
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
  ret

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

.if LANGUAGE == "en" || LANGUAGE == "literal"
; Order is important!
Items:
  ; Max width 18 excluding <...> prefix (with space)
  String " " ; empty item (blank). Must be at least one space.
  ;        Retranslation name                 Sega translation              Romaji              Japanese
; weapons: 01-0f
  String "<A> Wood Cane"                    ; WOODCANE  Wood Cane           uddokein            ウッドケイン
  String "<A> Short Sword"                  ; SHT. SWD  Short Sword         shōtosōdo           ショートソード
  String "<An> Iron Sword"                  ; IRN. SWD  Iron Sword          aiansōdo            アイアンソード
  String "<A> Psycho Wand"                  ; WAND      Wand                saikowondo          サイコウォンド
  String "<A> Silver Tusk"                  ; IRN.FANG  Iron Fang           shirubātasuku       シルバータスク   <-- Note, Silver fang/tusk reversed in Sega translation
  String "<An> Iron Axe"                    ; IRN. AXE  Iron Axe            aianakusu           アイアンアクス
  String "<A> Titanium Sword"               ; TIT. SWD  Titanium Sword      chitaniumusōdo      チタニウムソード
  String "<A> Ceramic Sword"                ; CRC. SWD  Ceramic Sword       seramikkusōdo       セラミックソード
  String "<A> Needle Gun"                   ; NEEDLGUN  Needle Gun          nīdorugan           ニードルガン
  String "<A> Saber Claw"                   ; SIL.FANG  Silver Fang         sāberukurō          サーベルクロー   <--
  String "<A> Heat Gun"                     ; HEAT.GUN  Heat Gun            ītogan              ヒートガン
  String "<A> Light Saber"                  ; LGT.SABR  Light Saber         raitoseibā          ライトセイバー
  String "<A> Laser Gun"                    ; LASR.GUN  Laser Gun           rēzāgan             レーザーガン
  String "<A> Laconian Sword"               ; LAC. SWD  Laconian Sword      rakoniansōdo        ラコニアンソード
  String "<A> Laconian Axe"                 ; LAC. AXE  Laconian Axe        rakonianakusu       ラコニアンアクス
; armour: 10-18
  String "<A> Leather Clothes"              ; LTH.ARMR  Leather Armor       rezākurosu          レザークロス
  String "<A> White Mantle"                 ; WHT.MANT  White Mantle        howaitomanto        ホワイトマント
  String "<A> Light Suit"                   ; LGT.SUIT  Light Suit          raitosūtsu          ライトスーツ
  String "<An> Iron Armor"                  ; IRN.ARMR  Iron Armor          aianāma             アイアンアーマ
  String "<A> Spiky Squirrel Fur"           ; THCK.FUR  Thick Fur           togerisunokegawa    トゲリスノケガワ
  String "<A> Zirconia Mail"                ; ZIR.ARMR  Zirconian Armour    jirukoniameiru      ジルコニアメイル
  String "<A> Diamond Armor"                ; DMD.ARMR  Diamond Armor       daiyanoyoroi        ダイヤノヨロイ
  String "<A> Laconian Armor"               ; LAC.ARMR  Laconian Armor      rakoniāama          ラコニアアーマ
  String "<The> Frad Mantle"                ; FRD.MANT  Frad Mantle         furādomanto         フラードマント
; shields: 19-20
  String "<A> Leather Shield"               ; LTH. SLD  Leather Shield      rezāshīrudo         レザーシールド
  String "<An> Iron Shield"                 ; BRNZ.SLD  Bronze Shield       aianshīrudo         アイアンシールド  <-- Note, order reversed in Sega translation
  String "<A> Bronze Shield"                ; IRN. SLD  Iron Shield         boronshīrudo        ボロンシールド   <--
  String "<A> Ceramic Shield"               ; CRC. SLD  Ceramic Shield      seramikkunotate     セラミックノタテ
  String "<An> Animal Glove"                ; GLOVE     Glove               animarugurabu       アニマルグラブ
  String "<A> Laser Barrier"                ; LASR.SLD  Laser Shield        rēzābaria           レーザーバリア
  String "<The> Shield of Perseus"          ; MIRR.SLD  Mirror Shield       peruseusunotate     ペルセウスノタテ
  String "<A> Laconian Shield"              ; LAC. SLD  Laconian Shield     rakoniashīrudo      ラコニアシールド
; vehicles: 21-23
  String "<The> LandMaster"                 ; LANDROVR  Land Rover          randomasutā         ランドマスター
  String "<The> FlowMover"                  ; HOVRCRFT  Hovercraft          furōmūbā            フロームーバー
  String "<The> IceDecker"                  ; ICE DIGR  Ice Digger          aisudekkā           アイスデッカー
; items: 24+
  String "<A> PelorieMate"                  ; COLA      Cola                perorīmeito         ペロリーメイト
  String "<A> Ruoginin"                     ; BURGER    Burger              ruoginin            ルオギニン
  String "<The> Soothe Flute"               ; FLUTE     Flute               sūzufurūto          スーズフルート
  String "<A> Searchlight"                  ; FLASH     Flash               sāchiraito          サーチライト
  String "<An> Escape Cloth"                ; ESCAPER   Escaper             esukēpukurosu       エスケープクロス
  String "<A> TranCarpet"                   ; TRANSER   Transer             torankāpetto        トランカーペット
  String "<A> Magic Hat"                    ; MAGC HAT  Magic Hat           majikkuhatto        マジックハット
  String "<An> Alsuline"                    ; ALSULIN   Alsulin             arushurin           アルシュリン
  String "<A> Polymeteral"                  ; POLYMTRL  Polymeteral         porimeterāru        ポリメテラール
  String "<A> Dungeon Key"                  ; DUGN KEY  Dungeon Key         danjonkī            ダンジョンキー
  String "<A> Telepathy Ball"               ; SPHERE    Sphere              terepashībōru       テレパシーボール
  String "<The> Eclipse Torch"              ; TORCH     Torch               ikuripusutōchi      イクリプストーチ
  String "<The> Aeroprism" ; $30            ; PRISM     Prism               earopurizumu        エアロプリズム
  String "<The> Laerma Berries"             ; NUTS      Nuts                raerumaberī         ラエルマベリー
  String "Hapsby"                           ; HAPSBY    Hapsby              hapusubī            ハプスビー
  String "<A> Roadpass"                     ; ROADPASS  Roadpass            rōdopasu            ロードパス
  String "<A> Passport"                     ; PASSPORT  Passport            pasupōto            パスポート
  String "<A> Compass"                      ; COMPASS   Compass             konpasu             コンパス
  String "<A> Shortcake"                    ; CAKE      Cake                shōtokēki           ショートケーキ
  String "<The> Governor[-General]'s Letter"; LETTER    Letter              soutokunotegami     ソウトクノテガミ
  String "<A> Laconian Pot"                 ; LAC. POT  Laconian Pot        rakonianpotto       ラコニアンポット
  String "<The> Light Pendant"              ; MAG.LAMP  Magic Lamp          raitopendanto       ライトペンダント
  String "<The> Carbuncle Eye"              ; AMBR EYE  Amber Eye           kābankuruai         カーバンクルアイ
  String "<A> GasClear"                     ; GAS. SLD  Gas Shield          gasukuria           ガスクリア
  String "Damoa's Crystal"                  ; CRYSTAL   Crystal             damoakurisutaru     ダモアクリスタル
  String "<A> Master System"                ; M SYSTEM  Master System       masutāshisutemu     マスターシステム
  String "<The> Miracle Key"                ; MRCL KEY  Miracle Key         mirakurukī          ミラクルキー
  String "Zillion"                          ; ZILLION   Zillion             jirion              ジリオン
  String "<A> Secret Thing"                 ; SECRET    Secret              himitsunomono       ヒミツノモノ

Names:
  String "Alisa"                            ; ALIS      Alis                arisa               アリサ
  String "Myau"                             ; MYAU      Myau                myau                ミャウ
.if LANGUAGE == "en"
  String "Tylon"                            ; ODIN      Odin                tairon              タイロン
.else
  String "Tairon" ; for "literal"
.endif
  String "Lutz"                             ; LUTZ      Lutz                rutsu               ルツ

Enemies:
  String " " ; Empty
  String "<The> Monster Fly"                ; SWORM     Sworm               monsutāfurai        モンスターフライ
  String "<The> Green Slime"                ; GR.SLIME  Green Slime         gurīnsuraimu        グリーンスライム
  String "<The> Wing Eye"                   ; WING EYE  Wing Eye            uinguai             ウイングアイ
  String "<The> Maneater"                   ; MANEATER  Man Eater           manītā              マンイーター
  String "<The> Scorpius"                   ; SCORPION  Scorpion            sukōpirasu          スコーピラス
  String "<The> Giant Naiad"                ; G.SCORPI  Gold Scorpion       rājāgo              ラージャーゴ
  String "<The> Blue Slime"                 ; BL.SLIME  Blue Slime          burūsuraimu         ブルースライム
  String "<The> Motavian Peasant"           ; N.FARMER  N.Farmer            motabiannōfu        モタビアンノーフ
  String "<The> Devil Bat"                  ; OWL BEAR  Owl Bear            debirubatto         デビルバット
  String "<The> Killer Plant"               ; DEADTREE  Dead Tree           kirāpuranto         キラープラント
  String "<The> Biting Fly"                 ; SCORPIUS  Scorpius            baitāfurai          バイターフライ
  String "<The> Motavian Teaser"            ; E.FARMER  E.Farmer            motabianibiru       モタビアンイビル
  String "<The> Herex"                      ; GIANTFLY  Giant Fly           herekkusu           ヘレックス
  String "<The> Sandworm"                   ; CRAWLER   Crawler             sandofūmu           サンドフーム
  String "<The> Motavian Maniac"            ; BARBRIAN  Barbarian           motabianmania       モタビアンマニア
  String "<The> Gold Lens" ; $10            ; GOLDLENS  Goldlens            gōrudorenzu         ゴールドレンズ
  String "<The> Red Slime"                  ; RD.SLIME  Red Slime           reddosuraimu        レッドスライム
  String "<The> Bat Man"                    ; WERE BAT  Werebat             battoman            バットマン
  String "<The> Horseshoe Crab"             ; BIG CLUB  Big Club            kabutogani          カブトガニ
  String "<The> Shark King"                 ; FISHMAN   Fishman             shākin              シャーキン
  String "<The> Lich"                       ; EVILDEAD  Evil Dead           ritchi              リッチ
  String "<The> Tarantula"                  ; TARANTUL  Tarantula           taranuchirra        タラヌチッラ
  String "<The> Manticort"                  ; MANTICOR  Manticore           manchikoa           マンチコア
  String "<The> Skeleton"                   ; SKELETON  Skeleton            sukeruton           スケルトン
  String "<The> Ant-lion"                   ; ANT LION  Ant Lion            arijigoku           アリジゴク
  String "<The> Marshes"                    ; MARMAN    Marshman            māshīzu             マーシーズ
  String "<The> Dezorian"                   ; DEZORIAN  Dezorian            dezorian            デゾリアン
  String "<The> Desert Leech"               ; LEECH     Leech               dezātorīchi         デザートリーチ
  String "<The> Cryon"                      ; VAMPIRE   Vampire             kuraion             クライオン
  String "<The> Big Nose"                   ; ELEPHANT  Elephant            biggunōzu           ビッグノーズ
  String "<The> Ghoul"                      ; GHOUL     Ghoul               gūru                グール
  String "<The> Ammonite" ; $20             ; SHELFISH  Shellfish           anmonaito           アンモナイト
  String "<The> Executor"                   ; EXECUTER  Executer            eguzekyūto          エグゼキュート
  String "<The> Wight"                      ; WIGHT     Wight               waito               ワイト
  String "<The> Skull Soldier"              ; SKULL-EN  Skull-En            sukarusorujā        スカルソルジャー
  String "<The> Snail"                      ; AMMONITE  Ammonite            maimai              マイマイ
  String "<The> Manticore"                  ; SPHINX    Sphinx              manchikōto          マンチコート
  String "<The> Serpent"                    ; SERPENT   Serpent             sāpento             サーペント
  String "<The> Leviathan"                  ; SANDWORM  Sandworm            ribaiasan           リバイアサン
  String "<The> Dorouge"                    ; LICH      Lich                dorūju              ドルージュ
  String "<The> Octopus"                    ; OCTOPUS   Octopus             okutopasu           オクトパス
  String "<The> Mad Stalker"                ; STALKER   Stalker             maddosutōkā         マッドストーカー
  String "<The> Dezorian Head"              ; EVILHEAD  Evil Head           dezorianheddo       デゾリアンヘッド
  String "<The> Zombie"                     ; ZOMBIE    Zombie              zonbi               ゾンビ
  String "<The> Living Dead"                ; BATALION  Battalion           byūto               ビュート
  String "<The> Robot Police"               ; ROBOTCOP  Robotcop            robottoporisu       ロボットポリス
  String "<The> Cyborg Mage"                ; SORCERER  Sorcerer            saibōgumeiji        サイボーグメイジ
  String "<The> Flame Lizard" ; $30         ; NESSIE    Nessie              furēmurizado        フレームリザド
  String "Tajim"                            ; TARZIMAL  Tarzimal            tajimu              タジム
  String "<The> Gaia"                       ; GOLEM     Golem               gaia                ガイア
  String "<The> Machine Guard"              ; ANDROCOP  Androcop            mashīngādā          マシーンガーダー
  String "<The> Big Eater"                  ; TENTACLE  Tentacle            bigguītā            ビッグイーター
  String "<The> Talos"                      ; GIANT     Giant               tarosu              タロス
  String "<The> Snake Lord"                 ; WYVERN    Wyvern              sunēkurōdo          スネークロード
  String "<The> Death Bearer"               ; REAPER    Reaper              desubearā           デスベアラー
  String "<The> Chaos Sorcerer"             ; MAGICIAN  Magician            kaosusōsarā         カオスソーサラー
  String "<The> Centaur"                    ; HORSEMAN  Horseman            sentōru             セントール
  String "<The> Ice Man"                    ; FROSTMAN  Frostman            aisuman             アイスマン
  String "<The> Vulcan"                     ; AMUNDSEN  Amundsen            barukan             バルカン
  String "<The> Red Dragon"                 ; RD.DRAGN  Red Dragon          reddodoragon        レッドドラゴン
  String "<The> Green Dragon"               ; GR.DRAGN  Green Dragon        gurīndoragon        グリーンドラゴン
  String "LaShiec"                          ; SHADOW    Shadow              rashīku             ラシーク
  String "<The> Mammoth"                    ; MAMMOTH   Mammoth             manmosu             マンモス
  String "<The> King Saber"   ; $40         ; CENTAUR   Centaur             kinguseibā          キングセイバー
  String "<The> Dark Marauder"              ; MARAUDER  Marauder            dākumarōdā          ダークマローダー
  String "<The> Golem"                      ; TITAN     Titan               kōremu              コーレム
  String "Medusa"                           ; MEDUSA    Medusa              medyūsa             メデューサ
  String "<The> Frost Dragon"               ; WT.DRAGN  White Dragon        furosutodoragon     フロストドラゴン
  String "Dragon Wise"                      ; B.DRAGN   Blue Dragon         doragonwaizu        ドラゴンワイズ
  String "<The> Gold Drake"                 ; GD.DRAGN  Gold Dragon         gōrudodoreiku       ゴールドドレイク
  String "<The> Mad Doctor"                 ; DR.MAD    Dr. Mad             maddodokutā         マッドドクター
  String "LaShiec"                          ; LASSIC    Lassic              rashīku             ラシーク
  String "Dark Force"                       ; DARKFALZ  Dark Falz           dākufarusu          ダークファルス
  String "Nightmare"                        ; SACCUBUS  Saccubus            naitomea            ナイトメア
.endif

.if LANGUAGE == "fr"
Items:
; empty item (blank)
  String " "
; Armes
  String "<du> Sceptre"
  String "<du> Glaive"
  String "<de l'>Épée"
  String "<du> Sceptre Psycho"
  String "<des> Griffes d'acier"
  String "<de la> Hache"
  String "<de l'>Épée titane"
  String "<de l'>Épée céramique"
  String "<du> Pistolet à pointes"
  String "<des> Crocs en métal"
  String "<du> Canon plasma"
  String "<du> Sabre laser"
  String "<du> Pistolet laser"
  String "<de l'>Épée laconian"
  String "<de la> Hache laconian"
; Armures
  String "<du> Tenue de cuir"
  String "<de la> Cape blanche"
  String "<du> Plastron"
  String "<de l'>Armure d'acier"
  String "<de la> Fourrure piquante"
  String "<de la> Armure zircon"
  String "<de l'>Armure diamant"
  String "<de l'>Armure laconian"
  String "<de la> Cape de Frad"
; Boucliers
  String "<du> Bouclier de cuir"
  String "<du> Bouclier de bronze"
  String "<du> Bouclier d'acier"
  String "<du> Bouclier céramique"
  String "<des> Gants sauvages"
  String "<du> Bouclier laser"
  String "<du> Bouclier de Persée"
  String "<du> Bouclier laconian"
; véhicules
  String "<du> GéoMaster"
  String "<de l'>AquaNaute"
  String "<du> ForaGlace"
; objets
  String "<de la> Vitabarre"
  String "<de l'>Aquavital"
  String "<de la> Flute apaisante"
  String "<de la> Lampe torche"
  String "<du> Voile de fuite"
  String "<du> Tapis du croyant"
  String "<de la> Coiffe magique"
  String "<de l'>Alsuline"
  String "<de la> Polymatériau"
  String "<de la> Clé des donjons"
  String "<de la> Sphère d'esprit"
  String "<de la> Torche d'éclipse"
  String "<de l'>Aéroprisme"
  String "<des> Baies Laerma"
  String "<de> Hapsby"
  String "<du> Permis"
  String "<du> Passeport"
  String "<du> Boussole"
  String "<de la> Tarte"
  String "<de la> Lettre [du Gouverneur]"
  String "<du> Vase laconian"
  String "<du> Pendentif lumineux"
  String "<de l'>Œil d'escarboucle"
  String "<du> Masque à gaz"
  String "<du> Cristal de Damoa"
  String "<de la> Master System"
  String "<de la> Clé Magique"
  String "<de> Shinobi"
  String "<de l'>Objet secret"
Names:
; Persos
  String "<d'>Alisa"
  String "<de> Myau"
  String "<de> Tylon"
  String "<de> Lutz"
Enemies:
; Monstres
; empty item (blank)
  String " "
  String "<de la> Mouche géante"
  String "<du> Gluant vert"
  String "<de l'>Oculum ailé"
  String "<du> Dévoreur"
  String "<du> Scorpion"
  String "<de la> Naïade géante"
  String "<du> Gluant bleu"
  String "<du> Paysan Motavien"
  String "<de l'>Oculum vampire"
  String "<de la> Plante carnivore"
  String "<de l'>Hélix"
  String "<du> Chineur Motavien"
  String "<de la> Mouche piquante"
  String "<du> Vers des sables"
  String "<du> Barjot Motavien"
  String "<de l'>Oculum doré"
  String "<du> Gluant rouge"
  String "<de l'>Homo chiropter"
  String "<de la> Limule"
  String "<de l'>Homo squalus"
  String "<de l'>Âme errante"
  String "<de la> Tarentule"
  String "<de la> Manticore"
  String "<du> Squelette"
  String "<du> Fourmilion"
  String "<de l'>Homo palustris"
  String "<du> Dézorien"
  String "<de la> Sangsue du désert"
  String "<de l'>Homo nosferatu"
  String "<de l'>Éléphant"
  String "<du> Goule"
  String "<de l'>Ammonite"
  String "<de l'>Exécuteur"
  String "<de la> Liche"
  String "<du> Soldat squelette"
  String "<du> Nautilus"
  String "<du> Sphinx"
  String "<du> Serpent"
  String "<du> Léviathan"
  String "<du> Roi Liche"
  String "<de la> Pieuvre"
  String "<du> Rôdeur"
  String "<du> Chef Dézorien"
  String "<du> Revenant"
  String "<du> Mort vivant"
  String "<du> Cyber garde"
  String "<du> Sorcier du Chaos"
  String "<du> Lézard de feu"
  String "<de> Maître Tajim"
  String "<du> Gaia"
  String "<du> Garde mécanique"
  String "<du> Kraken"
  String "<du> Talos"
  String "<du> Seigneur serpent"
  String "<du> Porteur de mort"
  String "<du> Cyber mage"
  String "<du> Centaure"
  String "<du> Géant de glace"
  String "<du> Géant de feu"
  String "<du> Dragon rouge"
  String "<du> Dragon vert"
  String "<de l'>Ombre de Lassic"
  String "<du> Mammouth"
  String "<du> Roi des sabres"
  String "<du> Maraudeur sombre"
  String "<du> Golem"
  String "<de> Médusa"
  String "<du> Dragon blanc"
  String "<du> Dragon de Casba"
  String "<du> Dragon doré"
  String "<du> Savant fou"
  String "<de> Lassic"
  String "<de> Force Obscure"
  String "<de> Cauchemar"
.endif

.if LANGUAGE == "pt-br"
Items:
; empty item (blank)
  String " "
; Armas         123456789012345678
  String  "<um> Cajado"
  String "<uma> Espada Curta"
  String "<uma> Espada de Ferro"
  String  "<um> Cajado Mágico"
  String "<uma> Presa de Prata"
  String  "<um> Machado de Ferro"
  String "<uma> Espada de Titânio"
  String "<uma> Espada de Cerâmica"
  String "<uma> Pistola de Agulhas"
  String "<uma> Garra Afiada"
  String "<uma> Pistola de Calor"
  String  "<um> Sabre de Luz"
  String "<uma> Arma Laser"
  String "<uma> Espada de Lacônia"
  String  "<um> Machado de Lacônia"
; Armaduras     123456789012345678
  String "<uma> Veste de Couro"
  String  "<um> Manto Branco"
  String "<uma> Veste Leve"
  String "<uma> Armadura de Ferro"
  String "<uma> Pele Espinhosa"
  String "<uma> Malha de Zicórnio"
  String "<uma> Armadura de Diamante"
  String "<uma> Armadura de Lacônia"
  String   "<o> Manto de Frade"
; Escudos       123456789012345678
  String  "<um> Escudo de Couro"
  String  "<um> Escudo de Bronze"
  String  "<um> Escudo de Ferro"
  String  "<um> Escudo de Cerâmica"
  String "<uma> Luva Animal"
  String "<uma> Barreira Laser"
  String   "<o> Escudo de Perseu"
  String  "<um> Escudo de Lacônia"
; veículos      123456789012345678
  String   "<o> Rover Terrestre"
  String   "<o> Aerobarco"
  String   "<o> Escavador de Gelo"
; objetos       123456789012345678
  String "<uma> PelorieMate"
  String "<uma> Ruoginina"
  String   "<a> Flauta Calmante"
  String "<uma> Lanterna"
  String "<uma> Capa de Fuga"
  String  "<um> Teletapete"
  String  "<um> Chapéu Mágico"
  String "<uma> Alsulina"
  String  "<um> Polimaterial"
  String "<uma> Chave do Calabouço"
  String "<uma> Bola de Telepatia"
  String   "<a> Tocha Eclipse"
  String   "<o> Aeroprisma"
  String  "<as> Frutas de Laerma"
  String       "Hapsby"
  String  "<um> Passe"
  String  "<um> Passaporte"
  String "<uma> Bússola"
  String  "<um> Bolo"
  String   "<a> Carta do Governador[-Geral]"
  String  "<um> Pote de Lacônia"
  String   "<o> Pingente de Luz"
  String   "<o> Olho de Carbúnculo"
  String "<uma> Máscara de Gás"
  String   "<o> Cristal de Damoa"
  String  "<um> Master System"
  String   "<a> Chave Milagrosa"
  String       "Zillion"
  String "<uma> Coisa Secreta"
Names:
; Personagens
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"
Enemies:
; Monstros
; empty item (blank)
  String " "
  String "<a> Mosca Gigante"
  String "<a> Gosma Verde"
  String "<o> Olho Alado"
  String "<o> Devorador"
  String "<o> Escorpião"
  String "<o> Escorpião Gigante"
  String "<a> Gosma Azul"
  String "<o> Motaviano Camponês"
  String "<o> Olho Perverso"
  String "<a> Planta Assassina"
  String "<o> Escorpião Assassino"
  String "<o> Motaviano Cardador"
  String "<a> Herex"
  String "<o> Verme da Areia"
  String "<o> Motaviano Maníaco"
  String "<a> Lente Dourada"
  String "<a> Gosma Vermelha"
  String "<o> Homem Morcego"
  String "<o> Caranguejo-Ferradura"
  String "<o> Homem-Peixe"
  String "<o> Lich"
  String "<a> Tarântula"
  String "<a> Mantícora"
  String "<o> Esqueleto"
  String "<a> Formiga-Leão"
  String "<o> Homem do Pântano"
  String "<o> Dezoriano"
  String "<a> Sanguessuga"
  String "<o> Vampiro"
  String "<o> Elefante"
  String "<o> Canibal"
  String "<a> Amonita"
  String "<o> Executor"
  String "<a> Alma Penada"
  String "<o> Soldado Caveira"
  String "<o> Caracol"
  String "<a> Esfinge"
  String "<a> Serpente"
  String "<o> Leviatã"
  String "<o> Opressor"
  String "<o> Polvo"
  String "<o> Caçador Maluco"
  String "<o> Líder Dezoriano"
  String "<o> Zumbi"
  String "<o> Morto-Vivo"
  String "<o> Robô Policial"
  String "<o> Mago Ciborgue"
  String "<a> Salamandra"
  String "<nome> Tajim"
  String "<o> Titã"
  String "<o> Guarda Mecânico"
  String "<o> Tentáculo"
  String "<o> Talos"
  String "<a> Senhora Serpente"
  String "<o> Ceifador"
  String "<o> Mago Caótico"
  String "<o> Centauro"
  String "<o> Homem de Gelo"
  String "<o> Vulcão"
  String "<o> Dragão Vermelho"
  String "<o> Dragão Verde"
  String "<nome> LaShiec"
  String "<o> Mamute"
  String "<o> Centauro Rei"
  String "<o> Saqueador Negro"
  String "<o> Golem"
  String "<nome> Medusa"
  String "<o> Dragão de Gelo"
  String "<o> Dragão Sábio"
  String "<o> Dragão Dourado"
  String "<o> Doutor Maluco"
  String "<nome> LaShiec"
  String "<nome> Força Sombria"
  String "<nome> Pesadelo"
.endif

.if LANGUAGE == "ca"
Items:
; empty item (blank)
  String " "
; Armas         123456789012345678
  String  "<un> Bastó"
  String "<una> Espasa Curta"
  String "<una> Espasa de Ferro"
  String  "<un> Bastó Màgic"
  String  "<un> Ullal de Plata"
  String "<una> Destral de Ferro"
  String "<una> Espasa de Titani"
  String "<una> Espasa de Ceràmica"
  String "<una> Pistola d'Agulles"
  String "<una> Garra Esmolada"
  String "<una> Pistola de Calor"
  String  "<un> Sabre de Llum"
  String "<una> Arma Làser"
  String "<una> Espasa de Laconia"
  String "<una> Destral de Laconia"
; Armaduras     123456789012345678
  String  "<un> Peto de Cuir"
  String  "<un> Mantell Blanc"
  String  "<un> Vestit Lleuger"
  String "<una> Armadura de Ferro"
  String "<una> Pell Punxeguda"
  String "<una> Malla de Zicorni"
  String "<una> Armadura de Diamant"
  String "<una> Armadura de Laconia"
  String  "<la> Capa de Frai"
; Escudos       123456789012345678
  String  "<un> Escut de Cuir"
  String  "<un> Escut de Bronze"
  String  "<un> Escut de Ferro"
  String  "<un> Escut de Ceràmica"
  String  "<un> Guant Animal"
  String "<una> Barrera Làser"
  String  "<el> Escut de Perseu"
  String  "<un> Escut de Laconia"
; veículos      123456789012345678
  String  "<el> LandMaster"
  String  "<l'>AeroLliscador"
  String  "<el> Trencaglaç"
; objetos       123456789012345678
  String  "<un> PelorieMate"
  String  "<un> Ruoginin"
  String  "<la> Flauta Calmant"
  String "<una> Llanterna"
  String "<una> Capa de Fuga"
  String "<una> Telecatifa"
  String  "<un> Barret Màgic"
  String "<una> Alsulina"
  String  "<un> Polymeteral"
  String "<una> Clau de Masmorra"
  String "<una> Bola Telepàtica"
  String  "<la> Torcha d'Eclipsi"
  String  "<el> Aeroprisma"
  String "<els> Fruits de Laerma"
  String  "<en> Hapsby"
  String  "<un> Salconduit"
  String  "<un> Passaport"
  String "<una> Brúixola"
  String  "<un> Pastís"
  String  "<la> Carta del Governador[ General]"
  String "<una> Olla de Laconia"
  String   "<l'>Arrecada de Llum"
  String   "<l'>Ull de Carboncle"
  String "<una> Màscara de Gas"
  String  "<el> Cristall de Damoa"
  String "<una> Master System"
  String  "<la> Clau Miraculosa"
  String       "Zillion"
  String "<una> Cosa Secreta"
Names:
; Personagens
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"
Enemies:
; Monstres
; empty item (blank)
  String " "
  String "<el> Borinot"
  String "<el> Llot Verd"
  String  "<l'>Ull Volador"
  String "<el> Devorahomes"
  String  "<l'>Escorpí"
  String  "<l'>Escorpí Gegant"
  String "<el> Llot Blau"
  String "<el> Pagés de Motavia"
  String "<el> Ratpenat Pervers"
  String "<la> Planta Assassina"
  String  "<l'>Escorpí Assassí"
  String "<el> Tafur de Motavia"
  String "<el> Herex"
  String "<el> Cuc de Terra"
  String "<el> Maníac de Motavia"
  String "<la> Lent Daurada"
  String "<el> Llot Vermell"
  String  "<l'>Home Ratpenat"
  String "<el> Cranc Ferradura"
  String "<el> Rei Tauró"
  String "<el> Calabre"
  String "<la> Taràntula"
  String "<la> Mantícora"
  String  "<l'>Esquelet"
  String "<la> Formiga Lleó"
  String  "<l'>Home de l'Aiguamoll"
  String "<el> Dezorià"
  String "<la> Sangonera de Sorra"
  String "<el> Vampir"
  String  "<l'>Elefant"
  String "<el> Gul"
  String  "<l'>Ammonita"
  String "<el> Botxí"
  String  "<l'>Anima en Pena"
  String "<el> Soldat Calavera"
  String "<el> Cargol"
  String "<l'> Esfinx"
  String "<la> Serp"
  String "<el> Leviatà"
  String  "<l'>Opressor"
  String "<el> Pop"
  String "<el> Caçador Foll"
  String "<el> Cabdill Dezorià"
  String "<el> Zombi"
  String "<el> Mort Vivent"
  String "<el> Policia Robot"
  String "<el> Mag Cyborg"
  String "<la> Salamandra"
  String "<en> Tajim"
  String "<el> Tità"
  String "<el> Guardia Mecànic"
  String "<el> Tentacle"
  String "<el> Talos"
  String "<la> Senyora Serp"
  String "<el> Portamort"
  String "<el> Mag del Caos"
  String "<el> Centaure"
  String  "<l'>Home de Gel"
  String "<el> Vulcà"
  String "<el> Drac Vermell"
  String "<el> Drac Verd"
  String "<en> Lashiec"
  String "<el> Mamut"
  String "<el> Rei Centaure"
  String "<el> Cavaller Negre"
  String "<el> Golem"
  String "<na> Medusa"
  String "<el> Drac de Gel"
  String "<el> Drac Savi"
  String "<el> Drac Daurat"
  String "<el> Doctor Boig"
  String "<en> Lashiec"
  String "<na> Força Fosca"
  String "<el> Súcube"
.endif

.if LANGUAGE == "es"
Items:
; empty item (blank)
  String " "
; Armas         123456789012345678
  String  "<un> Bastón"
  String "<una> Espada Corta"
  String "<una> Espada de Hierro"
  String  "<un> Bastón Mágico"
  String  "<un> Colmillo de Plata"
  String "<una> Hacha de Hierro"
  String "<una> Espada de Titanio"
  String "<una> Espada de Cerámica"
  String "<una> Pistola de Agujas"
  String "<una> Garra Afilada"
  String "<una> Pistola de Calor"
  String  "<un> Sable de Luz"
  String "<una> Arma Láser"
  String "<una> Espada de Laconia"
  String "<una> Hacha de Laconia"
; Armaduras     123456789012345678
  String  "<un> Peto de Cuero"
  String  "<un> Mantel Blanco"
  String  "<un> Vestido Ligero"
  String "<una> Armadura de Hierro"
  String "<una> Piel Puntiaguda"
  String "<una> Malla de Zicornio"
  String "<una> Armadura de Diamante"
  String "<una> Armadura de Laconia"
  String  "<la> Capa de Fray"
; Escudos       123456789012345678
  String  "<un> Escudo de Cuero"
  String  "<un> Escudo de Bronce"
  String  "<un> Escudo de Hierro"
  String  "<un> Escudo de Cerámica"
  String  "<un> Guante Animal"
  String "<una> Barrera Láser"
  String  "<el> Escudo de Perseo"
  String  "<un> Escudo de Laconia"
; veículos      123456789012345678
  String  "<el> LandMaster"
  String  "<el> Aerodeslizador"
  String  "<el> Rompehielos"
; objetos       123456789012345678
  String  "<un> PelorieMate"
  String  "<un> Ruoginin"
  String  "<la> Flauta Calmante"
  String "<una> Linterna"
  String "<una> Capa de Fuga"
  String "<una> TeleAlfombra"
  String  "<un> Sombrero Mágico"
  String "<una> Alsulina"
  String  "<un> Polymeteral"
  String "<una> Llave de Mazmorra"
  String "<una> Bola Telepática"
  String  "<la> Antorcha de Eclipse"
  String  "<el> Aeroprisma"
  String "<los> Frutos de Laerma"
  String  "Hapsby"
  String  "<un> Salvoconducto"
  String  "<un> Pasaporte"
  String "<una> Brújula"
  String  "<un> Pastel"
  String  "<la> Carta del Gobernador[ General]"
  String "<una> Olla de Laconia"
  String "<el> Pendiente de Luz"
  String "<el> Ojo de Carbúnculo"
  String "<una> Máscara de Gas"
  String  "<el> Cristal de Damoa"
  String "<una> Master System"
  String  "<la> llave Milagrosa"
  String       "Zillion"
  String "<una> Cosa Secreta"
Names:
; Personajes
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"
Enemies:
; Monstres
; empty item (blank)
  String " "
  String "<el> Abejorro"
  String "<el> Limo Verde"
  String "<el> Ojo Volador"
  String "<el> Devorahombres"
  String "<el> Escorpión"
  String "<el> Escorpión Gigante"
  String "<el> Limo Azul"
  String "<el> Agricultor de Motavia"
  String "<el> Murcielago Perverso"
  String "<la> Planta Asesina"
  String "<el> Escorpión Asesino"
  String "<el> Tahur de Motavia"
  String "<el> Herex"
  String "<la> Lombriz de Tierra"
  String "<el> Maníaco de Motavia"
  String "<la> Lente Dorada"
  String "<el> Limo Rojo"
  String "<el> Hombre Murciélago"
  String "<el> Cangrejo Herradura"
  String "<el> Rey Tiburón"
  String "<el> Liche"
  String "<la> Tarántula"
  String "<la> Mantícora"
  String "<el> Esqueleto"
  String "<la> Hormiga León"
  String "<el> Hombree del Pantano"
  String "<el> Dezoriano"
  String "<la> Sanguijuela de Arena"
  String "<el> Vampiro"
  String "<el> Elefante"
  String "<el> Necrófago"
  String "<la> Ammonita"
  String "<el> Verdugo"
  String "<el> Alma en Pena"
  String "<el> Soldado Calavera"
  String "<el> Caracol"
  String "<la> Esfinge"
  String "<la> Serpiente"
  String "<el> Leviatán"
  String "<el> Opresor"
  String "<el> Pulpo"
  String "<el> Cazador Loco"
  String "<el> Cabecilla Dezoriano"
  String "<el> Zombi"
  String "<el> Muerto Viviente"
  String "<el> Policía Robot"
  String "<el> Mago Cyborg"
  String "<la> Salamandra"
  String "Tajim"
  String "<el> Titán"
  String "<el> Guardia Mecánico"
  String "<el> Tentáculo"
  String "<el> Talos"
  String "<la> Señora Serpiente"
  String "<el> Portador de Muerte"
  String "<el> Mago del Caos"
  String "<el> Centauro"
  String "<el> Hombre de Hielo"
  String "<el> Vulcano"
  String "<el> Dragón Rojo"
  String "<el> Dragón Verde"
  String "Lashiec"
  String "<el> Mamut"
  String "<el> Rey Centauro"
  String "<el> Caballero Negro"
  String "<el> Golem"
  String "Medusa"
  String "<el> Dragón de Hielo"
  String "<el> Dragón Sabio"
  String "<el> Dragón Dorado"
  String "<el> Doctor Loco"
  String "Lashiec"
  String "Fuerza Oscura"
  String "<el> Súcubo"
.endif
.if LANGUAGE == "de"
Items:
  ; Max width 20 excluding <...> prefix (with space)
  ; Characters in [] only get printed in windows (enemy name, inventory, equipped items).
  ; Those in {} get printed only in the script window, if <item>/<player>/<monster> comes after <gen>.
  ; Those in () get printed only in the script window, if <item>/<player>/<monster> comes after <dat>.
  ; Those in «» get printed only in the script window, with no dependence on previous tags.

  String " " ; empty item (blank). Must be at least one space.
; weapons: 01-0f
  String "<Ein> Holzstock"
  String "<EinN> Kurzschwert"
  String "<EinN> Eisenschwert"
  String "<Ein> Psychostab"
  String "<Ein> Silberzahn"
  String "<Eine> Eisenaxt"
  String "<EinN> Titanschwert"
  String "<EinN> Keramikschwert"
  String "<Eine> Nadelpistole"
  String "<Eine> Säbelklaue"
  String "<Eine> Heißluftpistole"
  String "<EinN> Lichtschwert"
  String "<Eine> Laserpistole"
  String "<Das> Lakoniumschwert"
  String "<Die> Lakoniumaxt"
; armour: 10-18
  String "Lederkleidung"
  String "<Ein> Weiße[r](n) Umhang"
  String "<Ein> Leichte[r](n) Anzug"
  String "<Eine> Eisenrüstung"
  String "<EinN> Stacheltierfell"
  String "<Ein> Zirkoniumharnisch"
  String "<Eine> Diamantrüstung"
  String "<Die> Lakoniumrüstung"
  String "<Der> Frahd-Umhang"
; shields: 19-20
  String "<Ein> Lederschild"
  String "<Ein> Eisenschild"
  String "<Ein> Bronzeschild"
  String "<Ein> Keramikschild"
  String "Tierhandschuhe‹n›"
  String "<Eine> Laserbarriere"
  String "<Der> Schild des Perseus"
  String "<Der> Lakoniumschild"
; vehicles: 21-23
  String "<Der> LandMaster"
  String "<Der> FlowMover"
  String "<Der> IceDecker"
; items: 24+
  String "<EinN> PelorieMate"
  String "<EinN> Ruoginin"
  String "<Die> Sanfte Flöte"			; alt: "<Die> Besänftigungsflöte"
  String "<Ein> Scheinwerfer"
  String "<Ein> Tarnumhang"
  String "<Ein> Fliegende[r](n) Teppich"
  String "<Ein> Zauberhut"
  String "<Das> Alsulin"				; alt: "<Die> «Flasche »Alsulin"
  String "<Das> Polymeteral"			; alt: "<Eine> «Flasche »Polymeteral"
  String "<Der> Generalschlüssel"
  String "<Eine> Telepathiekugel"
  String "<Die> Sonnenfackel"
  String "<Das> Aeroprisma"
  String "<Die> Laermabeeren"
  String "Hapsby"
  String "<Ein> Straßenpass"			; use definite article?
  String "<Ein> Reisepass"				; use definite article?
  String "<Der> Kompass"
  String "<EinN> Törtchen"
  String "<Der> Brief vom G«eneralg»ouverneur"
  String "<Ein> Lakoniumtopf"
  String "<Ein> Lichtanhänger"
  String "<Das> Karbunkelauge"
  String "<Eine> Gasmaske"
  String "Damoas Kristall"
  String "<EinN> Master System"
  String "<Der> Wunderschlüssel"
  String "Zillion"
  String "<EinN> Geheimnis"

Names:
  String "Alisa{s}"
  String "Myau{s}"
  String "Tylon{s}"
  String "Lutz{'}"

Enemies:
; Max width 18 for enemy window, excluding <...> prefix (with space)
  String " " ; Empty
  String "<Die> Riesenfliege"
  String "<Der> Grünschleim{s}"
  String "<Das> Flügelauge{s}"
  String "<Der> Menschenfresser{s}"
  String "<Der> Skorpion{s}"
  String "<Der> Goldskorpion{s}"
  String "<Der> Blauschleim{s}"
  String "<Der> Motavische[r]{n}(n) Bauer{s}(n)"
  String "<Die> Teufelsfledermaus"
  String "<Der> Mörderbaum{s}"
  String "<Die> Beißerfliege"
  String "<Der> Motavische[r]{n}(n) Pläger{s}"
  String "<Der> Herex"
  String "<Der> Sandwurm{s}"
  String "<Der> Motavische[r]{n}(n) Irre[r]{n}(n)"
  String "<Die> Goldlinse"
  String "<Der> Rotschleim{s}"
  String "<Der> Fledermausmann{s}"
  String "<Der> Pfeilschwanzkrebs{es}"
  String "<Der> Haikönig{s}"
  String "<Der> Lich{s}"
  String "<Die> Tarantel"
  String "<Der> Mantikor{s}"
  String "<Das> Skelett{s}"
  String "<Der> Ameisenlöwe{n}(n)"
  String "<Der> Morastmann{s}"
  String "<Der> Dezorianer{s}"
  String "<Der> Wüstenegel{s}"
  String "<Der> Cryon{s}"							; think of a different translation
  String "<Der> Riesenrüssel{s}"
  String "<Der> Ghul{s}"
  String "<Der> Ammonit{s}"
  String "<Der> Hinrichter{s}"
  String "<Der> Wicht{s}"
  String "<Der> Schädelsoldat{en}(en)"
  String "<Die> Schnecke"							; different name, maybe?
  String "<Der> Mantikort{s}"
  String "<Die> Riesenschlange"
  String "<Der> Leviathan{s}"
  String "<Der> Königslich{s}"
  String "<Der> Krake{n}(n)"
  String "<Der> Wilde[r]{n}(n) Jäger{s}"
  String "<Der> Dezorianer-Häuptling{s}"			; too long
  String "<Der> Zombie{s}"
  String "<Der> Lebende[r]{n}(n) Tote[r]{n}(n)"
  String "<Der> Roboterpolizist{en}(en)"
  String "<Der> Cyborgmagier{s}"
  String "<Die> Feuerechse"
  String "Tajim{s}"
  String "<Der> Erdriese{n}(n)"
  String "<Die> Wächtermaschine"
  String "<Der> Vielfraß{es}"
  String "<Der> Talos"
  String "<Die> Oberschlange"
  String "<Der> Todbringer{s}"
  String "<Der> Chaosmagier{s}"
  String "<Der> Zentaur{en}(en)"
  String "<Der> Eismensch{en}(en)"
  String "<Der> Vulcanus"
  String "<Der> Rote[r]{n}(n) Drache{n}(n)"
  String "<Der> Grüne[r]{n}(n) Drache{n}(n)"
  String "Lashiec{s}"
  String "<Das> Mammut{s}"
  String "<Der> Säbelkönig{s}"
  String "<Der> Schattenplünderer{s}"
  String "<Der> Golem{s}"
  String "Medusa{s}"
  String "<Der> Eisdrache{n}(n)"
  String "<Der> Weise[r]{n}(n) Drache{n}(n)"
  String "<Der> Golddrache{n}(n)"
  String "<Der> Irre[r]{n}(n) Doktor{s}"
  String "Lashiec{s}"
  String "Dunkle{r} Macht"							; with or without article is the question
  String "<Der> Albtraum{s}"
.endif

.ends

.section "Static dictionary" superfree
.block "Words"
; Note that the number of words we add here has a complicated effect on the data size.
; Adding more words costs space here (in a paged bank), but saves space in bank 2.
; If our goal is to maximise script space then we should maximise the word count.
; The limit is 147 ($100 - WordListStart).
; If our goal is to minimise total space used across both the script and word list then the
; best number has to be found by brute force; for the 1.02 (English) script this was at 79.
Words:
.include {"generated/words.{LANGUAGE}.asm"}
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
.if LANGUAGE == "de"
      ; Select [] brackets only
      ld a,%0001
.else
      ; Skip all brackets
      xor a
.endif
      ld (SKIP_BITMASK),a

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM ; changed address
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out text
    call _wait_vblank

  pop hl
  pop bc

  inc hl      ; next item
  djnz -

  ret
; ________________________________________________________

shop:
; We extend this to do all the box drawing
  ; First we want to decide how wide it is.
  ; It looks like this:
  ; ┌──────────────────╖
  ; │Item 1       Price║
  ; │Item 2       Price║
  ; │Item 3       Price║
  ; ╘══════════════════╝
  ; Item names are variable length. Price is up to four digits. Item count is 1-3.
  ; We want to make it have two spaces between the names and items so we don't
  ; have it super wide if not needed.
  ; First we need to look up the items for this shop.
  ; This is all copied from the original game:
  ld a,3 ; bank for table at $f717
  ld (PAGING_SLOT_2),a
  ld a,(RoomIndex)
  and $1F
  ; Multiply by 10
  ld l,a
  ld h,0
  add hl,hl
  ld c,l
  ld b,h
  add hl,hl
  add hl,hl
  add hl,bc
  ; Look up (1-based)
  ld bc,$b717 - 10 ; Shop items table at $f717
  add hl,bc
  ; First byte is menu size - 1
  ld a,(hl)
  ld (CursorMax),a
  inc hl
  push hl ; save this pointer for the end
    ; Next are tuples of (item ID, price). We want to find the longest named item.
    push af
    push hl
      inc a
      ld b,a
      ld c,0 ; longest length seen
      di
-:    ld a,3 ; shop data
      ld (PAGING_SLOT_2),a
      ld a,(hl) ; Get item ID
      ; Move to next item
      inc hl
      inc hl
      inc hl
      push hl
      push bc
        call _lookUpShopItem
        call _checkLength
      pop bc
      pop hl
      cp c
      ; If it carries then c is bigger
      jr c,+
      ld c,a
+:    ; check if we have run out of items
      djnz -
      ei
      ; So the max must be C. Let's save it to RAM.
      ld a,c
      add a,6 ; space for numbers
      ld (ShopInventoryWidth),a

      ; Now let's try to draw the top border.
      ; First we compute the VRAM address. This is $3800 + (32 - (width+2)) / 2 * 2
      sub 30
      neg
      and %11111110
      ld e,a
      ld d,0
      ld hl,$7800
      add hl,de
      ex de,hl
      rst $08 ; Set VRAM address
      ; Set de to the next row down
      ld hl,ONE_ROW
      add hl,de
      ex de,hl
      ; Save that as the cursor address
      ld (CursorTileMapAddress),de
      ; Draw top border
      ld a,(ShopInventoryWidth)
      ld c,a
      ld hl,BorderTop
      call _DrawBorder
      call _wait_vblank
    pop hl
    pop af
    ; Now hl points at the first item, a is the row count, de is the write address

    ld a,(CursorMax)
    inc a
    ld b,a ; Only show as many rows as needed
_itemsLoop:
    push bc
    push hl

      di
        ld a,3 ; Shop data bank
        ld (PAGING_SLOT_2),a
        ld a,(hl)   ; grab item #
        push af
          inc hl
          ; and price
          ld a,(hl)
          inc hl
          ld h,(hl)
          ld l,a
          ld (NumberToShowInText),hl
        pop af
        call _lookUpShopItem
      ei

      ; Print item text
      push de
        rst $08
        ld hl,BorderSides
        call _DrawOneTile
        inc de
        inc de
        ; Now for the item name
        ld hl,TEMP_STR
        ld a,(LEN)
        ld b,a
        push bc
          ld c,0 ; counter for chars written
-:        ld a,(hl)
          inc hl
          cp SymbolStart ; don't draw scripting codes
          jr nc,+
          call EmitCharacter
          inc c
          inc de
          inc de
+:        djnz -
          ld a,c ; written character count
        pop bc
        ; Write out blanks
        ld c,a
        ld a,(ShopInventoryWidth)
        sub c
        sub 5 ; for price
        jr z,+
        ld b,a ; we want this many blanks
-:      xor a ; space
        call EmitCharacter
        djnz -
+:
        ; Write out price
        call DrawNumberToTempStr
        ; We called the function used for numbers in the script.
        ; It has rendered the number to TEMP_STR, and also set some other script state that we don't care about.
        ld hl,TEMP_STR
        ld b,5 ; digits
-:      ld a,(hl)
        inc hl
        call EmitCharacter
        djnz -

        ; Write out right border
        ld hl,BorderSides+2
        call _DrawOneTile
      pop de
      call _wait_vblank
      ; Next row
      ld hl,ONE_ROW
      add hl,de
      ex de,hl
      rst $08
    pop hl      ; restore counter, data pointer
    pop bc

    inc hl      ; next item
    inc hl
    inc hl
    djnz _itemsLoop
    ; Clear LEN to stop the item name being drawn later
    xor a
    ld (LEN),a

    ; Bottom border
    ld a,(ShopInventoryWidth)
    ld c,a
    ld hl,BorderBottom
    call _DrawBorder
    call _wait_vblank

    call WaitForMenuSelection
  pop hl
  ; Point hl to the shop table entry selected
  ; compute hl = hl + a * 3 = pointer to data for the selected item
  ld b,a
  add a,a
  add a,b
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,3
  ld (PAGING_SLOT_2),a
  ret

_lookUpShopItem:
  ld hl,Items
  push af
.if LANGUAGE == "de"
    ; Select [] brackets only
    ld a,%0001
.else
    ; Skip all brackets
    xor a
.endif
    ld (SKIP_BITMASK),a
  pop af
  push de
    call DictionaryLookup ; puts length in LEN
  pop de
  ret

_checkLength:
  ; When we do an item name lookup, the length includes control characters.
  ; We count the printable ones.
  ld a,(LEN)
  ld hl,TEMP_STR
  ld b,a
  ld c,0
-:ld a,(hl)
  inc hl
  cp SymbolStart
  jr nc,+
  inc c
+:djnz -
  ; now c is the real name length
  ld a,c
  ret


enemy:
  ; Enemy name window drawing
  ; Get enemy name to TEMP_STR
  di
    ld a,:Enemies
    ld (PAGING_SLOT_2),a

.if LANGUAGE == "de"
    ; Select [] brackets only
    ld a,%0001
.else
    ; Skip all brackets
    xor a
.endif
    ld (SKIP_BITMASK),a

    ld a,(EnemyIndex)
    ld hl,Enemies   ; table start

    push de
      call DictionaryLookup    ; copy string to RAM
    pop de
  ei

  ; compute the name length
  call _checkLength

  ; Compute the VRAM address
  ld hl,$7840 - 4 ; right-aligned, minus space for borders
  add a,a
  neg
  ld e,a
  ld d,-1
  add hl,de
  ex de,hl

  call _wait_vblank
  push de
    ; Set VRAM address
    rst $08
    ; Draw top border
    ld hl,BorderTop
    call _DrawBorder
  pop de
  ; Next row
  ld hl,ONE_ROW
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
      cp SymbolStart ; don't draw scripting codes
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
  out (PORT_VDP_DATA),a ; 11
  inc hl                ; 6
  ld a,(hl)             ; 7
  nop                   ; 4 -> total 28 cycles
  out (PORT_VDP_DATA),a
  inc hl
  ret

; Tilemap words for the borders
BorderTop:
.stringmap tilemap "┌─╖"
BorderSides:
.stringmap tilemap "│║"
BorderBottom:
.stringmap tilemap "╘═╝"

equipment:
  ld b,3    ; 3 items total

-:push bc
  push hl

    di
      ld a,:Items    ; data bank
      ld (PAGING_SLOT_2),a

.if LANGUAGE == "de"
      ; Select [] brackets only
      ld a,%0001
.else
      ; Skip all brackets
      xor a
.endif
      ld (SKIP_BITMASK),a

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

.define ITEM_NAME_WIDTH InventoryMenuDimensions_width-2 ; when drawn in menus

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
      ld a,c      ; check for end of string
      or a
      jr z,_blank_line

_read_byte:
      ld a,(hl)   ; read character
      inc hl      ; bump pointer
      dec c     ; shrink length

      cp SymbolStart      ; normal text is before this
      jr c,_bump_text

_space:
      jr nz,_check_length
      ; else fall through

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
      ld (VRAM_PTR),hl

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

  TrampolineTo inventory $3671 $3680
  TrampolineTo enemy $326d $3294
  TrampolineTo equipment $3850 $385f
  ; Shop trampoline is now done manually

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
; $de64 |               | +---------------+                   +---------------+
; $de80 +---------------+ | Yes/No        |
;                         | (5x4)         |
; $de96                   +---------------+
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
; 9. Shop with new equip option
; * Narrative
;   * Shop inventory
;   * Current money
;     * Player select
;       * Currently equipped items

; My layout

; $d700 +---------------+ // We assume these first three are always needed (nearly true)
;       | Party stats   |
; $d880 +---------------+ +---------------+
;       | Narrative box | | Character     |
;       |               | | stats         |
; $d9c4 |               | +---------------+
; $d9f4 +---------------+
;       | Narrative     |
;       | scroll buffer |
; $daae +---------------+                   +---------------+                  
;       | Regular menu  |                   | Battle menu   |                  
;       |           (W) |                   |           (B) |                  
; $db1e +---------------+ +---------------+ +---------------+                   +---------------+
;       | Currently     | | Hapsby travel | | Enemy name    |                   | Select        |
;       | equipped      | | (8x7)     (W) | | (21x3)    (B) |                   | save slot     |
; $db6e | items         | +---------------+ |               |                   | (22x9)    (W) |
; $db76 | (16x8)    (W) |                   |               |                   |               |
; $db9c |               |                   +---------------+                   |               |
; $dbe6 +---------------+ +---------------+ | Enemy stats   |                   |               |
; $dbee | Player select | | Buy/Sell      | | (8x10)    (B) |                   |               |
;       | (8x9) (B,W)   | | (6x4)     (S) | |               |                   |               |
; $dc1e |               | +- - - - - - - -+ |               |                   |               |
;       |               | | (fr:9x4)      | |               |                   |               |
; $dc2e |               | +---------------+ |               |                   |               |
; $dc3a +---------------+                   |               | +---------------+ |               |
; $dc3c +---------------+ +---------------+ +---------------+ | MST in shop   | |               |
; $dc4e | Inventory     | | Spells        |                   | and hospital  | |               |
;       | (16x21) (B,W) | | (12x12) (B,W) |                   | (16x3)    (S) | |               |
; $dca6 |               | |               |                   +---------------+ |               |
; $dcaa |               | |               |                   | Shop items    | +---------------+
; $dd00 |               | +- - - - - - - -+                   | (max 32x5)    |
;       |               | | (fr: 16x12)   |                   |           (S) |
; $dd38 |               | +---------------+                   |               |
; $dde6 |               |                                     +---------------+
; $de1c +---------------+ +---------------+ +---------------+
;       | Use/Equip/Drop| | Yes/No        | | Active player |
;       | (7x5)     (W) | | (5x5)         | | (during       |
; $de44 |               | +---------------+ | battle)   (B) |
; $de46 |               |                   +---------------+
; $de62 +- - - - - - - -+                   | Player select | 
;       | (fr:10x5)     |                   | (magic) (8x9) |
; $de80 +---------------+                   |         (B,W) |
; $de9a                                     +---------------+

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
.endm

;              Name             RAM location          W                             H                               X                                     Y
  DefineWindow PARTYSTATS       $d700                 32                            6                               0                                     18
  DefineWindow NARRATIVE        PARTYSTATS_end        NarrativeBox_width            NarrativeBox_height             1                                     18
  DefineWindow NARRATIVE_SCROLL NARRATIVE_end         31                            3                               2                                     19
  DefineWindow CHARACTERSTATS   NARRATIVE             StatsMenuDimensions_width     StatsMenuDimensions_height      31-StatsMenuDimensions_width          4
  DefineWindow MENU             NARRATIVE_SCROLL_end  WorldMenu_width               WorldMenu_height                1                                     1
  DefineWindow CURRENT_ITEMS    MENU_end              InventoryMenuDimensions_width 5                               31-InventoryMenuDimensions_width      13
  DefineWindow PLAYER_SELECT    CURRENT_ITEMS_end     ChoosePlayerMenu_width        ChoosePlayerMenu_height         1                                     8
  DefineWindow ENEMY_NAME       MENU_end              21                            3                               11                                    0 ; max width 19 chars
  DefineWindow ENEMY_STATS      ENEMY_NAME_end        8                             10                              24                                    3
; Inventory goes after the end of whichever of these is later
.ifdef WLA_DX_BUG_WORKAROUND
; The conditional does not work in makefile generation mode; we use the real logic in real compilation mode
.define INVENTORY_START ENEMY_STATS_end
.else
.if ENEMY_STATS_end > PLAYER_SELECT_end
.define INVENTORY_START ENEMY_STATS_end
.else
.define INVENTORY_START PLAYER_SELECT_end
.endif
.endif
  DefineWindow INVENTORY        INVENTORY_START       InventoryMenuDimensions_width InventoryMenuDimensions_height  31-InventoryMenuDimensions_width      1
  DefineWindow USEEQUIPDROP     INVENTORY_end         ItemActionMenu_width          ItemActionMenu_height           31-ItemActionMenu_width               13
  DefineWindow HAPSBY           MENU_end              8                             5                               21                                    13
  DefineWindow BUYSELL          CURRENT_ITEMS_end     ToolShopMenu_width            ToolShopMenu_height             29-ToolShopMenu_width                 14
  DefineWindow SPELLS           INVENTORY             SpellMenuBottom_width         7                               WorldMenu_width+1                     1 ; Spells and inventory are mutually exclusive
  DefineWindow PLAYER_SELECT_2  ACTIVE_PLAYER_end     ChoosePlayerMenu_width        ChoosePlayerMenu_height         9                                     8
  DefineWindow YESNO            USEEQUIPDROP          ChoiceMenu_width              ChoiceMenu_height               29-ChoiceMenu_width                   14
  DefineWindow ACTIVE_PLAYER    INVENTORY_end         AlisaActiveBox_width          3                               1                                     8
  DefineWindow SHOP             SHOP_MST_end          32                            5                               0                                     0 ; shop inventory width is dynamic, up to 32
  DefineWindow SHOP_MST         PLAYER_SELECT_end     StatsMenuDimensions_width     3                               3                                     15 ; same width as stats menu
  DefineWindow SAVE             MENU_end              SAVE_NAME_WIDTH+4             SAVE_SLOT_COUNT+2               27-SAVE_NAME_WIDTH                    1
  DefineWindow SoundTestWindow  $d700                 SoundTestMenu_width           SoundTestMenu_height+2          31-SoundTestMenu_width                0
  DefineWindow OptionsWindow    $d700                 OptionsMenu_width             OptionsMenu_height              32-OptionsMenu_width                  24-OptionsMenu_height
  DefineWindow ContinueWindow   $d700                 ContinueMenu_width            ContinueMenu_height             18                                    16

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

.define NARRATIVE_WIDTH 29 ; text character width
  PatchB $3364 NARRATIVE_WIDTH ; Width counter
  PatchWords NARRATIVE              $334d $3587 ; Narrative box
  PatchWords NARRATIVE_SCROLL       $3554 $3560 ; Narrative box scroll buffer
  PatchWords NARRATIVE_VRAM         $3350 $3386 $358a
  PatchWords NARRATIVE_SCROLL_VRAM  $3360 $3563
  PatchW $3557 NARRATIVE_SCROLL_VRAM + ONE_ROW
  PatchB $34c9 ONE_ROW ; cutscene text display: increment VRAM pointer by $0040 (not $0080) for newlines

  PatchWords MENU                   $322c $324a ; Battle menu
  PatchWords MENU                   $37fb $3819 ; Regular world menu

  PatchWords SHOP                   $39eb,$3ac4
  PatchWords SHOP_VRAM              $39ee,$3ac7
  PatchWords SHOP_dims              $39f1,$3aca

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
  PatchWords SHOP_MST_VRAM          $3b18 $3b41
  PatchWords SHOP_MST_dims          $3b1b $3b44

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
  PatchWords SPELLS_VRAM            $3598 $35e7
  PatchW $1ee1 SPELLS_VRAM + ONE_ROW
  PatchW $1b6a SPELLS_VRAM + ONE_ROW

  PatchWords PLAYER_SELECT          $3788 $37de ; Player select
  ; a = player count, but we want n+1 rows of data for n players
  PatchB $37c5 $3c ; inc a
  PatchB $37c8 ChoosePlayerMenu_width*2 ; width*2
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
.define NAME_TILEMAP_POS $4000 + $3800 + (NAME_TILEMAP_Y * 32 + NAME_TILEMAP_X) * 2

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
  ld hl,$d000 + (3 * 32 + 2) * 2
  ld de,$d000 + (3 * 32 + 2) * 2 + 2
  ld bc,54
  ldir
  ; Bottom
  ld hl,$d000 + (23 * 32 + 2) * 2
  ld de,$d000 + (23 * 32 + 2) * 2 + 2
  ld bc,54
  ldir
  ; Left
  ld hl,$d000 + (4 * 32 + 1) * 2
  ld de,$11f3 ; left edge tile
  call _side
  ld hl,$d000 + (4 * 32 + 30) * 2
  ld de,$13f3 ; left edge tile
  call _side

  ; Select the right palette
  ld hl,TitleScreenPalette
  ld de,$c240 ; TargetPalette
  ld bc,32
  ldir

  di
    ; Draw the tilemap to VRAM
    ld hl,$d000
    ld de,$7800
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
.dw $d000 + (y * 32 + x) * 2 ; destination
.db _NameEntryText\@end - CADDR - 1
.stringmap tilemap text
_NameEntryText\@end:
.endm

.macro NameEntryMask args x,y,count,text
.dw $d000 + (y * 32 + x) * 2 ; destination
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
.db 12
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


; Changed credits -------------------------
; Point to maybe relocated data
  PatchB $70b4 :CreditsData
  PatchW $70ba CreditsData-4
; Code treats values >64 as
.slot 2
.section "Credits" superfree
CreditsData:
.dw CreditsScreen1, CreditsScreen2, CreditsScreen3, CreditsScreen4, CreditsScreen5, CreditsScreen6, CreditsScreen7, CreditsScreen8, CreditsScreen9, CreditsScreen10, CreditsScreen11, CreditsScreen12, CreditsScreen13, CreditsScreen14

.stringmaptable credits "credits.tbl"

.macro CreditsEntry args x, y, text
.dw $d000 + ((y * 32) + x) * 2
.db _credits_\@_end - _credits_\@
_credits_\@:
.stringmap credits text
_credits_\@_end:
.endm

.if LANGUAGE == "en" || LANGUAGE == "literal"
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
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "fr"
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
  CreditsEntry 10,10,"RETRADUCTION"
CreditsScreen12: .db 8
  CreditsEntry 3,6,"ANGLAIS"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 3,15,"FRANCAIS"
  CreditsEntry 18,14,"ICHIGOBANKAI"
  CreditsEntry 20,15,"WIL76"
  CreditsEntry 18,16,"VINGAZOLE"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "pt-br"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 13,10,"EQUIPE"
CreditsScreen2: .db 3
  CreditsEntry 3,5,"PLANEJAMENTO"
  CreditsEntry 6,7,"TOTAL"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 5
  CreditsEntry 6,6,"CENARISTA"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 11,14,   "/"
  CreditsEntry 7,15,"HISTORIA"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 6
  CreditsEntry 4,6,"AUXILIAR DE"
  CreditsEntry 26,5,         "~"
  CreditsEntry 17,6,"COORDENACAO"
  CreditsEntry 25,7,        "'"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 5
  CreditsEntry 3,6,"DESIGN TOTAL"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"DESIGN DE"
  CreditsEntry 7,16,"MONSTRO"
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
  CreditsEntry 11,6,"SOM"
  CreditsEntry 18,6,"BO"
  CreditsEntry 9,15,"TESTE"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 7
  CreditsEntry 4,6,"AUXILIAR DE"
  CreditsEntry 26,5,         "~"
  CreditsEntry 17,6,"PROGRAMACAO"
  CreditsEntry 25,7,        "'"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 3
  CreditsEntry 6,5,"PROGRAMA"
  CreditsEntry 5,7,"PRINCIPAL"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 3
  CreditsEntry 19,9,         "~"
  CreditsEntry 11,10,"RETRADUCAO"
  CreditsEntry 18,11,       "'"
CreditsScreen12: .db 9
  CreditsEntry 7,5,    "^"
  CreditsEntry 3,6,"INGLES"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 10,14,      "^"
  CreditsEntry 3,15,"PORTUGUES"
  CreditsEntry 3,16,"DO BRASIL"
  CreditsEntry 18,15,"AJKMETIUK"
CreditsScreen13: .db 4
  CreditsEntry 7,5, "/"
  CreditsEntry 6,6,"CODIGO"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 4
  CreditsEntry 11,10,"APRESENTADO"
  CreditsEntry 14,11,"PELA"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "ca"
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
  CreditsEntry 10,10,"RETRADUCTION"
CreditsScreen12: .db 8
  CreditsEntry 7,5,    "/"
  CreditsEntry 3,6,"ANGLES"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 8,14,     "`"
  CreditsEntry 3,15,"CATALA"
  CreditsEntry 18,15,"KUSFO"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "es"
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
  CreditsEntry 10,10,"RETRADUCTION"
CreditsScreen12: .db 8
  CreditsEntry 7,5,    "/"
  CreditsEntry 3,6,"INGLES"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 8,14,     "`"
  CreditsEntry 3,15,"CASTELLANO"
  CreditsEntry 18,15,"KUSFO"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "de"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 10,10,"MITWIRKENDE"
CreditsScreen2: .db 3
  CreditsEntry 4,5,"KOMPLETTE"
  CreditsEntry 8,7,"PLANUNG"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 4
  CreditsEntry 4,6,"SZENARIO"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 4,15,"HANDLUNG"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 4
  CreditsEntry 1,5,"KOORDINATIONS-"
  CreditsEntry 6,7,"ASSISTENZ"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 6
  CreditsEntry 3,5,"KOMPLETTES"
  CreditsEntry 8,7,"DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"MONSTER-"
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
CreditsScreen8: .db 7
  CreditsEntry 10,6,"TON"
  CreditsEntry 18,6,"BO"
  CreditsEntry 4,14,"SOFTWARE-"
  CreditsEntry 3,15,"¨"
  CreditsEntry 9,15,      "¨"
  CreditsEntry 3,16,"UBERPRUFUNG"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 5
  CreditsEntry 3,5,"PROGRAMMIER-"
  CreditsEntry 4,7,"ASSISTENZ"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 3
  CreditsEntry 4,5,"HAUPT-"
  CreditsEntry 2,7,"PROGRAMMIERER"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 6
  CreditsEntry 2,5,"ENGLISCHE"
  CreditsEntry 4,6,   "¨"
  CreditsEntry 1,7,"NEUUBERSETZUNG"
  CreditsEntry 10,10,"PAUL JENSEN"
  CreditsEntry 2,15,"FRANK CIFALDI"
  CreditsEntry 21,15,"SATSU"
CreditsScreen12: .db 4
  CreditsEntry 2,5,"DEUTSCHE"
  CreditsEntry 4,6,"¨"
  CreditsEntry 4,7,"UBERSETZUNG"
  CreditsEntry 19,6,"POPFAN"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 5
  CreditsEntry 12,9,   "¨"
  CreditsEntry 10,10,"PRASENTIERT"
  CreditsEntry 14,12,"VON"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
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
.incbin "generated/font-credits.psgcompr"
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

; Title screen menu extension
  ROMPosition $073f
.section "Title screen extension part 1" force
;    TileMapAddressHL 9,16
;    ld (CursorTileMapAddress),hl
;    ld     a,$01           ; 000745 3E 01
;    ld     (CursorMax),a       ; 000747 32 6E C2
;    call   WaitForMenuSelection           ; 00074A CD B9 2E
;    or     a               ; 00074D B7
;    jp     nz,$079e        ; 00074E C2 9E 07
.define TitleScreenCursorBase $3800+(15*32+9)*2+$4000
  ld hl,TitleScreenCursorBase
  ld (CursorTileMapAddress),hl
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
  ld de,OptionsWindow_VRAM + ONE_ROW * 1 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(MovementSpeedUp)
  inc a
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 2 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(ExpMultiplier)
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 3 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(MoneyMultiplier)
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 4 + 2 * OptionsMenu_width  - _sizeof__BattlesAll - 2
  rst $8
  ld a,(FewerBattles)
  or a
  ld hl,_BattlesAll
  jr z,+
  ld hl,_BattlesHalf
+:ld b,_sizeof__BattlesAll
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 5 + 2 * OptionsMenu_width - _sizeof__Black - 2
  rst $8
  ld a,(BrunetteAlisa)
  or a
  ld hl,_Black
  jr z,+
  ld hl,_Brown
+:ld b,_sizeof__Black
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 6 + 2 * (OptionsMenu_width - 8)
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
  ld de,TitleScreenCursorBase + ONE_ROW * 3
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
  ld de,TitleScreenCursorBase + ONE_ROW * 3
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

.if LANGUAGE == "en" || LANGUAGE == "literal"
_BattlesAll:  .stringmap tilemap " All"
_BattlesHalf: .stringmap tilemap "Half"
_Brown: .stringmap tilemap "Brown"
_Black: .stringmap tilemap "Black"
_Font1: .stringmap tilemap "Polaris"
_Font2: .stringmap tilemap " AW2284"
.endif
.if LANGUAGE == "fr"
_BattlesAll:  .stringmap tilemap "Tout"
_BattlesHalf: .stringmap tilemap "Demi"
_Brown: .stringmap tilemap "Bruns"
_Black: .stringmap tilemap "Noirs"
_Font1: .stringmap tilemap "Polaris"
_Font2: .stringmap tilemap " AW2284"
.endif
.if LANGUAGE == "pt-br"
_BattlesAll:  .stringmap tilemap "    Todas"
_BattlesHalf: .stringmap tilemap "Reduzidas"
_Brown: .stringmap tilemap "Castanho"
_Black: .stringmap tilemap "   Preto"
_Font1: .stringmap tilemap "Polaris"
_Font2: .stringmap tilemap " AW2284"
.endif
.if LANGUAGE == "ca"
_BattlesAll:  .stringmap tilemap " Totes"
_BattlesHalf: .stringmap tilemap "Meitat"
_Brown: .stringmap tilemap "Marró"
_Black: .stringmap tilemap "Negre"
_Font1: .stringmap tilemap "Polaris"
_Font2: .stringmap tilemap " DG2284"
.endif
.if LANGUAGE == "es"
_BattlesAll:  .stringmap tilemap " Todas"
_BattlesHalf: .stringmap tilemap " Mitad"
_Brown: .stringmap tilemap "Marrón"
_Black: .stringmap tilemap " Negro"
_Font1: .stringmap tilemap "Polaris"
_Font2: .stringmap tilemap " DG2284"
.endif
.if LANGUAGE == "de"
_BattlesAll:  .stringmap tilemap "Voll"
_BattlesHalf: .stringmap tilemap "Halb"
_Brown: .stringmap tilemap "  Braun"
_Black: .stringmap tilemap "Schwarz"
_Font1: .stringmap tilemap "Polaris"
_Font2: .stringmap tilemap " AW2284"
.endif

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
  ld de,TitleScreenCursorBase + ONE_ROW * 1
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
    ; check for button 1 or 2
    bit 4,c
    jr nz,_button1 ; cancel on 1 regardless of selection
    call IsSlotUsed
    jr z,- ; repeat selection until a valid one is chosen
  pop af


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

_button1:
  pop af
  jr _closeSaveGameWindow

SoundTest:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)

  ld hl,SoundTestWindow
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestWindow_dims
  call InputTilemapRect

  ld hl,SoundTestMenuTop
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestMenuTop_dims ; (1<<8)|(15*2) ; top border
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
  ld de,TitleScreenCursorBase + ONE_ROW * 2
  jp BackToTitle

+:ld a,b

  or a
  jr nz,+
  ; Toggle FM - if allowed
  ld a,(HasFM)
  or a
  jr z,-
  ; Enable the right chip
  ld a,(Port3EValue)
  or $04 ; Disable IO chip
  out (PORT_MEMORY_CONTROL),a
  ld a,(UseFM)
  xor 1 ; happens to be the right value for the port this way
  ld (UseFM),a
  out (PORT_FM_CONTROL),a
  ld a,(Port3EValue)
  out (PORT_MEMORY_CONTROL),a  ; Turn IO chip back on
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
  ld bc,SoundTestMenuChipPSG_dims ; (1<<8)|(15*2) ; one row
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
  ; We first check if SRAM is working
  ld hl,$8000 ; SRAM marker
  ld de,$0962 ; Expected value
  ld bc,$0040 ; length
  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a
-:ld a,(de)
  inc de
  cpi
  jr nz,+ ; Skip copying if SRAM is bad
  jp pe,- ; parity odd indicates underflow of bc

  ld hl,$8210
  ld de,SettingsStart
  call CopySettings

  ; If they are not valid, we need to initialise the multipliers
  ld a,(ExpMultiplier)
  or a
  ret nz
+:
  ld a,1
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
    call OutputTilemapBoxWipePaging
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
.incbin "generated/alisa-sprite.bin"
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


; There is a bug in the Japanese ROM that makes Myau have a low attack stat at level 30.
; This "fix" makes it match the export version, with a sensible value.
  PatchB $fa88 $56

; There is another bug that causes the tool shop to lose some state regarding the script window, when showing the buy/sell window. We patch it here.
  ROMPosition $2dfa
.section "Shop bug fix" overwrite size 12
; Original code:
;    ld     hl,$b1c5        ; 002DF4 21 C5 B1 ; Welcome to the tool shop. May I help you?<end>
;    call TextBox20x6       ; 002DF7 CD 3A 33 ; State in BC for text window
;    call   $3894           ; 002DFA CD 94 38 ; Show Buy or Sell window; returns in  A, C
;    push   af              ; 002DFD F5
;    push   bc              ; 002DFE C5
;      call   $38b4           ; 002DFF CD B4 38 ; restore tilemap
;    pop    bc              ; 002E02 C1
;    pop    af              ; 002E03 F1
;    bit    4,c             ; 002E04 CB 61
; Following code assumes C is still valid
; We can fit a fix into the existing space by moving the BC push/pop around.
  push bc
    call $3894 ; Show Buy or Sell window; returns in A, C
    bit 4,c ; check for button 1
    push af
      call $38b4 ; restore tilemap
    pop af
  pop bc
.ends

; The same bug happens when picking from the inventory when selling.
  ROMPosition $2e13
.section "Shop bug fix 2" overwrite size 5
; Original code:
;    ld     hl,$b1e0        ; 002E0D 21 E0 B1 ; What do you have?
;    call TextBox20x6       ; 002E10 CD 3A 33 ; State in BC for text window
;    call   $35ef           ; 002E13 CD EF 35 ; Inventory select, returns in A, C
;    bit    4,c             ; 002E16 CB 61    ; Button 1 -> nz
; Following code assumes BC is still valid
; We can't fit this one into the original space...
  push bc
    call ShopSellInventoryFixHelper
  pop bc
.ends

.section "Shop bug fix part 2" free
ShopSellInventoryFixHelper:
  call $35ef ; inventory select
  bit 4,c
  ret
.ends

; And when selecting an item to drop from your inventory, when getting an item. This seems to always come when the box is already full, so we don't bother fixing that one.

; We get the same issue in the hospital.
  ROMPosition $2aff
.section "Hospital bug fix" overwrite size 5
; Original code:
;    ld     hl,$b25c                ; 002AF9 21 5C B2 ; Who will receive treatment?
;    call   nz,TextBox20x6          ; 002AFC C4 3A 33
;    call   ShowCharacterSelectMenu ; 002AFF CD 82 37 ; Returns in A, C
;    bit    4,c                     ; 002B02 CB 61
;    jp     nz,$2bae                ; 002B04 C2 AE 2B
; Following code assumes BC is still valid
  push bc
    call HospitalAndChurchFixHelper
  pop bc
.ends

.section "Hospital bug fix part 2" free
HospitalAndChurchFixHelper:
  call $3782 ; character select
  bit 4,c
  ret
.ends

; And in the church.
  ROMPosition $2c01
.section "Church bug fix" overwrite size 5
; Original code:
;    ld     hl,$b31e                ; 002BFB 21 1E B3 ; Who shall be returned?<end>
;    call   TextBox20x6             ; 002BFE CD 3A 33
;    call   ShowCharacterSelectMenu ; 002C01 CD 82 37 ; CharacterSelect
;    bit    4,c                     ; 002C04 CB 61    ; Returns in A, C
;    jp     nz,$2c9f                ; 002C06 C2 9F 2C
; Following code assumes BC is still valid
  push bc
    call HospitalAndChurchFixHelper
  pop bc
.ends

; And when saving a game...
  ROMPosition $1e41
.section "Save game bug fix" overwrite size 3
; Original code:
;    ld     hl,$b39f        ; 001E3B 21 9F B3
;    call   TextBox20x6     ; 001E3E CD 3A 33
;    call   $3acf           ; 001E41 CD CF 3A
; Following code assumes BC is still valid
  call SaveFixHelper
.ends

.section "Save game bug fix part 2" free
SaveFixHelper:
  push bc
    call $3acf ; save slot select
  pop bc
  ret
.ends


; Now we hack the shop to offer to equip items when you buy them.
  ROMPosition $2d7b
.section "Shop equip mod" overwrite size 3
; Original code:
;  call $28fb           ; 002D7B CD FB 28 ; AddItemToInventory
  call ShopEquipMod
.ends

.section "Shop equip mode part 2" free
ShopEquipMod:
  call $28fb ; AddItemToInventory
  ; This leaves hl pointing to the newly-added item. We need this later...
  ld ($c29b),hl ; The game saves the pointer here
  
  ; The original item equip code is at $2824. However we can't use it because it breaks our script state. So we copy/paste/enhance...
  

  ; Check if the item is equippable
  ld hl,PAGING_SLOT_2
  ld (hl),:ItemMetaData
  ld a,(ItemTableIndex)
  ld hl,ItemMetaData
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,(hl) ; hl = bfa9
  ; Get upper nybble into d = equippability bits per character
  rrca            
  rrca            
  rrca            
  rrca            
  and $0f         
  ; Zero means not equippable
  ret z
  
  ld d,a ; backup equippability bitmask

  ; Check if any alive characters can equip it
  push bc
    ld b,0 ; character index
    ld c,d
-:  ld a,b
    cp 4 ; valid range is 0..3
    jr z,_noMatches
    ; check equippable bit
    srl c
    jr nc,_invalid
    ; bit was 1, is character alive?
    call $19ea
    jr z,_invalid
    ; Character is alive
    jr + ; continue on then

_invalid:
    inc b ; try next character
    jr -
    
_noMatches:
  pop bc
  ret
    
+:pop bc

  push de     
  push hl
    ld hl,ScriptDoYouWantToEquip
    call TextBox
    ; Save BC so we can get at it below outside a push/pop safe place
    ld (ScriptBCStateBackup),bc
    call DoYesNoMenu
  pop hl
  pop de
  ret nz ; = chose "no"
  
_selectWho:
  push de     
  push hl     
    call $3782 ; show character select
  pop hl      
  pop de      
  
  bit 4,c ; cancel
  jp nz,_done

  call $19ea ; check character is alive
  jp z,_done

  ld (NameIndex),a
  ld c,a
  inc a ; range 1..4
  ld b,a
  ld a,d ; rotate upper nibble right by character number
-:rrca
  djnz -
  jp nc,_cantEquip ; if carry then bit was set -> can equip

  ; point to correct place in character stats
  ld a,c             
  add a,a            
  add a,a            
  add a,a            
  add a,a ; *16 to point to correct character stats
  ld de,$c40a ; Alisa weapon
  add a,e ; point to correct character
  ld e,a 
  adc a,d
  sub e  
  ld d,a 

  ; read metadata again
  ld a,:ItemMetaData
  ld (PAGING_SLOT_2),a
  ld a,(hl)
  ; low 2 bits are item type (0 = weapon, 1 = armour, 2 = shield)
  and %00000011
  add a,e
  ld e,a 
  ; read current equipped item
  ld a,(de)
  ld hl,($c29b) ; Read a pointer?
  ld (hl),a ; Replace item in inventory with de-equipped item
  push af
    ld a,(ItemTableIndex)
    ld (de),a
    ld hl,ScriptPlayerEquippedItem
    ld bc,(ScriptBCStateBackup)
    call TextBox
    ld (ScriptBCStateBackup),bc
    ld a,(NameIndex)       
    call $3824 ; Show player equpped items window
    call MenuWaitForButton           
    call $386a ; Hide it again
  pop af
  or a
  call z, $28d8 ; RemoveSelectedItemfromInventory ; because we swapped something for nothing

_done:
  call $1916 ; CharacterStatsUpdate
  ld bc,(ScriptBCStateBackup)
  jp $37d8 ; Close player select and return

_cantEquip:  
  ld hl,ScriptPlayerCantEquipItem
  ld bc,(ScriptBCStateBackup)
  call TextBox
  ld (ScriptBCStateBackup),bc
  call $37d8 ; Close player select
  jr _selectWho ; try again!

.ends
