; Attempt at unifying the PS1JERT into a WLA DX project...

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

.background "PS1-J.SMS"

.emptyfill $ff
.unbackground $00056 $00065 ; ExecuteFunctionIndexAInNextVBlank followed by unused space
/*
.unbackground $00486 $004ae ; Old tile decoder - can go up to 4e1
.unbackground $00925 $00932 ; Title screen palette - can go up to 944
.unbackground $034f2 $03544 ; draw one character to tilemap
.unbackground $033fe $03492 ; draw number inline with text (end is ?)
.unbackground $03eca $03fc1 ; background graphics lookup table
.unbackground $03fc2 $03fd1 ; sky castle palette
.unbackground $04059 $0407a ; password entered (unused)
.unbackground $04261 $04277 ; password population (unused)
.unbackground $0429b $042b4 ; draw to tilemap during entry
.unbackground $042b5 $042cb ; draw to RAM during entry
.unbackground $04396 $043e5 ; password lookup data (unused)
.unbackground $043e6 $04405 ; text for "please enter your name"
.unbackground $04406 $0448b ; tilemap for name entry
.unbackground $0448c $04509 ; data for lookup table during entry
.unbackground $045a4 $045c5 ; tile loading for intro
.unbackground $08000 $0bfff ; font tile lookup plus script
.unbackground $27b14 $27fff ; Mansion palette and tiles
.unbackground $2c000 $2ffff ; palettes and tiles
.unbackground $3BC68 $3bfff ; Title screen tilemap
.unbackground $40000 $43fff ; Scene tiles and palettes (whole bank)
.unbackground $44640 $47fff ; Palettes and tiles
.unbackground $4be84 $4bfff ; blank data                 
.unbackground $4c000 $4ffff ; Various enemy tiles
.unbackground $50000 $53dbb ; Palettes and tiles
.unbackground $58570 $5ac7b ; landscapes (world 2)       
.unbackground $5ac8d $5b9d5 ; Air Castle                 
.unbackground $5ea9f $5ffff ; Palettes and tiles
.unbackground $747b8 $77628 ; landscapes (world 1)       
.unbackground $7e8bd $7ffff ; Title screen tiles
*/
.define VRAM_PTR  $DFC0   ; VRAM address
.define BUFFER    $DFD0   ; 32-byte buffer

.define PAGING_SLOT_1 $fffe
.define PAGING_SLOT_2 $ffff
.define PORT_VDP_DATA $be

; Functions we call
.define VBlank $0127
.define DecompressToTileMapData $6e05
.define OutputTilemapRawDataBox $0428
.define TextBox20x6 $333a

; RAM used by the game, referenced here
.define HasFM               $c000 ; b 01 if YM2413 detected, 00 otherwise
.define NewMusic            $c004 ; b Which music to start playing
.define VBlankFunctionIndex $c208 ; b Index of function to execute in VBlank
.define FunctionLookupIndex $c202 ; b Index of "game phase" function
.define IntroState          $c600 ; b $ff when intro starts

; RAM

.define STR       $DFB0   ; pointer to WRAM string
.define LEN       $DFB2   ; length of substring in WRAM
.define TEMP_STR  $DFC0 + $08 ; dictionary RAM ($DFC0-DFEF)
.define FULL_STR  $DFC0

.define POST_LEN  $DFB3   ; post-string hint (ex. <Herb>...)
.define LINE_NUM  $DFB4   ; # of lines drawn
.define FLAG    $DFB5   ; auto-wait flag
.define ARTICLE   $DFB6   ; article category #
.define SUFFIX    $DFB7   ; suffix flag

.define LETTER_S  $37   ; suffix letter ('s')

.define NEWLINE   $54   ; carriage-return
.define EOS       $56   ; end-of-string

.define HLIMIT    $DFB9   ; horizontal chars left
.define VLIMIT    $DFBA   ; vertical line limit
.define SCRIPT    $DFBB   ; pointer to script
.define BANK      $DFBD   ; bank holding script
.define BARREL    $DFBE   ; current Huffman encoding barrel
.define TREE      $DFBF   ; current Huffman tree

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

.macro BinAtPosition args _address, _filename
  ROMPosition _address
.section "Auto bin include \2 @ \1" overwrite
BinAt\1:
.incbin _filename
.ends
.endm

.macro PatchB args _address, _value
  ROMPosition _address
.section "Auto patch @ \1" overwrite
PatchAt\1:
  .db _value
.ends
.endm

.macro PatchW args _address, _value
  ROMPosition _address
.section "Auto patch @ \1" overwrite
PatchAt\1:
  .dw _value
.ends
.endm

.macro Text
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
  .printt "' in Text macro\n"
  .fail
.endif
.endm

.macro TextLowPriority
  Text \1
  .redefine _out _out & $0fff
.endm

  ROMPosition $4be84, 1
.section "New bitmap decoder" overwrite

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
.section "Trampoline to new bitmap decoder" overwrite
; RLE/LZ bitmap decoder
; - support mapper

; Redirects calls to LoadTiles4BitRLENoDI@$0486 (decompress graphics, interrupt-unsafe version)
; to a ripped decompressor from Phantasy Star Gaiden which is stored at the above address
; Thus the remainder of the old decompressor is orphaned.
LoadTiles:
  ld a,:PSG_DECODER
  ld (PAGING_SLOT_1),a

  call PSG_DECODER

  ld a,1    ; Restore page 1
  ld (PAGING_SLOT_1),a

  ret
.ends

  ROMPosition $7e8bd
.section "Replacement title screen" overwrite
TitleScreenTiles:
.incbin "psg_encoder/title.psgcompr"
.ends

  ROMPosition $3bc68
.section "Title screen name table" overwrite
TitleScreenTilemap:
.incbin "new_graphics/title-nt.bin"
.ends

  ROMPosition $00925
.section "Title screen palette" overwrite
TitleScreenPalette:
.incbin "new_graphics/title-pal.bin"
.ends

.macro "LoadPagedTiles" args address, dest
LoadPagedTiles\1:
  ; Common pattern used to load tiles
  ld hl,PAGING_SLOT_2
  ld (hl),:address
  ld hl,dest
  ld de,address
  call LoadTiles
.endm

  ROMPosition $008f3
.section "Title screen patch" overwrite
TitleScreenPatch:
  LoadPagedTiles TitleScreenTiles $4000

  ld hl,PAGING_SLOT_2
  ld (hl),:TitleScreenTilemap
  ld hl,TitleScreenTilemap
  call DecompressToTileMapData
.ends

  ROMPosition $747b8
.section "Outside tiles" overwrite
OutsideTiles:
.incbin "psg_encoder/world1.psgcompr"
.ends
  ROMPosition $00ce4
.section "BG loader patch 1" overwrite
  LoadPagedTiles OutsideTiles $4000
.ends

  ROMPosition $58570
.section "Town tiles" overwrite
TownTiles:
.incbin "psg_encoder/world2.psgcompr"
.ends

  ROMPosition $00cf4
.section "BG loader patch 2" overwrite
  LoadPagedTiles TownTiles $4000
.ends

; Other backgrounds
; These are referenced by a structure originally at $3eca... but it is now moved.

 ROMPosition $3e8e
.section "Patch scene struct" overwrite
PatchSceneStruct1:
  ld de,SceneData-8
.ends

  ROMPosition $3e65
.section "Patch scene struct again" overwrite
PatchSceneStruct2:
  .dw SceneData-3 ; TODO: check the opcode
.ends

  ROMPosition $4396
.section "bg-vector" overwrite
SceneData: .incbin "handmade_bins/bg_vector.bin"   ; - vector table (moved)
.ends

  BinAtPosition $40000 "handmade_bins/bg_table1.bin"    ; - accompanying palette data
  BinAtPosition $40050 "psg_encoder/bg1.psgcompr"     ; - merged
  BinAtPosition $40ba7 "psg_encoder/bg2.psgcompr"
  BinAtPosition $41799 "psg_encoder/bg3.psgcompr"
  BinAtPosition $43406 "psg_encoder/bg5.psgcompr"     ; - merged w/ font (? I think not)
  BinAtPosition $44640 "handmade_bins/bg_table8.bin"  ; - accompanying palette data
  BinAtPosition $44680 "psg_encoder/bg8.psgcompr"     ; - merged
  BinAtPosition $45338 "psg_encoder/bg9.psgcompr"
  BinAtPosition $45cb0 "psg_encoder/bg10.psgcompr"
  BinAtPosition $46524 "psg_encoder/bg11.psgcompr"
  BinAtPosition $5ac8d "psg_encoder/bg13.psgcompr"    ; - no merge
  BinAtPosition $2c010 "psg_encoder/bg14.psgcompr"
  BinAtPosition $5eb6f "psg_encoder/bg16.psgcompr"
  BinAtPosition $27b24 "psg_encoder/bg29.psgcompr"
  BinAtPosition $524ea "psg_encoder/bg30.psgcompr"
  BinAtPosition $4c010 "psg_encoder/bg31.psgcompr"

/*
.bank 1 slot 1
.section "Scene data" overwrite

.macro SceneDataStruct ; structure holding scene data (palette, tiles and tilemap offsets)
.db :Palette\1
.dw Palette\1,Tiles\2
.db :Tilemap\3
.dw Tilemap\3
.endm

.macro TilesAndPalette
.section "\1 tiles" force
Palette\1: .db \3, \4, \5, \6, \7, \8, \9, \10, \11, \12, \13, \14, \15, \16, \17, \18
Tiles\1: .incbin "psg_encoder/\2.psgcompr"
.ends
.endm

SceneData:
;                Palette            Tiles               Tilemap
 SceneDataStruct PalmaOpen         ,PalmaAndDezorisOpen,PalmaOpen         ;  1 10 8000 8050 0F 8000 => 40000  40050 3C000
 SceneDataStruct PalmaForest       ,PalmaForest        ,PalmaForest       ;  2 10 8020 8BA7 0F 8333    40020  40BA7 3C333
 SceneDataStruct PalmaSea          ,PalmaSea           ,PalmaSea          ;  3 10 8040 9799 0F 86E9    40040  41799 3C6E9
 SceneDataStruct PalmaSea          ,PalmaSea           ,PalmaCoast        ;    10 8040 9799 0F 89A0    40040  41799 3C9A0
 SceneDataStruct MotabiaOpen       ,MotabiaOpen        ,MotabiaOpen       ;  5 10 B3F6 B406 0F 8C80    433F6  43406 3CC80
 SceneDataStruct DezorisOpen       ,PalmaAndDezorisOpen,DezorisOpen       ;    10 8010 8050 0F 8E46    40010  40050 3CE46
 SceneDataStruct PalmaOpen         ,PalmaAndDezorisOpen,PalmaLavapit      ;    10 8000 8050 0F 9116    40000  40050 3D116
 SceneDataStruct PalmaTown         ,PalmaTown          ,PalmaTown         ;  8 11 8640 8680 0F 947B    44640  44680 3D47B
 SceneDataStruct PalmaVillage      ,PalmaVillage       ,PalmaVillage      ;  9 11 8650 9338 0F 970A    44650  45338 3D70A
 SceneDataStruct Spaceport         ,Spaceport          ,Spaceport         ; 10 11 8660 9CB0 0F 9A2C    44660  45CB0 3DA2C
 SceneDataStruct DeadTrees         ,DeadTrees          ,DeadTrees         ; 11 11 8670 A524 0F 9C11    44670  46524 3DC11
 SceneDataStruct DezorisForest     ,PalmaForest        ,PalmaForest       ;    10 8030 8BA7 0F 8333    40030  40BA7 3C333
 SceneDataStruct AirCastle         ,AirCastle          ,AirCastle         ; 13 16 AC7D AC8D 16 BC32    5AC7D  5AC8D 5BC32
 SceneDataStruct GoldDragon        ,GoldDragon         ,GoldDragon        ; 14 0B 8000 8010 16 BE2A    2C000  2C010 5BE2A
 SceneDataStruct AirCastleFull     ,AirCastle          ,AirCastle         ;    16 3FC2 AC8D 16 BC32    53FC2  5AC8D 5BC32
 SceneDataStruct BuildingEmpty     ,Building           ,BuildingEmpty     ; 16 17 AA9F AB6F 17 8000    5EA9F  5EB6F 5C000
 SceneDataStruct BuildingWindows   ,Building           ,BuildingWindows   ;    17 AAAF AB6F 17 831E    5EAAF  5EB6F 5C31E
 SceneDataStruct BuildingHospital1 ,Building           ,BuildingHospital1 ;    17 AABF AB6F 17 8654    5EABF  5EB6F 5C654
 SceneDataStruct BuildingHospital2 ,Building           ,BuildingHospital2 ;    17 AACF AB6F 17 88DD    5EACF  5EB6F 5C8DD
 SceneDataStruct BuildingChurch1   ,Building           ,BuildingChurch1   ;    17 AADF AB6F 17 8BA6    5EADF  5EB6F 5CBA6
 SceneDataStruct BuildingChurch2   ,Building           ,BuildingChurch2   ;    17 AAEF AB6F 17 8F8E    5EAEF  5EB6F 5CF8E
 SceneDataStruct BuildingArmoury1  ,Building           ,BuildingArmoury1  ;    17 AAFF AB6F 17 92ED    5EAFF  5EB6F 5D2ED
 SceneDataStruct BuildingArmoury2  ,Building           ,BuildingArmoury2  ;    17 AB0F AB6F 17 961B    5EB0F  5EB6F 5D61B
 SceneDataStruct BuildingShop1     ,Building           ,BuildingShop1     ;    17 AB1F AB6F 17 9949    5EB1F  5EB6F 5D949
 SceneDataStruct BuildingShop2     ,Building           ,BuildingShop2     ;    17 AB2F AB6F 17 9CA3    5EB2F  5EB6F 5DCA3
 SceneDataStruct BuildingShop3     ,Building           ,BuildingShop3     ;    17 AB3F AB6F 17 9FE3    5EB3F  5EB6F 5DFE3
 SceneDataStruct BuildingShop4     ,Building           ,BuildingShop4     ;    17 AB4F AB6F 17 A310    5EB4F  5EB6F 5E310
 SceneDataStruct BuildingDestroyed ,Building           ,BuildingDestroyed ;    17 AB5F AB6F 17 A64C    5EB5F  5EB6F 5E64C
 SceneDataStruct Mansion           ,Mansion            ,Mansion           ; 29 09 BB14 BB24 09 B78B    27B14  27B24 2778B
 SceneDataStruct LassicRoom        ,LassicRoom         ,LassicRoom        ; 30 14 A4DA A4EA 1B BD63    524DA  524EA 6FD63
 SceneDataStruct DarkForce         ,DarkForce          ,DarkForce         ; 31 13 8000 8010 0D BDB1    4C000  4C010 37DB1
.ends
  
  ; TODO: these should be extracted to PNGs and then generated to bins
  TilesAndPalette DarkForce   bg31  $00,$00,$3F,$30,$38,$03,$0B,$0F,$20,$30,$34,$38,$3C,$02,$03,$01
  TilesAndPalette LassicRoom  bg30  $10,$00,$3F,$20,$25,$2A,$02,$03,$01,$06,$30,$38,$2F,$0F,$0B,$3F
  TilesAndPalette Mansion     bg29  $0B,$00,$3F,$0F,$06,$01,$03,$02,$00,$00,$00,$00,$00,$00,$00,$00
.section "Building tiles" force
PaletteBuildingEmpty:     .db $2c,$00,$3f,$3a,$28,$2c,$00,$00,$00,$00,$38,$34,$00,$00,$00,$00
PaletteBuildingWindows:   .db $2a,$00,$3f,$2a,$25,$25,$00,$00,$00,$00,$38,$34,$00,$08,$0c,$04
PaletteBuildingHospital1: .db $3f,$00,$3f,$38,$3c,$2f,$3f,$3e,$30,$00,$3c,$38,$3f,$25,$03,$00
PaletteBuildingHospital2: .db $2f,$00,$3f,$25,$06,$2a,$3f,$3e,$30,$00,$3c,$38,$3f,$25,$03,$00
PaletteBuildingChurch1:   .db $3c,$00,$3f,$30,$38,$38,$3a,$36,$31,$24,$3c,$0b,$3e,$0f,$03,$06
PaletteBuildingChurch2:   .db $2f,$00,$3f,$06,$06,$2f,$3c,$38,$34,$01,$3c,$0b,$3e,$0f,$03,$06
PaletteBuildingArmoury1:  .db $2e,$00,$3f,$2a,$29,$29,$38,$34,$20,$3d,$0b,$0f,$3d,$3a,$36,$38
PaletteBuildingArmoury2:  .db $2a,$00,$3f,$2a,$25,$25,$07,$06,$01,$0f,$38,$3d,$0b,$2a,$25,$0b
PaletteBuildingShop1:     .db $2c,$00,$3f,$3a,$28,$2c,$2a,$25,$11,$2a,$38,$34,$3e,$38,$3c,$34
PaletteBuildingShop2:     .db $2a,$00,$3f,$2a,$25,$25,$0b,$07,$06,$06,$38,$34,$0f,$08,$0c,$04
PaletteBuildingShop3:     .db $3a,$00,$3f,$25,$36,$36,$29,$28,$14,$2a,$38,$34,$2e,$38,$3c,$34
PaletteBuildingShop4:     .db $2a,$00,$3f,$25,$25,$2a,$0b,$07,$06,$06,$38,$34,$0f,$08,$0c,$04
PaletteBuildingDestroyed: .db $2a,$00,$3f,$25,$00,$2a,$00,$00,$00,$00,$34,$00,$00,$08,$0c,$04
TilesBuilding:           .incbin "psg_encoder/bg16.psgcompr"
.ends
  TilesAndPalette GoldDragon bg14 $30,$00,$3F,$30,$38,$03,$0B,$0F,$01,$02,$03,$07,$25,$2A,$2F,$20
.section "AirCastle tiles" force
PaletteAirCastle:         .db $30,$00,$3F,$0B,$06,$1A,$2F,$2A,$08,$15,$30,$30,$30,$30,$30,$30
PaletteAirCastleFull:     .db $30,$00,$3f,$0b,$06,$1a,$2f,$2a,$08,$15,$15,$0b,$06,$1a,$2f,$28
TilesAirCastle:           .incbin "psg_encoder/bg13.psgcompr"
.ends
  TilesAndPalette DeadTrees     bg11  $25,$00,$3F,$2F,$0B,$01,$06,$2A,$06,$06,$06,$06,$06,$06,$06,$06
  TilesAndPalette Spaceport     bg10  $34,$00,$3F,$01,$03,$2A,$25,$02,$0B,$3C,$00,$00,$00,$00,$00,$00
  TilesAndPalette PalmaVillage  bg9   $34,$00,$3F,$2F,$0B,$06,$01,$0C,$04,$25,$08,$2A,$3E,$3C,$38,$00
  TilesAndPalette PalmaTown     bg8   $34,$00,$3F,$2F,$0B,$06,$01,$0C,$04,$25,$08,$2A,$3E,$3C,$38,$00
  TilesAndPalette MotabiaOpen   bg5   $30,$00,$3F,$30,$34,$38,$3C,$04,$08,$0C,$0B,$06,$2F,$38,$38,$38
  TilesAndPalette PalmaSea      bg3   $30,$00,$3F,$30,$34,$38,$3C,$04,$08,$0C,$0B,$06,$2F,$38,$38,$38
.section "PalmaForest tiles" force
PalettePalmaForest:         .db $04,$00,$3F,$08,$0C,$06,$01,$0B,$00,$00,$00,$00,$00,$00,$00,$00
PaletteDezorisForest:       .db $3E,$00,$3F,$3F,$3F,$1C,$18,$3E,$00,$00,$00,$00,$00,$00,$00,$00
TilesPalmaForest:           .incbin "psg_encoder/bg2.psgcompr"
.ends
.section "PalmaAndDezorisOpen tiles" force
PalettePalmaOpen:         .db $01,$00,$3F,$2F,$0B,$06,$08,$0C,$04,$34,$00,$00,$00,$00,$00,$00
PaletteDezorisOpen:       .db $3E,$00,$3F,$3F,$3C,$38,$3C,$3F,$3C,$30,$00,$00,$00,$00,$00,$00
TilesPalmaAndDezorisOpen: .incbin "psg_encoder/bg1.psgcompr"
.ends

; Placeholders for tilemap addresses
.bank 15 slot 2
.orga $8000
TilemapPalmaOpen:
.orga $8333
TilemapPalmaForest:
.orga $86e9
TilemapPalmaSea:
.orga $89a0
TilemapPalmaCoast:
.orga $8c80
TilemapMotabiaOpen:
.orga $8e46
TilemapDezorisOpen:
.orga $9116
TilemapPalmaLavapit:
.orga $947b
TilemapPalmaTown:
.orga $970a
TilemapPalmaVillage:
.orga $9a2c
TilemapSpaceport:
.orga $9c11
TilemapDeadTrees:

.bank 22 slot 2
.orga $bc32
TilemapAirCastle:
.orga $be2a
TilemapGoldDragon:

.bank 23 slot 2
.orga $8000
TilemapBuildingEmpty:
.orga $831e
TilemapBuildingWindows:
.orga $8654
TilemapBuildingHospital1:
.orga $88dd
TilemapBuildingHospital2:
.orga $8ba6
TilemapBuildingChurch1:
.orga $8f8e
TilemapBuildingChurch2:
.orga $92ed
TilemapBuildingArmoury1:
.orga $961b
TilemapBuildingArmoury2:
.orga $9949
TilemapBuildingShop1:
.orga $9ca3
TilemapBuildingShop2:
.orga $9fe3
TilemapBuildingShop3:
.orga $a310
TilemapBuildingShop4:
.orga $a64c
TilemapBuildingDestroyed:

.bank 9 slot 2
.unbackground $27471 $2778a ; Mansion tiles
.org $2778b-$24000
TilemapMansion:

.bank 27 slot 2
.unbackground $6c000 $6f40a ; Various tiles
.org $6fd63-$6c000
TilemapLassicRoom:

.bank 13 slot 2
.org $37DB1-$34000
TilemapDarkForce:
*/

  ROMPosition $03eb0
.section "Background scene loader tile loader patch" overwrite
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

  ROMPosition $43871
.section "Font part 1" overwrite
FONT1:
.incbin "psg_encoder/font1.psgcompr"
.ends

  ROMPosition $43bb4
.section "Font part 2" overwrite
FONT2:
.incbin "psg_encoder/font2.psgcompr"
.ends

; Originally t0b.asm

  ROMPosition $045a4
.section "Intro font loader" overwrite
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
.section "Font patch 1" overwrite
FontPatch1:
  ; Load game font decoding
  call DECODE_FONT
  jr +$12
.ends

  ROMPosition $10e3
.section "Font patch 2" overwrite
FontPatch2:
  ; Dungeon font decoding
  call DECODE_FONT
  jr +$12
.ends

  ROMPosition $3dde
.section "Font patch 3" overwrite
FontPatch3:
  ; In-game font decoding
  call DECODE_FONT
  jr +$12
.ends

  ROMPosition $48da
.section "Font patch 4" overwrite
FontPatch4:
  ; Cutscene font decoding
  call DECODE_FONT
  jr +$12
.ends


; TODO: whats this?
  ROMPosition $697c
.section "Unknown patch" overwrite
FontPatch5:
  call DECODE_FONT2 ; (halfway through new loader, for just the second font group)
.ends


; Font renderer
; Originally t0d.asm

  ROMPosition $34f2
.section "Character drawing" overwrite
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
      adc a,b       ; overflow accounting
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

  ROMPosition $8000
.section "Font lookup" overwrite
FontLookup:
; This is used to convert text from the game's encoding (indexing into ths area) to name table entries. The extra spaces are unused (and could be repurposed?).
.dwm Text " 0123456789"
.dwm Text "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.dwm Text "abcdefghijklmnopqrstuvwxyz"
.dwm Text ".:`',  -!?               "
.ends

; Semi-adaptive Huffman script decoder

  ROMPosition $80b0
.section "Huffman tree vector" overwrite ; may need to be at $80b0?
TREE_PTR:
.incbin "script_inserter/tree_vector.bin"    ; Tree vectors
.ends
  ROMPosition $82b0
.section "Huffman tree" overwrite ; may need to be at $82b0?
ScriptTrees:
.incbin "script_inserter/script_trees.bin"   ; - actual Huffman trees
.ends

  ROMPosition $bf50
.section "Decoder init" overwrite
DecoderInit:
; Originally t4a_1.asm
;
; Semi-adaptive Huffman decoder
; - Init decoder
;
; Written in TASM 3.0.1
;

.define CODE $7fd8c/$4000 ; bank with 'backup' code TODO what is this?

  push af     ; Save routine selection

    ld a,CODE   ; Map in new page 1
    ld (PAGING_SLOT_1),a
  
    ld a,EOS    ; Starting tree symbol
    ld (TREE),a
  
    ld a,$80    ; Initial tree barrel
    ld (BARREL),a
  
    ld (SCRIPT),hl    ; Beginning script offset
  
    xor a     ; A = $00
    ld (POST_LEN),a   ; No post hints
    ld (LINE_NUM),a   ; No lines drawn
    ld (FLAG),a   ; No wait flag
;   ld (PLAYER),a   ; Do not reset (assume proper usage)
    ld (ARTICLE),a    ; No article usage
    ld (SUFFIX),a   ; No suffix flag

  pop af      ; Choose code reloading method
  or a
  jr nz,+

; Cutscene handler
  ld de,$7c42   ; Old code
  ld bc,$0000
  ld a,$06    ; Set internal wrapping limit
  ld (VLIMIT),a

  xor a
  call $34b0    ; Allow remapping of page 1 upon exit ; TODO what is this? In ShowNarrativeText in dasm
  jr ++

+:            ; In-game scripter
  ld a,$4     ; Set internal wrapping limit ; TODO what is this?
  ld (VLIMIT),a

  ld a,($c2d3)    ; Old code
  or a
  call $3343    ; Allow remapping of page 1 upon exit ; TODO what is this?

++:
  ld a,1    ; Put back old 'page 1'
  ld (PAGING_SLOT_1),a

  ret

.ends

  ROMPosition $3eca
.section "Dictionary lookup" overwrite
  ; HL = Table offset

DictionaryLookup:
  push af
    ld a,$77000/$4000 ; Load normal lists
    ld (PAGING_SLOT_2),a
    jr +

DictionaryLookup_Substring:
  push af
    ld a,$43c00/$4000 ; Load dictionary
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

  ROMPosition $bed0

.section "SFG decoder" overwrite
SFGDecoder:
; Originally t4a.asm

; Semi-adaptive Huffman decoder
; - Shining Force Gaiden: Final Conflict
;

; Start of decoder
;
; Note:
; The Z80 uses one set of registers for decoding the Huffman input data
; The other context is used to traverse the Huffman tree itself
;
; Encoded Huffman data is in page 2
;
; Huffman tree data is in page 2
; The symbols for the tree are stored in backwards linear order

.define TREE_BANK 2   ; bank containing Huffman trees ($8000-$BFFF)

  push hl

    ld a,(PAGING_SLOT_1)    ; Save current page 1
    push af

      ld a,$6f000/$4000 ; Load in script bank #2
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

        JR _Tree_Shift1    ; Need status of termination

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

  ROMPosition $7fe00, 1
.section "Additional scripting codes" overwrite
AdditionalScriptingCodes:
; Originally t4a_2.asm

; Narrative formatter
; - Extra scripting codes

_Start:
  call SubstringFormatter    ; Check substring RAM

  cp NEWLINE
  jr z,_No_decode

  cp EOS      ; Look for decode flag
  jp nz,_Done

_Decode:
  call SFGDecoder    ; Regular decode

_No_decode:

_Code1:
  cp $59      ; Post-length hints
  jr nz,_Code2   ; Check next code

  call SFGDecoder    ; Grab length
  ld (POST_LEN),A   ; Cache it
  jr _Decode   ; Immediately grab next code

_Code2:
  cp $00      ; Whitespace
  jr nz,_Code3   ; Check next code

  push hl
    ld (TEMP_STR),a   ; Store WS, $00
    inc a             ; A = $01
    ld (LEN),a        ; Store length
    ld hl,TEMP_STR    ; Load string location
    ld (STR),hl       ; Store string pointer
  pop hl

  call SubstringFormatter    ; Our new dictionary lookup code will do auto-formatting

  ; Intentional fall-through

_Code3:
  cp $55      ; - wait more
  jr nz,_Code4

_Reset_Lines:
  push af
    xor a

_Set_Lines:
    ld (LINE_NUM),a   ; Clear # lines used
  pop af

  jp _Done

_Code4:
  cp $54      ; Newline check
  jr nz,_Code5   ; Next code

  push hl     ; Automatic narrative waiting

    ld hl,LINE_NUM    ; Grab # lines drawn
    inc (hl)    ; One more line _Break
    ld l,(hl)   ; Load current value

    ld a,(VLIMIT)   ; Read vertical limit
    cp l      ; Check if limit reached
    jr z,_WAIT

_NO_WAIT:
    ld a,NEWLINE    ; Reload newline
    jr _Code4_End

_WAIT:
    ld a,$55    ; wait more
    ld (FLAG),a   ; Raise flag
    ld hl,LINE_NUM

_Wait_Clear:
    dec (hl)    ; Keep shrinking # lines drawn
    jr nz,_Wait_Clear  ; to save 1 byte of space

_Code4_End:
  pop hl      ; Restore stack
  jr _Done

_Code5:
  cp $60
  jr c,_Code6    ; Control codes, don't interfere

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

_Code6:
  cp $5A      ; Use article
  jr nz,_Code7

  call SFGDecoder    ; Grab #
  ld (ARTICLE),a
  jp _Decode

_Code7:
  cp $5B      ; Use suffix
  jr nz,_Code8

  ld a,(SUFFIX)   ; Check flag
  or a
  jp z,_Decode   ; No 's' needed

  ld a,LETTER_S   ; add 's'

_Code8:

_Done:
  cp $58      ; Old code
  ret     ; Go to remaining text handler

.ends

  ROMPosition $7fed0, 1
.section "Substring formatter" overwrite
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

_Check_Autowait:
  ; LD A,(FLAG)   ; Scan flag
  ; OR A      ; See if auto-wait occurred
  ; JR Z,Lookup   ; Not raised

  ; XOR A     ; Lower flag
  ; LD (FLAG),A
  ; XOR A     ; Reset it to zero
  ; LD (LINE_NUM),A
  ; LD A,NEWLINE    ; Need to emit a newline [NOT NEEDED]
  ; RET     ; No decoding needed

_Lookup:
  ld a,(LEN)    ; Grab length of string
  or a      ; Check for zero-length
  ld a,EOS    ; Load 'abort' flag
  ret z     ; Return if NULL

_Substring:
  ld a,b      ; Save width
  ld (HLIMIT),a

  push hl     ; Stack registers
  push bc

    ld bc,(STR)   ; Grab raw text location
    ld hl,LEN   ; Grab address of length

    ; ------------------------------------------------------
    ; Article (The, An, A, Some) handler

    push de     ; init

      ld a,(ARTICLE)    ; Check for article usage
      or a
      jr z,_Art_Exit   ; article = none

      ld de,TAB1
      cp $01      ; article = a,an,the
      jr Z,_Start_Art

      ld de,TAB2
      ; CP $02      ; article = A,AN,THE
      ; JR Z,_Start_Art

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
      cp EOS
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

; Articles in 'reverse' order

TAB1: .dw ART_11, ART_12, ART_13
ART_11: .db $00,$25,EOS     ; 'a '
ART_12: .db $00,$32,$25,EOS   ; 'an '
ART_13: .db $00,$29,$2c,$38,EOS   ; 'the '
ART_14: .db $00,$29,$31,$33,$37,EOS ; 'some '

TAB2: .dw ART_21, ART_22, ART_23
ART_21: .db $00,$0b,EOS     ; 'A '
ART_22: .db $00,$28,$0b,EOS   ; 'An '
ART_23: .db $00,$29,$2c,$1e,EOS   ; 'The '
ART_24: .db $00,$29,$31,$33,$1d,EOS ; 'Some '

_Initial_Codes:
    ld a,(bc)   ; Grab character
    cp $4f      ; Skip initial codes
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
    ld a,NEWLINE    ; newline

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

  cp $4f      ; Control codes
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
.section "Cutscene narrative init" overwrite
CutsceneNarrativeInit:
  ld a,0 ; method selection
  call DecoderInit
  ret
.ends

  ROMPosition $34b4
.section "Cutscene text decoder" overwrite
CutsceneTextDecoder:
  call AdditionalScriptingCodes
  jr z,OrderFlip ; = order flip
  cp $57
  jr z,OrderFlip+5 ; = ??? TODO
.ends

  ROMPosition $34e5
.section "Cutscene $55 clear code" overwrite
CutsceneClearCode:
  jp $bf77 ; TODO
OrderFlip:
.ends

  ROMPosition $333f
.section "In-game narrative init" overwrite
InGameNarrativeInit:
  dec a ; = method selection ($01)
  jp DecoderInit
.ends

  ROMPosition $3365
.section "In-game text decoder" overwrite
InGameTextDecoder:
  call AdditionalScriptingCodes
.ends


; Narrative scripting

  ROMPosition $33da
.section "Item lookup" overwrite
ItemLookup:
; Originally t1c_1.asm

;
; Item lookup
;

  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,($c2c4)    ; Grab item #
    ld hl,Items   ; Item lookup

LookupItem:
    call DictionaryLookup

  pop bc
  pop de
  pop hl
  jp InGameTextDecoder    ; Decode next byte
.ends

  ROMPosition $33aa
.section "Player lookup" overwrite
PlayerLookup:
; Originally t1c_2.asm

;
; Player lookup
;

  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,($C2C2)    ; Grab item #
    and $03

    ld hl,Names
    jp LookupItem
.ends

  ROMPosition $33c8
.section "Enemy lookup" overwrite
EnemyLookup:
; Originally t1c_3.asm

;
; Enemy lookup
;
  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,($c2e6)    ; Grab enemy #

    ld hl,Enemies
    jp LookupItem
.ends

  ROMPosition $33f6
.section "Number lookup" overwrite
NumberLookup:
; Originally t1b.asm

;
; Narrative number BCD creater
;

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

    ld hl,($c2c5)    ; Load 16-bit parameter
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
  or a         ; Clear carry flag

; subtract bc from hl until it overflows, then add it on again
; return a = number of subtractions done until overflow occurred,
;        hl = hl % bc
; so a = hl / bc + 1 (integer division + 1)
; eg. hl =  9999, bc = 10000, a = 1
; eg. hl = 10000, bc = 10000, a = 2
_BCD_Loop:
  sbc hl,bc    ; Divide by subtraction
  inc a        ; Bump place marker
  jr nc,_BCD_Loop ; No underflow

  add hl,bc    ; Restore value from underflowed subtraction
  ret
.ends

  ROMPosition $0003f
.section "VBlank intercept" overwrite
VBlankIntercept:
  jp VBlankPageSave ;$0494
.ends

  ROMPosition $00494
.section "VBlank page saving" overwrite
VBlankPageSave:
  ; We wrap the handler to select page 1 in slot 1 and then restore it
  ld a,(PAGING_SLOT_1)    ; Save page 1
  push af

    ld a,1    ; Regular page 1
    ld (PAGING_SLOT_1),a

    call VBlank ; $127    ; Resume old code

  pop af
  ld (PAGING_SLOT_1),a    ; Put back page 1

  pop af      ; Leave ISR manually
  ei
  ret
.ends

  ROMPosition $182
.section "Original VBlank handler no ei/reti" overwrite
OriginalVBlankHandlerPatch:
  ret
.ends

; Lists

.asciitable
; matches the .tbl files used elsewhere
map ' ' = $00
map '0' to '9' = $01 
map 'A' to 'Z' = $0b
map 'a' to 'z' = $25
 ; Punctuation
 map '.' = $3F
map ':' = $40
;map '‘' = $41 ; UTF-8 not working :(
;map '’' = $42
map "'" = $42
map ',' = $43
map '-' = $46
map '!' = $47
map '?' = $48
; Scripting codes
map '+' = $4F ; Conditional space (soft wrap point)
map '@' = $50 ; Newline (when in a menu)
map '%' = $51 ; Hyphen (when wrapped)
map '[' = $52 ; [] = do not draw in menus, only during narratives
map ']' = $53
; Articles
map '~' = $54 ; a
map '#' = $55 ; an
map '^' = $56 ; the
map '&' = $57 ; some
.enda

.macro String args s
.db s.length
.asc s
.endm

  ROMPosition $76ba6
.section "Enemy, name, item lists" overwrite

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
.section "Static dictionary" overwrite
Words:
.include "substring_formatter/words.asm"
; Terminator
.db $df
.ends

; English script

  ROMPosition $59ba
.section "Index table remap" overwrite
IndexTableRemap:
  jp TextBox20x6 ; see 'script_list.txt' for auto-generated
.ends

; Menus

  ROMPosition $46c81
.section "Menu data" overwrite
MenuData:
.include "menu_creater/menus.asm"

  PatchB $3b82 :MenuData
  PatchB $3bab :MenuData
  
  ; Enemy name VRAM
  PatchW $3259 $7818
  PatchW $3271 $7818
  PatchW $331e $7818
  
  ROMPosition $3211
.section "HP letters" overwrite
.dwm Text "HP"
.ends

  ROMPosition $3219
.section "MP letters" overwrite
.dwm Text "MP"
.ends

  ; Choose player: width*2
  PatchB $37c8 $10

  ROMPosition $3de4
.section "Active player - menu offset finder" overwrite
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
.section "Trampoline to above" overwrite
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
.section "Spell selection finder" overwrite
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
.section "Spell blank line" overwrite
SpellBlankLine:
; Originally t2b_2.asm
; Spell selection blank line drawer
; - support code

.define LINE_SIZE (10+2)*2  ; width of line

  ; TODO could do this more simply - we want hl = base + b * LINE_SIZE above

  push de
    ld de,LINE_SIZE   ; menu size
    ld a,b            ; init
    inc a
    call Add16        ; 16-bit addition
    ld de,0           ; auto-generated base value TODO I guess this is filled in later
    add hl,de
  pop de
.ends

  ROMPosition $3494
.section "Spell blank line - addition" overwrite
; Originally t2b_3.asm
; Spell selection blank line drawer
; - addition

Add16:
  ; hl = (a-1) * de
  ld h,0
  ld l,h

-:dec a       ; loop
  jr z,+      ; TODO: could ret z
  add hl,de   ; skip menu
  jr -

+:ret
.ends

  PatchB $35d4 $0c  ; - height

  ROMPosition $3516
.section "Stats menu part 1" overwrite
Level: .dwm Text "|Level   "
MST:   .dwm Text "|MST    "
.ends

  PatchW $3911 Level  ; - LV source
  PatchW $36e7 MST    ; - MST source

  ROMPosition $3982
.section "Stats menu part 2" overwrite
EXP:      .dwm Text "|EXP     "
Attack:   .dwm Text "|Attack  "
Defense:  .dwm Text "|Defense "
MaxHP:    .dwm Text "|Max HP  "
MaxMP:    .dwm Text "|Max MP   "
.ends

  PatchW $391a EXP    ; - EXP source
  PatchB $31a3 $0e    ; - width * 2
  PatchB $36dd $0e

  PatchW $392f Attack   ; - Attack source
  PatchW $3941 Defense  ; - Defense source
  PatchW $3953 MaxHP    ; - Max HP source
  PatchW $3965 MaxMP    ; - Max MP source
  PatchB $3145 $12      ; - width * 2

  PatchW $363f $78a8    ; Inventory VRAM (2 tiles left)
  PatchW $3778 $78a8
  PatchW $364b $78a8
  PatchB $36e5 $0c      ; - width * 2
  PatchW $3617 $7928    ; - VRAM cursor

  PatchW $3b18 $7bcc  ; Store MST VRAM
  PatchW $3b41 $7bcc
  PatchW $3b26 $7bcc

  PatchW $3a40 $784c    ; Shop inventory VRAM

  PatchB $3b58 $11      ; Hapsby travel (bank)
  PatchW $3b63 $7b2a    ; - VRAM cursor
  PatchW $3b4f $7aea    ; - move window down 1 tile
  PatchW $3b76 $7aea

  PatchW $3835 $7a88    ; Equipment VRAM
  PatchW $3829 $7a88
  PatchW $386e $7a88
  
  ROMPosition $5aadc
.section "Opening cinema" overwrite
Opening:
.include "menu_creater/opening.asm"

  PatchB $45d7 :Opening ; - source bank

; relocate Tarzimal's tiles (bug in 1.00-1.01 caused by larger magic menus)
  BinAtPosition $420e0 "handmade_bins/tiles-tarzimal.bin"
; rewire pointer to them (page $10, offset $a0e0)
  PatchB $ccaf $10
  PatchW $ccb0 $a0e0
  
  
  ROMPosition $2fe3e 1
.section "scripting code" overwrite
; Originally t2a.asm

;
; Item window drawer (generic)
;

inventory:
  ld b,8    ; 8 items total

_next_item:
  push bc
  push hl

    di
      ld a,$7f000/$4000 ; move to page 0
      ld ($fff0),a

; FIX: I've changed this to not use paging in slot 0 because too many
; emulators, and the GG/SMSPro flash carts, don't support it.
; Rather than fix up a load of references, I've instead left these in
; taking space but harmlessly writing to $fff0 instead.
; TODO: fix this!

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM ; changed address
      pop de

      ld a,$00    ; reload page 0
      ld ($fff0),a
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

_next_shop:
  push bc
  push hl

    di
      ld a,$7f000/$4000 ; move to page 0
      ld ($fff0),a

      ld a,$03    ; shop bank
      ld (PAGING_SLOT_2),a

      ld a,(hl)   ; grab item #
      ld (FULL_STR),hl  ; save current shop ptr
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM
      pop de

      ld a,$00    ; reload page 0
      ld ($fff0),a
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out 2 lines of text

    push hl     ; hacky workaround
    push de
      ld c,$01    ; write out price
      call _shop_price
    pop de
    pop hl
    ld a,$02    ; restore page 2
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
  djnz _next_shop

  ret


enemy:
  di
    ld a,$7f000/$4000 ; move to page 0
    ld ($fff0),a

    ld a,$03    ; shop bank
    ld (PAGING_SLOT_2),a

    ld a,($c2e6)    ; grab enemy #
    ld hl,Enemies   ; table start

    push de
      call DictionaryLookup    ; copy string to RAM
    pop de

    ld a,$00    ; reload page 0
    ld ($fff0),a
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
      ld a,$7f000/$4000 ; move to page 0
      ld ($fff0),a

      ld a,$03    ; shop bank
      ld (PAGING_SLOT_2),a

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM
      pop de

      ld a,$00    ; reload page 0
      ld ($fff0),a
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
      ld a,$f3    ; left border
      out ($be),a

      push af     ; Delay
      pop af
      ld a,$11    ; Top border?  
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

_newline:
      cp $50      ; pad rest of line with WS
      jr nz,_hyphen

_newline_flush:
      xor a
      call _write_nt
      djnz _newline_flush

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
      ld a,$f3
      out ($be),a

      push af
      pop af
      ld a,$13
      out ($be),a

    pop de      ; restore stack
    pop bc

    push hl
      ld hl,10*2+2    ; left border + 10-char width
      add hl,de   ; save VRAM ptr
      ld (FULL_STR+2),hl

      ld hl,$0040   ; VRAM newline
      add hl,de
      ex de,hl
    pop hl

  ei      ; wait for vblank
  ret

_write_nt:
      add a,a     ; lookup NT
      ld de,$8000
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

        ld a,$03    ; shop bank
        ld (PAGING_SLOT_2),a

        ld hl,(FULL_STR)  ; shop ptr

        ld a,(hl)   ; check for blank item
        or a
        jr nz,_write_price
        ld c,$00    ; no price

_write_price:
        push de     ; parameter
        push hl     ; parameter
          jp $3a9a    ; write price

.ends


  ROMPosition $3671
.section "inventory setup code" overwrite
; Originally t2a_1.asm

; Item window drawer (inventory)
; - setup code

  ld a,$2f000/$4000 ; jump to page 1
  ld (PAGING_SLOT_1),a

  call inventory

  ld a,$01    ; old page 1
  ld (PAGING_SLOT_1),a

  nop
  nop

  ; 0 bytes left
.ends

  ROMPosition $3a1f
.section "shop setup code" overwrite
; Originally t2a_2.asm

; Item window drawer (shop)
; - setup code

  ld a,$2f000/$4000 ; jump to page 1
  ld (PAGING_SLOT_1),a

  call shop

  ld a,$01    ; old page 1
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
.section "enemy setup code" overwrite
; Originally t2a_3.asm

; Enemy window drawer
; - setup code

  ld a,$2f000/$4000 ; jump to page 1
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
.section "equipment setup code" overwrite
; Originally t2a_4.asm

; Equipment window drawer
; - setup code

  ld a,$2f000/$4000 ; jump to page 1
  ld (PAGING_SLOT_1),a

  call equipment

  ld a,$01    ; old page 1
  ld (PAGING_SLOT_1),a

  nop
.ends

; Extra scripting

  ROMPosition $59bd
.section "Dezorian string" overwrite
; Originally t5.asm

; Extra scripting

  cp $ff      ; custom string [1E7]
  jr nz,$59ca-CADDR-1

  ld hl,$0000   ; dummy string, auto-replace
  jr $59ba-CADDR-1
.ends

  PatchB $eec9 $ff      ; - scripting code
  PatchW $49b0 $59bd    ; - JP NC,$59bd

; Window RAM cache

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
.section "Newline patch" overwrite
; Originally tx1.asm

; Text window drawer multi-line handler

newline:
    ld b,$12 ; reset x counter                              ; 06 xx
    inc hl   ; move pointer to next byte                    ; 23
    ld a,c   ; get line counter                             ; 79
    or a     ; test for c==0                                ; b7
    jr nz,_not_zero                                         ; xx xx
    ; zero: draw on 2nd line
    ld de,$7d0e                                             ; xx xx xx
_inc_and_finish:
    inc c                                                   ; xx
    jp InGameTextDecoder                                    ; xx xx xx
_not_zero:
    dec a    ; test for c==1                                ; 3d
    jr nz,_not_one                                          ; xx xx
    ; one: draw on 3rd
_draw_3rd_line:
    ld de,$7d4e                                             ; xx xx xx
    jr _inc_and_finish                                      ; xx xx
_not_one:
    dec a    ; test for c==2                                ; 3d
    jr nz,_not_two                                          ; xx xx
    ; two: draw on 4th
_draw_4th_line:
    ld de,$7d8e                                             ; xx xx xx
    jr _inc_and_finish                                      ; xx xx
_not_two:
    ; three: scroll, draw on 4th line
    call $3546 ; scroll                                     ; xx xx xx ; TODO: label
    dec c      ; cancel increment                           ; xx
    jr _draw_4th_line                                       ; xx xx
.ends

  ROMPosition $3397
.section "Newline patch trampoline" overwrite
  jp $000f
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
  BinAtPosition $3f02 "handmade_bins/save_tiles.bin"
  PatchW $42cd $3f02 ; rewire pointer

; "Enter your name" text at the top of the screen
  ROMPosition $4059
.section "Enter your name text" overwrite
EnterYourName:
.dwm Text "Enter your name:"
.ends

  PatchW $41c5 EnterYourName ; rewire pointer
  PatchW $41cb $0120   ; bc parameter = bytes per line, number of lines
  PatchW $41d2 $7850   ; de parameter = where to draw (8,1)
  PatchB $41d6 $28     ; change function call to full raw tilemap drawer

  PatchW $41e4 $3f3a   ; subvert call to output TileMapData to the screen
  
  ROMPosition $3f3a
.section "Name entry screen extended characters" overwrite
; Originally tx4.asm

; Name entry screen patch to draw extended characters

; OutputTilemapRawDataBox: ; $0428
; So hl = tilemap data (both bytes)
; b = height /tiles
; c = 2*width /tiles
; de = VRAM location

    call $03de  ; the call I stole to get here
    ld bc,$010e ; 14 bytes per row, 1 row
    ld de,$7bec ; Tilemap location 22,15
    ld hl,data
    call OutputTilemapRawDataBox  ; output raw tilemap data
    ret

data:
.dwm TextLowPriority ",:-!?`'"

.ends

  ROMPosition $4221
.section "Name entry cursor initial data" overwrite
.db $18, $60 ; x, y in screen coordinates
.dw $d30a ; x, y in RAM (?)
.db $0b ; pointed value is 'A'
.ends

  PatchB $4130 $18 ; min sprite x
  PatchB $40eb $e0 ; max sprite x
  PatchB $4102 $60 ; min sprite y
  PatchB $4119 $90 ; max sprite y

  PatchB $4344 $1a ; width of lookup table
  PatchB $4342 $04 ; height of lookup table - width*height<=126
  PatchB $434e $4c ; width complement, = $80-(4344)*2
  
  ROMPosition $448e
.section "Save lookup" overwrite
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
.section "Name entry 4-sprite cursor trampoline" overwrite
  call NameEntryCursor
  nop ; to fill space for patch
.ends
  ROMPosition $4a7
.section "Name entry 4-sprite cursor hack" overwrite
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
.section "Drawing to RAM as you enter" overwrite
; Originally tx2.asm

; Name entry screen patch for code that writes to the in-RAM name table copy

WriteLetterIndexAToDE: ; $429b
; parameters:
; de = where to write tile data (pointing to lower tile of pair)
; a = char number (space = 0)
; returns:
; c = low byte of name table value
; a = high byte
  push hl
    ex de,hl
    ld hl,PAGING_SLOT_2
    ld (hl),$02
    ld hl,$8000
    ld c,a
    ld b,$00
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
.section "Drawing to screen as you enter" overwrite
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
  BinAtPosition $53dbc "credits/credits.bin"               ; 577/580 bytes
  
  ROMPosition $488c
.section "Credits hack" overwrite
  ld hl,$5820
  ld de,$bdee
  call LoadTiles
.ends
  
  BinAtPosition $3fdee "psg_encoder/font3.psgcompr"   ;  411/530 bytes

  ROMPosition $00056
.section "HALT on idle polling loop" force
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
.section "Press Pause on the title screen to toggle PSG/FM - trampoline" overwrite
  ; There are 3 spare bytes at $66 that I can use. I move the following two opcodes up (as I need them anyway) and then call my handler...
  ; 
  push af
    ld a,(FunctionLookupIndex)
    call PauseFMToggle
.ends

  ROMPosition $3f58
.section "Press Pause on the title screen to toggle PSG/FM - implementation" overwrite
PauseFMToggle:
  cp 3          ; Indicates we are on the title screen
  ret nz
  ld a,(IntroState)
  cp $ff
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

; checksum (needs changing whenever anything changes)
  PatchW $7ffa $d6ac
; Can be replaced with:
;.computesmschecksum
; ...when we are hapy to let WLA DX default to a smaller checksum range.

; Stuff from script_list.txt
; TODO: generate it instead
  BinAtPosition $8cd4 "script_inserter/script1.bin"
  PatchW $4b49 $8cd4
  PatchW $4b4f $8d14
  PatchW $4b63 $8d31
  PatchW $4b7d $8d7b
  PatchW $4b83 $8d90
  PatchW $4b89 $8da9
  PatchW $4b8f $8dc1
  PatchW $4b95 $8dd6
  PatchW $4b9b $8df2
  PatchW $4bbb $8e08
  PatchW $4bc1 $8e1c
  PatchW $4bce $8e30
  PatchW $4c27 $8e30
  PatchW $4cc3 $8e30
  PatchW $4d0f $8e30
  PatchW $4bdb $8e46
  PatchW $4d24 $8e46
  PatchW $4be1 $8e58
  PatchW $4c3b $8e58
  PatchW $4cd6 $8e58
  PatchW $4d19 $8e58
  PatchW $4d2e $8e58
  PatchW $5498 $8e58
  PatchW $4bf2 $8e65
  PatchW $4bf8 $8e71
  PatchW $4bfe $8e81
  PatchW $4c04 $8eb0
  PatchW $4c0a $8ec5
  PatchW $4c10 $8ee2
  PatchW $4da8 $8f12
  PatchW $4dad $8f50
  PatchW $4db7 $8f5f
  PatchW $4dbc $8f99
  PatchW $4dc2 $8fbc
  PatchW $4dc8 $8fd0
  PatchW $4dce $9000
  PatchW $4dd4 $901d
  PatchW $4dda $903b
  PatchW $4de0 $905e
  PatchW $4de6 $909b
  PatchW $4dec $90b4
  PatchW $4df2 $90c3
  PatchW $4df8 $90ef
  PatchW $4dfe $9115
  PatchW $4e18 $9151
  PatchW $4e1e $9178
  PatchW $4e2c $9190
  PatchW $4baa $91a3
  PatchW $4e07 $91a3
  PatchW $4e27 $91a3
  PatchW $4ba1 $91a9
  PatchW $4bb5 $91b2
  PatchW $4c9f $9202
  PatchW $4ca5 $9216
  PatchW $4cab $9232
  PatchW $4c1e $925a
  PatchW $4cb8 $925a
  PatchW $4d34 $9263
  PatchW $4d45 $9272
  PatchW $4d56 $9299
  PatchW $4d6d $92b2
  PatchW $4d92 $92c6
  PatchW $4d3f $92e1
  PatchW $4d78 $92e1
  PatchW $4ecb $92e1
  PatchW $4d50 $92f2
  PatchW $4d61 $92f2
  PatchW $4e32 $9302
  PatchW $4e38 $930d
  PatchW $4e3e $931f
  PatchW $4e44 $9344
  PatchW $4e4a $9353
  PatchW $4e50 $9368
  PatchW $4e56 $9375
  PatchW $4e5c $9388
  PatchW $4e62 $9394
  PatchW $4e80 $93a5
  PatchW $4e8b $93de
  PatchW $4e99 $93ee
  PatchW $4eaa $9414
  PatchW $5628 $9439
  PatchW $564c $944b
  PatchW $5652 $9468
  PatchW $5633 $9475
  PatchW $4f1a $9484
  PatchW $4f14 $957f
  PatchW $4fc7 $957f
  PatchW $53c5 $9593
  PatchW $53e0 $95ac
  PatchW $53ca $95c1
  PatchW $4fd5 $95c6
  PatchW $4fdb $95ca
  PatchW $4ffa $95dd
  PatchW $500c $95eb
  PatchW $5035 $95eb
  PatchW $533b $95eb
  PatchW $54aa $95eb
  PatchW $5029 $9602
  PatchW $5017 $9647
  PatchW $5040 $9647
  PatchW $54b5 $9647
  PatchW $5050 $9654
  PatchW $507c $969f
  PatchW $4c31 $96e7
  PatchW $4cd0 $96e7
  PatchW $54cb $96e7
  PatchW $50a8 $96f0
  PatchW $50d2 $96fd
  PatchW $546e $9724
  PatchW $50df $9737
  PatchW $5072 $974d
  PatchW $5097 $9760
  PatchW $510e $977c
  PatchW $5429 $977c
  PatchW $5454 $978a
  PatchW $545f $97a6
  PatchW $5465 $97c3
  PatchW $5478 $97ea
  PatchW $5486 $980e
  PatchW $549e $9819
  PatchW $55e1 $9819
  PatchW $54c5 $9832
  PatchW $54d1 $9852
  PatchW $54e5 $985d
  PatchW $54eb $9888
  PatchW $54f1 $9898
  PatchW $550d $98bd
  PatchW $5430 $98e8
  PatchW $5437 $9910
  PatchW $57ed $9943
  PatchW $5513 $995d
  PatchW $5519 $996d
  PatchW $551f $997f
  PatchW $5000 $9994
  PatchW $50ec $99d3
  PatchW $5006 $9a4c
  PatchW $5525 $9a7a
  PatchW $513a $9a93
  PatchW $511a $9abc
  PatchW $5120 $9af6
  PatchW $5126 $9b25
  PatchW $512f $9b30
  PatchW $5114 $9b4c
  PatchW $5140 $9ba5
  PatchW $5146 $9bad
  PatchW $514c $9bcc
  PatchW $54df $9c3d
  PatchW $5152 $9c78
  PatchW $5158 $9c85
  PatchW $57be $9ce9
  PatchW $515e $9d11
  PatchW $5164 $9d19
  PatchW $516a $9d38
  PatchW $5170 $9d4a
  PatchW $5195 $9d6e
  PatchW $5176 $9da1
  PatchW $5134 $9dae
  PatchW $517f $9dae
  PatchW $54da $9dae
  PatchW $54ff $9dae
  PatchW $518f $9db5
  PatchW $2dac $9de0
  PatchW $2db1 $9df9
  PatchW $2ddd $9e19
  PatchW $5531 $9e52
  PatchW $54fa $9e7a
  PatchW $5542 $9eba
  PatchW $5553 $9eba
  PatchW $5564 $9eba
  PatchW $5548 $9ec0
  PatchW $553c $9ed1
  PatchW $5559 $9eea
  PatchW $556a $9eff
  PatchW $5575 $9f10
  PatchW $557b $9f1e
  PatchW $5586 $9f24
  PatchW $5598 $9f45
  PatchW $55a1 $9f57
  PatchW $55a6 $9f6c
  PatchW $519b $9f74
  PatchW $51a1 $9f7b
  PatchW $51a7 $9f93
  PatchW $51ad $9f98
  PatchW $51b3 $9fd4
  PatchW $51b9 $9ff5
  PatchW $51cc $a001
  PatchW $57e1 $a031
  PatchW $51c2 $a052
  PatchW $51d2 $a07a
  PatchW $51d8 $a090
  PatchW $51de $a0c7
  PatchW $51e4 $a0db
  PatchW $51ea $a0ef
  PatchW $51f0 $a10c
  PatchW $51f6 $a149
  PatchW $5202 $a179
  PatchW $5227 $a1b5
  PatchW $521e $a1bd
  PatchW $520d $a1dc
  PatchW $4ced $a1f1
  PatchW $4cfe $a21d
  PatchW $5239 $a22d
  PatchW $523f $a240
  PatchW $5245 $a257
  PatchW $524b $a278
  PatchW $5251 $a2c3
  PatchW $5257 $a2f9
  PatchW $525d $a31c
  PatchW $5263 $a331
  PatchW $5269 $a344
  PatchW $526f $a393
  PatchW $5275 $a3d0
  PatchW $527b $a3f4
  PatchW $5281 $a417
  PatchW $5287 $a445
  PatchW $528d $a48e
  PatchW $529b $a49e
  PatchW $5296 $a4ad
  PatchW $52a1 $a4bd
  PatchW $52a7 $a4cc
  PatchW $52b3 $a4e7
  PatchW $52b9 $a50a
  PatchW $52bf $a526
  PatchW $52c5 $a544
  PatchW $59c2 $a553
  PatchW $52cb $a569
  PatchW $52d7 $a585
  PatchW $52e2 $a5bd
  PatchW $52f3 $a5cd
  PatchW $5301 $a5e3
  PatchW $5307 $a64f
  PatchW $5310 $a669
  PatchW $5315 $a679
  PatchW $531b $a68c
  PatchW $5321 $a6a0
  PatchW $5327 $a6bf
  PatchW $5330 $a6d3
  PatchW $5335 $a6e8
  PatchW $5356 $a6fd
  PatchW $53a6 $a6fd
  PatchW $5346 $a705
  PatchW $502f $a70c
  PatchW $5056 $a70c
  PatchW $535c $a70c
  PatchW $5362 $a717
  PatchW $584a $a71c
  PatchW $58eb $a71c
  PatchW $561a $a749
  PatchW $5614 $a780
  PatchW $552b $a79b
  PatchW $55b4 $a7af
  PatchW $55c6 $a7b9
  PatchW $55f6 $a7e1
  PatchW $55fc $a7fb
  PatchW $5602 $a818
  PatchW $582e $a82b
  PatchW $583c $a839
  PatchW $5837 $a849
  PatchW $5608 $a851
  PatchW $58f0 $a876
  PatchW $560e $a892
  PatchW $57fe $a8b0
  PatchW $5804 $a8b0
  PatchW $5816 $a8d0
  PatchW $592e $a8e9
  PatchW $5662 $a919
  PatchW $5685 $a97d
  PatchW $566d $a989
  PatchW $568b $a997
  PatchW $5374 $a9a7
  PatchW $56c8 $a9f7
  PatchW $56da $aa0f
  PatchW $5723 $aa22
  PatchW $571d $aa58
  PatchW $56a7 $aa74
  PatchW $56b4 $aa84
  PatchW $56bd $aaa4
  PatchW $56c2 $aab8
  PatchW $5739 $aacd
  PatchW $574a $aaf7
  PatchW $5368 $ab2b
  PatchW $576b $ab30
  PatchW $5774 $abb0
  PatchW $5779 $abdf
  PatchW $58e2 $abf2
  PatchW $5934 $acab
  PatchW $5857 $acda
  PatchW $585d $ace8
  PatchW $4c41 $acfd
  PatchW $4e68 $ad1e
  PatchW $4e74 $ad4e
  PatchW $508c $ad60
  PatchW $50b6 $ade2
  PatchW $50c4 $ae22
  PatchW $50f7 $ae5a
  PatchW $4c55 $aeac
  PatchW $4c76 $aeba
  PatchW $4c7b $aec9
  PatchW $4f30 $aed1
  PatchW $4f0e $aeeb
  PatchW $4f5c $af06
  PatchW $4fa3 $af13
  PatchW $58fd $af1c
  PatchW $4ed7 $af30
  PatchW $56d4 $af3e
  PatchW $578a $af57
  PatchW $13a5 $af8e
  PatchW $1498 $af9c
  PatchW $1a97 $afa9
  PatchW $1ac1 $afb2
  PatchW $1ca5 $afb2
  PatchW $1ab8 $afb9
  PatchW $1b28 $afc2
  PatchW $20ce $afd3
  PatchW $20fb $afd3
  PatchW $2169 $afd3
  PatchW $21cc $afd3
  PatchW $21fe $afd3
  PatchW $22ad $afd3
  PatchW $1ffb $aff4
  PatchW $1493 $b008
  PatchW $14fa $b01f
  PatchW $15d4 $b01f
  PatchW $1638 $b01f
  PatchW $1459 $b035
  PatchW $1fbd $b046
  PatchW $1553 $b053
  PatchW $20d4 $b062
  PatchW $1520 $b06c
  PatchW $12dc $b076
  PatchW $140d $b07d
  PatchW $12d7 $b084
  PatchW $1408 $b091
  PatchW $2133 $b0a0
  PatchW $2170 $b0b6
  PatchW $210e $b0c5
  PatchW $21ae $b0df
  PatchW $21a0 $b0e6
  PatchW $21b3 $b0e6
  PatchW $23e7 $b0fe
  PatchW $23f6 $b0fe
  PatchW $240c $b0fe
  PatchW $2442 $b0fe
  PatchW $2477 $b0fe
  PatchW $24b1 $b0fe
  PatchW $24c6 $b0fe
  PatchW $252a $b0fe
  PatchW $2549 $b0fe
  PatchW $2576 $b0fe
  PatchW $265b $b0fe
  PatchW $2684 $b0fe
  PatchW $2776 $b0fe
  PatchW $27b2 $b0fe
  PatchW $27e0 $b0fe
  PatchW $280d $b0fe
  PatchW $2884 $b104
  PatchW $28cd $b10d
  PatchW $2100 $b116
  PatchW $23ed $b116
  PatchW $2555 $b116
  PatchW $2583 $b116
  PatchW $2678 $b116
  PatchW $2804 $b116
  PatchW $2419 $b120
  PatchW $242b $b120
  PatchW $244d $b120
  PatchW $245f $b120
  PatchW $2487 $b120
  PatchW $2305 $b12e
  PatchW $2439 $b138
  PatchW $246e $b138
  PatchW $2312 $b143
  PatchW $2403 $b14e
  PatchW $256a $b14e
  PatchW $26b0 $b14e
  PatchW $2702 $b14e
  PatchW $2817 $b14e
  PatchW $24ec $b157
  PatchW $2506 $b17c
  PatchW $2598 $b17c
  PatchW $25fa $b17c
  PatchW $26f2 $b17c
  PatchW $2743 $b17c
  PatchW $27a3 $b17c
  PatchW $2500 $b18c
  PatchW $2515 $b18c
  PatchW $258c $b18c
  PatchW $25ee $b18c
  PatchW $264c $b18c
  PatchW $2734 $b18c
  PatchW $2794 $b18c
  PatchW $251b $b194
  PatchW $25ab $b194
  PatchW $2652 $b194
  PatchW $279e $b194
  PatchW $112d $b1a1
  PatchW $25be $b1b2
  PatchW $2637 $b1b2
  PatchW $25b0 $b1ca
  PatchW $260d $b1ca
  PatchW $262e $b1ca
  PatchW $2612 $b1dd
  PatchW $2277 $b1ef
  PatchW $228f $b1ef
  PatchW $226a $b1fe
  PatchW $2272 $b1fe
  PatchW $228a $b1fe
  PatchW $26a0 $b209
  PatchW $2694 $b221
  PatchW $26e6 $b221
  PatchW $26d1 $b231
  PatchW $26c5 $b24b
  PatchW $2712 $b25f
  PatchW $273e $b27a
  PatchW $277c $b28d
  PatchW $2785 $b296
  PatchW $281c $b2a3
  PatchW $218e $b2b7
  PatchW $2196 $b2b7
  PatchW $29a0 $b2b7
  PatchW $2a2f $b2b7
  PatchW $579e $b2b7
  PatchW $2a16 $b2ce
  PatchW $2a9c $b2ce
  PatchW $21da $b2d4
  PatchW $22b6 $b2d4
  PatchW $2249 $b2e3
  PatchW $1b46 $b2e8
  PatchW $1f22 $b2e8
  PatchW $1b9f $b2ef
  PatchW $1f1d $b2ef
  PatchW $28a4 $b301
  PatchW $283f $b30a
  PatchW $1873 $b315
  PatchW $18f4 $b326
  PatchW $1911 $b32d
  PatchW $2a8d $b33c
  PatchW $2a38 $b345
  PatchW $2a74 $b34d
  PatchW $2919 $b353
  PatchW $2939 $b364
  PatchW $296b $b371
  PatchW $297e $b37b
  PatchW $2924 $b380
  PatchW $292f $b38a
  PatchW $28c4 $b390
  PatchW $295e $b390
  PatchW $1ba8 $b398
  PatchW $1f2e $b398
  PatchW $2237 $b3a5
  PatchW $17eb $b3af
  PatchW $14a7 $b3b8
  PatchW $15e5 $b3b8
  PatchW $1649 $b3b8
  PatchW $4c6a $b3b8
  PatchW $5910 $b3b8
  PatchW $19f8 $b3bc
  PatchW $2b10 $b3bc
  PatchW $2753 $b3c7
  PatchW $595a $b3d0
  PatchW $5996 $b3d9
  PatchW $5991 $b3ea
  PatchW $598b $b3f7
  PatchW $5981 $b402
  PatchW $597c $b409
  PatchW $5976 $b40f
  PatchW $5790 $b41b
  PatchW $2d1d $b425
  PatchW $2d28 $b433
  PatchW $2d8a $b433
  PatchW $2e47 $b433
  PatchW $537f $b433
  PatchW $2d39 $b441
  PatchW $2d7f $b44a
  PatchW $2d99 $b458
  PatchW $539d $b458
  PatchW $2dec $b468
  PatchW $2df5 $b478
  PatchW $2e0e $b485
  PatchW $2e50 $b489
  PatchW $2e67 $b49b
  PatchW $2aea $b4aa
  PatchW $2b55 $b4be
  PatchW $2b9a $b4d6
  PatchW $2afa $b4e4
  PatchW $2b8b $b4f1
  PatchW $2b38 $b4fe
  PatchW $2bb2 $b4fe
  PatchW $2b2c $b505
  PatchW $2be8 $b514
  PatchW $2c38 $b539
  PatchW $2c61 $b552
  PatchW $2bfc $b56c
  PatchW $2c72 $b576
  PatchW $2c25 $b57e
  PatchW $2ca9 $b58d
  PatchW $2d17 $b593
  PatchW $2ca3 $b59c
  PatchW $2c91 $b5ad
  PatchW $1e3c $b5d6
  PatchW $084f $b5e6
  PatchW $1e45 $b5e6
  PatchW $1e56 $b5f1
  PatchW $1e92 $b5fe
  PatchW $1ae6 $b603
  PatchW $1ae8 $b612
  PatchW $1aea $b623
  PatchW $1aec $b631
  PatchW $1aee $b642
  PatchW $1af0 $b647
  PatchW $1af2 $b65c
  PatchW $1af4 $b677
  PatchW $1af6 $b681
  PatchW $1ccf $b694
  PatchW $1cd1 $b6a4
  PatchW $1cd3 $b6b3
  PatchW $1cd5 $b6c0
  PatchW $1cd7 $b6d2
  PatchW $1cd9 $b6e8
  PatchW $1cdb $b701
  PatchW $1cdd $b71a
  PatchW $1cdf $b72c
  PatchW $1ce1 $b73e
  PatchW $1575 $b753
  PatchW $1800 $b768
  PatchW $27c4 $b777
  PatchW $27d0 $b780
  PatchW $27bd $b789
  PatchW $27cb $b792
  PatchW $1787 $b79a
  PatchW $178d $b7ae
  PatchW $2bc1 $b7d4
  PatchW $2d9e $b7d4
  PatchW $4d89 $b7d4
  PatchW $2e3e $b7e9
  PatchW $6c6f $b7f4
  PatchW $2c83 $b800
  PatchW $593a $b82b
  PatchW $594a $b83e
  PatchW $2cf0 $b84f
  PatchW $07ef $b861
  PatchW $07ff $b875
  PatchW $7fee $0c18
  PatchW $07e4 $b894
  PatchW $0830 $b8a2
  PatchW $083b $b8af
  PatchW $085a $b8c2
  PatchW $16a9 $b8ce
  PatchW $136f $b8d9
  PatchW $47db $b8e3
  PatchW $47e4 $b8fb
  PatchW $47ed $b916
  PatchW $14cd $b92e
  PatchW $58be $b942
  PatchW $24d7 $b970
  PatchW $45f0 $b97a
  PatchW $45fb $b9b6
  PatchW $4606 $baae
  PatchW $4644 $bafb
  PatchW $464f $bb18
  PatchW $465a $bb1a
  PatchW $4665 $bb47
  PatchW $4670 $bb83
  PatchW $4689 $bb97
  PatchW $4694 $bbcb
  PatchW $469f $bc0a
  PatchW $46aa $bc21
  PatchW $46b5 $bc44
  PatchW $46e8 $bc7e
  PatchW $46f3 $bc9b
  PatchW $471c $bd1b
  PatchW $4727 $bd43
  PatchW $4801 $bd7a
  PatchW $480c $bd85
  PatchW $4817 $bd90
  PatchW $4822 $bd9d
  PatchW $482d $bda8
