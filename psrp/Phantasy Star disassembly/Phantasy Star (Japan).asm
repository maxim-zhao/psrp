;=======================================================================================================
; Phantasy Star disassembly/retranslation
;=======================================================================================================
; by Maxim
; This aims to be a disassembly of Phantasy Star (jp)
; with comments describing what's going on as much as possible
; defines,macros,labels etc to make it cleaner
; and data blocks separated from code
;
; #############
; means something that seems unnecessary
;

;=======================================================================================================
; WLA-DX banking setup
;=======================================================================================================

.MEMORYMAP
DEFAULTSLOT 0
SLOTSIZE $7ff0
SLOT 0 $0000
SLOTSIZE $0010
SLOT 1 $7ff0
SLOTSIZE $4000
SLOT 2 $8000
.ENDME

.ROMBANKMAP
BANKSTOTAL 32
BANKSIZE $7ff0
BANKS 1
BANKSIZE $0010
BANKS 1
BANKSIZE $4000
BANKS 30
.ENDRO

; This disassembly was created using Emulicious (https://www.emulicious.net)

.enum $C000 export
HasFM db              ; 01 if YM2413 detected,00 otherwise
_RAM_C001_ db
_RAM_C002_ db
_RAM_C003_ db
NewMusic db           ; Which music to start playing
_RAM_C005_ db
_RAM_C006_ db
unusedC007      db
_RAM_C008_ db
_RAM_C009_ db
_RAM_C00A_ db
_RAM_C00B_ db
_RAM_C00C_ db
unusedC00D db
_RAM_C00E_ dsb $9
unusedC017 db
_RAM_C018_ db
.ende

.enum $C06E export
_RAM_C06E_ dsb $9
.ende

.enum $C08E export
_RAM_C08E_ db
_RAM_C08F_ db
.ende

.enum $C095 export
_RAM_C095_ db
.ende

.enum $C09C export
_RAM_C09C_ db
.ende

.enum $C0AE export
_RAM_C0AE_ db
_RAM_C0AF_ db
.ende

.enum $C0B5 export
_RAM_C0B5_ db
.ende

.enum $C0BC export
_RAM_C0BC_ db
.ende

.enum $C0CE export
_RAM_C0CE_ db
.ende

.enum $C0EE export
_RAM_C0EE_ dsb $9
.ende

.enum $C10E export
_RAM_C10E_ dsb $9
.ende

.enum $C12E export
_RAM_C12E_ dsb $7
_RAM_C135_ db
.ende

.enum $C14E export
_RAM_C14E_ dsb $9
.ende

.enum $C158 export
_RAM_C158_ db
.ende

.enum $C16E export
_RAM_C16E_ dsb $9
.ende

.enum $C18E export
_RAM_C18E_ db
.ende

.enum $C1AE export
_RAM_C1AE_ db
.ende

.enum $C1CE export
_RAM_C1CE_ db
.ende

.enum $C200 export
VDPReg0 db                    ; Contents of VDP register 0
VDPReg1 db                    ; Contents of VDP register 1
FunctionLookupIndex db        ; Index to lookup in FunctionLookup table
.ende

.enum $C204 export
ControlsNew db                ; Buttons just pressed (1 = pressed) \ Must be
Controls db                   ; All buttons pressed (1 = pressed)  / together
.ende

.enum $C208 export
VBlankFunctionIndex db        ; Index of function to execute in VBlank
IsJapanese db                 ; 00 if Japanese,ff if Export
IsNTSC db                     ; 00 if PAL,ff if NTSC
ResetButton db                ; Reset button state: %00010000 unpressed %00000000 pressed
RandomNumberGeneratorWord dw  ; Used for random number generator
MarkIIILogoDelay dw          ; Counter for number of frames to wait on Mark III logo
TileMapHighByte db            ; High byte to use when writing low-byte-only tile data to tilemap
Mask1BitOutput db             ; Mask used by 1bpp tile output code
PauseFlag db                  ; Pause flag $ff=pause/$00=not
PaletteMoveDelay db           ; Counter used to slow down palette changes (Mark III logo,water sparkles,???)
PaletteMovePos db             ; Current position in above palette changes (must follow)
.ende

.enum $C217 export
NextSpriteY dw                ; Pointer to next free sprite Y position in SpriteTable
NextSpriteX dw                ; Pointer to next free sprite X position in SpriteTable
PaletteFadeControl db         ; Palette fade control:
                                ;   bit 7 1 = fade in,0 = fade out
                                ;   lower bits = counter,should go 9->0
                                ; Must be followed by:
PaletteSize db                ; counter for number of entries in TargetPalette
PaletteFadeFrameCounter db    ; Palette fade frame counter
.ende

.struct OutsideAnimCounter
Enabled     db ; 00/01
ResetValue  db ; Reset value of counter
CountDown   db ; Counted down to 0 and then reset
Counter     db ; Counted up or down at each reset
.endst

.enum $C220 export
ActualPalette dsb 32          ; Actual palette (when fading)
TargetPalette dsb 32          ; Target palette
_RAM_C260_ dw
_RAM_C262_ db
_RAM_C263_ db                 ; Scrollingtilemap data page(?)
ScrollDirection db            ; Scroll direction; %----RLDU
PaletteRotateEnabled .db      ; Palette rotation enabled if non-zero
WalkingMovementCounter db     ; Counter for movement
_RAM_C267_BattleCurrentPlayer db
CursorEnabled db              ; $ff if cursor showing,$00 otherwise
CursorTileMapAddress dw       ; Address of low byte of top cursor position in tilemap
CursorPos db                  ; How many rows to shift cursor down
OldCursorPos db               ; Last position
CursorCounter db              ; Counter for flashing
CursorMax db                  ; Maximum value for cursor
OutsideAnimCounters instanceof OutsideAnimCounter 6 ; counter structures for outside tile animations
_RAM_C287_ dw
_RAM_C289_ db
SceneType db                  ; Scene characteristics; controls which animation to do (? and others)
.ende

.enum $C299 export
_RAM_C299_ dw
_RAM_C29B_ dw
_RAM_C29D_InBattle db
SceneType2 db
_RAM_C29F_ db
_RAM_C2A0_ db
.ende

.enum $C2AB export
_RAM_C2AB_ db
_RAM_C2AC_ dsb $10
AnimDelayCounter db           ; Counter for tile animation effects - delay between frames - must be followed by:
AnimFrameCounter db           ; Counter for tile animation effects - frame #
PaletteFlashFrames db         ; Number of frames over which to flash palette to white
.ende

.enum $C2C0 export
PaletteFlashCount db          ; Number of palette entries to set to white
PaletteFlashStart db          ; First palette entry to set to white
TextCharacterNumber db        ; Which number character (0-3) to write the name of when encountering text code $4f
.ende

.enum $C2C4 export
ItemTableIndex db             ; Index into item table for text display
NumberToShowInText dw         ; 16-bit int to output for text code TextNumber=$52
NumEnemies db                 ; counter for number of enemies
EnemyName dsb 8               ; 8 character enemy name
EnemyExperienceValue dw       ; Experience points for beatings
MovementInProgress db         ; $ff when doing a block movement
TextBox20x6Open db            ; 20x6 text box open
_RAM_C2D4_ db
_RAM_C2D5_ db
SceneAnimEnabled db           ; Enemy scene animations only happen when non-zero
_RAM_C2D7_ db
_RAM_C2D8_ db
_RAM_C2D9_ dw
RoomIndex db                  ; Room index to table at $49d1
_RAM_C2DC_ db
EnemyMoney dw                 ; Monster money drop
DungeonObjectItemIndex db
DungeonObjectItemTrapped db
DungeonObjectFlagAddress dw
BattleProbability db          ; Chance of an enemy encounter (*255)
DungeonMonsterPoolIndex db
_RAM_C2E5_ db
EnemyNumber db                ; Enemy number - index into EnemyData
RetreatProbability db
_RAM_C2E8_EnemyMagicType db
_RAM_C2E9_ db
_RAM_C2EA_ db
_RAM_C2EB_ db
_RAM_C2EC_SecretThingBuyCount db
_RAM_C2ED_PlayerWasHurt db
_RAM_C2EE_PlayerBeingAttacked db
_RAM_C2EF_MagicWallActiveAndCounter db
_RAM_C2F0_ db
_RAM_C2F1_ db
_RAM_C2F2_ db
_RAM_C2F3_ db
CurrentlyPlayingMusic db      ; Currently playing music number
_RAM_C2F5_ db
.ende

.enum $C300 export
GameData .dsb 1024            ; All data saved/loaded from SRAM
HScroll db                    ; Horizontal scroll
HLocation dw                  ; Horizontal location in map
.ende

.enum $C304 export
VScroll db                    ; Vertical scroll
VLocation dw                  ; Vertical location on map - skips parts
ScrollScreens db              ; Counted down when scrolling between planets/in intro
_RAM_C308_ db                 ; Type of current "world"???
_RAM_C309_ db                 ; Current "world"???
DungeonFacingDirection db
.ende

.enum $C30C export
DungeonPosition db
DungeonNumber db
VehicleMovementFlags db       ; ??? used by palette rotation but could be more
                                ; Zero if not in a vehicle,else flags for terrain that can be passed?
PaletteRotatePos db           ; Palette rotation position
PaletteRotateCounter db       ; Palette rotation delay counter
_RAM_C311_ dw
_RAM_C313_ dw
DungeonPaletteIndex db
_RAM_C316_ db
_RAM_C317_ db
.ende

.struct Character
IsAlive db      ;  +0 b alive (bit 0),power boost active (bit 7)
HP db           ;  +1 b HP
MP db           ;  +2 b MP
EP dw           ;  +3 w EP
LV db           ;  +5 b LV
MaxHP db        ;  +6 b Max HP
MaxMP db        ;  +7 b Max MP
Attack db       ;  +8 b Attack
Defence db      ;  +9 b Defence
Weapon db       ; +10 \  These 3 are bytes values
Armour db       ; +11  | from the same list.
Shield db       ; +12 /
Unknown1 db     ; +13 : Tied up state?
MagicCount db   ; +14 Number of magics known (?) <5
BattleMagicCount db     ; +15 Number of battle magics known
.endst

.enum $C400 export
.union
CharacterStats     instanceof Character 12
.nextu
CharacterStatsAlis instanceof Character
CharacterStatsMyau instanceof Character
CharacterStatsOdin instanceof Character
CharacterStatsLutz instanceof Character
CharacterStatsEnemies instanceof Character 8
.endu
Inventory dsb 32              ; Item indices. Space for 32 but limit is 24..?
Meseta dw                     ; Current money
InventoryCount db             ; Number of items in Inventory
.ende

.enum $C4F0 export
PartySize db                  ; 0-3 based on how many player characters have been unlocked
.ende

.enum $C500 export
_RAM_C500_ db
HaveVisitedSuelo db           ; 1 if you have been there
HaveGotPotfromNekise db       ; 1 if you have
LuvenoPrisonVisitCounter db   ; 0 on first visit,1 after
LuvenoState db                ; 0 -> in prison,1 -> waiting for assistant,2 -> have found assistant,3 -> paid,4..5 -> waiting,6 -> built but no Hapsby,7 -> all done
.ende

.enum $C506 export
HaveLutz db                   ; 0 -> not joined yet,1 -> has joined party (but may be dead)
SootheFluteIsUnhidden db      ; 0 -> hidden,1 -> can find it
FlowMoverIsUnhidden db        ; 0 -> hidden,1 -> can find it
PerseusShieldIsUnhidden db    ; 0 -> hidden,1 -> can find it
_RAM_C50A_ db
.ende

.enum $C511 export
HaveGivenShortcake db         ; $ff if yes
.ende

.enum $C516 export
HaveBeatenLaShiec db          ; 1 if yes
HaveBeatenShadow db           ; $ff if yes
.ende

.enum $C600 export
_RAM_C600_ db ; Dialogue flags
.ende

.enum $C604 export
DungeonKeyIsHidden db         ; $ff at start of game,0 when villager tells you about it
.ende

.enum $C780 export
NameEntryMode db              ; 0 = name entry,1 = password entry (not used)
NameEntryData .db             ; nn bytes: block used for name entry
NameEntryCharIndex db         ; current char is $c7nn
.ende

.enum $C784 export
NameEntryCursorX db           ; sprite X coordinate for char selection cursor
NameEntryCursorY db           ; sprite Y coordinate for char selection cursor
NameEntryCursorTileMapDataAddress dw ; address of TileMapData byte corresponding to the current cursor position
NameEntryCurrentlyPointed db  ; value currently being pointed at by the cursor
NameEntryKeyRepeatCounter db  ; counter for key repeat - delay before faster repeat
.ende

.enum $C800 export
CharacterSpriteAttributes .dsb 256 ; Character sprite attributes:
; +0: character number? Affects +1
; +1: character number? - 0 = empty,1 = Alis,2 = Lutz,3 = Odin,4 = Myau,5 = vehicle
; +2: sprite base y
; +4: sprite base x
; +10 ($0a): ???
; +13 ($0d): animation frame index 0-3
; +14 ($0e): animation counter
; +16 ($10): currentanimframe (based on +13 and +18)
; +17 ($11): lastanimframe
; +18 ($12): current facing direction (0,1,2,3=U,D,L,R)
; +19 ($13): previous facing direction (same as above)
; First 4 are main characters,other 4 are ???
_RAM_C801_ dsb $9
_RAM_C80A_ db
.ende

.enum $C80F export
_RAM_C80F_ db
_RAM_C810_ db
.ende

.enum $C812 export
_RAM_C812_ db
.ende

.enum $C880 export
_RAM_C880_ dsb $3
.ende

.enum $C88A export
_RAM_C88A_ db
.ende

.enum $C88D export
_RAM_C88D_ db
_RAM_C88E_ db
.ende

.enum $C894 export
_RAM_C894_ db
_RAM_C895_ db
_RAM_C896_ db
_RAM_C897_ db
_RAM_C898_ db
.ende

.enum $C8A0 export
_RAM_C8A0_ dsb $3
.ende

.struct SpriteTableStruct
    Ys dsb 64
    Gap dsb 64
    XNs dsw 64
.endst

.enum $C900 export
SpriteTable instanceof SpriteTableStruct ; copy of sprite table for rapid writing to VDP
.ende

.enum $CB00 export
DungeonMap dsb 256
.ende

.enum $CBC3 export
_RAM_CBC3_ db
.ende

.enum $CC00 export
_RAM_CC00_ db ; Areas for decompression of data
.ende

.enum $CD00 export
_RAM_CD00_ db
.ende

.enum $CE00 export
_RAM_CE00_ db
.ende

.enum $CF00 export
_RAM_CF00_ db
.ende

.enum $D000 export
TileMapData db                ; RAM copy of the tilemap
.ende

.enum $D0D4 export
_RAM_D0D4_ dsb $d
_RAM_D0E1_ db
.ende

.enum $D114 export
_RAM_D114_ dsb $18
.ende

.enum $D150 export
_RAM_D150_ dsb $4
_RAM_D154_ dsb $16
_RAM_D16A_ dsb $6
.ende

.enum $D1CF export
_RAM_D1CF_ db
.ende

.enum $D1D4 export
_RAM_D1D4_ dsb $18
.ende

.enum $D1EF export
_RAM_D1EF_ db
.ende

.enum $D21C export
_RAM_D21C_ dsb $8
.ende

.enum $D300 export
TileMapData+12*32*2 dsb $300
_RAM_D600_ dsb $100
_RAM_D700_ db
.ende

.enum $D724 export
_RAM_D724_ dsb 384                   ; RAM copy of old tilemap for ???
OldTileMapMenu dsb 132               ; RAM copy of old tilemap for menu
OldTileMapEnemyName10x4 dsb 10*4*2   ; RAM copy of old tilemap for 10x4 box for enemy name
OldTileMapEnemyStats8x10 dsb 8*10*2  ; RAM copy of old tilemap for 8x10 box for enemy stats
.ende

.enum $DA18 export
OldTileMap20x6 dsb 20*6*2            ; RAM copy of old tilemap for 20x6 box
OldTileMap20x6Scroll dsb 18*3*2      ; RAM copy of text tilemap for 18x3 box (for text scrolling in 20x6 box)
_RAM_DB74_ db
.ende

.enum $DC04 export
_RAM_DC04_ db
.ende

.enum $DDA8 export
_RAM_DDA8_ db
.ende

.enum $DE14 export
_RAM_DE14_ db
.ende

.enum $DE64 export
OldTileMap5x5 dsb 5*5*2       ; RAM copy of old tilemap for 5x5 box
.ende

.enum $DF00 export
Port3EVal db                  ; Last value written to port $3e (IO control)
_RAM_DF01_ db
.ende

.enum $DFE0 export
_RAM_DFE0_ db
.ende

;=======================================================================================================
; SRAM:
;=======================================================================================================

.enum $8000 export
SRAMIdent dsb 256 ; or 64?
SaveMenuTilemap dsb 216
.ende

.enum $8201 export
SRAMSlotsUsed db
.ende

;=======================================================================================================
; Other game-specific stuff:
;=======================================================================================================

.stringmaptable script "Japanese.tbl"

.enum $80
MusicStop        db ; 80
MusicTitle       db ; 81
MusicPalma       db ; 82
MusicMotavia     db ; 83
MusicDezoris     db ; 84
MusicFinalDungeon db ; 85
MusicDungeon     db ; 86
MusicTown        db ; 87
MusicVillage     db ; 88
MusicBattle      db ; 89
MusicStory       db ; 8a
MusicEnding      db ; 8b
MusicIntro       db ; 8c
MusicChurch      db ; 8d
MusicShop        db ; 8e
MusicVehicle     db ; 8f
MusicTower_      db ; 90 ; Unused? Same as $91
MusicTower       db ; 91
MusicLassic      db ; 92
MusicDarkForce   db ; 93
MusicGameOver    db ; 94
SFX_95           db ; 95
SFX_96           db ; 96
SFX_97           db ; 97
SFX_98           db ; 98
SFX_99           db ; 99
SFX_a0           db ; a0
SFX_a1           db ; a1
SFX_a2           db ; a2
SFX_a3           db ; a3
SFX_a4           db ; a4
SFX_a5           db ; a5
SFX_a6           db ; a6
SFX_a7           db ; a7
SFX_a8           db ; a8
SFX_a9           db ; a9
SFX_aa           db ; aa
SFX_ab           db ; ab
SFX_ac           db ; ac
SFX_ad           db ; ad
SFX_Death        db ; ae
SFX_af           db ; af
SFX_b0           db ; b0
SFX_b1           db ; b1
SFX_b2           db ; b2
SFX_b3           db ; b3
SFX_b4           db ; b4
SFX_b5           db ; b5
SFX_b6           db ; b6
SFX_b7           db ; b7
SFX_b8           db ; b8
SFX_b9           db ; b9
SFX_ba           db ; ba
SFX_bb           db ; bb
SFX_bc           db ; bc
SFX_bd           db ; bd
SFX_be           db ; be
SFX_bf           db ; bf
SFX_c0           db ; c0
SFX_Heal         db ; c1
SFX_c2           db ; c2
SFX_c3           db ; c3
SFX_c4           db ; c4
SFX_c5           db ; c5
SFX_c6           db ; c6
SFX_c7           db ; c7
SFX_c8           db ; c8
SFX_c9           db ; c9
SFX_ca           db ; ca
SFX_cb           db ; cb
SFX_cc           db ; cc
SFX_cd           db ; cd
SFX_ce           db ; ce
SFX_cf           db ; cf
SFX_d0           db ; d0
SFX_d1           db ; d1
SFX_d2           db ; d2
SFX_d3           db ; d3
SFX_d4           db ; d4
SFX_d5           db ; d5
SFX_d6           db ; d6
.ende
.define MusicStop $d7

.enum 0
Item_Empty                    db ; $00
Item_Weapon_WoodCane          db ; $01
Item_Weapon_ShortSword        db ; $02
Item_Weapon_IronSword         db ; $03
Item_Weapon_PsychoWand        db ; $04
Item_Weapon_SilverTusk        db ; $05
Item_Weapon_IronAxe           db ; $06
Item_Weapon_TitaniumSword     db ; $07
Item_Weapon_CeramicSword      db ; $08
Item_Weapon_NeedleGun         db ; $09
Item_Weapon_SaberClaw         db ; $0a
Item_Weapon_HeatGun           db ; $0b
Item_Weapon_LightSaber        db ; $0c
Item_Weapon_LaserGun          db ; $0d
Item_Weapon_LaconianSword     db ; $0e
Item_Weapon_LaconianAxe       db ; $0f
Item_Armour_LeatherClothes    db ; $10
Item_Armour_WhiteMantle       db ; $11
Item_Armour_LightSuit         db ; $12
Item_Armour_IronArmor         db ; $13
Item_Armour_SpikySquirrelFur  db ; $14
Item_Armour_ZirconiaMail      db ; $15
Item_Armour_DiamondArmor      db ; $16
Item_Armour_LaconianArmor     db ; $17
Item_Armour_FradMantle        db ; $18
Item_Shield_LeatherShield     db ; $19
Item_Shield_IronShield        db ; $1a
Item_Shield_BronzeShield      db ; $1b
Item_Shield_CeramicShield     db ; $1c
Item_Shield_AnimalGlove       db ; $1d
Item_Shield_LaserBarrier      db ; $1e
Item_Shield_ShieldOfPerseus   db ; $1f
Item_Shield_LaconianShield    db ; $20
Item_Vehicle_LandMaster       db ; $21
Item_Vehicle_FlowMover        db ; $22
Item_Vehicle_IceDecker        db ; $23
Item_PelorieMate              db ; $24
Item_Ruoginin                 db ; $25
Item_SootheFlute              db ; $26 39
Item_Searchlight              db ; $27 40
Item_EscapeCloth              db ; $28 41
Item_TranCarpet               db ; $29 42
Item_MagicHat                 db ; $2a 43
Item_Alsuline                 db ; $2b 44
Item_Polymeteral              db ; $2c 45
Item_DungeonKey               db ; $2d 46
Item_TelepathyBall            db ; $2e 47
Item_EclipseTorch             db ; $2f 48
Item_Aeroprism                db ; $30 49
Item_LaermaBerries            db ; $31 50
Item_Hapsby                   db ; $32 51
Item_RoadPass                 db ; $33 52
Item_Passport                 db ; $34 53
Item_Compass                  db ; $35 54
Item_Shortcake                db ; $36 55
Item_GovernorGeneralsLetter   db ; $37 56
Item_LaconianPot              db ; $38 57
Item_LightPendant             db ; $39 58
Item_CarbuncleEye             db ; $3a 59
Item_GasClear                 db ; $3b 60
Item_DamoasCrystal            db ; $3c 61
Item_MasterSystem             db ; $3d 62
Item_MiracleKey               db ; $3e 63
Item_Zillion                  db ; $3f
Item_SecretThing              db ; $40
.ende

.enum 0
Player_Alisa  db ; 0
Player_Myau   db ; 1
Player_Tylon  db ; 2
Player_Lutz   db ; 3
.ende

.enum 0
Enemy_Empty           db ; $00
Enemy_MonsterFly      db ; $01
Enemy_GreenSlime      db ; $02
Enemy_WingEye         db ; $03
Enemy_Maneater        db ; $04
Enemy_Scorpius        db ; $05
Enemy_GiantNaiad      db ; $06
Enemy_BlueSlime       db ; $07
Enemy_MotavianPeasant db ; $08
Enemy_DevilBat        db ; $09
Enemy_KillerPlant     db ; $0A
Enemy_BitingFly       db ; $0B
Enemy_MotavianTeaser  db ; $0C
Enemy_Herex           db ; $0D
Enemy_Sandworm        db ; $0E
Enemy_MotavianManiac  db ; $0F
Enemy_GoldLens        db ; $10
Enemy_RedSlime        db ; $11
Enemy_BatMan          db ; $12
Enemy_HorseshoeCrab   db ; $13
Enemy_SharkKing       db ; $14
Enemy_Lich            db ; $15
Enemy_Tarantula       db ; $16
Enemy_Manticort       db ; $17
Enemy_Skeleton        db ; $18
Enemy_Antlion         db ; $19
Enemy_Marshes         db ; $1A
Enemy_Dezorian        db ; $1B
Enemy_DesertLeech     db ; $1C
Enemy_Cryon           db ; $1D
Enemy_BigNose         db ; $1E
Enemy_Ghoul           db ; $1F
Enemy_Ammonite        db ; $20
Enemy_Executor        db ; $21
Enemy_Wight           db ; $22
Enemy_SkullSoldier    db ; $23
Enemy_Snail           db ; $24
Enemy_Manticore       db ; $25
Enemy_Serpent         db ; $26
Enemy_Leviathan       db ; $27
Enemy_Dorouge         db ; $28
Enemy_Octopus         db ; $29
Enemy_MadStalker      db ; $2A
Enemy_DezorianHead    db ; $2B
Enemy_Zombie          db ; $2C
Enemy_LivingDead      db ; $2D
Enemy_RobotPolice     db ; $2E
Enemy_CyborgMage      db ; $2F
Enemy_FlameLizard     db ; $30
Enemy_Tajim           db ; $31
Enemy_Gaia            db ; $32
Enemy_MachineGuard    db ; $33
Enemy_BigEater        db ; $34
Enemy_Talos           db ; $35
Enemy_SnakeLord       db ; $36
Enemy_DeathBearer     db ; $37
Enemy_ChaosSorcerer   db ; $38
Enemy_Centaur         db ; $39
Enemy_IceMan          db ; $3A
Enemy_Vulcan          db ; $3B
Enemy_RedDragon       db ; $3C
Enemy_GreenDragon     db ; $3D
Enemy_FakeLaShiec     db ; $3E
Enemy_Mammoth         db ; $3F
Enemy_KingSaber       db ; $40
Enemy_DarkMarauder    db ; $41
Enemy_Golem           db ; $42
Enemy_Medusa          db ; $43
Enemy_FrostDragon     db ; $44
Enemy_DragonWise      db ; $45
Enemy_GoldDrake       db ; $46
Enemy_MadDoctor       db ; $47
Enemy_LaShiec         db ; $48
Enemy_DarkForce       db ; $49
Enemy_Nightmare       db ; $4A
.ende

; Text special characters
.define TextCharacterName $4f
.define TextEnemyName  $50
.define TextItem       $51
.define TextNumber     $52
.define text53         $53
.define TextNewLine    $54
.define TextButton     $55
.define TextEnd        $56
.define TextPauseEnd   $57
.define TextButtonEnd  $58


;=======================================================================================================
; Macros:
;=======================================================================================================

.macro TileAddressDE ; sets de to the VRAM address of tile n
  ld de,$4000 + (\1*32)
.endm

.macro TileMapAddressDE ; sets de to the VRAM tilemap address of tile x,y
  ld de,TileMapAddress+(32*\2+\1)*2
.endm

.macro TileMapAddressHL ; sets hl to the VRAM tilemap address of tile x,y
  ld hl,TileMapAddress+(32*\2+\1)*2
.endm

.macro TileMapAreaBC ; sets b to y and c to 2*x for use with InputTilemapRect
  ld bc,(\2*256) + (\1*2)
.endm

;=======================================================================================================
; SMS-specific stuff:
;=======================================================================================================
; Ports:
.define VDPAddress      $bf ; w
.define VDPData         $be ; w
.define VDPStatus       $bf ; r
.define PSG             $7f ; w
.define FMAddress       $f0 ; w
.define FMData          $f1 ; w
.define AudioControl        $f2 ; r/w
.define MemoryControl   $3e ; w
.define IOControl       $3f ; w
.define IOPort1         $dc ; r/w
.define IOPort2         $dd ; r/w
; Other:
.define SRAMPaging      $fffc ; r/w
.define SRAMPagingOn    $08
.define SRAMPagingOff   $80
.define Frame2Paging    $ffff ; r/w
.define TileMapAddress     $3800 | $4000 ; ORed with $4000 for setting VRAM address
.define SpriteTableAddress $3f00 | $4000
.define PaletteAddress     $0000 | $c000
; VDP registers
.enum $80
VDPReg_0                 db ; Misc
VDPReg_1                 db ; Misc
VDPRegTileMapAddress     db
VDPReg_3                 db ; Unused
VDPReg_4                 db ; Unused
VDPRegSpriteTableAddress db
VDPRegSpriteTileSet      db
VDPRegBorderColour       db
VDPRegHScroll            db
VDPRegVScroll            db
VDPRegLineInt            db
.ende
.define P1U %00000001
.define P1D %00000010
.define P1L %00000100
.define P1R %00001000
.define P11 %00010000
.define P12 %00100000

;=======================================================================================================
; Bank 0: $0000 - $3fff
;=======================================================================================================
.bank 0 slot 0

.org $0000
.section "Boot handler" overwrite
    di
    im 1
    ld sp,$CB00
    jr Start
.ends
; followed by
.orga $0008
.section "SetVRAMAddressToDE() @ vector $0008" overwrite
; Outputs de to VRAM address port
; rst $08 / rst 08h
SetVRAMAddressToDE:
SetVDPRegisterDToE:
    ld a,e
    out (VDPAddress),a
    ld a,d
    out (VDPAddress),a
    ret
.ends
; followed by
.orga $0038
.section "IRQ handler" overwrite
IRQHandler:
    push af
      in a,(VDPStatus)
      or a
      jp p,IRQ_NotVBlank ; bit 7 not set
      jp VBlank          ; otherwise -> VBlank
.ends
; followed by
.section "Display enable/disable" overwrite
TurnOffDisplay:
    ld a,(VDPReg1)
    and $bf            ; Remove display enable bit
    jr +

TurnOnDisplay:
    ld a,(VDPReg1)
    or $40             ; Set display enable bit
+:  ld (VDPReg1),a
    ld e,a
    ld d,VDPReg_1
    rst SetVDPRegisterDToE
    ret
.ends
; followed by
.section "Execute function index a in next VBlank" overwrite
ExecuteFunctionIndexAInNextVBlank:
; Sets VBlankFunctionIndex to a and waits for it to be processed
    ld (VBlankFunctionIndex),a
-:  ld a,(VBlankFunctionIndex)
    or a               ; Wait for it to be zero
    jr nz,-
    ret
.ends
; followed by
.orga $0066
.section "NMI handler" overwrite
    nop                ; #############
    nop                ; #############
    nop                ; #############
    push af
      ld a,(FunctionLookupIndex)   ; Test value of FunctionLookupIndex
      cp $05
      jr z,+
      cp $09
      jr z,+
      cp $0B
      jr z,+
      cp $0D
      jr nz,++
+:    ld a,(PauseFlag)   ; If FunctionLookupIndex is 5,9,11 or 13 then invert all bits of PauseFlag
      cpl
      ld (PauseFlag),a
++: pop af
    retn
.ends
; followed by
.section "Main program start" overwrite
Start:                 ; $0087
    ld hl,SRAMPaging   ; Initialise paging registers
    ld (hl),SRAMPagingOff
    inc hl
    ld (hl),$00
    inc hl
    ld (hl),$01
    inc hl
    ld (hl),$02

    ld hl,$df00        ; Zero $df00-$dffb inclusive
    ld de,$df00+1
    ld bc,$fb
    ld (hl),$00
    ldir

    ld a,($c000)       ; Get last port $3e write from BIOS
    ld (Port3EVal),a   ; and store it in $df00

ResetPoint:
    di                 ; Already did these at boot
    ld sp,$cb00        ; but reset comes here (things done prior are one-time)

    ld hl,$c000        ; Zero $c000-$deff inclusive
    ld de,$c000+1
    ld bc,$1EFF
    ld (hl),$00
    ldir

    call CountryDetection
    or a               ; is it export?
    jr nz,+            ; if so,skip next bit

    ld b,$02           ; ############# delay by counting down $20000
-:  ld de,$ffff        ; #############
--: dec de             ; #############
    ld a,d             ; #############
    or e               ; #############
    jr nz,--           ; #############
    djnz -             ; #############

+:  call SoundInit     ; Initialise sound engine
    call FMDetection   ; FM detection
    call SRAMCheck     ; SRAM check/initialisation
    call VDPInitRegs   ; Initialise VDP registers
    call NTSCDetection ; NTSC detection
    ei

-:  ld hl,FunctionLookupIndex
    ld a,(hl)          ; Get value in FunctionLookupIndex (initialised to 0)
    and $1f            ; Strip to low 5 bits
    ld hl,FunctionLookupTable
    call FunctionLookup
    jp -

; Jump Table from EA to 111 (11 entries,indexed by FunctionLookupIndex)
FunctionLookupTable:
.dw LoadMarkIIILogo           ; 0 $06a0
.dw FadeInMarkIIILogoAndPause ; 1 $0689
.dw StartTitleScreen          ; 2 $08b7
.dw TitleScreen               ; 3 $073f --+  // and intro
.dw _LABEL_BB8_               ; 4         |
.dw _LABEL_9CB_               ; 5 *       |
.dw DoNothing                 ; 6         |
.dw DoNothing                 ; 7         |
.dw LoadScene                 ; 8       <-+
.dw _LABEL_C64_               ; 9 *
.dw _LABEL_10D9_              ; a
.dw _LABEL_1098_              ; b * Dungeon
.dw _LABEL_3D76_              ; c
.dw _LABEL_3CC0_              ; d *
.dw _LABEL_1033_              ; e
.dw _LABEL_FE7_               ; f
.dw LoadNameEntryScreen       ; 10 $4183
.dw HandleNameEntry           ; 11 $3fdd
.dw FadeToPictureFrame        ; 12
.dw FadeToPictureFrame        ; 13

FunctionLookup: ; $0112
    ; Looks up a function in the table pointed to by hl and jumps to that
    add a,a            ; Do some manoeuvring to add 2*a to hl allowing 2a+l>$ff
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)          ; Read what's at (hl+2a) into hl
    inc hl
    ld h,(hl)
    ld l,a
    jp (hl)            ; Jump to function
.ends
; followed by
.orga $011d
.section "Do pause" overwrite
; Pause loop - silences chips and then sits there waiting to be unpaused
DoPause:               ; $011d
    call SilenceChips
-:  ld a,(PauseFlag)
    or a
    ret z              ; Wait for PauseFlag=0
    jr -
.ends
; followed by
.section "VBlank handler" overwrite
VBlank:                ; $0127
    push bc
    push de
    push hl
    push ix
    push iy
      ld a,(SRAMPaging)         ; back up paging registers on stack
      push af
        ld a,(Frame2Paging)
        push af
          ld a,SRAMPagingOff
          ld (SRAMPaging),a ; turn off SRAM
          in a,(IOPort2)
          and %00010000     ; check for reset button
          ld hl,ResetButton
          ld c,(hl)         ; c = old value of ResetButton
          ld (hl),a         ; ResetButton = reset button state
          xor c             ; xor with old value
          and c             ; and with old value
                            ; old new xor result
                            ;  1   1   0    0
                            ;  1   0   1    1
                            ;  0   1   1    0
                            ;  0   0   0    0
                            ; so result = 1 if button just pushed,0 otherwise
          jp nz,ResetPoint

          ld a,(IsNTSC)
          or a
          jp nz,+
          ld b,$00          ; delay if not NTSC (why? Maybe to move CRAM dots further from the active area?) ###########
-:        djnz -
-:        djnz -
+:        ld a,(PauseFlag)
          or a
          jp nz,VBlank_Paused

          ld a,(VBlankFunctionIndex)  ; look up function in table - should be multiple of 2
          and $1f           ; trim to low 5 bits
          ld hl,VBlankFunctionTable
          add a,l
          ld l,a
          adc a,h
          sub l
          ld h,a
          ld a,(hl)
          inc hl
          ld h,(hl)
          ld l,a
          jp (hl)           ; jump to looked-up function

VBlank_LookupEnd:
          xor a             ; zero
          ld (VBlankFunctionIndex),a
VBlank_End:                   ; restore backed-up paging regs
        pop af
        ld (Frame2Paging),a
      pop af
      ld (SRAMPaging),a
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ei
    ret
.ends
; followed by
.section "VBlank function: turn on display" overwrite
; 11th entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
VBlankFunction_TurnOnDisplay:
    call TurnOnDisplay
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: palette effects" overwrite
; scroll,sprites,palette effects,tile effects,sound
; 12th entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
VBlankFunction_PaletteEffects:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    call UpdateSpriteTable
    call FadePaletteInRAM
    call FlashPaletteInRAM

    ; Update palette
    ld hl,ActualPalette
    ld de,PaletteAddress
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi32        ; output to palette

    call EnemySceneTileAnimation
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function lookup table" overwrite
VBlankFunctionTable:   ; $01bb                         enemy scene                 refresh
; Referenced by even numbers only       scroll sprites tile effects controls sound tilemap special
.dw VBlankFunction_SoundOnly        ; 0                                        Y
.dw VBlankFunction_MarkIIIFadeIn    ; 2           Y                    Y                   Mark III logo fade and delay
.dw VBlankFunction_SoundOnly        ; 4                                        Y
.dw VBlankFunction_MarkIIIFadeIn    ; 6           Y                    Y                   Mark III logo fade and delay
.dw VBlankFunction_Menu             ; 8    Y      Y         Y          Y       Y           Cursor
.dw VBlankFunction_Enemy            ; a    Y      Y         Y                  Y
.dw VBlankFunction_UpdateTilemap    ; c                                        Y    Y(28)
.dw VBlankFunction_OutsideScrolling ; e    Y      Y                    Y       Y           Palette rotation,character/vehicle sprite animation,scrolling tilemap,outside scene tile animations
.dw VBlankFunction_10               ; 10   Y      Y                            Y    Y(24)  Output palette
.dw VBlankFunction_12               ; 12   Y      Y                            Y    Y(28)  Output palette
.dw VBlankFunction_TurnOnDisplay    ; 14
.dw VBlankFunction_PaletteEffects   ; 16   Y      Y         Y                  Y           Flash palette,fade palette
.ends
; followed by
.section "VBlank function: Mark III logo fade in" overwrite
; 2nd entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
VBlankFunction_MarkIIIFadeIn:
    call UpdateSpriteTable
    call MarkIIIFadeIn
    call GetControllerInput

    ld hl,(MarkIIILogoDelay)
    ld a,l
    or h
    jp z,VBlank_LookupEnd ; end if MarkIIILogoDelay is zero
    dec hl
    ld (MarkIIILogoDelay),hl ; else decrement it and wait

    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: just update sound" overwrite
VBlankFunction_SoundOnly:
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: enemy scene with cursor" overwrite
; scroll,sprites,tile effects,controls,cursor,sound
VBlankFunction_Menu:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    call UpdateSpriteTable
    call EnemySceneTileAnimation
    call GetControllerInput
    call FlashCursor
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; 6th entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
.section "VBlank function: enemy encounter" overwrite
; scroll,sprites,tile effects,sound
VBlankFunction_Enemy:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    call UpdateSpriteTable
    call EnemySceneTileAnimation
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: Dungeon movement (tiles+sound)" overwrite
; scroll,fill tilemap from RAM,sound
VBlankFunction_UpdateTilemap:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    ld hl,TileMapData  ; where from
    xor a
    out (VDPAddress),a
    ld a,$78           ; Set VRAM address to $3800 = tilemap
    out (VDPAddress),a
    ld c,VDPData
    call outi128
    call outi128
    call outi128
    call outi128
    call outi128
    call outi128
    call outi128       ; output 896 bytes = 14 rows of tile numbers,quickly
    ld a,$03           ; Count $380 = 896 more bytes
    ld b,$80
-:  outi               ; and output another 14 rows,but more slowly
    jp nz,-
    dec a
    jp nz,-
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; 8th entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
.section "VBlank function: outside/scrolling scene" overwrite
; scroll,sprites,palette rotation,character/vehicle sprite animation,scrolling tilemap,outside scene tile animations,controls,sound
VBlankFunction_OutsideScrolling:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    call UpdateSpriteTable
    call PaletteRotate
    call AnimCharacterSprites
    call UpdateScrollingTilemap
    call OutsideSceneTileAnimations
    call GetControllerInput
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; 9th entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
.section "VBlank function: enemy in dungeon?" overwrite
; scroll,sprites,palette,output 24 rows of tilemap from RAM,sound
VBlankFunction_10:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    call UpdateSpriteTable

    ; Update palette
    ld hl,ActualPalette
    ld de,PaletteAddress
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi32        ; output to palette

    ld hl,TileMapData
    xor a
    out (VDPAddress),a
    ld a,$78
    out (VDPAddress),a ; Tilemap
    ld c,VDPData
    ld a,$06           ; count $600 bytes = 24 rows (full screen)
    ld b,$00
-:  outi               ; output
    jp nz,-
    dec a
    jp nz,-

    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; 10th entry of Jump Table from 1BB (indexed by VBlankFunctionIndex)
.section "VBlank function: update full tilemap..?" overwrite
; scroll,sprites,palette,output 28 rows of tilemap from RAM,sound
VBlankFunction_12:
    ld a,(HScroll)     ; set scroll registers
    out (VDPAddress),a
    ld a,VDPRegHScroll
    out (VDPAddress),a
    ld a,(VScroll)
    out (VDPAddress),a
    ld a,VDPRegVScroll
    out (VDPAddress),a

    call UpdateSpriteTable

    ; Update palette
    ld hl,ActualPalette
    ld de,PaletteAddress
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi32        ; output to palette

    ld hl,TileMapData
    xor a
    out (VDPAddress),a
    ld a,$78
    out (VDPAddress),a ; Tilemap
    ld c,VDPData
    ld a,$07           ; count $700 bytes = 28 rows (full tilemap)
    ld b,$00
-:  outi               ; output
    jp nz,-
    dec a
    jp nz,-

    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank paused handler" overwrite
VBlank_Paused:
    ; this seems a bit messy,maybe clear it up later? ##########
    call SilenceChips
    jp VBlank_End
.ends
; followed by
.section "Sound update redirector" overwrite
redirectSoundUpdate:
    ld hl,Frame2Paging
    ld (hl),:SoundUpdate
    jp SoundUpdate
.ends
; followed by
.section "Init sound engine redirector" overwrite
SoundInit:
    ld hl,Frame2Paging
    ld (hl),:SoundInitialise
    jp SoundInitialise
.ends
; followed by
.section "Silence chips sound engine redirector" overwrite
SilenceChips:
    ld hl,Frame2Paging
    ld (hl),:SilencePSGandFM
    jp SilencePSGandFM
.ends
; followed by
.section "Non-VBlank IRQ handler" overwrite
IRQ_NotVBlank:
    pop af             ; ################### not used?
    ei
    ret
.ends
; followed by
.section "Clear sprite table" overwrite
ClearSpriteTableAndFadeInWholePalette:
    ld hl,SpriteTable  ; Fill SpriteTable y positions with 224 to disable sprites
    ld de,SpriteTable + 1
    ld bc,64
    ld (hl),$E0
    ldir

    ld c,191           ; then fill the rest with $00
    ld (hl),$00
    ldir

    ld a,$14           ; VBlankFunction_TurnOnDisplay
    call ExecuteFunctionIndexAInNextVBlank

    jp FadeInWholePalette ; and ret
.ends
; followed by
.section "Country detection" overwrite
; Sets IsJapanese ram variable and returns in a
CountryDetection:
    ; Original code
    ld a,$F5
    out (IOControl),a  ; $f5 -> (IOControl)
    in a,(IOPort2)     ; (IOPort2) -> a
    and $C0
    cp  $c0            ; Check value that came back
    jr nz,+
    ld a,$55
    out (IOControl),a  ; $55 -> (IOControl)
    in a,(IOPort2)     ; (IOPort2) -> a
    and $C0
    or a               ; Check value that came back
    jr nz,+
    ld a,$ff           ; Japanese system detected
    out (IOControl),a  ; Reset IOControl
    ld (IsJapanese),a  ; Save to RAM ($ff)
    ret
+:  xor a              ; Export system detected
    ld (IsJapanese),a  ; Save to RAM ($00)
    ret
.ends
; followed by
.section "NTSC detection" overwrite
NTSCDetection:
    ld hl,$0000
-:  in a,(VDPStatus)   ; Check VDP status      ; 000386 DB BF
    or a
    jp p,-             ; Wait for bit 7 (VSync) to be 0
-:  in a,(VDPStatus)
    or a
    jp p,-             ; Again
-:  inc hl             ; Now count up in hl
    in a,(VDPStatus)
    or a
    jp p,-             ; so hl = number of reads before bit became 1 again
    xor a              ; 0 -> a and reset carry
    ld de,$0800
    sbc hl,de          ; carry = (hl>$800)
    sbc a,a            ; a = 0 if carry=0, ff otherwise
    ld (IsNTSC),a      ; Save to IsNTSC
    ret
.ends
; followed by
.section "FM chip detection" overwrite
; Sets HasFM ram variable
FMDetection:
    ld a,(Port3EVal)
    or $04             ; Disable IO chip
    out (MemoryControl),a
    ld bc, (7<<8)|0           ; Counter (7 -> b), plus 0 -> c
-:  ld a,b
    and $01
    out (AudioControl),a   ; Output 0/1 lots of times
    ld e,a
    in a,(AudioControl)
    and $07            ; Mask off high bits
    cp e               ; Compare to what was written
    jr nz,+
    inc c              ; c = # of times out==in
+:  djnz -
    ld a,c
    cp $07             ; if out==in 7 times then I must have a YM2413!
    jr z,+
    xor a              ; 0 -> a
+:  and $01            ; Strip to bit 0
    out (AudioControl),a   ; Output $01 if YM2413 and $00 otherwise
    ld (HasFM),a       ; Store that in HasFM
    ld a,(Port3EVal)
    out (MemoryControl),a  ; Turn IO chip back on
    ret
.ends
; followed by
.section "Get controller input" overwrite
GetControllerInput:
    in a,(IOPort1)     ; Get controls
    ld hl,ControlsNew
    cpl                ; Invert so 1 = pressed
    ld b,a             ; b = all buttons pressed
    xor (hl)
    ld (hl),b          ; Store b in ControlsNew
    inc hl
    and b              ; a = all buttons pressed since last time
    ld (hl),a          ; Store a in Controls
    ret
.ends
; followed by
.section "Output bc bytes from hl to VRAM de" overwrite
; Output bc bytes from hl to VRAM address de
OutputToVRAM:
    rst SetVRAMAddressToDE
    ld a,c
    or a
    jr z,+
    inc b
+:  ld a,b
    ld b,c
    ld c,VDPData
-:  outi
    jp nz,-
    dec a
    jp nz,-
    ret
.ends
; followed by
.section "Fill VRAM" overwrite
ClearTileMap:
    ld de,TileMapAddress
    ld bc,32*28        ; number of words
    ld hl,$0000        ; value to fill with
    ; fall through
FillVRAMWithHL:
; Fills bc words of VRAM from de with hl
    rst SetVRAMAddressToDE
    ld a,c
    or a               ; if c!=0 then inc b to make it loop over the right number
    jr z,+
    inc b
+:
-:  ld a,l             ; output hl to VDPData
    out (VDPData),a
    push af
    pop af
    ld a,h
    out (VDPData),a
    dec c              ; Decrement counter c
    jr nz,-
    djnz -
    ret
.ends
; followed by
.section "Output tilemap (interleaved) b x c tiles" overwrite
; Sets VRAM address to de
; Then outputs (hl) to VDPData, alternating with (TileMapHighByte)
; Outputs c words total (c bytes from (hl))
; Then moves VRAM write address forward by $40 (64 bytes)
; Repeats all of above b times
;
; So hl = tilemap data (low byte only)
; b = height /tiles
; c = width /tiles
; de = VRAM location
OutputTilemapRawBxC:
-:  push bc
      rst SetVRAMAddressToDE
      ld b,c
      ld c,VDPData
--:   outi           ; out (c),(hl); dec b; inc hl
      ld a,(TileMapHighByte)
      nop            ; delay
      out (c),a
      jr nz,--
      ex de,hl       ; add $40 to de
      ld bc,$40
      add hl,bc
      ex de,hl
    pop bc
    djnz -
    ret
.ends
; followed by
.section "Output tilemap (full data) b x c/2 tiles" overwrite
; Sets VRAM address to de
; Then outputs (hl) to VDPData
; Outputs c bytes total
; Then moves VRAM write address forward by $40 (64 bytes)
; Repeats all of above b times
;
; So hl = tilemap data (both bytes)
; b = height /tiles
; c = 2*width /tiles
; de = VRAM location
OutputTilemapRawDataBox:
-:  push bc
      rst SetVRAMAddressToDE
      ld b,c
      ld c,VDPData
--:   outi           ; out (c),(hl); dec b; inc hl
      jp nz,--
      ex de,hl       ; add $40 to de
      ld bc,$40
      add hl,bc
      ex de,hl
    pop bc
    djnz -
    ret
.ends
; followed by
.section "Tile loader (1bpp)" overwrite
; a is stored in Mask1BitOutput
; its low 4 bits are processed r-l
; for each 1 bit, the data in (hl) is output to the VDP starting at de
; for each 0 bit, a $00 is output
; eg. %----1101 -> (hl), 0, (hl), (hl)
; Repeat with next (hl), bc times.
; Suitable for 1-bit graphics
; Only used for Mark III logo (?) ############
Output1BitGraphics:
    ld (Mask1BitOutput),a ; a -> Mask1BitOutput
    rst SetVRAMAddressToDE
--: ld a,(hl)          ; get data at (hl)
    exx                ; swap bc,de,hl with mirrors
      ld c,VDPData
      ld b,$04
      ld h,a             ; backup data
      ld a,(Mask1BitOutput) ; get back original a
-:    rra                ; rotate right through carry
      ld d,h             ; get data back - could have put it there in the first place ##########
      jr c,+             ; if rotate went into carry
      ld d,$00           ; then keep it, else zero
+:    out (c),d          ; output to VDP
      djnz -             ; repeat 4 times
    exx                ; swap back
    inc hl             ; move to next data
    dec bc             ; decrement counter
    ld a,b
    or c
    jp nz,--           ; repeat if non-zero
    ret
.ends
; followed by
.section "Initialise VDP registers" overwrite
VDPInitRegs:           ; $045d
    ld hl,_VDPData
    ld bc,(_VDPDataEnd-_VDPData)<<8 | VDPAddress
    otir               ; Output VDP data

    ld a,(_VDPData)    ; Store some of it in RAM
    ld (VDPReg0),a
    ld a,(_VDPData + 2)
    ld (VDPReg1),a
    ret

; Data from 472 to 485 (20 bytes)
_VDPData:
.db $06,VDPReg_0
.db $A0,VDPReg_1
.db $FF,VDPRegTileMapAddress
.db $FF,VDPReg_3
.db $FF,VDPReg_4
.db $FF,VDPRegSpriteTableAddress
.db $FF,VDPRegSpriteTileSet
.db $00,VDPRegBorderColour
.db $00,VDPRegHScroll
.db $00,VDPRegVScroll

.ends
; followed by
.section "Tile loader (4 bpp RLE, no di/ei)" overwrite
; Decompresses tile data from hl to VRAM address de
LoadTiles4BitRLENoDI:
    ld b,$04
-:  push bc
    push de
      call + ; called 4 times for 4 bitplanes
    pop de
    inc de
    pop bc
    djnz -
    ret
+:
--: ld a,(hl)          ; read count byte <----+
    inc hl             ; increment pointer    |
    or a               ; return if zero       |
    ret z              ;                      |
                       ;                      |
    ld c,a             ; get low 7 bits in b  |
    and $7f            ;                      |
    ld b,a             ;                      |
    ld a,c             ; set z flag if high   |
    and $80            ; bit = 0              |
                       ;                      |
-:  rst SetVRAMAddressToDE ; <--------------+ |
    ld a,(hl)          ; Get data byte in a | |
    out (VDPData),a    ; Write it to VRAM   | |
    jp z,+             ; If z flag then  -+ | |
                       ; skip inc hl      | | |
    inc hl             ;                  | | |
                       ;                  | | |
+:  inc de             ; Add 4 to de <----+ | |
    inc de             ;                    | |
    inc de             ;                    | |
    inc de             ;                    | |
    djnz -             ; repeat block  -----+ |
                       ; b times              |
    jp nz,--           ; If not z flag then --+
    inc hl             ; inc hl here instead  |
    jp --              ; repeat forever ------+
                       ; (zero count byte quits)
.ends
; followed by
.section "Tile loader (4 bpp RLE, with di/ei)" overwrite
LoadTiles4BitRLE:      ; $04b3   Same as NoDI only with a di/ei around the VRAM access (because VBlanks will mess it up)
    ld b,$04           ; 4 bitplanes
-:  push bc
    push de
      call +
    pop de
    inc de
    pop bc
    djnz -
    ret
--:
+:  ld a,(hl)          ; header byte
    inc hl             ; data byte
    or a
    ret z              ; exit at zero terminator
    ld c,a             ; c = header byte
    and $7F
    ld b,a             ; b = count
    ld a,c
    and $80            ; z flag = high bit
-:  di
      rst SetVRAMAddressToDE
      ld a,(hl)
      out (VDPData),a    ; output data
    ei
    jp z,+             ; if z flag then don't move to next data byte
    inc hl
+:  inc de             ; move target forward 4 bytes
    inc de
    inc de
    inc de
    djnz -             ; repeat b times
    jp nz,--
    inc hl
    jp --
.ends
; followed by
.orga $4e2
.section "8-bit multiplication" overwrite
Multiply8:             ; $4e2
; input: h,e
; output: hl = h*e
; Works by shifting h left, and adding e in to lower 8 bits of hl whenever the it shifted out was a 1
; Thus, for every 1 in h, you get e << (position of that bit) added to the result
; Only called once
    ld d,$00           ; d=0 since we only want to add in e
    ld l,d             ; l=0 since we only care about the high bits' effect, and want to start with a total of 0
    add hl,hl          ; double hl (ie. shift h left, shift total left at the same time)
.rept 7
    jr nc,+
    add hl,de          ; if a bit is carried then add de (== add e to the total)
+:  add hl,hl          ; repeat for 8 bits
.endr
    ret nc
    add hl,de
    ret
.ends
; followed by
.orga $505
.section "16-bit multiplication" overwrite
Multiply16:            ; $0505
; input: de,bc
; output: dehl = de*bc
; Called 3 times
    or a               ; clear carry
    ld hl,$0000        ; zero hl

.rept 15
    rl e
    rl d               ; de<<=1,also copy carry into low bit of de (0 on first iteration,1 on others if hl just overflowed)
    jr nc,+
    add hl,bc          ; if a bit was rotated out then add bc to hl
    jr nc,+
    inc de             ; if hl has overflowed then there's another bit to carry into de
+:  add hl,hl          ; hl<<=1,carry bit set if it overflowed (will be carried into de by following opcodes)
.endr

    rl e               ; last iteration: rets instead of jrs
    rl d
    ret nc
    add hl,bc
    ret nc
    inc de             ; pick up last possible overflow bit
    ret
.ends
; followed by
.orga $5b7
.section "fn5b7 - divide?" overwrite
_LABEL_5B7_:
; Divide? hl/=e? or is it mod?
; used once
    xor a              ; zero a
    add hl,hl          ; hl <<= 1 (shift into carry)
.rept 16
    adc a,a            ; double a and add carry bit (shift out of hl)
    jr c,+             ; if a overflowed
    cp e               ; compare to e
    jr c,++            ; if bigger
+:  sub e              ; subtract e
    or a               ; make carry flag 1
++: ccf                ; make carry flag 0
    adc hl,hl          ; double hl and add carry bit
.endr
    ret
.ends
; followed by
.orga $66a
.section "Random number generator" overwrite
GetRandomNumber:
; returns a pseudo-random number in a
    push hl
      ld hl,(RandomNumberGeneratorWord)
      ld a,h         ; get high byte
      rrca           ; rotate right by 2
      rrca
      xor h          ; xor with original
      rrca           ; rotate right by 1
      xor l          ; xor with low byte
      rrca           ; rotate right by 4
      rrca
      rrca
      rrca
      xor l          ; xor again
      rra            ; rotate right by 1 through carry
      adc hl,hl      ; add RandomNumberGeneratorWord to itself
      jr nz,+
      ld hl,$733c    ; if last xor resulted in zero then re-seed random number generator
+:    ld a,r         ; r = refresh register = semi-random number
      xor l          ; xor with l which is fairly random
      ld (RandomNumberGeneratorWord),hl
    pop hl
    ret                ; return random number in a
.ends
; 2nd entry of Jump Table from EA (indexed by FunctionLookupIndex)
.orga $689
.section "Startup functions" overwrite
FadeInMarkIIILogoAndPause:
    ld a,$02           ; VBlankFunction_MarkIIIFadeIn
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P11 | P12      ; Button 1 or 2
    jr nz,+            ; If button pressed then skip to function 2 = StartTitleScreen
    ld a,(MarkIIILogoDelay)
    or a
    ret nz             ; Keep doing this function until MarkIIILogoDelay is zero
+:
-:  ld hl,FunctionLookupIndex ; This bit used by more than one function
    ld (hl),2          ; Set FunctionLookupIndex to 2 (StartTitleScreen)
    ret

; 1st entry of Jump Table from EA (indexed by FunctionLookupIndex)
LoadMarkIIILogo:
    ld a,(IsJapanese)
    or a
    jr nz,-            ; if IsJapanese==0 then skip to function 2 = StartTitleScreen

    ld hl,FunctionLookupIndex
    inc (hl)           ; Set FunctionLookupIndex to the next in sequence (FadeInMarkIIILogoAndPause)
    di

      ld hl,120          ; Number of frames to show logo for (2s)
      ld (MarkIIILogoDelay),hl

      ld hl,TileMapHighByte
      ld (hl),$01

      call TurnOffDisplay
      call SoundInit
      call ClearTileMap

      ; Clear tile 0
      TileAddressDE 0    ; Tile 0
      ld bc,16           ; 16 words = 1 tile
      ld hl,$0000        ; What to fill with
      call FillVRAMWithHL

      ; Load tiles
      ld hl,Frame2Paging
      ld (hl),:MarkIIILogo1bpp
      ld hl,MarkIIILogo1bpp
      TileAddressDE 256  ; Target tile
      ld bc,_sizeof_MarkIIILogo1bpp ; Count /bytes
      ld a,$01           ; Output mask (what to set 1s to)
      call Output1BitGraphics

      ; Load tilemap
      ld a,$01
      ld (TileMapHighByte),a
      ld hl,MarkIIILogoTilemap
      TileMapAddressDE 7,10 ; x,y
      ld bc,(2<<8)|19        ; Size (h<<8)|w)
      call OutputTilemapRawBxC

      ; Fill palette with colour $38 = blue
      ld de,PaletteAddress
      ld bc,16           ; 16 words = 32 bytes = full palette
      ld hl,$3838        ; should be $0000 to stop startup flash :P
      call FillVRAMWithHL

      ; Fill TargetPalette (32 bytes) with $38 = blue
      ld hl,TargetPalette
      ld de,TargetPalette + 1
      ld bc,32-1
      ld (hl),$38
      ldir

      ld a,$FF
      ld (_RAM_DF01_),a
      ld hl,$0000
      ld (PaletteMoveDelay),hl ; $00 -> PaletteMoveDelay, PaletteMovePos

    ei
    jp ClearSpriteTableAndFadeInWholePalette ; and ret
.ends
; followed by
.section "Fade in Mark III logo" overwrite
MarkIIIFadeIn:
    ld hl,PaletteMoveDelay
    dec (hl)
    ret p              ; Do nothing while PaletteMoveDelay is >=0
    ld (hl),$07        ; Put 7 in there (so it runs every 8 calls)
    inc hl
    ld a,(hl)          ; PaletteMovePos
    cp _ColoursEnd-_Colours
    ret nc             ; Do nothing if >=8
    inc (hl)           ; otherwise increment
    ld e,a
    ld d,$00           ; de = PaletteMovePos (before increment)
    ld hl,_Colours     ; Look up in colour table
    add hl,de
    ld a,(hl)
    ld de,PaletteAddress+1 ; Palette index 1
    push af
      rst SetVRAMAddressToDE
      ex (sp),hl     ; delay
      ex (sp),hl
    pop af
    out (VDPData),a
    ret

_Colours:              ; $737
.db $38,$38,$38,$39,$3A,$3B,$3E,$3F    ; Stupid palette fade :P should choose better colours?

.ends
; 4th entry of Jump Table from EA (indexed by FunctionLookupIndex)
.section "Title screen" overwrite
; Title screen menu / intro
TitleScreen:
    TileMapAddressHL 9,16
    ld (CursorTileMapAddress),hl

    ld a,$01
    ld (CursorMax),a

    call WaitForMenuSelection
    or a               ; examine returned value
    jp nz,TitleScreenContinue

NewGame:
    ld hl,GameData
    ld de,GameData+1
    ld bc,$400-1
    ld (hl),$00
    ldir               ; zero GameData

    ld iy,CharacterStatsAlis
    ld (iy+CharacterStats.Weapon),Item_Weapon_ShortSword
    ld (iy+CharacterStats.Armour),Item_Armour_LeatherClothes
    call InitialiseCharacterStats

    ld hl,_RAM_C600_
    ld (hl),$FF
    ld hl,DungeonKeyIsHidden
    ld (hl),$FF
    ld hl,$0404        ; Set "world" to 4 (type 4)
    ld (_RAM_C308_),hl
    ld hl,$0610
    ld (HLocation),hl
    ld (_RAM_C313_),hl
    ld hl,$0100
    ld (VLocation),hl
    ld (_RAM_C311_),hl
    ld hl,$0000
    ld (Meseta),hl

    call IntroSequence

    ld hl,FunctionLookupIndex
    ld (hl),$08 ; LoadScene
    ret
.ends
; followed by
.section "Continue selected on title screen" overwrite
TitleScreenContinue:
    ld a,SRAMPagingOn
    ld (SRAMPaging),a
    ld hl,SRAMSlotsUsed
    ld b,5             ; number of slots
-:  ld a,(hl)
    or a               ; Look for any used slots
    jr nz,_UsedSlotFound
    inc hl
    djnz -
    ld a,SRAMPagingOff
    ld (SRAMPaging),a
    jp NewGame         ; Start new game if none found

_UsedSlotFound:
    ld a,SRAMPagingOff
    ld (SRAMPaging),a

    call FadeOutFullPalette

    di
      call ClearTileMap
    ei

    ld hl,FunctionLookupIndex
    ld (hl),$08        ; LoadScene
    ld hl,Frame2Paging
    ld (hl),:TilesFont

    ld hl,TilesFont
    TileAddressDE $c0
    call LoadTiles4BitRLE
    ld hl,TilesExtraFont
    TileAddressDE $1f0
    call LoadTiles4BitRLE
    call ClearSpriteTableAndFadeInWholePalette

_ContinueOrDeleteMenu:
    ld hl,textContinueOrDelete
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_Delete
    ; Continue chosen
    ld hl,textChooseSlotToContinue
    call TextBox20x6
-:  push bc
      call GetSavegameSelection
    pop bc
    call IsSlotUsed
    jr z,-
    ld hl,textContinuingGameX
    call TextBox20x6
    call Close20x6TextBox

    ld a,SRAMPagingOn  ; Load game
    ld (SRAMPaging),a
    ld a,(NumberToShowInText)
    ld h,a
    ld l,$00
    add hl,hl
    add hl,hl
    set 7,h            ; hl = $8000 + $400*a = slot a game data ($400 bytes)
    ld de,GameData
    ld bc,$400         ; 1024 bytes
    ldir               ; Copy
    ld a,SRAMPagingOff
    ld (SRAMPaging),a
    ld a,(_RAM_C316_)
    cp 11
    ret nz             ; if == 11
    ld hl,FunctionLookupIndex
    ld (hl),$0a        ; ???
    ret

_Delete:
    ld hl,textConfirmDelete
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_ContinueOrDeleteMenu ; No -> back to start
--: ld hl,textChooseWhichToDelete
    call TextBox20x6
-:  push bc
      call GetSavegameSelection
      bit 4,c        ; z set if button 1 pressed
    pop bc
    jr nz,_Delete      ; repeat if button 2 pressed(?)
    call IsSlotUsed
    jr z,-             ; wait for a valid selection
    ld hl,textSaveDeleteConfirmSlot
    call TextBox20x6
    call DoYesNoMenu
    jr nz,--
    ld hl,textGameXHasBeenDeleted
    call TextBox20x6

    ld a,SRAMPagingOn  ; Delete game
    ld (SRAMPaging),a
    ld a,(NumberToShowInText)
    ld h,$82
    ld l,a             ; hl = 820n -> SRAMSlotsUsed
    ld (hl),$00        ; Mark as not there

    dec a              ; a = 0-based index of game
    add a,a
    ld e,a
    add a,a
    add a,a
    add a,a
    add a,e
    add a,a
    add a,$18
    ld e,a
    ld d,$81           ; de = SaveMenuTilemap + $16 + 66*a
    ld hl,_5Blanks
    ld bc,10
    ldir               ; Blank top line of name in SRAM tilemap
    ex de,hl
    ld bc,$0008        ; Add 8 to get to next row
    add hl,bc
    ex de,hl
    ld hl,_5Blanks
    ld bc,10
    ldir               ; Blank bottom line of name

    ld a,SRAMPagingOff
    ld (SRAMPaging),a
    ld hl,FunctionLookupIndex
    ld (hl),2          ; StartTitleScreen
    ret

; Data from 89A to 8A3 (10 bytes)
_5Blanks:
.dsw 5 $10c0           ; Blank tile in front of sprites

IsSlotUsed:
    ld a,SRAMPagingOn
    ld (SRAMPaging),a
    ld a,(NumberToShowInText)
    ld l,a
    ld h,$82           ; hl = 82nn -> SRAMSlotsUsed
    ld a,(hl)          ; Set z if slot not used
    or a
    ld a,SRAMPagingOff
    ld (SRAMPaging),a
    ret
.ends
; 3rd entry of Jump Table from EA (indexed by FunctionLookupIndex)
.section "Start title screen" overwrite
StartTitleScreen:      ; $08b7
    call FadeOutFullPalette
    di
      call TurnOffDisplay
      call SoundInit
      call ClearTileMap

      ld hl,FunctionLookupIndex
      inc (hl)           ; TitleScreen

      ld hl,600
      ld (MarkIIILogoDelay),hl ; ??? ##############

      ld hl,_TitleScreenPalette
      ld de,TargetPalette
      ld bc,_sizeof__TitleScreenPalette
      ldir               ; load palette
      ld hl,_RAM_C260_
      ld de,_RAM_C260_ + 1
      ld bc,$9f
      ld (hl),$00
      ldir               ; zero $c260-$c2ff

      ld hl,CharacterSpriteAttributes
      ld de,CharacterSpriteAttributes + 1
      ld bc,$00FF
      ld (hl),$00
      ldir               ; zero $c800-$c8ff
      ld hl,Frame2Paging
      ld (hl),:TilesTitleScreen
      ld hl,TilesTitleScreen
      TileAddressDE 0    ; tile number 0
      call LoadTiles4BitRLENoDI
      ld hl,Frame2Paging
      ld (hl),:TitleScreenTilemap
      ld hl,TitleScreenTilemap
      call DecompressToTileMapData

      xor a
      ld (VScroll),a
      ld (HScroll),a     ; Reset scroll registers

      ld a,MusicTitle
      ld (NewMusic),a ; Start music

      ld de,$8006        ; Output %00000110 to VDP register 0 - enable stretch screen, no scroll lock/column mask/line int/desync
      rst SetVDPRegisterDToE
    ei
    ld a,$0c           ; VBlankFunction_UpdateTilemap
    call ExecuteFunctionIndexAInNextVBlank
    jp ClearSpriteTableAndFadeInWholePalette ; and ret

; Data from 925 to 944 (32 bytes)
_TitleScreenPalette:
.db $00,$00,$3F,$0F,$0B,$06,$2B,$2A,$25,$27,$3B,$01,$3C,$34,$2F,$3C
.db $00,$00,$3C,$0F,$0B,$06,$2B,$2A,$25,$27,$3B,$01,$3C,$34,$2F,$3C
.ends
; followed by
.section "SRAM check" overwrite
SRAMCheck:
    ld a,SRAMPagingOn
    ld (SRAMPaging),a  ; Page in SRAM
    ld hl,SRAMIdent
    ld de,_SRAMIdentData
    ld bc,_sizeof__SRAMIdentData
-:  ld a,(de)
    inc de
    cpi                ; check if first $40 bytes of SRAM are the same as the marker
    jr nz,_InitSRAM    ; If not, initialise SRAM
    jp pe,-            ; Loop - p flag indicates when bc underflows
    ld a,SRAMPagingOff
    ld (SRAMPaging),a  ; page out SRAM
    ret

; Data from 962 to 9A1 (64 bytes)
_SRAMIdentData:
.db "PHANTASY STAR   "
.db "      BACKUP RAM"
.db "PROGRAMMED BY   "
.db "       NAKA YUJI"

_InitSRAM:
    ld hl,SRAMIdent
    ld de,SRAMIdent + 1
    ld bc,$1FFB
    ld (hl),$00
    ldir               ; Zero first $1ffc bytes of SRAM

    ld hl,DefaultSRAMData
    ld de,SaveMenuTilemap
    ld bc,_sizeof_DefaultSRAMData
    ldir               ; Fill from SaveMenuTilemap with default data

    ld hl,_SRAMIdentData
    ld de,SRAMIdent
    ld bc,_sizeof__SRAMIdentData
    ldir               ; Put in the identifier

    ld a,SRAMPagingOff
    ld (SRAMPaging),a  ; Page out SRAM
    ret
.ends
; 6th entry of Jump Table from EA (indexed by FunctionLookupIndex)
.orga $9cb
.section "unprocessed code" overwrite
_LABEL_9CB_:
    ld hl,$2009        ; Fade out, 32 colours
    ld (PaletteFadeControl),hl

-:  ld a,(PauseFlag)
    or a
    call nz,DoPause    ; Pause if flagged

    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank

    ld a,(Controls)
    and P11 | P12
    jr nz,_f

    call _LABEL_AF4_
    ld hl,(_RAM_C2F2_)
    ld de,8
    add hl,de
    ld (_RAM_C2F2_),hl
    ld a,h
    cp $08             ; Loop until h = $8 = 4096 frames = 68.2s?
    jr c,-

 __:ld a,$16           ; VBlankFunction_PaletteEffects
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(PaletteFadeControl)
    or a               ; repeat until palette is faded out
    jr nz,_b

    jr +               ; ####################
+:  ld hl,Frame2Paging

    ld (hl),:PaletteSpace
    ld hl,PaletteSpace
    ld de,TargetPalette
    ld bc,_sizeof_PaletteSpace
    ldir               ; Load palette
    call _LoadPlanetPalette

    ld hl,TilesSpace
    TileAddressDE 0
    call LoadTiles4BitRLE ; load tiles

    ld hl,Frame2Paging
    ld (hl),:TilemapBottomPlanet
    ld hl,TilemapBottomPlanet
    call DecompressToTileMapData

    ld hl,TileMapData
    ld de,TileMapData+12*32*2
    ld bc,$300
    ldir               ; duplicate tilemap data
    ld hl,TileMapData
    ld bc,$100         ; 4 rows
    ldir               ; a bit more...

    ld hl,TilemapSpace
    call DecompressToTileMapData

    xor a              ; Zero:
    ld (HScroll),a
    ld (VScroll),a

    ld hl,TileMapData
    TileMapAddressDE 0,0
    ld bc,32*28*2      ; full tilemap update
    di
      call OutputToVRAM
    ei

    ld hl,TileMapData
    ld de,TileMapData+12*32*2
    ld bc,$0300
    ldir               ; ############# again?

    ld a,MusicVehicle
    ld (NewMusic),a

    call FadeInWholePalette

    ld hl,0
    ld (_RAM_C2F2_),hl

    ld a,8
    ld (ScrollScreens),a

-:  ld a,(PauseFlag)
    or a
    call nz,DoPause    ; check for pause
    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P11 | P12
    jr nz,+            ; if no button pressed:
    call _ScrollToTopPlanet
    ld a,(ScrollScreens)
    or a               ; Loop until ScrollScreens==0
    jr nz,-

+:  ld hl,FunctionLookupIndex
    ld (hl),4

    call _LABEL_BD0_

    ld hl,$0800
    ld (_RAM_C2F2_),hl
-:  ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and $30
    jr nz,+
    call _LABEL_AF4_
    ld hl,(_RAM_C2F2_)
    ld de,$0008
    or a
    sbc hl,de
    ld (_RAM_C2F2_),hl
    jr nc,-
+:  ld hl,$0000
    ld (_RAM_C2F2_),hl
    ld hl,FunctionLookupIndex
    ld (hl),$08
    ld a,(_RAM_C2E9_)
    and $7F
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,$00
    ld de,$0C18
    add hl,de
    xor a
    ld (PaletteRotateEnabled),a
    ld (ScrollDirection),a
    ld (_RAM_C2E9_),a
    ld (VehicleMovementFlags),a
    ld (ScrollScreens),a
    call _LABEL_7B1E_
    ret

_LABEL_AF4_:
    ld de,(_RAM_C2F2_)
    ld a,(VScroll)
    ld h,a
    ld b,a
    ld a,(ScrollScreens)
    ld l,a
    or a
    sbc hl,de
    ld a,h
    cp $E0
    jr c,+
    sub $20
+:  ld h,a
    ld (VScroll),a
    ld a,l
    ld (ScrollScreens),a
    ld a,b
    sub h
    and $0F
    ret z
    ld e,a
    ld d,$00
    ld hl,(VLocation)
    ld b,h
    ld a,l
    sub e
    cp $C0
    jr c,+
    sub $40
    dec h
+:  ld l,a
    ld a,h
    and $07
    ld h,a
    ld (VLocation),hl
    cp b
    call nz,DecompressScrollingTilemapData
    call _LABEL_75DD_
    ld a,(_RAM_C2F3_)
    cp $07
    ret nz
    ld a,(PaletteFadeControl)
    or a
    call nz,FadePaletteInRAM
    ret

_ScrollToTopPlanet:
    ld de,2
    ld a,(VScroll)
    sub e              ; Scroll up by 2 lines
    cp 224
    jr c,+
    ld d,1             ; When it is >= 224
    sub 32             ; make it jump by 32 to scroll smoothly
+:  ld (VScroll),a

    ld a,(ScrollScreens)
    sub d              ; dec ScrollScreens for each screenful scrolled
    ld (ScrollScreens),a

    cp $1
    ret nz             ; exit if ScrollScreens!=1
    ld a,d
    or a
    ret z              ; or d==0

    ; When we have got to the last screen to scroll:
    ld a,(_RAM_C2E9_)
    and $7f            ; strip high bit
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,$00           ; hl = xc2e9*9
    ld de,_WorldData-9+3 ; get xc2e9th data
    add hl,de
    ld a,(hl)
    ld (_RAM_C308_),a
    call _LoadPlanetPalette

    ld hl,TargetPalette
    ld de,ActualPalette
    ld bc,32
    ldir               ; load palette

    ld hl,TilemapTopPlanet ; load top planet
    jp DecompressToTileMapData ; and ret

_LoadPlanetPalette:
    ld a,(_RAM_C308_)
    and $03
    add a,a
    ld l,a
    add a,a
    add a,l            ; a*=6
    ld d,$00
    ld e,a
    ld hl,PaletteSpacePlanets
    add hl,de
    ld de,TargetPalette+2
    ld bc,6
    ldir               ; load planet palette
    ret

; Data from BA6 to BB7 (18 bytes)
PaletteSpacePlanets:
.db $3E $38 $34 $30 $20 $04 ; Palma
.db $2F $1F $0B $06 $01 $06 ; Dezoris
.db $3F $3F $3E $3C $39 $38 ; Motavia

; 5th entry of Jump Table from EA (indexed by FunctionLookupIndex)
_LABEL_BB8_:
    ld a,(_RAM_C2E9_)
    and $7F
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,0             ; hl = xc2e9*9
    ld de,_WorldData-9
    add hl,de

    ld de,+
    push de ; Overriding return address
    call _LABEL_7B1E_

_LABEL_BD0_:
    ld a,(_RAM_C2E9_)
    and $7F
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,0
    ld de,_WorldData-9+3
    add hl,de

    ld de,+  ; Overriding return address
    push de
    call _LABEL_7B1E_

; Continuing address for two places above
+:  xor a
    ld (ControlsNew),a
    ld (ScrollDirection),a

    ld a,(_RAM_C2E9_)
    cp $83             ; ???
    ld a,$10
    jr c,+
    inc a
+:  ld (VehicleMovementFlags),a
    ld hl,0
    ld (_RAM_C2F2_),hl

    call LoadScene

    ld hl,OutsideAnimCounters ; zero OutsideAnimCounters
    ld de,OutsideAnimCounters + 1
    ld bc,24-1
    ld (hl),0
    ldir

    call SpriteHandler

    ld a,1
    ld (ScrollDirection),a ; Up
    ret

_WorldData: ; $0c1b
;    ,,--------------------------------- World number - space?
;    ||  ,,----------------------------- VLocation
;    ||  ||  ,,------------------------- HLocation
;    ||  ||  ||  ,,--------------------- World number - planet?
;    ||  ||  ||  ||  ,,----------------- VLocation
;    ||  ||  ||  ||  ||  ,,------------- HLocation
;    ||  ||  ||  ||  ||  ||  ,,--------- World number - ?
;    ||  ||  ||  ||  ||  ||  ||  ,,----- VLocation
;    ||  ||  ||  ||  ||  ||  ||  ||  ,,- HLocation
.db $00 $39 $43 $01 $8B $69 $10 $53 $17
.db $01 $37 $69 $00 $91 $43 $05 $17 $17
.db $00 $47 $35 $01 $27 $74 $0F $20 $58
.db $00 $47 $35 $02 $33 $2d $13 $18 $1b
.db $01 $53 $74 $00 $1b $35 $07 $25 $13
.db $01 $53 $74 $02 $33 $2d $13 $18 $1b
.db $02 $5b $2d $00 $1b $35 $07 $25 $13
.db $02 $5b $2d $01 $27 $74 $0f $20 $58

; 7th entry of Jump Table from EA (indexed by FunctionLookupIndex)
DoNothing:
    ret

; 10th entry of Jump Table from EA (indexed by FunctionLookupIndex)
_LABEL_C64_:
    ; check for Pause
    ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank
    call SpriteHandler
    call _LABEL_7A4F_
    ld a,(PaletteRotateEnabled)
    or a
    jr nz,+            ; if PaletteRotateEnabled then skip -+
    ld a,(MovementInProgress) ; ??? Read MovementInProgress |
    or a               ;                                    |
    jr z,+             ; if MovementInProgress==0 then skip-+
    xor a              ; Invert bits                        |
    ld (MovementInProgress),a ; and write back              |
    call _LABEL_61DF_
    or a               ; check result                       |
    jr z,+             ; if zero then skip -----------------+
    ld a,$ff           ; else set all bits in a             |
    jp ++              ; and skip onwards ------------------|-+
+:  ld a,(ControlsNew) ; Check controls  <------------------+ |
    and P11 | P12      ; Is a button pressed?                 |
    ret z              ; exit if not                          |
    ld a,(PaletteRotateEnabled) ;                             |
    or a               ;                                      |
    ret nz             ; exit if PaletteRotateEnabled         |
    xor a              ; zero a                               |
++: ld (_RAM_C29D_InBattle),a ; Save to xc29d <----------------------+

    ld hl,FunctionLookupIndex
    ld (hl),$0c        ; Set FunctionLookupIndex to 0c (???)

    ld a,(_RAM_C810_)
    ld (_RAM_C2D7_),a

    ld hl,OutsideAnimCounters
    ld de,OutsideAnimCounters+1
    ld bc,23
    ld (hl),$00
    ldir               ; Zero OutsideAnimCounters structure

    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$ff
    ld (hl),$00
    ldir               ; Zero CharacterSpriteAttributes
    ret
.ends
; 9th entry of Jump Table from EA (indexed by FunctionLookupIndex)
.orga $cc6
.section "Load scene" overwrite
LoadScene:
    call FadeOutFullPalette
    di
      call TurnOffDisplay
    ei
    ld hl,FunctionLookupIndex
    inc (hl)           ; -> 9 = ???
    xor a              ; Set to 0:
    ld (SceneAnimEnabled),a
    ld (DungeonPaletteIndex),a
    inc a              ; Set to 1:
    ld (_RAM_C2D5_),a
    ld a,(_RAM_C308_)
    cp 4
    jr nc,+
    ; load non-town tileset
    ld hl,Frame2Paging
    ld (hl),:TilesOutside
    ld hl,TilesOutside
    TileAddressDE 0
    call LoadTiles4BitRLE
    jr ++

+:  ; Otherwise, load non-Palma tileset
    ld hl,Frame2Paging
    ld (hl),:TilesTown
    ld hl,TilesTown
    TileAddressDE 0    ; could save doing this twice? ############
    call LoadTiles4BitRLE

++: call _ResetCharacterSpriteAttributes
    call SpriteHandler
    ld b,4
-:  push bc
      ld a,$0a       ; VBlankFunction_Enemy
      call ExecuteFunctionIndexAInNextVBlank
      di
        call AnimCharacterSprites
      ei
    pop bc
    djnz -
    ld a,(HLocation)   ; low byte only
    neg
    ld (HScroll),a     ; HScroll = - Hlocation (because HScroll is the opposite direction)
    ld a,(VLocation)   ; low byte only
    ld (VScroll),a
    ld a,(_RAM_C309_)
    ld e,a
    ld d,$00
    ld hl,WorldDataLookup1
    add hl,de          ; hl = WorldDataLookup1 + _RAM_c309_
    ld a,(hl)
    ld (_RAM_c308_),a       ; _RAM_c308_ = (hl) = world type
    add a,a
    ld h,a
    add a,a
    ld l,a
    add a,a
    add a,l
    add a,h
    ld l,a
    ld h,$00
    ld de,WorldDataLookup2
    add hl,de          ; hl = WorldDataLookup2 + 14*_RAM_c308_
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld (_RAM_c260_),de      ; _RAM_c260_ = word there
    ld a,(hl)
    ld (_RAM_c262_),a       ; _RAM_c262_ = byte after it
    inc hl
    ld e,(hl)
    ld d,$1F
    ld (OutsideAnimCounters.1),de ; = reset $1f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$0F
    ld (OutsideAnimCounters.2),de ; = reset $f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$0F
    ld (OutsideAnimCounters.3),de ; = reset $f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$03
    ld (OutsideAnimCounters.4),de ; = reset 3, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$0F
    ld (OutsideAnimCounters.5),de ; = reset $f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$07
    ld (OutsideAnimCounters.6),de ; = reset 7, enabled (next byte)
    inc hl
    ld a,(hl)
    ld (_RAM_c263_),a       ; _RAM_c263_ = next byte
    inc hl
    ld a,(hl)
    inc hl
    push hl
      ld h,(hl)
      ld l,a         ; hl = next word = palette location
      ld de,TargetPalette
      ld bc,17
      ldir           ; Load start of palette
      ld a,(VehicleMovementFlags)
      or a
      jr nz,+
      push hl
        ld hl,SpritePalette1
        ld bc,13
        ldir       ; Load rest of palette
      pop hl
      ldi            ; last 2 palette entries from end of palette location
      ldi
      jp ++
+:    ld hl,SpritePalette2
      ld bc,15
      ldir           ; Load different palette
++: pop hl
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a             ; hl = next word = ???
    ld (_RAM_C2D9_),hl
    call DecompressScrollingTilemapData
    call FillTilemap
    ld a,$14
    call GetLocationUnknownData
    rrca               ; divide result by 16
    rrca
    rrca
    rrca
    and $f             ; trim to low nibble
    ld (SceneType),a   ; set SceneType accordingly (???)

    ld a,(VehicleMovementFlags)
    cp $10             ; if _RAM_c30e_>16
    ld c,$b8           ; then c=$b8 (?)
    jr nc,+
    or a
    ld c,MusicVehicle  ; else c=MusicVehicle
    jr nz,+            ; if _RAM_c30e_==0
    ld a,(_RAM_c309_)       ; then:
    ld e,a
    ld d,$00
    ld hl,WorldMusics
    add hl,de          ; de = WorldMusics+_RAM_c309_
    ld c,(hl)          ; c = (de) = music number
+:  ld a,c
    call CheckMusic

    ld de,$8026
    di
      rst SetVDPRegisterDToE ; output %00100110 to VDP register 0 - ???
    ei
    jp ClearSpriteTableAndFadeInWholePalette ; and ret

CheckMusic:           ; $df3
    push hl
      ld hl,CurrentlyPlayingMusic
      cp (hl)        ; if a!=CurrentlyPlayingMusic
      jr nz,+
    pop hl
    ret

+:    ld (NewMusic),a ; then set NewMusic to a
      ld (hl),a
    pop hl
    ret

_ResetCharacterSpriteAttributes:
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$FF
    ld (hl),$00
    ldir               ; Zero $100 bytes (all of CharacterSpriteAttributes)
    ld a,(VehicleMovementFlags)
    or a               ; If zero,
    jp z,_InitialiseCharacterSpriteAttributes
    ld hl,CharacterSpriteAttributes
    ld (hl),$09        ; else set CharacterSpriteAttributes+00 to 9 (???)
    ret

_InitialiseCharacterSpriteAttributes:
    ld de,CharacterSpriteAttributes
    ld bc,32           ; size of each entry in CharacterSpriteAttributes
    ld hl,CharacterStatsAlis.IsAlive
    ld a,$01
    call +
    ld hl,CharacterStatsLutz.IsAlive
    ld a,$03
    call +
    ld hl,CharacterStatsOdin.IsAlive
    ld a,$05
    call +
    ld hl,CharacterStatsMyau.IsAlive
    ld a,$07
    ; fall through
+:                     ; $e3f
    bit 0,(hl)         ; exit if low bit of (hl) = IsAlive is not set
    ret z
    ld (de),a          ; copy a to (de) = CharacterSpriteAttributes+0 ???
    ex de,hl
    add hl,bc          ; add bc to de to get to next entry
    ex de,hl
    ret
.ends
; followed by
; Data from E47 to EFE (184 bytes)
.section "Scrolling area palettes" overwrite
Palettee47:            ; $e47
.db $08,$00,$3f,$01,$03,$0b,$0f,$2f,$06,$38,$3c,$25,$2a,$04,$30,$0c,$08
Palettee58:            ; $e58
.db $08,$00,$3f,$01,$03,$0b,$0f,$2f,$06,$38,$3c,$25,$2a,$04,$30,$0c,$2f
Palettee69:            ; $e69
.db $3f,$00,$3f,$24,$03,$3c,$0f,$3f,$28,$38,$3c,$25,$2a,$04,$30,$0c,$3f
Palettee7a:            ; $e7a
.db $09,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$08,$09,$08,$0c
Palettee8d:            ; $e8d
.db $08,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$08,$08,$0c,$04
Paletteea0:            ; $ea0
.db $2a,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$08,$2a,$2a,$2a
Paletteeb3:            ; $eb3
.db $2f,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$08,$2f,$0b,$06
Paletteec6:            ; $ec6
.db $3f,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$3f,$3f,$3c,$38
Paletteed9:            ; $ed9
.db $00,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$08,$00,$00,$00
Paletteeec:            ; $eec
.db $3c,$00,$3f,$06,$2f,$0b,$0c,$04,$2a,$25,$3c,$38,$30,$03,$02,$08,$3c,$3c,$3c
.ends
; followed by
; Data from EFF to F0D (15 bytes)
.section "Sprite palettes" overwrite
SpritePalette1:        ; $eff ; last 2 entries are dependent on something else (?)
.db $00,$3f,$2b,$0b,$2f,$37,$0f,$38,$34,$06,$01,$2a,$25,$00,$00

; Data from F0E to F1C (15 bytes)
SpritePalette2:        ; $fe0
.db $00,$3f,$02,$03,$0b,$0f,$20,$38,$34,$2f,$2a,$25,$2f,$2a,$25
.ends
; followed by
.orga $f1d
.section "World data" overwrite
WorldDataLookup1: ; which "world" to load data for for each value of _RAM_c309_
.db $00,$01,$02,$03,$04,$04,$04,$05,$05,$05,$05,$05,$06,$06,$07,$07,$07,$07,$07,$08,$08,$09,$09,$0A
WorldMusics: ; Music for each value of _RAM_c309_
.db MusicPalma,MusicMotavia,MusicDezoris,MusicDezoris,MusicTown,MusicTown,MusicTown,MusicVillage,MusicVillage,MusicVillage,MusicVillage,MusicVillage,MusicTown,MusicTown,MusicTown,MusicVillage,MusicTown,MusicVillage,MusicVillage,MusicDezoris,MusicDezoris,MusicVillage,MusicVillage,MusicFinalDungeon
WorldDataLookup2: ; "World" data
; Data from F4D to F57 (11 bytes)
WorldDataLookup2:
;    ,,--,,-------------------------------------- Offset  _RAM_c260_ \ Scrolling tilemap data?
;    ||  ||  ,,---------------------------------- Page    _RAM_c262_ /
;    ||  ||  || ,-,-,-,-,-,---------------------- various tile animation enables
;    ||  ||  || | | | | | |  ,,------------------ _RAM_c263_ ??? page?
;    ||  ||  || | | | | | |  ||  ,,--,,---------- Palette offset
;    ||  ||  || | | | | | |  ||  ||  ||  ,,--,,-- _RAM_c2d9_ ??? offset?
.db $00,$80,$0d,1,1,0,1,1,0,$1d,$47,$0e,$35,$a9 ; Palma
.db $76,$a2,$0d,0,0,1,1,0,1,$1d,$58,$0e,$b9,$a9 ; Motabia
.db $00,$80,$0e,0,0,0,0,0,0,$1d,$69,$0e,$e3,$a9 ; Dezoris
.db $00,$80,$0e,0,0,0,0,0,0,$1d,$69,$0e,$49,$aa ; Town
.db $00,$80,$18,0,0,0,0,0,0,$16,$7a,$0e,$4a,$aa ; Village
.db $62,$87,$18,0,0,0,0,0,0,$16,$8d,$0e,$70,$ab ; ???
.db $42,$8f,$18,0,0,0,0,0,0,$16,$a0,$0e,$8b,$ac ; ???
.db $d9,$93,$18,0,0,0,0,0,0,$16,$b3,$0e,$f7,$ac ; ???
.db $07,$9c,$18,0,0,0,0,0,0,$16,$c6,$0e,$5f,$ae ; ???
.db $8b,$9d,$18,0,0,0,0,0,0,$16,$d9,$0e,$71,$ae ; ??? town
.db $50,$a2,$18,0,0,0,0,0,0,$16,$ec,$0e,$37,$af ; Air Castle
.ends
.orga $fe7

_LABEL_FE7_:
    ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$0E
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and $30
    jr nz,+
    ld a,(_RAM_C2EA_)
    ld (ControlsNew),a
    call SpriteHandler
    ld a,(PaletteRotateEnabled)
    or a
    ret nz
    ld a,(_RAM_C2EB_)
    dec a
    ld (_RAM_C2EB_),a
    ret nz
+:  ld hl,FunctionLookupIndex
    ld (hl),$08
    ld a,(_RAM_C2E9_)
    add a,a
    add a,a
    add a,a
    ld l,a
    ld h,$00
    ld de,$1065
    add hl,de
    xor a
    ld (PaletteRotateEnabled),a
    ld (_RAM_C2E9_),a
    ld (_RAM_C2EA_),a
    ld (_RAM_C2EB_),a
    call _LABEL_7B1E_
    ret

; Data from 1033 to 107C (74 bytes)
_LABEL_1033_: ; Unreferenced?
    ld a, (_RAM_C2E9_)
    ; Find a'th entry in _DATA_1068 (1-based)
    add a, a
    add a, a
    add a, a
    ld l, a
    ld h, $00
    ld de, _DATA_1068 - 8
    add hl, de
    ld a, (hl)
    ld (_RAM_C2EA_), a
    inc hl
    ld a, (hl)
    ld (_RAM_C2EB_), a
    inc hl
    ld de, +
    push de
    call _LABEL_7B1E_
+:  call _LABEL_CC6_
    ld hl, _RAM_C26F_
    ld de, _RAM_C26F_ + 1
    ld bc, $0017
    ld (hl), $00
    ldir
    ld hl, $0001
    ld (_RAM_C27B_), hl
    ret

_DATA_1068:
.db $04 $0C $00 $38 $51 $05 $21 $2C
.db $01 $0B $00 $46 $46 $05 $27 $21
.db $01 $04 $01 $33 $64 $0E $2A $20
.db $08 $0C $00 $38 $48 $04 $21 $53
.db $02 $0B $00 $3A $46 $06 $54 $20
.db $02 $04 $01 $2B $64 $10 $43 $1E

_LABEL_1098_:
    ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$08 ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    call _LABEL_6891_
    ld a,(MovementInProgress)
    or a
    ret z
    xor a
    ld (MovementInProgress),a
    ld a,(BattleProbability)
    ld b,a
    call GetRandomNumber
    cp b
    ret nc
    ld b,$01
    call _LABEL_6E6D_
    ret nz
    xor a
_LABEL_10C0_:
    ld (MovementInProgress),a
    ld a,(DungeonMonsterPoolIndex)
    call _LABEL_6254_SelectMonsterFromPool
    or a
    ret z
    call LoadEnemy
    call _LABEL_116B_
    ld a,(CharacterSpriteAttributes)
    or a
    call nz,_LABEL_1D3D_
    ret

; 11th entry of Jump Table from EA (indexed by FunctionLookupIndex)
_LABEL_10D9_:
    call FadeOutFullPalette
    call CheckDungeonMusic
    ld hl,FunctionLookupIndex
    inc (hl)
    ld hl,Frame2Paging
    ld (hl),$10
    ld hl,TilesFont
    ld de,$5800
    call LoadTiles4BitRLE
    ld hl,TilesExtraFont
    ld de,$7E00
    call LoadTiles4BitRLE
    ld a,$39
    call HaveItem
    jr nz,+
    ld a,$FF
    ld (DungeonPaletteIndex),a
+:  call _LABEL_114F_
    xor a
    ld (VScroll),a
    ld (HScroll),a
    ld (_RAM_C2D5_),a
    ld (SceneAnimEnabled),a
    ld (TextBox20x6Open),a
    ld de,$8006
    di
      rst SetVDPRegisterDToE
    ei
    call ClearSpriteTableAndFadeInWholePalette
    ld b,$01
    call _LABEL_6C06_
    ld a,(DungeonPaletteIndex)
    or a
    ret nz
    ld hl,textTooDarkToMove
    call TextBox20x6
    call Close20x6TextBox
    call _LABEL_1D3D_
    ld a,(DungeonPaletteIndex)
    or a
    jr z,+
    ld a,$FF
    ld (DungeonPaletteIndex),a
    call LoadDungeonData
    jp FadeInWholePalette

+:  ld hl,FunctionLookupIndex
    ld (hl),$08
    ret

_LABEL_114F_:
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$00FF
    ld (hl),$00
    ldir
    ld a,$D0
    ld (SpriteTable),a
    call LoadDungeonMap
    xor a
    ld (SceneType),a
    jp DungeonScriptItem

_LABEL_116B_:
    ld a,(EnemyNumber)
    cp Enemy_LaShiec
    ld c,MusicLassic
    jr z,+
    cp Enemy_DarkForce
    jr z,++
    ld c,MusicBattle
+:  ld a,c
    ld (NewMusic),a
++: ld hl,_RAM_C2AB_
    ld b,$0C
-:  ld a,b
    dec a
    ld (hl),a
    dec hl
    djnz -
    xor a
    ld (_RAM_C2EF_MagicWallActiveAndCounter),a
    call ShowEnemyData
    ld b,$04
-:  ld a,b
    dec a
    call PointHLToCharacterInA
    jp nz,_LABEL_119F_
    djnz -
    jp _LABEL_17B2_

_LABEL_119F_:
    ld b,$04
-:  ld a,b
    dec a
    call PointHLToCharacterInA
    inc hl
    ld a,(hl)
    or a
    jp nz,+
    djnz -
    jp _LABEL_17B2_

+:  ld hl,_RAM_C2AC_
    ld de,_RAM_C2AC_ + 1
    ld bc,$000F
    ld (hl),$00
    ldir
    ld a,$FF
    ld (_RAM_C29D_InBattle),a
    xor a
    ld (_RAM_C267_BattleCurrentPlayer),a
    ld (_RAM_C2D4_),a
    call ShowCombatMenu
    call _LABEL_3041_UpdatePartyStats
_LABEL_11D0_:
    call PointHLToBattleCurrentPlayer
    jp z,_LABEL_11DC_
    inc hl
    ld a,(hl)
    or a
    jp nz,+
_LABEL_11DC_:
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
    jp ++

+:  ld de,$000C
    add hl,de
    ld a,(hl)
    or a
    jr nz,_LABEL_11DC_
    call _LABEL_326D_UpdateEnemyHP
    call RefreshCombatMenu
    call _LABEL_3014_
    ld hl,$7882
    ld (CursorTileMapAddress),hl
    ld a,$04
    ld (CursorMax),a
    call WaitForMenuSelection
    bit 4,c
    jp nz,_LABEL_127D_
    ld hl,_DATA_1A6E_
    call FunctionLookup
    call _LABEL_3035_
++:  ld a,(_RAM_C267_BattleCurrentPlayer)
    cp $04
    jp c,_LABEL_11D0_
    cp $05
    jp nc,_LABEL_179A_
    xor a
    ld (_RAM_C267_BattleCurrentPlayer),a
    call _LABEL_321F_HidePartyStats
    call CloseMenu
    call _LABEL_1A4E_
    ld hl,_RAM_C2A0_
    ld b,$0C
_LABEL_1232_:
    push bc
    push hl
      ld a,(hl)
      cp $04
      jp nc,+
      call _LABEL_12A4_
      jp ++

+:    call _LABEL_13E8_
++:   ld hl,CharacterStatsEnemies.1.HP
      ld de,_sizeof_Character
      ld b,8
-:    ld a,(hl)
      or a
      jp nz,+
      add hl,de
      djnz -
    pop hl
    pop bc
    jp _LABEL_17B2_ ; Enemies are all dead

+:    ld hl,CharacterStatsAlis.IsAlive
      ld de,_sizeof_Character
      ld b,4
-:    ld a,(hl)
      or a
      jp nz,+
      add hl,de
      djnz -
    pop hl
    pop bc
    jp _LABEL_175E_ ; Party is all dead

+:  pop hl
    pop bc
    inc hl
    ld a,(_RAM_C267_BattleCurrentPlayer)
    cp $05
    jp z,_LABEL_179A_
    djnz _LABEL_1232_
    jp _LABEL_119F_

_LABEL_127D_:
    call _LABEL_3035_
-:  ld a,(_RAM_C267_BattleCurrentPlayer)
    or a
    jr z,+
    dec a
+:  ld (_RAM_C267_BattleCurrentPlayer),a
    jp z,_LABEL_11D0_
    call PointHLToBattleCurrentPlayer
    jp z,-
    inc hl
    ld a,(hl)
    or a
    jp z,-
    ld de,$000C
    add hl,de
    ld a,(hl)
    or a
    jr nz,-
    jp _LABEL_11D0_

_LABEL_12A4_:
    ld (_RAM_C267_BattleCurrentPlayer),a
    call PointHLToBattleCurrentPlayer
    ret z
    ld a,(_RAM_C2D4_)
    or a
    ret nz
    push hl
    pop iy
    ld a,(iy+1)
    or a
    ret z
    ld a,(iy+13)
    or a
    jr z,++
    ld a,(_RAM_C267_BattleCurrentPlayer)
    ld (TextCharacterNumber),a
    call GetRandomNumber
    and $01
    inc a
    ld b,a
    ld a,(iy+13)
    sub b
    jr nc,+
    xor a
+:  ld (iy+13),a
    or a
    ld hl,textPlayerRemovedBindings
    jr z,+
    ld hl,textPlayerCantMove
+:  call TextBox20x6
    jp Close20x6TextBox

++: call _LABEL_3014_
    call _LABEL_1D2A_ ; Look up data from _RAM_C2AC_
    cp $01
    jp nz,_LABEL_1338_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    ld (TextCharacterNumber),a
    add a,a
    add a,a
    add a,a
    add a,a
    ld hl,CharacterStatsAlis.Weapon
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
    cp Item_Weapon_NeedleGun
    jr z,+
    cp Item_Weapon_HeatGun
    jr z,++
    cp Item_Weapon_LaserGun
    jr z,+++
    call _LABEL_1A05_
-:  call GetRandomNumber
    and $07
    add a,$04
    call PointHLToCharacterInA
    jp z,-
    push hl
    pop ix
    call _LABEL_1379_
    jp _LABEL_1367_

+:  ld d,$FB
    jr ++++

++: ld d,$F6
    jr ++++

+++:ld d,$EC
++++:
    ld e,a
    call _LABEL_204A_
    jp _LABEL_1367_

_LABEL_1338_:
    cp $03
    jp nz,+
    ld a,c
    ld (TextCharacterNumber),a
    ld a,b
    and $1F
    ld hl,_DATA_1BE6_
    call FunctionLookup
    jp _LABEL_1367_

+:  cp $04
    jp nz,_LABEL_1367_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    ld (TextCharacterNumber),a
    ld a,b
    ld (ItemTableIndex),a
    call HaveItem
    jr nz,+
    ld (_RAM_C29B_),hl
    call UseItem
_LABEL_1367_:
    call _LABEL_326D_UpdateEnemyHP
    call _LABEL_3035_
    ret

+:  ld hl,textItemUsedUp
    call TextBox20x6
    call Close20x6TextBox
    jr _LABEL_1367_

_LABEL_1379_:
    ld a,(iy+8)
    bit 7,(iy+0)
    jr z,+
    ld c,a
    rrca
    and $7F
    add a,c
    jr nc,+
    ld a,$FF
+:  call RandomReduce
    ld c,a
    ld a,(ix+9)
    call RandomReduce
    sub c
    jr c,_LABEL_13BA_
    cp $10
    jr c,_LABEL_13AD_
    rrca
    jr c,_LABEL_13AD_
    ld a,SFX_bb
    ld (NewMusic),a
    ld hl,textMonsterDodgesPlayersAttack
    call TextBox20x6
    jp Close20x6TextBox

_LABEL_13AD_:
    call GetRandomNumber
    and $1F
    cp (iy+5)
    jr z,+
    jr nc,_LABEL_13AD_
+:  cpl
_LABEL_13BA_:
    push af
      ld a,SFX_ad
      ld (NewMusic),a
      call _LABEL_7E4F_
    pop af
    add a,(ix+1)
    jr c,+
    xor a
+:  ld (ix+1),a
    ret nz
    ld (ix+0),a
    ld (ix+13),a
    ret

RandomReduce:
; Multiplies a by a random value between 0.75 and 1
    rrca
    and $7F
    ld b,a ; b = a/2
    rrca
    and $3F
    ld e,a ; e = a/4
    call GetRandomNumber
    ld h,a
    call Multiply8 ; hl = rnd() * e
    ld a,e ; Compute a/4
    add a,b ; + a/2
    add a,h ; + (rnd()  * a/4
    ret

_LABEL_13E8_:
    call PointHLToCharacterInA
    ret z
    push hl
    pop iy
    ld a,(iy+13)
    or a
    jr z,++
    call GetRandomNumber
    and $01
    inc a
    ld b,a
    ld a,(iy+13)
    sub b
    jr nc,+
    xor a
+:  ld (iy+13),a
    or a
    ld hl,textMonsterRemovedBindings
    jr z,+
    ld hl,textMonsterCantMove
+:  call TextBox20x6
    jp Close20x6TextBox

++: ld a,(_RAM_C2E8_EnemyMagicType)
    and $07
    ld hl,EnemyAttackFunctions
    jp FunctionLookup

; Jump Table from 1420 to 142F (8 entries,indexed by _RAM_C2E8_EnemyMagicType)
EnemyAttackFunctions:
.dw _LABEL_1461_RegularEnemyAttack _LABEL_14E2_EnemyMagic_Bind _LABEL_1528_EnemyMagic_Heal80 _LABEL_155B_EnemyMagic_PowerUp _LABEL_157D_EnemyMagicAttack _LABEL_15F9_EnemyMagic_AttackAll40 _LABEL_1676_MedusaAttack _LABEL_16BD_Attack_DamoasCrystal

MaybeRemoveMagicWall:
    ld a,(_RAM_C2E8_EnemyMagicType)
    and MAGIC_WALL_BREAKER
    jr z,++
    ; Subtract rand(0..3) from its counter
    call GetRandomNumber
    and $03
    ld c,a
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    ld b,a
    and $7F
    sub c
    jr nc,+
    xor a
+:  or a
    jr z,++
    bit 7,b
    jr z,+
    or $80
+:  ld (_RAM_C2EF_MagicWallActiveAndCounter),a
    ret

++: xor a
    ld (_RAM_C2EF_MagicWallActiveAndCounter),a
    ld hl,textMagicWallEnd
    call TextBox20x6
    jp Close20x6TextBox

; 1st entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_1461_RegularEnemyAttack:
    ; Regular enemy attack - wears down a magic wall
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    or a
    call nz,MaybeRemoveMagicWall
-:  ; Pick a player at random
    call GetRandomNumber
    and $03
    call PointHLToCharacterInA
    jp z,-
    ld (TextCharacterNumber),a
    push hl
    pop ix
    push af
      ld (_RAM_C2EE_PlayerBeingAttacked),a
      call _LABEL_30FB_ShowCharacterStatsBox
      call EnemyAttacksPlayer
      ld a,(_RAM_C2ED_PlayerWasHurt)
      or a
      push af
        call _LABEL_1A2A_
      pop af
      jr nz,++
      ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
      or a
      ld hl,textMagicWallDeflectsMonstersAttack
      jr nz,+
      ld hl,textPlayerDodgesMonstersAttack
+:    call TextBox20x6
      call Close20x6TextBox
++: pop af
    call PointHLToCharacterInA
    jr nz,++
    ; PLayer is now dead
    ld hl,textPlayerDied
    call TextBox20x6
    ; Check for Gold Drake killing Myau in flight
    ld a,(EnemyNumber)
    cp Enemy_GoldDrake
    jr nz,+
    ld a,(TextCharacterNumber)
    cp Player_Myau
    jr nz,+
    ; Check if anyone else is alive
    ld hl,CharacterStats
    ld de,_sizeof_Character
    xor a
    ld b,$04
-:  or (hl)
    ld (hl),$00
    add hl,de
    djnz -
    or a
    jr z,+
    ; Yes: then show text for that
    ld hl,textMyauDiesWhileFlying
    call TextBox20x6
    ; Else show nothing, we will go to the game over text later
+:  call Close20x6TextBox
++: ld b,$04
-:  ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    djnz -
    call _LABEL_321F_HidePartyStats
    ret

; 2nd entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_14E2_EnemyMagic_Bind:
    ; 3/4 chance of a regular attack
    ; 1/4 chance of casting a bind spell:
    ; - will wear down a magic wall if present
    ; - else "ties up" a player
    call GetRandomNumber
    and $03
    jp nz,_LABEL_1461_RegularEnemyAttack  ; 75% chance
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    call nz,MaybeRemoveMagicWall
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    jr z,+
    ; Magic wall still active
    ld hl,textMagicWallDeflectsMonstersMagic
    call TextBox20x6
    jp Close20x6TextBox

+:  ; No magic wall
    ; Pick a random player
-:  call GetRandomNumber
    and $03
    call PointHLToCharacterInA
    jr z,-
    ld (TextCharacterNumber),a
    ; hl += $0d -> Unknown1
    ld a,Character.Unknown1
    add a,l
    ld l,a
    ld a,(hl)
    or a
    jp nz,_LABEL_1461_RegularEnemyAttack
    ld (hl),$03
    ld a,SFX_a1
    ld (NewMusic),a
    ld hl,textPlayerTiedUp
    call TextBox20x6
    jp Close20x6TextBox

; 3rd entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_1528_EnemyMagic_Heal80:
    ; If enemy HP is below 30, always heal.
    ; Else 7/8 chance of a regular attack,
    ; 1/8 chance of healing by up to 80 HP
    ld a,(iy+Character.HP)
    cp 30
    jr c,+
    call GetRandomNumber
    and $07
    jp nz,_LABEL_1461_RegularEnemyAttack ; 7/8 chance
+:  ld b,(iy+Character.MaxHP)
    ld a,(iy+Character.HP)
    add a,$50 ; Add 80 HP
    jr nc,+
    ld a,$FF
+:  cp b
    jr c,+
    ld a,b
+:  ld (iy+Character.HP),a
    ld a,SFX_a1
    ld (NewMusic),a
    call _LABEL_326D_UpdateEnemyHP
    ld hl,textMonsterHealed
    call TextBox20x6
    jp Close20x6TextBox

; 4th entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_155B_EnemyMagic_PowerUp:
    ; 15/16 chance of a regular attack
    ; 1/16 chance of enemy strength boost
    call GetRandomNumber
    and $0F
    jp nz,_LABEL_1461_RegularEnemyAttack ; 15/16 chance
    ld a,(iy+Character.IsAlive)
    and $80 ; Check if already powered up
    jp nz,_LABEL_1461_RegularEnemyAttack
    ; Yes
    set 7,(iy+Character.IsAlive)
    ld a,SFX_a1
    ld (NewMusic),a
    ld hl,textMonsterStrengthBoost
    call TextBox20x6
    jp Close20x6TextBox

; 5th entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_157D_EnemyMagicAttack:
    ; 3/4 chance of a regular attack
    ; 1/4 chance to damage between 7 and 10 HP to two random players
    call GetRandomNumber
    and $03
    jp nz,_LABEL_1461_RegularEnemyAttack ; 3/4 chance
    ; Do all this twice
    call +
+:  ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    call nz,MaybeRemoveMagicWall
    ; Not sure why it is iterating from 0-3 this way?
    ld b,$04
-:  ld a,b
    sub $04
    neg
    call PointHLToCharacterInA
    jr nz,+ ; Do damage if anyone is alive. Maybe the first attack killed the last player?
    djnz -
    ret

+:  ; Pick a random player
-:  call GetRandomNumber
    and 3
    call PointHLToCharacterInA
    jp z,-
    ld (TextCharacterNumber),a
    ld (_RAM_C2EE_PlayerBeingAttacked),a
    call _LABEL_30FB_ShowCharacterStatsBox
    ;
    call GetRandomNumber
    and $03
    add a,-10 ; -> random damage between -10 and -7
    ld b,a
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    ld a,b
    call z,_LABEL_171E_ReducePlayerHP
    ; Magic wall is active
    ld a,$80
    ld (_RAM_C88A_),a
    call _LABEL_1A2A_
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    jr z,+
    ld hl,textMagicWallDeflectsMonstersMagic
    call TextBox20x6
    call Close20x6TextBox
+:  ld a,(TextCharacterNumber)
    call PointHLToCharacterInA
    jr nz,+
    ld hl,textPlayerDied
    call TextBox20x6
    call Close20x6TextBox
+:  ld b,$04
-:  ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    djnz -
    jp _LABEL_321F_HidePartyStats

; 6th entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_15F9_EnemyMagic_AttackAll40:
    ; 3/4 chance of a regular attack
    ; 1/4 chance of -40 attack on all players
    call GetRandomNumber
    and $03
    jp nz,_LABEL_1461_RegularEnemyAttack
    ld c,-40 ; $D8
MagicAttackDamageC:
    ; Loop over players
    ld b,$04
--: push bc
      ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
      and $80
      call nz,MaybeRemoveMagicWall
    pop bc
    push bc
      ld a,b
      sub $04
      neg
      call PointHLToCharacterInA
      jr z,+++ ; Skip dead players
      ld (TextCharacterNumber),a
      ld (_RAM_C2EE_PlayerBeingAttacked),a
      push bc
        call _LABEL_30FB_ShowCharacterStatsBox
      pop bc

      ; Perform attack using c as the parameter
      call ++

      ld a,$C0
      ld (_RAM_C88A_),a
      call _LABEL_1A2A_
      ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
      and $80
      jr z,+
      ld hl,textMagicWallDeflectsMonstersMagic
      call TextBox20x6
      call Close20x6TextBox
+:    ld a,(TextCharacterNumber)
      call PointHLToCharacterInA
      jr nz,+
      ld hl,textPlayerDied
      call TextBox20x6
      call Close20x6TextBox
+:    ld b,$04
-:    ld a,$08
      call ExecuteFunctionIndexAInNextVBlank
      djnz -
      call _LABEL_321F_HidePartyStats
+++:
    pop bc
    djnz --
    ret

++: ; If c is -1, that's the damage
    ld a,c
    cp $FF
    jp z,EnemyAttacksPlayer_NoMagicWallCheck
    ; Else if there's a magic wall, do nothing
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    ret nz
    ; Else apply 0..15 damage
    call GetRandomNumber
    and $0F
    add a,c
    jp _LABEL_171E_ReducePlayerHP

; 7th entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_1676_MedusaAttack:
    ; Regular attack if Odin has the Shield of Perseus equipped.
    ; Else turn a random player to stone.
    ld a,(CharacterStatsOdin)
    or a
    jr z,+
    ld a,(CharacterStatsOdin.Shield)
    cp Item_Shield_ShieldOfPerseus
    jp z,_LABEL_1461_RegularEnemyAttack
    ; If so, normal attack
+:  ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    or a
    call nz,MaybeRemoveMagicWall
-:  call GetRandomNumber
    and $03
    call PointHLToCharacterInA
    jp z,-
    ld (TextCharacterNumber),a
    ld (_RAM_C2EE_PlayerBeingAttacked),a
    push hl
      call _LABEL_30FB_ShowCharacterStatsBox
    pop hl
    xor a
    ld (hl),a
    inc hl
    ld (hl),a
    call _LABEL_1A2A_
    ld hl,textPlayerTurnedToStone
    call TextBox20x6
    call Close20x6TextBox
    ld b,$04
-:  ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    djnz -
    jp _LABEL_321F_HidePartyStats

; 8th entry of Jump Table from 1420 (indexed by _RAM_C2E8_EnemyMagicType)
_LABEL_16BD_Attack_DamoasCrystal:
    ; +1 HP if you have Damoa's Crystal?
    ld a,Item_DamoasCrystal
    ld (ItemTableIndex),a
    call HaveItem
    ld c,1
    jp nz,MagicAttackDamageC ; Have it -> +1 HP ?
    ld c,-1
    jp MagicAttackDamageC ; -1 signals a random damage

EnemyAttacksPlayer:
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    or a
    jr nz,++
EnemyAttacksPlayer_NoMagicWallCheck:
    ld a,(iy+Character.Attack) ; Enemy attack points?
    bit 7,(iy+Character.IsAlive) ; Check for powered up bit
    jr z,+
    ld c,a ; Attack *= 1.5 if powered up
    rrca
    and $7F
    add a,c
    jr nc,+
    ld a,$FF
+:  bit 6,(iy+Character.IsAlive) ; Bit 6 = powered down
    jr z,+
    ld c,a ; Attack *= 0.75 if set
    rrca
    rrca
    and $3F
    ld b,a
    ld a,c
    sub b
+:  call RandomReduce
    ld c,a
    ld a,(ix+Character.Defence)
    call RandomReduce
    sub c ; Calculate modified(defence) - modified(attack)
    ; If negative, apply that as damage:
    jr c,_LABEL_171E_ReducePlayerHP
    ; If <16:
    cp 16
    jr c,_LABEL_170E_RandomDamage
    ; Else if low bit is 1, do random damage
    rrca
    jr c,_LABEL_170E_RandomDamage
++: ; else do no damage
    xor a
    ld (_RAM_C2ED_PlayerWasHurt),a
    ret

_LABEL_170E_RandomDamage:
    ; Get a random number between 0 and character's LV
-:  call GetRandomNumber
    and $1F
    cp (ix+Character.LV)
    jr z,+
    jr nc,-
+:  rrca ; Divide by 2
    and $7F
    cpl ; And invert
    ; This makes -(rnd() * LV + 1)

    ; And fall through
_LABEL_171E_ReducePlayerHP:
    ; Applies a (a negative number) to player's HP
    add a,(ix+Character.HP)
    jr c,+
    xor a
+:  ld (ix+Character.HP),a
    jr nz,+
    ld (ix+Character.IsAlive),a
    ld (ix+Character.Unknown1),a
+:  ld a,$FF
    ld (_RAM_C2ED_PlayerWasHurt),a
    ret

_LABEL_1735_:
    call HideEnemyData
_LABEL_1738_:
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$00FF
    ld (hl),$00
    ldir
    call SpriteHandler
    ld a,(SceneType)
    or a
    jp nz,+
    call _LABEL_6DDD_
    jp ++

+:  call _LABEL_3E5A_
++: ld a,$10
    call ExecuteFunctionIndexAInNextVBlank
    ret

_LABEL_175E_:
    ld a,(EnemyNumber)
    cp Enemy_Tajim
    jr z,+
    cp Enemy_Nightmare
    jr nz,++
+:  ld a,SFX_d8
    ld (NewMusic),a
    ret

++: cp Enemy_GoldDrake
    jr nz,+
    ld hl,ActualPalette+16
    ld b,16
-:  ld (hl),$30
    inc hl
    djnz -
+:  ld a,MusicGameOver
    ld (NewMusic),a
    ld a,(PartySize)
    or a
    ld hl,textAllDead
    call nz,TextBox20x6
    ld hl,textGameOver
    call TextBox20x6
    ld hl,FunctionLookupIndex
    ld (hl),$02
    jp Close20x6TextBox

_LABEL_179A_:
    push af
      call _LABEL_1735_
      call CharacterStatsUpdate
      ld a,SFX_d8
      ld (NewMusic),a
    pop af
    cp $05
    ret nz
    ld a,(SceneType)
    or a
    ret nz
    jp _LABEL_6B2F_

_LABEL_17B2_:
    ld a,(EnemyNumber)
    cp Enemy_Tajim
    jr nz,+
    ld a,SFX)d8
    ld (NewMusic),a
    ret

+:  cp Enemy_GoldDrake
    jr nz,+
    ld hl,ActualPalette+16
    ld b,$10
-:  ld (hl),$30
    inc hl
    djnz -
+:  ld a,SFX_af
    ld (NewMusic),a
    call _LABEL_1735_
    ld a,(EnemyNumber)
    cp Enemy_LaShiec
    jr z,+
    cp Enemy_DarkForce
    jr nz,++
+:  ld b,$B4
    call PauseBFrames
++: ld a,SFX_d8
    ld (NewMusic),a
    ld hl,textMonsterKilled
    call TextBox20x6
    call _LABEL_1869_
    call CharacterStatsUpdate
    ld hl,(EnemyMoney)
    ld a,(DungeonObjectItemIndex)
    or l
    or h
    ret z
    ld hl,textMonsterHadATreasureChest
    call TextBox20x6
    call ShowTreasureChest
    call MenuWaitForButton
    jp _LABEL_2A37_

ShowTreasureChest:
    ld hl,Frame2Paging
    ld (hl),:Palette_TreasureChest
    ld hl,Palette_TreasureChest
    ld de,TargetPalette+16+8
    ld bc,_sizeof_Palette_TreasureChest
    ldir
    ld hl,TargetPalette
    ld de,ActualPalette
    ld bc,32
    ldir
    ld hl,TilesTreasureChest
    ld de,$6000
    call LoadTiles4BitRLE
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$00FF
    ld (hl),$00
    ldir
    ld a,$0D
    ld (CharacterSpriteAttributes),a
    call SpriteHandler
    ld a,$16
    call ExecuteFunctionIndexAInNextVBlank
    ret
.orga $184d
.section "Initialise character stats in iy" overwrite
InitialiseCharacterStats:
    ld (iy+0),$01      ; alive
    ld (iy+5),$01      ; LV
    push iy
      call CharacterStatsUpdate
    pop iy
    ld a,(iy+6)        ; copy Max HP and Max MP to HP and MP
    ld (iy+1),a
    ld a,(iy+7)
    ld (iy+2),a
    ret
.ends
.orga $1869

_LABEL_1869_:
    ld hl,(EnemyExperienceValue)
    ld (NumberToShowInText),hl
    ld a,l
    or h
    ret z
    ld hl,textGainedExperience
    call TextBox20x6
    ld iy,CharacterStatsAlis
    ld de,$B8AF
    xor a
    ld (TextCharacterNumber),a
    call +
    ld iy,CharacterStatsMyau
    ld de,LevelStatsMyau
    ld a,$01
    ld (TextCharacterNumber),a
    call +
    ld iy,CharacterStatsOdin
    ld de,LevelStatsOdin
    ld a,$02
    ld (TextCharacterNumber),a
    call +
    ld iy,CharacterStatsLutz
    ld de,LevelStatsLutz
    ld a,$03
    ld (TextCharacterNumber),a
+:  bit 0,(iy+Character.IsAlive)
    ret z
    ld hl,Frame2Paging
    ld (hl),$03
    ld l,(iy+Character.LV)
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,de
    push hl
    pop ix
    ld e,(iy+Character.EP)
    ld d,(iy+Character.EP+1)
    ld hl,(EnemyExperienceValue)
    add hl,de
    jr nc,+
    ld hl,-1
+:  ld (iy+Character.EP),l
    ld (iy+Character.EP+1),h
    ret c
    ld a,(iy+Character.LV)
    cp $1E
    ret z
    ld a,h
    sub (ix+5)
    ret c
    jr nz,+
    ld a,l
    sub (ix+4)
    ret c
+:  ld a,SFX_ba
    ld (NewMusic),a
    ld hl,_DATA_AFB9_
    call TextBox20x6
    ld hl,Frame2Paging
    ld (hl),$03
    inc (iy+Character.LV)
    ld a,(ix+6)
    cp (iy+Character.MagicCount)
    jr nz,+
    ld a,(ix+7)
    cp (iy+Character.BattleMagicCount)
    ret z
+:  ld hl,textPlayerLearnedASpell
    jp TextBox20x6

.orga $1916
.section "Characters item/level stats update" overwrite
CharacterStatsUpdate:
    ld hl,Frame2Paging
    ld (hl),:LevelStats

    ld iy,CharacterStatsAlis
    ld de,LevelStatsAlis-8
    call +

    ld iy,CharacterStatsMyau
    ld de,LevelStatsMyau-8 ; -8 because other characters start at level 1
    call +

    ld iy,CharacterStatsOdin
    ld de,LevelStatsOdin-8
    call +

    ld iy,CharacterStatsLutz
    ld de,LevelStatsLutz-8
    ; fall through

+:  bit 0,(iy+CharacterStats.IsAlive)
    ret z
    ld (iy+CharacterStats.IsAlive),$01
    ld (iy+CharacterStats.Unknown1),$00
    ld l,(iy+CharacterStats.LV)
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,de
    push hl
    pop ix             ; ix = de + LV*8

    ld a,(ix+0)
    ld (iy+6),a        ; Max HP

    ld l,(iy+10)
    ld h,$00
    ld de,_ItemStrengths
    add hl,de
    ld a,(hl)
    add a,(ix+1)
    ld (iy+8),a        ; Attack = (_ItemStrengths + Weapon) + level bonus

    ld l,(iy+11)
    ld h,$00
    add hl,de
    ld a,(hl)
    ld l,(iy+12)
    ld h,$00
    add hl,de
    add a,(hl)
    add a,(ix+2)
    ld (iy+9),a        ; Defence = (_ItemStrengths + Armour) + (_ItemStrengths + Shield) + level bonus

    ld a,(ix+3)
    ld (iy+7),a        ; Max MP

    ld a,(ix+6)
    ld (iy+14),a       ; Number of magics known

    ld a,(ix+7)
    ld (iy+15),a       ; ??? = ix+7
    ret

_ItemStrengths:
.db  0,3,4,12,10,10,10,21,31,18,30,30,46,50,60,80 ; weapons
.db  5,5,15,20,30,30,60,80,40                      ; armour - splits not certain ???
.db  3,8,15,23,40,30,40,50                         ; shields
.dsb 31,0                                          ; 31 0s at the end -> 64 bytes total ##############
.ends
.orga $19d6

PointHLToBattleCurrentPlayer:
    ld a,(_RAM_C267_BattleCurrentPlayer)
PointHLToCharacterInA:
    push af
      add a,a
      add a,a
      add a,a
      add a,a
      ld hl,CharacterStatsAlis
      add a,l
      ld l,a
      adc a,h
      sub l
      ld h,a
    pop af
    bit 0,(hl)
    ret

ShowMessageIfDead:
    push hl
      call PointHLToCharacterInA
    pop hl
    ret nz
    push af
    push bc
    push de
    push hl
      ld (TextCharacterNumber),a
      ld hl,textPlayerAlreadyDead
      call TextBox20x6
      call Close20x6TextBox
    pop hl
    pop de
    pop bc
    pop af
    ret

_LABEL_1A05_:
    push iy
      ld (_RAM_C80A_),a
      ld a,$0B
      ld (CharacterSpriteAttributes),a
      call _LABEL_1A15_
    pop iy
    ret

_LABEL_1A15_:
    ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    call SpriteHandler
    ld a,(CharacterSpriteAttributes)
    or a
    jp nz,_LABEL_1A15_
    ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    ret

_LABEL_1A2A_:
    push iy
      ld a,$FF
      ld (_RAM_C29F_),a
      ld a,(_RAM_C2F1_)
      ld (NewMusic),a
-:    ld a,$08
      call ExecuteFunctionIndexAInNextVBlank
      call SpriteHandler
      ld a,(_RAM_C29F_)
      or a
      jp nz,-
      ld a,$08
      call ExecuteFunctionIndexAInNextVBlank
    pop iy
    ret

_LABEL_1A4E_:
    ld hl,_RAM_C2A0_
    ld b,$0C
-:  call GetRandomNumber
    and $0F
    cp $0C
    jr nc,-
    add a,$A0
    ld e,a
    ld a,$C2
    adc a,$00
    ld d,a
    ld c,(hl)
    ld a,(de)
    ex de,hl
    ld (hl),c
    ld (de),a
    ex de,hl
    inc hl
    djnz -
    ret

; Jump Table from 1A6E to 1A77 (5 entries,indexed by CursorPos)
_DATA_1A6E_:
.dw BattleMenu_Fight BattleMenu_Magic BattleMenu_Item BattleMenu_Talk BattleMenu_RunAway

; 1st entry of Jump Table from 1A6E (indexed by CursorPos)
BattleMenu_Fight:
    ld bc,$0001
    xor a
    call _LABEL_1D15_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
    ret

; 4th entry of Jump Table from 1A6E (indexed by CursorPos)
BattleMenu_Talk:
    call _LABEL_3035_
    call _LABEL_321F_HidePartyStats
    call CloseMenu
    ld a,(_RAM_C267_BattleCurrentPlayer)
    ld (TextCharacterNumber),a
    ld hl,textPlayerSpeaks
    call TextBox20x6
    ld a,(_RAM_C2E8_EnemyMagicType)
    and TALK_NORMAL
    jr z,MonsterDoesNotUnderstand
    ld a,(CharacterStatsEnemies.1.Attack)
    ld b,a
    ld a,(CharacterStatsAlis.Attack)
    cp b
    jr nc,MonsterTalk
    ; else fall through

MonsterDoesNotUnderstand:
    ld a,4 ; End of battle sequence
    ld (_RAM_C267_BattleCurrentPlayer),a
    ld a,$FF
    ld (_RAM_C2D4_),a
    ld hl,textMonsterDoesntUnderstand
    call TextBox20x6
    jp Close20x6TextBox

MonsterTalk:
    ld hl,textMonsterAnswers
    call TextBox20x6
    ; Pick a random entry
-:  call GetRandomNumber
    and $0F
    cp $09
    jr nc,-
    ld l,a
    ld h,$00
    add hl,hl
    ld de,_MonsterDialogue
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    call TextBox20x6
    ld a,$06
    ld (_RAM_C267_BattleCurrentPlayer),a
    jp Close20x6TextBox

; Pointer Table from 1AE6 to 1AF7 (9 entries,indexed by random number)
_MonsterDialogue:
.dw textMonster1 textMonster2 textMonster3 textMonster4 textMonster5 textMonster6 textMonster7 textMonster8 textMonster9

; 5th entry of Jump Table from 1A6E (indexed by CursorPos)
BattleMenu_RunAway:
    call _LABEL_3035_
    call _LABEL_321F_HidePartyStats
    call CloseMenu
    ld a,(RetreatProbability)
    ld b,a
    call GetRandomNumber
    cp b
    jr nc,++
    ld a,(SceneType)
    or a
    jr nz,+
    call _LABEL_6B1D_
    jr nz,++
+:  ld a,SFX_bc
    ld (NewMusic),a
    ld a,$05
    ld (_RAM_C267_BattleCurrentPlayer),a
    ret

++: ld a,(_RAM_C267_BattleCurrentPlayer)
    ld (TextCharacterNumber),a
    ld hl,textMonsterBlocksRetreat
    call TextBox20x6
    ld a,$04
    ld (_RAM_C267_BattleCurrentPlayer),a
    ld a,$FF
    ld (_RAM_C2D4_),a
    jp Close20x6TextBox

; 2nd entry of Jump Table from 1A6E (indexed by CursorPos)
BattleMenu_Magic:
    ld a,(_RAM_C267_BattleCurrentPlayer)
    ld (TextCharacterNumber),a
    cp Player_Tylon
    jp nz,+
    ld hl,textTaironCantUseMagic
    call TextBox20x6
    jp Close20x6TextBox

+:  ld c,a
    add a,a ; x16
    add a,a
    add a,a
    add a,a
    ld hl,CharacterStatsAlis.MagicCount
    add a,l
    ld l,a
    ld a,(hl) ; Get player magic count
    or a
    jp z,_noMagicYet
    ld b,a
    ld a,c
    cp $03
    jr nz,+
    dec a
+:  push af
      push hl
        call _LABEL_3592_
        ld hl,$7A8C
        ld (CursorTileMapAddress),hl
      pop hl
      ld a,(hl)
      dec a
      ld (CursorMax),a
      call WaitForMenuSelection
    pop hl
    bit 4,c
    jp nz,+
    ld l,a
    ld a,h
    add a,a
    add a,a
    add a,h
    add a,l
    ld l,a
    ld h,$00
    ld de,_DATA_1BB3_BattleMagicIndices
    add hl,de
    ld a,(hl)
    and $1F
    ld b,a
    call CheckIfEnoughMP
    jr c,++
    ld a,b
    ld hl,_DATA_1BC2_
    call FunctionLookup
+:  jp _LABEL_35E3_

_noMagicYet:
    ld hl,textPlayerHasNoMagicYet
    call TextBox20x6
    jp Close20x6TextBox

++: ld hl,textNotEnoughMagicPoints
    call TextBox20x6
    call Close20x6TextBox
    jp _LABEL_35E3_

; Data from 1BB3 to 1BC1 (15 bytes)
_DATA_1BB3_BattleMagicIndices:
.db $01 $09 $10 $05 $08 ; Alisa
.db $02 $0B $03 $0A $00 ; Myau
.db $05 $11 $07 $04 $06 ; Lutz

; Jump Table from 1BC2 to 1BE5 (18 entries,indexed by unknown)
_DATA_1BC2_:
.dw _LABEL_1C0A_ _LABEL_1C0D_ _LABEL_1C0D_ _LABEL_1C59_ _LABEL_1C59_ _LABEL_1C2C_ _LABEL_1C2C_ _LABEL_1C2C_
.dw _LABEL_1C2C_ _LABEL_1C59_ _LABEL_1C3A_ _LABEL_1C59_ _LABEL_1C59_ _LABEL_1C59_ _LABEL_1C59_ _LABEL_1C59_
.dw _Magic10_Transrate _Magic11_Telepathy

; Jump Table from 1BE6 to 1C09 (18 entries,indexed by _RAM_C2AD_)
_DATA_1BE6_:
.dw _InvalidMagicFunction _Magic01_Heal_Battle _Magic02_SuperHeal_Battle _Magic03_Waller _Magic04_MagicWaller _Magic05_Fire _Magic06Thunder _Magic07_Wind
.dw _Magic08_Bind _Magic09_QuickDash _Magic0a_PowerBoost _Magic0b_Terror _Magic0c_Untrap _Magic0d_Bypass _Magic0e_MagicUnseal _Magic0f_Rebirth
.dw _Magic10_Transrate _Magic11_Telepathy

; 1st entry of Jump Table from 1BC2 (indexed by unknown)
_LABEL_1C0A_:
    jp _LABEL_1C0A_

; 2nd entry of Jump Table from 1BC2 (indexed by unknown)
_LABEL_1C0D_:
    push bc
      call _LABEL_379F_ChooseCharacter
    pop de
    bit 4,c
    jr nz,+
    call ShowMessageIfDead
    jr z,+
    ld c,$03
    ld b,d
    call _LABEL_1D15_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
+:  call _LABEL_37E9_
    ret

; 6th entry of Jump Table from 1BC2 (indexed by unknown)
_LABEL_1C2C_:
    ld c,$03
    xor a
    call _LABEL_1D15_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
    ret

; 11th entry of Jump Table from 1BC2 (indexed by unknown)
_LABEL_1C3A_:
    push bc
      call _LABEL_379F_ChooseCharacter
    pop de
    bit 4,c
    jr nz,+
    call ShowMessageIfDead
    jr z,+
    ld c,$03
    ld b,d
    call _LABEL_1D15_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
+:  call _LABEL_37E9_
    ret

; 4th entry of Jump Table from 1BC2 (indexed by unknown)
_LABEL_1C59_:
    ld c,$03
    ld a,(TextCharacterNumber)
    call _LABEL_1D15_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
    ret

; 17th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic10_Transrate:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
DoTransrate:
    ld a,(_RAM_C2E8_EnemyMagicType)
    and TALK_NORMAL | TALK_MAGIC
    jp z,MonsterDoesNotUnderstand
    and TALK_MAGIC
    jp z,MonsterTalk
    ld a,(CharacterStatsEnemies.1.Attack)
    ld b,a
    ld a,(CharacterStatsAlis.Attack)
    cp b
    jr nc,+
    jp MonsterDoesNotUnderstand

; 18th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic11_Telepathy:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
DoTelepathy:
    ld a,(_RAM_C2E8_EnemyMagicType)
    and TALK_NORMAL | TALK_MAGIC
    jp z,MonsterDoesNotUnderstand
    and TALK_MAGIC
    jp z,MonsterTalk
+:  ld a,SFX_ac
    ld (NewMusic),a
    ld hl,textMonsterAnswers
    call TextBox20x6
    ; Pick a random answer
-:  call GetRandomNumber
    and $0F
    cp $0A
    jr nc,-
    ld l,a
    ld h,$00
    add hl,hl
    ld de,_MonsterDialogue2
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    call TextBox20x6
    ld a,$06
    ld (_RAM_C267_BattleCurrentPlayer),a
    ld a,SFX_d5
    ld (NewMusic),a
    jp Close20x6TextBox

; Pointer Table from 1CCF to 1CE2 (10 entries,indexed by unknown)
_MonsterDialogue2:
.dw textMonster10, textMonster11, textMonster12, textMonster13, textMonster14, textMonster15, textMonster16, textMonster17, textMonster18, textMonster19

CheckIfEnoughMP:
    ; Look up a'th entry in MagicMPCosts
    ld hl,MagicMPCosts
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ; Look up MP of the player
    ld a,(_RAM_C267_BattleCurrentPlayer)
    add a,a
    add a,a
    add a,a
    add a,a
    ld de,CharacterStatsAlis.MP
    add a,e
    ld e,a
    ld a,(de)
    ; Check if we have enough
    sub (hl)
    ret

; 3rd entry of Jump Table from 1A6E (indexed by CursorPos)
BattleMenu_Item:
    call _LABEL_35EF_SelectItemFromInventory
    call _LABEL_3773_HideInventoryWindow
    bit 4,c
    ret nz
    ld a,(ItemTableIndex)
    ld b,a
    ld c,$04
    xor a
    call _LABEL_1D15_
    ld a,(_RAM_C267_BattleCurrentPlayer)
    inc a
    ld (_RAM_C267_BattleCurrentPlayer),a
    ret

_LABEL_1D15_:
    push af
      ld a,(_RAM_C267_BattleCurrentPlayer)
      add a,a
      add a,a
      ld hl,$C2AC
      add a,l
      ld l,a
      adc a,h
      sub l
      ld h,a
    pop af
    ld (hl),c
    inc hl
    ld (hl),b
    inc hl
    ld (hl),a
    ret

_LABEL_1D2A_:
    ld a,(_RAM_C267_BattleCurrentPlayer)
    ; multiply by 4
    add a,a
    add a,a
    ; index into _RAM_C2AC_
    ld hl,_RAM_C2AC_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ; Read into a, b, c
    ld a,(hl)
    inc hl
    ld b,(hl)
    inc hl
    ld c,(hl)
    ret

_LABEL_1D3D_:
    xor a
    ld (_RAM_C29D_InBattle),a
    ld (_RAM_C2D8_),a
    call _LABEL_37FA_
    call _LABEL_3041_UpdatePartyStats
-:  ld a,(_RAM_C2D8_)
    or a
    jr nz,++
    ld hl,$7882
    ld (CursorTileMapAddress),hl
    ld a,$04
    ld (CursorMax),a
    call WaitForMenuSelection
    bit 4,c
    jp nz,+
    ld hl,_DATA_1DF3_
    call FunctionLookup
    call _LABEL_380C_
    jp -

+:  ld a,$FF
++: push af
      cp $05
      jr z,+
      xor a
      ld (CharacterSpriteAttributes),a
      ld a,$D0
      ld (SpriteTable),a
+:    call _LABEL_321F_HidePartyStats
      call _LABEL_3818_
    pop af
    cp $FF
    ret z
    cp $03
    ret c
    cp $05
    jr nc,+
    ld c,a
    jp _LABEL_6ABE_

+:  cp $06
    jr nc,+
    call _LABEL_7F28_
    call MenuWaitForButton
    jp _LABEL_467B_

+:  cp $07
    jr nc,+
    ld a,MusicFinalDungeon
    call CheckMusic
    call _LABEL_7F59_
    ld a,$FF
    ld (_RAM_C2DC_),a
    jp _LABEL_1D3D_

+:  cp $08
    jp c,_LABEL_46FE_
    ld a,SFX_bf
    ld (NewMusic),a
    ld hl,FunctionLookupIndex
    ld (hl),$08
    xor a
    ld (VehicleMovementFlags),a
    ld a,(_RAM_C317_)
    ld l,a
    add a,a
    add a,l
    ld h,$00
    ld l,a
    ld de,_DATA_1DD8_
    add hl,de
    jp _LABEL_7B1E_

; Data from 1DD8 to 1DF2 (27 bytes)
_DATA_1DD8_:
.db $04 $16 $69 $04 $27 $6B $07 $29 $2A $09 $19 $66 $0E $29 $19 $0F
.db $15 $43 $11 $53 $52 $16 $15 $2C $15 $28 $61

; Jump Table from 1DF3 to 1DFC (5 entries,indexed by CursorPos)
_DATA_1DF3_:
.dw _LABEL_1DFD_ _LABEL_1EA9_ _LABEL_22C4_ _LABEL_2995_ _LABEL_1E3B_

; 1st entry of Jump Table from 1DF3 (indexed by CursorPos)
_LABEL_1DFD_:
    call ShowCharacterSelectMenu
    bit 4,c
    jr nz,+++
    call ShowMessageIfDead
    jr z,+++
    push af
      call _LABEL_3824_
      call _LABEL_38EC_
      call MenuWaitForButton
    pop af
    ld c,a
    add a,a
    add a,a
    add a,a
    add a,a
    ld hl,CharacterStatsAlis.MagicCount
    add a,l
    ld l,a
    ld a,(hl)
    or a
    jr z,++
    ld b,a
    ld a,c
    cp $03
    jr nz,+
    dec a
+:  call _LABEL_3592_
    call MenuWaitForButton
    call _LABEL_35E3_
++:  call _LABEL_39DE_
    call _LABEL_386A_
+++:jp _LABEL_37D8_ClosePlayerSelect

; 5th entry of Jump Table from 1DF3 (indexed by CursorPos)
_LABEL_1E3B_:
    ld hl,textSaveSelectSlot
    call TextBox20x6
    call _LABEL_3ACF_
    ld hl,textSaveDeleteConfirmSlot
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_LABEL_1E97_
    ld a,(FunctionLookupIndex)
    ld (_RAM_C316_),a
    ld hl,textSavingToSlot
    call TextBox20x6
    push bc
      ld a,(NumberToShowInText)
      ld h,a
      ld l,$00
      add hl,hl
      add hl,hl
      set 7,h
      ex de,hl
      call IsSlotUsed
      push af
      push hl
        ld a,$08
        ld (SRAMPaging),a
        ld (hl),$00
        ld hl,HScroll
        ld bc,$0400
        ldir
        ld a,$80
        ld (SRAMPaging),a
      pop hl
      pop af
      ld a,$08
      ld (SRAMPaging),a
      ld (hl),$01
      ld a,$80
      ld (SRAMPaging),a
    pop bc
    jr z,+
    ld hl,textSavingComplete
    call TextBox20x6
_LABEL_1E97_:
    call _LABEL_3B07_
    jp Close20x6TextBox

+:  xor a
    ld (NameEntryMode),a
    ld hl,FunctionLookupIndex
    ld (hl),$10
    pop hl
    pop hl
    ret

; 2nd entry of Jump Table from 1DF3 (indexed by CursorPos)
_LABEL_1EA9_:
    call ShowCharacterSelectMenu
    bit 4,c
    jp nz,_LABEL_1F16_
    call ShowMessageIfDead
    jp z,_LABEL_1F16_
    cp Player_Tylon
    jp z,_LABEL_1F21_TaironNoMagic
    ld c,a
    ld (TextCharacterNumber),a
    ld (_RAM_C267_BattleCurrentPlayer),a
    ; Multiply by 16 to look up player's battle magic count
    add a,a
    add a,a
    add a,a
    add a,a
    ld hl,CharacterStatsAlis.BattleMagicCount
    add a,l
    ld l,a
    ld a,(hl) ; Player's magic count
    or a
    jp z,_noMagicYet
    ld b,a
    ld a,c ; Convert to c a magic player index (0-2)
    cp $03
    jr nz,+
    dec a
+:  ld c,a
    add a,$03 ; Add 3 to magic count to make a line count
    push bc
      push hl
        call _LABEL_3592_ ; Show magic menu
        ld hl,$7A8C
        ld (CursorTileMapAddress),hl
      pop hl
      ld a,(hl) ; Get magic count again
      dec a
      ld (CursorMax),a
      call WaitForMenuSelection
    pop hl
    bit 4,c
    jp nz,_LABEL_1F13_
    ld h,a ; Chosen magic index (0-based)
    ld a,l ; l is the value from c earlier, i.e. the "magic player index"
    add a,a
    add a,a
    add a,l ; CursorMax*5+selection?
    add a,h
    ld l,a
    ld h,$00
    ld de,_OverworldMagicIndicesByPlayer
    add hl,de
    ld a,(hl)
    and $1F
    ld b,a ; preserve magic index
    call CheckIfEnoughMP
    jp c,++
    ld a,b ; loop up magic index in MagicFunctions
    ld hl,MagicFunctions
    call FunctionLookup
_LABEL_1F13_:
    call _LABEL_35E3_
_LABEL_1F16_:
    call _LABEL_37D8_ClosePlayerSelect
    jp _LABEL_30A4_

_noMagicYet:
    ld hl,textPlayerHasNoMagicYet
    jr +

_LABEL_1F21_TaironNoMagic:
    ld hl,textTaironCantUseMagic
+:  call TextBox20x6
    call Close20x6TextBox
    jp _LABEL_37D8_ClosePlayerSelect

++:  ld hl,textNotEnoughMagicPoints
    call TextBox20x6
    call Close20x6TextBox
    jr _LABEL_1F13_

; Data from 1F38 to 1F4A (19 bytes)
MagicMPCosts: ; indexed by "magix index" (see below)
.db $00
.db $02 $06 $06 $0A $04
.db $10 $0C $04 $02 $0A
.db $02 $02 $04 $04 $0C
.db $02 $04 $08

; Data from 1F4B to 1F59 (15 bytes)
_OverworldMagicIndicesByPlayer:
.db $01 $12 $00 $00 $00 ; Alisa - Heal, Troop
.db $02 $0C $0D $00 $00 ; Myau - Super Heal, Untrap, Bypass
.db $02 $0D $11 $0E $0F ; Lutz - Super Heal, Bypass, Telepathy, Magic Unseal, Rebirth

; Jump Table from 1F5A to 1F7F (19 entries,indexed by unknown)
MagicFunctions:
.dw _InvalidMagicFunction
.dw _Magic01_Heal _Magic02_SuperHeal _Magic03_Waller _Magic04_MagicWaller _Magic05_Fire _Magic06Thunder _Magic07_Wind _Magic08_Bind
.dw _Magic09_QuickDash _Magic0a_PowerBoost _Magic0b_Terror _Magic0c_Untrap _Magic0d_Bypass _Magic0e_MagicUnseal _Magic0f_Rebirth
.dw _Magic11_Telepathy _Magic11_Telepathy _Magic12_Troop ; Note: index $10 points to _Magic_11

; 1st entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_InvalidMagicFunction:
    jp _InvalidMagicFunction ; Lock up the game, invalid index!

; 2nd entry of Jump Table from 1F5A (indexed by unknown)
_Magic01_Heal:
    ld d,$14
    jr +

; 3rd entry of Jump Table from 1F5A (indexed by unknown)
_Magic02_SuperHeal:
    ld d,$50
+:  push bc
      push de
        call _LABEL_379F_ChooseCharacter
      pop de
      bit 4,c
    pop bc
    jr nz,+
    ld (TextCharacterNumber),a
    call ShowMessageIfDead
    jr z,+
    call ++
+:  jp _LABEL_37E9_

; 2nd entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic01_Heal_Battle:
    ld d,$14
    jr +

; 3rd entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic02_SuperHeal_Battle:
    ld d,$50
+:  ld a,(TextCharacterNumber)
    call ShowMessageIfDead
    ret z
++: push de
      ld a,b
      call CheckIfEnoughMP
      ld (de),a
      ld a,SFX_ab
      ld (NewMusic),a
    pop de
_LABEL_1FBB_Heal:
    push de
      ld hl,textPlayerHealed
      call TextBox20x6
    pop de
    ld a,SFX_Heal
    ld (NewMusic),a
    ld a,(TextCharacterNumber)
    call PointHLToCharacterInA
    push hl
    pop ix
    ld b,(ix+Character.MaxHP)
    ld a,(ix+Character.HP)
    add a,d
    jr nc,+
    ld a,$FF
+:  cp b
    jr c,+
    ld a,b
+:  ld (ix+Character.HP),a
    jp Close20x6TextBox

; 4th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic03_Waller:
    ld c,$06
    jr +

; 5th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic04_MagicWaller:
    ld c,$86
+:  ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,c
    ld (_RAM_C2EF_MagicWallActiveAndCounter),a
    ld hl,textMagicWall
    call TextBox20x6
    jp Close20x6TextBox

; 6th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic05_Fire:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld de,$F610
    call _LABEL_200E_
_LABEL_200E_:
    ld b,$08
-:  ld a,b
    sub $0C
    neg
    call PointHLToCharacterInA
    jr nz,+
    djnz -
    ret

+:  push de
      ld a,e
      call _LABEL_1A05_
  -:  call GetRandomNumber
      and $07
      add a,$04
      call PointHLToCharacterInA
      jp z,-
      push hl
      pop ix
    pop de
    push de
      call GetRandomNumber
      and $03
      add a,d
      call _LABEL_13BA_
      call _LABEL_326D_UpdateEnemyHP
    pop de
    ret

; 7th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic06Thunder:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld de,$D811
_LABEL_204A_:
    ld b,$08
-:  push bc
      ld a,b
      sub $0C
      neg
      call PointHLToCharacterInA
      jp z,++
      push hl
      pop ix
      push de
        ld a,e
        call _LABEL_1A05_
      pop de
      push de
        ld a,d
        cp $D8
        jr nz,+
        call GetRandomNumber
        and $0F
        add a,d
+:      call _LABEL_13BA_
        call _LABEL_326D_UpdateEnemyHP
      pop de
      ld a,(EnemyNumber)
      cp Enemy_DarkForce
      jr z,+++
++: pop bc
    djnz -
    ret

+++:pop bc
    ret

; 8th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic07_Wind:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld de,$F412
    call _LABEL_200E_
    call _LABEL_200E_
    jp _LABEL_200E_

; 9th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic08_Bind:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,(_RAM_C2E8_EnemyMagicType)
    and BIND_PROOF
    jr z,++
    ld a,(CharacterStatsEnemies.1.Attack)
    ld b,a
    ld a,(CharacterStatsAlis.Attack)
    cp b
    ld c,$03
    jr nc,+
    call GetRandomNumber
    and $03
    jr z,++
    ld c,a
+:  ld de,$000D
    ld b,$08
-:  ld a,b
    sub $0C
    neg
    call PointHLToCharacterInA
    jr z,+
    add hl,de
    ld a,(hl)
    or a
    jr z,+++
+:  djnz -
++: ld hl,textPlayersSpellHadNoEffect
    jr ++++

+++:ld (hl),c
    ld hl,textMonsterTiedUp
++++:
    call TextBox20x6
    jp Close20x6TextBox

; 10th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic09_QuickDash:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    xor a
    ld (ItemTableIndex),a
DoQuickDash:
    ld a,(RetreatProbability)
    or a
    jr z,+
    ld a,(SceneType)
    or a
    jr nz,++
    call _LABEL_6B1D_
    jr z,++
+:  ld a,(ItemTableIndex)
    or a
    ld hl,textPlayersSpellHadNoEffect
    jr z,+
    ld hl,textNoEffect
+:  call TextBox20x6
    jp Close20x6TextBox

++: ld a,SFX_bc
    ld (NewMusic),a
    ld hl,textPartyRanAway
    call TextBox20x6
    call Close20x6TextBox
    ld a,$05
    ld (_RAM_C267_BattleCurrentPlayer),a
    ret

; 11th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic0a_PowerBoost:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,(TextCharacterNumber)
    call ShowMessageIfDead
    ret z
    call PointHLToCharacterInA
    set 7,(hl)
    ld hl,textPlayerEnergyBoost
    call TextBox20x6
    jp Close20x6TextBox

; 12th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic0b_Terror:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,(CharacterStatsEnemies.1.Attack)
    ld b,a
    ld a,(CharacterStatsAlis.Attack)
    cp b
    jr c,++
    call GetRandomNumber
    cp $B2
    jr nc,++
    ld b,$08
-:  ld a,b
    sub $0C
    neg
    call PointHLToCharacterInA
    jr z,+
    bit 6,(hl)
    jr z,+++
+:  djnz -
++: ld hl,textPlayersSpellHadNoEffect
    jr ++++

+++:set 6,(hl)
    ld hl,textMonsterRanAway
++++:
    call TextBox20x6
    jp Close20x6TextBox

; 13th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic0c_Untrap:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,(CharacterSpriteAttributes)
    cp $0E
    jr z,++
    ld a,(SceneType)
    or a
    ld hl,textNothingUnusualHere
    jr nz,+
    call _SquareInFrontOfPlayerContainsObject
    ld hl,textNothingUnusualHere
    jr z,+
    ld l,c
    ld h,>DungeonMap
    ld (hl),$00
    ld hl,textTrapDisarmed
+:  call TextBox20x6
    jp Close20x6TextBox

++: ld a,(_RAM_C80F_)
    cp $3D
    ld hl,textNoTrap
    jr z,+
    ld hl,textTrapDisarmed
+:  call TextBox20x6
    ld a,$3D
    ld (_RAM_C80F_),a
    jp _LABEL_2A4A_

; 14th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic0d_Bypass:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,(SceneType)
    or a
    jr z,_LABEL_21D4_
    ld hl,textPlayersSpellHadNoEffect
    call TextBox20x6
    jp Close20x6TextBox

_LABEL_21D4_:
    ld a,SFX_bf
    ld (NewMusic),a
    ld hl,textYouBecomeLight
    call TextBox20x6
    call Close20x6TextBox
    ld a,$FF
    ld (_RAM_C2D8_),a
    ld hl,FunctionLookupIndex
    ld (hl),$08
    ret

; 15th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic0e_MagicUnseal:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,(SceneType)
    or a
    jr z,+
-:  ld hl,textPlayersSpellHadNoEffect
    call TextBox20x6
    jp Close20x6TextBox

+:  ld b,$01
    call DungeonGetRelativeSquare
    and $07
    cp $06 ; Magically locked door
    jr nz,-
    bit 7,(hl) ; Mark as unlocked
    jr nz,-
    ld a,$04
    ld (_RAM_C2D8_),a
    ret

; 16th entry of Jump Table from 1BE6 (indexed by _RAM_C2AD_)
_Magic0f_Rebirth:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    call _LABEL_379F_ChooseCharacter
    bit 4,c
    jr nz,+++
    push af
      ld a,SFX_ab
      ld (NewMusic),a
    pop af
    ld (TextCharacterNumber),a
    call PointHLToCharacterInA
    jr z,+
    ld hl,textPlayerIsNotDead
    jr ++

+:  ld (hl),$01
    ld a,$06
    add a,l
    ld e,a
    ld d,h
    ex de,hl
    inc de
    ldi
    ldi
    ld hl,textPlayerRevived
++: call TextBox20x6
    call Close20x6TextBox
+++:jp _LABEL_37E9_

; 17th entry of Jump Table from 1F5A (indexed by unknown)
_Magic11_Telepathy:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ac
    ld (NewMusic),a
DoTelepathy:
    ld a,(CharacterSpriteAttributes)
    cp $0E
    jr z,++
    ld a,(SceneType)
    or a
    ld hl,textPlayerNoPremonition
    ; Only works in dungeons
    jr nz,+
    call _SquareInFrontOfPlayerContainsObject
    ; Say whether there's an object in front of you
    ld hl,textPlayerNoPremonition
    jr z,+
    ld hl,textPlayerPremonition
+:  call TextBox20x6
    ld a,SFX_d5
    ld (NewMusic),a
    jp Close20x6TextBox

++: ld a,(_RAM_C80F_)
    cp $3D
    ld hl,textPlayerNoPremonition
    jr z,+
    ld hl,textPlayerPremonition
+:  call TextBox20x6
    ld a,SFX_d5
    ld (NewMusic),a
    jp _LABEL_2A37_

; 19th entry of Jump Table from 1F5A (indexed by unknown)
_Magic12_Troop:
    ld a,b
    call CheckIfEnoughMP
    ld (de),a
    ld a,SFX_ab
    ld (NewMusic),a
    ld a,(SceneType)
    or a
    jr nz,_LABEL_22B5_
    ld hl,textPlayersSpellHadNoEffect
    call TextBox20x6
    jp Close20x6TextBox

_LABEL_22B5_:
    ld hl,textYouBecomeLight
    call TextBox20x6
    call Close20x6TextBox
    ld a,$08
    ld (_RAM_C2D8_),a
    ret

; 3rd entry of Jump Table from 1DF3 (indexed by CursorPos)
_LABEL_22C4_:
    ld a,(InventoryCount)
    or a
    jp nz,+
    call _LABEL_35EF_SelectItemFromInventory
    jp _LABEL_3773_HideInventoryWindow
    ; and fall through to do it again?!?

+:  call _LABEL_35EF_SelectItemFromInventory
    bit 4,c
    jp nz,_LABEL_2351_
    ld a,(ItemTableIndex)
    cp Item_Vehicle_LandMaster
    jr c,+++ ; Equipment
    cp Item_PelorieMate
    jr nc,+++ ; Items
    ; It's a vehicle
    sub $21
    add a,a
    add a,a
    add a,$04
    ld b,a
    ld a,(VehicleMovementFlags)
    or a
    jr z,+++
    cp b
    jr nz,+++
    cp $08
    jr z,+
    push bc
      call _LABEL_78F9_
    pop bc
    jr ++

+:  push bc
      call _LABEL_79D5_
    pop bc
++: ld hl,textCantDisembark
    jr nz,+
    xor a
    ld (VehicleMovementFlags),a
    dec a
    ld (_RAM_C2D8_),a
    ld hl,textDisembarkedVehicle
+:  call TextBox20x6
    call Close20x6TextBox
    jp _LABEL_2351_

+++:ld b,$04
-:  ld a,b
    sub $04
    neg
    call PointHLToCharacterInA
    jp nz,+
    djnz -
    jp _LABEL_2351_

+:  ld (TextCharacterNumber),a
    call _LABEL_3876_
    ld hl,$7A72
    ld (CursorTileMapAddress),hl
    ld a,$02
    ld (CursorMax),a
    call WaitForMenuSelection
    bit 4,c
    jp nz,+
    ld hl,UseEquipDropHandlers
    call FunctionLookup
+:  call _LABEL_3888_
_LABEL_2351_:
    call _LABEL_3773_HideInventoryWindow
    jp _LABEL_30A4_

; Jump Table from 2357 to 235C (3 entries,indexed by CursorPos)
UseEquipDropHandlers:
.dw UseItem EquipItem DropItem

; 1st entry of Jump Table from 2357 (indexed by CursorPos)
UseItem:
    ld a,(ItemTableIndex)
    ld hl,_UseItemTable
    jp FunctionLookup

; Jump Table from 2366 to 23E5 (64 entries,indexed by ItemTableIndex)
_UseItemTable:
.dw UseItem_NoEffect ; Index 0 is never used
.dw UseItem_NoEffect ; Weapons
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_PsychoWand
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect ; Armour
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect ; Shields
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_NoEffect
.dw UseItem_LandMaster ; Vehicles
.dw UseItem_FlowMover
.dw UseItem_IceDecker
.dw UseItem_PelorieMate ; Items
.dw UseItem_Ruoginin
.dw UseItem_SootheFlute
.dw UseItem_Searchlight
.dw UseItem_EscapeCloth
.dw UseItem_TranCarpet
.dw UseItem_MagicHat
.dw UseItem_Alsuline
.dw UseItem_Polymeteral
.dw UseItem_DungeonKey
.dw UseItem_TelepathyBall
.dw UseItem_EclipseTorch
.dw UseItem_AeroPrism
.dw UseItem_LaermaBerries
.dw UseItem_Hapsby
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_Compass
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_AlwaysActive
.dw UseItem_MiracleKey
.dw UseItem_AlwaysActive
; No entry for Secret Thing

; 1st entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_NoEffect:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld hl,textNoEffect
    call TextBox20x6
    jp Close20x6TextBox

; 5th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_PsychoWand:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jp nz,DoQuickDash
    ld hl,textNothingHappened
    call TextBox20x6
    jp Close20x6TextBox

; 34th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_LandMaster:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld e,$04
_LABEL_2413_:
    ld a,(_RAM_C308_)
    cp $04
    ld hl,textItemNoUseHere
    jr nc,+
    ld a,(SceneType)
    or a
    jr z,+
    push bc
    push de
      call _LABEL_78F9_
    pop de
    pop bc
    ld hl,textItemNoUseHere
    jr nz,+
    ld a,e
    ld (VehicleMovementFlags),a
    ld a,$FF
    ld (_RAM_C2D8_),a
    ld hl,textBoardedVehicle
+:  call TextBox20x6
    jp Close20x6TextBox

; 35th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_FlowMover:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C308_)
    cp $04
    ld hl,textItemNoUseHere
    jr nc,+
    ld a,(SceneType)
    or a
    jr z,+
    push bc
    push de
      call _LABEL_7964_
    pop de
    pop bc
    ld hl,textItemNoUseHere
    jr nz,+
    ld a,$08
    ld (VehicleMovementFlags),a
    ld a,$FF
    ld (_RAM_C2D8_),a
    ld hl,textBoardedVehicle
+:  call TextBox20x6
    jp Close20x6TextBox

; 36th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_IceDecker:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C308_)
    cp $02
    ld e,$0C
    jp z,_LABEL_2413_
    ld hl,textItemNoUseHere
    call TextBox20x6
    jp Close20x6TextBox

; 37th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_PelorieMate:
    ld d,10 ; HP boost
    jr +

; 38th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_Ruoginin:
    ld d,40 ; HP boost
+:  ld a,(_RAM_C29D_InBattle)
    or a
    ld a,(_RAM_C267_BattleCurrentPlayer)
    jr nz,+
    push de
      call ShowCharacterSelectMenu
    pop de
    bit 4,c
    jr nz,++
+:  ld (TextCharacterNumber),a
    call ShowMessageIfDead
    jr z,++
    push de
      ld hl,textPlayerUsedItem
      call TextBox20x6
    pop de
    call _LABEL_1FBB_Heal
    call _LABEL_28D8_RemoveItemFromInventory
++: ld a,(_RAM_C29D_InBattle)
    or a
    ret nz
    jp _LABEL_37D8_ClosePlayerSelect

; 39th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_SootheFlute:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,SFX_c2
    ld (NewMusic),a
    ld a,(_RAM_C29D_InBattle)
    or a
    jr nz,+
    ld hl,textSoothFlute
    call TextBox20x6
    ld a,SFX_d5
    ld (NewMusic),a
    ld a,(SceneType)
    or a
    jp z,_LABEL_21D4_
    jp Close20x6TextBox

+:  ld hl,textSootheFluteCalmedMonster
    call TextBox20x6
    ld a,SFX_d5
    ld (NewMusic),a
    jp Close20x6TextBox

; 40th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_Searchlight:
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ; In battle
    ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld hl,textCantDoThatNow
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(SceneType)
    or a
    jr z,+
    ; In overworld
-:  ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld hl,textNoNeedNow
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(DungeonPaletteIndex)
    or a
    jr nz,-
    ; In a dungeon with palette 0
    ld hl,textPlayerUsedItem
    call TextBox20x6
    call Close20x6TextBox
    call _LABEL_28D8_RemoveItemFromInventory
    ld a,-1 ; Palette -1 is the lit one
    ld (DungeonPaletteIndex),a
    ld (_RAM_C2D8_),a
    ret

; 41st entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_EscapeCloth:
    ld a,(_RAM_C29D_InBattle)
    or a
    call nz,_LABEL_28D8_RemoveItemFromInventory
    jp UseItem_PsychoWand

; 42nd entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_TranCarpet:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ld hl,textNoEffect
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(SceneType)
    or a
    push af
      call nz,_LABEL_28D8_RemoveItemFromInventory
    pop af
    jp nz,_LABEL_22B5_
    ld hl,textNothingHappened
    call TextBox20x6
    jp Close20x6TextBox

; 43rd entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_MagicHat:
    call _LABEL_28D8_RemoveItemFromInventory
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jp nz,DoTransrate
    ld hl,textNoEffect
    call TextBox20x6
    jp Close20x6TextBox

; 44th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_Alsuline:
    ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ld hl,textCantDoThatNow
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(RoomIndex)
    cp $A3 ; Tairon turned to stone ; _room_a3_TaironStone
    jr z,++
    call IsAnyoneOtherThanMyauAlive
    ld hl,textNothingUnusualHere ; changed to textNoNeedNow in retranslation
    jr nz,+
-:  ld hl,textMyauCantOpenBottle
+:  call TextBox20x6
    jp Close20x6TextBox

++:  call IsAnyoneOtherThanMyauAlive
    jr z,-
    ld hl,textAlisPourBottle
    call TextBox20x6
    call Close20x6TextBox
    call _LABEL_28D8_RemoveItemFromInventory
    ld iy,CharacterStatsOdin
    ld (iy+10),$06
    ld (iy+11),$13
    call InitialiseCharacterStats
    ld a,$02
    ld (PartySize),a
    ld hl,_RAM_C600_
    ld (hl),$00
    ld hl,_RAM_C50A_
    ld (hl),$FF
    ld a,$05
    ld (_RAM_C2D8_),a
    ret

; 45th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_Polymeteral:
    ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ld hl,textCantDoThatNow
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(RoomIndex)
    cp $A1 ; _room_a1_HapsbyScrapHeap
    jr z,++
    call IsAnyoneOtherThanMyauAlive
    ld hl,textMyauCantOpenBottle
    jr z,+
    ld hl,textItStinks
+:  call TextBox20x6
    jp Close20x6TextBox

IsAnyoneOtherThanMyauAlive:
    ; Returns z is they are all dead or not found yet
    ld a,(CharacterStatsAlis.IsAlive)
    ld d,a
    ld a,(CharacterStatsOdin.IsAlive)
    ld e,a
    ld a,(CharacterStatsLutz.IsAlive)
    or d
    or e
    ret

++: call IsAnyoneOtherThanMyauAlive
    jr nz,+
    ld hl,textMyauCantOpenBottle
    call TextBox20x6
    jp Close20x6TextBox

+:  ld hl,textAlisPourBottle
    call TextBox20x6
    call _LABEL_28D8_RemoveItemFromInventory
    call GetHapsby
    jp Close20x6TextBox

; 46th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_DungeonKey:
    ld a,(SceneType)
    or a
    jr z,+
UseKeyNotInDungeon: ; shared with Miracle Key
    ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld hl,textNothingUnusualHere ; changed to textNoNeedNow in retranslation
    call TextBox20x6
    jp Close20x6TextBox

+:  ld hl,textPlayerUsedItem
    call TextBox20x6
    ld b,$01
    call DungeonGetRelativeSquare
    and $07
    cp $05
    jr nz,+
    bit 7,(hl)
    jr nz,+
    ld a,$03
    ld (_RAM_C2D8_),a
    jp Close20x6TextBox

+:  ld hl,textNoEffect
    call TextBox20x6
    jp Close20x6TextBox

; 47th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_TelepathyBall:
    call _LABEL_28D8_RemoveItemFromInventory
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jp nz,DoTelepathy
    jp DoTelepathy

; 48th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_EclipseTorch:
    ld hl,textPlayerHeldItemUp
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ld hl,textMonsterAfraidOfFlame
    call TextBox20x6
    jp Close20x6TextBox ; and ret

+:  ld a,(RoomIndex)
    cp $AF ; Laerma tree ; _room_af_LaermaTree
    jr z,+
    ld hl,textNothingHappened
    call TextBox20x6
    jp Close20x6TextBox

+:  push bc
      call _LABEL_7F44_PaletteAnimation
    pop bc
    ld a,Item_LaconianPot
    call HaveItem
    jr z,+
    ld hl,textLaermaBerriesShriveledUp
    call TextBox20x6
    jp Close20x6TextBox

+:  call _LABEL_28D8_RemoveItemFromInventory
    ld hl,textPlayerPutLaermaBerriesInLaconianPot
    call TextBox20x6
    call Close20x6TextBox
    ld a,Item_LaermaBerries
    ld (ItemTableIndex),a
    call HaveItem
    ret z
    jp _LABEL_28FB_AddItemToInventory

; 49th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_AeroPrism:
    ld hl,textPlayerHeldItemUp
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ld hl,textCantDoThatNow
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(RoomIndex)
    cp $B0 ; _room_b0_TopOfBayaMarlay
    jr z,+
-:  ld hl,textNothingHappened
    call TextBox20x6
    jp Close20x6TextBox

+:  ld a,(_RAM_C2DC_)
    cp $FF
    jr z,-
    ld hl,textAerocastleAppeared
    call TextBox20x6
    ld a,$06
    ld (_RAM_C2D8_),a
    jp Close20x6TextBox

; 50th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_LaermaBerries:
    ld a,(CharacterStatsMyau)
    or a
    jr z,_LABEL_2733_
    ld a,(_RAM_C309_)
    cp $17
    jr z,+++
    ld a,(RoomIndex)
    cp $B0 ; _room_b0_TopOfBayaMarlay
    jr z,++
_LABEL_2733_:
    ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    ld hl,textNobodyHungry
    jr z,+
    ld hl,textCantDoThatNow
+:  call TextBox20x6
    jp Close20x6TextBox

++: ld a,(_RAM_C2DC_)
    cp $FF
    jr nz,_LABEL_2733_
-:  ld hl,textMyauAteLaermaBerry
    call TextBox20x6
    call Close20x6TextBox
    ld a,$07
    ld (_RAM_C2D8_),a
    ret

+++:ld a,(SceneType)
    or a
    jr z,_LABEL_2733_
    ld a,(_RAM_C29D_InBattle)
    or a
    jr nz,_LABEL_2733_
    jr -

; 51st entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_Hapsby:
    ld a,(_RAM_C29D_InBattle)
    or a
    jr z,+
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld hl,textHapsbySaysNo
    call TextBox20x6
    jp Close20x6TextBox

+:  ld hl,textHapsbyHardHead
    call TextBox20x6
    jp Close20x6TextBox

; 54th entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_Compass:
    ld a,(SceneType)
    or a
    jr z,++
    ; Not in a dungeon
-:  ld hl,textPlayerTakesOutItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    ld hl,textNoNeedNow
    jr z,+
    ld hl,textCantDoThatNow
+:  call TextBox20x6
    jp Close20x6TextBox

++: ld a,(_RAM_C29D_InBattle)
    or a
    jr nz,-
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(DungeonFacingDirection)
    and $03
    ld hl,textCompassNorth
    jr z,+
    cp $01
    ld hl,textCompassEast
    jr z,+
    cp $02
    ld hl,textCompassSouth
    jr z,+
    ld hl,textCompassWest
+:  call TextBox20x6
    jp Close20x6TextBox

; 63rd entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_MiracleKey:
    ld a,(SceneType)
    or a
    jp nz,UseKeyNotInDungeon
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld b,$01
    call DungeonGetRelativeSquare
    bit 7,(hl)
    jr nz,++
    and $07
    cp $05
    ld b,$03
    jr z,+
    cp $06
    jr nz,++
    ld b,$04
+:  ld a,b
    ld (_RAM_C2D8_),a
    jp Close20x6TextBox

++:  ld hl,textNoEffect
    call TextBox20x6
    jp Close20x6TextBox

; 52nd entry of Jump Table from 2366 (indexed by ItemTableIndex)
UseItem_AlwaysActive:
    ld hl,textPlayerUsedItem
    call TextBox20x6
    ld a,(_RAM_C29D_InBattle)
    or a
    ld hl,textNothingHappened
    jr nz,+
    ld hl,textItemAlwaysActive
+:  call TextBox20x6
    jp Close20x6TextBox

; 2nd entry of Jump Table from 2357 (indexed by CursorPos)
EquipItem:
    ld hl,Frame2Paging
    ld (hl),:ItemMetadata
    ld a,(ItemTableIndex)
    ld hl,ItemMetadata
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
    rrca
    rrca
    rrca
    rrca
    and $0F
    jp nz,+
    ; Item is not eqippable by anyone
    ld hl,textNoNeedToEquipItem
    call TextBox20x6
    jp Close20x6TextBox

+:  ld d,a
    push de
    push hl
      call ShowCharacterSelectMenu
    pop hl
    pop de
    bit 4,c
    jp nz,_LABEL_289D_
    call ShowMessageIfDead
    jp z,_LABEL_289D_
    ld (TextCharacterNumber),a
    ld c,a
    inc a
    ld b,a
    ld a,d
-:  rrca
    djnz -
    jp nc,+
    ld a,c
    add a,a
    add a,a
    add a,a
    add a,a
    ld de,CharacterStatsAlis.Weapon
    add a,e
    ld e,a
    adc a,d
    sub e
    ld d,a
    ld a,(hl)
    and $03
    add a,e
    ld e,a
    ld a,(de)
    ld hl,(_RAM_C29B_)
    ld (hl),a
    push af
      ld a,(ItemTableIndex)
      ld (de),a
      ld hl,textPlayerEquippedItem
      call TextBox20x6
      ld a,(TextCharacterNumber)
      call _LABEL_3824_
      call MenuWaitForButton
      call _LABEL_386A_
      call Close20x6TextBox
    pop af
    or a
    call z,_LABEL_28D8_RemoveItemFromInventory
_LABEL_289D_:
    call CharacterStatsUpdate
    jp _LABEL_37D8_ClosePlayerSelect

+:  ld hl,textPlayerCantEquipItem
    call TextBox20x6
    call Close20x6TextBox
    jr _LABEL_289D_

; 3rd entry of Jump Table from 2357 (indexed by CursorPos)
DropItem:
    ld hl,Frame2Paging
    ld (hl),:ItemMetadata
    ld a,(ItemTableIndex)
    ld hl,ItemMetadata
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
    and $04
    jr z,+
    ld hl,textCantDropItem
    call TextBox20x6
    jp Close20x6TextBox

+:  ld hl,textPlayerDroppedItem
    call TextBox20x6
    call _LABEL_28D8_RemoveItemFromInventory
    jp Close20x6TextBox

_LABEL_28D8_RemoveItemFromInventory:
    ld hl,(_RAM_C29B_)
RemoveItemFromInventory:
    push bc
      ld e,l
      ld d,h
      inc hl
      ld a,$D7
      sub e
      and $1F
      jr z,+
      ld c,a
      ld b,$00
      ldir
  +:  ld hl,Inventory
      ld a,(InventoryCount)
      dec a
      ld (InventoryCount),a
      add a,l
      ld l,a
      ld (hl),$00
    pop bc
    ret

_LABEL_28FB_AddItemToInventory:
    ld a,(InventoryCount)
    cp $18
    jr nc,_LABEL_2918_InventoryFull
    ld hl,Inventory
    add a,l
    ld l,a
    ld a,(ItemTableIndex)
    ld (hl),a
    ld a,(InventoryCount)
    inc a
    ld (InventoryCount),a
    ld a,SFX_b3
    ld (NewMusic),a
    ret

_LABEL_2918_InventoryFull:
    ld hl,textInventoryFull
    call TextBox20x6
    call DoYesNoMenu
    jr z,_LABEL_2934_SelectItemToDrop
    ld hl,textConfirmDropItem
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_LABEL_2934_SelectItemToDrop
    ld hl,textDropItem
    jp TextBox20x6

_LABEL_2934_SelectItemToDrop:
    ld a,(ItemTableIndex)
    push af
      ld hl,_DATA_B013_
      call TextBox20x6
      call _LABEL_35EF_SelectItemFromInventory
      call _LABEL_3773_HideInventoryWindow
      bit 4,c
      jr nz,++
      ld hl,Frame2Paging
      ld (hl),:ItemMetadata
      ld a,(ItemTableIndex)
      ld hl,ItemMetadata
      add a,l
      ld l,a
      adc a,h
      sub l
      ld h,a
      ld a,(hl)
      and $04 ; Droppable flag
      jr z,+
      ld hl,textCantDropItem
      call TextBox20x6
    pop af
    ld (ItemTableIndex),a
    jp _LABEL_2934_SelectItemToDrop

+:  ld hl,textDropItemToGetItem
    call TextBox20x6
    pop af
    ld (ItemTableIndex),a
    ld hl,(_RAM_C29B_)
    ld (hl),a
    ld a,SFX_b3
    ld (NewMusic),a
    ld hl,textAndGetItem
    jp TextBox20x6

++:  pop af
    ld (ItemTableIndex),a
    jp _LABEL_2918_InventoryFull

HaveItem:
    ld hl,Inventory
    ld b,$18
-:  cp (hl)
    ret z
    inc hl
    djnz -
    ret

; 4th entry of Jump Table from 1DF3 (indexed by CursorPos)
_LABEL_2995_:
    ld a,(CharacterSpriteAttributes)
    cp $0E
    jr nz,+
    call _LABEL_321F_HidePartyStats
    ld hl,textNothingUnusualHere
    call TextBox20x6
    call _LABEL_2A37_
    jp _LABEL_3041_UpdatePartyStats

+:  ld hl,(VLocation)
    ld a,l
    add a,$60
    jr c,+
    cp $C0
    jr c,++
+:  add a,$40
    inc h
++:  ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,h
    ld hl,(HLocation)
    ld bc,$0080
    add hl,bc
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld l,a
    ld a,(_RAM_C309_)
    cp $07
    jr nz,+
    ld a,l
    cp $28
    jr nz,_LABEL_2A21_
    ld a,h
    cp $1E
    jr nz,_LABEL_2A21_
    ld a,(SootheFluteIsUnhidden)
    or a
    jr z,_LABEL_2A21_
    cp $FF
    jr z,_LABEL_2A21_
    ld a,$FF
    ld (SootheFluteIsUnhidden),a
    ld a,Item_SootheFlute
    jr ++

+:  cp $01
    jr nz,_LABEL_2A21_
    ld a,l
    cp $30
    jr nz,_LABEL_2A21_
    ld a,h
    cp $48
    jr nz,_LABEL_2A21_
    ld a,(PerseusShieldIsUnhidden)
    or a
    jr z,_LABEL_2A21_
    ld a,(CharacterStatsOdin.Shield)
    ld b,a
    ld a,Item_Shield_ShieldOfPerseus
    cp b
    jr z,_LABEL_2A21_
++: ld (ItemTableIndex),a
    call HaveItem
    jr z,_LABEL_2A21_
    ld hl,textFoundItem
    call TextBox20x6
    call _LABEL_28FB_AddItemToInventory
    jp Close20x6TextBox

_LABEL_2A21_:
    ld a,(RoomIndex)
    cp $A2 ; _room_a2_5795 ???
    jp z,_LABEL_57C6_
    cp $A3 ; _room_a3_TaironStone
    jp z,FindTairon
    ld hl,textNothingUnusualHere
    call TextBox20x6
    jp Close20x6TextBox

_LABEL_2A37_:
    ld hl,textDoYouWantToOpenIt
    call TextBox20x6
    call ShowMenuYesNo
    push af
      call HideMenuYesNo
      call Close20x6TextBox
    pop af
    or a
    ret nz
_LABEL_2A4A_:
    ld a,SFX_b0
    ld (NewMusic),a
    ; Set ibject flag to $ff so we don't see it again
    ld hl,(DungeonObjectFlagAddress)
    ld (hl),$FF
    ld a,$01
    ld (_RAM_C80A_),a
    push bc
      call _LABEL_1A15_
    pop bc
    ld a,(_RAM_C80F_)
    cp $3D
    call nz,_LABEL_2AAC_
    ld hl,(EnemyMoney)
    ld a,h
    or l
    jr nz,+
    ld a,(DungeonObjectItemIndex)
    or a
    jr nz,+
    ld hl,textItsEmpty
    call TextBox20x6
    ld a,$D0
    ld (SpriteTable),a
    jp Close20x6TextBox

+:  ld hl,(EnemyMoney)
    ld (NumberToShowInText),hl
    call _addDEMesetas
    ld a,h
    or l
    ld hl,textMesetasInside
    call nz,TextBox20x6
    ld a,(DungeonObjectItemIndex)
    ld (ItemTableIndex),a
    or a
    jr z,+
    ld hl,textFoundItem
    call TextBox20x6
    call _LABEL_28FB_AddItemToInventory
+:  ld a,$D0
    ld (SpriteTable),a
    jp Close20x6TextBox

_LABEL_2AAC_:
    ld a,(_RAM_C80F_)
    cp $3E
    jr nz,+
    ld b,$04
-:  ld a,b
    dec a
    call ++
    djnz -
    ret

+:  call GetRandomNumber
    and $03
++:  call PointHLToCharacterInA
    ret z
    inc hl
    push hl
      ld h,(hl)
      ld l,$00
      ld e,$03
      call _LABEL_5B7_
    pop de
    ex de,hl
    ld a,(hl)
    sub d
    ld (hl),a
    ret

_addDEMesetas:
    ex de,hl
      ld hl,(Meseta)
      add hl,de
      jr nc,+
      ld hl,$FFFF ; Max 64K
+:    ld (Meseta),hl
    ex de,hl
    ret

; Orphaned code? $2ae5
    call MenuWaitForButton
    ret

_LABEL_2AE9_:
    ld hl,textHospital ; This is a hospital. Do you require medical care?<end>
    call TextBox20x6
    call DoYesNoMenu
    jp nz,_LABEL_2BB1_HospitalEnd
_LABEL_2AF5_HospitalSelectWhoLoop:
    ld a,(PartySize)
    or a
    ld hl,textHospitalWho ; Who will receive treatment?
    call nz,TextBox20x6
    call ShowCharacterSelectMenu
    bit 4,c
    jp nz,_LABEL_2BAE_HospitalClosePlayerSelect
    ld (TextCharacterNumber),a
    call PointHLToCharacterInA
    jr nz,+
    ld hl,textPlayerAlreadyDead
    call TextBox20x6
    jp _LABEL_2BA4_

+:  push hl
    pop iy
    ; Check if at full HP/MP
    ld a,(iy+Character.HP)
    cp (iy+Character.MaxHP)
    jr nz,+
    ld a,(iy+Character.MP)
    cp (iy+Character.MaxMP)
    jr nz,+
    ld hl,textHospitalNoNeedToHealPlayer
    call TextBox20x6
    ld a,(PartySize)
    or a
    jr nz,_LABEL_2BA4_
    ld hl,textHospitalPleaseBeCareful
    call TextBox20x6
    jp Close20x6TextBox

+:  ; Price = 1 MST per HP and MP needed
    ld a,(iy+Character.MaxHP)
    sub (iy+Character.HP)
    ld b,a
    ld a,(iy+Character.MaxMP)
    sub (iy+Character.MaxMP)
    add a,b
    ld l,a
    ld h,$00
    ld (NumberToShowInText),hl
    ld hl,textHospitalFee
    call TextBox20x6
    call _LABEL_3B13_ShopMesetaWindowDraw
    call DoYesNoMenu
    push af
      call nz,_LABEL_3B3C_
    pop af
    jr nz,_LABEL_2BA4_
    ld de,(NumberToShowInText)
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr c,_LABEL_2BBA_
    ld (Meseta),hl
    call _LABEL_3B21_
    ld a,SFX_Heal
    ld (NewMusic),a
    ld a,(iy+Character.MaxHP)
    ld (iy+Character.HP),a
    ld a,(iy+Character.MaxMP)
    ld (iy+Character.MP),a
    ld hl,textHospitalThankYouForWaiting
    call TextBox20x6
    call _LABEL_3B3C_
    ld a,(PartySize)
    or a
    jr z,+
    ld hl,textHospitalAnyoneElse
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_LABEL_2BAE_HospitalClosePlayerSelect
_LABEL_2BA4_:
    call _LABEL_37D8_ClosePlayerSelect
    ld a,(PartySize)
    or a
    jp nz,_LABEL_2AF5_HospitalSelectWhoLoop
_LABEL_2BAE_HospitalClosePlayerSelect:
    call _LABEL_37D8_ClosePlayerSelect
_LABEL_2BB1_HospitalEnd:
    ld hl,textHospitalCouldNotHelp
    call TextBox20x6
    jp Close20x6TextBox

_LABEL_2BBA_:
    call _LABEL_3B3C_
    call _LABEL_37D8_ClosePlayerSelect
    ld hl,textShopNotEnoughMoney
    call TextBox20x6
+:  jp Close20x6TextBox

_LABEL_2BC9_:
    ld bc,$04FF
-:  ld a,b
    dec a
    call PointHLToCharacterInA
    jr z,+
    ld a,$06
    add a,l
    ld e,a
    ld d,h
    ex de,hl
    inc de
    ldi
    ldi
+:  djnz -
    ret

_LABEL_2BE1_:
    ld a,(RoomIndex)
    ld (_RAM_C317_),a
    ld hl,textChurch
    call TextBox20x6
    call DoYesNoMenu
    or a
    jp nz,_LABEL_2CA2_
_LABEL_2BF4_:
    ld a,(PartySize)
    or a
    jp z,_LABEL_2C8D_
    ld hl,textChurchWho
    call TextBox20x6
    call ShowCharacterSelectMenu
    bit 4,c
    jp nz,_LABEL_2C9F_
    call PointHLToCharacterInA
    jr nz,_LABEL_2C8D_
    ld (TextCharacterNumber),a
    push hl
    pop iy
    ; resurrection cost = LV * 20
    ld a,(iy+Character.LV)
    add a,a
    add a,a
    ld l,a
    ld h,$00
    ld e,l
    ld d,h
    add hl,hl
    add hl,hl
    add hl,de
    ld (NumberToShowInText),hl
    ld hl,textChurchPrice
    call TextBox20x6
    call _LABEL_3B13_ShopMesetaWindowDraw
    call DoYesNoMenu
    push af
      call nz,_LABEL_3B3C_
    pop af
    jr nz,_LABEL_2C71_
    ld hl,textChurchIncantation1
    call TextBox20x6
    ld de,(NumberToShowInText)
    ld hl,(Meseta)
    or a
    sbc hl,de
    jp c,+
    ; Enough money
    ld (Meseta),hl
    call _LABEL_3B21_
    ld (iy+Character.IsAlive),$01
    ld a,(iy+Character.MaxHP)
    ld (iy+Character.HP),a
    ld a,(iy+Character.MaxMP)
    ld (iy+Character.MP),a
    ld hl,textChurchIncantation2
    call TextBox20x6
    ld a,SFX_c5
    ld (NewMusic),a
    call MenuWaitHalfSecond
    call _LABEL_3B3C_
_LABEL_2C71_:
    ld hl,textChurchAnyoneElse
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_LABEL_2C9F_
    call _LABEL_37D8_ClosePlayerSelect
    jp _LABEL_2BF4_

+:  ld hl,textChurchNotEnoughMoney
    call TextBox20x6
    call _LABEL_3B3C_
    jr _LABEL_2C71_

_LABEL_2C8D_:
    ld (TextCharacterNumber),a
    ld hl,textChurchPlayerNotDead
    call TextBox20x6
    ld a,(PartySize)
    or a
    jr nz,_LABEL_2C71_
    call MenuWaitForButton
_LABEL_2C9F_:
    call _LABEL_37D8_ClosePlayerSelect
_LABEL_2CA2_:
    ld hl,textChurchEnd
    call TextBox20x6
    ld hl,textChurchToLevelUp
    call TextBox20x6
    call +
    jp Close20x6TextBox

+:  ld iy,CharacterStatsAlis
    ld de,LevelStatsAlis
    xor a
    call +
    ld iy,CharacterStatsMyau
    ld de,LevelStatsMyau
    ld a,1
    call +
    ld iy,CharacterStatsOdin
    ld de,LevelStatsOdin
    ld a,2
    call +
    ld iy,CharacterStatsLutz
    ld de,LevelStatsLutz
    ld a,3
+:  ld (TextCharacterNumber),a
    bit 0,(iy+Character.IsAlive)
    ret z
    ld a,(iy+Character.LV)
    cp $1E
    jr c,+
    ld hl,_DATA_B6E7_
    jp TextBox20x6

+:  ld hl,Frame2Paging
    ld (hl),$03
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,de
    push hl
    pop ix
    ld e,(iy+3)
    ld d,(iy+4)
    ld l,(ix+4)
    ld h,(ix+5)
    or a
    sbc hl,de
    ld (NumberToShowInText),hl
    ld hl,textChurchPlayerNeedsExperiencePoints
    jp TextBox20x6

_LABEL_2D1C_:
    ld hl,textArmory
    call TextBox20x6
_LABEL_2D22_ShopMenus:
    call DoYesNoMenu
    jr z,_LABEL_2D30_Buy
    ld hl,textShopComeAgain
    call TextBox20x6
    jp Close20x6TextBox

_LABEL_2D30_Buy:
    push bc
      call _LABEL_39EA_ShopMesetaWindowCopy
      call _LABEL_3B13_ShopMesetaWindowDraw
    pop bc
_LABEL_2D38_BuyLoop:
    ld hl,textShopWhatDoYouWant
    call TextBox20x6
    push bc
      call _LABEL_39F6_Shop
      bit 4,c
    pop bc
    jr nz,_LABEL_2D89_
    ld a,(InventoryCount)
    cp $18
    jr nc,_LABEL_2D98_InventoryFull
    ld a,(hl)
    ld (ItemTableIndex),a
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr c,_LABEL_2D9D_NotEnoughMoney
    ld a,(ItemTableIndex)
    cp Item_SecretThing
    jr nc,_LABEL_2DA2_BuySecretThing
    ld (Meseta),hl
    call _LABEL_3B21_
    ld a,(ItemTableIndex)
    cp Item_Vehicle_LandMaster
    jr c,+ ; Shields, weapons, armour
    cp Item_PelorieMate
    jr nc,+ ; Items
    ; So it must be a vehicle. You can't have more than one of these?
    call HaveItem
    jr z,++
+:  call _LABEL_28FB_AddItemToInventory
++: ld hl,textShopBuyItem
    call TextBox20x6
    call DoYesNoMenu
    jr z,_LABEL_2D38_BuyLoop
_LABEL_2D89_:
    ld hl,textShopComeAgain
-:  call TextBox20x6
    call _LABEL_3B3C_
    call _LABEL_3AC3_
    jp Close20x6TextBox

_LABEL_2D98_InventoryFull:
    ld hl,textShopInventoryFull
    jr -

_LABEL_2D9D_NotEnoughMoney:
    ld hl,textShopNotEnoughMoney
    jr -

_LABEL_2DA2_BuySecretThing:
    ld a,(_RAM_C2EC_SecretThingBuyCount)
    cp $02
    jr nc,++
    cp $01
    ld hl,$0142
    ; I don’t know who told you that, but you’d better just forget about it if you know what’s good for you.
    jr c,+
    ld hl,$0144
    ; Give it up, willya? Now get outta here!
+:  inc a
    ld (_RAM_C2EC_SecretThingBuyCount),a
    call DrawText20x6
    call _LABEL_3B3C_
    call _LABEL_3AC3_
    jp Close20x6TextBox

++: xor a
    ld (_RAM_C2EC_SecretThingBuyCount),a
    push hl
      ld a,Item_RoadPass
      ld (ItemTableIndex),a
      call HaveItem
    pop hl
    jr z,_LABEL_2DA2_BuySecretThing ; Go back to the start if you already have it
    ld (Meseta),hl
    call _LABEL_3B21_
    call _LABEL_28FB_AddItemToInventory
    ld hl,$0146 ; You just don't quit, do you? If you're gonna keep bugging me, then fine[, take it]. But don't tell anybody.
    call DrawText20x6
    call _LABEL_3B3C_
    call _LABEL_3AC3_
    jp Close20x6TextBox

_LABEL_2DEB_:
    ld hl,textPharmacy
    call TextBox20x6
    jp _LABEL_2D22_ShopMenus ; Share code with Armory

_LABEL_2DF4_:
    ld hl,textToolShop
    call TextBox20x6
    call _LABEL_3894_BuySellMenu
    push af
    push bc
      call _LABEL_38B4_BuySellMenuClose
    pop bc
    pop af
    bit 4,c ; Button 1
    jp nz,_LABEL_2E46_Cancel
    or a
    jp z,_LABEL_2D30_Buy
_LABEL_2E0D_Sell:
    ld hl,textToolShop_WhatToSell
    call TextBox20x6
    call _LABEL_35EF_SelectItemFromInventory
    bit 4,c
    push af
      call _LABEL_3773_HideInventoryWindow
    pop af
    jp nz,_LABEL_2E46_Cancel
    ld hl,Frame2Paging
    ld (hl),:_DATA_F82F_ItemSellingPrices
    ld a,(ItemTableIndex)
    and $3F
    add a,a
    ld hl,_DATA_F82F_ItemSellingPrices
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld (NumberToShowInText),hl
    or h
    jr nz,+
    ; Selling price 0 -> can't sell it
    ld hl,textHandyLater
    call TextBox20x6
    jp _LABEL_2E0D_Sell

_LABEL_2E46_Cancel:
    ld hl,textShopComeAgain
    call TextBox20x6
    jp Close20x6TextBox

+:  ld hl,textToolShop_SellPriceOffer
    call TextBox20x6
    call DoYesNoMenu
    jr z,+
    jp _LABEL_2E0D_Sell

+:  call _LABEL_28D8_RemoveItemFromInventory
    ld hl,(NumberToShowInText)
    call _addDEMesetas
    ld hl,textToolShop_SoldItem
    call TextBox20x6
    call DoYesNoMenu
    jp z,_LABEL_2E0D_Sell
    jp _LABEL_2E46_Cancel

.orga $2e75
.section "Do yes/no menu" overwrite
DoYesNoMenu:
    push bc
      call ShowMenuYesNo
      push af
        call HideMenuYesNo
      pop af
    pop bc
    or a               ; set flag z = yes
    ret
.ends
; followed by
.orga $2e81
.section "Pause until button press with VBlankFunction_Menu" overwrite
MenuWaitForButton:
    ld a,$08           ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P11 | P12
    jp z,MenuWaitForButton
    ret
.ends
; followed by
.orga $2e8f
.section "Wait 0.5s unless button pressed" overwrite
MenuWaitHalfSecond:
    ld b,30            ; 30 frames
-:  ld a,$08           ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P11 | P12
    ret nz             ; return if button pressed
    djnz -
    ret
.ends
; followed by
.orga $2e9f
.section "Pause 3 seconds (180 frames) with VBlankFunction_Menu" overwrite
Pause3Seconds:
    ld b,3*60
-:  ld a,8             ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P11 | P12
    ret nz             ; stop if button pressed
    djnz -
    ret
.ends
; followed by
.orga $2eaf
.section "Pause 256 frames with VBlankFunction_Menu" overwrite
Pause256Frames:
    ld b,0           ; Frames to wait (0 = 256 = 4.3s)
PauseBFrames:
-:  ld a,8           ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    djnz -
    ret
.ends
; followed by
.orga $2eb9
.section "Wait for menu selection" overwrite
; returns menu selection (0-based) in a
WaitForMenuSelection:
    ld a,$FF
    ld (CursorEnabled),a  ; Enable cursor
    ld hl,$0000
    ld (CursorPos),hl  ; 0 -> CursorPos, OldCursorPos
    xor a
    ld (CursorCounter),a ; zero CursorCounter
-:  ld a,$08           ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P1U | P1D      ; if U or D not pressed
    jp z,++            ; then skip this bit
    ld c,a             ; -> c
    ld hl,CursorMax
    ld a,(CursorPos)
    bit 0,c
    jr z,+
    sub $01            ; if D then decrease CursorPos
    jr nc,+            ; if <0
    ld a,(hl)          ; then replace with CursorMax
+:  bit 1,c
    jr z,+
    inc a              ; if U then increase CursorPos
    cp (hl)            ; compare to CursorMax
    jr c,+             ; if greater
    jr z,+             ; or equal
    xor a              ; then zero it
+:  ld (CursorPos),a   ; save in CursorPos
++:  ld a,(Controls)
    and P11 | P12      ; button 1 or 2
    jp z,-             ; repeat until button is pressed
    ld c,a             ; remember button pressed in c
    xor a
    ld (CursorCounter),a ; zero CursorCounter -> get rid of cursor
    ld a,$08           ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    xor a
    ld (CursorEnabled),a ; turn off cursor
    ld a,(CursorPos)
    ret                ; return a = CursorPos - 0 or 1; c = button pressed
.ends
.orga $2f0d

_LABEL_2F0D_:
    ld a,$FF
    ld (CursorEnabled),a
_LABEL_2F12_:
    ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    ld c,a
    and $03
    jp z,++
    ld c,a
    ld hl,CursorMax
    ld a,(CursorPos)
    bit 0,c
    jr z,+
    sub $01
    jr nc,+
    ld a,(hl)
+:  bit 1,c
    jr z,+
    inc a
    cp (hl)
    jr c,+
    jr z,+
    xor a
+:  ld (CursorPos),a
    jp +++

++:  ld hl,(_RAM_C299_)
    ld a,h
    or a
    jr z,+++
    bit 2,c
    jr z,+
    ld a,l
    sub $08
    jr nc,++
    ld a,h
    jr ++

+:  bit 3,c
    jr z,+++
    ld a,l
    add a,$08
    cp h
    jr c,++
    jr z,++
    xor a
++:  ld (_RAM_C299_),a
    jr ++++

+++:ld a,c
    and $30
    jr z,_LABEL_2F12_
    xor a
    ld (CursorCounter),a
    ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    xor a
    ld (CursorEnabled),a
    bit 4,c
    ret nz
    ld a,(InventoryCount)
    cp $09
    ld a,(CursorPos)
    ret c
    or a
    jr z,+
    dec a
    ret

+:  ld hl,(_RAM_C299_)
    ld a,l
    add a,$08
    cp h
    jr c,+
    jr z,+
    xor a
+:  ld (_RAM_C299_),a
++++:
    xor a
    ld (CursorEnabled),a
    call _LABEL_3647_
    ld a,(_RAM_C299_)
    ld l,a
    ld a,(InventoryCount)
    dec a
    cp $08
    ld h,$00
    jr c,+
    ld h,$01
+:  sub l
    cp $08
    jr c,+
    ld a,$07
+:  and $07
    add a,h
    ld (CursorMax),a
    ld hl,(CursorPos)
    cp l
    jr nc,+
    ld l,a
+:  ld h,l
    ld (CursorPos),hl
    jp _LABEL_2F0D_

.orga $2fca
.section "Flash cursor" overwrite
FlashCursor:
    ld a,(CursorEnabled) ; Check CursorEnabled
    or a
    ret z              ; Continue if non-zero
    ld a,(FunctionLookupIndex)
    cp 3               ; if FunctionLookupIndex<>3 (TitleScreen)
    ld bc,$f0f3        ; then b=$f0, c=$f3 (in-game cursor tile #s, actually $1xx)
    jr nz,+
    ld bc,$ff00        ; else b=$ff, c=$00 (title screen cursor tile #s)
+:  ld hl,(CursorTileMapAddress) ; Load CursorTilemapAddress
    ld a,(OldCursorPos) ; and OldCursorPos
    srl a
    ld e,$00
    rr e
    ld d,a             ; de = _RAM_c26c_ * 128 (128 bytes = 2 rows of tiles)
    add hl,de
    ex de,hl           ; de = CursorTilemapAddress + _RAM_c26c_ * 128
    rst SetVRAMAddressToDE

    ld a,c             ; $00 or $f3 ("off" cursor)
    out (VDPData),a    ; Write tile

    ld hl,(CursorTileMapAddress)
    ld a,(CursorPos)   ; Copy CursorPos to OldCursorPos
    ld (OldCursorPos),a
    srl a
    ld e,$00
    rr e
    ld d,a             ; de = CursorPos * 128
    add hl,de
    ex de,hl           ; de = CursorTilemapAddress + CursorPos * 128
    rst SetVRAMAddressToDE

    ld a,(CursorCounter)
    dec a
    and $0F
    ld (CursorCounter),a ; decrement CursorCounter, limit to $f-$0
    bit 3,a            ; if bit 3 is 0
    ld a,b             ; then output b ($f0 or $ff) ("on" cursor)
    jr nz,+
    ld a,c             ; else output c ($f3 or $00) ("off" cursor)
+:  out (VDPData),a
    ret
.ends
.orga $3014

_LABEL_3014_:
    ld hl,_RAM_D700_
    ld de,$7B02
    ld bc,$030C
    call InputTilemapRect
    ld a,(_RAM_C267_BattleCurrentPlayer)
    add a,a
    add a,a
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld hl,$B40B
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    jp OutputTilemapBoxWipePaging

_LABEL_3035_:
    ld hl,_RAM_D700_
    ld de,$7B02
    ld bc,$030C
    jp OutputTilemapBoxWipePaging

_LABEL_3041_UpdatePartyStats:
    ld hl,_RAM_D724_
    ld de,$7C80
    ld bc,$0640
    call InputTilemapRect
    ld hl,MenuBox8Top
    ld de,$7C80
    ld ix,CharacterStatsAlis
    call +
    ld hl,_DATA_6F4DB_
    ld de,$7C90
    ld ix,CharacterStatsMyau
    call +
    ld hl,_DATA_6F50B_
    ld de,$7CA0
    ld ix,CharacterStatsOdin
    call +
    ld hl,_DATA_6F53B_
    ld de,$7CB0
    ld ix,CharacterStatsLutz
+:  bit 0,(ix+0)
    ret z
_LABEL_3083_:
    ld bc,$0310
    call OutputTilemapBoxWipePaging
    ld hl,TilesHP
    ld a,(ix+1)
    call Output4CharsPlusStat
    ld hl,TilesMP
    ld a,(ix+2)
    call Output4CharsPlusStat
    ld hl,MenuBox8Bottom
    ld bc,$0110
    jp OutputTilemapBoxWipePaging

_LABEL_30A4_:
    ld hl,MenuBox8Top
    ld de,$7C80
    ld ix,CharacterStatsAlis
    call +
    ld hl,_DATA_6F4DB_
    ld de,$7C90
    ld ix,CharacterStatsMyau
    call +
    ld hl,_DATA_6F50B_
    ld de,$7CA0
    ld ix,CharacterStatsOdin
    call +
    ld hl,_DATA_6F53B_
    ld de,$7CB0
    ld ix,CharacterStatsLutz
+:  bit 0,(ix+0)
    ret z
    ld bc,$0310
    call OutputTilemapRect
    ld hl,TilesHP
    ld a,(ix+1)
    call Output4CharsPlusStat
    ld hl,TilesMP
    ld a,(ix+2)
    call Output4CharsPlusStat
    ld hl,MenuBox8Bottom
    ld bc,$0110
    jp OutputTilemapRect

_LABEL_30FB_ShowCharacterStatsBox:
    push af
      ld hl,_RAM_D724_
      ld de,$7C80
      ld bc,$0640
      call InputTilemapRect
    pop af
_LABEL_3109_:
    ld hl,MenuBox8Top
    ld de,$7C80
    ld ix,CharacterStatsAlis
    or a
    jp z,_LABEL_3083_
    ld hl,_DATA_6F4DB_
    ld de,$7C90
    ld ix,CharacterStatsMyau
    dec a
    jp z,_LABEL_3083_
    ld hl,_DATA_6F50B_
    ld de,$7CA0
    ld ix,CharacterStatsOdin
    dec a
    jp z,_LABEL_3083_
    ld hl,_DATA_6F53B_
    ld de,$7CB0
    ld ix,CharacterStatsLutz
    jp _LABEL_3083_

.orga $3140
.section "Output chars plus number plus right |" overwrite
; outputs 8/16 bytes = 4/8 chars at (hl), then 3-digit number in a, then write | to VRAM address de
; Then does VBlankFunction_Enemy in VBlank to keep tile animations going
Output4CharsPlusStatWide:
    di
      push de
        push af
          rst SetVRAMAddressToDE
          ld b,16
          jp +

Output4CharsPlusStat:
    di
      push de
        push af
          rst SetVRAMAddressToDE
          ld b,8   ; counter

+:
-:        ld a,(hl)
          out (VDPData),a ; output 8 bytes from hl to de
          inc hl
          djnz -
        pop af

        ld bc,$c010    ; tile c0 for leading blanks

        ld d,$FF
-:      sub 100        ; d = 100s digit in a
        inc d
        jr nc,-
        add a,100

        ld l,a         ; backup a
        ld a,d
        call OutputDigit

        ld d,$FF
        ld a,l
-:      sub 10         ; d = 10s digit in a
        inc d
        jr nc,-
        add a,10

        ld l,a         ; same as before
        ld a,d
        call OutputDigit

        ld d,$FF
        ld a,l
-:      sub 1          ; d = 1s digit in a
        inc d
        jr nc,-
        ld a,d

        ld bc,$c110    ; tile c1 for a final 0 if zero
        call OutputDigit

        push af        ; delay
        pop af

        ld a,$f3       ; output right |
        out (VDPData),a
        push af
        pop af
        ld a,$13
        out (VDPData),a
      pop de
      ld hl,32*2
      add hl,de
      ex de,hl           ; de = next row down
    ei
    ld a,$0a           ; VBlankFunction_Enemy
    call ExecuteFunctionIndexAInNextVBlank
    ret
.ends
.orga $319e

_LABEL_319E_:
    di
      push de
        push bc
          rst SetVRAMAddressToDE
          ld b,$0C
-:        ld a,(hl)
          out (VDPData),a
          inc hl
          djnz -
        pop hl
        ld bc,$C010 ; tile c0 for leading blanks
        ld de,10000
        xor a
        dec a
-:      sbc hl,de
        inc a
        jr nc,-
        add hl,de
        call OutputDigit
        ld de,1000
        ld a,-1
-:      sbc hl,de
        inc a
        jr nc,-
        add hl,de
        call OutputDigit
        ld de,100
        ld a,-1
-:      sbc hl,de
        inc a
        jr nc,-
        add hl,de
        call OutputDigit
        ld d,-1
        ld a,l
-:      sub 10
        inc d
        jr nc,-
        add a,10
        ld l,a
        ld a,d
        call OutputDigit
        ld d,-1
        ld a,l
-:      sub 1
        inc d
        jr nc,-
        ld a,d
        ld bc,$C110
        call OutputDigit
        push af
        pop af
        ld a,$F3
        out (VDPData),a
        push af
        pop af
        ld a,$13
        out (VDPData),a
      pop de
      ld hl,$0040
      add hl,de
      ex de,hl
    ei
    ld a,$0A
    call ExecuteFunctionIndexAInNextVBlank
    ret

.orga $320f
.section "Tilemaps for HM and MP display" overwrite
; Data from 320F to 3216 (8 bytes)
TilesHP:
.dw $11f3 $11f4 $11f5 $10c0 ; "|HP "
TilesMP:
.dw $11F3 $11F6 $11F5 $10C0 ; "|MP "
.ends
; followed by
.orga $321f
.section "Output _RAM_d724_ tilemap data to bottom of screen" overwrite
_LABEL_321F_HidePartyStats:
    ld hl,_RAM_D724_
    TileMapAddressDE 0,18
    TileMapAreaBC 32,6
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $322b
.section "Show combat menu" overwrite
ShowCombatMenu:
    ld hl,OldTileMapMenu
    TileMapAddressDE 1,1
    TileMapAreaBC 6,11
    call InputTilemapRect ; backup tilemap
    ld hl,MenuCombat
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $323d
.section "Refresh combat menu" overwrite
RefreshCombatMenu:
    ld hl,MenuCombat
    TileMapAddressDE 1,1
    TileMapAreaBC 6,11
    jp OutputTilemapRect ; and ret
.ends
; followed by
.orga $3249
.section "Close menu" overwrite
CloseMenu:             ; $3249
    ld hl,OldTileMapMenu
    TileMapAddressDE 1,1
    TileMapAreaBC 6,11
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $3255
.section "Show enemy name and stats" overwrite
ShowEnemyData:         ; $3255
; displays EnemyName and stats for however many are "there"
    ld hl,OldTileMapEnemyName10x4
    TileMapAddressDE 14,0
    TileMapAreaBC 10 4
    call InputTilemapRect

    ld hl,OldTileMapEnemyStats8x10
    TileMapAddressDE 24,0
    TileMapAreaBC 8,10
    call InputTilemapRect
_LABEL_326D_UpdateEnemyHP:
    ld hl,Menu10Top    ; tilemap data for menu top?
    TileMapAddressDE 14,0
    TileMapAreaBC 10,1
    call OutputTilemapRect

    ld hl,Frame2Paging
    ld (hl),$02

    ld hl,EnemyName
    ld c,$00
    call Output8CharMenuLine
    ld c,$01
    call Output8CharMenuLine

    ld hl,Menu10Bottom ; tilemap data for menu bottom
    TileMapAreaBC 10,1
    call OutputTilemapRect

    ld a,(EnemyNumber)
    cp Enemy_DarkForce
    ret z              ; end if EnemyNumber = Dark Force

    ld hl,MenuBox8Top
    TileMapAddressDE 24,0
    TileMapAreaBC 8,1
    call OutputTilemapBoxWipePaging

    ld ix,CharacterStatsEnemies ; Enemy stats
    ld a,(NumEnemies)
    ld b,a             ; b = number of enemies
-:  push bc
      ld hl,TilesHP
      ld a,(ix+$01)  ; HP
      call Output4CharsPlusStat
      ld bc,$10      ; Next enemy's stats
      add ix,bc
    pop bc
    djnz -

    ld hl,MenuBox8Bottom
    TileMapAreaBC 8,1
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $32c9
.section "Output 8 char menu line" overwrite
Output8CharMenuLine:   ; $32c9
; outputs |item----| to tilemap
; where item---- is an 8 letter string pointed to by hl
; call once with c=0 and once with c=1
; Needs character lookup paged in
    di
    push bc
    push hl
      push de
        rst SetVRAMAddressToDE
        push af    ; delay
        pop af

        ld a,$f3   ; Output tile 1f3 = | (high priority)
        out (VDPData),a
        push af
        pop af
        ld a,$11
        out (VDPData),a

        ld b,$08   ; b=8 = counter for 8 chars

-:      ld a,(hl)
        add a,a
        add a,c
        ld de,$8000
        add a,e
        ld e,a
        adc a,d
        sub e
        ld d,a     ; de=$8000 + (hl)*2+c
        ld a,(de)
        out (VDPData),a ; output tile number found there with high priority
        push af
        pop af
        ld a,$10
        out (VDPData),a
        inc hl
        djnz -

        push af    ; output right |
        pop af
        ld a,$F3
        out (VDPData),a
        push af
        pop af
        ld a,$13
        out (VDPData),a
      pop de
      ld hl,32*2
      add hl,de
      ex de,hl       ; move de to next row
    pop hl
    pop bc
    ei
    ret
.ends
; followed by
.orga $3309
.section "Restore tilemap after killing enemy" overwrite
HideEnemyData:         ; $3309
    ld hl,OldTileMapEnemyStats8x10
    TileMapAddressDE 24,0
    TileMapAreaBC 8,10
    ld a,(EnemyNumber)
    cp Enemy_DarkForce
    call nz,OutputTilemapBoxWipePaging ; restore tilemap if EnemyNumber!=73=Dark Force

    ld hl,OldTileMapEnemyName10x4
    TileMapAddressDE 14,0
    TileMapAreaBC 10,4
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $3326
; Data from 3326 to 3335 (16 bytes)
.section "20x6 text box at bottom of screen" overwrite
_CharacterNames:
.stringmap script "アリサ<wait>"
.stringmap script "ミャウ<wait>"
.stringmap script "タイロン"
.stringmap script "ルツ<wait>　"

-:  dec hl             ; move pointer back <-+
    jp _NextLine       ; ------------------------------------------+
                       ;                     |                     |
TextBox20x6:           ; $333a               |                     |
; Draws 20x6 text box to screen with text at |                     |
; (hl) in it                                 |                     |
; Supports several text codes                |                     |
; Parameters:                                |                     |
; hl = pointer to text                       |                     |
    ld a,:DialogueText ;                     |                     |
    ld (Frame2Paging),a ;                    |                     |
                       ;                     |                     |
    ld a,(TextBox20x6Open) ;                 |                     |
    or a               ;                     |                     |
    jp nz,-            ; if non-zero --------+                     |
                       ;                                           |
    ld a,$ff           ;                                           |
    ld (TextBox20x6Open),a ; set TextBox20x6Open                   |
    push hl            ;                                           |
      ld hl,OldTileMap20x6  ; Read existing tilemap into buffer    |
      TileMapAddressDE 6,18 ;                                      |
      TileMapAreaBC 20,6    ;                                      |
      call InputTilemapRect ;                                      |
      ld hl,MenuBox20x6     ;                                      |
      call OutputTilemapBoxWipePaging ; Draw empty 20x6 box        |
    pop hl             ;                                           |
-:                     ;                                           |
_ResetCursor:          ; $335f                                     |
    TileMapAddressDE 7,19 ; inside box                             |
    ld bc,$1200        ; b = 18 , c = 0 (x, y)                     |
_ReadData:             ; $3365 <-----------------------------------|--+
    ld a,(hl)          ; Get data                                  |  |
;                                                                  |  |
; $4f Insert character name                                        |  |
; $50 Insert enemy name                                            |  |
; $51 OutputItemName (in ItemTableIndex)                           |  |
; $52 OutputNumber (in NumberToShowInText)                         |  |
; $53 ??? Also blanks text box                                     |  |
; $54 NextLine                                                     |  |
; $55 BlankTextAfterButton (intro), WaitForButton (menu)           |  |
; $56 ExitImmediately                                              |  |
; $57 ExitAfterPause (256 frames in intro, 30 in menu)             |  |
; $58 ExitAfterButton/text end marker                              |  |
;                                                                  |  |
    cp TextButtonEnd   ;                                           |  |
    jp nc,MenuWaitForButton ; and ret                              |  |
    cp TextEnd         ;                                           |  |
    ret z              ;                                           |  |
    cp TextPauseEnd    ;                                           |  |
    jp z,MenuWaitHalfSecond ; and ret                              |  |
    cp TextButton      ;                                           |  |
    jr nz,+            ; if none of the above ---+                 |  |
    call MenuWaitForButton ;                     |                 |  |
    jp _NextLine       ; ------------------------|-----------------+  |
                       ;                         |                 |  |
+:                     ; $337d               <---+                 |  |
    cp $53             ; Blanks text box                           |  |
    jr nz,+            ; not $53 ----------------+                 |  |
    ; fall through                               |                 |  |
;_BlankTextBox:         ; $3381                  |                 |  |
    push hl            ;                         |                 |  |
      ld hl,MenuBox20x6      ;                   |                 |  |
      TileMapAddressDE 6,18  ;                   |                 |  |
      ld bc,$0628            ; 20x6              |                 |  |
      call OutputTilemapRect ;                   |                 |  |
    pop hl             ;                         |                 |  |
    inc hl             ; Next data               |                 |  |
    jp _ResetCursor    ;                         |                 |  |
                       ;                         |                 |  |
+:                     ; $3393       <-----------+                 |  |
    cp TextNewLine     ;                                           |  |
    jr nz,+            ; ------------------------+                 |  |
    ; fall through                               |                 |  |
_NextLine:             ; $3397                <--------------------+  |
    ld a,c             ; if not on first row     |                    |
    or a               ; then scroll text up     |                    |
    call nz,_ScrollTextBoxUp2Lines ;             |                    |
    TileMapAddressDE 7,21 ; move "cursor"        |                    |
    ld bc,$1201        ; reset b = 18, c = 1     |                    |
    inc hl             ; next data               |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33a6             <-----+                    |
    cp TextCharacterName ; Draw TextCharacterNumberth 4 letters from _CharacterNames
    jr nz,+            ;                    -----+                    |
    push hl            ;                         |                    |
      ld a,(TextCharacterNumber) ;             |                    |
      and $03          ; just low 2 bits         |                    |
      add a,a          ; multiply by 4           |                    |
      add a,a          ;                         |                    |
      ld hl,_CharacterNames ;                  |                    |
      add a,l          ;                         |                    |
      ld l,a           ;                         |                    |
      adc a,h          ;                         |                    |
      sub l            ; hl = _CharacterNames    |                    |
      ld h,a           ; + 4*TextCharacterNumber |                    |
      ld a,4           ;                         |                    |
      call _DrawALetters ;                     |                    |
    pop hl             ;                         |                    |
    inc hl             ; next data               |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33c4           <-------+                    |
    cp TextEnemyName   ;                                              |
    jr nz,+            ; ------------------------+                    |
    push hl            ;                         |                    |
      ld hl,EnemyName  ;                         |                    |
      ld a,8           ;                         |                    |
      call _DrawALetters ;                       |                    |
    pop hl             ;                         |                    |
    inc hl             ; next data               |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33d6      <------------+                    |
    cp TextItem        ; Draws ItemTableIndexth text from ItemTextTable
    jr nz,+            ; ------------------------+                    |
    push hl            ;                         |                    |
      ld a,(ItemTableIndex) ;                    |                    |
      ld l,a           ;                         |                    |
      ld h,$00         ;                         |                    |
      add hl,hl        ;                         |                    |
      add hl,hl        ;                         |                    |
      add hl,hl        ;                         |                    |
      push bc          ;                         |                    |
        ld bc,ItemTextTable ;                    |                    |
        add hl,bc      ; hl = ItemTextTable      |                    |
      pop bc           ;    + ItemTableIndex * 8 |                    |
      ld a,8           ;                         |                    |
      call _DrawALetters ;                       |                    |
    pop hl             ;                         |                    |
    inc hl             ;                         |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33f4  <----------------+                    |
    cp TextNumber      ;                                              |
    jr nz,+            ; ------------------------+                    |
    push hl            ;                         |                    |
      push bc          ;                         |                    |
        push de        ;                         |                    |
          ld hl,(NumberToShowInText) ;           |                    |
          ld de,10000  ;                         |                    |
          xor a        ; reset carry and a       |                    |
          ld c,a       ; c = 0                   |                    |
          dec a        ; a = -1                  |                    |
-:        sbc hl,de    ;                         |                    |
          inc a        ; a = hl/10000            |                    |
          jr nc,-      ;                         |                    |
          add hl,de    ; hl = remainder          |                    |
        pop de           ;                       |                    |
        call _OutputDigitA ;                     |                    |
        push de        ;                         |                    |
          ld de,1000   ;                         |                    |
          ld a,-1      ;                         |                    |
-:        sbc hl,de    ;                         |                    |
          inc a        ; a = hl/1000             |                    |
          jr nc,-      ;                         |                    |
          add hl,de    ; hl = remainder          |                    |
        pop de           ;                       |                    |
        call _OutputDigitA ;                     |                    |
        push de          ;                       |                    |
          ld de,100    ;                         |                    |
          ld a,-1      ;                         |                    |
-:        sbc hl,de    ;                         |                    |
          inc a        ; a = hl/100              |                    |
          jr nc,-      ;                         |                    |
          add hl,de    ; l = remainder           |                    |
        pop de         ;                         |                    |
        call _OutputDigitA ;                     |                    |
        push de        ;                         |                    |
          ld d,-1      ;                         |                    |
          ld a,l       ;                         |                    |
-:        sub 10       ;                         |                    |
          inc d        ; d = l/10                |                    |
          jr nc,-      ;                         |                    |
          add a,10     ;                         |                    |
          ld l,a       ; l = remainder           |                    |
          ld a,d       ;                         |                    |
        pop de           ;                       |                    |
        call _OutputDigitA ;                     |                    |
        push de          ;                       |                    |
          ld d,-1      ;                         |                    |
          ld a,l       ;                         |                    |
-:        sub 1        ;                         |                    |
          inc d        ; d = l/1 (??? why?)      |                    |
          jr nc,-      ;                         |                    |
          ld a,d       ;                         |                    |
          ld c,1       ; Force output if 0       |                    |
        pop de           ;                       |                    |
        call _OutputDigitA ;                     |                    |
        ld a,b         ; preserve digit counter  |                    |
      pop bc           ; through pop             |                    |
      ld b,a           ;                         |                    |
    pop hl             ;                         |                    |
    inc hl             ; next data               |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $3457 <-----------------+                    |
    call _DrawLetter   ; Finally... a normal letter.                  |
    jp _ReadData       ; ---------------------------------------------+

_OutputDigitA:         ; $345d
; Only outputs 0 when low bit of c is set
; Decrements b to count how many digits have been displayed
    or a               ; if a!=0
    jp nz,+            ; then don't check c
    bit 0,c            ; else check that low bit of c is set
    ret z              ; return if not
+:  ld c,$01           ; Set low bit of c to signify that zeroes should be displayed after this digit
    di                 ;
    push de            ;
      push af        ;
        rst SetVRAMAddressToDE
        push af    ; delay
        pop af     ;
        ld a,$c0   ; space
        out (VDPData),a ;
        push af    ;
        pop af     ;
        ld a,$10   ;
        out (VDPData),a ;
        ld a,$40   ; add $40 = 1 line to de
        add a,e    ;
        ld e,a     ;
        adc a,d    ;
        sub e      ;
        ld d,a     ;
        rst SetVRAMAddressToDE
      pop af         ; retrieve parameter a
      add a,$c1      ; add $c1 = '0'
      out (VDPData),a ;
      push af        ;
      pop af         ;
      ld a,$10       ;
      out (VDPData),a ;
    pop de             ;
    inc de             ; Move to next location in tilemap
    inc de             ;
    ei                 ;
    ld a,$0a           ; VBlankFunction_Enemy
    call ExecuteFunctionIndexAInNextVBlank ;
    dec b              ;
    ret                ;
                       ;
_DrawALetters:         ; $3494
; Draws a letters of text from hl
    push af            ;
      call _DrawLetter ; moves hl
      ld a,(hl)        ; peek at next data
      cp $58           ; ExitAfterButton -> no return
      jr z,+           ; ------------------------+
    pop af             ;                         |
    dec a              ; dec counter             |
    jp nz,_DrawALetters; repeat until a=0        |
    ret                ;                         |
+:  pop af             ; <-----------------------+
    ret                ; return


ShowNarrativeText:      ; $34a5
    ld a,:DialogueText
    ld (Frame2Paging),a

    TileMapAddressDE 6,16 ; where to start drawing text from
    ld bc,$0000        ; reset b & c
--: push de
-:    call _DrawLetter ; modifies b and c sometimes for its own re-use
      ld a,(hl)        ; check for special bytes
      cp TextPauseEnd
      jr z,_ExitAfterPause
      cp $58
      jr z,_ExitAfterButton
      cp TextButton
      jr z,_BlankTextAfterButton
      cp TextNewLine
      jr nz,-
      inc hl         ; next data
      ex de,hl
    pop hl
    ld bc,32*2*2       ; 2 lines down
    add hl,bc
    ex de,hl
    jp --

_BlankTextAfterButton: ; $34d0
    pop de             ; don't need it
    inc hl             ; move to next data
    push hl
      call MenuWaitForButton

      TileMapAddressDE 0,16
      ld bc,8*32     ; 8 rows
      ld hl,$0800    ; Tile 0, sprite palette
      di
        call FillVRAMWithHL
      ei
    pop hl
    jp ShowNarrativeText ; repeat

_ExitAfterButton:      ; $34e8
    call MenuWaitForButton
    pop de             ; don't need it
    ret                ; exit

_ExitAfterPause:       ; $34ed
    call Pause256Frames
    pop de             ; don't need it
    ret                ; exit

_DrawLetter:           ; $34f2
    di
    push bc
      push de
        rst SetVRAMAddressToDE
        ld a,(hl)      ; Get data (upper half of letter)
        add a,a
        ld bc,TileNumberLookup
        add a,c
        ld c,a
        adc a,b
        sub c
        ld b,a         ; bc = TileNumberLookup + 2*a
        ld a,(bc)      ; get tile number corresponding to a from there
        out (VDPData),a
        push af        ; delay
        pop af
        ld a,$10       ; in front of sprites
        out (VDPData),a
        ex de,hl
          ld bc,$40      ; add $40 to de (1 row)
          add hl,bc
        ex de,hl
        rst SetVRAMAddressToDE
        ld a,(hl)      ; get data (lower half of letter)
        add a,a
        ld bc,TileNumberLookup + 1
        add a,c
        ld c,a
        adc a,b
        sub c
        ld b,a         ; bc = TileNumberLookup+1 + 2*a
        ld a,(bc)      ; get tile number corresponding to a from there
        out (VDPData),a
        push af        ; delay
        pop af
        cp $fe         ; should the lower half be reversed? (tile $fe = . also acts as a dot above a letter the other way round)
        ld a,$12       ; if so, in front of sprite + horizontal mirror
        jr z,+
        ld a,$10       ; else in front of sprites
+:      out (VDPData),a
        inc hl         ; move to next data
      pop de
      inc de
      inc de
    pop bc
    ei
    ld a,$0a           ; VBlankFunction_Enemy (I have to fix these labels...)
    call ExecuteFunctionIndexAInNextVBlank
    dec b              ; dec b
    ret nz             ; return if non-zero -> only do next bit when b=1 at start

    ld a,(hl)          ; peek at next data
    cp $53
    ret nc             ; if >=$53 (control codes)
    ld a,c             ; get c
    or a               ; if non-zero,
    call nz,_ScrollTextBoxUp2Lines
    TileMapAddressDE 7,21
    ld bc,$1201        ; reset b=1, c=$12
    ret

_ScrollTextBoxUp2Lines: ; $3546
    push bc
    push de
    push hl
      call _ScrollTextBoxUp1Line
      call _ScrollTextBoxUp1Line
    pop hl
    pop de
    pop bc
    ret

_ScrollTextBoxUp1Line: ; $3553
    ld hl,OldTileMap20x6Scroll
    TileMapAddressDE 7,20
    ld bc,$0324        ; input 18x3 rect (108 bytes)
    call InputTilemapRect

    ld hl,OldTileMap20x6Scroll
    TileMapAddressDE 7,19
    ld bc,$0324        ; output it 1 line higher
    call OutputTilemapRect

    ld hl,Menu18Blanks
    ld bc,$0124        ; output 18 blank tiles 1 line lower
    call OutputTilemapRect

    ld b,4             ; wait 4 frames
-:  ld a,$0a           ; VBlankFunction_Enemy
    call ExecuteFunctionIndexAInNextVBlank
    djnz -
    ret
.ends
; followed by
.orga $357e
.section "Close 20x6 text box" overwrite
Close20x6TextBox:      ; $357e
    ld hl,TextBox20x6Open
    ld a,(hl)
    or a
    ret z              ; return if TextBox20x6Open==0
    ld (hl),$00        ; TextBox20x6Open = 0
    ld hl,OldTileMap20x6
    TileMapAddressDE 6,18
    ld bc,$0628        ; 20x6
    jp OutputTilemapBoxWipePaging ; and ret
.ends
.orga $3592

_LABEL_3592_:
    push af
    push bc
      ld hl,_RAM_DB74_
      ld de,$7A0C
      ld bc,$0C0C
      call InputTilemapRect
    pop bc
    pop af
    add a,a
    add a,a
    add a,a
    ld l,a
    ld h,$00
    ld e,l
    ld d,h
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,de
    add hl,hl
    ld de,$B6DF
    add hl,de
    ld de,$7A0C
    ld a,b
    or a
    jp z,+
    add a,a
    inc a
    ld b,a
    ld c,$0C
    push bc
      call OutputTilemapBoxWipePaging
    pop bc
    ld a,b
    add a,a
    ld l,a
    add a,a
    add a,l
    add a,a
    ld hl,$BA3F
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,$0C
    sub b
    ld b,a
    jp OutputTilemapBoxWipePaging

+:  ld hl,_DATA_6FA3F_
    ld bc,$0C0C
    jp OutputTilemapBoxWipePaging

_LABEL_35E3_:
    ld hl,_RAM_DB74_
    ld de,$7A0C
    ld bc,$0C0C
    jp OutputTilemapBoxWipePaging

_LABEL_35EF_SelectItemFromInventory:
    ld a,(InventoryCount)
    dec a
    and $18
    ld h,a
    ld l,$00
    ld (_RAM_C299_),hl
    call _LABEL_363B_
    ld a,(InventoryCount)
    or a
    jp z,MenuWaitForButton
    dec a
    cp $08
    ld l,$00
    jr c,+
    ld l,$01
    ld a,$07
+:  and $07
    add a,l
    ld (CursorMax),a
    ld hl,$796C
    ld (CursorTileMapAddress),hl
    ld hl,$0000
    ld (CursorPos),hl
    xor a
    ld (CursorCounter),a
    call _LABEL_2F0D_
    ld l,a
    ld a,(_RAM_C299_)
    add a,l
    ld hl,Inventory
    add a,l
    ld l,a
    ld (_RAM_C29B_),hl
    ld a,(hl)
    ld (ItemTableIndex),a
    ret

_LABEL_363B_:
    ld hl,_RAM_DC04_
    ld de,$78AC
    ld bc,$1514
    call InputTilemapRect
_LABEL_3647_:
    ld hl,Menu10Top
    ld de,$78AC
    ld bc,$0114
    call OutputTilemapBoxWipePaging
    call _LABEL_36E1_
    ld a,(InventoryCount)
    cp $09
    ld hl,_DATA_6FAF7_
    ld bc,$0214
    call nc,OutputTilemapBoxWipePaging
    ld hl,Frame2Paging
    ld (hl),$02
    ld a,(_RAM_C299_)
    ld hl,Inventory
    add a,l
    ld l,a
    ld b,$08
-:  ld c,$00
    call _LABEL_368A_
    ld c,$01
    call _LABEL_368A_
    inc hl
    djnz -
    ld hl,Menu10Bottom
    ld bc,$0114
    call OutputTilemapBoxWipePaging
    ret

_LABEL_368A_:
    di
    push bc
    push hl
      push de
        rst SetVRAMAddressToDE
        ld l,(hl)
        ld h,$00
        add hl,hl
        add hl,hl
        add hl,hl
        ld de,ItemTextTable
        add hl,de
        push af
        pop af
        ld a,$F3
        out (VDPData),a
        push af
        pop af
        ld a,$11
        out (VDPData),a
        ld b,$08
-:      ld a,(hl)
        add a,a
        add a,c
        ld de,$8000
        add a,e
        ld e,a
        adc a,d
        sub e
        ld d,a
        ld a,(de)
        out (VDPData),a
        push af
        pop af
        ld a,$10
        out (VDPData),a
        inc hl
        djnz -
        push af
        pop af
        ld a,$F3
        out (VDPData),a
        push af
        pop af
        ld a,$13
        out (VDPData),a
      pop de
      ld hl,$0040
      add hl,de
      ex de,hl
    pop hl
    pop bc
    ei
    ld a,$0A
    call ExecuteFunctionIndexAInNextVBlank
    ret

_LABEL_36D9_:
    di
    push de
      rst SetVRAMAddressToDE
      ld b,$0C
      jp +

_LABEL_36E1_:
    di
    push de
      rst SetVRAMAddressToDE
      ld b,$08
+:    ld hl,_DATA_3756_
-:    ld a,(hl)
      out (VDPData),a
      inc hl
      djnz -
      ld hl,(Meseta)
_LABEL_36F2_DrawLargeNumberAndRightBorder:
      ld bc,$C010
      ld de,10000
      ld a,-1
-:    sbc hl,de
      inc a
      jr nc,-
      add hl,de
      call OutputDigit
      ld de,1000
      ld a,-1
-:    sbc hl,de
      inc a
      jr nc,-
      add hl,de
      call OutputDigit
      ld de,100
      ld a,-1
-:    sbc hl,de
      inc a
      jr nc,-
      add hl,de
      call OutputDigit
      ld d,-1
      ld a,l
-:    sub 10
      inc d
      jr nc,-
      add a,10
      ld l,a
      ld a,d
      call OutputDigit
      ld d,-1
      ld a,l
-:    sub 1
      inc d
      jr nc,-
      ld a,d
      ld bc,$C110
      call OutputDigit
_LABEL_373D_DrawRightBorder:
      push af
      pop af
      ld a,$F3
      out (VDPData),a
      push af
      pop af
      ld a,$13
      out (VDPData),a
    pop de
    ld hl,$0040
    add hl,de
    ex de,hl
    ei
    ld a,$0A
    call ExecuteFunctionIndexAInNextVBlank
    ret

; Data from 3756 to 3761 (12 bytes)
_DATA_3756_:
.db $F3 $11 $EC $10 $D8 $10 $DA $10 $C0 $10 $C0 $10

.orga $3762
.section "Output digit in a" overwrite
OutputDigit:           ; $3762
; outputs digit in a to VRAM (address already set)
; unless a=0 when the value in bc determines which tile is output
    and $0f            ; cut a down to a single digit
    jp z,+             ; if non-zero,
    ld bc,$c110        ; add to $c1 = index of tile '0'
+:  add a,b            ; else add to whatever bc was already
    out (VDPData),a
    push af
    pop af
    ld a,c
    out (VDPData),a    ; output
    ret
.ends
.orga $3773

_LABEL_3773_HideInventoryWindow:
    push bc
      ld hl,_RAM_DC04_
      ld de,$78AC
      ld bc,$1514
      call OutputTilemapBoxWipePaging
    pop bc
    ret

ShowCharacterSelectMenu:
    ld a,(PartySize)
    or a
    ret z
    ld hl,_RAM_DDA8_
    ld de,$7A44
    ld bc,$090C
    call InputTilemapRect
    call +
    ld hl,$7A84
    ld (CursorTileMapAddress),hl
    jp WaitForMenuSelection

_LABEL_379F_ChooseCharacter:
    ld a,(PartySize)
    or a
    ret z
    ld hl,_RAM_DE14_
    ld de,$7A54
    ld bc,$090C
    call InputTilemapRect
    call +
    ld hl,$7A94
    ld (CursorTileMapAddress),hl
    jp WaitForMenuSelection

+:  ld a,(PartySize)
    or a
    ret z
    ld (CursorMax),a
    inc a
    add a,a
    ld b,a
    ld c,$0C
    ld hl,_DATA_6FB1F_
    call OutputTilemapBoxWipePaging
    ld hl,_DATA_6FB7F_
    ld bc,$010C
    jp OutputTilemapBoxWipePaging

_LABEL_37D8_ClosePlayerSelect:
    ld a,(PartySize)
    or a
    ret z
    ld hl,_RAM_DDA8_
    ld de,$7A44
    ld bc,$090C
    jp OutputTilemapBoxWipePaging

_LABEL_37E9_:
    ld a,(PartySize)
    or a
    ret z
    ld hl,_RAM_DE14_
    ld de,$7A54
    ld bc,$090C
    jp OutputTilemapBoxWipePaging

_LABEL_37FA_:
    ld hl,OldTileMapMenu
    ld de,$7842
    ld bc,$0B0C
    call InputTilemapRect
    ld hl,_DATA_6FB8B_
    jp OutputTilemapBoxWipePaging

_LABEL_380C_:
    ld hl,_DATA_6FB8B_
    ld de,$7842
    ld bc,$0B0C
    jp OutputTilemapRect

_LABEL_3818_:
    ld hl,OldTileMapMenu
    ld de,$7842
    ld bc,$0B0C
    jp OutputTilemapBoxWipePaging

_LABEL_3824_:
    push af
      ld hl,OldTileMapEnemyName10x4
      ld de,$7A8C
      ld bc,$0814
      call InputTilemapRect
      ld hl,Menu10Top
      ld de,$7A8C
      ld bc,$0114
      call OutputTilemapBoxWipePaging
    pop af
    push af
      add a,a
      add a,a
      add a,a
      add a,a
      ld hl,Frame2Paging
      ld (hl),$02
      ld hl,CharacterStatsAlis.Weapon
      add a,l
      ld l,a
      adc a,h
      sub l
      ld h,a
      ld b,$03
-:    ld c,$00
      call _LABEL_368A_
      ld c,$01
      call _LABEL_368A_
      inc hl
      djnz -
      ld hl,Menu10Bottom
      ld bc,$0114
      call OutputTilemapBoxWipePaging
    pop af
    ret

_LABEL_386A_:
    ld hl,OldTileMapEnemyName10x4
    ld de,$7A8C
    ld bc,$0814
    jp OutputTilemapBoxWipePaging

_LABEL_3876_:
    ld hl,_RAM_DE14_
    ld de,$7A32
    ld bc,$070A
    call InputTilemapRect
    ld hl,_DATA_6FC0F_
    jp OutputTilemapBoxWipePaging

_LABEL_3888_:
    ld hl,_RAM_DE14_
    ld de,$7A32
    ld bc,$070A
    jp OutputTilemapBoxWipePaging

_LABEL_3894_BuySellMenu:
    ld hl,_RAM_DE14_
    ld de,$7B48
    ld bc,$050C
    call InputTilemapRect
    ld hl,_DATA_6FC55_
    call OutputTilemapBoxWipePaging
    ld hl,$7B88
    ld (CursorTileMapAddress),hl
    ld a,$01
    ld (CursorMax),a
    jp WaitForMenuSelection

_LABEL_38B4_BuySellMenuClose:
    ld hl,_RAM_DE14_
    ld de,$7B48
    ld bc,$050C
    jp OutputTilemapBoxWipePaging

.orga $38c0
.section "Show yes/no menu" overwrite
ShowMenuYesNo:         ; $38c0
    ld hl,OldTileMap5x5
    TileMapAddressDE 21,13
    ld bc,$050a        ; 5x5 (50 bytes)
    call InputTilemapRect

    ld hl,MenuYesNo
    call OutputTilemapBoxWipePaging

    TileMapAddressHL 21,14
    ld (CursorTileMapAddress),hl
    ld a,1
    ld (CursorMax),a
    jp WaitForMenuSelection ; and ret, return selection
.ends
; followed by
.orga $38e0
.section "Hide yes/no menu" overwrite
HideMenuYesNo:
    ld hl,OldTileMap5x5
    TileMapAddressDE 21,13
    ld bc,$050a        ; 5x5
    jp OutputTilemapBoxWipePaging ; and ret - could do non-paging version?
.ends
.orga $38ec

_LABEL_38EC_:
    add a,a
    add a,a
    add a,a
    add a,a
    ld hl,CharacterStatsAlis
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    push hl
    pop ix
    ld hl,_RAM_DC04_
    ld de,$7920
    ld bc,$0E18
    call InputTilemapRect
    ld hl,_DATA_6FCC3_
    ld bc,$0118
    call OutputTilemapBoxWipePaging
    ld hl,_DATA_3982_
    ld a,(ix+Character.LV)
    call Output4CharsPlusStatWide
    ld hl,_DATA_3992_
    ld c,(ix+Character.EP)
    ld b,(ix+Character.EP+1)
    call _LABEL_319E_
    ld hl,_DATA_6FCDB_
    ld bc,$0118
    call OutputTilemapBoxWipePaging
    ld hl,_DATA_399E_
    ld a,(ix+Character.Attack)
    call Output4CharsPlusStatWide
    ld hl,_DATA_6FCDB_
    ld bc,$0118
    call OutputTilemapBoxWipePaging
    ld hl,_DATA_39AE_
    ld a,(ix+Character.Defence)
    call Output4CharsPlusStatWide
    ld hl,_DATA_6FCDB_
    ld bc,$0118
    call OutputTilemapBoxWipePaging
    ld hl,_DATA_39BE_
    ld a,(ix+Character.MaxHP)
    call Output4CharsPlusStatWide
    ld hl,_DATA_6FCDB_
    ld bc,$0118
    call OutputTilemapBoxWipePaging
    ld hl,_DATA_39CE_
    ld a,(ix+Character.MaxMP)
    call Output4CharsPlusStatWide
    ld hl,_DATA_6FCF3_
    ld bc,$0118
    call OutputTilemapBoxWipePaging
    call _LABEL_36D9_
    ld hl,_DATA_6FD0B_
    ld bc,$0118
    jp OutputTilemapBoxWipePaging

; Data from 3982 to 3991 (16 bytes)
_DATA_3982_:
.db $F3 $11 $FA $11 $FB $11 $C0 $10 $C0 $10 $C0 $10 $C0 $10 $C0 $10

; Data from 3992 to 399D (12 bytes)
_DATA_3992_:
.db $F3 $11 $F7 $11 $F5 $11 $C0 $10 $C0 $10 $C0 $10

; Data from 399E to 39AD (16 bytes)
_DATA_399E_:
.db $F3 $11 $D4 $10 $CD $10 $D3 $10 $D1 $10 $F2 $10 $FC $10 $D2 $10

; Data from 39AE to 39BD (16 bytes)
_DATA_39AE_:
.db $F3 $11 $D6 $10 $FB $10 $E5 $10 $F2 $10 $FC $10 $D2 $10 $C0 $10

; Data from 39BE to 39CD (16 bytes)
_DATA_39BE_:
.db $F3 $11 $D5 $10 $CC $10 $DA $10 $CC $10 $F4 $11 $F5 $11 $C0 $10

; Data from 39CE to 39DD (16 bytes)
_DATA_39CE_:
.db $F3 $11 $D5 $10 $CC $10 $DA $10 $CC $10 $F6 $11 $F5 $11 $C0 $10

_LABEL_39DE_:
    ld hl,_RAM_DC04_
    ld de,$7920
    ld bc,$0E18
    jp OutputTilemapBoxWipePaging

_LABEL_39EA_ShopMesetaWindowCopy:
    ld hl,OldTileMapMenu
    ld de,$780C
    ld bc,$0820
    jp InputTilemapRect

_LABEL_39F6_Shop:
    ; Draw shop items
    ; Top border
    ld hl,_DATA_6FD23_TopBorder16
    ld de,$780C
    ld bc,$0120
    call OutputTilemapBoxWipePaging
    ld hl,Frame2Paging
    ld (hl),:_DATA_F717_ShopItems
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
    ld bc,_DATA_F717_ShopItems - 10
    add hl,bc
    ; First byte is menu size
    ld a,(hl)
    ld (CursorMax),a
    inc hl
    push hl
      ld b,$03
-:    push bc
        ; Draw first row of two-line items (i.e. accent markers)
        ld c,$00
        push hl
          call + ; Draw 
        pop hl
        ; Draw second line (characters and price)
        ld c,$01
        push hl
          call +
        pop hl
        inc hl
        inc hl
        inc hl
      pop bc
      djnz -
      ld hl,_DATA_6FD43_ ; Bottom border
      ld bc,$0120
      call OutputTilemapBoxWipePaging
      ld hl,$788C
      ld (CursorTileMapAddress),hl
      call WaitForMenuSelection
      ld hl,Frame2Paging
      ld (hl),$03
    pop hl
    ; compute hl = hl + a * 3 = pointer to data for the selected item
    ld b,a
    add a,a
    add a,b
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ret

+:  di
    push de
    push hl
      rst SetVRAMAddressToDE
      ; Look up item text
      ld a,:ItemTextTable
      ld (Frame2Paging),a
      ld a,(hl)
      or a
      jr nz,+
      ld c,$00 ; c is set to 0 if the first byte is zero = no items
+:    ld l,a
      ld h,$00
      add hl,hl
      add hl,hl
      add hl,hl
      ld de,ItemTextTable
      add hl,de
      push af
      pop af
      ; Draw left border
      ld a,$F3
      out (VDPData),a
      push af
      pop af
      ld a,$11
      out (VDPData),a
      ; Unnecessary?
      ld a,:ItemTextTable
      ld (Frame2Paging),a
      ld b,$08 ; Length
-:    ld a,(hl)
      add a,a
      add a,c
      ld de,TileNumberLookup ; Look up tilemap data for character
      add a,e
      ld e,a
      adc a,d
      sub e
      ld d,a
      ld a,(de)
      out (VDPData),a ; Write to tilemap
      push af
      pop af
      ld a,$10 ; MSB is always $10
      out (VDPData),a
      inc hl
      djnz - ; Loop over 8 chars
      
      ; check c to determine the space to leave for numbers?
      ld a,c
      or a
      ld b,$01 ; 1 or 6?
      jr nz,+
      ld b,$06
+:
-:    push af
      pop af
      ld a,$C0
      out (VDPData),a
      push af
      pop af
      ld a,$10
      out (VDPData),a
      djnz - ; Draw some spaces
      ld hl,Frame2Paging
      ld (hl),$03
    pop hl
    inc hl
    ; Read price to hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ; then 
    ld a,c
    or a
    jp nz,_LABEL_36F2_DrawLargeNumberAndRightBorder
    jp _LABEL_373D_DrawRightBorder

_LABEL_3AC3_:
    ld hl,OldTileMapMenu
    ld de,$780C
    ld bc,$0820
    jp OutputTilemapBoxWipePaging

_LABEL_3ACF_:
    ld hl,OldTileMapEnemyName10x4
    ld de,$786E
    ld bc,$0C12
    call InputTilemapRect

.orga $3adb
.section "Show savegame list and get selection" overwrite
GetSavegameSelection:  ; $3adb
    ld a,SRAMPagingOn  ; Draw menu from tilemap in SRAM
    ld (SRAMPaging),a
    ld hl,SaveMenuTilemap
    TileMapAddressDE 23,1
    ld bc,$0c12        ; 6x12
    call OutputTilemapBoxWipe
    ld a,SRAMPagingOff
    ld (SRAMPaging),a

    TileMapAddressHL 23,3 ; Show cursor and get selection
    ld (CursorTileMapAddress),hl
    ld a,4
    ld (CursorMax),a
    call WaitForMenuSelection

    ld l,a             ; Put number (1-based) in NumberToShowInText
    inc l
    ld h,$00
    ld (NumberToShowInText),hl
    ret                ; returns 0-based in a, button pressed from WaitForMenuSelection in c
.ends
.orga $3b07

_LABEL_3B07_:
    ld hl,OldTileMapEnemyName10x4
    ld de,$786E
    ld bc,$0C12
    jp OutputTilemapBoxWipePaging

_LABEL_3B13_ShopMesetaWindowDraw:
    push bc
      ld hl,_RAM_D700_
      ld de,$782C
      ld bc,$0314
      call InputTilemapRect
    pop bc
_LABEL_3B21_:
    push bc
      ld hl,Menu10Top
      ld de,$782C
      ld bc,$0114
      call OutputTilemapBoxWipePaging
      call _LABEL_36E1_
      ld hl,Menu10Bottom
      ld bc,$0114
      call OutputTilemapBoxWipePaging
    pop bc
    ret

_LABEL_3B3C_:
    push bc
      ld hl,_RAM_D700_
      ld de,$782C
      ld bc,$0314
      call OutputTilemapBoxWipePaging
    pop bc
    ret

_LABEL_3B4B_:
    ld hl,_RAM_DE14_
    ld de,$7AAA
    ld bc,$080A
    call InputTilemapRect
    ld a,$03
    ld (Frame2Paging),a
    ld hl,_DATA_FEB2_
    call OutputTilemapBoxWipe
    ld hl,$7B2A
    ld (CursorTileMapAddress),hl
    ld a,$02
    ld (CursorMax),a
    call WaitForMenuSelection
    push af
    push bc
      ld hl,_RAM_DE14_
      ld de,$7AAA
      ld bc,$080A
      call OutputTilemapBoxWipePaging
    pop bc
    pop af
    ret

.orga $3b81
.section "Output box of tilemap (vertical wipe) (with paging handler)" overwrite
OutputTilemapBoxWipePaging: ; $3b81
; Sets page for MenuTilemaps, calls OutputTilemapBoxWipe, sets page for DialogueText
    ld a,:MenuTilemaps
    ld (Frame2Paging),a
    call OutputTilemapBoxWipe
    ld a,:DialogueText
    ld (Frame2Paging),a
    ret
.ends
; followed by
.orga $3b8f
.section "Output box of tilemap (vertical wipe)" overwrite
OutputTilemapBoxWipe:      ; $3b8f
; Outputs c/2 x b block of tilemap data from hl to de
; with 1 frame delay between rows
--: push bc
      di
        rst SetVRAMAddressToDE
        ld b,c
        ld c,VDPData
-:      outi           ; output c bytes
        jp nz,-
        ex de,hl
        ld bc,32*2
        add hl,bc
        ex de,hl       ; add 32*2 = 1 row to de
      ei
      ld a,$0a       ; VBlankFunction_Enemy (why?)
      call ExecuteFunctionIndexAInNextVBlank
    pop bc
    djnz --
    ret
.ends
; followed by
.orga $3baa
.section "Output rect of tilemap data" overwrite
; output c bytes from hl to VRAM address de
; then move down 1 row
; repeat b times
; so:
; output (c/2) x b rectangle from hl with top-left de
; hl must be in page $1b (TilemapBox)
OutputTilemapRect:     ; $3baa
    ld a,:MenuTilemaps
    ld (Frame2Paging),a
    di
--:   push bc
        rst SetVRAMAddressToDE
        ld b,c
        ld c,VDPData
-:      outi           ; output
        jp nz,-
        ex de,hl
        ld bc,$40
        add hl,bc
        ex de,hl       ; add $40 = 1 row to de
      pop bc
      djnz --
    ei
    ld a,:DialogueText
    ld (Frame2Paging),a
    ret
.ends
; followed by
.orga $3bca
.section "Input rect of tilemap data" overwrite
; INPUT c bytes TO hl FROM VRAM address de
; then move down 1 row
; repeat b times
; so:
; INPUT (c/2) x b rectangle with top-left de TO hl
InputTilemapRect:
    di
    push bc
    push de
      res 6,d        ; unset VRAM write bit in de
--:   push bc
        rst SetVRAMAddressToDE ; (for reading)
        ld b,c
        ld c,VDPData
-:      ini        ; input from VRAM
        push af    ; delay
        pop af
        jp nz,-
        ex de,hl
        ld bc,$0040
        add hl,bc
        ex de,hl   ; add $40 = 1 row to de
      pop bc
      djnz --
    pop de
    pop bc
    ei
    ret
.ends
; followed by
.orga $3be8
.section "Default SRAM data for initialisation" overwrite
; Data from 3BE8 to 3CBF (216 bytes)
DefaultSRAMData: ; Default data for SRAM
; TODO: to stringmap
.dw $11f1,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$13f1
.dw $11f3,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c2,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c3,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c4,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c5,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10c6,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $15f1,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$17f1
.ends
.orga $3cc0


_LABEL_3CC0_:
    ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(_RAM_C29D_InBattle)
    or a
    jp nz,_LABEL_3D3E_
    ld a,(_RAM_C2DC_)
    call LoadDialogueSprite
    ld a,(SceneType)
    sub $10
    jr nc,+
    xor a
+:  and $0F
    ld hl,_DATA_3D4E_
    call FunctionLookup
_LABEL_3CE9_:
    ld a,(SceneType)
    sub $0F
    jr nc,+
    xor a
+:  and $0F
    ld l,a
    ld h,$00
    ld de,$3E49
    add hl,de
    ld a,(hl)
    or a
    jr z,+
    ld a,SFX_d8
    ld (NewMusic),a
+:  xor a
    ld (_RAM_C29D_InBattle),a
    ld (SceneType),a
    ld (_RAM_C2D5_),a
    ld hl,$0000
    ld (RoomIndex),hl
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$00FF
    ld (hl),$00
    ldir
    ld a,(FunctionLookupIndex)
    cp $0D
    ret nz
    ld a,(_RAM_C2E9_)
    bit 7,a
    jr z,+
    ld a,$04
    ld (FunctionLookupIndex),a
    ret

+:  or a
    ld a,$08
    jr z,+
    ld a,$0E
+:  ld (FunctionLookupIndex),a
    ret

_LABEL_3D3E_:
    call LoadEnemy
    call _LABEL_116B_
    ld a,(CharacterSpriteAttributes)
    or a
    call nz,_LABEL_1D3D_
    jp _LABEL_3CE9_

; Jump Table from 3D4E to 3D75 (20 entries,indexed by SceneType)
_DATA_3D4E_:
.dw DoRoomScript DoRoomScript _LABEL_2AE9_ _LABEL_2AE9_ _LABEL_2BE1_ _LABEL_2BE1_ _LABEL_2D1C_ _LABEL_2D1C_
.dw _LABEL_2DEB_ _LABEL_2DEB_ _LABEL_2DF4_ _LABEL_2DF4_ DoRoomScript DoRoomScript DoRoomScript DoRoomScript
.dw DoRoomScript DoRoomScript DoRoomScript DoRoomScript

_LABEL_3D76_:
    ld a,SFX_d6
    ld (NewMusic),a
    call FadeOutFullPalette
    ld a,(_RAM_C308_)
    or a
    jr nz,+
    ld a,(SceneType)
    cp $05
    jr nz,_LABEL_3DD1_
    ld a,$04
    ld (SceneType),a
    jr _LABEL_3DD1_

+:  cp $01
    jr nz,+
    ld a,(SceneType)
    cp $01
    jr nz,_LABEL_3DD1_
    ld a,$05
    ld (SceneType),a
    jr _LABEL_3DD1_

+:  cp $07
    jr nz,+
    ld a,(SceneType)
    cp $01
    jr nz,_LABEL_3DD1_
    ld a,$05
    ld (SceneType),a
    jr _LABEL_3DD1_

+:  cp $08
    jr nz,+
    ld a,$06
    ld (SceneType),a
    jr _LABEL_3DD1_

+:  cp $0A
    jr nz,_LABEL_3DD1_
    ld a,(SceneType)
    cp $09
    jr nz,_LABEL_3DD1_
    ld a,$08
    ld (SceneType),a
_LABEL_3DD1_:
    ld a,(SceneType)
    or a
    jr nz,+
    inc a
    ld (SceneType),a
+:  call LoadSceneData
    ld hl,Frame2Paging
    ld (hl),$10
    ld hl,TilesFont
    ld de,$5800
    call LoadTiles4BitRLE
    ld hl,TilesExtraFont
    ld de,$7E00
    call LoadTiles4BitRLE
    xor a
    ld (VScroll),a
    ld (HScroll),a
    ld (CharacterSpriteAttributes),a
    ld (_RAM_C2E9_),a
    dec a
    ld (SceneAnimEnabled),a
    ld hl,$0000
    ld (PaletteMoveDelay),hl
    ld hl,$FF00
    ld (AnimDelayCounter),hl
    di
      call EnemySceneTileAnimation
    ei
    ld a,(SceneType)
    sub $0F
    jr nc,+
    xor a
+:  and $0F
    ld l,a
    ld h,$00
    ld de,$3E49
    add hl,de
    ld a,(hl)
    or a
    jr z,+
    ld (NewMusic),a
+:  ld hl,FunctionLookupIndex
    inc (hl)
    di
      ld de,$8006
      rst SetVDPRegisterDToE
    ei
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    jp ClearSpriteTableAndFadeInWholePalette

.orga $3e41
.section "Sprite palette(s) (?)" overwrite
; Data from 3E41 to 3E48 (8 bytes)
SpritePaletteStart:
.db $00,$00,$3F,$30,$38,$03,$0B,$0F
.ends
.orga $3e49

; Data from 3E49 to 3E49 (1 bytes)
_DATA_3E49_:
.db $00

; Data from 3E4A to 3E59 (16 bytes)
_DATA_3E4A_:
.db $00 $00 $00 $00 $8D $8D $8E $8E $8E $8E $8E $8E $00 $00 $00 $00

_LABEL_3E5A_:
    cp $20
    jr nc,+
    add a,a
    add a,a
    add a,a
    ld l,a
    ld h,$00
    ld de,_SceneData - 3
    add hl,de
    jp _LABEL_3EBA_

.orga $3e6b
.section "Scene data loader" overwrite
LoadSceneData:         ; $3e6b
    ld a,(SceneType)
    cp 32
    jr c,_LoadSceneData ; if SceneType<32 then load data

+:  ld hl,TileMapData
    ld de,TileMapData+2
    ld bc,$5fe
    ld (hl),$00
    inc hl
    ld (hl),$08
    dec hl
    ldir               ; fill 24 rows of TileMapData with $0800 = tile 0, sprite palette

    xor a
    ld (TextBox20x6Open),a ; zero TextBox20x6Open
    ret

_LoadSceneData:        ; $3e88
    add a,a
    add a,a
    add a,a            ; multiply SceneType by 8
    ld l,a
    ld h,$00
    ld de,_SceneData-8 ; -8 because SceneType>0
    add hl,de
    ld a,(hl)          ; +0: page
    ld (Frame2Paging),a
    inc hl
    ld a,(hl)          ; +1-2: palette offset
    inc hl
    push hl
      ld h,(hl)
      ld l,a         ; hl = offset
      ld de,TargetPalette
      ld bc,16
      ldir           ; load palette
      ld hl,SpritePaletteStart
      ld c,8         ; and sprite palette
      ldir
    pop hl
    inc hl
    ld a,(hl)          ; +3-4: tiles
    inc hl
    push hl
      ld h,(hl)
      ld l,a         ; hl = offset
      TileAddressDE 0
      call LoadTiles4BitRLE
    pop hl
    inc hl
_LABEL_3EBA_:
    xor a
    ld (TextBox20x6Open),a ; zero TextBox20x6Open
    ld a,(hl)          ; +5: page
    ld (Frame2Paging),a
    inc hl
    ld a,(hl)          ; +6-7: tilemap
    inc hl
    ld h,(hl)
    ld l,a
    jp DecompressToTileMapData ; and ret

; Pointer Table from 3ECA to 3ECB (1 entries,indexed by SceneType)
_SceneData:

.macro SceneDataStruct ; structure holding scene data (palette,tiles and tilemap offsets)
.db :Palette\1
.dw Palette\1,Tiles\2
.db :Tilemap\3
.dw Tilemap\3
.endm

;                Palette            Tiles               Tilemap
 SceneDataStruct PalmaOpen         ,PalmaAndDezorisOpen,PalmaOpen         ; 01 Palma enemy (open)
 SceneDataStruct PalmaForest       ,PalmaForest        ,PalmaForest       ; 02 Palma enemy (forest)
 SceneDataStruct PalmaSea          ,PalmaSea           ,PalmaSea          ; 03 Palma enemy (sea)
 SceneDataStruct PalmaSea          ,PalmaSea           ,PalmaCoast        ; 04 Palma enemy (coast)
 SceneDataStruct MotabiaOpen       ,MotabiaOpen        ,MotabiaOpen       ; 05 Motabia enemy
 SceneDataStruct DezorisOpen       ,PalmaAndDezorisOpen,DezorisOpen       ; 06 Dezoris enemy
 SceneDataStruct PalmaOpen         ,PalmaAndDezorisOpen,PalmaLavapit      ; 07 Palma enemy (lava pit)
 SceneDataStruct PalmaTown         ,PalmaTown          ,PalmaTown         ; 08 Palma town
 SceneDataStruct PalmaVillage      ,PalmaVillage       ,PalmaVillage      ; 09 Palma village
 SceneDataStruct Spaceport         ,Spaceport          ,Spaceport         ; 0a Spaceport
 SceneDataStruct DeadTrees         ,DeadTrees          ,DeadTrees         ; 0b Dead trees (?)
 SceneDataStruct DezorisForest     ,PalmaForest        ,PalmaForest       ; 0c Dezoris forest
 SceneDataStruct AirCastle         ,AirCastle          ,AirCastle         ; 0d
 SceneDataStruct GoldDragon        ,GoldDragon         ,GoldDragon        ; 0e
; The original rom is a bit odd here... the palette is in an unpaged area but a page number
; must be given as part of the data structure... so they put $16. My macro puts 0,so I have
; to do the data structure explicitly; the macro works 100% though.
; SceneDataStruct AirCastleFull     ,AirCastle          ,AirCastle         ; 0f
.db $16
.dw PaletteAirCastleFull,TilesAirCastle
.db :TilemapAirCastle
.dw TilemapAirCastle
 SceneDataStruct BuildingEmpty     ,Building           ,BuildingEmpty     ; 10
 SceneDataStruct BuildingWindows   ,Building           ,BuildingWindows   ; 11
 SceneDataStruct BuildingHospital1 ,Building           ,BuildingHospital1 ; 12
 SceneDataStruct BuildingHospital2 ,Building           ,BuildingHospital2 ; 13
 SceneDataStruct BuildingChurch1   ,Building           ,BuildingChurch1   ; 14
 SceneDataStruct BuildingChurch2   ,Building           ,BuildingChurch2   ; 15
 SceneDataStruct BuildingArmoury1  ,Building           ,BuildingArmoury1  ; 16
 SceneDataStruct BuildingArmoury2  ,Building           ,BuildingArmoury2  ; 17
 SceneDataStruct BuildingShop1     ,Building           ,BuildingShop1     ; 18
 SceneDataStruct BuildingShop2     ,Building           ,BuildingShop2     ; 19
 SceneDataStruct BuildingShop3     ,Building           ,BuildingShop3     ; 1a
 SceneDataStruct BuildingShop4     ,Building           ,BuildingShop4     ; 1b
 SceneDataStruct BuildingDestroyed ,Building           ,BuildingDestroyed ; 1c
 SceneDataStruct Mansion           ,Mansion            ,Mansion           ; 1d
 SceneDataStruct LassicRoom        ,LassicRoom         ,LassicRoom        ; 1e
 SceneDataStruct DarkForce         ,DarkForce          ,DarkForce         ; 1f
.ends
; followed by
.orga $3fc2
.section "Sky castle full palette" overwrite
PaletteAirCastleFull:  ; $3fc2
.db $30,$00,$3f,$0b,$06,$1a,$2f,$2a,$08,$15,$15,$0b,$06,$1a,$2f,$28
.ends
.orga $3fd2
.db $1A $2F $28

.db $A6 $8B $17 $EF $AA $6F $AB $17 $8E $8F $17

.orga $3fdd
.section "Name entry screens (FunctionLookupTable $10, $11)" overwrite
HandleNameEntry: ; 3fdd
    ld a,(PauseFlag)             ; 003FDD 3A 12 C2
    or a                         ; 003FE0 B7
    call nz,DoPause              ; 003FE1 C4 1D 01

    ld ix,NameEntryCursorX       ; 003FE4 DD 21 84 C7
    ld a,$08                     ; 003FE8 3E 08         ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank ; 003FEA CD 56 00
    call _DrawCursorSprites      ; 003FED CD 26 42
    ld a,(Controls)              ; 003FF0 3A 05 C2

    and P11 | P12                ; 003FF3 E6 30
    jp z,_NameEntryNoButtonPressed ;03FF5 CA C8 40      ; not a button

    and P11                      ; 003FF8 E6 10         ; which button?
    jp nz,_Button1Pressed        ; 003FFA C2 3E 40

_Button2Pressed:
    ld a,(NameEntryCurrentlyPointed);3FFD 3A 88 C7      ; what is pointed?
    cp $4e                       ; 004000 FE 4E         ; = Next
    jr z,_MoveToNextChar         ; 004002 28 12
    jr nc,_ControlChar           ; 004004 30 22         ; some other control char

    ld de,(NameEntryCharIndex)   ; 004006 ED 5B 81 C7   ; else,it's a char. Get the address to write to (this opcode could have been ld e,(NameEntryCharIndex))
    ld d,$c7                     ; 00400A 16 C7
    ld (de),a                    ; 00400C 12
    call _GetTileMapDataAddressForCharAInHL ; 00400D CD 78 42
    ld a,(de)                    ; 004010 1A            ; retrieve value since the function killed it
    di                           ; 004011 F3
    call _WriteCharAToTileMapAndTileMapDataAtHL ; 004012 CD B5 42
    ei                           ; 004015 FB

_MoveToNextChar:
+:  ld a,(NameEntryMode)         ; 004016 3A 80 C7
    ld c,$37                     ; 004019 0E 37         ; max = $37 for password
    rra                          ; 00401B 1F
    jr c,+                       ; 00401C 38 02
    ld c,$25                     ; 00401E 0E 25         ; max = $25 nor name entry
+:  ld hl,NameEntryCharIndex
    ld a,(hl)                    ; 004023 7E
    cp c                         ; 004024 B9
    ret z                        ; 004025 C8
    inc (hl)                     ; 004026 34            ; increment index if < max
    ret                          ; 004027 C9

_ControlChar: ; 4028
    cp $50                       ; 004028 FE 50         ; = OK
    jr z,_OKSelected             ; 00402A 28 27

_PrevSelected:
    ld a,(NameEntryMode)         ; 00402C 3A 80 C7      ; name entry or password?
    ld c,$00                     ; 00402F 0E 00         ; min = $00 for password
    rra                          ; 004031 1F
    jr c,+                       ; 004032 38 02
    ld c,$21                     ; 004034 0E 21         ; min = $21 for name entry
+:  ld hl,NameEntryCharIndex     ; 004036 21 81 C7      ; decrement NameEntryCharIndex if > min
    ld a,(hl)                    ; 004039 7E
    cp c                         ; 00403A B9
    ret z                        ; 00403B C8
    dec (hl)                     ; 00403C 35
    ret                          ; 00403D C9

_Button1Pressed: ; 403e
; delete current char and move cursor back
    ld de,(NameEntryCharIndex)   ; 00403E ED 5B 81 C7   ; get pointed char
    ld d,$c7                     ; 004042 16 C7
    ld a,$00                     ; 004044 3E 00
    ld (de),a                    ; 004046 12            ; zero it
    call _GetTileMapDataAddressForCharAInHL ; 004047 CD 78 42
    ld a,(de)                    ; 00404A 1A
    di                           ; 00404B F3
      call _WriteCharAToTileMapAndTileMapDataAtHL ; 00404C CD B5 42
    ei                           ; 00404F FB
    jp _PrevSelected             ; 004050 C3 2C 40

_OKSelected:
    ld a,(NameEntryMode)         ; 004053 3A 80 C7
    rra                          ; 004056 1F
    jr nc,_OKSelected_NameEntry  ; 004057 30 22

_OKSelected_Password:            ; ####################### this section is unused
    ld de,_PasswordLookupData    ; 004059 11 96 43   ; data
    exx                          ; 00405C D9
    ld b,$38                     ; 00405D 06 38
    ld hl,$c700
    ld de,$c740                  ; 004062 11 40 C7
-:  ld a,(hl)                    ; 004065 7E         ; read byte
    or a                         ; 004066 B7
    jr z,+                       ; 004067 28 07

    exx                          ; 004069 D9         ; if non-zero,look up corresponding byte in the table
    ld l,a                       ; 00406A 6F
    ld h,$00                     ; 00406B 26 00
    add hl,de                    ; 00406D 19
    ld a,(hl)                    ; 00406E 7E
    exx                          ; 00406F D9

+:  ld (de),a                    ; 004070 12         ; write byte to de
    inc hl                       ; 004071 23
    inc de                       ; 004072 13
    djnz -                       ; 004073 10 F0      ; repeat for $38 bytes

    ld hl,FunctionLookupIndex
    ld (hl),$0c                  ; 004078 36 0C      ; $3d76
    ret                          ; 00407A C9

_OKSelected_NameEntry:
    ld hl,$c721                  ; 00407B 21 21 C7   ; copy entered name
    ld de,$c778                  ; 00407E 11 78 C7   ; (why???)
    ld bc,$0005                  ; 004081 01 05 00
    ldir                         ; 004084 ED B0

    ld hl,(NumberToShowInText)   ; 004086 2A C5 C2   ; still contains the slot number (1-5)
    add hl,hl                    ; 004089 29
    ld de,_SaveSlotNameTileAddresses-2 ; 00408A 11 BC 40   ; because it's a 1-based index
    add hl,de                    ; 00408D 19
    ld e,(hl)                    ; 00408E 5E
    inc hl                       ; 00408F 23
    ld d,(hl)                    ; 004090 56         ; de = slot address

    ld hl,$d19a                  ; 004091 21 9A D1   ; TileMapData location of (13,6) (top row of name)
    ld bc,$000a                  ; 004094 01 0A 00   ; 10 bytes

    ld a,SRAMPagingOn            ; 004097 3E 08
    ld (SRAMPaging),a            ; 004099 32 FC FF   ; page in SRAM
    ldir                         ; 00409C ED B0      ; copy tiles to SRAM name section

    ld c,$08                     ; 00409E 0E 08      ; move dest 8 bytes on
    ex de,hl                     ; 0040A0 EB
    add hl,bc                    ; 0040A1 09
    ex de,hl                     ; 0040A2 EB
    ld c,$36                     ; 0040A3 0E 36      ; move src 54 bytes on (bottom row of name)
    add hl,bc                    ; 0040A5 09
    ld c,$0a                     ; 0040A6 0E 0A      ; copy another 10 bytes
    ldir                         ; 0040A8 ED B0

    ld a,SRAMPagingOff           ; 0040AA 3E 80      ; page out SRAM
    ld (SRAMPaging),a            ; 0040AC 32 FC FF

    ld a,(_RAM_c316_)                 ; 0040AF 3A 16 C3   ; ???
    cp $0b                       ; 0040B2 FE 0B
    ld a,$0a                     ; 0040B4 3E 0A      ; $10d9
    jr z,+                       ; 0040B6 28 02
    ld a,$0c                     ; 0040B8 3E 0C      ; $3d76
+:  ld (FunctionLookupIndex),a   ; 0040BA 32 02 C2   ; continue on to there
    ret                          ; 0040BD C9

_SaveSlotNameTileAddresses: ; $40be
.dw $8118 $813c $8160 $8184 $81a8

_NameEntryNoButtonPressed: ; 40c8
    ld a,(Controls)              ; 0040C8 3A 05 C2
    rra                          ; 0040CB 1F
    jr c,_UpHeld            ; 0040CC 38 3E
    rra                          ; 0040CE 1F
    jr c,_DownHeld          ; 0040CF 38 52
    rra                          ; 0040D1 1F
    jr c,_LeftHeld          ; 0040D2 38 66
    rra                          ; 0040D4 1F
    jr c,_RightHeld         ; 0040D5 38 1E
    ld a,(ControlsNew)           ; 0040D7 3A 04 C2
    rra                          ; 0040DA 1F
    jr c,_UpNew                  ; 0040DB 38 1F
    rra                          ; 0040DD 1F
    jr c,_DownNew                ; 0040DE 38 33
    rra                          ; 0040E0 1F
    jr c,_LeftNew                ; 0040E1 38 47
    rra                          ; 0040E3 1F
    ret nc                       ; 0040E4 D0

_RightNew:
    call _DecrementKeyRepeatCounter ;40E5 CD 7B 41
    ret nz                       ; 0040E8 C0
-:  ld bc,($c8<<8)|(+8)                  ; 0040E9 01 08 C8      ; stop/delta for cursor sprite coordinate
    ld de,+2                     ; 0040EC 11 02 00      ; delta for tilemap address
    ld iy,NameEntryCursorX       ; 0040EF FD 21 84 C7   ; which cursor sprite coordinate to change
    jr _NameEntryDirectionPressed
_RightHeld:
    ld a,24                      ; 0040F5 3E 18
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 0040FA 18 ED

_UpNew:
    call _DecrementKeyRepeatCounter ;40FC CD 7B 41
    ret nz                       ; 0040FF C0
-:  ld bc,($68<<8)|(-16 & $ff)                 ; 004100 01 F0 68
    ld de,-$80                   ; 004103 11 80 FF
    ld iy,NameEntryCursorY       ; 004106 FD 21 85 C7
    jr _NameEntryDirectionPressed
_UpHeld:
    ld a,24
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 004111 18 ED

_DownNew:
    call _DecrementKeyRepeatCounter ;4113 CD 7B 41
    ret nz                       ; 004116 C0
-:  ld bc,($b8<<8)|(+16)                 ; 004117 01 10 B8
    ld de,+$80                   ; 00411A 11 80 00
    ld iy,NameEntryCursorY       ; 00411D FD 21 85 C7
    jr _NameEntryDirectionPressed
_DownHeld:
    ld a,24
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 004128 18 ED

_LeftNew:
    call _DecrementKeyRepeatCounter ;412A CD 7B 41
    ret nz                       ; 00412D C0
-:  ld bc,($28<<8)|(-8 & $ff)                  ; 00412E 01 F8 28
    ld de,-2                     ; 004131 11 FE FF
    ld iy,NameEntryCursorX       ; 004134 FD 21 84 C7
    jr _NameEntryDirectionPressed
_LeftHeld:
    ld a,24
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 00413F 18 ED


    ; b = "stop" value
    ; c = delta
    ; de = delta VRAM address
    ; iy = address of sprite coordinate to modify
_NameEntryDirectionPressed:
    ld a,(iy+$00)                ; 004141 FD 7E 00
    cp b                         ; 004144 B8         ; compare coordinate to "stop" value
    ret z                        ; 004145 C8         ; do nothing if equal
    add a,c                      ; 004146 81
    ld (iy+$00),a                ; 004147 FD 77 00   ; else add c

    ld hl,(NameEntryCursorTileMapDataAddress)        ; add delta to value array pointer
    add hl,de                    ; 00414D 19
    ld (NameEntryCursorTileMapDataAddress),hl

    ld a,(hl)                    ; 004151 7E
    or a                         ; 004152 B7
    jr z,_NameEntryDirectionPressed         ; repeat if a zero was pointed to -> cursor will snap to next valid position

    cp (ix+$04)                  ; 004155 DD BE 04   ; or if it's equal to the existing value -> cursor will skip past control code selections
    jr z,_NameEntryDirectionPressed

    ld (NameEntryCurrentlyPointed),a;415A 32 88 C7   ; save value pointed

    cp $4e                       ; 00415D FE 4E      ; check if it was a control char,in which case snap to its left char
    ret c                        ; 00415F D8


    ld c,$88                     ; 004160 0E 88      ; values for jump to Next ($4e)
    ld hl,$d5a2
    jr z,+                       ; 004165 28 0C
    cp $4f                       ; 004167 FE 4F
    ld l,$aa                     ; 004169 2E AA      ; values for jump to Prev ($4f)
    ld c,$a8                     ; 00416B 0E A8
    jr z,+                       ; 00416D 28 04
    ld c,$c8                     ; 00416F 0E C8      ; default: jump to Save
    ld l,$b2                     ; 004171 2E B2

+:  ld (NameEntryCursorTileMapDataAddress),hl
    ld a,c                       ; 004176 79
    ld (NameEntryCursorX),a      ; 004177 32 84 C7
    ret                          ; 00417A C9


; decrement keypress repeat counter,set to 5 if zero
_DecrementKeyRepeatCounter: ; 417b
    ld hl,$c789
    dec (hl)                     ; 00417E 35
    ret nz                       ; 00417F C0
    ld (hl),$05                  ; 004180 36 05
    ret                          ; 004182 C9

LoadNameEntryScreen: ; $4183
    call FadeOutFullPalette      ; 004183 CD A8 7D   ; go to name entry screen

    TileMapAddressDE 0,0         ; 004186 11 00 78   ; clear name table
    ld bc,$0300                  ; 004189 01 00 03
    ld hl,$0000
    di                           ; 00418F F3
      call FillVRAMWithHL        ; 004190 CD FB 03
    ei                           ; 004193 FB

    ld hl,FunctionLookupIndex    ; 004194 21 02 C2   ; increment FunctionLookupIndex do it'll do the right thing after this function finishes
    inc (hl)                     ; 004197 34

    ld hl,NameEntryData          ; 004198 21 81 C7   ; blank NameEntryData block
    ld (hl),$00                  ; 00419B 36 00
    ld de,NameEntryData+1        ; 00419D 11 82 C7
    ld bc,$007e                  ; 0041A0 01 7E 00
    ldir                         ; 0041A3 ED B0

    ld hl,TileMapData            ; 0041A5 21 00 D0   ; blank TileMapData
    ld de,TileMapData+1          ; 0041A8 11 01 D0
    ld bc,$0600                  ; 0041AB 01 00 06
    ld (hl),$00                  ; 0041AE 36 00
    ldir                         ; 0041B0 ED B0

    call DecompressNameEntryTilemapData ; 0041B2 CD CC 42

    ld hl,$c700                  ; 0041B5 21 00 C7   ; blank $c700-$c738
    ld de,$c701                  ; 0041B8 11 01 C7
    ld bc,$0037                  ; 0041BB 01 37 00
    ld (hl),$00                  ; 0041BE 36 00
    ldir                         ; 0041C0 ED B0

    ld a,$21                     ; 0041C2 3E 21      ; starting point for name entry (see after next opcode)

    ld hl,EnterYourNameRawTilemapData ; 041C4 21 E6 43   ; tilemap data

    ld (NameEntryCharIndex),a    ; 0041C7 32 81 C7

    ld bc,(2<<8)|16                    ; 0041CA 01 10 02   ; ld bc<<8)|$0210
    xor a                        ; 0041CD AF
    ld (TileMapHighByte),a       ; 0041CE 32 10 C2   ; TileMapHighByte = 0
    TileMapAddressDE 8,0         ; 0041D1 11 10 78   ; ld de,$7810
    di                           ; 0041D4 F3
      call OutputTilemapRawBxC   ; 0041D5 CD 0F 04
    ei                           ; 0041D8 FB

    TileMapAddressDE 0,3         ; 0041D9 11 C0 78   ; ld de,$78c0
    ld hl,$d0c0                  ; 0041DC 21 C0 D0   ; offset in TileMapData for (0,3)
    ld bc,$0540                  ; 0041DF 01 40 05   ; amount of data to copy
    di                           ; 0041E2 F3
      call OutputToVRAM          ; 0041E3 CD DE 03
    ei                           ; 0041E6 FB

    call _LoadTileMapDataWithCharValues ; 0041E7 CD 3B 43

    ld hl,_NameEntryPalette      ; 0041EA 21 56 43   ; load wanted palette
    ld de,TargetPalette          ; 0041ED 11 40 C2
    ld bc,32                     ; 0041F0 01 20 00
    ldir                         ; 0041F3 ED B0

    TileAddressDE $100           ; 0041F5 11 00 60   ; ld de,$6000
    ld hl,_NameEntryCursorSprite
    ld bc,32                     ; 0041FB 01 20 00   ; load cursor sprite
    di                           ; 0041FE F3
      call OutputToVRAM          ; 0041FF CD DE 03
    ei                           ; 004202 FB

    ld de,NameEntryCursorX       ; 004203 11 84 C7
    ld hl,_NameEntryCursorInitialValues
    ld bc,_NameEntryCursorInitialValuesEnd-_NameEntryCursorInitialValues ; load cursor initial values
    ldir                         ; 00420C ED B0

    xor a                        ; 00420E AF         ; zero some stuff
    ld (VScroll),a               ; 00420F 32 04 C3
    ld (HScroll),a               ; 004212 32 00 C3
    ld (TextBox20x6Open),a       ; 004215 32 D3 C2

    ld de,$8006                  ; 004218 11 06 80
    di                           ; 00421B F3
    rst SetVRAMAddressToDE           ; 00421C CF
    ei                           ; 00421D FB
    jp ClearSpriteTableAndFadeInWholePalette         ; and ret



_NameEntryCursorInitialValues: ; 4221
.db $28 ; selected char cursor sprite X
.db $68 ; selected char cursor sprite Y
.dw $D30A ; selected char TileMapData address (5,12)
.db $01 ; currently pointed char
_NameEntryCursorInitialValuesEnd:


_DrawCursorSprites: ; 4226
; sets sprites for cursors
    call _GetTileMapDataAddressForCharAInHL          ; get address of editing char tile for "current tile" indicator
    ld de,$3040                  ; 004229 11 40 30   ; $3000 means it'll wipe out the $D000 prefix,$40 is because we want a constant offset of 1 row (the cursor is exactly below the relevant tile)
    add hl,de                    ; 00422C 19         ; add them on and multiply by 4 to get h = row number + 1,l = pixel x coordinate
    add hl,hl                    ; 00422D 29
    add hl,hl                    ; 00422E 29
    ld de,SpriteTable            ; 00422F 11 00 C9
    ld a,h                       ; 004232 7C         ; now a = row number in tilemap,but for a sprite it's a pixel count -> multiply by 8
    add a,a                      ; 004233 87
    add a,a                      ; 004234 87
    add a,a                      ; 004235 87
    ld (de),a                    ; 004236 12         ; set y coordinate of first sprite to that

    ld a,(NameEntryCurrentlyPointed);4237 3A 88 C7
    cp $4e                       ; 00423A FE 4E      ; is it a control char?

    ld a,(NameEntryCursorY)      ; 00423C 3A 85 C7
    inc de                       ; 00423F 13
    ld (de),a                    ; 004240 12         ; set y coordinate for selection cursor
    jr c,+                       ; 004241 38 04      ; and another 2 if it's a control code since they're 3 chars wide
    inc e                        ; 004243 1C
    ld (de),a                    ; 004244 12
    inc e                        ; 004245 1C
    ld (de),a                    ; 004246 12
+:  inc e                        ; 004247 1C
    ld a,208                     ; 004248 3E D0      ; terminate sprites
    ld (de),a                    ; 00424A 12

    ld e,$80                     ; 00424B 1E 80      ; move to x coordinates
    ex de,hl                     ; 00424D EB
    ld a,e                       ; 00424E 7B         ; current char x coordinate
    ld bc,$0300                  ; 00424F 01 00 03   ; b = maximum width of cursor (3),c = sprite number for cursor (0)
    ld (hl),a                    ; 004252 77         ; set current char sprite x
    inc l                        ; 004253 2C
    ld (hl),c                    ; 004254 71         ; set sprite tile
    ld a,(NameEntryCursorX)      ; 004255 3A 84 C7   ; load cursor x
-:  inc l                        ; 004258 2C
    ld (hl),a                    ; 004259 77         ; set sprite x,
    inc l                        ; 00425A 2C
    ld (hl),c                    ; 00425B 71         ; tile number
    sub $08                      ; 00425C D6 08
    djnz -                                           ; repeat for full-width cursor
    ret                          ; 004260 C9


_DrawEntirePassword: ; $4261
; Orphaned code to draw the 56-char password on-screen ###############
    ld hl,NameEntryCharIndex
    ld (hl),$38                  ; 004264 36 38      ; past end of password
    ld d,$c7                     ; 004266 16 C7
-:  dec (hl)                     ; 004268 35         ; so now it's the end of the password
    ret m                        ; 004269 F8         ; quit when we get to offset -1
    ld e,(hl)                    ; 00426A 5E         ; de = current char in TileMapData
    push hl                      ; 00426B E5
      call _GetTileMapDataAddressForCharAInHL ; 00426C CD 78 42
      ld a,(de)                  ; 00426F 1A
      push de                    ; 004270 D5
        call _WriteCharAToTileMapDataAtHL ; 004271 CD 9B 42
      pop de                     ; 004274 D1
    pop hl                       ; 004275 E1
    jr -                         ; 004276 18 F0



_GetTileMapDataAddressForCharAInHL: ; 4278
    ld a,(NameEntryCharIndex)    ; 004278 3A 81 C7   ; current editing char
    ld hl,$d146                  ; 00427B 21 46 D1   ; a < 24 -> hl = $d146 = (3,5)
    sub $18                      ; 00427E D6 18
    jr c,+                       ; 004280 38 0B
    ld l,$c6                     ; 004282 2E C6      ; 25 < a < 48 -> hl = $d1c6 = (3,7)
    sub $18                      ; 004284 D6 18
    jr c,+                       ; 004286 38 05
    ld hl,$d246                  ; 004288 21 46 D2   ; a > 49 -> hl = $d246 = (3,9)
    sub $18                      ; 00428B D6 18
+:  add a,$18                    ; 00428D C6 18      ; a = x position in this row
    ld c,a                       ; 00428F 4F
    add a,a                      ; 004290 87
    add a,l                      ; 004291 85
    ld l,a                       ; 004292 6F         ; hl += a*2,now points to TileMapData address for currently editing char

    ld a,c                       ; 004293 79
    rra                          ; 004294 1F
    rra                          ; 004295 1F         ; a /= 4
    and $06                      ; 004296 E6 06      ; now it'll be 0,2 or 4 for each of the 3 sections of the row
    add a,l                      ; 004298 85         ; add that on -> 1 char gap every 8 chars
    ld l,a                       ; 004299 6F
    ret                          ; 00429A C9

_WriteCharAToTileMapDataAtHL: ; 429b
    push hl                      ; 00429B E5
      ex de,hl                   ; 00429C EB         ; save hl
      ld hl,Frame2Paging         ; 00429D 21 FF FF   ; map in bank 2
      ld (hl),2                  ; 0042A0 36 02
      ld hl,TileNumberLookup     ; 0042A2 21 00 80   ; look up tilemap data for char a
      ld c,a                     ; 0042A5 4F
      ld b,$00                   ; 0042A6 06 00
      add hl,bc                  ; 0042A8 09
      add hl,bc                  ; 0042A9 09
      ld c,(hl)                  ; 0042AA 4E
      inc hl                     ; 0042AB 23
      ld a,(hl)                  ; 0042AC 7E
      ld (de),a                  ; 0042AD 12         ; write lower char to de
      ld hl,-$40
      add hl,de                  ; 0042B1 19         ; write upper char 1 row above
      ld (hl),c                  ; 0042B2 71
    pop hl                       ; 0042B3 E1
    ret                          ; 0042B4 C9

_WriteCharAToTileMapAndTileMapDataAtHL: ; 42b5
    call _WriteCharAToTileMapDataAtHL ; 0042B5 CD 9B 42
    ld b,a                       ; 0042B8 47
    ld a,h                       ; 0042B9 7C         ; convert hl to the corresponding tilemap address
    sub $58                      ; 0042BA D6 58
    ld h,a                       ; 0042BC 67
    ex de,hl                     ; 0042BD EB
    rst SetVRAMAddressToDE           ; 0042BE CF
    ld a,b                       ; 0042BF 78
    out (VDPData),a              ; 0042C0 D3 BE      ; write lower part
    ld hl,-$40
    add hl,de                    ; 0042C5 19
    ex de,hl                     ; 0042C6 EB
    rst SetVRAMAddressToDE           ; 0042C7 CF
    ld a,c                       ; 0042C8 79
    out (VDPData),a              ; 0042C9 D3 BE      ; write upper part
    ret                          ; 0042CB C9

; Decompress data from NameEntryTilemapData to TileMapData(0,6)
DecompressNameEntryTilemapData: ; $42cc
    ld hl,NameEntryTilemapData
    ld de,TileMapData+32*6       ; 0042CF 11 C0 D0   ; location 0,6

--: ld a,(hl)                    ; 0042D2 7E         ; read byte n
    inc hl                       ; 0042D3 23
    or a                         ; 0042D4 B7
    jr z,+++                     ; 0042D5 28 2B      ; zero = end
    jp p,++                      ; 0042D7 F2 F8 42   ; bit 7 unset = RLE
    bit 6,a                      ; 0042DA CB 77
    jr nz,+                      ; 0042DC 20 0D      ; bit 6 set = raw data

    and $3f                      ; 0042DE E6 3F      ; else RLE incrementing series
    ld b,a                       ; 0042E0 47
    ld a,(hl)                    ; 0042E1 7E         ; write (next byte) up to (next byte + n&$3f)
-:  ld (de),a                    ; 0042E2 12
    inc de                       ; 0042E3 13         ; skip 1 byte
    inc de                       ; 0042E4 13
    inc a                        ; 0042E5 3C         ; increment value
    djnz -                       ; 0042E6 10 FA      ; repeat
    inc hl                       ; 0042E8 23
    jr --                        ; 0042E9 18 E7

+:  and $3f                      ; 0042EB E6 3F      ; raw
    ld c,a                       ; 0042ED 4F         ; n&$3f = count
    ld b,$00                     ; 0042EE 06 00
-:  ldi                          ; 0042F0 ED A0      ; write data
    inc de                       ; 0042F2 13
    jp pe,-                      ; 0042F3 EA F0 42   ; repeat until bc == -1
    jr --                        ; 0042F6 18 DA

++: ld b,a                       ; 0042F8 47
    ld a,(hl)                    ; 0042F9 7E         ; write (next byte) n times
-:  ld (de),a                    ; 0042FA 12
    inc de                       ; 0042FB 13
    inc de                       ; 0042FC 13
    djnz -                       ; 0042FD 10 FB
    inc hl                       ; 0042FF 23
    jr --                        ; 004300 18 D0

+++:ld hl,$d102                  ; 004302 21 02 D1   ; where to write to (1,4)
    ld de,$f301                  ; 004305 11 01 F3   ; tile data to write (vertical bar,left)
    call _DrawVerticalLine       ; 004308 CD 28 43

    inc hl                       ; 00430B 23
    ld bc,($1d<<8)|5                   ; 00430C 01 05 1D   ; flip bottom edge vertically
    call _SetLineFlip            ; 00430F CD 35 43

    ld (hl),$07                  ; 004312 36 07      ; flip bottom-right corner
    ld hl,$d0fd                  ; 004314 21 FD D0   ; (30,3)
    ld (hl),$03                  ; 004317 36 03      ; flip top-right corner
    ld hl,$d0c3                  ; 004319 21 C3 D0   ; (1,3)
    ld bc,($1d<<8)|1                   ; 00431C 01 01 1D   ; no flip on top edge<<8)|but it's still the high tileset
    call _SetLineFlip            ; 00431F CD 35 43
    ld hl,$d13c                  ; 004322 21 3C D1   ; (1,7)
    ld de,$f303                  ; 004325 11 03 F3   ; vertical bar,right
    ; fall through

_DrawVerticalLine: ; 4328
; draws data de to address hl every 32 words,for a rows
    ld a,$13                     ; 004328 3E 13
    ld bc,$003f                  ; 00432A 01 3F 00   ; amount to jump in between (draw every 32nd tile)
-:  ld (hl),d                    ; 00432D 72
    inc l                        ; 00432E 2C
    ld (hl),e                    ; 00432F 73
    add hl,bc                    ; 004330 09
    dec a                        ; 004331 3D
    jr nz,-                      ; 004332 20 F9
    ret                          ; 004334 C9

_SetLineFlip: ; 4335
; draws tile flipping data c to hl for b tiles (skipping tile numbers in-between)
    ld (hl),c                    ; 004335 71
    inc l                        ; 004336 2C
    inc l                        ; 004337 2C
    djnz _SetLineFlip            ; 004338 10 FB
    ret                          ; 00433A C9

_LoadTileMapDataWithCharValues: ; 433b
    ld hl,NameEntryCharValues    ; 00433B 21 8C 44   ; data
    ld de,$d30a                  ; 00433E 11 0A D3   ; location in RAM tilemap copy (5,12)
    ld a,$06                     ; 004341 3E 06      ; number of rows
--: ld bc,21                     ; 004343 01 15 00   ; write out 21 bytes
-:  ldi                          ; 004346 ED A0      ; output
    inc de                       ; 004348 13         ; skip 1
    jp pe,-                      ; 004349 EA 46 43   ; repeat
    ex de,hl                     ; 00434C EB
    ld bc,$0056                  ; 00434D 01 56 00   ; skip on by 86 bytes so we're at the start of the next row
    add hl,bc                    ; 004350 09
    ex de,hl                     ; 004351 EB
    dec a                        ; 004352 3D
    jr nz,--                     ; 004353 20 EE      ; repeat for all rows
    ret                          ; 004355 C9

_NameEntryPalette: ; 4356
.db $00 $00 $3F $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
.db $00 $3C $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

_NameEntryCursorSprite: ; 4376
.db $FF $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00

_PasswordLookupData: ; 4396
; unused,does nothing? ##################
.db $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10
.db $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F $20
.db $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30
.db $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $3F $40
.db $41 $42 $43 $44 $45 $46 $47 $48 $49 $4A $4B $4C $4D $4E $4F $50

EnterYourNameRawTilemapData: ; $43e6
; text at top of screen "Enter your name"
.db $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $C0 $FD $C0 $C0 $C0
.db $DF $E9 $CE $F7 $C0 $DE $CD $F5 $D2 $D6 $DD $D2 $DA $D5 $CC $FE

NameEntryTilemapData: ; $4406
; draw letter selection tilemap
; missing vertical box lines to save a few bytes by drawing them in code
; no tile flipping data,that's fixed up in code
.db $c2 $c0 $f1 $1c $f2 $01 $f1 $61 $c0 $75 $c0 $20 $c0 $05 $fd $0b $c0 $85 $cb $03 $c0 $85 $e9 $03 $c0 $85 $d0 $1b $c0 $05 $fd $0b
.db $c0 $85 $d0 $03 $c0 $c5 $ee $c0 $ef $c0 $f0 $03 $c0 $85 $d5 $1b $c0 $05 $fd $0b $c0 $85 $d5 $03 $c0 $85 $f1 $03 $c0 $85 $da $1b
.db $c0 $05 $fd $0b $c0 $85 $da $03 $c0 $c5 $f6 $c0 $f7 $c0 $f8 $03 $c0 $85 $e4 $1b $c0 $05 $fe $0b $c0 $85 $df $03 $c0 $c5 $fa $fb
.db $fc $f9 $ff $03 $c0 $85 $e4 $1a $c0 $01 $fd $10 $c0 $85 $e4 $05 $c0 $cb $d7 $d7 $eb $c0 $ed $de $f3 $c0 $cf $f6 $f3 $07 $c0 $01
.db $f1 $1c $f2 $01 $f1 $00

NameEntryCharValues: ; 448c
; character codes corresponding to the tiles being shown
; but only 21 per row
; also note prev/next/save text at bottom right
.db $01 $02 $03 $04 $05 $00 $00 $00 $1F $20 $21 $22 $23 $00 $00 $00 $33 $34 $35 $36 $37
.db $06 $07 $08 $09 $0A $00 $00 $00 $24 $00 $25 $00 $26 $00 $00 $00 $38 $39 $3A $3B $3C
.db $0B $0C $0D $0E $0F $00 $00 $00 $27 $28 $29 $2A $2B $00 $00 $00 $3D $3E $3F $40 $41
.db $10 $11 $12 $13 $14 $00 $00 $00 $2C $00 $2D $00 $2E $00 $00 $00 $42 $43 $44 $45 $46
.db $15 $16 $17 $18 $19 $00 $00 $00 $30 $31 $32 $2F $4D $00 $00 $00 $47 $48 $49 $4A $4B
.db $1A $1B $1C $1D $1E $00 $00 $00 $4E $4E $4E $4E $4E $00 $4F $4F $4F $4F $50 $50 $50

.ends

.orga $450a
.section "Intro sequence" overwrite
; stops music, fades out, loads space graphics, scolls down to planet, pauses, fades out, loads
; Palma town scene, shows text box, ...
IntroSequence:
    ld a,MusicStop
    ld (NewMusic),a

    call FadeOutFullPalette
    ld hl,Frame2Paging
    ld (hl),:PaletteSpace
    ld hl,PaletteSpace
    ld de,TargetPalette
    ld bc,_sizeof_PaletteSpace
    ldir               ; Load palette

    ld hl,TilesSpace
    TileAddressDE 0    ; tile 0
    call LoadTiles4BitRLE
    ld hl,Frame2Paging
    ld (hl),:TilemapSpace
    ld hl,TilemapSpace ; 12 rows
    call DecompressToTileMapData

    ld hl,TileMapData
    ld de,TileMapData+32*2*12 ; 12 rows
    ld bc,32*2*12
    ldir               ; duplicate tilemap

    ld hl,TileMapData
    ld bc,$0100        ; 4 rows
    ldir               ; duplicate tilemap -> 28 rows filled

    xor a
    ld (HScroll),a     ; zero HScroll
    ld a,$80
    ld (VScroll),a     ; $80 = 128 -> VScroll

    ld hl,TileMapData
    ld de,TileMapAddress
    ld bc,32*2*28      ; full tilemap
    di
      call OutputToVRAM  ; output
    ei

    ld a,MusicIntro
    ld (NewMusic),a    ; set music

    call FadeInWholePalette

    ld a,%00000010     ; down
    ld (ScrollDirection),a

    ld a,$02
    ld (ScrollScreens),a

-:  ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank

    ld a,(Controls)
    and P11 | P12
    jr nz,+            ; if button pressed then skip next bit

    call IntroScrollDown

    ld a,(ScrollScreens)
    cp $01
    jr nz,-            ; repeat until ScrollScreens = 1

    ld a,(VScroll)
    cp $80
    jr nz,-            ; and VScroll = 128

    call Pause3Seconds

+:  xor a              ; zero ScrollDirection and ScrollScreens
    ld (ScrollDirection),a
    ld (ScrollScreens),a
    call FadeOutFullPalette
    ld a,$08
    ld (SceneType),a    ; Palma Town
    call LoadSceneData

    ld (hl),:TilesFont

    ld hl,TilesFont
    TileAddressDE $c0
    call LoadTiles4BitRLE
    ld hl,TilesExtraFont
    TileAddressDE $1f0
    call LoadTiles4BitRLE
    ld hl,TilesExtraFont2
    TileAddressDE $b8
    call LoadTiles4BitRLE

    xor a              ; zero VScroll and HScroll
    ld (VScroll),a
    ld (HScroll),a

    ld a,$0c           ; VBlankFunction_UpdateTilemap
    call ExecuteFunctionIndexAInNextVBlank

    call FadeInWholePalette
    ld hl,Frame2Paging
    ld (hl),:IntroBox1
    ld hl,IntroBox1
    TileMapAddressDE 3,2
    ld bc,IntroBox1Dimensions
    call OutputTilemapBoxWipe

    call Pause3Seconds
    call FadeToPictureFrame

    ld a,$00
    call FadeToNarrativePicture

    ld hl,textIntro1      ; You little bastard - poking your nose into LaShiec's business like that!
    call ShowNarrativeText ; Maybe from now on you'll try to mind your manners!
                          ; Nero! What happened?! Hang on!

    ld a,$01
    call FadeToNarrativePicture

    ld hl,textIntro2      ; ...Alisa... listen...
    call ShowNarrativeText ; ...LaShiec has brought an enormous calamity upon our world...
                          ; ...The world is facing ruin...
                          ; ...I tried to find out what LaShiec is planning...
                          ; ...But by myself, I wasn't able to do anything...
                          ; ...I heard rumors of a mighty warrior named 'Tairon' during my journey...
                          ; ...If you combine forces, you might be able to defeat LaShiec... and restore peace...
                          ; ...Alisa...
                          ; ...It’s too late for me...
                          ; ...Please forgive me... for leaving you alone...

    ld a,$02
    call FadeToNarrativePicture

    ld hl,textIntro3      ; I will go and fight to ensure that my brother did not die in vain!
    call ShowNarrativeText ; I know he will be watching over me...

    ld a,MusicStop
    ld (NewMusic),a
    ret
.ends
; followed by
.orga $4611
.section "Intro: scroll down, decompressing planet tilemap when necessary" overwrite
IntroScrollDown:
    ld de,$0001        ; d = 0, e = 1
    ld a,(VScroll)
    add a,e            ; scroll down
    cp 224             ; if it's >224
    jr c,+
    ld d,$01           ; d = 1
    add a,$20          ; e = 0 (smooth scroll)
+:  ld (VScroll),a
    ld a,(ScrollScreens)
    sub d
    ld (ScrollScreens),a ; dec ScrollScreens if scroll has passed 224
    cp $01
    ret nz             ; return if it's not 1

    ld a,d
    or a
    ret z              ; return if we didn't just decrease it

    ld hl,TilemapBottomPlanet
    jp DecompressToTileMapData ; and ret
.ends
.orga $4636

_LABEL_4636_MyauIntro:
    call FadeToPictureFrame
    ld a,MusicStory
    ld (NewMusic),a
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textMyauIntro1
    call ShowNarrativeText
    ld a,$04
    call FadeToNarrativePicture
    ld hl,textMyauIntro2
    call ShowNarrativeText
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textMyauIntro3
    call ShowNarrativeText
    ld a,$04
    call FadeToNarrativePicture
    ld hl,textMyauIntro4
    call ShowNarrativeText
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textMyauIntro5
    call ShowNarrativeText
    ld a,SFX_d8
    ld (NewMusic),a
    ret

_LABEL_467B_:
    call FadeToPictureFrame
    ld a,MusicStory
    ld (NewMusic),a
    ld a,$05
    call FadeToNarrativePicture
    ld hl,textTylonIntro1
    call ShowNarrativeText
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textTylonIntro2
    call ShowNarrativeText
    ld a,$05
    call FadeToNarrativePicture
    ld hl,textTylonIntro3
    call ShowNarrativeText
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textTylonIntro4
    call ShowNarrativeText
    ld a,$05
    call FadeToNarrativePicture
    ld hl,textTylonIntro5
    call ShowNarrativeText
    call FadeOutFullPalette
    call _LABEL_114F_
    ld a,SFX_d8
    ld (NewMusic),a
    jp FadeInWholePalette

_LABEL_46C8_:
    call FadeToPictureFrame
    ld a,MusicStory
    ld (NewMusic),a
    ; Pick an alive character to show
    ld a,$03
    ld hl,CharacterStatsAlis
    bit 0,(hl)
    jr nz,+
    ld a,$05
    ld hl,CharacterStatsOdin
    bit 0,(hl)
    jr nz,+
    ld a,$04
+:  call FadeToNarrativePicture
    ld hl,textLutzIntro1
    call ShowNarrativeText
    ld a,$06
    call FadeToNarrativePicture
    ld hl,_DATA_BC3E_
    call ShowNarrativeText
    ld a,SFX_d8
    ld (NewMusic),a
    ret

_LABEL_46FE_:
    ld a,(_RAM_C309_)
    cp $17
    jr nz,+
    call _LABEL_477E_
    ld hl,_DATA_477B_
    jp _LABEL_4770_

+:  call FadeToPictureFrame
    ld a,MusicStory
    ld (NewMusic),a
    ld a,$07
    call FadeToNarrativePicture
    ld hl,textMyausTransformation1
    call ShowNarrativeText
    ld a,$08
    call FadeToNarrativePicture
    ld hl,_DATA_BCD8_
    call ShowNarrativeText
    call _LABEL_477E_
    ld a,$0E
    ld (SceneType),a
    call LoadSceneData
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    ld hl,TargetPalette+16
    ld b,$10
-:  ld (hl),$30
    inc hl
    djnz -
    call FadeInWholePalette
    call MenuWaitHalfSecond
    ld hl,Frame2Paging
    ld (hl),$0B
    ld hl,_DATA_2C000_
    ld de,TargetPalette+16
    ld bc,$0008
    ldir
    ld a,Enemy_GoldDrake
    ld (EnemyNumber),a
    call LoadEnemy
    call _LABEL_116B_
    ld a,(FunctionLookupIndex)
    cp $02
    ret z
    ld hl,_DATA_4778_
_LABEL_4770_:
    ld a,$08
    ld (FunctionLookupIndex),a
    jp _LABEL_7B1E_

; Data from 4778 to 477A (3 bytes)
_DATA_4778_:
.db $17 $28 $1F

; Data from 477B to 477D (3 bytes)
_DATA_477B_:
.db $00 $40 $4C

_LABEL_477E_:
    call FadeOutFullPalette
    ld a,$0F
    ld (SceneType),a
    call LoadSceneData
    ld hl,Frame2Paging
    ld (hl),$16
    ld hl,_DATA_5B9D8_
    ld de,TargetPalette+16+1
    ld bc,$000F
    ldir
    ld hl,_DATA_5B9E7_
    ld de,$6000
    call LoadTiles4BitRLE
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    ld a,$15
    ld (CharacterSpriteAttributes),a
    call _LABEL_1A15_
    jp FadeOutFullPalette

_LABEL_47B5_:
    call FadeOutFullPalette
    ld a,$D0
    ld (SpriteTable),a
    ld a,MusicEnding
    ld (NewMusic),a
    ld a,$0D
    ld (SceneType),a
    call LoadSceneData
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    ld b,$00
    call PauseBFrames
    call _LABEL_7F82_
    ld hl,textEnding1
    call TextBox20x6
    call Pause256Frames
    ld hl,textEnding2
    call TextBox20x6
    call Pause256Frames
    ld hl,textEnding3
    call TextBox20x6
    call Pause256Frames
    call Close20x6TextBox
    call FadeToPictureFrame
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textEndingAlisa
    call ShowNarrativeText
    ld a,$05
    call FadeToNarrativePicture
    ld hl,textEndingTylon
    call ShowNarrativeText
    ld a,$06
    call FadeToNarrativePicture
    ld hl,textEndingLutz
    call ShowNarrativeText
    ld a,$04
    call FadeToNarrativePicture
    ld hl,textEndingMyau
    call ShowNarrativeText
    ld a,$03
    call FadeToNarrativePicture
    ld hl,textEndingEnd
    call ShowNarrativeText
    call FadeOutFullPalette
    ld hl,Frame2Paging
    ld (hl),$1F
    ld hl,_DATA_7D676_
    ld de,TargetPalette
    ld bc,$0011
    ldir
    ld hl,_DATA_7D687_
    ld de,$4000
    call LoadTiles4BitRLE
    ld hl,Frame2Paging
    ld (hl),$18
    ld hl,TileMapData
    ld de,TileMapData + 1
    ld bc,$0600
    ld (hl),$00
    ldir
    ld hl,_DATA_625E0_
    ld de,_RAM_D0D4_
    ld bc,$1316
    call _LABEL_7107_
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    call Pause256Frames
    call Pause256Frames
    ld hl,$3DF7
    ld (DungeonPosition),hl
    xor a
    ld (DungeonFacingDirection),a
    call _PitFall
    ld hl,Frame2Paging
    ld (hl),$0F
    ld hl,CreditsFont
    ld de,$5820
    call LoadTiles4BitRLE
    ld a,$01
    ld (_RAM_C2F5_),a
    ld a,MusicTower
    ld (NewMusic),a
    ld hl,_DATA_FF98_
-:  ld a,$03
    ld (Frame2Paging),a
    ld a,(hl)
    cp $FF
    jr z,++
    cp $0F
    jr nz,+
    ld b,$B4
    call PauseBFrames
    inc hl
    jr -

+:  push hl
      ld (ControlsNew),a
      call _LABEL_6891_
    pop hl
    inc hl
    jr -

++:  ld a,SFX_d7
    ld (NewMusic),a
    xor a
    ld (_RAM_C2F5_),a
    ld b,$B4
    call PauseBFrames
    ld a,$02
    ld (FunctionLookupIndex),a
    ret

.orga $48d7
.section "Load picture frame" overwrite
FadeToPictureFrame:      ; $48d7
    call FadeOutFullPalette
    ld hl,Frame2Paging
    ld (hl),:TilesFont
    ld hl,TilesFont
    TileAddressDE $c0
    call LoadTiles4BitRLE

    ld hl,TilesExtraFont
    TileAddressDE $1f0
    call LoadTiles4BitRLE
    ld hl,Frame2Paging
    ld (hl),:PaletteFrame

    ld hl,TargetPalette
    ld de,TargetPalette + 1
    ld (hl),$00
    ld bc,15
    ldir               ; blank tile palette

    ld hl,PaletteFrame
    ld bc,16
    ldir               ; load frame palette into sprite half

    ld hl,TilesFrame
    TileAddressDE 0
    call LoadTiles4BitRLE

    ld hl,TilemapFrame
    call DecompressToTileMapData

    xor a              ; zero stuff
    ld (VScroll),a
    ld (HScroll),a
    ld (TextBox20x6Open),a

    ld a,$0c           ; VBlankFunction_UpdateTilemap
    call ExecuteFunctionIndexAInNextVBlank
    jp ClearSpriteTableAndFadeInWholePalette
.ends
; followed by
.orga $492c
.section "Fade to narrative picture" overwrite
; parameter: a = which picture to load and fade in
FadeToNarrativePicture: ; $492c
    push af
      call FadeOutTilePalette
    pop af

    ld l,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,$00
    ld de,_NarrativeGraphicsLookup
    add hl,de
    ld a,(hl)          ; look up (a*5)th value in _NarrativeGraphicsLookup

    ld (Frame2Paging),a ; +0: page
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)          ; +1-2: palette offset
    inc hl
    push hl
      ex de,hl
      ld de,TargetPalette
      ld bc,16
      ldir           ; load palette
      TileAddressDE $100
      call LoadTiles4BitRLE ; and tiles after it

      ld hl,Frame2Paging
      ld (hl),NarrativeTilemaps
    pop hl
    ld a,(hl)          ; +3-4: Tilemap offset
    inc hl
    ld h,(hl)
    ld l,a
    TileMapAddressDE 6,3
    ld bc,$0c28        ; height $0c = 12, width $28/2 = 20
    di
      call OutputTilemapRawDataBox

      TileMapAddressDE 0,16
      ld bc,8*32         ; 8 rows
      ld hl,$0800        ; Tile 0, sprite palette
      call FillVRAMWithHL ; Fills bc words of VRAM from de with hl

    ei
    jp FadeInTilePalette ; and ret

_NarrativeGraphicsLookup:
; page, palette+tiles offset, raw tiles offset
.macro NarrativeGraphicsData
.db :NarrativeGraphics\1
.dw NarrativeGraphics\1,NarrativeTilemap\1
.endm
 NarrativeGraphicsData IntroNero1
 NarrativeGraphicsData IntroNero2
 NarrativeGraphicsData IntroAlis
 NarrativeGraphicsData Alis
 NarrativeGraphicsData Myau
 NarrativeGraphicsData Odin
 NarrativeGraphicsData Lutz
 NarrativeGraphicsData MyauWings1
 NarrativeGraphicsData MyauWings2
.ends
; followed by
.section "Room script handling" force
DoRoomScript:
    ; Exit if room is 0
    ld a,(RoomIndex)
    or a
    jp z,_LABEL_1D3D_
    cp $B7
    jp nc,BadScriptIndex
    ; Look up. It's 1-based
    ld de,_RoomScriptTable - 2
    call _RoomScriptDispatcher

    ld a,(SceneType)
    or a
    jp nz,Close20x6TextBox ; close and return
    ; else
    call Close20x6TextBox
    jp _LABEL_1738_

_ScriptEnd:
    pop hl
    jp MenuWaitForButton ; end end

_RoomScriptDispatcher: ; $49c9
    ; Same functionality as FunctionLookup except using de as the base
    ld l,a
    ld h,$00
    add hl,hl
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    jp (hl)

; Jump Table from 49D3 to 4B3E (182 entries,indexed by RoomIndex)
_RoomScriptTable:
; Room index => handler lookup
.dw _room_01_Suelo
.dw _room_02_Nekise
.dw _room_03_CamineetMan1
.dw _room_04_CamineetMan2
.dw _room_05_CamineetMan3
.dw _room_06_CamineetMan4
.dw _room_07_CamineetMan5
.dw _room_08_Camineet_AlgolMan:
.dw _room_09_CamineetGuard1
.dw _room_0a_CamineetGuard2
.dw _room_0b_CamineetGuard3
.dw _room_0c_CamineetGuard4
.dw _room_0d_ParolitWoman1
.dw _room_0e_ParolitMan1
.dw _room_0f_ParolitMan2
.dw _room_10_ParolitMan3
.dw _room_11_ParolitMan4
.dw _room_12_ParolitMan5
.dw _room_13_AirStripGuard
.dw _room_14_AirStripGuard
.dw _room_15_Shion_Man1
.dw _room_16_MadDoctor
.dw _room_17_PalmaSpaceportLuggageHandler1
.dw _room_18_PalmaSpaceportLuggageHandler2
.dw _room_19_PalmaSpaceportLuggageHandler3
.dw _room_1a_AirStripGuard
.dw _room_1b_RoadGuard
.dw _room_1c_RoadGuard
.dw _room_1d_PassportOffice
.dw _room_1e_Shion_Man1
.dw _room_1f_Shion_Man2
.dw _room_20_ShionMan3
.dw _room_21_ShionMan4
.dw _room_22_ShionMan5
.dw _room_23_ShionMan6
.dw _room_24_ShionMan7
.dw _room_25_ShionMan8
.dw _room_26_EppiMan1
.dw _room_27_EppiMan2
.dw _room_28_EppiMan3
.dw _room_29_EppiMan4
.dw _room_2a_EppiMan5
.dw _room_2b_EppiMan6
.dw _room_2c_PaseoSpaceportLuggageHandler1
.dw _room_2d_PaseoSpaceportLuggageHandler2
.dw _room_2e_PaseoSpaceport3
.dw _room_2f_Paseo1
.dw _room_30_Paseo2
.dw _room_31_Paseo3
.dw _room_32_Paseo4
.dw _room_33_Paseo5
.dw _room_34_Paseo6
.dw _room_35_Paseo7
.dw _room_36_PaseoMyauSeller
.dw _room_37_GovernorGeneral
.dw _room_38_MansionGuard1
.dw _room_39_GuestHouseLady
.dw _room_3a_BartevoVillager1
.dw _room_3b_BartevoVillager2
.dw _room_3c_GothicWoods1
.dw _room_3d_GothicWoods2
.dw _room_3e_DrLuveno
.dw _room_3f_50FC
.dw _room_40_LoreVillager1
.dw _room_41_LoreVillager2
.dw _room_42_511F
.dw _room_43_LoreVillager4
.dw _room_44_LoreVillager5
.dw _room_45_AbionVillager1
.dw _room_46_AbionVillager2
.dw _room_47_AbionVillager3
.dw _room_48_AbionVillager4
.dw _room_49_AbionVillager5
.dw _room_4a_UzoVillager1
.dw _room_4b_UzoVillager2
.dw _room_4c_UzoVillager3
.dw _room_4d_UzoVillager4
.dw _room_4e_UzoVillager5
.dw _room_4f_UzoVillager6
.dw _room_50_CasbaVillager1
.dw _room_51_CasbaVillager2
.dw _room_52_AeroCastle1
.dw _room_53_CasbaVillager3
.dw _room_54_CasbaVillager4
.dw _room_55_CasbaVillager5
.dw _room_56_Drasgo1
.dw _room_57_Drasgo2
.dw _room_58_Drasgo3
.dw _room_59_Drasgo4
.dw _room_5a_ChokoOneesan
.dw _room_5b_DrasgoCave1
.dw _room_5c_DrasgoCave2
.dw _room_5d_DrasgoGasClearSeller
.dw _room_5e_Skray1
.dw _room_5f_Skray2
.dw _room_60_Skray3
.dw _room_61_Skray4
.dw _room_62_Skray5
.dw _room_63_Skray6
.dw _room_64_Skray7
.dw _room_65_Skray8
.dw _room_66_Skray9
.dw _room_67_Skray10
.dw _room_68_HonestDezorian1
.dw _room_69_HonestDezorian2
.dw _room_6a_HonestDezorian3
.dw _room_6b_HonestDezorian4
.dw _room_6c_HonestDezorian5
.dw _room_6d_HonestDezorian6
.dw _room_6e_DishonestDezorian1
.dw _room_6f_DishonestDezorian2
.dw _room_70_DishonestDezorian3
.dw _room_71_DishonestDezorian4
.dw _room_72_DishonestDezorian5
.dw _room_73_DishonestDezorian6
.dw _room_74_SopiaVillageChief
.dw _room_75_GamerMikiChan
.dw _room_76_Sopia1
.dw _room_77_Sopia2
.dw _room_78_Sopia3
.dw _room_79_Sopia4
.dw _room_7a_AeroCastle2
.dw _room_7b_AeroCastle3
.dw _room_7c_ShortcakeShop
.dw _room_7d_MahalCaveMotavianPeasant
.dw _room_7e_Lutz
.dw _room_7f_LuvenosAssistant
.dw _room_80_5436
.dw _room_81_Luveno_Prison
.dw _room_82_TriadaPrisonGuard1
.dw _room_83_TriadaPrisoner1
.dw _room_84_TriadaPrisoner2
.dw _room_85_TriadaPrisoner3
.dw _room_86_TriadaPrisoner4
.dw _room_87_TriadaPrisoner5
.dw _room_88_TriadaPrisoner6
.dw _room_89_MedusasTower1
.dw _room_8a_MedusasTower2
.dw _room_8b_MedusasTower3
.dw _room_8c_BartevoCave
.dw _room_8d_AvionTower
.dw _room_8e_5530
.dw _room_8f_5597
; Repeats?
.dw _room_90_DrasgoCave1
.dw _room_91_DrasgoCave2
.dw _room_92_DrasgoGasClearSeller
.dw _room_93_55AB
.dw _room_94_55F5
.dw _room_95_55FB
.dw _room_96_5601
.dw _room_97_5607
.dw _room_98_560D
.dw _room_99_5613
.dw _room_9a_5619
.dw _room_9b_561F
.dw _room_9c_TorchBearer
.dw _room_9d_Tajim
.dw _room_9e_ShadowWarrior
.dw _room_9f_LaShiec
.dw _room_a0_EppiWoodsNoCompass
.dw _room_a1_HapsbyScrapHeap
.dw _room_a2_5795
.dw _room_a3_TaironStone
.dw _room_a4_CoronoTowerDezorian1
.dw _room_a5_GuaranMorgue
.dw _room_a6_CoronaDungeonDishonestDezorian: ; $5809
.dw _room_a7_581B
.dw _room_a8_BayaMarlayPrisoner: ; $582D
.dw _room_a9_BuggyUnused: ; $5841
.dw _room_aa_LuvenoGuard: ; $584F
.dw _room_ab_DarkForce: ; $5879
.dw _room_ac_58C6
.dw _room_ad_58FC
.dw _room_ae_5902
.dw _room_af_LaermaTree
.dw _room_b0_TopOfBayaMarlay
.dw _room_b1_592D
.dw _room_b2_OtegamiChieChan: ; $5933
.dw _room_b3_FlightToMotavia: ; $5939
.dw _room_b4_FlightToPalma: ; $5949
.dw _room_b5_HapsbyTravel: ; $5959
.dw _room_b6_5795

_room_01_Suelo: ; $4B3F
    ld hl,HaveVisitedSuelo
    ld a,(hl)
    or a
    jr nz,+
    ; First time
    ld (hl),1
    ld hl,$0002
    ; Alisa... taking on LaShiec is crazy. But I know how stubborn and determined you can be.<wait more>
    ; I won't waste my breath trying to talk you out of this, just... please be careful.<wait more>
    ; If you ever get hurt, come back here to heal.<wait more>
    ; We've been neighbors a long time, you know Suelo's home is always open for you.<wait>
    call DrawText20x6
+:  ld hl,$0006
    ; Please get some rest.<wait more>
    ; Your brother would be proud of you. But don't overdo it, okay? Come back here anytime.<wait>
    call DrawText20x6
    ld a,SFX_Heal
    ld (NewMusic),a
    jp _LABEL_2BC9_

_room_02_Nekise: ; $4b5c
    ld a,(HaveGotPotfromNekise)
    or a
    jr nz,+
    ; First visit
    ld hl,$0008
    ; My name is Nekise.<line><line>
    ; I was sorry to hear about your loss.<wait more>
    ; Nero asked me to help him find a warrior named Tylon, are you looking for him too?<wait more>
    ; The last I heard, he was staying in a town called Shion. Maybe he's still near there.<wait more>
    ; Your brother also asked me to keep this Laconian Pot safe for him.<wait more>
    ; It's pretty valuable, maybe it will help you on your journey? Here, please take it.<wait>
    call DrawText20x6
    ld a,Item_LaconianPot
    ld (ItemTableIndex),a
    call AddItemToInventory
    ld a,Item_LaconianPot
    call HaveItem
    jr nz,+
    ld a,1
    ld (HaveGotPotfromNekise),a
+:  ld hl,$0010
    ; Forgive me, but there is nothing more I can do. May you[r journey] be safe.
    jp DrawText20x6 ; and ret

_room_03_CamineetMan1: ; $4B82
    ld hl,$0012
    ; The Camineet residential district is under martial law.
    jp DrawText20x6 ; and ret

_room_04_CamineetMan2: ; $4B88
    ld hl,$0014
    ; You need a ‘Dungeon Key’ to open locked doors.
    jp DrawText20x6 ; and ret

_room_05_CamineetMan3 ; $4B8E
    ld hl,$0016
    ; You will not be able to advance through certain dungeons if you don't have a light.
    jp DrawText20x6 ; and ret

_room_06_CamineetMan4 ; $4B94:
    ld hl,$0018
    ; West of Camineet? That's the Spaceport.
    jp DrawText20x6 ; and ret

_room_07_CamineetMan5 ; $4B9A:
    ld hl,$001A
    ; They say that all sorts of business goes on in the port town.
    jp DrawText20x6 ; and ret

_room_08_Camineet_AlgolMan: ; $4BA0:
    ld hl,$0062
    ; Do you know the planets in the Algol Solar System?
    call DrawText20x6
    call DoYesNoMenu
    ld hl,$0060 ; If yes
    ; I see. Never mind.
    jr z,+
    ld hl,3 ; If no
    ld (NumberToShowInText),hl
    ld hl,$0064
    ; There are three planets: Palma, Motabia, and Dezoris.
    ; Palma is a planet of greenery.
    ; Motavia is a planet of sand.
    ; Dezoris is a planet of ice.
    ; There is a crisis drawing near to Algol...
+:  jp DrawText20x6 ; and ret

_room_09_CamineetGuard1 ; $4BBA
    ld hl,$001C
    ; Stay inside the residential area if you know what's good for you.
    jp DrawText20x6 ; and ret

_room_0a_CamineetGuard2: ; $4BC0
    ld hl,$001E
    ; Want to stay alive?  Then stay here!
    jp DrawText20x6 ; and ret

_room_0b_CamineetGuard3: ; $4BC6:
    ld a,Item_RoadPass
    call HaveItem
    jr z,+
    ld hl,$0020
    ; I can’t just let you pass through here!
    jp DrawText20x6 ; and ret

_room_0c_CamineetGuard4: ; $4BD3:
    ld a,Item_RoadPass
    call HaveItem
    jr z,+
    ld hl,$0022
    ; Nobody gets through here without a 'Roadpass'.
    jp DrawText20x6 ; and ret
+:  ld hl,$0024
    ; Okay, you may pass.
    call DrawText20x6
    ; Copy something from _RAM_c309_ to _RAM_c2e9_ TODO what is this?
    ld a,(_RAM_C309_)
    rrca
    dec a
    and $03
    ld (_RAM_C2E9_),a
    ret

_room_0d_ParolitWoman1: ; $4BF1:
    ld hl,$0026
    ; This is Parolit residential district.
    jp DrawText20x6 ; and ret

_room_0e_ParolitMan1: ; $4BF7:
    ld hl,$0028
    ; When you're in the forest, you need to be especially cautious.
    jp DrawText20x6 ; and ret

_room_0f_ParolitMan2: ; $4BFD:
    ld hl,$002A
    ; I hear that the monster Medusa has returned to the cave South of the city. They say if you look at it, you'll turn to stone!
    jp DrawText20x6 ; and ret

_room_10_ParolitMan3: ; $4C03:
    ld hl,$002E
    ; If you travel East, you will reach the port town of Shion.
    jp DrawText20x6 ; and ret

_room_11_ParolitMan4: ; $4C09:
    ld hl,$0030
    ; You can travel to Paseo, on the planet Motavia, from the spaceport.
    jp DrawText20x6 ; and ret

_room_12_ParolitMan5: ; 4C0F:
    ld hl,$0032
    ; I hear you can get to the Gothic Forest -- which is West of Parolit -- through an underground passageway.
    jp DrawText20x6 ; and ret

_room_13_AirStripGuard: ; $4C15:
_room_14_AirStripGuard: ; $4C15:
    ld a,(LuvenoState)
    cp $07
    jp nc,SpacePortsAreClosed
    ld hl,$0070
    ; Do you have a passport?
    call DrawText20x6
    call DoYesNoMenu
    ld hl,$0020
    ; I can’t just let you pass through here!
    jr nz,+
    ld a,Item_Passport
    call HaveItem
    ; Don't have one
    ld hl,$00CE
    ; Well? Let’s see it.
    jr nz,+
    ld a,$06
    ld (_RAM_c2e9_),a ; ???
    ld hl,$0024
    ; Okay, you may pass.
+:  jp DrawText20x6 ; and ret

_room_15_Shion_Man1: ; $4C40:
    ld hl,$0286
    ; On Motabia, there are the Motavians. On Dezoris, the Dezorians. I’d like to hang out and talk with them sometime.
    jp DrawText20x6 ; and ret

_room_16_MadDoctor: ; $4C46:
    ld a,Enemy_MadDoctor
    ld (EnemyNumber),a
    call LoadEnemy
    ld a,(CharacterStatsMyau)
    or a
    jr z,+
    ld hl,$0296
    ; Hey, cat! C'mere!
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ; Kill Myau
    ld a,SFX_Death
    ld (NewMusic),a
    ld a,Player_Myau
    ld (TextCharacterNumber),a
    ld hl,textPlayerDied
    ; <player> died.<delay>
    call TextBox20x6
    ld hl,$0000
    ld (CharacterStatsMyau),hl
    ld hl,$0298
    ; Hee hee hee! You guys wanna die too?
    jr ++
+:  ; Myau is dead or refuses to "come here"
    ld hl,$029a
    ; I will kill anything that gets in my way!
++:  call DrawText20x6
    call Close20x6TextBox
    ld a,(PartySize)
    or a
    jr z,+ ; No Myau yet
    ld a,Item_LaconianPot
    call HaveItem
    jr z,+
    ; Don't have a Laconian Pot
    ld hl,$C518
    ld (DungeonObjectFlagAddress),hl
    ld a,Item_LaconianPot
    ld (DungeonObjectItemIndex),a
+:  jp _LABEL_55E9_

_room_17_PalmaSpaceportLuggageHandler1: ; $4C9E:
    ld hl,$006A
    ; This is Palma Spaceport. You can go to Paseo, on the planet Motavia.
    jp DrawText20x6 ; and ret

_room_18_PalmaSpaceportLuggageHandler2: ; $4CA4:
    ld hl,$006C
    ; The Governor-General lives in Paseo. He rules all of Motavia.
    jp DrawText20x6 ; and ret

_room_19_PalmaSpaceportLuggageHandler3: ; $4CAA:
    ld hl,$006E
    ; Rumor has it that the Gothic Laboratory was once used to build spaceships. Back in the old days, ships like these were built at the laboratory in Gothic.<wait>
    jp DrawText20x6 ; and ret

_room_1a_AirStripGuard: ; $4CB0:
    ld a,(LuvenoState)
    cp $07
    jr nc,SpacePortsAreClosed
    ld hl,$0070
    ; Do you have a passport?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$0020
    ; I can’t just let you pass through here!
    jp DrawText20x6 ; and ret
+:  ; Yes
    ld a,Item_Passport
    call HaveItem
    jr z,+
    ; Don't have one
    ld hl,$00CE
    ; Well? Let’s see it.
    jp DrawText20x6 ; and ret
+:  ; Have one
    ld hl,$0024
    ; Okay, you may pass.
    call DrawText20x6
    ; Warp position?
    ld a,(VLocation)
    cp $60
    ld hl,_4d03
    jr nz,+
    ld hl,_4d06
+:  call _LABEL_7B1E_
    ret

SpacePortsAreClosed:
    ld hl,$019E
    ; Algol security is now at threat level red. Space travel is off limits to all citizens.<wait>
    call DrawText20x6
    ld a,Item_Passport
    call HaveItem
    ret nz
    push bc
      call RemoveItemFromInventory
    pop bc
    ld hl,$01A0
    ; WE ARE CONFISCATING YOUR PASSPORT.<end>
    jp DrawText20x6 ; and ret

; Data from 4D03 to 4D05 (3 bytes)
_DATA_4D03_:
.db $05 $20 $17

; Data from 4D06 to 4D08 (3 bytes)
_DATA_4D06_:
.db $05 $21 $15

_room_1b_RoadGuard: ; $4D09:
    ld a,Item_RoadPass
    call HaveItem
    ld hl,$0020
    ; I can’t just let you pass through here!
    jr nz,+
    ld a,$04
    ld (_RAM_C2E9_),a
    ld hl,$0024
    ; Okay, you may pass.
+:  jp DrawText20x6 ; and ret

_room_1c_RoadGuard: ; $4D1E:
    ld a,Item_RoadPass
    call HaveItem
    ld hl,$0022
    ; Nobody gets through here without a 'Roadpass'.
    jr nz,+
    ld a,$05
    ld (_RAM_C2E9_),a
    ld hl,$0024
    ; Okay, you may pass.
+:  jp DrawText20x6 ; and ret

_room_1d_PassportOffice: ; $4D33:
    ld hl,$0072
    ; You can apply for a ‘passport’ here. Would you like to apply?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$007C
    ; I see. Well then, take care.
    jp DrawText20x6 ; and ret
+:  ; Yes
    ld hl,$0074
    ; Up to today, have you ever done any bad things?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ; Yes
    ld hl,$007E
    ; That's too bad. Please come back some other time.
    jp DrawText20x6 ; and ret
+:  ; No
    ld hl,$0076
    ; Are you suffering from an illness right now?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ; Yes
    ld hl,$007E
    ; That's too bad. Please come back some other time.
    jp DrawText20x6 ; and ret
+:  ; No
    ld hl,100
    ld (NumberToShowInText),hl
    ld hl,$0078
    ; The fee is 100 mesetas. Is that agreeable?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$007C
    ; I see. Well then, take care.
    jp DrawText20x6 ; and ret
+:  ; Yes
    ld de,100
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr nc,+
    ld hl,textShopNotEnoughMoney
    ; It looks like you don’t have enough money.<line>
    ; Please come back later.<wait>
    jp TextBox20x6 ; and ret
+:  ; Have enough money; pay it
    ld (Meseta),hl
    ld hl,$007A
    ; Well then, we will issue you a passport. Here you go.
    call DrawText20x6
    ld a,Item_Passport
    ld (ItemTableIndex),a
    call HaveItem
    ret z
    jp AddItemToInventory ; and ret

_room_1e_Shion_Man1: ; $4DA3:
    ld a,(PartySize)
    or a
    ; No Myau yet
    ld hl,$0034
    ; Tairon? He went to slay Medusa! That guy, he was with a TALKING ANIMAL! And the animal -- it had a bottle of medicine around it's neck. I wonder if it has any special purpose?
    jr z,+
    ; Have found Myau
    ld hl,$003A
    ; You’re on a quest to defeat LaShiec, huh? Well, good luck!
+:  jp DrawText20x6 ; and ret

_room_1f_Shion_Man2: ; $4DB2:
    ld a,(PartySize)
    or a
    ; No Myau yet
    ld hl,$003C
    ; I found a talking animal in Medusa’s Cave earlier, see? Then I sold it off to a trader in Paseo and made a bundle! Heh, heh, heh!
    jr z,+
    ; Have found Myau
    ld hl,$0040
    ; Times have been rough lately, don’t you think? I wonder if there’s anywhere I can go to make money.
+:  jp DrawText20x6 ; and ret

_room_20_ShionMan3: ; $4DC1:
    ld hl,$0042
    ; On the peninsula South of Shion, you will find Iala Cave.
    jp DrawText20x6 ; and ret

_room_21_ShionMan4: ; $4DC7:
    ld hl,$0044
    ; This is the port town of Shion. This place used to be busy with trade.
    jp DrawText20x6 ; and ret

_room_22_ShionMan5: ; $4DCD:
    ld hl,$0046
    ; The Eppi Woods are confusing. You need a ‘Compass’ just to pass through them.
    jp DrawText20x6 ; and ret

_room_23_ShionMan6: ; $4DD3:
    ld hl,$0048
    ; Magically-sealed doors can be opened only with magic.
    jp DrawText20x6 ; and ret

_room_24_ShionMan7: ; $4DD9:
    ld hl,$004A
    ; If you go North from this town you will reach the hill of Baya Mahrey. However, we aren’t able to get near to it.
    jp DrawText20x6 ; and ret

_room_25_ShionMan8: ; $4DDF:
    ld hl,$004C
    ; On the beach North of Baya Mahrey, you will find Naula Cave.
    jp DrawText20x6 ; and ret

_room_26_EppiMan1: ; $4DE5:
    ld hl,$004E
    ; I wonder if Motabia’s Governor-general might aid you in your quest.
    jp DrawText20x6 ; and ret

_room_27_EppiMan2: ; $4DEB:
    ld hl,$0050
    ; On Motabia live the great ‘Espers’.
    jp DrawText20x6 ; and ret

_room_28_EppiMan3: ; $4DF1:
    ld hl,$0052
    ; A doctor named ‘Luveno’ used to have a laboratory in Gothic Forest.
    jp DrawText20x6 ; and ret

_room_29_EppiMan4: ; $4DF7:
    ld hl,$0054
    ; Welcome to Eppi Village!<wait more>
    ; We don’t get many visitors lately, now that the forest is crawling with monsters.<wait>
    jp DrawText20x6 ; and ret

_room_2a_EppiMan5: ; $4DFD:
    ld hl,$0056
    ; Are you by any chance searching for the ‘Dungeon Key’?
    call DrawText20x6
    call DoYesNoMenu
    ; No
    ld hl,$0060
    ; I see. Never mind.
    jr nz,+
    ; Yes
    ld a,Item_DungeonKey
    call HaveItem
    jr z,++
    ld hl,DungeonKeyIsHidden
    ld (hl),0
++: ld hl,$0058
    ; I hid the ‘Dungeon Key’ in a secret place, inside the warehouse located on the outskirts of Camineet residential area.
+:  jp DrawText20x6  ; and ret

_room_2b_EppiMan6: ; $4E1D:
    ld hl,$005C
    ; Do you know what the hardest, strongest material in the world is?
    call DrawText20x6
    call DoYesNoMenu
    ld hl,$0060
    ; I see. Never mind.
    jr z,+
    ld hl,$005E
    ; It’s ‘Laconia’! Laconian weapons are the strongest [in the solar system].
+:  jp DrawText20x6 ; and ret

_room_2c_PaseoSpaceportLuggageHandler1: ; $4E31:
    ld hl,$0080
    ; This is Paseo spaceport, on the planet Motabia.
    jp DrawText20x6 ; and ret

_room_2d_PaseoSpaceportLuggageHandler2: ; $4E37:
    ld hl,$0082
    ; I’ve heard rumors that there are vicious ‘Ant-lions’ in the desert!
    jp DrawText20x6 ; and ret

_room_2e_PaseoSpaceport3: ; $4E3D:
    ld hl,$0084
    ; THERE IS A CAKE SHOP IN THE CAVE CALLED NAULA ON PALMA!
    jp DrawText20x6 ; and ret

_room_2f_Paseo1: ; $4E43:
    ld hl,$0086
    ; ..Actually, the Governor-General seems to be on very bad terms with LaShiec!
    jp DrawText20x6 ; and ret

_room_30_Paseo2: ; $4E49:
    ld hl,$0088
    ; You need to have a gift in order to meet with the Governor-General.
    jp DrawText20x6 ; and ret

_room_31_Paseo3: ; $4E4F:
    ld hl,$008A
    ; The Governor-General loves sweets.
    jp DrawText20x6 ; and ret

_room_32_Paseo4: ; $4E55:
    ld hl,$008C
    ; Maharu Cave is located in the mountains to the north of Paseo.
    jp DrawText20x6 ; and ret

_room_33_Paseo5: ; $4E5B:
    ld hl,$008E
    ; This is Paseo, capital of Motabia.
    jp DrawText20x6 ; and ret

_room_34_Paseo6: ; $4E61:
    ld hl,$0090
    ; There’s no way to pass over those ant lions on FOOT, [but...].
    jp DrawText20x6 ; and ret

_room_35_Paseo7: ; $4E67:
    ld hl,$0288
    ; I hear that intelligent monsters have monster languages.
    jp DrawText20x6 ; and ret

_room_36_PaseoMyauSeller: ; $4E6D:
    ld a,(PartySize)
    or a
    jr z,+
    ; Have found Myau
    ld hl,$028A
    ; That laconian pot was worth a fortune! Thanks a bundle!
    jp DrawText20x6 ; and ret
+:  ; No Myau yet
    ld hl,10
    ld (NumberToShowInText),hl
    ld hl,$0092
    ; I gotta real rare animal here. You can have it fer a billion mesetas. Whuddayuhsay?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ld hl,$0094
    ; Yeah, right. You gotta be kiddin’ me!
    jp DrawText20x6 ; and ret
+:  ld a,$38
    call HaveItem
    jr nz,+
    push hl
      ld hl,$0096
      ; Say... That’s a real unusual pot you got there... ...is 'dat a ‘Laconian Pot’?! How ‘bout I give you da animal, you give me the pot? Whuddayuhsay?
      call DrawText20x6
      call DoYesNoMenu
    pop hl
    jr nz,+
    push bc
      call RemoveItemFromInventory
    pop bc
    ld hl,$009A
    ; Alri---ght, there yuh go. Take good care uv‘im.
    call DrawText20x6
    call Close20x6TextBox
    pop hl
    ; Bring Myau to life
    ld iy,CharacterStatsMyau
    call InitialiseCharacterStats
    ld a,1
    ld (PartySize),a
    ; Get some Alsuline
    ld a,Item_Alsuline
    ld (ItemTableIndex),a
    call AddItemToInventory
    jp _LABEL_4636_MyauIntro
+:  ld hl,$007C
    ; I see. Well then, take care.
    jp DrawText20x6 ; and ret

_room_37_GovernorGeneral: ; $4ED0:
    ld a,(HaveBeatenLaShiec)
    or a
    jr z,+
    ld hl,$02A6
    ; Hey. That’s weird... Where’d the Governor-General go?
    call DrawText20x6
    call Close20x6TextBox
    pop hl
    ld hl,$22E6
    ld ($c30c),hl
    xor a
    ld ($c30a),a
    ld hl,FunctionLookupIndex
    ld (hl),$0B
    call $68bf
    ld a,MusicFinalDungeon
    jp CheckMusic ; and ret
+:  ld a,$35
    call LoadDialogueSprite
    call SpriteHandler
    ld a,(PartySize)
    cp 3
    jr nc,+
    ld a,Item_GovernorGeneralsLetter
    call HaveItem
    jr nz,++
+:  ; No Lutz yet, or have the letter
    ld hl,$029e
    ; There’s no time to lose! Have faith in yourself. I’ll be praying for your safety.
    call DrawText20x6
    ld hl,$00AA
    ; I am absolutely certain that you will defeat LaShiec and return here.
    jp DrawText20x6 ; and ret
++:  ld hl,$00A4
    ; I am the Governor-General of this planet. I understand you are on a quest to defeat LaShiec. I commend you for your courage. In Maharu Cave you will find an Esper named Lutz (pronounced 'roots'). Please take this letter to him. I am absolutely certain that you will defeat LaShiec and return here.
    call DrawText20x6
    ; Get the letter
    push bc
      ld a,Item_GovernorGeneralsLetter
      ld (ItemTableIndex),a
      call AddItemToInventory
    pop bc
    ld a,Item_GovernorGeneralsLetter
    call HaveItem
    ret nz ; Inventory full -> kick out?
    ld hl,$029C
    ; You must be tired from your long journey. You should relax here for a while.
    call DrawText20x6
    call FadeOutFullPalette
    call Close20x6TextBox
    ld a,$20
    ld (SceneType),a
    call LoadSceneData
    ; Turn off sprites
    ld a,$D0
    ld (SpriteTable),a
    ld a,$0c ; VBlankFunction_UpdateTilemap
    call ExecuteFunctionIndexAInNextVBlank
    ld hl,_GovernorGeneralPalette
    ld de,TargetPalette
    ld bc,_sizeof__GovernorGeneralPalette
    ldir
    call FadeInWholePalette
    ld hl,$02A0
    ; You enter into a deep sleep...
    call DrawText20x6
    call Close20x6TextBox
    ld a,SFX_a0
    ld (NewMusic),a
    call Pause256Frames
    ld a,Enemy_Nightmare
    ld (EnemyNumber),a
    call LoadEnemy
    ; Preserve all stats as it's just a dream...
    ld a,(CharacterStatsAlis)
    push af
      ld a,(CharacterStatsMyau)
      push af
        ld a,(CharacterStatsOdin)
        push af
          call _LABEL_116B_
        pop af
        ld (CharacterStatsOdin),a
      pop af
      ld (CharacterStatsMyau),a
    pop af
    ld (CharacterStatsAlis),a
    call FadeOutFullPalette
    call LoadSceneData
    ld a,$D0
    ld (SpriteTable),a
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    ld hl,$02A2
    ; What a frightening dream!
    call DrawText20x6
    call FadeOutFullPalette
    ld a,$1D
    ld (SceneType),a
    call LoadSceneData
    call _LABEL_2BC9_
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    ld a,$35
    call LoadDialogueSprite
    call SpriteHandler
    ld hl,$00AA
    ; I am absolutely certain that you will defeat LaShiec and return here.
    jp DrawText20x6 ; and ret

_GovernorGeneralPalette:
.db $00 $00 $3F $00 $00 $00 $00 $00 ; Blacks with one white

_room_38_MansionGuard1: ; $4FD4:
    ld hl,$00B4
    ; zzz... zzz...
    jp DrawText20x6 ; and ret

_room_39_GuestHouseLady: ; $4FDA:
    ld hl,$00B6
    ; Please rest before you go.
    call DrawText20x6
    call FadeOutFullPalette
    call Close20x6TextBox
    ld a,SFX_a0
    ld (NewMusic),a
    call Pause256Frames
    call _LABEL_2BC9_
    ld a,SFX_Heal
    ld (NewMusic),a
    call FadeInWholePalette
    ld hl,$00B8
    ; I AM PRAYING FOR YOUR SAFETY.<end>
    jp DrawText20x6 ; and ret

_room_3a_BartevoVillager1: ; $4FFF:
    ld hl,$0102
    ; Bartevo is my territory. Don’t be screwin’ around!
    jp DrawText20x6 ; and ret

_room_3b_BartevoVillager2: ; $5005:
    ld hl,$0106
    ; I heard that a high-performance robot got dumped inside one of these scrap piles. I wonder if it’s true?
    jp DrawText20x6 ; and ret

_room_3c_GothicWoods1:
    ld hl,$00BA
    ; Hey, you mind if I bum a ‘PelorieMate’?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$00C2
    ; I ain’t talking to you, then. Get the hell away from me.
    jp DrawText20x6 ; and ret
+:  ld a,Item_PelorieMate
    call HaveItem
    jr nz,+
    ; Have one
    push bc
      call RemoveItemFromInventory
    pop bc
    ld hl,$00BC
    ; Thanks. This place used to be the lab of a scientist named ‘Luveno’. But he turned crazy, see, and got locked up in Toriada, the prison to the South of this village.
    jp DrawText20x6 ; and ret
+:  ld hl,$020E
    ; Don’t f--- with me!
    jp DrawText20x6 ; and ret

_room_3d_GothicWoods2:
    ld hl,$00BA
    ; Hey, you mind if I bum a ‘PelorieMate’?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$00C2
    ; I ain’t talking to you, then. Get the hell away from me.
    jp DrawText20x6 ; and ret
+:  ld a,Item_PelorieMate
    call HaveItem
    jr nz,+
    ; Have one
    call RemoveItemFromInventory
    ld hl,$00C4
    ; In the heart of the mountains, there's a tower that can be reached by one of the roads leading out of Gothic. Inside the tower, they say, there's a freaky monster that, if you just LOOK at it, will turn yuh tuh stone!
    jp DrawText20x6 ; and ret
+:  ld hl,$020E
    ; Don’t f--- with me!
    jp DrawText20x6 ; and ret

_room_3e_DrLuveno: ; $505B:
    ld a,(LuvenoState)
    or a
    jp z,_ScriptEnd
    ld a,$34
    call LoadDialogueSprite
    call SpriteHandler
    ld a,(LuvenoState)
    cp $07
    jr c,+
    ; Have the Luveno
    ld hl,$00D8
    ; How’s the ‘Luveno’ holding up? Please be careful with it.
    jp DrawText20x6 ; and ret
+:  cp $02
    jr nc,+
    ; Didn't talk to assistant yet
    ld hl,$00CA
    ; Ahh, you’re late! Quickly! Do me a favor and bring my assistant back here. He’s probably hiding in that underground tunnel. It really irritates me shy a person he is.
    jp DrawText20x6 ; and ret
+:  cp $03
    jr nc
    ; Have assistant but haven't paid
    ld hl,1200
    ld (NumberToShowInText),hl
    ld hl,$028C
    ; Okay, it looks like my staff is assembled. Manufacturing expenses come to 1200 meseta. Will you please give it to me?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$00DA
    ; What a shame. So your journey ends here, I suppose...
    jp DrawText20x6 ; and ret
+:  ld de,1200
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr nc,+;
    ld hl,$00D0
    ; You don’t have enough? I’m sorry, but must get some more money.
    jp DrawText20x6 ; and ret
+:  ld (Meseta),hl
    ld a,$03
    ld (LuvenoState),a
    ld hl,$0290
    ; Thanks. Now then, let’s begin construction, shall we? Please wait for a little while.
    jp DrawText20x6
++:  cp $05
    jr nc,+
    ; Next two visits
    inc a
    ld (LuvenoState),a ; increment to 4, 5
    ld hl,$0292
    ; IT CANNOT BE HURRIED! PLEASE SHOW A BIT MORE PATIENCE!
    jp DrawText20x6 ; and ret
+:  cp $06
    jr nc,+
    ; Third visit
    inc a
    ld (LuvenoState),a ; i.e. 6
    ld hl,$00D2
    ; At last, the spaceship is finished!  I’m pleased to present to you, the ‘Luveno’!
    call DrawText20x6
    ld a,Item_Hapsby
    call HaveItem
    jr z,++
    ; No Hapsby
    ld hl,$00D6
    ; But you won’t be able to pilot the spaceship yourself.
    call DrawText20x6
+:  ld a,Item_Hapsby
    call HaveItem
    jr z,++
    ; No Hapsby
    ld hl,$0104
    ; YOU MUST FIND A ROBOT NAMED HAPSBY. HE CAN FLY A SPACESHIP.
    jp DrawText20x6 ; and ret
++: ld a,7
    ld (LuvenoState),a ; Final state
    ld hl,$0294
    ; Now then, you can use the Luveno to fly through space. Go outside the village and take a look. It’s a brilliant piece of work.
    jp DrawText20x6 ; and ret

_room_3f_50FC:
    ld hl,LuvenoState
    ld a,(hl)
    cp 2
    jp c,_ScriptEnd
    ; Nothing if Luveno is in progress or done
    ld a,$10
    call $63f9
    call SpriteHandler
    ld hl,$00DC
    ; I’m busy right now, so please don’t interrupt.
    jp DrawText20x6 ; and ret

_room_40_LoreVillager1: ; $5113:
    ld hl,$0118
    ; Huh? You’re going to defeat LaShiec? Awesome!
    jp DrawText20x6 ; and ret

_room_41_LoreVillager2: ; $5119:
    ld hl,$010E
    ; Do you know of a jewel called the ‘Carbuncle Eye’? Rumor has it that it’s being held by the Casba Dragon.
    jp DrawText20x6 ; and ret

_room_42_LoreVillager3: ; $511F:
    ld hl,$0112
    ; On the West end of this island, there is a village called Abion.
    jp DrawText20x6 ; and ret

_room_43_LoreVillager4: ; $5125:
    ld hl,$0114
    ; Do you know about the ‘Laerma Tree?'
    call DrawText20x6
    call DoYesNoMenu
    ; No
    ld hl,$0116
    ; I hear the Altiplano Plateau on Dezoris is totally covered by them.
    jr nz,+
    ld hl,$013C
    ; Really? What a bore!
+:  jp DrawText20x6 ; and ret

_room_44_LoreVillager5: ; $5139:
    ld hl,$010C
    ; This is the Village of Lore. Thanks to LaShiec, it’s become a wasteland.
    jp DrawText20x6 ; and ret

_room_45_AbionVillager1: ; $513F:
    ld hl,$011C
    ; This village is called Abion.
    jp DrawText20x6 ; and ret

_room_46_AbionVillager2: ; $5145:
    ld hl,$011E
    ; The evil hand of LaShiec has extended to this village as well! Please help us!
    jp DrawText20x6 ; and ret

_room_47_AbionVillager3: ; $514B:
    ld hl,$0120
    ; Some weird freak just moved to this village, and he was carrying a jar or something. It seems he’s been doing experiments on animals. I gotta bad feeling about that guy.
    jp DrawText20x6 ; and ret

_room_48_AbionVillager4: ; $5151:
    ld hl,$0126
    ; I want to try and travel the stars.
    jp DrawText20x6 ; and ret

_room_49_AbionVillager5: ; $5157:
    ld hl,$0128
    ; They say if an animal called a ‘Musk Cat’ eats a certain type of berry, it’ll grow large, and become able to fly! Weird, huh?
    jp DrawText20x6 ; and ret

_room_4a_UzoVillager1: ; $515D:
    ld hl,$012E
    ; This is Uzo Village, on the planet Motavia.
    jp DrawText20x6 ; and ret

_room_4b_UzoVillager2: ; $5163:
    ld hl,$0130
    ; You can pass over antlions if you have a ‘LandMaster.’
    jp DrawText20x6 ; and ret

_room_4c_UzoVillager3: ; $5169:
    ld hl,$0132
    ; To the South of Uzo, there is a village called Casba.
    jp DrawText20x6 ; and ret

_room_4d_UzoVillager4: ; $516F:
    ld hl,$0134
    ; It seems that a dragon has settled in Casba Cave! That dragon has a jewel or something embedded in its head!
    jp DrawText20x6 ; and ret

_room_4e_UzoVillager5: ; $5175:
    ld hl,$013A
    ; Do you know about the ‘Soothe Flute?’
    call DrawText20x6
    call DoYesNoMenu
    ld hl,$013C
    ; Really? What a bore!
    jr z,+
    ld a,(SootheFluteIsUnhidden)
    or a
    jr nz,++
    ld a,1
    ld (SootheFluteIsUnhidden),a
++: ld hl,$013e
    ; Well, this is a secret, but when I went to Palma, I buried it on the outskirts of Gothic Village. Don’t tell anybody!
+:  jp DrawText20x6 ; and ret

_room_4f_UzoVillager6: ; $5194:
    ld hl,$0136
    ; Have you heard of the ‘Frad Cloak?' They say it’s light in weight, but has superb defensive power.
    jp DrawText20x6 ; and ret

_room_50_CasbaVillager1: ; $519A:
    ld hl,$0166
    ; This is Casba Village.
    jp DrawText20x6 ; and ret

_room_51_CasbaVillager2: ; $51A0:
    ld hl,$0168
    ; There’s a dragon living in Casba Cave! I’m so scared!
    jp DrawText20x6 ; and ret

_room_52_AeroCastle1: ; $51A6:
    ld hl,$016A
    ; You can't always trust your eyes in dungeons.
    jp DrawText20x6 ; and ret

_room_53_CasbaVillager3: ; $51AC:
    ld hl,$016C
    ; The people in the village surrounded by gas tell a tale of a legendary shield. They say that a long time ago, [a man named] Perseus used that shield to confront a monster.
    jp DrawText20x6 ; and ret

_room_54_CasbaVillager4: ; $51B2:
    ld hl,$0170
    ; One time I traveled west of the lake, and a frightening, fog-like poison gas was spreading all over! Whatever you do, stay away from there!
    jp DrawText20x6 ; and ret

_room_55_CasbaVillager5: ; $51B8:
    ld hl,$0172
    ; Do you know about the ‘FlowMover’?
    call DrawText20x6
    call DoYesNoMenu
    ; No
    ld hl,$017C
    ; With a FlowMover, you can glide smoothly across the the top of the water. They can really come in handy!
    jr nz,+
    ; Yes
    ld a,1
    ld (FlowMoverIsUnhidden),a
    ld hl,$0174
    ; Well, I bought one on Palma, in the town of Shion, but it turned out to be broken, so I ditched it in Bartevo. What a waste!
+:  jp DrawText20x6 ; and ret

_room_56_Drasgo1 ; $51D1:
    ld hl,$017E
    ; This is Drasgo, a tiny town on the sea.
    jp DrawText20x6 ; and ret

_room_57_Drasgo2: ; $51D7:
    ld hl,$0180
    ; Amazing! You managed to make it here even though they shut down the sea routes and we are no longer allowed to use boats!
    jp DrawText20x6 ; and ret

_room_58_Drasgo3: ; $51DD:
    ld hl,$0184
    ; I hear that there's an enchanted sword in Abion Tower.
    jp DrawText20x6 ; and ret

_room_59_Drasgo4: ; $51E3:
    ld hl,$0186
    ; I once saw a huge floating rock in the sky!
    jp DrawText20x6 ; and ret

_room_5a_ChokoOneesan: ; $51E9:
    ld hl,$0188
    ; It's me, Choko Oneesan! Be brave and strong as you continue your quest!
    jp DrawText20x6 ; and ret

_room_5b_DrasgoCave1; $51EF:
_room_90_DrasgoCave1; $51EF:
    ld hl,$018C
    ; I heard that a store in this city sells an apparatus called a ‘GasClear’, which protects the body against poison gas. The only thing is, I can’t find the damn store! Sheesh!
    jp DrawText20x6 ; and ret

_room_5c_DrasgoCave2: ; $51F5:
_room_91_DrasgoCave2: ; $51F5:
    ld hl,$0190
    ; This is an item shop. What can I do for you? Haah haah! Sorry, I’m just kidding! Please forgive me.
    jp DrawText20x6 ; and ret

_room_5d_DrasgoGasClearSeller: ; 51FB
_room_92_DrasgoGasClearSeller:
    ld hl,1000
    ld (NumberToShowInText),hl
    ld hl,$0194
    ; You must be pretty shocked to see a store in a place like this, huh? ‘GasClears’ are 1000 mesetas. Pretty cheap, no? You wanna buy one?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$019C
    ; Hey, what the hell?! I’m not selling you ANYTHING!
    jp DrawText20x6 ; and ret
+:  ld de,1000
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr nc,+
    ld hl,$019A
    ; Huh? You don’t have enough money? What the hell?! I’m not selling you ANYTHING!
    jp DrawText20x6 ; and ret
+:  ld (Meseta),hl
    ld hl,$0198
    ; Thank you. Please come again.
    call DrawText20x6
    ld a,Item_GasClear
    ld (ItemTableIndex),a
    call HaveItem
    ret z ; You can only have one... even if you pay twice
    jp AddItemToInventory

_room_5e_Skray1: ; $5238:
    ld hl,$01A2
    ; This is Skray, on the planet Dezoris. Pretty cold outside, wasn’t it?
    jp DrawText20x6 ; and ret

_room_5f_Skray2: ; $523E:
    ld hl,$01A4
    ; Nearly all of the Palman immigrants live in this town.
    jp DrawText20x6 ; and ret

_room_60_Skray3: ; $5244:
    ld hl,$01A6
    ; I don’t know much about this planet, but I do know that there are some native Dezorians living in a village inside the the northern mountains.
    jp DrawText20x6 ; and ret

_room_61_Skray4: ; $524A:
    ld hl,$01AA
    ; What? ‘Overthrow LaShiec?’ If you really are going to do that, you must gather all of the Laconian weapons: Sword, Axe, Shield, and Armor. These weapons are more powerful than any others. I’ll be praying for your safety.
    jp DrawText20x6 ; and ret

_room_62_Skray5: ; $5250:
    ld hl,$01B2
    ; Weapons made from laconia conceal holy powers, y’know. I heard that LaShiec despises them, so he hid them here and there throughout the planets of Algol.
    jp DrawText20x6 ; and ret

_room_63_Skray6: ; $5256:
    ld hl,$01B8
    ; Planet Dezoris is made of ice.
    jp DrawText20x6 ; and ret

_room_64_Skray7: ; $525C:
    ld hl,$01BA
    ; There are places inside the ice mountains that can be easily broken.
    jp DrawText20x6 ; and ret

_room_65_Skray8: ; $5262:
    ld hl,$01BC
    ; The area around the Altiplano Plateau is encircled by mountains of ice.
    jp DrawText20x6 ; and ret

_room_66_Skray9: ; $5268:
    ld hl,$01BE
    ; This planet has a solar eclipse once every hundred years. There is a flame lit at this time called an ‘Eclipse Torch’. It is regarded by the Dezorians as sacred.
    jp DrawText20x6 ; and ret

_room_67_Skray10: ; $526E:
    ld hl,$01C4
    ; I heard that all the dead people in the Guaran Morgue have come back to life! How creepy!
    jp DrawText20x6 ; and ret

_room_68_HonestDezorian1: ;
    ld hl,$01C8
    ; Those guys in the village next to us are all a bunch of liars. Be careful, eh.
    jp DrawText20x6 ; and ret

_room_69_HonestDezorian2: ;
    ld hl,$01CA
    ; Corona Tower lies on the other side of the mountains to the North of this village, eh.
    jp DrawText20x6 ; and ret

_room_6a_HonestDezorian3: ; $5280:
    ld hl,$01CC
    ; To the West of Corona Tower is Dezoris Cave, eh. Please send my regards to our comrades there, eh.
    jp DrawText20x6 ; and ret

_room_6b_HonestDezorian4: ; $5286:
    ld hl,$01D0
    ; Laerma trees make berries called ‘Laerma Berries’, eh. Those berries are real tasty, eh. We wanna use them for food, eh, but if we don’t put them into a ‘Laconian Pot’, they just get all shriveled up, eh.
    jp DrawText20x6 ; and ret

_room_6c_HonestDezorian5: ; $528C:
    ld hl,$01D6
    ; Do you know about the ‘Aeroprism’?
    call DrawText20x6
    call DoYesNoMenu
    ; No
    ld hl,$01DA
    ; I hear you can use it to look at other worlds, eh.
    jr z,+
    ; Yes
    ld hl,$01D8
    ; I’d really like to see it at least once, eh.
+:  jp DrawText20x6 ; and ret

_room_6d_HonestDezorian6: ; $52A0:
    ld hl,$01DC
    ; All the people in this village hate those Palmans, eh.
    jp DrawText20x6 ; and ret

_room_6e_DishonestDezorian1: ; $52A6:
    ld hl,$01DE
    ; There's a Life Spring/Fountain of Youth in Corona Tower, y’know.
    jp DrawText20x6 ; and ret

_room_6f_DishonestDezorian2: ; $52AC:
    ld hl,10
    ld (NumberToShowInText),hl
    ld hl,$01E0
    ; There's a warp on the 10th underground floor of Dezoris cave, y’know.
    jp DrawText20x6 ; and ret

_room_70_DishonestDezorian3: ; $52B8:
    ld hl,$01E2
    ; Laerma Berries are colored blue. We use them as a dye, y’know.
    jp DrawText20x6 ; and ret

_room_71_DishonestDezorian4: ; $52BE:
    ld hl,$01E4
    ; If you use a crystal in front of the Laerma Tree, berries will grow, y’know.
    jp DrawText20x6 ; and ret

_room_72_DishonestDezorian5: ; $52C4:
    ld hl,$01E6
    ; This village welcomes Palmans.
    jp DrawText20x6 ; and ret

_room_73_DishonestDezorian6: ; $52CA:
    ; This seems to be a bug in the original - it uses a line from elsewhere.
    ld hl,$01E8
    ; This village is called Sopia. I’m glad that you were able to brave your way through the poison gas.
    jp DrawText20x6 ; and ret

_room_74_SopiaVillageChief: ; $52D0:
    ld hl,$0190
    ld (NumberToShowInText),hl
    ld hl,$01EA
    ; I am the chief of this village. Due to the gas, Sopia is cut off from other towns and villages, and is therefore very poor. Could you by any chance offer a contribution of 400 mesetas?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ld hl,$01F0
    ; I see. What a pity. Hmmm...
    jp DrawText20x6 ; and ret
+:  ld de,400
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr nc,+
    ld hl,$01F2
    ; You are poor as well, eh? What a sad world in which we live.
    jp DrawText20x6 ; and ret
+:  ld (Meseta),hl
    ld a,$01
    ld (PerseusShieldIsUnhidden),a
    ld hl,$01F4
    ; Thank you. According to local legend, the shield that Perseus used when he defeated Medusa is buried under a cactus on the island in the middle of the lake.
    jp DrawText20x6 ; and ret

_room_75_GamerMikiChan: ; $5306:
    ld hl,$01FA
    ; I'm Gamer Miki-chan! Do you own a Master System?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$01FC
    ; Wow! I guess we game the same! After all, the FM sound system is way cool, huh?
    jr z,+
    ld hl,$01FE
    ; Aawww! That’s no good! Hurry up and buy one! Hmph!
+:  jp DrawText20x6 ; and ret

_room_76_Sopia1: ; $531A:
    ld hl,$0200
    ; Before LaShiec’s powerful grasp, this village was very wealthy.
    jp DrawText20x6 ; and ret

_room_77_Sopia2: ; $5320:
    ld hl,$0202
    ; There’s a monk named Tajimu living in the mountains South of the lake.
    jp DrawText20x6 ; and ret

_room_78_Sopia3: ; $5326:
    ld hl,$0204
    ; I heard that Palma is a very beautiful planet. Is it really true?
    call DrawText20x6
    call DoYesNoMenu
    ld hl,$0206
    ; Ooh, I want to go there soo bad!
    jr z,+
    ld hl,$0208
    ; Oh, I see. I want to go to a place with cleaner air.
+:  jp DrawText20x6 ; and ret

_room_79_Sopia4: ; 533A:
    ld hl,$00BA
    ; Hey, you mind if I bum a ‘PelorieMate’?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ld hl,$020C
    ; Cheapskate!
    jp DrawText20x6
+:  ld a,Item_PelorieMate
    call HaveItem
    jr nz,+
    call $28db ; RemoveItemFromInventory
    ld hl,$020A
    ; Thanks. Please come again.
    jp DrawText20x6 ; and ret
+:  ld hl,$020E
    ; Don’t f--- with me!
    jp DrawText20x6 ; and ret

_room_7a_AeroCastle2: ; $5361:
    ld hl,$0210
    ; ...........
    jp DrawText20x6 ; and ret

_room_7b_AeroCastle3: ; $5367:
    ld hl,$026A
    ; Do not defy the great LaShiec.
    jp DrawText20x6 ; and ret

_room_7c_ShortcakeShop: ; $536D:
    ld hl,280
    ld (NumberToShowInText),hl
    ld hl,$024A
    ; I’m sorry for having a store in a place like this. Shortcakes are 280 meseta. Would you like one?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,textShopComeAgain
    ; Take care, come back and see us soon.<wait>
    jp TextBox20x6 ; and ret
+:  ld de,280
    ld hl,(Meseta)
    or a
    sbc hl,de
    jr nc,+
    ld hl,textShopNotEnoughMoney
    ; It looks like you don’t have enough money.<line>
    ; Please come back later.<wait>
    jp TextBox20x6 ; and ret
+:  ld a,(InventoryCount)
    cp $18
    jr c,+
    ld hl,textShopInventoryFull
    ; You can’t carry any more. Come back when you can.<wait>
    jp TextBox20x6 ; and ret
+:  ld (Meseta),hl
    ld hl,$020A
    ; Thank you!<wait>
    call DrawText20x6
    ld a,Item_Shortcake
    ld (ItemTableIndex),a
    call HaveItem
    ret z ; You can't have two
    jp AddItemToInventory ; and ret

_room_7d_MahalCaveMotavianPeasant: ; $53B7:
    ld a,Enemy_MotavianPeasant
    ld (EnemyNumber),a
    call LoadEnemy
    ld a,(PartySize)
    cp 3
    ; No Lutz yet
    ld hl,$00AC
    ; Since the orders are from the Governor-General, Lutz will probably listen.
    jr nz,+
    ; Have Lutz
    ld hl,$00B2
    ; Yahoo!
+:  jp DrawText20x6 ; and ret

_room_7e_Lutz: ; $53CF:
    ld a,(PartySize)
    cp 3
    jp nc,_ScriptEnd
    ; No Lutz yet
    ld a,$3B
    call LoadDialogueSprite
    call SpriteHandler
    ld hl,$00AE
    ; Who are you? I'm in the middle of training right now. Please don’t interrupt.
    call DrawText20x6
    ld a,Item_GovernorGeneralsLetter
    call HaveItem
    ret nz
    call RemoveItemFromInventory
    pop hl
    call Close20x6TextBox
    call MenuWaitForButton
    ld a,1
    ld (HaveLutz),a
    ld iy,CharacterStatsLutz
    ld (iy+$0a),$01
    ld (iy+$0b),$11
    call InitialiseCharacterStats
    ld a,3
    ld (PartySize),a
    jp _LABEL_46C8_

_room_7f_LuvenosAssistant: ; $5411:
    ld hl,LuvenoState
    ld a,(hl)
    cp 2
    jp nc,_ScriptEnd ; Nothing if we haven't been to Luveno yet
    ld a,$10
    call LoadDialogueSprite
    call SpriteHandler
    ld hl,LuvenoState
    ld a,(hl)
    cp 1
    ld de,$00DC
    ; I’m busy right now, so please don’t interrupt.
    jr nz,+
    ld (hl),2 ; Progress LuvenoState
    ld de,$00F6
    ; Huh? You say Dr. Luveno is back... and he’s going to build a spaceship?! Well, I guess I have no choice [but to help]. I’ll go there right away.
+:  ex de,hl
    jp DrawText20x6 ; and ret

_room_80_5436:
    ld hl,$00F8
    ; NO MAN THAT GOES INTO THE ROOM INTHE FAR CORNER HAS EVER COME OUT ALIVE! AHA-HA-HA!
    jp DrawText20x6 ; and ret

_room_81_Luveno_Prison: ; $543C:
    ld a,(LuvenoState)
    or a
    jp nz,_ScriptEnd ; Nothing if he is not in prison any more
    ld a,$34
    call LoadDialogueSprite
    call SpriteHandler
    ld hl,LuvenoPrisonVisitCounter
    ld a,(hl)
    or a
    jr nz,+
    ; First visit
    inc (hl)
    ld hl,$00DE
    ; I’m Luveno. You came here to rescue me? That’s not really necessary. You should go home.
    jp DrawText20x6 ; and ret
+:  cp 1
    jr nz,+
    ; Second visit
    inc (hl)
    ld hl,$00E0
    ; What? Did you say 'build a spaceship?' [BAKA MO YASUMIYASUMI IE.]  Do you think I want to be responsible for something like that?
    jp DrawText20x6 ; and ret
+:  ; Third visit
    ld hl,$00e2
    ; Hmmm... Didn’t I tell you to-- Aah, I give up! You must promise to do whatever I ask. Agreed?
    call DrawText20x6
    call DoYesNoMenu
    ld hl,$00D4
    ; Well, if you won’t promise, then I’m afraid I can’t help you.
    jr nz,+
    ld hl,LuvenoState
    ld (hl),1 ; Freed
    ld hl,$00E4
    ; Good. Well then, I’m going to go to Gothic Village and make the proper arrangements. Meet me there later. Oh, don’t worry. I can make it there myself.
+:  jp DrawText20x6 ; and ret

_room_82_TriadaPrisonGuard1: ; $547D:
    ld a,Enemy_RobotPolice
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$00E6
    ; Do you have a Roadpass?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ; Yes
    ld a,Item_RoadPass
    call HaveItem
    jr nz,+
    ld hl,$0024
    ; Okay, you may pass.
    jp DrawText20x6 ; and ret
+:  ld hl,$00E8
    ; You are very brave. Please allow me to kill you...
    call DrawText20x6
    call Close20x6TextBox
    jp _LABEL_55E9_

_room_83_TriadaPrisoner1: ; $54A9:
    ld hl,$00BA
    ; Hey, you mind if I bum a ‘PelorieMate’?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ld hl,$00C2
    ; I ain’t talking to you, then. Get the hell away from me.
    jp DrawText20x6 ; and ret
+:  ld a,Item_PelorieMate
    call HaveItem
    jr nz,+
    call $28db ; RemoveItemFromInventory
    ld hl,$00EA
    ; Thanks. Y’know, no matter what people say, spiders are actually very wise creatures.
    jp DrawText20x6 ; and ret
+:  ld hl,$00CE
    ; Well? Let's see it.
    jp DrawText20x6 ; and ret

_room_84_TriadaPrisoner2: ; $54D0:
    ld hl,$00EC
    ; Do you know of a robot called ‘Hapsby’?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$013C
    ; Really? What a bore!
    jr z,+
    ld hl,$0124
    ; It’s a robot made out of laconia! But it seems to have been dumped into a scrap heap!
+:  jp DrawText20x6 ; and ret

_room_85_TriadaPrisoner3: ; $54E4:
    ld hl,$00EE
    ; I hear that on the other side of the mountains there's a whole bunch of lava because of the volcanic eruptions.
    jp DrawText20x6 ; and ret

_room_86_TriadaPrisoner4: ; $54EA:
    ld hl,$00F0
    ; The tower nestled in the Gothic Mountains is called ‘Medusa’s Tower.’
    jp DrawText20x6 ; and ret

_room_87_TriadaPrisoner5: ; $54F0:
    ld hl,$00F2
    ; Whassup? I haven’t seen any people in a long time! Let’s talk!
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$014C
    ; Y’know, I’ve got a friend in Bartevo. But those lava pools are making things real tough right now, I guess. If you see my friend, could you tell him I said ‘hi?’
    jr z,+
    ; No
    ld hl,$013C
    ; Really? What a bore!
+:  jp DrawText20x6 ; and ret

_room_88_TriadaPrisoner6: ; $5504:
    ld a,Enemy_Tarantula
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$00F4
    ; There’s this chemical called ‘Polymeteral’ that they say will dissolve any material except laconia.
    jp DrawText20x6 ; and ret

_room_89_MedusasTower1: ; $5512:
    ld hl,$00FC
    ; You’ve gotten far. Soon you will know the truth.
    jp DrawText20x6 ; and ret

_room_8a_MedusasTower2: ; $5518:
    ld hl,$00FE
    ; Get out of here while you're still breathing! You don’t know what you’re up against!
    jp DrawText20x6 ; and ret

_room_8b_MedusasTower3: ; $551E:
    ld hl,$0100
    ; Oh, what a brave young lady you are! Beware of traps.<wait>
    jp DrawText20x6 ; and ret

_room_8c_BartevoCave: ; $5524:
    ld hl,$010A
    ; The drug store in Abion sells Polymeteral, I hear.
    jp DrawText20x6 ; and ret

_room_8d_AvionTower: ; $552A:
    ld hl,$021A
    ; Leaving? Better do it now.
    jp DrawText20x6 ; and ret

_room_8e_5530:
    ld hl,$0148
    ; I am the World’s Greatest Fortune Teller, Damoa! Do you believe in my amazing powers?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
-:  ld hl,$0152
    ; What did you say? You are very disobedient. I think you should leave.
    jp DrawText20x6 ; and ret
+:  ; Yes
    ld hl,$014e
    ; Good. Good.
    call DrawText20x6
    ld hl,$0150
    ; I sense that you are looking for something, yes?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,-
    ; Yes
    ld hl,$014E
    ; Good. Good.
    call DrawText20x6
    ld hl,$0154
    ; I see that you are looking for Alex Ossale, yes?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,-
    ; Yes
    ld hl,$014E
    ; Good. Good.
    call DrawText20x6
    ld hl,$0156
    ; Everything I say is correct. Understand?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ; Yes
    ld hl,$0158
    ; In that case, perhaps you should come back later.
    jp DrawText20x6 ; and ret
+:  ; No
    ld hl,$015a
    ; Do you oppose me?
    call DrawText20x6
    call DoYesNoMenu
    jr z,-
    ; No
    ld hl,$015C
    ; Is that so... You show considerable promise. I shall give you this crystal as a reward.
    call DrawText20x6
    ld a,Item_DamoasCrystal
    ld (ItemTableIndex),a
    call HaveItem
    ret z ; You can't have two
    jp AddItemToInventory ; and ret

_room_8f_5597:
    ld hl,$0160
    ; Did you come here seeking Baya Marlay tower?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$0162
    ; Then you will be destroyed!
    jr z,+
    ; No
    ld hl,$0164
    ; Then you should turn back.
    jp DrawText20x6 ; and ret

_room_93_55AB:
    ld a,Enemy_RobotPolice
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$021C
    ; Do you have a Roadpass?
    call DrawText20x6
    call DoYesNoMenu
    jr nz,+
    ld a,Item_RoadPass
    call HaveItem
    jr nz,+
    ld hl,$021E
    ; Let me see here... Hm? This is a fake! Don't think you can fool me just because I'm a robot! Let me show you to your cell.
    call DrawText20x6
    call Close20x6TextBox
    pop hl
    ld hl,$159C
    ld (DungeonPosition),hl
    ld a,$01
    ld (DungeonFacingDirection),a
    ld hl,FunctionLookupIndex
    ld (hl),$0A
    ret

+:  ld hl,$00E8
    ; You are very brave. Please allow me to kill you...
    call DrawText20x6
    call Close20x6TextBox
_LABEL_55E9_:
    call _LABEL_116B_
    ld a,(CharacterSpriteAttributes)
    or a
    call nz,_LABEL_1D3D_
    pop hl
    ret

_room_94_55F5:
    ld hl,$0222
    ; I wonder if you could help me escape from this place, but it’s hopeless.
    jp DrawText20x6 ; and ret

_room_95_55FB:
    ld hl,$0224
    ; Defeat LaShiec?! That’s nonsense!
    jp DrawText20x6 ; and ret

_room_96_5601:
    ld hl,$0226
    ; We will all be sacrificed in the name of LaShiec! Agh!
    jp DrawText20x6 ; and ret

_room_97_5607:
    ld hl,$022E
    ; All those who have gone up against LaShiec have had their souls taken by his magic.
    jp DrawText20x6 ; and ret

_room_98_560D:
    ld hl,$0232
    ; There is a tower on top of Baya Mahrey knoll. There must be secrets hidden inside.
    jp DrawText20x6 ; and ret

_room_99_5613:
    ld hl,$0218
    ; You’d better not go any further, ‘cuz there’s a guard station up there.
    jp DrawText20x6 ; and ret

_room_9a_5619:
    ld hl,$0214
    ; Oh! So you’re locked up in here as well? How tragic. There IS a way to get outside, but I'D rather stay here where it's nice and cozy.
    jp DrawText20x6 ; and ret

_room_9b_561F:
    ld a,Enemy_RobotPolice
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$009C
    ; Did you bring a present for the Governor-General?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$00A2
    ; Leave at once!
    call DrawText20x6
    jr ++
+:  ld a,Item_Shortcake
    call HaveItem
    jr nz,+
    push bc
      call RemoveItemFromInventory
    pop bc
    ld a,$FF
    ld (HaveGivenShortcake),a
    ld hl,$009E
    ; Well then, I’ll look after this ‘Shortcake’.
    jp DrawText20x6 ; and ret
+:  ld hl,$00A0
    ; That is NOT a suitable gift.
    call DrawText20x6
++:  pop hl
    call Close20x6TextBox
    call _LABEL_1738_
    jp _LABEL_6B2F_

_room_9c_TorchBearer: ; $5661:
    ld hl,$023E
    ; This flame is lit during each centennial solar eclipse. If you give me a dragon’s jewel, however, I’ll share the flame with you. Do we have an agreement?
    call DrawText20x6
    call DoYesNoMenu
    jr z,+
    ; No
    ld hl,$0246
    ; You don’t want it?! Then, ah, for what did you come here?
    jp DrawText20x6 ; and ret
+:  ; Yes
    ld a,Item_CarbuncleEye
    call HaveItem
    jr nz,+
    call RemoveItemFromInventory
    ld a,Item_EclipseTorch
    ld (ItemTableIndex),a
    call AddItemToInventory
    ; No need to check for space as we just removed the Carbuncle Eye
    ld hl,$0244
    ; Well then, please accept this ‘Eclipse Torch’.
    jp DrawText20x6 ; and ret
+:  ld hl,$0248
    ; You mean to say you don’t have the jewel?! Don’t toy with me!
    jp DrawText20x6 ; and ret

_room_9d_Tajim: ; $5690:
    ld a,Enemy_Tajim
    ld (EnemyNumber),a
    call LoadEnemy
    ld a,($c43b)
    ld b,a
    ld a,Item_Armour_FradMantle ; ???
    cp b
    jr z,+
    call HaveItem
    jr nz,++
+:  ld hl,$0258
    ; There is nothing more I can teach you.
    jp DrawText20x6 ; and ret
++: ; Check if Lutz has joined the party
    ld a,(PartySize)
    cp 3
    jr nc,++
    ; No Lutz
    ld hl,$025A
    ; Who, may I ask, are you? I have a student, Lutz, in the Cave of Magic. Do you know him?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$025E
    ; There is something I must tell Lutz. Would you please escort him to me?
    jr z,+
    ; No
    ld hl,$0260
    ; I see. In that case, I guess it’s pointless for us to talk.
+:  jp DrawText20x6 ; and ret
++:  ld hl,$024C
    ; Ah. My student, Lutz! I see you are finally on your way to defeating LaShiec.
    call DrawText20x6
    ; Check if Lutz is dead
    ld a,(CharacterStatsLutz.IsAlive)
    or a
    jr nz,+
    ld hl,$02A8
    ; ...Lutz? Oh, I see, he's dead. You there, go revive Lutz at a church and bring him back here.
    jp DrawText20x6 ; and ret
+:  ld hl,$024E
    ; That being the case, I'll give you your final test: a duel with me!
    call DrawText20x6
    call Close20x6TextBox
    ; Preserve Lutz' HP but everyone else's IsAlive, to make a Lutz-only fight
    ld a,(CharacterStatsLutz.HP) ; HP
    push af
      ld a,(CharacterStatsAlis.IsAlive)
      push af
        ld a,(CharacterStatsMyau.IsAlive)
        push af
          ld a,(CharacterStatsOdin.IsAlive)
          push af
            xor a
            ld (CharacterStatsAlis.IsAlive),a
            ld (CharacterStatsMyau.IsAlive),a
            ld (CharacterStatsOdin.IsAlive),a
            call _LABEL_116B_
          pop af
          ld (CharacterStatsOdin.IsAlive),a
        pop af
        ld (CharacterStatsMyau.IsAlive),a
      pop af
      ld (CharacterStatsAlis.IsAlive),a
    pop af
    ld b,a ; Lutz' HP before
    ld a,(CharacterStatsLutz.HP) ; Lutz' HP now
    or a
    jr nz,+
    ; Lutz' HP s 0
    ; Restore it (and bring him back to life)
    ld a,b
    ld (CharacterStatsLutz.HP),a
    ld a,1
    ld (CharacterStatsLutz.IsAlive),a
    ld hl,$0256
    ; You still haven’t trained enough. You should come back later.
    jp DrawText20x6 ; and ret
+:  ; Lutz won
    ld hl,$0250
    ; You’ve become strong, my boy! You have all the power you’ll ever need. Please use this Frad Cloak. It is my gift to you. It will protect your body from harm. Well then, you’d best be on your way.
    call DrawText20x6
    ld a,Item_Armour_FradMantle
    ld (ItemTableIndex),a
    jp AddItemToInventory

_room_9e_ShadowWarrior:
    ld a,Enemy_FakeLaShiec
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$0262
    ; Make your move, fools. I can see right through you.
    call DrawText20x6
    call Close20x6TextBox
    call _LABEL_574F_
    ld a,$FF
    ld (HaveBeatenShadow),a
    ld hl,$0266
    ; I am King LaShiec’s shadow warrior. You have gained nothing by defeating me! Hee hee hee!
    jp DrawText20x6 ; and ret

_LABEL_574F_:
    call _LABEL_116B_
    ld a,(FunctionLookupIndex)
    cp $02
    ret nz
    pop hl
    pop hl
    ret

_room_9f_LaShiec: ; $575B:
    ld a,(HaveBeatenLaShiec)
    or a
    jp nz,_ScriptEnd
    ld a,Enemy_LaShiec
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$026C
    ; And so you finally arrive. How fortunate you are. Do you really wish to defeat me?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$026E
    ; I see. Then perhaps I should show you the error in your judgment!
    jr z,+
    ld hl,$0270
    ; You have already wasted too much of my time. I shall make you regret it!
+:  call DrawText20x6
    call Close20x6TextBox
    call _LABEL_574F_
    ld a,1
    ld (HaveBeatenLaShiec),a
    ld hl,$02AA
    ; What?! Could it be that I die? What a disgrace. I shall live again!
    ; LaShiec has fallen. Alisa’s wish has come true. Surely even Nero will be rejoicing in heaven. Now let's hurry back to Paseo and see the Governor-General!
    jp DrawText20x6 ; and ret

_room_a0_EppiWoodsNoCompass:
    ld hl,textEppiWoodsCantPass
    jp TextBox20x6 ; and ret

_room_a1_HapsbyScrapHeap:
_room_a2_5795:
_room_af_LaermaTree:
_room_b0_TopOfBayaMarlay:
_room_b6_5795:
    call MenuWaitForButton
_room_a3_TaironStone:
    call _LABEL_1D3D_
    pop hl
    ret

_NothingInterestingHere:
    ld hl,textNothingUnusualHere
    ; There doesn’t seem to be anything particularly unusual here.
    call TextBox20x6
    jp Close20x6TextBox ; and ret


GetHapsby:
    ld a,Item_Hapsby
    ld (ItemTableIndex),a
    call HaveItem
    jr z,_NothingInterestingHere
    call Close20x6TextBox
    ld hl,_RAM_C801_
    inc (hl)
    call SpriteHandler
    call MenuWaitForButton
    ld hl,$012C
    ; I am Hapsby. Thanks for getting me out of that scrap heap. Let me pilot the ‘Luveno’ for you, okay?
    call DrawText20x6
    jp AddItemToInventory ; and ret

CheckFlowMover:
    ; Is it unhidden?
    ld a,(FlowMoverIsUnhidden)
    or a
    jr z,_NothingInterestingHere
    ; Do we have Hapsby?
    ld a,Item_Hapsby
    ld (ItemTableIndex),a
    call HaveItem
    jr nz,_NothingInterstingHere
    ; Do we have it already?
    ld a,Item_Vehicle_FlowMover
    ld (ItemTableIndex),a
    call HaveItem
    jr z,_NothingInterstingHere
    ld hl,$0178
    ; You found the ‘FlowMover’! Hapsby fixed the areas that were damaged, so you can use it now!
    call DrawText20x6
    call Close20x6TextBox
    jp AddItemToInventory ; and ret

FindTairon:
    ld hl,$00FA
    ; It seems that something turned this person into stone! Maybe he can be returned to normal...
    call DrawText20x6
    jp Close20x6TextBox ; and ret

_room_a4_CoronoTowerDezorian1: ; 57F5:
    ld a,Enemy_DezorianHead
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$0234
    ; What is your business here? Don’t cause any trouble!
    jp DrawText20x6 ; and ret

_room_a5_GuaranMorgue: ; $5803:
    ld hl,$0234
    ; What is your business here? Don’t cause any trouble!
    jp DrawText20x6 ; and ret

_room_a6_CoronaDungeonDishonestDezorian: ; $5809:
    ld a,Enemy_Dezorian
    ld (EnemyNumber),a
    call LoadEnemy
    xor a
    ld (_RAM_CBC3_),a
    ld hl,$0238
    ; Be careful up ahead. You should turn left at the fork in the path.<wait>
    jp DrawText20x6 ; and ret

_room_a7_581B:
    ld a,Enemy_Serpent
    ld (EnemyNumber),a
    call LoadEnemy
    pop hl
    ; Make it drop no money
    ld hl,$0000
    ld (EnemyMoney),hl
    jp _LABEL_116B_

_room_a8_BayaMarlayPrisoner: ; $582D:
    ld hl,$0228
    ; Have you gotten the armor from Guaran?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$022C
    ; Damn! You’re pretty cool!
    jr z,+
    ld hl,$022A
    ; It’s on the other side of a pitfall!
+:  jp DrawText20x6 ; and ret

_room_a9_BuggyUnused: ; $5841:
    ; Presumably unused...
    ld a,Enemy_MotavianPeasant
    ld (EnemyNumber),a
    call LoadEnemy
    ld hl,$0212
    ; I see. Then indeed, you are the daughter of the King of Algol, [and our new Queen]. Please let me help you [however I can].
    jp DrawText20x6 ; and ret

_room_aa_LuvenoGuard: ; $584F:
    ld a,(LuvenoState)
    cp $07
    jr nc,+
    ld hl,$0282
    ; Hey! Keep outta my turf!<wait>
    jp DrawText20x6 ; and ret
+:  ld hl,$0284
    ; I guess I’ve got to do what Dr. Luveno says. Go on through.<wait>
    call DrawText20x6
    ld a,(HLocation)
    cp $40
    ld hl,_DATA_5873_
    jr nc,+
    ld hl,_DATA_5876_
+:  call _LABEL_7B1E_
    ret

; Data from 5873 to 5875 (3 bytes)
_DATA_5873_:
.db $07 $1B $1B

; Data from 5876 to 5878 (3 bytes)
_DATA_5876_:
.db $07 $1B $1D

_room_ab_DarkForce: ; $5879:
    ld a,MusicDarkForce
    ld (NewMusic),a
    call Pause256Frames
    ld a,$1F
    ld (SceneType),a
    call LoadSceneData
    ld hl,Frame2Paging
    ld (hl),:DarkForceSpritePalette
    ld hl,DarkForceSpritePalette
    ld de,TargetPalette+16 ; sprite palette
    ld bc,$0010
    ldir
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    ld a,Enemy_DarkForce
    ld (EnemyNumber),a
    call LoadEnemy
    call MenuWaitHalfSecond
    ld a,$20
    ld (SceneType),a
    call _LABEL_574F_
    call Close20x6TextBox
    ; Did we win?
    ld a,(CharacterStatsAlis)
    or a
    jr nz,+
    ; No
    ld hl,textDarkForceResurrection
    call TextBox20x6
    call Close20x6TextBox

_room_ac_58C6:
+:  call FadeOutFullPalette
    ld a,$1D
    ld (SceneType),a
    call LoadSceneData
    ld a,$0C
    call ExecuteFunctionIndexAInNextVBlank
    call FadeInWholePalette
    ld a,$35
    call LoadDialogueSprite
    call SpriteHandler
    ld hl,$0272
    ; Oh! My friends, please forgive me. My mind and body seem to have been enchanted by some sort of evil force.
    ; Well done! You have saved the world! If you had taken any longer, terrible events might have come to pass. I extend you my utmost appreciation.
    ; And now, Alisa, I have something I wish to tell you:
    ; The truth is, your father was once the King of Algol.
    ; Now that the demon’s fortress has been destroyed, and LaShiec is no more, will be your father’s successor and become the Queen of Algol?
    call DrawText20x6
    call DoYesNoMenu
    ; Yes
    ld hl,$0212
    ; I see. Then indeed, you are the daughter of the King of Algol, [and our new Queen]. Please let me help you [however I can].
    jr z,+
    ; No
    ld hl,$0230
    ; I see. [You must do as you wish]. You are welcome to return at anytime.
+:  call DrawText20x6
    call Close20x6TextBox
    pop hl
    jp _LABEL_47B5_

_room_ad_58FC:
    ld hl,$02A4
    ; This is Alisa’s house. Nobody is here.
    jp DrawText20x6 ; and ret

_room_ae_5902:
    ld a,(_RAM_C2F0_)
    ld d,a
    ld e,0 ; Character number
-:  ld a,e
    ld (TextCharacterNumber),a
    rr d
    push de
      ld hl,textPlayerDied
      ; <player> died.
      call c,TextBox20x6
    pop de
    inc e
    ld a,e
    cp $04
    jr nz,-
    ld b,4
--: ld a,b
    dec a
    call PointHLToCharacterInA
    jr nz,+
    djnz --
    jp _LABEL_175E_

+:  jp Close20x6TextBox ; and ret

_room_b1_592D:
    ld hl,$023A
    ; Don’t let this get out, but there's a fortune-teller named Damoa who is in possession of a crystal that LaShiec hates. There must be something secret about that crystal.
    jp DrawText20x6 ; and ret

_room_b2_OtegamiChieChan: ; $5933:
    ld hl,$027A
    ; I am 'Otegami Chie-chan!’ Thanks for all your letters. Please tell us how you feel about this game. We’ll be waiting.
    jp DrawText20x6 ; and ret

_room_b3_FlightToMotavia: ; $5939:
    ld hl,textBoundForMotavia
    ; BOUND FOR MOTAVIA. GETTING ON?
    call TextBox20x6
    call DoYesNoMenu
    ret nz
    ld a,$81
    ld (_RAM_C2E9_),a
    ret

_room_b4_FlightToPalma: ; $5949:
    ld hl,textBoundForPalma
    ; BOUND FOR PALMA. GETTING ON?
    call TextBox20x6
    call DoYesNoMenu
    ret nz
    ld a,$82
    ld (_RAM_C2E9_),a
    ret

_room_b5_HapsbyTravel: ; $5959:
-:  ld hl,textHapsby_ChooseDestination
    ; Where would you like to go?
    call TextBox20x6
    ; Select a planet
    push bc
    call _LABEL_3B4B_
    bit 4,c
    pop bc
    ret nz
    ld d,a
    ; Are we already there?
    ld a,(_RAM_C309_)
    rrca
    rrca
    rrca
    and $03
    ld e,a
    cp d
    jr nz,+
    ; Print the error
    or a
    ld hl,textHapsby_ThisIsGothic
    ; This IS Gothic.
    jr z,++
    dec a
    ld hl,textHapsby_ThisIsUzo
    ; This IS Uzo.
    jr z,++
    ld hl,textHapsby_ThisIsSkray
    ; This IS Skray.
++: call TextBox20x6
    jr -

+:  ld a,d
    or a
    ld hl,textHapsby_DestinationGothic
    ; Destination: Gothic, on Palma. Confirm?
    jr z,+
    dec a
    ld hl,textHapsby_DestinationUzo
    ; Destination: Uzo, on Motabia. Confirm?
    jr z,+
    ld hl,textHapsby_DestinationSkray
    ; Destination: Skray, on Dezoris. Confirm?
+:  push de
    call TextBox20x6
    call DoYesNoMenu
    pop de
    jr nz,-
    ; Current * 3 + next
    ld a,e
    add a,a
    add a,e
    add a,d
    ld d,$00
    ld e,a
    ld hl,_table
    add hl,de
    ld a,(hl)
    ld (_RAM_C2E9_),a
    ret
_table:
.db $81 $83 $84
.db $85 $82 $86
.db $87 $88
.ends
; followed by
.orga $59ba
.section "Draw text 20x6" overwrite
; de = 1-based table offset * 2
DrawText20x6:          ; $59ba
    ld a,:ScriptLookup ; Page in script
    ld (Frame2Paging),a
    ld de,ScriptLookup-2
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a             ; look up text
    jp TextBox20x6     ; Draw text and ret
.ends
; followed by
.orga $59ca
.section "Say something and close 20x8 box" overwrite
_badScriptIndex:                ; $59ca
    ld hl,_text        ; see below
    call TextBox20x6
    jp Close20x6TextBox
_text:
.db $1f $3d $00 $49 $2b $35 $27 $21 $33 $00 $40 $07 $13 $02 $1f $0e $2e $4c $58
; マダ プロ グラムガ デキテイマセン.
; MaDa PuRoGuRaMuGa DeKiTeIMaSeN.[Exit after button press]
; The program is not made yet.
; or
; This feature hasn't been coded yet.
.ends
; followed by
.orga $59e6
.section "Sort sprite entity table and update sprite table" overwrite
SpriteHandler:         ; $59e6
    ld hl,_RAM_C289_
    ld (_RAM_C287_),hl
    ld de,_RAM_c289_+2
    ld bc,$e
    ld (hl),$00
    inc hl
    ld (hl),$FF
    dec hl
    ldir               ; Fill _RAM_c289_ with $00, $ff

    ld hl,SpriteTable
    ld (NextSpriteY),hl ; Set NextSpriteY to first entry
    ld hl,SpriteTable.XNs
    ld (NextSpriteX),hl ; Set NextSpriteX to first entry
    ld iy,CharacterSpriteAttributes
    ld bc,$0800        ; b = 8, c = 0
-:  ld a,(iy+$00)      ; CharacterSpriteAttributes+00 = ???
    and $7f            ; strip high bit
    jr z,+             ; if rest is 0 then skip -------------------------+
    push bc            ;                                                 |
      ld hl,_DATA_5AA3_ - 2
      call FunctionLookup ;                                              |
    pop bc             ;                                                 |
    or a               ; if result == 0 then skip again -----------------+
    jp z,+             ;                                                 |
    ld hl,(_RAM_C287_)
    ld a,(iy+2)        ; CharacterSpriteAttributes+2 = ???               |
    ld (hl),a          ; Copy to hl                                      |
    inc hl             ;                                                 |
    ld (hl),c          ; 0?                                              |
    inc hl             ;                                                 |
    ld (_RAM_C287_),hl
+:  ld de,32           ;                                 <---------------+
    add iy,de          ; Move iy to next CharacterSpriteAttributes
    inc c              ; and inc c
    djnz -             ; repeat 8 times???

    ld de,_RAM_c289_        ; Sort _RAM_c289_ into increasing numerical order by 1st byte in each entry (?)
    ld b,3             ; counter
--: push bc            ; <-----------------------------+
        ld l,e         ; hl = de                       |
        ld h,d         ;                               |
        inc hl         ; hl = de+2                     |
        inc hl         ;                               |
-:      ld a,(de)      ; <---------------------------+ |
        cp (hl)        ;                             | |
        jr nc,+        ; if lowbyte(de)<lowbyte(hl): | |
        ld c,a         ;                             | |
        ld a,(hl)      ;                             | |
        ld (hl),c      ; Swap words (de) and (hl)    | |
        ld (de),a      ;                             | |
        inc hl         ;                             | |
        inc de         ;                             | |
        ld a,(de)      ;                             | |
        ld c,a         ;                             | |
        ld a,(hl)      ;                             | |
        ld (hl),c      ;                             | |
        ld (de),a      ;                             | |
        dec hl         ;                             | |
        dec de         ;                             | |
+:      inc hl         ; move hl forward 1 word      | |
        inc hl         ;                             | |
        djnz -         ; repeat 3 times -------------+ |
        inc de         ; then move de forward 1 word   |
        inc de         ;                               |
    pop bc             ;                               |
    djnz --            ; and repeat 3 times -----------+

    ld hl,SceneType
    ld b,8             ; counter (number of entries in _RAM_c289_)
-:  ld a,(hl)          ; If (hl)==$ff then skip:
    cp $FF
    jr z,++
    push bc
    push hl
      ld l,a
      ld h,$00
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld de,CharacterSpriteAttributes
      add hl,de
      push hl
      pop iy         ; iy = CharacterSpriteAttributes + value*32
      cp 4           ; Compare value to 4
      ld a,:CharacterSpriteData
      ld bc,CharacterSpriteData
      jr c,+         ; if value>=4:
      ld a,:EnemySpriteDataTable
      ld bc,EnemySpriteDataTable
+:    ld (Frame2Paging),a ; Set page
      call UpdateSprites
    pop hl
    pop bc
++: inc hl             ; Move to next entry in _RAM_c289_
    inc hl
    djnz -             ; and repeat
    ld hl,(NextSpriteY)
    ld (hl),208        ; Set last sprite y to 208 = no more sprites
    ret
.ends
; followed by
.orga $5a94
.section "Zero iy structure +1 to +31" overwrite
ZeroIYStruct:
    push iy
    pop hl
    inc hl
    ld e,l
    ld d,h
    inc de
    xor a
    ld (hl),a
    ld bc,$1e
    ldir               ; Zero (iy+1) to (iy+31)
    ret
.ends
; Jump Table from 5AA3 to 5ACE (22 entries,indexed by CharacterSpriteAttributes)
_DATA_5AA3_:
.dw _LABEL_5C1B_ _LABEL_5C50_ _LABEL_5C5C_ _LABEL_5C61_ _LABEL_5C6D_ _LABEL_5C72_ _LABEL_5C7E_ _LABEL_5C83_
.dw _LABEL_5CCB_ _LABEL_5CEC_ _LABEL_5E03_ _LABEL_5E4A_ _LABEL_5EDF_ _LABEL_5F15_ _LABEL_601C_ _LABEL_60A7_
.dw _LABEL_60AA_ _LABEL_60EE_ _LABEL_612A_ _LABEL_6166_ _LABEL_5FAC_ _LABEL_5FD7_
;.ends
; followed by
.orga $5acf
.section "Update character sprites" overwrite
UpdateSprites:         ; $5acf
    ld l,(iy+1)        ; hl = CharacterSpriteAttributes+1 = character number
    ld h,$00
    add hl,hl          ; Double
    add hl,bc          ; and add bc = offset
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a             ; hl = data there = pointer to byte
    ld b,(hl)          ; b = that byte = count
    push bc
      inc hl
      ld de,(NextSpriteY)
      ld c,(iy+2)    ; Character sprites base Y position
-:    ld a,(hl)
      add a,c
      ld (de),a      ; set (de) to next byte + sprite base y
      inc de
      inc hl
      djnz -         ; repeat
      ld (NextSpriteY),de  ; Update NextSpriteY
    pop bc
    ld de,(NextSpriteX)
    ld c,(iy+4)        ; Character sprites base X position
-:  ld a,(hl)          ; repeat with x positions and tile numbers of sprites
    add a,c
    ld (de),a          ; x position
    inc de
    inc hl
    ld a,(hl)
    ld (de),a          ; tile number
    inc hl
    inc de
    djnz -
    ld (NextSpriteX),de
    ret
.ends
; followed by
.orga $5b07
.section "Output sprite table from RAM to VDP" overwrite
UpdateSpriteTable:
    ld hl,SpriteTable
    ld de,SpriteTableAddress
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi64
    ld hl,SpriteTable.XNs
    ld de,SpriteTableAddress+$80
    rst SetVRAMAddressToDE
    ; fall through
.ends
; depends on being followed by
.orga $5b1a
.section "outi block" overwrite
; outi instruction 128/64/32 times to output 128/64/32 bytes
outi128:
.rept 64
    outi
.endr
outi64:                ; $5b9a
.rept 32
    outi
.endr
outi32:                ; $5bda
.rept 32
    outi
.endr
    ret
.ends
; followed by
.orga $5c1b
.section "Sprite handler lookup functions" overwrite
_LABEL_5C1B_:
    ld b,$01
_LABEL_5C1D_:
    push bc
      call ZeroIYStruct
      inc (iy+0)
    pop bc
    ld (iy+2),$60      ; ???
    ld a,(_RAM_C2EA_)
    and $03            ; if _RAM_c2ea_ is a multiple of 4
    ld a,$84           ; then a=$84
    jr nz,+
    ld a,$80           ; else a=$80
+:  ld (iy+$04),a
    ld (iy+$12),$01
    ld (iy+$01),b      ; depends on lookup function
    ld (iy+$11),$01
    ld a,c
    or a
    ld a,$00
    jr nz,+
    ld a,$03
+:  ld (iy+$0a),a
    ld a,$FF
    ret
.ends
.orga $5c50

; 2nd entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C50_:
    ld de,_DATA_5C8F_
    ld hl,_DATA_5C93_
    call _LABEL_5D14_
    ld a,$FF
    ret

; 3rd entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C5C_:
    ld b,$02
    jp _LABEL_5C1D_

; 4th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C61_:
    ld de,$5CA3
    ld hl,_DATA_5CA7_
    call _LABEL_5D14_
    ld a,$FF
    ret

; 5th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C6D_:
    ld b,$03
    jp _LABEL_5C1D_

; 6th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C72_:
    ld de,$5C8F
    ld hl,_DATA_5C93_
    call _LABEL_5D14_
    ld a,$FF
    ret

; 7th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C7E_:
    ld b,$04
    jp _LABEL_5C1D_

; 8th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5C83_:
    ld de,$5CB7
    ld hl,_DATA_5CBB_
    call _LABEL_5D14_
    ld a,$FF
    ret

; Data from 5C8F to 5C92 (4 bytes)
_DATA_5C8F_:
.db $01 $00 $09 $0C

; Data from 5C93 to 5CA6 (20 bytes)
_DATA_5C93_:
.db $05 $06 $07 $06 $02 $03 $04 $03 $08 $09 $0A $09 $0B $0C $0D $0C
.db $05 $00 $08 $0B

; Data from 5CA7 to 5CBA (20 bytes)
_DATA_5CA7_:
.db $04 $05 $06 $05 $01 $02 $03 $02 $07 $08 $09 $08 $0A $0B $0C $0B
.db $01 $00 $0E $0F

; Data from 5CBB to 5CCA (16 bytes)
_DATA_5CBB_:
.db $05 $06 $07 $06 $02 $03 $04 $03 $08 $09 $0A $0A $0B $0C $0D $0D

; 9th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5CCB_:
    call ZeroIYStruct
    inc (iy+0)
    ld (iy+2),$60
    ld (iy+4),$80
    ld (iy+1),$05
    ld a,(VehicleMovementFlags)
    sub $04
    ld (iy+16),a
    ld (iy+17),$01
    ld a,$FF
    ret

; 10th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5CEC_:
    call +
    ld a,$FF
    ret

+:  call _LABEL_73E6_
    ld a,(ScrollDirection)
    and $0F
    ret z
    ld c,$FF
-:  rrca
    inc c
    jp nc,-
    ld hl,$5D10
    ld b,$00
    add hl,bc
    ld a,(VehicleMovementFlags)
    add a,(hl)
    ld (iy+16),a
    ret

; Data from 5D10 to 5D13 (4 bytes)
.db $FC $FE $FF $FD

_LABEL_5D14_:
    ld a,c
    or a
    call z,_LABEL_73E6_
    ld a,(PaletteRotateEnabled)
    or a
    jp z,_LABEL_5D78_
    cp $0F
    jp nz,_LABEL_5DAC_
    ld a,c
    or a
    jp nz,+
    ld a,(iy+18)
    ld (iy+19),a
    ld a,(ScrollDirection)
    and $0F
    jp z,_LABEL_5D78_
    ld b,$FF
-:  rrca
    inc b
    jp nc,-
    ld (iy+18),b
    jp _LABEL_5DAC_

+:  bit 0,(iy+10)
    jr z,+
    set 1,(iy+10)
+:  ld a,(iy-28)
    cp (iy+4)
    jr nz,+
    ld a,(iy-30)
    cp (iy+2)
    jr z,++
+:  bit 1,(iy-22)
    jr z,++
    set 0,(iy+10)
++:  ld a,(iy+18)
    ld (iy+19),a
    ld a,(iy-13)
    ld (iy+18),a
    jp _LABEL_5DAC_

_LABEL_5D78_:
    ld a,(ScrollDirection)
    and $0F
    jp nz,_LABEL_5DAC_
--: ld a,(iy+18)
    ld (iy+19),a
    ld a,c
    or a
    jr nz,+
    ld a,(ControlsNew)
    and $0F
    jr z,+
    ld l,$FF
-:  rrca
    inc l
    jp nc,-
    jr ++

+:  ld a,c
    or a
    ld l,(iy+18)
    jr z,++
    ld l,(iy-13)
++:  ld h,$00
    add hl,de
    ld a,(hl)
    ld (iy+16),a
    ret

_LABEL_5DAC_:
    ld a,c
    or a
    call nz,+
    ld a,(_RAM_C2E9_)
    or a
    jr nz,--
    dec (iy+14)
    ret p
    ld (iy+14),$07
    ld a,(iy+18)
    add a,a
    add a,a
    ld b,a
    ld a,(iy+13)
    inc a
    and $03
    ld (iy+13),a
    add a,b
    ld e,a
    ld d,$00
    add hl,de
    ld a,(hl)
    ld (iy+16),a
    ret

+:  bit 0,(iy+10)
    ld a,(iy+18)
    call nz,+
    ld a,(_RAM_C812_)
    xor $01
+:  cp $02
    jp nc,++
    or a
    jr nz,+
    dec a
+:  add a,(iy+2)
    ld (iy+2),a
    ret

++:  sub $02
    jr nz,+
    dec a
+:  add a,(iy+4)
    ld (iy+4),a
    ret

; 11th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5E03_:
    ld a,(iy+10)
    push af
      call ZeroIYStruct
    pop af
    inc (iy+0)
    ld hl,Frame2Paging
    ld (hl),$12
    add a,a
    ld e,a
    add a,a
    add a,e
    ld e,a
    ld d,$00
    ld hl,_DATA_5E6D_
    add hl,de
    ld a,(hl)
    ld (NewMusic),a
    inc hl
    ld a,(hl)
    ld (iy+24),a
    inc hl
    ld a,(hl)
    ld (iy+1),a
    inc hl
    ld a,(hl)
    ld (iy+15),a
    inc hl
    ld a,(_RAM_C894_)
    ld (iy+2),a
    ld a,(_RAM_C895_)
    ld (iy+4),a
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld de,$7400
    call LoadTiles4BitRLE
    xor a
    ret

; 12th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5E4A_:
    call +
    ld a,$FF
    ret

+:  dec (iy+14)
    ret p
    ld a,(iy+24)
    ld (iy+14),a
    ld a,(iy+1)
    inc a
    cp (iy+15)
    jr nc,+
    ld (iy+1),a
    ret

+:  xor a
    ld (iy+0),a
    pop hl
    ret

; Data from 5E6D to 5EDE (114 bytes)
_DATA_5E6D_:
.db $A2 $03 $66 $6B $2A $AD $A2 $03 $05 $0A $00 $9C $A2 $03 $05 $0A
.db $00 $9C $A2 $03 $05 $0A $00 $9C $A2 $03 $05 $0A $00 $9C $A2 $03
.db $6A $72 $91 $AF $A2 $03 $71 $76 $77 $B1 $A2 $03 $05 $0A $00 $9C
.db $A2 $03 $05 $0A $00 $9C $A7 $03 $18 $21 $70 $A2 $A2 $03 $6A $72
.db $91 $AF $A6 $03 $11 $19 $36 $A0 $A3 $03 $5E $63 $C0 $AA $A5 $03
.db $09 $12 $D7 $9D $A4 $03 $62 $67 $9D $AB $A4 $03 $75 $7A $44 $B2
.db $A8 $03 $20 $29 $BC $A3 $A9 $03 $28 $32 $E0 $A5 $AA $03 $31 $3A
.db $FD $A7

; 13th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5EDF_:
    call ZeroIYStruct
    inc (iy+0)
    ld (iy+2),$58
    ld (iy+4),$60
    ld (iy+1),$3A
    ld (iy+14),$07
    call GetRandomNumber
    ld b,a
    ld c,$3D
    ld a,(DungeonObjectItemTrapped)
    or a
    jr z,++
    cp $F0
    jr nc,+
    cp b
    jr c,++
+:  rrca
    ld c,$3E
    jr nc,++
    ld c,$43
++:  ld (iy+15),c
    ld a,$FF
    ret

; 14th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5F15_:
    call +
    ld a,$FF
    ret

+:  bit 0,(iy+10)
    ret z
    bit 1,(iy+10)
    jr nz,+
    dec (iy+14)
    ret p
    ld (iy+14),$07
    ld a,(iy+1)
    inc a
    ld (iy+1),a
    cp $3D
    ret nz
    ld (iy+14),$17
    set 1,(iy+10)
    ret

+:  bit 2,(iy+10)
    jr nz,++
    dec (iy+14)
    ret p
    ld (iy+14),$03
    ld a,(iy+15)
    ld (iy+1),a
    set 2,(iy+10)
    cp $3D
    jr nz,+
    ld (iy+0),$00
    ret

+:  cp $3E
    ld a,$B1
    jr z,+
    inc a
+:  ld (NewMusic),a
    ret

++:  dec (iy+14)
    ret p
    ld (iy+14),$03
    ld a,(iy+15)
    cp $3E
    jr nz,+
    ld a,(iy+1)
    inc a
    ld (iy+1),a
    push af
      cp $42
      call z,_LABEL_7E67_
    pop af
    cp $43
    ret c
    ld (iy+1),$3D
    ld (iy+0),$00
    ret

+:  ld a,(iy+1)
    inc a
    ld (iy+1),a
    cp $47
    ret c
    call _LABEL_7E67_
    ld (iy+1),$3D
    ld (iy+0),$00
    ret

; 21st entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5FAC_:
    call ZeroIYStruct
    inc (iy+0)
    ld a,(_RAM_C309_)
    cp $17
    ld a,$84
    ld de,$88D0
    jr nz,+
    ld a,$88
    ld de,$3050
+:  ld (iy+2),d
    ld (iy+4),e
    ld (iy+1),a
    ld (iy+15),a
    ld a,SFX_b9
    ld (NewMusic),a
    ld a,$FF
    ret

; 22nd entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_5FD7_:
    call +
    ld a,$FF
    ret

+:  dec (iy+14)
    ret p
    ld (iy+14),$07
    ld a,(iy+13)
    inc (iy+13)
    and $03
    add a,(iy+15)
    ld (iy+1),a
    ld a,(_RAM_C309_)
    cp $17
    jr z,+
    dec (iy+4)
    dec (iy+2)
    ld a,(iy+4)
    cp $90
    ret nz
-:  ld (iy+0),$00
    ret

+:  inc (iy+2)
    ld a,(iy+2)
    cp $78
    jr z,-
    and $07
    ret nz
    dec (iy+4)
    ret

; 15th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_601C_:
    call +
    ld a,(iy+1)
    ret

+:  ld a,(_RAM_C29F_)
    or a
    ret z
    ld a,(CharacterSpriteAttributes)
    or a
    ret nz
_LABEL_602D_:
    dec (iy+14)
    ret p
    ld a,(iy+24)
    ld (iy+14),a
    ld hl,Frame2Paging
    ld (hl),$03
    ld c,(iy+13)
    ld l,c
    ld h,$00
    bit 7,(iy+10)
    ld e,(iy+27)
    ld d,(iy+28)
    jr nz,_LABEL_6054_
    ld e,(iy+25)
    ld d,(iy+26)
_LABEL_6054_:
    add hl,de
    ld a,(hl)
    or a
    jr nz,+
    bit 0,(iy+10)
    jr z,++
    ld (_RAM_C29F_),a
    ld (iy+10),a
    ld (_RAM_C2ED_PlayerWasHurt),a
    ld c,a
    ld a,(de)
+:  inc c
    ld (iy+13),c
    ld (iy+1),a
    ret

++:  set 0,(iy+10)
    inc c
    ld (iy+13),c
    bit 7,(iy+10)
    jr z,+
    ld a,(EnemyNumber)
    cp Enemy_LaShiec
    jr z,_LABEL_6099_
    ld a,$11
    ld (CharacterSpriteAttributes),a
    ret

+:  ld a,(_RAM_C2ED_PlayerWasHurt)
    or a
    jr nz,_LABEL_6099_
    ld a,SFX_bb
    ld (NewMusic),a
    ret

_LABEL_6099_:
    ld a,SFX_Death
    ld (NewMusic),a
    call _LABEL_7E67_
    ld a,(_RAM_C2EE_PlayerBeingAttacked)
    jp _LABEL_3109_

; 16th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_60A7_:
    ld a,$FF
    ret

; 17th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_60AA_:
    call ZeroIYStruct
    inc (iy+0)
    ld hl,Frame2Paging
    ld (hl),$0B
    ld a,(_RAM_C88A_)
    bit 6,a
    ld hl,_DATA_611E_
    jr z,+
    ld hl,_DATA_6124_
+:  ld a,(hl)
    ld (NewMusic),a
    inc hl
    ld a,(hl)
    ld (iy+24),a
    inc hl
    ld a,(hl)
    ld (iy+1),a
    inc hl
    ld a,(hl)
    ld (iy+15),a
    inc hl
    ld a,(_RAM_C896_)
    ld (iy+2),a
    ld a,(_RAM_C897_)
    ld (iy+4),a
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld de,$7400
    call LoadTiles4BitRLE
    xor a
    ret

; 18th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_60EE_:
    call +
    ld a,$FF
    ret

+:  dec (iy+14)
    ret p
    ld a,(iy+24)
    ld (iy+14),a
    ld a,(iy+1)
    inc a
    cp (iy+15)
    jr nc,+
    ld (iy+1),a
    ret

+:  xor a
    ld (iy+0),a
    pop hl
    ld a,(_RAM_C2EF_MagicWallActiveAndCounter)
    and $80
    jp z,_LABEL_6099_
    ld a,SFX_bb
    ld (NewMusic),a
    ret

; Data from 611E to 6123 (6 bytes)
_DATA_611E_:
.db $A8 $03 $46 $4F $01 $99

; Data from 6124 to 6129 (6 bytes)
_DATA_6124_:
.db $A9 $03 $79 $82 $F0 $9A

; 19th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_612A_:
    call +
    ld a,(iy+1)
    ret

+:  ld a,(_RAM_C29F_)
    or a
    ret z
    dec (iy+14)
    ret p
    ld a,(iy+24)
    ld (iy+14),a
    ld hl,Frame2Paging
    ld (hl),$03
    ld a,(_RAM_C2EE_PlayerBeingAttacked)
    or a
    ld de,_DATA_D4F6_
    jr z,+
    dec a
    ld de,_DATA_D506_
    jr z,+
    dec a
    ld de,$9511
    jr z,+
    ld de,$951C
+:  ld c,(iy+13)
    ld l,c
    ld h,$00
    jp _LABEL_6054_

; 20th entry of Jump Table from 5AA3 (indexed by CharacterSpriteAttributes)
_LABEL_6166_:
    call +
    ld a,(iy+1)
    ret

+:  ld a,(_RAM_C29F_)
    or a
    ret z
    ld a,(iy+12)
    cp $02
    jr nc,+
    dec (iy+11)
    ret p
    ld (iy+11),$07
    inc (iy+12)
    or a
    ld hl,_DATA_63F50_
    jr z,_LABEL_618D_
    ld hl,_DATA_63F80_
_LABEL_618D_:
    ld a,$18
    ld (Frame2Paging),a
    ld de,$7A5C
    ld bc,$0608
    di
      call OutputTilemapRawDataBox
    ei
    ret

+:  cp $03
    jr nc,++
    call _LABEL_602D_
    ld a,(iy+13)
    cp $13
    jr nz,+
    ld (iy+2),$47
+:  ld a,(_RAM_C29F_)
    or a
    ret nz
    dec a
    ld (_RAM_C29F_),a
    inc (iy+12)
    ld (iy+2),$4F
    ret

++:  dec (iy+11)
    ret p
    ld (iy+11),$07
    inc (iy+12)
    cp $04
    ld hl,_DATA_63F50_
    jr nz,_LABEL_618D_
    xor a
    ld (iy+12),a
    ld (_RAM_C29F_),a
    ld hl,_DATA_63F20_
    jr _LABEL_618D_

_LABEL_61DF_:
    ld hl,Frame2Paging
    ld (hl),:
    ld a,(_RAM_C308_)
    cp $03
    jp nc,_LABEL_6275_
    ; Look up a*128
    ld h,a
    ld l,$00
    srl h
    rr l
    ld de,_DATA_C000_
    add hl,de
    ld de,(VLocation)
    ld a,e
    add a,$60
    jr c,+
    cp $C0
    ccf
+:  ld a,$00
    adc a,d
    and $07
    add a,a
    add a,a
    add a,a
    ld c,a
    ld de,(HLocation)
    ld a,e
    add a,$80
    ld a,$00
    adc a,d
    and $07
    add a,c
    add a,a
    ld d,$00
    ld e,a
    add hl,de
    ld b,(hl)
    ld a,(VehicleMovementFlags)
    or a
    jr z,+
    srl b
    srl b
+:  call GetRandomNumber
    cp b
    jp nc,_LABEL_6275_
    inc hl
    ld b,$00
    ld c,(hl)
    ld a,(_RAM_C2E5_)
    ld l,a
    ld h,$00
    ld de,_DATA_C5A0_
    add hl,de
    ld a,(_RAM_C308_)
    or a
    jr z,+
    ld a,$0A
+:  add a,(hl)
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,_DATA_C470_
    add hl,de
    add hl,bc
    ld a,(hl)
_LABEL_6254_SelectMonsterFromPool:
    ; Return if 0
    or a
    ret z
    ; Else look up in _DATA_C180_MonsterPools
    ld hl,Frame2Paging
    ld (hl),:_DATA_C180_MonsterPools
    ld l,a
    ld h,$00
    add hl,hl ; x8
    add hl,hl
    add hl,hl
    ld de,_DATA_C180_MonsterPools-8 ; it's 1-indexes
    add hl,de
    ; Then randomly +0-7
    call GetRandomNumber
    and $07
    ld e,a
    ld d,$00
    add hl,de
    ld a,(hl)
    ld (EnemyNumber),a
    ld a,$FF
    ret

_LABEL_6275_:
    xor a
    ld (_RAM_C29D_InBattle),a
    ret

.orga $627a
.section "Enemy data loader" overwrite
LoadEnemy:
    ld hl,Frame2Paging
    ld (hl),$03        ; for enemy data

    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,255
    ld (hl),$00
    ldir               ; blank CharacterSpriteAttributes

    ld hl,CharacterStatsEnemies
    ld de,CharacterStatsEnemies + 1
    ld bc,127
    ld (hl),$00
    ldir               ; blank CharacterStatsEnemies (128 bytes)

    ld a,(EnemyNumber)
    ld a,a             ; ################
    and $7F
    ret z              ; Return if no value

    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl          ; hl = EnemyNumber*32

    ld de,EnemyData-32
    add hl,de          ; hl = (EnemyData-32) + EnemyNumber*32

    ld de,EnemyName
    ld bc,8
    ldir               ; Load name

    ld de,TargetPalette+16+8
    ld bc,8
    ldir               ; Load palette

    ld b,(hl)          ; Next byte = page
    inc hl
    ld a,(hl)
    inc hl
    push hl
      ld h,(hl)
      ld l,a         ; hl = next word = offset
      ld a,b
      ld (Frame2Paging),a
      TileAddressDE $100
      call LoadTiles4BitRLE ; load enemy tiles
    pop hl
    inc hl
    ld a,:EnemyData
    ld (Frame2Paging),a
    ld a,(hl)          ; a = next byte
    push hl
      call _LABEL_6379_
    pop hl
    inc hl
    ld a,:EnemyData    ; reset paging
    ld (Frame2Paging),a
    ld a,(hl)          ; a = next byte
    bit 7,a            ; if bit 7 set then skip next block
    jr nz,+            ; ------------------------------+
    and $f             ;                               |
    ld b,a             ; low nibble -> b               |
    ld a,(PartySize)   ;                               |
    inc a              ; add 1                         |
    add a,a            ; and double                    |
    cp b               ;                               |
    jr nc,_f           ;                               |
    ld b,a             ; if (PartySize+1)*2<b then b=that  |
 __:call GetRandomNumber ;                             |
    and 7              ;                               |
    cp b               ;                               |
    jp nc,_b           ; get a random number <b        |
    inc a              ; add 1                         |
+:  and $f             ; <-----------------------------+
    ld b,a             ; put it in b = number of enemies
    ld (NumEnemies),a  ; and in NumEnemies
    inc hl
    ld a,(hl)          ; HP
    inc hl
    ld d,(hl)          ; Attack
    inc hl
    ld e,(hl)          ; Defence
    inc hl
    push hl
      ex de,hl       ; de -> hl
      ld ix,CharacterStatsEnemies
      ld de,16       ; size of stats (16 bytes)
-:    ld (ix+Character.IsAlive),1   ; alive = 1
      ld (ix+Character.HP),a        ; HP = a
      ld (ix+Character.MaxHP),a     ; Max HP = a
      ld (ix+Character.Attack),h    ; Attack = h
      ld (ix+Character.Defence),l   ; Defence = l
      add ix,de      ; repeat for each enemy
    djnz -
    pop hl
    ld a,(hl)           ; Item
    ld (DungeonObjectItemIndex),a
    inc hl             ; next word in de = money per enemy
    ld e,(hl)
    inc hl
    ld d,(hl)
    push hl
      ld a,(NumEnemies)
      ld c,a
      ld b,0
      call Multiply16
      ld (EnemyMoney),hl  ; EnemyMoney = NumEnemies*de
    pop hl
    inc hl
    ld a,(hl)          ; Next byte in DungeonObjectItemTrapped
    ld (DungeonObjectItemTrapped),a
    inc hl             ; next word in de
    ld e,(hl)
    inc hl
    ld d,(hl)
    push hl
      ld a,(NumEnemies)
      ld c,a
      ld b,0
      call Multiply16
      ld (EnemyExperienceValue),hl  ; EnemyExperienceValue = NumEnemies*de
    pop hl
    inc hl
    ld a,(hl)
    ld (_RAM_C2E8_EnemyMagicType),a       ; Next byte in _RAM_C2E8_EnemyMagicType
    inc hl
    ld a,(hl)
    ld (RetreatProbability),a       ; Next byte in RetreatProbability

    ld hl,_RAM_C500_
    ld (DungeonObjectFlagAddress),hl      ; $c500 -> DungeonObjectFlagAddress

    call SpriteHandler
    call SpriteHandler

    ld hl,TargetPalette
    ld de,ActualPalette
    ld bc,32
    ldir               ; update palette

    ld a,$10           ; VBlankFunction_10
    jp ExecuteFunctionIndexAInNextVBlank ; and ret
.ends
; followed by
.orga $6379
.section "Load data from data8fdf" overwrite
_LABEL_6379_:
; loads ath data from 24-byte structures at data8fdf
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    ld e,l
    ld d,h
    add hl,hl
    add hl,de
    ld de,_DATA_CFC7_
    add hl,de          ; hl = $8fc7 + a*24

    ld de,_RAM_C880_
    ld bc,3
    ldir               ; Copy 3 bytes from there to $c880 (then never used?)

    inc de             ; skip 1 byte
    ldi                ; and copy 1 more

    ld de,_RAM_C894_
    ld bc,9
    ldir               ; next 9 to $c894

    ld a,(_RAM_C898_)
    ld (_RAM_C88E_),a

    ld a,$01
    ld ($c88d),a       ; set $c88d = 1

    ld c,(hl)
    inc hl
    ld b,(hl)          ; bc = next word
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)          ; de = next werd
    inc hl
    ld a,(hl)          ; ah = next word
    inc hl
    push hl
      ld h,(hl)        ; data: cbedah
      ld l,c           ;       l
      ld c,a           ;           c
      ld a,h           ;            a
      ld h,b           ;        h
      ld b,a           ;            b
                       ; hl = bc; bc = ah
      or c             ; test c
      ld a,$18         ; page for ???
      ld (Frame2Paging),a
      call nz,_DataCopier ; if c!=0 then call _DataCopier
    pop hl
    inc hl

    ld a,$03           ; Reset paging
    ld (Frame2Paging),a

    ld de,_RAM_C8A0_
    ld bc,3
    ldir               ; Next 3 bytes -> $ca80
    inc de             ; skip 1
    ldi                ; copy 1
    ld a,(hl)
    ld (_RAM_C2F1_),a
    ret

_DataCopier:           ; $63d6
; Copies data from hl to de
; data format: fdd
; if f=0 then dd is skipped
; parses b data blocks
; then adds 64 to original value of de
; repeats c times
--: push bc
      push de
        ld c,$FF ; Ensure ldi won't affect b
-:      ld a,(hl)
        or a
        jp z,_skip
        ldi        ; copy 2 bytes
        ldi
_loopend:djnz -
      pop de
      ex de,hl
        ld bc,64
        add hl,bc
      ex de,hl       ; de = de + 64
    pop bc
    dec c              ; repeat c times
    jp nz,--
    ret
_skip:
        inc hl             ; skip 2 bytes
        inc de
        inc hl
        inc de
        jp _loopend
.ends
.orga $63f2

LoadDialogueSprite:
    or a
    ret z
    ld hl,Frame2Paging
    ld (hl),:DialogueSpritePaletteIndices
    ; Blank CharacterSpriteAttributes
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$00FF
    ld (hl),$00
    ldir
    ; Blank CharacterStatsEnemies
    ld hl,CharacterStatsEnemies
    ld de,CharacterStatsEnemies + 1
    ld bc,$007F
    ld (hl),$00
    ldir
    ; Look up in DialogueSpritePaletteIndices
    ld l,a
    ld h,$00
    add hl,hl
    ld de,DialogueSpritePaletteIndices
    add hl,de
    ld a,(hl)
    push hl
      ; Look up in DialogueSpritePalettes and load palette
      ld l,a
      ld h,$00
      add hl,hl
      add hl,hl
      add hl,hl
      ld de,DialogueSpritePalettes
      add hl,de
      push hl
        ld de,TargetPalette+16+8
        ld bc,$0008
        ldir
      pop hl
      ld de,ActualPalette+16+8
      ld bc,$0008
      ldir
    pop hl
    inc hl
    ld a,(hl) ; Second byte from DialogueSpritePaletteIndices entry
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,DialogueSprites ; Look up in DialogueSprites
    add hl,de
    ; Copy into CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes
    ld bc,3
    ldir
    inc de
    ldi
    inc hl
    ld b,(hl)
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,b
    ld (Frame2Paging),a
    ld de,$6000
    call LoadTiles4BitRLE
    call SpriteHandler
    ld a,$16
    jp ExecuteFunctionIndexAInNextVBlank

.orga $6471
.section "Load character animation tiles" overwrite
; Load raw character animation tiles from ROM
AnimCharacterSprites:  ; $6471
    ld hl,Frame2Paging
    ld (hl),:CharacterSprites
    ld ix,CharacterSpriteAttributes
    ld b,4             ; counter - only first 4
-:  ld a,(ix+16)       ; if 16 bytes after (currentanimframe)
    cp (ix+17)         ; != 17 bytes after (lastanimframe)
    jp z,+             ; then:
    ld (ix+17),a           ; make it equal
    ld d,a                 ; save in d
    ld a,(ix+$01)          ; get 1 byte after = character number
    or a                   ; check for zero
    ld hl,_FunctionTable-2 ; -2 because 0 is not used
    jp nz,FunctionLookup
+:  ld de,32           ; move to next data
    add ix,de
    djnz -
    ret
_FunctionTable:
.dw _Alis
.dw _Lutz
.dw _Odin
.dw _Myau
.dw _Vehicle

_Alis:                 ; $64a5
    ld e,$00
    srl d
    rr e
    ld l,e
    ld h,d
    srl d
    rr e
    add hl,de
    ld de,AlisSprites
    add hl,de          ; hl = AlisSprites + (ix+$10)*192 = where to
    TileAddressDE $1aa
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi128       ; output 192 bytes = 6 tiles
    jp outi64          ; and ret

_Lutz:                 ; $64c2
    ld e,$00
    srl d
    rr e
    ld l,e
    ld h,d
    srl d
    rr e
    add hl,de
    ld de,LutzSprites
    add hl,de          ; hl = LutzSprites + (ix+$10)*192
    TileAddressDE $1b0
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi128       ; output 192 bytes = 6 tiles
    jp outi64          ; and ret

_Odin:                 ; $64df
    ld e,$00
    srl d
    rr e
    ld l,e
    ld h,d
    srl d
    rr e
    add hl,de
    ld de,OdinSprites
    add hl,de          ; hl = LutzSprites + (ix+$10)*192
    TileAddressDE $1b6
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi128       ; output 192 bytes = 6 tiles
    jp outi64          ; and ret

_Myau:                 ; $64fc
    ld e,$00
    srl d
    rr e
    ld hl,MyauSprites
    add hl,de          ; hl = MyauSprite + (ix+$10)*128
    TileAddressDE $1bc
    rst SetVRAMAddressToDE
    ld c,VDPData
    jp outi128         ; output 128 bytes = 4 tiles and ret

_Vehicle:              ; $650f
    ld a,(FunctionLookupIndex)
    cp $05             ; if FunctionLookupIndex==5 or 9 then pass
    jr z,+
    cp $09
    ret nz
+:  ld hl,Frame2Paging
    ld (hl),:VehicleSprites
    ld l,$00
    ld h,d
    add hl,hl
    ld de,VehicleSprites
    add hl,de          ; hl = VehicleSprites + (ix+$10)*512
    ld de,$7540        ; tile $1aa
    rst SetVRAMAddressToDE
    ld c,VDPData
    call outi128
    call outi128
    call outi128
    jp outi128         ; output 512 bytes = 16 tiles
.ends
; followed by
.orga $6538
.section "Outside scene tile animations" overwrite
OutsideSceneTileAnimations: ; $6538
    ld hl,Frame2Paging
    ld (hl),:TilesOutsideAnimation

    ld hl,OutsideAnimCounters.1
    ld de,_AnimSeaShoreFrames
    ld bc,(12 << 8) | ($04*4) ; 12 tiles, tile $04
    call _CountAndAnimate

    ld hl,OutsideAnimCounters.2
    ld de,_AnimSeaFrames
    ld bc,( 3 << 8) | ($10*4) ; 3 tiles, tile $10
    call _CountAndAnimate

    ld hl,OutsideAnimCounters.3
    ld de,_AnimSmokeFrames
    ld bc,( 4 << 8) | ($13*4) ; 4 tiles, tile $13
    call _CountAndAnimate

    ld hl,OutsideAnimCounters.4
    ld de,_AnimRoadwayFrames
    ld bc,( 6 << 8) | ($17*4) ; 6 tiles, tile $17
    call _CountAndAnimate

    ld hl,OutsideAnimCounters.5
    ld de,_AnimLavaPitFrames
    ld bc,( 8 << 8) | ($1d*4) ; 8 tiles, tile $1d
    call _CountAndAnimate

    ld hl,OutsideAnimCounters.6
    ld de,_AnimAntlionHillFrames
    ld bc,(16 << 8) | ($25*4) ; 16 tiles, tile $25
    call _CountAndAnimate ; could jp and save the ret?
    ret

_CountAndAnimate:      ; $6586
; data structure at hl:
; b Enabled     00/01
; b ResetValue  Reset value of counter
; b CountDown   Counted down to 0 and then reset
; b Counter     Counted up or down at each reset
    ld a,(hl)          ; Enabled                              ; hl = $c26f (RAM) = counter structure
    or a                                                      ; de = $65c1 (ROM) = tile data
    ret z              ; exit if zero                         ; b = $0c = no. of tiles
    inc hl                                                    ; c = $10 = tile number * 4
    ld a,(hl)          ; get ResetValue
    inc hl
    dec (hl)           ; decrement CountDown
    ret p              ; exit if >=0
    ld (hl),a          ; else reset
    inc hl             ; Counter
    ld a,(_RAM_C2E9_)
    cp $04             ; if _RAM_c2e9_>=4
    jr c,+
    dec (hl)           ; then decrement Counter
    jr ++
+:  inc (hl)           ; else increment Counter
++:  ld a,(hl)
    and %00000111
    ld l,a
    ld h,$00           ; hl = 0-7 (low 3 bits of Counter)
    add hl,hl
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ex de,hl           ; de = word at (counterlowbits*2+de)
    ld l,c
    ld h,$08           ; hl = $08cc
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl           ; de = ($08cc)*8 = VRAM address of tile (cc/4), hl = word at (counterlowbits*2+de)
    rst SetVRAMAddressToDE
    ld c,VDPData
    ld a,b             ; counter = b = number of tiles
--: ld b,$20           ; counter = 32 bytes = 1 tile
-:  outi               ; output from hl to (c)
    nop                ; delay
    jp nz,-
    dec a
    jp nz,--
    pop hl             ; why?
    ret

; Pointer Table from 65C1 to 65D0 (8 entries,indexed by _RAM_C272_)
_AnimSeaShoreFrames:
_AnimSeaShoreFrames:   ; $65c1
.dw TilesOutsideSeaShore+12*32*0 ; 12 tiles x 32 bytes per tile x frame number
.dw TilesOutsideSeaShore+12*32*0
.dw TilesOutsideSeaShore+12*32*1
.dw TilesOutsideSeaShore+12*32*2
.dw TilesOutsideSeaShore+12*32*2
.dw TilesOutsideSeaShore+12*32*1
.dw TilesOutsideSeaShore+12*32*3
.dw TilesOutsideSeaShore+12*32*4

; Pointer Table from 65D1 to 65E0 (8 entries,indexed by _RAM_C276_)
_AnimSeaFrames:
.dw TilesOutsideSea+3*32*0 ; 3 tiles x 32 bytes per tile x frame number
.dw TilesOutsideSea+3*32*0
.dw TilesOutsideSea+3*32*1
.dw TilesOutsideSea+3*32*1
.dw TilesOutsideSea+3*32*2
.dw TilesOutsideSea+3*32*2
.dw TilesOutsideSea+3*32*3
.dw TilesOutsideSea+3*32*3

; Pointer Table from 65E1 to 65F0 (8 entries,indexed by _RAM_C27A_)
_AnimSmokeFrames:
.dw TilesSmoke+4*32*0  ; 4 tiles x 32 bytes per tile x frame number
.dw TilesSmoke+4*32*0
.dw TilesSmoke+4*32*1
.dw TilesSmoke+4*32*1
.dw TilesSmoke+4*32*2
.dw TilesSmoke+4*32*2
.dw TilesSmoke+4*32*1
.dw TilesSmoke+4*32*1

; Pointer Table from 65F1 to 6600 (8 entries,indexed by _RAM_C27E_)
_AnimRoadwayFrames:
.dw TilesRoadway+6*32*0 ; 6 tiles x 32 bytes per tiles x frame number
.dw TilesRoadway+6*32*0
.dw TilesRoadway+6*32*1
.dw TilesRoadway+6*32*1
.dw TilesRoadway+6*32*2
.dw TilesRoadway+6*32*2
.dw TilesRoadway+6*32*3
.dw TilesRoadway+6*32*3

; Pointer Table from 6601 to 6610 (8 entries,indexed by _RAM_C282_)
_AnimLavaPitFrames:
.dw TilesLavaPit+8*32*0 ; 8 tiles x 32 bytes per tile x frame number
.dw TilesLavaPit+8*32*0
.dw TilesLavaPit+8*32*1
.dw TilesLavaPit+8*32*1
.dw TilesLavaPit+8*32*2
.dw TilesLavaPit+8*32*2
.dw TilesLavaPit+8*32*1
.dw TilesLavaPit+8*32*1

; Pointer Table from 6611 to 6620 (8 entries,indexed by _RAM_C286_)
_AnimAntlionHillFrames:
.dw TilesAntlionHill+16*32*1
.dw TilesAntlionHill+16*32*1
.dw TilesAntlionHill+16*32*1
.dw TilesAntlionHill+16*32*1
.dw TilesAntlionHill+16*32*1
.dw TilesAntlionHill+16*32*2
.dw TilesAntlionHill+16*32*3
.dw TilesAntlionHill+16*32*0
.ends
; followed by
.orga $6621
.section "Enemy scene tile animations" overwrite
EnemySceneTileAnimation: ; $6621
    ld a,(SceneAnimEnabled)
    or a
    ret z              ; if AnimEnabled!=0
    ld a,(SceneType)
    or a
    ret z              ; and SceneType!=0
    ld hl,_AnimationFunctions-2 ; -2 because 0 is excluded
    jp FunctionLookup  ; look up (SceneType)th function in _AnimationFunctions and jump to it

_AnimationFunctions:   ; $6631
.dsw 2 _nothing        ; 1,2
.dw _AnimSeaWaveIn     ; 3
.dw _AnimSeaInOut      ; 4
.dsw 2 _nothing        ; 5,6
.dw _AnimLavaPit       ; 7
.dsw 3 _nothing        ; 8-9
.dw _AnimateUnknownPalette ; 10
.dsw 21 _nothing       ; 11-32

_nothing:              ; $6671
    ret
_AnimSeaWaveIn:        ; $6672       12 frame delay, 9 "frames" x 4x4 tiles
    call _AnimateWaterPalette
    ld hl,AnimDelayCounter ; Count down AnimDelayCounter
    dec (hl)
    ret p              ; proceed when it's 0
    ld (hl),$0b        ; and reset to 11 -> 1 in 12 calls
    inc hl
    ld a,(hl)          ; AnimFrameCounter
    inc a              ; count up
    cp $09
    jr c,+             ; if not <9
    xor a              ; then zero -> 0-8
+:  ld (hl),a
    ld hl,Frame2Paging
    ld (hl),:TilesAnimSea
    ld hl,AnimSeaWaveInFrames
    add a,a            ; (AnimFrameCounter)*8 - could shl?
    add a,a
    add a,a
    ld e,a
    ld d,$00
    add hl,de          ; AnimSeaWaveInFrames + 8*(AnimFrameCounter)
    ld b,$04
    jp _DoAnimation

_AnimSeaInOut:         ; $6699       16 frame delay, 14 "frames" x 3x4 tiles
    call _AnimateWaterPalette
    ld hl,AnimDelayCounter ; Count down AnimDelayCounter
    dec (hl)
    ret p              ; proceed when it's 0
    ld (hl),$0f        ; and reset to 15 -> 1 in 16 calls
    inc hl
    ld a,(hl)          ; AnimFrameCounter
    inc a              ; count up
    cp $0E
    jr c,+             ; if not <14
    xor a              ; then zero -> 0-13
+:  ld (hl),a
    ld hl,Frame2Paging
    ld (hl),:TilesAnimSea
    ld hl,AnimSeaInOutFrames
    add a,a            ; (AnimFrameCounter)*6
    ld e,a
    add a,a
    add a,e
    ld e,a
    ld d,$00
    add hl,de          ; AnimSeaInOutFrames + 6*(AnimFrameCounter)
    ld b,$03           ; Number of sets of 4 tiles to draw
    ; fall through
_DoAnimation:          ; $66be  hl = tile information looked up in table, b = number of 4 tile groups per frame
    push bc
      ld e,(hl)      ; Get what was looked up = xx
      ld d,$02       ; $02xx
      ex de,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ex de,hl       ; multiply by 32 -> VRAM address of tile number xx
      rst SetVRAMAddressToDE
      inc hl
      ld d,(hl)      ; Get next data byte yy
      inc hl
      push hl
        ld e,$00
        srl d      ; yy*128
        rr e
        ld hl,TilesAnimSea ; raw tile data
        add hl,de  ; TilesAnimSea + 128*yy
        ld bc,$80be; b = $80 = 128 bytes; c = VDPData
-:      outi       ; Output 128 bytes from table to VDPData (4 tiles)
        jp nz,-
      pop hl
    pop bc
    djnz _DoAnimation
    ret

_AnimLavaPit:          ; $66e5        16 frame delay, 6 "frames" x (4x4 + 2x2) tiles
    ld hl,AnimDelayCounter ; Count down AnimDelayCounter
    dec (hl)
    ret p              ; proceed when it's 0
    ld (hl),$0f        ; and reset to 15 -> 1 in 16 calls
    inc hl
    ld a,(hl)          ; AnimFrameCounter
    inc a              ; count up
    cp $06
    jr c,+             ; if not <6
    xor a              ; then zero -> 0-5
+:  ld (hl),a
    ld hl,Frame2Paging
    ld (hl),:TilesBubblingStuff
    add a,a
    ld b,a
    add a,a
    add a,b
    ld e,a             ; AnimFrameCounter*6
    ld d,$00
    ld hl,AnimLavaPitFrames
    add hl,de          ; AnimLavaPitFrames + AnimFrameCounter*6
    ld de,$4020        ; tile 1
    rst SetVRAMAddressToDE
    ld b,$04           ; number of sets of tiles
--: push bc
      ld d,(hl)      ; get word which was looked up
      inc hl
      ld e,$00
      srl d
      rr e           ; Multiply by 128
      ld bc,TilesBubblingStuff
      ex de,hl
      add hl,bc
      ld bc,$80be    ; output 128 bytes (4 tiles) to VDPData
-:    outi
      jp nz,-
    pop bc
    ex de,hl           ; get back hl = offset
    djnz --            ; loop
    ld b,$02           ; and 2 more seta of tiles...
--: push bc
      ld d,(hl)      ; get word which was looked up
      inc hl
      ld e,$00
      srl d
      rr e
      srl d
      rr e           ; multiply by 64
      ld bc,TilesBubblingStuff ; add to BubblingStuffTiles
      ex de,hl
      add hl,bc
      ld bc,$40be    ; output 64 bytes = 2 tiles
-:    outi
      jp nz,-
    pop bc
    ex de,hl           ; get back hl = offset
    djnz --
    ret

_AnimateWaterPalette:  ; $6746
    ld a,(PaletteFadeControl)
    or a
    ret nz             ; if PaletteFadeControl!=0
    ld a,(FunctionLookupIndex)
    cp $d
    ret nz             ; and FunctionLookupIndex!=13
    ld hl,PaletteMoveDelay
    dec (hl)
    ret p              ; if PaletteMoveDelay<0
    ld (hl),$1f        ; reset to 31 and continue
    ld de,PaletteAddress+13
    rst SetVRAMAddressToDE
    inc hl
    ld a,(hl)          ; PaletteMovePos
    inc a
    and $03            ; 0-3
    ld (hl),a
    ld e,a
    ld d,$00
    ld hl,WaterPalette
    add hl,de          ; add to WaterPalette
    ld bc,$03be        ; counter = 3, VDPData
-:  outi               ; output
    jp nz,-
    ret

_AnimateUnknownPalette:; $6772
    ld a,(PaletteFadeControl)
    or a
    ret nz             ; if PaletteFadeControl!=0
    ld a,(FunctionLookupIndex)
    cp $d
    ret nz             ; and FunctionLookupIndex!=13
    ld hl,PaletteMoveDelay
    dec (hl)
    ret p              ; if PaletteMoveDelay<0
    ld (hl),$07        ; reset to 7 and continue
    ld de,PaletteAddress+8
    rst SetVRAMAddressToDE
    inc hl
    ld a,(hl)          ; PaletteMovePos
    dec a
    and $0f            ; 0-15
    ld (hl),a
    ld e,a
    ld d,$00
    ld hl,UnknownPalette
    add hl,de          ; add to UnknownPalette
    ld bc,$04be        ; counter = 4, VDPData
-:  outi               ; output
    jp nz,-
    ld hl,UnknownPalette+8
    add hl,de          ; and again (?)
    ld b,$04
-:  outi
    jp nz,-
    ret
.ends
; followed by
.orga $67a9
.section "Sea animations lookup table" overwrite
AnimSeaWaveInFrames:   ; $67a9
;     ,,-----,,------,,------,,------ Tile number to write 4 tiles from
;    ||  ,,--||--,,--||--,,--||--,,-- nnx128 byte offset into data to load from
.db $01,$15,$25,$09,$29,$0a,$29,$0a ; 0
.db $01,$00,$05,$0b,$01,$00,$05,$0b ; 1
.db $05,$01,$09,$0d,$05,$01,$09,$0d ; 2
.db $09,$02,$0d,$0d,$09,$02,$0d,$0d ; 3
.db $0d,$03,$11,$0e,$0d,$03,$11,$0e ; 4
.db $11,$04,$15,$0e,$11,$04,$15,$0e ; 5
.db $15,$05,$19,$0f,$15,$05,$19,$0f ; 6
.db $19,$06,$21,$0f,$19,$06,$21,$0f ; 7
.db $21,$08,$01,$10,$25,$0c,$29,$11 ; 8
AnimSeaInOutFrames:    ; $67f1
;     ,,-----,,------,,------ Tile number to write 4 tiles from
;    ||  ,,--||--,,--||--,,-- nnx128KB offset into data to load from
.db $25,$09,$29,$0a,$29,$0a ; 0
.db $25,$09,$29,$0a,$29,$0a ; 1
.db $25,$09,$29,$0c,$29,$0c ; 2
.db $21,$08,$25,$0f,$29,$14 ; 3
.db $21,$0f,$25,$13,$29,$14 ; 4
.db $19,$06,$1d,$0f,$21,$12 ; 5
.db $15,$05,$19,$0e,$1d,$12 ; 6
.db $15,$0e,$19,$12,$19,$12 ; 7
.db $15,$0e,$19,$12,$19,$12 ; 8
.db $15,$05,$19,$0e,$1d,$12 ; 9
.db $19,$06,$1d,$0f,$21,$12 ; 10
.db $1d,$07,$21,$0f,$25,$13 ; 11
.db $21,$08,$25,$0c,$29,$11 ; 12
.db $25,$09,$29,$0c,$29,$0c ; 13
.ends
; followed by
.orga $6845
.section "Lava pit animation lookup table" overwrite
AnimLavaPitFrames:     ; $6845
;    ,,--,,--,,--,,---------- nnx128KB offset into data to load from (4 tiles, foreground)
;    ||  ||  ||  ||  ,,--,,-- nnx64KB offset into data to load from (2 tiles, background)
.db $00,$02,$05,$08,$15,$18 ; 0
.db $00,$03,$06,$09,$16,$14 ; 1
.db $01,$04,$07,$05,$17,$14 ; 2
.db $02,$00,$08,$05,$18,$15 ; 3
.db $03,$00,$09,$06,$14,$16 ; 4
.db $04,$01,$05,$07,$14,$17 ; 5
.ends
; followed by
.orga $6869
.section "Water palette animation palette" overwrite
WaterPalette:
.db $3f,$3c,$38,$38
.db $3f,$3c,$38,$38 ; last 2 bytes not needed ###############
.ends
.orga $6871
.section "Unknown palette animation palette" overwrite
UnknownPalette:
.db $06,$06,$06,$06,$06,$06,$06,$06
.db $06,$06,$06,$06,$25,$2A,$3E,$3F
.db $06,$06,$06,$06,$06,$06,$06,$06
.db $06,$06,$06,$06,$06,$06,$06,$06 ; can probably lose some of these too
.ends
.orga $6891

_LABEL_6891_:
    ld a,(DungeonPosition)
    ld l,a
    ld h,>DungeonMap
    ld a,(hl)
    cp $08 ; Object or pitfall
    jp nz,_NotPitFall
    ; It is 8
    ld c,l
    ld a,(DungeonNumber)
    ld b,a
    ld hl,Frame2Paging
    ld (hl),:DungeonObjects
    ld hl,DungeonObjects
    ld de,6 ; 7 bytes per entry, but we inc hl once
-:  ld a,(hl)
    ; IF we reach the end of the list, it's a pitfall
    cp $FF
    jr z,_PitFall
    inc hl
    ; Else check if it matches our dungeon
    cp b
    jr nz,+
    ; And our location
    ld a,(hl)
    cp c
    jp z,_NotPitFall
+:  add hl,de
    jp -

_PitFall:
    ld de,$7E00
    ld hl,$00C0
    ld bc,$0080
    di
      call FillVRAMWithHL
    ei
    ld a,SFX_c0
    ld (NewMusic),a
    xor a
    ld (VScroll),a
    ld b,$0C
-:  push bc
      ld a,(VScroll)
      add a,$10
      ld (VScroll),a
      ld a,$08
      call ExecuteFunctionIndexAInNextVBlank
      ld a,b
      sub $0C
      neg
      ld c,$00
      ld b,a
      srl b
      rr c
      ld hl,$7800
      add hl,bc
      ex de,hl
      ld hl,$00C0
      ld bc,$0040
      di
        call FillVRAMWithHL
      ei
    pop bc
    djnz -
    ; Move down a floor
    ld a,(DungeonNumber)
    sub 1
    jr nc,+
    xor a
+:  ld (DungeonNumber),a
    call LoadDungeonMap
    ; Scroll in the new dungeon
    xor a
    call _LABEL_6D90_
    ld hl,TargetPalette
    ld de,ActualPalette
    ld bc,$0020
    ldir
    ld a,$16
    call ExecuteFunctionIndexAInNextVBlank
    ld a,$10
    ld (VScroll),a
    ld b,$0C
-:  push bc
      ld a,(VScroll)
      add a,$10
      ld (VScroll),a
      ld a,$08
      call ExecuteFunctionIndexAInNextVBlank
      ld a,b
      sub $0C
      neg
      ld c,$00
      ld b,a
      srl b
      rr c
      ld hl,$7800
      add hl,bc
      ex de,hl
      ld hl,TileMapData
      add hl,bc
      ld bc,$0080
      di
        call OutputToVRAM
      ei
    pop bc
    djnz -
    ld b,$05
-:  ld a,(VScroll)
    or a
    ld a,$D8
    jr z,+
    xor a
+:  ld (VScroll),a
    ld a,$08
    call ExecuteFunctionIndexAInNextVBlank
    djnz -
    ; Restore the font as we used its area for scrolling
    ld hl,Frame2Paging
    ld (hl),:TilesExtraFont
    ld hl,TilesExtraFont
    ld de,$7E00
    call LoadTiles4BitRLE
    ld b,$01
    jp _LABEL_6C06_

_NotPitFall:
    ld a,(ControlsNew)
    and $0F ; Mask to directions
    jp z,_NotMoving
    ; Check movememnt direction
    ld c,a
    bit 0,c ; Up -> forwards
    jp z,_NotForwards
    ; See what's in front
    ld b,$01
    call DungeonGetRelativeSquare
    ld b,a
    and $07
    ; Zero ->
    jp z,_LABEL_69FB_
    sub $02
    jp c,_NotForwards
    cp $05
    jp z,_LABEL_69F8_
    cp $02
    jp nc,++
    ld c,a
    ld a,SFX_c3
    ld (NewMusic),a
    ld a,c
    bit 3,b
    jp nz,_LABEL_6B5F_
    ; Is it a stair up or down?
    or a
    ld b,+1
    jr z,+
    ld b,-1
+:  ld a,(DungeonNumber)
    add a,b
    ld (DungeonNumber),a
    call LoadDungeonMap
    jp +++

++: bit 7,(hl)
    ret z
    bit 3,b
    jp nz,_LABEL_6B5F_
+++:call FadeOutFullPalette
    ld a,(DungeonFacingDirection)
    and $03
    ld hl,_DATA_6D82_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(DungeonPosition)
    add a,(hl)
    add a,(hl)
    ld (DungeonPosition),a
    xor a
    call DungeonScriptItem
    call FadeInWholePalette
    ld b,$01
    jp _LABEL_6C06_

_LABEL_69F8_:
    call _LABEL_69FB_
_LABEL_69FB_:
    ld a,$00
    call DungeonAnimation
    ld a,(DungeonFacingDirection)
    and $03
    ld hl,_DATA_6D82_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(DungeonPosition)
    add a,(hl)
    ld (DungeonPosition),a
    xor a
    call DungeonScriptItem
    ld b,$01
    jp _LABEL_6C06_

_NotForwards:
    ; Down -> backwards
    bit 1,c
    jr z,+
    ld b,$0B
    call _LABEL_6E6D_
    jr nz,+
    call _LABEL_6A35_
    ld b,$01
    call _LABEL_6C06_
    ld b,$0B
    jp _LABEL_6C06_

_LABEL_6A35_:
    ld a,(DungeonFacingDirection)
    and $03
    ld hl,_DATA_6D82_ + 2
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(DungeonPosition)
    add a,(hl)
    ld (DungeonPosition),a
    ld a,$01
    jp DungeonAnimation

+:  ; Left -> turn left
    bit 2,c
    jr z,++
    call _TurnLeft
    ld b,$01
    jp _LABEL_6C06_

_TurnLeft:
    ld a,(DungeonFacingDirection)
    dec a
    and $03
    ld (DungeonFacingDirection),a
    ld h,$02
    ld b,$0D
    call _LABEL_6E6D_
    jr z,+
    inc h
    inc h
+:  ld b,$01
    call _LABEL_6E6D_
    jr z,+
    inc h
+:  ld a,h
    jp DungeonAnimation

++: ; Right -> turn right
    bit 3,c
    ret z
    call _TurnRight
    ld b,$01
    jp _LABEL_6C06_

_TurnRight:
    ld a,(DungeonFacingDirection)
    inc a
    and $03
    ld (DungeonFacingDirection),a
    ld h,$06
    ld b,$0C
    call _LABEL_6E6D_
    jr z,+
    inc h
    inc h
+:  ld b,$01
    call _LABEL_6E6D_
    jr z,+
    inc h
+:  ld a,h
    jp DungeonAnimation

_NotMoving:
    ld a,(Controls)
    and $30
    ret z
    ld b,$01
    call _LABEL_6E6D_
    cp $04
    jr nz,+
    ld c,$02
    call _LABEL_6ABE_
    ret z
+:  call _LABEL_1D3D_
    ret

_LABEL_6ABE_:
    ld b,$01
    call DungeonGetRelativeSquare
    bit 7,(hl)
    ret nz
    set 7,(hl)
    ld a,SFX_bd
    ld (NewMusic),a
    ld h,c
    ld l,$00
    ld b,$03
--: push bc
-:    push hl
        ld a,h
        call _LABEL_70EF_
        ld a,$0C
        call ExecuteFunctionIndexAInNextVBlank
      pop hl
      ld a,h
      ld bc,$0040
      add hl,bc
      cp h
      jr z,-
      inc h
      inc h
    pop bc
    djnz --
    xor a
    ret

_SquareInFrontOfPlayerContainsObject:
    ld b,$01
    call DungeonGetRelativeSquare
    cp $08
    jr nz,++
    ld c,l
    ld a,(DungeonNumber)
    ld b,a
    ld hl,Frame2Paging
    ld (hl),:DungeonObjects
    ld hl,DungeonObjects
    ld de,$0006
-:  ld a,(hl)
    cp $FF
    jr z,+++
    inc hl
    cp b
    jr nz,+
    ld a,(hl)
    cp c
    jr z,++
+:  add hl,de
    jp -

++: xor a ; item found -> return 0
    ret

+++:ld a,$FF ; Item not found
    or a
    ret

_LABEL_6B1D_:
    ld b,$0B
    call _LABEL_6E6D_
    ret z
    ld b,$0C
    call _LABEL_6E6D_
    ret z
    ld b,$0D
    call _LABEL_6E6D_
    ret

_LABEL_6B2F_:
    ld b,$0B
    call _LABEL_6E6D_
    jr z,+++
    ld b,$0C
    call _LABEL_6E6D_
    jr nz,++
    ld b,$0D
    call _LABEL_6E6D_
    jr nz,+
    ; Randomly turn left or right
    call GetRandomNumber
    rrca
    jr nc,++
+:  call _TurnRight
    jr +++
++: call _TurnLeft
+++:call _LABEL_6A35_
    ld b,$01
    call _LABEL_6C06_
    ld b,$0B
    jp _LABEL_6C06_

_LABEL_6B5F_:
    ld b,$01
    call DungeonGetRelativeSquare
    and $08
    ret z
    ld c,l
    ld a,(DungeonNumber)
    ld b,a
    ld hl,Frame2Paging
    ld (hl),$03
    ld hl,_DATA_F473_
    ld de,$0004
-:  ld a,(hl)
    cp $FF
    jr z,++
    inc hl
    cp b
    jr nz,+
    ld a,(hl)
    cp c
    jr z,+++
+:  add hl,de
    jp -

; Data from 6B88 to 6B88 (1 bytes)
.db $C9

++:  ld hl,FunctionLookupIndex
    ld (hl),$08
    ret

+++:inc hl
    ld a,(hl)
    ld d,a
    dec hl
    cp $80
    ld a,$08
    jp c,_LABEL_7B1A_
    ld a,d
    cp $FF
    jr nz,_LABEL_6BEA_
    push hl
      call FadeOutFullPalette
      ld hl,Frame2Paging
      ld (hl),$09
      ld hl,_DATA_27471_
      ld de,$4000
      call LoadTiles4BitRLE
      ld hl,_DATA_27130_
      call DecompressToTileMapData
      ld a,$0F
      ld (SceneType),a
      xor a
      ld (TargetPalette+16),a
_LABEL_6BC0_:
      ld a,$0C
      call ExecuteFunctionIndexAInNextVBlank
      call FadeInWholePalette
-:    ld hl,Frame2Paging
      ld (hl),$03
    pop hl
    inc hl
    inc hl
    call _LABEL_6CD2_
    ld a,(FunctionLookupIndex)
    cp $0B
    ret nz
    call FadeOutFullPalette
    xor a
    call DungeonScriptItem
    call LoadDungeonData
    call CheckDungeonMusic
    call FadeInWholePalette
    ret

_LABEL_6BEA_:
    push hl
      push af
        call FadeOutFullPalette
      pop af
      ld c,$0D
      cp $FE
      jr z,+
      ld c,$1E
      cp $FD
      jr nz,-
+:    ld a,c
      ld (SceneType),a
      call LoadSceneData
      jp _LABEL_6BC0_

_LABEL_6C06_:
    call DungeonGetRelativeSquare
    cp $08
    ret nz
    ld c,l
    ; Check if the pointed square has an object
    push bc
      ld a,(DungeonNumber)
      ld b,a
      ld hl,Frame2Paging
      ld (hl),:DungeonObjects
      ld hl,DungeonObjects
      ld de,6
-:    ld a,(hl)
      cp $FF
      jp z,++
      inc hl
      cp b
      jr nz,+
      ld a,(hl)
      cp c
      jr z,+++
+:    add hl,de
      jp -
++: pop bc
    ret

+++:pop bc
    ; Object found, hl points to its second byte
    inc hl
    ld e,(hl) ; Read flag address to de
    inc hl
    ld d,(hl)
    ld a,(de)
    cp $FF
    ret z ; Do nothing if it is $ff
    ; Remember it
    ld (DungeonObjectFlagAddress),de

    ld a,$FF
    ld (MovementInProgress),a

    inc hl
    ld a,(hl) ; Read object type
    inc hl
    or a
    jr nz,+
    ; Type 0: item
    ld a,(hl) ; Read item type
    ld (DungeonObjectItemIndex),a
    inc hl
    ld a,(hl) ; And trapped byte
    ld (DungeonObjectItemTrapped),a
    ld hl,0
    ld (EnemyMoney),hl
    jp ++

+:  cp DungeonObject_Meseta
    jr nz,+++
    ; Type 1: money
    xor a
    ld (DungeonObjectItemIndex),a
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld (EnemyMoney),hl
    ; fall through

++: ; Treasure chest for item or money
    ld a,b ; relative square index?
    cp $01
    ret nz ; Nothing if not in front
    ld hl,textFoundTreasureChest
    call TextBox20x6
    push bc
      call ShowTreasureChest
    pop bc
    call _LABEL_2A37_
    ld a,(CharacterSpriteAttributes)
    or a
    ret z
    jp _LABEL_1D3D_

+++:cp DungeonObject_Battle
    jr nz,++
    ; Type 2: battle
    ld a,b
    cp $01
    jr z,+
    ; Direction is not 1, so turn around
    push hl
      ; Turn around 180 degrees
      call _TurnLeft
      call _TurnLeft
      ld hl,Frame2Paging
      ld (hl),$03
    pop hl
+:  ld a,(hl)
    ld (EnemyNumber),a
    or a
    ret z ; Should not be possible
    inc hl
    ld a,(hl) ; Enemy item drop
    push af
      ld hl,(DungeonObjectFlagAddress)
      push hl
        call LoadEnemy
      pop hl
      ld (DungeonObjectFlagAddress),hl
    pop af
    ld (DungeonObjectItemIndex),a
    call _LABEL_116B_
    ld a,(CharacterSpriteAttributes)
    or a
    ret z
    jp _LABEL_1D3D_

++: cp DungeonObject_Dialogue
    ret nz
    ; Type 3: dialogue
    ld a,b
    cp $01
    jr z,+
    push hl
      ; turn around 180 degrees
      call _TurnRight
      call _TurnRight
      ld hl,Frame2Paging
      ld (hl),$03 ; ???
    pop hl
+:
_LABEL_6CD2_:
    ; Load word into RoomIndex
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld (RoomIndex),hl ; also writing to _RAM_C2DC_
    ld a,(_RAM_C2DC_)
    call LoadDialogueSprite
    call DoRoomScript
    ; Turn off sprites
    ld a,$D0
    ld (SpriteTable),a
    ; Clear other stuff
    xor a
    ld (CharacterSpriteAttributes),a
    ld (_RAM_C29D_InBattle),a
    ld (SceneType),a
    ld (_RAM_C2D5_),a
    ld hl,0
    ld (RoomIndex),hl ; and _RAM_C2DC_
    ret

DungeonAnimation: ; $6CFB
    ; Look up in _DATA_6D19_
    ld l,a
    ld h,$00
    add hl,hl
    ld de,_table
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,$FF
    ld (MovementInProgress),a
-:  ld a,(hl)
    cp $FF
    ret z
    push hl
      call DungeonScriptItem
    pop hl
    inc hl
    jp -

; Data from 6D19 to 6D83 (107 bytes)
_table:
.dw _table0 _table1 _table2 _table3 _table4 _table5 _table6 _table7 _table8 _table9
_table0: .db $01 $02 $03 $04 $05 $FF              ; 0 = Forward
_table1: .db $05 $04 $03 $02 $01 $00 $FF          ; 1 = Backward
_table2: .db $07 $08 $09 $0A $0B $0C $0D $00 $FF  ; 2 = turn corridor to corridor (left)
_table3: .db $17 $18 $19 $1A $1B $1C $1D $00 $FF  ; 3 = turn corridor to wall (left)
_table4: .db $1F $20 $21 $22 $23 $24 $25 $00 $FF  ; 4 = turn wall to corridor (left)
_table5: .db $0F $10 $11 $12 $13 $14 $15 $00 $FF  ; 5 = turn wall to wall (left)
_table6: .db $0D $0C $0B $0A $09 $08 $07 $00 $FF  ; 6 = turn corridor to corridor (right)
_table7: .db $25 $24 $23 $22 $21 $20 $1F $00 $FF  ; 7 = turn corridor to wall (right)
_table8: .db $1D $1C $1B $1A $19 $18 $17 $00 $FF  ; 8 = turn wall to corridor (right)
_table9:.db $15 $14 $13 $12 $11 $10 $0F $00 $FF   ; 9 = turn wall to wall (right)

_DATA_6D82_:
.db $F0 $01 $10 $FF $F0 $01

DungeonScriptItem:
    call _LABEL_6D90_
    ld a,$0C ; VBlankFunction_UpdateTilemap
    jp ExecuteFunctionIndexAInNextVBlank

_LABEL_6D90_:
    and $3F
    jr nz,+
    ld b,$01
    call _LABEL_6E6D_
    ld a,$00
    jr z,+
    ld a,$06
+:  ld c,a                    ; Take a copy of the table entry number
    add a,a                   ; multiply by 6
    ld b,a
    add a,a
    add a,b
    ld hl,DungeonTilesTable   ; look up in table
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    push bc
      ; Byte 1: page
      ld a,(hl)
      ld (Frame2Paging),a
      inc hl
      ld a,(hl)
      inc hl
      push hl
        ; Following word: address
        ld h,(hl)
        ld l,a
        rr c
        ; Even entry numbers go to $40xx (bottom tileset)
        ld d,$40
        jr nc,+
        ; Odd entry numbers go to $60xx (top tileset)
        ld d,$60
+:      di
          ; Set VRAM address (could do rst SetVRAMAddressToDE)
          xor a
          out (VDPAddress),a
          ld a,d
          out (VDPAddress),a
        ei
        call DungeonTilesDecode
      pop hl
      inc hl
      ; Repeat for the next entry for the tilemap
      ld a,(hl)
      ld (Frame2Paging),a
      inc hl
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      call DecompressToTileMapData
    pop bc
    call _LABEL_6EE9_
    ret

_LABEL_6DDD_:
    ld b,$01
    call _LABEL_6E6D_
    ld a,$00
    jr z,+
    ld a,$06
+:  ld c,a
    add a,a
    ld e,a
    add a,a
    add a,e
    ld e,a
    ld d,$00
    ld hl,_DATA_7305_
    add hl,de
    push bc
      ld a,(hl)
      ld (Frame2Paging),a
      inc hl
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      call DecompressToTileMapData
    pop bc
    jp _LABEL_6EE9_


.orga $6e05
.section "Decompress to TileMapData" overwrite
; Copies data from (hl) to TileMapData
; with RLE decompression and 2-interleaving
; data format:
; Header: $fccccccc
;   f = flag: 1 = not RLE, 0 = RLE
;   ccccccc = count
; Then [count] bytes are copied to even bytes starting at TileMapData
; Then the process is repeated for the odd bytes
DecompressToTileMapData:
    ld b,$00           ; b=0
    ld de,TileMapData
    call _f            ; Process even bytes first -------------+
    inc hl             ; and odd bytes second                  |
    ld de,TileMapData+1 ;                                      |
 __:ld a,(hl)          ; Get data count in a <-----------------+
    or a               ; \ return                              |
    ret z              ; / if zero                             |
    jp m,_raw          ; if bit 8 is set then ---------------+ |
_rle:                  ; else:                               | |
    ld c,a             ; put it in c -> bc = data count      | |
    inc hl             ; move hl pointer to next byte (data) | |
-:  ldi                ; copy 1 byte from hl to de, <------+ | |
                       ; inc hl, inc de, dec bc            | | |
    dec hl             ; move hl pointer back (RLE)        | | |
    inc de             ; skip dest byte                    | | |
    jp pe,-            ; if bc!=0 then repeat -------------+ | |
    inc hl             ; move past RLE'd byte                | |
    jp _b              ; repeat -----------------------------|-+
_raw:                  ;                                     | |
+:  and $7f            ; (if bit 8 is set:) unset it <-------+ |
    ld c,a             ; put it in c -> bc = data count        |
    inc hl             ; move hl pointer to next byte (data)   |
-:  ldi                ; copy 1 byte from hl to de, <--------+ |
                       ; inc hl, inc de, dec bc              | |
    inc de             ; skip dest byte                      | |
    jp pe,-            ; if bc!=0 then repeat ---------------+ |
    jp _b              ; repeat -------------------------------+
.ends
.orga $6e31

DungeonTilesDecode:
    ld c,VDPData
--: ; Read byte
    ld a,(hl)
    or a
    ; 0 = end
    ret z
    ; high bit -> raw
    jp m,_raw

    ; else RLE
_rle:
    ; byte = count
    ld b,a
    inc hl
-:  ; Accumulate the first three bytes as we go
    ld a,(hl)
    ; Emit to VRAM
    outi
    ; Undo decrement from outi
    inc b
    or (hl)
    outi
    inc b
    or (hl)
    outi
    ; Repeat
    dec hl
    dec hl
    dec hl
    ; and emit ORed value as the fourth
    out (VDPData),a
    jp nz,-
    inc hl
    inc hl
    inc hl
    jp --

_raw:
    ; cc: count
    ; dd * cc * 3: data
    ; fourth byte is generated again

    ; clear high bit
    and $7F
    ld b,a
    inc hl
-:  ld a,(hl)
    outi
    inc b
    or (hl)
    outi
    inc b
    or (hl)
    outi
    ; delay
    push af
    pop af
    out (VDPData),a
    jp nz,-
    jp --

_LABEL_6E6D_:
    push hl
      ld a,(DungeonFacingDirection)
      and $03
      add a,a
      add a,a
      add a,a
      add a,a
      ld e,a
      ld d,$00
      ld hl,_RelativeSquareOffsets
      add hl,de
      ld e,b
      add hl,de
      ld a,(DungeonPosition)
      add a,(hl)
      ld h,>DungeonMap
      ld l,a
      ld a,(hl)
      and $07
    pop hl
    ret

DungeonGetRelativeSquare:
    ld a,(DungeonFacingDirection)
    and $03 ; 0-3
    add a,a ; Multiply by 16
    add a,a
    add a,a
    add a,a
    ld e,a
    ld d,$00
    ld hl,_RelativeSquareOffsets ; Look up in table
    add hl,de
    ; Then offset by b
    ld e,b
    add hl,de
    ld a,(DungeonPosition) ; Add pointed value to DungeonPosition
    add a,(hl)
    ld h,>DungeonMap ; Look up in DungeonMap
    ld l,a
    ld a,(hl) ; Read byte
    and $7F ; Reset high bit and return it
    ret

_RelativeSquareOffsets:
; Offsets of tile a certain distance away in the map. For a player at X facing right:
;
;  $0b $0c $02 $05 $07
;      [X] $01 $04 $08 $0a
;      $0d $03 $06 $09
;
;         1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
.db $00 $F0 $EF $F1 $E0 $DF $E1 $D0 $CF $D1 $C0 $10 $FF $01 $00 $00 ; Up
.db $00 $01 $F1 $11 $02 $F2 $12 $03 $F3 $13 $04 $FF $F0 $10 $00 $00 ; Right
.db $00 $10 $11 $0F $20 $21 $1F $30 $31 $2F $40 $F0 $01 $FF $00 $00 ; Down
.db $00 $FF $0F $EF $FE $0E $EE $FD $0D $ED $FC $01 $10 $F0 $00 $00 ; Left

_LABEL_6EE9_:
    ld a,c
    cp $06
    jp z,_LABEL_70DB_
    ret nc
    ld hl,Frame2Paging
    ld (hl),$06
    add a,a
    ld l,a
    add a,a
    add a,a
    ld h,a
    add a,a
    add a,h
    add a,l
    ld l,a
    ld h,$00
    ld e,l
    ld d,h
    add hl,hl
    add hl,de
    ld de,_DATA_712E_
    add hl,de
    ld b,$04
    call _LABEL_6E6D_
    jr z,+
    call _LABEL_6FB6_
    ld b,$02
    call _LABEL_6E6D_
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push bc
      call _LABEL_6FD7_
      ld b,$03
      call _LABEL_6E6D_
    pop bc
    jp _LABEL_6FD7_

+:  ld de,$000C
    add hl,de
    ld b,$02
    call _LABEL_6E6D_
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push bc
      call _LABEL_6FE8_
      ld b,$03
      call _LABEL_6E6D_
    pop bc
    call _LABEL_6FE8_
    ld b,$07
    call _LABEL_6E6D_
    jr z,+
    call _LABEL_6FB6_
    ld b,$05
    call _LABEL_6E6D_
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push bc
      call _LABEL_6FD7_
      ld b,$06
      call _LABEL_6E6D_
    pop bc
    jp _LABEL_6FD7_

+:  ld de,$000C
    add hl,de
    ld b,$05
    call _LABEL_6E6D_
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push bc
      call _LABEL_6FE8_
      ld b,$06
      call _LABEL_6E6D_
    pop bc
    call _LABEL_6FE8_
    ld b,$0A
    call _LABEL_6E6D_
    jr z,+
    call _LABEL_6FB6_
    ld b,$08
    call _LABEL_6E6D_
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push bc
      call _LABEL_6FD7_
      ld b,$09
      call _LABEL_6E6D_
    pop bc
    jp _LABEL_6FD7_

+:  ld de,$000C
    add hl,de
    ld b,$08
    call _LABEL_6E6D_
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    push bc
      call _LABEL_6FE8_
      ld b,$09
      call _LABEL_6E6D_
    pop bc
    jp _LABEL_6FE8_

_LABEL_6FB6_:
    push af
      call +
    pop af
    cp $07
    jr z,+
    cp $01
    jr nc,+
    xor a
+:  ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld b,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld a,(hl)
    inc hl
    push hl
      ld h,(hl)
      ld l,a
      call nz,_LABEL_7107_
    pop hl
    inc hl
    ret

_LABEL_6FD7_:
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    inc hl
    push hl
      ld h,(hl)
      ld l,a
      call z,_LABEL_7107_
    pop hl
    inc hl
    ret

_LABEL_6FE8_:
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld a,(hl)
    inc hl
    push hl
      ld h,(hl)
      ld l,a
      call z,_LABEL_7107_
    pop hl
    inc hl
    inc hl
    inc hl
    ret

LoadDungeonMap:
    ld hl,Frame2Paging
    ld (hl),:DungeonMaps

    ld a,(DungeonNumber)
    ld h,a
    ld l,0
    srl h               ; Divide by 2 to get a multiple of 128
    rr l
    ld de,DungeonMaps  ; Table
    add hl,de

    ld de,DungeonMap
    ld b,8*16 ; Byte count
-:  ld a,(hl)
    ; High nibble...
    rrca
    rrca
    rrca
    rrca
    and $0F
    ld (de),a
    inc de
    ; ...then low nibble
    ld a,(hl)
    and $0F
    ld (de),a
    inc de
    inc hl
    djnz -
    ; fall through

LoadDungeonData:
    ; Sprite palette
    ld hl,Frame2Paging
    ld (hl),:DungeonSpritePalette
    ld hl,DungeonSpritePalette
    ld de,TargetPalette+16+1
    ld bc,7
    ldir

    ld a,(DungeonNumber)
    add a,a
    add a,a                   ; x4
    ld l,a
    ld h,0
    ld de,DungeonData1
    add hl,de
    ld e,(hl) ; First byte = battle probability
    inc hl
    ld d,(hl) ; Second byte = DungeonMonsterPoolIndex
    ld (BattleProbability),de ; also DungeonMonsterPoolIndex
    inc hl
    ld a,(DungeonPaletteIndex)
    or a
    ld a,(hl) ; Third byte = palette index - 1, if DungeonPaletteIndex is >0
    jr nz,+
    ld e,a
    ld a,(DungeonNumber)
    ld hl,_70a1
    ld bc,_sizeof__70a1 ; 6
    cpir
    ld a,e ; If found, use n+1
    jr z,+
    ld a,-1 ; Else use index 0 = black
+:  inc a
    ld (DungeonPaletteIndex),a ; And store it in DungeonPaletteIndex
    add a,a ; Multiply by 8
    add a,a
    add a,a
    ld l,a
    ld h,$00
    ld de,DungeonPalettes
    add hl,de
    ld a,(hl)
    ld (TargetPalette),a
    ld de,TargetPalette+8
    ld bc,8
    ldir ; Load it
    ; Clone a couple of colours
    ld a,(TargetPalette+9)
    ld (TargetPalette+8),a
    ld a,(TargetPalette+13)
    ld (TargetPalette+16),a
    ret

CheckDungeonMusic:
    ld hl,Frame2Paging
    ld (hl),:DungeonData1
    ; Index into table by DungeonNumber
    ld a,(DungeonNumber)
    add a,a
    add a,a
    ld l,a
    ld h,0
    ld de,DungeonData1+DungeonData.Music
    add hl,de
    ld a,(hl)
    jp CheckMusic

; Data from 709A to 70A6 (13 bytes)
DungeonSpritePalette:
.db $00 $3F $30 $38 $03 $0B $0F
_70a1:
.db $01 $02 $14 $15 $16 $21

---: ld a,(_RAM_C2F5_)
    or a
    ret z
    inc a
    ld (_RAM_C2F5_),a
    ld hl,Frame2Paging
    ld (hl),$14
    ld h,$00
    ld l,a
    add hl,hl
    ld de,$BDB8
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld b,(hl)
    inc hl
--: push bc
      ld e,(hl)
      inc hl
      ld d,(hl)
      inc hl
      ld b,(hl)
      inc hl
-:    ld a,(hl)
      add a,$80
      cp $C0
      jr c,+
      ld (de),a
+:    inc de
      inc de
      inc hl
      djnz -
    pop bc
    djnz --
    ret

_LABEL_70DB_:
    ld b,$01
    call DungeonGetRelativeSquare
    and $07
    cp $07
    jr z,---
    sub $02
    ret c
    bit 7,(hl)
    jr z,_LABEL_70EF_
    add a,$06
_LABEL_70EF_:
    ld hl,Frame2Paging
    ld (hl),$06
    add a,a
    ld hl,_DATA_7118_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld de,_RAM_D114_
    ld bc,$1218
_LABEL_7107_:
    push bc
      push de
        ld b,$00
        ldir
        ex de,hl
      pop hl
      ld bc,$0040
      add hl,bc
      ex de,hl
    pop bc
    djnz _LABEL_7107_
    ret

; Pointer Table from 7118 to 712D (11 entries,indexed by DungeonMap)
_DATA_7118_:
.dw _DATA_1AC50_ _DATA_1AE00_ _DATA_1AFB0_ _DATA_1B160_ _DATA_1B670_ _DATA_1B310_ _DATA_1B310_ _DATA_1B820_
.dw _DATA_1B4C0_ _DATA_1B4C0_ _DATA_1B9D0_

; Data from 712E to 7301 (468 bytes)
_DATA_712E_:
.db $D4 $D1 $08 $18 $90 $80 $1C $D2 $07 $08 $F4 $82 $0C $06 $50 $D1
.db $A0 $81 $30 $82 $6A $D1 $E8 $81 $78 $82 $18 $D2 $06 $10 $30 $80
.db $5C $D2 $05 $08 $CC $82 $06 $02 $18 $D2 $70 $81 $88 $81 $26 $D2
.db $7C $81 $94 $81 $5A $D2 $04 $0C $00 $80 $9E $D2 $03 $04 $C0 $82
.db $04 $02 $5A $D2 $50 $81 $60 $81 $64 $D2 $58 $81 $68 $81 $94 $D1
.db $0A $18 $BC $83 $1A $D2 $08 $0C $B0 $87 $0E $0A $0C $D1 $4C $85
.db $64 $86 $2A $D1 $D8 $85 $F0 $86 $18 $D2 $06 $10 $5C $83 $5C $D2
.db $05 $08 $88 $87 $08 $04 $D6 $D1 $CC $84 $0C $85 $E6 $D1 $EC $84
.db $2C $85 $5A $D2 $04 $0C $2C $83 $9E $D2 $03 $04 $7C $87 $04 $02
.db $5A $D2 $AC $84 $BC $84 $64 $D2 $B4 $84 $C4 $84 $92 $D1 $0A $1C
.db $A0 $88 $1A $D2 $08 $0C $EC $8D $12 $0C $88 $D0 $58 $8A $08 $8C
.db $AC $D0 $30 $8B $E0 $8C $18 $D2 $06 $10 $40 $88 $5C $D2 $05 $08
.db $C4 $8D $08 $04 $D6 $D1 $D8 $89 $18 $8A $E6 $D1 $F8 $89 $38 $8A
.db $5A $D2 $04 $0C $10 $88 $9E $D2 $03 $04 $B8 $8D $04 $02 $5A $D2
.db $B8 $89 $C8 $89 $64 $D2 $C0 $89 $D0 $89 $50 $D1 $0C $20 $DC $8E
.db $DA $D1 $0A $0C $E0 $97 $16 $12 $00 $D0 $7C $91 $20 $96 $2E $D0
.db $08 $93 $94 $94 $18 $D2 $06 $10 $7C $8E $5C $D2 $05 $08 $B8 $97
.db $08 $06 $D4 $D1 $BC $90 $1C $91 $E6 $D1 $EC $90 $4C $91 $5A $D2
.db $04 $0C $4C $8E $9E $D2 $03 $04 $AC $97 $06 $04 $18 $D2 $5C $90
.db $8C $90 $24 $D2 $74 $90 $A4 $90 $0C $D1 $0E $28 $00 $99 $D8 $D1
.db $0B $10 $28 $A1 $16 $0E $00 $D0 $10 $9C $78 $9E $32 $D0 $44 $9D
.db $AC $9F $16 $D2 $06 $14 $88 $98 $5C $D2 $05 $08 $00 $A1 $08 $04
.db $D4 $D1 $90 $9B $D0 $9B $E8 $D1 $B0 $9B $F0 $9B $5A $D2 $04 $0C
.db $58 $98 $5C $D2 $04 $08 $E0 $A0 $06 $04 $18 $D2 $30 $9B $60 $9B
.db $24 $D2 $48 $9B $78 $9B $88 $D0 $12 $30 $C0 $A2 $96 $D1 $0E $14
.db $38 $AB $16 $0A $00 $D0 $70 $A7 $28 $A9 $36 $D0 $4C $A8 $04 $AA
.db $D6 $D1 $08 $14 $20 $A2 $5C $D2 $06 $08 $08 $AB $0A $06 $92 $D1
.db $80 $A6 $F8 $A6 $A8 $D1 $BC $A6 $34 $A7 $1A $D2 $06 $0C $D8 $A1
.db $5C $D2 $05 $08 $E0 $AA $06 $04 $18 $D2 $20 $A6 $50 $A6 $24 $D2
.db $38 $A6 $68 $A6

; Data from 7302 to 7304 (3 bytes)
DungeonTilesTable:
.db $07 $00 $80

; Data from 7305 to 7305 (1 bytes)
_DATA_7305_:
.db $04

; Pointer Table from 7306 to 7307 (1 entries,indexed by unknown)
.dw _DATA_10B0F_

; Data from 7308 to 73E5 (222 bytes)
.db $07 $4B $8A $04 $D4 $8E $07 $1E $95 $04 $A4 $92 $07 $6B $9F $04
.db $73 $96 $07 $13 $AA $04 $34 $9A $08 $00 $80 $04 $02 $9E $08 $ED
.db $89 $04 $06 $89 $08 $23 $A4 $04 $D3 $A1 $09 $D1 $83 $04 $35 $A5
.db $07 $22 $B4 $04 $80 $A8 $05 $AF $B1 $04 $A6 $AB $07 $22 $B4 $04
.db $5B $AF $09 $D1 $83 $04 $3D $B3 $08 $23 $A4 $04 $6C $B7 $08 $ED
.db $89 $04 $06 $89 $08 $3F $96 $1C $C0 $A6 $08 $06 $9D $1C $35 $A9
.db $05 $27 $AA $1C $D0 $AB $09 $00 $80 $1C $C9 $AE $05 $27 $AA $1C
.db $0C $B2 $08 $06 $9D $1C $C2 $B5 $08 $3F $96 $1C $5A $B9 $08 $ED
.db $89 $04 $06 $89 $09 $4A $8F $05 $00 $80 $09 $BD $9A $05 $67 $83
.db $09 $0D $A6 $05 $95 $86 $08 $75 $AF $05 $7A $89 $04 $00 $80 $05
.db $62 $8C $05 $30 $B8 $05 $18 $8F $08 $26 $B9 $05 $8F $91 $08 $ED
.db $89 $04 $06 $89 $08 $26 $B9 $05 $C6 $93 $05 $30 $B8 $05 $2E $97
.db $04 $00 $80 $05 $AD $9A $08 $75 $AF $05 $7E $9E $09 $0D $A6 $05
.db $48 $A2 $09 $BD $9A $05 $12 $A6 $09 $4A $8F $04 $BE $BB

_LABEL_73E6_:
    push bc
    push de
    push hl
      call +
    pop hl
    pop de
    pop bc
    ret

+:  ld hl,PaletteRotateEnabled
    ld a,(hl)
    dec (hl)
    jp m,+
    ld a,(ScrollDirection)
    ld c,a
    jp ++

+:  ld (hl),$00
    ld a,(ControlsNew)
    and $0F
    or $80
    ld c,a
    ld a,(VehicleMovementFlags)
    or a
    ld a,$0F
    jr z,+
    ld a,$07
+:  ld (PaletteRotateEnabled),a
++:  ld de,$0001
    ld a,(VehicleMovementFlags)
    or a
    jr z,+
    inc e
+:  ld a,(VScroll)
    ld d,a
    ld hl,(VLocation)
    ld b,h
    bit 0,c
    jr z,++
    ld a,$02
    bit 7,c
    call nz,_LABEL_7787_
    jr nz,++
    ld a,d
    sub e
    cp $E0
    jr c,+
    sub $20
+:  ld d,a
    ld a,l
    sub e
    cp $C0
    jr c,+
    sub $40
    dec h
+:  ld l,a
    ld a,$01
    jp +++

++:  bit 1,c
    jr z,++++
    ld a,$04
    bit 7,c
    call nz,_LABEL_7787_
    jr nz,++++
    ld a,d
    add a,e
    cp $E0
    jr c,+
    add a,$20
+:  ld d,a
    ld a,l
    add a,e
    cp $C0
    jr c,+
    add a,$40
    inc h
+:  ld l,a
    ld a,$02
+++:ld (ScrollDirection),a
    ld a,$FF
    ld (MovementInProgress),a
    ld a,d
    ld (VScroll),a
    ld a,h
    and $07
    ld h,a
    ld (VLocation),hl
    cp b
    call nz,DecompressScrollingTilemapData
    jp _LABEL_75DD_

++++:
    ld d,$00
    ld hl,(HLocation)
    ld b,h
    bit 2,c
    jr z,+
    ld a,$06
    bit 7,c
    call nz,_LABEL_7787_
    jr nz,+
    or a
    sbc hl,de
    ld a,$04
    jp ++

+:  bit 3,c
    jr z,+++
    ld a,$08
    bit 7,c
    call nz,_LABEL_7787_
    jr nz,+++
    add hl,de
    ld a,$08
++:  ld (ScrollDirection),a
    ld a,$FF
    ld (MovementInProgress),a
    ld a,l
    neg
    ld (HScroll),a
    ld a,h
    and $07
    ld h,a
    ld (HLocation),hl
    cp b
    jp nz,DecompressScrollingTilemapData
    jp _LABEL_7549_

+++:ld a,SFX_d6
    ld (NewMusic),a
    xor a
    ld (MovementInProgress),a
    ld (ScrollDirection),a
    ld (PaletteRotateEnabled),a
    ret

.orga $74e0
.section "Decompress (scrolling tilemap?) data to _RAM_cc00_-_RAM_cfff_" overwrite
DecompressScrollingTilemapData:
    ld a,(_RAM_C262_)
    ld (Frame2Paging),a

    ld a,(VLocation+1)
    add a,a
    ld e,a
    add a,a
    add a,a
    add a,a
    add a,e
    ld e,a
    ld a,(HLocation+1)
    add a,a
    add a,e
    ld e,a
    ld d,$00
    ld hl,(_RAM_C260_)
    add hl,de          ; hl = _RAM_c260_ + VLocation high byte * 18 + HLocation high byte * 2
    ld a,(hl)          ;    = pos
    inc hl
    push hl
      ld h,(hl)
      ld l,a         ; hl = word there (pos+0,1) = compressed data offset
      ld de,_RAM_CC00_
      call _DecompressToDE
    pop hl
    push hl
      inc hl
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a         ; hl = next word (pos+2,3) = next compressed data offset
      ld de,_RAM_CD00_
      call _DecompressToDE
    pop hl
    ld de,17
    add hl,de
    ld a,(hl)
    inc hl
    push hl
      ld h,(hl)
      ld l,a         ; hl = 17 bytes later = pos+20,21
      ld de,_RAM_CE00_
      call _DecompressToDE
    pop hl
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a             ; hl = next word = pos+22,23
    ld de,_RAM_CF00_
    ; fall through
_DecompressToDE:
    ld b,$00
--: ld a,(hl)          ; get header <--------------------------+
    or a               ;                                       |
    ret z              ; exit when zero                        |
    jp m,+             ; If high bit is set ----------------+  |
    ld b,a             ; b = count                          |  |
    inc hl             ;                                    |  |
    ld a,(hl)          ; get data                           |  |
-:  ld (de),a          ; copy to de  <-----------+          |  |
    inc de             ; (RLE)                   |          |  |
    djnz -             ; repeat b times ---------+          |  |
    inc hl             ; move to next header                |  |
    jp --              ; -----------------------------------|--+
+:  and $7f            ; Strip high bit --------------------+  |
    ld c,a             ; c = count                             |
    inc hl             ; next data                             |
    ldir               ; copy c bytes to de (not RLE)          |
    jp --              ; --------------------------------------+
.ends
.orga $7549

_LABEL_7549_:
    ld a,(ScrollDirection)
    and $0C
    ret z
    ld b,a
    ld a,(_RAM_C263_)
    ld (Frame2Paging),a
    ld c,$00
    ld a,(HLocation)
    and $07
    jr z,+
    ld a,b
    and $08
    jr nz,+
    ld c,$08
+:  ld a,(VScroll)
    and $F0
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,(HLocation)
    add a,c
    rrca
    rrca
    and $3C
    add a,l
    ld e,a
    ld a,h
    add a,$D0
    ld d,a
    ld h,$CC
    ld a,(VLocation)
    and $F0
    ld l,a
    ld a,(HLocation)
    add a,c
    jr nc,+
    inc h
+:  rrca
    rrca
    rrca
    rrca
    and $0F
    add a,l
    ld l,a
    ld a,b
    and $08
    jr z,+
    inc h
+:  ld b,$0E
-:  push bc
      push hl
        ld l,(hl)
        ld h,$10
        add hl,hl
        add hl,hl
        add hl,hl
        ldi
        ldi
        ldi
        ldi
        ld a,$3C
        add a,e
        ld e,a
        adc a,d
        sub e
        ld d,a
        ldi
        ldi
        ldi
        ldi
      pop hl
      ld a,$10
      add a,l
      cp $C0
      jr c,+
      sub $C0
      inc h
      inc h
+:    ld l,a
      ld a,$3C
      add a,e
      ld e,a
      adc a,d
      sub e
      sub $D7
      jr nc,+
      add a,$07
+:    add a,$D0
      ld d,a
    pop bc
    djnz -
    ret

_LABEL_75DD_:
    ld a,(ScrollDirection)
    and $03
    ret z
    ld b,a
    and $01
    ld a,(_RAM_C263_)
    ld (Frame2Paging),a
    ld a,(VScroll)
    ld b,$00
    jr nz,++
    cp $20
    jr c,+
    add a,$20
+:  ld b,$C0
    add a,b
++:  and $F0
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,(HLocation)
    rrca
    rrca
    and $3C
    add a,l
    ld e,a
    ld a,h
    add a,$D0
    ld d,a
    ld a,(VLocation)
    and $F0
    add a,b
    ld l,a
    adc a,$00
    sub l
    ld h,a
    ld a,(HLocation)
    rrca
    rrca
    rrca
    rrca
    and $0F
    add a,l
    ld l,a
    ld bc,$00C0
    or a
    sbc hl,bc
    ld a,$CE
    jr nc,+
    add hl,bc
    ld a,$CC
+:  ld h,a
    ld b,$10
-:  push bc
      push hl
        ld l,(hl)
        ld h,$10
        add hl,hl
        add hl,hl
        add hl,hl
        ldi
        ldi
        ldi
        ldi
        push de
          ld a,$3C
          add a,e
          ld e,a
          adc a,d
          sub e
          ld d,a
          ldi
          ldi
          ldi
          ldi
        pop de
        ld a,e
        and $3F
        jr nz,+
        ld a,e
        sub $40
        ld e,a
+:    pop hl
      ld a,l
      and $F0
      ld b,a
      inc l
      ld a,l
      and $F0
      cp b
      jr z,+
      inc h
      ld l,b
+:  pop bc
    djnz -
    ret

.orga $7673
.section "Update scrolling tilemap" overwrite
; Update scrolling tilemap
UpdateScrollingTilemap: ; $7673
    ld a,(ScrollDirection) ; check ScrollDirection (%----RLDU)
    and $0F
    ret z              ; return if not scrolling
    ld b,a             ; b = ScrollDirection
    and $03
    ld a,(_RAM_C263_)
    ld (Frame2Paging),a ; Set to page _RAM_c263_ - why?
    jp nz,_Vertical    ; if ScrollDirection==U or D then handle differently
_Horizontal:
; Updates column of tiles in tilemap
    ld c,$00           ; c = $00
    ld a,(HLocation)   ; a = low byte of HLocation
    and $07
    jr z,+             ; if HLocation is not a multiple of 8:
    ld a,b                 ; if ScrollDirection==R
    and $08
    jr nz,+
    ld c,$08               ; then c=8
+:  ld a,(HLocation)
    add a,c            ; a = low HLocation + c (0 or 8)
    rrca               ; shift right by 2 (ie. divide by 4)
    rrca
    and %00111110
    ld e,a
    ld l,a
    ld d,$78           ; de = tilemap     + (low HLocation + c)/4
    ld h,$d0           ; hl = TileMapData + (low HLocation+ c)/4
    ld bc,$1cbe        ; counter = $1c = 28 rows; c = VDPData
-:  push bc
      rst SetVRAMAddressToDE
      nop            ; delay
      nop
      nop
      outi           ; output byte
      nop            ; delay
      nop
      nop
      outi           ; output second byte
      ld bc,31*2     ; add 62 = 31 tiles to hl (tilemap in RAM)
      add hl,bc
      ex de,hl       ; add 64 = 32 tiles to de (tilemap in VDP)
      ld c,32*2
      add hl,bc
      ex de,hl
    pop bc
    djnz -
    ret
_Vertical:
; updates row of tiles in tilemap
    ld a,b
    and $01            ; z = ScrollDirection==U
    ld a,(VScroll)
    ld b,$00           ; b = $00
    jr nz,++           ; if ScrollDirection==D
    cp $20             ; if VScroll>=$20
    jr c,+
    add a,$20          ; then a+=$20
+:  ld b,$c0           ; b = $c0
    add a,b            ; a = VScroll + $c0 + ($20 if VScroll>=$20)
++: and %11111000      ; zero low 3 bits -> now it's the offset into the RAM tilemap
    ld l,a             ; put in hl
    ld h,$00
    add hl,hl          ; multiply by 8
    add hl,hl
    add hl,hl
    ld a,h
    add a,$78
    ld d,a             ; de = tilemap + a*8
    ld e,l
    rst SetVRAMAddressToDE
    ld a,h
    add a,$D0
    ld h,a             ; hl = TileMapData + a*8
    ld bc,$40be        ; counter = $40 = 64 bytes = 32 tiles; c = VDPData
-:  outi               ; output byte
    nop                ; delay
    jp nz,-
    ret
.ends
; followed by
.orga $76ee
.section "Fill tilemap from compressed data? Not understood :(" overwrite
FillTilemap:          ; $76ee
    call _LABEL_78A5_
    ld a,(_RAM_C263_)
    ld (Frame2Paging),a
    ld a,(VScroll)
    and $f0            ; strip to high nibble
    ld l,a
    ld h,$00           ; hl = 00v0
    add hl,hl
    add hl,hl
    add hl,hl          ; hl = hl * 8
    ld a,(HLocation)
    rrca
    rrca
    and $3c            ; a = HLocation/4
    add a,l            ; add that to hl
    ld e,a
    ld a,h
    add a,$D0
    ld d,a             ; de = $d000+hl

    ld a,(VLocation)
    and $F0
    ld l,a
    ld a,(HLocation)
    rrca
    rrca
    rrca
    rrca
    and $0F
    add a,l
    ld l,a
    ld h,$cc           ; hl = $ccyn where y = high nibble of y location, x = high nibble of x location

    ld b,$0c           ; counter (12)
--: push bc
      push hl
        ld b,$10   ; counter (16)
-:      push bc
          push hl
            ld l,(hl)
            ld h,$10
            add hl,hl
            add hl,hl
            add hl,hl
            ldi
            ldi
            ldi
            ldi                ; copy 4 bytes from $8000 + 8*(hl) to de
            push de
              ld a,$3c       ; 60
              add a,e
              ld e,a
              adc a,d
              sub e
              ld d,a         ; de = de + 60
              ldi
              ldi
              ldi
              ldi            ; Copy another 4 bytes to there
            pop de
            ld a,e
            and $3F
            jr nz,+            ; If e is a multiple of $40
            ld a,e
            sub $40            ; then subtract $40
            ld e,a
+:        pop hl
          ld a,l
          and $F0
          ld b,a                 ; b = high nibble of l
          inc l
          ld a,l
          and $F0
          cp b                   ; if adding 1 doesn't change the high nibble (so low=$f???)
          jr z,+
          inc h                  ; inc h
          ld l,b                 ; and strip l to high nibble
+:      pop bc
        djnz -     ; repeat 16 times

        ld a,$80
        add a,e
        ld e,a
        adc a,d
        sub e      ; de = de + $80
        sub $d7    ; if de < $d700
        jr nc,+
        add a,$07  ; then subtract $d000
+:      add a,$d0  ; else subtract $0700
        ld d,a
      pop hl
      ld a,$10       ; add 16 to l
      add a,l
      cp $c0         ; when it e_RAM_ceed_s 192
      jr c,+
      sub $c0        ; subtract 192
      inc h          ; and add 2 to h
      inc h
+:    ld l,a
    pop bc
    djnz --            ; repeat 12 times
    ld a,$12           ; refresh full tilemap
    jp ExecuteFunctionIndexAInNextVBlank ; and ret
.ends
.orga $7787

_LABEL_7787_:
    push bc
    push hl
      ld c,a
      ld a,(_RAM_C2E9_)
      or a
      jr nz,+
      ld a,(VehicleMovementFlags)
      or a
      jr nz,++
      ld b,$00
      ld hl,_DATA_7CC6_ - 2
      add hl,bc
      ld a,(hl)
      call GetLocationUnknownData
      and $01
    pop hl
    pop bc
    ret

+:    xor a
    pop hl
    pop bc
    ret

++:   cp $04
      jr nz,++
      push de
        ld b,$00
        ld hl,$7CCE
        add hl,bc
        ex de,hl
        ld a,(de)
        call GetLocationUnknownData
        and $01
        jr nz,+
        inc de
        ld a,(de)
        call GetLocationUnknownData
        and $01
+:    pop de
    pop hl
    pop bc
    ret

++:   cp $08
      jr nz,++
      push de
        ld b,$00
        ld hl,$7CCE
        add hl,bc
        ex de,hl
        ld a,(de)
        call GetLocationUnknownData
        and $0A
        jr nz,+
        inc de
        ld a,(de)
        call GetLocationUnknownData
        and $0A
+:    pop de
    pop hl
    pop bc
    ret

++:   push de
        ld b,$00
        ld hl,$7CCE
        add hl,bc
        ld e,b
        ld a,(hl)
        inc hl
        ld d,(hl)
        call ++
        and $01
        ld c,a
        ld a,d
        ld d,c
        call ++
        and $01
        or d
        push af
          ld a,e
          or a
          jr z,+
          ld a,SFX_b7
          ld (NewMusic),a
+:      pop af
      pop de
    pop hl
    pop bc
    ret

++:  ld hl,_DATA_7D30_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld h,$CC
    ld a,(VLocation)
    add a,c
    jr c,+
    cp $C0
    jr c,++
+:  add a,$40
    inc h
    inc h
++:  and $F0
    ld l,a
    ld a,(HLocation)
    add a,b
    jr nc,+
    inc h
+:  rrca
    rrca
    rrca
    rrca
    and $0F
    add a,l
    ld l,a
    ld a,(hl)
    cp $D8
    jr c,_LABEL_788B_
    cp $E0
    jr nc,_LABEL_788B_
    ld (hl),$D7
    push de
      ld a,(VScroll)
      add a,c
      jr nc,+
      add a,$20
+:    cp $E0
      jr c,+
      add a,$20
+:    and $F0
      ld l,a
      ld h,$00
      add hl,hl
      add hl,hl
      add hl,hl
      ld a,(HLocation)
      add a,b
      rrca
      rrca
      and $3C
      add a,l
      ld e,a
      ld a,h
      add a,$78
      ld d,a
      ld hl,_DATA_7D5C_
      di
        ld bc, $0200 | VDPData
--:     push bc
          rst SetVRAMAddressToDE
          ld b,$04
-:        outi
          nop
          jp nz,-
          ex de,hl
          ld bc,$0040
          add hl,bc
          ex de,hl
        pop bc
        djnz --
      ei
    pop de
    ld a,$D7
    ld e,a
_LABEL_788B_:
    ld (_RAM_C2E5_),a
    ld hl,Frame2Paging
    ld (hl),$03
    ld hl,_DATA_FC6F_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(_RAM_C308_)
    cp $04
    jr c,+
    inc h
+:  ld a,(hl)
    ret

_LABEL_78A5_:
    ld a,(_RAM_C308_)
    cp $02
    ret nz
    ld a,(VehicleMovementFlags)
    cp $0C
    ret nz
    ld a,$0A
    call +
    ld a,$0C
    call +
    ld a,$12
    call +
    ld a,$14
    ; fall through
+:  ld hl,_DATA_7D30_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld c,(hl)
    inc hl
    ld b,(hl)          ; bc = (hl) = x,y to add?
    ld h,$CC
    ld a,(VLocation)
    add a,c            ; a=lo(VLocation)+c
    jr c,+
    cp $c0             ; if a is between $c0 and $ff then it's OK (?)
    jr c,++
+:  add a,$40          ; if a is >=$100 (borrow) then add $40
    inc h
    inc h              ; and add 2 to h -> $ce
++: and $f0            ; Strip a to high nibble
    ld l,a             ; -> l
    ld a,(HLocation)
    add a,b            ; Add b to lo(HLocation)
    jr nc,+
    inc h              ; if it's over $100 then hl++
+:  rrca
    rrca
    rrca
    rrca
    and $0f            ; divide by 16
    add a,l            ; add to l = nibble of VLocation
    ld l,a
    ld a,(hl)          ; so now we have an offset into the decompressed data. Get the byte
    cp $d8             ; if it's >$d8=216
    ret c
    cp $e0             ; and <=$e0=224
    ret nc
    ld (hl),$d7        ; then set it to $d7=215
    ret
;.ends
.orga $78f9

_LABEL_78F9_:
    ld bc,$0400
-:  push bc
      ld b,$00
      ld hl,_DATA_7CD8_
      add hl,bc
      ex de,hl
      ld a,(de)
      call GetLocationUnknownData
      and $0D
      jr nz,+
      inc de
      ld a,(de)
      call GetLocationUnknownData
      and $0D
      jr nz,+
      inc de
      ld a,(de)
      call GetLocationUnknownData
      and $0D
      jr nz,+
      inc de
      ld a,(de)
      call GetLocationUnknownData
      and $0D
      jr z,++
+:  pop bc
    ld a,c
    add a,$04
    ld c,a
    djnz -
    ld a,$FF
    or a
    ret

++:  pop bc
    ld a,c
    or a
    ret z
    ld de,$0010
    cp $04
    jr z,++
    cp $08
    jr nz,+
    ld de,$0000
+:  ld hl,(VLocation)
    ld a,l
    add a,$10
    cp $C0
    jr c,+
    add a,$40
    inc h
+:  ld l,a
    ld (VLocation),hl
    ld (_RAM_C311_),hl
++:  ld hl,(HLocation)
    add hl,de
    ld (HLocation),hl
    ld (_RAM_C313_),hl
    xor a
    ret

_LABEL_7964_:
    ld bc,$0800
-:  push bc
      ld b,$00
      ld hl,_DATA_7CE8_
      add hl,bc
      ex de,hl
      ld a,(de)
      call GetLocationUnknownData
      and $0A
      jr nz,+
      inc de
      ld a,(de)
      call GetLocationUnknownData
      and $0A
      jr nz,+
      inc de
      ld a,(de)
      call GetLocationUnknownData
      and $0A
      jr nz,+
      inc de
      ld a,(de)
      call GetLocationUnknownData
      and $0A
      jr z,++
+:  pop bc
    ld a,c
    add a,$06
    ld c,a
    djnz -
    ld a,$FF
    or a
    ret

++:  ld hl,$7CEC
_LABEL_79A0_:
    pop bc
    ld b,$00
    add hl,bc
    ld de,(VLocation)
    ld a,e
    add a,(hl)
    cp $C0
    jr c,++
    bit 7,(hl)
    jr nz,+
    add a,$40
    inc d
    jr ++

+:  sub $40
    dec d
++:  ld e,a
    ld (VLocation),de
    ld (_RAM_C311_),de
    inc hl
    ld a,(hl)
    ld e,a
    rlca
    sbc a,a
    ld d,a
    ld hl,(HLocation)
    add hl,de
    ld (HLocation),hl
    ld (_RAM_C313_),hl
    xor a
    ret

_LABEL_79D5_:
    ld a,(_RAM_C2D7_)
    and $03
    ld c,a
    add a,a
    add a,c
    add a,a
    ld c,a
    ld b,$08
-:  push bc
      ld b,$00
      ld hl,_DATA_7D18_
      add hl,bc
      ld a,(hl)
      call GetLocationUnknownData
      and $0D
      jr z,++
    pop bc
    ld a,c
    add a,$03
    cp $18
    jr c,+
    sub $18
+:  ld c,a
    djnz -
    ld a,$FF
    or a
    ret

++:  ld hl,_DATA_7D18_ + 1
    jp _LABEL_79A0_

.orga $7a07
.section "Get data from a table based on the current H/VLocation" overwrite
GetLocationUnknownData: ; $7a07
    ld hl,_DATA_7D30_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld c,(hl)
    inc hl
    ld b,(hl)          ; bc = word there
    ld h,$CC
    ld a,(VLocation)   ; a = c + lo(VLocation)
    add a,c
    jr c,+             ; if a>$ff
    cp $C0
    jr c,++            ; or <=$c0
+:  add a,$40          ; then add $40
    inc h              ; and add 2 to h -> $ce
    inc h
++: and $f0            ; strip to high nibble
    ld l,a             ; and keep in l
    ld a,(HLocation)   ; Add b to lo(HLocation)
    add a,b
    jr nc,+            ; if >$ff
    inc h              ; then inc h
+:  rrca
    rrca
    rrca
    rrca
    and $0f            ; divide by 16
    add a,l            ; put in l
    ld l,a
    ld a,(hl)          ; get data
    ld (_RAM_c2e5_),a       ; put that in _RAM_c2e5_
    ld hl,Frame2Paging
    ld (hl),$03        ; ???
    ld hl,_DATA_FC6F_
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a             ; hl = bc6f + a
    ld a,(_RAM_C308_)
    cp 4
    jr c,+
    inc h              ; if _RAM_c308_>=4 then inc h (add 256)
+:  ld a,(hl)          ; get data in a
    ret
.ends
.orga $7a4f

_LABEL_7A4F_:
    ld hl,_RAM_C2D5_
    ld a,(PaletteRotateEnabled)
    or a
    jp z,+
    ld (hl),$00
    ret

+:  ld a,(hl)
    or a
    ret nz
    ld (hl),$FF
    ld a,$14
    ld e,a
    call GetLocationUnknownData
    ld b,a
    rrca
    rrca
    rrca
    rrca
    and $0F
    ld (SceneType),a
    ld a,b
    and $08
    jr nz,++
    ld a,b
    and $04
    jp nz,_LABEL_7BCD_
    ld a,(VehicleMovementFlags)
    or a
    jr z,+
    ld a,$12
    ld e,a
    call GetLocationUnknownData
    and $08
    jr nz,++
    ld a,$0A
    ld e,a
    call GetLocationUnknownData
    and $08
    jr nz,++
    ld a,$0C
    ld e,a
    call GetLocationUnknownData
    and $08
    jr nz,++
    ld a,$14
    ld e,a
    call GetLocationUnknownData
+:  ld hl,(VLocation)
    ld (_RAM_C311_),hl
    ld hl,(HLocation)
    ld (_RAM_C313_),hl
    ret

++:  ld a,e
    ld hl,$7D30
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld de,(VLocation)
    ld a,e
    add a,(hl)
    jr c,+
    cp $C0
    jr c,++
+:  add a,$40
    inc d
++:  ld e,a
    ex de,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl
    inc hl
    ld c,(hl)
    ld b,$00
    ld hl,(HLocation)
    add hl,bc
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld e,h
    ld hl,Frame2Paging
    ld (hl),$03
    ld hl,(_RAM_C2D9_)
-:  ld a,(hl)
    cp $FF
    ret z
    push hl
      ld a,(hl)
      cp d
      jr z,++
      inc a
      ld b,a
      and $0F
      cp $0C
      ld a,b
      jr c,+
      add a,$10
      and $70
+:    cp d
      jr nz,+++
++:   inc hl
      ld a,(hl)
      cp e
      jr z,++++
      inc a
      cp e
      jr z,++++
+++:pop hl
    ld bc,$0006
    add hl,bc
    jp -

++++:
    pop hl
    inc hl
    inc hl
    ld a,(hl) ; Get byte
    cp $08
    jp nz,_LABEL_7B60_
    ; $08
_LABEL_7B1A_:
    ld (FunctionLookupIndex),a
    inc hl

.orga $7b1e
.section "???" overwrite
_LABEL_7B1E_:
    ld a,(hl)          ; get byte at hl (eg 01)
    ld (_RAM_c308_),a       ; save in _RAM_c308_ and _RAM_c309_
    ld (_RAM_C309_),a
    inc hl             ; next byte hhhhllll in de (eg 8b)
    ld e,(hl)
    ld d,$00
    ex de,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl          ; *16 -> 0000hhhhllll0000
    ld a,l
    sub $60            ; Subtract $60 from llll0000
    jr c,+
    cp $c0             ; If it's positive and <$c0 then skip:
    jr c,++
+:  sub $40            ; subtract $40
    dec h              ; and take 1 from h
++: ld l,a             ; Put it back in hl
    ld a,h
    and $07            ; trim to 00000hhh
    ld h,a
    ld (VLocation),hl
    ld (_RAM_C311_),hl
    ex de,hl           ; get hl back
    inc hl
    ld a,(hl)          ; get next byte (eg 69)
    sub $08            ; subtract 8
    and $7f            ; strip high bit
    ld l,a
    ld h,$00           ; put in hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl          ; multiply by 16
    ld (HLocation),hl
    ld (_RAM_C313_),hl
    xor a              ; zero _RAM_c30e_
    ld (VehicleMovementFlags),a
    jp _LABEL_7BAB_

_LABEL_7B60_:
    cp $0A
    jp nz,+
    ; $0a = dungeon
    ld (FunctionLookupIndex),a
    inc hl
    ; Next byte = dungeon number
    ld d,(hl)
    inc hl
    ; Next byte = dungeon position
    ld e,(hl)
    ld (DungeonPosition),de ; Set DungeonPosition and DungeonNumber
    inc hl
    ; Next byte = DungeonFacingDirection
    ld a,(hl)
    ld (DungeonFacingDirection),a
    ld hl,(_RAM_C311_)
    ld (VLocation),hl
    ld hl,(_RAM_C313_)
    ld (HLocation),hl
    xor a
    ld (VehicleMovementFlags),a
    jp _LABEL_7BAB_

+:  cp $0C
    ret nz
    ld (FunctionLookupIndex),a
    inc hl
    ld a,(hl)
    ld (SceneType),a
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld (RoomIndex),hl
    xor a
    ld (_RAM_C29D_InBattle),a
    ld hl,(_RAM_C311_)
    ld (VLocation),hl
    ld hl,(_RAM_C313_)
    ld (HLocation),hl
_LABEL_7BAB_:
+++:ld a,(CharacterSpriteAttributes+16) ; CharacterSpriteAttributes[0].currentanimframe
    ld (_RAM_C2D7_),a

    ld hl,OutsideAnimCounters ; Zero OutsideAnimCounters
    ld de,OutsideAnimCounters+1
    ld bc,24-1
    ld (hl),0
    ldir

    ld hl,CharacterSpriteAttributes ; Zero CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes + 1
    ld bc,$100-1
    ld (hl),0
    ldir

    pop hl              ; pop number pushed before call into hl
    ret
.ends
.org $7bcd

_LABEL_7BCD_:
    ld a,(_RAM_C2E5_)
    cp $4C
    jp nz,+
    ld a,(_RAM_C309_)
    cp $05
    ret nz
    ld a,(HaveLutz)
    or a
    ret z
    ld a,$0A
    ld (FunctionLookupIndex),a
    ld hl,$00DE
    ld (DungeonPosition),hl
    ld a,$00
    ld (DungeonFacingDirection),a
    ld hl,(_RAM_C311_)
    ld (VLocation),hl
    ld hl,(_RAM_C313_)
    ld (HLocation),hl
    jp _LABEL_7BAB_

+:  cp $5E
    jp nz,+
    ld a,(VehicleMovementFlags)
    or a
    ret nz
    ld a,Item_Compass
    call HaveItem
    ret z
    ld hl,$00A0 ; _room_a0_EppiWoodsNoCompass
    ld (RoomIndex),hl
_LABEL_7C15_:
    ld a,$0C
    ld (FunctionLookupIndex),a
    ld hl,(_RAM_C311_)
    ld (VLocation),hl
    ld hl,(_RAM_C313_)
    ld (HLocation),hl
    jp _LABEL_7BAB_

+:  cp $5F
    ret c
    cp $64
    jp nc,+
    ld a,(VehicleMovementFlags)
    cp $08
    ret z
    call _LABEL_7E67_
    ld c,$02
    jp _LABEL_7C85_

+:  cp $AD
    jp nz,+
    ld a,(_RAM_C309_)
    sub $04
    ret c
    ld l,a
    ld h,$00
    ld e,l
    ld d,h
    add hl,hl
    add hl,de
    ld de,$7D63
    add hl,de
    ld a,$08
    jp _LABEL_7B1A_

+:  cp $C3
    ret c
    cp $C7
    jp nc,+
    ld a,(VehicleMovementFlags)
    or a
    ret nz
    ld a,$FF
    ld (_RAM_C29D_InBattle),a
    ld a,Enemy_Antlion
    ld (EnemyNumber),a
    jp _LABEL_7C15_

+:  cp $C7
    ret c
    cp $D2
    ret nc
    ld a,$3B
    call HaveItem
    ret z
    call _LABEL_7E67_
    ld c,$1E
_LABEL_7C85_:
    ld b,$00
    ld a,$03
    call +
    ld a,$02
    call +
    ld a,$01
    call +
    ld a,$00
    call +
    ld a,b
    or a
    ret z
    ld (_RAM_C2F0_),a
    ld hl,$00AE
    ld (RoomIndex),hl ; _room_ae_5902
    ld a,$0C
    ld (FunctionLookupIndex),a
    jp _LABEL_7BAB_

+:  call PointHLToCharacterInA
    jr z,++
    inc hl
    ld a,(hl)
    sub c
    jr nc,+
    xor a
+:  ld (hl),a
    jr nz,++
    dec hl
    ld (hl),a
    sub $01
++:  rl b
    ret

; Data from 7CC4 to 7CC5 (2 bytes)
.db $14 $14

; Data from 7CC6 to 7CD7 (18 bytes)
_DATA_7CC6_:
.db $0C $0C $1C $1C $12 $12 $16 $16 $0A $14 $02 $04 $1A $1C $08 $10
.db $0E $16

; Data from 7CD8 to 7CE7 (16 bytes)
_DATA_7CD8_:
.db $0A $0C $12 $14 $0C $0E $14 $16 $12 $14 $1A $1C $14 $16 $1C $1E

; Data from 7CE8 to 7D17 (48 bytes)
_DATA_7CE8_:
.db $02 $04 $0A $0C $F0 $00 $04 $06 $0C $0E $F0 $10 $0E $26 $16 $28
.db $00 $20 $16 $28 $1E $2A $10 $20 $1C $1E $22 $24 $20 $10 $1A $1C
.db $20 $22 $20 $00 $10 $12 $18 $1A $10 $F0 $08 $0A $10 $12 $00 $F0

; Data from 7D18 to 7D2F (24 bytes)
_DATA_7D18_:
.db $02 $E0 $F0 $04 $E0 $00 $0E $F0 $10 $16 $00 $10 $1C $10 $00 $1A
.db $10 $F0 $10 $00 $E0 $08 $F0 $E0

.orga $7d30
.section "Lookup table $7d30" overwrite
; Data from 7D30 to 7D5B (44 bytes)
_DATA_7D30_:
; Pairs of y,x amounts???
.db $40,$60,$40,$70,$40,$80,$40,$90,$50,$60,$50,$70,$50,$80,$50,$90
.db $60,$60,$60,$70,$60,$80,$60,$90,$70,$60,$70,$70,$70,$80,$70,$90
.db $80,$70,$80,$80,$80,$90,$50,$a0,$60,$a0,$70,/*stop???*/$a0

; Data from 7D5C to 7D9F (68 bytes)
_DATA_7D5C_:
.db $91 $01 $92 $01 $93 $01 $94 $01 $00 $39 $55 $00 $39 $55 $00 $48
.db $49 $00 $47 $38 $00 $66 $55 $00 $25 $42 $00 $14 $0F $00 $41 $1A
.db $00 $66 $75 $00 $38 $66 $01 $27 $64 $01 $53 $73 $01 $27 $64 $01
.db $71 $5A $01 $26 $29 $02 $5B $2C $02 $38 $49 $02 $5B $2C $02 $38
.db $49 $00 $16 $6A

.ends
; followed by
.orga $7da0
.section "Fade out full palette (and wait)" overwrite
FadeOutTilePalette:   ; $7da0
    ld hl,$1009
    ld (PaletteFadeControl),hl ; PaletteFadeControl = fade out/counter=9; PaletteSize=16
    jr _FadeOutPalette

FadeOutFullPalette:   ; $7da8
    ld hl,$2009
    ld (PaletteFadeControl),hl ; PaletteFadeControl = fade out/counter=9; PaletteSize=32

_FadeOutPalette:
    ld a,$16           ; VBlankFunction_PaletteEffects
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(PaletteFadeControl)       ; wait for palette to fade out
    or a
    jp nz,_FadeOutPalette
    ret
.ends
; followed by
.orga $7dbb
.section "Palette fading" overwrite
FadeInTilePalette:     ; $7dbb
    ld hl,$1089        ; Set PaletteFadeControl to fade in ($89) the tile palette ($10)
    ld (PaletteFadeControl),hl
    jr _DoFade         ; doesn't blank ActualPalette first

FadeInWholePalette:    ; $7dc3
    ld hl,$2089        ; Set PaletteFadeControl to fade in ($89) the whole palette ($20)
    ld (PaletteFadeControl),hl

    ld hl,ActualPalette
    ld de,ActualPalette + 1
    ld bc,31
    ld (hl),$00
    ldir               ; Fill ActualPalette with black

_DoFade:
    ld a,$16           ; VBlankFunction_18b
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(PaletteFadeControl)
    or a
    jp nz,_DoFade      ; Repeat until palette fade finished
    ret
.ends
; followed by
.orga $7de3
.section "Fade palette in RAM" overwrite
; Main function body only runs every 4 calls (using PaletteFadeFrameCounter as a counter)
; Checks PaletteFadeControl - bit 7 = fade in, rest = counter
; PaletteSize tells it how many palette entries to fade
; TargetPalette and ActualPalette are referred to
FadePaletteInRAM:      ; 7de3
    ld hl,PaletteFadeFrameCounter ; Decrement PaletteFadeFrameCounter
    dec (hl)
    ret p              ; return if >=0
    ld (hl),$03        ; otherwise set to 3 and continue (so only do this part every 4 calls)
    ld hl,PaletteFadeControl ; Check PaletteFadeControl
    ld a,(hl)
    bit 7,a            ; if bit 7 is set
    jp nz,_FadeIn      ; then fade in
    or a               ; If PaletteFadeControl==0
    ret z              ; then return
    dec (hl)           ; Otherwise, decrement PaletteFadeControl
    inc hl
    ld b,(hl)          ; PaletteSize
    ld hl,ActualPalette
-:  call _FadeOut      ; process PaletteSize bytes from ActualPalette
    inc hl
    djnz -
    ret

_FadeOut:
    ld a,(hl)
    or a
    ret z              ; zero = black = no fade to do
    and %00000011      ; check red
    jr z,+
    dec (hl)           ; If non-zero, decrement
    ret
+:  ld a,(hl)
    and %00001100      ; check green
    jr z,+
    ld a,(hl)
    sub $04            ; If non-zero, decrement
    ld (hl),a
    ret
+:  ld a,(hl)
    and $30            ; check blue
    ret z
    sub $10            ; If non-zero, decrement
    ld (hl),a
    ret

_FadeIn:
    cp $80             ; Is only bit 7 set?
    jr nz,+            ; If not, handle that
    ld (hl),$00        ; Otherwise, zero it (PaletteFadeControl)
    ret
+:  dec (hl)           ; Decrement it (PaletteFadeControl)
    inc hl
    ld b,(hl)          ; PaletteSize
    ld hl,TargetPalette
    ld de,ActualPalette
-:  call _FadePaletteEntry ; compare PaletteSize bytes from ActualPalette
    inc hl
    inc de
    djnz -
    ret

_FadePaletteEntry:
    ld a,(de)          ; If (de)==(hl) then leave it
    cp (hl)
    ret z
    add a,%00010000    ; increment blue
    cp (hl)
    jr z,+
    jr nc,++           ; if it's too far then try green
+:  ld (de),a          ; else save that
    ret
++:  ld a,(de)
    add a,%00000100    ; increment green
    cp (hl)
    jr z,+
    jr nc,++           ; if it's too far then try red
+:  ld (de),a          ; else save that
    ret
++:  ex de,hl
    inc (hl)           ; increment red
    ex de,hl
    ret
.ends
.orga $7e4f

_LABEL_7E4F_:
    ld a,$0A
    ld (PaletteFlashFrames),a
    ld hl,$0D13
    ld (PaletteFlashCount),hl
-:  ld a,$16
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(PaletteFlashFrames)
    or a
    jp nz,-
    ret

_LABEL_7E67_:
    ld a,$0A
    ld (PaletteFlashFrames),a
    ld hl,$0E03
    ld a,(EnemyNumber)
    cp Enemy_GoldDrake
    jr z,+
    cp Enemy_DarkForce
    jr z,+
    cp Enemy_Nightmare
    jr z,+
    ld hl,$0D03
+:  ld (PaletteFlashCount),hl
-:  ld a,$16
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(PaletteFlashFrames)
    or a
    jp nz,-
    ret

.orga $7e91
.section "Flash palette" overwrite
; if PaletteFlashFrames is non-zero then it is counted down, each time setting palette entries
; PaletteFlashStart to PaletteFlashCount alternately to white or their original colours.
FlashPaletteInRAM:
    ld a,(PaletteFlashFrames) ; check PaletteFlashFrames
    or a
    ret z              ; Do nothing if zero
    dec a              ; else decrement
    ld (PaletteFlashFrames),a
    rrca               ; If low bit is zero
    jp c,+
    ld hl,TargetPalette
    ld de,ActualPalette
    ld bc,32
    ldir               ; then copy target to actual palette
    ret
+:  ld hl,(PaletteFlashCount) ; else set palette entries to white
    ld b,h             ; b = PaletteFlashCount
    ld a,l             ; a = PaletteFlashStart
    ld hl,ActualPalette
    add a,l
    ld l,a             ; hl = [PaletteFlashStart]th palette entry
    ld a,$3f           ; White
-:  ld (hl),a          ; Set palette entry to white
    inc hl
    djnz -
    ret
.ends
; followed by
.orga $7ebb
.section "Palette rotation" overwrite
PaletteRotate:
    ld a,(VehicleMovementFlags)
    or a
    ret z
    cp $10             ; Handle values 16 and 17 specially
    jp z,_ResetPalette
    cp $11
    jp z,_ResetPalette
    cp $0e             ; Do nothing if >=14
    ret nc
    ld b,a             ; still VehicleMovementFlags
    ld c,$d1           ;
    cp $08             ; if it's 8...
    jp z,+             ; skip this bit:
    ld c,$d0           ; change c
    ld a,(PaletteRotateEnabled) ; check PaletteRotateEnabled is not zero
    or a
    ret z              ; if it is, exit
+:  ld hl,PaletteRotateCounter
    dec (hl)           ; decrement PaletteRotateCounter
    ret p              ; exit while >= 0
    ld (hl),$03        ; reset to 3 -> pass 1 call in 4 -> 15 per second
    dec hl             ; hl = PaletteRotatePos
    ld a,c             ; $d1 or $d0
    ld (NewMusic),a
    ld a,(hl)          ; check (PaletteRotatePos)
    inc a              ; increment
    cp $03             ; if >=3
    jr c,+
    xor a              ; then zero -> 0-2
+:  ld (hl),a          ; put back in PaletteRotatePos
    ld c,a
    ld a,b
    cp $08             ; if _RAM_c30e_==8 then
    ld hl,_Palette1    ; this palette data
    ld de,PaletteAddress+29 ; palette entries 29-31
    jp nz,+            ; else
    ld hl,_Palette2    ; this palette data
    ld de,PaletteAddress+23 ; palette entry 23-25
+:  ld b,$00
    add hl,bc          ; add PaletteRotatePos to hl -> rotate palette left
    rst SetVRAMAddressToDE
    ld bc,$03be        ; count 3 bytes, output to VDPData
-:  outi
    jp nz,-
    ret

_Palette1:             ; $7f10
.db $2F $2A $25
.db $2F $2A $25

_Palette2:             ; $7f16
.db $3C $2F $2A
.db $3C $2F $2A
; Palettes are repeated to allow shifting to achieve a circular effect

_ResetPalette:
    ld hl,ActualPalette
    ld de,PaletteAddress
    rst SetVRAMAddressToDE
    ld c,VDPData
    jp outi32          ; and ret
.ends
; followed by
.orga $7f28
.section "Flash palette 1" overwrite
_LABEL_7F28_:
    ld hl,_DATA_7FB5_
    ld a,$6f           ; counter - when low nibble is 0, it changes the palette (so 7 palettes total); and stops when it's all counted down.
-:  push af
      and $0F
      ld de,ActualPalette+32-8
      ld bc,8
      jr nz,+
      ldir           ; copy 8 colours to palette
+:    ld a,$16       ; VBlankFunction_PaletteEffects
      call ExecuteFunctionIndexAInNextVBlank
    pop af
    dec a
    jr nz,-
    ret
.ends
; followed by
.orga $7f44
.section "Palette animation 1" overwrite
_LABEL_7F44_PaletteAnimation:
    ld hl,Frame2Paging
    ld (hl),:_DATA_FE1D_
    ld hl,_DATA_FE1D_
    ld de,ActualPalette+32-5
    ld bc,5
    ldir
    ld a,$16           ; VBlankFunction_PaletteEffects
    jp ExecuteFunctionIndexAInNextVBlank ; and ret
.ends
; followed by
.orga $7f59
.section "Palette animation 2" overwrite
_LABEL_7F59_:
    ld hl,Frame2Paging
    ld (hl),:_DATA_FE52_
    call +
    call +
    call +
    ld hl,_DATA_FE52_
    ld b,13            ; animation steps
--: push bc
      ld de,ActualPalette+10
      ld bc,6        ; # of colours
      ldir
      ld b,8         ; frames to delay
-:    ld a,$16       ; VBlankFunction_PaletteEffects
      call ExecuteFunctionIndexAInNextVBlank
      djnz -
    pop bc
    djnz --
    ret

_LABEL_7F82_:
    ld hl,Frame2Paging
    ld (hl),:_DATA_FEA0_
    ld hl,_DATA_FEA0_
    ld bc,$0918
    jr _f

+:  ld hl,_DATA_FE22_
    ld bc,$1803        ; b = $18 = 24 steps of palette animation; c = 3 = number of frames to delay
 __:push bc
      ld a,(hl)      ; get colour
      ld (ActualPalette+0),a ; put it in colour 0
      ld b,6
      ld de,ActualPalette+10
-:    ld (de),a      ; and 10-16
      inc de
      djnz -
      inc hl         ; get next colour
      ld a,(hl)
      ld (ActualPalette+7),a ; put it in colour 7
      inc hl         ; move to next colour
      ld b,c
-:    ld a,$16       ; VBlankFunction_PaletteEffects
      call ExecuteFunctionIndexAInNextVBlank
      djnz -
    pop bc
    djnz _b
    ret
.ends
; followed by
.orga $7fb5
.section "Palette animation 1 data" overwrite
; Data from 7FB5 to 7FEF (59 bytes)
; Palette fade cyan/blue/white-white-various
_DATA_7FB5_:
.db $3C $38 $3C $3C $3F $3C $38 $38 $3E $3C $3E $3E $3F $3E $3C $3C
.db $3F $3E $3F $3F $3F $3F $3E $3E $3F $2B $0F $2F $2F $3E $3C $0F
.db $2F $06 $0B $1F $0F $3C $38 $0B $2B $01 $06 $0F $0B $2A $25 $06
.ends
; blank until end of slot

;=======================================================================================================
; Bank 1: $7ff0 - $7fff - rom header
;=======================================================================================================
.BANK 1 SLOT 1
.ORG $0000
; Data from 7FF0 to 7FFF (16 bytes)
.db "TMR SEGA" $FF $FF $6B $2C $00 $95 $00 $40

;=======================================================================================================
; Bank 2: $8000 - $bfff
;=======================================================================================================
.bank 2 slot 2
.orga $8000
.section "Dialogue text and text to tile conversion table" overwrite
DialogueText:          ; label for page with script, lookup table
TileNumberLookup:      ; $8000
; Table of top & bottom tile numbers for different letters
; 89 entries (?)
; TODO .stringmap here
.db $c0,$c0 ; blank        00
.db $c0,$cb ; A  ァ        01
.db $c0,$cc ; I  イ        02
.db $c0,$cd ; U  ウ        03
.db $c0,$ce ; E  エ        04
.db $c0,$cf ; O  オ        05
.db $c0,$d0 ; Ka カ        06
.db $c0,$d1 ; Ki キ        07
.db $c0,$d2 ; Ku ク        08
.db $c0,$d3 ; Ke ケ        09
.db $c0,$d4 ; Ko コ        0a
.db $c0,$d5 ; Sa サ        0b
.db $c0,$d6 ; Si シ        0c
.db $c0,$d7 ; Su ス        0d
.db $c0,$d8 ; Se セ        0e
.db $c0,$d9 ; So ソ        0f
.db $c0,$da ; Ta タ        10
.db $c0,$db ; Ti チ        11
.db $c0,$dc ; Tu ツ        12
.db $c0,$dd ; Te テ        13
.db $c0,$de ; To ト        14
.db $c0,$df ; Na ナ        15
.db $c0,$e0 ; Ni ニ        16
.db $c0,$e1 ; Nu ヌ        17
.db $c0,$e2 ; Ne ネ        18
.db $c0,$e3 ; No ノ        19
.db $c0,$e4 ; Ha ハ        1a
.db $c0,$e5 ; Hi ヒ        1b
.db $c0,$e6 ; Hu フ        1c
.db $c0,$e7 ; He ヘ        1d
.db $c0,$e8 ; Ho ホ        1e
.db $c0,$e9 ; Ma マ        1f
.db $c0,$ea ; Mi ミ        20
.db $c0,$eb ; Mu ム        21
.db $c0,$ec ; Me メ        22
.db $c0,$ed ; Mo モ        23
.db $c0,$ee ; Ya ヤ        24
.db $c0,$ef ; Yu ユ        25
.db $c0,$f0 ; Yo ヨ        26
.db $c0,$f1 ; Ra ラ        27
.db $c0,$f2 ; Ri リ        28      Unused?
.db $c0,$f3 ; Ru ル        29      Wiヰ
.db $c0,$f4 ; Re レ        2a      Weヱ
.db $c0,$f5 ; Ro ロ        2b      Vuヴ
.db $c0,$f6 ; Wa ワ        2c
.db $c0,$f7 ; Wo ヲ        2d
.db $c0,$f8 ; N  ン        2e
.db $c0,$f9 ; Small Tu ッ  2f
.db $c0,$fa ; Small Ya ャ  30
.db $c0,$fb ; Small Yu ュ  31
.db $c0,$fc ; Small Yo ョ  32
.db $fd,$d0 ; Ga ガ        33
.db $fd,$d1 ; Gi ギ        34
.db $fd,$d2 ; Gu グ        35
.db $fd,$d3 ; Ge ゲ        36
.db $fd,$d4 ; Go ゴ        37
.db $fd,$d5 ; Za ザ        38
.db $fd,$d6 ; Zi ジ        39
.db $fd,$d7 ; Zu ズ        3a
.db $fd,$d8 ; Ze ゼ        3b
.db $fd,$d9 ; Zo ゾ        3c
.db $fd,$da ; Da ダ        3d
.db $fd,$db ; Di ヂ        3e
.db $fd,$dc ; Du ヅ        3f
.db $fd,$dd ; De デ        40
.db $fd,$de ; Do ド        41
.db $fd,$e4 ; Ba バ        42
.db $fd,$e5 ; Bi ビ        43
.db $fd,$e6 ; Bu ブ        44
.db $fd,$e7 ; Be ベ        45
.db $fd,$e8 ; Bo ボ        46
.db $fe,$e4 ; Pa パ        47
.db $fe,$e5 ; Pi ピ        48
.db $fe,$e6 ; Pu プ        49
.db $fe,$e7 ; Pe ペ        4a
.db $fe,$e8 ; Po ポ        4b
.db $c0,$fe ; .            4c
.db $c0,$ff ; -            4d
.db $c0,$a4 ; ???          4e    a4 is normally graphics, 1a4 is in the tilemap...
.db $c0,$c0 ; Blank        4f
.db $c0,$c0 ; Blank        50
.db $c0,$c0 ; Blank        51
.db $c0,$c0 ; Blank        52
.db $c0,$c0 ; Blank        53
.db $c0,$c0 ; Blank        54
.db $c0,$c0 ; Blank        55
.db $c0,$c0 ; Blank        56
.db $c0,$c0 ; Blank        57
.db $c0,$c0 ; Blank        58
.ends
; followed by
.orga $80b2
.section "Script" overwrite
.include "text\text1.inc" ; TODO inline with .stringmap
.ends

; Data from BD94 to BF9B (520 bytes)
ItemTextTable: ; All items are padded to 8 chars, with <wait> at the end
.stringmap script "　　　　　　　　"
.stringmap script "ウッドケイン<wait>　"
.stringmap script "ショートソード<wait>"
.stringmap script "アイアンソード<wait>"
.stringmap script "サイコウオンド<wait>"
.stringmap script "シルバータスク<wait>"
.stringmap script "アイアンアクス<wait>"
.stringmap script "チタニウムソード"
.stringmap script "セラミックソード"
.stringmap script "ニードルガン<wait>　"
.stringmap script "サーベルクロー<wait>"
.stringmap script "ヒートガン<wait>　　"
.stringmap script "ライトセイバー<wait>"
.stringmap script "レーザーガン<wait>　"
.stringmap script "ラコニアンソード"
.stringmap script "ラコニアンアクス"
.stringmap script "レザークロス<wait>　"
.stringmap script "ホワイトマント<wait>"
.stringmap script "ライトスーツ<wait>　"
.stringmap script "アイアンアーマー"
.stringmap script "トゲリスノケガワ"
.stringmap script "ジルコニアメイル"
.stringmap script "ダイヤノヨロイ<wait>"
.stringmap script "ラコニアアーマー"
.stringmap script "フラードマント<wait>"
.stringmap script "レザーシールド<wait>"
.stringmap script "アイアンシールド"
.stringmap script "ボロンシールド<wait>"
.stringmap script "セラミックノタテ"
.stringmap script "アニマルグラブ<wait>"
.stringmap script "レーザーバリア<wait>"
.stringmap script "ペルセウスノタテ"
.stringmap script "ラコニアシールド"
.stringmap script "ランドマスター<wait>"
.stringmap script "フロームーバー<wait>"
.stringmap script "アイスデッカー<wait>"
.stringmap script "ペロリーメイト<wait>"
.stringmap script "ルオギニン<wait>　　"
.stringmap script "スーズフルート<wait>"
.stringmap script "サーチライト<wait>　"
.stringmap script "エスケープクロス"
.stringmap script "トランカーペット"
.stringmap script "マジックハット<wait>"
.stringmap script "アルシュリン<wait>　"
.stringmap script "ポリメテラール<wait>"
.stringmap script "ダンジョンキー<wait>"
.stringmap script "テレパシーボール"
.stringmap script "イクリプストーチ"
.stringmap script "エアロプリズム<wait>"
.stringmap script "ラエルマベリー<wait>"
.stringmap script "ハプスビー<wait>　　"
.stringmap script "ロードパス<wait>　　"
.stringmap script "パスポート<wait>　　"
.stringmap script "コンパス<wait>　　　"
.stringmap script "ショートケーキ<wait>"
.stringmap script "ソウトクノテガミ"
.stringmap script "ラコニアンポット"
.stringmap script "ライトペンダント"
.stringmap script "カーバンクルアイ"
.stringmap script "ガスクリア<wait>　　"
.stringmap script "ダモアクリスタル"
.stringmap script "マスターシステム"
.stringmap script "ミラクルキー<wait>　"
.stringmap script "ジリオン<wait>　　　"
.stringmap script "ヒミツノモノ<wait>　"
.orga $bf9c
.section "Item metadata" overwrite
; Data from BF9C to BFFF (100 bytes)
ItemMetadata:
; %765432tt
;  |||| |``- Item type: 0 = weapon, 1 = armour, 2 = shield
;  |||| `--- Undroppable item
;  ````----- Equippable by player bits. Zero if equippable. Lutz - Odin - Myau - Alis

.define ItemMetadata_Weapon %00
.define ItemMetadata_Armour %01
.define ItemMetadata_Shield %10
.db $00 ; blank
; Weapons
.db %11010000 ; Wood Cane - Myau?
.db %11010000
.db %01010000
.db %11010000
.db %00100000
.db %01000000
.db %01010000
.db %01010000
.db %01000000
.db %00100000
.db %01000000
.db %01010000
.db %01000000
.db %01010000
.db %01000000
; Armour
.db %01010001
.db %10000001
.db %01010001
.db %01000001
.db %00100001
.db %01010001
.db %01010001
.db %01000001
.db %10000001
; Shields
.db %01010010
.db %01000010
.db %01010010
.db %01010010
.db %00100010
.db %11010010
.db %01000110
.db %01010010
; Vehicles
.db %00000100 ; Undroppable
.db %00000100 ; Undroppable
.db %00000100 ; Undroppable
; Items. $04 means undroppable:
.db $00
.db $00
.db $00
.db $00
.db $00
.db $00
.db $00
.db $04 ; Item_Alsuline
.db $00
.db $04 ; Item_DungeonKey
.db $00
.db $04 ; Item_EclipseTorch
.db $04 ; Item_Aeroprism
.db $04 ; Item_LaermaBerries
.db $04 ; Item_Hapsby
.db $04 ; Item_RoadPass
.db $00
.db $04 ; Item_Compass
.db $00
.db $04 ; Item_GovernorGeneralsLetter
.db $04 ; Item_LaconianPot
.db $00
.db $04 ; Item_CarbuncleEye
.db $00
.db $00
.db $00
.db $04 ; Item_MiracleKey
.db $00
.ends

;=======================================================================================================
; Bank 3: $c000 - $ffff
;=======================================================================================================
.bank 3 slot 2

; Data from C000 to C177 (376 bytes)
_DATA_C000_:
.db $10 $0C $10 $0C $10 $0C $10 $0B $10 $0B $10 $05 $10 $05 $10 $0F
.db $10 $0C $10 $0C $10 $0B $10 $0B $10 $0B $10 $04 $10 $0F $10 $0E
.db $10 $0A $10 $0A $10 $0A $10 $0B $10 $0B $10 $01 $10 $01 $10 $0E
.db $10 $0D $10 $0A $10 $0A $10 $07 $10 $00 $10 $00 $10 $01 $10 $06
.db $10 $0A $10 $0A $10 $0A $10 $07 $10 $00 $10 $00 $10 $01 $10 $06
.db $10 $09 $10 $09 $10 $08 $10 $07 $10 $02 $10 $02 $10 $01 $10 $06
.db $10 $09 $10 $09 $10 $08 $10 $08 $10 $03 $10 $03 $10 $06 $10 $0B
.db $10 $0A $10 $09 $10 $08 $10 $08 $10 $03 $10 $03 $10 $0B $10 $0D
.db $10 $09 $10 $09 $10 $08 $10 $03 $10 $03 $10 $06 $10 $06 $10 $06
.db $10 $09 $10 $0E $10 $0E $10 $0E $10 $02 $10 $02 $10 $02 $10 $02
.db $10 $08 $10 $0E $10 $0F $10 $0E $10 $0D $10 $01 $10 $01 $10 $05
.db $10 $08 $10 $0C $10 $0C $10 $0D $10 $0D $10 $00 $10 $00 $10 $05
.db $10 $08 $10 $0A $10 $0B $10 $0B $10 $07 $10 $00 $10 $01 $10 $04
.db $10 $08 $10 $09 $10 $0B $10 $0A $10 $07 $10 $05 $10 $04 $10 $04
.db $10 $08 $10 $09 $10 $0A $10 $0A $10 $07 $10 $05 $10 $05 $10 $05
.db $10 $09 $10 $09 $10 $08 $10 $08 $10 $07 $10 $06 $10 $06 $10 $06
.db $10 $0F $10 $0F $10 $0D $10 $0C $10 $0E $10 $0E $10 $0F $10 $0F
.db $10 $0F $10 $0D $10 $0D $10 $0C $10 $0B $10 $0B $10 $0C $10 $0F
.db $10 $0D $10 $0D $10 $0D $10 $0C $10 $0B $10 $0A $10 $09 $10 $09
.db $10 $04 $10 $06 $10 $06 $10 $03 $10 $07 $10 $08 $10 $08 $10 $04
.db $10 $04 $10 $05 $10 $03 $10 $01 $10 $0D $10 $08 $10 $06 $10 $04
.db $10 $03 $10 $03 $10 $00 $10 $00 $10 $0D $10 $08 $10 $04 $10 $03
.db $10 $03 $10 $03 $10 $00 $10 $00 $10 $0D $10 $0D $10 $04 $10 $03
.db $10 $0F $10 $02 $10 $02 $10 $01 $10 $0D $10 $0D $10 $0F $10 $0F

; Data from C178 to C46F (760 bytes)
_DATA_C180_MonsterPools:
.dsb 5 Enemy_MonsterFly
.dsb 3 Enemy_Scorpius

.dsb 2 Enemy_MonsterFly
.dsb 2 Enemy_Maneater
.dsb 4 Enemy_Scorpius

.db Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_Maneater Enemy_Maneater Enemy_Maneater Enemy_Maneater Enemy_Lich
.db Enemy_MonsterFly Enemy_MonsterFly Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat Enemy_Lich
.db Enemy_MonsterFly Enemy_GiantNaiad Enemy_GiantNaiad Enemy_GiantNaiad Enemy_KillerPlant Enemy_KillerPlant Enemy_KillerPlant Enemy_KillerPlant
.db Enemy_Maneater Enemy_KillerPlant Enemy_KillerPlant Enemy_KillerPlant Enemy_KillerPlant Enemy_Lich Enemy_Lich Enemy_Manticort
.db Enemy_MonsterFly Enemy_MonsterFly Enemy_GiantNaiad Enemy_GiantNaiad Enemy_KillerPlant Enemy_KillerPlant Enemy_KillerPlant Enemy_Manticort
.db Enemy_Herex Enemy_Herex Enemy_Lich Enemy_Lich Enemy_Lich Enemy_BigNose Enemy_BigNose Enemy_FlameLizard
.db Enemy_Scorpius Enemy_BitingFly Enemy_BitingFly Enemy_Manticort Enemy_Manticort Enemy_Skeleton Enemy_Skeleton Enemy_Skeleton
.db Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat Enemy_GoldLens Enemy_GoldLens Enemy_Wight Enemy_Wight Enemy_Talos
.db Enemy_SnakeLord Enemy_SnakeLord Enemy_KingSaber Enemy_KingSaber Enemy_KingSaber Enemy_KingSaber Enemy_KingSaber Enemy_KingSaber
.db Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_Tarantula
.db Enemy_Tarantula Enemy_Tarantula Enemy_Tarantula Enemy_Cryon Enemy_Cryon Enemy_SkullSoldier Enemy_SkullSoldier Enemy_SkullSoldier
.db Enemy_WingEye Enemy_WingEye Enemy_Manticore Enemy_Manticore Enemy_Manticore Enemy_Manticore Enemy_Manticore Enemy_Manticore
.db Enemy_Tarantula Enemy_Tarantula Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Talos Enemy_Talos Enemy_Talos
.db Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat Enemy_DevilBat ; $10
.db Enemy_MonsterFly Enemy_MonsterFly Enemy_Scorpius Enemy_Scorpius Enemy_Scorpius Enemy_Scorpius Enemy_KillerPlant Enemy_KillerPlant
.db Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_BatMan Enemy_BatMan Enemy_BatMan Enemy_BatMan Enemy_BatMan
.db Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Tarantula Enemy_Tarantula Enemy_Tarantula Enemy_Tarantula
.db Enemy_DevilBat Enemy_DevilBat Enemy_GoldLens Enemy_GoldLens Enemy_Tarantula Enemy_Tarantula Enemy_Skeleton Enemy_Cryon
.db Enemy_DevilBat Enemy_DevilBat Enemy_Ghoul Enemy_Ghoul Enemy_Ghoul Enemy_Ghoul Enemy_Ghoul Enemy_Ghoul
.db Enemy_Lich Enemy_Lich Enemy_Ghoul Enemy_Ghoul Enemy_SkullSoldier Enemy_SkullSoldier Enemy_Manticore Enemy_Manticore
.db Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent
.db Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Manticore Enemy_Manticore Enemy_Manticore Enemy_Manticore
.db Enemy_WingEye Enemy_KillerPlant Enemy_KillerPlant Enemy_GoldLens Enemy_GoldLens Enemy_Tarantula Enemy_Skeleton Enemy_Skeleton
.db Enemy_Cryon Enemy_SkullSoldier Enemy_Serpent Enemy_LivingDead Enemy_Gaia Enemy_Gaia Enemy_Gaia Enemy_Gaia
.db Enemy_DevilBat Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder
.db Enemy_KillerPlant Enemy_Golem Enemy_Golem Enemy_Golem Enemy_Golem Enemy_Golem Enemy_Golem Enemy_Golem
.db Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly Enemy_MonsterFly
.db Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing
.db Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Lich Enemy_Lich
.db Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus ; $20
.db Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent Enemy_Serpent
.db Enemy_Snail Enemy_Snail Enemy_Snail Enemy_Snail Enemy_Snail Enemy_Snail Enemy_Snail Enemy_Snail
.db Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord
.db Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing Enemy_SharkKing
.db Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_HorseshoeCrab
.db Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite
.db Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus Enemy_Octopus
.db Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard
.db Enemy_Herex Enemy_Marshes Enemy_Marshes Enemy_Marshes Enemy_Marshes Enemy_Serpent Enemy_Serpent Enemy_Serpent
.db Enemy_BigEater Enemy_BigEater Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord
.db Enemy_HorseshoeCrab Enemy_HorseshoeCrab Enemy_Ammonite Enemy_Ammonite Enemy_Wight Enemy_Wight Enemy_Wight Enemy_Wight
.db Enemy_Wight Enemy_Wight Enemy_Snail Enemy_Snail Enemy_Snail Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord
.db Enemy_Manticort Enemy_Manticort Enemy_Wight Enemy_Wight Enemy_Zombie Enemy_Zombie Enemy_CyborgMage Enemy_DeathBearer
.db Enemy_Antlion Enemy_Antlion Enemy_Antlion Enemy_Antlion Enemy_Antlion Enemy_Antlion Enemy_Antlion Enemy_Antlion
.db Enemy_Scorpius Enemy_Scorpius Enemy_Scorpius Enemy_Scorpius Enemy_GiantNaiad Enemy_GiantNaiad Enemy_MotavianPeasant Enemy_MotavianTeaser
.db Enemy_Sandworm Enemy_Sandworm Enemy_Sandworm Enemy_Sandworm Enemy_Sandworm Enemy_Sandworm Enemy_MotavianManiac Enemy_MotavianManiac ; $30
.db Enemy_GoldLens Enemy_GoldLens Enemy_DesertLeech Enemy_DesertLeech Enemy_DesertLeech Enemy_DesertLeech Enemy_DesertLeech Enemy_DesertLeech
.db Enemy_MotavianTeaser Enemy_MotavianTeaser Enemy_Tarantula Enemy_Tarantula Enemy_Manticort Enemy_Manticort Enemy_SkullSoldier Enemy_SkullSoldier
.db Enemy_Ammonite Enemy_Leviathan Enemy_Leviathan Enemy_Leviathan Enemy_Leviathan Enemy_Leviathan Enemy_Leviathan Enemy_Leviathan
.db Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite Enemy_Ammonite
.db Enemy_Leviathan Enemy_Leviathan Enemy_CyborgMage Enemy_CyborgMage Enemy_CyborgMage Enemy_CyborgMage Enemy_FlameLizard Enemy_FlameLizard
.db Enemy_MotavianManiac Enemy_FlameLizard Enemy_Gaia Enemy_Gaia Enemy_Gaia Enemy_Gaia Enemy_Gaia Enemy_Gaia
.db Enemy_MotavianPeasant Enemy_MotavianPeasant Enemy_GoldLens Enemy_GoldLens Enemy_Centaur Enemy_Centaur Enemy_Centaur Enemy_Centaur
.db Enemy_Scorpius Enemy_Scorpius Enemy_DesertLeech Enemy_DesertLeech Enemy_DesertLeech Enemy_DesertLeech Enemy_Vulcan Enemy_Vulcan
.db Enemy_FlameLizard Enemy_FlameLizard Enemy_Centaur Enemy_Centaur Enemy_Vulcan Enemy_Vulcan Enemy_Vulcan Enemy_Vulcan
.db Enemy_BlueSlime Enemy_BlueSlime Enemy_BitingFly Enemy_BitingFly Enemy_Herex Enemy_Herex Enemy_Dezorian Enemy_Dezorian
.db Enemy_BitingFly Enemy_BitingFly Enemy_Dezorian Enemy_Dezorian Enemy_Executor Enemy_Executor Enemy_Snail Enemy_Snail
.db Enemy_Dezorian Enemy_Dezorian Enemy_Dezorian Enemy_Dezorian Enemy_Cryon Enemy_Cryon Enemy_Manticore Enemy_Manticore
.db Enemy_Executor Enemy_Executor Enemy_Executor Enemy_Manticore Enemy_Manticore Enemy_Dorouge Enemy_Dorouge Enemy_MadStalker
.db Enemy_Herex Enemy_Snail Enemy_Snail Enemy_MadStalker Enemy_MadStalker Enemy_MadStalker Enemy_LivingDead Enemy_LivingDead
.db Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Dorouge Enemy_Dorouge Enemy_Dorouge Enemy_Centaur
.db Enemy_DezorianHead Enemy_DezorianHead Enemy_DezorianHead Enemy_DezorianHead Enemy_DezorianHead Enemy_DezorianHead Enemy_SnakeLord Enemy_SnakeLord ; $40
.db Enemy_Manticore Enemy_Manticore Enemy_Manticore Enemy_SnakeLord Enemy_SnakeLord Enemy_SnakeLord Enemy_ChaosSorcerer Enemy_ChaosSorcerer
.db Enemy_BlueSlime Enemy_BlueSlime Enemy_Mammoth Enemy_Mammoth Enemy_Mammoth Enemy_Mammoth Enemy_Mammoth Enemy_Mammoth
.db Enemy_MadStalker Enemy_MadStalker Enemy_IceMan Enemy_IceMan Enemy_IceMan Enemy_IceMan Enemy_IceMan Enemy_IceMan
.db Enemy_DezorianHead Enemy_DezorianHead Enemy_LivingDead Enemy_LivingDead Enemy_LivingDead Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder
.db Enemy_Herex Enemy_Herex Enemy_IceMan Enemy_IceMan Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder
.db Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Cryon Enemy_Dorouge Enemy_Dorouge Enemy_MadStalker Enemy_MadStalker
.db Enemy_Manticore Enemy_Manticore Enemy_LivingDead Enemy_LivingDead Enemy_ChaosSorcerer Enemy_ChaosSorcerer Enemy_ChaosSorcerer Enemy_ChaosSorcerer
.db Enemy_Centaur Enemy_Centaur Enemy_Centaur Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder
.db Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon
.db Enemy_GreenSlime Enemy_GreenSlime Enemy_WingEye Enemy_WingEye Enemy_BitingFly Enemy_BitingFly Enemy_Herex Enemy_Herex
.db Enemy_DevilBat Enemy_DevilBat Enemy_MotavianTeaser Enemy_MotavianTeaser Enemy_RedSlime Enemy_RedSlime Enemy_Tarantula Enemy_Tarantula
.db Enemy_BlueSlime Enemy_BlueSlime Enemy_GoldLens Enemy_GoldLens Enemy_BatMan Enemy_BatMan Enemy_DezorianHead Enemy_DezorianHead
.db Enemy_Lich Enemy_Lich Enemy_Skeleton Enemy_Skeleton Enemy_Cryon Enemy_Cryon Enemy_Ghoul Enemy_Ghoul
.db Enemy_Manticort Enemy_Manticort Enemy_Dorouge Enemy_Dorouge Enemy_MadStalker Enemy_MadStalker Enemy_Zombie Enemy_Zombie
.db Enemy_Wight Enemy_Wight Enemy_Manticore Enemy_Manticore Enemy_Serpent Enemy_Serpent Enemy_LivingDead Enemy_LivingDead
.db Enemy_BitingFly Enemy_BitingFly Enemy_BitingFly Enemy_BitingFly Enemy_Herex Enemy_Herex Enemy_Herex Enemy_Ghoul ; $50
.db Enemy_Zombie Enemy_Zombie Enemy_Zombie Enemy_Zombie Enemy_Zombie Enemy_Zombie Enemy_Zombie Enemy_Zombie
.db Enemy_Skeleton Enemy_Skeleton Enemy_Cryon Enemy_Cryon Enemy_Vulcan Enemy_Vulcan Enemy_RedDragon Enemy_RedDragon
.db Enemy_Manticore Enemy_Manticore Enemy_MadStalker Enemy_MadStalker Enemy_GreenDragon Enemy_GreenDragon Enemy_DarkMarauder Enemy_DarkMarauder
.db Enemy_ChaosSorcerer Enemy_ChaosSorcerer Enemy_Mammoth Enemy_Mammoth Enemy_KingSaber Enemy_KingSaber Enemy_Golem Enemy_Golem
.db Enemy_RedSlime Enemy_RedSlime Enemy_DeathBearer Enemy_DeathBearer Enemy_DeathBearer Enemy_DeathBearer Enemy_DeathBearer Enemy_DeathBearer
.db Enemy_CyborgMage Enemy_CyborgMage Enemy_CyborgMage Enemy_CyborgMage Enemy_KingSaber Enemy_KingSaber Enemy_Golem Enemy_Golem
.db Enemy_MachineGuard Enemy_MachineGuard Enemy_SnakeLord Enemy_SnakeLord Enemy_ChaosSorcerer Enemy_ChaosSorcerer Enemy_Centaur Enemy_Centaur
.db Enemy_MachineGuard Enemy_MachineGuard Enemy_Talos Enemy_Talos Enemy_RedDragon Enemy_RedDragon Enemy_RedDragon Enemy_RedDragon
.db Enemy_MadStalker Enemy_MadStalker Enemy_IceMan Enemy_IceMan Enemy_Mammoth Enemy_Mammoth Enemy_FrostDragon Enemy_FrostDragon
.db Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon Enemy_FrostDragon
.db Enemy_GreenSlime Enemy_GreenSlime Enemy_GreenSlime Enemy_GreenSlime Enemy_WingEye Enemy_WingEye Enemy_WingEye Enemy_WingEye
.db Enemy_GoldLens Enemy_GoldLens Enemy_GoldLens Enemy_BatMan Enemy_BatMan Enemy_BatMan Enemy_Lich Enemy_Lich ; $5b
.db Enemy_Manticore Enemy_Manticore Enemy_Manticore Enemy_FlameLizard Enemy_FlameLizard Enemy_FlameLizard Enemy_MachineGuard Enemy_MachineGuard
.db Enemy_DevilBat Enemy_DevilBat Enemy_BatMan Enemy_BatMan Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder Enemy_DarkMarauder

; Data from C470 to C59F (304 bytes)
_DATA_C470_:
.db $01 $02 $02 $03 $04 $05 $05 $06 $07 $07 $08 $09 $0A $0A $06 $0B
.db $01 $02 $02 $03 $04 $05 $05 $06 $07 $07 $08 $09 $0A $0A $06 $0B
.dsb 16,$00
.db $0C $0C $0C $0D $0E $0E $0E $0E $0E $0E $0E $0F $0F $0F $0F $0F
.db $10 $10 $11 $12 $13 $13 $14 $14 $17 $15 $16 $18 $19 $1A $1B $1C
.db $10 $10 $11 $12 $13 $13 $14 $14 $17 $15 $16 $18 $19 $1A $1B $1C
.db $1D $1D $1D $1E $1E $1F $1F $20 $20 $21 $21 $20 $22 $22 $23 $23
.db $24 $24 $24 $24 $25 $25 $25 $26 $26 $26 $26 $27 $28 $28 $28 $28
.db $24 $24 $24 $24 $25 $25 $25 $26 $26 $26 $26 $27 $28 $28 $28 $28
.db $29 $29 $29 $29 $29 $2A $29 $29 $29 $29 $29 $29 $29 $29 $2A $2A
.db $2F $2F $30 $31 $32 $30 $32 $33 $32 $35 $36 $38 $37 $34 $39 $37
.dsb 16,$2E
.db $3A $3B $3C $3D $3E $3E $3F $40 $41 $42 $42 $41 $43 $42 $44 $45
.db $46 $46 $46 $46 $46 $46 $47 $47 $47 $47 $47 $48 $48 $48 $48 $49
.dsb 16,$00
.dsb 16,$2D
.db $2C $2C $2C $2C $2B $2B $2B $2B $2C $2C $2C $2C $2C $2C $2C $2C
.db $2F $2F $30 $31 $32 $30 $32 $33 $32 $35 $36 $38 $37 $34 $39 $37
.db $25 $26 $24 $24 $27 $27 $28 $28 $27 $26 $28 $27 $27 $26 $27 $28

; Data from C5A0 to C67E (223 bytes)
_DATA_C5A0_:
.db $00 $00 $03 $03 $03 $03 $03 $04 $04 $00 $00 $00 $00 $00 $04
.dsb 9,$00
.dsb 9,$07
.db $00 $00 $00 $00 $05
.dsb 17,$00
.db $08 $08 $08 $08
.dsb 10,$06
.db $07 $07 $07 $07
.dsb 9,$06
.dsb 9,$02
.db $01 $02 $05 $04 $09 $09 $09 $09 $09
.dsb 10,$00
.db $02 $02 $02 $02
.dsb 80,$00
.db $02 $01 $01 $01 $01 $05 $02 $02 $02 $02 $02 $02 $05 $05 $05 $05
.db $00 $00 $00 $00 $00 $02 $02 $02 $02 $02 $02 $02 $02

; TODO 16B missing here from C67F

.orga $869f
.section "Enemy data" overwrite
.struct EnemyData
  Name                dsb 8
  Palette             dsb 8
  SpriteTilesPage     db
  SpriteTilesAddress  dw
  UnknownIndex        db ; index into _DATA_CFC7_
  MaxEnemyCount       db ; high bit means not random?
  HP                  db
  AP                  db
  DP                  db
  ItemIndex           db
  MoneyDrop           dw
  ChestTrapped        db
  ExperienceValue     dw ; multiplies by number of enemies
  TalkingAndMagicType db ; bit 7 = ability to talk; bit 6 = ability to talk magically; bit 5 = 1 if enemy is impervious to "bind" magic; bit 4 = 1 if enemy always removes a magic wall; bit 3 = ?; low 3 bits are an index into EnemyAttackFunctions for enemy magic
  RetreatProbability  db ; Relates to ability to run away, higher means less likely to block it. $ff means can always run away, $00 means never can.
.ends
.define TALK_NORMAL         %10000000
.define TALK_MAGIC          %01000000
.define BIND_PROOF          %00100000
.define MAGIC_WALL_BREAKER  %00010000

EnemyData:
.dstruct instanceof EnemyData nolabels values
  Name:               .db $23 $2e $0d $10 $4d $1c $27 $02 ; 1 MoNSuTa-HuRaI = Monster Fly? (Sworm)
  Palette:            .db $2a $25 $05 $0a $08 $04 $0c $2f
  SpriteTilesPage:    .db :TilesFly
  SpriteTilesAddress: .dw TilesFly
  UnknownIndex        .db $12
  MaxEnemyCount       .db 8
  HP                  .db 8
  AP                  .db 13
  DP                  .db 9
  ItemIndex           .db Item_Empty
  MoneyDrop           .dw 3
  ChestTrapped        .db %11000000
  ExperienceValue     .dw 2
  TalkingAndMagicType .db BIND_PROOF | MAGIC_WALL_BREAKER | 0 ; Regular attack
  RetreatProbability  .db $ff
.endst
/*
.db $23 $2e $0d $10 $4d $1c $27 $02 ; 1 MoNSuTa-HuRaI = Monster Fly? (Sworm)
.db $2a $25 $05 $0a $08 $04 $0c $2f
.db :TilesFly
.dw TilesFly
.db $12 $08 $08,$0d,$09 $00
.dw $0003
.db $0c
.dw $0002
.db $38 $ff
*/
.db $35 $28 $4d $2e $0d $27 $02 $21 ; 2 GuRi-NSuRaIMu = Green Slime
.db $10 $04 $0c $0e $00 $00 $00 $00
.db :TilesSlime
.dw TilesSlime
.db $02 $06 $12,$12,$0d $00
.dw $0008
.db $0c
.dw $0004
.db $30 $cc

.db $03 $02 $2e $35 $01 $02 $58 $00 ; 3 UINGuAI = Wing Eye
.db $00 $3e $00 $3e $3c $34 $30 $00
.db :TilesWingEye
.dw TilesWingEye
.db $23 $06 $0b,$0c,$0a $00
.dw $0006
.db $0f
.dw $0002
.db $38 $7f

.db $1f $2e $02 $4d $10 $4d $58 $00 ; 4 MaNI-Ta- = Man-eater
.db $00 $00 $05 $0a $33 $21 $37 $00
.db :TilesManEater
.dw TilesManEater
.db $17 $05 $10,$0c,$0a $00
.dw $000d
.db $0f
.dw $0003
.db $30 $ff

.db $0d $0a $4d $48 $27 $0d $58 $00 ; 5 SuKo-PiRaSu = Scorpion
.db $2a $25 $02 $03 $08 $00 $00 $37
.db :TilesScorpion
.dw TilesScorpion
.db $0f $04 $0c,$0e,$0c $00
.dw $000d
.db $0f
.dw $0004
.db $38 $cc

.db $27 $4d $39 $24 $4d $37 $58 $00 ; 6 Ra-ZiYa-Go = ??? (G. Scorpion)
.db $2a $25 $05 $0a $08 $00 $00 $2f
.db :TilesScorpion
.dw TilesScorpion
.db $0f $04 $14,$14,$11 $00
.dw $000b
.db $99
.dw $0005
.db $38 $7f

.db $44 $29 $4d $0d $27 $02 $21 $58 ; 7 BuRu-SuRaIMu = Blue Slime
.db $20 $30 $38 $3c $00 $00 $00 $00
.db :TilesSlime
.dw TilesSlime
.db $02 $06 $28,$1a,$14 $00
.dw $0013
.db $0f
.dw $0005
.db $32 $99

.db $23 $10 $43 $01 $2e $19 $4d $1c ; 8 MoTaBiANNo-Hu = North Motabian (North Farmer)
.db $20 $30 $34 $38 $01 $06 $0a $0f
.db :TilesFarmer
.dw TilesFarmer
.db $19 $05 $26,$25,$25 $24
.dw $0008
.db $00
.dw $0005
.db $f0 $b2

.db $40 $43 $29 $42 $2f $14 $58 $00 ; 9 DeBiRuBatuTo = ??? (Owl Bear)
.db $00 $0f $00 $0b $07 $03 $01 $00
.db :TilesWingEye
.dw TilesWingEye
.db $23 $04 $12,$16,$12 $00
.dw $000c
.db $0c
.dw $0005
.db $38 $99

.db $07 $27 $4d $49 $27 $2e $14 $58 ; 10 KiRa-PuRaNTo = Killer Plant (Dead Tree)
.db $00 $00 $02 $03 $0c $08 $2e $00
.db :TilesManEater
.dw TilesManEater
.db $17 $03 $17,$17,$19 $00
.dw $0015
.db $28
.dw $0004
.db $30 $cc

.db $42 $02 $10 $4d $1c $27 $02 $58 ; 11 BaITa-HuRaI = ??? (Scorpius)
.db $0c $08 $24 $25 $08 $00 $00 $2a
.db :TilesScorpion
.dw TilesScorpion
.db $0f $05 $16,$19,$14 $00
.dw $001b
.db $0f
.dw $0008
.db $39 $66

.db $23 $10 $43 $01 $2e $02 $43 $29 ; 12 MoTaBiANIBiRu = East Motabian (East Farmer)
.db $20 $30 $34 $38 $01 $03 $07 $0f
.db :TilesFarmer
.dw TilesFarmer
.db $1b $05 $2a,$1b,$28 $00
.dw $001e
.db $0f
.dw $0009
.db $f0 $cc

.db $1d $2a $2f $08 $0d $58 $00 $00 ; 13 HeRetuKuSu = ??? (Giant Fly)
.db $2a $25 $02 $03 $02 $01 $03 $0b
.db :TilesFly
.dw TilesFly
.db $12 $04 $19,$1e,$15 $00
.dw $0020
.db $0f
.dw $0007
.db $3c $66

.db $0b $2e $41 $2c $4d $21 $58 $00 ; 14 SaNDoWa-Mu = Sandworm (Crawler)
.db $02 $06 $0a $0e $01 $03 $2f $00
.db :TilesSandWorm
.dw TilesSandWorm
.db $22 $03 $28,$1f,$20 $00
.dw $001e
.db $0f
.dw $0009
.db $30 $7f

.db $23 $10 $43 $01 $2e $1f $16 $01 ; 15 MoTaBiANMaNiA = Motabian ??? (Barbarian)
.db $20 $30 $34 $38 $04 $08 $0c $0f
.db :TilesFarmer
.dw TilesFarmer
.db $1a $08 $36,$23,$32 $24
.dw $0059
.db $14
.dw $000a
.db $f0 $4c

.db $37 $4d $29 $41 $2a $2e $3a $58 ; 16 Go-RuDoReNZu = Goldlens
.db $00 $2a $00 $2f $0a $06 $01 $00
.db :TilesWingEye
.dw TilesWingEye
.db $23 $04 $1c,$24,$23 $00
.dw $0018
.db $0f
.dw $0009
.db $38 $7f

.db $2a $2f $41 $0d $27 $02 $21 $58 ; 17 RetuDoSuRaIMu = Red Slime
.db $01 $13 $33 $3a $00 $00 $00 $00
.db :TilesSlime
.dw TilesSlime
.db $02 $03 $1d,$25,$19 $00
.dw $001f
.db $0f
.dw $000b
.db $31 $99

.db $42 $2f $14 $1f $2e $58 $00 $00 ; 18 BatuToMaN = Bat Man (Were Bat)
.db $20 $34 $38 $3c $03 $02 $00 $00
.db :TilesBat
.dw TilesBat
.db $24 $04 $32,$25,$23 $00
.dw $003f
.db $0f
.dw $000b
.db $3b $7f

.db $06 $44 $14 $33 $16 $58 $00 $00 ; 19 KaBuToGaNi = ??? (Big Club)
.db $01 $02 $03 $07 $0b $00 $00 $00
.db :TilesClub
.dw TilesClub
.db $08 $02 $2e,$28,$24 $00
.dw $0028
.db $0f
.dw $0009
.db $30 $cc

.db $0c $30 $4d $07 $2e $58 $00 $00 ; 20 Siya-KiN = ??? (Fishman)
.db $05 $39 $0a $13 $33 $0f $3f $00
.db :TilesFishMan
.dw TilesFishMan
.db $07 $05 $2a,$2a,$28 $00
.dw $002a
.db $0f
.dw $000b
.db $30 $99

.db $28 $2f $11 $58 $00 $00 $00 $00 ; 21 RituTi = ??? (Evil Dead)
.db $02 $03 $34 $01 $04 $08 $0e $38
.db :TilesEvilDead
.dw TilesEvilDead
.db $21 $03 $1e,$2b,$24 $00
.dw $0008
.db $0c
.dw $000e
.db $30 $e5

.db $10 $27 $2e $11 $31 $27 $58 $00 ; 22 TaRaNTiyuRa = Tarantula
.db $2a $01 $2a $05 $08 $04 $0c $2f
.db :TilesTarantula
.dw TilesTarantula
.db $11 $02 $32,$32,$2b $00
.dw $0033
.db $26
.dw $000a
.db $71 $99

.db $1f $2e $11 $0a $01 $58 $00 $00 ; 23 MaNTiKoA = Manticor
.db $01 $03 $07 $0b $28 $2d $2f $20
.db :TilesManticor
.dw TilesManticor
.db $14 $03 $3c,$35,$2c $00
.dw $0031
.db $0f
.dw $000f
.db $5c $99

.db $0d $09 $29 $14 $2e $58 $00 $00 ; 24 SuKeRuToN = Skeleton
.db $3f $2f $2a $25 $20 $3c $00 $00
.db :TilesSkeleton
.dw TilesSkeleton
.db $0c $05 $35,$3a,$29 $00
.dw $0019
.db $0f
.dw $000d
.db $30 $cc

.db $01 $28 $39 $37 $08 $58 $00 $00 ; 25 ARiZiGoKu = ??? (Antlion)
.db $2a $00 $25 $00 $06 $01 $0a $2f
.db :TilesTarantula
.dw TilesTarantula
.db $11 $01 $42,$3b,$34 $00
.dw $0007
.db $0c
.dw $0008
.db $31 $b2

.db $1f $4d $0c $4d $3a $58 $00 $00 ; 26 Ma-Si-Zu = ??? (Merman)
.db $21 $3c $36 $04 $2c $3a $07 $00
.db :TilesFishMan
.dw TilesFishMan
.db $07 $06 $3a,$43,$32 $00
.dw $002b
.db $0f
.dw $000e
.db $30 $7f

.db $40 $3c $28 $01 $2e $58 $00 $00 ; 27 DeZoRiAN = Dezorian
.db $02 $3c $0a $04 $2c $01 $08 $2f
.db :TilesDezorian
.dw TilesDezorian
.db $0a $05 $4c,$4d,$3f $00
.dw $0069
.db $0c
.dw $0012
.db $f0 $7f

.db $40 $38 $4d $14 $28 $4d $11 $58 ; 28 DeZa-ToRi-Ti = ??? (Leech)
.db $08 $22 $33 $37 $04 $0c $2f $06
.db :TilesSandWorm
.dw TilesSandWorm
.db $22 $04 $46,$43,$2f $00
.dw $002f
.db $0c
.dw $000f
.db $33 $a5

.db $08 $27 $02 $05 $2e $58 $00 $00 ; 29 KuRaION = ??? (Vampire)
.db $01 $06 $0a $2f $2a $25 $00 $2a
.db :TilesBat
.dw TilesBat
.db $24 $02 $43,$44,$2e $27
.dw $0047
.db $0c
.dw $000f
.db $38 $cc

.db $43 $2f $35 $19 $4d $3a $58 $00 ; 30 BituGuNo-Zu = Big-nose (Elephant)
.db $22 $33 $37 $3b $2d $2f $2a $0c
.db :TilesElephant
.dw TilesElephant
.db $03 $05 $56,$3e,$30 $00
.dw $0026
.db $0c
.dw $0011
.db $20 $cc

.db $35 $4d $29 $58 $00 $00 $00 $00 ; 31 Gu-Ru = Ghoul
.db $0b $03 $34 $38 $37 $33 $31 $3c
.db :TilesGhoul
.dw TilesGhoul
.db $13 $03 $44,$40,$2f $00
.dw $001a
.db $0c
.dw $0010
.db $30 $b2

.db $01 $2e $23 $15 $02 $14 $58 $00 ; 32 ANMoNaITo = Ammonite (Shellfish)
.db $03 $3a $2b $22 $33 $0f $07 $3f
.db :TilesAmmonite
.dw TilesAmmonite
.db $09 $03 $3e,$4d,$34 $00
.dw $002e
.db $14
.dw $0010
.db $30 $e5

.db $04 $35 $3b $07 $31 $4d $14 $58 ; 33 EGuZeKiyu-To = Executer
.db $01 $04 $08 $0c $0f $00 $00 $00
.db :TilesClub
.dw TilesClub
.db $08 $03 $3e,$49,$32 $00
.dw $003f
.db $35
.dw $000c
.db $30 $66

.db $2c $02 $14 $58 $00 $00 $00 $00 ; 34 WaITo = Wight
.db $08 $0c $03 $04 $02 $03 $07 $0f
.db :TilesEvilDead
.dw TilesEvilDead
.db $21 $03 $32,$40,$30 $00
.dw $0028
.db $0c
.dw $0012
.db $31 $b2

.db $0d $06 $29 $0f $29 $39 $30 $4d ; 35 SuKaRuSoRuZiya- = ??? (Skull-en)
.db $3f $0f $0d $06 $00 $0c $00 $00
.db :TilesSkeleton
.dw TilesSkeleton
.db $0d $03 $39,$4b,$35 $00
.dw $0025
.db $0c
.dw $0012
.db $30 $b2

.db $1f $02 $1f $02 $58 $00 $00 $00 ; 36 MaIMaI = ??? (Ammonite)
.db $04 $3e $0c $38 $3c $0f $08 $3f
.db :TilesAmmonite
.dw TilesAmmonite
.db $09 $02 $5a,$58,$3c $00
.dw $0047
.db $3f
.dw $0013
.db $30 $99

.db $1f $2e $11 $0a $4d $14 $58 $00 ; 37 MaNTiKo-To = ??? (Sphinx)
.db $01 $03 $07 $0b $0a $0f $2f $20
.db :TilesManticor
.dw TilesManticor
.db $14 $04 $4e,$50,$41 $27
.dw $003a
.db $0c
.dw $0015
.db $58 $cc

.db $0b $4d $4a $2e $14 $58 $00 $00 ; 38 Sa-PeNTo = Serpent
.db $22 $32 $33 $37 $3b $00 $00 $00
.db :TilesSnake
.dw TilesSnake
.db $10 $01 $50,$64,$42 $00
.dw $0060
.db $0f
.dw $0017
.db $38 $b2

.db $28 $42 $02 $01 $0b $2e $58 $00 ; 39 RiBaIASaN = ??? (Sandworm)
.db $0a $34 $38 $3c $05 $0f $2f $06
.db :TilesSandWorm
.dw TilesSandWorm
.db $22 $03 $52,$6b,$3f $00
.dw $0081
.db $0f
.dw $0014
.db $30 $99

.db $41 $29 $4d $39 $31 $58 $00 $00 ; 40 DoRu-Ziyu = ??? (Lich)
.db $31 $35 $08 $21 $23 $33 $37 $0e
.db :TilesEvilDead
.dw TilesEvilDead
.db $21 $02 $3c,$54,$3e $00
.dw $0021
.db $0c
.dw $0016
.db $31 $cc

.db $05 $08 $14 $47 $0d $58 $00 $00 ; 41 OKuToPaSu = Octopus
.db $02 $00 $00 $22 $33 $01 $00 $3f
.db :TilesOctopus
.dw TilesOctopus
.db $05 $01 $5a,$55,$44 $00
.dw $0040
.db $0c
.dw $0014
.db $30 $bf

.db $1f $2f $41 $0d $14 $4d $06 $4d ; 42 MatuDoSuTo-Ka- = Mad Stalker
.db $3f $3d $37 $33 $00 $0f $00 $00
.db :TilesSkeleton
.dw TilesSkeleton
.db $0e $04 $4f,$5a,$4b $00
.dw $0057
.db $0f
.dw $0016
.db $30 $e5

.db $40 $3c $28 $01 $2e $1d $2f $41 ; 43 DeZoRiANHetuDo = Dezorian ??? (EvilDead)
.db $02 $3c $03 $04 $2c $01 $08 $07
.db :TilesDezorian
.dw TilesDezorian
.db $0a $03 $56,$76,$4d $00
.dw $0088
.db $0f
.dw $0014
.db $f0 $7f

.db $3c $2e $43 $58 $00 $00 $00 $00 ; 44 ZoNBi = Zombie
.db $2a $25 $05 $0a $08 $08 $0c $2f
.db :TilesGhoul
.dw TilesGhoul
.db $13 $04 $57,$6c,$3a $00
.dw $001b
.db $0f
.dw $0014
.db $30 $99

.db $43 $31 $4d $14 $58 $00 $00 $00 ; 45 Biyu-To = ??? (Battalion)
.db $03 $02 $25 $2a $03 $02 $07 $03
.db :TilesGhoul
.dw TilesGhoul
.db $13 $03 $64,$70,$40 $00
.dw $003b
.db $0c
.dw $0015
.db $30 $cc

.db $2b $46 $2f $14 $4b $28 $0d $58 ; 46 RoBotuToPoRiSu = Robot Police (RobotCop)
.db $25 $2a $2f $3f $03 $26 $20 $00
.db :TilesRobotCop
.dw TilesRobotCop
.db $15 $01 $6e,$87,$5a $00
.dw $009c
.db $0f
.dw $0019
.db $00 $66

.db $0b $02 $46 $4d $35 $22 $02 $39 ; 47 SaIBo-GuMeIZ = ??? (Sorceror)
.db $01 $31 $35 $39 $3d $03 $23 $02
.db :TilesSorceror
.dw TilesSorceror
.db $04 $02 $6e,$79,$4a $00
.dw $0078
.db $33
.dw $001a
.db $34 $cc

.db $1c $2a $4d $21 $28 $38 $4d $41 ; 48 HuRe-MuRiZa-Do = ??? (Nessie)
.db $04 $08 $0c $2f $3f $00 $00 $00
.db :TilesSnake
.dw TilesSnake
.db $10 $02 $5d,$7e,$4d $00
.dw $0065
.db $0c
.dw $001c
.db $38 $cc

.db $10 $39 $21 $58 $00 $00 $00 $00 ; 49 TaZiMu = Tarzimal
.db $2b $20 $06 $2a $25 $3e $01 $0f
.db :TilesTarzimal
.dw TilesTarzimal
.db $06 $01 $7d,$78,$64 $00
.dw $0000
.db $0c
.dw $0000
.db $14 $00

.db $33 $02 $01 $58 $00 $00 $00 $00 ; 50 GaIA = ??? (Golem)
.db $01 $02 $03 $34 $30 $00 $00 $00
.db :TilesGolem
.dw TilesGolem
.db $1f $02 $8c,$79,$60 $00
.dw $0096
.db $0c
.dw $0018
.db $20 $b2

.db $1f $0c $4d $2e $33 $4d $3d $4d ; 51 MaSi-NGa-Da- = Machine Guard? (AndroCop)
.db $02 $03 $07 $3f $3c $03 $02 $00
.db :TilesRobotCop
.dw TilesRobotCop
.db $15 $02 $78,$91,$59 $00
.dw $007b
.db $0c
.dw $001d
.db $00 $7f

.db $43 $2f $35 $02 $4d $10 $4d $58 ; 52 BituGuI-Ta- = ??? (Tentacle)
.db $00 $00 $00 $20 $25 $30 $00 $0b
.db :TilesOctopus
.dw TilesOctopus
.db $05 $01 $76,$76,$57 $00
.dw $0062
.db $0c
.dw $001b
.db $30 $b2

.db $10 $2b $0d $58 $00 $00 $00 $00 ; 53 TaRoSu = ??? (Giant)
.db $04 $08 $0c $03 $02 $00 $00 $00
.db :TilesGolem
.dw TilesGolem
.db $1f $02 $78,$7a,$58 $00
.dw $0077
.db $0c
.dw $001e
.db $20 $7f

.db $0d $18 $4d $08 $2b $4d $41 $58 ; 54 SuNe-KuRo-Do = Snake ??? (Wyvern)
.db $01 $05 $1a $2f $3f $00 $00 $00
.db :TilesSnake
.dw TilesSnake
.db $10 $01 $6e,$7b,$54 $00
.dw $007d
.db $0c
.dw $001a
.db $38 $7f

.db $40 $0d $45 $01 $27 $4d $58 $00 ; 55 DeSuBeARa- = ??? (Reaper)
.db $20 $25 $2a $2f $3f $02 $01 $30
.db :TilesReaper
.dw TilesReaper
.db $1e $01 $b9,$87,$66 $00
.dw $00fe
.db $33
.dw $001e
.db $23 $cc

.db $06 $05 $0d $0f $4d $0b $27 $4d ; 56 KaOSuSo-SaRa- = ??? Sorceror (Magician)
.db $00 $25 $25 $2a $2f $08 $0c $04
.db :TilesSorceror
.dw TilesSorceror
.db $04 $01 $8a,$91,$5a $00
.dw $00bb
.db $0c
.dw $0020
.db $35 $7f

.db $0e $2e $14 $4d $29 $58 $00 $00 ; 57 SeNTo-Ru = Centaur (HorseMan)
.db $20 $30 $34 $38 $3c $10 $0c $2f
.db :TilesCentaur
.dw TilesCentaur
.db $1d $02 $82,$7e,$59 $27
.dw $0094
.db $00
.dw $001e
.db $44 $59

.db $01 $02 $0d $1f $2e $58 $00 $00 ; 58 AISuMaN = Ice-man (FrostMan)
.db $20 $30 $34 $38 $3c $3f $3a $3e
.db :TilesIceMan
.dw TilesIceMan
.db $1c $01 $8c,$8a,$62 $00
.dw $0080
.db $14
.dw $0024
.db $10 $bf

.db $42 $29 $06 $2e $58 $00 $00 $00 ; 59 BaRuKaN = ??? (Amundsen)
.db $01 $02 $03 $07 $0b $0f $0b $0f
.db :TilesIceMan
.dw TilesIceMan
.db $1c $01 $85,$8c,$62 $00
.dw $0078
.db $0c
.dw $0020
.db $10 $b2

.db $2a $2f $41 $41 $27 $37 $2e $58 ; 60 RetuDoDoRaGoN = Red Dragon?
.db $01 $20 $34 $02 $03 $07 $30 $38
.db :TilesDragon
.dw TilesDragon
.db $01 $01 $af,$a0,$69 $00
.dw $00c1
.db $0f
.dw $0041
.db $58 $7f

.db $35 $28 $4d $2e $41 $27 $37 $2e ; 61 GuRi-NDoRaGoN = Green Dragon
.db $04 $03 $0b $08 $0c $0e $07 $0f
.db :TilesDragon
.dw TilesDragon
.db $01 $01 $a0,$91,$5f $00
.dw $00b0
.db $0c
.dw $0035
.db $58 $99

.db $27 $0c $4d $08 $58 $00 $00 $00 ; 62 RaSi-Ku = ??? (Shadow)
.db $20 $30 $34 $38 $25 $2a $2f $00
.db :TilesShadow
.dw TilesShadow
.db $18 $01 $a5,$ac,$68 $00
.dw $0000
.db $0c
.dw $003c
.db $30 $7f

.db $1f $2e $23 $0d $58 $00 $00 $00 ; 63 MaNMoSu = Mammoth
.db $31 $35 $39 $3d $23 $2f $2a $02
.db :TilesElephant
.dw TilesElephant
.db $03 $05 $b4,$9a,$64 $00
.dw $007d
.db $0f
.dw $0028
.db $20 $b2

.db $07 $2e $35 $0e $02 $42 $4d $58 ; 64 KiNGuSeIBa- = ??? (Centaur)
.db $06 $07 $0b $0f $2f $03 $0b $0f
.db :TilesCentaur
.dw TilesCentaur
.db $1d $01 $be,$9b,$64 $00
.dw $0085
.db $28
.dw $001f
.db $41 $7f

.db $3d $4d $08 $1f $2b $4d $3d $4d ; 65 Da-KuMaRo-Da- = Dark Marauder (Marauder)
.db $10 $20 $30 $34 $38 $03 $02 $00
.db :TilesReaper
.dw TilesReaper
.db $1e $01 $87,$86,$58 $00
.dw $00ad
.db $0f
.dw $001e
.db $25 $b2

.db $37 $4d $2a $21 $58 $00 $00 $00 ; 66 Go-ReMu = Golem(Titan)
.db $01 $06 $0a $2a $25 $00 $00 $00
.db :TilesGolem
.dw TilesGolem
.db $1f $02 $be,$92,$61 $00
.dw $008a
.db $21
.dw $0020
.db $20 $7f

.db $22 $40 $31 $4d $0b $58 $00 $00 ; 67 MeDeyu-Sa = Medusa
.db $01 $12 $37 $2b $32 $02 $22 $10
.db :TilesMedusa
.dw TilesMedusa
.db $20 $01 $c8,$a6,$67 $27
.dw $00c2
.db $00
.dw $0032
.db $26 $99

.db $1c $2b $0d $14 $41 $27 $37 $2e ; 68 HuRoSuToDoRaGoN = ??? Dragon (White Dragon)
.db $34 $3c $3f $38 $3c $2f $3f $3f
.db :TilesDragon
.dw TilesDragon
.db $01 $01 $c8,$b4,$68 $00
.dw $00ea
.db $0f
.dw $004b
.db $48 $99

.db $41 $27 $37 $2e $2c $02 $3a $58 ; 69 DoRaGoNWaIZu = Dragon ??? (Blue Dragon)
.db $20 $3e $3f $25 $2a $2f $3f $3f
.db :TilesDragon
.dw TilesDragon
.db $01 $01 $d2,$9b,$5a $00
.dw $00b2
.db $0c
.dw $0058
.db $48 $99

.db $37 $4d $29 $41 $41 $2a $02 $08 ; 70 Go-RuDoDoReIKu = Gold Dragon
.db $03 $07 $0b $0f $25 $2a $2f $00
.db :TilesGoldDragonHead
.dw TilesGoldDragonHead
.db $16 $01 $aa,$c8,$62 $00
.dw $0000
.db $00
.dw $0064
.db $0a $00

.db $1f $2f $41 $41 $08 $10 $4d $58 ; 71 MatuDoDoKuTa- = Mad? Doctor (Dr. Mad)
.db $38 $3c $3e $3f $25 $2a $2f $00
.db :TilesShadow
.dw TilesShadow
.db $18 $01 $e9,$b4,$55 $00
.dw $008c
.db $00
.dw $0019
.db $30 $66

.db $27 $0c $4d $08 $58 $00 $00 $00 ; 72 RaSi-Ku = Lassic
.db $01 $06 $34 $30 $2f $0f $0b $02
.db :TilesLassic
.dw TilesLassic
.db $26 $01 $ee,$e6,$b4 $00
.dw $0000
.db $00
.dw $0000
.db $07 $00

.db $3d $4d $08 $1c $4e $29 $0d $58 ; 73 Da-KuHu[4E]RuSu = Dark Force
.db $20 $30 $34 $38 $3c $02 $03 $01
.db :TilesDarkForceFlame
.dw TilesDarkForceFlame
.db $27 $82 $ff,$ff,$96 $00
.dw $0000
.db $00
.dw $0000
.db $00 $00

.db $15 $02 $14 $22 $01 $58 $00 $00 ; 74 NaIToMeA = Nightmare? (Succubus)
.db $20 $25 $2a $2f $3f $02 $03 $01
.db :TilesSuccubus
.dw TilesSuccubus
.db $25 $01 $ff,$96,$fa $00
.dw $0000
.db $00
.dw $000a
.db $01 $00

.ends
; followed by
.orga $8fdf
.section "data8fdf data" overwrite
data8fdf:
; WLA DX won't let me have a macro for this :( it only allows 16 parameters to a macro.
;    ,,--,,--,,-------------------------------------------------------------------------------------- 3 bytes to $c880
;    ||  ||  ||  ,,---------------------------------------------------------------------------------- 1 byte  to $c884
;    ||  ||  ||  ||  ,,--,,--,,--,,--,,--,,--,,--,,--,,---------------------------------------------- 9 bytes to $c894
;    ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ,,--,,--,,--,,------------------------------ dest, src (words)
;    ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ,,--,,---------------------- outer, inner count
;    ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ,,--,,--,,---------- 3 bytes to $ca80
;    ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ,,------ 1 byte  to $ca84
;    ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ||  ,,-- 1 byte  to $c2f1
.db $0f,$02,$27,$60,$57,$80,$57,$80,$03,$87,$93,$87,$93,$70,$b9,$5c,$d1,$0d,$07,$10,$01,$1f,$60,$ca
.db $0f,$09,$57,$68,$6f,$7c,$6f,$7c,$07,$90,$93,$90,$93,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c7
.db $0f,$16,$2f,$70,$4b,$80,$4b,$80,$07,$9f,$93,$9f,$93,$26,$ba,$d8,$d1,$0a,$08,$10,$15,$2f,$58,$c7
.db $0f,$1c,$37,$60,$57,$78,$5c,$86,$0f,$a8,$93,$ae,$93,$c6,$ba,$1c,$d2,$09,$03,$00,$00,$00,$00,$c7
.db $0f,$20,$3f,$68,$57,$80,$57,$80,$07,$b2,$93,$b2,$93,$fc,$ba,$5c,$d3,$04,$06,$00,$00,$00,$00,$c8
.db $0f,$24,$4f,$68,$67,$7e,$5f,$6a,$07,$ba,$93,$ba,$93,$2c,$bb,$1e,$d3,$06,$02,$00,$00,$00,$00,$c6
.db $0f,$28,$4f,$68,$57,$74,$57,$74,$07,$c4,$93,$c4,$93,$44,$bb,$de,$d2,$06,$03,$00,$00,$00,$00,$c8
.db $0f,$2d,$57,$6c,$3f,$7c,$3f,$7c,$07,$cc,$93,$cc,$93,$00,$00,$00,$00,$00,$00,$10,$2c,$27,$6c,$c6
.db $0f,$35,$47,$70,$4f,$80,$4f,$80,$07,$d6,$93,$d6,$93,$00,$00,$00,$00,$00,$00,$10,$34,$2f,$70,$c6
.db $0f,$40,$37,$74,$4f,$7c,$4f,$7c,$07,$e1,$93,$e1,$93,$00,$00,$00,$00,$00,$00,$10,$3f,$37,$74,$cb
.db $0f,$45,$37,$74,$4f,$7c,$4f,$7c,$07,$e1,$93,$e1,$93,$00,$00,$00,$00,$00,$00,$10,$3f,$37,$74,$00
.db $0f,$4a,$2f,$68,$47,$7c,$47,$7c,$07,$ea,$93,$ea,$93,$00,$00,$00,$00,$00,$00,$10,$47,$2f,$68,$cb
.db $0f,$4a,$2f,$68,$47,$7c,$47,$7c,$07,$ea,$93,$ea,$93,$00,$00,$00,$00,$00,$00,$10,$48,$2f,$68,$cb
.db $0f,$4a,$2f,$68,$47,$7c,$47,$7c,$07,$ea,$93,$ea,$93,$00,$00,$00,$00,$00,$00,$10,$49,$2f,$68,$cb
.db $0f,$50,$4f,$68,$6f,$74,$6f,$74,$01,$f2,$93,$f2,$93,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c9
.db $0f,$54,$47,$68,$5f,$74,$5f,$74,$03,$fd,$93,$fd,$93,$68,$bb,$9c,$d1,$09,$06,$10,$53,$27,$68,$ca
.db $0f,$5d,$6f,$68,$77,$7c,$77,$7c,$07,$0c,$94,$0c,$94,$d4,$bb,$18,$d3,$06,$08,$10,$5c,$57,$60,$c6
.db $0f,$66,$3f,$68,$57,$7c,$5f,$7c,$01,$17,$94,$17,$94,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c9
.db $0f,$69,$37,$70,$47,$7c,$47,$7c,$0b,$22,$94,$22,$94,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c8
.db $0f,$70,$37,$68,$67,$70,$6f,$6e,$05,$31,$94,$31,$94,$34,$bc,$1c,$d3,$04,$04,$00,$00,$00,$00,$c7
.db $0f,$79,$47,$84,$4f,$7c,$4f,$7c,$03,$3c,$94,$3c,$94,$00,$00,$00,$00,$00,$00,$10,$78,$3f,$6c,$c6
.db $0f,$e3,$27,$60,$3f,$7c,$3f,$7c,$03,$48,$94,$48,$94,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ca
.db $0f,$82,$6f,$78,$6f,$7c,$6f,$7c,$03,$5a,$94,$5a,$94,$00,$00,$00,$00,$00,$00,$10,$81,$5f,$68,$c8
.db $0f,$00,$4f,$68,$4f,$78,$4f,$78,$03,$66,$94,$66,$94,$54,$bc,$5c,$d2,$09,$04,$10,$8d,$3f,$68,$c6
.db $0f,$99,$4f,$68,$5f,$7c,$5f,$7c,$03,$73,$94,$73,$94,$00,$00,$00,$00,$00,$00,$10,$96,$4f,$68,$cb
.db $0f,$9d,$4f,$68,$5f,$7c,$5f,$7c,$03,$7a,$94,$7a,$94,$00,$00,$00,$00,$00,$00,$10,$97,$4f,$68,$c6
.db $0f,$99,$4f,$68,$5f,$7c,$5f,$7c,$03,$73,$94,$73,$94,$00,$00,$00,$00,$00,$00,$10,$98,$4f,$68,$cb
.db $0f,$a3,$1f,$60,$37,$7c,$37,$7c,$07,$84,$94,$84,$94,$9c,$bc,$9e,$d1,$0c,$02,$10,$ab,$57,$60,$ca
.db $0f,$ad,$27,$60,$3f,$7c,$4b,$86,$07,$92,$94,$9a,$94,$cc,$bc,$de,$d1,$0a,$03,$10,$ac,$27,$60,$cb
.db $0f,$b5,$27,$60,$3f,$80,$43,$81,$05,$a0,$94,$a9,$94,$08,$bd,$da,$d1,$0b,$05,$10,$b4,$27,$60,$cc
.db $0f,$bb,$1f,$60,$3f,$80,$3f,$80,$07,$ac,$94,$ac,$94,$76,$bd,$5a,$d1,$0d,$06,$10,$ba,$1f,$60,$c7
.db $0f,$c0,$2f,$60,$3f,$78,$3f,$78,$03,$b2,$94,$b2,$94,$12,$be,$dc,$d1,$0b,$04,$10,$bf,$2f,$60,$c6
.db $0f,$00,$27,$60,$4f,$7c,$4f,$7c,$07,$bb,$94,$bb,$94,$6a,$be,$1e,$d2,$04,$03,$10,$c6,$27,$60,$c9
.db $0f,$ce,$37,$70,$77,$7c,$77,$7c,$07,$c6,$94,$c6,$94,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c8
.db $0f,$d3,$2f,$64,$4f,$77,$4f,$77,$05,$d0,$94,$d0,$94,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c9
.db $0f,$d7,$1f,$60,$47,$7c,$47,$7c,$03,$dd,$94,$dd,$94,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c9
.db $0f,$df,$47,$70,$57,$7c,$57,$7c,$07,$ee,$94,$ee,$94,$82,$be,$5c,$d2,$06,$04,$00,$00,$00,$00,$c6
.db $13,$00,$ff,$8d,$4f,$7c,$4f,$7c,$03,$f6,$94,$f6,$94,$b2,$be,$9c,$d2,$0b,$05,$10,$cb,$ff,$68,$a9
.db $14,$00,$4f,$70,$47,$7c,$47,$7c,$05,$27,$95,$27,$95,$20,$bf,$5c,$d2,$06,$04,$00,$00,$00,$00,$a9
.ends
.orga $9387

; Data from CFC7 to D4F5 (1327 bytes)
_DATA_CFC7_: ; 24 bytes per entry
.db $20 $25 $2A $2F $3F $02 $03 $01 $13 $83 $BD $25 $01 $FF $96 $FA $00 $00 $00 $00 $0A $00 $01 $00
.db $0F $02 $27 $60 $57 $80 $57 $80 $03 $87 $93 $87 $93 $70 $B9 $5C $D1 $0D $07 $10 $01 $1F $60 $CA
.db $0F $09 $57 $68 $6F $7C $6F $7C $07 $90 $93 $90 $93 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C7
.db $0F $16 $2F $70 $4B $80 $4B $80 $07 $9F $93 $9F $93 $26 $BA $D8 $D1 $0A $08 $10 $15 $2F $58 $C7
.db $0F $1C $37 $60 $57 $78 $5C $86 $0F $A8 $93 $AE $93 $C6 $BA $1C $D2 $09 $03 $00 $00 $00 $00 $C7
.db $0F $20 $3F $68 $57 $80 $57 $80 $07 $B2 $93 $B2 $93 $FC $BA $5C $D3 $04 $06 $00 $00 $00 $00 $C8
.db $0F $24 $4F $68 $67 $7E $5F $6A $07 $BA $93 $BA $93 $2C $BB $1E $D3 $06 $02 $00 $00 $00 $00 $C6
.db $0F $28 $4F $68 $57 $74 $57 $74 $07 $C4 $93 $C4 $93 $44 $BB $DE $D2 $06 $03 $00 $00 $00 $00 $C8
.db $0F $2D $57 $6C $3F $7C $3F $7C $07 $CC $93 $CC $93 $00 $00 $00 $00 $00 $00 $10 $2C $27 $6C $C6
.db $0F $35 $47 $70 $4F $80 $4F $80 $07 $D6 $93 $D6 $93 $00 $00 $00 $00 $00 $00 $10 $34 $2F $70 $C6
.db $0F $40 $37 $74 $4F $7C $4F $7C $07 $E1 $93 $E1 $93 $00 $00 $00 $00 $00 $00 $10 $3F $37 $74 $CB
.db $0F $45 $37 $74 $4F $7C $4F $7C $07 $E1 $93 $E1 $93 $00 $00 $00 $00 $00 $00 $10 $3F $37 $74 $00
.db $0F $4A $2F $68 $47 $7C $47 $7C $07 $EA $93 $EA $93 $00 $00 $00 $00 $00 $00 $10 $47 $2F $68 $CB
.db $0F $4A $2F $68 $47 $7C $47 $7C $07 $EA $93 $EA $93 $00 $00 $00 $00 $00 $00 $10 $48 $2F $68 $CB
.db $0F $4A $2F $68 $47 $7C $47 $7C $07 $EA $93 $EA $93 $00 $00 $00 $00 $00 $00 $10 $49 $2F $68 $CB
.db $0F $50 $4F $68 $6F $74 $6F $74 $01 $F2 $93 $F2 $93 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C9
.db $0F $54 $47 $68 $5F $74 $5F $74 $03 $FD $93 $FD $93 $68 $BB $9C $D1 $09 $06 $10 $53 $27 $68 $CA
.db $0F $5D $6F $68 $77 $7C $77 $7C $07 $0C $94 $0C $94 $D4 $BB $18 $D3 $06 $08 $10 $5C $57 $60 $C6
.db $0F $66 $3F $68 $57 $7C $5F $7C $01 $17 $94 $17 $94 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C9
.db $0F $69 $37 $70 $47 $7C $47 $7C $0B $22 $94 $22 $94 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C8
.db $0F $70 $37 $68 $67 $70 $6F $6E $05 $31 $94 $31 $94 $34 $BC $1C $D3 $04 $04 $00 $00 $00 $00 $C7
.db $0F $79 $47 $84 $4F $7C $4F $7C $03 $3C $94 $3C $94 $00 $00 $00 $00 $00 $00 $10 $78 $3F $6C $C6
.db $0F $E3 $27 $60 $3F $7C $3F $7C $03 $48 $94 $48 $94 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $CA
.db $0F $82 $6F $78 $6F $7C $6F $7C $03 $5A $94 $5A $94 $00 $00 $00 $00 $00 $00 $10 $81 $5F $68 $C8
.db $0F $00 $4F $68 $4F $78 $4F $78 $03 $66 $94 $66 $94 $54 $BC $5C $D2 $09 $04 $10 $8D $3F $68 $C6
.db $0F $99 $4F $68 $5F $7C $5F $7C $03 $73 $94 $73 $94 $00 $00 $00 $00 $00 $00 $10 $96 $4F $68 $CB
.db $0F $9D $4F $68 $5F $7C $5F $7C $03 $7A $94 $7A $94 $00 $00 $00 $00 $00 $00 $10 $97 $4F $68 $C6
.db $0F $99 $4F $68 $5F $7C $5F $7C $03 $73 $94 $73 $94 $00 $00 $00 $00 $00 $00 $10 $98 $4F $68 $CB
.db $0F $A3 $1F $60 $37 $7C $37 $7C $07 $84 $94 $84 $94 $9C $BC $9E $D1 $0C $02 $10 $AB $57 $60 $CA
.db $0F $AD $27 $60 $3F $7C $4B $86 $07 $92 $94 $9A $94 $CC $BC $DE $D1 $0A $03 $10 $AC $27 $60 $CB
.db $0F $B5 $27 $60 $3F $80 $43 $81 $05 $A0 $94 $A9 $94 $08 $BD $DA $D1 $0B $05 $10 $B4 $27 $60 $CC
.db $0F $BB $1F $60 $3F $80 $3F $80 $07 $AC $94 $AC $94 $76 $BD $5A $D1 $0D $06 $10 $BA $1F $60 $C7
.db $0F $C0 $2F $60 $3F $78 $3F $78 $03 $B2 $94 $B2 $94 $12 $BE $DC $D1 $0B $04 $10 $BF $2F $60 $C6
.db $0F $00 $27 $60 $4F $7C $4F $7C $07 $BB $94 $BB $94 $6A $BE $1E $D2 $04 $03 $10 $C6 $27 $60 $C9
.db $0F $CE $37 $70 $77 $7C $77 $7C $07 $C6 $94 $C6 $94 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C8
.db $0F $D3 $2F $64 $4F $77 $4F $77 $05 $D0 $94 $D0 $94 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C9
.db $0F $D7 $1F $60 $47 $7C $47 $7C $03 $DD $94 $DD $94 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $C9
.db $0F $DF $47 $70 $57 $7C $57 $7C $07 $EE $94 $EE $94 $82 $BE $5C $D2 $06 $04 $00 $00 $00 $00 $C6
.db $13 $00 $FF $8D $4F $7C $4F $7C $03 $F6 $94 $F6 $94 $B2 $BE $9C $D2 $0B $05 $10 $CB $FF $68 $A9
.db $14 $00 $4F $70 $47 $7C $47 $7C $05 $27 $95 $27 $95 $20 $BF $5C $D2 $06 $04 $00 $00 $00 $00 $A9
.db $02 $03 $04 $05 $06 $07 $08 $00 $00 $09 $0A $0B $0C $0D $0D $0E $0F $0E $0F $0D $00 $0C $0B $00
.db $16 $17 $18 $19 $1A $1B $00 $1A $00 $1C $1D $1E $00 $1D $00 $1C $1F $00 $00 $20 $21 $22 $23 $00
.db $22 $21 $00 $24 $25 $26 $27 $26 $27 $00 $26 $25 $00 $28 $29 $2A $2B $00 $2A $29 $00 $2D $2E $2F
.db $30 $31 $32 $33 $00 $31 $00 $35 $36 $37 $38 $39 $3A $3B $3C $00 $36 $00 $40 $41 $42 $43 $44 $00
.db $43 $42 $00 $4A $4B $4C $4D $4E $00 $4F $00 $50 $51 $52 $51 $50 $51 $52 $51 $50 $00 $00 $54 $55
.db $56 $56 $57 $58 $59 $5A $5B $59 $5A $5B $00 $56 $00 $5D $5E $5F $60 $61 $62 $63 $64 $65 $00 $00
.db $66 $67 $66 $68 $66 $67 $66 $68 $66 $00 $00 $69 $6A $69 $6A $6B $6C $6D $6E $6F $00 $6E $6D $6C
.db $6B $00 $70 $71 $72 $72 $73 $74 $75 $00 $74 $73 $00 $79 $7A $7B $7B $7C $7D $7E $7F $80 $00 $7B
.db $00 $E3 $E4 $E4 $E5 $E5 $E6 $E7 $E8 $E9 $EA $EB $EA $EB $EA $EB $00 $E4 $00 $82 $83 $84 $85 $86
.db $87 $00 $86 $85 $84 $83 $00 $00 $8F $90 $90 $91 $91 $92 $93 $94 $95 $00 $8F $00 $99 $9A $9B $9B
.db $9C $00 $00 $9D $9E $9F $9F $A0 $A1 $00 $A2 $9F $00 $A3 $A4 $A5 $A5 $A4 $A3 $A6 $A6 $A7 $A8 $A9
.db $AA $00 $00 $AD $B0 $B1 $B1 $B2 $AD $00 $00 $AD $AE $AF $00 $AE $00 $B5 $B6 $B6 $B7 $B8 $B9 $00
.db $B9 $00 $B5 $00 $00 $BB $BC $BD $BE $00 $00 $C0 $C1 $C2 $C3 $C4 $C5 $C0 $00 $00 $00 $C7 $C8 $C9
.db $CA $C7 $C8 $C9 $CA $00 $00 $CE $CF $D0 $D1 $D2 $00 $D1 $D0 $CF $00 $D3 $D4 $D5 $D6 $D4 $D3 $D4
.db $D5 $D6 $D4 $D3 $00 $00 $D7 $D8 $D8 $D9 $D9 $DA $DB $DC $DD $DB $DC $00 $DD $DE $D9 $D9 $00 $DF
.db $E0 $E1 $E2 $E1 $E2 $00 $00
; Data from D4F6 to D505 (16 bytes)
_DATA_D4F6_:
.db $00 $EC $ED $EE $ED $EE $EF $F0 $F1 $F2 $F3 $F4 $F5 $00 $F6 $00

; Data from D506 to D53F (58 bytes)
_DATA_D506_:
.db $00 $EF $F0 $F1 $F7 $F8 $F9 $FA $00 $FB $00 $00 $EF $F0 $F1 $FC
.db $FD $FE $FF $00 $10 $00 $00 $EF $F0 $F1 $11 $12 $B3 $46 $00 $8E
.db $00 $00 $13 $13 $14 $3D $3E $76 $3D $3E $76 $3D $3E $76 $3D $77
.db $77 $88 $89 $8A $8B $8C $CC $00 $CD $00

; Data from D540 to D5BB (124 bytes)
DialogueSpritePaletteIndices:
; Pair of
; * Index into DialogueSpritePalettes
; * ???
; for each dialogue
.db $00 $00 $00 $00 $01 $00 $02 $00 $03 $00 $04 $00 $05 $00 $06 $00
.db $07 $00 $08 $00 $09 $00 $0A $00 $0B $00 $00 $01 $01 $01 $02 $01
.db $03 $01 $04 $01 $05 $01 $06 $01 $07 $01 $08 $01 $09 $01 $0A $01
.db $0B $01 $00 $02 $01 $02 $02 $02 $03 $02 $04 $02 $05 $02 $06 $02
.db $07 $02 $08 $02 $09 $02 $0A $02 $0B $02 $00 $03 $01 $03 $02 $03
.db $03 $03 $04 $03 $05 $03 $06 $03 $07 $03 $08 $03 $09 $03 $0A $03
.db $0B $03 $0C $04 $0D $05 $0C $06 $0E $07 $0F $08 $10 $09 $10 $0A
.db $11 $0B $12 $0C $13 $0D $14 $0E $15 $0F $15 $10

; Data from D5BC to D66B (176 bytes)
DialogueSpritePalettes:
.db $2B $0B $06 $2A $25 $03 $02 $0F
.db $2B $0B $06 $2A $25 $0C $08 $0F
.db $2B $0B $06 $2A $25 $3C $38 $0F
.db $2B $0B $06 $2A $25 $3F $3C $0F
.db $2B $00 $06 $2A $25 $03 $02 $25
.db $2B $00 $06 $2A $25 $0C $08 $25
.db $2B $00 $06 $2A $25 $3C $38 $25
.db $2B $00 $06 $2A $25 $3F $3C $25
.db $2B $34 $06 $2A $25 $03 $02 $38
.db $2B $34 $06 $2A $25 $0C $08 $38
.db $2B $34 $06 $2A $25 $3C $38 $38
.db $2B $34 $06 $2A $25 $3F $3C $38
.db $2B $0B $06 $2A $25 $03 $02 $0F
.db $2B $0B $06 $2A $25 $01 $02 $0F
.db $2B $0B $06 $2A $25 $0A $05 $0F
.db $2B $0B $06 $2A $25 $3C $20 $02
.db $2B $0B $06 $2A $25 $3E $3C $02
.db $04 $01 $06 $3F $3E $3C $3E $3F
.db $2B $0B $06 $2A $3E $21 $02 $36
.db $2A $25 $2A $2A $3F $2A $25 $25
.db $2B $3E $06 $2A $25 $3C $00 $00
.db $02 $3C $0A $04 $2C $01 $08 $2F

; Data from D66C to D6F3 (136 bytes)
DialogueSprites:
;   Attributes         Page  Offset
.db $10 $50 $4F $70 $00 $1B $00 $80
.db $10 $51 $4F $70 $00 $1B $00 $80
.db $10 $52 $4F $70 $00 $1B $00 $80
.db $10 $53 $4F $70 $00 $1B $00 $80
.db $10 $54 $4F $68 $00 $1B $19 $8E
.db $10 $55 $4F $70 $00 $1B $19 $8E
.db $10 $56 $4F $70 $00 $1B $19 $8E
.db $10 $57 $4F $70 $00 $06 $80 $BB
.db $10 $58 $4F $68 $00 $1B $79 $99
.db $10 $59 $6F $64 $00 $1B $26 $9F
.db $10 $5A $6F $6C $00 $1B $26 $9F
.db $10 $5B $4F $70 $00 $1B $5E $A7
.db $10 $5C $4F $70 $00 $1B $04 $AB
.db $10 $5D $4F $6C $00 $1B $6C $AE
.db $10 $5E $4F $68 $00 $15 $97 $BA
.db $10 $82 $4F $74 $00 $13 $ED $96
.db $10 $83 $4F $74 $00 $13 $ED $96

.orga $96f4
.section "Character sprite data table" overwrite
; Pointer Table from D6F4 to D80B (140 entries,indexed by CharacterSpriteAttributes)
CharacterSpriteData:   ; $96f4
; Sprite data 1
; Table of structures, followed by structures themselves, for various sprites
; giving their y, x and tile numbers
; for use when updating the sprite table in RAM and then VRAM

.dw _DATA_D80C_ _DATA_D80C_ _DATA_D81F_ _DATA_D832_ _DATA_D845_ _DATA_D852_ _DATA_D883_ _DATA_D890_
.dw _DATA_D89D_ _DATA_D8B3_ _DATA_D8C6_ _DATA_D8CD_ _DATA_D8DA_ _DATA_D8F3_ _DATA_D909_ _DATA_D910_
.dw _DATA_D917_ _DATA_D91B_ _DATA_D925_ _DATA_D92C_ _DATA_D939_ _DATA_D952_ _DATA_D965_ _DATA_D972_
.dw _DATA_D976_ _DATA_D97A_ _DATA_D981_ _DATA_D98E_ _DATA_D99B_ _DATA_D9A2_ _DATA_D9A6_ _DATA_D9AA_
.dw _DATA_D9AE_ _DATA_D9B2_ _DATA_D9B9_ _DATA_D9C6_ _DATA_D9DF_ _DATA_D9EC_ _DATA_D9F3_ _DATA_D9F7_
.dw _DATA_D9FE_ _DATA_DA05_ _DATA_DA0C_ _DATA_DA19_ _DATA_DA2F_ _DATA_DA3F_ _DATA_DA52_ _DATA_DA5C_
.dw _DATA_DA60_ _DATA_DA64_ _DATA_DA68_ _DATA_DA6F_ _DATA_DA7C_ _DATA_DA95_ _DATA_DAAE_ _DATA_DABB_
.dw _DATA_DABF_ _DATA_DAC6_ _DATA_DD5C_ _DATA_DDA2_ _DATA_DDE8_ _DATA_DE3D_ _DATA_DE80_ _DATA_DEC3_
.dw _DATA_DF06_ _DATA_DF55_ _DATA_DFC8_ _DATA_E011_ _DATA_E054_ _DATA_E097_ _DATA_E0E0_ _DATA_DC9B_
.dw _DATA_DCA2_ _DATA_DCA9_ _DATA_DCB0_ _DATA_DCBA_ _DATA_DCCD_ _DATA_DCDA_ _DATA_DCE1_ _DATA_DCE1_
.dw _DATA_E13B_ _DATA_E199_ _DATA_E1FD_ _DATA_E26D_ _DATA_E2D7_ _DATA_E34D_ _DATA_E3B7_ _DATA_E41E_
.dw _DATA_E49D_ _DATA_E58F_ _DATA_E53A_ _DATA_E60B_ _DATA_E681_ _DATA_E6F7_ _DATA_E788_ _DATA_DACA_
.dw _DATA_DAD7_ _DATA_DAEA_ _DATA_DB03_ _DATA_DB13_ _DATA_DB20_ _DATA_DB33_ _DATA_DB4C_ _DATA_DB62_
.dw _DATA_DB7B_ _DATA_DB8E_ _DATA_DBA7_ _DATA_DBB4_ _DATA_DBC1_ _DATA_DBC8_ _DATA_DBDB_ _DATA_DBF1_
.dw _DATA_DBF8_ _DATA_DC0B_ _DATA_DC15_ _DATA_DC22_ _DATA_DC2F_ _DATA_DC3F_ _DATA_DC4C_ _DATA_DC5F_
.dw _DATA_DC78_ _DATA_DC8E_ _DATA_DCEE_ _DATA_DCF5_ _DATA_DCFC_ _DATA_DD09_ _DATA_DD1C_ _DATA_DD3B_
.dw _DATA_DD48_ _DATA_DD4F_ _DATA_E816_ _DATA_E874_ _DATA_E8D2_ _DATA_E8E2_ _DATA_E8F2_ _DATA_E8E2_
.dw _DATA_E902_ _DATA_E912_ _DATA_E922_ _DATA_E912_

; 1st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D80C to D81E (19 bytes)
_DATA_D80C_:
.db 6 ; count
.db  -9    , -9    , -1    , -1    ,  7    ,  7     ; y positions
.db   0,$AA,  8,$AB,  0,$AC,  8,$AD,  0,$AE,  8,$AF ; x positions/tile numbers

; 3rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D81F to D831 (19 bytes)
_DATA_D81F_:
.db 6 ; count
.db  -9    , -9    , -1    , -1    ,  7    ,  7     ; y positions
.db   0,$B0,  8,$B1,  0,$B2,  8,$B3,  0,$B4,  8,$B5 ; x positions/tile numbers

; 4th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D832 to D844 (19 bytes)
_DATA_D832_:
.db 6 ; count
.db  -9    , -9    , -1    , -1    ,  7    ,  7     ; y positions
.db   0,$B6,  8,$B7,  0,$B8,  8,$B9,  0,$BA,  8,$BB ; x positions/tile numbers

; 5th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D845 to D851 (13 bytes)
_DATA_D845_:
.db 4 ; count
.db  -1    , -1    ,  7    ,  7     ; y positions
.db   0,$BC,  8,$BD,  0,$BE,  8,$BF ; x positions/tile numbers

; 6th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D852 to D882 (49 bytes)
_DATA_D852_:
.db 16 ; count
.db -17    ,-17    ,-17    ,-17    , -9    , -9    , -9    , -9    , -1    , -1    , -1    , -1    ,  7    ,  7    ,  7    ,  7     ; y positions
.db -16,$AA, -8,$AB,  0,$AC,  8,$AD,-16,$AE, -8,$AF,  0,$B0,  8,$B1,-16,$B2, -8,$B3,  0,$B4,  8,$B5,-16,$B6, -8,$B7,  0,$B8,  8,$B9 ; x positions/tile numbers

; 7th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D883 to D88F (13 bytes)
_DATA_D883_:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  20,$A0, 15,$A1, 11,$A2,  7,$A3 ; x positions/tile numbers

; 8th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D890 to D89C (13 bytes)
_DATA_D890_:
.db  -4    , -4    ,  4    ,  4     ; y positions
.db   0,$A4,  8,$A5, -1,$A6,  7,$A7 ; x positions/tile numbers

; 9th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D89D to D8B2 (22 bytes)
_DATA_D89D_:
.db 7 ; count
.db  -4    , -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   0,$A8,  8,$A9,  1,$AA, -5,$AB, -8,$AC,-12,$AD,-16,$A0 ; x positions/tile numbers

; 10th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D8B3 to D8C5 (19 bytes)
_DATA_D8B3_:
.db 6 ; count
.db  -4    , -4    ,  4    , 20    , 28    , 36     ; y positions
.db   0,$AE, 13,$AF,  3,$B0, -8,$B1,-12,$B2,-16,$B3 ; x positions/tile numbers

; 11th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D8C6 to D8CC (7 bytes)
_DATA_D8C6_:
.db 2 ; count
.db  96    ,104     ; y positions
.db  45,$A0, 45,$A1 ; x positions/tile numbers

; 12th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D8CD to D8D9 (13 bytes)
_DATA_D8CD_:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers

; 13th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D8DA to D8F2 (25 bytes)
_DATA_D8DA_:
.db 8 ; count
.db  72    , 72    , 80    , 80    , 88    , 88    , 96    , 96     ; y positions
.db  35,$A6, 43,$A7, 36,$A8, 44,$A9, 39,$AA, 47,$AB, 42,$AC, 50,$AD ; x positions/tile numbers

; 14th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D8F3 to D908 (22 bytes)
_DATA_D8F3_:
.db 7 ; count
.db  40    , 48    , 48    , 56    , 56    , 64    , 64     ; y positions
.db  21,$AE, 23,$AF, 31,$A7, 26,$B0, 34,$B1, 29,$B2, 37,$B3 ; x positions/tile numbers

; 15th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D909 to D90F (7 bytes)
_DATA_D909_:
.db 2 ; count
.db  24    , 32     ; y positions
.db  14,$B4, 16,$B5 ; x positions/tile numbers

; 16th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D910 to D916 (7 bytes)
_DATA_D910_:
.db 2 ; count
.db   8    , 16     ; y positions
.db   8,$B6, 10,$B7 ; x positions/tile numbers

; 17th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D917 to D91A (4 bytes)
_DATA_D917_:
.db 1 ; count
.db   8     ; y positions
.db   5,$B8 ; x positions/tile numbers

; 18th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D91B to D924 (10 bytes)
_DATA_D91B_:
.db 3 ; count
.db   0    ,  8    ,  8     ; y positions
.db   4,$B9,  2,$BA, 10,$BB ; x positions/tile numbers

; 19th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D925 to D92B (7 bytes)
_DATA_D925_:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers

; 20th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D92C to D938 (13 bytes)
_DATA_D92C_:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers

; 21st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D939 to D951 (25 bytes)
_DATA_D939_:
.db 8 ; count
.db  56    , 64    , 72    , 80    , 80    , 88    , 88    , 96     ; y positions
.db  26,$A6, 30,$A7, 32,$A8, 35,$A9, 43,$AA, 38,$AB, 46,$AC, 44,$AD ; x positions/tile numbers

; 22nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D952 to D964 (19 bytes)
_DATA_D952_:
.db 6 ; count
.db  24    , 32    , 40    , 40    , 48    , 56     ; y positions
.db  13,$AE, 17,$AF, 19,$B0, 27,$B1, 22,$B2, 27,$B3 ; x positions/tile numbers

; 23rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D965 to D971 (13 bytes)
_DATA_D965_:
.db 4 ; count
.db   0    ,  8    , 16    , 24     ; y positions
.db   6,$B4,  7,$B5, 10,$B6, 16,$B7 ; x positions/tile numbers

; 24th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D972 to D975 (4 bytes)
_DATA_D972_:
.db 1 ; count
.db   0     ; y positions
.db   2,$B8 ; x positions/tile numbers

; 25th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D976 to D979 (4 bytes)
_DATA_D976_:
.db 1 ; count
.db   0     ; y positions
.db   0,$B9 ; x positions/tile numbers

; 26th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D97A to D980 (7 bytes)
_DATA_D97A_:
.db 2 ; count
.db  96    ,104     ; y positions
.db  45,$A0, 46,$A1 ; x positions/tile numbers

; 27th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D981 to D98D (13 bytes)
_DATA_D981_:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 42,$A4, 50,$A5 ; x positions/tile numbers

; 28th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D98E to D99A (13 bytes)
_DATA_D98E_:
.db 4 ; count
.db  72    , 72    , 80    , 80     ; y positions
.db  34,$A6, 42,$A7, 36,$A8, 44,$A9 ; x positions/tile numbers

; 29th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D99B to D9A1 (7 bytes)
_DATA_D99B_:
.db 2 ; count
.db  40    , 40     ; y positions
.db  19,$AA, 27,$AB ; x positions/tile numbers

; 30th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9A2 to D9A5 (4 bytes)
_DATA_D9A2_:
.db 1 ; count
.db  16     ; y positions
.db  10,$AC ; x positions/tile numbers

; 31st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9A6 to D9A9 (4 bytes)
_DATA_D9A6_:
.db 1 ; count
.db   0     ; y positions
.db   5,$AD ; x positions/tile numbers

; 32nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9AA to D9AD (4 bytes)
_DATA_D9AA_:
.db 1 ; count
.db   0     ; y positions
.db   2,$AE ; x positions/tile numbers

; 33rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9AE to D9B1 (4 bytes)
_DATA_D9AE_:
.db 1 ; count
.db   0     ; y positions
.db   0,$AF ; x positions/tile numbers

; 34th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9B2 to D9B8 (7 bytes)
_DATA_D9B2_:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers

; 35th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9B9 to D9C5 (13 bytes)
_DATA_D9B9_:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers

; 36th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9C6 to D9DE (25 bytes)
_DATA_D9C6_:
.db 8 ; count
.db  56    , 56    , 64    , 64    , 72    , 80    , 80    , 88     ; y positions
.db  24,$A6, 32,$A7, 25,$A8, 33,$A9, 32,$AA, 35,$AB, 43,$AC, 41,$AD ; x positions/tile numbers

; 37th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9DF to D9EB (13 bytes)
_DATA_D9DF_:
.db 4 ; count
.db  24    , 24    , 32    , 40     ; y positions
.db  13,$AE, 22,$AF, 16,$B0, 19,$B1 ; x positions/tile numbers

; 38th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9EC to D9F2 (7 bytes)
_DATA_D9EC_:
.db 2 ; count
.db   8    , 16     ; y positions
.db   7,$B2, 12,$B3 ; x positions/tile numbers

; 39th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9F3 to D9F6 (4 bytes)
_DATA_D9F3_:
.db 1 ; count
.db   0     ; y positions
.db   2,$B4 ; x positions/tile numbers

; 40th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9F7 to D9FD (7 bytes)
_DATA_D9F7_:
.db 2 ; count
.db   0    ,  0     ; y positions
.db   0,$B5,  8,$B6 ; x positions/tile numbers

; 41st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from D9FE to DA04 (7 bytes)
_DATA_D9FE_:
.db 2 ; count
.db   0    ,  8     ; y positions
.db   2,$B7,  0,$B8 ; x positions/tile numbers

; 42nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA05 to DA0B (7 bytes)
_DATA_DA05_:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers

; 43rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA0C to DA18 (13 bytes)
_DATA_DA0C_:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers

; 44th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA19 to DA2E (22 bytes)
_DATA_DA19_:
.db 7 ; count
.db  56    , 64    , 72    , 80    , 88    , 96    , 96     ; y positions
.db  34,$A6, 40,$A7, 41,$A8, 40,$A9, 40,$AA, 41,$AB, 49,$AC ; x positions/tile numbers

; 45th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA2F to DA3E (16 bytes)
_DATA_DA2F_:
.db 5 ; count
.db  24    , 32    , 40    , 48    , 56     ; y positions
.db  32,$AD, 32,$AE, 32,$AF, 33,$B0, 34,$B1 ; x positions/tile numbers

; 46th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA3F to DA51 (19 bytes)
_DATA_DA3F_:
.db 6 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 24     ; y positions
.db  16,$B2, 24,$B3, 16,$B4, 24,$B5, 27,$B6, 32,$B7 ; x positions/tile numbers

; 47th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA52 to DA5B (10 bytes)
_DATA_DA52_:
.db 3 ; count
.db   0    ,  0    ,  8     ; y positions
.db   3,$B8, 11,$B9,  8,$BA ; x positions/tile numbers

; 48th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA5C to DA5F (4 bytes)
_DATA_DA5C_:
.db 1 ; count
.db   0     ; y positions
.db   2,$BB ; x positions/tile numbers

; 49th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA60 to DA63 (4 bytes)
_DATA_DA60_:
.db 1 ; count
.db   0     ; y positions
.db   0,$BC ; x positions/tile numbers

; 50th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA64 to DA67 (4 bytes)
_DATA_DA64_:
.db 1 ; count
.db   0     ; y positions
.db   0,$BD ; x positions/tile numbers

; 51st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA68 to DA6E (7 bytes)
_DATA_DA68_:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers

; 52nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA6F to DA7B (13 bytes)
_DATA_DA6F_:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers

; 53rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA7C to DA94 (25 bytes)
_DATA_DA7C_:
.db 8 ; count
.db  64    , 64    , 72    , 72    , 80    , 80    , 88    , 88     ; y positions
.db  29,$A6, 37,$A7, 29,$A8, 37,$A9, 31,$AA, 39,$AB, 32,$AC, 40,$AD ; x positions/tile numbers

; 54th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DA95 to DAAD (25 bytes)
_DATA_DA95_:
.db 8 ; count
.db  32    , 32    , 40    , 40    , 48    , 48    , 56    , 56     ; y positions
.db  17,$AE, 25,$AF, 19,$B0, 27,$B1, 21,$B2, 29,$B3, 23,$B4, 31,$B5 ; x positions/tile numbers

; 55th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DAAE to DABA (13 bytes)
_DATA_DAAE_:
.db 4 ; count
.db   8    , 16    , 16    , 24     ; y positions
.db   9,$B6,  9,$B7, 17,$B8, 13,$B9 ; x positions/tile numbers

; 56th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DABB to DABE (4 bytes)
_DATA_DABB_:
.db 1 ; count
.db   0     ; y positions
.db   6,$BA ; x positions/tile numbers

; 57th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DABF to DAC5 (7 bytes)
_DATA_DABF_:
.db 2 ; count
.db   0    ,  0     ; y positions
.db   0,$BB,  8,$BC ; x positions/tile numbers

; 58th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DAC6 to DAC9 (4 bytes)
_DATA_DAC6_:
.db 1 ; count
.db   0     ; y positions
.db   4,$BD ; x positions/tile numbers

; 96th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DACA to DAD6 (13 bytes)
_DATA_DACA_:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  18,$A0, 14,$A1, 10,$A1,  6,$A1 ; x positions/tile numbers

; 97th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DAD7 to DAE9 (19 bytes)
_DATA_DAD7_:
.db 6 ; count
.db -20    ,-12    , -4    , -4    ,  4    ,  4     ; y positions
.db  12,$A2,  7,$A3, -4,$A4,  4,$A5, -2,$A6,  6,$A7 ; x positions/tile numbers

; 98th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DAEA to DB02 (25 bytes)
_DATA_DAEA_:
.db 8 ; count
.db  -4    , -4    ,  4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   1,$A8,  9,$A9, -5,$AA,  3,$AB, -6,$A1,-10,$A1,-14,$A1,-14,$AC ; x positions/tile numbers

; 99th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB03 to DB12 (16 bytes)
_DATA_DB03_:
.db 5 ; count
.db  -4    ,  4    , 20    , 28    , 36     ; y positions
.db   3,$AD,  0,$AD, -8,$AE,-12,$AF,-16,$B0 ; x positions/tile numbers

; 100th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB13 to DB1F (13 bytes)
_DATA_DB13_:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  19,$A0, 15,$A1,  9,$A2,  6,$A3 ; x positions/tile numbers

; 101st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB20 to DB32 (19 bytes)
_DATA_DB20_:
.db 6 ; count
.db -12    , -4    , -4    ,  4    ,  4    , 12     ; y positions
.db   5,$A4, -1,$A5,  7,$A6, -4,$A7,  4,$A8, -5,$A9 ; x positions/tile numbers

; 102nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB33 to DB4B (25 bytes)
_DATA_DB33_:
.db 8 ; count
.db  -4    , -4    ,  4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db  -3,$AA,  5,$AB,  0,$AC,  8,$AD, -6,$AE, -9,$AF,-13,$A1,-15,$B0 ; x positions/tile numbers

; 103rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB4C to DB61 (22 bytes)
_DATA_DB4C_:
.db 7 ; count
.db -12    , -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   3,$B1,  3,$B2, -3,$B3,  4,$B1, -9,$B4,-12,$B4,-16,$B5 ; x positions/tile numbers

; 104th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB62 to DB7A (25 bytes)
_DATA_DB62_:
.db 8 ; count
.db -40    ,-32    ,-32    ,-24    ,-24    ,-16    ,-16    , -8     ; y positions
.db  16,$A0, 12,$A1, 20,$A2,  7,$A3, 15,$A4,  5,$A5, 13,$A6,  7,$A7 ; x positions/tile numbers

; 105th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB7B to DB8D (19 bytes)
_DATA_DB7B_:
.db 6 ; count
.db -16    , -8    , -8    ,  0    ,  0    ,  8     ; y positions
.db   3,$A8, -1,$A9,  7,$AA, -3,$AB,  5,$AC,  1,$AD ; x positions/tile numbers

; 106th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DB8E to DBA6 (25 bytes)
_DATA_DB8E_:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db  -5,$AE,  3,$AF, -8,$B0,  0,$B1,-12,$B2, -4,$B3,-14,$B4, -6,$B5 ; x positions/tile numbers

; 107th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DBA7 to DBB3 (13 bytes)
_DATA_DBA7_:
.db 4 ; count
.db   8    , 24    , 24    , 32     ; y positions
.db  -6,$B6,-16,$B7, -8,$B8,-16,$B9 ; x positions/tile numbers

; 108th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DBB4 to DBC0 (13 bytes)
_DATA_DBB4_:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  18,$A0, 14,$A1, 10,$A1,  8,$A2 ; x positions/tile numbers

; 109th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DBC1 to DBC7 (7 bytes)
_DATA_DBC1_:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   2,$A3,  0,$A2 ; x positions/tile numbers

; Data from DBC8 to DBDA (19 bytes)
_DATA_DBC8_:
.db 6 ; count
.db  -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   0,$A4,  0,$A5, -6,$A3,-10,$A1,-14,$A1,-16,$A6 ; x positions/tile numbers

; 111th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DBDB to DBF0 (22 bytes)
_DATA_DBDB_:
.db 7 ; count
.db -36    ,-28    ,-20    ,-12    , 20    , 28    , 36     ; y positions
.db -16,$A7,-14,$A8,-10,$A8, -6,$A9, -7,$AA,-12,$AB,-16,$AC ; x positions/tile numbers

; 112th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DBF1 to DBF7 (7 bytes)
_DATA_DBF1_:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   0,$AD,  2,$A9 ; x positions/tile numbers

; 113th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DBF8 to DC0A (19 bytes)
_DATA_DBF8_:
.db 6 ; count
.db  -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   0,$AE,  0,$AF,  8,$AD, 10,$A8, 14,$A8, 18,$B0 ; x positions/tile numbers

; 114th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC0B to DC14 (10 bytes)
_DATA_DC0B_:
.db 3 ; count
.db  20    , 28    , 36     ; y positions
.db  13,$B1, 15,$B2, 18,$B3 ; x positions/tile numbers

; 115th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC15 to DC21 (13 bytes)
_DATA_DC15_:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db -16,$A0,-12,$A1,-10,$A2, -6,$A2 ; x positions/tile numbers

; 116th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC22 to DC2E (13 bytes)
_DATA_DC22_:
.db 4 ; count
.db -12    , -4    ,  4    , 12     ; y positions
.db  -4,$A1, -2,$A2,  2,$A2,  6,$A3 ; x positions/tile numbers

; 117th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC2F to DC3E (16 bytes)
_DATA_DC2F_:
.db 5 ; count
.db  -4    ,  4    , 12    , 20    , 28     ; y positions
.db   0,$A4,  0,$A5,  6,$A2, 10,$A2, 14,$A3 ; x positions/tile numbers

; 118th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC3F to DC4B (13 bytes)
_DATA_DC3F_:
.db 4 ; count
.db  -4    ,  4    , 28    , 36     ; y positions
.db   3,$A6, -3,$A6, 16,$A7, 20,$A8 ; x positions/tile numbers

; 119th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC4C to DC5E (19 bytes)
_DATA_DC4C_:
.db 6 ; count
.db -36    ,-28    ,-20    ,-20    ,-12    ,-12     ; y positions
.db -16,$A0,-12,$A1,-10,$A2, -2,$A3, -8,$A4,  0,$A5 ; x positions/tile numbers

; 120th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC5F to DC77 (25 bytes)
_DATA_DC5F_:
.db 8 ; count
.db -12    ,-12    , -4    , -4    ,  4    ,  4    , 12    , 12     ; y positions
.db  -8,$A4,  0,$A5, -3,$A6,  5,$A7,  0,$A8,  8,$A7,  4,$A9, 12,$AA ; x positions/tile numbers

; 121st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC78 to DC8D (22 bytes)
_DATA_DC78_:
.db 7 ; count
.db  -4    ,  4    , 12    , 12    , 20    , 20    , 28     ; y positions
.db   0,$AB,  0,$AC,  4,$A9, 12,$AA,  8,$AD, 16,$A3, 14,$AE ; x positions/tile numbers

; 122nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC8E to DC9A (13 bytes)
_DATA_DC8E_:
.db 4 ; count
.db  -4    ,  4    , 28    , 36     ; y positions
.db   4,$AF, -4,$AF, 14,$B0, 20,$B1 ; x positions/tile numbers

; 72nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DC9B to DCA1 (7 bytes)
_DATA_DC9B_:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   2,$A0,  2,$A1 ; x positions/tile numbers

; 73rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCA2 to DCA8 (7 bytes)
_DATA_DCA2_:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers

; 74th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCA9 to DCAF (7 bytes)
_DATA_DCA9_:
.db 2 ; count
.db   4    , 12     ; y positions
.db   4,$A4,  3,$A5 ; x positions/tile numbers

; 75th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCB0 to DCB9 (10 bytes)
_DATA_DCB0_:
.db 3 ; count
.db  12    , 20    , 28     ; y positions
.db   1,$A6, -1,$A7, -3,$A8 ; x positions/tile numbers

; 76th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCBA to DCCC (19 bytes)
_DATA_DCBA_:
.db 6 ; count
.db  44    , 52    , 60    , 60    , 68    , 68     ; y positions
.db   2,$A9,  1,$AA, -3,$AB,  5,$AC, -3,$AD,  5,$AE ; x positions/tile numbers

; 77th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCCD to DCD9 (13 bytes)
_DATA_DCCD_:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -3,$AF,  5,$B0, -4,$B1,  4,$B2 ; x positions/tile numbers

; 78th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCDA to DCE0 (7 bytes)
_DATA_DCDA_:
.db 2 ; count
.db  68    , 76     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers

; 79th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCE1 to DCED (13 bytes)
_DATA_DCE1_:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -4,$B3,  4,$B4, -4,$B5,  4,$B6 ; x positions/tile numbers

; 123rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCEE to DCF4 (7 bytes)
_DATA_DCEE_:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   2,$A0,  2,$A1 ; x positions/tile numbers

; 124th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCF5 to DCFB (7 bytes)
_DATA_DCF5_:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers

; 125th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DCFC to DD08 (13 bytes)
_DATA_DCFC_:
.db 4 ; count
.db  -4    ,  4    ,  4    , 12     ; y positions
.db   2,$A0,  2,$A4, 10,$A5,  3,$A6 ; x positions/tile numbers

; 126th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DD09 to DD1B (19 bytes)
_DATA_DD09_:
.db 6 ; count
.db   4    , 12    , 20    , 28    , 28    , 36     ; y positions
.db  -4,$A7, -4,$A8, -4,$A9, -3,$AA,  5,$AB,  2,$AC ; x positions/tile numbers

; 127th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DD1C to DD3A (31 bytes)
_DATA_DD1C_:
.db 10 ; count
.db  12    , 20    , 20    , 28    , 36    , 44    , 44    , 52    , 60    , 68     ; y positions
.db   3,$AD, -1,$AE,  7,$AF, -2,$B0,  3,$B0, -2,$B1,  6,$B2, -3,$B3,  0,$B4,  0,$A3 ; x positions/tile numbers

; 128th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DD3B to DD47 (13 bytes)
_DATA_DD3B_:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -3,$B5,  5,$B6, -4,$B7,  4,$B8 ; x positions/tile numbers

; 129th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DD48 to DD4E (7 bytes)
_DATA_DD48_:
.db 2 ; count
.db  68    , 76     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers

; 130th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DD4F to DD5B (13 bytes)
_DATA_DD4F_:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -4,$B9,  4,$BA, -4,$BB,  4,$BC ; x positions/tile numbers

; 59th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DD5C to DDA1 (70 bytes)
_DATA_DD5C_:
.db 23 ; count
.db  16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  12,$00, 20,$01, 28,$02, 36,$03, 44,$04, 10,$05, 18,$06, 26,$07, 34,$08, 42,$09, 50,$0A, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 60th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DDA2 to DDE7 (70 bytes)
_DATA_DDA2_:
.db 23 ; count
.db  16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  12,$16, 20,$17, 28,$18, 36,$19, 44,$1A, 11,$1B, 19,$1C, 27,$1D, 35,$1E, 43,$1F, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 61st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DDE8 to DE3C (85 bytes)
_DATA_DDE8_:
.db 28 ; count
.db   8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  15,$21, 23,$22, 31,$22, 39,$23, 47,$24, 15,$25, 23,$26, 31,$26, 39,$27, 47,$28, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 62nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DE3D to DE7F (67 bytes)
_DATA_DE3D_:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 63rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DE80 to DEC2 (67 bytes)
_DATA_DE80_:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$2F, 35,$30, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 64th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DEC3 to DF05 (67 bytes)
_DATA_DEC3_:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$31, 24,$32, 32,$33, 40,$34, 11,$35, 19,$36, 27,$37, 35,$38, 43,$39, 51,$3A, 11,$3B, 19,$3C, 27,$3D, 35,$3E, 43,$3F, 51,$40,  8,$41, 16,$42, 24,$43, 32,$43, 40,$44, 48,$45 ; x positions/tile numbers

; 65th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DF06 to DF54 (79 bytes)
_DATA_DF06_:
.db 26 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  24,$46, 32,$47, 40,$48, 16,$49, 24,$4A, 32,$4B, 40,$4C, 48,$4D, 11,$4E, 19,$4F, 27,$50, 35,$51, 43,$52, 51,$53,  8,$54, 16,$55, 24,$56, 32,$57, 40,$58, 48,$59,  8,$5A, 16,$5B, 24,$5C, 32,$5D, 40,$5E, 48,$5F ; x positions/tile numbers

; 66th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DF55 to DFC7 (115 bytes)
_DATA_DF55_:
.db 38 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  13,$60, 21,$61, 35,$62, 43,$63,  9,$64, 17,$65, 25,$66, 33,$67, 41,$68, 49,$69,  8,$6A, 16,$6B, 24,$6C, 32,$6D, 40,$6E, 48,$6F,  8,$70, 16,$71, 24,$72, 32,$73, 40,$74, 48,$75,  1,$76,  9,$77, 17,$78, 25,$79, 33,$7A, 41,$7B, 49,$7C, 57,$7D,  0,$7E,  8,$7F, 16,$80, 24,$81, 32,$82, 40,$83, 48,$84, 56,$85 ; x positions/tile numbers

; 67th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from DFC8 to E010 (73 bytes)
_DATA_DFC8_:
.db 24 ; count
.db  16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db   8,$86, 16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$87, 27,$88, 35,$1E, 43,$2B, 51,$89, 59,$8A, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 68th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E011 to E053 (67 bytes)
_DATA_E011_:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$8B, 35,$8C, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers

; 69th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E054 to E096 (67 bytes)
_DATA_E054_:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$8D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$8E, 35,$8F, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$90, 32,$91, 40,$14, 48,$15 ; x positions/tile numbers

; 70th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E097 to E0DF (73 bytes)
_DATA_E097_:
.db 24 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$92, 32,$93, 40,$14, 48,$15, 24,$94, 32,$95 ; x positions/tile numbers

; 71st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E0E0 to E13A (91 bytes)
_DATA_E0E0_:
.db 30 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$96, 32,$97, 40,$14, 48,$15, 26,$98, 34,$99, 19,$9A, 27,$9B, 35,$9C, 43,$9D, 24,$9E, 32,$9F ; x positions/tile numbers

; 81st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E13B to E198 (94 bytes)
_DATA_E13B_:
.db 31 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80     ; y positions
.db  10,$00, 18,$01,  8,$02, 16,$03,  6,$04, 14,$05, 22,$06,  4,$07, 12,$08, 20,$09, 28,$0A,  2,$0B, 10,$0C, 18,$0D, 26,$0E,  0,$0F,  8,$10, 16,$11, 24,$12,  0,$13,  8,$14, 16,$15,  9,$16, 17,$17, 10,$18, 18,$19, 10,$1A, 18,$1B,  4,$1C, 12,$1D, 20,$1E ; x positions/tile numbers

; 82nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E199 to E1FC (100 bytes)
_DATA_E199_:
.db 33 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   9,$1F, 17,$20,  9,$21, 17,$22,  3,$23, 11,$24, 19,$25, 27,$26,  3,$27, 11,$28, 19,$29, 27,$2A,  5,$2B, 13,$2C, 21,$2D,  6,$2E, 14,$2F, 22,$30,  6,$31, 14,$32, 22,$33,  6,$34, 17,$35, 25,$36,  6,$37, 18,$38,  6,$39, 19,$3A, 27,$3B,  0,$3C,  8,$3D, 16,$3E, 24,$3F ; x positions/tile numbers

; 83rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E1FD to E26C (112 bytes)
_DATA_E1FD_:
.db 37 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  10,$40, 18,$01,  8,$41, 16,$42,  6,$43, 14,$44, 22,$45,  3,$46, 11,$47, 19,$48, 27,$49,  2,$4A, 10,$4B, 18,$4C, 26,$4D,  0,$4E,  8,$4F, 16,$50,  0,$51,  8,$52, 16,$53, 24,$54,  4,$55, 12,$56, 20,$57,  1,$58,  9,$59, 17,$5A, 25,$5B,  2,$5C, 10,$5D, 18,$5E, 26,$5F,  3,$60, 11,$61, 19,$62, 27,$63 ; x positions/tile numbers

; 84th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E26D to E2D6 (106 bytes)
_DATA_E26D_:
.db 35 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   9,$64, 17,$65,  9,$66, 17,$67,  2,$68, 10,$69, 18,$6A, 26,$6B,  0,$6C,  8,$6D, 16,$6E, 24,$6F,  0,$70,  8,$71, 16,$72, 24,$73,  3,$74, 11,$75, 19,$76, 27,$77,  6,$78, 14,$79, 22,$7A,  5,$7B, 13,$7C, 21,$7D,  4,$7E, 12,$7F, 20,$80,  3,$81, 20,$82,  0,$83,  8,$84, 16,$85, 24,$86 ; x positions/tile numbers

; 85th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E2D7 to E34C (118 bytes)
_DATA_E2D7_:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$00, 19,$01, 27,$02, 10,$03, 18,$04, 26,$05, 34,$06,  8,$07, 16,$08, 24,$09, 32,$0A,  8,$0B, 16,$0C, 24,$0D, 32,$0E,  6,$0F, 14,$10, 22,$11, 30,$12, 38,$13,  6,$14, 14,$15, 22,$16, 30,$17,  8,$18, 16,$19, 24,$1A, 32,$1B, 12,$1C, 20,$1D, 28,$1E, 12,$1F, 27,$20, 11,$21, 28,$22,  8,$23, 16,$24, 24,$25, 32,$26 ; x positions/tile numbers

; 86th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E34D to E3B6 (106 bytes)
_DATA_E34D_:
.db 35 ; count
.db   8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  10,$27, 18,$28,  3,$29, 11,$2A, 19,$2B, 27,$2C,  2,$2D, 10,$2E, 18,$2F, 26,$30,  2,$31, 10,$32, 18,$33, 26,$34,  5,$35, 13,$36, 21,$37,  3,$38, 11,$39, 19,$3A,  2,$3B, 10,$3C, 18,$3D, 26,$3E,  2,$3F, 10,$40, 18,$41, 26,$42,  4,$43, 12,$44, 20,$45,  0,$46,  8,$47, 16,$48, 24,$49 ; x positions/tile numbers

; 87th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E3B7 to E41D (103 bytes)
_DATA_E3B7_:
.db 34 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$4A, 19,$4B,  8,$4C, 16,$4D,  4,$4E, 12,$4F, 20,$50,  2,$51, 10,$52, 18,$53, 26,$54,  2,$55, 10,$56, 18,$57, 26,$58,  4,$59, 12,$5A, 20,$5B,  4,$5C, 12,$5D, 20,$5E,  5,$5F, 13,$60, 21,$61,  6,$62, 14,$63, 22,$64,  5,$65, 13,$66, 21,$67,  4,$68, 12,$69, 20,$6A, 28,$6B ; x positions/tile numbers

; 88th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E41E to E49C (127 bytes)
_DATA_E41E_:
.db 42 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   5,$00, 13,$01, 21,$02,  6,$03, 14,$04, 22,$05,  1,$06,  9,$07, 17,$08, 25,$09,  0,$0A,  8,$0B, 16,$0C, 24,$0D,  0,$0E,  8,$0F, 16,$10, 24,$11,  2,$12, 10,$13, 18,$14, 26,$15,  2,$16, 10,$17, 18,$18, 26,$19,  1,$1A,  9,$1B, 17,$1C, 25,$1D,  1,$1E,  9,$1F, 17,$20, 25,$21,  3,$22, 11,$23, 19,$24, 27,$25,  0,$26,  8,$27, 16,$28, 24,$29 ; x positions/tile numbers

; 89th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E49D to E539 (157 bytes)
_DATA_E49D_:
.db 52 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  11,$00, 19,$01, 27,$02, 35,$03, 11,$04, 19,$05, 27,$06, 35,$07, 11,$08, 19,$09, 27,$0A, 35,$07, 10,$0B, 18,$0C, 26,$0D, 34,$0E, 10,$0F, 18,$10, 26,$11, 34,$12,  3,$13, 11,$14, 19,$15, 27,$16, 35,$17, 43,$18,  2,$19, 10,$1A, 18,$1B, 26,$1C, 34,$1D, 42,$1E,  5,$1F, 13,$20, 21,$21, 29,$22, 37,$23,  4,$24, 12,$25, 20,$26, 28,$27, 36,$28,  4,$29, 12,$2A, 20,$2B, 28,$2C, 36,$2D,  4,$2E, 12,$2F, 20,$30, 28,$31, 36,$32 ; x positions/tile numbers

; 91st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E53A to E58E (85 bytes)
_DATA_E53A_:
.db 28 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48     ; y positions
.db   9,$00, 17,$01, 25,$02,  4,$03, 12,$04, 20,$05, 28,$06,  4,$07, 12,$08, 20,$09, 28,$0A,  5,$0B, 13,$0C, 21,$0D, 29,$0E,  4,$0F, 12,$10, 20,$11, 28,$12,  4,$13, 12,$14, 20,$15, 28,$16,  2,$17, 10,$18, 18,$19, 26,$1A, 34,$1B ; x positions/tile numbers

; 90th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E58F to E60A (124 bytes)
_DATA_E58F_:
.db 41 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 48     ; y positions
.db  16,$1C, 24,$1D, 32,$1E, 40,$1F,  8,$20, 16,$21, 24,$22, 32,$23, 40,$24, 48,$25,  8,$26, 16,$27, 24,$28, 32,$29, 40,$2A, 48,$2B,  1,$2C,  9,$2D, 17,$2E, 25,$2F, 33,$30, 41,$31,  8,$32, 16,$33, 24,$34, 32,$35, 40,$36,  0,$37,  8,$38, 16,$39, 24,$3A, 32,$3B, 40,$3C, 48,$3D,  0,$3E,  8,$3F, 16,$40, 24,$41, 32,$42, 40,$43, 48,$44 ; x positions/tile numbers

; 92nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E60B to E680 (118 bytes)
_DATA_E60B_:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   8,$00, 16,$01,  5,$02, 13,$03, 21,$04,  4,$05, 12,$06, 20,$07, 28,$08,  1,$09,  9,$0A, 17,$0B, 25,$0C,  0,$0D,  8,$0E, 16,$0F, 24,$10,  1,$11,  9,$12, 17,$13, 25,$14,  0,$0D,  8,$0E, 16,$0F, 24,$10,  1,$11,  9,$12, 17,$13, 25,$14,  1,$15,  9,$16, 17,$17, 25,$18,  8,$19, 16,$1A,  0,$1B,  8,$1C, 16,$1D, 24,$1E ; x positions/tile numbers

; 93rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E681 to E6F6 (118 bytes)
_DATA_E681_:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  10,$00, 18,$01, 10,$02, 18,$03,  5,$04, 13,$05, 21,$06,  0,$07,  8,$08, 16,$09, 24,$0A,  0,$0B,  8,$0C, 16,$0D, 24,$0E,  0,$0F,  8,$10, 16,$11, 24,$12,  0,$13,  8,$14, 16,$15, 24,$16,  0,$17,  8,$18, 16,$19, 24,$1A,  0,$1B,  8,$18, 16,$1C, 24,$1D,  0,$1E,  8,$18, 16,$19, 24,$1F,  0,$20,  8,$21, 16,$22, 24,$23 ; x positions/tile numbers

; 94th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E6F7 to E787 (145 bytes)
_DATA_E6F7_:
.db 48 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  14,$00, 22,$01, 30,$02,  1,$03,  9,$04, 17,$05, 25,$06, 33,$07,  1,$08,  9,$09, 17,$0A, 25,$0B, 33,$0C,  0,$0D,  8,$0E, 16,$0F, 24,$10, 32,$11,  0,$12, 10,$13, 18,$14, 26,$15, 34,$16,  1,$17,  9,$18, 17,$19, 25,$1A,  6,$1B, 14,$1C, 22,$1D, 30,$1E,  4,$1F, 12,$20, 23,$21, 31,$22,  2,$23, 10,$24, 23,$25, 31,$26,  2,$27, 10,$28, 24,$29, 32,$2A,  0,$2B,  8,$2C, 16,$2D, 24,$2E, 32,$2F ; x positions/tile numbers

; 95th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E788 to E815 (142 bytes)
_DATA_E788_:
.db 47 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  18,$00, 26,$01, 15,$02, 23,$03, 31,$04, 12,$05, 20,$06, 28,$07, 36,$08, 10,$09, 18,$0A, 26,$0B, 34,$0C, 10,$0D, 18,$0E, 26,$0F, 34,$10, 10,$11, 18,$12, 26,$13, 34,$14, 10,$15, 18,$16, 26,$17, 34,$18,  7,$19, 15,$1A, 23,$1B, 31,$1C, 39,$1D,  4,$1E, 12,$1F, 20,$20, 28,$21, 36,$22,  2,$23, 10,$24, 18,$25, 26,$26, 34,$27, 42,$28,  2,$29, 10,$2A, 18,$2B, 26,$2C, 34,$2D, 42,$2E ; x positions/tile numbers

; 131st entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E816 to E873 (94 bytes)
_DATA_E816_:
.db 31 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    ,  8    , 16    , 24    , 32    , 40     ; y positions
.db   8,$00, 16,$01,  6,$02, 14,$03,  8,$04, 16,$05,  8,$06, 16,$07,  8,$08, 16,$09,  5,$0A, 13,$0B, 21,$0C,  4,$0D, 12,$0E, 20,$0F,  5,$10, 13,$11, 21,$12,  5,$13, 13,$14,  6,$15, 14,$16,  0,$17,  8,$18, 16,$19,  1,$1A,  0,$1B,  0,$1C,  0,$1D,  2,$1E ; x positions/tile numbers

; 132nd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E874 to E8D1 (94 bytes)
_DATA_E874_:
.db 31 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    ,  8    , 16    , 24    , 32    , 40     ; y positions
.db   8,$00, 16,$01,  6,$02, 14,$03,  8,$04, 16,$05,  8,$06, 16,$07,  8,$08, 16,$09,  5,$0A, 13,$0B, 21,$0C,  4,$0D, 12,$0E, 20,$0F,  5,$10, 13,$11, 21,$12,  5,$13, 13,$14,  6,$15, 14,$16,  0,$17,  8,$18, 16,$19,  2,$2E,  2,$2F,  1,$30,  0,$29,  2,$1E ; x positions/tile numbers

; 133rd entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E8D2 to E8E1 (16 bytes)
_DATA_E8D2_:
.db 5 ; count
.db   0    ,  0    ,  0    ,  8    ,  8     ; y positions
.db   0,$00,  8,$01, 16,$02,  8,$03, 16,$04 ; x positions/tile numbers

; 134th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E8E2 to E8F1 (16 bytes)
_DATA_E8E2_:
.db 5 ; count
.db   0    ,  0    ,  8    ,  8    ,  8     ; y positions
.db   4,$05, 12,$06,  0,$07,  8,$08, 16,$09 ; x positions/tile numbers

; 135th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E8F2 to E901 (16 bytes)
_DATA_E8F2_:
.db 5 ; count
.db   0    ,  0    ,  8    ,  8    ,  8     ; y positions
.db   6,$0A, 14,$0B,  2,$0C, 10,$0D, 18,$0E ; x positions/tile numbers

; 137th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E902 to E911 (16 bytes)
_DATA_E902_:
.db 5 ; count
.db   0    ,  8    ,  8    ,  8    , 16     ; y positions
.db  11,$0F,  1,$10,  9,$11, 17,$12,  8,$13 ; x positions/tile numbers

; 138th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E912 to E921 (16 bytes)
_DATA_E912_:
.db 5 ; count
.db   0    ,  8    ,  8    ,  8    , 16     ; y positions
.db  11,$0F,  1,$14,  9,$15, 17,$16,  8,$13 ; x positions/tile numbers

; 139th entry of Pointer Table from D6F4 (indexed by CharacterSpriteAttributes)
; Data from E922 to EF5B (1594 bytes)
_DATA_E922_:
.db 6 ; count
.db   4    ,  0    ,  0    ,  8    ,  8    , 16     ; y positions
.db  16,$17,  2,$18, 11,$0F,  3,$19, 11,$1A,  8,$13 ; x positions/tile numbers

.ends
.orga $a935

; Data from EF5C to F472 (1303 bytes)
DungeonObjects:
.enum 0
  DungeonObject_Item db
  DungeonObject_Meseta db
  DungeonObject_Battle db
  DungeonObject_Dialogue db
.ende
.struct DungeonObject
  DungeonNumber db
  DungeonPosition db ; YX
  FlagAddress db ; to ensure you only get it once. Object triggers if RAM value is not $ff.
  ObjectType db ; see DungeonObject_ enum
  .union
    ItemID db
    IsTrapped db
  .nextu
    MesetaValue dw
  .nextu
    EnemyID db
    DroppedItemID db
  .nextu
    CharacterID db
    RoomID db
  .endu
.endst
.macro AddDungeonObject_Item
.dstruct instanceof DungeonObject values
  DungeonNumber:    .db \1,
  DungeonPosition:  .db \2,
  FlagAddress:      .dw \3,
  ObjectType:       .db DungeonObject_Item,
  ItemID:           .db \4,
  IsTrapped:        .db \5
.endst
.endm
.macro AddDungeonObject_Meseta
.dstruct instanceof DungeonObject values
  DungeonNumber:    .db \1,
  DungeonPosition:  .db \2,
  FlagAddress:      .dw \3,
  ObjectType:       .db DungeonObject_Item,
  MesetaValue:      .dw \4
.endst
.endm
.macro AddDungeonObject_Battle
.dstruct instanceof DungeonObject values
  DungeonNumber:    .db \1,
  DungeonPosition:  .db \2,
  FlagAddress:      .dw \3,
  ObjectType:       .db DungeonObject_Battle,
  EnemyID:          .db \4,
  ItemID:           .db \5,
.endst
.endm
.macro AddDungeonObject_Dialogue
.dstruct instanceof DungeonObject values
  DungeonNumber:    .db \1,
  DungeonPosition:  .db \2,
  FlagAddress:      .dw \3,
  ObjectType:       .db DungeonObject_Dialogue,
  CharacterID:      .db \4,
  RoomID:           .db \5
.endst
.endm
;                            ,,-------------------------- DungeonNumber
;                            ||   ,,---------------------- Y, X
;                            ||   ||   ,,,,--------------- RAM address to flag for object so you see it only once
;                            ||   ||   ||||
;                            ||   ||   ||||
  AddDungeonObject_Item     $00, $36, $c600, Item_Compass, 0
  AddDungeonObject_Meseta   $00, $E0, $c601, 20
  AddDungeonObject_Battle   $00, $53, $C6C0, Enemy_MadDoctor, Item_Empty
  AddDungeonObject_Dialogue $00, $E3, $C50A, $A3, $3A ; _room_a3_TaironStone ???
  AddDungeonObject_Meseta   $00, $7C, $C602, 10
  AddDungeonObject_Item     $01, $17, $C603, Item_Empty, $FC
  AddDungeonObject_Battle   $01, $5D, $C6C1, Enemy_Skeleton, Item_Empty
  AddDungeonObject_Dialogue $01, $B2, $C50C, $82, $00 ; _room_82_TriadaPrisonGuard1
  AddDungeonObject_Dialogue $01, $E9, $C50B, $88, $00 ; _room_88_TriadaPrisoner6
  AddDungeonObject_Item     $02, $17, DungeonKeyIsHidden, Item_DungeonKey, $00
  AddDungeonObject_Meseta   $02, $67, $C605, 50
  AddDungeonObject_Meseta   $02, $3A, $C606, 30
  AddDungeonObject_Meseta   $02, $63, $C607, 20
  AddDungeonObject_Item     $03, $9C, $C608, Item_Empty, $FC
  AddDungeonObject_Item     $03, $9E, $C609, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $03, $E1, $C60A, 10
  AddDungeonObject_Item     $03, $E8, $C60B, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $03, $E1, $C60C, 100
  AddDungeonObject_Item     $03, $56, $C60D, Item_EscapeCloth, $00
  AddDungeonObject_Item     $03, $58, $C60E, Item_Searchlight, $00
  AddDungeonObject_Meseta   $04, $13, $C60F, 20
  AddDungeonObject_Item     $04, $E5, $C610, Item_PelorieMate, $00
  AddDungeonObject_Meseta   $04, $13, $C611, 100
  AddDungeonObject_Item     $04, $1D, $C612, Item_Empty, $FC
  AddDungeonObject_Meseta   $05, $5B, $C613, 10
  AddDungeonObject_Meseta   $05, $A1, $C614, 5
  AddDungeonObject_Item     $05, $A3, $C615, Item_Empty, $FF
  AddDungeonObject_Item     $05, $DD, $C616, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $05, $5B, $C617, 100
  AddDungeonObject_Meseta   $05, $A1, $C618, 50
  AddDungeonObject_Meseta   $06, $55, $C619, 35
  AddDungeonObject_Item     $06, $93, $C61A, Item_Empty, $FC
  AddDungeonObject_Meseta   $06, $55, $C61B, 100
  AddDungeonObject_Meseta   $06, $29, $C61C, 10
  AddDungeonObject_Item     $07, $65, $C61D, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $07, $AC, $C61E, 100
  AddDungeonObject_Meseta   $07, $AC, $C61F, 500
  AddDungeonObject_Item     $07, $89, $C620, Item_Empty, $FF
  AddDungeonObject_Battle   $08, $29, $C6C2, Enemy_SkullSoldier, Item_Empty
  AddDungeonObject_Battle   $08, $65, $C6C3, Enemy_Herex, Item_Empty
  AddDungeonObject_Item     $08, $C3, $C621, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $08, $C5, $C622, 50
  AddDungeonObject_Item     $08, $EE, $C623, Item_Empty, $FF
  AddDungeonObject_Item     $09, $64, $C624, Item_PelorieMate, $00
  AddDungeonObject_Item     $09, $EE, $C625, Item_Ruoginin, $00
  AddDungeonObject_Item     $09, $91, $C626, Item_LightPendant, $00
  AddDungeonObject_Battle   $0A, $48, $C6C4, Enemy_BitingFly, Item_Empty
  AddDungeonObject_Item     $0A, $61, $C627, Item_Empty, $FF
  AddDungeonObject_Battle   $0A, $67, $C6C5, Enemy_Medusa, Item_Weapon_LaconianAxe
  AddDungeonObject_Item     $0A, $EE, $C628, Item_PelorieMate, $00
  AddDungeonObject_Meseta   $0A, $17, $C629, 500
  AddDungeonObject_Meseta   $0A, $E3, $C62A, 500
  AddDungeonObject_Item     $0A, $A9, $C62B, Item_EscapeCloth, $00
  AddDungeonObject_Item     $0A, $AB, $C62C, Item_Empty, $FC
  AddDungeonObject_Item     $0B, $71, $C62D, Item_Weapon_ShortSword, $00
  AddDungeonObject_Item     $0B, $ED, $C62E, Item_Weapon_LightSaber, $00
  AddDungeonObject_Item     $0B, $1C, $C62F, Item_Ruoginin, $00
  AddDungeonObject_Item     $0B, $63, $C630, Item_Weapon_IronSword, $00
  AddDungeonObject_Item     $0C, $11, $C631, Item_MiracleKey, $FC
  AddDungeonObject_Meseta   $0C, $2B, $C632, 20
  AddDungeonObject_Battle   $0C, $39, $C6C6, Enemy_BatMan, Item_Empty
  AddDungeonObject_Battle   $0C, $85, $C6C7, Enemy_MadStalker, Item_Empty
  AddDungeonObject_Battle   $0C, $A9, $C6C8, Enemy_MadStalker, Item_Empty
  AddDungeonObject_Item     $0C, $A5, $C633, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $0D, $68, $C634, 100
  AddDungeonObject_Item     $0D, $EB, $C635, Item_Weapon_IronAxe, $00
  AddDungeonObject_Item     $0D, $EE, $C636, Item_Empty, $FC
  AddDungeonObject_Meseta   $0D, $68, $C637, 100
  AddDungeonObject_Item     $0D, $E8, $C638, Item_Empty, $FF
  AddDungeonObject_Item     $0E, $11, $C639, Item_Ruoginin, $00
  AddDungeonObject_Item     $0E, $41, $C63A, Item_Empty, $FF
  AddDungeonObject_Item     $0E, $AC, $C63B, Item_Ruoginin, $00
  AddDungeonObject_Item     $0E, $E9, $C63C, Item_Empty, $FC
  AddDungeonObject_Item     $0F, $EE, $C63D, Item_Ruoginin, $00
  AddDungeonObject_Item     $10, $1E, $C63E, Item_PelorieMate, $00
  AddDungeonObject_Item     $10, $8B, $C63F, Item_Empty, $FC
  AddDungeonObject_Item     $10, $61, $C640, Item_Searchlight, $00
  AddDungeonObject_Item     $10, $9C, $C641, Item_Searchlight, $00
  AddDungeonObject_Battle   $10, $C7, $C6C9, Enemy_Skeleton, Item_Weapon_SilverTusk
  AddDungeonObject_Item     $10, $D1, $C642, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $11, $26, $C643, 10
  AddDungeonObject_Meseta   $11, $5E, $C644, 50
  AddDungeonObject_Meseta   $11, $71, $C645, 20
  AddDungeonObject_Meseta   $11, $7D, $C646, 20
  AddDungeonObject_Meseta   $11, $26, $C647, 20
  AddDungeonObject_Item     $12, $19, $C648, Item_Empty, $FC
  AddDungeonObject_Item     $12, $1E, $C649, Item_PelorieMate, $00
  AddDungeonObject_Item     $12, $CC, $C64A, Item_Searchlight, $00
  AddDungeonObject_Item     $12, $77, $C64B, Item_Weapon_ShortSword, $00
  AddDungeonObject_Meseta   $12, $92, $C64C, 20
  AddDungeonObject_Item     $12, $94, $C64D, Item_Empty, $FF
  AddDungeonObject_Item     $13, $1E, $C64E, Item_PelorieMate, $00
  AddDungeonObject_Meseta   $13, $33, $C64F, 20
  AddDungeonObject_Item     $13, $A5, $C650, Item_Empty, $00
  AddDungeonObject_Item     $13, $EC, $C651, Item_Empty, $7F
  AddDungeonObject_Meseta   $13, $EC, $C652, 20
  AddDungeonObject_Dialogue $14, $41, $C50D, $93, $00 ; _room_93_55AB
  AddDungeonObject_Dialogue $15, $55, $C50E, $91, $0F ; _room_91_DrasgoCave2
  AddDungeonObject_Dialogue $15, $A1, $C50F, $90, $29 ; _room_90_DrasgoCave1
  AddDungeonObject_Dialogue $15, $C8, $C518, $16, $00 ; _room_16_MadDoctor
  AddDungeonObject_Meseta   $16, $3E, $C653, 100
  AddDungeonObject_Item     $16, $5E, $C654, Item_Empty, $FC
  AddDungeonObject_Item     $16, $81, $C655, Item_Searchlight, $00
  AddDungeonObject_Item     $16, $C8, $C656, Item_EscapeCloth, $00
  AddDungeonObject_Meseta   $17, $AA, $C657, 20
  AddDungeonObject_Meseta   $17, $AA, $C658, 200
  AddDungeonObject_Item     $18, $16, $C659, Item_Empty, $FF
  AddDungeonObject_Battle   $18, $1C, $C6CA, Enemy_RedSlime, Item_Empty
  AddDungeonObject_Item     $19, $1A, $C65A, Item_Ruoginin, $00
  AddDungeonObject_Item     $19, $B9, $C65B, Item_Empty, $FF
  AddDungeonObject_Meseta   $19, $35, $C65C, 100
  AddDungeonObject_Meseta   $19, $C3, $C65D, 1
  AddDungeonObject_Item     $19, $74, $C65E, Item_Ruoginin, $00
  AddDungeonObject_Item     $19, $A3, $C65F, Item_Empty, $FC
  AddDungeonObject_Item     $1A, $1E, $C660, Item_Empty, $FC
  AddDungeonObject_Meseta   $1A, $33, $C661, 20
  AddDungeonObject_Item     $1A, $51, $C662, Item_Ruoginin, $00
  AddDungeonObject_Item     $1A, $CB, $C663, Item_Empty, $00
  AddDungeonObject_Battle   $1B, $5A, $C6CB, Enemy_RedDragon, Item_Weapon_LaconianSword
  AddDungeonObject_Item     $1B, $E1, $C664, Item_Ruoginin, $00
  AddDungeonObject_Battle   $1C, $1E, $C6CC, Enemy_RedDragon, Item_Empty
  AddDungeonObject_Meseta   $1C, $31, $C665, 2000
  AddDungeonObject_Item     $1D, $1B, $C666, Item_Searchlight, $00
  AddDungeonObject_Item     $1D, $21, $C667, Item_Ruoginin, $00
  AddDungeonObject_Item     $1D, $41, $C668, Item_Ruoginin, $FC
  AddDungeonObject_Item     $1D, $8C, $C669, Item_Searchlight, $00
  AddDungeonObject_Meseta   $1D, $CA, $C66A, 50
  AddDungeonObject_Battle   $1D, $B1, $C6CD, Enemy_MotavianPeasant, Item_Empty
  AddDungeonObject_Item     $1E, $1E, $C66B, Item_PelorieMate, $00
  AddDungeonObject_Meseta   $1E, $11, $C66C, 20
  AddDungeonObject_Dialogue $21, $94, $C511, $9B, $00 ; _room_9b_561F
  AddDungeonObject_Meseta   $22, $11, $C66D, 500
  AddDungeonObject_Dialogue $22, $24, $C512, $9D, $00 ; _room_9d_Tajim
  AddDungeonObject_Item     $22, $6E, $C66E, Item_Empty, $FC
  AddDungeonObject_Item     $22, $91, $C66F, Item_Empty, $FF
  AddDungeonObject_Item     $22, $EA, $C670, Item_Weapon_TitaniumSword, $00
  AddDungeonObject_Item     $22, $EE, $C671, Item_Empty, $FF
  AddDungeonObject_Meseta   $22, $E3, $C672, 500
  AddDungeonObject_Item     $23, $79, $C673, Item_Searchlight, $00
  AddDungeonObject_Item     $23, $91, $C674, Item_Empty, $FC
  AddDungeonObject_Item     $23, $C1, $C675, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $24, $47, $C676, 3000
  AddDungeonObject_Item     $24, $11, $C677, Item_Armour_WhiteMantle, $00
  AddDungeonObject_Item     $24, $1E, $C678, Item_Weapon_WoodCane, $00
  AddDungeonObject_Item     $24, $EE, $C679, Item_PelorieMate, $00
  AddDungeonObject_Battle   $25, $1D, $C6CE, Enemy_DragonWise, Item_CarbuncleEye
  AddDungeonObject_Meseta   $25, $86, $C67A, 100
  AddDungeonObject_Item     $25, $8A, $C67B, Item_Empty, $FC
  AddDungeonObject_Meseta   $25, $3E, $C67C, 100
  AddDungeonObject_Meseta   $26, $7B, $C67D, 5000
  AddDungeonObject_Battle   $27, $9E, $C6CF, Enemy_RedDragon, Item_Weapon_LightSaber
  AddDungeonObject_Meseta   $27, $71, $C67E, 500
  AddDungeonObject_Meseta   $28, $D1, $C67F, 500
  AddDungeonObject_Battle   $29, $67, $C6D0, Enemy_Zombie, Item_Empty
  AddDungeonObject_Battle   $29, $79, $C6D1, Enemy_Zombie, Item_Empty
  AddDungeonObject_Item     $29, $99, $C680, Item_Ruoginin, $00
  AddDungeonObject_Battle   $29, $A4, $C6D2, Enemy_Wight, Item_Empty
  AddDungeonObject_Battle   $29, $D5, $C6D3, Enemy_Zombie, Item_Empty
  AddDungeonObject_Battle   $2A, $53, $C6D4, Enemy_Zombie, Item_Empty
  AddDungeonObject_Battle   $2A, $73, $C6D5, Enemy_Zombie, Item_Empty
  AddDungeonObject_Battle   $2A, $B1, $C6D6, Enemy_Zombie, Item_Empty
  AddDungeonObject_Dialogue $2A, $DB, $C513, $A4, $00 ; _room_a4_CoronoTowerDezorian1
  AddDungeonObject_Item     $2A, $99, $C681, Item_Armour_LaconianArmor, $7F
  AddDungeonObject_Item     $2B, $79, $C682, Item_EscapeCloth, $00
  AddDungeonObject_Item     $2C, $45, $C683, Item_Empty, $FC
  AddDungeonObject_Item     $2C, $ED, $C684, Item_Ruoginin, $00
  AddDungeonObject_Meseta   $2C, $4B, $C685, 500
  AddDungeonObject_Meseta   $2D, $18, $C686, 20
  AddDungeonObject_Item     $2D, $83, $C687, Item_PelorieMate, $00
  AddDungeonObject_Item     $2D, $AD, $C688, Item_Searchlight, $00
  AddDungeonObject_Meseta   $2D, $E3, $C689, 20
  AddDungeonObject_Item     $2D, $A3, $C68A, Item_Empty, $FF
  AddDungeonObject_Item     $2F, $11, $C68B, Item_Shield_LaconianShield, $7F
  AddDungeonObject_Item     $2F, $2B, $C68C, Item_Empty, $FF
  AddDungeonObject_Item     $2F, $73, $C68D, Item_Empty, $FC
  AddDungeonObject_Meseta   $2F, $D6, $C68E, 100
  AddDungeonObject_Item     $32, $3B, $C68F, Item_Empty, $FC
  AddDungeonObject_Item     $33, $19, $C690, Item_Empty, $FF
  AddDungeonObject_Battle   $33, $D9, $C6D7, $0B, Item_Empty
  AddDungeonObject_Meseta   $34, $16, $C691, 50
  AddDungeonObject_Item     $34, $1E, $C692, Item_MagicHat, $00
  AddDungeonObject_Item     $34, $EE, $C693, Item_Shield_CeramicShield, $00
  AddDungeonObject_Dialogue $34, $C3, $C514, $A6, $00 ; _room_a6_CoronaDungeonDishonestDezorian
  AddDungeonObject_Dialogue $35, $C2, $C517, $9E, $00 ; _room_9e_ShadowWarrior
  AddDungeonObject_Battle   $3A, $79, $C6D8, Enemy_Golem, Item_Aeroprism
  AddDungeonObject_Item     $3A, $82, $C694, Item_MagicHat, $00
.db $FF

; Data from F473 to F5B8 (326 bytes)
_DATA_F473_:
.db $00 $EE $05 $27 $12 $00 $5C $FF $7F $00 $00 $1E $07 $14 $2D $00
.db $EC $00 $54 $4E $00 $6A $00 $12 $79 $00 $14 $00 $07 $74 $01 $34
.db $FF $84 $33 $01 $75 $FF $85 $33 $01 $79 $FF $81 $00 $01 $87 $FF
.db $86 $33 $01 $8C $FF $87 $33 $01 $C5 $FF $83 $33 $02 $11 $0A $51
.db $13 $02 $EE $0A $51 $21 $04 $E8 $00 $65 $22 $04 $DA $FF $89 $32
.db $06 $43 $FF $8A $32 $07 $A8 $FF $8B $32 $08 $81 $FF $8F $32 $08
.db $8C $FF $01 $00 $0B $C9 $00 $19 $69 $0F $C5 $FF $8E $32 $0F $1D
.db $FE $B0 $00 $10 $65 $FF $7C $2F $13 $3C $FF $80 $33 $14 $11 $00
.db $26 $68 $14 $DB $00 $29 $69 $14 $49 $FF $94 $33 $14 $4D $FF $95
.db $33 $14 $63 $FF $99 $17 $14 $79 $FF $A8 $3C $14 $7D $FF $97 $33
.db $14 $83 $FF $98 $33 $14 $A4 $FF $96 $1B $15 $3E $FF $92 $0F $15
.db $CC $FF $9A $32 $16 $11 $00 $30 $18 $16 $1D $FF $8C $33 $16 $EE
.db $00 $3A $1B $19 $2E $FF $8D $32 $1D $78 $FF $7E $00 $1F $CE $FC
.db $AB $00 $21 $51 $0E $18 $1D $21 $E4 $0E $23 $22 $27 $E3 $01 $79
.db $5D $27 $EC $11 $44 $54 $28 $13 $13 $15 $13 $28 $5B $15 $14 $60
.db $28 $97 $16 $24 $20 $28 $ED $14 $17 $39 $2B $76 $FF $A5 $3C $2B
.db $98 $FF $B1 $3C $2E $3D $FF $9C $3D $2F $D1 $02 $75 $23 $2F $DE
.db $02 $75 $35 $30 $1E $02 $2B $5F $30 $77 $02 $63 $17 $30 $89 $02
.db $38 $5F $30 $EE $02 $70 $20 $31 $1D $02 $38 $43 $31 $E1 $02 $3B
.db $2B $32 $49 $02 $49 $10 $32 $EB $02 $58 $11 $39 $CB $FD $9F $00

; "-1"th palette?
.db $3A $98 $FF $B2 $1D $FF

; Data from F5B9 to F618 (96 bytes)
DungeonPalettes:
.db $00 $00 $00 $00 $00 $00 $00 $00
.db $07 $0B $00 $02 $1F $03 $07 $0B
.db $18 $1C $00 $14 $2E $19 $1D $2E
.db $34 $38 $00 $20 $3C $30 $34 $38
.db $30 $34 $00 $10 $38 $10 $20 $30
.db $25 $2A $00 $10 $3F $20 $25 $2A
.db $0B $0F $00 $06 $3F $0B $0F $3F
.db $1B $1F $00 $06 $3F $17 $1B $1F
.db $02 $03 $00 $01 $07 $01 $02 $03
.db $38 $3C $00 $00 $3F $00 $00 $00
.db $38 $3C $00 $30 $3F $34 $38 $3C
.db $08 $0C $00 $04 $3F $04 $08 $0C

.struct DungeonData
  BattleProbability db
  DungeonMonsterPoolIndex db
  PaletteNumber db
  Music db
.endst
.macro AddDungeonData
.dstruct instanceof DungeonData values
  BattleProbability:       .db \1
  DungeonMonsterPoolIndex: .db \2
  PaletteNumber:           .db \3
  Music:                   .db \4
.endst
.endm
DungeonData1:
  AddDungeonData $19 $5B $03 MusicDungeon ; 0
  AddDungeonData $00 $00 $04 MusicDungeon
  AddDungeonData $00 $00 $01 MusicDungeon
  AddDungeonData $19 $56 $00 MusicTower
  AddDungeonData $19 $53 $00 MusicTower
  AddDungeonData $19 $5E $00 MusicTower
  AddDungeonData $19 $53 $00 MusicTower
  AddDungeonData $19 $55 $00 MusicTower
  AddDungeonData $19 $57 $00 MusicTower
  AddDungeonData $19 $57 $00 MusicTower
  AddDungeonData $19 $53 $00 MusicTower ; 10
  AddDungeonData $19 $56 $00 MusicTower
  AddDungeonData $19 $56 $00 MusicTower
  AddDungeonData $19 $55 $00 MusicTower
  AddDungeonData $19 $57 $00 MusicTower
  AddDungeonData $00 $00 $00 MusicTower
  AddDungeonData $19 $5C $03 MusicDungeon
  AddDungeonData $19 $5C $03 MusicDungeon
  AddDungeonData $19 $5C $03 MusicDungeon
  AddDungeonData $19 $5C $03 MusicDungeon
  AddDungeonData $00 $00 $02 MusicDungeon ; 20
  AddDungeonData $00 $00 $02 MusicDungeon
  AddDungeonData $19 $4D $03 MusicDungeon
  AddDungeonData $19 $4D $01 MusicTower
  AddDungeonData $19 $5D $01 MusicTower
  AddDungeonData $19 $5D $01 MusicTower
  AddDungeonData $19 $5E $01 MusicTower
  AddDungeonData $19 $53 $01 MusicTower
  AddDungeonData $19 $4B $06 MusicDungeon
  AddDungeonData $19 $4B $06 MusicDungeon
  AddDungeonData $19 $4B $06 MusicDungeon ; 30
  AddDungeonData $19 $54 $05 MusicFinalDungeon
  AddDungeonData $19 $58 $05 MusicFinalDungeon
  AddDungeonData $00 $00 $05 MusicFinalDungeon
  AddDungeonData $19 $52 $06 MusicDungeon
  AddDungeonData $19 $4F $06 MusicDungeon
  AddDungeonData $19 $4B $06 MusicDungeon
  AddDungeonData $19 $50 $06 MusicDungeon
  AddDungeonData $19 $50 $06 MusicDungeon
  AddDungeonData $19 $4B $06 MusicDungeon
  AddDungeonData $19 $4C $09 MusicDungeon ; 40
  AddDungeonData $19 $51 $09 MusicDungeon
  AddDungeonData $19 $51 $09 MusicDungeon
  AddDungeonData $19 $52 $07 MusicTower
  AddDungeonData $19 $4F $07 MusicTower
  AddDungeonData $19 $4F $07 MusicTower
  AddDungeonData $19 $56 $07 MusicTower
  AddDungeonData $19 $50 $08 MusicDungeon
  AddDungeonData $19 $51 $08 MusicDungeon
  AddDungeonData $19 $4F $08 MusicDungeon
  AddDungeonData $19 $5A $08 MusicDungeon ; 50
  AddDungeonData $19 $59 $08 MusicDungeon
  AddDungeonData $19 $59 $08 MusicDungeon
  AddDungeonData $19 $55 $05 MusicTower
  AddDungeonData $19 $53 $05 MusicTower
  AddDungeonData $19 $57 $05 MusicTower
  AddDungeonData $19 $57 $05 MusicTower
  AddDungeonData $19 $58 $05 MusicTower
  AddDungeonData $19 $59 $09 MusicDungeon
  AddDungeonData $19 $01 $0A MusicTower
  AddDungeonData $19 $01 $02 MusicTower ; 60


.dsb 10,$00 ; blank entry for index 0 in the following table, unnecessary?

; Data from F717 to F832 (284 bytes)
_DATA_F717_ShopItems: ; 10B per entry, indexed by RoomIndex, only up to index $1c
.struct ShopItems
  MaxIndex db ; = count - 1
  Item1 db
  Item1Price  dw
  Item2 db
  Item2Price  dw
  Item3 db
  Item3Price  dw
.endst
.macro ShopItem
.dstruct instanceof ShopItems data
  MaxIndex:   .db NARGS/2-1
  Item1:      .db \1
  Item1Price: .dw \2
  .if NARGS > 2
  Item2:      .db \3
  Item2Price: .dw \4
  .endif
  .if NARGS > 4
  Item2:      .db \5
  Item2Price: .dw \6
  .endif
.endm
  ShopItem Item_Shield_LeatherShield  30 Item_Shield_BronzeShield      520 Item_Shield_CeramicShield  1400
  ShopItem Item_Searchlight           20 Item_EscapeCloth               10 Item_TranCarpet              48
  ShopItem Item_PelorieMate           10 Item_Ruoginin                  40
  ShopItem Item_Weapon_IronSword      75 Item_Weapon_TitaniumSword     320 Item_Weapon_CeramicSword   1120
  ShopItem Item_Searchlight           20 Item_EscapeCloth               10 Item_LightPendant          1400
  ShopItem Item_PelorieMate           10 Item_Ruoginin                  40
  ShopItem Item_Armour_LeatherClothes 28 Item_Armour_LightSuit         290 Item_Armour_ZirconiaMail   1000
  ShopItem Item_Searchlight           20 Item_TranCarpet                48 Item_SecretThing            200
  .dsb 10 $00 ; no entry
  ShopItem Item_PelorieMate           10 Item_Ruoginin                  40
  ShopItem Item_Searchlight           20 Item_EscapeCloth               10 Item_Passport               100
  ShopItem Item_Weapon_ShortSword     30 Item_Armour_SpikySquirrelFur  630 Item_Armour_DiamondArmor  15000
  .dsb 10 $00 ; no entry
  ShopItem Item_Weapon_IronAxe        64 Item_Weapon_NeedleGun         400 Item_Shield_IronShield      310
  ShopItem Item_Searchlight           20 Item_TranCarpet                48 Item_LightPendant          1400
  ShopItem Item_Armour_WhiteMantle    78 Item_Weapon_HeatGun          1540 Item_Weapon_SaberClaw      1620
  ShopItem Item_Weapon_WoodCane       25 Item_Armour_IronArmor          84 Item_Shield_LaserBarrier   4800
  ShopItem Item_Searchlight           20 Item_MagicHat                  20 Item_LightPendant          1400
  ShopItem Item_PelorieMate           10 Item_Ruoginin                  40 Item_Polymeteral           1600
  ShopItem Item_PelorieMate           10 Item_Ruoginin                  40
  ShopItem Item_Weapon_HeatGun      1540 Item_Weapon_LightSaber       2980 Item_Shield_CeramicShield  1400
  ShopItem Item_Searchlight           20 Item_TranCarpet                48 Item_TelepathyBall           30
  ShopItem Item_Vehicle_LandMaster  5200
  ShopItem Item_Weapon_PsychoWand   1200 Item_Weapon_LaserGun         4120 Item_Shield_AnimalGlove    3300
  ShopItem Item_Searchlight           20 Item_MagicHat                  20 Item_TelepathyBall           30
  ShopItem Item_PelorieMate           10 Item_Ruoginin                  40
  ShopItem Item_Vehicle_IceDecker  12000
  ShopItem Item_Searchlight           20 Item_EscapeCloth               10 Item_TranCarpet              48

_DATA_F82F_ItemSellingPrices:
; 0 means you can't sell it
.dw $0000 ; Item_Empty
.dw $000C ; Item_Weapon_WoodCane
.dw $000f ; Item_Weapon_ShortSword
.dw $0025 ; Item_Weapon_IronSword
.dw $0258 ; Item_Weapon_PsychoWand
.dw $015E ; Item_Weapon_SilverTusk
.dw $0020 ; Item_Weapon_IronAxe
.dw $00A0 ; Item_Weapon_TitaniumSword
.dw $0230 ; Item_Weapon_CeramicSword
.dw $00C8 ; Item_Weapon_NeedleGun
.dw $032A ; Item_Weapon_SaberClaw
.dw $0302 ; Item_Weapon_HeatGun
.dw $05D2 ; Item_Weapon_LightSaber
.dw $080C ; Item_Weapon_LaserGun
.dw $01F4 ; Item_Weapon_LaconianSword
.dw $0186 ; Item_Weapon_LaconianAxe
.dw $000E ; Item_Armour_LeatherClothes
.dw $0027 ; Item_Armour_WhiteMantle
.dw $0091 ; Item_Armour_LightSuit
.dw $002A ; Item_Armour_IronArmor
.dw $013B ; Item_Armour_SpikySquirrelFur
.dw $01F4 ; Item_Armour_ZirconiaMail
.dw $1D4C ; Item_Armour_DiamondArmor
.dw $01EA ; Item_Armour_LaconianArmor
.dw $01A4 ; Item_Armour_FradMantle
.dw $000F ; Item_Shield_LeatherShield
.dw $009B ; Item_Shield_IronShield
.dw $0104 ; Item_Shield_BronzeShield
.dw $02BC ; Item_Shield_CeramicShield
.dw $0672 ; Item_Shield_AnimalGlove
.dw $0960 ; Item_Shield_LaserBarrier
.dw $0000 ; Item_Shield_ShieldOfPerseus
.dw $019A ; Item_Shield_LaconianShield
.dw $0000 ; Item_Vehicle_LandMaster
.dw $0000 ; Item_Vehicle_FlowMover
.dw $1770 ; Item_Vehicle_IceDecker
.dw $0005 ; Item_PelorieMate
.dw $0014 ; Item_Ruoginin
.dw $00A0 ; Item_SootheFlute
.dw $000A ; Item_Searchlight
.dw $0005 ; Item_EscapeCloth
.dw $0018 ; Item_TranCarpet
.dw $000A ; Item_MagicHat
.dw $0000 ; Item_Alsuline
.dw $0320 ; Item_Polymeteral
.dw $0000 ; Item_DungeonKey
.dw $000f ; Item_TelepathyBall
.dw $0000 ; Item_EclipseTorch
.dw $0000 ; Item_Aeroprism
.dw $0000 ; Item_LaermaBerries
.dw $0000 ; Item_Hapsby
.dw $0000 ; Item_RoadPass
.dw $0032 ; Item_Passport
.dw $0000 ; Item_Compass
.dw $008C ; Item_Shortcake
.dw $0000 ; Item_GovernorGeneralsLetter
.dw $0000 ; Item_LaconianPot
.dw $02BC ; Item_LightPendant
.dw $0000 ; Item_CarbuncleEye
.dw $01F4 ; Item_GasClear
.dw $0000 ; Item_DamoasCrystal
.dw $0000 ; Item_MasterSystem
.dw $0000 ; Item_MiracleKey
.dw $0000 ; Item_Zillion


.orga $b8a7
.section "Character level stats" overwrite
LevelStats:
;    ,,------------------------------ Max HP
;    ||  ,,-------------------------- Attack boost
;    ||  ||  ,,---------------------- Defence boost
;    ||  ||  ||  ,,------------------ Max MP
;    ||  ||  ||  ||  ,,--,,---------- Experience threshold for level
;    ||  ||  ||  ||  ||  ||  ,,------ Magics known
;    ||  ||  ||  ||  ||  ||  ||  ,,-- Battle magics known
.db 0,0,0,0,0,0,0,0
LevelStatsAlis:
.db $10,$08,$08,$00,$00,$00,$00,$00
.db $14,$0a,$0b,$00,$14,$00,$00,$00
.db $19,$0c,$0f,$00,$32,$00,$00,$00
.db $22,$0e,$14,$04,$64,$00,$01,$01
.db $2d,$0f,$18,$06,$e6,$00,$02,$01
.db $36,$12,$1b,$08,$4a,$01,$03,$01
.db $42,$15,$1e,$0a,$c2,$01,$03,$01
.db $4c,$17,$21,$0c,$58,$02,$03,$01
.db $51,$18,$28,$0d,$20,$03,$03,$01
.db $5d,$19,$33,$0e,$1a,$04,$03,$01
.db $63,$1b,$3c,$0f,$14,$05,$03,$01
.db $6f,$1e,$40,$10,$a4,$06,$04,$01
.db $7b,$1f,$44,$12,$98,$08,$04,$01
.db $84,$22,$4b,$14,$f0,$0a,$05,$01
.db $8c,$24,$50,$16,$ac,$0d,$05,$01
.db $99,$26,$55,$16,$04,$10,$05,$02
.db $9f,$28,$5a,$18,$88,$13,$05,$02
.db $a6,$29,$60,$18,$70,$17,$05,$02
.db $ad,$2b,$64,$19,$20,$1c,$05,$02
.db $b6,$2c,$6b,$19,$34,$21,$05,$02
.db $bb,$2e,$6e,$1a,$10,$27,$05,$02
.db $c0,$30,$70,$1a,$e0,$2e,$05,$02
.db $c8,$31,$71,$1b,$a4,$38,$05,$02
.db $cc,$32,$72,$1c,$5c,$44,$05,$02
.db $d0,$33,$73,$1d,$d8,$59,$05,$02
.db $d2,$34,$77,$1d,$30,$75,$05,$02
.db $d4,$35,$75,$1e,$70,$94,$05,$02
.db $d6,$36,$76,$1e,$c8,$af,$05,$02
.db $d8,$37,$77,$20,$20,$cb,$05,$02
.db $da,$38,$78,$20,$18,$f6,$05,$02
LevelStatsMyau:
.db $16,$12,$16,$00,$00,$00,$00,$00
.db $1e,$15,$1a,$00,$32,$00,$00,$00
.db $26,$19,$1f,$00,$78,$00,$00,$00
.db $2a,$1c,$22,$00,$dc,$00,$00,$00
.db $2c,$1f,$26,$00,$5e,$01,$00,$00
.db $36,$23,$29,$0c,$a8,$02,$01,$01
.db $3c,$27,$2d,$0f,$b6,$03,$01,$01
.db $40,$2a,$35,$11,$7e,$04,$01,$01
.db $46,$2d,$37,$13,$78,$05,$02,$01
.db $4e,$30,$3c,$15,$a4,$06,$02,$01
.db $54,$32,$3f,$16,$34,$08,$02,$01
.db $5a,$33,$44,$17,$28,$0a,$03,$01
.db $74,$34,$47,$19,$80,$0c,$03,$01
.db $76,$38,$4a,$1b,$3c,$0f,$03,$01
.db $79,$3b,$50,$1e,$94,$11,$03,$02
.db $84,$3d,$55,$22,$50,$14,$03,$02
.db $8e,$3f,$59,$24,$d4,$17,$03,$03
.db $96,$43,$5f,$26,$58,$1b,$03,$03
.db $9b,$46,$64,$28,$08,$20,$03,$03
.db $a2,$49,$66,$2c,$1c,$25,$04,$03
.db $af,$4c,$68,$2e,$04,$29,$04,$03
.db $b7,$4d,$6a,$2f,$c8,$32,$04,$03
.db $c1,$4f,$6c,$30,$98,$3a,$04,$03
.db $ca,$50,$70,$31,$50,$46,$04,$03
.db $d0,$51,$71,$32,$f0,$55,$04,$03
.db $d2,$52,$72,$33,$30,$75,$04,$03
.db $d3,$53,$73,$34,$a0,$8c,$04,$03
.db $d4,$54,$74,$35,$10,$a4,$04,$03
.db $d5,$55,$75,$36,$50,$c3,$04,$03
.db $d6,$24,$76,$37,$60,$ea,$04,$03 ; Bug in attack stat here
LevelStatsOdin:
.db $2a,$0d,$0d,$00,$00,$00,$00,$00
.db $2f,$0f,$0f,$00,$50,$00,$00,$00
.db $34,$11,$11,$00,$a0,$00,$00,$00
.db $39,$12,$13,$00,$fa,$00,$00,$00
.db $3c,$13,$15,$00,$5e,$01,$00,$00
.db $3f,$14,$17,$00,$e0,$01,$00,$00
.db $43,$15,$19,$00,$76,$02,$00,$00
.db $4b,$17,$1b,$00,$52,$03,$00,$00
.db $52,$18,$1d,$00,$4c,$04,$00,$00
.db $5e,$19,$1f,$00,$78,$05,$00,$00
.db $64,$1a,$22,$00,$08,$07,$00,$00
.db $6b,$1b,$25,$00,$fc,$08,$00,$00
.db $74,$1c,$28,$00,$b8,$0b,$00,$00
.db $81,$1e,$2b,$00,$d8,$0e,$00,$00
.db $83,$1f,$2d,$00,$04,$10,$00,$00
.db $87,$20,$2f,$00,$88,$13,$00,$00
.db $8c,$21,$31,$00,$70,$17,$00,$00
.db $93,$23,$35,$00,$e8,$1c,$00,$00
.db $96,$24,$38,$00,$28,$23,$00,$00
.db $9c,$25,$3d,$00,$04,$29,$00,$00
.db $a2,$26,$41,$00,$e0,$2e,$00,$00
.db $a9,$27,$42,$00,$bc,$34,$00,$00
.db $af,$28,$43,$00,$8c,$3c,$00,$00
.db $b3,$29,$44,$00,$5c,$44,$00,$00
.db $bb,$2a,$45,$00,$20,$4e,$00,$00
.db $bc,$2b,$46,$00,$60,$6d,$00,$00
.db $bd,$2c,$47,$00,$b8,$88,$00,$00
.db $be,$2d,$48,$00,$28,$a0,$00,$00
.db $bf,$2e,$49,$00,$50,$c3,$00,$00
.db $c0,$2f,$4a,$00,$60,$ea,$00,$00
LevelStatsLutz:
.db $2d,$12,$1e,$0c,$00,$00,$01,$01
.db $31,$16,$24,$12,$46,$00,$01,$01
.db $36,$17,$29,$16,$96,$00,$01,$01
.db $39,$1a,$2f,$19,$fa,$00,$01,$01
.db $3d,$1d,$35,$1c,$7c,$01,$01,$01
.db $41,$1e,$3c,$20,$08,$02,$01,$02
.db $47,$20,$41,$24,$bc,$02,$01,$02
.db $4f,$22,$47,$24,$20,$03,$02,$03
.db $53,$24,$4b,$29,$84,$03,$02,$03
.db $59,$26,$52,$2b,$4c,$04,$02,$03
.db $5f,$28,$55,$2e,$78,$05,$02,$03
.db $65,$29,$58,$30,$6c,$07,$03,$03
.db $6b,$2b,$5c,$31,$c4,$09,$03,$03
.db $70,$2d,$60,$32,$e4,$0c,$04,$03
.db $76,$2f,$63,$34,$68,$10,$04,$03
.db $7c,$30,$64,$36,$b4,$14,$04,$03
.db $83,$32,$67,$3a,$64,$19,$04,$04
.db $89,$35,$6a,$3e,$60,$22,$05,$04
.db $8f,$39,$6c,$42,$10,$27,$05,$04
.db $9b,$3c,$6e,$46,$e0,$2e,$05,$05
.db $a1,$3e,$70,$48,$b0,$36,$05,$05
.db $a8,$40,$73,$4b,$b8,$3d,$05,$05
.db $ac,$42,$74,$4c,$50,$46,$05,$05
.db $ba,$44,$75,$4d,$2c,$4c,$05,$05
.db $be,$46,$76,$4e,$08,$52,$05,$05
.db $bf,$47,$77,$4f,$a8,$61,$05,$05
.db $c0,$48,$78,$50,$30,$75,$05,$05
.db $c1,$49,$79,$51,$70,$94,$05,$05
.db $c2,$4a,$7a,$52,$c8,$af,$05,$05
.db $c3,$4b,$7b,$53,$50,$c3,$05,$05
.ends
; followed by
.orga $bc6f
.section "Unknown data 2" overwrite
; Data from FC6F to FE1C (430 bytes)
_DATA_FC6F_:
.db $12 $12 $12 $12 $12 $12 $12 $22 $22 $12 $8A $8A $8A $8A $22 $13
.db $13 $13 $13 $13 $13 $13 $13
.dsb 10,$52
.db $12 $12 $12 $12 $B2 $52 $9A $9A $9A $9A
.dsb 10,$13
.db $1A $13 $40 $40 $40 $40 $41 $41 $41 $41 $41 $41 $41 $41 $31 $31
.db $52 $52 $52 $52
.dsb 9,$32
.dsb 9,$1A
.db $12 $12 $22 $26 $74 $74 $74 $74 $74 $13 $13 $13 $13 $13 $13 $53
.db $53 $5A $5A $63 $63 $6A $6A $13 $13 $13 $13 $9A $9A $9A $9A $1A
.db $1A $1A $1A $1A $1A $1A $1A
.dsb 56,$12
.db $13 $13 $13 $13 $13 $13 $13 $13 $62 $56 $56 $56 $56 $B6 $12 $12
.db $12 $12 $12 $12 $B6 $B6 $B6 $B6 $43 $42 $42 $42 $42 $66 $63 $63
.db $63 $63 $63 $63 $63 $63 $12 $12 $12 $12 $12 $12 $12 $12 $1A $1A
.db $1A $1A $12 $12 $12 $62 $C2 $12 $43 $43 $43 $43 $6A
.dsb 9,$10
.db $82 $82
.dsb 10,$83
.db $8A $8A $83 $83 $8A $8A $83 $83 $8A $8A $83 $83 $8A $8A $83 $83
.db $8A $8A $83 $83 $8A $8A
.dsb 9,$83
.db $82 $82
.dsb 25,$83
.db $8A $83 $8A $82 $82 $82 $A4 $A3 $A3 $A3 $A3 $A3 $A3 $AA $AA $AA
.db $AA $A2 $A2 $A2 $A2 $12 $A3 $A2 $AA $A2 $83 $83 $8A $8A $83 $8A
.db $83
.dsb 16,$93
.db $92 $93 $93 $9A $9A $93 $93 $9A $9A $93 $93 $9A $9A $93 $93 $9A
.db $9A $93 $93 $9A $9A $93 $9A $93 $9A $93 $9A $A2 $A3 $A2 $AA $83
.db $83 $83 $83 $1A $1A $1A $1A $83 $83 $83 $83 $83 $8A $8A $83 $83
.db $A2 $A2 $A2 $92 $92 $92 $16
; followed by
; Data from FE1D to FE21 (5 bytes)
_DATA_FE1D_:
.db $0C $08 $04 $03 $0B ; Green darkening fade, red, orange
; followed by
; Data from FE22 to FE51 (48 bytes)
_DATA_FE22_: ; $fe22 Palette cycle for two colours - blue-green-yellow-red-purple-blue and blue-cyan-blue
.db $34 $38 $35 $3C $38 $3E $3C $3E $3D $3E $2C $3E $1E $3E $0C $3E
.db $0E $3E $0F $3E $1B $3E $0B $3E $07 $3E $27 $3E $37 $3E $3B $3E
.db $3A $3E $36 $3E $35 $3E $34 $3E $38 $3E $35 $3C $34 $38 $30 $2A

; Data from FE52 to FE9F (78 bytes)
_DATA_FE52_: ; $fe52 Palette fade - blue-white-various
.db $34 $34 $34 $34 $34 $34 $35 $35 $35 $35 $35 $35
.dsb 10,$38
.db $3C $38 $38 $3C $38 $3C $3E $38 $38 $3E $3C $3E $3F $38 $3C $3F
.db $3E $3F $3F $3C $3E $3F $3F $3F $3F $3E $3F $3F $3F $3F $3F $3F
.db $2F $3F $2F $3F $3F $3D $1F $2F $0F $2F $3F $2C $1A $0F $0B $1F
.db $2F $2C $15 $0B $06 $1A $2F $28

; Data from FEA0 to FEB1 (18 bytes)
_DATA_FEA0_: ; $fea0 Palette cycle for two colours - blue-cyan-white-cyan-blue and grey + cyan-white-cyan
.db $30 $2A $34 $38 $38 $3E $3C $3E $3E $3F $3F $3F $3E $3F $3C $3E
.db $38 $3E
.ends
; followed by
.orga $beb2            ; $feb2
.section "Hapsby travel menu" overwrite
; raw tilemap data
; Data from FEB2 to FF01 (80 bytes)
_DATA_FEB2_:
; TODO stringmap like menus.yml
.dw $11f1,$11f2,$11f2,$11f2,$13f1
.dw $11f3,$10fd,$10c0,$10c0,$13f3
.dw $11f3,$10d0,$10d6,$10d4,$13f3
.dw $11f3,$10c0,$10c0,$10fd,$13f3
.dw $11f3,$10cd,$10ff,$10d9,$13f3
.dw $11f3,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10d7,$10d2,$10f4,$13f3
.dw $15f1,$15f2,$15f2,$15f2,$17f1
; Dimensions $080a ; 5x8
.ends
.orga $bf02            ; $ff02
.section "Intro box 1" overwrite
; raw tilemap data
IntroBox1: ; Spring, AW 342
; Camineet Residential District on the planet Palma
; Data from FF02 to FF97 (150 bytes)
.dw $11f1,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$11f2,$13f1
.dw $11f3,$10b8,$10b9,$10c0,$10c4,$10c5,$10c3,$10ba,$10c0,$10bb,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10fe,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$10c0,$13f3
.dw $11f3,$10e4,$10f3,$10e9,$10bc,$10c0,$10d0,$10ea,$10e0,$10ff,$10de,$10bd,$10be,$10bf,$13f3
.dw $15f1,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$15f2,$17f1
.define IntroBox1Dimensions $051e ; 30x5
.ends
; followed by
.orga $bf98
.section "More unknown data" overwrite
; Data from FF98 to FFFF (104 bytes)
_DATA_FF98_:
.db $01 $01 $01 $0F $08 $01 $01 $01 $0F $04 $01 $01 $08 $01 $0F $04
.db $04 $01 $08 $01 $01 $0F $04 $01 $01 $08 $01 $0F $02 $02 $00 $08
.db $01 $01 $0F $04 $01 $01 $01 $01 $02 $04 $0F $02 $02 $02 $08 $01
.db $01 $01 $01 $04 $0F $08 $08 $0F $08 $01 $01 $08 $01 $01 $01 $01
.db $01 $01 $01 $08 $02 $02 $04 $0F $04 $01 $01 $00 $0F $04 $04 $01
.db $01 $08 $01 $0F $02 $02 $02 $02 $08 $0F $02 $04 $04 $01 $01 $01
.db $08 $01 $01 $01 $01 $0F $FF $FF
.ends

;=======================================================================================================
; Bank 4: $10000 - $13fff
;=======================================================================================================
.bank 4 slot 2
.ORG $0000

.db $0E $00 $00 $00 $81 $13 $00 $00 $04 $00 $00 $00 $81 $01 $00 $00
.db $02 $00 $00 $00 $81 $FF $00 $00 $04 $00 $00 $00 $81 $6F $00 $00
.db $02 $00 $00 $00 $81 $FF $00 $00 $04 $00 $00 $00 $81 $FF $00 $00
.db $02 $00 $00 $00 $81 $FF $00 $00 $04 $00 $00 $00 $81 $FF $00 $00
.db $02 $00 $00 $00 $83 $FF $00 $00 $BF $00 $00 $00 $03 $00 $02 $00
.db $00 $00 $81 $FF $00 $00 $02 $00 $00 $00 $02 $FF $00 $00 $85 $69
.db $96 $7F $1F $60 $1F $03 $1C $03 $FC $03 $00 $00 $00 $00 $03 $FF
.db $00 $00 $81 $00 $FF $FF $02 $FF $00 $FF $86 $00 $FF $FF $1F $E0
.db $1F $E0 $1F $03 $FC $03 $00 $FF $00 $00 $00 $FF $FF $02 $FF $00
.db $FF $82 $00 $FF $FF $FF $00 $FF $02 $00 $FF $FF $82 $00 $FF $1F
.db $00 $FF $FF $02 $FF $00 $FF $82 $00 $FF $FF $FF $00 $FF $03 $00
.db $FF $FF $06 $00 $00 $00 $82 $C0 $00 $00 $3E $C0 $00 $06 $00 $00
.db $00 $82 $01 $00 $00 $07 $00 $00 $02 $00 $00 $00 $8A $17 $00 $00
.db $00 $00 $00 $BF $00 $00 $17 $00 $00 $FF $00 $00 $BF $00 $00 $2F
.db $00 $00 $00 $00 $00 $FF $00 $00 $0B $00 $00 $05 $FF $00 $00 $81
.db $01 $00 $00 $07 $FF $00 $00 $81 $2F $00 $00 $0E $FF $00 $00 $82
.db $E0 $1F $03 $FC $03 $00 $06 $FE $01 $00 $02 $00 $FF $FF $83 $00
.db $FF $1F $60 $1F $87 $78 $07 $80 $03 $7F $00 $80 $05 $00 $FF $FF
.db $85 $00 $FF $1F $E0 $1F $07 $F8 $07 $00 $01 $3E $00 $00 $01 $00
.db $06 $00 $00 $00 $84 $E0 $00 $00 $1E $E0 $00 $01 $1E $00 $00 $01
.db $00 $02 $00 $00 $00 $89 $01 $00 $00 $05 $00 $00 $17 $00 $00 $37
.db $00 $00 $4F $00 $B0 $08 $F0 $07 $B0 $0F $00 $FF $00 $00 $BF $00
.db $00 $05 $FF $00 $00 $83 $0F $00 $F0 $00 $F0 $0F $F0 $0F $00 $06
.db $FF $00 $00 $83 $7F $00 $80 $07 $80 $78 $80 $78 $07 $07 $FF $00
.db $00 $81 $7F $00 $80 $08 $FE $01 $00 $08 $7F $00 $80 $81 $01 $00
.db $00 $03 $05 $00 $00 $82 $15 $00 $00 $07 $00 $00 $02 $17 $00 $00
.db $81 $F8 $07 $00 $07 $FF $00 $00 $83 $03 $80 $7C $80 $7C $03 $9C
.db $43 $20 $05 $9F $40 $20 $85 $FF $00 $00 $3F $00 $C0 $01 $C0 $3E
.db $C0 $3E $01 $FE $01 $00 $06 $FF $00 $00 $84 $1F $00 $E0 $01 $E0
.db $1E $E0 $1E $01 $FE $01 $00 $06 $FF $00 $00 $83 $0F $00 $F0 $00
.db $F0 $0F $F0 $0F $00 $07 $FF $00 $00 $81 $0F $00 $F0 $02 $17 $00
.db $00 $83 $57 $00 $00 $1F $00 $00 $57 $00 $00 $03 $5F $00 $00 $08
.db $9F $40 $20 $82 $00 $F0 $0F $F0 $0F $00 $06 $FF $00 $00 $84 $7F
.db $00 $80 $07 $80 $78 $80 $78 $07 $F8 $07 $00 $06 $FF $00 $00 $84
.db $7F $00 $80 $03 $80 $7C $80 $7C $03 $FC $03 $00 $06 $FF $00 $00
.db $84 $3F $00 $C0 $03 $C0 $3C $C0 $3C $03 $FC $03 $00 $06 $FE $01
.db $00 $85 $1E $01 $E0 $00 $E1 $1E $00 $00 $00 $01 $00 $00 $00 $00
.db $00 $05 $01 $00 $00 $07 $5F $00 $00 $83 $7F $00 $00 $E0 $1F $00
.db $FE $01 $00 $06 $FF $00 $00 $83 $1F $00 $E0 $00 $E0 $1F $E0 $1F
.db $00 $07 $FF $00 $00 $83 $0F $00 $F0 $00 $F0 $0F $F0 $0F $00 $03
.db $FF $00 $00 $82 $05 $00 $00 $01 $00 $00 $06 $05 $00 $00 $81 $5F
.db $00 $00 $06 $7F $00 $00 $81 $FF $00 $00 $06 $05 $00 $00 $83 $F9
.db $00 $04 $02 $FC $01 $7F $00 $00 $06 $FF $00 $00 $81 $00 $00 $FF
.db $07 $FF $00 $00 $82 $1F $00 $E0 $04 $03 $00 $07 $05 $00 $00 $81
.db $00 $FF $00 $07 $FF $00 $00 $82 $00 $E0 $1F $E0 $1F $00 $06 $FF
.db $00 $00 $83 $01 $00 $FE $00 $FE $01 $FE $01 $00 $06 $FF $00 $00
.db $82 $00 $00 $FF $00 $FF $00 $05 $FF $00 $00 $84 $9F $40 $20 $0F
.db $40 $B0 $00 $F0 $0F $F0 $0F $00 $06 $FF $00 $00 $82 $00 $00 $FF
.db $00 $FF $00 $06 $FF $00 $00 $83 $7F $00 $80 $00 $80 $7F $80 $7F
.db $00 $06 $FF $00 $00 $83 $03 $00 $FC $00 $FC $03 $FC $03 $00 $06
.db $FF $00 $00 $82 $00 $00 $FF $00 $FF $00 $06 $FF $00 $00 $83 $3F
.db $00 $C0 $00 $C0 $3F $C0 $3F $00 $06 $FF $00 $00 $83 $01 $00 $FE
.db $00 $FE $01 $FE $01 $00 $06 $FF $00 $00 $82 $00 $00 $FF $00 $FF
.db $00 $06 $FF $00 $00 $82 $0F $00 $F0 $00 $F0 $0F $07 $FF $00 $00
.db $84 $00 $00 $FF $05 $00 $00 $07 $00 $00 $05 $00 $00 $04 $07 $00
.db $00 $82 $27 $00 $00 $F0 $0F $00 $07 $FE $01 $00 $81 $00 $FF $00
.db $07 $7F $00 $80 $82 $00 $80 $7F $80 $7F $00 $06 $FF $00 $00 $08
.db $27 $00 $00 $81 $97 $68 $FF $02 $FF $00 $FF $82 $00 $FF $FF $FF
.db $00 $FF $03 $00 $FF $FF $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF
.db $00 $FF $02 $00 $FF $FF $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF
.db $00 $FF $82 $00 $FF $FF $02 $FD $FE $03 $FF $00 $FF $89 $00 $FF
.db $FC $F0 $0F $F3 $E3 $1C $EF $10 $FF $9F $1F $E0 $7F $E3 $1C $E7
.db $C7 $38 $DF $1F $E0 $3F $C9 $F6 $FF $02 $FF $00 $FF $81 $00 $FF
.db $FF $04 $FF $00 $FF $81 $7F $80 $FF $02 $FF $00 $FF $81 $00 $FF
.db $FF $07 $FF $00 $FF $81 $37 $C8 $FF $09 $FF $00 $FF $0C $00 $FF
.db $FF $89 $00 $FF $FC $03 $FF $FB $04 $FF $E7 $18 $FF $9F $01 $FF
.db $F9 $06 $FF $F7 $08 $FF $CF $30 $FF $3F $C0 $FF $FF $04 $00 $FF
.db $FF $81 $0B $F4 $FF $07 $00 $FF $FF $81 $7F $80 $FF $06 $00 $FF
.db $FF $84 $0B $F4 $FF $FF $00 $FF $00 $FF $FF $2F $D0 $FF $04 $00
.db $FF $FF $02 $FF $00 $FF $86 $17 $E8 $FF $FF $00 $FF $02 $FD $FF
.db $17 $E8 $FF $00 $FF $FF $02 $FD $FF $06 $FF $00 $FF $85 $7F $80
.db $FF $9F $60 $FF $00 $FF $3F $C0 $3F $07 $F8 $07 $00 $05 $FF $00
.db $00 $03 $00 $FF $FF $85 $00 $FF $3F $C0 $3F $07 $F8 $07 $01 $FE
.db $01 $00 $FF $00 $00 $06 $00 $FF $FF $82 $00 $FF $3F $C0 $3F $07
.db $05 $00 $FF $FF $89 $00 $FF $FE $01 $FF $F9 $06 $FF $E7 $00 $FF
.db $FE $01 $FF $FD $02 $FF $F3 $0C $FF $CF $30 $FF $3F $C0 $FF $FF
.db $02 $00 $FF $FF $82 $60 $FF $7F $80 $FF $FF $06 $00 $FF $FF $88
.db $17 $E8 $FF $13 $EC $FF $02 $FD $FF $13 $EC $FF $02 $FD $FF $00
.db $FF $FF $02 $FD $FF $00 $FF $FF $06 $FF $00 $FF $84 $7F $80 $FF
.db $5F $A0 $FF $F8 $07 $01 $FE $01 $00 $06 $FF $00 $00 $85 $18 $FF
.db $9F $20 $FF $3F $C0 $3F $0F $F0 $0F $01 $FE $01 $00 $03 $FF $00
.db $00 $04 $00 $FF $FF $84 $00 $FF $3F $C0 $3F $0F $F0 $0F $01 $FE
.db $01 $00 $07 $00 $FF $FF $82 $00 $FF $3F $7F $80 $FF $03 $5F $A0
.db $FF $82 $57 $A8 $FF $1F $E0 $FF $02 $17 $E8 $FF $83 $C0 $3F $0F
.db $F0 $0F $01 $FE $01 $00 $05 $FF $00 $00 $02 $00 $FF $FF $84 $00
.db $FF $3F $C0 $3F $0F $F0 $0F $01 $F2 $09 $04 $02 $F3 $08 $04 $05
.db $00 $FF $FF $83 $00 $FF $3F $C0 $3F $0F $F0 $0F $01 $04 $17 $E8
.db $FF $81 $15 $EA $FF $02 $05 $FA $FF $81 $01 $FE $FF $03 $FF $00
.db $00 $84 $7F $00 $80 $07 $80 $78 $80 $78 $07 $F8 $07 $00 $06 $FF
.db $00 $00 $83 $7F $00 $80 $03 $80 $7C $80 $7C $03 $07 $FF $00 $00
.db $81 $3F $00 $C0 $08 $F3 $08 $04 $81 $FE $01 $00 $07 $FF $00 $00
.db $84 $00 $FF $3F $C0 $3F $0F $F0 $0F $01 $FE $01 $00 $04 $FF $00
.db $00 $03 $00 $FF $FF $85 $00 $FF $3F $C0 $3F $0F $F0 $0F $01 $FE
.db $01 $00 $FF $00 $00 $06 $00 $FF $FF $82 $00 $FF $3F $C0 $3F $0F
.db $07 $05 $FA $FF $84 $01 $FE $FF $FF $00 $FF $7F $80 $FF $FF $00
.db $FF $03 $7F $80 $FF $83 $70 $8F $F0 $00 $FF $0F $FC $03 $00 $07
.db $FF $00 $00 $83 $03 $C0 $3C $C0 $3C $03 $FC $03 $00 $06 $FF $00
.db $00 $84 $1F $00 $E0 $01 $E0 $1E $20 $9E $41 $3E $81 $40 $03 $3F
.db $80 $40 $03 $FF $00 $00 $83 $1F $00 $E0 $00 $E0 $1F $E0 $1F $00
.db $02 $FF $00 $00 $06 $F3 $08 $04 $84 $73 $08 $84 $03 $88 $74 $F0
.db $0F $01 $FC $03 $00 $06 $FC $02 $01 $85 $00 $FF $FF $00 $FF $3F
.db $C0 $3F $0F $F0 $0F $01 $FE $01 $00 $03 $FF $00 $00 $04 $00 $FF
.db $FF $84 $00 $FF $3C $C3 $3F $03 $F0 $0F $01 $FE $01 $00 $02 $00
.db $FF $FF $8A $00 $FF $F8 $07 $FF $C7 $38 $FF $3F $C0 $FF $FF $00
.db $FF $FF $00 $FF $7F $00 $FF $F8 $06 $FF $87 $79 $FE $7F $81 $FE
.db $FF $03 $01 $FE $FF $83 $00 $FF $FF $AF $F0 $FF $7F $80 $FF $06
.db $5F $A0 $FF $08 $3F $80 $40 $82 $80 $78 $07 $F8 $07 $00 $06 $FF
.db $00 $00 $84 $7F $00 $80 $03 $80 $7C $80 $7C $03 $FC $03 $00 $06
.db $FF $00 $00 $83 $3F $00 $C0 $01 $C0 $3E $C0 $3E $01 $03 $FE $01
.db $00 $04 $FF $00 $00 $84 $1F $00 $E0 $01 $E0 $1E $60 $1E $81 $7E
.db $01 $80 $06 $FC $02 $01 $85 $0C $02 $F1 $00 $F2 $0D $80 $7F $0F
.db $E0 $1F $01 $E6 $11 $08 $05 $E7 $10 $08 $86 $01 $FE $FF $00 $FF
.db $FF $00 $FF $7F $80 $7F $0F $F0 $0F $01 $FE $01 $00 $02 $FF $00
.db $00 $05 $5F $A0 $FF $84 $5B $A4 $7F $8F $70 $0F $A1 $4E $01 $F0
.db $0F $00 $07 $FF $00 $00 $83 $07 $00 $F8 $00 $F8 $07 $F8 $07 $00
.db $06 $FF $00 $00 $84 $7F $00 $80 $07 $80 $78 $80 $78 $07 $C8 $27
.db $10 $03 $CF $20 $10 $03 $E7 $10 $08 $84 $27 $10 $C8 $03 $D0 $2C
.db $C0 $3C $03 $FC $03 $00 $06 $FF $00 $00 $84 $1F $00 $E0 $01 $E0
.db $1E $E0 $1E $01 $A0 $41 $00 $06 $A4 $40 $00 $85 $24 $40 $80 $FF
.db $00 $00 $3F $00 $C0 $00 $C0 $3F $C0 $3F $00 $04 $FF $00 $00 $02
.db $3F $80 $40 $83 $01 $80 $7E $00 $FE $01 $FE $01 $00 $06 $FF $00
.db $00 $82 $00 $00 $FF $00 $FF $00 $06 $FF $00 $00 $83 $0F $00 $F0
.db $00 $F0 $0F $F0 $0F $00 $06 $FF $00 $00 $82 $00 $00 $FF $00 $FF
.db $00 $02 $F3 $08 $04 $04 $FF $00 $00 $84 $7F $00 $80 $00 $80 $7F
.db $80 $7F $00 $FF $00 $00 $05 $FE $01 $00 $83 $06 $01 $F8 $00 $F9
.db $06 $F8 $07 $00 $06 $7F $00 $80 $82 $00 $00 $FF $00 $FF $00 $06
.db $FF $00 $00 $82 $3F $00 $C0 $00 $C0 $3F $07 $FF $00 $00 $81 $01
.db $00 $FE $08 $CF $20 $10 $81 $E6 $11 $08 $07 $E7 $10 $08 $83 $04
.db $E0 $00 $E0 $1F $00 $A4 $01 $00 $05 $E4 $01 $00 $81 $C0 $3F $00
.db $07 $FC $02 $01 $82 $00 $FE $01 $FE $01 $00 $06 $FF $00 $00 $82
.db $00 $20 $DF $00 $FF $00 $06 $FF $00 $00 $83 $0F $00 $F0 $00 $F0
.db $0F $E0 $1F $00 $06 $E7 $10 $08 $82 $01 $10 $EE $00 $FF $00 $05
.db $FF $00 $00 $02 $E4 $01 $00 $82 $64 $81 $00 $80 $7F $00 $04 $A4
.db $40 $00 $05 $00 $00 $00 $83 $00 $03 $00 $03 $0C $03 $0F $70 $0F
.db $02 $00 $00 $00 $84 $00 $03 $00 $03 $1C $03 $1F $60 $1F $7F $80
.db $7F $02 $FF $00 $FF $83 $03 $1C $03 $1F $60 $1F $7F $80 $7F $05
.db $FF $00 $FF $06 $00 $00 $00 $82 $00 $01 $00 $01 $0E $01 $03 $00
.db $00 $00 $89 $00 $03 $00 $03 $0C $03 $0F $70 $0F $7F $80 $7F $FF
.db $00 $FF $00 $03 $00 $03 $0C $03 $0F $70 $0F $7F $80 $7F $04 $FF
.db $00 $FF $81 $7F $80 $7F $07 $FF $00 $FF $82 $F8 $07 $F9 $FE $01
.db $FE $06 $FF $00 $FF $86 $7F $80 $FF $3F $C0 $7F $8F $70 $BF $C3
.db $3C $CF $F0 $0F $F3 $FC $03 $FC $07 $FF $00 $FF $86 $7F $80 $FF
.db $1F $E0 $7F $87 $78 $9F $E1 $1E $E7 $F8 $07 $F9 $FE $01 $FE $07
.db $FF $00 $FF $86 $3F $C0 $FF $0F $F0 $3F $C7 $38 $CF $F1 $0E $F7
.db $F8 $07 $F9 $FE $01 $FE

.org $10906-$10000
.section "Tilemap data 1 - dungeon" overwrite
.incbin "Tilemaps\10906tilemap.dat"
_DATA_10B0F_:
.incbin "Tilemaps\10B0Ftilemap.dat"
.incbin "Tilemaps\10ED4tilemap.dat"
.incbin "Tilemaps\112A4tilemap.dat"
.incbin "Tilemaps\11673tilemap.dat"
.incbin "Tilemaps\11A34tilemap.dat"
.incbin "Tilemaps\11E02tilemap.dat"
.incbin "Tilemaps\121D3tilemap.dat"
.incbin "Tilemaps\12535tilemap.dat"
.incbin "Tilemaps\12880tilemap.dat"
.incbin "Tilemaps\12BA6tilemap.dat"
.incbin "Tilemaps\12F5Btilemap.dat"
.incbin "Tilemaps\1333Dtilemap.dat"
.incbin "Tilemaps\1376Ctilemap.dat"
.incbin "Tilemaps\13BBEtilemap.dat"
.ends
; Fits exactly

;=======================================================================================================
; Bank 5: $14000 - $17fff
;=======================================================================================================
.bank 5 slot 2
.ORG $0000

.section "Tilemap data 1 - dungeon - continued" overwrite
.incbin "Tilemaps\14000tilemap.dat"
.incbin "Tilemaps\14367tilemap.dat"
.incbin "Tilemaps\14695tilemap.dat"
.incbin "Tilemaps\1497Atilemap.dat"
.incbin "Tilemaps\14C62tilemap.dat"
.incbin "Tilemaps\14F18tilemap.dat"
.incbin "Tilemaps\1518Ftilemap.dat"
.incbin "Tilemaps\153C6tilemap.dat"
.incbin "Tilemaps\1572Etilemap.dat"
.incbin "Tilemaps\15AADtilemap.dat"
.incbin "Tilemaps\15E7Etilemap.dat"
.incbin "Tilemaps\16248tilemap.dat"
.incbin "Tilemaps\16612tilemap.dat"
.ends

.org $16a27-$14000
.db $0E $00 $00 $00 $82 $13 $00 $00 $00 $00 $00 $06 $00 $01 $00 $86
.db $FE $01 $00 $00 $01 $00 $8F $10 $0F $83 $0C $03 $80 $03 $00 $EF
.db $00 $00 $02 $80 $00 $00 $82 $7F $00 $80 $80 $00 $00 $03 $FF $00
.db $FF $85 $00 $FF $3F $1F $20 $1F $07 $18 $07 $F8 $07 $01 $00 $01
.db $00 $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF $00 $FF $82 $00 $FF
.db $FF $40 $BF $7F $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF $00 $FF
.db $02 $00 $FF $FF $81 $E9 $16 $FF $02 $FF $00 $FF $82 $00 $FF $FF
.db $FF $00 $FF $04 $00 $FF $FF $02 $FF $00 $FF $82 $00 $FF $FF $FF
.db $00 $FF $03 $00 $FF $FF $06 $00 $00 $00 $82 $C0 $00 $00 $38 $C0
.db $00 $06 $00 $00 $00 $82 $01 $00 $00 $07 $00 $00 $02 $00 $00 $00
.db $8A $17 $00 $00 $00 $00 $00 $BF $00 $00 $17 $00 $00 $FF $00 $00
.db $BF $00 $00 $2F $00 $00 $00 $00 $00 $FF $00 $00 $0B $00 $00 $05
.db $FF $00 $00 $81 $01 $00 $00 $06 $FF $00 $00 $82 $FE $01 $00 $2E
.db $01 $00 $06 $FE $01 $00 $08 $7F $00 $80 $08 $FF $00 $00 $84 $80
.db $7F $3F $C0 $3F $0F $F0 $0F $03 $FC $03 $00 $04 $FF $00 $00 $04
.db $00 $FF $FF $84 $00 $FF $3F $C0 $3F $1F $E0 $1F $07 $F8 $07 $01
.db $08 $00 $FF $FF $82 $07 $38 $00 $00 $07 $00 $07 $00 $00 $00 $8F
.db $E0 $00 $00 $1C $E0 $00 $03 $1C $00 $00 $03 $00 $00 $00 $00 $01
.db $00 $00 $05 $00 $00 $17 $00 $00 $37 $00 $00 $BF $00 $00 $B7 $00
.db $00 $4F $80 $30 $81 $70 $0E $B0 $0E $01 $FE $01 $00 $06 $FF $00
.db $00 $82 $3F $00 $C0 $07 $C0 $38 $09 $FE $01 $00 $07 $FF $00 $00
.db $85 $00 $FF $7F $80 $7F $3F $C0 $3F $0F $F0 $0F $03 $FC $03 $00
.db $03 $FF $00 $00 $05 $00 $FF $FF $83 $00 $FF $7F $80 $7F $1F $E0
.db $1F $07 $06 $00 $FF $FF $82 $00 $FF $FC $03 $FC $E0 $03 $00 $FF
.db $FF $88 $00 $FF $FC $03 $FC $E0 $1F $E0 $80 $7F $80 $00 $FF $00
.db $00 $00 $FF $FC $03 $FC $E0 $1F $E0 $00 $05 $FF $00 $00 $81 $01
.db $00 $00 $03 $05 $00 $00 $82 $15 $00 $00 $07 $00 $00 $02 $17 $00
.db $00 $82 $C0 $38 $07 $F8 $07 $00 $07 $FF $00 $00 $84 $1F $00 $E0
.db $03 $E0 $1C $E0 $1C $03 $FC $03 $00 $06 $FF $00 $00 $85 $7F $00
.db $80 $1F $80 $60 $83 $60 $1C $E0 $1C $03 $FC $03 $00 $06 $FE $01
.db $00 $83 $7E $01 $80 $0E $81 $70 $F8 $07 $01 $07 $FE $01 $00 $82
.db $1F $E0 $80 $7F $80 $00 $06 $FF $00 $00 $02 $17 $00 $00 $83 $57
.db $00 $00 $1F $00 $00 $57 $00 $00 $03 $5F $00 $00 $83 $80 $71 $0E
.db $F0 $0F $00 $FE $01 $00 $05 $FF $00 $00 $85 $7F $00 $80 $3F $00
.db $C0 $07 $C0 $38 $C0 $38 $07 $F8 $07 $00 $07 $FF $00 $00 $84 $1F
.db $00 $E0 $03 $E0 $1C $E0 $1C $03 $FC $03 $00 $06 $FF $00 $00 $85
.db $7F $00 $80 $0F $80 $70 $00 $00 $00 $01 $00 $00 $00 $00 $00 $05
.db $01 $00 $00 $07 $5F $00 $00 $84 $7F $00 $00 $81 $70 $0E $F0 $0E
.db $01 $FE $01 $00 $06 $FF $00 $00 $85 $3F $00 $C0 $0F $C0 $30 $C1
.db $30 $0E $F0 $0E $01 $FE $01 $00 $06 $FF $00 $00 $84 $3F $00 $C0
.db $07 $C0 $38 $C0 $38 $07 $F8 $07 $00 $07 $FE $01 $00 $81 $1E $01
.db $E0 $07 $FF $00 $00 $81 $FC $00 $03 $05 $FF $00 $00 $83 $FE $00
.db $01 $C0 $01 $3E $01 $3E $C0 $03 $FF $00 $00 $87 $FE $00 $01 $E0
.db $01 $1E $01 $1E $E0 $1F $E0 $00 $FF $00 $00 $05 $00 $00 $01 $00
.db $00 $06 $05 $00 $00 $81 $5F $00 $00 $06 $7F $00 $00 $84 $FF $00
.db $00 $02 $E1 $1C $E0 $1D $02 $FC $03 $00 $05 $FE $01 $00 $83 $C0
.db $03 $3C $03 $3C $C0 $3F $C0 $00 $05 $FF $00 $00 $81 $3F $C0 $00
.db $07 $FF $00 $00 $06 $05 $00 $00 $83 $C5 $00 $00 $3A $C0 $05 $7F
.db $00 $00 $06 $FF $00 $00 $82 $1F $00 $E0 $00 $3F $00 $07 $05 $00
.db $00 $82 $00 $E0 $1F $E0 $1F $00 $06 $FF $00 $00 $83 $0F $00 $F0
.db $00 $F0 $0F $F0 $0F $00 $06 $FF $00 $00 $83 $07 $00 $F8 $00 $F8
.db $07 $F8 $07 $00 $06 $FF $00 $00 $83 $03 $00 $FC $00 $FC $03 $FC
.db $03 $00 $06 $FF $00 $00 $83 $03 $00 $FC $00 $FC $03 $FC $03 $00
.db $06 $FF $00 $00 $82 $00 $00 $FF $00 $FF $00 $02 $FE $01 $00 $05
.db $FF $00 $00 $83 $00 $00 $FF $00 $FF $00 $7F $00 $80 $06 $FF $00
.db $00 $82 $00 $00 $FF $00 $FF $00 $06 $FF $00 $00 $85 $7F $00 $80
.db $00 $80 $7F $05 $00 $00 $07 $00 $00 $05 $00 $00 $04 $07 $00 $00
.db $82 $27 $00 $00 $80 $7F $00 $07 $FF $00 $00 $82 $00 $C0 $3F $C0
.db $3F $00 $06 $FF $00 $00 $83 $3F $00 $C0 $00 $C0 $3F $C0 $3F $00
.db $05 $FF $00 $00 $84 $FE $01 $00 $1E $01 $E0 $00 $E1 $1E $E0 $1F
.db $00 $04 $FE $01 $00 $84 $FF $00 $00 $FC $00 $03 $00 $03 $FC $03
.db $FC $00 $05 $FF $00 $00 $82 $00 $00 $FF $00 $FF $00 $05 $FF $00
.db $00 $83 $E0 $00 $1F $00 $1F $E0 $1F $E0 $00 $05 $FF $00 $00 $08
.db $27 $00 $00 $81 $00 $FF $FF $02 $FF $00 $FF $82 $00 $FF $FF $FF
.db $00 $FF $02 $00 $FF $FF $82 $00 $FF $F8 $00 $FF $FF $02 $FF $00
.db $FF $8A $00 $FF $FF $F8 $07 $F8 $07 $F8 $C0 $3F $C0 $00 $FF $00
.db $00 $96 $69 $FE $F8 $06 $F8 $C0 $38 $C0 $3F $C0 $00 $00 $00 $00
.db $03 $FF $00 $00 $81 $00 $C0 $00 $02 $00 $00 $00 $81 $FF $00 $00
.db $02 $00 $00 $00 $02 $FF $00 $00 $03 $00 $00 $00 $81 $FF $00 $00
.db $02 $00 $00 $00 $82 $FF $00 $00 $FD $00 $00 $03 $00 $00 $00 $81
.db $FF $00 $00 $02 $00 $00 $00 $81 $FF $00 $00 $04 $00 $00 $00 $81
.db $F6 $00 $00 $02 $00 $00 $00 $81 $FF $00 $00 $04 $00 $00 $00 $81
.db $80 $00 $00 $02 $00 $00 $00 $82 $FF $00 $00 $00 $00 $00 $05 $00
.db $FF $FF $83 $00 $FF $F8 $07 $F8 $E0 $1F $E0 $00 $02 $00 $FF $FF
.db $83 $00 $FF $F8 $06 $F8 $E1 $1E $E0 $01 $03 $FE $00 $01 $82 $07
.db $F8 $C0 $3F $C0 $00 $06 $7F $80 $00 $82 $FF $00 $00 $F4 $00 $00
.db $06 $FF $00 $00 $06 $00 $00 $00 $82 $03 $00 $00 $7C $03 $00 $07
.db $FF $00 $00 $81 $FE $00 $01 $05 $FF $00 $00 $83 $FE $00 $01 $E0
.db $01 $1E $01 $1E $E0 $04 $FF $00 $00 $90 $F0 $00 $0F $00 $0F $F0
.db $0F $F0 $00 $FF $00 $00 $E8 $00 $00 $EC $00 $00 $F2 $00 $0D $10
.db $0F $E0 $0D $F0 $00 $FF $00 $00 $FD $00 $00 $FF $00 $00 $07 $00
.db $00 $78 $07 $00 $80 $78 $00 $00 $80 $00 $02 $00 $00 $00 $84 $80
.db $00 $00 $A0 $00 $00 $80 $7C $00 $00 $80 $00 $06 $00 $00 $00 $07
.db $FF $00 $00 $81 $F0 $00 $0F $05 $FF $00 $00 $83 $F0 $00 $0F $00
.db $0F $F0 $0F $F0 $00 $03 $FF $00 $00 $84 $F8 $00 $07 $80 $07 $78
.db $07 $78 $80 $7F $80 $00 $02 $FF $00 $00 $84 $FC $00 $03 $80 $03
.db $7C $03 $7C $80 $7F $80 $00 $03 $FF $00 $00 $83 $C0 $01 $3E $01
.db $3E $C0 $39 $C2 $04 $05 $F9 $02 $04 $81 $1F $E0 $00 $07 $FF $00
.db $00 $06 $7F $80 $00 $82 $78 $80 $07 $00 $87 $78 $04 $FF $00 $00
.db $84 $FC $00 $03 $C0 $03 $3C $03 $3C $C0 $3F $C0 $00 $02 $FF $00
.db $00 $84 $FE $00 $01 $C0 $01 $3E $01 $3E $C0 $3F $C0 $00 $02 $FF
.db $00 $00 $84 $FE $00 $01 $E0 $01 $1E $01 $1E $E0 $1F $E0 $00 $04
.db $FF $00 $00 $82 $00 $0F $F0 $0F $F0 $00 $06 $FF $00 $00 $08 $F9
.db $02 $04 $02 $FF $00 $00 $83 $F0 $00 $0F $00 $0F $F0 $0F $F0 $00
.db $03 $FF $00 $00 $83 $F8 $00 $07 $00 $07 $F8 $07 $F8 $00 $05 $FF
.db $00 $00 $82 $07 $F8 $00 $7F $80 $00 $0D $FF $00 $00 $82 $F8 $00
.db $07 $FE $00 $00 $06 $FF $00 $00 $81 $00 $00 $FF $06 $A0 $00 $00
.db $82 $9F $00 $20 $40 $3F $80 $07 $FF $00 $00 $81 $00 $00 $FF $06
.db $FF $00 $00 $82 $F0 $00 $0F $00 $0F $F0 $05 $FF $00 $00 $83 $80
.db $00 $7F $00 $7F $80 $7F $80 $00 $04 $FF $00 $00 $83 $FC $00 $03
.db $00 $03 $FC $03 $FC $00 $05 $FF $00 $00 $82 $00 $00 $FF $00 $FF
.db $00 $04 $FF $00 $00 $83 $FE $00 $01 $00 $01 $FE $01 $FE $00 $05
.db $FF $00 $00 $82 $00 $00 $FF $00 $FF $00 $04 $FF $00 $00 $84 $F9
.db $02 $04 $F0 $02 $0D $00 $0F $F0 $0F $F0 $00 $04 $FF $00 $00 $83
.db $80 $00 $7F $00 $7F $80 $7F $80 $00 $05 $FF $00 $00 $81 $00 $FF
.db $00 $07 $FF $00 $00 $81 $20 $C0 $00 $07 $A0 $00 $00 $82 $00 $01
.db $FE $01 $FE $00 $06 $FF $00 $00 $81 $00 $FF $00 $07 $FE $00 $01
.db $81 $0F $F0 $00 $07 $7F $80 $00 $06 $00 $00 $00 $82 $00 $03 $00
.db $03 $04 $03 $02 $00 $01 $00 $84 $01 $06 $01 $07 $08 $07 $0F $30
.db $0F $3F $C0 $3F $02 $FF $00 $FF $82 $1F $60 $1F $7F $80 $7F $0E
.db $FF $00 $FF $07 $00 $00 $00 $81 $00 $01 $00 $02 $00 $00 $00 $89
.db $00 $01 $00 $01 $02 $01 $03 $0C $03 $0F $30 $0F $3F $C0 $3F $FF
.db $00 $FF $07 $18 $07 $1F $60 $1F $7F $80 $7F $05 $FF $00 $FF $83
.db $C0 $38 $C0 $F8 $06 $F8 $FE $01 $FE $05 $FF $00 $FF $02 $00 $00
.db $00 $84 $00 $C0 $00 $C0 $38 $C0 $F8 $06 $F8 $FE $01 $FE $02 $FF
.db $00 $FF $05 $00 $00 $00 $84 $00 $C0 $00 $C0 $30 $C0 $F0 $0E $F0
.db $FE $01 $FE $07 $FF $00 $FF $84 $00 $C0 $00 $C0 $30 $C0 $F0 $0E
.db $F0 $FE $01 $FE $04 $FF $00 $FF $03 $00 $00 $00 $85 $00 $C0 $00
.db $C0 $30 $C0 $F0 $0E $F0 $FE $01 $FE $FF $00 $FF $06 $00 $00 $00
.db $82 $00 $80 $00 $80 $70 $80 $7F $00 $00 $00 $7F $00 $00 $00 $7F
.db $00 $00 $00 $0B $00 $00 $00 $00 $08 $00 $00 $00 $0E $FF $00 $FF
.db $81 $EC $13 $FF $04 $FF $00 $FF $81 $FE $01 $FF $02 $FF $00 $FF
.db $8A $00 $FF $FF $FF $00 $FF $F9 $06 $FB $F3 $0C $F7 $E7 $18 $EF
.db $88 $7F $EF $CF $30 $DF $9F $60 $BF $20 $FF $BF $3F $C0 $7F $03
.db $FF $00 $FF $81 $00 $FF $FF $02 $FF $00 $FF $86 $00 $FF $FF $FF
.db $00 $FF $1F $E0 $9F $87 $78 $E7 $E1 $1E $F9 $06 $FF $FE $02 $FF
.db $00 $FF $82 $00 $FF $FF $40 $BF $FF $03 $FF $00 $FF $85 $00 $FF
.db $7F $1F $E0 $9F $87 $78 $E7 $18 $FF $F9 $06 $FF $FE $03 $FF $00
.db $FF $82 $00 $FF $FF $FF $00 $FF $02 $00 $FF $FF $81 $00 $FF $7F
.db $03 $FF $00 $FF $82 $00 $FF $FF $FF $00 $FF $03 $00 $FF $FF $06
.db $FF $00 $FF $82 $FE $01 $FF $F9 $06 $FF $02 $FF $00 $FF $8A $E8
.db $17 $FF $FF $00 $FF $40 $BF $FF $E8 $17 $FF $00 $FF $FF $40 $BF
.db $FF $D0 $2F $FF $FF $00 $FF $00 $FF $FF $F4 $0B $FF $05 $00 $FF
.db $FF $81 $FE $01 $FF $06 $00 $FF $FF $83 $00 $FF $FE $D0 $2F $FE
.db $01 $FF $FD $02 $02 $FF $FB $81 $04 $FF $F7 $02 $08 $FF $EF $02
.db $80 $FF $FF $0E $00 $FF $FF $81 $01 $FF $FF $07 $00 $FF $FF $84
.db $80 $FF $9F $60 $FF $E7 $18 $FF $F8 $07 $FF $FF $07 $00 $FF $FF
.db $85 $00 $FF $3F $C0 $FF $CF $30 $FF $F3 $0C $FF $FC $03 $FF $FF
.db $07 $00 $FF $FF $81 $00 $FF $3F $06 $FF $00 $FF $89 $FE $01 $FF
.db $FA $05 $FF $E8 $17 $FF $C8 $37 $FF $40 $BF $FF $C8 $37 $FF $40
.db $BF $FF $00 $FF $FF $40 $BF $FF $05 $00 $FF $FF $02 $00 $FF $FE
.db $83 $01 $FF $FD $02 $FF $FB $10 $FF $DF $02 $20 $FF $BF $81 $40
.db $FF $7F $02 $80 $FF $FF $02 $00 $FF $FF $84 $C0 $FF $CF $30 $FF
.db $F3 $0C $FF $FC $03 $FF $FF $04 $00 $FF $FF $85 $FF $00 $FF $3F
.db $C0 $3F $03 $FC $C3 $C0 $3F $FC $FC $03 $FF $03 $FF $00 $FF $81
.db $FE $01 $FF $02 $FA $05 $FF $85 $3A $C5 $3F $02 $FD $C3 $C4 $3F
.db $FC $EB $17 $FF $E8 $17 $FF $05 $00 $FF $FF $85 $00 $FF $3F $C0
.db $FF $C3 $3C $FF $FC $02 $FF $FB $04 $FF $F7 $02 $08 $FF $EF $81
.db $10 $FF $DF $02 $20 $FF $BF $81 $40 $FF $7F $06 $00 $FF $FF $8A
.db $00 $FF $FE $01 $FE $F8 $C0 $FF $CF $30 $FF $F1 $0E $FF $FE $00
.db $FF $F8 $04 $F9 $E2 $1C $E1 $82 $7C $81 $02 $FC $01 $02 $04 $E8
.db $17 $FF $81 $A8 $57 $FF $02 $A0 $5F $FF $82 $80 $7F $FF $03 $FF
.db $FF $07 $00 $FF $FF $83 $C0 $FF $C3 $3C $FF $FC $03 $FF $FF $05
.db $00 $FF $FF $86 $00 $FF $FE $00 $FF $3E $C1 $FF $C1 $3A $FF $FB
.db $02 $FF $FB $04 $FF $F7 $02 $08 $FF $EF $06 $00 $FF $FF $82 $00
.db $FF $FE $00 $FF $F8 $02 $00 $FF $FF $89 $00 $FF $FE $01 $FE $F8
.db $07 $F8 $E0 $1F $E0 $80 $7F $80 $00 $FF $00 $00 $07 $F8 $E0 $1F
.db $E0 $80 $7F $80 $00 $05 $FF $00 $00 $08 $FC $01 $02 $83 $FF $00
.db $FF $FE $01 $FF $FF $00 $FF $05 $FE $01 $FF $07 $A0 $5F $FF $81
.db $80 $7F $FF $06 $00 $FF $FF $82 $00 $FF $FC $03 $FC $F0 $02 $00
.db $FF $FF $84 $00 $FF $FC $03 $FC $F0 $0F $F0 $C0 $3F $C0 $00 $02
.db $FF $00 $00 $82 $04 $F9 $E2 $1C $E1 $02 $06 $FC $01 $02 $08 $FF
.db $00 $00 $82 $FA $05 $FF $FE $01 $FF $06 $FA $05 $FF $81 $A0 $5F
.db $FF $06 $80 $7F $FF $83 $00 $FF $FF $02 $FF $FB $04 $FF $F7 $02
.db $08 $FF $EF $84 $00 $FF $C0 $3F $FF $BF $00 $FF $BF $00 $FF $7F
.db $05 $00 $FF $FF $82 $00 $FF $00 $FF $FF $FF $07 $00 $FF $FF $82
.db $00 $FF $00 $FF $FF $FF $07 $00 $FF $FF $81 $00 $FF $00 $06 $00
.db $FF $FF $82 $00 $FF $FC $03 $FC $E0 $02 $00 $FF $FF $84 $00 $FF
.db $FC $03 $FC $F0 $0F $F0 $C0 $1F $E0 $00 $02 $9F $20 $40 $82 $0F
.db $F0 $C0 $3F $C0 $00 $0D $FF $00 $00 $81 $FC $00 $03 $05 $FF $00
.db $00 $83 $F8 $00 $07 $80 $07 $78 $07 $78 $80 $03 $FC $01 $02 $83
.db $E0 $01 $1E $00 $1F $E0 $1C $E1 $02 $02 $FC $01 $02 $82 $00 $FF
.db $01 $FE $01 $FE $06 $FF $00 $FF $83 $80 $7F $FF $00 $FF $03 $FC
.db $03 $FC $05 $FF $00 $FF $86 $00 $FF $FE $AA $55 $FE $05 $FA $0D
.db $F1 $0E $F1 $FB $04 $FB $F7 $08 $F7 $02 $EF $10 $EF $02 $00 $FF
.db $FF $81 $55 $AA $FF $05 $FF $00 $FF $02 $00 $FF $FF $82 $40 $BF
.db $FF $AA $55 $FF $04 $FF $00 $FF $02 $00 $FF $FF $82 $01 $FE $FF
.db $AA $55 $FF $04 $FF $00 $FF $92 $FF $FF $FF $02 $FD $FF $55 $AA
.db $FF $AA $55 $FF $FF $00 $FF $FE $01 $FE $F8 $06 $F8 $E0 $18 $E0
.db $00 $FF $00 $FE $FF $FE $51 $AE $F8 $A7 $58 $E0 $8B $60 $80 $17
.db $C0 $00 $2B $40 $00 $17 $40 $00 $1F $E0 $00 $7F $80 $00 $06 $FF
.db $00 $00 $08 $9F $20 $40 $06 $FF $00 $00 $82 $FC $00 $03 $C0 $03
.db $3C $04 $FF $00 $00 $84 $F8 $00 $07 $80 $07 $78 $07 $78 $80 $7F
.db $80 $00 $02 $FC $01 $02 $83 $E0 $01 $1E $01 $1E $E0 $1F $E0 $00
.db $03 $FF $00 $00 $83 $C0 $03 $3C $03 $3C $C0 $3F $C0 $00 $05 $FF
.db $00 $00 $81 $7F $80 $00 $07 $FF $00 $00 $94 $FF $00 $FF $FF $20
.db $DF $FF $25 $DA $03 $FD $02 $FC $27 $D8 $FF $25 $DA $55 $AF $50
.db $00 $FF $00 $FF $00 $FF $FF $AA $55 $FF $FD $02 $FF $FF $00 $02
.db $FF $00 $FC $FF $00 $55 $FF $00 $00 $FF $00 $DF $20 $DF $83 $7C
.db $83 $BC $57 $A8 $7F $FA $05 $03 $FF $FF $00 $81 $AA $FF $00 $02
.db $FF $00 $FF $82 $00 $FF $00 $FF $AA $55 $03 $FF $FF $00 $81 $AA
.db $FF $00 $02 $FF $00 $FF $90 $7F $80 $7F $80 $FF $00 $FF $55 $AA
.db $FE $FF $00 $F1 $FF $00 $8F $FF $00 $FF $00 $FF $FE $01 $FE $F8
.db $07 $F8 $04 $FD $00 $8A $6B $80 $54 $D5 $00 $68 $E9 $00 $50 $D1
.db $00 $80 $60 $80 $00 $80 $00 $06 $00 $00 $00 $88 $2F $40 $00 $17
.db $40 $00 $2F $40 $00 $1F $40 $00 $2F $40 $00 $1C $40 $03 $00 $43
.db $3C $02 $7C $01 $03 $FF $00 $00 $83 $F8 $00 $07 $80 $07 $78 $07
.db $78 $80 $02 $7F $80 $00 $84 $9E $20 $41 $80 $21 $5E $01 $3E $C0
.db $1F $E0 $00 $04 $FF $00 $00 $82 $03 $3C $C0 $33 $C4 $08 $06 $F3
.db $04 $08 $08 $00 $FF $00 $02 $1F $FF $00 $91 $5F $FF $00 $1F $FF
.db $00 $5F $FF $00 $18 $FF $00 $43 $FF $00 $3B $FF $00 $68 $E9 $00
.db $50 $D1 $00 $68 $E9 $00 $50 $D7 $00 $00 $F8 $00 $40 $D0 $00 $E0
.db $F0 $00 $C0 $D0 $00 $00 $01 $00 $00 $1E $00 $00 $F0 $00 $05 $00
.db $10 $00 $88 $3E $C0 $01 $5E $00 $01 $BE $00 $01 $7E $00 $01 $BE
.db $00 $01 $7E $00 $01 $BE $00 $01 $7E $00 $01 $08 $7F $80 $00 $07
.db $FF $00 $00 $81 $C0 $00 $3F $06 $F3 $04 $08 $82 $F0 $04 $0B $00
.db $0F $F0 $05 $FF $00 $00 $83 $FC $00 $03 $00 $03 $FC $03 $FC $00
.db $05 $FF $00 $00 $83 $00 $00 $FF $00 $FF $00 $FC $01 $02 $04 $FF
.db $00 $00 $82 $00 $00 $FF $00 $FF $00 $05 $FF $00 $00 $83 $C0 $00
.db $3F $00 $3F $C0 $3F $C0 $00 $02 $FF $00 $00 $02 $FC $01 $02 $83
.db $F0 $01 $0E $00 $0F $F0 $0C $F1 $02 $03 $FC $01 $02 $90 $7B $FF
.db $00 $3B $FF $00 $7B $FF $00 $3B $FF $00 $40 $FF $00 $1F $FF $00
.db $5F $FF $00 $1F $FF $00 $E0 $F0 $00 $C0 $D0 $00 $E0 $F0 $00 $C0
.db $DF $00 $00 $F1 $00 $40 $C1 $00 $60 $E1 $00 $40 $C1 $00 $02 $00
.db $10 $00 $82 $00 $13 $00 $00 $FC $00 $04 $00 $00 $00 $8B $BE $00
.db $01 $7E $00 $01 $00 $FF $00 $3F $40 $00 $BF $40 $00 $3F $40 $00
.db $BF $40 $00 $3F $40 $00 $00 $80 $7F $00 $FF $00 $7F $80 $00 $05
.db $FF $00 $00 $82 $00 $3F $C0 $1F $E0 $00 $06 $9F $20 $40 $81 $0F
.db $F0 $00 $07 $FF $00 $00 $82 $F9 $06 $FB $FC $03 $FD $02 $FE $01
.db $FE $04 $FF $00 $FF $85 $F8 $07 $FE $E1 $1E $F9 $07 $F8 $E7 $1F
.db $E0 $9F $3F $C0 $7F $02 $9F $60 $BF $82 $CF $30 $DF $7F $80 $7F
.db $07 $FF $00 $FF $02 $E7 $18 $EF $81 $F3 $0C $F7 $02 $F9 $06 $FB
.db $81 $FC $03 $FD $02 $FE $01 $FE $06 $FF $00 $FF $02 $7F $80 $FF
.db $7F $00 $00 $00 $7F $00 $00 $00 $7F $00 $00 $00 $7F $00 $00 $00
.db $7F $00 $00 $00 $1D $00 $00 $00 $00 $0E $00 $00 $00 $81 $13 $00
.db $00 $04 $00 $00 $00 $81 $01 $00 $00 $02 $00 $00 $00 $81 $FF $00
.db $00 $04 $00 $00 $00 $81 $6F $00 $00 $02 $00 $00 $00 $81 $FF $00
.db $00 $04 $00 $00 $00 $81 $FF $00 $00 $02 $00 $00 $00 $81 $FF $00
.db $00 $04 $00 $00 $00 $81 $FF $00 $00 $02 $00 $00 $00 $82 $FF $00
.db $00 $BF $00 $00 $03 $00 $00 $00 $81 $FF $00 $00 $02 $00 $00 $00
.db $02 $FF $00 $00 $81 $16 $00 $00 $02 $00 $00 $00 $82 $FF $00 $00
.db $00 $00 $00 $03 $FF $00 $00 $85 $E0 $1F $01 $00 $01 $00 $00 $00
.db $00 $FF $00 $00 $00 $00 $00 $03 $FF $00 $00 $85 $00 $FF $FF $1F
.db $E0 $1F $01 $1E $01 $FE $01 $00 $00 $00 $00 $03 $FF $00 $00 $81
.db $00 $FF $FF $02 $FF $00 $FF $83 $00 $FF $1F $03 $1C $03 $FC $03
.db $00 $02 $FF $00 $00 $81 $00 $FF $FF $02 $FF $00 $FF $85 $00 $FF
.db $FF $FF $00 $FF $00 $FF $3F $C0 $3F $03 $FC $03 $00 $06 $00 $00
.db $00 $82 $01 $00 $00 $07 $00 $00 $02 $00 $00 $00 $8A $17 $00 $00
.db $00 $00 $00 $BF $00 $00 $17 $00 $00 $FF $00 $00 $BF $00 $00 $2F
.db $00 $00 $00 $00 $00 $FF $00 $00 $0B $00 $00 $05 $FF $00 $00 $81
.db $01 $00 $00 $07 $FF $00 $00 $81 $2F $00 $00 $0E $FF $00 $00 $02
.db $00 $00 $00 $83 $FC $00 $00 $03 $FC $00 $00 $03 $00 $06 $00 $00
.db $00 $8C $F0 $00 $00 $0F $F0 $00 $00 $0F $00 $01 $00 $00 $05 $00
.db $00 $17 $00 $00 $37 $00 $00 $BF $00 $00 $37 $00 $00 $5F $00 $A0
.db $00 $E0 $1F $A0 $1F $00 $06 $FF $00 $00 $83 $7F $00 $80 $01 $80
.db $7E $80 $7E $01 $07 $FF $00 $00 $82 $03 $00 $FC $01 $00 $00 $03
.db $05 $00 $00 $82 $15 $00 $00 $07 $00 $00 $02 $17 $00 $00 $81 $FE
.db $01 $00 $07 $FF $00 $00 $82 $00 $FC $03 $FC $03 $00 $06 $FF $00
.db $00 $83 $0F $00 $F0 $00 $F0 $0F $F0 $0F $00 $06 $FF $00 $00 $83
.db $3F $00 $C0 $00 $C0 $3F $C0 $3F $00 $06 $FF $00 $00 $84 $7F $00
.db $80 $01 $80 $7E $80 $7E $01 $FE $01 $00 $06 $FF $00 $00 $83 $07
.db $00 $F8 $00 $F8 $07 $F8 $07 $00 $06 $FF $00 $00 $83 $0F $00 $F0
.db $00 $F0 $0F $C0 $2F $10 $06 $FF $00 $00 $82 $3F $00 $C0 $00 $C0
.db $3F $02 $17 $00 $00 $83 $57 $00 $00 $1F $00 $00 $57 $00 $00 $03
.db $5F $00 $00 $08 $CF $20 $10 $81 $C0 $3F $00 $07 $FF $00 $00 $83
.db $01 $00 $FE $00 $FE $01 $FE $01 $00 $06 $FF $00 $00 $83 $07 $00
.db $F8 $00 $F8 $07 $F8 $07 $00 $06 $FF $00 $00 $83 $1F $00 $E0 $00
.db $E0 $1F $E0 $1F $00 $06 $FF $00 $00 $83 $3F $00 $C0 $00 $C0 $3F
.db $C0 $3F $00 $07 $FF $00 $00 $86 $01 $00 $FE $00 $FE $01 $FE $01
.db $00 $00 $00 $00 $01 $00 $00 $00 $00 $00 $05 $01 $00 $00 $07 $5F
.db $00 $00 $83 $7F $00 $00 $05 $00 $00 $01 $00 $00 $06 $05 $00 $00
.db $81 $5F $00 $00 $06 $7F $00 $00 $81 $FF $00 $00 $08 $05 $00 $00
.db $81 $7F $00 $00 $07 $FF $00 $00 $82 $FA $00 $05 $00 $FF $00 $06
.db $05 $00 $00 $82 $00 $00 $FF $00 $FF $00 $06 $FF $00 $00 $83 $1F
.db $00 $E0 $00 $E0 $1F $E0 $1F $00 $06 $FF $00 $00 $82 $00 $00 $FF
.db $00 $FF $00 $06 $FF $00 $00 $83 $03 $00 $FC $00 $FC $03 $FC $03
.db $00 $06 $FF $00 $00 $82 $00 $00 $FF $00 $FF $00 $06 $FF $00 $00
.db $83 $7F $00 $80 $00 $80 $7F $80 $7F $00 $06 $FF $00 $00 $82 $00
.db $00 $FF $00 $FF $00 $03 $FF $00 $00 $03 $CF $20 $10 $83 $0F $20
.db $D0 $00 $F0 $0F $F0 $0F $00 $06 $FF $00 $00 $82 $00 $00 $FF $00
.db $FF $00 $06 $FF $00 $00 $83 $01 $00 $FE $00 $FE $01 $FE $01 $00
.db $06 $FF $00 $00 $82 $00 $00 $FF $00 $FF $00 $06 $FF $00 $00 $83
.db $3F $00 $C0 $00 $C0 $3F $C0 $3F $00 $06 $FF $00 $00 $85 $00 $00
.db $FF $00 $FF $00 $05 $00 $00 $07 $00 $00 $05 $00 $00 $04 $07 $00
.db $00 $09 $27 $00 $00 $81 $00 $FF $FF $02 $FF $00 $FF $82 $00 $FF
.db $FF $FF $00 $FF $02 $00 $FF $FF $82 $00 $FF $3F $00 $FF $FF $02
.db $FF $00 $FF $82 $00 $FF $FF $FF $00 $FF $03 $00 $FF $FF $81 $97
.db $68 $FF $02 $FF $00 $FF $82 $00 $FF $FF $FF $00 $FF $03 $00 $FF
.db $FF $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF $00 $FF $02 $00 $FF
.db $FF $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF $00 $FF $82 $00 $FF
.db $FF $02 $FD $FF $03 $FF $00 $FF $81 $00 $FF $FF $02 $FF $00 $FF
.db $81 $00 $FF $FF $04 $FF $00 $FF $81 $09 $F6 $FF $02 $FF $00 $FF
.db $81 $00 $FF $FF $04 $FF $00 $FF $89 $7E $81 $FE $F8 $07 $F9 $F1
.db $0E $F7 $08 $FF $CF $8F $70 $BF $E3 $1C $E7 $C7 $38 $DF $1F $E0
.db $3F $3F $C0 $FF $02 $FF $00 $FF $81 $37 $C8 $FF $09 $FF $00 $FF
.db $82 $C0 $3F $07 $F8 $07 $00 $06 $FF $00 $00 $84 $00 $FF $FF $00
.db $FF $7F $00 $FF $07 $38 $87 $40 $04 $3F $80 $40 $03 $00 $FF $FF
.db $83 $00 $FF $7F $80 $7F $0F $F0 $0F $00 $02 $FF $00 $00 $06 $00
.db $FF $FF $82 $00 $FF $0F $F0 $0F $00 $0E $00 $FF $FF $8C $00 $FF
.db $FC $03 $FF $FB $00 $FF $FE $01 $FF $FD $02 $FF $F3 $0C $FF $EF
.db $10 $FF $9F $60 $FF $7F $80 $FF $FF $00 $FF $FF $40 $FF $7F $8B
.db $F4 $FF $07 $00 $FF $FF $81 $7F $80 $FF $06 $00 $FF $FF $84 $0B
.db $F4 $FF $FF $00 $FF $00 $FF $FF $2F $D0 $FF $04 $00 $FF $FF $02
.db $FF $00 $FF $86 $17 $E8 $FF $FF $00 $FF $02 $FD $FF $17 $E8 $FF
.db $00 $FF $FF $02 $FD $FF $06 $FF $00 $FF $82 $7F $80 $FF $9F $60
.db $FF $08 $3F $80 $40 $83 $00 $FF $0F $F0 $0F $01 $FE $01 $00 $05
.db $FF $00 $00 $02 $00 $FF $FF $83 $00 $FF $1F $E0 $1F $01 $FE $01
.db $00 $03 $FF $00 $00 $03 $00 $FF $FF $89 $00 $FF $FE $01 $FF $19
.db $E2 $1F $03 $FC $03 $00 $FF $00 $00 $04 $FF $E7 $18 $FF $DF $20
.db $FF $3F $C0 $FF $FF $02 $00 $FF $FF $8A $00 $FF $3F $C0 $3F $03
.db $17 $E8 $FF $13 $EC $FF $02 $FD $FF $13 $EC $FF $02 $FD $FF $00
.db $FF $FF $02 $FD $FF $00 $FF $FF $06 $FF $00 $FF $83 $7F $80 $FF
.db $5F $A0 $FF $FC $03 $00 $07 $FF $00 $00 $83 $00 $FF $3F $C0 $3F
.db $03 $FC $03 $00 $05 $FF $00 $00 $02 $00 $FF $FF $83 $00 $FF $3F
.db $C0 $3F $03 $FC $03 $00 $03 $FF $00 $00 $04 $00 $FF $FF $84 $00
.db $FF $7F $80 $7F $07 $F0 $0F $00 $F3 $08 $04 $06 $00 $FF $FF $83
.db $00 $FF $7F $80 $7F $07 $7F $80 $FF $03 $5F $A0 $FF $82 $57 $A8
.db $FF $1F $E0 $FF $02 $17 $E8 $FF $06 $FF $00 $00 $82 $07 $00 $F8
.db $00 $F8 $07 $07 $3F $80 $40 $81 $1F $80 $60 $08 $F3 $08 $04 $81
.db $F8 $07 $00 $07 $FF $00 $00 $83 $00 $FF $7F $80 $7F $07 $F8 $07
.db $00 $05 $FF $00 $00 $03 $00 $FF $FF $82 $00 $FF $0F $F0 $0F $00
.db $03 $FF $00 $00 $04 $17 $E8 $FF $84 $15 $EA $FF $05 $FA $0F $F0
.db $0F $00 $FE $00 $00 $07 $FF $00 $FF $83 $0F $F0 $0F $00 $E0 $1F
.db $E0 $1F $00 $06 $FF $00 $00 $83 $3F $00 $C0 $00 $C0 $3F $C0 $3F
.db $00 $07 $FF $00 $00 $83 $03 $00 $FC $00 $FC $03 $FC $03 $00 $06
.db $FF $00 $00 $83 $07 $00 $F8 $00 $F8 $07 $F8 $07 $00 $06 $FF $00
.db $00 $83 $1F $00 $E0 $00 $E0 $1F $E0 $1F $00 $06 $FF $00 $00 $86
.db $7F $00 $80 $08 $80 $77 $80 $7F $00 $00 $0F $00 $80 $00 $00 $00
.db $00 $00 $05 $80 $00 $00 $02 $F3 $08 $04 $84 $73 $08 $84 $01 $88
.db $76 $80 $7E $01 $FE $01 $00 $07 $FF $00 $00 $84 $1F $00 $E0 $00
.db $E0 $1F $E0 $1F $00 $C0 $3F $00 $07 $FE $01 $00 $83 $02 $00 $FC
.db $00 $FC $03 $7C $03 $80 $05 $7F $00 $80 $88 $A0 $00 $00 $50 $00
.db $A0 $0F $F0 $00 $A0 $0F $00 $A0 $00 $00 $A4 $00 $00 $A0 $00 $00
.db $A4 $00 $00 $07 $FF $00 $00 $81 $00 $00 $FF $08 $FE $01 $00 $08
.db $7F $00 $80 $81 $A0 $00 $00 $06 $A4 $00 $00 $82 $E4 $00 $00 $00
.db $FF $00 $07 $3F $80 $40 $81 $00 $FF $00 $07 $FF $00 $00 $83 $F3
.db $08 $04 $00 $08 $F7 $00 $FF $00 $07 $FF $00 $00 $83 $01 $00 $FE
.db $00 $FE $01 $FE $01 $00 $06 $FF $00 $00 $82 $00 $00 $FF $00 $FF
.db $00 $03 $F3 $08 $04 $03 $FF $00 $00 $83 $7F $00 $80 $00 $80 $7F
.db $80 $7F $00 $02 $FF $00 $00 $04 $FE $01 $00 $82 $00 $01 $FE $00
.db $FF $00 $02 $FF $00 $00 $04 $7F $00 $80 $87 $1F $00 $E0 $00 $E0
.db $1F $E0 $1F $00 $FF $00 $00 $A4 $00 $00 $E4 $00 $00 $A4 $00 $00
.db $02 $E4 $00 $00 $83 $1B $00 $E4 $00 $FF $00 $E4 $00 $00 $07 $00
.db $00 $00 $81 $00 $07 $00 $05 $00 $00 $00 $83 $00 $07 $00 $07 $78
.db $07 $7F $80 $7F $03 $00 $00 $00 $83 $00 $0F $00 $0F $70 $0F $7F
.db $80 $7F $02 $FF $00 $FF $83 $00 $00 $00 $00 $0F $00 $0F $F0 $0F
.db $05 $FF $00 $FF $81 $1F $E0 $1F $07 $FF $00 $FF $07 $00 $00 $00
.db $81 $00 $01 $00 $05 $00 $00 $00 $83 $00 $01 $00 $01 $1E $01 $1F
.db $E0 $1F $03 $00 $00 $00 $83 $00 $03 $00 $03 $3C $03 $3F $C0 $3F
.db $02 $FF $00 $FF $84 $00 $00 $00 $00 $03 $00 $03 $3C $03 $3F $C0
.db $3F $04 $FF $00 $FF $82 $07 $78 $07 $7F $80 $7F $06 $FF $00 $FF
.db $83 $80 $7F $00 $00 $80 $7F $7F $00 $80 $05 $FF $00 $00 $82 $F8
.db $07 $FB $FC $03 $FC $07 $FF $00 $FF $87 $7F $80 $FF $1F $E0 $7F
.db $8F $70 $9F $E3 $1C $EF $F1 $0E $F3 $FC $03 $FD $FE $01 $FE $06
.db $FF $00 $FF $87 $7F $80 $FF $3F $C0 $7F $8F $70 $BF $C7 $38 $CF
.db $F1 $0E $F7 $F8 $07 $F9 $FE $01 $FE $07 $FF $00 $FF $84 $3F $C0
.db $FF $1F $E0 $3F $C7 $38 $DF $E3 $1C $E7 $7F $00 $00 $00 $7F $00
.db $00 $00 $72 $00 $00 $00 $00

;=======================================================================================================
; Bank 6: $18000 - $1bfff
;=======================================================================================================
.bank 6 slot 2
.ORG $0000

; Data from 18000 to 1AC4F (11344 bytes)
.incbin "Phantasy Star (Japan)_DATA_18000_.inc"

; 1st entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1AC50 to 1ADFF (432 bytes)
_DATA_1AC50_:
.db $2F $00 $30 $00 $30 $00 $30 $00 $30 $00 $30 $00 $30 $00 $30 $00
.db $30 $00 $30 $00 $30 $00 $2F $02 $31 $00 $32 $00 $33 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $33 $02 $32 $02 $31 $02
.db $31 $00 $32 $00 $33 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $33 $02 $32 $02 $31 $02 $31 $00 $32 $00 $33 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $33 $02 $32 $02 $31 $02
.db $35 $00 $36 $00 $33 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $33 $02 $36 $02 $35 $02 $31 $00 $37 $00 $38 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $38 $02 $37 $02 $31 $02
.db $31 $00 $32 $00 $33 $00 $34 $00 $39 $00 $3A $00 $3A $00 $39 $02
.db $34 $00 $33 $02 $32 $02 $31 $02 $31 $04 $32 $04 $33 $04 $3B $00
.db $3C $00 $3C $00 $3C $00 $3C $00 $3B $02 $33 $06 $32 $06 $31 $06
.db $31 $04 $37 $04 $38 $04 $3D
.dsb 9,$00
.db $3D $02 $38 $06 $37 $06 $31 $06 $35 $04 $36 $04 $3E $00 $3F $00
.db $40 $00 $40 $00 $40 $00 $40 $00 $3F $02 $3E $02 $36 $06 $35 $06
.db $31 $04 $32 $04 $41 $00 $42 $00 $42 $00 $42 $00 $42 $00 $42 $00
.db $42 $00 $41 $02 $32 $06 $31 $06 $31 $04 $43 $00 $44 $00 $45 $00
.db $45 $00 $45 $00 $45 $00 $45 $00 $45 $00 $44 $02 $43 $02 $31 $06
.db $31 $04 $46 $00 $47 $00 $48 $00 $48 $00 $48 $00 $48 $00 $48 $00
.db $48 $00 $47 $02 $46 $02 $31 $06 $49 $00 $32 $04 $4A
.dsb 13,$00
.db $4A $02 $32 $06 $49 $02 $31 $04 $32 $04 $4B $00 $4C $00 $4C $00
.db $4C $00 $4C $00 $4C $00 $4C $00 $4B $02 $32 $06 $31 $06 $31 $04
.db $4D
.dsb 17,$00
.db $4D $02 $31 $06 $31 $04 $4E
.dsb 17,$00
.db $4E $02 $31 $06 $4F $00 $42 $04 $42 $04 $42 $04 $42 $04 $42 $04
.db $42 $04 $42 $04 $42 $04 $42 $04 $42 $04 $4F $02

; 2nd entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1AE00 to 1AFAF (432 bytes)
_DATA_1AE00_:
.db $2F $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00
.db $50 $00 $50 $00 $50 $00 $2F $02 $31 $00 $51 $00 $52 $00 $52 $00
.db $52 $00 $52 $00 $52 $02 $52 $02 $52 $02 $52 $02 $51 $02 $31 $02
.db $31 $00 $43 $04 $53 $00 $54 $00 $54 $00 $54 $00 $54 $00 $54 $00
.db $54 $00 $53 $02 $43 $06 $31 $02 $31 $00 $32 $00 $55 $00 $56 $00
.db $57 $00 $57 $00 $57 $02 $57 $02 $56 $02 $55 $02 $32 $02 $31 $02
.db $58 $00 $36 $00 $33 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $33 $02 $36 $02 $58 $02 $31 $00 $37 $00 $38 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $38 $02 $37 $02 $31 $02
.db $31 $00 $32 $00 $33 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $33 $02 $32 $02 $31 $02 $31 $04 $32 $04 $33 $04 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $33 $06 $32 $06 $31 $06
.db $31 $04 $37 $04 $38 $04 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $38 $06 $37 $06 $31 $06 $58 $04 $36 $04 $33 $04 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $33 $06 $36 $06 $58 $06
.db $31 $04 $32 $04 $59 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $59 $02 $32 $06 $31 $06 $31 $04 $43 $00 $5A $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $5A $02 $43 $02 $31 $06
.db $31 $04 $46 $00 $33 $04 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $33 $06 $46 $02 $31 $06 $49 $00 $32 $04 $5B $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $5B $02 $32 $06 $49 $02
.db $31 $04 $32 $04 $5C $00 $5D $00 $5E $00 $5F $00 $5F $00 $5E $02
.db $5D $02 $5C $02 $32 $06 $31 $06 $31 $04 $4D
.dsb 17,$00
.db $4D $02 $31 $06 $31 $04 $4E
.dsb 17,$00
.db $4E $02 $31 $06 $4F $00 $42 $04 $42 $04 $42 $04 $42 $04 $42 $04
.db $42 $04 $42 $04 $42 $04 $42 $04 $42 $04 $4F $02

; 3rd entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1AFB0 to 1B15F (432 bytes)
_DATA_1AFB0_:
.db $60 $00 $61 $00 $61 $00 $61 $00 $61 $00 $62 $00 $62 $02 $61 $00
.db $61 $00 $61 $00 $61 $00 $60 $02 $63 $00 $64 $00 $65 $00 $65 $00
.db $65 $00 $66 $00 $66 $02 $65 $00 $65 $00 $65 $00 $64 $02 $63 $02
.db $63 $00 $67 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $67 $02 $63 $02 $63 $00 $67 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $67 $02 $63 $02
.db $69 $00 $6A $00 $6B $00 $6B $00 $6C $00 $68 $00 $68 $02 $6C $02
.db $6B $00 $6B $00 $6A $02 $69 $02 $63 $00 $6D $00 $6E $00 $6E $00
.db $6F $00 $68 $00 $68 $02 $6F $02 $6E $02 $6E $02 $6D $02 $63 $02
.db $63 $00 $70 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $70 $02 $63 $02 $63 $00 $67 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $67 $02 $63 $02
.db $63 $00 $67 $00 $10 $00 $10 $00 $71 $00 $68 $00 $68 $02 $71 $02
.db $10 $00 $10 $00 $67 $02 $63 $02 $69 $04 $67 $00 $10 $00 $10 $00
.db $71 $04 $68 $00 $68 $02 $71 $06 $10 $00 $10 $00 $67 $02 $69 $06
.db $63 $00 $67 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $67 $02 $63 $02 $63 $00 $6A $00 $6B $00 $6B $00
.db $6C $00 $68 $00 $68 $02 $6C $02 $6B $00 $6B $00 $6A $02 $63 $02
.db $63 $00 $6D $00 $6E $00 $6E $00 $6F $00 $68 $00 $68 $02 $6F $02
.db $6E $02 $6E $02 $6D $02 $63 $02 $75 $00 $70 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $70 $02 $75 $02
.db $63 $00 $67 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $67 $02 $63 $02 $63 $00 $67 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $67 $02 $63 $02
.db $63 $00 $64 $04 $65 $04 $65 $04 $65 $04 $66 $04 $66 $06 $65 $04
.db $65 $04 $65 $04 $64 $06 $63 $02 $76 $00 $77 $00 $77 $00 $77 $00
.db $77 $00 $78 $00 $78 $02 $77 $00 $77 $00 $77 $00 $77 $00 $76 $02

; 4th entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1B160 to 1B30F (432 bytes)
_DATA_1B160_:
.db $60 $00 $61 $00 $61 $00 $61 $00 $61 $00 $62 $00 $62 $02 $61 $00
.db $61 $00 $61 $00 $61 $00 $60 $02 $63 $00 $64 $00 $65 $00 $65 $00
.db $65 $00 $66 $00 $66 $02 $65 $00 $65 $00 $65 $00 $64 $02 $63 $02
.db $63 $00 $67 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $67 $02 $63 $02 $63 $00 $67 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $67 $02 $63 $02
.db $69 $00 $6A $00 $6B $00 $6B $00 $6C $00 $68 $00 $68 $02 $6C $02
.db $6B $00 $6B $00 $6A $02 $69 $02 $63 $00 $6D $00 $6E $00 $6E $00
.db $6F $00 $68 $00 $68 $02 $6F $02 $6E $02 $6E $02 $6D $02 $63 $02
.db $63 $00 $70 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $70 $02 $63 $02 $63 $00 $67 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $67 $02 $63 $02
.db $63 $00 $67 $00 $10 $00 $10 $00 $71 $00 $68 $00 $68 $02 $71 $02
.db $10 $00 $10 $00 $67 $02 $63 $02 $69 $04 $67 $00 $10 $00 $10 $00
.db $71 $04 $72 $00 $72 $02 $71 $06 $10 $00 $10 $00 $67 $02 $69 $06
.db $63 $00 $67 $00 $10 $00 $10 $00 $10 $00 $73 $00 $73 $02 $10 $00
.db $10 $00 $10 $00 $67 $02 $63 $02 $63 $00 $6A $00 $6B $00 $6B $00
.db $6C $00 $74 $00 $74 $02 $6C $02 $6B $00 $6B $00 $6A $02 $63 $02
.db $63 $00 $6D $00 $6E $00 $6E $00 $6F $00 $68 $00 $68 $02 $6F $02
.db $6E $02 $6E $02 $6D $02 $63 $02 $75 $00 $70 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $70 $02 $75 $02
.db $63 $00 $67 $00 $10 $00 $10 $00 $10 $00 $68 $00 $68 $02 $10 $00
.db $10 $00 $10 $00 $67 $02 $63 $02 $63 $00 $67 $00 $10 $00 $10 $00
.db $10 $00 $68 $00 $68 $02 $10 $00 $10 $00 $10 $00 $67 $02 $63 $02
.db $63 $00 $64 $04 $65 $04 $65 $04 $65 $04 $66 $04 $66 $06 $65 $04
.db $65 $04 $65 $04 $64 $06 $63 $02 $76 $00 $77 $00 $77 $00 $77 $00
.db $77 $00 $78 $00 $78 $02 $77 $00 $77 $00 $77 $00 $77 $00 $76 $02

; 6th entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1B310 to 1B4BF (432 bytes)
_DATA_1B310_:
.db $60 $00 $79 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00
.db $50 $00 $50 $00 $79 $02 $60 $02 $63 $00 $7A $00 $7B
.dsb 13,$00
.db $7B $02 $7A $02 $63 $02 $63 $00 $7C $00 $7D $00 $7E $00 $7F $00
.db $52 $00 $52 $02 $7F $02 $7E $02 $7D $02 $7C $02 $63 $02 $63 $00
.db $7C $00 $00 $00 $80 $00 $81 $00 $54 $00 $54 $00 $81 $02 $80 $02
.db $00 $00 $7C $02 $63 $02 $69 $00 $82 $00 $00 $00 $80 $00 $83 $00
.db $57 $00 $57 $02 $83 $02 $80 $02 $00 $00 $82 $02 $69 $02 $63 $00
.db $84 $00 $85 $00 $80 $00 $86 $00 $34 $00 $34 $00 $86 $02 $80 $02
.db $85 $02 $84 $02 $63 $02 $63 $00 $87 $00 $88 $00 $80 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $80 $02 $88 $02 $87 $02 $63 $02 $63 $00
.db $7C $00 $00 $00 $80 $00 $86 $00 $34 $00 $34 $00 $86 $02 $80 $02
.db $00 $00 $7C $02 $63 $02 $63 $00 $7C $00 $00 $00 $89 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $89 $02 $00 $00 $7C $02 $63 $02 $69 $04
.db $7C $00 $00 $00 $89 $04 $86 $00 $34 $00 $34 $00 $86 $02 $89 $06
.db $00 $00 $7C $02 $69 $06 $63 $00 $7C $00 $00 $00 $80 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $80 $02 $00 $00 $7C $02 $63 $02 $63 $00
.db $87 $04 $88 $04 $80 $00 $86 $00 $34 $00 $34 $00 $86 $02 $80 $02
.db $88 $06 $87 $06 $63 $02 $63 $00 $84 $04 $85 $04 $80 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $80 $02 $85 $06 $84 $06 $63 $02 $75 $00
.db $82 $04 $00 $00 $80 $00 $83 $04 $57 $04 $57 $06 $83 $06 $80 $02
.db $00 $00 $82 $06 $75 $02 $63 $00 $7C $00 $00 $00 $80 $00 $81 $00
.db $54 $00 $54 $00 $81 $02 $80 $02 $00 $00 $7C $02 $63 $02 $63 $00
.db $7C $00 $7D $04 $7E $04 $7F $04 $52 $04 $52 $06 $7F $06 $7E $06
.db $7D $06 $7C $02 $63 $02 $63 $00 $7A $04 $7B $04
.dsb 12,$00
.db $7B $06 $7A $06 $63 $02 $76 $00 $8A $00 $42 $04 $42 $04 $42 $04
.db $42 $04 $42 $04 $42 $04 $42 $04 $42 $04 $8A $02 $76 $02

; 9th entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1B4C0 to 1B66F (432 bytes)
_DATA_1B4C0_:
.db $60 $00 $8B $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00
.db $50 $00 $50 $00 $8B $02 $60 $02 $63 $00 $8C
.dsb 17,$00
.db $8C $02 $63 $02 $63 $00 $8D $00 $8E $00 $52 $00 $52 $00 $52 $00
.db $52 $02 $52 $02 $52 $02 $8E $02 $8D $02 $63 $02 $63 $00 $8F $00
.db $90 $00 $54 $00 $54 $00 $54 $00 $54 $00 $54 $00 $54 $00 $90 $02
.db $8F $02 $63 $02 $69 $00 $91 $00 $92 $00 $57 $00 $57 $00 $57 $00
.db $57 $02 $57 $02 $57 $02 $92 $02 $91 $02 $69 $02 $63 $00 $93 $00
.db $94 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $94 $02
.db $93 $02 $63 $02 $63 $00 $95 $00 $94 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $94 $02 $95 $02 $63 $02 $63 $00 $8F $00
.db $94 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $94 $02
.db $8F $02 $63 $02 $63 $00 $8F $00 $94 $00 $34 $00 $34 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $94 $02 $8F $02 $63 $02 $69 $04 $8F $00
.db $94 $04 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $94 $06
.db $8F $02 $69 $06 $63 $00 $8F $00 $94 $04 $34 $00 $34 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $94 $06 $8F $02 $63 $02 $63 $00 $95 $04
.db $94 $04 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $34 $00 $94 $06
.db $95 $06 $63 $02 $63 $00 $93 $04 $94 $04 $34 $00 $34 $00 $34 $00
.db $34 $00 $34 $00 $34 $00 $94 $06 $93 $06 $63 $02 $75 $00 $91 $04
.db $92 $04 $57 $04 $57 $04 $57 $04 $57 $06 $57 $06 $57 $06 $92 $06
.db $91 $06 $75 $02 $63 $00 $8F $00 $90 $04 $54 $00 $54 $00 $54 $00
.db $54 $00 $54 $00 $54 $00 $90 $06 $8F $02 $63 $02 $63 $00 $8D $04
.db $8E $04 $52 $04 $52 $04 $52 $04 $52 $06 $52 $06 $52 $06 $8E $06
.db $8D $06 $63 $02 $63 $00 $8C $04
.dsb 16,$00
.db $8C $06 $63 $02 $76 $00 $96 $00 $42 $04 $42 $04 $42 $04 $42 $04
.db $42 $04 $42 $04 $42 $04 $42 $04 $96 $02 $76 $02

; 5th entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1B670 to 1B81F (432 bytes)
_DATA_1B670_:
.db $60 $00 $61 $00 $61 $00 $61 $00 $61 $00 $62 $00 $62 $02 $61 $00
.db $61 $00 $61 $00 $61 $00 $60 $02 $63 $00 $97 $00 $98 $00 $99 $00
.db $98 $02 $9A $00 $9A $02 $98 $00 $99 $00 $98 $02 $97 $02 $63 $02
.db $63 $00 $9B $00 $10 $00 $10 $00 $10 $00 $9C $00 $9C $02 $10 $00
.db $10 $00 $10 $00 $9B $02 $63 $02 $63 $00 $9D $00 $10 $00 $10 $00
.db $10 $00 $9E $00 $9E $02 $10 $00 $10 $00 $10 $00 $9D $02 $63 $02
.db $69 $00 $9D $00 $10 $00 $10 $00 $10 $00 $9E $00 $9E $02 $10 $00
.db $10 $00 $10 $00 $9D $02 $69 $02 $63 $00 $9D $00 $9F $00 $A0 $00
.db $A1 $00 $9E $00 $9E $02 $A1 $02 $A0 $02 $9F $02 $9D $02 $63 $02
.db $63 $00 $9D $00 $A2 $00 $A3 $00 $A4 $00 $9E $00 $9E $02 $A4 $02
.db $A3 $02 $A2 $02 $9D $02 $63 $02 $63 $00 $9D $00 $A5 $00 $A6 $00
.db $A7 $00 $9E $00 $9E $02 $A7 $02 $A6 $02 $A5 $02 $9D $02 $63 $02
.db $63 $00 $9D $00 $10 $00 $10 $00 $A8 $00 $A9 $00 $A9 $02 $A8 $02
.db $10 $00 $10 $00 $9D $02 $63 $02 $69 $04 $9D $00 $10 $00 $10 $00
.db $A8 $04 $A9 $04 $A9 $06 $A8 $06 $10 $00 $10 $00 $9D $02 $69 $06
.db $63 $00 $9D $00 $10 $00 $10 $00 $10 $00 $9E $00 $9E $02 $10 $00
.db $10 $00 $10 $00 $9D $02 $63 $02 $63 $00 $9D $00 $10 $00 $10 $00
.db $10 $00 $9E $00 $9E $02 $10 $00 $10 $00 $10 $00 $9D $02 $63 $02
.db $63 $00 $9D $00 $10 $00 $10 $00 $10 $00 $9E $00 $9E $02 $10 $00
.db $10 $00 $10 $00 $9D $02 $63 $02 $75 $00 $9D $00 $10 $00 $10 $00
.db $10 $00 $9E $00 $9E $02 $10 $00 $10 $00 $10 $00 $9D $02 $75 $02
.db $63 $00 $9D $00 $10 $00 $10 $00 $10 $00 $9E $00 $9E $02 $10 $00
.db $10 $00 $10 $00 $9D $02 $63 $02 $63 $00 $9B $04 $10 $00 $10 $00
.db $10 $00 $9C $04 $9C $06 $10 $00 $10 $00 $10 $00 $9B $06 $63 $02
.db $63 $00 $97 $04 $98 $04 $99 $04 $98 $06 $9A $04 $9A $06 $98 $04
.db $99 $04 $98 $06 $97 $06 $63 $02 $76 $00 $77 $00 $77 $00 $77 $00
.db $77 $00 $78 $00 $78 $02 $77 $00 $77 $00 $77 $00 $77 $00 $76 $02

; 8th entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1B820 to 1B9CF (432 bytes)
_DATA_1B820_:
.db $60 $00 $79 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00 $50 $00
.db $50 $00 $50 $00 $79 $02 $60 $02 $63 $00 $AA $00 $AB
.dsb 13,$00
.db $AB $02 $AA $02 $63 $02 $63 $00 $AC $00 $AD $00 $AE $00 $7F $00
.db $52 $00 $52 $02 $7F $02 $AE $02 $AD $02 $AC $02 $63 $02 $63 $00
.db $AF $00 $00 $00 $B0 $00 $81 $00 $54 $00 $54 $00 $81 $02 $B0 $02
.db $00 $00 $AF $02 $63 $02 $69 $00 $AF $00 $00 $00 $B1 $00 $83 $00
.db $57 $00 $57 $02 $83 $02 $B1 $02 $00 $00 $AF $02 $69 $02 $63 $00
.db $AF $00 $B2 $00 $B3 $00 $86 $00 $34 $00 $34 $00 $86 $02 $B3 $02
.db $B2 $02 $AF $02 $63 $02 $63 $00 $AF $00 $B4 $00 $B5 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $B5 $02 $B4 $02 $AF $02 $63 $02 $63 $00
.db $AF $00 $B6 $00 $B7 $00 $86 $00 $34 $00 $34 $00 $86 $02 $B7 $02
.db $B6 $02 $AF $02 $63 $02 $63 $00 $AF $00 $00 $00 $B8 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $B8 $02 $00 $00 $AF $02 $63 $02 $69 $04
.db $AF $00 $00 $00 $B8 $04 $86 $00 $34 $00 $34 $00 $86 $02 $B8 $06
.db $00 $00 $AF $02 $69 $06 $63 $00 $AF $00 $00 $00 $B1 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $B1 $02 $00 $00 $AF $02 $63 $02 $63 $00
.db $AF $00 $00 $00 $B1 $00 $86 $00 $34 $00 $34 $00 $86 $02 $B1 $02
.db $00 $00 $AF $02 $63 $02 $63 $00 $AF $00 $00 $00 $B1 $00 $86 $00
.db $34 $00 $34 $00 $86 $02 $B1 $02 $00 $00 $AF $02 $63 $02 $75 $00
.db $AF $00 $00 $00 $B1 $00 $83 $04 $57 $04 $57 $06 $83 $06 $B1 $02
.db $00 $00 $AF $02 $75 $02 $63 $00 $AF $00 $00 $00 $B0 $04 $81 $00
.db $54 $00 $54 $00 $81 $02 $B0 $06 $00 $00 $AF $02 $63 $02 $63 $00
.db $AC $04 $AD $04 $AE $04 $7F $04 $52 $04 $52 $06 $7F $06 $AE $06
.db $AD $06 $AC $06 $63 $02 $63 $00 $AA $04 $AB $04
.dsb 12,$00
.db $AB $06 $AA $06 $63 $02 $76 $00 $8A $00 $42 $04 $42 $04 $42 $04
.db $42 $04 $42 $04 $42 $04 $42 $04 $42 $04 $8A $02 $76 $02

; 11th entry of Pointer Table from 7118 (indexed by DungeonMap)
; Data from 1B9D0 to 1BFFF (1584 bytes)
_DATA_1B9D0_:
.incbin "Phantasy Star (Japan)_DATA_1B9D0_.inc"

;=======================================================================================================
; Bank 7: $1c000 - $1ffff
;=======================================================================================================
.bank 7 slot 2
.ORG $0000

; Data from 1C000 to 1FFFF (16384 bytes)
.incbin "Phantasy Star (Japan)_DATA_1C000_.inc"

;=======================================================================================================
; Bank 8: $20000 - $23fff
;=======================================================================================================
.bank 8 slot 2
.ORG $0000

; Data from 20000 to 23FFF (16384 bytes)
.incbin "Phantasy Star (Japan)_DATA_20000_.inc"

;=======================================================================================================
; Bank 9: $24000 - $27fff
;=======================================================================================================
.bank 9 slot 2
.ORG $0000

; Data from 24000 to 2712F (12592 bytes)
.incbin "Phantasy Star (Japan)_DATA_24000_.inc"

; Data from 27130 to 27470 (833 bytes)
_DATA_27130_:
.db $9F $01 $02 $03 $04 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $04 $03 $02
.db $03 $01 $9C $09 $04 $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C
.db $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $04 $09 $04
.db $01 $9C $0E $0F $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06
.db $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $04 $0E $04 $01
.db $9C $10 $04 $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C
.db $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $04 $10 $05 $01 $9A
.db $04 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $04 $06 $01 $9A $04 $0A $0B
.db $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B
.db $0C $0D $0A $0B $0C $0D $04 $06 $01 $9A $04 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $04 $06 $01 $9A $04 $0C $0D $0A $0B $0C $0D $0A $0B
.db $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B
.db $04 $06 $01 $9A $04 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $04 $06 $01
.db $9A $04 $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B
.db $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $04 $06 $01 $9A $04 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $04 $06 $01 $9A $04 $0C $0D $0A $0B
.db $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B
.db $0C $0D $0A $0B $04 $06 $01 $9A $04 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $04 $05 $01 $9C $10 $04 $0A $0B $0C $0D $0A $0B $0C $0D $0A
.db $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $04
.db $10 $04 $01 $9C $0E $04 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08
.db $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $04 $0E
.db $04 $01 $9C $09 $04 $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A
.db $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $04 $09 $03
.db $01 $E7 $02 $03 $04 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07
.db $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $04 $03 $02
.db $01 $01 $11 $12 $04 $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C
.db $0D $0A $0B $0C $0D $0A $0B $0C $0D $0A $0B $0C $0D $04 $12 $11
.db $01 $13 $14 $00 $04 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05
.db $06 $07 $08 $05 $06 $07 $08 $05 $06 $07 $08 $05 $06 $04 $00 $14
.db $13 $15 $16 $17 $18 $19 $19 $1A $1B $05 $19 $81 $1C $04 $19 $81
.db $1C $05 $19 $8A $1B $1A $19 $19 $2D $17 $16 $15 $1D $1E $04 $1F
.db $81 $20 $05 $1F $82 $21 $22 $04 $1F $82 $22 $21 $05 $1F $81 $20
.db $04 $1F $82 $1E $1D $04 $23 $82 $24 $25 $06 $23 $81 $26 $06 $23
.db $81 $26 $06 $23 $82 $25 $24 $04 $23 $03 $27 $82 $28 $29 $07 $27
.db $81 $2A $06 $27 $81 $2A $07 $27 $82 $29 $28 $05 $27 $82 $28 $29
.db $07 $27 $82 $2B $2C $06 $27 $82 $2C $2B $07 $27 $82 $29 $28 $02
.db $27 $00 $1C $00 $03 $02 $1D $00 $02 $02 $1E $00 $02 $02 $1E $00
.db $02 $02 $1E $00 $81 $02 $1F $00 $81 $02 $1F $00 $81 $02 $1F $00
.db $81 $02 $1F $00 $81 $02 $1F $00 $81 $02 $1F $00 $81 $02 $1F $00
.db $81 $02 $1F $00 $81 $02 $05 $00 $81 $04 $19 $00 $82 $02 $06 $04
.db $00 $81 $04 $19 $00 $82 $02 $06 $04 $00 $81 $04 $19 $00 $82 $02
.db $06 $03 $00 $02 $04 $19 $00 $81 $02 $02 $06 $1D $00 $03 $02 $1D
.db $00 $82 $02 $00 $02 $02 $12 $00 $81 $02 $05 $00 $02 $02 $03 $00
.db $03 $02 $10 $00 $10 $02 $13 $00 $81 $02 $06 $00 $02 $02 $17 $00
.db $81 $02 $07 $00 $02 $02 $16 $00 $02 $02 $07 $00 $02 $02 $02 $00
.db $00

.org $27471-$24000
.section "Tile data 2" overwrite
.incbin "Tiles\27471compr.dat"
.ends
; followed by
.org $2778b-$24000
.section "Mansion tilemap" overwrite
TilemapMansion:
.incbin "Tilemaps\2778btilemap.dat"
.ends
; followed by
.org $27b14-$24000
.section "Tile data 3" overwrite
PaletteMansion:
.db $0B,$00,$3F,$0F,$06,$01,$03,$02,$00,$00,$00,$00,$00,$00,$00,$00 ; palette
TilesMansion:
.incbin "Tiles\27b24compr.dat"
.ends
;.org $27f3e-$24000
; Blank until end of bank

;=======================================================================================================
; Bank 10: $28000 - $2bfff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 10 slot 2
.ORG $0000

.orga $8000
.section "Tile data 4" overwrite
TilesBat:
.incbin "Tiles\28000compr.dat"
TilesReaper:
.incbin "Tiles\28d7ecompr.dat"
TilesEvilDead:
.incbin "Tiles\29b85compr.dat"
TilesMedusa:
.incbin "Tiles\2a044compr.dat"
TilesSandWorm:
.incbin "Tiles\2aa8ccompr.dat"
TilesWingEye:
.incbin "Tiles\2b7e4compr.dat"
.ends
;.org $2bff9
; Blank until end of bank

;=======================================================================================================
; Bank 11: $2c000 - $2ffff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 11 slot 2
.org 0
.section "Tile data 5" overwrite
PaletteGoldDragon:
.db $30,$00,$3F,$30,$38,$03,$0B,$0F,$01,$02,$03,$07,$25,$2A,$2F,$20 ; palette
TilesGoldDragon:
.incbin "Tiles\2c010compr.dat"
TilesGoldDragonHead: ; for Gold Dragon
.incbin "Tiles\2caebcompr.dat" ; dragon head + flame
.incbin "Tiles\2d901compr.dat" ; fireball?
.incbin "Tiles\2daf0compr.dat" ; ???
TilesFly:
.incbin "Tiles\2dcdacompr.dat" ; fly thing
TilesSorceror:
.incbin "Tiles\2e25fcompr.dat" ; ???
TilesLassic:
.incbin "Tiles\2ed79compr.dat" ; ???
TilesSlime:
.incbin "Tiles\2f869compr.dat" ; ball enemy
.ends
;.org 2fe3e
; Blank until end of bank

;=======================================================================================================
; Bank 12: $30000 - $33fff - sound engine
;=======================================================================================================
.bank 12 slot 2
.ORG $0000
.section "Sound engine initialisation" overwrite
SoundInitialise:       ; 0e/8000
    push hl
    push de
    push bc
      call _ZeroC003toC00D
      ld b,$0f       ; counter (15 columns below)
      ld hl,_RAM_c00e_    ; start
      xor a          ; 0 -> a
-:    ld (hl),a      ; 0 -> c00e,c02e,c04e ... c1ee
      ld de,$0018
      add hl,de
      ld (hl),a      ; 0 -> c026,c046,c066 ... c206
      inc hl
      ld (hl),a      ; 0 -> c027,c047,c067 ... c207
      inc hl
      ld (hl),a      ; 0 -> c028,c048,c068 ... c208
      ld de,$0006
      add hl,de
      djnz -
    pop bc
    pop de
    pop hl
; fall through
SilencePSGandFM:       ; 0e/801f
    push hl
    push bc
      ld hl,_SilencePSGData
      ld c,Port_PSG
      ld b,_sizeof__SilencePSGData
    otir
    pop bc
    pop hl

SilenceFM:
    push bc
    push de
      ld b,$06       ; 6 channels
      ld d,$20       ; YM2413 registers $20-$26
-:    ld a,d
      inc d
      call ZeroYM2413Channel
      djnz -
    pop de
    pop bc
    ret ; from SoundInitialise, SilencePSG or SilenceFM

_ZeroC003toC00D:       ; Zero $c003-$c00d
    xor a
    ld hl,_RAM_C003_
    ld (hl),a
    ld de,_RAM_C003_ + 1
    ld bc,$000A
    ldir
    ret

; Data from 3004A to 30051 (8 bytes)
_SilencePSGData:
.db $80,$00            ; ch 0 freq $000
.db $A0,$00            ; ch 1 freq $000
.db $C0,$00            ; ch 2 freq $000
.db $E5,$FF            ; ch 3 freq %101 then %111 = white, ch 2
.ends
; followed by
.orga $8052
.section "Sound update" overwrite
SoundUpdate:           ; 0e/8052
    ld a,(HasFM)
    or a
    ex af,af'
    ld hl,_RAM_C00C_
    exx
    call _LABEL_30135_
    call _LABEL_3015C_
    call _LABEL_30466_
    call _LABEL_30110_
    ld a,(HasFM)
    or a
    jp z,SoundUpdatePSG
    ; FM music:
    ld a,(_RAM_C002_)
    or a
    jp m,++
    ld ix,_RAM_C00E_
    ld b,$0A
--: push bc
      ld a,$04
      cp b
      jr z,+
      bit 7,(ix+0)
      call nz,_LABEL_30664_
-:    ld de,$0020
      add ix,de
    pop bc
    djnz --
    ret

+:  bit 7,(ix+0)
    call nz,_LABEL_30608_
    jr -

++:  ld ix,_RAM_C0EE_
    ld b,$08
--: push bc
      ld a,$01
      cp b
      jr z,+
      bit 7,(ix+0)
      call nz,_LABEL_30664_
-:    ld de,$0020
      add ix,de
    pop bc
    djnz --
    ret

+:  bit 7,(ix+0)
    call nz,_LABEL_30608_
    jr -

SoundUpdatePSG:
    ld a,(_RAM_C002_)
    or a
    jp m,++
    ld ix,_RAM_C06E_
    ld b,$07
--: push bc
      ld a,$04
      cp b
      jr z,+
      bit 7,(ix+0)
      call nz,_LABEL_30BD9_
-:    ld de,$0020
      add ix,de
    pop bc
    djnz --
    ret

+:  bit 7,(ix+0)
    call nz,_LABEL_30B37_
    jr -

++:  ld ix,_RAM_C0EE_
    ld b,$08
--: push bc
      ld a,$01
      cp b
      jr z,+
      bit 7,(ix+0)
      call nz,_LABEL_30BD9_
-:    ld de,$0020
      add ix,de
    pop bc
    djnz --
    ret

+:  bit 7,(ix+0)
    call nz,_LABEL_30B37_
    jr -

.ends
; followed by
.orga $8110
.section "More music code" overwrite
_LABEL_30110_:
    ld hl,_RAM_C12E_
    bit 7,(hl)
    ret z
    ld a,(_RAM_C10E_)
    or a
    jp m,++
    bit 6,(hl)
    jr z,+
    inc hl
    ld a,(hl)
    cp $E0
    jr nz,+
    ld hl,_RAM_C06E_
    set 2,(hl)
+:  ld hl,_RAM_C0AE_
    set 2,(hl)
    ret

++:  set 2,(hl)
    ret

_LABEL_30135_:
    ld hl,_RAM_C001_
    ld a,(hl)
    or a
    ret z
    dec (hl)
    ret nz
    ld a,(_RAM_C002_)
    or a
    res 7,a
    ld (hl),a
    ld hl,_RAM_C018_
    ld de,$0020
    ld b,$07
    jp m,_LABEL_30157_
    ld hl,_RAM_C158_
    ld de,$0020
    ld b,$05
_LABEL_30157_:
    inc (hl)
    add hl,de
    djnz _LABEL_30157_
    ret

_LABEL_3015C_:
    ld a,(_RAM_C00A_)
    or a
    ret z
    jp m,_LABEL_301D0_
    ld a,(_RAM_C00B_)
    dec a
    jr z,+
    ld (_RAM_C00B_),a
    ret

+:  ld a,(_RAM_C009_)
    ld (_RAM_C00B_),a
    ld a,(_RAM_C00A_)
    inc a
    cp $0C
    ld (_RAM_C00A_),a
    jr nz,++
    xor a
    ld (_RAM_C00A_),a
    ld a,(_RAM_C002_)
    cp $7F
    jr nz,+
    ld a,$85
    jp _LABEL_304AD_

+:  or a
    jp p,SoundInitialise
    ld a,(_RAM_C006_)
    or a
    ret z
    jp _LABEL_30218_

++:  ld ix,_RAM_C00E_
    ld de,$0020
    ld b,$06
    ld a,(_RAM_C002_)
    or a
    jp p,_LABEL_301B1_
    ld ix,_RAM_C14E_
    ld b,$04
_LABEL_301B1_:
    ld a,(ix+8)
    inc a
    cp $10
    jr z,+
    ld (ix+8),a
    ld a,(HasFM)
    or a
    call nz,++
+:  add ix,de
    djnz _LABEL_301B1_
    ret

++:  bit 2,(ix+0)
    ret nz
    jp _LABEL_30748_

_LABEL_301D0_:
    ld a,(_RAM_C00B_)
    dec a
    jr z,+
    ld (_RAM_C00B_),a
    ret

+:  ld a,$0A
    ld (_RAM_C00B_),a
    ld a,(_RAM_C00A_)
    inc a
    cp $8B
    ld (_RAM_C00A_),a
    jr nz,+
    xor a
    ld (_RAM_C00A_),a
    ld hl,_RAM_C0CE_
    res 2,(hl)
    ret

+:  ld ix,_RAM_C00E_
    ld de,$0020
    ld b,$06
-:  ld a,(ix+8)
    dec a
    jp m,+
    cp (ix+23)
    jr c,+
    ld (ix+8),a
    ld a,(HasFM)
    or a
    call nz,_LABEL_30748_
+:  add ix,de
    djnz -
    ret

; 5th entry of Jump Table from 3045C (indexed by NewMusic)
_LABEL_30218_:
    call SilencePSGandFM
    ld a,(_RAM_C005_)
    ld (_RAM_C002_),a
    ld a,$80
    ld (_RAM_C00A_),a
    ld a,$0A
    ld (_RAM_C00B_),a
    ld hl,_RAM_C0CE_
    set 2,(hl)
    push ix
      ld ix,_RAM_C00E_
      ld b,$06
      ld de,$0020
-:    ld a,(ix+8)
      ld (ix+23),a
      ld a,$09
      ld (ix+8),a
      add ix,de
      djnz -
    pop ix
    jp _LABEL_305F9_

; 3rd entry of Jump Table from 3045C (indexed by NewMusic)
_LABEL_3024F_:
    ld a,$0A
    ld (_RAM_C00B_),a
    ld (_RAM_C009_),a
_LABEL_30257_:
    ld a,$03
    ld (_RAM_C00A_),a
    ld a,(_RAM_C002_)
    or a
    jp m,+
    xor a
    ld (_RAM_C0CE_),a
+:  ld a,$FF
    out (Port_PSG),a
    xor a
    ld (_RAM_C1CE_),a
    jp _LABEL_305F9_
.ends
.section "Output 0 to YM2413 channel in a" overwrite
ZeroYM2413Channel: ; $8272
    out (FMAddress),a
    call SoundFMDelay
    xor a
    out (FMData),a
    ret
.ends
.org $3027b-$30000
.section "Yet more music code" overwrite
_LABEL_3027B_:
    xor a
    ld (_RAM_C12E_),a
    ld a,$DF
    out (Port_PSG),a
    ld a,$FF
    out (Port_PSG),a
    ld a,$25
    out (FMAddress),a
    call SoundFMDelay
    xor a
    out (FMData),a
    ret

_LABEL_30292_:
    push bc
      ld b,$12
      ld hl,_DATA_30312_
      ld c,FMData
-:    dec c
      outi
      inc c
      call SoundFMDelay
      outi
      call SoundFMDelay
      jr nz,-
    pop bc
    ret

; 4th entry of Jump Table from 3045C (indexed by NewMusic)
_LABEL_302AA_:
    ld a,(_RAM_C002_)
    cp $7F
    jp z,_LABEL_3024F_
    ld a,$80
    ld (_RAM_C006_),a
    jp _LABEL_3024F_

; 1st entry of Jump Table from 3045C (indexed by NewMusic)
_LABEL_302BA_:
    xor a
    ld (_RAM_C10E_),a
    ld (_RAM_C0EE_),a
    ld hl,_RAM_C08E_
    call _LABEL_30307_
    ld hl,_RAM_C1AE_
    call _LABEL_30307_
    ex af,af'
    jr nz,+
    ex af,af'
    ld hl,_SilencePSGData
    ld c,Port_PSG
    ld b,$08
    otir
    jp _LABEL_305F9_

+:  ex af,af'
    ld a,$25
    call ZeroYM2413Channel
    call SoundFMDelay
    ld a,$24
    call ZeroYM2413Channel
    ld a,(_RAM_C002_)
    or a
    jp m,_LABEL_305F9_
    push ix
      ld ix,_RAM_C08E_
      call _LABEL_30748_
      ld ix,_RAM_C0AE_
      call _LABEL_30748_
    pop ix
    jp _LABEL_305F9_

_LABEL_30307_:
    ld de,$0020
    ld b,$03
-:  res 2,(hl)
    add hl,de
    djnz -
    ret

; Data from 30312 to 30323 (18 bytes)
_DATA_30312_:
.db $16 $20 $17 $B0 $18 $01 $26 $05 $27 $01 $28 $01 $36 $00 $37 $51
.db $38 $02

; Data from 30324 to 30337 (20 bytes)
_DATA_30324_:
.db $00 $00 $00 $00 $00 $00 $03 $00 $80 $80 $00 $00 $80 $80 $00 $00
.db $00 $7F $7F $00

; Data from 30338 to 3035F (40 bytes)
_DATA_30338_:
.db $A6 $A3 $0B $A4 $70 $A4 $D5 $A4 $3A $A5 $9F $A5 $FB $A5 $57 $A6
.db $AA $A6 $06 $A7 $74 $A7 $D9 $A7 $2C $A8 $88 $A8 $F6 $A8 $5B $A9
.db $5B $A9 $C0 $A9 $25 $AA $81 $AA

; Pointer Table from 30360 to 303BF (48 entries,indexed by NewMusic)
_DATA_30360_:
.dw _DATA_32AA8_ _DATA_32ADF_ _DATA_32B1A_ _DATA_32B63_ _DATA_32BC0_ _DATA_32C23_ _DATA_32C6C_ _DATA_32CD1_
.dw _DATA_32C6C_ _DATA_32D1F_ _DATA_32D81_ _DATA_32DBE_ _DATA_32DED_ _DATA_32E1B_ _DATA_32E74_ _DATA_32EC3_
.dw _DATA_32F23_ _DATA_32F59_ _DATA_32FBB_ _DATA_32FE5_ _DATA_3300A_ _DATA_33027_ _DATA_3303C_ _DATA_33046_
.dw _DATA_3308F_ _DATA_33127_ _DATA_3316A_ _DATA_33191_ _DATA_331B7_ _DATA_331F9_ _DATA_33226_ _DATA_33247_
.dw _DATA_3327B_ _DATA_332B4_ _DATA_332E5_ _DATA_3331C_ _DATA_3331C_ _DATA_33354_ _DATA_33386_ _DATA_333DF_
.dw _DATA_33450_ _DATA_334C8_ _DATA_33559_ _DATA_335A3_ _DATA_33606_ _DATA_33671_ _DATA_336BE_ _DATA_33715_

; Pointer Table from 303C0 to 303F1 (25 entries,indexed by NewMusic)
_DATA_303C0_:
.dw _DATA_3300A_ _DATA_33027_ _DATA_3303C_ _DATA_33046_ _DATA_33046_ _DATA_32366_ _DATA_323CB_ _DATA_32430_
.dw _DATA_32495_ _DATA_324FA_ _DATA_3255F_ _DATA_325C4_ _DATA_32617_ _DATA_3267C_ _DATA_326D8_ _DATA_32734_
.dw _DATA_32799_ _DATA_327FE_ _DATA_3285A_ _DATA_328B6_ _DATA_3291B_ _DATA_3291B_ _DATA_32980_ _DATA_329E5_
.dw _DATA_32A4A_

; Pointer Table from 303F2 to 30451 (48 entries,indexed by NewMusic)
_DATA_303F2_:
.dw _DATA_32A9E_ _DATA_32ACC_ _DATA_32B07_ _DATA_32B50_ _DATA_32BAD_ _DATA_32C10_ _DATA_32C59_ _DATA_32CC7_
.dw _DATA_32C59_ _DATA_32D0C_ _DATA_32D6E_ _DATA_32DAB_ _DATA_32DDA_ _DATA_32E08_ _DATA_32E61_ _DATA_32EB0_
.dw _DATA_32F10_ _DATA_32F46_ _DATA_32FB1_ _DATA_32FD2_ _DATA_33000_ _DATA_3301D_ _DATA_3303C_ _DATA_3303C_
.dw _DATA_33073_ _DATA_33114_ _DATA_33157_ _DATA_33187_ _DATA_331A4_ _DATA_331E6_ _DATA_3321C_ _DATA_33234_
.dw _DATA_33268_ _DATA_332A1_ _DATA_332D2_ _DATA_33312_ _DATA_33312_ _DATA_33341_ _DATA_33373_ _DATA_333CC_
.dw _DATA_3343D_ _DATA_334B5_ _DATA_33546_ _DATA_33590_ _DATA_335F3_ _DATA_3365E_ _DATA_336AB_ _DATA_33702_

; Pointer Table from 30452 to 3045B (5 entries,indexed by NewMusic)
_DATA_30452_:
.dw _DATA_33000_ _DATA_3301D_ _DATA_3303C_ _DATA_3303C_ _DATA_3303C_

; Jump Table from 3045C to 30465 (5 entries,indexed by NewMusic)
_DATA_3045C_:
.dw _LABEL_302BA_ _LABEL_3027B_ _LABEL_3024F_ _LABEL_302AA_ _LABEL_30218_

_LABEL_30466_:
    ld a,(NewMusic)
    bit 7,a
    jp z,SoundInitialise
    cp $A0
    jr c,_LABEL_304AD_
    cp $D0
    jp c,_LABEL_30524_
    cp $D5
    jp c,+
    cp $DA
    jp nc,SoundInitialise
    sub $D5
    add a,a
    ld c,a
    ld b,$00
    ld hl,_DATA_3045C_
    add hl,bc
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    jp (hl)

+:  ld hl,_DATA_30452_
    sub $D0
    ex af,af'
    jr nz,+
    ld hl,_DATA_303C0_
+:  ex af,af'
    call _LABEL_305FF_
    ld de,_RAM_C12E_
    ld a,$FF
    out (Port_PSG),a
    ld a,$DF
    out (Port_PSG),a
    jp _LABEL_305C6_

_LABEL_304AD_:
    cp $95
    jp nc,_LABEL_305F9_
    sub $81
    ret m
    ld b,$00
    ld c,a
    ld hl,_DATA_30324_
    add hl,bc
    push af
      ld a,(_RAM_C002_)
      and $7F
      ld (_RAM_C005_),a
      ld a,(hl)
      ld (_RAM_C001_),a
      ld (_RAM_C002_),a
      push af
        ld a,(_RAM_C00A_)
        or a
        jp p,+
        ld ix,_RAM_C00E_
        ld de,$0020
        ld b,$06
-:      ld a,(ix+23)
        ld (ix+8),a
        add ix,de
        djnz -
+:      call _ZeroC003toC00D
        call SilencePSGandFM
      pop af
      ex af,af'
      jr nz,++
      ex af,af'
      ld de,_RAM_C14E_
      or a
      jp m,+
      call SoundInitialise
      ld de,$C06E
+:    ld hl,_DATA_30338_
      jr +++

++:   ex af,af'
      call _LABEL_30292_
      ld de,_RAM_C14E_
      or a
      jp m,+
      ld de,_RAM_C00E_
      call SoundInitialise
      jr ++

+:    call SilenceFM
++:   ld hl,$83CA
+++:pop af
    call _LABEL_305FF_
    jp _LABEL_305C6_

_LABEL_30524_:
    sub $A0
    ld hl,_DATA_30360_
    ex af,af'
    jr z,+
    ld hl,_DATA_303F2_
+:  ex af,af'
    call _LABEL_305FF_
    ld h,b
    ld l,c
    inc hl
    inc hl
    ld a,(hl)
    ex af,af'
    jr z,++++
    ex af,af'
    cp $10
    jr z,+
    cp $14
    jr z,++
    ld de,_RAM_C10E_
    ld a,$25
    jr +++

+:  call SoundInitialise
    ld de,_RAM_C00E_
    jr _LABEL_305C6_

++:  ld de,_RAM_C0EE_
    ld a,$24
    ld hl,_RAM_C08E_
    set 2,(hl)
+++:ld hl,_RAM_C0AE_
    set 2,(hl)
    call ZeroYM2413Channel
    jr _LABEL_305C6_

++++:
    ex af,af'
    cp $C0
    jr z,++
    cp $E0
    jr z,+
    cp $A0
    jr z,+++
    push bc
      call SoundInitialise
    pop bc
    ld de,_RAM_C06E_
    jr _LABEL_305C6_

+:  ld a,$DF
    out (Port_PSG),a
    ld hl,_RAM_C0CE_
    set 2,(hl)
    ld a,$E7
    out (Port_PSG),a
++:  ld de,_RAM_C10E_
    jr ++++

+++:ld de,$0009
    add hl,de
    ld a,(hl)
    cp $E0
    jr nz,+
    ld a,$E7
    out (Port_PSG),a
    ld hl,_RAM_C0CE_
    set 2,(hl)
    ld hl,_RAM_C1CE_
    set 2,(hl)
    ld a,$DF
    out (Port_PSG),a
+:  ld de,_RAM_C0EE_
    ld hl,_RAM_C08E_
    set 2,(hl)
    ld hl,_RAM_C18E_
    set 2,(hl)
++++:
    ld a,$FF
    out (Port_PSG),a
    ld hl,_RAM_C0AE_
    set 2,(hl)
    ld hl,_RAM_C1AE_
    set 2,(hl)
_LABEL_305C6_:
    ld h,b
    ld l,c
    ld b,(hl)
    inc hl
-:  push bc
      push hl
      pop ix
      ld bc,$0009
      ldir
      ld a,$20
      ld (de),a
      inc de
      ld a,$01
      ld (de),a
      inc de
      xor a
      ld (de),a
      inc de
      ld (de),a
      inc de
      ld (de),a
      push hl
        ld hl,$0013
        add hl,de
        ex de,hl
      pop hl
      ld bc,+  ; Overriding return address
      push bc
      ld a,(HasFM)
      or a
      jp nz,_LABEL_30748_
      jp _LABEL_30CCE_

+:  pop bc
    djnz -
_LABEL_305F9_:
    ld a,MusicStop
    ld (NewMusic),a
    ret

_LABEL_305FF_:
    add a,a
    ld b,$00
    ld c,a
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    ret

_LABEL_30608_:
    inc (ix+11)
    ld a,(ix+10)
    sub (ix+11)
    jr nz,+
    call ++
    bit 2,(ix+0)
    ret nz
    ld a,$0E
    out (FMAddress),a
    ld a,(ix+16)
    or $20
    out (FMData),a
    ret

+:  cp $02
    ret nz
    ld a,$0E
    out (FMAddress),a
    call SoundFMDelay
    ld a,$20
    out (FMData),a
    ret

++:  ld e,(ix+3)
    ld d,(ix+4)
-:  ld a,(de)
    inc de
    cp $E0
    jp nc,++
    cp $7F
    jp c,_LABEL_3080B_
    bit 5,a
    jr z,+
    or $01
+:  bit 2,a
    jr z,+
    or $10
+:  ld (ix+16),a
    jp _LABEL_307FD_

++: ld hl,+  ; Overriding return address
    jp _LABEL_308AE_

+:  inc de
    jp -

_LABEL_30664_:
    inc (ix+11)
    ld a,(ix+10)
    sub (ix+11)
    call z,_LABEL_307B9_
    ld (_RAM_C00C_),a
    cp $80
    jp z,_LABEL_306CD_
    bit 5,(ix+0)
    jp z,_LABEL_306CD_
    exx
    ld (hl),$80
    exx
    bit 3,(ix+0)
    jp nz,++
    ld a,(ix+17)
    bit 7,a
    jr z,+
    add a,(ix+14)
    jr c,++++
    dec (ix+15)
    dec (ix+15)
    jp +++

+:  add a,(ix+14)
    jr nc,++++
    inc (ix+15)
    inc (ix+15)
    jp +++

++:  ld a,(ix+17)
    bit 7,a
    jr z,+
    add a,(ix+14)
    jr c,++++
    dec (ix+15)
    jr +++

+:  add a,(ix+14)
    jr nc,++++
    inc (ix+15)
+++:set 1,(ix+7)
++++:
    ld (ix+14),a
_LABEL_306CD_:
    bit 2,(ix+0)
    ret nz
    ld a,(ix+19)
    cp $1F
    ret z
    ld a,(_RAM_C00C_)
    bit 0,(ix+7)
    jr nz,+
    cp $02
    jp c,_LABEL_3075E_
+:  or a
    jp m,+
    bit 7,(ix+20)
    ret nz
    ld a,(ix+6)
    dec a
    jp p,++
    ret

+:  ld a,(ix+6)
    dec a
++:  ld l,(ix+14)
    ld h,(ix+15)
    jp m,+
    ex de,hl
    ld hl,_DATA_33805_
    call _LABEL_3076B_
    call _LABEL_30778_
+:  bit 3,(ix+0)
    call nz,_LABEL_30855_
    ld c,FMData
    ld a,(ix+1)
    out (FMAddress),a
    add a,$10
    call SoundFMDelay
    out (c),l
    call SoundFMDelay
    exx
    bit 7,(hl)
    exx
    out (FMAddress),a
    jr nz,+
    bit 0,(ix+7)
    jr z,+
    bit 1,(ix+7)
    ret z
    res 1,(ix+7)
+:  bit 2,(ix+7)
    jr z,+
    set 5,h
+:  out (c),h
    ret

_LABEL_30748_:
    ld a,(ix+1)
    add a,$20
    out (FMAddress),a
    ld a,(ix+7)
    and $F0
    ld c,a
    ld a,(ix+8)
    and $0F
    or c
    out (FMData),a
    ret

_LABEL_3075E_:
    ld a,(ix+1)
    add a,$10
    call ZeroYM2413Channel
    ld (ix+19),$1F
    ret

_LABEL_3076B_:
    ld c,a
    ld b,$00
    add hl,bc
    add hl,bc
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ret

-:    ld (ix+13),a
_LABEL_30778_:
      push hl
        ld c,(ix+13)
        ld b,$00
        add hl,bc
        ld c,l
        ld b,h
      pop hl
      ld a,(bc)
      bit 7,a
      jp z,+++
      cp $83
      jr z,+
      cp $80
      jr z,++
      ld a,$FF
      ld (ix+20),a
    pop hl
    ret

+:    inc bc
      ld a,(bc)
      jr -

++:   xor a
      jr -

+++:  inc (ix+13)
      ld l,a
      ld h,$00
      add hl,de
      ld a,(HasFM)
      or a
      jr z,+
      ld a,h
      cp (ix+16)
      jr z,+
      set 1,(ix+7)
+:    ld (ix+16),a
      ret

_LABEL_307B9_:
    ld e,(ix+3)
    ld d,(ix+4)
_LABEL_307BF_:
    ld a,(de)
    inc de
    cp $E0
    jp nc,_LABEL_308AB_
    bit 3,(ix+0)
    jp nz,_LABEL_30834_
    cp $80
    jp c,_LABEL_3080B_
    jr nz,+
+:  call _LABEL_30894_
    ld a,(hl)
    ld (ix+14),a
    inc hl
    ld a,(hl)
    ld (ix+15),a
_LABEL_307E0_:
    bit 5,(ix+0)
    jp z,_LABEL_307FD_
    ld a,(de)
    inc de
    ld (ix+18),a
    ld (ix+17),a
    bit 3,(ix+0)
    ld a,(de)
    jr nz,+
    ld (ix+17),a
    inc de
    ld a,(de)
    jr +

_LABEL_307FD_:
    ld a,(de)
    or a
    jp p,+
    ld a,(ix+21)
    ld (ix+10),a
    jr _LABEL_3081B_

+:  inc de
_LABEL_3080B_:
    ld b,(ix+2)
    dec b
    jr z,+
    ld c,a
-:  add a,c
    djnz -
+:  ld (ix+10),a
    ld (ix+21),a
_LABEL_3081B_:
    xor a
    ld (ix+12),a
    ld (ix+13),a
    ld (ix+11),a
    ld (ix+19),a
    ld (ix+20),a
    ld (ix+3),e
    ld (ix+4),d
    ld a,$80
    ret

_LABEL_30834_:
    ld h,a
    ld a,(de)
    inc de
    ld l,a
    ld a,(ix+5)
    or a
    jr z,+++
    jp p,+
    add a,l
    jr c,++
    dec h
    jr ++

+:  add a,l
    jr nc,++
    inc h
++:  ld l,a
+++:ld (ix+14),l
    ld (ix+15),h
    jp _LABEL_307E0_

_LABEL_30855_:
    push de
      ld a,h
      or a
      jr z,+
      cp $02
      ld a,$12
      jr c,++
      srl h
      rr l
      ld a,$10
      jr ++

+:    ld a,l
      or a
      jp z,+++
      ld bc,$0400
-:    rlca
      inc c
      jr c,+
      djnz -
+:    ld b,c
      ld a,$12
-:    inc a
      inc a
      sla l
      rl h
      djnz -
++:   ld de,$0757
      ex de,hl
      or a
      sbc hl,de
      bit 1,h
      jr z,+
      set 0,h
+:    ld d,a
      ld e,$00
      add hl,de
+++:pop de
    ret

_LABEL_30894_:
    sub $80
    jr z,+
    add a,(ix+5)
+:  ld hl,$8CDB
    ex af,af'
    jr z,+
    ld hl,_DATA_30D6D_
+:  ex af,af'
    ld c,a
    ld b,$00
    add hl,bc
    add hl,bc
    ret

_LABEL_308AB_:
    ld hl,+  ; Overriding return address
_LABEL_308AE_:
    push hl
    sub $EE
    ld hl,_DATA_308C2_
    add a,a
    ld c,a
    ld b,$00
    add hl,bc
    ld c,(hl)
    inc hl
    ld h,(hl)
    ld l,c
    jp (hl)

+:  inc de
    jp _LABEL_307BF_

; Jump Table from 308C2 to 308E5 (18 entries,indexed by unknown)
_DATA_308C2_:
.dw _LABEL_308F0_ _LABEL_30921_ _LABEL_30939_ _LABEL_308E6_ _LABEL_30A38_ _LABEL_30977_ _LABEL_309A9_ _LABEL_3098B_
.dw _LABEL_309C6_ _LABEL_30B1C_ _LABEL_30AEE_ _LABEL_30B09_ _LABEL_30961_ _LABEL_30950_ _LABEL_309CC_ _LABEL_30A29_
.dw _LABEL_3091C_ _LABEL_308F8_

; 4th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_308E6_:
    ld a,(de)
    ld (_RAM_C009_),a
    ld (_RAM_C00B_),a
    jp _LABEL_30257_

; 1st entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_308F0_:
    ld a,(de)
    add a,(ix+2)
    ld (ix+2),a
    ret

; 18th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_308F8_:
    ld a,(ix+1)
    add a,$10
    out (FMAddress),a
    call SoundFMDelay
    xor a
    out (FMData),a
    call SoundFMDelay
    ld h,d
    ld l,e
    ld b,$08
    ld c,FMData
-:  out (FMAddress),a
    inc a
    call SoundFMDelay
    outi
    jr nz,-
    ld d,h
    ld e,l
    dec de
    ret

; 17th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_3091C_:
    ld a,(HasFM)
    or a
    ret z
; 2nd entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30921_:
    ld a,(_RAM_C00A_)
    or a
    jp m,+
    ld a,(de)
    add a,(ix+8)
    jp +++

+:  ld a,(de)
    add a,(ix+23)
    and $0F
    ld (ix+23),a
    ret

; 3rd entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30939_:
    ld a,(de)
    cp $01
    jr z,+
    res 0,(ix+7)
    res 1,(ix+7)
    ret

+:  set 0,(ix+7)
    set 1,(ix+7)
    ret

; 14th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30950_:
    ex af,af'
    jr nz,+
    ex af,af'
    ld a,(de)
    inc de
    jr ++

+:  inc de
    ld a,(de)
++:  add a,(ix+5)
    ld (ix+5),a
    ret

; 13th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30961_:
    ld a,(de)
    ld (ix+2),a
    ret

+++:and $0F
    ld (ix+8),a
    ex af,af'
    jp nz,+
    ex af,af'
    jp _LABEL_30CCE_

+:  ex af,af'
    jp _LABEL_30748_

; 6th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30977_:
    ld a,(de)
    or $E0
    out (Port_PSG),a
    or $FC
    inc a
    jr nz,+
    res 6,(ix+0)
    ret

+:  set 6,(ix+0)
    ret

; 8th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_3098B_:
    ex af,af'
    jr nz,+
    ex af,af'
    ld a,(de)
    inc de
    cp $80
    ret z
    ld (ix+7),a
    ret

+:  ex af,af'
    inc de
    ld a,(de)
    cp $04
    ret z
    ld (ix+7),a
    ld a,(_RAM_C00A_)
    or a
    ret nz
    jp _LABEL_30748_

; 7th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_309A9_:
    ld a,(de)
    ld (ix+6),a
    ret

; Data from 309AE to 309C5 (24 bytes)
.db $06 $00 $0E $1C $DD $E5 $E1 $09 $7E $B7 $20 $06 $1A $3D $77 $13
.db $13 $C9 $13 $35 $28 $02 $13 $C9

; 9th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_309C6_:
    ex de,hl
    ld e,(hl)
    inc hl
    ld d,(hl)
    dec de
    ret

; 15th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_309CC_:
    ld a,(de)
    cp $01
    jr nz,++
    set 5,(ix+0)
    ld a,(ix+1)
    ex af,af'
    jr nz,+
    ex af,af'
    ld a,(ix+8)
    or a
    ret z
    dec (ix+8)
    dec (ix+8)
    ret

+:  ex af,af'
    cp $13
    ret nc
    dec (ix+8)
    dec (ix+8)
    ld a,(ix+7)
    ld (ix+22),a
    ld (ix+7),$53
    jp _LABEL_30748_

++:  res 5,(ix+0)
    ld a,(ix+1)
    ex af,af'
    jr nz,+
    ex af,af'
    ld a,(ix+8)
    or a
    ret z
    inc (ix+8)
    inc (ix+8)
    ret

+:  ex af,af'
    cp $13
    ret nc
    inc (ix+8)
    inc (ix+8)
    ld a,(ix+22)
    ld (ix+7),a
    jp _LABEL_30748_

; 16th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30A29_:
    ld a,(de)
    cp $01
    jr nz,+
    set 3,(ix+0)
    ret

+:  res 3,(ix+0)
    ret

; 5th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30A38_:
    ld hl,_RAM_C12E_
    res 2,(hl)
    xor a
    ld (_RAM_C008_),a
    ld (ix+0),a
    ex af,af'
    jp nz,_LABEL_30A9D_
    ex af,af'
    ld a,(ix+1)
    add a,$1F
    out (Port_PSG),a
    ld a,$E5
    out (Port_PSG),a
    ld a,(_RAM_C08E_)
    and $80
    jr z,+
    ld hl,_RAM_C09C_
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,(_RAM_C08F_)
    call _LABEL_30C79_
    ld hl,_RAM_C08E_
    res 2,(hl)
+:  ld hl,_RAM_C18E_
    res 2,(hl)
    ld hl,_RAM_C1CE_
    res 2,(hl)
    ld hl,_RAM_C0CE_
    res 2,(hl)
    ld a,(_RAM_C0AE_)
    and $80
    jr z,+
    ld hl,_RAM_C0BC_
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,(_RAM_C0AF_)
    call _LABEL_30C79_
    ld hl,_RAM_C0AE_
    res 2,(hl)
+:  ld hl,_RAM_C1AE_
    res 2,(hl)
_LABEL_30A9A_:
    pop hl
    pop hl
    ret

_LABEL_30A9D_:
    ex af,af'
    ld a,(ix+1)
    push af
      add a,$10
      out (FMAddress),a
      call SoundFMDelay
      xor a
      out (FMData),a
    pop af
    cp $15
    jr z,+
    call SoundFMDelay
    ld hl,_RAM_C08E_
    res 2,(hl)
    ld a,$34
    out (FMAddress),a
    ld hl,_RAM_C095_
    call ++
    jp _LABEL_30A9A_

+:  ld hl,_RAM_C0AE_
    res 2,(hl)
    ld a,(_RAM_C12E_)
    or a
    ld hl,_RAM_C0B5_
    jp p,+
    ld hl,_RAM_C135_
+:  ld a,$35
    out (FMAddress),a
    call ++
    jp _LABEL_30A9A_

++:  ld a,(hl)
    and $F0
    ld c,a
    inc hl
    ld a,(hl)
    and $0F
    or c
    out (FMData),a
    ret

; 11th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30AEE_:
    ld a,(de)
    ld c,a
    inc de
    ld a,(de)
    ld b,a
    push bc
      push ix
      pop hl
      dec (ix+9)
      ld c,(ix+9)
      dec (ix+9)
      ld b,$00
      add hl,bc
      ld (hl),d
      dec hl
      ld (hl),e
    pop de
    dec de
    ret

; 12th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30B09_:
    push ix
    pop hl
    ld c,(ix+9)
    ld b,$00
    add hl,bc
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc (ix+9)
    inc (ix+9)
    ret

; 10th entry of Jump Table from 308C2 (indexed by unknown)
_LABEL_30B1C_:
    ld a,(de)
    inc de
    add a,$18
    ld c,a
    ld b,$00
    push ix
    pop hl
    add hl,bc
    ld a,(hl)
    or a
    jr nz,+
    ld a,(de)
    ld (hl),a
+:  inc de
    dec (hl)
    jp nz,_LABEL_309C6_
    inc de
    ret

SoundFMDelay:                    ; Delay for use between YM2413 writes
    push hl
    pop hl
    ret

_LABEL_30B37_:
    inc (ix+11)
    ld a,(ix+10)
    sub (ix+11)
    call z,+
    bit 2,(ix+0)
    ret nz
    bit 4,(ix+19)
    ret nz
    ld a,(ix+7)
    dec a
    ret m
    ld hl,_DATA_33766_
    call _LABEL_3076B_
    call _LABEL_30C8E_
    or $F0
    out (Port_PSG),a
    ret

+:  ld e,(ix+3)
    ld d,(ix+4)
-:  ld a,(de)
    inc de
    cp $E0
    jp nc,+
    cp $80
    jp c,_LABEL_3080B_
    call ++
    ld a,(de)
    inc de
    cp $80
    jp c,_LABEL_3080B_
    dec de
    ld a,(ix+21)
    ld (ix+10),a
    jp _LABEL_3081B_

; Data from 30B86 to 30B89 (4 bytes)
.db $1B $C3 $1B $88

+:  ld hl,+  ; Overriding return address
    jp _LABEL_308AE_

+:  inc de
    jp -

++:  bit 3,a
    jr nz,+
    bit 5,a
    jr nz,++
    bit 1,a
    jr nz,++
    bit 0,a
    jr nz,+++
    bit 2,a
    jr nz,+++
    ld (ix+7),$00
    ld a,$FF
    out (Port_PSG),a
    ret

+:  ex af,af'
    ld a,$02
    ld b,$04
    jr ++++

++:  ld c,$04
    bit 0,a
    jr nz,+
    ld c,$03
+:  ex af,af'
    ld a,c
    ld b,$05
    jr ++++

+++:ex af,af'
    ld a,$01
    ld b,$06
++++:
    ld (ix+7),a
    ex af,af'
    bit 2,a
    jr z,+
    dec b
    dec b
+:  ld (ix+8),b
    ret

_LABEL_30BD9_:
    inc (ix+11)
    ld a,(ix+10)
    sub (ix+11)
    call z,_LABEL_307B9_
    ld (_RAM_C00C_),a
    cp $80
    jp z,+++
    bit 5,(ix+0)
    jp z,+++
    exx
    ld (hl),$80
    exx
    ld a,(ix+18)
    bit 7,a
    jr z,+
    add a,(ix+14)
    jr c,++
    dec (ix+15)
    jr ++

+:  add a,(ix+14)
    jr nc,++
    inc (ix+15)
++:  ld (ix+14),a
+++:bit 2,(ix+0)
    ret nz
    ld a,(ix+19)
    cp $1F
    ret z
    jr nz,+
+:  ld a,(ix+19)
    cp $FF
    jp z,+
    ld a,(ix+7)
    dec a
    jp m,+
    ld hl,_DATA_33766_
    call _LABEL_3076B_
    call _LABEL_30C8E_
    or (ix+1)
    add a,$10
    out (Port_PSG),a
+:  ld a,(_RAM_C00C_)
    or a
    jp m,+
    bit 7,(ix+20)
    ret nz
    ld a,(ix+6)
    dec a
    jp p,++
    ret

+:  ld a,(ix+6)
    dec a
++: ld l,(ix+14)
    ld h,(ix+15)
    jp m,+
    ex de,hl
    ld hl,_DATA_33805_
    call _LABEL_3076B_
    call _LABEL_30778_
+:  bit 6,(ix+0)
    ret nz
    ld a,(ix+1)
    cp $E0
    jr nz,_LABEL_30C79_
    ld a,$C0
_LABEL_30C79_:
    ld c,a
    ld a,l
    and $0F
    or c
    out (Port_PSG),a
    ld a,l
    and $F0
    or h
    rrca
    rrca
    rrca
    rrca
    out (Port_PSG),a
    ret

-:  ld (ix+12),a
_LABEL_30C8E_:
    push hl
      ld c,(ix+12)
      ld b,$00
      add hl,bc
      ld c,l
      ld b,h
    pop hl
    ld a,(bc)
    bit 7,a
    jr z,++++
    cp $82
    jr z,+
    cp $81
    jr z,+++
    cp $80
    jr z,++
    inc bc
    ld a,(bc)
    jr -

+:  pop hl
    ld a,$1F
    ld (ix+19),a
    add a,(ix+1)
    out (Port_PSG),a
    ret

++:  xor a
    jr -

+++:ld (ix+19),$FF
    pop hl
    ret

++++:
    inc (ix+12)
    add a,(ix+8)
    bit 4,a
    ret z
    ld a,$0F
    ret

_LABEL_30CCE_:
    ld a,(ix+8)
    and $0F
    or (ix+1)
    add a,$10
    out (Port_PSG),a
    ret

; Data from 30CDB to 30D6C (146 bytes)
.db $00 $00 $FF $03 $C7 $03 $90 $03 $5D $03 $2D $03 $FF $02 $D4 $02
.db $AB $02 $85 $02 $61 $02 $3F $02 $1E $02 $00 $02 $E3 $01 $C8 $01
.db $AF $01 $96 $01 $80 $01 $6A $01 $56 $01 $43 $01 $30 $01 $1F $01
.db $0F $01 $00 $01 $F2 $00 $E4 $00 $D7 $00 $CB $00 $C0 $00 $B5 $00
.db $AB $00 $A1 $00 $98 $00 $90 $00 $88 $00 $80 $00 $79 $00 $72 $00
.db $6C $00 $66 $00 $60 $00 $5B $00 $55 $00 $51 $00 $4C $00 $48 $00
.db $44 $00 $40 $00 $3C $00 $39 $00 $36 $00 $33 $00 $30 $00 $2D $00
.db $2B $00 $28 $00 $26 $00 $24 $00 $22 $00 $20 $00 $1E $00 $1C $00
.db $1B $00 $19 $00 $18 $00 $16 $00 $15 $00 $14 $00 $13 $00 $12 $00
.db $11 $00

; Data from 30D6D to 32365 (5625 bytes)
_DATA_30D6D_:
.incbin "Phantasy Star (Japan)_DATA_30D6D_.inc"

; 6th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32366 to 323CA (101 bytes)
_DATA_32366_:
.db $07 $80 $10 $02 $02 $8E $FC $01 $C0 $01 $80 $11 $02 $6C $8E $FC
.db $00 $E0 $03 $80 $12 $02 $CB $8E $FC $00 $30 $04 $80 $13 $02 $01
.db $8E $FC $00 $80 $04 $80 $14 $02 $6C $8E $FC $00 $80 $04 $80 $15
.db $02 $CA $8E $FC $00 $B0 $04 $C0 $00 $02 $5E $B8 $00 $00 $00 $0F
.db $04 $80 $80 $02 $02 $8E $F8 $01 $05 $01 $80 $A0 $02 $6C $8E $F8
.db $00 $05 $04 $80 $C0 $02 $CB $8E $F8 $00 $09 $05 $C0 $E0 $02 $5E
.db $B8 $00 $00 $00 $00

; 7th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 323CB to 3242F (101 bytes)
_DATA_323CB_:
.db $07 $80 $10 $02 $1E $8F $FC $01 $50 $02 $80 $11 $02 $8C $8F $F0
.db $04 $E0 $03 $80 $12 $02 $0D $90 $FC $00 $80 $04 $80 $13 $02 $52
.db $90 $FC $00 $80 $04 $80 $14 $02 $9B $90 $FC $00 $80 $04 $80 $15
.db $02 $1D $8F $FC $00 $80 $04 $C0 $00 $02 $E3 $B8 $00 $00 $00 $00
.db $04 $80 $80 $02 $1E $8F $E8 $01 $06 $01 $80 $A0 $02 $8C $8F $F4
.db $00 $06 $04 $80 $C0 $02 $0D $90 $E8 $00 $09 $05 $C0 $E0 $02 $E3
.db $B8 $00 $00 $00 $00

; 8th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32430 to 32494 (101 bytes)
_DATA_32430_:
.db $07 $80 $10 $02 $E1 $90 $FA $01 $B0 $00 $80 $11 $02 $6A $91 $FA
.db $00 $E0 $03 $80 $12 $02 $0D $92 $FA $00 $A0 $03 $80 $13 $02 $9C
.db $92 $FA $00 $C0 $02 $80 $14 $02 $FD $92 $FA $00 $C0 $02 $80 $15
.db $02 $E0 $90 $FA $00 $A0 $04 $C0 $00 $02 $4F $B9 $00 $00 $00 $00
.db $04 $80 $80 $02 $E1 $90 $EA $01 $05 $02 $80 $A0 $02 $6A $91 $F6
.db $00 $04 $04 $80 $C0 $02 $0D $92 $EA $00 $06 $05 $C0 $E0 $02 $4F
.db $B9 $00 $00 $00 $00

; 9th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32495 to 324F9 (101 bytes)
_DATA_32495_:
.db $07 $80 $10 $02 $6B $93 $FC $02 $B0 $01 $80 $11 $02 $C0 $93 $F0
.db $00 $F0 $03 $80 $12 $02 $01 $94 $FC $00 $40 $04 $80 $13 $02 $C0
.db $93 $FC $01 $80 $03 $80 $14 $02 $6B $93 $FC $00 $90 $04 $80 $15
.db $02 $01 $94 $FC $00 $C0 $04 $C0 $00 $02 $F8 $B9 $00 $00 $09 $02
.db $04 $80 $80 $02 $6B $93 $E4 $01 $07 $02 $80 $A0 $02 $C0 $93 $F0
.db $00 $04 $04 $80 $C0 $02 $01 $94 $E4 $00 $06 $05 $C0 $E0 $02 $F8
.db $B9 $00 $00 $00 $00

; 10th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 324FA to 3255E (101 bytes)
_DATA_324FA_:
.db $07 $80 $10 $02 $33 $94 $FC $02 $B0 $02 $80 $11 $02 $91 $94 $FC
.db $00 $F0 $03 $80 $12 $02 $E0 $94 $FC $00 $40 $04 $80 $13 $02 $91
.db $94 $FC $00 $80 $04 $80 $14 $02 $32 $94 $FC $00 $90 $04 $80 $15
.db $02 $DF $94 $FC $00 $C0 $04 $C0 $00 $02 $73 $BA $00 $00 $09 $02
.db $04 $80 $80 $02 $33 $94 $EC $01 $05 $02 $80 $A0 $02 $91 $94 $F8
.db $00 $05 $04 $80 $C0 $02 $E0 $94 $EC $00 $09 $04 $C0 $E0 $02 $73
.db $BA $00 $00 $00 $00

; 11th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 3255F to 325C3 (101 bytes)
_DATA_3255F_:
.db $07 $80 $10 $02 $2B $95 $FC $00 $70 $02 $80 $11 $02 $B1 $95 $F0
.db $00 $E0 $03 $80 $12 $02 $F3 $95 $FC $00 $70 $04 $80 $13 $02 $B1
.db $95 $FC $00 $F0 $04 $80 $14 $02 $24 $95 $FC $00 $C0 $04 $80 $15
.db $02 $F2 $95 $FC $00 $C0 $04 $C0 $00 $02 $CB $BA $00 $00 $00 $00
.db $04 $80 $80 $02 $19 $95 $E8 $01 $05 $02 $80 $A0 $02 $B1 $95 $F4
.db $00 $05 $04 $80 $C0 $02 $F3 $95 $E8 $00 $09 $05 $C0 $E0 $02 $CB
.db $BA $00 $00 $00 $00

; 12th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 325C4 to 32616 (83 bytes)
_DATA_325C4_:
.db $06 $80 $10 $03 $A5 $96 $F8 $01 $30 $02 $80 $11 $03 $04 $97 $F8
.db $00 $80 $03 $80 $12 $03 $A4 $96 $F8 $00 $80 $04 $80 $13 $03 $04
.db $97 $F8 $00 $30 $04 $80 $14 $03 $A3 $96 $F8 $00 $30 $04 $80 $15
.db $03 $A2 $96 $F8 $00 $30 $04 $03 $80 $80 $03 $A5 $96 $E0 $01 $05
.db $01 $80 $A0 $03 $04 $97 $F8 $00 $04 $04 $80 $C0 $03 $A4 $96 $EC
.db $00 $09 $05

; 13th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32617 to 3267B (101 bytes)
_DATA_32617_:
.db $07 $80 $10 $02 $54 $97 $FC $01 $70 $02 $80 $11 $02 $85 $97 $FC
.db $00 $E0 $03 $80 $12 $02 $BB $97 $FC $00 $B0 $02 $80 $13 $02 $85
.db $97 $FC $00 $80 $04 $80 $14 $02 $53 $97 $FC $00 $60 $04 $80 $15
.db $02 $BA $97 $FC $00 $80 $04 $C0 $00 $02 $85 $BB $00 $00 $00 $00
.db $04 $80 $80 $02 $54 $97 $F0 $01 $06 $02 $80 $A0 $02 $85 $97 $FC
.db $00 $05 $04 $80 $C0 $02 $BB $97 $F0 $00 $09 $05 $C0 $E0 $02 $85
.db $BB $00 $00 $00 $00

; 14th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 3267C to 326D7 (92 bytes)
_DATA_3267C_:
.db $05 $80 $10 $02 $D8 $97 $08 $01 $80 $02 $80 $11 $02 $EB $98 $FC
.db $00 $F0 $03 $80 $12 $02 $4E $99 $08 $00 $80 $02 $80 $13 $02 $D7
.db $97 $FC $00 $D0 $04 $C0 $00 $02 $A6 $BB $00 $00 $00 $00 $05 $00
.db $80 $02 $D8 $97 $EC $01 $06 $FF $80 $80 $02 $D8 $97 $EC $01 $06
.db $02 $80 $A0 $02 $EB $98 $F8 $00 $05 $04 $80 $C0 $02 $4E $99 $EC
.db $00 $06 $05 $C0 $E0 $02 $A6 $BB $00 $00 $00 $00

; 15th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 326D8 to 32733 (92 bytes)
_DATA_326D8_:
.db $05 $80 $10 $02 $9F $99 $F4 $01 $80 $02 $80 $11 $02 $C3 $99 $F4
.db $00 $E0 $03 $80 $12 $02 $E5 $99 $F4 $00 $40 $04 $80 $13 $02 $C3
.db $99 $F4 $00 $30 $04 $C0 $00 $02 $22 $BC $00 $00 $00 $00 $05 $00
.db $80 $02 $65 $9C $F0 $00 $09 $FF $80 $80 $02 $9F $99 $F4 $01 $09
.db $02 $80 $A0 $02 $C3 $99 $F4 $00 $05 $04 $80 $C0 $02 $E5 $99 $F4
.db $00 $06 $05 $C0 $E0 $02 $22 $BC $00 $00 $00 $00

; 16th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32734 to 32798 (101 bytes)
_DATA_32734_:
.db $07 $80 $10 $03 $06 $9A $F4 $01 $80 $02 $80 $11 $03 $85 $9A $F4
.db $00 $E0 $03 $80 $12 $03 $14 $9B $F4 $00 $40 $04 $80 $13 $03 $85
.db $9A $F4 $00 $30 $04 $80 $14 $03 $05 $9A $F4 $00 $30 $04 $80 $15
.db $03 $13 $9B $F4 $00 $30 $04 $C0 $00 $03 $63 $BC $00 $00 $00 $00
.db $04 $80 $80 $03 $06 $9A $EE $01 $05 $01 $80 $A0 $03 $85 $9A $FA
.db $00 $05 $04 $80 $C0 $03 $14 $9B $EE $00 $09 $05 $C0 $E0 $03 $63
.db $BC $00 $00 $00 $00

; 17th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32799 to 327FD (101 bytes)
_DATA_32799_:
.db $07 $80 $10 $02 $82 $9B $F4 $01 $80 $02 $80 $11 $02 $DF $9B $F4
.db $00 $E0 $03 $80 $12 $02 $16 $9C $F4 $00 $40 $04 $80 $13 $02 $DF
.db $9B $F4 $00 $30 $04 $80 $14 $02 $81 $9B $F4 $00 $30 $04 $80 $15
.db $02 $15 $9C $F4 $00 $30 $04 $C0 $00 $02 $06 $BD $00 $00 $00 $00
.db $04 $80 $80 $02 $82 $9B $EE $01 $05 $01 $80 $A0 $02 $DF $9B $FA
.db $00 $05 $04 $80 $C0 $02 $16 $9C $EE $00 $09 $05 $C0 $E0 $02 $06
.db $BD $00 $00 $00 $00

; 18th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 327FE to 32859 (92 bytes)
_DATA_327FE_:
.db $05 $80 $10 $02 $65 $9C $F4 $01 $80 $02 $80 $11 $02 $A6 $9C $F4
.db $00 $E0 $03 $80 $12 $02 $C7 $9C $F4 $00 $40 $04 $80 $13 $02 $A6
.db $9C $F4 $00 $30 $04 $C0 $00 $02 $58 $BD $00 $00 $00 $00 $05 $00
.db $80 $02 $65 $9C $F0 $00 $09 $01 $80 $80 $02 $65 $9C $F0 $00 $09
.db $01 $80 $A0 $02 $A6 $9C $F0 $00 $05 $04 $80 $C0 $02 $C7 $9C $F0
.db $00 $06 $05 $C0 $E0 $02 $58 $BD $00 $00 $00 $00

; 19th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 3285A to 328B5 (92 bytes)
_DATA_3285A_:
.db $05 $80 $10 $02 $F5 $9C $F4 $01 $80 $02 $80 $11 $02 $27 $9D $F4
.db $00 $E0 $03 $80 $12 $02 $64 $9D $F4 $00 $40 $04 $80 $13 $02 $27
.db $9D $F4 $00 $30 $04 $C0 $00 $02 $8D $BD $00 $00 $09 $02 $05 $00
.db $80 $02 $F5 $9C $F4 $01 $06 $FF $80 $80 $02 $F5 $9C $F4 $01 $06
.db $01 $80 $A0 $02 $27 $9D $F4 $00 $05 $04 $80 $C0 $02 $64 $9D $F4
.db $00 $06 $03 $C0 $E0 $02 $8D $BD $00 $00 $00 $00

; 20th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 328B6 to 3291A (101 bytes)
_DATA_328B6_:
.db $07 $80 $10 $02 $8A $9D $F4 $01 $80 $03 $80 $11 $02 $EB $9D $F4
.db $00 $E0 $03 $80 $12 $02 $73 $9E $F4 $00 $80 $02 $80 $13 $02 $C7
.db $9E $F4 $00 $80 $02 $80 $14 $02 $EB $9D $F4 $00 $F0 $04 $80 $15
.db $02 $89 $9D $F4 $00 $30 $04 $C0 $00 $02 $CD $BD $00 $00 $00 $00
.db $04 $80 $80 $02 $8A $9D $E6 $01 $05 $02 $80 $A0 $02 $EB $9D $F2
.db $00 $05 $04 $80 $C0 $02 $73 $9E $E6 $00 $05 $02 $C0 $E0 $02 $CD
.db $BD $00 $00 $00 $00

; 21st entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 3291B to 3297F (101 bytes)
_DATA_3291B_:
.db $07 $80 $10 $02 $24 $9F $F4 $01 $70 $02 $80 $11 $02 $D3 $9F $F4
.db $00 $F0 $03 $80 $12 $02 $3B $A0 $F4 $00 $70 $04 $80 $13 $02 $D3
.db $9F $F4 $00 $A0 $04 $80 $14 $02 $23 $9F $F4 $00 $80 $04 $80 $15
.db $02 $3A $A0 $F4 $00 $A0 $04 $C0 $00 $02 $46 $BE $00 $00 $00 $00
.db $04 $80 $80 $02 $24 $9F $EE $00 $06 $01 $80 $A0 $02 $D3 $9F $FA
.db $00 $04 $04 $80 $C0 $02 $3B $A0 $EE $00 $06 $05 $C0 $E0 $02 $46
.db $BE $00 $00 $00 $00

; 23rd entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32980 to 329E4 (101 bytes)
_DATA_32980_:
.db $07 $80 $10 $02 $CF $A0 $F4 $01 $70 $02 $80 $11 $02 $56 $A1 $F4
.db $00 $F0 $03 $80 $12 $02 $C8 $A1 $F4 $00 $60 $04 $80 $13 $02 $CE
.db $A0 $F4 $00 $F0 $04 $80 $14 $02 $56 $A1 $F4 $00 $50 $04 $80 $15
.db $02 $C7 $A1 $F4 $00 $30 $04 $C0 $00 $02 $E0 $BE $00 $00 $00 $00
.db $04 $80 $80 $02 $CF $A0 $E8 $01 $06 $01 $80 $A0 $02 $56 $A1 $F4
.db $00 $05 $04 $80 $C0 $02 $C8 $A1 $E8 $00 $06 $05 $C0 $E0 $02 $E0
.db $BE $00 $00 $00 $0F

; 24th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 329E5 to 32A49 (101 bytes)
_DATA_329E5_:
.db $07 $80 $10 $02 $18 $A2 $F4 $01 $60 $02 $80 $11 $02 $69 $A2 $F4
.db $00 $F0 $03 $80 $12 $02 $CB $A2 $F4 $00 $70 $04 $80 $13 $02 $17
.db $A2 $F4 $00 $B0 $02 $80 $14 $02 $69 $A2 $F4 $00 $60 $04 $80 $15
.db $02 $CA $A2 $F4 $00 $B0 $04 $C0 $00 $02 $49 $BF $00 $00 $00 $00
.db $04 $80 $80 $02 $18 $A2 $E8 $01 $09 $01 $80 $A0 $02 $69 $A2 $F4
.db $00 $06 $04 $80 $C0 $02 $CB $A2 $E8 $00 $06 $05 $C0 $E0 $02 $49
.db $BF $00 $00 $00 $00

; 25th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 32A4A to 32A9D (84 bytes)
_DATA_32A4A_:
.db $06 $80 $10 $02 $31 $A3 $F8 $01 $C0 $02 $80 $11 $02 $43 $A3 $F8
.db $00 $E0 $03 $80 $12 $02 $55 $A3 $F8 $00 $C0 $04 $80 $13 $02 $30
.db $A3 $F8 $00 $30 $04 $80 $14 $02 $43 $A3 $F8 $00 $30 $04 $80 $15
.db $02 $54 $A3 $F8 $00 $30 $04 $03 $80 $80 $02 $31 $A3 $EC $00 $05
.db $01 $80 $A0 $02 $43 $A3 $EC $00 $05 $04 $80 $C0 $02 $55 $A3 $EC
.db $00 $06 $05 $FF

; 1st entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32A9E to 32AA1 (4 bytes)
_DATA_32A9E_:
.db $01 $88 $15 $01

; Pointer Table from 32AA2 to 32AA3 (1 entries,indexed by unknown)
.dw _DATA_32AC0_

; Data from 32AA4 to 32AA7 (4 bytes)
.db $00 $00 $B0 $00

; 1st entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32AA8 to 32AAB (4 bytes)
_DATA_32AA8_:
.db $01 $88 $E0 $01

; Pointer Table from 32AAC to 32AAD (1 entries,indexed by unknown)
.dw _DATA_32AB2_

; Data from 32AAE to 32AB1 (4 bytes)
.db $00 $00 $01 $00

; 1st entry of Pointer Table from 32AAC (indexed by unknown)
; Data from 32AB2 to 32ABF (14 bytes)
_DATA_32AB2_:
.db $F3 $07 $00 $20 $01 $00 $00 $20 $F7 $00 $04 $B4 $AA $F2

; Data from 32AC0 to 32ACB (12 bytes)
_DATA_32AC0_:
.db $05 $00 $02 $00 $00 $20 $F7 $00 $04 $C0 $AA $F2

; 2nd entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32ACC to 32ACF (4 bytes)
_DATA_32ACC_:
.db $02 $A8 $14 $01

; Pointer Table from 32AD0 to 32AD3 (2 entries,indexed by unknown)
.dw _DATA_32AF2_ $00F0

; Data from 32AD4 to 32ADE (11 bytes)
.db $43 $00 $A8 $15 $01 $F2 $AA $E0 $00 $F3 $00

; 2nd entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32ADF to 32AE2 (4 bytes)
_DATA_32ADF_:
.db $02 $A8 $A0 $01

; Pointer Table from 32AE3 to 32AE4 (1 entries,indexed by unknown)
.dw _DATA_32AF2_

; Data from 32AE5 to 32AF1 (13 bytes)
.db $00 $00 $00 $00 $A8 $C0 $01 $F2 $AA $08 $02 $05 $00

; 1st entry of Pointer Table from 32AE3 (indexed by unknown)
; Data from 32AF2 to 32B06 (21 bytes)
_DATA_32AF2_:
.db $02 $00 $15 $04 $02 $40 $E0 $06 $FB $F2 $04 $F7 $00 $04 $F2 $AA
.db $01 $50 $F8 $14 $F2

; 3rd entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32B07 to 32B0A (4 bytes)
_DATA_32B07_:
.db $02 $A8 $14 $01

; Pointer Table from 32B0B to 32B0E (2 entries,indexed by unknown)
.dw _DATA_32B36_ _DATA_30_

; Data from 32B0F to 32B19 (11 bytes)
.db $63 $01 $A8 $15 $01 $2D $AB $00 $00 $03 $00

; 3rd entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32B1A to 32B1D (4 bytes)
_DATA_32B1A_:
.db $02 $A8 $A0 $01

; Pointer Table from 32B1E to 32B21 (2 entries,indexed by unknown)
.dw _DATA_32B43_ _DATA_100_

; Data from 32B22 to 32B35 (20 bytes)
.db $04 $00 $A8 $C0 $01 $43 $AB $F0 $01 $04 $00 $FF $F8 $32 $0B $07
.db $B2 $F0 $A8 $FC

; Data from 32B36 to 32B42 (13 bytes)
_DATA_32B36_:
.db $01 $80 $E0 $02 $01 $60 $0A $04 $02 $00 $F7 $0E $F2

; 1st entry of Pointer Table from 32B1E (indexed by unknown)
; Data from 32B43 to 32B4F (13 bytes)
_DATA_32B43_:
.db $03 $FF $F0 $02 $00 $60 $0A $01 $02 $00 $E0 $18 $F2

; 4th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32B50 to 32B53 (4 bytes)
_DATA_32B50_:
.db $02 $A8 $14 $01

; Pointer Table from 32B54 to 32B55 (1 entries,indexed by unknown)
.dw _DATA_32B76_

; Data from 32B56 to 32B62 (13 bytes)
.db $00 $00 $53 $01 $A8 $15 $01 $94 $AB $00 $00 $03 $00

; 4th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32B63 to 32B66 (4 bytes)
_DATA_32B63_:
.db $02 $A8 $A0 $01

; Pointer Table from 32B67 to 32B68 (1 entries,indexed by unknown)
.dw _DATA_32B7F_

; Data from 32B69 to 32B75 (13 bytes)
.db $00 $00 $04 $00 $A8 $E0 $01 $A1 $AB $00 $00 $04 $00

; Data from 32B76 to 32B7E (9 bytes)
_DATA_32B76_:
.db $FF $F7 $31 $0B $07 $92 $F0 $28 $FB

; 1st entry of Pointer Table from 32B67 (indexed by unknown)
; Data from 32B7F to 32BAC (46 bytes)
_DATA_32B7F_:
.db $03 $F0 $A0 $06 $03 $D0 $E7 $06 $03 $00 $8F $05 $FB $14 $14 $F7
.db $00 $05 $87 $AB $F2 $03 $00 $33 $06 $04 $00 $B7 $08 $04 $00 $0B
.db $17 $F2 $00 $20 $13 $06 $F5 $04 $04 $00 $20 $05 $14 $F2

; 5th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32BAD to 32BB0 (4 bytes)
_DATA_32BAD_:
.db $02 $A8 $14 $01

; Pointer Table from 32BB1 to 32BB2 (1 entries,indexed by unknown)
.dw _DATA_32BD3_

; Data from 32BB3 to 32BBF (13 bytes)
.db $00 $00 $03 $00 $88 $15 $01 $E0 $AB $00 $00 $03 $00

; 5th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32BC0 to 32BC3 (4 bytes)
_DATA_32BC0_:
.db $02 $A8 $A0 $01

; Pointer Table from 32BC4 to 32BC5 (1 entries,indexed by unknown)
.dw _DATA_32BD3_

; Data from 32BC6 to 32BD2 (13 bytes)
.db $00 $00 $00 $00 $A8 $E0 $01 $03 $AC $00 $00 $00 $00

; Data from 32BD3 to 32C0F (61 bytes)
_DATA_32BD3_:
.db $03 $F0 $90 $04 $03 $FF $DC $08 $03 $20 $E9 $14 $F2 $FF $FA $31
.db $0B $07 $60 $F1 $2F $FF $05 $00 $03 $FB $06 $FF $F7 $00 $06 $E9
.db $AB $05 $00 $02 $FB $00 $10 $F7 $00 $05 $F4 $AB $05 $00 $02 $F2
.db $00 $10 $25 $04 $00 $40 $15 $04 $00 $80 $FB $14 $F2

; 6th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32C10 to 32C13 (4 bytes)
_DATA_32C10_:
.db $02 $88 $14 $01

; Pointer Table from 32C14 to 32C15 (1 entries,indexed by unknown)
.dw _DATA_32C36_

; Data from 32C16 to 32C22 (13 bytes)
.db $FF $06 $03 $00 $88 $15 $01 $3F $AC $00 $06 $03 $00

; 6th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32C23 to 32C26 (4 bytes)
_DATA_32C23_:
.db $02 $88 $A0 $01

; Pointer Table from 32C27 to 32C28 (1 entries,indexed by unknown)
.dw _DATA_32C3F_

; Data from 32C29 to 32C35 (13 bytes)
.db $00 $00 $00 $00 $88 $C0 $01 $3F $AC $F6 $00 $00 $00

; Data from 32C36 to 32C3E (9 bytes)
_DATA_32C36_:
.db $FF $F1 $75 $07 $0B $80 $51 $C8 $AC

; 1st entry of Pointer Table from 32C27 (indexed by unknown)
; Data from 32C3F to 32C58 (26 bytes)
_DATA_32C3F_:
.db $01 $60 $01 $FB $F2 $04 $F7 $00 $02 $3F $AC $00 $60 $01 $FB $F6
.db $FC $F7 $00 $04 $4A $AC $00 $60 $14 $F2

; 7th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32C59 to 32C5C (4 bytes)
_DATA_32C59_:
.db $02 $A8 $14 $01

; Pointer Table from 32C5D to 32C5E (1 entries,indexed by unknown)
.dw _DATA_32C7F_

; Data from 32C5F to 32C6B (13 bytes)
.db $40 $00 $D3 $00 $A8 $15 $01 $98 $AC $00 $00 $03 $00

; 7th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32C6C to 32C6F (4 bytes)
_DATA_32C6C_:
.db $02 $A8 $A0 $01

; Pointer Table from 32C70 to 32C73 (2 entries,indexed by unknown)
.dw _DATA_32C7F_ _DATA_103_

; Data from 32C74 to 32C7E (11 bytes)
.db $00 $00 $A8 $E0 $01 $BA $AC $03 $01 $00 $00

; Data from 32C7F to 32CC6 (72 bytes)
_DATA_32C7F_:
.db $03 $80 $09 $06 $03 $FF $FC $08 $F5 $01 $04 $FC $00 $03 $FF $03
.db $FB $F4 $FC $F7 $00 $0A $8C $AC $F2 $FF $36 $32 $07 $07 $5D $8C
.db $0B $06 $05 $00 $33 $06 $05 $F0 $FE $08 $FC $00 $08 $00 $03 $FB
.db $00 $FC $F7 $00 $08 $AB $AC $08 $00 $06 $F2 $00 $30 $20 $03 $00
.db $F0 $FE $08 $00 $78 $FE $14 $F2

; 8th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32CC7 to 32CCA (4 bytes)
_DATA_32CC7_:
.db $01 $A8 $15 $01

; Pointer Table from 32CCB to 32CCC (1 entries,indexed by unknown)
.dw _DATA_32CDB_

; Data from 32CCD to 32CD0 (4 bytes)
.db $F0 $03 $03 $00

; 8th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32CD1 to 32CD4 (4 bytes)
_DATA_32CD1_:
.db $01 $A8 $E0 $01

; Pointer Table from 32CD5 to 32CD6 (1 entries,indexed by unknown)
.dw _DATA_32CF9_

; Data from 32CD7 to 32CDA (4 bytes)
.db $00 $00 $00 $00

; Data from 32CDB to 32CF8 (30 bytes)
_DATA_32CDB_:
.db $FF $F5 $EE $4B $07 $F3 $F4 $F4 $F9 $02 $F0 $20 $06 $FC $00 $02
.db $00 $02 $FB $00 $F0 $F7 $00 $0A $EA $AC $01 $30 $04 $F2

; 1st entry of Pointer Table from 32CD5 (indexed by unknown)
; Data from 32CF9 to 32D0B (19 bytes)
_DATA_32CF9_:
.db $F3 $03 $00 $10 $10 $04 $00 $80 $FD $0A $F5 $04 $04 $00 $60 $F8
.db $0A $F2 $F2

; 10th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32D0C to 32D0F (4 bytes)
_DATA_32D0C_:
.db $02 $88 $14 $01

; Pointer Table from 32D10 to 32D13 (2 entries,indexed by unknown)
.dw _DATA_32D32_ $00EC

; Data from 32D14 to 32D1E (11 bytes)
.db $03 $00 $88 $15 $01 $3E $AD $00 $00 $03 $00

; 10th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32D1F to 32D22 (4 bytes)
_DATA_32D1F_:
.db $02 $88 $A0 $01

; Pointer Table from 32D23 to 32D24 (1 entries,indexed by unknown)
.dw _DATA_32D32_

; Data from 32D25 to 32D31 (13 bytes)
.db $00 $00 $02 $00 $88 $E0 $01 $59 $AD $00 $00 $02 $00

; 1st entry of Pointer Table from 32D23 (indexed by unknown)
; Data from 32D32 to 32D6D (60 bytes)
_DATA_32D32_:
.db $03 $F0 $02 $00 $10 $02 $F7 $00 $0C $32 $AD $F2 $FF $F3 $31 $0B
.db $07 $E2 $B1 $F2 $F7 $03 $00 $04 $04 $10 $04 $F7 $00 $04 $47 $AD
.db $FC $01 $05 $00 $EF $10 $F2 $00 $20 $02 $00 $10 $04 $F7 $00 $05
.db $59 $AD $F5 $00 $04 $FC $01 $00 $A3 $F7 $12 $F2

; 11th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32D6E to 32D71 (4 bytes)
_DATA_32D6E_:
.db $02 $A8 $14 $01

; Pointer Table from 32D72 to 32D75 (2 entries,indexed by unknown)
.dw _DATA_32D94_ $00FA

; Data from 32D76 to 32D80 (11 bytes)
.db $63 $04 $A8 $15 $01 $94 $AD $00 $00 $63 $04

; 11th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32D81 to 32D84 (4 bytes)
_DATA_32D81_:
.db $02 $A8 $A0 $01

; Pointer Table from 32D85 to 32D88 (2 entries,indexed by unknown)
.dw _DATA_32D94_ _DATA_10_

; Data from 32D89 to 32D93 (11 bytes)
.db $00 $04 $A8 $C0 $01 $94 $AD $00 $00 $00 $04

; Data from 32D94 to 32DAA (23 bytes)
_DATA_32D94_:
.db $01 $40 $15 $04 $01 $80 $EE $08 $EF $FF $FB $0A $14 $F7 $00 $04
.db $94 $AD $01 $80 $FA $14 $F2

; 12th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32DAB to 32DAE (4 bytes)
_DATA_32DAB_:
.db $02 $80 $14 $01

; Pointer Table from 32DAF to 32DB4 (3 entries,indexed by unknown)
.dw _DATA_32DD1_ _DATA_103_ _DATA_33_

; Data from 32DB5 to 32DBD (9 bytes)
.db $80 $15 $01 $D1 $AD $16 $00 $C3 $00

; 12th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32DBE to 32DC1 (4 bytes)
_DATA_32DBE_:
.db $02 $80 $A0 $01

; Pointer Table from 32DC2 to 32DC5 (2 entries,indexed by unknown)
.dw _DATA_32DD1_ _DATA_103_

; Data from 32DC6 to 32DD0 (11 bytes)
.db $09 $00 $80 $C0 $01 $D1 $AD $03 $00 $09 $00

; 1st entry of Pointer Table from 32DC2 (indexed by unknown)
; Data from 32DD1 to 32DD9 (9 bytes)
_DATA_32DD1_:
.db $A2 $02 $A5 $A9 $AB $AC $AE $18 $F2

; 13th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32DDA to 32DDD (4 bytes)
_DATA_32DDA_:
.db $02 $80 $14 $01

; Pointer Table from 32DDE to 32DE1 (2 entries,indexed by unknown)
.dw _DATA_32E00_ _DATA_110_

; Data from 32DE2 to 32DEC (11 bytes)
.db $50 $02 $80 $15 $01 $00 $AE $10 $00 $50 $02

; 13th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32DED to 32DF0 (4 bytes)
_DATA_32DED_:
.db $02 $80 $A0 $01

; Pointer Table from 32DF1 to 32DF4 (2 entries,indexed by unknown)
.dw _DATA_32E00_ _DATA_103_

; Data from 32DF5 to 32DFF (11 bytes)
.db $09 $00 $80 $C0 $01 $00 $AE $03 $00 $09 $00

; Data from 32E00 to 32E07 (8 bytes)
_DATA_32E00_:
.db $B1 $0C $99 $AA $A7 $F6 $00 $AE

; 14th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32E08 to 32E0B (4 bytes)
_DATA_32E08_:
.db $02 $A8 $14 $01

; Pointer Table from 32E0C to 32E0D (1 entries,indexed by unknown)
.dw _DATA_32E2E_

; Data from 32E0E to 32E1A (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $3C $AE $00 $00 $03 $00

; 14th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32E1B to 32E1E (4 bytes)
_DATA_32E1B_:
.db $02 $A8 $A0 $01

; Pointer Table from 32E1F to 32E22 (2 entries,indexed by unknown)
.dw _DATA_32E2E_ _DATA_103_

; Data from 32E23 to 32E2D (11 bytes)
.db $00 $00 $A8 $E0 $01 $53 $AE $03 $01 $00 $00

; Data from 32E2E to 32E60 (51 bytes)
_DATA_32E2E_:
.db $03 $FF $C1 $03 $F7 $00 $03 $2E $AE $03 $80 $12 $08 $F2 $FF $F5
.db $30 $0B $07 $F4 $82 $54 $F6 $05 $00 $50 $03 $F7 $00 $03 $45 $AE
.db $04 $80 $FA $08 $F2 $00 $10 $38 $03 $F7 $00 $03 $53 $AE $00 $40
.db $FA $08 $F2

; 15th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32E61 to 32E64 (4 bytes)
_DATA_32E61_:
.db $02 $88 $14 $01

; Pointer Table from 32E65 to 32E66 (1 entries,indexed by unknown)
.dw _DATA_32E87_

; Data from 32E67 to 32E73 (13 bytes)
.db $41 $00 $03 $00 $88 $15 $01 $91 $AE $00 $00 $03 $00

; 15th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32E74 to 32E77 (4 bytes)
_DATA_32E74_:
.db $02 $88 $A0 $01

; Pointer Table from 32E78 to 32E79 (1 entries,indexed by unknown)
.dw _DATA_32E87_

; Data from 32E7A to 32E86 (13 bytes)
.db $00 $00 $00 $00 $88 $E0 $01 $A4 $AE $00 $00 $00 $00

; Data from 32E87 to 32EAF (41 bytes)
_DATA_32E87_:
.db $02 $80 $03 $01 $20 $04 $03 $80 $08 $F2 $FF $F1 $33 $0B $07 $C2
.db $F2 $BA $F8 $05 $00 $03 $04 $80 $04 $05 $80 $08 $F2 $F3 $03 $00
.db $10 $03 $00 $80 $04 $00 $20 $08 $F2

; 16th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32EB0 to 32EB3 (4 bytes)
_DATA_32EB0_:
.db $02 $A8 $14 $01

; Pointer Table from 32EB4 to 32EB5 (1 entries,indexed by unknown)
.dw _DATA_32ED6_

; Data from 32EB6 to 32EC2 (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $DF $AE $00 $00 $03 $00

; 16th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32EC3 to 32EC6 (4 bytes)
_DATA_32EC3_:
.db $02 $88 $A0 $01

; Pointer Table from 32EC7 to 32ECA (2 entries,indexed by unknown)
.dw _DATA_32EF9_ _DATA_100_

; Data from 32ECB to 32ED5 (11 bytes)
.db $00 $00 $88 $C0 $01 $F9 $AE $30 $01 $00 $00

; Data from 32ED6 to 32EF8 (35 bytes)
_DATA_32ED6_:
.db $FF $C3 $34 $0B $07 $B2 $A2 $F5 $F4 $05 $20 $40 $1F $FC $00 $05
.db $A0 $04 $08 $20 $04 $05 $00 $02 $FB $10 $10 $EF $01 $F7 $02 $03
.db $E5 $AE $F2

; 1st entry of Pointer Table from 32EC7 (indexed by unknown)
; Data from 32EF9 to 32F0F (23 bytes)
_DATA_32EF9_:
.db $01 $80 $01 $00 $A0 $01 $02 $20 $01 $01 $00 $01 $FB $10 $10 $EF
.db $01 $F7 $02 $08 $F9 $AE $F2

; 17th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32F10 to 32F13 (4 bytes)
_DATA_32F10_:
.db $02 $A8 $14 $01

; Pointer Table from 32F14 to 32F19 (3 entries,indexed by unknown)
.dw _DATA_32F36_ _DATA_30_ _DATA_63_

; Data from 32F1A to 32F22 (9 bytes)
.db $A8 $15 $01 $36 $AF $33 $00 $D3 $00

; 17th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32F23 to 32F26 (4 bytes)
_DATA_32F23_:
.db $02 $A8 $A0 $01

; Pointer Table from 32F27 to 32F28 (1 entries,indexed by unknown)
.dw _DATA_32F36_

; Data from 32F29 to 32F35 (13 bytes)
.db $00 $04 $01 $00 $A8 $C0 $01 $36 $AF $F6 $04 $01 $00

; 1st entry of Pointer Table from 32F27 (indexed by unknown)
; Data from 32F36 to 32F45 (16 bytes)
_DATA_32F36_:
.db $01 $70 $05 $04 $01 $80 $FB $03 $F5 $02 $04 $01 $10 $DD $0A $F2

; 18th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32F46 to 32F49 (4 bytes)
_DATA_32F46_:
.db $02 $A8 $14 $01

; Pointer Table from 32F4A to 32F4B (1 entries,indexed by unknown)
.dw _DATA_32F6C_

; Data from 32F4C to 32F58 (13 bytes)
.db $00 $00 $53 $00 $A8 $15 $01 $82 $AF $00 $00 $53 $00

; 18th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32F59 to 32F5C (4 bytes)
_DATA_32F59_:
.db $02 $A8 $A0 $01

; Pointer Table from 32F5D to 32F5E (1 entries,indexed by unknown)
.dw _DATA_32F6C_

; Data from 32F5F to 32F6B (13 bytes)
.db $00 $00 $05 $00 $A8 $E0 $01 $9E $AF $00 $00 $00 $00

; Data from 32F6C to 32FB0 (69 bytes)
_DATA_32F6C_:
.db $00 $80 $73 $06 $F5 $09 $04 $00 $40 $76 $06 $FB $1A $0A $EF $01
.db $F7 $00 $08 $73 $AF $F2 $FF $F6 $31 $0B $07 $F9 $A2 $39 $F6 $05
.db $30 $0C $06 $05 $40 $F4 $06 $FB $02 $02 $EF $01 $F7 $00 $08 $8F
.db $AF $F2 $00 $30 $0C $06 $00 $40 $26 $06 $FB $02 $02 $EF $01 $F7
.db $00 $08 $A2 $AF $F2

; 19th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32FB1 to 32FB4 (4 bytes)
_DATA_32FB1_:
.db $01 $A8 $15 $01

; Pointer Table from 32FB5 to 32FB6 (1 entries,indexed by unknown)
.dw _DATA_32FC5_

; Data from 32FB7 to 32FBA (4 bytes)
.db $00 $00 $63 $00

; 19th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32FBB to 32FBE (4 bytes)
_DATA_32FBB_:
.db $01 $A8 $C0 $01

; Pointer Table from 32FBF to 32FC0 (1 entries,indexed by unknown)
.dw _DATA_32FC5_

; Data from 32FC1 to 32FC4 (4 bytes)
.db $00 $00 $00 $00

; Data from 32FC5 to 32FD1 (13 bytes)
_DATA_32FC5_:
.db $01 $00 $33 $03 $01 $A0 $F6 $02 $00 $60 $10 $0A $F2

; 20th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 32FD2 to 32FD5 (4 bytes)
_DATA_32FD2_:
.db $02 $80 $14 $01

; Pointer Table from 32FD6 to 32FD7 (1 entries,indexed by unknown)
.dw _DATA_32FF8_

; Data from 32FD8 to 32FE4 (13 bytes)
.db $18 $01 $C0 $00 $80 $15 $01 $F9 $AF $18 $00 $C0 $00

; 20th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 32FE5 to 32FE8 (4 bytes)
_DATA_32FE5_:
.db $02 $80 $A0 $01

; Pointer Table from 32FE9 to 32FEC (2 entries,indexed by unknown)
.dw _DATA_32FF8_ _DATA_103_

; Data from 32FED to 32FF7 (11 bytes)
.db $04 $00 $80 $C0 $01 $F9 $AF $03 $00 $04 $00

; Data from 32FF8 to 32FFF (8 bytes)
_DATA_32FF8_:
.db $04 $A5 $06 $9E $A7 $A5 $18 $F2

; 1st entry of Pointer Table from 30452 (indexed by NewMusic)
; Data from 33000 to 33009 (10 bytes)
_DATA_33000_:
.db $01 $88 $15 $01 $14 $B0 $00 $00 $A0 $00

; 1st entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 3300A to 3301C (19 bytes)
_DATA_3300A_:
.db $01 $88 $C0 $01 $14 $B0 $00 $00 $01 $00 $03 $00 $03 $03 $F0 $03
.db $F6 $14 $B0

; 2nd entry of Pointer Table from 30452 (indexed by NewMusic)
; Data from 3301D to 33026 (10 bytes)
_DATA_3301D_:
.db $01 $A8 $15 $01 $31 $B0 $00 $00 $53 $02

; 2nd entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 33027 to 3303B (21 bytes)
_DATA_33027_:
.db $01 $A8 $C0 $01 $31 $B0 $00 $00 $00 $03 $02 $00 $E7 $06 $01 $80
.db $0E $0A $F6 $31 $B0

; 3rd entry of Pointer Table from 30452 (indexed by NewMusic)
; Data from 3303C to 33045 (10 bytes)
_DATA_3303C_:
.db $01 $88 $15 $01 $50 $B0 $FA $00 $00 $00

; 4th entry of Pointer Table from 303C0 (indexed by NewMusic)
; Data from 33046 to 33072 (45 bytes)
_DATA_33046_:
.db $01 $88 $E0 $01 $66 $B0 $FA $03 $04 $00 $FF $F1 $30 $0B $07 $F1
.db $F5 $F9 $FC $05 $00 $06 $04 $00 $04 $03 $00 $03 $04 $80 $03 $F2
.db $00 $A0 $01 $00 $10 $01 $00 $80 $02 $00 $28 $03 $F2

; 25th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33073 to 33076 (4 bytes)
_DATA_33073_:
.db $03 $88 $10 $01

; Pointer Table from 33077 to 33078 (1 entries,indexed by unknown)
.dw _DATA_330CE_

; Data from 33079 to 3308E (22 bytes)
.db $44 $00 $03 $00 $88 $11 $01 $CE $B0 $40 $01 $03 $00 $88 $12 $01
.db $CE $B0 $3F $01 $03 $00

; 25th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 3308F to 33092 (4 bytes)
_DATA_3308F_:
.db $03 $88 $80 $01

; Pointer Table from 33093 to 33094 (1 entries,indexed by unknown)
.dw _DATA_330AB_

; Data from 33095 to 330AA (22 bytes)
.db $FF $01 $00 $05 $88 $A0 $01 $AB $B0 $00 $01 $00 $05 $88 $E0 $01
.db $F1 $B0 $FF $01 $00 $00

; 1st entry of Pointer Table from 33093 (indexed by unknown)
; Data from 330AB to 330CD (35 bytes)
_DATA_330AB_:
.db $02 $00 $04 $FB $FF $02 $F7 $00 $14 $AB $B0 $02 $00 $08 $FB $FE
.db $02 $F7 $00 $08 $B6 $B0 $F5 $00 $04 $02 $00 $50 $FC $01 $02 $00
.db $FF $50 $F2

; Data from 330CE to 33113 (70 bytes)
_DATA_330CE_:
.db $FF $33 $30 $0E $07 $70 $80 $F5 $F6 $04 $00 $04 $FB $FF $FD $F7
.db $00 $14 $D7 $B0 $04 $00 $03 $FB $FF $FE $F7 $00 $38 $E2 $B0 $04
.db $00 $70 $F2 $00 $80 $04 $FB $FF $FE $F7 $00 $14 $F1 $B0 $00 $80
.db $08 $FB $FF $FE $F7 $00 $08 $FC $B0 $F5 $05 $04 $00 $80 $50 $FC
.db $01 $00 $80 $FF $50 $F2

; 26th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33114 to 33117 (4 bytes)
_DATA_33114_:
.db $02 $A8 $14 $01

; Pointer Table from 33118 to 33119 (1 entries,indexed by unknown)
.dw _DATA_3313A_

; Data from 3311A to 33126 (13 bytes)
.db $00 $00 $33 $00 $A8 $15 $01 $3A $B1 $00 $00 $33 $00

; 26th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33127 to 3312A (4 bytes)
_DATA_33127_:
.db $02 $A8 $A0 $01

; Pointer Table from 3312B to 3312C (1 entries,indexed by unknown)
.dw _DATA_3313A_

; Data from 3312D to 33139 (13 bytes)
.db $00 $00 $00 $00 $A8 $C0 $01 $3A $B1 $00 $00 $00 $00

; Data from 3313A to 33156 (29 bytes)
_DATA_3313A_:
.db $02 $00 $F6 $0A $FB $F8 $F6 $F7 $00 $08 $3A $B1 $02 $00 $A0 $02
.db $EE $01 $EF $01 $FB $0C $12 $F7 $00 $0A $46 $B1 $F2

; 27th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33157 to 3315A (4 bytes)
_DATA_33157_:
.db $02 $80 $14 $01

; Pointer Table from 3315B to 3315C (1 entries,indexed by unknown)
.dw _DATA_3317D_

; Data from 3315D to 33169 (13 bytes)
.db $00 $00 $C3 $00 $80 $15 $01 $7E $B1 $00 $00 $C3 $00

; 27th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 3316A to 3316D (4 bytes)
_DATA_3316A_:
.db $02 $80 $A0 $01

; Pointer Table from 3316E to 33171 (2 entries,indexed by unknown)
.dw _DATA_3317D_ _DATA_100_

; Data from 33172 to 3317C (11 bytes)
.db $04 $00 $80 $C0 $01 $7E $B1 $04 $00 $04 $00

; Data from 3317D to 33186 (10 bytes)
_DATA_3317D_:
.db $02 $A5 $03 $A9 $AB $AC $AE $B0 $30 $F2

; 28th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33187 to 3318A (4 bytes)
_DATA_33187_:
.db $01 $A8 $15 $01

; Pointer Table from 3318B to 33190 (3 entries,indexed by unknown)
.dw _DATA_3319B_ _DATA_103_ $00F3

; 28th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33191 to 33194 (4 bytes)
_DATA_33191_:
.db $01 $A8 $C0 $01

; Pointer Table from 33195 to 33198 (2 entries,indexed by unknown)
.dw _DATA_3319B_ _DATA_103_

; Data from 33199 to 3319A (2 bytes)
.db $09 $00

; 1st entry of Pointer Table from 33195 (indexed by unknown)
; Data from 3319B to 331A3 (9 bytes)
_DATA_3319B_:
.db $01 $00 $DA $04 $00 $10 $0B $0E $F2

; 29th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 331A4 to 331A7 (4 bytes)
_DATA_331A4_:
.db $02 $88 $14 $01

; Pointer Table from 331A8 to 331A9 (1 entries,indexed by unknown)
.dw _DATA_331CA_

; Data from 331AA to 331B6 (13 bytes)
.db $0C $00 $00 $02 $88 $15 $01 $D3 $B1 $00 $00 $00 $00

; 29th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 331B7 to 331BA (4 bytes)
_DATA_331B7_:
.db $02 $88 $A0 $01

; Pointer Table from 331BB to 331BC (1 entries,indexed by unknown)
.dw _DATA_331D3_

; Data from 331BD to 331C9 (13 bytes)
.db $00 $00 $01 $04 $88 $E0 $01 $DC $B1 $00 $00 $01 $00

; Data from 331CA to 331D2 (9 bytes)
_DATA_331CA_:
.db $FF $F1 $52 $0B $07 $F5 $F7 $FE $FA

; 1st entry of Pointer Table from 331BB (indexed by unknown)
; Data from 331D3 to 331E5 (19 bytes)
_DATA_331D3_:
.db $04 $50 $06 $F7 $00 $09 $D3 $B1 $F2 $00 $40 $08 $F7 $00 $09 $DC
.db $B1 $F2 $F2

; 30th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 331E6 to 331E9 (4 bytes)
_DATA_331E6_:
.db $02 $88 $14 $01

; Pointer Table from 331EA to 331EB (1 entries,indexed by unknown)
.dw _DATA_3320C_

; Data from 331EC to 331F8 (13 bytes)
.db $DF $00 $B0 $00 $88 $15 $01 $0C $B2 $DB $00 $D0 $00

; 30th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 331F9 to 331FC (4 bytes)
_DATA_331F9_:
.db $02 $88 $A0 $02

; Pointer Table from 331FD to 331FE (1 entries,indexed by unknown)
.dw _DATA_3320C_

; Data from 331FF to 3320B (13 bytes)
.db $00 $00 $02 $00 $88 $E0 $02 $13 $B2 $00 $00 $02 $00

; Data from 3320C to 3321B (16 bytes)
_DATA_3320C_:
.db $03 $40 $06 $03 $00 $08 $F2 $F3 $03 $00 $80 $06 $00 $60 $08 $F2

; 31st entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 3321C to 3321F (4 bytes)
_DATA_3321C_:
.db $01 $88 $15 $02

; Pointer Table from 33220 to 33221 (1 entries,indexed by unknown)
.dw _DATA_33230_

; Data from 33222 to 33225 (4 bytes)
.db $03 $00 $53 $00

; 31st entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33226 to 33229 (4 bytes)
_DATA_33226_:
.db $01 $88 $C0 $02

; Pointer Table from 3322A to 3322B (1 entries,indexed by unknown)
.dw _DATA_33230_

; Data from 3322C to 3322F (4 bytes)
.db $03 $00 $02 $00

; Data from 33230 to 33233 (4 bytes)
_DATA_33230_:
.db $01 $00 $03 $F2

; 32nd entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33234 to 33237 (4 bytes)
_DATA_33234_:
.db $02 $80 $14 $01

; Pointer Table from 33238 to 33239 (1 entries,indexed by unknown)
.dw _DATA_3325B_

; Data from 3323A to 33246 (13 bytes)
.db $18 $01 $C3 $00 $80 $15 $01 $5A $B2 $18 $01 $C3 $00

; 32nd entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33247 to 3324A (4 bytes)
_DATA_33247_:
.db $02 $80 $A0 $01

; Pointer Table from 3324B to 3324E (2 entries,indexed by unknown)
.dw _DATA_3325B_ _DATA_103_

; Data from 3324F to 3325A (12 bytes)
.db $00 $00 $80 $C0 $01 $5A $B2 $03 $00 $04 $00 $02

; Data from 3325B to 33267 (13 bytes)
_DATA_3325B_:
.db $99 $02 $FB $01 $02 $F7 $00 $10 $5B $B2 $99 $30 $F2

; 33rd entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33268 to 3326B (4 bytes)
_DATA_33268_:
.db $02 $A8 $14 $01

; Pointer Table from 3326C to 3326D (1 entries,indexed by unknown)
.dw _DATA_3328E_

; Data from 3326E to 3327A (13 bytes)
.db $0E $00 $53 $00 $A8 $15 $01 $8E $B2 $0E $00 $53 $00

; 33rd entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 3327B to 3327E (4 bytes)
_DATA_3327B_:
.db $02 $A8 $A0 $01

; Pointer Table from 3327F to 33280 (1 entries,indexed by unknown)
.dw _DATA_3328E_

; Data from 33281 to 3328D (13 bytes)
.db $17 $04 $00 $00 $A8 $C0 $01 $8E $B2 $00 $01 $00 $00

; Data from 3328E to 332A0 (19 bytes)
_DATA_3328E_:
.db $02 $80 $1D $06 $02 $80 $29 $06 $FB $0A $0A $EF $01 $F7 $00 $04
.db $92 $B2 $F2

; 34th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 332A1 to 332A4 (4 bytes)
_DATA_332A1_:
.db $02 $80 $14 $01

; Pointer Table from 332A5 to 332A6 (1 entries,indexed by unknown)
.dw _DATA_332C7_

; Data from 332A7 to 332B3 (13 bytes)
.db $17 $01 $80 $00 $80 $15 $01 $C7 $B2 $14 $00 $C0 $00

; 34th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 332B4 to 332B7 (4 bytes)
_DATA_332B4_:
.db $02 $80 $A0 $01

; Pointer Table from 332B8 to 332BB (2 entries,indexed by unknown)
.dw _DATA_332C7_ _DATA_104_

; Data from 332BC to 332C6 (11 bytes)
.db $02 $00 $80 $C0 $01 $C7 $B2 $0A $00 $03 $00

; Data from 332C7 to 332D1 (11 bytes)
_DATA_332C7_:
.db $99 $04 $FB $01 $01 $F7 $00 $12 $C7 $B2 $F2

; 35th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 332D2 to 332D5 (4 bytes)
_DATA_332D2_:
.db $02 $80 $14 $03

; Pointer Table from 332D6 to 332D9 (2 entries,indexed by unknown)
.dw _DATA_332F9_ _DATA_100_

; Data from 332DA to 332E4 (11 bytes)
.db $43 $00 $80 $15 $03 $F8 $B2 $00 $00 $43 $00

; 35th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 332E5 to 332E8 (4 bytes)
_DATA_332E5_:
.db $02 $80 $A0 $03

; Pointer Table from 332E9 to 332EC (2 entries,indexed by unknown)
.dw _DATA_332F9_ _DATA_100_

; Data from 332ED to 332F8 (12 bytes)
.db $0A $00 $80 $C0 $03 $F8 $B2 $00 $00 $0A $00 $02

; Data from 332F9 to 33311 (25 bytes)
_DATA_332F9_:
.db $B5 $12 $B1 $06 $30 $B8 $06 $B6 $0C $B5 $06 $B3 $09 $B5 $B1 $06
.db $B1 $B5 $0C $B3 $AC $06 $AC $24 $F2

; 36th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33312 to 33315 (4 bytes)
_DATA_33312_:
.db $01 $88 $15 $01

; Pointer Table from 33316 to 33317 (1 entries,indexed by unknown)
.dw _DATA_33326_

; Data from 33318 to 3331B (4 bytes)
.db $00 $00 $00 $00

; 36th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 3331C to 3331F (4 bytes)
_DATA_3331C_:
.db $01 $88 $E0 $01

; Pointer Table from 33320 to 33321 (1 entries,indexed by unknown)
.dw _DATA_33338_

; Data from 33322 to 33325 (4 bytes)
.db $00 $00 $01 $00

; Data from 33326 to 33337 (18 bytes)
_DATA_33326_:
.db $FF $F0 $31 $0B $07 $F6 $E6 $FB $FA $03 $00 $14 $F7 $00 $03 $2F
.db $B3 $F2

; 1st entry of Pointer Table from 33320 (indexed by unknown)
; Data from 33338 to 33340 (9 bytes)
_DATA_33338_:
.db $00 $40 $0E $F7 $00 $03 $38 $B3 $F2

; 38th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33341 to 33344 (4 bytes)
_DATA_33341_:
.db $02 $80 $14 $01

; Pointer Table from 33345 to 33348 (2 entries,indexed by unknown)
.dw _DATA_33368_ _DATA_100_

; Data from 33349 to 33353 (11 bytes)
.db $80 $00 $80 $15 $01 $67 $B3 $00 $00 $80 $00

; 38th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33354 to 33357 (4 bytes)
_DATA_33354_:
.db $02 $80 $A0 $01

; Pointer Table from 33358 to 3335B (2 entries,indexed by unknown)
.dw _DATA_33368_ _DATA_100_

; Data from 3335C to 33367 (12 bytes)
.db $05 $00 $80 $C0 $01 $67 $B3 $00 $01 $05 $00 $02

; Data from 33368 to 33372 (11 bytes)
_DATA_33368_:
.db $A9 $0C $B0 $B1 $B0 $B1 $B3 $B0 $B5 $20 $F2

; 39th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33373 to 33376 (4 bytes)
_DATA_33373_:
.db $02 $A8 $14 $01

; Pointer Table from 33377 to 33378 (1 entries,indexed by unknown)
.dw _DATA_33399_

; Data from 33379 to 33385 (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $A7 $B3 $00 $00 $03 $00

; 39th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33386 to 33389 (4 bytes)
_DATA_33386_:
.db $02 $A8 $A0 $01

; Pointer Table from 3338A to 3338B (1 entries,indexed by unknown)
.dw _DATA_33399_

; Data from 3338C to 33398 (13 bytes)
.db $03 $00 $04 $00 $A8 $E0 $01 $BE $B3 $03 $00 $04 $00

; Data from 33399 to 333CB (51 bytes)
_DATA_33399_:
.db $03 $00 $33 $06 $F7 $00 $03 $B0 $B3 $03 $FF $F3 $14 $F2 $FF $61
.db $31 $0B $07 $F4 $F1 $66 $F6 $03 $00 $33 $06 $F7 $00 $03 $B0 $B3
.db $03 $FF $F3 $14 $F2 $00 $20 $06 $06 $F7 $00 $03 $BE $B3 $00 $FF
.db $F4 $14 $F2

; 40th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 333CC to 333CF (4 bytes)
_DATA_333CC_:
.db $02 $A8 $14 $01

; Pointer Table from 333D0 to 333D1 (1 entries,indexed by unknown)
.dw _DATA_3341D_

; Data from 333D2 to 333DE (13 bytes)
.db $00 $00 $F3 $00 $A8 $15 $01 $1D $B4 $00 $00 $D3 $00

; 40th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 333DF to 333E2 (4 bytes)
_DATA_333DF_:
.db $02 $A8 $A0 $01

; Pointer Table from 333E3 to 333E6 (2 entries,indexed by unknown)
.dw _DATA_333F2_ _DATA_30_

; Data from 333E7 to 333F1 (11 bytes)
.db $00 $04 $A8 $E0 $01 $06 $B4 $00 $00 $00 $00

; 1st entry of Pointer Table from 333E3 (indexed by unknown)
; Data from 333F2 to 3341C (43 bytes)
_DATA_333F2_:
.db $02 $00 $F8 $03 $01 $F0 $1C $0A $FC $00 $04 $00 $06 $03 $00 $06
.db $02 $00 $08 $F2 $00 $40 $E8 $03 $00 $10 $18 $0A $FC $00 $F5 $02
.db $04 $00 $40 $06 $00 $10 $06 $00 $30 $08 $F2

; Data from 3341D to 3343C (32 bytes)
_DATA_3341D_:
.db $02 $00 $F8 $03 $01 $F0 $1C $0A $F5 $00 $03 $FC $00 $FF $72 $31
.db $06 $07 $D2 $F2 $78 $FB $04 $00 $06 $01 $00 $03 $04 $00 $08 $F2

; 41st entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 3343D to 33440 (4 bytes)
_DATA_3343D_:
.db $02 $A8 $14 $01

; Pointer Table from 33441 to 33442 (1 entries,indexed by unknown)
.dw _DATA_33463_

; Data from 33443 to 3344F (13 bytes)
.db $00 $00 $13 $00 $A8 $15 $01 $7A $B4 $00 $00 $73 $00

; 41st entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33450 to 33453 (4 bytes)
_DATA_33450_:
.db $02 $A8 $A0 $01

; Pointer Table from 33454 to 33455 (1 entries,indexed by unknown)
.dw _DATA_33463_

; Data from 33456 to 33462 (13 bytes)
.db $00 $00 $07 $00 $A8 $E0 $01 $9A $B4 $00 $00 $07 $00

; Data from 33463 to 334B4 (82 bytes)
_DATA_33463_:
.db $03 $40 $0C $06 $F5 $00 $04 $00 $10 $07 $10 $FC $00 $03 $40 $04
.db $03 $20 $06 $03 $60 $06 $F2 $05 $40 $E0 $06 $03 $10 $57 $10 $F5
.db $00 $03 $FC $00 $FF $F1 $61 $0B $07 $F0 $B0 $84 $F6 $03 $40 $05
.db $05 $20 $06 $04 $60 $06 $F2 $F3 $03 $00 $40 $F7 $06 $F5 $00 $04
.db $00 $10 $07 $10 $F3 $07 $FC $00 $00 $40 $05 $00 $20 $06 $00 $60
.db $06 $F2

; 42nd entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 334B5 to 334B8 (4 bytes)
_DATA_334B5_:
.db $02 $88 $14 $01

; Pointer Table from 334B9 to 334BA (1 entries,indexed by unknown)
.dw _DATA_334DB_

; Data from 334BB to 334C7 (13 bytes)
.db $00 $00 $03 $00 $88 $15 $01 $F8 $B4 $00 $00 $03 $00

; 42nd entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 334C8 to 334CB (4 bytes)
_DATA_334C8_:
.db $02 $88 $A0 $01

; Pointer Table from 334CC to 334CD (1 entries,indexed by unknown)
.dw _DATA_334DB_

; Data from 334CE to 334DA (13 bytes)
.db $0E $09 $00 $00 $88 $E0 $01 $29 $B5 $0F $0A $00 $02

; Data from 334DB to 33545 (107 bytes)
_DATA_334DB_:
.db $03 $00 $06 $02 $40 $05 $F7 $00 $03 $DB $B4 $01 $00 $0A $FC $01
.db $03 $00 $12 $08 $FB $0A $0A $F7 $00 $04 $EB $B4 $F2 $FF $FF $33
.db $0B $07 $B1 $F2 $F8 $F7 $03 $00 $06 $02 $40 $05 $F7 $00 $03 $01
.db $B5 $FC $00 $01 $00 $0A $F5 $00 $00 $00 $00 $02 $FC $01 $F5 $00
.db $03 $03 $00 $12 $08 $FB $0A $0A $F7 $00 $04 $1C $B5 $F2 $03 $00
.db $06 $02 $40 $05 $F7 $00 $03 $DB $B4 $01 $00 $0A $FC $01 $03 $00
.db $12 $08 $FB $0A $0A $F7 $00 $04 $39 $B5 $F2

; 43rd entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33546 to 33549 (4 bytes)
_DATA_33546_:
.db $02 $A8 $14 $01

; Pointer Table from 3354A to 3354B (1 entries,indexed by unknown)
.dw _DATA_3357E_

; Data from 3354C to 33558 (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $7E $B5 $40 $00 $03 $00

; 43rd entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33559 to 3355C (4 bytes)
_DATA_33559_:
.db $02 $A8 $A0 $01

; Pointer Table from 3355D to 3355E (1 entries,indexed by unknown)
.dw _DATA_3356C_

; Data from 3355F to 3356B (13 bytes)
.db $00 $00 $00 $00 $A8 $E0 $01 $75 $B5 $00 $00 $00 $00

; 1st entry of Pointer Table from 3355D (indexed by unknown)
; Data from 3356C to 3357D (18 bytes)
_DATA_3356C_:
.db $03 $10 $F8 $08 $00 $FF $41 $0A $F2 $00 $20 $F8 $05 $00 $20 $0C
.db $0A $F2

; Data from 3357E to 3358F (18 bytes)
_DATA_3357E_:
.db $FF $F4 $23 $0B $07 $D2 $F2 $A5 $F5 $06 $00 $0A $08 $06 $00 $EC
.db $0F $F2

; 44th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33590 to 33593 (4 bytes)
_DATA_33590_:
.db $02 $A8 $14 $01

; Pointer Table from 33594 to 33595 (1 entries,indexed by unknown)
.dw _DATA_335D0_

; Data from 33596 to 335A2 (13 bytes)
.db $03 $00 $03 $00 $A8 $15 $01 $E6 $B5 $03 $00 $03 $00

; 44th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 335A3 to 335A6 (4 bytes)
_DATA_335A3_:
.db $02 $A8 $A0 $01

; Pointer Table from 335A7 to 335A8 (1 entries,indexed by unknown)
.dw _DATA_335B6_

; Data from 335A9 to 335B5 (13 bytes)
.db $00 $04 $09 $00 $A8 $E0 $01 $C3 $B5 $00 $00 $09 $00

; 1st entry of Pointer Table from 335A7 (indexed by unknown)
; Data from 335B6 to 335CF (26 bytes)
_DATA_335B6_:
.db $01 $00 $7A $08 $03 $80 $B3 $04 $00 $20 $00 $0E $F2 $00 $30 $04
.db $08 $00 $30 $04 $04 $00 $40 $F8 $0E $F2

; Data from 335D0 to 335F2 (35 bytes)
_DATA_335D0_:
.db $FF $F9 $3E $0B $07 $F2 $72 $F8 $FF $03 $00 $0A $08 $01 $80 $FE
.db $04 $00 $40 $00 $1E $F2 $01 $30 $04 $08 $04 $30 $04 $04 $01 $40
.db $F8 $1E $F2

; 45th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 335F3 to 335F6 (4 bytes)
_DATA_335F3_:
.db $02 $A8 $14 $01

; Pointer Table from 335F7 to 335F8 (1 entries,indexed by unknown)
.dw _DATA_33633_

; Data from 335F9 to 33605 (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $44 $B6 $00 $00 $03 $00

; 45th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33606 to 33609 (4 bytes)
_DATA_33606_:
.db $02 $88 $A0 $01

; Pointer Table from 3360A to 3360B (1 entries,indexed by unknown)
.dw _DATA_33619_

; Data from 3360C to 33618 (13 bytes)
.db $00 $00 $00 $00 $88 $E0 $01 $26 $B6 $00 $00 $00 $00

; 1st entry of Pointer Table from 3360A (indexed by unknown)
; Data from 33619 to 33632 (26 bytes)
_DATA_33619_:
.db $00 $80 $01 $03 $FF $04 $03 $80 $04 $03 $FF $06 $F2 $00 $20 $01
.db $00 $2F $04 $00 $10 $04 $00 $80 $06 $F2

; Data from 33633 to 3365D (43 bytes)
_DATA_33633_:
.db $04 $80 $08 $06 $04 $FF $FC $04 $04 $80 $FC $0A $04 $80 $F6 $0A
.db $F2 $FF $F1 $57 $0B $0A $F4 $D2 $F3 $F7 $06 $60 $20 $05 $05 $9F
.db $70 $04 $05 $80 $00 $02 $05 $80 $50 $0B $F2

; 46th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 3365E to 33661 (4 bytes)
_DATA_3365E_:
.db $02 $88 $14 $01

; Pointer Table from 33662 to 33663 (1 entries,indexed by unknown)
.dw _DATA_33695_

; Data from 33664 to 33670 (13 bytes)
.db $00 $00 $03 $00 $88 $15 $01 $95 $B6 $00 $00 $03 $00

; 46th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33671 to 33674 (4 bytes)
_DATA_33671_:
.db $02 $A8 $A0 $01

; Pointer Table from 33675 to 33676 (1 entries,indexed by unknown)
.dw _DATA_33684_

; Data from 33677 to 33683 (13 bytes)
.db $00 $00 $00 $00 $A8 $C0 $01 $84 $B6 $03 $01 $00 $00

; 1st entry of Pointer Table from 33675 (indexed by unknown)
; Data from 33684 to 33694 (17 bytes)
_DATA_33684_:
.db $04 $80 $08 $06 $04 $FF $FC $04 $04 $80 $FC $0A $04 $80 $F6 $0A
.db $F2

; Data from 33695 to 336AA (22 bytes)
_DATA_33695_:
.db $FF $FF $33 $05 $07 $B9 $F5 $F8 $F7 $05 $60 $03 $05 $FF $04 $05
.db $80 $02 $05 $80 $0B $F2

; 47th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 336AB to 336AE (4 bytes)
_DATA_336AB_:
.db $02 $A8 $14 $01

; Pointer Table from 336AF to 336B0 (1 entries,indexed by unknown)
.dw _DATA_336EC_

; Data from 336B1 to 336BD (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $F5 $B6 $0E $00 $03 $00

; 47th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 336BE to 336C1 (4 bytes)
_DATA_336BE_:
.db $02 $A8 $A0 $01

; Pointer Table from 336C2 to 336C3 (1 entries,indexed by unknown)
.dw _DATA_336D1_

; Data from 336C4 to 336D0 (13 bytes)
.db $00 $00 $00 $00 $A8 $E0 $01 $DA $B6 $00 $00 $00 $00

; 1st entry of Pointer Table from 336C2 (indexed by unknown)
; Data from 336D1 to 336EB (27 bytes)
_DATA_336D1_:
.db $00 $70 $2E $08 $03 $B0 $92 $06 $F2 $F3 $03 $00 $01 $03 $04 $00
.db $01 $2A $06 $F5 $04 $04 $00 $40 $06 $06 $F2

; Data from 336EC to 33701 (22 bytes)
_DATA_336EC_:
.db $FF $FD $3A $0B $07 $B1 $F2 $F8 $F7 $05 $20 $FE $08 $04 $20 $02
.db $06 $05 $40 $06 $06 $F2

; 48th entry of Pointer Table from 303F2 (indexed by NewMusic)
; Data from 33702 to 33705 (4 bytes)
_DATA_33702_:
.db $02 $A8 $14 $01

; Pointer Table from 33706 to 33707 (1 entries,indexed by unknown)
.dw _DATA_3374C_

; Data from 33708 to 33714 (13 bytes)
.db $00 $00 $03 $00 $A8 $15 $01 $4C $B7 $18 $00 $03 $00

; 48th entry of Pointer Table from 30360 (indexed by NewMusic)
; Data from 33715 to 33718 (4 bytes)
_DATA_33715_:
.db $02 $A8 $A0 $01

; Pointer Table from 33719 to 3371A (1 entries,indexed by unknown)
.dw _DATA_33728_

; Data from 3371B to 33727 (13 bytes)
.db $00 $00 $00 $00 $A8 $E0 $01 $39 $B7 $00 $00 $00 $00

; 1st entry of Pointer Table from 33719 (indexed by unknown)
; Data from 33728 to 3374B (36 bytes)
_DATA_33728_:
.db $00 $10 $4A $04 $03 $40 $06 $05 $03 $00 $FC $06 $03 $F0 $BA $05
.db $F2 $F3 $03 $00 $01 $0A $04 $00 $02 $06 $05 $00 $01 $0C $03 $00
.db $01 $0A $06 $F2

; Data from 3374C to 33765 (26 bytes)
_DATA_3374C_:
.db $FF $FA $39 $0B $07 $B1 $C2 $78 $A7 $05 $F0 $AA $08 $05 $40 $06
.db $08 $05 $00 $FC $06 $05 $40 $0A $0A $F2

; Pointer Table from 33766 to 3377B (11 entries,indexed by _RAM_C0F5_)
_DATA_33766_:
.dw _DATA_3377C_ _DATA_3377F_ _DATA_3378C_ _DATA_33795_ _DATA_3379E_ _DATA_337A9_ _DATA_337C8_ _DATA_337D3_
.dw _DATA_337E4_ _DATA_337F0_ _DATA_337FA_

; 1st entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 3377C to 3377E (3 bytes)
_DATA_3377C_:
.db $00 $00 $82

; 2nd entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 3377F to 3378B (13 bytes)
_DATA_3377F_:
.db $00 $00 $01 $02 $02 $03 $03 $04 $04 $05 $05 $06 $82

; 3rd entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 3378C to 33794 (9 bytes)
_DATA_3378C_:
.db $01 $00 $01 $01 $03 $04 $07 $0A $82

; 4th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 33795 to 3379D (9 bytes)
_DATA_33795_:
.db $01 $00 $00 $00 $00 $00 $01 $01 $82

; 5th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 3379E to 337A8 (11 bytes)
_DATA_3379E_:
.db $02 $01 $00 $01 $02 $02 $03 $03 $04 $04 $81

; 6th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 337A9 to 337C7 (31 bytes)
_DATA_337A9_:
.db $00 $00 $01 $01 $01 $01 $02 $02 $02 $02 $03 $03 $03 $03 $04 $04
.db $04 $04 $05 $05 $05 $05 $06 $06 $06 $06 $07 $07 $07 $08 $81

; 7th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 337C8 to 337D2 (11 bytes)
_DATA_337C8_:
.db $04 $04 $03 $03 $02 $02 $01 $01 $02 $02 $81

; 8th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 337D3 to 337E3 (17 bytes)
_DATA_337D3_:
.db $00 $00 $00 $00 $00 $00 $04 $05 $06 $07 $08 $09 $0A $0B $0E $0F
.db $82

; 9th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 337E4 to 337EF (12 bytes)
_DATA_337E4_:
.db $00 $00 $01 $01 $03 $03 $04 $05 $05 $05 $83 $04

; 10th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 337F0 to 337F9 (10 bytes)
_DATA_337F0_:
.db $02 $02 $03 $03 $02 $02 $01 $01 $00 $00

; 11th entry of Pointer Table from 33766 (indexed by _RAM_C0F5_)
; Data from 337FA to 33804 (11 bytes)
_DATA_337FA_:
.db $02 $01 $00 $00 $01 $01 $02 $03 $04 $05 $81

; Pointer Table from 33805 to 3380E (5 entries,indexed by _RAM_C114_)
_DATA_33805_:
.dw _DATA_3380F_ _DATA_33825_ _DATA_33841_ _DATA_33858_ _DATA_33858_

; 1st entry of Pointer Table from 33805 (indexed by _RAM_C114_)
; Data from 3380F to 33824 (22 bytes)
_DATA_3380F_:
.dsb 10,$01
.db $00 $00 $01 $01 $02 $02 $01 $00 $01 $01 $02 $02

; 2nd entry of Pointer Table from 33805 (indexed by _RAM_C114_)
; Data from 33825 to 33840 (28 bytes)
_DATA_33825_:
.db $01 $00 $00 $01 $02 $03 $03 $02 $01 $00 $00 $01 $02 $03 $03 $02
.db $02 $01 $00 $00 $00 $01 $02 $03 $04 $03 $02 $01

; 3rd entry of Pointer Table from 33805 (indexed by _RAM_C114_)
; Data from 33841 to 33857 (23 bytes)
_DATA_33841_:
.db $00 $01 $02 $04 $05 $04 $03 $02 $01 $00 $01 $02 $03 $04 $05 $04
.db $03 $02 $01 $00 $01 $01 $81

; 4th entry of Pointer Table from 33805 (indexed by _RAM_C114_)
; Data from 33858 to 33FFF (1960 bytes)
_DATA_33858_:
.incbin "Phantasy Star (Japan)_DATA_33858_.inc"
.ends

;=======================================================================================================
; Bank 13: $34000 - $37fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 13 slot 2
/*
.orga $8000
.section "WorldData1" overwrite
WorldData1:
.dw _d00 _d01 _d02 _d03 _d04 _d05 _d06 _d07 _d08 _d09 _d10 _d11 _d12 _d13 _d14 _d15 _d16 _d17 _d18 _d19 _d20 _d21 _d22 _d23 _d24 _d25 _d26 _d27 _d28 _d29 _d30 _d31 _d32 _d33 _d34 _d35 _d36 _d37 _d38 _d39 _d40 _d41 _d42 _d43 _d44 _d45 _d46 _d47 _d48 _d49 _d50 _d51 _d52 _d53 _d54 _d55 _d56 _d57 _d58 _d59 _d60 _d61 _d62 _d63 _d64 _d65 _d66 _d67 _d68 _d69 _d70 _d71 _d72 _d73 _d74 _d75 _d76 _d77 _d78 _d79 _d80

_d00: .incbin "Tilemaps\340a2tilemap.dat"
_d01: .incbin "Tilemaps\340e8map.bin"
_d02: .incbin "Tilemaps\34118map.bin"
_d03: .incbin "Tilemaps\34141map.bin"
_d04: .incbin "Tilemaps\3418dmap.bin"
_d05: .incbin "Tilemaps\341dcmap.bin"
_d06: .incbin "Tilemaps\3424amap.bin"
_d07: .incbin "Tilemaps\342d6map.bin"
_d08: .incbin "Tilemaps\340a2map.bin"
_d09: .incbin "Tilemaps\34371map.bin"
_d10: .incbin "Tilemaps\34404map.bin"
_d11: .incbin "Tilemaps\344a6map.bin"
_d12: .incbin "Tilemaps\34548map.bin"
_d13: .incbin "Tilemaps\345damap.bin"
_d14: .incbin "Tilemaps\34672map.bin"
_d15: .incbin "Tilemaps\34718map.bin"
_d16: .incbin "Tilemaps\347d5map.bin"
_d17: .incbin "Tilemaps\34371map.bin"
_d18: .incbin "Tilemaps\34887map.bin"
_d19: .incbin "Tilemaps\34906map.bin"
_d20: .incbin "Tilemaps\349b2map.bin"
_d21: .incbin "Tilemaps\34a43map.bin"
_d22: .incbin "Tilemaps\34aeemap.bin"
_d23: .incbin "Tilemaps\34ba8map.bin"
_d24: .incbin "Tilemaps\34c2cmap.bin"
_d25: .incbin "Tilemaps\34cdamap.bin"
_d26: .incbin "Tilemaps\34887map.bin"
_d27: .incbin "Tilemaps\34d57map.bin"
_d28: .incbin "Tilemaps\34dbdmap.bin"
_d29: .incbin "Tilemaps\34e69map.bin"
_d30: .incbin "Tilemaps\34f02map.bin"
_d31: .incbin "Tilemaps\34fb5map.bin"
_d32: .incbin "Tilemaps\35049map.bin"
_d33: .incbin "Tilemaps\350eamap.bin"
_d34: .incbin "Tilemaps\3517bmap.bin"
_d35: .incbin "Tilemaps\35d57map.bin"
_d36: .incbin "Tilemaps\351c8map.bin"
_d37: .incbin "Tilemaps\351ffmap.bin"
_d38: .incbin "Tilemaps\35299map.bin"
_d39: .incbin "Tilemaps\35302map.bin"
_d40: .incbin "Tilemaps\353bdmap.bin"
_d41: .incbin "Tilemaps\35453map.bin"
_d42: .incbin "Tilemaps\354d6map.bin"
_d43: .incbin "Tilemaps\35595map.bin"
_d44: .incbin "Tilemaps\351c8map.bin"
_d45: .incbin "Tilemaps\3563cmap.bin"
_d46: .incbin "Tilemaps\3568dmap.bin"
_d47: .incbin "Tilemaps\35731map.bin"
_d48: .incbin "Tilemaps\357dfmap.bin"
_d49: .incbin "Tilemaps\35895map.bin"
_d50: .incbin "Tilemaps\35934map.bin"
_d51: .incbin "Tilemaps\359e1map.bin"
_d52: .incbin "Tilemaps\35a80map.bin"
_d53: .incbin "Tilemaps\3563cmap.bin"
_d54: .incbin "Tilemaps\35addmap.bin"
_d55: .incbin "Tilemaps\35b1dmap.bin"
_d56: .incbin "Tilemaps\35bd1map.bin"
_d57: .incbin "Tilemaps\35c93map.bin"
_d58: .incbin "Tilemaps\35d4fmap.bin"
_d59: .incbin "Tilemaps\35e11map.bin"
_d60: .incbin "Tilemaps\35ec5map.bin"
_d61: .incbin "Tilemaps\35f0cmap.bin"
_d62: .incbin "Tilemaps\35addmap.bin"
_d63: .incbin "Tilemaps\35f6cmap.bin"
_d64: .incbin "Tilemaps\35fb2map.bin"
_d65: .incbin "Tilemaps\3603dmap.bin"
_d66: .incbin "Tilemaps\360cbmap.bin"
_d67: .incbin "Tilemaps\3615amap.bin"
_d68: .incbin "Tilemaps\361aamap.bin"
_d69: .incbin "Tilemaps\36204map.bin"
_d70: .incbin "Tilemaps\3623dmap.bin"
_d71: .incbin "Tilemaps\35f6cmap.bin"
_d72: .incbin "Tilemaps\340a2map.bin"
_d73: .incbin "Tilemaps\340e8map.bin"
_d74: .incbin "Tilemaps\34118map.bin"
_d75: .incbin "Tilemaps\34141map.bin"
_d76: .incbin "Tilemaps\3418dmap.bin"
_d77: .incbin "Tilemaps\341dcmap.bin"
_d78: .incbin "Tilemaps\3424amap.bin"
_d79: .incbin "Tilemaps\342d6map.bin"
_d80: .incbin "Tilemaps\340a2map.bin"

.ends
; followed by
.org $36276-$34000
.section "WorldData2" overwrite
; Another table referring to compressed data after it
WorldData2:
.dw _d00 _d01 _d02 _d03 _d04 _d05 _d06 _d07 _d08 _d09 _d10 _d11 _d12 _d13 _d14 _d15 _d16 _d17 _d18 _d19 _d20 _d21 _d22 _d23 _d24 _d25 _d26 _d27 _d28 _d29 _d30 _d31 _d32 _d33 _d34 _d35 _d36 _d37 _d38 _d39 _d40 _d41 _d42 _d43 _d44 _d45 _d46 _d47 _d48 _d49 _d50 _d51 _d52 _d53 _d54 _d55 _d56 _d57 _d58 _d59 _d60 _d61 _d62 _d63 _d64 _d65 _d66 _d67 _d68 _d69 _d70 _d71 _d72 _d73 _d74 _d75 _d76 _d77 _d78 _d79 _d80

_d00: .incbin "Tilemaps\a318map.bin"
_d01: .incbin "Tilemaps\a32fmap.bin"
_d02: .incbin "Tilemaps\a357map.bin"
_d03: .incbin "Tilemaps\a3b4map.bin"
_d04: .incbin "Tilemaps\a46emap.bin"
_d05: .incbin "Tilemaps\a523map.bin"
_d06: .incbin "Tilemaps\a5b1map.bin"
_d07: .incbin "Tilemaps\a619map.bin"
_d08: .incbin "Tilemaps\a318map.bin"
_d09: .incbin "Tilemaps\a66bmap.bin"
_d10: .incbin "Tilemaps\a682map.bin"
_d11: .incbin "Tilemaps\a6b8map.bin"
_d12: .incbin "Tilemaps\a745map.bin"
_d13: .incbin "Tilemaps\a7f9map.bin"
_d14: .incbin "Tilemaps\a8a5map.bin"
_d15: .incbin "Tilemaps\a958map.bin"
_d16: .incbin "Tilemaps\aa01map.bin"
_d17: .incbin "Tilemaps\a66bmap.bin"
_d18: .incbin "Tilemaps\aac2map.bin"
_d19: .incbin "Tilemaps\ab1bmap.bin"
_d20: .incbin "Tilemaps\ab6bmap.bin"
_d21: .incbin "Tilemaps\abbcmap.bin"
_d22: .incbin "Tilemaps\ac51map.bin"
_d23: .incbin "Tilemaps\ac9dmap.bin"
_d24: .incbin "Tilemaps\acffmap.bin"
_d25: .incbin "Tilemaps\ad8cmap.bin"
_d26: .incbin "Tilemaps\aac2map.bin"
_d27: .incbin "Tilemaps\ae4dmap.bin"
_d28: .incbin "Tilemaps\ae6amap.bin"
_d29: .incbin "Tilemaps\aebemap.bin"
_d30: .incbin "Tilemaps\af33map.bin"
_d31: .incbin "Tilemaps\af52map.bin"
_d32: .incbin "Tilemaps\af75map.bin"
_d33: .incbin "Tilemaps\affcmap.bin"
_d34: .incbin "Tilemaps\b05bmap.bin"
_d35: .incbin "Tilemaps\ae4dmap.bin"
_d36: .incbin "Tilemaps\b108map.bin"
_d37: .incbin "Tilemaps\b138map.bin"
_d38: .incbin "Tilemaps\b1a0map.bin"
_d39: .incbin "Tilemaps\b222map.bin"
_d40: .incbin "Tilemaps\b2d7map.bin"
_d41: .incbin "Tilemaps\b34fmap.bin"
_d42: .incbin "Tilemaps\b409map.bin"
_d43: .incbin "Tilemaps\b4b1map.bin"
_d44: .incbin "Tilemaps\b108map.bin"
_d45: .incbin "Tilemaps\b570map.bin"
_d46: .incbin "Tilemaps\b5b7map.bin"
_d47: .incbin "Tilemaps\b623map.bin"
_d48: .incbin "Tilemaps\b6c8map.bin"
_d49: .incbin "Tilemaps\b781map.bin"
_d50: .incbin "Tilemaps\b7e1map.bin"
_d51: .incbin "Tilemaps\b7fcmap.bin"
_d52: .incbin "Tilemaps\b82amap.bin"
_d53: .incbin "Tilemaps\b570map.bin"
_d54: .incbin "Tilemaps\b86dmap.bin"
_d55: .incbin "Tilemaps\b8a3map.bin"
_d56: .incbin "Tilemaps\b8f5map.bin"
_d57: .incbin "Tilemaps\b9a1map.bin"
_d58: .incbin "Tilemaps\ba43map.bin"
_d59: .incbin "Tilemaps\babfmap.bin"
_d60: .incbin "Tilemaps\baf6map.bin"
_d61: .incbin "Tilemaps\bb22map.bin"
_d62: .incbin "Tilemaps\b86dmap.bin"
_d63: .incbin "Tilemaps\bb4dmap.bin"
_d64: .incbin "Tilemaps\bb7cmap.bin"
_d65: .incbin "Tilemaps\bba7map.bin"
_d66: .incbin "Tilemaps\bc08map.bin"
_d67: .incbin "Tilemaps\bc80map.bin"
_d68: .incbin "Tilemaps\bcd0map.bin"
_d69: .incbin "Tilemaps\bd3amap.bin"
_d70: .incbin "Tilemaps\bd78map.bin"
_d71: .incbin "Tilemaps\bb4dmap.bin"
_d72: .incbin "Tilemaps\a318map.bin"
_d73: .incbin "Tilemaps\a32fmap.bin"
_d74: .incbin "Tilemaps\a357map.bin"
_d75: .incbin "Tilemaps\a3b4map.bin"
_d76: .incbin "Tilemaps\a46emap.bin"
_d77: .incbin "Tilemaps\a523map.bin"
_d78: .incbin "Tilemaps\a5b1map.bin"
_d79: .incbin "Tilemaps\a619map.bin"
_d80: .incbin "Tilemaps\a318map.bin"

.ends
;.org 37fda
; Blank until end of bank
*/
;=======================================================================================================
; Bank 14: $38000 - $3bfff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 14 slot 2
.orga $8000
/*
.section "WorldData3" overwrite
WorldData3:
.dw _d00 _d01 _d02 _d03 _d04 _d05 _d06 _d07 _d08 _d09 _d10 _d11 _d12 _d13 _d14 _d15 _d16 _d17 _d18 _d19 _d20 _d21 _d22 _d23 _d24 _d25 _d26 _d27 _d28 _d29 _d30 _d31 _d32 _d33 _d34 _d35 _d36 _d37 _d38 _d39 _d40 _d41 _d42 _d43 _d44 _d45 _d46 _d47 _d48 _d49 _d50 _d51 _d52 _d53 _d54 _d55 _d56 _d57 _d58 _d59 _d60 _d61 _d62 _d63 _d64 _d65 _d66 _d67 _d68 _d69 _d70 _d71 _d72 _d73 _d74 _d75 _d76 _d77 _d78 _d79 _d80

_d00: .incbin "Tilemaps\80a2map.bin"
_d01: .incbin "Tilemaps\80cdmap.bin"
_d02: .incbin "Tilemaps\8176map.bin"
_d03: .incbin "Tilemaps\8239map.bin"
_d04: .incbin "Tilemaps\82f7map.bin"
_d05: .incbin "Tilemaps\83bamap.bin"
_d06: .incbin "Tilemaps\8431map.bin"
_d07: .incbin "Tilemaps\84f0map.bin"
_d08: .incbin "Tilemaps\80a2map.bin"
_d09: .incbin "Tilemaps\8521map.bin"
_d10: .incbin "Tilemaps\85aamap.bin"
_d11: .incbin "Tilemaps\8618map.bin"
_d12: .incbin "Tilemaps\8680map.bin"
_d13: .incbin "Tilemaps\86b7map.bin"
_d14: .incbin "Tilemaps\8715map.bin"
_d15: .incbin "Tilemaps\87b4map.bin"
_d16: .incbin "Tilemaps\8819map.bin"
_d17: .incbin "Tilemaps\8521map.bin"
_d18: .incbin "Tilemaps\88bdmap.bin"
_d19: .incbin "Tilemaps\896bmap.bin"
_d20: .incbin "Tilemaps\89d7map.bin"
_d21: .incbin "Tilemaps\8a35map.bin"
_d22: .incbin "Tilemaps\8a62map.bin"
_d23: .incbin "Tilemaps\8ademap.bin"
_d24: .incbin "Tilemaps\8b45map.bin"
_d25: .incbin "Tilemaps\8bf2map.bin"
_d26: .incbin "Tilemaps\88bdmap.bin"
_d27: .incbin "Tilemaps\8c77map.bin"
_d28: .incbin "Tilemaps\8d2cmap.bin"
_d29: .incbin "Tilemaps\8dddmap.bin"
_d30: .incbin "Tilemaps\8e6amap.bin"
_d31: .incbin "Tilemaps\8f2dmap.bin"
_d32: .incbin "Tilemaps\8fd1map.bin"
_d33: .incbin "Tilemaps\907dmap.bin"
_d34: .incbin "Tilemaps\90demap.bin"
_d35: .incbin "Tilemaps\8c77map.bin"
_d36: .incbin "Tilemaps\9123map.bin"
_d37: .incbin "Tilemaps\91b2map.bin"
_d38: .incbin "Tilemaps\9216map.bin"
_d39: .incbin "Tilemaps\92bcmap.bin"
_d40: .incbin "Tilemaps\936bmap.bin"
_d41: .incbin "Tilemaps\942emap.bin"
_d42: .incbin "Tilemaps\9487map.bin"
_d43: .incbin "Tilemaps\948cmap.bin"
_d44: .incbin "Tilemaps\9123map.bin"
_d45: .incbin "Tilemaps\94a1map.bin"
_d46: .incbin "Tilemaps\9533map.bin"
_d47: .incbin "Tilemaps\95eamap.bin"
_d48: .incbin "Tilemaps\9679map.bin"
_d49: .incbin "Tilemaps\973emap.bin"
_d50: .incbin "Tilemaps\9801map.bin"
_d51: .incbin "Tilemaps\98abmap.bin"
_d52: .incbin "Tilemaps\98b2map.bin"
_d53: .incbin "Tilemaps\94a1map.bin"
_d54: .incbin "Tilemaps\992bmap.bin"
_d55: .incbin "Tilemaps\99e8map.bin"
_d56: .incbin "Tilemaps\9a98map.bin"
_d57: .incbin "Tilemaps\9b2fmap.bin"
_d58: .incbin "Tilemaps\9bebmap.bin"
_d59: .incbin "Tilemaps\9caemap.bin"
_d60: .incbin "Tilemaps\9d71map.bin"
_d61: .incbin "Tilemaps\9e29map.bin"
_d62: .incbin "Tilemaps\992bmap.bin"
_d63: .incbin "Tilemaps\9ee3map.bin"
_d64: .incbin "Tilemaps\9f2dmap.bin"
_d65: .incbin "Tilemaps\9fe6map.bin"
_d66: .incbin "Tilemaps\a09dmap.bin"
_d67: .incbin "Tilemaps\a161map.bin"
_d68: .incbin "Tilemaps\a21emap.bin"
_d69: .incbin "Tilemaps\a2e1map.bin"
_d70: .incbin "Tilemaps\a3a3map.bin"
_d71: .incbin "Tilemaps\9ee3map.bin" ; These are not right, we have reused bins
_d72: .incbin "Tilemaps\80a2map.bin"
_d73: .incbin "Tilemaps\80cdmap.bin"
_d74: .incbin "Tilemaps\8176map.bin"
_d75: .incbin "Tilemaps\8239map.bin"
_d76: .incbin "Tilemaps\82f7map.bin"
_d77: .incbin "Tilemaps\83bamap.bin"
_d78: .incbin "Tilemaps\8431map.bin"
_d79: .incbin "Tilemaps\84f0map.bin"
_d80: .incbin "Tilemaps\80a2map.bin"
.ends
*/
; followed by
.orga $a3e8
.section "Outside area tile animations" overwrite
TilesOutsideAnimation:
TilesOutsideSeaShore: ; $3a3e8
.incbin "Tiles\3a3e8raw Outside seashore.dat" ; 5 frames x 12 tiles x 32 bytes per tile
TilesOutsideSea:       ; $3ab68
.incbin "Tiles\3ab68raw Outside sea.dat" ; 4 frames x 3 tiles x 32 bytes per tile
TilesRoadway:          ; $3ace8
.incbin "Tiles\3ace8raw Outside roadway.dat" ; 4 frames x 6 tiles x 32 bytes per tiles
TilesLavaPit:          ; $3afe8
.incbin "Tiles\3afe8raw Outside lava pit.dat" ; 3 frames x 8 tiles x 32 bytes per tiles
TilesAntlionHill:      ; $3b2e8
.incbin "Tiles\3b2e8raw Outside Antlion hill.dat" ; 4 frames x 16 tiles x 32 bytes per tile
TilesSmoke:            ; $3bae8
.incbin "Tiles\3bae8raw Outside smoke.dat" ; 4 frames x 4 tiles x 32 bytes per tile
.ends
; followed by
.orga $bc68
.section "Title screen tilemap" overwrite
TitleScreenTilemap:
.incbin "Tilemaps\3BC68 Title screen tilemap.dat"
.ends
.orga $bf60
; blank until end of slot

;=======================================================================================================
; Bank 15: $3c000 - $3ffff
;=======================================================================================================
.bank 15 slot 2
.orga $8000
.section "Tilemap data 4" overwrite
; Enemy scenes
TilemapPalmaOpen:
.incbin "Tilemaps\3C000tilemap.dat"
TilemapPalmaForest:
.incbin "Tilemaps\3C333tilemap.dat"
TilemapPalmaSea:
.incbin "Tilemaps\3C6E9tilemap.dat"
TilemapPalmaCoast:
.incbin "Tilemaps\3C9A0tilemap.dat"
TilemapMotabiaOpen:
.incbin "Tilemaps\3CC80tilemap.dat"
TilemapDezorisOpen:
.incbin "Tilemaps\3CE46tilemap.dat"
TilemapPalmaLavapit:
.incbin "Tilemaps\3D116tilemap.dat"
TilemapPalmaTown:
.incbin "Tilemaps\3D47Btilemap.dat"
TilemapPalmaVillage:
.incbin "Tilemaps\3D70Atilemap.dat"
TilemapSpaceport:
.incbin "Tilemaps\3DA2Ctilemap.dat"
TilemapDeadTrees:
.incbin "Tilemaps\3DC11tilemap.dat"
.ends
;.org 3df6e

; Data from 3DF6E to 3FDED (7808 bytes)
DungeonMaps:

.stringmaptable dungeons "Dungeons.tbl"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱⏫🌫🌫🌫🌫🧱🌫🧱🧱🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫📦🧱🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🌫🌫🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🌫🌫🌫🧱🌫🧱🌫🧱⏩🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱⏫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱📦🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🧱🧱🌫🌫🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫📦🧱🧱🧱🧱📦🌫🌫🧱⏫🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱⏫🌫🌫🌫🌫🧱🌫🧱🧱🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫📦🧱🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🌫🌫🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🌫🌫🌫🧱🌫🧱🌫🧱⏩🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱⏫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱📦🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🧱🧱🌫🌫🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫📦🧱🧱🧱🧱📦🌫🌫🧱⏫🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱📦🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱⏹🧱🧱🔐🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🔐🌫📦🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🔐🧱🧱⏹🧱🧱🧱⏹🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱⏹🧱🧱🧱🧱⏹🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱📦🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱⏹🧱🧱🧱🔐🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱⏩🧱🧱🧱🧱🧱🧱📦🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱⏫🌫🌫🌫🌫🧱📦🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱📦🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🔐🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🧱🌫🧱📦🌫🚪🌫🌫🌫🧱⏫🧱"
.stringmap dungeons "🧱🔐🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🔐🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🔐🌫🌫🌫🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🌫🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱📦🌫📦🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🔐🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🌫🌫🧱📦🌫📦🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🔐🧱🧱🧱🧱🌫🧱🔐🧱🔐🧱🧱🔼🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱📦🌫🔐🌫🌫🌫🧱📦🧱🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫📦🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🔼🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🧱🧱🌫🧱🌫🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🌫🧱🧱📦🧱🧱🔼🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🧱🧱🧱🌫🌫🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🔽🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱⏹🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫📦🧱🧱⏩🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🔽🧱🌫🧱📦🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🔼🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🌫🧱🔐🧱📦🧱🔽🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🌫🔐🌫🌫🧱🧱"
.stringmap dungeons "🧱🔐🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱📦🧱📦🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🔐🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🔐🌫📦🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱📦🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🔐🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🔽🧱⏹🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱📦🧱🌫🧱🔼🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🔐🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🔐🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱📦🌫🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🧱🌫🔐🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🔐🧱🔼🧱🌫🧱🔐🧱🔽🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱📦🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫📦🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫⏹🧱🧱🧱📦🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🔐🌫🌫🌫🌫🧱📦🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🔼🧱"
.stringmap dungeons "🧱🔼🧱🧱🧱🔐🧱🌫🧱🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔽🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱📦🧱🌫🧱🌫🌫🔐🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱⏹🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🔼🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🧱📦🧱🧱🌫🌫🔐🌫🔼🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🔐🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🔼🌫🌫🌫🧱🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🔽🧱"
.stringmap dungeons "🧱🔽🧱🧱🧱🔼🌫🌫🧱🧱🔼🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱📦🧱🧱🌫🧱🧱🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🔼🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🔼🧱🌫🧱🌫🧱🌫🌫🔽🧱🧱🔼🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🔼🧱🌫🌫🌫🧱🧱🔽🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🌫🌫🌫🌫🎩🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🔽🧱🧱📦🌫📦🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🔼🧱"
.stringmap dungeons "🧱🔐🧱🌫🌫🔽🧱🧱📦🧱🔽🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🌫🌫🔐🌫📦🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🌫🌫🔽🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🔼🧱🔽🧱🧱🧱🌫🌫📦🧱📦🌫🧱🔽🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔽🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱📦🌫🌫🌫🌫🌫🔼🧱🧱🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱📦🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🔼🌫🌫🧱🔐🧱🔽🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🌫🧱🧱🧱🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🔽🧱🌫🌫🌫🧱🧱🧱🎩🧱🧱🧱🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🔼🧱🌫🧱🔼🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🌫🧱🌫🧱⏩🧱🌫🧱🧱🔼🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🌫🌫🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🧱🧱🧱🧱🔽🌫🌫🌫📦🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🌫🌫🌫🔼🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🌫🧱🧱🧱🧱📦🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🌫🔽🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🌫🌫🧱🔼🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🔐🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱📦🧱🌫🌫🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🌫🧱🧱🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱📦🧱🌫🧱📦🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔼🧱🌫🧱🔽🧱🌫🧱🔽🧱🧱🧱🧱"
.stringmap dungeons "🧱🔼🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🔽🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🔼🧱🧱🧱🔽🌫🌫🔼🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🧱🧱🧱🌫🧱🔽🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫📦🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🌫🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🔐🧱"
.stringmap dungeons "🧱🌫🧱🔽🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🔽🧱🌫🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🌫🧱🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫📦🧱🧱📦🧱🧱📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🌫🧱🧱🔽🌫🌫🌫🌫🧱🧱🔽🌫🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🌫🌫🌫🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🌫🌫🌫🔼🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🔐🌫🌫🔼🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🔐🌫🌫🌫🌫📦🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🔐🌫🌫🌫🌫🔼🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🌫🌫🌫📦🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🚪🌫🌫🌫🚪🌫🌫🌫⏫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🚪🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🌫🌫🚪🌫🌫📦🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🚪🌫🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🔽🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🚪🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🔽🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫⏹🧱🧱🌫🧱🧱🔽🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🔼🧱🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱📦🧱🌫🌫⏩🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱📦🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱🔐🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🚪🌫🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🚪🧱📦🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱📦🌫🧱🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🧱🌫🌫🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫📦🧱🧱🌫🧱📦🧱🌫🧱🧱"
.stringmap dungeons "🧱🔽🧱🌫🧱🧱🧱🧱🧱🌫🌫🧱🌫📦🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🔼🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🌫🧱🌫🌫🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🧱🧱🌫🧱🌫🌫🔐🌫📦🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🚪🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🧱🔼🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🚪🌫🌫🧱🌫🧱🌫🧱🌫🧱🧱🔼🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🌫🧱🧱🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🌫🌫🚪🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🧱📦📦🌫🌫🧱📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🌫🧱🌫📦🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🔽🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🧱🧱🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫📦🧱🚪🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫📦🧱📦🌫🌫🧱🌫🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🧱🔽🧱🧱🌫🧱"
.stringmap dungeons "🧱🔐🧱🔼🧱🌫🧱🌫🌫🧱🧱🧱🧱🧱🔽🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🧱🌫🧱🧱📦🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🚪🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫⏫🧱🧱🌫🌫🌫🌫🚪🌫🌫📦🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🔐🧱📦🌫🌫🧱🌫🌫📦🧱🧱⏩🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🌫🧱🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🌫🌫🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱🚪🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱📦🧱🌫🌫🌫🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🔽🧱🧱🧱🌫🧱🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🌫🌫🧱🧱🌫🧱🌫🧱🔐🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🧱📦🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱⏩🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🌫🧱🧱⏹🌫🌫🌫⏹🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫⏹🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱⏹🌫🌫🌫⏹🧱🧱"
.stringmap dungeons "🧱🌫🌫⏹🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🎩🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱⏹🌫🌫🧱🔼🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🌫🌫⏩🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🌫🌫🧱🧱🧱⏩🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱📦🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🚪🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🌫🧱🌫🧱🔽🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🌫🧱📦🧱🧱🧱⏹🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱⏫🧱🌫🌫🌫🌫🧱⏩⏫🧱🧱🧱🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱⏫🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫⏹🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱📦🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🌫🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🔐🧱🌫🌫🌫🌫🔐🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🔼🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🧱🌫🌫🌫🔼🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🔐🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🔼🌫🌫🧱🌫🌫📦🧱🔐🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🔐🌫🌫🌫🔐🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱⏩🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱📦🧱🌫🌫🌫🧱📦🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🔽🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🔼🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🌫🧱🔼🧱🧱🔽🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🌫🔽🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱📦🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🧱🧱📦🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱⏹🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫📦🧱🔼🧱🧱🌫🧱🔼🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🔽🧱🌫🌫🌫🌫🧱🧱🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🔽🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱📦🧱🌫🧱🌫🧱📦🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🌫🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🌫🌫🌫🌫🧱🧱🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🌫🧱📦🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🧱📦🧱🌫🧱🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🧱🧱🌫🌫🌫🌫🧱📦🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📦🧱🌫🧱🔽🧱🌫🧱🧱🔽🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🔼🌫🔐🌫🌫🌫🌫🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🔐🌫📦🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🔐🧱🔐🧱🌫🧱🧱🧱🧱🧱🧱🔐🧱🔐🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🔽🧱🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🌫🔐🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🧱🧱📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🌫🌫🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🚪🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔼🧱🧱🧱🧱🌫🧱🧱🧱🚪🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫📦🧱🌫🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🌫🌫🧱🌫🌫🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🧱⏩🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱📦🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🔽🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🌫🌫🔼🧱📦🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱📄🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🌫🧱🧱⏫🌫🌫🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫📦🧱🔽🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🚪🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🎆🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🚪🧱🚪🧱🎩🧱🧱📦🧱🌫🧱🚪🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🚪🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱⏫🧱🧱🧱🧱🧱🧱🧱🧱🎩🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🌫🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱📦🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🔐🧱🔐🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🔐🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱⏫🧱🌫🧱🌫🌫🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱📦🌫🌫🌫🔐🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🧱🌫🌫🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱📄🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🔼🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱📦🧱🧱🧱🧱🧱🧱📦🧱🧱🧱📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫📦🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🌫🧱🧱🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🔽🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🌫🧱🔼🌫🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🌫🌫🌫🧱🌫🌫🌫🌫🧱🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🌫🧱🧱🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱📦🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🧱🧱🌫🧱🧱🧱🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🔐🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱📄🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🔽🧱🧱🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱⏫🧱🧱🧱🧱📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🔼🧱🧱🧱🧱🌫🧱🌫🌫🌫📦🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🔼🧱🧱🌫🧱🌫🌫🌫🧱📦🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱📦🧱🌫🧱📦🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🔼🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🔼🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔽🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔽🌫🌫🌫🌫🌫🧱🔼🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱📄🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🔼🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫📦🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🔼🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔽🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🔽🧱🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🔼🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🔽🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫📄🌫🧱🧱🌫🧱🧱🧱🔽🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🌫📄🌫🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🔽🧱🧱🧱🌫🧱🌫🧱📦🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱⏫🧱🧱🧱🧱🔽🌫🌫🧱⏫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱⏫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱⏬🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🌫🌫🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫📄🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱⏬🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱📦🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱⏫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🔼🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫🔼🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔼🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱📦🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🌫🌫🔼🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🌫🌫🧱🌫🧱🔽🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫📦🧱🌫🧱🌫🌫🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🧱🧱📦🧱🧱🔽🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫📦🧱🔽🧱🧱🧱🚪🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🧱🧱📦🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱📦🌫🧱🧱🧱🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱📦🌫🌫🧱🧱🌫🧱🧱🧱🔽🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🚪🌫🌫📦🌫🌫⏩🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🔼🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫⏩🧱🧱📦🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱⏩🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱⏩🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱📦🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🚪🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱📦🌫🧱🔼🧱🌫📦🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🔽🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱📦🧱🧱🌫🧱🧱📦🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱📦🧱🧱🌫🧱🚪🧱🧱"
.stringmap dungeons "🧱🧱🧱🚪🧱🌫🧱🧱🌫🧱🧱🌫🧱📦🧱🧱"
.stringmap dungeons "🧱🧱🧱📦🧱🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫📦🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫📦🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🔽🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱📦🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱📦🌫🌫🌫🌫🌫🌫🌫🌫🌫📦🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱📦🧱🔼🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🚪🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱⏹🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🌫🌫🌫🧱🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🔽🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🌫🔐🌫🌫🌫🔼🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫📦🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🔼🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🔼🧱🧱🌫🧱🧱🧱🔼🌫🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫📦🧱🌫🧱🧱🌫🧱🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔼🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱⏫🌫🌫🌫🌫📦🧱🌫🌫🌫🧱🌫🌫⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🔽🌫🌫🌫🧱🧱🧱⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🧱🧱🔼🌫🌫🧱🧱🧱🔽🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🔽🧱🧱🧱🌫🌫🌫🔽🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱⏫🧱🌫🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔽🧱🌫🧱⏫🧱🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫⏫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🔼🧱🧱🌫🌫🔼🧱🧱🌫🌫⏫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🌫🌫🔽🧱🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🔼🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱⏫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔽🌫🌫🧱🧱🔽🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔼🧱🧱🧱🧱🧱📦🧱🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱⏫🧱🌫🧱🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🔼🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🌫🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🔽🌫🌫🌫🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱⏫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔽🧱🧱🧱🌫🧱🧱🌫🧱🔼🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱📦🧱🧱🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🔽🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🔼🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🧱🧱🧱🧱🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🔼🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱📦🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫📦🧱🌫🌫🌫🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🌫🌫🌫🌫🌫🧱🔽🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱📦🧱🌫🧱🧱🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🚪🧱🌫🧱🔽🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🔽🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🧱"
.stringmap dungeons "🧱🧱🧱📦🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱"
.stringmap dungeons "🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱⏫🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫📦🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🔼🧱🌫🧱🌫🧱🔼🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🔐🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🌫🌫🧱🌫🧱🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱📦🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🔽🧱🌫🧱🌫🧱🔽🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🧱🌫🧱🧱🧱🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🔼🌫🌫🌫🧱🧱🧱🔼🌫🌫🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🔼🧱🌫🧱🌫🧱🧱🔼🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🔽🧱🌫🌫🧱🌫🌫🔽🧱🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🔼🧱🌫🧱🌫🧱🧱🔼🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🧱🌫🧱🌫🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🔽🧱🌫🧱🌫🧱🧱🔽🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🚪🧱🌫🧱🌫🧱🧱🚪🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🌫🧱🌫🧱🌫🧱🧱🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🔽🧱🌫🧱🌫🧱🧱🔽🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🌫🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🌫🌫🌫🧱🌫🧱🧱🎆🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱⏩🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🌫🌫🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🔐🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🌫🌫🌫🧱🧱🌫🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🧱🧱🧱🧱🧱🧱🌫🧱🚪🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🌫🌫🧱🧱📦🌫🌫🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱📦🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🌫🌫⏹🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫🌫🚪🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱⏫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🌫🌫🌫🔼🧱🧱🧱🧱🧱🧱🧱📄🌫📄🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🔼🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫📄🧱📄🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱📄🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱📄🧱🧱🌫🌫🌫📄🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"

.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🔽🌫🌫🌫📄🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🔽🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱📄🌫🧱🧱📄🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱📄🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱📦🧱🧱🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱📦🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫📄🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱📄🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫📄🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"

; Data from 3FDEE to 3FFFF (530 bytes)
CreditsFont:
.incbin "Tiles\3fdeecompr.dat" ; curly font (for credits)
;.org $3ff80
; Blank until end of bank

;=======================================================================================================
; Bank 16: $40000 - $43fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 16 slot 2
.org 0
.section "Tile data 7" overwrite
PalettePalmaOpen:
.db $01,$00,$3F,$2F,$0B,$06,$08,$0C,$04,$34,$00,$00,$00,$00,$00,$00 ; palette
PaletteDezorisOpen:
.db $3E,$00,$3F,$3F,$3C,$38,$3C,$3F,$3C,$30,$00,$00,$00,$00,$00,$00 ; palette
TilesPalmaAndDezorisOpen:
.incbin "Tiles\40020compr.dat"
PalettePalmaForest:
.db $04,$00,$3F,$08,$0C,$06,$01,$0B,$00,$00,$00,$00,$00,$00,$00,$00 ; palette
PaletteDezorisForest: ; ???
.db $3E,$00,$3F,$3F,$3F,$1C,$18,$3E,$00,$00,$00,$00,$00,$00,$00,$00 ; palette
TilesPalmaForest:
.incbin "Tiles\40f36compr.dat"
PalettePalmaSea:
.db $30,$00,$3F,$30,$34,$38,$3C,$04,$08,$0C,$0B,$06,$2F,$38,$38,$38 ; palette
TilesPalmaSea:
.incbin "Tiles\41c82compr.dat"
.ends
; followed by
.section "Sea scene wave effects raw tile data" overwrite
TilesAnimSea:
.incbin "Tiles\428f6raw.dat" ; 88 Sea scene wave effects (raw tile data)
.ends
; followed by
.section "Tile data 8" overwrite
PaletteMotabiaOpen:
.db $30,$00,$3F,$06,$2F,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; palette for following
TilesMotabiaOpen:
.incbin "Tiles\43406compr.dat" ; 134
TilesFont:
.incbin "Tiles\43ad8compr.dat" ; Main font
TilesExtraFont:
.incbin "Tiles\43ebecompr.dat" ; menu borders, HP, MP, LV
TilesExtraFont2:
.incbin "Tiles\43f5ecompr.dat" ; can't read :P
.ends
;.org 43fe4
; Blank until end of bank

;=======================================================================================================
; Bank 17: $44000 - $47fff - almost all tiles/palette
;=======================================================================================================
.bank 17 slot 2
.org 0
.section "Raw tile data 2" overwrite
TilesBubblingStuff:
.incbin "Tiles\44000raw.dat" ; 50 tiles
.ends
; followed by
.section "Tile data 9" overwrite
PalettePalmaTown:
.db $34,$00,$3F,$2F,$0B,$06,$01,$0C,$04,$25,$08,$2A,$3E,$3C,$38,$00 ; palette
TilesPalmaTown:
.incbin "Tiles\44650compr.dat" ; 181 first planet
PalettePalmaVillage:
.db $34,$00,$3F,$08,$04,$06,$01,$0C,$0B,$25,$2A,$00,$00,$00,$00,$00 ; palette
TilesPalmaVillage:
.incbin "Tiles\457d4compr.dat"
PaletteSpaceport:
.db $34,$00,$3F,$01,$03,$2A,$25,$02,$0B,$3C,$00,$00,$00,$00,$00,$00 ; palette
TilesSpaceport:
.incbin "Tiles\464c1compr.dat"
PaletteDeadTrees: ; fix name ???
.db $25,$00,$3F,$2F,$0B,$01,$06,$2A,$06,$06,$06,$06,$06,$06,$06,$06 ; palette
TilesDeadTrees:
.incbin "Tiles\46f68compr.dat"
TilesTarzimal:
.incbin "Tiles\4794acompr.dat"
.ends
;.org $47fe5
; Blank until end of bank

;=======================================================================================================
; Data from 48000 to 4BFFF (16384 bytes)
;=======================================================================================================
.bank 18 slot 2
.orga $8000             ; $48000
.section "Vehicle sprites" overwrite
VehicleSprites:
.include "Tiles\48000 Vehicle sprites.inc"
.ends
; followed by
.org $49c00-$48000
.section "Tile data 10" overwrite
.incbin "Tiles\49c00compr.dat"
.incbin "Tiles\49dd7compr.dat"
.incbin "Tiles\4a036compr.dat"
.incbin "Tiles\4a270compr.dat"
.incbin "Tiles\4a3bccompr.dat"
.incbin "Tiles\4a5e0compr.dat"
.incbin "Tiles\4a7fdcompr.dat"
.incbin "Tiles\4aac0compr.dat"
.incbin "Tiles\4ab9dcompr.dat"
.incbin "Tiles\4ad2acompr.dat"
.incbin "Tiles\4af91compr.dat"
.incbin "Tiles\4b177compr.dat"
.incbin "Tiles\4b244compr.dat"
NarrativeGraphicsLutz:
.db $00,$00,$3F,$38,$3C,$03,$01,$0F,$2B,$0B,$06,$31,$3E,$2F,$36,$20 ; palette
.incbin "Tiles\4b398compr.dat"
.ends
;.org 4be84
; Blank until end of bank

;=======================================================================================================
; Bank 19: $4c000 - $4ffff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 19 slot 2
.org 0
.section "Tile data 11" overwrite
DarkForceSpritePalette:
.db $00,$00,$3F,$30,$38,$03,$0B,$0F,$20,$30,$34,$38,$3C,$02,$03,$01 ; palette
TilesDarkForce:
.incbin "Tiles\4c010compr.dat" ; 165 - Dark Force
TilesFarmer:
.incbin "Tiles\4cdbecompr.dat" ; 91 - farmer?
TilesDezorian:
.incbin "Tiles\4d6edcompr.dat" ; 49
TilesElephant:
.incbin "Tiles\4dc25compr.dat" ; 153
TilesRobotCop:
.incbin "Tiles\4ea0fcompr.dat" ; 94
TilesTarantula:
.incbin "Tiles\4f28acompr.dat" ; 133
TilesSuccubus:
.incbin "Tiles\4fd83compr.dat" ; 20
.ends
;.org $4ff59
; Blank until end of bank

;=======================================================================================================
; Bank 20: $50000 - $53fff - tiles/palette + credits
;=======================================================================================================
.bank 20 slot 2
.org $0

; Data from 50000 to 50007 (8 bytes)
Palette_TreasureChest:
.db $12 $06 $1A $01 $25 $2F $2A $02

; Data from 50008 to 53DBB (15796 bytes)
TilesTreasureChest:
.incbin "Tiles\50008compr.dat" ; 160 - treasure chest
TilesClub: ; "Big Club"/"Executer"
.incbin "Tiles\50febcompr.dat" ; 74
TilesDarkForceFlame:
.incbin "Tiles\517c4compr.dat" ; 154
PaletteLassicRoom:
.db $10,$00,$3F,$20,$25,$2A,$02,$03,$01,$06,$30,$38,$2F,$0F,$0B,$3F ; palette
TilesLassicRoom:
.incbin "Tiles\524eacompr.dat" ; 96
TilesAmmonite:
.incbin "Tiles\52ba2compr.dat" ; 75
TilesGolem:
.incbin "Tiles\53395compr.dat" ; 127

.section "Credits" overwrite
; Pointer Table from 53DBC to 53DD7 (14 entries,indexed by _RAM_C2F5_)
_DATA_53DBC_:
.dw _DATA_53DD8_ _DATA_53DE1_ _DATA_53E04_ _DATA_53E1D_ _DATA_53E41_ _DATA_53E79_ _DATA_53E97_ _DATA_53EB9_
.dw _DATA_53EDD_ _DATA_53F07_ _DATA_53F15_ _DATA_53F31_ _DATA_53F66_ _DATA_53F83_

; 1st entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53DD8 to 53DE0 (9 bytes)
_DATA_53DD8_:
.db $01 $9A $D2 $05 $53 $54 $41 $46 $46

; 2nd entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53DE1 to 53E03 (35 bytes)
_DATA_53DE1_:
.db $03 $4A $D1 $05 $54 $4F $54 $41 $4C $CC $D1 $08 $50 $4C $41 $4E
.db $4E $49 $4E $47 $A2 $D1 $0C $4F $53 $53 $41 $4C $45 $20 $4B $4F
.db $48 $54 $41

; 3rd entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53E04 to 53E1C (25 bytes)
_DATA_53E04_:
.db $02 $CC $D3 $08 $53 $54 $4F $52 $59 $20 $42 $59 $E2 $D3 $0A $41
.db $50 $52 $49 $4C $20 $46 $4F $4F $4C

; 4th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53E1D to 53E40 (36 bytes)
_DATA_53E1D_:
.db $03 $4C $D1 $08 $53 $43 $45 $4E $41 $52 $49 $4F $CE $D1 $06 $57
.db $52 $49 $54 $45 $52 $A2 $D1 $0C $4F $53 $53 $41 $4C $45 $20 $4B
.db $4F $48 $54 $41

; 5th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53E41 to 53E78 (56 bytes)
_DATA_53E41_:
.db $04 $92 $D2 $09 $41 $53 $53 $49 $53 $54 $41 $4E $54 $14 $D3 $0C
.db $43 $4F $4F $52 $44 $49 $4E $41 $54 $4F $52 $53 $C4 $D3 $0C $4F
.db $54 $45 $47 $41 $4D $49 $20 $43 $48 $49 $45 $E4 $D3 $0A $47 $41
.db $4D $45 $52 $20 $4D $49 $4B $49

; 6th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53E79 to 53E96 (30 bytes)
_DATA_53E79_:
.db $02 $86 $D1 $0C $54 $4F $54 $41 $4C $20 $44 $45 $53 $49 $47 $4E
.db $A4 $D1 $0B $50 $48 $4F $45 $48 $49 $58 $20 $52 $49 $45

; 7th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53E97 to 53EB8 (34 bytes)
_DATA_53E97_:
.db $03 $8A $D3 $07 $4D $4F $4E $53 $54 $45 $52 $0A $D4 $06 $44 $45
.db $53 $49 $47 $4E $E2 $D3 $0B $43 $48 $41 $4F $54 $49 $43 $20 $4B
.db $41 $5A

; 8th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53EB9 to 53EDC (36 bytes)
_DATA_53EB9_:
.db $03 $90 $D1 $06 $44 $45 $53 $49 $47 $4E $92 $D2 $0A $52 $4F $43
.db $4B $48 $59 $20 $4E $41 $4F $E2 $D3 $0A $53 $41 $44 $41 $4D $4F
.db $52 $49 $41 $4E

; 9th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53EDD to 53F06 (42 bytes)
_DATA_53EDD_:
.db $04 $90 $D1 $06 $44 $45 $53 $49 $47 $4E $92 $D2 $0A $4D $59 $41
.db $55 $20 $43 $48 $4F $4B $4F $E2 $D3 $06 $47 $20 $43 $48 $49 $45
.db $D2 $D4 $07 $59 $4F $4E $45 $53 $41 $4E

; 10th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53F07 to 53F14 (14 bytes)
_DATA_53F07_:
.db $02 $92 $D1 $05 $53 $4F $55 $4E $44 $A4 $D1 $02 $42 $4F

; 11th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53F15 to 53F30 (28 bytes)
_DATA_53F15_:
.db $02 $C6 $D3 $0A $53 $4F $46 $54 $20 $43 $48 $45 $43 $4B $E4 $D3
.db $0B $57 $4F $52 $4B $53 $20 $4E $49 $53 $48 $49

; 12th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53F31 to 53F65 (53 bytes)
_DATA_53F31_:
.db $05 $46 $D1 $09 $41 $53 $53 $49 $53 $54 $41 $4E $54 $C8 $D1 $0B
.db $50 $52 $4F $47 $52 $41 $4D $4D $45 $52 $53 $92 $D2 $08 $43 $4F
.db $4D $20 $42 $4C $55 $45 $C8 $D3 $06 $4D $20 $57 $41 $4B $41 $E6
.db $D3 $03 $41 $53 $49

; 13th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53F66 to 53F82 (29 bytes)
_DATA_53F66_:
.db $02 $84 $D1 $0C $4D $41 $49 $4E $20 $50 $52 $4F $47 $52 $41 $4D
.db $A2 $D1 $0A $4D $55 $55 $55 $55 $20 $59 $55 $4A $49

; 14th entry of Pointer Table from 53DBC (indexed by _RAM_C2F5_)
; Data from 53F83 to 53FFF (125 bytes)
_DATA_53F83_:
.db $02 $C6 $D3 $0C $50 $52 $45 $53 $45 $4E $54 $45 $44 $20 $42 $59
.db $E4 $D3 $04 $53 $45 $47 $41
.ends

;=======================================================================================================
; Bank 21: $54000 - $57fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 21 slot 2
.org $54000-$54000
.section "Enemy sprite data offset table" overwrite
EnemySpriteDataTable:
; Sprite data 2
; Table of structures, followed by structures themselves, for various sprites
; giving their y, x and tile numbers
; for use when updating the sprite table in RAM and then VRAM

.dw _8200,_8204,_829e,_82ae,_82be,_82d4,_82fc,_8321
.dw _8349,_836b,_8384,_839d,_83bc,_83ea,_841e,_8452
.dw _b6c9,_b6d6,_b6ef,_b7a2,_b7af,_8486,_84f3,_850c
.dw _852b,_8544,_8569,_858b,_85bf,_863b,_86c9,_8745
.dw _87b8,_8834,_88ad,_8923,_8999,_89cd,_8a19,_8a65
.dw _8ab1,_8b27,_8b9d,_8c13,_8c89,_8cd2,_8ceb,_8d07
.dw _8d1d,_8d3c,_8d52,_8d65,_8d9f,_8dd0,_8df2,_8e14
.dw _8e36,_8e58,_8e7a,_8e9f,_8ed0,_b7bc,_b7c9,_8f72
.dw _8fc1,_8fd1,_8fde,_8fee,_8ffb,_900e,_b72a,_901e
.dw _9085,_90ec,_9153,_916c,_918e,_91a7,_91b4,_91d0
.dw _91ec,_923b,_9287,_92d0,_933d,_935c,_937b,_939a
.dw _93b9,_93de,_941e,_945e,_949e,_94cf,_94fa,_9522
.dw _954a,_9575,_95a0,_95ce,_9605,_963f,_96a0,_96da
.dw _971a,_974e,_97c4,_983a,_98b0,_9926,_999c,_9a12
.dw _9a88,_9b10,_9b98,_9c1d,_9ca2,_9d2a,_b7d6,_b7e3
.dw _9db5,_9e28,_9e4a,_9e66,_9e7f,_9e98,_9eb1,_9ed0
.dw _9ef2,_9f11,_9f4e,_9f67,_9f80,_9f99,_9fb2,_9fcb
.dw _b7ea,_b80f,_b8a6,_b92b,_b98f,_9fe4,_b737,_a039
.dw _a046,_a053,_a060,_a070,_a083,_a0a5,_a0e8,_a143
.dw _a19b,_a1f6,_a203,_a210,_a226,_a233,_a240,_a24d
.dw _a25a,_a26a,_a280,_a299,_a2d9,_a328,_a389,_a3cf
.dw _a418,_a461,_a4ad,_a4f0,_a536,_a5af,_a5e0,_a617
.dw _a648,_a67c,_a6b3,_b723,_a6db,_a721,_a77c,_a7d4
.dw _a823,_a860,_a8af,_a92b,_a944,_a954,_a964,_a99e
.dw _aa02,_aa09,_aa16,_aa29,_aa87,_aaa0,_aadd,_ab1a
.dw _ab39,_ab5e,_ab80,_b744,_ba1a,_ba81,_ab90,_abb8
.dw _abf5,_ac56,_acdb,_ad63,_ada3,_ade0,_ae17,_ae54
.dw _aebb,_af64,_afc5,_b02c,_b069,_b0a6,_b0e3,_b14a
.dw _b151,_b158,_b15f,_b16f,_b1bb,_b207,_b253,_b29f
.dw _b2f1,_b352,_b3c2,_b47a,_b532,_b542,_b56a,_b58f
.dw _b59f,_b5af,_b5bf,_b5d8,_b603,_b60a,_b617,_b624
.dw _b646,_b65f,_b666,_b673,_b680,_b690,_b6b5,_b6bc
_8200:
.db 1 ; count
.db  -1     ; y positions
.db   0,$F0 ; x positions/tile numbers
_8204:
.db 51 ; count
.db   0    ,  0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 88    , 88    , 96    , 96    , 96    , 96    ,104    ,104    ,104    ,104    ,104     ; y positions
.db  21,$38, 29,$39, 37,$3A, 51,$3B, 59,$3C, 19,$3D, 40,$3E, 48,$3F, 64,$40, 17,$41, 64,$42, 11,$43, 64,$44,  2,$45, 10,$46, 72,$47,  0,$48,  8,$49, 72,$4A, 11,$4B, 40,$4C, 48,$4D, 72,$4E, 11,$4F, 40,$50, 56,$51, 72,$52, 11,$53, 19,$54, 48,$55, 64,$56, 72,$57, 11,$58, 48,$59, 72,$5A,  9,$5B, 48,$5C, 56,$5D, 64,$5E, 75,$5F,  9,$60, 24,$61, 12,$62, 20,$63, 28,$64, 64,$65,  8,$66, 16,$67, 24,$68, 32,$69, 56,$6A ; x positions/tile numbers
_829e:
.db 5 ; count
.db  32    , 40    , 40    , 48    , 48     ; y positions
.db  24,$6B, 16,$6C, 24,$6D, 16,$6E, 24,$6F ; x positions/tile numbers
_82ae:
.db 5 ; count
.db  32    , 40    , 40    , 48    , 48     ; y positions
.db  24,$70, 16,$71, 24,$72, 16,$73, 24,$74 ; x positions/tile numbers
_82be:
.db 7 ; count
.db  32    , 40    , 40    , 48    , 48    , 56    , 56     ; y positions
.db  24,$70, 16,$75, 24,$76, 16,$77, 24,$78, 12,$79, 20,$7A ; x positions/tile numbers
_82d4:
.db 13 ; count
.db  32    , 40    , 40    , 48    , 48    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80     ; y positions
.db  24,$70, 16,$75, 24,$76, 16,$7B, 24,$7C, 16,$7D,  8,$7E, 16,$7F,  8,$80, 16,$81,  2,$82, 10,$83, 18,$84 ; x positions/tile numbers
_82fc:
.db 12 ; count
.db  32    , 40    , 40    , 48    , 48    , 80    , 88    , 88    , 96    , 96    ,104    ,104     ; y positions
.db  24,$70, 16,$71, 24,$72, 16,$73, 24,$74,  7,$85,  2,$86, 10,$87, -3,$88,  5,$89, -4,$8A,  4,$8B ; x positions/tile numbers
_8321:
.db 13 ; count
.db  32    , 40    , 40    , 48    , 48    ,104    ,112    ,112    ,112    ,120    ,120    ,120    ,120     ; y positions
.db  24,$70, 16,$71, 24,$72, 16,$73, 24,$74, -1,$8C,-10,$8D, -2,$8E,  6,$8F,-16,$90, -8,$91,  0,$92,  8,$93 ; x positions/tile numbers
_8349:
.db 11 ; count
.db  32    , 40    , 40    , 48    , 48    ,112    ,112    ,120    ,120    ,120    ,120     ; y positions
.db  24,$70, 16,$71, 24,$72, 16,$73, 24,$74,-24,$94, 16,$95,-24,$96,-16,$97,  9,$98, 17,$99 ; x positions/tile numbers
_836b:
.db 8 ; count
.db  20    , 20    , 20    , 20    , 28    , 28    , 28    , 28     ; y positions
.db   9,$00, 17,$01, 25,$02, 33,$03,  8,$04, 16,$05, 24,$06, 32,$07 ; x positions/tile numbers
_8384:
.db 8 ; count
.db  20    , 20    , 20    , 20    , 28    , 28    , 28    , 28     ; y positions
.db   8,$08, 16,$09, 24,$0A, 32,$0B,  8,$0C, 16,$0D, 24,$0E, 32,$0F ; x positions/tile numbers
_839d:
.db 10 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 40    , 40     ; y positions
.db  15,$10, 23,$11, 31,$12, 14,$13, 22,$14, 30,$15, 17,$16, 25,$17, 16,$18, 24,$19 ; x positions/tile numbers
_83bc:
.db 15 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 48    , 48    , 48     ; y positions
.db  16,$1A, 24,$1B, 12,$1C, 20,$1D, 28,$1E, 11,$1F, 19,$20, 27,$21, 35,$22, 13,$23, 21,$24, 29,$25, 12,$26, 20,$27, 28,$28 ; x positions/tile numbers
_83ea:
.db 17 ; count
.db  32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48     ; y positions
.db   6,$29, 14,$2A, 22,$2B, 30,$2C, 38,$2D,  2,$2E, 10,$2F, 18,$30, 26,$31, 34,$32, 42,$33,  1,$34,  9,$35, 17,$36, 25,$37, 33,$38, 41,$39 ; x positions/tile numbers
_841e:
.db 17 ; count
.db  32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48     ; y positions
.db   3,$3A, 11,$3B, 19,$3C, 27,$3D, 35,$3E,  1,$3F,  9,$40, 17,$41, 25,$42, 33,$43, 41,$44,  1,$45,  9,$46, 17,$47, 25,$48, 33,$49, 41,$4A ; x positions/tile numbers
_8452:
.db 17 ; count
.db  32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48     ; y positions
.db   8,$4B, 16,$4C, 24,$4D, 32,$4E, 40,$4F,  2,$50, 10,$51, 18,$30, 26,$52, 34,$53, 42,$54,  1,$55,  9,$56, 17,$36, 25,$57, 33,$58, 41,$59 ; x positions/tile numbers
_8486:
.db 36 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 88    , 88    , 88     ; y positions
.db  33,$33, 41,$34, 49,$35, 26,$36, 48,$37, 56,$38,  1,$39,  9,$3A, 17,$3B, 56,$3C, 64,$3D, 72,$3E,  9,$3F, 64,$40,  9,$41, 64,$42,  8,$43, 16,$44, 64,$45,  8,$46, 11,$47, 32,$48, 72,$49, 10,$4A, 32,$4B, 64,$4C,  9,$4D, 64,$4E,  6,$4F, 40,$50, 48,$51, 56,$52, 64,$53,  9,$54, 17,$55, 25,$56 ; x positions/tile numbers
_84f3:
.db 8 ; count
.db  40    , 40    , 48    , 48    , 56    , 56    , 64    , 64     ; y positions
.db   8,$57, 16,$58,  8,$59, 16,$5A,  9,$5B, 17,$5C, 10,$5D, 18,$5E ; x positions/tile numbers
_850c:
.db 10 ; count
.db  32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56     ; y positions
.db   8,$5F, 16,$60,  6,$61, 14,$62, 22,$63,  6,$64, 14,$65, 22,$66,  9,$67, 17,$68 ; x positions/tile numbers
_852b:
.db 8 ; count
.db  16    , 16    , 24    , 24    , 32    , 32    , 40    , 40     ; y positions
.db  10,$69, 18,$6A,  9,$6B, 17,$6C,  8,$6D, 16,$6E,  8,$6F, 16,$70 ; x positions/tile numbers
_8544:
.db 12 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40     ; y positions
.db  11,$71, 19,$72, 10,$73, 18,$74, 10,$75, 18,$76,  9,$77, 17,$78,  8,$79, 16,$7A,  9,$7B, 17,$7C ; x positions/tile numbers
_8569:
.db 11 ; count
.db  32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56     ; y positions
.db   8,$7D, 16,$7E,  7,$7F, 15,$80, 23,$81,  5,$82, 13,$83, 21,$84,  5,$85, 13,$86, 21,$87 ; x positions/tile numbers
_858b:
.db 17 ; count
.db  32    , 32    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72     ; y positions
.db   8,$88, 16,$89,  8,$8A, 16,$8B,  5,$8C, 13,$8D, 21,$8E,  1,$8F,  9,$90, 17,$91, 25,$92,  1,$93,  9,$94, 17,$95, 25,$96,  1,$97, 27,$98 ; x positions/tile numbers
_85bf:
.db 41 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  22,$11, 30,$12,  5,$13, 15,$14, 23,$15, 32,$16, 40,$17,  6,$18, 14,$19, 40,$1A, 48,$1B,  9,$1C, 17,$1D, 40,$1E, 48,$1F, 12,$20, 20,$21, 32,$22, 40,$23, 48,$24, 13,$25, 21,$26, 32,$27, 40,$28, 48,$29, 16,$2A, 40,$2B, 48,$2C, 16,$2D, 40,$2E, 48,$2F, 16,$30, 40,$31, 48,$32, 10,$33, 18,$34, 40,$35, 25,$36, 33,$37, 41,$38, 49,$39 ; x positions/tile numbers
_863b:
.db 47 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   7,$3A, 15,$3B, 23,$3C, 31,$3D,  9,$3E, 17,$3F, 32,$16, 40,$17,  8,$40, 40,$1A, 48,$1B,  6,$41, 14,$42, 22,$43, 40,$1E, 48,$1F,  6,$44, 14,$45, 22,$46, 32,$22, 40,$23, 48,$24,  7,$47, 15,$48, 23,$49, 32,$27, 40,$28, 48,$29, 10,$4A, 18,$4B, 40,$2B, 48,$2C, 10,$4C, 18,$4D, 40,$2E, 48,$2F, 10,$4E, 18,$4F, 40,$31, 48,$32, 10,$33, 18,$34, 40,$35, 25,$36, 33,$37, 41,$38, 49,$39 ; x positions/tile numbers
_86c9:
.db 41 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  22,$11, 30,$12, 15,$14, 23,$15, 32,$16, 40,$17,  8,$50, 40,$1A, 48,$1B,  8,$51, 16,$52, 40,$1E, 48,$1F,  8,$53, 16,$54, 32,$22, 40,$23, 48,$24,  9,$55, 17,$56, 32,$27, 40,$28, 48,$29, 10,$57, 18,$58, 40,$2B, 48,$2C, 12,$59, 20,$5A, 40,$2E, 48,$2F, 16,$30, 40,$31, 48,$32, 10,$33, 18,$34, 40,$35, 25,$36, 33,$37, 41,$38, 49,$39 ; x positions/tile numbers
_8745:
.db 38 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  22,$11, 30,$12,  5,$13, 15,$14, 23,$15, 32,$16, 40,$17,  6,$18, 14,$19, 40,$5B, 48,$1B,  9,$1C, 17,$1D, 40,$5C, 48,$5D, 12,$20, 20,$21, 32,$5E, 40,$5F, 48,$60, 13,$25, 21,$26, 32,$61, 40,$62, 48,$63, 16,$2A, 40,$64, 16,$2D, 40,$65, 16,$30, 40,$31, 10,$33, 18,$34, 40,$35, 25,$36, 33,$37, 41,$38, 49,$39 ; x positions/tile numbers
_87b8:
.db 41 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72     ; y positions
.db  12,$11, 20,$12, 28,$13, 36,$14, 11,$15, 19,$16, 27,$17, 35,$18, 10,$19, 18,$1A, 26,$1B, 34,$1C, 11,$1D, 19,$1E, 27,$1F, 35,$20, 47,$21, 16,$22, 24,$23, 32,$24, 40,$25, 48,$26,  9,$27, 17,$28, 25,$29, 48,$2A,  4,$2B, 48,$2C, 56,$2D,  1,$2E, 56,$2F,  2,$30, 24,$31, 40,$32, 48,$33, 56,$34,  5,$35, 13,$36, 21,$37, 32,$38, 40,$39 ; x positions/tile numbers
_8834:
.db 40 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72     ; y positions
.db  13,$3A, 21,$3B, 29,$3C, 13,$3D, 21,$3E, 29,$3F, 37,$40, 13,$41, 21,$42, 29,$43, 37,$44, 14,$45, 22,$46, 30,$47, 38,$48, 46,$49, 16,$4A, 24,$4B, 32,$4C, 40,$4D, 48,$14,  9,$27, 17,$4E, 25,$4F, 48,$2A,  2,$50, 48,$2C, 56,$2D,  0,$51, 56,$52,  2,$53, 24,$54, 40,$55, 48,$56, 56,$57,  5,$58, 13,$59, 21,$5A, 32,$5B, 40,$39 ; x positions/tile numbers
_88ad:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72     ; y positions
.db  16,$5C, 24,$5D, 32,$5E, 15,$5F, 23,$60, 31,$61, 13,$62, 21,$63, 29,$64, 37,$65, 14,$66, 22,$67, 30,$68, 38,$69, 47,$21, 16,$6A, 24,$6B, 32,$6C, 40,$6D, 48,$26,  9,$27, 17,$4E, 25,$4F, 48,$2A,  4,$2B, 48,$2C, 56,$2D,  1,$2E, 56,$2F,  2,$30, 24,$31, 40,$32, 48,$33, 56,$34,  5,$35, 13,$36, 21,$37, 32,$38, 40,$39 ; x positions/tile numbers
_8923:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72     ; y positions
.db  16,$6E, 24,$6F, 32,$70, 15,$71, 23,$72, 31,$73, 13,$74, 21,$75, 29,$76, 37,$77, 14,$78, 22,$79, 30,$7A, 38,$7B, 49,$7C, 16,$7D, 24,$7E, 32,$7F, 40,$80, 48,$81,  9,$27, 17,$82, 25,$83, 48,$2A,  2,$50, 48,$2C, 56,$2D,  0,$51, 56,$52,  2,$53, 24,$54, 40,$55, 48,$56, 56,$57,  5,$58, 13,$59, 21,$5A, 32,$5B, 40,$39 ; x positions/tile numbers
_8999:
.db 17 ; count
.db   0    ,  8    ,  8    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 48    , 48    , 56    , 56     ; y positions
.db  22,$0D, 16,$0E, 24,$0F, 32,$10, 14,$11, 32,$12,  9,$13, 17,$14, 32,$15,  9,$16, 32,$17, 10,$18, 32,$19, 11,$1A, 32,$1B, 10,$1C, 32,$1D ; x positions/tile numbers
_89cd:
.db 25 ; count
.db   0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56     ; y positions
.db  22,$0D, 16,$0E, 24,$0F, 32,$10,  4,$1E, 14,$11, 32,$12,  4,$1F, 12,$20, 32,$21, 40,$22,  6,$23, 14,$24, 32,$25, 40,$26,  7,$27, 15,$28, 32,$29, 40,$2A,  7,$2B, 15,$2C, 32,$1B,  7,$2D, 15,$2E, 32,$2F ; x positions/tile numbers
_8a19:
.db 25 ; count
.db   0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56     ; y positions
.db  22,$0D, 16,$0E, 24,$0F, 32,$10,  1,$30,  9,$31, 32,$12, 41,$32,  1,$33,  9,$34, 32,$35, 40,$36,  4,$37, 12,$38, 32,$39, 40,$3A,  4,$3B, 12,$3C, 32,$3D, 40,$3E,  4,$3F, 12,$40, 32,$1B, 10,$41, 32,$2F ; x positions/tile numbers
_8a65:
.db 25 ; count
.db   0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56     ; y positions
.db  22,$0D, 16,$0E, 24,$0F, 32,$10,  1,$42,  9,$31, 32,$12, 41,$32,  1,$43,  9,$34, 32,$35, 40,$36,  4,$44, 12,$38, 32,$39, 40,$3A,  4,$45, 12,$3C, 32,$3D, 40,$3E,  4,$46, 12,$40, 32,$1B, 10,$41, 32,$2F ; x positions/tile numbers
_8ab1:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db   9,$09, 17,$0A, 33,$0B,  8,$0C, 24,$0D, 32,$0E, 40,$0F,  1,$10,  9,$11, 17,$12, 25,$13, 40,$14,  2,$15, 10,$16, 24,$17, 40,$18, 48,$19,  3,$1A, 11,$1B, 19,$1C, 32,$1D, 40,$1E, 48,$1F,  2,$20, 10,$21, 18,$22, 32,$23, 40,$24, 48,$25,  0,$26,  8,$27, 32,$28, 40,$29, 48,$2A,  0,$2B,  8,$2C, 16,$2D, 24,$2E, 32,$2F ; x positions/tile numbers
_8b27:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db   9,$09, 17,$0A, 33,$0B,  8,$0C, 24,$0D, 32,$0E, 40,$0F,  1,$10,  9,$30, 17,$31, 25,$13, 40,$14,  2,$15, 10,$32, 24,$17, 40,$18, 48,$19,  3,$1A, 11,$1B, 19,$1C, 32,$1D, 40,$33, 48,$34,  2,$20, 10,$21, 18,$22, 32,$23, 40,$35, 48,$36,  0,$37,  8,$38, 32,$39, 41,$3A, 49,$3B,  0,$3C,  8,$3D, 16,$3E, 24,$3F, 32,$40 ; x positions/tile numbers
_8b9d:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db   9,$09, 17,$0A, 33,$0B,  8,$0C, 24,$0D, 32,$0E, 40,$0F,  1,$10,  9,$41, 17,$42, 25,$43, 40,$14,  2,$15, 10,$16, 24,$44, 40,$18, 48,$19,  3,$1A, 11,$1B, 19,$1C, 32,$1D, 40,$1E, 48,$1F,  2,$20, 10,$21, 18,$22, 32,$23, 40,$45, 48,$25,  0,$26,  8,$27, 32,$28, 41,$46, 49,$47,  0,$48,  8,$2C, 16,$2D, 24,$2E, 32,$2F ; x positions/tile numbers
_8c13:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db   9,$09, 17,$0A, 33,$0B,  8,$0C, 24,$0D, 32,$0E, 40,$0F,  1,$10,  9,$49, 17,$31, 25,$13, 40,$14,  2,$4A, 10,$4B, 24,$17, 40,$18, 48,$19,  3,$4C, 11,$4D, 19,$4E, 32,$1D, 40,$1E, 48,$1F,  2,$4F, 10,$50, 18,$51, 32,$52, 40,$53, 48,$54,  0,$37,  8,$38, 32,$55, 40,$56, 48,$57,  0,$3C,  8,$3D, 16,$3E, 24,$3F, 32,$40 ; x positions/tile numbers
_8c89:
.db 24 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40     ; y positions
.db   6,$00, 14,$01, 22,$02, 30,$03,  2,$04, 10,$05, 18,$06, 26,$07, 34,$08,  2,$09, 10,$0A, 18,$0B, 26,$0C, 34,$0D,  4,$0E, 12,$0F, 20,$10, 28,$11,  5,$12, 13,$13, 21,$14, 29,$15, 12,$16, 20,$17 ; x positions/tile numbers
_8cd2:
.db 8 ; count
.db   0    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db  17,$18, 19,$19, 15,$1A, 23,$1B, 12,$1C, 20,$1D, 12,$1E, 21,$1F ; x positions/tile numbers
_8ceb:
.db 9 ; count
.db   0    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32     ; y positions
.db  17,$18, 19,$19, 13,$20, 21,$21,  9,$22, 17,$23, 25,$24, 10,$25, 26,$26 ; x positions/tile numbers
_8d07:
.db 7 ; count
.db   0    ,  8    , 16    , 24    , 24    , 32    , 32     ; y positions
.db  17,$18, 19,$19, 17,$27, 12,$28, 20,$29, 13,$2A, 21,$2B ; x positions/tile numbers
_8d1d:
.db 10 ; count
.db   0    ,  8    , 16    , 24    , 24    , 32    , 32    , 32    , 40    , 40     ; y positions
.db  17,$18, 19,$19, 19,$19, 13,$20, 21,$21,  9,$22, 17,$23, 25,$24, 10,$25, 26,$26 ; x positions/tile numbers
_8d3c:
.db 7 ; count
.db   0    ,  8    , 16    , 16    , 24    , 24    , 32     ; y positions
.db  17,$18, 19,$2C, 13,$2D, 21,$2E, 12,$2F, 20,$30, 12,$31 ; x positions/tile numbers
_8d52:
.db 6 ; count
.db   0    ,  8    ,  8    , 16    , 16    , 24     ; y positions
.db  17,$32, 17,$33, 25,$34, 16,$35, 24,$36, 24,$37 ; x positions/tile numbers
_8d65:
.db 19 ; count
.db   0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48     ; y positions
.db  17,$18, 17,$38, 25,$39, 17,$3A, 25,$3B,  7,$3C, 15,$3D, 23,$3E,  1,$3F,  9,$40, 17,$41, 25,$42,  2,$43, 10,$44, 18,$45, 26,$46,  9,$47, 17,$48, 25,$49 ; x positions/tile numbers
_8d9f:
.db 16 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 32    , 40    , 40     ; y positions
.db   5,$00, 13,$01, 21,$02,  5,$03, 13,$04, 21,$05, 29,$06,  2,$07, 10,$08, 18,$09, 26,$0A, 34,$0B, 32,$0C, 32,$0D, 24,$0E, 32,$0F ; x positions/tile numbers
_8dd0:
.db 11 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16     ; y positions
.db   2,$10, 10,$11, 18,$12, 26,$13,  3,$14, 11,$15, 19,$16, 27,$17,  6,$18, 14,$19, 22,$1A ; x positions/tile numbers
_8df2:
.db 11 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16     ; y positions
.db   2,$1B, 10,$1C, 18,$1D, 26,$1E,  2,$1F, 10,$20, 18,$21, 26,$22,  6,$18, 14,$19, 22,$1A ; x positions/tile numbers
_8e14:
.db 11 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16     ; y positions
.db   2,$23, 10,$24, 18,$25, 26,$1E,  0,$26,  8,$27, 16,$28, 24,$29,  4,$2A, 12,$2B, 20,$2C ; x positions/tile numbers
_8e36:
.db 11 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16     ; y positions
.db   2,$23, 10,$2D, 18,$25, 26,$1E,  0,$26,  8,$2E, 16,$2F, 24,$29,  4,$2A, 12,$2B, 20,$2C ; x positions/tile numbers
_8e58:
.db 11 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16     ; y positions
.db   2,$23, 10,$24, 18,$25, 26,$1E,  0,$30,  8,$31, 16,$28, 24,$29,  4,$32, 12,$33, 20,$2C ; x positions/tile numbers
_8e7a:
.db 12 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24     ; y positions
.db   2,$23, 10,$24, 18,$25, 26,$1E,  0,$30,  8,$34, 16,$28, 24,$29,  4,$35, 12,$36, 20,$2C,  8,$37 ; x positions/tile numbers
_8e9f:
.db 16 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 32    , 40    , 40    , 48    , 48     ; y positions
.db   2,$23, 10,$24, 18,$25, 26,$38,  0,$30,  8,$39, 16,$28, 24,$3A,  4,$2A, 12,$3B, 20,$2C,  8,$3C,  6,$3D, 14,$3E,  6,$3F, 14,$40 ; x positions/tile numbers
_8ed0:
.db 21 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 88    , 88     ; y positions
.db   2,$23, 10,$24, 18,$25, 26,$1E,  0,$30,  8,$39, 16,$28, 24,$29,  4,$2A, 12,$3B, 20,$2C,  5,$41, 13,$42,  3,$43, 11,$44, 19,$45,  3,$46, 11,$47, 19,$48,  4,$49, 12,$4A ; x positions/tile numbers

; Unused duplicates of _8d9f - can be removed
.db 16
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 32    , 40    , 40     ; y positions
.db   5,$00, 13,$01, 21,$02,  5,$03, 13,$04, 21,$05, 29,$06,  2,$07, 10,$08, 18,$09, 26,$0A, 34,$0B, 32,$0C, 32,$0D, 24,$0E, 32,$0F ; x positions/tile numbers
.db  16
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 32    , 40    , 40     ; y positions
.db   5,$00, 13,$01, 21,$02,  5,$03, 13,$04, 21,$05, 29,$06,  2,$07, 10,$08, 18,$09, 26,$0A, 34,$0B, 32,$0C, 32,$0D, 24,$0E, 32,$0F ; x positions/tile numbers

_8f72:
.db 26 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80     ; y positions
.db   8,$00, 16,$01,  6,$02, 14,$03,  8,$04, 16,$05,  8,$06, 16,$07,  8,$08, 16,$09,  5,$0A, 13,$0B, 21,$0C,  4,$0D, 12,$0E, 20,$0F,  5,$10, 13,$11, 21,$12,  5,$13, 13,$14,  6,$15, 14,$16,  0,$17,  8,$18, 16,$19 ; x positions/tile numbers
_8fc1:
.db 5 ; count
.db   8    , 16    , 24    , 32    , 40     ; y positions
.db   1,$1A,  0,$1B,  0,$1C,  0,$1D,  2,$1E ; x positions/tile numbers
_8fd1:
.db 4 ; count
.db   8    , 16    , 24    , 32     ; y positions
.db   1,$1F,  0,$20,  0,$21,  2,$22 ; x positions/tile numbers
_8fde:
.db 5 ; count
.db   8    , 16    , 24    , 32    , 40     ; y positions
.db   1,$23,  0,$24,  0,$25,  0,$26,  2,$1E ; x positions/tile numbers
_8fee:
.db 4 ; count
.db  16    , 24    , 32    , 40     ; y positions
.db   2,$27,  1,$28,  0,$29,  2,$1E ; x positions/tile numbers
_8ffb:
.db 6 ; count
.db  16    , 16    , 24    , 24    , 32    , 40     ; y positions
.db   0,$2A,  8,$2B,  0,$2C,  8,$2D,  0,$29,  2,$1E ; x positions/tile numbers
_900e:
.db 5 ; count
.db   8    , 16    , 24    , 32    , 40     ; y positions
.db   2,$2E,  2,$2F,  1,$30,  0,$29,  2,$1E ; x positions/tile numbers
_901e:
.db 34 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 88     ; y positions
.db  19,$00, 27,$01, 18,$02, 26,$03, 16,$04, 24,$05, 32,$06, 16,$07, 24,$08, 32,$09, 40,$0A, 16,$0B, 24,$0C, 32,$0D, 40,$0E, 16,$0F, 24,$10, 32,$11, 40,$12, 13,$13, 28,$14, 36,$15, 12,$16, 31,$17, 11,$18, 32,$19,  8,$1A, 34,$1B,  1,$1C,  9,$1D, 17,$1E, 25,$1F, 33,$20, 41,$21 ; x positions/tile numbers
_9085:
.db 34 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 88     ; y positions
.db  19,$00, 27,$01, 18,$02, 26,$03, 16,$04, 24,$05, 32,$06, 16,$07, 24,$22, 32,$23, 40,$0A, 16,$0B, 24,$24, 32,$25, 40,$0E, 16,$0F, 24,$26, 32,$27, 40,$12, 13,$13, 28,$14, 36,$15, 12,$16, 31,$17, 11,$18, 32,$19,  8,$1A, 34,$1B,  1,$1C,  9,$1D, 17,$1E, 25,$1F, 33,$20, 41,$21 ; x positions/tile numbers
_90ec:
.db 34 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 88     ; y positions
.db  19,$00, 27,$01, 18,$02, 26,$03, 16,$04, 24,$05, 32,$06, 16,$07, 24,$28, 32,$29, 40,$0A, 16,$0B, 24,$2A, 32,$2B, 40,$0E, 16,$0F, 24,$2C, 32,$2D, 40,$12, 13,$13, 28,$14, 36,$15, 12,$16, 31,$17, 11,$18, 32,$19,  8,$1A, 34,$1B,  1,$1C,  9,$1D, 17,$1E, 25,$1F, 33,$20, 41,$21 ; x positions/tile numbers
_9153:
.db 8 ; count
.db  24    , 32    , 40    , 48    , 56    , 64    , 72    , 80     ; y positions
.db  13,$2E, 11,$2F, 10,$30,  8,$31,  6,$32,  6,$33,  4,$34,  1,$35 ; x positions/tile numbers
_916c:
.db 11 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24     ; y positions
.db  14,$36, 22,$37,  8,$38, 16,$39, 30,$0A,  6,$3A, 14,$3B, 30,$3C, 38,$0A, 11,$3D, 35,$3E ; x positions/tile numbers
_918e:
.db 8 ; count
.db   0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24     ; y positions
.db  14,$3F,  8,$40, 16,$41,  4,$42, 12,$3B, 29,$43,  8,$44, 32,$45 ; x positions/tile numbers
_91a7:
.db 4 ; count
.db   0    ,  8    , 16    , 24     ; y positions
.db  11,$46,  8,$47,  8,$48,  8,$49 ; x positions/tile numbers
_91b4:
.db 9 ; count
.db  24    , 24    , 32    , 32    , 40    , 40    , 48    , 48    , 56     ; y positions
.db  13,$4A, 21,$0A, 18,$4B, 26,$4C, 25,$4D, 33,$4E, 30,$4F, 38,$50, 41,$51 ; x positions/tile numbers
_91d0:
.db 9 ; count
.db  24    , 32    , 40    , 40    , 48    , 48    , 48    , 56    , 56     ; y positions
.db  13,$52, 14,$53, 15,$54, 23,$55, 23,$56, 31,$57, 39,$0A, 34,$58, 42,$59 ; x positions/tile numbers
_91ec:
.db 26 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  17,$00, 25,$01, 16,$02, 24,$03, 32,$04, 40,$05, 15,$06, 23,$07, 31,$08, 39,$09,  0,$0A,  8,$0B, 16,$0C, 24,$0D, 32,$0E, 40,$0F,  0,$10,  8,$11, 16,$12, 24,$13, 32,$14,  3,$15, 11,$16, 19,$17, 27,$18, 35,$19 ; x positions/tile numbers
_923b:
.db 25 ; count
.db   8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40     ; y positions
.db   0,$1A, 24,$1B, 32,$1C, 40,$1D,  1,$1E,  9,$1F, 22,$20, 30,$21, 38,$22,  0,$0A,  8,$23, 16,$24, 24,$25, 32,$0E, 40,$0F,  0,$26,  8,$27, 16,$28, 24,$13, 32,$14,  3,$29, 11,$2A, 19,$17, 27,$18, 35,$19 ; x positions/tile numbers
_9287:
.db 24 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  24,$1B, 32,$04, 40,$05,  0,$2B,  8,$2C, 25,$2D, 33,$2E, 41,$2F,  0,$30,  8,$31, 16,$32, 24,$33, 32,$34, 40,$0F,  0,$10,  8,$11, 16,$12, 24,$13, 32,$14,  3,$15, 11,$16, 19,$17, 27,$18, 35,$19 ; x positions/tile numbers
_92d0:
.db 36 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  50,$11, 58,$12,  3,$13, 11,$14, 34,$15, 42,$16, 56,$17,  8,$18, 16,$19, 24,$1A, 33,$1B, 48,$1C, 10,$1D, 32,$1E, 48,$1F, 40,$20, 48,$21, 32,$22, 40,$23,  1,$24, 32,$25, 40,$26,  0,$27, 40,$28,  2,$29, 40,$2A, 48,$2B,  4,$2C, 32,$2D, 40,$2E, 48,$2F,  8,$30, 16,$31, 24,$32, 32,$33, 48,$34 ; x positions/tile numbers
_933d:
.db 10 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   9,$35, 17,$36,  8,$37, 16,$38,  8,$39, 16,$3A,  8,$3B, 16,$3C,  8,$3D, 16,$3E ; x positions/tile numbers
_935c:
.db 10 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   9,$3F, 17,$40,  8,$41, 16,$42,  8,$43, 16,$44,  8,$45, 16,$46,  8,$47, 16,$48 ; x positions/tile numbers
_937b:
.db 10 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   9,$49, 17,$4A,  8,$4B, 16,$4C,  8,$4D, 16,$4E,  8,$4F, 16,$50,  8,$51, 16,$52 ; x positions/tile numbers
_939a:
.db 10 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   9,$49, 17,$4A,  8,$4B, 16,$4C,  8,$53, 16,$54,  8,$55, 16,$56,  8,$51, 16,$52 ; x positions/tile numbers
_93b9:
.db 12 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40     ; y positions
.db   9,$49, 17,$4A,  8,$4B, 16,$4C,  8,$53, 16,$54,  8,$57, 16,$58,  8,$59, 16,$5A,  8,$5B, 16,$5C ; x positions/tile numbers
_93de:
.db 21 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64     ; y positions
.db   9,$49, 17,$4A,  8,$4B, 16,$4C,  8,$5D, 16,$5E,  8,$5F, 16,$60,  8,$61, 16,$62, 13,$63,  8,$64, 16,$65,  0,$66,  9,$67, 17,$68, 25,$69,  0,$6A,  8,$6B, 16,$6C, 27,$6D ; x positions/tile numbers
_941e:
.db 21 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64     ; y positions
.db   9,$49, 17,$4A,  8,$4B, 16,$4C,  8,$6E, 16,$5E,  8,$6F, 16,$70,  8,$71, 16,$72, 13,$73, 11,$74, 19,$75,  1,$76,  9,$77, 17,$78, 25,$79,  2,$7A, 10,$7B, 18,$7C, 26,$7D ; x positions/tile numbers
_945e:
.db 21 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64     ; y positions
.db   9,$49, 17,$4A,  8,$4B, 16,$4C,  8,$6E, 16,$5E,  8,$7E, 16,$7F,  8,$80, 16,$81, 13,$82,  8,$83, 16,$84,  0,$85,  8,$86, 16,$87, 24,$88,  1,$89,  9,$8A, 17,$8B, 25,$8C ; x positions/tile numbers
_949e:
.db 16 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    ,  8    , 24    , 24    , 40    , 40    , 48    , 48     ; y positions
.db   4,$17, 12,$18, 48,$19, 56,$1A,  1,$1B, 16,$1C, 24,$1D, 32,$1E, 40,$1F, 56,$20,  8,$21, 48,$22,  0,$23, 56,$24,  2,$25, 56,$26 ; x positions/tile numbers
_94cf:
.db 14 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 24    , 24    , 24    , 24     ; y positions
.db  11,$27, 19,$28, 27,$29, 35,$2A,  9,$2B, 17,$2C, 25,$2D, 34,$2E, 10,$2F, 35,$30,  0,$31,  8,$32, 32,$32, 40,$33 ; x positions/tile numbers
_94fa:
.db 13 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 24    , 24    , 24    , 24     ; y positions
.db   9,$34, 17,$35, 25,$36, 34,$37,  9,$38, 17,$2C, 25,$39, 33,$3A, 30,$3B,  0,$31,  8,$32, 32,$32, 40,$33 ; x positions/tile numbers
_9522:
.db 13 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 24    , 24    , 24    , 24     ; y positions
.db  13,$3C, 21,$3D, 29,$3E, 37,$3F, 10,$40, 18,$41, 26,$42, 34,$43, 11,$44,  0,$31,  8,$32, 32,$32, 40,$33 ; x positions/tile numbers
_954a:
.db 14 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 24    , 24    , 24    , 24     ; y positions
.db  11,$45, 19,$46, 27,$47, 35,$2A,  9,$48, 17,$49, 25,$4A, 34,$2E, 10,$2F, 35,$30,  0,$31,  8,$32, 32,$32, 40,$33 ; x positions/tile numbers
_9575:
.db 14 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 24    , 24    , 24    , 24     ; y positions
.db  11,$45, 19,$46, 27,$47, 35,$2A,  9,$48, 17,$4B, 25,$4C, 34,$2E, 10,$2F, 35,$30,  0,$31,  8,$32, 32,$32, 40,$33 ; x positions/tile numbers
_95a0:
.db 15 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24     ; y positions
.db  11,$45, 19,$46, 27,$47, 35,$2A,  9,$48, 17,$4D, 25,$4A, 34,$2E, 10,$2F, 22,$4E, 35,$30,  0,$31,  8,$32, 32,$32, 40,$33 ; x positions/tile numbers
_95ce:
.db 18 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24     ; y positions
.db  11,$45, 19,$46, 27,$47, 35,$2A,  9,$48, 17,$4F, 25,$50, 34,$2E, 10,$2F, 18,$51, 26,$52, 35,$30,  0,$31,  8,$32, 18,$53, 29,$54, 37,$55, 45,$56 ; x positions/tile numbers
_9605:
.db 19 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32     ; y positions
.db  11,$45, 19,$57, 27,$47, 35,$2A,  9,$58, 17,$59, 25,$5A, 33,$5B, 10,$5C, 18,$5D, 26,$5E, 34,$5F,  0,$31,  8,$60, 16,$61, 24,$62, 32,$63, 40,$33, 21,$64 ; x positions/tile numbers
_963f:
.db 32 ; count
.db   0    ,  0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40     ; y positions
.db   7,$65, 15,$66, 23,$67, 31,$68, 40,$69,  6,$6A, 14,$6B, 22,$6C, 30,$6D, 38,$6E,  1,$6F,  9,$70, 17,$71, 25,$72, 33,$73, 41,$74,  0,$75,  8,$76, 16,$77, 24,$78, 32,$79, 40,$7A,  6,$7B, 14,$7C, 22,$7D, 30,$7E, 38,$7F,  4,$80, 13,$81, 21,$82, 29,$83, 41,$84 ; x positions/tile numbers
_96a0:
.db 19 ; count
.db   8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40     ; y positions
.db   0,$00,  8,$01, 33,$02, 41,$03,  3,$04, 11,$05, 19,$06, 27,$07, 35,$08, 43,$09,  9,$0A, 17,$0B, 25,$0C, 33,$0D, 10,$0E, 18,$0F, 26,$10, 34,$11, 20,$12 ; x positions/tile numbers
_96da:
.db 21 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40     ; y positions
.db   8,$13, 34,$14,  7,$15, 15,$16, 30,$17, 38,$18, 10,$19, 18,$1A, 26,$1B, 34,$1C,  9,$1D, 17,$1E, 25,$1F, 33,$20, 10,$21, 18,$22, 26,$23, 34,$24, 12,$25, 20,$26, 30,$25 ; x positions/tile numbers
_971a:
.db 17 ; count
.db  16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40     ; y positions
.db   0,$27,  8,$28, 16,$29, 24,$2A, 32,$2B, 40,$2C,  0,$2D,  8,$2E, 16,$2F, 24,$30, 32,$31, 40,$32, 10,$33, 18,$34, 26,$35, 34,$36, 20,$37 ; x positions/tile numbers
_974e:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$00, 19,$01,  2,$02, 10,$03, 18,$04,  2,$05, 10,$06, 18,$07, 26,$08,  1,$09,  9,$0A, 17,$0B, 25,$0C,  1,$0D, 10,$0E, 18,$0F, 26,$10,  1,$11,  9,$12, 17,$13, 25,$14,  5,$15, 13,$16, 21,$17, 29,$18,  5,$19, 13,$1A, 21,$1B,  6,$1C, 14,$1D, 22,$1E,  4,$1F, 12,$20, 20,$21, 28,$22,  2,$23, 10,$24, 18,$25, 26,$26 ; x positions/tile numbers
_97c4:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  12,$27, 20,$01, 11,$28, 19,$29, 27,$2A,  3,$2B, 11,$2C, 19,$2D, 27,$2E,  4,$2F, 12,$30, 20,$31, 28,$32,  3,$33, 11,$34, 19,$35, 27,$36,  3,$37, 11,$38, 19,$39, 27,$3A,  3,$3B, 11,$3C, 19,$3D, 27,$3E,  9,$3F, 17,$40, 25,$41,  6,$1C, 14,$1D, 22,$1E,  4,$1F, 12,$20, 20,$21, 28,$22,  2,$23, 10,$24, 18,$25, 26,$26 ; x positions/tile numbers
_983a:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$42, 19,$43,  2,$44, 10,$45, 18,$46,  2,$05, 10,$47, 18,$48, 26,$08,  1,$09,  9,$0A, 17,$0B, 25,$0C,  1,$0D, 10,$0E, 18,$0F, 26,$10,  1,$11,  9,$12, 17,$13, 25,$14,  5,$15, 13,$16, 21,$17, 29,$18,  5,$19, 13,$1A, 21,$1B,  6,$1C, 14,$1D, 22,$1E,  4,$1F, 12,$20, 20,$21, 28,$22,  2,$23, 10,$24, 18,$25, 26,$26 ; x positions/tile numbers
_98b0:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$49, 19,$4A,  2,$02, 10,$4B, 18,$4C,  2,$05, 10,$4D, 18,$4E, 26,$08,  1,$09,  9,$4F, 17,$50, 25,$0C,  1,$0D, 10,$0E, 18,$51, 26,$10,  1,$11,  9,$12, 17,$13, 25,$14,  5,$15, 13,$16, 21,$17, 29,$18,  5,$19, 13,$1A, 21,$1B,  6,$1C, 14,$1D, 22,$1E,  4,$1F, 12,$20, 20,$21, 28,$22,  2,$23, 10,$24, 18,$25, 26,$26 ; x positions/tile numbers
_9926:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$52, 19,$53,  2,$02, 10,$54, 18,$55,  2,$05, 10,$56, 18,$57, 26,$08,  1,$09,  9,$58, 17,$59, 25,$0C,  1,$0D, 10,$5A, 18,$5B, 26,$10,  1,$11,  9,$12, 17,$13, 25,$14,  5,$15, 13,$16, 21,$17, 29,$18,  5,$19, 13,$1A, 21,$1B,  6,$1C, 14,$1D, 22,$1E,  4,$1F, 12,$20, 20,$21, 28,$22,  2,$23, 10,$24, 18,$25, 26,$26 ; x positions/tile numbers
_999c:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  12,$5C, 20,$5D,  2,$02, 10,$5E, 18,$5F,  2,$05, 10,$60, 18,$61, 26,$08,  1,$09,  9,$62, 17,$63, 25,$0C,  1,$0D, 10,$64, 18,$65, 26,$10,  1,$11,  9,$66, 17,$67, 25,$14,  5,$15, 13,$68, 21,$17, 29,$18,  5,$19, 13,$69, 21,$1B,  6,$1C, 14,$6A, 22,$1E,  4,$1F, 12,$20, 20,$21, 28,$22,  2,$23, 10,$24, 18,$25, 26,$26 ; x positions/tile numbers
_9a12:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  12,$5C, 20,$5D,  2,$02, 10,$5E, 18,$5F,  2,$05, 10,$60, 18,$61, 26,$08,  1,$09,  9,$62, 17,$6B, 25,$0C,  1,$0D, 10,$6C, 18,$6D, 26,$10,  1,$11,  9,$66, 17,$6E, 25,$14,  5,$15, 13,$6F, 21,$17, 29,$18,  5,$19, 13,$70, 21,$1B,  6,$1C, 14,$71, 22,$1E,  4,$1F, 12,$72, 20,$21, 28,$22,  2,$23, 10,$73, 18,$25, 26,$26 ; x positions/tile numbers
_9a88:
.db 45 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db   1,$0B, 38,$0C, 46,$0D,  5,$0E, 13,$0F, 31,$10, 39,$11, 10,$12, 27,$13, 35,$14, 10,$15, 18,$16, 26,$17, 34,$18,  3,$19, 11,$1A, 19,$1B, 27,$1C, 35,$1D,  0,$1E, 32,$1F, 40,$20,  0,$21,  8,$22, 40,$23,  1,$24,  9,$25, 40,$26, 49,$27,  4,$28, 12,$29, 20,$2A, 32,$2B, 40,$2C, 48,$2D,  9,$2E, 17,$2F, 25,$30, 33,$31, 41,$32,  6,$33, 14,$34, 22,$35, 30,$36, 38,$37 ; x positions/tile numbers
_9b10:
.db 45 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db   1,$0B, 38,$0C, 46,$0D,  5,$0E, 13,$0F, 31,$10, 39,$11, 10,$12, 27,$13, 35,$14, 10,$15, 18,$16, 26,$17, 34,$18,  3,$19, 11,$1A, 19,$1B, 27,$1C, 35,$1D,  0,$1E, 32,$38, 40,$39,  0,$3A,  8,$3B, 40,$3C,  1,$3D,  9,$3E, 40,$3F, 48,$40,  4,$28, 12,$29, 20,$2A, 32,$2B, 40,$41, 48,$42,  9,$2E, 17,$2F, 25,$30, 33,$31, 41,$32,  6,$33, 14,$34, 22,$35, 30,$36, 38,$37 ; x positions/tile numbers
_9b98:
.db 44 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db   1,$0B, 38,$0C, 46,$0D,  5,$0E, 13,$0F, 31,$10, 39,$11, 10,$12, 27,$13, 35,$14, 10,$15, 18,$16, 26,$17, 34,$18,  3,$19, 11,$1A, 19,$1B, 27,$1C, 35,$43, 43,$44,  0,$1E, 32,$45, 40,$46,  0,$47,  8,$48, 40,$49,  1,$4A,  9,$4B, 40,$4C,  4,$28, 12,$29, 20,$2A, 32,$2B, 40,$4D,  9,$2E, 17,$2F, 25,$30, 33,$31, 41,$32,  6,$33, 14,$34, 22,$35, 30,$36, 38,$37 ; x positions/tile numbers
_9c1d:
.db 44 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db   1,$0B, 38,$0C, 46,$0D,  5,$0E, 13,$0F, 31,$10, 39,$11, 10,$12, 27,$13, 35,$14, 10,$15, 18,$16, 26,$17, 34,$4E, 42,$4F,  3,$19, 11,$1A, 19,$1B, 27,$1C, 35,$50,  0,$1E, 32,$51, 40,$52,  0,$53,  8,$54, 40,$55,  1,$56,  9,$57, 40,$4C,  4,$28, 12,$29, 20,$2A, 32,$2B, 40,$4D,  9,$2E, 17,$2F, 25,$30, 33,$31, 41,$32,  6,$33, 14,$34, 22,$35, 30,$36, 38,$37 ; x positions/tile numbers
_9ca2:
.db 45 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db   1,$0B, 38,$0C, 46,$0D,  5,$0E, 13,$0F, 31,$10, 39,$11, 10,$12, 27,$13, 35,$14, 10,$15, 18,$16, 26,$17, 34,$18,  3,$19, 11,$1A, 19,$1B, 27,$58, 35,$59,  0,$1E, 28,$5A, 36,$5B,  0,$5C,  8,$5D, 27,$5E, 40,$49,  1,$5F,  9,$60, 28,$61, 40,$4C,  4,$62, 12,$29, 20,$2A, 32,$2B, 40,$4D,  9,$2E, 17,$2F, 25,$30, 33,$31, 41,$32,  6,$33, 14,$34, 22,$35, 30,$36, 38,$37 ; x positions/tile numbers
_9d2a:
.db 46 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db   1,$0B, 38,$0C, 46,$0D,  5,$0E, 13,$0F, 31,$10, 39,$11, 10,$12, 27,$13, 35,$14, 10,$15, 18,$16, 26,$17, 34,$18,  3,$19, 11,$1A, 19,$1B, 27,$63, 35,$64,  0,$1E, 28,$65, 36,$66,  0,$5C,  8,$5D, 26,$67, 40,$68,  1,$5F,  9,$60, 25,$69, 33,$6A, 41,$6B,  4,$62, 12,$29, 20,$6C, 28,$6D, 36,$6E,  9,$2E, 17,$2F, 25,$30, 33,$31, 41,$32,  6,$33, 14,$34, 22,$35, 30,$36, 38,$37 ; x positions/tile numbers
_9db5:
.db 38 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72     ; y positions
.db  13,$00, 21,$01,  4,$02, 12,$03, 20,$04, 28,$05,  3,$06, 11,$07, 19,$08, 27,$09,  3,$0A, 11,$0B, 19,$0C, 27,$0D,  3,$0E, 11,$0F, 19,$10, 27,$11,  3,$12, 11,$13, 19,$14, 27,$15,  3,$16, 11,$17, 21,$18, 29,$19,  4,$1A, 12,$1B, 21,$1C, 29,$1D,  8,$1E, 16,$1F, 24,$20,  2,$21, 10,$22, 18,$23, 26,$24, 34,$25 ; x positions/tile numbers
_9e28:
.db 11 ; count
.db   0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 40    , 48    , 56     ; y positions
.db   8,$26,  3,$27, 11,$28,  4,$29, 12,$2A,  4,$2B, 12,$2C,  6,$2D,  6,$2E,  6,$2F,  7,$30 ; x positions/tile numbers
_9e4a:
.db 9 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40     ; y positions
.db   3,$31, 11,$32,  4,$33, 12,$34,  4,$35, 12,$36,  6,$37, 14,$38,  6,$39 ; x positions/tile numbers
_9e66:
.db 8 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   3,$3A, 11,$3B,  4,$3C, 12,$3D,  4,$3E, 12,$3F,  5,$40, 13,$41 ; x positions/tile numbers
_9e7f:
.db 8 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   3,$3A, 11,$3B,  4,$3C, 12,$3D,  4,$42, 12,$3F,  5,$40, 13,$41 ; x positions/tile numbers
_9e98:
.db 8 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32     ; y positions
.db   3,$3A, 11,$3B,  4,$3C, 12,$3D,  4,$43, 12,$44,  5,$45, 13,$41 ; x positions/tile numbers
_9eb1:
.db 10 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 32    , 32    , 32     ; y positions
.db   3,$3A, 11,$3B,  1,$46,  9,$47, 17,$48,  2,$49, 10,$4A,  1,$4B,  9,$4C, 17,$4D ; x positions/tile numbers
_9ed0:
.db 11 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32     ; y positions
.db   3,$3A, 11,$3B,  1,$4E,  9,$4F, 17,$48,  0,$50,  8,$51, 16,$52,  0,$53,  8,$54, 16,$55 ; x positions/tile numbers
_9ef2:
.db 10 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32     ; y positions
.db   3,$3A, 11,$3B,  3,$56, 11,$57,  0,$58,  8,$59, 16,$5A,  0,$5B,  8,$5C, 16,$5D ; x positions/tile numbers
_9f11:
.db 20 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 40    , 40     ; y positions
.db   1,$00,  9,$01, 33,$02, 41,$03, 10,$04, 18,$05, 26,$06, 34,$07,  0,$08,  8,$09, 32,$0A, 40,$0B,  1,$0C,  9,$0D, 32,$0E, 40,$0F, 12,$10, 32,$11,  9,$12, 32,$13 ; x positions/tile numbers
_9f4e:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   0,$14,  8,$15,  0,$16,  8,$17,  0,$18,  8,$19,  0,$1A,  8,$1B ; x positions/tile numbers
_9f67:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   0,$1C,  8,$1D,  0,$1E,  8,$1F,  0,$18,  8,$19,  0,$1A,  8,$1B ; x positions/tile numbers
_9f80:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   0,$20,  8,$21,  0,$22,  8,$23,  0,$18,  8,$19,  0,$1A,  8,$1B ; x positions/tile numbers
_9f99:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   0,$20,  8,$21,  0,$24,  8,$25,  0,$26,  8,$27,  0,$1A,  8,$1B ; x positions/tile numbers
_9fb2:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   0,$20,  8,$21,  0,$28,  8,$29,  0,$2A,  8,$2B,  0,$2C,  8,$2D ; x positions/tile numbers
_9fcb:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   0,$20,  8,$21,  0,$2E,  8,$2F,  0,$30,  8,$31,  0,$32,  8,$33 ; x positions/tile numbers
_9fe4:
.db 28 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72     ; y positions
.db  17,$0E, 25,$0F,  8,$10, 32,$11,  7,$12, 40,$12,  7,$13, 40,$13,  7,$14, 15,$15, 32,$16, 40,$17,  5,$18, 13,$19, 32,$1A, 40,$1B,  5,$1C, 13,$1D, 32,$1E, 40,$1F, 11,$20, 32,$21, 11,$22, 19,$23, 27,$24, 35,$25,  8,$26, 32,$27 ; x positions/tile numbers
_a039:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  16,$28, 24,$29, 16,$2A, 24,$2B ; x positions/tile numbers
_a046:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  16,$2C, 24,$2D, 16,$2E, 24,$2F ; x positions/tile numbers
_a053:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  16,$30, 24,$31, 16,$32, 24,$33 ; x positions/tile numbers
_a060:
.db 5 ; count
.db   8    ,  8    , 16    , 16    , 24     ; y positions
.db  16,$34, 24,$35, 16,$36, 24,$37, 23,$38 ; x positions/tile numbers
_a070:
.db 6 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db  16,$39, 24,$3A, 16,$3B, 24,$3C, 18,$3D, 26,$3E ; x positions/tile numbers
_a083:
.db 11 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24     ; y positions
.db  14,$3F, 22,$40, 30,$41,  6,$42, 14,$43, 22,$44, 30,$45, 38,$46, 14,$47, 22,$48, 30,$49 ; x positions/tile numbers
_a0a5:
.db 22 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32     ; y positions
.db  15,$4A, 23,$4B, 31,$4C, 44,$4D,  9,$4E, 17,$4F, 25,$50, 33,$51, 41,$52,  8,$53, 16,$54, 24,$55, 32,$56,  0,$57,  8,$58, 16,$59, 24,$5A, 32,$5B,  0,$5C, 15,$5D, 23,$5E, 31,$5F ; x positions/tile numbers
_a0e8:
.db 30 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db  14,$00, 22,$01, 30,$02, 13,$03, 21,$04, 29,$05, 10,$06, 18,$07, 26,$08, 34,$09, 12,$0A, 20,$0B, 28,$0C, 36,$0D, 13,$0E, 21,$0F, 29,$10, 37,$11, 11,$12, 19,$13, 27,$14, 35,$15, 13,$16, 21,$17, 29,$18,  7,$19, 15,$1A, 23,$1B, 31,$1C, 39,$1D ; x positions/tile numbers
_a143:
.db 29 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db  14,$1E, 26,$1F, 13,$20, 21,$21, 29,$22, 10,$23, 18,$24, 26,$25, 34,$26, 12,$0A, 20,$0B, 28,$0C, 36,$0D, 13,$0E, 21,$0F, 29,$10, 37,$11, 11,$12, 19,$13, 27,$14, 35,$15, 13,$16, 21,$17, 29,$18,  7,$19, 15,$1A, 23,$1B, 31,$1C, 39,$1D ; x positions/tile numbers
_a19b:
.db 30 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56     ; y positions
.db  14,$00, 22,$01, 30,$02, 13,$03, 21,$27, 29,$05, 10,$06, 18,$28, 26,$29, 34,$2A, 12,$0A, 20,$0B, 28,$0C, 36,$0D, 13,$0E, 21,$0F, 29,$10, 37,$11, 11,$12, 19,$13, 27,$14, 35,$15, 13,$16, 21,$17, 29,$18,  7,$19, 15,$1A, 23,$1B, 31,$1C, 39,$1D ; x positions/tile numbers
_a1f6:
.db 4 ; count
.db  24    , 32    , 40    , 48     ; y positions
.db   9,$2B,  8,$2C,  7,$2D,  6,$2E ; x positions/tile numbers
_a203:
.db 4 ; count
.db  24    , 32    , 32    , 40     ; y positions
.db   8,$2F,  2,$30, 10,$31,  6,$32 ; x positions/tile numbers
_a210:
.db 7 ; count
.db   0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db   7,$33,  3,$34, 11,$35,  2,$36, 10,$37,  4,$38, 12,$39 ; x positions/tile numbers
_a226:
.db 4 ; count
.db  16    , 24    , 32    , 40     ; y positions
.db   6,$3A,  2,$3B,  2,$3C,  7,$3D ; x positions/tile numbers
_a233:
.db 4 ; count
.db  24    , 32    , 40    , 48     ; y positions
.db   9,$3E,  8,$3F,  7,$40,  7,$41 ; x positions/tile numbers
_a240:
.db 4 ; count
.db  24    , 32    , 32    , 40     ; y positions
.db   8,$42,  7,$43, 15,$44,  6,$45 ; x positions/tile numbers
_a24d:
.db 4 ; count
.db  24    , 32    , 32    , 40     ; y positions
.db   8,$46,  6,$47, 14,$48,  6,$49 ; x positions/tile numbers
_a25a:
.db 5 ; count
.db  24    , 24    , 32    , 32    , 40     ; y positions
.db   6,$4A, 14,$4B,  4,$4C, 12,$4D,  6,$4E ; x positions/tile numbers
_a26a:
.db 7 ; count
.db  24    , 24    , 32    , 32    , 32    , 40    , 40     ; y positions
.db   2,$4F, 10,$50,  1,$51,  9,$52, 17,$53,  2,$54, 10,$55 ; x positions/tile numbers
_a280:
.db 8 ; count
.db  24    , 24    , 24    , 32    , 32    , 40    , 40    , 40     ; y positions
.db   0,$56,  8,$46, 16,$57,  6,$47, 14,$48,  0,$58,  8,$59, 16,$5A ; x positions/tile numbers
_a299:
.db 21 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$16, 21,$17, 40,$18, 48,$19, 17,$1A, 40,$1B, 16,$1C, 24,$1D, 32,$1E, 40,$1F, 21,$20, 40,$21 ; x positions/tile numbers
_a2d9:
.db 26 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$22, 21,$23, 29,$24, 37,$25, 45,$26, 11,$27, 19,$28, 27,$29, 35,$2A, 43,$2B, 13,$2C, 21,$2D, 29,$2E, 37,$2F, 45,$30, 21,$20, 40,$21 ; x positions/tile numbers
_a328:
.db 32 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$31, 21,$32, 29,$24, 37,$33, 45,$34,  9,$35, 17,$36, 25,$37, 33,$38, 41,$39, 49,$3A,  2,$3B, 10,$3C, 18,$3D, 26,$3E, 34,$3F, 44,$40, 52,$41, 60,$42,  0,$43, 21,$20, 40,$21, 55,$44 ; x positions/tile numbers
_a389:
.db 23 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 31,$45, 40,$14, 48,$15, 13,$16, 21,$46, 29,$47, 37,$48, 45,$49, 17,$1A, 40,$1B, 16,$1C, 24,$1D, 32,$1E, 40,$1F, 21,$20, 40,$21 ; x positions/tile numbers
_a3cf:
.db 24 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$16, 21,$4A, 29,$4B, 40,$18, 48,$19, 17,$1A, 25,$4C, 33,$4D, 41,$4E, 16,$1C, 24,$1D, 32,$1E, 40,$1F, 21,$20, 40,$21 ; x positions/tile numbers
_a418:
.db 24 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$16, 21,$4F, 30,$50, 40,$18, 48,$19, 17,$1A, 26,$51, 34,$52, 42,$53, 16,$54, 24,$55, 32,$56, 40,$57, 21,$20, 40,$21 ; x positions/tile numbers
_a461:
.db 25 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$16, 21,$17, 29,$58, 40,$18, 48,$19, 17,$1A, 27,$59, 35,$5A, 43,$5B, 16,$5C, 24,$5D, 32,$5E, 40,$5F, 20,$60, 28,$61, 36,$62 ; x positions/tile numbers
_a4ad:
.db 22 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48     ; y positions
.db  24,$0D, 32,$0E, 21,$0F, 29,$10, 37,$11, 12,$12, 20,$13, 40,$14, 48,$15, 13,$16, 21,$17, 40,$18, 48,$19, 17,$1A, 40,$1B, 16,$63, 24,$64, 32,$65, 40,$66, 20,$67, 28,$68, 36,$69 ; x positions/tile numbers
_a4f0:
.db 23 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48     ; y positions
.db  17,$6A, 40,$6B, 18,$6C, 26,$6D, 34,$6E, 42,$6F, 21,$70, 29,$71, 37,$72, 21,$73, 29,$74, 37,$75, 20,$76, 28,$77, 36,$78, 18,$79, 26,$7A, 34,$7B, 42,$7C, 13,$7D, 21,$7E, 40,$7F, 48,$80 ; x positions/tile numbers
_a536:
.db 40 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 96    , 96    , 96    , 96    , 96     ; y positions
.db  23,$0E, 34,$0F, 23,$10, 31,$11, 21,$12, 32,$13, 40,$14, 21,$15, 40,$16, 20,$17, 32,$18, 22,$19, 32,$1A, 40,$1B, 19,$1C, 48,$1D, 18,$1E, 48,$1F, 17,$20, 25,$21, 40,$22, 48,$23, 17,$24, 32,$25, 40,$26, 48,$27, 16,$28, 30,$29, 38,$2A, 48,$2B, 12,$2C, 22,$2D, 30,$2E, 40,$2F, 48,$30, 10,$31, 18,$32, 26,$33, 34,$34, 42,$35 ; x positions/tile numbers
_a5af:
.db 16 ; count
.db  16    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 48    , 48    , 56    , 56    , 64    , 72    , 80    , 88     ; y positions
.db  15,$36, 13,$37, 21,$38, 40,$39, 14,$3A, 39,$3B, 12,$3C, 41,$3D, 11,$3E, 42,$3F, 12,$40, 42,$41, 10,$42,  9,$43,  7,$44,  7,$45 ; x positions/tile numbers
_a5e0:
.db 18 ; count
.db  16    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 64    , 72    , 80    , 88     ; y positions
.db  15,$36, 13,$37, 21,$38, 40,$46, 14,$3A, 38,$47, 46,$48, 12,$3C, 38,$49, 46,$4A, 11,$3E, 38,$4B, 46,$4C, 12,$40, 10,$42,  9,$43,  7,$44,  7,$45 ; x positions/tile numbers
_a617:
.db 16 ; count
.db  16    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 56    , 64    , 72    , 80    , 88     ; y positions
.db  15,$36, 13,$37, 21,$38, 40,$4D, 14,$3A, 37,$4E, 45,$4F, 12,$3C, 37,$50, 45,$51, 11,$3E, 12,$40, 10,$42,  9,$43,  7,$44,  7,$45 ; x positions/tile numbers
_a648:
.db 17 ; count
.db  16    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56     ; y positions
.db  15,$36, 13,$52, 21,$53, 40,$39, 16,$54, 24,$55, 38,$56, 46,$57, 20,$58, 28,$59, 36,$5A, 44,$5B, 52,$5C, 28,$5D, 36,$5E, 44,$5F, 42,$41 ; x positions/tile numbers
_a67c:
.db 18 ; count
.db   0    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 48    , 56     ; y positions
.db  42,$60, 40,$61, 15,$36, 35,$62, 43,$63, 13,$64, 21,$65, 29,$66, 37,$67, 45,$68, 16,$69, 24,$6A, 32,$6B, 40,$6C, 26,$6D, 41,$3D, 42,$3F, 42,$41 ; x positions/tile numbers
_a6b3:
.db 13 ; count
.db  16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 40    , 40    , 48    , 48    , 56     ; y positions
.db  14,$6E, 37,$6F, 14,$70, 22,$71, 34,$72, 42,$73, 32,$74, 40,$6C, 30,$75, 41,$3D, 26,$76, 42,$3F, 42,$41 ; x positions/tile numbers
_a6db:
.db 23 ; count
.db  40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 96    , 96    , 96    , 96     ; y positions
.db  20,$1C, 48,$1D, 13,$1E, 21,$1F, 48,$20,  8,$21, 48,$22,  0,$23, 48,$24,  8,$25, 16,$26, 48,$27, 21,$28, 48,$29, 19,$2A, 27,$2B, 35,$2C, 43,$2D, 51,$2E, 13,$2F, 21,$30, 48,$31, 56,$32 ; x positions/tile numbers
_a721:
.db 30 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 56    , 56     ; y positions
.db  28,$33, 36,$34, 44,$35,  0,$36,  8,$37, 25,$38, 40,$39,  1,$3A,  9,$3B, 18,$3C, 26,$3D, 40,$3E, 48,$3F,  2,$40, 10,$41, 18,$42, 26,$43, 48,$44, 16,$45, 24,$46, 32,$47, 40,$48, 48,$49, 17,$4A, 25,$4B, 33,$4C, 41,$4D, 49,$4E, 42,$4F, 50,$50 ; x positions/tile numbers
_a77c:
.db 29 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    ,  0    ,  8    , 16    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 56     ; y positions
.db  27,$51, 35,$52, 25,$53, 33,$54, 41,$55, 23,$56, 31,$57, 39,$58, 47,$59, 22,$5A, 30,$5B, 38,$5C, 46,$5D, 32,$5E, 21,$5F, 19,$60, 21,$61, 16,$62, 24,$63, 17,$64, 25,$65, 33,$66, 41,$67, 20,$68, 28,$69, 36,$6A, 21,$6B, 31,$6C, 21,$6D ; x positions/tile numbers
_a7d4:
.db 26 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    ,  8    , 16    , 24    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48     ; y positions
.db  27,$51, 35,$52, 25,$53, 33,$54, 41,$55, 23,$56, 31,$57, 39,$58, 47,$59, 22,$5A, 30,$5B, 38,$5C, 46,$5D, 32,$5E, 12,$6E,  8,$6F,  6,$70,  6,$71, 16,$72,  7,$73, 17,$74, 25,$75, 33,$76,  8,$77, 20,$78, 28,$79 ; x positions/tile numbers
_a823:
.db 20 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 56    , 64    , 64     ; y positions
.db  30,$7A, 38,$7B, 25,$7C, 33,$7D, 41,$7E, 22,$7F, 30,$80, 38,$81, 46,$82, 22,$83, 30,$84, 38,$85, 46,$86, 32,$87, 24,$88, 37,$89, 22,$8A, 11,$8B, 18,$8C, 26,$8D ; x positions/tile numbers
_a860:
.db 26 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56     ; y positions
.db  30,$7A, 38,$7B, 25,$7C, 33,$7D, 41,$7E, 22,$7F, 30,$80, 38,$81, 46,$82, 22,$83, 30,$84, 38,$85, 46,$86, 32,$87, 25,$8E, 33,$8F, 28,$90, 36,$91, 44,$92, 37,$93, 45,$94, 53,$95, 61,$35, 43,$96, 51,$97, 59,$98 ; x positions/tile numbers
_a8af:
.db 41 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 48    , 56    , 56    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 96    , 96    , 96    , 96    ,104    ,104    ,104    ,104    ,104     ; y positions
.db  22,$31, 30,$32, 38,$33, 16,$34, 40,$35,  6,$36, 14,$37, 48,$38, 56,$39,  4,$3A, 56,$3B,  4,$3C, 56,$3D,  5,$3E,  5,$3F,  4,$40, 48,$41,  4,$42, 48,$43,  7,$44, 15,$45, 56,$46,  8,$47, 24,$48, 34,$49, 42,$4A, 56,$4B,  7,$4C, 24,$4D, 40,$4E, 48,$4F, 56,$50,  6,$51, 14,$52, 24,$53, 48,$54,  5,$55, 24,$56, 32,$57, 40,$58, 48,$59 ; x positions/tile numbers
_a92b:
.db 8 ; count
.db  40    , 40    , 48    , 48    , 48    , 56    , 56    , 56     ; y positions
.db  48,$5A, 56,$5B, 46,$5C, 54,$5D, 62,$5E, 46,$5F, 54,$60, 62,$61 ; x positions/tile numbers
_a944:
.db 5 ; count
.db  40    , 40    , 48    , 48    , 56     ; y positions
.db  48,$62, 56,$63, 46,$64, 54,$65, 55,$66 ; x positions/tile numbers
_a954:
.db 5 ; count
.db  32    , 40    , 40    , 48    , 48     ; y positions
.db  51,$67, 48,$68, 56,$69, 48,$6A, 56,$6B ; x positions/tile numbers
_a964:
.db 19 ; count
.db  40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72     ; y positions
.db  45,$6C, 53,$6D, 61,$6E, 38,$6F, 46,$70, 54,$71, 62,$72, 34,$73, 42,$74, 50,$75, 58,$76, 33,$77, 41,$78, 49,$79, 57,$7A, 34,$7B, 42,$7C, 50,$7D, 58,$7E ; x positions/tile numbers
_a99e:
.db 33 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 88    , 88     ; y positions
.db  19,$19, 27,$1A, 35,$1B, 16,$1C, 32,$1D, 14,$1E, 40,$1F, 14,$20, 22,$21, 32,$22, 40,$23,  9,$24, 17,$25, 32,$26, 40,$27,  9,$28, 17,$29, 32,$2A, 40,$2B, 10,$2C, 18,$2D, 40,$2E, 11,$2F, 40,$30, 52,$31, 11,$32, 48,$33, 13,$34, 48,$35, 18,$36, 40,$37, 19,$38, 40,$39 ; x positions/tile numbers
_aa02:
.db 2 ; count
.db   8    , 16     ; y positions
.db  25,$3A, 25,$3B ; x positions/tile numbers
_aa09:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  24,$3C, 32,$3D, 23,$3E, 31,$3F ; x positions/tile numbers
_aa16:
.db 6 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16     ; y positions
.db  20,$40, 28,$41, 36,$42, 20,$43, 28,$44, 36,$45 ; x positions/tile numbers
_aa29:
.db 31 ; count
.db   8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 88    , 88    , 88    , 88     ; y positions
.db  24,$3C, 32,$3D, 23,$46, 31,$47, 22,$48, 30,$49, 19,$4A, 31,$4B, 17,$4C, 33,$4D, 15,$4E, 35,$4F, 12,$50, 37,$51, 45,$3D,  9,$52, 17,$53, 37,$54, 45,$55,  6,$56, 14,$57, 39,$58, 47,$59,  3,$5A, 11,$5B, 41,$5C, 49,$5D,  1,$5E,  9,$5F, 42,$60, 50,$61 ; x positions/tile numbers
_aa87:
.db 8 ; count
.db  88    , 88    , 88    , 88    , 96    , 96    , 96    , 96     ; y positions
.db   0,$62,  8,$63, 42,$62, 50,$63,  0,$64,  8,$65, 42,$64, 50,$65 ; x positions/tile numbers
_aaa0:
.db 20 ; count
.db  80    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 88    , 88    , 96    , 96    , 96    , 96    , 96    , 96    ,104    ,104    ,104    ,104     ; y positions
.db   0,$66,  8,$67, 41,$66, 49,$67, -4,$68,  4,$69, 12,$6A, 37,$68, 45,$69, 53,$6A, -4,$6B,  4,$69, 12,$6C, 37,$6B, 45,$69, 53,$6C,  0,$6D,  8,$6E, 41,$6D, 49,$6E ; x positions/tile numbers
_aadd:
.db 20 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 80    , 88     ; y positions
.db  26,$0A, 34,$0B, 16,$0C, 24,$0D, 32,$0E, 16,$0F, 40,$10, 17,$11, 40,$12, 17,$13, 18,$14, 40,$15, 24,$16, 32,$17, 40,$18, 26,$19, 34,$1A, 26,$1B, 26,$1C, 24,$1D ; x positions/tile numbers
_ab1a:
.db 10 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 24    , 40    , 48     ; y positions
.db   0,$1E,  8,$1F, 40,$20,  1,$21,  9,$22, 39,$23, 39,$24, 22,$25, 19,$26, 21,$27 ; x positions/tile numbers
_ab39:
.db 12 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 32    , 40     ; y positions
.db   3,$28, 13,$29, 34,$2A,  3,$2B, 11,$2C, 28,$2D, 36,$2E, 12,$2F, 20,$30, 28,$31, 20,$32, 23,$33 ; x positions/tile numbers
_ab5e:
.db 11 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 32    , 32    , 40     ; y positions
.db   8,$34, 27,$35, 11,$36, 19,$37, 27,$38, 13,$39, 21,$3A, 29,$3B, 16,$3C, 24,$3D, 16,$3E ; x positions/tile numbers
_ab80:
.db 5 ; count
.db  16    , 16    , 24    , 24    , 32     ; y positions
.db  17,$3F, 29,$40, 19,$41, 27,$42, 21,$43 ; x positions/tile numbers
_ab90:
.db 13 ; count
.db  56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   8,$00, 16,$01,  4,$02, 12,$03, 20,$04,  0,$05,  8,$06, 16,$07, 24,$08,  1,$09,  9,$0A, 17,$0B, 25,$0C ; x positions/tile numbers
_abb8:
.db 20 ; count
.db  40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   4,$0D, 12,$0E,  3,$0F, 11,$10, 19,$11,  4,$12, 12,$13, 20,$14,  1,$15,  9,$16, 17,$17, 25,$18,  0,$19,  8,$1A, 16,$1B, 24,$1C,  1,$1D,  9,$1E, 17,$1F, 25,$20 ; x positions/tile numbers
_abf5:
.db 32 ; count
.db  16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   9,$21, 17,$22,  3,$23, 11,$24, 19,$25, 27,$26,  1,$27,  9,$28, 17,$29, 25,$2A,  1,$2B,  9,$2C, 17,$2D, 25,$2E,  1,$2F,  9,$30, 17,$31,  2,$32, 10,$33, 18,$34,  1,$35,  9,$36, 17,$37, 25,$38,  0,$39,  8,$3A, 16,$3B, 24,$3C,  2,$3D, 10,$3E, 18,$3F, 26,$40 ; x positions/tile numbers
_ac56:
.db 44 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  12,$41, 20,$42, 28,$43,  6,$44, 14,$45, 22,$46, 30,$47,  4,$48, 12,$49, 20,$4A, 28,$4B, 36,$4C,  2,$4D, 10,$4E, 18,$4F, 26,$50, 34,$51,  1,$52,  9,$53, 17,$54, 25,$55, 33,$56,  1,$57,  9,$58, 17,$59, 25,$5A,  1,$5B,  9,$5C, 17,$5D,  2,$5E, 10,$5F, 18,$60,  2,$61, 10,$62, 18,$63, 27,$64,  0,$65,  8,$66, 16,$67, 24,$68,  0,$69,  8,$6A, 16,$6B, 24,$6C ; x positions/tile numbers
_acdb:
.db 45 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  12,$6D, 20,$6E, 28,$6F,  6,$70, 14,$71, 22,$72, 30,$73,  4,$74, 12,$49, 20,$75, 28,$76, 36,$4C,  2,$77, 10,$78, 18,$79, 26,$46, 34,$7A,  1,$7B,  9,$7C, 17,$7D, 25,$7E, 33,$7F,  1,$80,  9,$81, 17,$82, 25,$83,  1,$84,  9,$85, 17,$86, 25,$87,  2,$88, 10,$89, 18,$8A,  3,$8B, 11,$8C, 19,$8D, 29,$8E,  0,$8F,  8,$90, 16,$91, 24,$92,  0,$93,  8,$94, 16,$95, 24,$96 ; x positions/tile numbers
_ad63:
.db 21 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40     ; y positions
.db  14,$00, 37,$01, 12,$02, 20,$03, 34,$04, 42,$05, 10,$06, 18,$07, 31,$08, 39,$09, 11,$0A, 19,$0B, 27,$0C, 35,$0D, 43,$0E, 16,$0F, 24,$10, 32,$11, 19,$12, 27,$13, 35,$14 ; x positions/tile numbers
_ada3:
.db 20 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32     ; y positions
.db   0,$15, 48,$16,  2,$17, 10,$18, 39,$19, 47,$1A,  4,$1B, 12,$1C, 22,$1D, 30,$1E, 38,$1F, 46,$20, 11,$21, 19,$22, 27,$23, 35,$24, 43,$25, 19,$26, 27,$27, 35,$28 ; x positions/tile numbers
_ade0:
.db 18 ; count
.db  24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  11,$29, 19,$2A, 27,$2B, 35,$2C, 43,$2D,  4,$2E, 12,$2F, 20,$30, 28,$31, 36,$32, 44,$33,  2,$34, 10,$35, 24,$36, 39,$37, 47,$38,  0,$39, 48,$3A ; x positions/tile numbers
_ae17:
.db 20 ; count
.db   8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  22,$1D, 30,$3B, 16,$3C, 24,$3D, 32,$3E, 11,$3F, 19,$40, 27,$41, 35,$42, 43,$43, 10,$44, 18,$45, 31,$46, 39,$47, 12,$48, 20,$49, 34,$4A, 42,$4B, 14,$4C, 37,$4D ; x positions/tile numbers
_ae54:
.db 34 ; count
.db  32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 96    , 96    ,104    ,104    ,104    ,104     ; y positions
.db  24,$00, 32,$01, 18,$02, 26,$03, 34,$04, 42,$05, 16,$06, 24,$07, 32,$08, 40,$09, 16,$0A, 24,$0B, 32,$0C, 40,$0D, 19,$0E, 27,$0F, 35,$10, 43,$11, 20,$12, 28,$13, 36,$14, 20,$15, 28,$16, 36,$17, 19,$18, 27,$19, 35,$1A, 43,$1B, 19,$1C, 38,$1D, 17,$1E, 25,$1F, 36,$20, 44,$21 ; x positions/tile numbers
_aebb:
.db 56 ; count
.db  32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 96    , 96    ,104    ,104    ,104    ,104     ; y positions
.db   0,$22, 24,$00, 32,$01, 57,$22,  0,$23,  8,$24, 16,$25, 24,$26, 32,$27, 40,$28, 48,$29, 56,$2A,  0,$2B,  8,$2C, 16,$2D, 24,$2E, 32,$2F, 40,$30, 48,$31, 56,$32,  3,$33, 11,$34, 19,$35, 27,$36, 35,$37, 43,$38, 51,$39, 59,$3A,  2,$3B, 10,$3C, 18,$3D, 26,$3E, 34,$3F, 42,$40, 50,$41, 58,$42,  8,$43, 16,$44, 24,$45, 32,$46, 40,$47, 48,$48, 16,$49, 24,$4A, 33,$4B, 41,$4C, 18,$4D, 26,$4E, 35,$4F, 43,$50, 19,$1C, 38,$1D, 17,$1E, 25,$1F, 36,$20, 44,$21 ; x positions/tile numbers
_af64:
.db 32 ; count
.db  40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 88    , 88    , 88    , 96    , 96    , 96    , 96    ,104    ,104    ,104    ,104     ; y positions
.db  24,$00, 32,$01, 18,$02, 26,$03, 34,$04, 42,$05, 16,$06, 24,$07, 32,$08, 40,$09, 16,$0A, 24,$51, 32,$0C, 40,$0D, 19,$0E, 27,$0F, 35,$10, 43,$11, 20,$12, 28,$13, 36,$14, 20,$15, 28,$16, 36,$17, 19,$52, 27,$19, 35,$53, 43,$54, 17,$1E, 25,$1F, 36,$20, 44,$21 ; x positions/tile numbers
_afc5:
.db 34 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 72    , 72    , 72    , 72     ; y positions
.db  18,$55, 26,$56, 34,$57, 42,$05, 16,$06, 24,$58, 32,$59, 40,$09, 16,$0A, 24,$5A, 32,$5B, 40,$0D, 19,$0E, 27,$0F, 35,$10, 43,$11, 20,$12, 28,$13, 36,$14, 20,$15, 28,$16, 36,$17, 19,$18, 27,$19, 35,$1A, 43,$1B, 19,$1C, 38,$1D, 18,$5C, 38,$5D, 17,$5E, 25,$5F, 36,$60, 44,$61 ; x positions/tile numbers
_b02c:
.db 20 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32     ; y positions
.db  17,$62, 25,$63, 33,$64, 41,$65, 17,$66, 25,$67, 33,$68, 41,$69, 17,$6A, 25,$6B, 33,$6C, 41,$6D, 17,$6E, 25,$6F, 33,$70, 41,$71, 17,$72, 25,$73, 33,$74, 41,$75 ; x positions/tile numbers
_b069:
.db 20 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32     ; y positions
.db  17,$76, 25,$77, 33,$78, 41,$79, 17,$7A, 25,$7B, 33,$7C, 41,$7D, 17,$7E, 25,$7F, 33,$80, 41,$81, 17,$82, 25,$83, 33,$84, 41,$85, 17,$86, 25,$87, 33,$88, 41,$89 ; x positions/tile numbers
_b0a6:
.db 20 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32     ; y positions
.db  17,$8A, 25,$8B, 33,$8C, 41,$8D, 17,$8E, 25,$8F, 33,$8F, 41,$90, 17,$91, 25,$92, 33,$93, 41,$94, 17,$95, 25,$96, 33,$97, 41,$98, 17,$99, 25,$9A, 33,$9B, 41,$9C ; x positions/tile numbers
_b0e3:
.db 34 ; count
.db   8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  18,$55, 26,$56, 34,$57, 42,$05, 16,$06, 24,$58, 32,$59, 40,$09, 16,$0A, 24,$5A, 32,$5B, 40,$0D, 19,$0E, 27,$0F, 35,$10, 43,$11, 20,$12, 28,$13, 36,$14, 20,$15, 28,$16, 36,$17, 19,$18, 27,$19, 35,$1A, 43,$1B, 19,$1C, 38,$1D, 18,$5C, 38,$5D, 17,$5E, 25,$5F, 36,$60, 44,$61 ; x positions/tile numbers
_b14a:
.db 2 ; count
.db  11    , 11     ; y positions
.db   7,$0D, 20,$0D ; x positions/tile numbers
_b151:
.db 2 ; count
.db  11    , 11     ; y positions
.db   7,$0E, 20,$0E ; x positions/tile numbers
_b158:
.db 2 ; count
.db  11    , 11     ; y positions
.db   6,$0F, 19,$0F ; x positions/tile numbers
_b15f:
.db 5 ; count
.db   8    ,  8    ,  8    , 16    , 16     ; y positions
.db   4,$10, 12,$11, 20,$12,  6,$13, 19,$13 ; x positions/tile numbers
_b16f:
.db 25 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 56    , 56     ; y positions
.db  18,$00, 41,$01, 18,$02, 26,$03, 35,$04, 43,$05, 18,$06, 26,$07, 34,$08, 42,$09, 18,$0A, 26,$0B, 34,$0C, 42,$0D, 19,$0E, 27,$0F, 35,$10, 43,$11, 20,$12, 28,$13, 36,$14, 24,$15, 32,$16, 27,$17, 35,$18 ; x positions/tile numbers
_b1bb:
.db 25 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 64    , 64     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 20,$27, 28,$28, 36,$29, 24,$2A, 32,$2B, 26,$2C, 34,$2D, 27,$2E, 35,$11 ; x positions/tile numbers
_b207:
.db 25 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 64    , 64     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 20,$27, 28,$2F, 36,$29, 24,$30, 32,$31, 26,$2C, 34,$2D, 27,$2E, 35,$11 ; x positions/tile numbers
_b253:
.db 25 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 64    , 64     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 20,$32, 28,$33, 36,$34, 24,$35, 32,$36, 25,$37, 33,$38, 27,$2E, 35,$11 ; x positions/tile numbers
_b29f:
.db 27 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 20,$39, 28,$3A, 36,$3B, 20,$3C, 28,$3D, 36,$3E, 20,$3F, 28,$40, 36,$41, 27,$2E, 35,$11 ; x positions/tile numbers
_b2f1:
.db 32 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 16,$42, 24,$43, 32,$44, 40,$45, 16,$46, 24,$47, 32,$48, 40,$49, 16,$4A, 24,$4B, 32,$4C, 40,$3E, 16,$4D, 24,$4E, 32,$4F, 40,$41 ; x positions/tile numbers
_b352:
.db 37 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 20,$50, 28,$51, 36,$3B, 12,$52, 20,$53, 28,$54, 36,$55, 44,$56, 12,$4A, 20,$57, 28,$58, 36,$59, 44,$49, 13,$5A, 21,$5B, 29,$5C, 37,$5D, 45,$5E, 20,$4D, 28,$4F, 36,$5F ; x positions/tile numbers
_b3c2:
.db 61 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 88     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 12,$60, 20,$61, 28,$3A, 36,$62, 44,$63,  4,$52, 12,$64, 20,$65, 28,$3D, 36,$66, 44,$67, 52,$56,  4,$4A, 12,$68, 20,$47, 28,$54, 36,$48, 44,$69, 52,$6A,  4,$46, 12,$6B, 20,$57, 28,$6C, 36,$59, 44,$6D, 52,$3E,  5,$6E, 13,$6F, 21,$70, 29,$71, 37,$72, 45,$73, 53,$74,  5,$75, 13,$76, 21,$77, 29,$78, 37,$79, 45,$7A, 53,$7B, 12,$7C, 20,$4F, 28,$4E, 36,$7D, 44,$5F ; x positions/tile numbers
_b47a:
.db 61 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 80    , 80    , 88    , 88    , 88    , 88    , 88     ; y positions
.db  18,$19, 42,$19, 18,$1A, 37,$1B, 18,$1C, 26,$1D, 34,$1E, 42,$1F, 18,$20, 26,$21, 34,$22, 42,$23, 19,$24, 27,$25, 35,$26, 43,$18, 12,$52, 20,$7E, 28,$7F, 36,$80, 44,$60,  5,$81, 13,$82, 21,$83, 29,$84, 37,$85, 45,$86, 53,$87,  4,$46, 12,$6B, 20,$54, 28,$48, 36,$59, 44,$88, 52,$49,  5,$89, 13,$8A, 21,$8B, 29,$8C, 37,$72, 45,$8D, 53,$8E,  4,$4A, 12,$8F, 20,$57, 28,$4B, 36,$90, 44,$6D, 52,$3E,  4,$4D, 12,$4B, 20,$91, 28,$92, 36,$93, 44,$4C, 52,$56, 12,$5F, 20,$4E, 28,$7D, 36,$4F, 44,$41 ; x positions/tile numbers
_b532:
.db 5 ; count
.db   0    ,  8    , 16    , 24    , 32     ; y positions
.db   9,$1F,  9,$20,  8,$21, 10,$22,  8,$23 ; x positions/tile numbers
_b542:
.db 13 ; count
.db   0    ,  0    ,  8    , 16    , 24    , 32    , 40    , 48    , 56    , 56    , 64    , 64    , 64     ; y positions
.db   0,$24,  8,$25,  3,$26,  4,$27,  3,$28,  3,$29,  3,$2A,  3,$2B,  2,$2C, 10,$2D,  0,$2E,  8,$2F, 16,$30 ; x positions/tile numbers
_b56a:
.db 12 ; count
.db   0    ,  8    , 16    , 24    , 32    , 40    , 48    , 56    , 56    , 64    , 64    , 64     ; y positions
.db   5,$31,  3,$32,  3,$33,  3,$34,  4,$35,  6,$36,  6,$37,  2,$38, 10,$39,  0,$3A,  8,$3B, 16,$3C ; x positions/tile numbers
_b58f:
.db 5 ; count
.db  56    , 56    , 64    , 64    , 64     ; y positions
.db   2,$3D, 10,$3E,  0,$3F,  8,$40, 16,$41 ; x positions/tile numbers
_b59f:
.db 5 ; count
.db  56    , 56    , 64    , 64    , 64     ; y positions
.db   2,$42, 10,$43,  0,$44,  8,$45, 16,$41 ; x positions/tile numbers
_b5af:
.db 5 ; count
.db  56    , 56    , 64    , 64    , 64     ; y positions
.db   2,$46, 10,$47,  0,$48,  8,$49, 16,$4A ; x positions/tile numbers
_b5bf:
.db 8 ; count
.db  72    , 72    , 80    , 80    , 80    , 88    , 88    , 88     ; y positions
.db  -8,$4B,  0,$4C,-20,$4D,-12,$4E, -4,$4F,-26,$50,-18,$51,-10,$52 ; x positions/tile numbers
_b5d8:
.db 14 ; count
.db  88    , 96    , 96    ,104    ,112    ,112    ,112    ,112    ,120    ,120    ,128    ,128    ,136    ,136     ; y positions
.db -26,$53,-40,$54,-32,$55,-43,$56,-68,$57,-60,$58,-52,$59,-44,$5A,-80,$5B,-72,$5C,-91,$5D,-83,$5E,-104,$5F,-96,$60 ; x positions/tile numbers
_b603:
.db 2 ; count
.db 136    ,136     ; y positions
.db -103,$61,-95,$62 ; x positions/tile numbers
_b60a:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db -100,$63,-106,$64,-98,$65,-90,$66 ; x positions/tile numbers
_b617:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db -99,$67,-107,$68,-98,$69,-90,$6A ; x positions/tile numbers
_b624:
.db 11 ; count
.db  56    , 56    , 64    , 72    , 72    , 80    , 80    , 80    , 88    , 88    , 88     ; y positions
.db -10,$6B, -2,$6C,-13,$56,-15,$6D, -7,$6E,-24,$6F,-16,$70, -8,$71,-30,$50,-22,$51,-14,$52 ; x positions/tile numbers
_b646:
.db 8 ; count
.db  96    ,104    ,112    ,112    ,120    ,128    ,136    ,136     ; y positions
.db -31,$72,-29,$73,-40,$74,-32,$75,-42,$76,-40,$77,-46,$78,-38,$79 ; x positions/tile numbers
_b65f:
.db 2 ; count
.db 136    ,136     ; y positions
.db -46,$61,-38,$62 ; x positions/tile numbers
_b666:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db -43,$63,-49,$64,-41,$65,-33,$66 ; x positions/tile numbers
_b673:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db -43,$67,-51,$68,-42,$69,-34,$6A ; x positions/tile numbers
_b680:
.db 5 ; count
.db  72    , 80    , 80    , 88    , 88     ; y positions
.db  11,$7B, 11,$6D, 19,$6E, 11,$7C, 19,$7D ; x positions/tile numbers
_b690:
.db 12 ; count
.db  88    , 96    , 96    ,104    ,112    ,112    ,120    ,120    ,128    ,128    ,136    ,136     ; y positions
.db  17,$7E, 10,$7F, 18,$80, 10,$73,  9,$81, 17,$82,  8,$83, 16,$84,  5,$85, 13,$86, 10,$87, 18,$88 ; x positions/tile numbers
_b6b5:
.db 2 ; count
.db 136    ,136     ; y positions
.db  11,$61, 19,$62 ; x positions/tile numbers
_b6bc:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db  14,$63,  8,$64, 16,$65, 24,$66 ; x positions/tile numbers
_b6c9:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db  15,$67,  7,$68, 16,$69, 24,$6A ; x positions/tile numbers
_b6d6:
.db 8 ; count
.db  56    , 56    , 64    , 72    , 72    , 80    , 80    , 80     ; y positions
.db  19,$89, 27,$8A, 25,$8B, 26,$8C, 34,$8D, 31,$8E, 39,$8F, 47,$90 ; x positions/tile numbers
_b6ef:
.db 17 ; count
.db  80    , 88    , 88    , 88    , 96    , 96    , 96    ,104    ,112    ,112    ,120    ,120    ,128    ,128    ,128    ,136    ,136     ; y positions
.db  44,$91, 37,$4D, 45,$4E, 53,$4F, 37,$92, 45,$93, 53,$94, 44,$95, 44,$96, 52,$97, 48,$98, 56,$99, 49,$9A, 57,$9B, 65,$9C, 54,$9D, 62,$9E ; x positions/tile numbers
_b723:
.db 2 ; count
.db 136    ,136     ; y positions
.db  60,$61, 68,$62 ; x positions/tile numbers
_b72a:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db  63,$63, 57,$64, 65,$65, 73,$66 ; x positions/tile numbers
_b737:
.db 4 ; count
.db 128    ,136    ,136    ,136     ; y positions
.db  64,$67, 56,$68, 65,$69, 73,$6A ; x positions/tile numbers
_b744:
.db 31 ; count
.db  56    , 56    , 64    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 88    , 96    ,104    ,112    ,120    ,128    ,136    ,136    ,-112    ,-112    ,-112    ,-104    ,-104    ,-96    ,-96    ,-96    ,-96     ; y positions
.db  40,$00, 48,$01, 10,$02, 18,$03, 26,$04, 34,$05, 42,$06, 50,$07, 11,$08, 19,$09, 27,$0A, 35,$0B, 43,$0C,  3,$0D,  6,$0E,  5,$0F,  4,$10,  4,$11,  5,$12,  4,$13,  4,$14, 40,$15,  4,$16, 40,$17, 48,$18,  4,$19, 32,$1A,  2,$1B, 10,$1C, 32,$1D, 40,$1E ; x positions/tile numbers


_b7a2:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db   9,$00, 17,$01,  8,$02, 16,$03 ; x positions/tile numbers
_b7af:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  10,$04, 18,$05, 10,$06, 18,$07 ; x positions/tile numbers
_b7bc:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  11,$08, 19,$09, 11,$0A, 19,$0B ; x positions/tile numbers
_b7c9:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  10,$0C, 18,$0D,  8,$0E, 16,$0F ; x positions/tile numbers
_b7d6:
.db 4 ; count
.db   8    ,  8    , 16    , 16     ; y positions
.db  10,$10, 18,$11, 10,$12, 18,$13 ; x positions/tile numbers
_b7e3:
.db 2 ; count
.db   8    , 16     ; y positions
.db  13,$14, 13,$15 ; x positions/tile numbers
_b7ea:
.db 12 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24     ; y positions
.db   6,$16, 14,$17, 22,$18,  4,$19, 12,$1A, 20,$1B,  5,$1C, 13,$1D, 21,$1E,  8,$1F, 16,$20, 24,$21 ; x positions/tile numbers
_b80f:
.db 50 ; count
.db -40    ,-40    ,-40    ,-32    ,-32    ,-32    ,-24    ,-24    ,-24    ,-24    ,-24    ,-24    ,-16    ,-16    ,-16    ,-16    , -8    , -8    , -8    , -8    , -8    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56     ; y positions
.db -13,$22, -5,$23,  3,$24,-14,$25, -6,$26,  2,$27,-16,$28, -8,$29,  0,$2A, 34,$2B, 42,$2C, 50,$2D,  0,$2E, 32,$2F, 40,$30, 48,$31,  5,$32, 28,$33, 36,$34, 44,$35, 52,$36,  5,$37, 24,$38,-22,$2B,-14,$2C, -6,$39,  2,$3A, 10,$3B, 18,$3C,-24,$2F,-16,$30, -8,$31,  2,$3D, 10,$3E, 18,$3F,-22,$40,-14,$41, -6,$42,  3,$43, 24,$44, 28,$45, 27,$22, 35,$23, 43,$24, 26,$25, 34,$26, 42,$27, 24,$28, 32,$29, 40,$2A ; x positions/tile numbers
_b8a6:
.db 44 ; count
.db -48    ,-48    ,-48    ,-40    ,-40    ,-40    ,-32    ,-32    ,-32    ,-24    ,-16    ,  0    ,  0    ,  0    ,  0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 40    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72     ; y positions
.db   2,$2B, 10,$2C, 18,$2D,  0,$2F,  8,$30, 16,$31,  2,$40, 10,$41, 18,$42,  4,$46,  0,$47,-37,$22,-29,$23,-21,$24, 32,$48, 40,$49, 54,$4A, 62,$4B,-38,$25,-30,$26,-22,$27, 52,$4C, 60,$4D,-40,$28,-32,$29,-24,$2A,-16,$4E, 13,$14, 54,$4F, 62,$50,-12,$51, -3,$52, 13,$15, 25,$53, 21,$54, 10,$2B, 18,$2C, 26,$2D,  8,$2F, 16,$30, 24,$31, 10,$40, 18,$41, 26,$42 ; x positions/tile numbers
_b92b:
.db 33 ; count
.db -40    ,-40    ,-40    ,-32    ,-32    ,-32    ,-24    ,-24    ,-24    ,-16    ,-16    , -8    , -8    ,  0    ,  0    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80     ; y positions
.db  35,$22, 43,$23, 51,$24, 34,$25, 42,$26, 50,$27, 32,$28, 40,$29, 48,$2A,-43,$4A,-35,$4B,-45,$4C,-37,$4D,-43,$4F,-35,$50, 59,$22, 67,$23, 75,$24, 58,$25, 66,$26, 74,$27, 56,$28, 64,$29, 72,$2A,-21,$22,-13,$23, -5,$24,-22,$25,-14,$26, -6,$27,-24,$28,-16,$29, -8,$2A ; x positions/tile numbers
_b98f:
.db 46 ; count
.db -72    ,-72    ,-72    ,-72    ,-64    ,-64    ,-64    ,-56    ,-56    ,-48    ,-40    ,-40    ,-40    ,-32    ,-32    ,-32    ,-24    ,-24    ,-24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 64    , 72    , 80    , 80    , 80    , 88    , 88    , 96    , 96    ,104    ,104    ,104    ,104    ,112    ,112    ,112    ,112    ,112     ; y positions
.db  72,$55, 80,$56, 88,$57, 96,$58, 64,$59, 72,$5A, 80,$5B, 56,$5C, 64,$5D, 49,$5E,-53,$22,-45,$23,-37,$24,-54,$25,-46,$26,-38,$27,-56,$28,-48,$29,-40,$2A, 58,$2B, 66,$2C, 74,$2D, 56,$2F, 64,$30, 72,$31, 58,$40, 66,$41, 74,$42,-24,$5F,-29,$60,-40,$61,-32,$62, 96,$63,-48,$64,-40,$65,-50,$66,-42,$67,-59,$68,-51,$69,-43,$6A, 72,$6B,-72,$6C,-64,$6D,-56,$6E,-48,$6F, 80,$70 ; x positions/tile numbers
_ba1a:
.db 34 ; count
.db -72    ,-72    ,-72    ,-72    ,-72    ,-64    ,-64    ,-64    ,-56    ,-56    ,-56    ,-48    ,-48    ,-40    , 48    , 56    , 64    , 72    , 72    , 80    , 88    , 88    , 96    , 96    , 96    ,104    ,104    ,104    ,104    ,112    ,112    ,112    ,112    ,112     ; y positions
.db -106,$71,-98,$72,-90,$73, 80,$74, 88,$75,-92,$76,-84,$77, 73,$78,-84,$79,-76,$7A,-68,$7B,-66,$7C,-58,$7D,-56,$7E, 67,$7F, 72,$80, 73,$81, 74,$82, 82,$83, 81,$84, 80,$85, 88,$86,-44,$87, 86,$88, 94,$89,-50,$8A, 88,$8B, 96,$8C,104,$8D,-63,$8E,-55,$8F, 93,$90,101,$91,109,$92 ; x positions/tile numbers
_ba81:
.db 7 ; count
.db -72    ,-72    ,-64    ,104    ,104    ,112    ,112     ; y positions
.db -102,$93,-94,$94,-88,$95, 93,$96,101,$97, 98,$98,106,$99 ; x positions/tile numbers

.ends
; followed by
.org $57a97-$54000
.section "Tile data 13" overwrite
.incbin "Tiles\57a97compr.dat"
.ends
;.org 57fdb
; Blank until end of bank

;=======================================================================================================
; Bank 22: $58000 - $5bfff - tile data/palettes/tilemap
;=======================================================================================================
.bank 22 slot 2
.ORG $0000

; Data from 58000 to 5856F (1392 bytes)
.incbin "Phantasy Star (Japan)_DATA_58000_.inc"

.org $58570-$58000
.section "Tile data 14" overwrite
TilesTown:
.incbin "Tiles\58570compr.dat" ; 405
PaletteAirCastle:
.db $30,$00,$3F,$0B,$06,$1A,$2F,$2A,$08,$15,$30,$30,$30,$30,$30,$30 ; palette for following (with castle hidden!)
TilesAirCastle:
.incbin "Tiles\5ac8dcompr.dat" ; 141 - AirCastle
.db $38,$3F,$00,$38,$1F,$0B,$06,$3E,$00,$00,$00,$00,$00,$00,$00,$00 ; palette for following
.incbin "Tiles\5b9e7compr.dat" ; 27 - flying Myau?
.ends
; followed by
.org $5bc32-$58000
.section "Tilemap data 5" overwrite
TilemapAirCastle:
.incbin "Tilemaps\5bc32tilemap.dat"
TilemapGoldDragon:
.incbin "Tilemaps\5be2atilemap.dat"
.ends
;.org $5bff6
; Blank until end of bank

;=======================================================================================================
; Bank 23: $5c000 - $5ffff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 23 slot 2
.orga $8000
.section "Tilemap data 6" overwrite
; building interiors
TilemapBuildingEmpty:
.incbin "Tilemaps\5C000tilemap.dat" ; empty
TilemapBuildingWindows:
.incbin "Tilemaps\5C31Etilemap.dat" ; 2 windows
TilemapBuildingHospital1:
.incbin "Tilemaps\5C654tilemap.dat" ; hospital
TilemapBuildingHospital2:
.incbin "Tilemaps\5C8DDtilemap.dat" ; hospital 2 (brick wall)
TilemapBuildingChurch1:
.incbin "Tilemaps\5CBA6tilemap.dat" ; church (tall windows)
TilemapBuildingChurch2:
.incbin "Tilemaps\5CF8Etilemap.dat" ; church 2 (brick wall)
TilemapBuildingArmoury1:
.incbin "Tilemaps\5D2EDtilemap.dat" ; armoury
TilemapBuildingArmoury2:
.incbin "Tilemaps\5D61Btilemap.dat" ; armoury 2 (brick wall)
TilemapBuildingShop1:
.incbin "Tilemaps\5D949tilemap.dat" ; shop (bottles + boxes)
TilemapBuildingShop2:
.incbin "Tilemaps\5DCA3tilemap.dat" ; shop 2 (bottles + boxes + brick wall)
TilemapBuildingShop3:
.incbin "Tilemaps\5DFE3tilemap.dat" ; shop 3 (boxes)
TilemapBuildingShop4:
.incbin "Tilemaps\5E310tilemap.dat" ; shop 4 (boxes + brick wall)
TilemapBuildingDestroyed:
.incbin "Tilemaps\5E64Ctilemap.dat" ; destroyed building
.ends
; followed by
.org $5ea9f-$5c000
.section "Room palettes" overwrite
PaletteBuildingEmpty: ; 5ea9f
.db $2c,$00,$3f,$3a,$28,$2c,$00,$00,$00,$00,$38,$34,$00,$00,$00,$00
PaletteBuildingWindows: ; 5eaaf
.db $2a,$00,$3f,$2a,$25,$25,$00,$00,$00,$00,$38,$34,$00,$08,$0c,$04
PaletteBuildingHospital1 ; 5eabf
.db $3f,$00,$3f,$38,$3c,$2f,$3f,$3e,$30,$00,$3c,$38,$3f,$25,$03,$00
PaletteBuildingHospital2 ; 5eacf
.db $2f,$00,$3f,$25,$06,$2a,$3f,$3e,$30,$00,$3c,$38,$3f,$25,$03,$00
PaletteBuildingChurch1: ; 5eadf
.db $3c,$00,$3f,$30,$38,$38,$3a,$36,$31,$24,$3c,$0b,$3e,$0f,$03,$06
PaletteBuildingChurch2: ; 5eaef
.db $2f,$00,$3f,$06,$06,$2f,$3c,$38,$34,$01,$3c,$0b,$3e,$0f,$03,$06
PaletteBuildingArmoury1: ; 5eaff
.db $2e,$00,$3f,$2a,$29,$29,$38,$34,$20,$3d,$0b,$0f,$3d,$3a,$36,$38
PaletteBuildingArmoury2: ; 5eb0f
.db $2a,$00,$3f,$2a,$25,$25,$07,$06,$01,$0f,$38,$3d,$0b,$2a,$25,$0b
PaletteBuildingShop1: ; 5eb1f
.db $2c,$00,$3f,$3a,$28,$2c,$2a,$25,$11,$2a,$38,$34,$3e,$38,$3c,$34
PaletteBuildingShop2: ; 5eb2f
.db $2a,$00,$3f,$2a,$25,$25,$0b,$07,$06,$06,$38,$34,$0f,$08,$0c,$04
PaletteBuildingShop3: ; 5eb3f
.db $3a,$00,$3f,$25,$36,$36,$29,$28,$14,$2a,$38,$34,$2e,$38,$3c,$34
PaletteBuildingShop4: ; 5eb4f
.db $2a,$00,$3f,$25,$25,$2a,$0b,$07,$06,$06,$38,$34,$0f,$08,$0c,$04
PaletteBuildingDestroyed: ; 5eb5f
.db $2a,$00,$3f,$25,$00,$2a,$00,$00,$00,$00,$34,$00,$00,$08,$0c,$04
.ends
; followed by
.org $5eb6f-$5c000
.section "Tile data 15" overwrite
TilesBuilding:
.incbin "Tiles\5eb6fcompr.dat" ; 176 - building interiors
PaletteSpace:          ; $5f767
.db $10,$3F,$3E,$38,$34,$30,$20,$04,$3C,$20,$00,$00,$00,$00,$00,$00 ; palette
.db $10                                                             ; end empty for target planet (?)

; Data from 5F778 to 5FFFF (2184 bytes)
TilesSpace:            ; $5f778
.incbin "Tiles\5f778compr.dat" ; 98
.ends
;.org 5ffe9
; Blank until end of bank

;=======================================================================================================
; Bank 24: $60000 - $63fff - a few tiles + palette
;=======================================================================================================
.bank 24 slot 2
.orga $8000
.section "WorldData4" overwrite
WorldData4:
.dw $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2
.dw $80a2 $80a2 $80a7 $810d $80a2 $80a2 $816e $820b
.dw $80a2 $80a2 $80a2 $829c $831c $837c $8385 $838e
.dw $842a $80a2 $80a2 $80a2 $80a2 $84cb $80a2 $80a2
.dw $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $8508 $80a2
.dw $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $8545 $85d4
.dw $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $8673
.dw $86e8 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2
.dw $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2
.dw $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2 $80a2
.dw $80a2
.ends
.org $600a2-$60000

; data pointed to, +?

; Data from 62484 to 62579 (246 bytes)
.section "Picture frame data" overwrite
TilemapFrame:
.incbin "Tilemaps\62484tilemap.dat" ; must be in same frame as palette and tiles
PaletteFrame:
.db $00,$00,$3F,$0F,$0B,$06,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
TilesFrame:
.incbin "Tiles\6258acompr.dat" ; 4
.ends
.org $625e0-$60000
; Data from 625E0 to 62781 (418 bytes)
_DATA_625E0_:
.dsb 12,$00
.db $01 $00 $02 $00 $01 $02
.dsb 16,$00
.db $03 $00 $04 $00 $05 $00 $00 $00 $00 $00 $00 $00 $06 $00 $07 $00
.db $00 $00 $00 $00 $00 $00 $08 $00 $09 $00 $0A $00 $00 $00 $00 $00
.db $00 $00 $0B $00 $0C $00 $0D $00 $00 $00 $0E $00 $0F $00 $10 $00
.db $11 $00 $12 $00 $00 $00 $00 $00 $13 $00 $14 $00 $15 $00 $16 $00
.db $17 $00 $18 $00 $19 $00 $1A $00 $1B $00 $1C $00 $1D $00 $1E $00
.db $1F $00 $20 $00 $21 $00 $22 $00 $23 $00 $24 $00 $25 $00 $26 $00
.db $27 $00 $1D $04 $28 $00 $29 $00 $2A $00 $2B $00 $2C $00 $2D $00
.db $2E $00 $2F $00 $30 $00 $31 $00 $00 $00 $32 $00 $33 $00 $34 $00
.db $35 $00 $36 $00 $37 $00 $38 $00 $39 $00 $3A $00 $3B $00 $00 $00
.db $3C $00 $3D $00 $3E $00 $3F $00 $40 $00 $41 $00 $42 $00 $43 $00
.db $00 $00 $00 $00 $00 $00 $44 $00 $45 $00 $46 $00 $47 $00 $48 $00
.db $49 $00 $4A $00 $4B $00 $00 $00 $00 $00 $00 $00 $4C $00 $4D $00
.db $4E $00 $4F $00 $50 $00 $51 $00 $52 $00 $53 $00 $00 $00 $00 $00
.db $54 $00 $55 $00 $56 $00 $57 $00 $58 $00 $59 $00 $5A $00 $5B $00
.db $5C $00 $00 $00 $00 $00 $5D $00 $5E $00 $5F $00 $60 $00 $61 $00
.db $62 $00 $63 $00 $64 $00 $65 $00 $66 $00 $00 $00 $67 $00 $68 $00
.db $69 $00 $6A $00 $6B $00 $6C $00 $6D $00 $6E $00 $6F $00 $70 $00
.db $00 $00 $71 $00 $72 $00 $73 $00 $74 $00 $75 $00 $76 $00 $77 $00
.db $78 $00 $79 $00 $7A $00 $00 $00 $70 $02 $7B $00 $7C $00 $7D $00
.db $7E $00 $7F $00 $80 $00 $81 $00 $82 $00 $83 $00 $00 $00 $84 $00
.db $85 $00 $86 $00 $87 $00 $88 $00 $89 $00 $8A $00 $8B $00 $8C $00
.db $8D $00 $00 $00 $8E $00 $8F $00 $90 $00 $91 $00 $92 $00 $93 $00
.db $94 $00 $95 $00 $96 $00 $97
.dsb 9,$00
.db $98 $00 $99 $00 $9A $00 $9B $00 $9C $00 $9D $00 $9E $00 $00 $00

.orga $a782 ; $62782
.section "Mark III logo data" overwrite
MarkIIILogoTilemap:    ; $62782
; Data from 62782 to 627A7 (38 bytes)
.db $01 $02 $01 $02 $01 $02 $03 $04 $00 $05 $06 $03 $04 $07 $08 $09
.db $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $00 $15 $16 $13 $14
.db $17 $18 $19 $1A $1B $1C

; Data from 627A8 to 63F1F (6008 bytes)
MarkIIILogo1bpp:
  .include "Tiles\627a8raw Mark III logo 1bpp.inc"
MarkIIILogo1bppEnd:
.ends
; followed by
.orga $a890 ; $62890
.section "Narrative tilemaps" overwrite
.include "Tilemaps\Portrait tilemaps (raw).inc"
.ends
; .org $63970 more tilemaps?

; Data from 63F20 to 63F4F (48 bytes)
_DATA_63F20_:
.db $2F $08 $30 $08 $30 $0A $2F $0A $39 $08 $3A $08 $3A $0A $39 $0A
.db $43 $08 $44 $08 $44 $0A $43 $0A $4C $08 $4D $08 $4D $0A $4C $0A
.db $55 $08 $56 $08 $56 $0A $55 $0A $5D $08 $5E $08 $5E $0A $5D $0A

; Data from 63F50 to 63F7F (48 bytes)
_DATA_63F50_:
.db $92 $08 $93 $08 $93 $0A $92 $0A $94 $08 $95 $08 $95 $0A $94 $0A
.db $96 $08 $97 $08 $97 $0A $96 $0A $98 $08 $99 $08 $99 $0A $98 $0A
.db $55 $08 $9A $08 $9A $0A $55 $0A $5D $08 $5E $08 $5E $0A $5D $0A

; Data from 63F80 to 63FFF (128 bytes)
_DATA_63F80_:
.db $9B $08 $9C $08 $9C $0A $9B $0A $9D $08 $9E $08 $9E $0A $9D $0A
.db $96 $08 $9F $08 $9F $0A $96 $0A $A0 $08 $A1 $08 $A1 $0A $A0 $0A
.db $55 $08 $A2 $08 $A2 $0A $55 $0A $5D $08 $A3 $08 $A3 $0A $5D $0A
.dsb 80,$FF

;=======================================================================================================
; Bank 25: $64000 - $67fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 25 slot 2
.org 0
.section "Tile data 17" overwrite
TilesShadow:
.incbin "Tiles\64000compr.dat" ; 96
TilesDragon:
.incbin "Tiles\6493bcompr.dat" ; 154
TilesSnake:
.incbin "Tiles\65755compr.dat" ; 141
TilesScorpion:
.incbin "Tiles\664d0compr.dat" ; 53
TilesSkeleton:
.incbin "Tiles\66a4acompr.dat" ; 90
TilesGhoul:
.incbin "Tiles\67326compr.dat" ; 116
.ends
; Fits exactly :P

;=======================================================================================================
; Bank 26: $68000 - $6bfff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 26 slot 2
.org 0
.section "Tile data 18" overwrite
TilesCentaur:
.incbin "Tiles\68000compr.dat" ; 119
TilesIceMan:
.incbin "Tiles\68a1fcompr.dat" ; 129
TilesManticor:
.incbin "Tiles\69748compr.dat" ; 111
TilesManEater:
.incbin "Tiles\6a180compr.dat" ; 52
TilesFishMan:
.incbin "Tiles\6a7b8compr.dat" ; 88
TilesOctopus:
.incbin "Tiles\6b17ecompr.dat" ; 132
.ends
;.org 6bfdc
; Blank until end of slot

;=======================================================================================================
; Bank 27: $6c000 - $6ffff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 27 slot 2
.org 0
.section "Tile data 19" overwrite
.incbin "Tiles\6c000compr.dat" ; 135
.incbin "Tiles\6ce19compr.dat" ; 108
.incbin "Tiles\6d979compr.dat" ; 51
.incbin "Tiles\6df26compr.dat" ; 69
.incbin "Tiles\6e75ecompr.dat" ; 31
.incbin "Tiles\6eb04compr.dat" ; 36
.incbin "Tiles\6ee6ccompr.dat" ; 48
.ends
; followed by
.org $6f40b-$6c000
.section "Menu tilemaps" overwrite
MenuTilemaps:
.include "Tilemaps\Menus.inc"
.ends
; followed by
.org $6fd63-$6c000
.section "Lassic room tilemap" overwrite
TilemapLassicRoom:
.incbin "Tilemaps\6fd63tilemap.dat"
.ends
; Blank until end of slot

;=======================================================================================================
; Bank 28: $70000 - $73fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 28 slot 2
.orga $8000
.section "Character sprites" overwrite
CharacterSprites:
AlisSprites:
.include "Tiles\70000 Alis sprites.inc"
LutzSprites:
.include "Tiles\70a80 Lutz sprites.inc"
OdinSprites:
.include "Tiles\71440 Odin sprites.inc"
MyauSprites:
.include "Tiles\71ec0 Myau sprites.inc"
.ends
; followed by
.org $726c0-$70000
.section "Tilemap data 7" overwrite
.incbin "Tilemaps\726C0tilemap.dat" ; Dungeon...
.incbin "Tilemaps\72935tilemap.dat"
.incbin "Tilemaps\72BD0tilemap.dat"
.incbin "Tilemaps\72EC9tilemap.dat"
.incbin "Tilemaps\7320Ctilemap.dat"
.incbin "Tilemaps\735C2tilemap.dat"
.incbin "Tilemaps\7395Atilemap.dat"
.ends
; followed by
.orga $bd00
.section "Space tilemaps" overwrite
; interplanetary travel - 12 lines per tilemap
TilemapTopPlanet:
.incbin "Tilemaps\73D00tilemap.dat" ; top planet
TilemapSpace:          ; $73e00
.incbin "Tilemaps\73E00tilemap.dat" ; space
TilemapBottomPlanet:   ; $73e88
.incbin "Tilemaps\73E88tilemap.dat" ; bottom planet
.ends
;.org $73f96
; Blank until end of slot

;=======================================================================================================
; Bank 29: $74000 - $77fff
;=======================================================================================================
.bank 29 slot 2
.ORG $0000

; Data from 74000 to 747B7 (1976 bytes)
.incbin "Phantasy Star (Japan)_DATA_74000_.inc"

.org $747b8-$74000
.section "Tile data 20" overwrite
TilesOutside:
.incbin "Tiles\747b8compr.dat"
NarrativeGraphicsOdin:
.db $00,$00,$3F,$01,$02,$03,$0B,$0F,$30,$2F,$06,$0A,$2A,$25,$38,$20 ; palette
.incbin "Tiles\7763acompr.dat"
.ends
;.org 77f46
; Blank until end of bank

;=======================================================================================================
; Bank 30: $78000 - $7bfff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 30 slot 2
.org 0
.section "Tile data 21" overwrite
NarrativeGraphicsIntroNero2:
.db $00,$00,$3F,$34,$38,$03,$0B,$01,$2B,$2F,$06,$2A,$25,$3E,$20,$36 ; palette
.incbin "Tiles\78010compr.dat" ; 132 Intro
NarrativeGraphicsIntroAlis:
.db $00,$00,$3F,$30,$3C,$03,$01,$0F,$2B,$0B,$06,$2A,$25,$2F,$37,$30 ; palette
.incbin "Tiles\78f72compr.dat" ; 109 Alisa in intro
NarrativeGraphicsAlis:
.db $00,$00,$3F,$30,$3C,$03,$01,$0F,$2B,$0B,$06,$2A,$25,$2F,$37,$2C ; palette
.incbin "Tiles\79c3bcompr.dat" ; 124 Alisa portrait
NarrativeGraphicsMyauWings1:
.db $00,$00,$3F,$2F,$0F,$0B,$2B,$06,$3F,$3E,$1E,$1D,$2C,$3C,$3E,$00 ; palette
.incbin "Tiles\7aa5ecompr.dat" ; 91 Myau
NarrativeGraphicsMyauWings2:
.db $00,$00,$3F,$2F,$0F,$0B,$2B,$06,$3C,$3A,$04,$3E,$38,$00,$00,$38 ; palette
.incbin "Tiles\7b31ccompr.dat" ; 122 Myau with wings
.ends
;.org 7bfde
; Blank until end of bank

;=======================================================================================================
; Bank 31: $7c000 - $7ffff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 31 slot 2
.org 0
.section "Tile data 22" overwrite
NarrativeGraphicsIntroNero1:
.db $00,$00,$3F,$34,$38,$03,$0B,$01,$2B,$2F,$06,$2A,$25,$3E,$20,$36 ; palette
.incbin "Tiles\7c010compr.dat" ; 100 intro
NarrativeGraphicsMyau:
.db $00,$00,$3F,$2F,$0F,$0B,$2B,$06,$08,$0C,$2C,$3E,$38,$20,$34,$28 ; palette
.incbin "Tiles\7CAEBcompr.dat" ; 118 Myau
_DATA_7D676_:
.db $30,$00,$3F,$38,$3E,$27,$01,$0F,$2B,$0B,$06,$2A,$25,$2F,$3B,$3C ; palette
.db $30 ; ???
; Data from 7D687 to 7E8BC (4662 bytes)
_DATA_7D687_:
.incbin "Tiles\7d687compr.dat" ; 159 ending picture
TilesTitleScreen:      ; $7e8bd
.incbin "Tiles\7E8BDcompr Title screen tiles.dat" ; 256 title
.ends
; to end :)

.smsheader ; for checksum
.endsms
