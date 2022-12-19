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

  push ix
    call PSGaiden_tile_decompr
  pop ix

  ld a,1
  ld (PAGING_SLOT_1),a

  ret
.ends

  ROMPosition $004b3
.section "Trampoline to new bitmap decoder 2" force ; not movable
; RLE/LZ bitmap decoder
; - support mapper

; Redirects calls to LoadTiles4BitRLE@$04b3 (decompress graphics, interrupt-safe version)
; to the same one as above
LoadTilesDIEI:
  jp LoadTiles
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

; Macro to load tiles from the given label
.macro LoadPagedTiles args address, dest
LoadPagedTiles\1:
  ; Common pattern used to load tiles in the original code
  ld hl,PAGING_SLOT_2
  ld (hl),:address
  ld hl,address
  ld de,dest
  call LoadTiles
.endm

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
  ld h,(hl)
  ld l,a
  ld de,TileWriteAddress(0)
  call LoadTiles
.ends

.slot 2

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
.section "Lutz portrait 1" superfree
PaletteLutzPortrait: CopyFromOriginal $4b388 16
TilesLutzPortrait: .incbin "generated/4b398.psgcompr"
.ends
.section "Tairon portrait" superfree
PaletteTaironPortrait: CopyFromOriginal $7762a 16
TilesTaironPortrait: .incbin "generated/7763a.psgcompr"
.ends
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

.section "Nero portrait 1" superfree
PaletteNeroPortrait1: CopyFromOriginal $7c000 16
TilesNeroPortrait1: .incbin "generated/7c010.psgcompr"
.ends
.section "Myau portrait 1" superfree
PaletteMyauPortrait1: CopyFromOriginal $7cadb 16
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

; Treasure chests
.slot 2
.section "Treasure chest art" superfree
PaletteTreasureChest: CopyFromOriginal $50000 8
TilesTreasureChest: .incbin "generated/50008.psgcompr"
.ends
;    ld     hl,$ffff        ; 00180E 21 FF FF
;    ld     (hl),:PaletteTreasureChest ;$14        ; 001811 36 14
  PatchB $1812 :PaletteTreasureChest
;    ld     hl,PaletteTreasureChest ;$8000        ; 001813 21 00 80
  PatchW $1814 PaletteTreasureChest
;    ld     de,$c258        ; 001816 11 58 C2
;    ld     bc,$0008        ; 001819 01 08 00
;    ldir                   ; 00181C ED B0
;    ld     hl,$c240        ; 00181E 21 40 C2
;    ld     de,$c220        ; 001821 11 20 C2
;    ld     bc,$0020        ; 001824 01 20 00
;    ldir                   ; 001827 ED B0
;    ld     hl,TilesTreasureChest ;$8008        ; 001829 21 08 80
  PatchW $182a TilesTreasureChest
;    ld     de,$6000        ; 00182C 11 00 60
;    call   $04b3           ; 00182F CD B3 04

; Ending picture
.slot 2
.section "Ending picture art" superfree
PaletteEnding: CopyFromOriginal $7d676 17
TilesEnding: .incbin "generated/7d687.psgcompr"
.ends
;    ld     hl,$ffff        ; 004835 21 FF FF
;    ld     (hl),:PaletteEnding ;$1f        ; 004838 36 1F
  PatchB $4839 :PaletteEnding
;    ld     hl,PaletteEnding ;$9676        ; 00483A 21 76 96
  PatchW $483b PaletteEnding
;    ld     de,$c240        ; 00483D 11 40 C2
;    ld     bc,$0011        ; 004840 01 11 00
;    ldir                   ; 004843 ED B0
;    ld     hl,TilesEnding ;$9687        ; 004845 21 87 96
  PatchW $4846 TilesEnding
;    ld     de,$4000        ; 004848 11 00 40
;    call   $04b3           ; 00484B CD B3 04

; Enemies
; Table at $869f has 32 per enemy type.
; Tiles bank is at +16, pointer at +17
.slot 2
.section "Bat art" superfree
TilesBat: .incbin "generated/28000.psgcompr"
.ends
.section "Reaper art" superfree
TilesReaper: .incbin "generated/28d7e.psgcompr"
.ends
.section "Evil Dead art" superfree
TilesEvilDead: .incbin "generated/29b85.psgcompr"
.ends
.section "Medusa art" superfree
TilesMedusa: .incbin "generated/2a044.psgcompr"
.ends
.section "Sand worm art" superfree
TilesSandWorm: .incbin "generated/2aa8c.psgcompr"
.ends
.section "Wing Eye art" superfree
TilesWingEye: .incbin "generated/2b7e4.psgcompr"
.ends

.section "Fly art" superfree
TilesFly: .incbin "generated/2dcda.psgcompr"
.ends
.section "TilesSorceror art" superfree
TilesSorceror: .incbin "generated/2e25f.psgcompr"
.ends
.section "TilesLassic art" superfree
TilesLassic: .incbin "generated/2ed79.psgcompr"
.ends
.section "Slime art" superfree
TilesSlime: .incbin "generated/2f869.psgcompr"
.ends

.section "TilesFarmer art" superfree
TilesFarmer: .incbin "generated/4cdbe.psgcompr"
.ends
.section "TilesDezorian art" superfree
TilesDezorian: .incbin "generated/4d6ed.psgcompr"
.ends
.section "TilesElephant art" superfree
TilesElephant: .incbin "generated/4dc25.psgcompr"
.ends
.section "TilesRobotCop art" superfree
TilesRobotCop: .incbin "generated/4ea0f.psgcompr"
.ends
.section "TilesTarantula art" superfree
TilesTarantula: .incbin "generated/4f28a.psgcompr"
.ends
.section "TilesSuccubus art" superfree
TilesSuccubus: .incbin "generated/4fd83.psgcompr"
.ends

.section "TilesClub art" superfree
TilesClub: .incbin "generated/50feb.psgcompr"
.ends
.section "TilesDarkForceFlame art" superfree
TilesDarkForceFlame: .incbin "generated/517c4.psgcompr"
.ends

.section "TilesAmmonite art" superfree
TilesAmmonite: .incbin "generated/52ba2.psgcompr"
.ends
.section "TilesGolem art" superfree
TilesGolem: .incbin "generated/53395.psgcompr"
.ends

.section "TilesShadow art" superfree
TilesShadow: .incbin "generated/64000.psgcompr"
.ends
.section "TilesDragon art" superfree
TilesDragon: .incbin "generated/6493b.psgcompr"
.ends
.section "TilesSnake art" superfree
TilesSnake: .incbin "generated/65755.psgcompr"
.ends
.section "TilesScorpion art" superfree
TilesScorpion: .incbin "generated/664d0.psgcompr"
.ends
.section "TilesSkeleton art" superfree
TilesSkeleton: .incbin "generated/66a4a.psgcompr"
.ends
.section "TilesGhoul art" superfree
TilesGhoul: .incbin "generated/67326.psgcompr"
.ends

.section "Centaur art" superfree
TilesCentaur: .incbin "generated/68000.psgcompr"
.ends
.section "IceMan art" superfree
TilesIceMan: .incbin "generated/68a1f.psgcompr"
.ends
.section "Manticore art" superfree
TilesManticore: .incbin "generated/69748.psgcompr"
.ends
.section "Man Eater art" superfree
TilesManEater: .incbin "generated/6a180.psgcompr"
.ends
.section "FishMan art" superfree
TilesFishMan: .incbin "generated/6a7b8.psgcompr"
.ends
.section "Octopus art" superfree
TilesOctopus: .incbin "generated/6b17e.psgcompr"
.ends



.section "TilesTarzimal art" superfree
TilesTarzimal: .incbin "generated/4794a.psgcompr"
.ends

.section "TilesGoldDragonHead art" superfree
TilesGoldDragonHead: .incbin "generated/2caeb.psgcompr"
.ends

; Table is at $c69f, 1-indexed.
; Each entry is 32B.
; Page number is offset +16B, pointer at +17B.
.macro PatchEnemy args index, label
  ROMPosition ($c69f+(index-1)*32+16)
.section "Enemy data patch for \1 \2" overwrite
PatchEnemy\1\2:
.db :\2
.dw \2
.ends
.endm

  PatchEnemy  1 TilesFly ; Monster Fly
  PatchEnemy  2 TilesSlime ; Green Slime
  PatchEnemy  3 TilesWingEye ; Wing Eye
  PatchEnemy  4 TilesManEater ; Maneater
  PatchEnemy  5 TilesScorpion ; Scorpius
  PatchEnemy  6 TilesScorpion ; Giant Naiad
  PatchEnemy  7 TilesSlime ; Blue Slime
  PatchEnemy  8 TilesFarmer ; Motavian Peasant
  PatchEnemy  9 TilesWingEye ; Devil Bat
  PatchEnemy 10 TilesManEater ; Killer Plant
  PatchEnemy 11 TilesScorpion ; Biting Fly
  PatchEnemy 12 TilesFarmer ; Motavian Teaser
  PatchEnemy 13 TilesFly ; Herex
  PatchEnemy 14 TilesSandWorm ; Sandworm
  PatchEnemy 15 TilesFarmer ; Motavian Maniac
  PatchEnemy 16 TilesWingEye ; Gold Lens
  PatchEnemy 17 TilesSlime ; Red Slime
  PatchEnemy 18 TilesBat ; Bat Man
  PatchEnemy 19 TilesClub ; Horseshoe Crab
  PatchEnemy 20 TilesFishMan ; Shark King
  PatchEnemy 21 TilesEvilDead ; Lich
  PatchEnemy 22 TilesTarantula ; Tarantula
  PatchEnemy 23 TilesManticore ; Manticort
  PatchEnemy 24 TilesSkeleton ; Skeleton
  PatchEnemy 25 TilesTarantula ; Ant-lion
  PatchEnemy 26 TilesFishMan ; Marshes
  PatchEnemy 27 TilesFarmer ; Dezorian
  PatchEnemy 28 TilesSandWorm ; Desert Leech
  PatchEnemy 29 TilesBat ; Cryon
  PatchEnemy 30 TilesElephant ; Big Nose
  PatchEnemy 31 TilesGhoul ; Ghoul
  PatchEnemy 32 TilesAmmonite ; Ammonite
  PatchEnemy 33 TilesClub ; Executor
  PatchEnemy 34 TilesEvilDead ; Wight
  PatchEnemy 35 TilesSkeleton ; Skull Soldier
  PatchEnemy 36 TilesAmmonite ; Snail
  PatchEnemy 37 TilesManticore ; Manticore
  PatchEnemy 38 TilesSnake ; Serpent
  PatchEnemy 39 TilesSandWorm ; Leviathan
  PatchEnemy 40 TilesEvilDead ; Dorouge
  PatchEnemy 41 TilesOctopus ; Octopus
  PatchEnemy 42 TilesSkeleton ; Mad Stalker
  PatchEnemy 43 TilesFarmer ; Dezorian Head
  PatchEnemy 44 TilesGhoul ; Zombie
  PatchEnemy 45 TilesGhoul ; Living Dead
  PatchEnemy 46 TilesRobotCop ; Robot Police
  PatchEnemy 47 TilesSorceror ; Cyborg Mage
  PatchEnemy 48 TilesSnake ; Flame Lizard
  PatchEnemy 49 TilesTarzimal ; Tajim
  PatchEnemy 50 TilesGolem ; Gaia
  PatchEnemy 51 TilesRobotCop ; Machine Guard
  PatchEnemy 52 TilesOctopus ; Big Eater
  PatchEnemy 53 TilesGolem ; Talos
  PatchEnemy 54 TilesSnake ; Snake Lord
  PatchEnemy 55 TilesReaper ; Death Bearer
  PatchEnemy 56 TilesSorceror ; Chaos Sorcerer
  PatchEnemy 57 TilesCentaur ; Centaur
  PatchEnemy 58 TilesIceMan ; Ice Man
  PatchEnemy 59 TilesIceMan ; Vulcan
  PatchEnemy 60 TilesDragon ; Red Dragon
  PatchEnemy 61 TilesDragon ; Green Dragon
  PatchEnemy 62 TilesShadow ; LaShiec
  PatchEnemy 63 TilesElephant ; Mammoth
  PatchEnemy 64 TilesCentaur ; King Saber
  PatchEnemy 65 TilesReaper ; Dark Marauder
  PatchEnemy 66 TilesGolem ; Golem
  PatchEnemy 67 TilesMedusa ; Medusa
  PatchEnemy 68 TilesDragon ; Frost Dragon
  PatchEnemy 69 TilesDragon ; Dragon Wise
  PatchEnemy 70 TilesGoldDragonHead ; Gold Drake
  PatchEnemy 71 TilesShadow ; Mad Doctor
  PatchEnemy 72 TilesLassic ; LaShiec
  PatchEnemy 73 TilesDarkForceFlame ; Dark Force
  PatchEnemy 74 TilesSuccubus ; Nightmare

; Dialogue sprites
.bank 2
.section "1bb80 art" superfree
Tiles1bb80: .incbin "generated/1bb80.psgcompr"
.ends

.section "57a97 art" superfree
Tiles57a97: .incbin "generated/57a97.psgcompr"
.ends

.section "6c000 art" superfree
Tiles6c000: .incbin "generated/6c000.psgcompr"
.ends
.section "6ce19 art" superfree
Tiles6ce19: .incbin "generated/6ce19.psgcompr"
.ends
.section "6d979 art" superfree
Tiles6d979: .incbin "generated/6d979.psgcompr"
.ends
.section "6df26 art" superfree
Tiles6df26: .incbin "generated/6df26.psgcompr"
.ends
.section "6e75e art" superfree
Tiles6e75e: .incbin "generated/6e75e.psgcompr"
.ends
.section "6eb04 art" superfree
Tiles6eb04: .incbin "generated/6eb04.psgcompr"
.ends
.section "6ee6c art" superfree
Tiles6ee6c: .incbin "generated/6ee6c.psgcompr"
.ends

; Table is at $d66c, 0-indexed.
; Each entry is 8B.
; Page number is offset +5B, pointer at +6B.
.macro PatchPerson args index, label
  ROMPosition ($d66c+index*8+5)
.section "Person data patch for \1 \2" overwrite
PatchPerson\1\2:
.db :\2
.dw \2
.ends
.endm
  
  PatchPerson 0 Tiles6c000
  PatchPerson 1 Tiles6c000 ; Palman townsperson
  PatchPerson 2 Tiles6c000 ; Nekise
  PatchPerson 3 Tiles6c000
  PatchPerson 4 Tiles6ce19 ; Robot cop
  PatchPerson 5 Tiles6ce19 ; Old man
  PatchPerson 6 Tiles6ce19
  PatchPerson 7 Tiles1bb80
  PatchPerson 8 Tiles6d979
  PatchPerson 9 Tiles6df26
  PatchPerson 10 Tiles6df26
  PatchPerson 11 Tiles6e75e
  PatchPerson 12 Tiles6eb04 ; Priest
  PatchPerson 13 Tiles6ee6c
  PatchPerson 14 Tiles57a97
  PatchPerson 15 TilesDezorian
  PatchPerson 16 TilesDezorian
  
; Attack/magic sprites
.bank 2
.section "Attack/magic sprites art" superfree
; These have to share a bank
AttackSprites:
Tiles49c00: .incbin "generated/49c00.psgcompr"
Tiles49dd7: .incbin "generated/49dd7.psgcompr"
Tiles4a036: .incbin "generated/4a036.psgcompr"
Tiles4a270: .incbin "generated/4a270.psgcompr"
Tiles4a3bc: .incbin "generated/4a3bc.psgcompr"
Tiles4a5e0: .incbin "generated/4a5e0.psgcompr"
Tiles4a7fd: .incbin "generated/4a7fd.psgcompr"
Tiles4aac0: .incbin "generated/4aac0.psgcompr"
Tiles4ab9d: .incbin "generated/4ab9d.psgcompr"
Tiles4ad2a: .incbin "generated/4ad2a.psgcompr"
Tiles4af91: .incbin "generated/4af91.psgcompr"
Tiles4b177: .incbin "generated/4b177.psgcompr"
Tiles4b244: .incbin "generated/4b244.psgcompr"
.ends

; And the table that references them...
; Attack art table at $5e6d, stride = 6, delta = 4:
.macro PatchAttackSprites args index, label
  ROMPosition ($5e6d+index*6+4)
.section "Attack sprites patch for \1 \2" overwrite
PatchAttackSprites\1\2:
.dw \2
.ends
.endm

 PatchAttackSprites 0 Tiles4ad2a
 PatchAttackSprites 1 Tiles49c00
 PatchAttackSprites 2 Tiles49c00
 PatchAttackSprites 3 Tiles49c00
 PatchAttackSprites 4 Tiles49c00
 PatchAttackSprites 5 Tiles4af91
 PatchAttackSprites 6 Tiles4b177
 PatchAttackSprites 7 Tiles49c00
 PatchAttackSprites 8 Tiles49c00
 PatchAttackSprites 9 Tiles4a270
 PatchAttackSprites 10 Tiles4af91
 PatchAttackSprites 11 Tiles4a036
 PatchAttackSprites 12 Tiles4aac0
 PatchAttackSprites 13 Tiles49dd7
 PatchAttackSprites 14 Tiles4ab9d
 PatchAttackSprites 15 Tiles4b244
 PatchAttackSprites 16 Tiles4a3bc
 PatchAttackSprites 17 Tiles4a5e0
 PatchAttackSprites 18 Tiles4a7fd

; And the bank...
  PatchB $5e12 :AttackSprites
  
; Attack/magic sprites
.bank 2
.section "Attack/magic sprites art 2" superfree
; These have to share a bank
AttackSprites2:
Tiles2d901: .incbin "generated/2d901.psgcompr"
Tiles2daf0: .incbin "generated/2daf0.psgcompr"
.ends
; And their pointers...
  PatchW $6122 Tiles2d901
  PatchW $6128 Tiles2daf0
  PatchB $60b4 :AttackSprites2

; Myau flight
.bank 2
.section "Myau flight art" superfree
MyauFlightPalette:  CopyFromOriginal $5b9d8 15
MyauFlightTiles:    .incbin "generated/5b9e7.psgcompr"
.ends
;    ld     hl,$ffff        ; 004789 21 FF FF 
;    ld     (hl),$16        ; 00478C 36 16 
  PatchB $478d :MyauFlightPalette
;    ld     hl,$b9d8        ; 00478E 21 D8 B9 
  PatchW $478f MyauFlightPalette
;    ld     de,$c251        ; 004791 11 51 C2 
;    ld     bc,$000f        ; 004794 01 0F 00 
;    ldir                   ; 004797 ED B0 
;    ld     hl,$b9e7        ; 004799 21 E7 B9 
  PatchW $479a MyauFlightTiles
;    ld     de,$6000        ; 00479C 11 00 60 
;    call   $04b3           ; 00479F CD B3 04 

; Dungeon rooms
.bank 2
.section "Dungeon room art" superfree
DungeonRoomTiles:   .incbin "generated/27471.psgcompr"
DungeonRoomTilemap: CopyFromOriginal $27130 $27471-$27130
.ends
;    ld     hl,$ffff        ; 006BA3 21 FF FF 
;    ld     (hl),$09        ; 006BA6 36 09 
  PatchB $6ba7 :DungeonRoomTiles
;    ld     hl,$b471        ; 006BA8 21 71 B4 
  PatchW $6ba9 DungeonRoomTiles
;    ld     de,$4000        ; 006BAB 11 00 40 
;    call   $04b3           ; 006BAE CD B3 04 
;    ld     hl,$b130        ; 006BB1 21 30 B1 
  PatchW $6bb2 DungeonRoomTilemap
;    call   $6e05           ; 006BB4 CD 05 6E 

/*
; Places LoadTiles4BitRLE @ $04b3 is used:
    call   $04b3           ; 0007D4 CD B3 04 Save game loading to load font. Replaced.
    call   $04b3           ; 0007DD CD B3 04 Save game loading to load font. Replaced.
    call   $04b3           ; 000A1C CD B3 04 Space travel - data is done
    call   $04b3           ; 000CEF CD B3 04 Scene loader - data is done
    call   $04b3           ; 000CFF CD B3 04 Scene loader - data is done
    call   $04b3           ; 0010EE CD B3 04 Dungeon font loader - replaced
    call   $04b3           ; 0010F7 CD B3 04 Dungeon font loader - replaced 
    call   $04b3           ; 00182F CD B3 04 Treasure chest after killing a monster - done
    call   $04b3           ; 003DE9 CD B3 04 "Scene" font loader - replaced
    call   $04b3           ; 003DF2 CD B3 04 "Scene" font loader - replaced 
    call   $04b3           ; 003EB5 CD B3 04 "Scene" background loader - done
    call   $04b3           ; 004528 CD B3 04 Intro space tiles - done
    call   $04b3           ; 0045AF CD B3 04 Intro font loader - replaced
    call   $04b3           ; 0045B8 CD B3 04 Intro font loader - replaced
    call   $04b3           ; 0045C1 CD B3 04 Intro font loader - replaced
    call   $04b3           ; 00479F CD B3 04 Myau flight sprites - done
    call   $04b3           ; 00484B CD B3 04 Ending picture - done
    call   $04b3           ; 004892 CD B3 04 Credits font - done
    call   $04b3           ; 0048E5 CD B3 04 Picture frame font - done
    call   $04b3           ; 0048EE CD B3 04 Picture frame font - done
    call   $04b3           ; 004911 CD B3 04 Picture frame tiles - done
    call   $04b3           ; 004952 CD B3 04 Picture frame picture tiles - done
    call   $04b3           ; 005E45 CD B3 04 Attack sprites - done
    call   $04b3           ; 0060E9 CD B3 04 More attack sprites - done
    call   $04b3           ; 0062CA CD B3 04 Enemy sprite loader - data done
    call   $04b3           ; 006466 CD B3 04 Dialog counterpart loader - done
    call   $04b3           ; 00697C CD B3 04 Reload tiles after a pitfall - done
    call   $04b3           ; 006BAE CD B3 04 Dungeon room - done
    call   m,$04b3         ; 00DCE6 FC B3 04 Not real code

*/
