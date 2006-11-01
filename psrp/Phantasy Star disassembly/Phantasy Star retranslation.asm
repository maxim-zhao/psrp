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

;=======================================================================================================
; Load original as base
;=======================================================================================================
.BACKGROUND "Phantasy Star (jp).sms"

;=======================================================================================================
; Memory:
;=======================================================================================================

.define HasFM                     $c000     ; b 01 if YM2413 detected, 00 otherwise

; $c002, $c003-$c00d                  ; sound engine

.define NewMusic                  $c004     ; b Which music to start playing

.define VDPReg0                   $c200     ; b Contents of VDP register 0
.define VDPReg1                   $c201     ; b Contents of VDP register 1
.define FunctionLookupIndex       $c202     ; b Index to lookup in FunctionLookup table

.define ControlsNew               $c204     ; b Buttons just pressed (1 = pressed) \ Must be
.define Controls                  $c205     ; b All buttons pressed (1 = pressed)  / together

.define VBlankFunctionIndex       $c208     ; b Index of function to execute in VBlank
.define IsJapanese                $c209     ; b 00 if Japanese, ff if Export
.define IsNTSC                    $c20a     ; b 00 if PAL, ff if NTSC
.define ResetButton               $c20b     ; b Reset button state: %00010000 unpressed %00000000 pressed

.define MarkIIILogoDelay          $c20e     ; w Counter for number of frames to wait on Mark III logo
.define TileMapHighByte           $c210     ; b High byte to use when writing low-byte-only tile data to tilemap
.define Mask1BitOutput            $c211     ; b Mask used by 1bpp tile output code
.define PauseFlag                 $c212     ; b Pause flag $ff=pause/$00=not
.define PaletteMoveDelay          $c213     ; b Counter used to slow down palette changes (Mark III logo, water sparkles, ???)
.define PaletteMovePos            $c214     ; b Current position in above palette changes (must follow)

.define NextSpriteY               $c217     ; w Pointer to next free sprite Y position in SpriteTable
.define NextSpriteX               $c219     ; w Pointer to next free sprite X position in SpriteTable
.define PaletteFadeControl        $c21b     ; b Palette fade control:
                                            ;   bit 7 1 = fade in, 0 = fade out
                                            ;   lower bits = counter, should go 9->0
                                            ; Must be followed by:
.define PaletteSize               $c21c     ; b counter for number of entries in TargetPalette
.define PaletteFadeFrameCounter   $c21d     ; b Palette fade frame counter

.define ActualPalette             $c220     ; 32 bytes Actual palette (when fading)
.define TargetPalette             $c240     ; 32 bytes Target palette

.define xc260                     $c260     ; w ???
.define xc262                     $c262     ; b ??? Page
.define xc263                     $c263     ; b ??? Scrollingtilemap data page(?)
.define ScrollDirection           $c264     ; b Scroll direction; %----RLDU
.define PaletteRotateEnabled      $c265     ; b Palette rotation enabled if non-zero

.define CursorEnabled             $c268     ; b $ff if cursor showing, $00 otherwise
.define CursorTileMapAddress      $c269     ; w Address of low byte of top cursor position in tilemap
.define CursorPos                 $c26b     ; b How many rows to shift cursor down
.define OldCursorPos              $c26c     ; b Last position
.define CursorCounter             $c26d     ; b Counter for flashing
.define CursorMax                 $c26e     ; b Maximum value for cursor
.define OutsideAnimCounters       $c26f     ; 24 (6x4) bytes -> c287, counter structures for outside tile animations:
                                            ; +0: Enabled     00/01
                                            ; +1: ResetValue  Reset value of counter
                                            ; +2: CountDown   Counted down to 0 and then reset
                                            ; +3: Counter     Counted up or down at each reset
.define xc289Pointer              $c287     ; w Pointer into following
.define xc289                     $c289     ; 16 (2*8) bytes -> c299, array of 2-byte entries - list of multi-sprite "entities"?

.define SceneType                 $c29e     ; b Scene characteristics; controls which animation to do (? and others)
                                            ;   1-32

.define AnimDelayCounter          $c2bc     ; b Counter for tile animation effects - delay between frames - must be followed by:
.define AnimFrameCounter          $c2bd     ; b Counter for tile animation effects - frame #
.define PaletteFlashFrames        $c2be     ; b Number of frames over which to flash palette to white

.define PaletteFlashCount         $c2c0     ; b Number of palette entries to set to white
.define PaletteFlashStart         $c2c1     ; b First palette entry to set to white
.define xc2c2                     $c2c2     ; b ???

.define xc2c4                     $c2c4     ; b ???
.define NumberToShowInText        $c2c5     ; w 16-bit int to output for text code $52

.define xc2c8                     $c2c8     ; 8+ bytes Buffer for text output

.define TextBox20x6Open           $c2d3     ; b 20x6 text box open

.define xc2d5                     $c2d5     ; b ???
.define SceneAnimEnabled          $c2d6     ; b Enemy scene animations only happen when non-zero

.define xc2d9                     $c2d9     ; w ???

.define xc2e5                     $c2e5     ; b ???

.define xc2e9                     $c2e9     ; b ???
.define xc2ea                     $c2ea     ; b ???

.define CurrentlyPlayingMusic     $c2f4     ; b Currently playing music number

.define GameData                  $c300     ; 1024 bytes -> $c700 All data saved/loaded from SRAM
.define HScroll                   $c300     ; b Horizontal scroll
.define HLocation                 $c301     ; w Horizontal location in map

.define VScroll                   $c304     ; b Vertical scroll
.define VLocation                 $c305     ; w Vertical location on map - skips parts

.define ScrollScreens             $c307     ; b Counted down when scrolling down in intro
.define xc308                     $c308     ; b Type of current "world"???
.define xc309                     $c309     ; b Current "world"???


.define xc30e                     $c30e     ; b ??? used by palette rotation but could be more
.define PaletteRotatePos          $c30f     ; b Palette rotation position
.define PaletteRotateCounter      $c310     ; b Palette rotation delay counter
.define xc311                     $c311     ; w?

.define xc313                     $c313     ; w ??? Related to HLocation?
.define xc315                     $c315     ; b ???
.define xc316                     $c316     ; b ???

.define CharacterStats            $c400     ; 64 (4 x 16) bytes -> $c43f Character attributes:
                                            ; +0: b alive 00/01
                                            ; +1: b HP
                                            ; +2: b MP
                                            ; +3: w EP
                                            ; +5: b LV
                                            ; +6: b Max HP
                                            ; +7: b Max MP
                                            ; +8: b Attack
                                            ; +9: b Defence
                                            ; +a: Weapon \  These 3 are bytes values
                                            ; +b: Armour  | from the same list.
                                            ; +c: Shield /
                                            ; +d: ???
                                            ; +e: Number of magics known (?) <5
                                            ; +f: ???
.define CharacterStatsAlis        $c400
.define CharacterStatsMyau        $c410
.define CharacterStatsOdin        $c420
.define CharacterStatsNoah        $c430

.define xc4e0                     $c4e0     ; ?

.define xc600                     $c600     ; ?

.define xc604                     $c604     ; ?

.define CharacterSpriteAttributes $c800     ; 256 (8 x 32) bytes -> $c8ff Character sprite attributes:
                                            ; +0: character number? Affects +1
                                            ; +1: character number? - 0 = empty, 1 = Alis, 2 = Noah, 3 = Odin, 4 = Myau, 5 = vehicle
                                            ; +2: sprite base y
                                            ; +4: sprite base x
                                            ; +16: currentanimframe
                                            ; +17: lastanimframe
                                            ; First 4 are main characters, other 4 are ???

.define SpriteTable               $c900     ; 256 bytes -> $ca00 , copy of sprite table for rapid writing to VDP

.define xcc00                     $cc00     ; 192 bytes? Areas for decompression of data
.define xcd00                     $cd00     ;
.define xce00                     $ce00     ;
.define xcf00                     $cf00     ;

.define TileMapData               $d000     ; 1792 bytes -> $d700 RAM copy of the tilemap

.define OldTileMap20x6            $da18     ; 240 bytes -> $db08 RAM copy of old tilemap for 20x6 box
.define OldTileMap20x6Scroll      $db08     ; 108 bytes -> $db74 RAM copy of old tilemap for 18x3 box (for text scrolling in 20x6 box)
                                            ; could use previous area???

.define OldTileMap5x5             $de64     ; 50 bytes -> $de96  RAM copy of old tilemap for 5x5 box

.define Port3EVal                 $df00     ; b Last value written to port $3e (IO control)
.define xdf01                     $df01     ; b ???

;=======================================================================================================
; SRAM:
;=======================================================================================================
.define SRAMIdent                 $8000     ; 64 bytes Marker for checking for SRAM corruption

.define x8100                     $8100     ; 216 bytes ??? Tilemap?

.define SRAMSlotsUsed             $8201     ; 5 bytes 00 = slot empty, 01 = slot used

.define SaveGameSlots             $8400     ; 1024 x 5 = 5120 bytes -> $9800
                                            ; Copy to/from GameData when loading/saving

;=======================================================================================================
; Other game-specific stuff:
;=======================================================================================================

.enum $81
MusicTitle       db ; 81
MusicPalma       db ; 82
MusicMotavia     db ; 83
MusicDezoris     db ; 84
MusicBossDungeon db ; 85
MusicCave        db ; 86
MusicTown        db ; 87
MusicVillage     db ; 88
MusicBattle      db ; 89
MusicStory       db ; 8a
MusicEnding      db ; 8b
MusicIntro       db ; 8c
MusicChurch      db ; 8d
MusicShop        db ; 8e
MusicVehicle     db ; 8f
MusicMedusa      db ; 90
MusicLassic      db ; 91
MusicDarkForce   db ; 92
MusicGameOver    db ; 93
.ende
.define MusicStop $d7
; $b8 = ?

;=======================================================================================================
; Macros:
;=======================================================================================================

.macro SetPage ; sets slot 2 for access to label given as parameter
  ld hl,Frame2Paging
  ld (hl),:\1
.endm

.macro TileAddressDE ; sets de to the VRAM address of tile n
  ld de,$4000 + (\1*32)
.endm

.macro TileMapAddressDE ; sets de to the VRAM tilemap address of tile x,y
  ld de,TileMapAddress+(32*\2+\1)*2
.endm

.macro TileMapAddressHL ; sets hl to the VRAM tilemap address of tile x,y
  ld hl,TileMapAddress+(32*\2+\1)*2
.endm

.macro SceneDataStruct ; structure holding scene data (palette, tiles and tilemap offsets)
.db :Palette\1
.dw Palette\1,Tiles\2
.db :Tilemap\3
.dw Tilemap\3
.endm

.macro PortraitGraphicsData
.db :PortraitGraphics\1
.dw PortraitGraphics\1,PortraitTilemap\1
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
.define FMDetect        $f2 ; r/w
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

.unbackground $00b9 $00cb
.orga $00b9
.section "Remove delay/country test" force
    ld a,0             ; Set to Japanese
    ld (IsJapanese),a
    jp $00cb
.ends

.unbackground $043c $045d-1 ; Remove Mark III logo stuff
.unbackground $01d3 $01eb-1
.unbackground $0689 $073f-1
.unbackground $62782 $6288f


/*
VBlankFunctionTable:   ; $01bb                         enemy scene                 refresh
; Referenced by even numbers only       scroll sprites tile effects controls sound tilemap special
.dw VBlankFunction_SoundOnly        ; 0                                        Y
.dw VBlankFunction_MarkIIIFadeIn    ; 2           Y                    Y                   Mark III logo fade and delay
.dw VBlankFunction_SoundOnly        ; 4                                        Y
.dw VBlankFunction_MarkIIIFadeIn    ; 6           Y                    Y                   Mark III logo fade and delay
.dw VBlankFunction_Menu             ; 8    Y      Y         Y          Y       Y           Cursor
.dw VBlankFunction_Enemy            ; a    Y      Y         Y                  Y
.dw VBlankFunction_UpdateTilemap    ; c                                        Y    Y(28)
.dw VBlankFunction_OutsideScrolling ; e    Y      Y                    Y       Y           Palette rotation, character/vehicle sprite animation, scrolling tilemap, outside scene tile animations
.dw VBlankFunction_10               ; 10   Y      Y                            Y    Y(24)  Output palette
.dw VBlankFunction_12               ; 12   Y      Y                            Y    Y(28)  Output palette
.dw VBlankFunction_TurnOnDisplay    ; 14
.dw VBlankFunction_PaletteEffects   ; 16   Y      Y         Y                  Y           Flash palette, fade palette
.ends*/

