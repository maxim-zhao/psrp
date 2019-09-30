; This unifies all the work donw for the PS1JERT into a single WLA DX files,
; using WLA DX to do the assembly and insertion of code and data.
; We use WLA DX features (and macrros) to implement some of the data transformation.

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

; Macros

; Wrapper around .unbackground to clear what's used vs. what's unused. The former is
; needed to stay byte-identical to 1.02, but the latter is "better" when we come to extens
; past that.
.macro FreeSpace args _start, _end, _realEnd
; Change to realEnd when auto-fitting (need to debug that?)
.unbackground _start _realEnd
.endm

; Some data is relocated unmodified from the original ROM; this
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

; Creates a section with the given name holding the given binary file.
; Uses the current address.
.macro Bin
.section "\1" free
\1:
.incbin \2
\1_end:
.ends
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
  .redefine _out $11f3 ; hflipped for left bar
.else
.if \1 == ':'
  .redefine _out $11f4 ; hflipped?
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
.macro "LoadPagedTiles" args address, dest
LoadPagedTiles\1:
  ; Common pattern used to load tiles in the original code
  ld hl,PAGING_SLOT_2
  ld (hl),:address
  ld hl,dest
  ld de,address
  call LoadTiles
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
map "-" = $46
map "!" = $47
map "?" = $48
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

.emptyfill $ff

; Bank 0
  FreeSpace $0000f $00037 $00037 ; Unused space
  FreeSpace $00056 $00065 $00065 ; ExecuteFunctionIndexAInNextVBlank followed by unused space
  FreeSpace $00486 $004ae $004b2 ; Old tile decoder
  FreeSpace $008f3 $0090b $0090b ; Title screen graphics loading
  FreeSpace $00925 $00932 $00944 ; Title screen palette - can go up to 944
  FreeSpace $033da $033eb $033f3 ; Draw item name
  FreeSpace $033aa $033b7 $033c3 ; Draw character name
  FreeSpace $033c8 $033d3 $033d5 ; Draw enemy name
  FreeSpace $033f6 $03466 $03493 ; Draw number
  FreeSpace $03494 $0349d $034a4 ; Draw characters from buffer
  FreeSpace $034f2 $03537 $03545 ; Draw one character to tilemap
  FreeSpace $03982 $039dd $039dd ; Stats menu tilemap data
  FreeSpace $03eca $03f6e $03fc1 ; background graphics lookup table
; Bank 1
  FreeSpace $04059 $04078 $0407a ; password entered (unused)
  FreeSpace $0429b $042b2 $042b4 ; draw to tilemap during entry
  FreeSpace $042b5 $042c5 $042cb ; draw to RAM during entry
  FreeSpace $04261 $04277 $04277 ; password population (unused)
  FreeSpace $04396 $043e5 $043e5 ; password lookup data (unused)
  FreeSpace $043e6 $04405 $04405 ; text for "please enter your name"
  FreeSpace $04406 $0448b $0448b ; tilemap for name entry
  FreeSpace $0448c $044f5 $04509 ; data for lookup table during entry - can go up to $4509
  FreeSpace $045a4 $045c3 $045c3 ; tile loading for intro
  FreeSpace $059ba $059c5 $059c9 ; Draw text box 20x6 (dialogue)
  FreeSpace $07fe5 $07fff $07fff ; Unused space + header
; Bank 2
  FreeSpace $08000 $080b1 $080b1 ; font tile lookup
  FreeSpace $080b2 $0bd93 $0bd93 ; script
  FreeSpace $0bd94 $0bdd1 $0bf9b ; item names
  FreeSpace $0bed0 $0bf35 $0bf9b ; item names - now SFG decoder TODO check for use of space in between
  FreeSpace $0bf50 $0bf99 $0bf9b ; item names - now Huffman decoder init
; Bank 9
  FreeSpace $27b24 $27e75 $27fff ; Mansion tiles + unused space
; Bank 11
  FreeSpace $2c010 $2c85a $2caeb ; Gold Dragon tiles
  FreeSpace $2fe3e $2ffff $2ffff ; Unused space
; Bank 14
  FreeSpace $3BC68 $3bfff $3bfff ; Title screen tilemap + unused space
; Bank 15
  FreeSpace $3fdee $3ffff $3ffff ; Credits font
; Bank 16
  FreeSpace $40000 $4277a $428f5 ; Scene tiles and palettes (part 1)
  FreeSpace $43406 $43a82 $43fff ; Scene tiles and palettes (part 2)
  FreeSpace $43bb4 $43ee3 $43fff ; see above
; Bank 17
  FreeSpace $44640 $47aaa $47fff ; Palettes and tiles
; Bank 18
  FreeSpace $4be84 $4bfff $4bfff ; Unused space
; Bank 19
  FreeSpace $4c010 $4ccfb $4cdbd ; Dark Force tiles
; Bank 20
  FreeSpace $524ea $52a66 $52ba1 ; Lassic room tiles
  FreeSpace $53dbc $53fff $53fff ; Credits data, unused space
; Bank 22
  FreeSpace $58570 $5a6db $5ac8c ; Tiles for town
  FreeSpace $5aadc $5ac1d $5ac8c ; ...
  FreeSpace $5ac8d $5b78c $5b9e6 ; Tiles for air castle
; Bank 23
  FreeSpace $5eb6f $5f5ba $5f766 ; Building interior tiles
; Bank 29
  FreeSpace $747b8 $77294 $77629 ; landscapes (world 1)
; Bank 31
  FreeSpace $7e8bd $7fd47 $7ffff ; Title screen tiles
  FreeSpace $7fe00 $7fe91 $7ffff ; ...
  FreeSpace $7fed0 $7ff9d $7ffff ; ...

.define PAGING_SLOT_1 $fffe
.define PAGING_SLOT_2 $ffff
.define PORT_VDP_DATA $be

; RAM used by the game, referenced here
.define HasFM               $c000 ; b 01 if YM2413 detected, 00 otherwise
.define NewMusic            $c004 ; b Which music to start playing
.define VBlankFunctionIndex $c208 ; b Index of function to execute in VBlank
.define FunctionLookupIndex $c202 ; b Index of "game phase" function
.define IntroState          $c600 ; b $ff when intro starts
.define NameIndex           $c2c2 ; b Index into Names
.define ItemIndex           $c2c4 ; b Index into Items
.define NumberToShowInText  $c2c5 ; b Number to show in text
.define EnemyIndex          $c2e6 ; b Index into Enemies

; RAM

.define VRAM_PTR  $DFC0   ; VRAM address
.define BUFFER    $DFD0   ; 32-byte buffer

.define STR       $DFB0   ; pointer to WRAM string
.define LEN       $DFB2   ; length of substring in WRAM
.define TEMP_STR  $DFC0 + $08 ; dictionary RAM ($DFC0-DFEF)
.define FULL_STR  $DFC0

.define POST_LEN  $DFB3   ; post-string hint (ex. <Herb>...)
.define LINE_NUM  $DFB4   ; # of lines drawn
.define FLAG      $DFB5   ; auto-wait flag
.define ARTICLE   $DFB6   ; article category #
.define SUFFIX    $DFB7   ; suffix flag

.define HLIMIT    $DFB9   ; horizontal chars left
.define VLIMIT    $DFBA   ; vertical line limit
.define SCRIPT    $DFBB   ; pointer to script
.define BANK      $DFBD   ; bank holding script
.define BARREL    $DFBE   ; current Huffman encoding barrel
.define TREE      $DFBF   ; current Huffman tree


.slot 1
  ROMPosition $4be84, 1
.section "New bitmap decoder" superfree
; Originally t4b, t4b_1
; RLE/LZ bitmap decoder
; - Phantasy Star Gaiden
PSG_DECODER:
  push af     ; Save registers
  push bc
  push de
  push hl
  push ix
  push iy

    ld (VRAM_PTR),hl  ; Cache VRAM offset

    push de     ; New source register
    pop ix

    ld c,(ix+0)   ; Load # tiles to decode
    inc ix
    ld b,(ix+0)
    inc ix

_Tiles_Loop:
    push bc     ; Save # runs

      ld c,(ix+0)   ; Decoder method selection
      inc ix

      ld b,4    ; 4 color planes
      ld de,BUFFER

      ; Decoder method
      ; - 00 = 8 $00's
      ; - 01 = 8 $FF's
      ; - 10 = RLE/LZ extended
      ; - 11 = 8 raw bytes

_Plane_Decode:
      rlc c     ; 00/01
      jr nc,_All_Bytes
      rlc c     ; 11
      jr c,_Free_Bytes

      ld a,(ix+0)   ; RLE/LZ selection
      inc ix

      ex de,hl    ; Lower 2 bits = LZ-window
      ld d,a
      and %11
      add a,a
      add a,a
      add a,a
      ld e,a

      ld a,d      ; LZ-window cursor
      ld d,0
      ld iy,BUFFER
      add iy,de
      ex de,hl

      cp $03      ; Check RLE/LZ pattern
      jr c,_LZ_Normal
      cp $10
      jr c,_RLE_Mix
      cp $13
      jr c,_LZ_Invert
      cp $20
      jr c,_RLE_Mix
      cp $23
      jr c,_LZ_Mix_Normal
      cp $40
      jr c,_RLE_Mix
      cp $43
      jr c,_LZ_Mix_Invert

_RLE_Mix:
      ld h,a      ; Set 8-bit decode pattern
      ld l,(ix+0)   ; Set RLE byte
      inc ix
      jr _RLE_Init


_Free_Bytes:
      ld h,0    ; 8 raw bytes
      jr _RLE_Init


_All_Bytes:
      rlc c     ; Dummy bit

      sbc a,a     ; $00 or $FF is cache byte
      ld l,a

      ld h,$ff    ; 8 RLE's pattern mask

_RLE_Init:
      push bc     ; 8 runs
        ld b,8

_RLE_Loop:
        ld a,l      ; Load cached (RLE) byte
        rlc h     ; Check pattern mask: Free or RLE
        jr c,_RLE_Store

        ld a,(ix+0)   ; Read raw byte
        inc ix

_RLE_Store:
        ld (de),a   ; Store byte, keep decoding
        inc de
        djnz _RLE_Loop

      pop bc      ; Proceed to next color plane
      jr _End_Loop

_LZ_Normal:
      ld hl,$ff00   ; 8 LZ transactions
      jr _LZ_Init

_LZ_Invert:
      ld hl,$ffff   ; 8 LZ runs (inversion)
      jr _LZ_Init

_LZ_Mix_Normal:
      ld h,(ix+0)   ; Load pattern mask
      ld l,0        ; No inversion
      inc ix
      jr _LZ_Init

_LZ_Mix_Invert:
      ld h,(ix+0)   ; Load pattern mask
      ld l,$ff    ; Inversion
      inc ix
      ; fall through

_LZ_Init:
      push bc     ; 8 Runs
        ld b,8

_LZ_Loop:
        ld a,(iy+0)   ; Load byte at LZ window cursor
        inc iy

        xor l     ; Full inversion if needed

        rlc h     ; Decode: Free or LZ
        jr c,_LZ_Store

        ld a,(ix+0)   ; Load raw
        inc ix

_LZ_Store:
        ld (de),a   ; Enter data until exhausted
        inc de
        djnz _LZ_Loop

      pop bc
      ; fall through

_End_Loop:
      dec b     ; One fewer color planes
      jp nz,_Plane_Decode

      ld de,(VRAM_PTR)  ; Set VRAM address
      di
        rst $08

        ld de,8   ; Color planes grouped in bytes of 8
        ld c,e

        ld hl,BUFFER    ; 4-bpp tile address

_Write_Loop:
        ld b,4    ; 4 color planes
        push hl

_Write_VRAM:
          ld a,(hl)   ; Grab byte
          out (PORT_VDP_DATA),a ; Write to VRAM
          add hl,de   ; Bump to next plane
          djnz _Write_VRAM

        pop hl      ; Go to next byte in sequence
        inc hl
        dec c
        jr nz,_Write_Loop

      ei      ; Update new VRAM offset
      ld hl,(VRAM_PTR)
      ld bc,32
      add hl,bc
      ld (VRAM_PTR),hl

    pop bc
    ; Determine # tiles left to decode
    dec bc
    ld a,b
    or c
    jp nz,_Tiles_Loop

  pop iy      ; Done
  pop ix
  pop hl
  pop de
  pop bc
  pop af
  ret

.ends

  ROMPosition $00486
.section "Trampoline to new bitmap decoder" force ; not movable
; RLE/LZ bitmap decoder
; - support mapper

; Redirects calls to LoadTiles4BitRLENoDI@$0486 (decompress graphics, interrupt-unsafe version)
; to a ripped decompressor from Phantasy Star Gaiden which is stored at the above address
; Thus the remainder of the old decompressor is orphaned.
LoadTiles:
  ld a,:PSG_DECODER
  ld (PAGING_SLOT_1),a

  call PSG_DECODER

  ld a,1
  ld (PAGING_SLOT_1),a

  ret
.ends

  ROMPosition $7e8bd
.section "Replacement title screen" superfree
TitleScreenTiles:
.incbin "new_graphics/title.psgcompr"
.ends

  ROMPosition $3bc68
.section "Title screen name table" superfree
TitleScreenTilemap:
.incbin "new_graphics/title-nt.pscompr"
.ends

  ROMPosition $00925
.section "Title screen palette" force ; not movable
TitleScreenPalette:
.incbin "new_graphics/title-pal.bin"
.ends

  ROMPosition $008f3
.section "Title screen patch" size 25 force ; not movable
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
  call $6e05 ; DecompressToTileMapData
  ; Size matches original
.ends

  ROMPosition $00ce4
.section "BG loader patch 1" size 14 overwrite ; not movable
  LoadPagedTiles OutsideTiles $4000
.ends

  ROMPosition $747b8
.section "Outside tiles" superfree
OutsideTiles:
.incbin "psg_encoder/world1.psgcompr"
.ends

  ROMPosition $58570
.section "Town tiles" superfree
TownTiles:
.incbin "psg_encoder/world2.psgcompr"
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

  ROMPosition $40000
.section "Palettes 1" force ; TODO attach palettes to tiles and superfree together
PalettePalmaOpen:      CopyFromOriginal $40000 16
PaletteDezorisOpen:    CopyFromOriginal $40010 16
PalettePalmaForest:    CopyFromOriginal $40f16 16
PaletteDezorisForest:  CopyFromOriginal $40f26 16
PalettePalmaSea:       CopyFromOriginal $41c72 16
.ends

  Bin TilesPalmaAndDezorisOpen    "psg_encoder/bg1.psgcompr"
  Bin TilesPalmaForest  "psg_encoder/bg2.psgcompr"
  Bin TilesPalmaSea     "psg_encoder/bg3.psgcompr"

; Some data from $428f6 (sea animation tiles)

  ROMPosition $43406
  Bin TilesMotabiaOpen  "psg_encoder/bg5.psgcompr"

; Gap?

  ROMPosition $44640
.section "Palettes 2" force ; TODO inline, attach to tiles and superfree
PalettePalmaTown:     CopyFromOriginal $44640 16
PalettePalmaVillage:  CopyFromOriginal $457c4 16
PaletteSpaceport:     CopyFromOriginal $464b1 16
PaletteDeadTrees:     CopyFromOriginal $46f58 16
.ends

  Bin TilesPalmaTown    "psg_encoder/bg8.psgcompr"
  Bin TilesPalmaVillage "psg_encoder/bg9.psgcompr"
  Bin TilesSpaceport    "psg_encoder/bg10.psgcompr"
  Bin TilesDeadTrees    "psg_encoder/bg11.psgcompr"

  ROMPosition $5ac8d
  Bin TilesAirCastle    "psg_encoder/bg13.psgcompr"
  ROMPosition $2c010
  Bin TilesGoldDragon   "psg_encoder/bg14.psgcompr"
  ROMPosition $5eb6f
  Bin TilesBuilding     "psg_encoder/bg16.psgcompr"
  ROMPosition $27b24
  Bin TilesMansion      "psg_encoder/bg29.psgcompr"
  ROMPosition $524ea
  Bin TilesLassicRoom   "psg_encoder/bg30.psgcompr"
  ROMPosition $4c010
  Bin TilesDarkForce    "psg_encoder/bg31.psgcompr"

  ; We also need the non-relocated tilemap and palette addresses to populate the table...
.macro LabelAtPosition
  ROMPosition \1
  \2:
.endm

  LabelAtPosition $03fc2 PaletteAirCastleFull
  LabelAtPosition $27b14 PaletteMansion
  LabelAtPosition $2c000 PaletteGoldDragon
  LabelAtPosition $433f6 PaletteMotabiaOpen
  LabelAtPosition $4c000 PaletteDarkForce
  LabelAtPosition $524da PaletteLassicRoom
  LabelAtPosition $5ac7d PaletteAirCastle
  LabelAtPosition $5ea9f PaletteBuildingEmpty
  LabelAtPosition $5eaaf PaletteBuildingWindows
  LabelAtPosition $5eabf PaletteBuildingHospital1
  LabelAtPosition $5eacf PaletteBuildingHospital2
  LabelAtPosition $5eadf PaletteBuildingChurch1
  LabelAtPosition $5eaef PaletteBuildingChurch2
  LabelAtPosition $5eaff PaletteBuildingArmoury1
  LabelAtPosition $5eb0f PaletteBuildingArmoury2
  LabelAtPosition $5eb1f PaletteBuildingShop1
  LabelAtPosition $5eb2f PaletteBuildingShop2
  LabelAtPosition $5eb3f PaletteBuildingShop3
  LabelAtPosition $5eb4f PaletteBuildingShop4
  LabelAtPosition $5eb5f PaletteBuildingDestroyed

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
FONT1:
.incbin "new_graphics/font1.psgcompr"
; Need to be in the same bank
FONT2:
.incbin "new_graphics/font2.psgcompr"
.ends

  ROMPosition $045a4
.section "Intro font loader" force ; not movable
; Originally t0b.asm
IntroFontLoader:
; was:
; ld hl,$ffff        SetPage TilesFont
; ld (hl),$10
; ld hl,$bad8        ld hl,TilesFont
; ld de,$5800        TileAddressDE $c0
; call $04b3         call LoadTiles4BitRLE
; ld hl,$bebe        ld hl,TilesExtraFont
; ld de,$7e00        TileAddressDE $1f0
; call $04b3         call LoadTiles4BitRLE
; ld hl,$bf5e        ld hl,TilesExtraFont2
; ld de,$5700        TileAddressDE $b8
; call $04b3         call LoadTiles4BitRLE

.define Font1VRAMAddress $5800
.define Font2VRAMAddress $7e00

; replace an in-line font decoding setup with a new one that's reusable,
; because it has a ret after it

  call DECODE_FONT
  jr ++

DECODE_FONT:    ; reusable elsewhere now
  ld hl,PAGING_SLOT_2
  ld (hl),:FONT1

  ld de,FONT1
  ld hl,Font1VRAMAddress
  call LoadTiles

DECODE_FONT2:
  ld de,FONT2
  ld hl,Font2VRAMAddress
  call LoadTiles
  ret

  nop ; this version is actually 3 bytes smaller now... need to nop out old code
  nop ; to continue correctly
  nop

++
.ends

  ROMPosition $7c9
.section "Font patch 1" overwrite ; not movable
FontPatch1:
  ; Load game font decoding
  ; Original code:
; ld hl,$ffff       ; page in
; ld (hl),$10
; ld hl,$bad8       ; laod part 1
; ld de,$5800
; call $04b3
; ld hl,$bebe       ; load part 2
; ld de,$7e00
; call $04b3

  call DECODE_FONT
  ; TODO: free the space
  jr $7e0-CADDR-1
.ends

  ROMPosition $10e3
.section "Font patch 2" overwrite ; not movable
FontPatch2:
  ; Dungeon font decoding
  ; Original code same as above

  call DECODE_FONT
  ; TODO: free the space
  jr $10fa-CADDR-1
.ends

  ROMPosition $3dde
.section "Font patch 3" overwrite ; not movable
FontPatch3:
  ; In-game font decoding
  ; Original code same as above

  call DECODE_FONT
  ; TODO: free the space
  jr $3df5-CADDR-1
.ends

  ROMPosition $48da
.section "Font patch 4" overwrite ; not movable
FontPatch4:
  ; Cutscene font decoding
  ; Original code same as above

  call DECODE_FONT
  jr $48f1-CADDR-1
.ends


  ROMPosition $697c
.section "Font patch 5" overwrite ; not movable
FontPatch5:
  ; Original code:
; ld hl,$ffff       ; page in
; ld (hl),$10
; ld hl,$bebe       ; load part 2
; ld de,$7e00
; call $04b3        ; <-- We only patch this part. TODO: free the space?

  call DECODE_FONT2 ; just the second font group
.ends


; Font renderer

  ROMPosition $34f2
.section "Character drawing" force ; not movable
; Originally t0d.asm
CharacterDrawing:
; Replacing draw-one-character function from $34f2-3545
; drawing 2 tilemap chars, with conditional mirroring, and a scrolling handler,
; with a new one from $3f42-3f66 that draws a single char using a 2-byte lookup
; and leaves the scrolling to be handled by the word-wrapping code elsewhere

  di            ; prepare VRAM output
  push bc
    push de
      push af
        rst $08      ; Set address
      pop af

      add a,a        ; 2-byte table

      ld bc,FontLookup ; index into table
      add a,c
      ld c,a
      adc a,b       ; overflow accounting ; TODO not necessary if it's aligned
      sub c
      ld b,a

      ld a,(bc)     ; load low NT-byte
      out (PORT_VDP_DATA),a
      push af       ; VRAM wait
      pop af

      inc bc        ; write out high NT-byte
      ld a,(bc)
      out (PORT_VDP_DATA),a

    pop de        ; Bump VRAM address
    inc de
    inc de
  pop bc

  ei               ; Wait for VBlank
  ld a,10          ; Trigger a name table refresh
  call ExecuteFunctionIndexAInNextVBlank

  dec b             ; Shrink window width
  ret
.ends

.bank 0 slot 0 ; Dictionary lookup must be in slot 0 as the others are being mapped.

.section "Dictionary lookup" free
  ; HL = Table offset

DictionaryLookup:
  push af
    ld a,:Items ; Load normal lists
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

  dec hl      ; Check last character
  ld a,(hl)

  cp LETTER_S   ; <name>'s attack
  jr nz,+

  xor a     ; Clear flag

+:ld (SUFFIX),a

  ld a,2    ; Normal page
  ld (PAGING_SLOT_2),a

  ret
.ends

  ROMPosition $7fe00, 1
.section "Additional scripting codes" force ; superfree
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

+:cp $60
  jr c,+    ; Control codes, don't interfere

  sub $60     ; Relocate dictionary entry #

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

.ends

.enum $4f ; Scripting codes
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
.ende

  ROMPosition $7fed0, 1
.section "Substring formatter" force ; superfree
SubstringFormatter:
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
.dw +, ++, +++ ; no "Some"? TODO use or remove
+:    Article " a"
++:   Article " na"
+++:  Article " eht"
      Article " emos"

ArticlesInitialUpper:
.dw +, ++, +++ ; no "Some"? TODO use or remove
+:    Article " A"
++:   Article " dA" ; BUG: wrong text here
+++:  Article " ehT"
      Article " emoS"

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
  call $2e81 ; MenuWaitForButton
  pop de
  ret

ExitAfterPause:
  call $2eaf ; Pause256Frames
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
    ld (ix+$00),A

    ld bc,1000     ; # 1000's
    call _BCD_Digit
    ld (ix+$01),A

    ld bc,100      ; # 100's
    call _BCD_Digit
    ld (ix+$02),A

    ld bc,10       ; # 10's
    call _BCD_Digit
    ld (ix+$03),A

    ld a,l      ; # 1's (_BCD_Digit has made it only possible to be in the range 0..9)
    add a,$01   ; add 1 because result = digit+1
    ld (ix+$04),a


    ; scan the resultant string to see where the first non-zero digit is
    ; but we want to show the last digit even if it is zero
    ld b,$04    ; look at 4 digits max
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
    cp $01
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
  ld a,$00     ; Init digit value
               ; Note: $01 = '0', auto-bump
  or a         ; Clear carry flag ; TODO: can just xor a to zero and clear flag

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

    call $0127 ; VBlank ; Resume old code

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

  ROMPosition $76ba6
.section "Enemy, name, item lists" force ; superfree

; Order is important!
Items:
  String " " ; empty item (blank)
; weapons
  String "~Wood Cane"
  String "~Short@ Sword"
  String "#Iron Sword"
  String "~Psycho@ Wand"
  String "~Saber Claw"
  String "#Iron Axe"
  String "~Titanium@ Sword"
  String "~Ceramic@ Sword"
  String "~Needle Gun"
  String "~Silver@ Tusk"
  String "~Heat Gun"
  String "~Light@ Saber"
  String "~Laser Gun"
  String "~Laconian@ Sword"
  String "~Laconian@ Axe"
; armour
  String "~Leather@ Clothes"
  String "~White@ Cloak"
  String "~Light Suit"
  String "#Iron Armor"
  String "~Spiky [Squirrel ]Fur"
  String "~Zirconian@ Mail"
  String "~Diamond@ Armor"
  String "~Laconian@ Armor"
  String "^Frad Cloak"
; shields
  String "~Leather@ Shield"
  String "~Bronze@ Shield"
  String "#Iron@ Shield"
  String "~Ceramic@ Shield"
  String "#Animal@ Glove"
  String "~Laser@ Barrier"
  String "^Shield of@ Perseus"
  String "~Laconian@ Shield"
; vehicles
  String "^LandMaster"
  String "^FlowMover"
  String "^IceDecker"
; items
  String "~Pelorie%@+Mate"
  String "~Ruoginin"
  String "^Soothe@ Flute"
  String "~Search%@+light"
  String "#Escape@ Cloth"
  String "~TranCarpet"
  String "~Magic Hat"
  String "#Alsuline"
  String "~Poly%@+meteral"
  String "~Dungeon@ Key"
  String "~Telepathy@ Ball"
  String "^Eclipse@ Torch"
  String "^Aeroprism"
  String "^Laerma@ Berries"
  String "Hapsby"
  String "~Road Pass"
  String "~Passport"
  String "~Compass"
  String "~Shortcake"
  String "^Governor[-General]'s@ Letter"
  String "~Laconian@ Pot"
  String "^Light@ Pendant"
  String "^Carbunckle@ Eye"
  String "~GasClear"
  String "Damoa's@ Crystal"
  String "~Master@ System"
  String "^Miracle@ Key"
  String "Zillion"
  String "~Secret@ Thing"

Names:
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"

Enemies:
  String " " ; Empty
  String "^Monster@ Fly"
  String "^Green@ Slime"
  String "^Wing Eye"
  String "^Maneater"
  String "^Scorpius"
  String "^Giant@ Naiad"
  String "^Blue@ Slime"
  String "^Motavian@ Peasant"
  String "^Devil Bat"
  String "^Killer@ Plant"
  String "^Biting@ Fly"
  String "^Motavian@ Teaser"
  String "^Herex"
  String "^Sandworm"
  String "^Motavian@ Maniac"
  String "^Gold Lens"
  String "^Red Slime"
  String "^Bat Man"
  String "^Horseshoe@ Crab"
  String "^Shark King"
  String "^Lich"
  String "^Tarantula"
  String "^Manticort"
  String "^Skeleton"
  String "^Ant-lion"
  String "^Marshes"
  String "^Dezorian"
  String "^Desert@ Leech"
  String "^Cryon"
  String "^Big Nose"
  String "^Ghoul"
  String "^Ammonite"
  String "^Executor"
  String "^Wight"
  String "^Skull@ Soldier"
  String "^Snail"
  String "^Manticore"
  String "^Serpent"
  String "^Leviathan"
  String "^Dorouge"
  String "^Octopus"
  String "^Mad@ Stalker"
  String "^Dezorian@ Head"
  String "^Zombie"
  String "^Living@ Dead"
  String "^Robot@ Police"
  String "^Cyborg@ Mage"
  String "^Flame@ Lizard"
  String "Tajim"
  String "^Gaia"
  String "^Machine@ Guard"
  String "^Big Eater"
  String "^Talos"
  String "^Snake@ Lord"
  String "^Death@ Bearer"
  String "^Chaos@ Sorcerer"
  String "^Centaur"
  String "^Ice Man"
  String "^Vulcan"
  String "^Red@ Dragon"
  String "^Green@ Dragon"
  String "LaShiec"
  String "^Mammoth"
  String "^King Saber"
  String "^Dark@ Marauder"
  String "^Golem"
  String "Medusa"
  String "^Frost@ Dragon"
  String "Dragon@ Wise"
  String "Gold Drake"
  String "Mad Doctor"
  String "LaShiec"
  String "Dark Force"
  String "Nightmare"
; Terminator
.db $df
.ends

  ROMPosition $43c00
.section "Static dictionary" force ; superfree
Words:
.include "substring_formatter/words.asm"
; Terminator
.db $df
.ends

; English script

  ROMPosition $59ba
.section "Index table remap" force ; not movable
IndexTableRemap:
  jp $333a ; TextBox20x6
.ends

; Menus

  ROMPosition $46c81
.section "Menu data" force ; superfree
MenuData:
.include "menu_creater/menus.asm"
.ends

.include "menu_creater/menu-patches.asm"

  PatchB $3b82 :MenuData
  PatchB $3bab :MenuData

  ; Enemy name VRAM
  PatchW $3259 $7818
  PatchW $3271 $7818
  PatchW $331e $7818

  ROMPosition $3211
.section "HP letters" size 4 overwrite ; not movable
.dwm TextToTilemap "HP"
.ends

  ROMPosition $3219
.section "MP letters" size 4 overwrite ; not movable
.dwm TextToTilemap "MP"
.ends

  ; Choose player: width*2
  PatchB $37c8 $10

  ROMPosition $3de4
.section "Active player - menu offset finder" overwrite ; not movable?
ActivePlayerMenuOffsetFinder:
; Originally t2b.asm
; Active player menu selection

  xor a
  inc h

-:dec h     ; loop
  ret z

  add a,l     ; skip menu
  jr -

.ends

  ROMPosition $3023
.section "Trampoline to above" overwrite ; not movable
TrampolineToActivePlayerMenuOffsetFinder:
; Original code was doing it inline:
;  ld a,($c267) ; get index
;  add a,a      ; multiply by 36
;  add a,a
;  ld l,a
;  add a,a
;  add a,a
;  add a,a
;  add a,l
; We replace all this with a jump to a helper as the necessary replacement is a bit bigger
  ld h,a
  ld l,$30 ; MENU_SIZE = (8*2)*3
  nop ; Fill space
  call ActivePlayerMenuOffsetFinder
.ends

  ROMPosition $35a2
.section "Spell selection finder" overwrite ; not movable
SpellSelectionFinder:
; Originally t2b_1.asm
; Spell selection offset finder

.define MENU_SIZE ((10+2)*2)*11 ; top border + text

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

  PatchB $35bf $18      ; - (12+2)*2 width
  PatchW $1ee1 $7a4c    ; - VRAM cursor
  PatchW $1b6a $7a4c    ; - VRAM cursor


  ROMPosition $35c5
.section "Spell blank line" size 14 overwrite ; not movable
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

.define LINE_SIZE (10+2)*2  ; width of line

  ; Our menus are wider now, we want a = b * 24.
  ; We don't have space to do it with shifts so we loop instead (slower)...
  
  push de
  push bc
    ld hl,BlankSpellMenu
    ld de,LINE_SIZE
-:  add hl,de
    djnz -
  pop bc
  pop de
.ends

  PatchB $35d4 $0c  ; - height

  ROMPosition $3516
.section "Stats menu part 1" free
; The width of these is important
Level: .dwm TextToTilemap "|Level   " ; 3 digit number
MST:   .dwm TextToTilemap "|MST   "   ; 5 digit number
.ends

  PatchW $3911 Level  ; - LV source
  PatchW $36e7 MST    ; - MST source

  ROMPosition $3982
.section "Stats menu part 2" free
; The width of these is important
EXP:      .dwm TextToTilemap "|Exp.  "   ; 5 digit number
Attack:   .dwm TextToTilemap "|Attack  " ; 3 digit numbers
Defense:  .dwm TextToTilemap "|Defense "
MaxHP:    .dwm TextToTilemap "|Max HP  "
MaxMP:    .dwm TextToTilemap "|Max MP  "
.ends

  PatchW $391a EXP    ; - EXP source
  PatchB $31a3 _sizeof_EXP ; size
  PatchB $36dd _sizeof_EXP

  PatchW $392f Attack   ; - Attack source
  PatchW $3941 Defense  ; - Defense source
  PatchW $3953 MaxHP    ; - Max HP source
  PatchW $3965 MaxMP    ; - Max MP source
  PatchB $3145 _sizeof_Attack ; - length in bytes

  PatchW $363f $78a8    ; Inventory VRAM (2 tiles left)
  PatchW $3778 $78a8
  PatchW $364b $78a8
  PatchB $36e5 $0c      ; - width * 2
  PatchW $3617 $7928    ; - VRAM cursor

  PatchW $3b18 $7bcc    ; Store MST VRAM
  PatchW $3b41 $7bcc
  PatchW $3b26 $7bcc

  PatchW $3a40 $784c    ; Shop inventory VRAM

  PatchB $3b58 :MenuData ; Hapsby travel (bank)
  PatchW $3b63 $7b2a    ; - VRAM cursor
  PatchW $3b4f $7aea    ; - move window down 1 tile
  PatchW $3b76 $7aea

  PatchW $3835 $7a88    ; Equipment VRAM
  PatchW $3829 $7a88
  PatchW $386e $7a88

  ROMPosition $5aadc
.section "Opening cinema" superfree
Opening:
.include "menu_creater/opening.asm"
.ends

.include "menu_creater/opening-patches.asm"

  PatchB $45d7 :Opening ; - source bank

; relocate Tarzimal's tiles (bug in 1.00-1.01 caused by larger magic menus)

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

_next_item:
  push bc
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

    call _start_write
    call _wait_vblank

  pop hl
  pop bc

  inc hl      ; next item
  djnz _next_item

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

    call _start_write

    push hl     ; hacky workaround
    push de
      ld c,$00    ; do not write price
      call _shop_price
    pop de
    pop hl

  pop hl      ; restore old parameters
  pop bc

  inc hl      ; next item
  inc hl
  inc hl
  djnz -

  ret


enemy:
  di
    ld a,3    ; enemy data bank
    ld (PAGING_SLOT_2),a

    ld a,(EnemyIndex)    ; grab enemy #
    ld hl,Enemies   ; table start

    push de
      call DictionaryLookup    ; copy string to RAM
    pop de
  ei

  ld hl,TEMP_STR    ; start of text

  call _start_write ; write out line of text

  ld a,(LEN)    ; optionally write next line
  or a
  call nz,_start_write

  call _wait_vblank

  ret


equipment:
  ld b,3    ; 3 items total

_next_equipment:
  push bc
  push hl

    di
      ld a,3    ; data bank
      ld (PAGING_SLOT_2),a

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out 2 lines of text
    call _wait_vblank

    call _start_write
    call _wait_vblank

  pop hl
  pop bc

  inc hl      ; next item
  djnz _next_equipment

  ret

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
      ld b,10   ; 10-width

_check_length:
      ld a,c      ; check for zero string
      or a
      jr z,_blank_line

_read_byte:
      ld a,(hl)   ; read character
      inc hl      ; bump pointer
      dec c     ; shrink length

      cp $4f      ; normal text
      jr c,_bump_text

_space:
      jr z,_blank_line    ; non-narrative WS

      ; These correspond to the control codes in the .asciitable, not the ones in the script.
_newline:
      cp $50      ; pad rest of line with WS
      jr nz,_hyphen

-:    xor a
      call _write_nt
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
      call _write_nt
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
      ld hl,10*2+2    ; left border + 10-char width
      add hl,de   ; save VRAM ptr
      ld (FULL_STR+2),hl

      ld hl,32*2  ; VRAM newline
      add hl,de
      ex de,hl
    pop hl

  ei      ; wait for vblank
  ret

_write_nt:
      add a,a     ; lookup NT
      ld de,FontLookup
      add a,e
      ld e,a
      adc a,d
      sub e
      ld d,a

      ld a,(de)   ; write NT + VDP delay
      out ($be),a
      push af
      pop af
      inc de
      ld a,(de)
      out ($be),a

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

  ROMPosition $3279
.section "enemy setup code" size 18 overwrite ; not movable
; Originally t2a_3.asm
; Enemy window drawer
; - setup code

  ld a,:enemy
  ld (PAGING_SLOT_1),a

  call enemy

  ld a,$01    ; old page 1
  ld (PAGING_SLOT_1),a

  nop
  nop
  nop
  nop
  nop
.ends

  ROMPosition $3850
.section "equipment setup code" size 14 overwrite ; not movable
; Originally t2a_4.asm
; Equipment window drawer
; - setup code

  ld a,:equipment
  ld (PAGING_SLOT_1),a

  call equipment

  ld a,1
  ld (PAGING_SLOT_1),a

  nop
.ends

; Extra scripting

  ROMPosition $59bd
.section "Dezorian string" force 
; needs to be close to its hooked points unless I change to jp opcodes
; also the string pointer address needs to be fixed...
; Originally t5.asm
; Extra scripting
; This is placed in a bit of free space and we patch a jump into it...
DezorianCustomStringCheck:
  cp $ff      ; custom string [1E7]
  jr nz,$59ca-CADDR-1 ; Where the patched jump went to (shows an error message?)

  ld hl,$0000   ; String pointer is patched by script.asm, needs to match the address this ends up at...
  ; Pointed string is "Those guys in the other village are all liars. For real.<wait>"
  jr $59ba-CADDR-1 ; DrawText20x6
.ends

  PatchB $eec9 $ff      ; - insert $ff scripting code into data
  PatchW $49b0 DezorianCustomStringCheck ; Patch to jump to extra code

; Window RAM cache
; When showing "windows", the game copies the tilemap data to RAM so it can restore the
; background when the window closes. The windows thus need to (1) close in reverse opening order
; and (2) use non-overlapping areas of this cache.
; The total number of windows exceeds the cache size, so it is a careful act to select the right
; addresses.

  PatchW $3788 $de60    ; #5  - Choose player
  PatchW $37de $de60
  PatchW $37a5 $ddd0    ; #7  - Magic - Depth 3 (choose player)
  PatchW $37ef $ddd0
  PatchW $3877 $d960    ; #8  - Item selected
  PatchW $3889 $d960
  PatchW $3826 $def0    ; #9  - Current equipment
  PatchW $386b $def0
  PatchW $38fc $dc50    ; #10 - Individual stats
  PatchW $39df $dc50
  PatchW $3256 $df20    ; #12 - Enemy name
  PatchW $331b $df20
  PatchW $3015 $df80    ; #14 - Active player
  PatchW $3036 $df80
  PatchW $3ad0 $dd00    ; #18 - Save slots
  PatchW $3b08 $dd00
  PatchW $38c1 $def0   ; Yes/no - clashes with #5
  PatchW $38e1 $def0

  PatchW $3595 $db30   ; #6 - Magic - Depth 2 (choose spell)
  PatchW $35e4 $db30

; Fixes from alex_231 - untested
/*
  PatchW $334d $d9f4 ; #3 Narrative Box
  PatchW $3387 $d9f4
  PatchW $3877 $d954 ; #8 Item selected
  PatchW $3889 $d954
  PatchW $38fc $dcbc ; #10 Individual stats
  PatchW $39df $dcbc
  PatchW $3262 $d954 ; #12 Enemy party
  PatchW $330a $d954
  PatchW $3595 $db74 ; #6 Magic - Depth 2 (choose spell)
  PatchW $35e4 $db74
*/

; Text densification
  PatchB $34c9 $40 ; cutscene text display: increment VRAM pointer by $0040 (not $0080) for newlines

  ROMPosition $0000f
.section "Newline patch" free
; Originally tx1.asm
; Text window drawer multi-line handler

newline:
    ld b,$12 ; reset x counter
    inc hl   ; move pointer to next byte
    ld a,c   ; get line counter                             ;
    or a     ; test for c==0
    jr nz,_not_zero
    ; zero: draw on 2nd line
    ld de,$7d0e ; VRAM address
_inc_and_finish:
    inc c
    jp InGameTextDecoder
_not_zero:
    dec a    ; test for c==1
    jr nz,_not_one
    ; one: draw on 3rd
_draw_3rd_line:
    ld de,$7d4e ; VRAM address
    jr _inc_and_finish
_not_one:
    dec a    ; test for c==2
    jr nz,_not_two
    ; two: draw on 4th
_draw_4th_line:
    ld de,$7d8e
    jr _inc_and_finish
_not_two:
    ; three: scroll, draw on 4th line
    call $3546 ; _ScrollTextBoxUp2Lines (see patch below reduces it to one)
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

; Savegame name entry screen hacking ---------------------------------------------
; compressed tile data (low byte only) for name entry screen
  ROMPosition $3f02
.section "Name entry tilemap data" force ; free
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
.db RLE |   8, $c0      ;           "        "
.db RLE |   8, $ff      ; (punctuation all dots - will be patched later)
.db RLE |  38, $c0      ; (space)
.db RAW |  10, $cc $e5 $e7 $ef $c0 $c0 $d8 $e9 $fc $f8 ; "Back  Next"
.db RLE |  12, $c0      ; (space)
.db RAW |   4, $dd $e5 $fa $e9 ; "Save"
.db RLE | 127, $c0      ; (space)
.db RLE |  37, $c0
.db RAW |   1, $f1      ; "\"
.db RLE |  28, $f2      ;  "----------------------------"
.db RLE |   1, $f1      ;                              "/" ; should be RAW, doesn't matter
.db $00 ; Terminator
.ends

  ROMPosition $42cc
.section "Patch name entry tiles pointer" overwrite ; not movable
  ld hl,NameEntryTiles ; rewire pointer
.ends

; "Enter your name" text at the top of the screen
  ROMPosition $4059
.section "Enter your name text" force ; free
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
  call $0428 ; OutputTilemapRawDataBox ; change function call to full raw tilemap drawer
.ends

  ROMPosition $41e3
.section "Name entry punctuation hook" overwrite ; not movable
  ; We patch a call here to minimise the patch size
  call DrawExtendedCharacters
.ends

  ROMPosition $3f3a
.section "Name entry screen extended characters" force ; free
; Originally tx4.asm
; Name entry screen patch to draw extended characters
DrawExtendedCharacters:
    call $03de ; OutputToVRAM ; the call I stole to get here
    ld bc,$010e ; 14 bytes per row, 1 row
    ld de,$7bec ; Tilemap location 22,15
    ld hl,_punctuation
    call $0428 ; OutputTilemapRawDataBox  ; output raw tilemap data
    ret

_punctuation:
.dwm TextToTilemap ",:-!?`'"

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

  ROMPosition $448e
.section "Save lookup" force ; free (can be bank 0 or 1)
SaveLookup:
; Character found at each location in the name entry screen
; A-Z
.db $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F $20 $21 $22 $23 $24
; a-z
.db $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E
; 0-9, then empty space (so the cursor jumps over it), then punctuation
.db $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $00 $00 $00 $00 $00 $00 $00 $00 $3F $43 $40 $46 $47 $48 $41 $42
; Back, Next, Save. We extend their values to whole rows to enable "snapping" the cursor when moving down from above.
.db $4F $4F $4F $4F $4F $4E $4E $4E $4E $4E $4E $4E $4E $4E $4E $4E $50 $50 $50 $50 $50 $50 $50 $50 $50 $51
.ends
  PatchW $433c SaveLookup ; rewire pointer

; Cursor snapping for
  PatchB $4161 $48 ; x coordinate of sprite for Next
  PatchW $4163 $d496 ; lookup position for Next
  PatchB $416c $18 ; x coordinate of sprite for Prev
  PatchB $416a $8a ; lookup position for Prev (same high byte as for Next)
  PatchB $4170 $c8 ; x coordinate of sprite for Save
  PatchB $4172 $b6 ; lookup position for Save (same high byte as for Next)

; make $50+ count as Save - change jr z,<addr> to jr nc,<addr>
; because I'm using a $51 in the lookup data to stop a cursor bug
  PatchB $402a $30


; 4-sprite cursor hack
; 1. Extra y coordinates
  ROMPosition $4243
.section "Name entry 4-sprite cursor trampoline" size 4 overwrite ; not movable
; Original code:
; inc e
; ld (de),a
; inc e
; ld (de),a
  call NameEntryCursor
  nop ; to fill space for patch
.ends
  ROMPosition $04a7
.section "Name entry 4-sprite cursor hack" force ; free
NameEntryCursor:
  inc e
  ld (de),a
  inc e
  ld (de),a
  inc e
  ld (de),a
  ret
  ret ; TODO: remove this. Needed to match a bug in 0.92.
.ends

; 2. Extra x coords and tile indices
  PatchB $4251 $04
; 3. Cursor extends right, not left, relative to the "snapped" positions
  PatchB $425c $c6 ; sub nn -> add a,nn

; Text drawing as you enter your name
  ROMPosition $429b
.section "Drawing to RAM as you enter" force ; free
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

; New title screen ------------------------
  PatchB $2fdb $dc    ; cursor tile index

; Changed credits -------------------------
  ROMPosition $53dbc
.section "Credits" force ; not movable
CreditsData:
.dw CreditsScreen1, CreditsScreen2, CreditsScreen3, CreditsScreen4, CreditsScreen5, CreditsScreen6, CreditsScreen7, CreditsScreen8, CreditsScreen9, CreditsScreen10, CreditsScreen11, CreditsScreen12, CreditsScreen13, CreditsScreen14
.macro CreditsEntry args x, y, text
.dw $d000 + ((y * 32) + x) * 2
.db text.length, text
.endm
CreditsScreen1:
.db 1 ; entry count
  CreditsEntry 13,10,"STAFF"
CreditsScreen2:
.db 3
  CreditsEntry 5,5,"TOTAL"
  CreditsEntry 6,7,"PLANNING"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3:
.db 5
  CreditsEntry 6,5,"SCENARIO"
  CreditsEntry 7,7,"WRITER"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 9,15,"STORY"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4:
.db 4
  CreditsEntry 4,5,"ASSISTANT"
  CreditsEntry 3,7,"COORDINATORS"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5:
.db 5
  CreditsEntry 3,6,"TOTAL DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"MONSTER"
  CreditsEntry 7,16,"DESIGN"
  CreditsEntry 17,15,"CHAOTIC KAZ"
CreditsScreen6:
.db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"
CreditsScreen7:
.db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"
CreditsScreen8:
.db 4
  CreditsEntry 9,6,"SOUND"
  CreditsEntry 18,6,"BO"
  CreditsEntry 4,15,"SOFT CHECK"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9:
.db 5
  CreditsEntry 3,5,"ASSISTANT"
  CreditsEntry 4,7,"PROGRAMMERS"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10:
.db 2
  CreditsEntry 2,6,"MAIN PROGRAM"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11:
.db 1
  CreditsEntry 9,10,"RETRANSLATION"
CreditsScreen12:
.db 4
  CreditsEntry 3,6,"WORDS"
  CreditsEntry 10,10,"PAUL JENSEN"
  CreditsEntry 2,15,"FRANK CIFALDI"
  CreditsEntry 18,15,"SATSU"
CreditsScreen13:
.db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z[\ GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14:
.db 3
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

  ROMPosition $3fdee
.section "Credits font" force ; superfree
CreditsFont:
.incbin "new_graphics/font3.psgcompr"
.ends

  ROMPosition $00056
.section "HALT on idle polling loop" force ; free
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

  ROMPosition $00066
.section "Press Pause on the title screen to toggle PSG/FM - trampoline" overwrite ; not movable
  ; There are 3 spare bytes at $66 that I can use.
  ; I move the following two opcodes up (as I need them anyway) and then call my handler...
  push af
    ld a,(FunctionLookupIndex)
    call PauseFMToggle
.ends

  ROMPosition $3f58
.section "Press Pause on the title screen to toggle PSG/FM - implementation" force ; free
PauseFMToggle:
  cp 3          ; Indicates we are on the title screen
  ret nz
  ; We make no attempt to preserve FunctionLookupIndex on return (TODO?)
  ld a,(IntroState)
  cp $ff        ; could inc a to save a byte
  ret z         ; Intro started
  ; Toggle FM bit
  ld a,(HasFM)
  xor 1
  ld (HasFM),a
  ; Restart title screen music
  ld a,$81
  ld (NewMusic),a
  ret
.ends

; Remove waits for button press --------------------
  PatchW $1808 0
  PatchB $180a 0 ; found treasure chest/display/wait/do you want to open it?

; The font lookup, Huffman bits and script all share a bank as they are needed at the same time.
.bank 2 slot 2

.section "Font lookup" free
FontLookup:
; This is used to convert text from the game's encoding (indexing into ths area) to name table entries. The extra spaces are unused (and could be repurposed?).
.dwm TextToTilemap " 0123456789"
.dwm TextToTilemap "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.dwm TextToTilemap "abcdefghijklmnopqrstuvwxyz"
.dwm TextToTilemap ".:`',  -!?               "
.ends

; Both the trees and script entries could be micro-sections but they need to share a bank, 
; and it's pretty empty, so we don't get any benefit to split them up.

.block "HuffmanTrees"
.section "Huffman tree stuff" free
TREE_PTR:
.include "script_inserter/tree.asm"
.ends
.endb

.section "Script" free
.block "Script"
.include "script_inserter/script.asm"
.endb
.ends

.section "Decoder init" free ; same bank as script
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

.section "SFG decoder" free ; same bank as script
SFGDecoder:
; Originally t4a.asm
; Semi-adaptive Huffman decoder
; - Shining Force Gaiden: Final Conflict

; Start of decoder

; Note:
; The Z80 uses one set of registers for decoding the Huffman input data
; The other context is used to traverse the Huffman tree itself

; Encoded Huffman data is in page 2

; Huffman tree data is in page 2
; The symbols for the tree are stored in backwards linear order

  push hl

    ld a,(PAGING_SLOT_1)    ; Save current page 1
    push af

      ld a,$6f000/$4000 ; Load in script bank #2 ; TODO is this needed? Our script fits in page 2?
      ld (PAGING_SLOT_1),a

      ld hl,(SCRIPT)    ; Set Huffman data location
      ld a,(BARREL)   ; Load Huffman barrel

      ex af,af'   ; Context switch to tree mode
      exx
        ld a,(TREE)   ; Load in tree / last symbol

        push af
          ld bc,TREE_PTR    ; Set physical address of tree data
          ld h,0      ; 8 -> 16
          ld l,a
          add hl,hl   ; 2-byte indices
          add hl,bc   ; add offset

          ld a,(hl)   ; grab final offset
          inc hl
          ld h,(hl)
          ld l,a
        pop af

        ld a,$80    ; Initialise the tree barrel data
        ld d,h      ; Point to symbol data
        ld e,l
        dec de      ; Symbol data starts one behind the tree

        jr _Tree_Shift1    ; Grab first bit

_Tree_Mode1:
      ex af,af'   ; Context switch to tree mode
      exx

_Tree_Shift1:
        add a,a     ; Shift out next tree bit to carry flag
        jr nz,+     ; Check for empty tree barrel

        ld a,(hl)   ; Shift out next tree bit to carry flag
        inc hl      ; Bump tree pointer

        adc a,a     ; Note: We actually shift in a '1' by doing this! Clever trick to use all 8 bits for tree codes

+:      jr c,_Decode_Done ; 0 -> tree node = continue looking
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

        ld c,1    ; Start counting how many symbols to skip in the linear list since we are traversing the right sub-tree

_Tree_Shift2:
        add a,a     ; Check if tree data needs refreshing
        jr nz,_Check_Tree2

        ld a,(hl)   ; Refresh tree barrel again
        inc hl      ; Bump tree pointer
        adc a,a     ; Grab new tree bit

_Check_Tree2:
        jr c,_Bump_Symbol  ; 0 -> tree, 1 -> symbol

        inc c     ; Need to bypass one more node
        jr _Tree_Shift2    ; Keep bypassing symbols

_Bump_Symbol:
        dec de      ; Bump pointer in symbol list backwards
        dec c     ; One less node/symbol to skip

        jr nz,_Tree_Shift2 ; Check for full exhaustion of left subtree nodes

        jr _Tree_Shift1    ; Need status of termination

_Decode_Done:
    pop af      ; Restore old page 1
    ld (PAGING_SLOT_1),a

    ld a,(de)   ; Find symbol
    ld (TREE),a   ; Save decoded byte

    ex af,af'   ; Go to Huffman mode
    exx
      ld (SCRIPT),hl    ; Save script pointer
      ld (BARREL),a   ; Save Huffman barrel
    ex af,af'   ; Go to Tree mode
    ; no need to exx again

  pop hl      ; Restore stack and exit
  ret
.ends

.include "script_inserter/script-patches.asm"

.smsheader
   productcode 00, 95, 0 ; 9500
   version 3 ; 1.03 :)
   regioncode 4
   reservedspace $ff, $ff
.endsms
