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

  ROMPosition $004b3
.section "Trampoline to new bitmap decoder 2" force ; not movable
; RLE/LZ bitmap decoder
; - support mapper

; Redirects calls to LoadTiles4BitRLE@$04b3 (decompress graphics, interrupt-safe version)
; to a ripped decompressor from Phantasy Star Gaiden
LoadTilesDIEI:
  ld a,:PSGaiden_tile_decompr
  ld (PAGING_SLOT_1),a
  ; TODO: is this too slow? The original does di/ei in the inner loop body...
  ex de,hl ; ??????
  di
    call PSGaiden_tile_decompr
  ei
  ld a,1
  ld (PAGING_SLOT_1),a

  ret
.ends
.slot 2
.section "Outside tiles" superfree
OutsideTiles:
.incbin "generated/747b8.psgcompr"
.ends

.section "Town tiles" superfree
TownTiles:
.incbin {"generated/{LANGUAGE}/world2.psgcompr"}
.ends

  ROMPosition $00ce4
.section "BG loader patch 1" size 14 overwrite ; not movable
  LoadPagedTiles OutsideTiles TileWriteAddress(0)
.ends

  ROMPosition $00cf4
.section "BG loader patch 2" size 14 overwrite ; not movable
  LoadPagedTiles TownTiles TileWriteAddress(0)
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
  ld hl,TileWriteAddress(0)
  call LoadTiles
.ends

.slot 2

.unbackground $5f778 $5ffff
.section "Space graphics" superfree
TilesSpace: .incbin "generated/5f778.psgcompr"
PaletteSpace: CopyFromOriginal $5f767 17
.ends

; Intro sequence:
;    ld     hl,$ffff        ; 004512 21 FF FF 
;    ld     (hl),:PaletteSpace ;$17        ; 004515 36 17 
  PatchB $4516 :PaletteSpace
;    ld     hl,PaletteSpace ;$b767        ; 004517 21 67 B7 
  PatchW $4518 PaletteSpace
;    ld     de,$c240        ; 00451A 11 40 C2 
;    ld     bc,$0011        ; 00451D 01 11 00 
;    ldir                   ; 004520 ED B0 
;    ld     hl,TilesSpace ;$b778        ; 004522 21 78 B7 
  PatchW $4523 TilesSpace
;    ld     de,$4000        ; 004525 11 00 40 
;    call   LoadTiles ;$04b3           ; 004528 CD B3 04 

; Interplanetary flight:
;    ld     hl,$ffff        ; 000A03 21 FF FF 
;    ld     (hl),:PaletteSpace ;$17        ; 000A06 36 17 
  PatchB $0a07 :PaletteSpace
;    ld     hl,PaletteSpace ;$b767        ; 000A08 21 67 B7 
  PatchW $0a09 PaletteSpace
;    ld     de,$c240        ; 000A0B 11 40 C2 
;    ld     bc,$0011        ; 000A0E 01 11 00 
;    ldir                   ; 000A11 ED B0 
;    call   $0b8d           ; 000A13 CD 8D 0B 
;    ld     hl,TilesSpace ;$b778        ; 000A16 21 78 B7 
  PatchW $0a17 TilesSpace
;    ld     de,$4000        ; 000A19 11 00 40 
;    call   LoadTiles ;$04b3           ; 000A1C CD B3 04 

.slot 2
.unbackground $62484 $625df
.section "Frame graphics" superfree
TilesFrame: .incbin "generated/6258a.psgcompr"
PaletteFrame: CopyFromOriginal $6257a 16
TilemapFrame: CopyFromOriginal $62484 $6257a-$62484
.ends
;    ld     hl,$ffff        ; 0048F1 21 FF FF 
;    ld     (hl),:TilesFrame ;$18        ; 0048F4 36 18 
  PatchB $48f5 :TilesFrame
;    ld     hl,$c240        ; 0048F6 21 40 C2 
;    ld     de,$c241        ; 0048F9 11 41 C2 
;    ld     (hl),$00        ; 0048FC 36 00 
;    ld     bc,$000f        ; 0048FE 01 0F 00 
;    ldir                   ; 004901 ED B0 
;    ld     hl,PaletteFrame ;$a57a        ; 004903 21 7A A5 
  PatchW $4904 PaletteFrame
;    ld     bc,$0010        ; 004906 01 10 00 
;    ldir                   ; 004909 ED B0 
;    ld     hl,TilesFrame ;$a58a        ; 00490B 21 8A A5 
  PatchW $490c TilesFrame
;    ld     de,$4000        ; 00490E 11 00 40 
;    call   DecompressTiles ;$04b3           ; 004911 CD B3 04 
;    ld     hl,TilemapFrame ;$a484        ; 004914 21 84 A4 
  PatchW $4915 TilemapFrame
;    call   DecompressTileamap ;$6e05           ; 004917 CD 05 6E 

; Character portraits
; Palette+tiles are spread around the place but tilemaps are all together.
; We thus only need to move the palette+tiles (and rewrite the table for them).

.slot 2
.unbackground $4b388 $4bfff ; Lutz portrait palette and tiles, unused space
.section "Lutz portrait 1" superfree
PaletteLutzPortrait: CopyFromOriginal $4b388 16
TilesLutzPortrait: .incbin "generated/4b398.psgcompr"
.ends
.unbackground $7762a $77fff ; Tairon portrait palette and tiles, unused space
.section "Tairon portrait" superfree
PaletteTaironPortrait: CopyFromOriginal $7762a 16
TilesTaironPortrait: .incbin "generated/7763a.psgcompr"
.ends
.unbackground $78000 $7bfff ; Various portrait palette and tiles, unused space
.section "Nero portrait 2" superfree
PaletteNeroPortrait2: CopyFromOriginal $78000 16
TilesNeroPortrait2: .incbin "generated/78010.psgcompr"
.ends
.section "Alisa portrait 1" superfree
PaletteAlisaPortrait1: CopyFromOriginal $78f62 16
TilesAlisaPortrait1: .incbin "generated/78f72.psgcompr"
.ends
.section "Alisa portrait 2" superfree
PaletteAlisaPortrait2: CopyFromOriginal $79c2b 16
TilesAlisaPortrait2: .incbin "generated/79c3b.psgcompr"
.ends
.section "Myau portrait 2" superfree
PaletteMyauPortrait2: CopyFromOriginal $7aa4e 16
TilesMyauPortrait2: .incbin "generated/7aa5e.psgcompr"
.ends
.section "Myau portrait 3" superfree
PaletteMyauPortrait3: CopyFromOriginal $7b30c 16
TilesMyauPortrait3: .incbin "generated/7b31c.psgcompr"
.ends

.unbackground $7c000 $7d676 ; Nero death part 1, Myau palette and tiles
.section "Nero portrait 1" superfree
PaletteNeroPortrait1: CopyFromOriginal $7c000 16
TilesNeroPortrait1: .incbin "generated/7c010.psgcompr"
.ends
.section "Myau portrait 1" superfree
PaletteMyauPortrait1: CopyFromOriginal $7cedb 16
TilesMyauPortrait1: .incbin "generated/7caeb.psgcompr"
.ends

; And the table...
.macro PatchPortrait
  PatchB \1 :\2
  PatchW \1+1 \2
.endm
  PatchPortrait $4979 PaletteNeroPortrait1
  PatchPortrait $497e PaletteNeroPortrait2
  PatchPortrait $4983 PaletteAlisaPortrait1
  PatchPortrait $4988 PaletteAlisaPortrait2
  PatchPortrait $498d PaletteMyauPortrait1
  PatchPortrait $4992 PaletteTaironPortrait
  PatchPortrait $4997 PaletteLutzPortrait
  PatchPortrait $499c PaletteMyauPortrait2
  PatchPortrait $49a1 PaletteMyauPortrait3
