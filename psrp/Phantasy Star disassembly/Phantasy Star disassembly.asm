;=======================================================================================================
; Phantasy Star disassembly/retranslation
;=======================================================================================================
; by Maxim
; This aims to be a disassembly of Phantasy Star (jp)
; with comments describing what's going on as much as possible
; defines, macros, labels etc to make it cleaner
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

;=======================================================================================================
; Load original as base
;=======================================================================================================
.background "PS1-J.sms"
;.background "blank.dat"

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
.define RandomNumberGeneratorWord $c20c     ; w Used for random number generator
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

.define xc258                     $c258     ; 8 bytes? ??? RAM re-used for enemy scenes as well as scrolling scenes?

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

.define xc29d                     $c29d     ; b ???

.define AnimDelayCounter          $c2bc     ; b Counter for tile animation effects - delay between frames - must be followed by:
.define AnimFrameCounter          $c2bd     ; b Counter for tile animation effects - frame #
.define PaletteFlashFrames        $c2be     ; b Number of frames over which to flash palette to white

.define PaletteFlashCount         $c2c0     ; b Number of palette entries to set to white
.define PaletteFlashStart         $c2c1     ; b First palette entry to set to white
.define TextCharacterNumber       $c2c2     ; b Which number character (0-3) to write the name of when encountering text code $4f

.define ItemTableIndex            $c2c4     ; b Index into item table for text display
.define NumberToShowInText        $c2c5     ; w 16-bit int to output for text code TextNumber=$52
.define NumEnemies                $c2c7     ; b counter for number of enemies
.define EnemyName                 $c2c8     ; 8 bytes -> $c2d0 8 character enemy name

.define xc2d0                     $c2d0     ; w ??? result of NumEnemies*(something)
.define xc2d2                     $c2d2     ; b ???
.define TextBox20x6Open           $c2d3     ; b 20x6 text box open

.define xc2d5                     $c2d5     ; b ???
.define SceneAnimEnabled          $c2d6     ; b Enemy scene animations only happen when non-zero
.define xc2d7                     $c2d7     ; b ???

.define xc2d9                     $c2d9     ; w ???

.define xc2dd                     $c2dd     ; w ??? result of numenemies*(something)
.define xc2df                     $c2df     ; b ???
.define xc2e0                     $c2e0     ; b ???
.define xc2e1                     $c2e1     ; w ??? might be 2*b

.define xc2e5                     $c2e5     ; b ???
.define EnemyNumber               $c2e6     ; b Enemy number - index into EnemyData
.define xc2e7                     $c2e7     ; b ???
.define xc2e8                     $c2e8     ; b ???
.define xc2e9                     $c2e9     ; b ???
.define xc2ea                     $c2ea     ; b ???
.define xc2eb                     $c2eb     ; b ???

.define xc2f2                     $c2f2     ; w ???
.define CurrentlyPlayingMusic     $c2f4     ; b Currently playing music number

.define GameData                  $c300     ; 1024 bytes -> $c700 All data saved/loaded from SRAM
.define HScroll                   $c300     ; b Horizontal scroll
.define HLocation                 $c301     ; w Horizontal location in map

.define VScroll                   $c304     ; b Vertical scroll
.define VLocation                 $c305     ; w Vertical location on map - skips parts

.define ScrollScreens             $c307     ; b Counted down when scrolling between planets/in intro
.define xc308                     $c308     ; b Type of current "world"???
.define xc309                     $c309     ; b Current "world"???


.define xc30e                     $c30e     ; b ??? used by palette rotation but could be more
.define PaletteRotatePos          $c30f     ; b Palette rotation position
.define PaletteRotateCounter      $c310     ; b Palette rotation delay counter
.define xc311                     $c311     ; w ??? Related to VLocation
.define xc313                     $c313     ; w ??? Related to HLocation
.define xc315                     $c315     ; b ???
.define xc316                     $c316     ; b Backup of FunctionLookupIndex?

.define CharacterStats            $c400     ; 192 (12 x 16) bytes -> $c4c0 Character attributes:
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
.define CharacterStatsEnemies     $c440     ; Enemy character stats x 8

.define xc4e0                     $c4e0     ; ?
.define xc4f0                     $c4f0     ; ?

.define xc600                     $c600     ; ?

.define xc604                     $c604     ; ?

.define NameEntryMode             $c780     ; b 0 = name entry, 1 = password entry (not used)
.define NameEntryData             $c781     ; nn bytes: block used for name entry
.define NameEntryCharIndex        $c781     ; b current char is $c7nn

.define NameEntryCursorX          $c784     ; b sprite X coordinate for char selection cursor
.define NameEntryCursorY          $c785     ; b sprite Y coordinate for char selection cursor
.define NameEntryCursorTileMapDataAddress $c786 ; w address of TileMapData byte corresponding to the current cursor position
.define NameEntryCurrentlyPointed $c788     ; b value currently being pointed at by the cursor
.define NameEntryKeyRepeatCounter $c789     ; b counter for key repeat - delay before faster repeat

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

.define xd724                     $d724     ;  384 bytes -> $d8a4 RAM copy of old tilemap for ???
.define OldTileMapMenu            $d8a4     ;  132 bytes -> $d928 RAM copy of old tilemap for menu
.define OldTileMapEnemyName10x4   $d928     ;   80 bytes -> $d978 RAM copy of old tilemap for 10x4 box for enemy name
.define OldTileMapEnemyStats8x10  $d978     ;  160 bytes -> $d9c8 RAM copy of old tilemap for 8x10 box for enemy stats

.define OldTileMap20x6            $da18     ;  240 bytes -> $db08 RAM copy of old tilemap for 20x6 box
.define OldTileMap20x6Scroll      $db08     ;  108 bytes -> $db74 RAM copy of text tilemap for 18x3 box (for text scrolling in 20x6 box)

.define OldTileMap5x5             $de64     ;   50 bytes -> $de96  RAM copy of old tilemap for 5x5 box

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
MusicMotabia     db ; 83
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

.macro SetVRAMAddressToDE
  rst $8
.endm

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

.macro TileMapAreaBC ; sets b to y and c to 2*x for use with InputTilemapRect
  ld bc,(\2*256) + (\1*2)
.endm

.macro PageAndOffset
.db :\1
.dw \1
.endm

.macro SceneDataStruct ; structure holding scene data (palette, tiles and tilemap offsets)
.db :Palette\1
.dw Palette\1,Tiles\2
.db :Tilemap\3
.dw Tilemap\3
.endm

.macro NarrativeGraphicsData
.db :NarrativeGraphics\1
.dw NarrativeGraphics\1,NarrativeTilemap\1
.endm

.macro ldbc args bval,cval
  ld bc,((bval << 8) & $ff00) | ( cval & $ff )
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
; colours
.enum $00
cl000 db
cl100 db
cl200 db
cl300 db
cl010 db
cl110 db
cl210 db
cl310 db
cl020 db
cl120 db
cl220 db
cl320 db
cl030 db
cl130 db
cl230 db
cl330 db
cl001 db
cl101 db
cl201 db
cl301 db
cl011 db
cl111 db
cl211 db
cl311 db
cl021 db
cl121 db
cl221 db
cl321 db
cl031 db
cl131 db
cl231 db
cl331 db
cl002 db
cl102 db
cl202 db
cl302 db
cl012 db
cl112 db
cl212 db
cl312 db
cl022 db
cl122 db
cl222 db
cl322 db
cl032 db
cl132 db
cl232 db
cl332 db
cl003 db
cl103 db
cl203 db
cl303 db
cl013 db
cl113 db
cl213 db
cl313 db
cl023 db
cl123 db
cl223 db
cl323 db
cl033 db
cl133 db
cl233 db
cl333 db
.ende

;=======================================================================================================
; Bank 0: $0000 - $3fff
;=======================================================================================================
.bank 0 slot 0

.org $0000
.section "Boot handler" overwrite
    di
    im 1
    ld sp,$cb00
    jr Start
.ends
; followed by
.orga $0008
.section "SetVRAMAddressToDE() @ vector $0008" overwrite
; Outputs de to VRAM address port
; rst $08 / rst 08h
    ld a,e
    out (VDPAddress),a
    ld a,d
    out (VDPAddress),a
    ret
.ends
; followed by
.orga $0038
.section "IRQ handler" overwrite
    push af
    in a,(VDPStatus)
    or a
    jp p,IRQ_NotVBlank ; bit 7 not set
    jp VBlank          ; otherwise -> VBlank
.ends
; followed by
.section "Display enable/disable" overwrite
TurnOffDisplay:        ; $0042
    ld a,(VDPReg1)
    and $bf            ; Remove display enable bit
    jr +
TurnOnDisplay:         ; $0049
    ld a,(VDPReg1)
    or $40             ; Set display enable bit
  +:ld (VDPReg1),a
    ld e,a
    ld d,VDPReg_1
    SetVRAMAddressToDE
    ret
.ends
; followed by
.section "Execute function index a in next VBlank" overwrite
ExecuteFunctionIndexAInNextVBlank ; $0056
; Sets VBlankFunctionIndex to a and waits for it to be processed
    ld (VBlankFunctionIndex),a
  -:ld a,(VBlankFunctionIndex)
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
        cp $0b
        jr z,+
        cp $0d
        jr nz,++
      +:ld a,(PauseFlag)   ; If FunctionLookupIndex is 5, 9, 11 or 13 then invert all bits of PauseFlag
        cpl
        ld (PauseFlag),a
 ++:pop af
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
    ld bc,$1eff
    ld (hl),$00
    ldir

    call CountryDetection
    or a               ; is it export?
    jr nz,+            ; if so, skip next bit

    ld b,$02           ; ############# delay by counting down $20000
  -:ld de,$ffff        ; #############
 --:dec de             ; #############
    ld a,d             ; #############
    or e               ; #############
    jr nz,--           ; #############
    djnz -             ; #############

  +:call SoundInit     ; Initialise sound engine
    call FMDetection   ; FM detection
    call SRAMCheck     ; SRAM check/initialisation
    call VDPInitRegs   ; Initialise VDP registers
    call NTSCDetection ; NTSC detection
    ei

  -:ld hl,FunctionLookupIndex
    ld a,(hl)          ; Get value in FunctionLookupIndex (initialised to 0)
    and $1f            ; Strip to low 5 bits
    ld hl,FunctionLookupTable
    call FunctionLookup
    jp -

FunctionLookupTable:
.dw LoadMarkIIILogo           ; 0 $06a0
.dw FadeInMarkIIILogoAndPause ; 1 $0689
.dw StartTitleScreen          ; 2 $08b7
.dw TitleScreen               ; 3 $073f --+
.dw fn0bb8                    ; 4         |
.dw fn9cb                     ; 5 *       |
.dw DoNothing                 ; 6         |
.dw DoNothing                 ; 7         |
.dw LoadScene                 ; 8       <-+
.dw fn0c64                    ; 9 *
.dw $10d9                     ; a
.dw $1098                     ; b *
.dw $3d76                     ; c
.dw $3cc0                     ; d *
.dw $1033                     ; e
.dw $0fe7                     ; f
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
  -:ld a,(PauseFlag)
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
                                  ; so result = 1 if button just pushed, 0 otherwise
                jp nz,ResetPoint

                ld a,(IsNTSC)
                or a
                jp nz,+
                ld b,$00          ; delay if not NTSC (why?) ###########
              -:djnz -
              -:djnz -
              +:ld a,(PauseFlag)
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

VBlank_LookupEnd:                 ; $16f
                xor a             ; zero
                ld (VBlankFunctionIndex),a
 VBlank_End:pop af                ; restore backed-up paging regs
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
VBlankFunction_TurnOnDisplay: ; $0185
    call TurnOnDisplay
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: palette effects" overwrite
; scroll, sprites, palette effects, tile effects, sound
VBlankFunction_PaletteEffects: ; $018b
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
    SetVRAMAddressToDE
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
.dw VBlankFunction_OutsideScrolling ; e    Y      Y                    Y       Y           Palette rotation, character/vehicle sprite animation, scrolling tilemap, outside scene tile animations
.dw VBlankFunction_10               ; 10   Y      Y                            Y    Y(24)  Output palette
.dw VBlankFunction_12               ; 12   Y      Y                            Y    Y(28)  Output palette
.dw VBlankFunction_TurnOnDisplay    ; 14
.dw VBlankFunction_PaletteEffects   ; 16   Y      Y         Y                  Y           Flash palette, fade palette
.ends
; followed by
.section "VBlank function: Mark III logo fade in" overwrite
VBlankFunction_MarkIIIFadeIn: ; $01d3
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
VBlankFunction_SoundOnly: ; $01eb
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: enemy scene with cursor" overwrite
; scroll, sprites, tile effects, controls, cursor, sound
VBlankFunction_Menu:   ; $01f1
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
; followed by
.section "VBlank function: enemy encounter" overwrite
; scroll, sprites, tile effects, sound
VBlankFunction_Enemy: ; $0215
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
; scroll, fill tilemap from RAM, sound
VBlankFunction_UpdateTilemap: ; $0233
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
    call outi128       ; output 896 bytes = 14 rows of tile numbers, quickly
    ld a,$03           ; Count $380 = 896 more bytes
    ld b,$80
  -:outi               ; and output another 14 rows, but more slowly
    jp nz,-
    dec a
    jp nz,-
    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: outside/scrolling scene" overwrite
; scroll, sprites, palette rotation, character/vehicle sprite animation, scrolling tilemap, outside scene tile animations, controls, sound
VBlankFunction_OutsideScrolling: ; $0279
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
; followed by
.section "VBlank function: enemy in dungeon?" overwrite
; scroll, sprites, palette, output 24 rows of tilemap from RAM, sound
VBlankFunction_10;     ; $02a3
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
    SetVRAMAddressToDE
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
  -:outi               ; output
    jp nz,-
    dec a
    jp nz,-

    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank function: update full tilemap..?" overwrite
; scroll, sprites, palette, output 28 rows of tilemap from RAM, sound
VBlankFunction_12:     ; $02e3
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
    SetVRAMAddressToDE
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
  -:outi               ; output
    jp nz,-
    dec a
    jp nz,-

    call redirectSoundUpdate
    jp VBlank_LookupEnd
.ends
; followed by
.section "VBlank paused handler" overwrite
VBlank_Paused:         ; $0323
    ; this seems a bit messy, maybe clear it up later? ##########
    call SilenceChips
    jp VBlank_End
.ends
; followed by
.section "Sound update redirector" overwrite
redirectSoundUpdate:   ; $0329
    SetPage SoundUpdate
    jp SoundUpdate
.ends
; followed by
.section "Init sound engine redirector" overwrite
SoundInit:             ; $0331
    SetPage SoundInitialise
    jp SoundInitialise
.ends
; followed by
.section "Silence chips sound engine redirector" overwrite
SilenceChips:          ; $0339
    SetPage SilencePSGandFM
    jp SilencePSGandFM
.ends
; followed by
.section "Non-VBlank IRQ handler" overwrite
IRQ_NotVBlank:         ; $0341
    pop af             ; ################### not used?
    ei
    ret
.ends
; followed by
.section "Clear sprite table" overwrite
ClearSpriteTableAndFadeInWholePalette: ; $0344
    ld hl,SpriteTable  ; Fill SpriteTable y positions with 224 to disable sprites
    ld de,SpriteTable+1
    ld bc,64
    ld (hl),$e0
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
CountryDetection:      ; $035f
    ; Original code
    ld a,$f5
    out (IOControl),a  ; $f5 -> (IOControl)
    in a,(IOPort2)     ; (IOPort2) -> a
    and $c0
    cp  $c0            ; Check value that came back
    jr nz,+
    ld a,$55
    out (IOControl),a  ; $55 -> (IOControl)
    in a,(IOPort2)     ; (IOPort2) -> a
    and $c0
    or a               ; Check value that came back
    jr nz,+
    ld a,$ff           ; Japanese system detected
    out (IOControl),a  ; Reset IOControl
    ld (IsJapanese),a  ; Save to RAM ($ff)
    ret
  +:xor a              ; Export system detected
    ld (IsJapanese),a  ; Save to RAM ($00)
    ret
.ends
; followed by
.section "NTSC detection" overwrite
NTSCDetection:         ; $0383
    ld hl,$0000
  -:in a,(VDPStatus)   ; Check VDP status      ; 000386 DB BF
    or a
    jp p,-             ; Wait for bit 7 (VSync) to be 0
  -:in a,(VDPStatus)
    or a
    jp p,-             ; Again
  -:inc hl             ; Now count up in hl
    in a,($bf)
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
FMDetection:           ; $03a4
    ld a,(Port3EVal)
    or $04             ; Disable IO chip
    out (MemoryControl),a
    ldbc 7,0           ; Counter (7 -> b), plus 0 -> c
  -:ld a,b
    and $01
    out (FMDetect),a   ; Output 0/1 lots of times
    ld e,a
    in a,(FMDetect)
    and $07            ; Mask off high bits
    cp e               ; Compare to what was written
    jr nz,+
    inc c              ; c = # of times out==in
  +:djnz -
    ld a,c
    cp $07             ; if out==in 7 times then I must have a YM2413!
    jr z,+
    xor a              ; 0 -> a
  +:and $01            ; Strip to bit 0
    out (FMDetect),a   ; Output $01 if YM2413 and $00 otherwise
    ld (HasFM),a       ; Store that in HasFM
    ld a,(Port3EVal)
    out (MemoryControl),a  ; Turn IO chip back on
    ret
.ends
; followed by
.section "Get controller input" overwrite
GetControllerInput:    ; $03d1  
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
OutputToVRAM:          ; $03de
    SetVRAMAddressToDE
    ld a,c
    or a
    jr z,+
    inc b
  +:ld a,b
    ld b,c
    ld c,VDPData
  -:outi
    jp nz,-
    dec a
    jp nz,-
    ret
.ends
; followed by
.section "Fill VRAM" overwrite
ClearTileMap:          ; $03f2
    ld de,TileMapAddress
    ld bc,32*28        ; number of words
    ld hl,$0000        ; value to fill with
    ; fall through
FillVRAMWithHL:        ; $03fb
; Fills bc words of VRAM from de with hl
    SetVRAMAddressToDE
    ld a,c
    or a               ; if c!=0 then inc b to make it loop over the right number
    jr z,_f
    inc b
 __:ld a,l             ; output hl to VDPData
    out (VDPData),a
    push af
    pop af
    ld a,h
    out (VDPData),a
    dec c              ; Decrement counter c
    jr nz,_b
    djnz _b
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
OutputTilemapRawBxC:   ; $040f
  -:push bc
        SetVRAMAddressToDE
        ld b,c
        ld c,VDPData
     --:outi           ; out (c),(hl); dec b; inc hl
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
OutputTilemapRawDataBox: ; $0428
  -:push bc
        SetVRAMAddressToDE
        ld b,c
        ld c,VDPData
     --:outi           ; out (c),(hl); dec b; inc hl
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
Output1BitGraphics:    ; $043c
    ld (Mask1BitOutput),a ; a -> Mask1BitOutput
    SetVRAMAddressToDE
 --:ld a,(hl)          ; get data at (hl)
    exx                ; swap bc,de,hl with mirrors
        ld c,VDPData
        ld b,$04
        ld h,a             ; backup data
        ld a,(Mask1BitOutput) ; get back original a
      -:rra                ; rotate right through carry
        ld d,h             ; get data back - could have put it there in the first place ##########
        jr c,+             ; if rotate went into carry
        ld d,$00           ; then keep it, else zero
      +:out (c),d          ; output to VDP
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
    ld a,(_VDPData+2)
    ld (VDPReg1),a
    ret
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
_VDPDataEnd:
.ends
; followed by
.section "Tile loader (4 bpp RLE, no di/ei)" overwrite
; Decompresses tile data from hl to VRAM address de
LoadTiles4BitRLENoDI:  ; $0486  
    ld b,$04
  -:push bc
        push de
            call + ; called 4 times for 4 bitplanes
        pop de
        inc de
    pop bc
    djnz -
    ret
  +:
 --:ld a,(hl)          ; read count byte <----+
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
  -:SetVRAMAddressToDE ; <------------------+ |
    ld a,(hl)          ; Get data byte in a | |
    out (VDPData),a    ; Write it to VRAM   | |
    jp z,+             ; If z flag then  -+ | |
                       ; skip inc hl      | | |
    inc hl             ;                  | | |
                       ;                  | | |
  +:inc de             ; Add 4 to de <----+ | |
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
  -:push bc
        push de
            call +
        pop de
        inc de
    pop bc
    djnz -
    ret
 --:
  +:ld a,(hl)          ; header byte
    inc hl             ; data byte
    or a
    ret z              ; exit at zero terminator
    ld c,a             ; c = header byte
    and $7f
    ld b,a             ; b = count
    ld a,c
    and $80            ; z flag = high bit
  -:di
      SetVRAMAddressToDE
      ld a,(hl)
      out (VDPData),a    ; output data
    ei
    jp z,+             ; if z flag then don't move to next data byte
    inc hl
  +:inc de             ; move target forward 4 bytes
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
  +:add hl,hl          ; repeat for 8 bits
.endr
/* ie:
    jr nc,+
    add hl,de          ; if a bit is carried then add de
  +:add hl,hl          ; repeat for 8 bits
    jr nc,+
    add hl,de
  +:add hl,hl
    jr nc,+
    add hl,de
  +:add hl,hl
    jr nc,+
    add hl,de
  +:add hl,hl
    jr nc,+
    add hl,de
  +:add hl,hl
    jr nc,+
    add hl,de
  +:add hl,hl
    jr nc,+
    add hl,de
  +:add hl,hl
*/
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
    rl d               ; de<<=1, also copy carry into low bit of de (0 on first iteration, 1 on others if hl just overflowed)
    jr nc,+
    add hl,bc          ; if a bit was rotated out then add bc to hl
    jr nc,+
    inc de             ; if hl has overflowed then there's another bit to carry into de
  +:add hl,hl          ; hl<<=1, carry bit set if it overflowed (will be carried into de by following opcodes)
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
fn5b7:                 ; $5b7
; Divide? hl/=e? or is it mod?
; used once
    xor a              ; zero a
    add hl,hl          ; hl <<= 1 (shift into carry)
.rept 16
    adc a,a            ; double a and add carry bit (shift out of hl)
    jr c,+             ; if a overflowed
    cp e               ; compare to e
    jr c,++            ; if bigger
  +:sub e              ; subtract e
    or a               ; make carry flag 1
 ++:ccf                ; make carry flag 0
    adc hl,hl          ; double hl and add carry bit
.endr
/*
    a << = 1;
    a += hl >> 15;
    hl << = 1;

    if (a > 255)
    {
      a &= 255;
      a -= e;
    }
    else
    {
      if (a <= e)
        a -= e;
      else
        hl += 1;
    }
*/
    ret
.ends
; followed by
.orga $66a
.section "Random number generator" overwrite
GetRandomNumber:       ; $066a
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
      +:ld a,r         ; r = refresh register = semi-random number
        xor l          ; xor with l which is fairly random
        ld (RandomNumberGeneratorWord),hl
    pop hl
    ret                ; return random number in a
.ends
; followed by
.orga $689
.section "Startup functions" overwrite
FadeInMarkIIILogoAndPause: ; $0689
    ld a,$02           ; VBlankFunction_MarkIIIFadeIn
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(Controls)
    and P11 | P12      ; Button 1 or 2
    jr nz,_f           ; If button pressed then skip to function 2 = StartTitleScreen
    ld a,(MarkIIILogoDelay)
    or a
    ret nz             ; Keep doing this function until MarkIIILogoDelay is zero
 __:ld hl,FunctionLookupIndex ; This bit used by more than one function
    ld (hl),2          ; Set FunctionLookupIndex to 2 (StartTitleScreen)
    ret

LoadMarkIIILogo:       ; $6a0
    ld a,(IsJapanese)
    or a
    jr nz,_b            ; if IsJapanese==0 then skip to function 2 = StartTitleScreen

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
    SetPage MarkIIILogo1bpp
    ld hl,MarkIIILogo1bpp ; Tile data
    TileAddressDE 256  ; Target tile
    ld bc,MarkIIILogo1bppEnd-MarkIIILogo1bpp ; Count /bytes
    ld a,$01           ; Output mask (what to set 1s to)
    call Output1BitGraphics

    ; Load tilemap
    ld a,$01
    ld (TileMapHighByte),a
    ld hl,MarkIIILogoTilemap
    TileMapAddressDE 7,10 ; x,y
    ldbc 2,19        ; Size (h,w)
    call OutputTilemapRawBxC

    ; Fill palette with colour $38 = blue
    ld de,PaletteAddress
    ld bc,16           ; 16 words = 32 bytes = full palette
    ld hl,$3838        ; should be $0000 to stop startup flash :P
    call FillVRAMWithHL

    ; Fill TargetPalette (32 bytes) with $38 = blue
    ld hl,TargetPalette
    ld de,TargetPalette+1
    ld bc,32-1
    ld (hl),$38
    ldir

    ld a,$ff
    ld (xdf01),a       ; $ff ->

    ld hl,$0000
    ld (PaletteMoveDelay),hl ; $00 -> PaletteMoveDelay, PaletteMovePos

    ei
    jp ClearSpriteTableAndFadeInWholePalette ; and ret
.ends
; followed by
.section "Fade in Mark III logo" overwrite
MarkIIIFadeIn:         ; $0717
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
        SetVRAMAddressToDE
        ex (sp),hl     ; delay
        ex (sp),hl
    pop af
    out (VDPData),a
    ret
_Colours:              ; $737
.db $38,$38,$38,$39,$3A,$3B,$3E,$3F    ; Stupid palette fade :P should choose better colours?
_ColoursEnd:
.ends
; followed by
.section "Title screen" overwrite
; Title screen menu / intro
TitleScreen:           ; $073f
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
    ld (iy+10),$02     ; Weapon $02
    ld (iy+11),$10     ; Armour $10
    call InitialiseCharacterStats

    ld hl,xc600        ; ???
    ld (hl),$ff
    ld hl,xc604        ; ???
    ld (hl),$ff
    ld hl,$0404        ; Set "world" to 4 (type 4)
    ld (xc308),hl      ;
    ld hl,$0610        ;
    ld (HLocation),hl
    ld (xc313),hl      ; ???
    ld hl,$0100        ;
    ld (VLocation),hl
    ld (xc311),hl      ; ???
    ld hl,$0000        ;
    ld (xc4e0),hl      ; ???

    call IntroSequence

    ld hl,FunctionLookupIndex
    ld (hl),$08        ; LoadScene
    ret
.ends
; followed by
.section "Continue selected on title screen" overwrite
TitleScreenContinue:   ; $079e
    ld a,SRAMPagingOn
    ld (SRAMPaging),a
    ld hl,SRAMSlotsUsed
    ld b,5             ; number of slots
  -:ld a,(hl)
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

    SetPage TilesFont

    ld hl,TilesFont
    TileAddressDE $c0
    call LoadTiles4BitRLE
    ld hl,TilesExtraFont
    TileAddressDE $1f0
    call LoadTiles4BitRLE
    call ClearSpriteTableAndFadeInWholePalette

_ContinueOrDeleteMenu: ; $7e3
    ld hl,TextContinueOrDelete
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_Delete
    ; Continue chosen
    ld hl,TextChooseWhichToContinue
    call TextBox20x6
  -:push bc            
      call GetSavegameSelection
    pop bc
    call IsSlotUsed
    jr z,-
    ld hl,TextContinuingGameX
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
    ld a,(xc316)       ; Check xc316
    cp 11
    ret nz             ; if == 11
    ld hl,FunctionLookupIndex
    ld (hl),$0a        ; ???
    ret

_Delete:               ; $82f
    ld hl,TextConfirmDelete
    call TextBox20x6
    call DoYesNoMenu
    jr nz,_ContinueOrDeleteMenu ; No -> back to start
 --:ld hl,TextChooseWhichToDelete
    call TextBox20x6
  -:push bc
        call GetSavegameSelection
        bit 4,c        ; z set if button 1 pressed
    pop bc
    jr nz,_Delete      ; repeat if button 2 pressed(?)
    call IsSlotUsed
    jr z,-             ; wait for a valid selection
    ld hl,TextConfirmSlotSelection
    call TextBox20x6
    call DoYesNoMenu
    jr nz,--
    ld hl,TextGameXHasBeenDeleted
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
    ld d,$81           ; de = x8100 + $16 + 66*a
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

_5Blanks:              ; $89a
.dsw 5 $10c0           ; Blank tile in front of sprites

IsSlotUsed:            ; $8a4
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
; followed by
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
      ld bc,32
      ldir               ; load palette

      ld hl,$c260
      ld de,$c260+1
      ld bc,$9f
      ld (hl),$00
      ldir               ; zero $c260-$c2ff

      ld hl,$c800
      ld de,$c801
      ld bc,$00ff
      ld (hl),$00
      ldir               ; zero $c800-$c8ff

      SetPage TilesTitleScreen
      ld hl,TilesTitleScreen
      TileAddressDE 0    ; tile number 0
      call LoadTiles4BitRLENoDI
  
      SetPage TitleScreenTilemap
      ld hl,TitleScreenTilemap
      call DecompressToTileMapData
  
      xor a
      ld (VScroll),a
      ld (HScroll),a     ; Reset scroll registers
  
      ld a,MusicTitle
      ld (NewMusic),a ; Start music
  
      ld de,$8006        ; Output %00000110 to VDP register 0 - enable stretch screen, no scroll lock/column mask/line int/desync
      SetVRAMAddressToDE

    ei
    ld a,$0c           ; VBlankFunction_UpdateTilemap
    call ExecuteFunctionIndexAInNextVBlank
    jp ClearSpriteTableAndFadeInWholePalette ; and ret

_TitleScreenPalette:   ; $0925
.db $00,$00,$3F,$0F,$0B,$06,$2B,$2A,$25,$27,$3B,$01,$3C,$34,$2F,$3C
.db $00,$00,$3C,$0F,$0B,$06,$2B,$2A,$25,$27,$3B,$01,$3C,$34,$2F,$3C
.ends
; followed by
.section "SRAM check" overwrite
SRAMCheck:             ; $0945
    ld a,SRAMPagingOn
    ld (SRAMPaging),a  ; Page in SRAM
    ld hl,SRAMIdent
    ld de,_SRAMIdentData
    ld bc,_SRAMIdentDataEnd-_SRAMIdentData
  -:ld a,(de)
    inc de
    cpi                ; check if first $40 bytes of SRAM are the same as the marker
    jr nz,_InitSRAM    ; If not, initialise SRAM
    jp pe,-            ; Loop
    ld a,SRAMPagingOff
    ld (SRAMPaging),a  ; page out SRAM
    ret
_SRAMIdentData:
.db "PHANTASY STAR   "
.db "      BACKUP RAM"
.db "PROGRAMMED BY   "
.db "       NAKA YUJI"
_SRAMIdentDataEnd:
_InitSRAM:
    ld hl,$8000
    ld de,$8001
    ld bc,$1ffb
    ld (hl),$00
    ldir               ; Zero first $1ffc bytes of SRAM

    ld hl,DefaultSRAMData
    ld de,x8100
    ld bc,DefaultSRAMDataEnd-DefaultSRAMData
    ldir               ; Fill from x8100 with default data

    ld hl,_SRAMIdentData
    ld de,SRAMIdent
    ld bc,_SRAMIdentDataEnd-_SRAMIdentData
    ldir               ; Put in the identifier

    ld a,SRAMPagingOff
    ld (SRAMPaging),a  ; Page out SRAM
    ret
.ends
; followed by
.orga $9cb
.section "unprocessed code" overwrite
fn9cb: ; Interplanetary flight?
    ld hl,$2009        ; Fade out, 32 colours
    ld (PaletteFadeControl),hl

  -:ld a,(PauseFlag)
    or a
    call nz,DoPause    ; Pause if flagged

    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank

    ld a,(Controls)
    and P11 | P12
    jr nz,_f

    call _fnaf4        ; if no button pressed:
    ld hl,(xc2f2)
    ld de,8
    add hl,de
    ld (xc2f2),hl      ; Add 8 to xc2f2
    ld a,h
    cp $08             ; Loop until h = $8 = 4096 frames = 68.2s?
    jr c,-

 __:ld a,$16           ; VBlankFunction_PaletteEffects
    call ExecuteFunctionIndexAInNextVBlank
    ld a,(PaletteFadeControl)
    or a               ; repeat until palette is faded out
    jr nz,_b

    jr +               ; ####################
  +:ld hl,Frame2Paging
  
    ld (hl),:PaletteSpace
    ld hl,PaletteSpace
    ld de,TargetPalette
    ld bc,17
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
    ld de,TileMapData+$300 ; 12 rows
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
    ld de,TileMapData+$300
    ld bc,$300
    ldir               ; ############# again?

    ld a,MusicVehicle
    ld (NewMusic),a

    call FadeInWholePalette

    ld hl,0
    ld (xc2f2),hl

    ld a,8
    ld (ScrollScreens),a

  -:ld a,(PauseFlag)
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

  +:ld hl,FunctionLookupIndex
    ld (hl),4

    call fn0bd0

    ld hl,$0800        ; 000A9A 21 00 08
    ld ($c2f2),hl      ; 000A9D 22 F2 C2
  -:ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank
    ld a,($c205)       ; 000AAC 3A 05 C2
    and $30             ; 000AAF E6 30
    jr nz,+
    call _fnaf4           ; 000AB3 CD F4 0A
    ld hl,($c2f2)      ; 000AB6 2A F2 C2
    ld de,$0008        ; 000AB9 11 08 00
    or a               ; 000ABC B7
    sbc hl,de           ; 000ABD ED 52
    ld ($c2f2),hl      ; 000ABF 22 F2 C2
    jr nc,-
  +:ld hl,$0000        ; 000AC4 21 00 00
    ld ($c2f2),hl      ; 000AC7 22 F2 C2
    ld hl,FunctionLookupIndex        ; 000ACA 21 02 C2
    ld (hl),$08        ; 000ACD 36 08
    ld a,($c2e9)       ; 000ACF 3A E9 C2
    and $7f             ; 000AD2 E6 7F
    ld l,a             ; 000AD4 6F
    add a,a             ; 000AD5 87
    add a,a             ; 000AD6 87
    add a,a             ; 000AD7 87
    add a,l             ; 000AD8 85
    ld l,a             ; 000AD9 6F
    ld h,$00           ; 000ADA 26 00
    ld de,$0c18        ; 000ADC 11 18 0C
    add hl,de           ; 000ADF 19
    xor a               ; 000AE0 AF
    ld (PaletteRotateEnabled),a       ; 000AE1 32 65 C2
    ld ($c264),a       ; 000AE4 32 64 C2
    ld ($c2e9),a       ; 000AE7 32 E9 C2
    ld ($c30e),a       ; 000AEA 32 0E C3
    ld ($c307),a       ; 000AED 32 07 C3
    call fn7b1e
    ret

_fnaf4:
    ld de,($c2f2)      ; 000AF4 ED 5B F2 C2
    ld a,($c304)       ; 000AF8 3A 04 C3
    ld h,a             ; 000AFB 67
    ld b,a             ; 000AFC 47
    ld a,($c307)       ; 000AFD 3A 07 C3
    ld l,a             ; 000B00 6F
    or a               ; 000B01 B7
    sbc hl,de           ; 000B02 ED 52
    ld a,h             ; 000B04 7C
    cp $e0             ; 000B05 FE E0
    jr c,+
    sub $20             ; 000B09 D6 20
  +:ld h,a             ; 000B0B 67
    ld ($c304),a       ; 000B0C 32 04 C3
    ld a,l             ; 000B0F 7D
    ld ($c307),a       ; 000B10 32 07 C3
    ld a,b             ; 000B13 78
    sub h               ; 000B14 94
    and $0f             ; 000B15 E6 0F
    ret z               ; 000B17 C8
    ld e,a             ; 000B18 5F
    ld d,$00           ; 000B19 16 00
    ld hl,($c305)      ; 000B1B 2A 05 C3
    ld b,h             ; 000B1E 44
    ld a,l             ; 000B1F 7D
    sub e               ; 000B20 93
    cp $c0             ; 000B21 FE C0
    jr c,+
    sub $40             ; 000B25 D6 40
    dec h               ; 000B27 25
  +:ld l,a             ; 000B28 6F
    ld a,h             ; 000B29 7C
    and $07             ; 000B2A E6 07
    ld h,a             ; 000B2C 67
    ld ($c305),hl      ; 000B2D 22 05 C3
    cp b               ; 000B30 B8
    call nz,$74e0        ; 000B31 C4 E0 74
    call $75dd           ; 000B34 CD DD 75
    ld a,($c2f3)       ; 000B37 3A F3 C2
    cp $07             ; 000B3A FE 07
    ret nz              ; 000B3C C0
    ld a,($c21b)       ; 000B3D 3A 1B C2
    or a               ; 000B40 B7
    call nz,$7de3        ; 000B41 C4 E3 7D
    ret                    ; 000B44 C9

_ScrollToTopPlanet:    ; $0b45
    ld de,2
    ld a,(VScroll)
    sub e              ; Scroll up by 2 lines
    cp 224             
    jr c,+
    ld d,1             ; When it is >= 224
    sub 32             ; make it jump by 32 to scroll smoothly
  +:ld (VScroll),a

    ld a,(ScrollScreens)
    sub d              ; dec ScrollScreens for each screenful scrolled
    ld (ScrollScreens),a

    cp $1
    ret nz             ; exit if ScrollScreens!=1
    ld a,d
    or a
    ret z              ; or d==0

    ; When we have got to the last screen to scroll:
    ld a,(xc2e9)       ; get xc2e9
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
    ld (xc308),a
    call _LoadPlanetPalette

    ld hl,TargetPalette
    ld de,ActualPalette
    ld bc,32
    ldir               ; load palette

    ld hl,TilemapTopPlanet ; load top planet
    jp DecompressToTileMapData ; and ret

_LoadPlanetPalette:    ; $0b8d
    ld a,(xc308)
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

PaletteSpacePlanets:   ; $0ba6
.db cl233 cl023 cl013 cl003 cl002 cl010 ;$3E $38 $34 $30 $20 $04 ; Palma
.db cl332 cl331 cl320 cl210 cl100 cl210 ;$2F $1F $0B $06 $01 $06 ; Dezoris
.db cl333 cl333 cl233 cl033 cl123 cl023 ;$3F $3F $3E $3C $39 $38 ; Motavia

fn0bb8: ; $0bb8
    ld a,(xc2e9)
    and $7f
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,0             ; hl = xc2e9*9
    ld de,_WorldData-9
    add hl,de

    ld de,$0be8
    push de
    call fn7b1e

fn0bd0:
    ld a,(xc2e9)       ; ??? again at +3?
    and $7f
    ld l,a
    add a,a
    add a,a
    add a,a
    add a,l
    ld l,a
    ld h,0
    ld de,_WorldData-9+3
    add hl,de

    ld de,$0be8
    push de
    call fn7b1e

    xor a              ; Zero:
    ld (ControlsNew),a
    ld (ScrollDirection),a

    ld a,(xc2e9)
    cp $83             ; ???
    ld a,$10
    jr c,+
    inc a
  +:ld (xc30e),a       ; xc30e = $10 or $11 if xc2e9==$83

    ld hl,0
    ld (xc2f2),hl

    call LoadScene

    ld hl,OutsideAnimCounters ; zero OutsideAnimCounters
    ld de,OutsideAnimCounters+1
    ld bc,24-1
    ld (hl),0
    ldir

    call SpriteHandler

    ld a,1
    ld (ScrollDirection),a ; Up
    ret

_WorldData: ; $0c12
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

DoNothing: ; $0c63
    ret

fn0c64: ; $0c64
    ; check for Pause
    ld a,(PauseFlag)
    or a
    call nz,DoPause
    ld a,$0e           ; VBlankFunction_OutsideScrolling
    call ExecuteFunctionIndexAInNextVBlank
    call SpriteHandler
    call $7a4f         ; ???
    ld a,(PaletteRotateEnabled)
    or a
    jr nz,+            ; if PaletteRotateEnabled then skip -+
    ld a,(xc2d2)       ; ??? Read xc2d2                     |
    or a               ;                                    |
    jr z,+             ; if xc2d2==0 then skip -------------+
    xor a              ; Invert bits                        |
    ld (xc2d2),a       ; and write back                     |
    call $61df         ; ???                                |
    or a               ; check result                       |
    jr z,+             ; if zero then skip -----------------+
    ld a,$ff           ; else set all bits in a             |
    jp ++              ; and skip onwards ------------------|-+
  +:ld a,(ControlsNew) ; Check controls  <------------------+ |
    and P11 | P12      ; Is a button pressed?                 |
    ret z              ; exit if not                          |
    ld a,(PaletteRotateEnabled) ;                             |
    or a               ;                                      |
    ret nz             ; exit if PaletteRotateEnabled         |
    xor    a           ; zero a                               |
 ++:ld (xc29d),a       ; Save to xc29d <----------------------+

    ld hl,FunctionLookupIndex
    ld (hl),$0c        ; Set FunctionLookupIndex to 0c (???)

    ld a,($c810)       ; Copy CharacterSpriteAttributes[0].currentanimframe
    ld (xc2d7),a       ; to xc2d7

    ld hl,OutsideAnimCounters
    ld de,OutsideAnimCounters+1
    ld bc,23
    ld (hl),$00
    ldir               ; Zero OutsideAnimCounters structure

    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes+1
    ld bc,$ff
    ld (hl),$00
    ldir               ; Zero CharacterSpriteAttributes
    ret
.ends
; followed by
.orga $cc6
.section "Load scene" overwrite
LoadScene:             ; $0cc6
    call FadeOutFullPalette
    di
    call TurnOffDisplay
    ei
    ld hl,FunctionLookupIndex
    inc (hl)           ; -> 9 = ???
    xor a              ; Set to 0:
    ld (SceneAnimEnabled),a
    ld (xc315),a
    inc a              ; Set to 1:
    ld (xc2d5),a
    ld a,(xc308)
    cp 4
    jr nc,+

    SetPage TilesOutside ; If xc308 is <=4:
    ld hl,TilesOutside ; load non-town tileset
    TileAddressDE 0
    call LoadTiles4BitRLE
    jr ++

  +:SetPage TilesTown ; Otherwise, load non-Palma tileset
    ld hl,TilesTown
    TileAddressDE 0    ; could save doing this twice? ############
    call LoadTiles4BitRLE

 ++:call _ResetCharacterSpriteAttributes
    call SpriteHandler
    ld b,4
  -:push bc
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
    ld a,(xc309)
    ld e,a
    ld d,$00
    ld hl,WorldDataLookup1
    add hl,de          ; hl = WorldDataLookup1 + xc309
    ld a,(hl)
    ld (xc308),a       ; xc308 = (hl) = world type
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
    add hl,de          ; hl = WorldDataLookup2 + 14*xc308
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld (xc260),de      ; xc260 = word there
    ld a,(hl)
    ld (xc262),a       ; xc262 = byte after it
    inc hl
    ld e,(hl)
    ld d,$1f
    ld (OutsideAnimCounters+4*0),de ; OutsideAnimCounters[0] = reset $1f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$0f
    ld (OutsideAnimCounters+4*1),de ; OutsideAnimCounters[1] = reset $f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$0f
    ld (OutsideAnimCounters+4*2),de ; OutsideAnimCounters[2] = reset $f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$03
    ld (OutsideAnimCounters+4*3),de ; OutsideAnimCounters[3] = reset 3, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$0f
    ld (OutsideAnimCounters+4*4),de ; OutsideAnimCounters[4] = reset $f, enabled (next byte)
    inc hl
    ld e,(hl)
    ld d,$07
    ld (OutsideAnimCounters+4*5),de ; OutsideAnimCounters[5] = reset 7, enabled (next byte)
    inc hl
    ld a,(hl)
    ld (xc263),a       ; xc263 = next byte
    inc hl             
    ld a,(hl)
    inc hl
    push hl
        ld h,(hl)
        ld l,a         ; hl = next word = palette location
        ld de,TargetPalette
        ld bc,17
        ldir           ; Load start of palette
        ld a,(xc30e)
        or a
        jr nz,+
        push hl        ; if xc30e=0:
            ld hl,SpritePalette1
            ld bc,13
            ldir       ; Load rest of palette
        pop hl
        ldi            ; last 2 palette entries from end of palette location
        ldi
        jp ++          ; if xc30e!=0:
      +:ld hl,SpritePalette2
        ld bc,15
        ldir           ; Load different palette
 ++:pop hl
    inc hl
    ld a,(hl)          
    inc hl
    ld h,(hl)
    ld l,a             ; hl = next word = ???
    ld (xc2d9),hl
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

    ld a,(xc30e)
    cp $10             ; if xc30e>16
    ld c,$b8           ; then c=$b8 (?)
    jr nc,+
    or a
    ld c,MusicVehicle  ; else c=MusicVehicle
    jr nz,+            ; if xc30e==0
    ld a,(xc309)       ; then:
    ld e,a
    ld d,$00
    ld hl,WorldMusics
    add hl,de          ; de = WorldMusics+xc309
    ld c,(hl)          ; c = (de) = music number
  +:ld a,c
    call CheckMusic

    ld de,$8026
    di
      SetVRAMAddressToDE ; output %00100110 to VDP register 0 - ???
    ei
    jp ClearSpriteTableAndFadeInWholePalette ; and ret

CheckMusic:           ; $df3
    push hl
        ld hl,CurrentlyPlayingMusic
        cp (hl)        ; if a!=CurrentlyPlayingMusic
        jr nz,+
    pop hl
    ret
      +:ld (NewMusic),a ; then set NewMusic to a
        ld (hl),a
    pop hl
    ret

_ResetCharacterSpriteAttributes: ; $e02
    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes+1
    ld bc,$ff
    ld (hl),$00
    ldir               ; Zero $100 bytes (all of CharacterSpriteAttributes)
    ld a,(xc30e)       ; Check xc30e
    or a               ; If zero,
    jp z,_InitialiseCharacterSpriteAttributes
    ld hl,CharacterSpriteAttributes
    ld (hl),$09        ; else set CharacterSpriteAttributes+00 to 9 (???)
    ret

_InitialiseCharacterSpriteAttributes: ; $e1c
    ld de,CharacterSpriteAttributes
    ld bc,32           ; size of each entry in CharacterSpriteAttributes
    ld hl,CharacterStatsAlis
    ld a,$01
    call +
    ld hl,CharacterStatsNoah
    ld a,$03
    call +
    ld hl,CharacterStatsOdin
    ld a,$05
    call +
    ld hl,CharacterStatsMyau
    ld a,$07
    ; fall through
  +:                   ; $e3f
    bit 0,(hl)         ; exit if low bit of (hl) = IsAlive is not set
    ret z
    ld (de),a          ; copy a to (de) = CharacterSpriteAttributes+0 ???
    ex de,hl
    add hl,bc          ; add bc to de to get to next entry
    ex de,hl
    ret
.ends
; followed by
.orga $e47
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
.orga $eff
.section "Sprite palettes" overwrite
SpritePalette1:        ; $eff ; last 2 entries are dependent on something else (?)
.db $00,$3f,$2b,$0b,$2f,$37,$0f,$38,$34,$06,$01,$2a,$25,$00,$00
SpritePalette2:        ; $fe0
.db $00,$3f,$02,$03,$0b,$0f,$20,$38,$34,$2f,$2a,$25,$2f,$2a,$25
.ends
; followed by
.orga $f1d
.section "World data" overwrite
WorldDataLookup1: ; which "world" to load data for for each value of xc309
.db $00,$01,$02,$03,$04,$04,$04,$05,$05,$05,$05,$05,$06,$06,$07,$07,$07,$07,$07,$08,$08,$09,$09,$0A
WorldMusics: ; Music for each value of xc309
.db MusicPalma,MusicMotabia,MusicDezoris,MusicDezoris,MusicTown,MusicTown,MusicTown,MusicVillage,MusicVillage,MusicVillage,MusicVillage,MusicVillage,MusicTown,MusicTown,MusicTown,MusicVillage,MusicTown,MusicVillage,MusicVillage,MusicDezoris,MusicDezoris,MusicVillage,MusicVillage,MusicBossDungeon
WorldDataLookup2: ; "World" data
/*
.macro WorldData
.dw \1
.db :\1 \2 \3 \4 \5 \6 \7 \8
.dw \9 \10
.endm
;          ,,,,----------------------------------- Offset xc260 Points to a table of pointers to tilemap data?
;          ||||      ,-,-,-,-,-,------------------ various tile animation enables
;          ||||      | | | | | |  ,,-------------- xc263 ??? page?
;          ||||      | | | | | |  ||  ,,,,-------- Palette offset
;          ||||      | | | | | |  ||  |||| -,,,,-- xc2d9 ??? offset?
WorldData WorldData1,1,1,0,1,1,0,$1d,$0e47,$a935 ; Palma
WorldData WorldData2,0,0,1,1,0,1,$1d,$0e58,$a9b9 ; Motabia
WorldData WorldData3,0,0,0,0,0,0,$1d,$0e69,$a9e3 ; Dezoris
WorldData WorldData3,0,0,0,0,0,0,$1d,$0e69,$aa49 ; Town
WorldData WorldData4,0,0,0,0,0,0,$16,$0e7a,$aa4a ; Village
WorldData $8762,0,0,0,0,0,0,$16,$0e8d,$ab70 ; ???
WorldData $8f42,0,0,0,0,0,0,$16,$0ea0,$ac8b ; ???
WorldData $93d9,0,0,0,0,0,0,$16,$0eb3,$acf7 ; ???
WorldData $9c07,0,0,0,0,0,0,$16,$0ec6,$ae5f ; ???
WorldData $9d8b,0,0,0,0,0,0,$16,$0ed9,$ae71 ; ??? town
WorldData $a250,0,0,0,0,0,0,$16,$0eec,$af37 ; Air Castle
*/
;    ,,--,,-------------------------------------- Offset  xc260 \ Scrolling tilemap data?
;    ||  ||  ,,---------------------------------- Page    xc262 /
;    ||  ||  || ,-,-,-,-,-,---------------------- various tile animation enables
;    ||  ||  || | | | | | |  ,,------------------ xc263 ??? page?
;    ||  ||  || | | | | | |  ||  ,,--,,---------- Palette offset
;    ||  ||  || | | | | | |  ||  ||  ||  ,,--,,-- xc2d9 ??? offset?
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $184d
.section "Initialise character stats in iy" overwrite
InitialiseCharacterStats: ; $184d
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $1916
.section "Characters item/level stats update" overwrite
CharacterStatsUpdate:  ; $1916
    SetPage LevelStats

    ld iy,CharacterStatsAlis
    ld de,LevelStatsAlis
    call +

    ld iy,CharacterStatsMyau
    ld de,LevelStatsMyau-8 ; -8 because other characters start at level 1
    call +

    ld iy,CharacterStatsOdin
    ld de,LevelStatsOdin-8
    call +

    ld iy,CharacterStatsNoah
    ld de,LevelStatsNoah-8
    ; fall through

  +:bit 0,(iy+0)       ; if alive...
    ret z
    ld (iy+0),$01      ; set alive to normal value (01)
    ld (iy+13),$00     ; set +13 to 0 ???

    ld l,(iy+5)
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

_ItemStrengths:        ; $1996
.db  0, 3, 4,12,10,10,10,21,31,18,30,30,46,50,60,80 ; weapons
.db  5, 5,15,20,30,30,60,80,40                      ; armour - splits not certain ???
.db  3, 8,15,23,40,30,40,50                         ; shields
.dsb 31, 0                                          ; 31 0s at the end -> 64 bytes total ##############
.ends
.orga $19d6

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $2e75
.section "Do yes/no menu" overwrite
DoYesNoMenu:           ; $2e75
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
MenuWaitForButton:     ; $2e81
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
MenuWaitHalfSecond:    ; $2e8f
    ld b,30            ; 30 frames
  -:ld a,$08           ; VBlankFunction_Menu
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
Pause3Seconds:         ; $2e9f  Could make it handle PAL speed?
    ld b,3*60
  -:ld a,8             ; VBlankFunction_Menu
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
Pause256Frames:      ; $2eaf
    ld b,0           ; Frames to wait (0 = 256 = 4.3s)
  -:ld a,8           ; VBlankFunction_Menu
    call ExecuteFunctionIndexAInNextVBlank
    djnz -      
    ret
.ends
; followed by
.orga $2eb9
.section "Wait for menu selection" overwrite
; returns menu selection (0-based) in a
WaitForMenuSelection:
    ld a,$ff
    ld (CursorEnabled),a  ; Enable cursor
    ld hl,$0000
    ld (CursorPos),hl  ; 0 -> CursorPos, OldCursorPos
    xor a
    ld (CursorCounter),a ; zero CursorCounter
  -:ld a,$08           ; VBlankFunction_Menu
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
  +:bit 1,c
    jr z,+
    inc a              ; if U then increase CursorPos
    cp (hl)            ; compare to CursorMax
    jr c,+             ; if greater
    jr z,+             ; or equal
    xor a              ; then zero it
  +:ld (CursorPos),a   ; save in CursorPos
 ++:ld a,(Controls)
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $2fca
.section "Flash cursor" overwrite
FlashCursor:           ; $2fca
    ld a,(CursorEnabled) ; Check CursorEnabled
    or a
    ret z              ; Continue if non-zero
    ld a,(FunctionLookupIndex)
    cp 3               ; if FunctionLookupIndex<>3 (TitleScreen)
    ld bc,$f0f3        ; then b=$f0, c=$f3 (in-game cursor tile #s, actually $1xx)
    jr nz,+
    ld bc,$ff00        ; else b=$ff, c=$00 (title screen cursor tile #s)
  +:ld hl,(CursorTileMapAddress) ; Load CursorTilemapAddress
    ld a,(OldCursorPos) ; and OldCursorPos
    srl a
    ld e,$00
    rr e
    ld d,a             ; de = xc26c * 128 (128 bytes = 2 rows of tiles)
    add hl,de
    ex de,hl           ; de = CursorTilemapAddress + xc26c * 128
    SetVRAMAddressToDE

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
    SetVRAMAddressToDE

    ld a,(CursorCounter)
    dec a
    and $0f
    ld (CursorCounter),a ; decrement CursorCounter, limit to $f-$0
    bit 3,a            ; if bit 3 is 0
    ld a,b             ; then output b ($f0 or $ff) ("on" cursor)
    jr nz,+
    ld a,c             ; else output c ($f3 or $00) ("off" cursor)
  +:out ($be),a
    ret
.ends
.orga $3014

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $3140
.section "Output chars plus number plus right |" overwrite
; outputs 8/16 bytes = 4/5 chars at (hl), then 3-digit number in a, then write | to VRAM address de
; Then does VBlankFunction_Enemy in VBlank to keep tile animations going
Output4CharsPlusStatWide:  ; $3140
    di                           ; 003140 F3
    push de                      ; 003141 D5
        push af                  ; 003142 F5
            SetVRAMAddressToDE   ; 003143 CF
            ld b,16              ; 003144 06 10
            jp _f                ; 003146 C3 4F 31

Output4CharsPlusStat:  ; $3149
    di
    push de
        push af
            SetVRAMAddressToDE
            ld b,$08   ; counter
            

         __:ld a,(hl)
            out (VDPData),a ; output 8 bytes from hl to de
            inc hl
            djnz _b
        pop af

        ld bc,$c010    ; tile c0 for leading blanks

        ld d,$ff
      -:sub 100        ; d = 100s digit in a
        inc d
        jr nc,-
        add a,100

        ld l,a         ; backup a
        ld a,d
        call OutputDigit

        ld d,$ff
        ld a,l
      -:sub 10         ; d = 10s digit in a
        inc d
        jr nc,-
        add a,10

        ld l,a         ; same as before
        ld a,d
        call OutputDigit

        ld d,$ff
        ld a,l
      -:sub 1          ; d = 1s digit in a
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $320f
.section "Tilemaps for HM and MP display" overwrite
TilesHP:
.dw $11f3 $11f4 $11f5 $10c0 ; "|HP "
TilesMP:
.dw $11F3 $11F6 $11F5 $10C0 ; "|MP "
.ends
; followed by
.orga $321f
.section "Output xd724 tilemap data to bottom of screen" overwrite
fn321f:                ; $321f
    ld hl,xd724
    TileMapAddressDE 0,18
    TileMapAreaBC 32,6
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $322b
.section "Show combat menu" overwrite
ShowCombatMenu:        ; $322b
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
RefreshCombatMenu:     ; $323d
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
    cp 73
    ret z              ; end if EnemyNumber = 73 = Dark Force

    ld hl,MenuBox8Top
    TileMapAddressDE 24,0
    TileMapAreaBC 8,1
    call OutputTilemapBoxWipePaging

    ld ix,CharacterStatsEnemies ; Enemy stats
    ld a,(NumEnemies)
    ld b,a             ; b = number of enemies
  -:push bc
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
            SetVRAMAddressToDE
            push af    ; delay
            pop af

            ld a,$f3   ; Output tile 1f3 = | (high priority)
            out (VDPData),a
            push af
            pop af
            ld a,$11
            out (VDPData),a

            ld b,$08   ; b=8 = counter for 8 chars

          -:ld a,(hl)
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
            ld a,$f3
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
    cp 73
    call nz,OutputTilemapBoxWipePaging ; restore tilemap if EnemyNumber!=73=Dark Force

    ld hl,OldTileMapEnemyName10x4
    TileMapAddressDE 14,0
    TileMapAreaBC 10,4
    jp OutputTilemapBoxWipePaging ; and ret
.ends
; followed by
.orga $3326
.section "20x6 text box at bottom of screen" overwrite
_CharacterNames:       ; $3326
.db $01,$28,$0B,TextButtonEnd    ; Alisa
.db $20,$30,$03,TextButtonEnd    ; Myau
.db $10,$02,$2B,$2E              ; Tairon
.db $29,$12,TextButtonEnd,$00    ; Lutz

  -:dec hl             ; move pointer back <-+
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
        ld hl,OldTileMap20x6  ; Read existing tilemap into buffer  |
        TileMapAddressDE 6,18 ;                                    |
        TileMapAreaBC 20,6    ;                                    |
        call InputTilemapRect ;                                    |
        ld hl,MenuBox20x6     ;                                    |
        call OutputTilemapBoxWipePaging ; Draw empty 20x6 box      |
    pop hl             ;                                           |
                       ;                                           |
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
        ld hl,MenuBox20x6      ;                 |                 |  |
        TileMapAddressDE 6,18  ;                 |                 |  |
        ld bc,$0628            ; 20x6            |                 |  |
        call OutputTilemapRect ;                 |                 |  |
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
        and $03        ; just low 2 bits         |                    |
        add a,a        ; multiply by 4           |                    |
        add a,a        ;                         |                    |
        ld hl,_CharacterNames ;                  |                    |
        add a,l        ;                         |                    |
        ld l,a         ;                         |                    |
        adc a,h        ;                         |                    |
        sub l          ; hl = _CharacterNames    |                    |
        ld h,a         ; + 4*TextCharacterNumber |                    |
        ld a,4         ;                         |                    |
        call _DrawALetters ;                     |                    |
    pop hl             ;                         |                    |
    inc hl             ; next data               |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33c4           <-------+                    |
    cp TextEnemyName   ;                                              |
    jr nz,+            ; ------------------------+                    |
    push hl            ;                         |                    |
        ld hl,EnemyName;                         |                    |
        ld a,8         ;                         |                    |
        call _DrawALetters ;                     |                    |
    pop hl             ;                         |                    |
    inc hl             ; next data               |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33d6      <------------+                    |
    cp TextItem        ; Draws ItemTableIndexth text from ItemTextTable
    jr nz,+            ; ------------------------+                    |
    push hl            ;                         |                    |
        ld a,(ItemTableIndex) ;                  |                    |
        ld l,a         ;                         |                    |
        ld h,$00       ;                         |                    |
        add hl,hl      ;                         |                    |
        add hl,hl      ;                         |                    |
        add hl,hl      ;                         |                    |
        push bc        ;                         |                    |
            ld bc,ItemTextTable ;                |                    |
            add hl,bc  ; hl = ItemTextTable      |                    |
        pop bc         ;    + ItemTableIndex * 8 |                    |
        ld a,8         ;                         |                    |
        call _DrawALetters ;                     |                    |
    pop hl             ;                         |                    |
    inc hl             ;                         |                    |
    jp _ReadData       ;                         |                    |
                       ;                         |                    |
+:                     ; $33f4  <----------------+                    |
    cp TextNumber                                                     |
    jr nz,+            ; ------------------------+                    |
    push hl            ;                         |                    |
        push bc        ;                         |                    |
            push de    ;                         |                    |
                ld hl,(NumberToShowInText);      |                    |
                ld de,10000  ;                   |                    |
                xor a        ; reset carry and a |                    |
                ld c,a       ; c = 0             |                    |
                dec a        ; a = -1            |                    |
              -:sbc hl,de    ;                   |                    |
                inc a        ; a = hl/10000      |                    |
                jr nc,-      ;                   |                    |
                add hl,de    ; hl = remainder    |                    |
            pop de           ;                   |                    |
            call _OutputDigitA ;                 |                    |
            push de          ;                   |                    |
                ld de,1000   ;                   |                    |
                ld a,-1      ;                   |                    |
              -:sbc hl,de    ;                   |                    |
                inc a        ; a = hl/1000       |                    |
                jr nc,-      ;                   |                    |
                add hl,de    ; hl = remainder    |                    |
            pop de           ;                   |                    |
            call _OutputDigitA ;                 |                    |
            push de          ;                   |                    |
                ld de,100    ;                   |                    |
                ld a,-1      ;                   |                    |
              -:sbc hl,de    ;                   |                    |
                inc a        ; a = hl/100        |                    |
                jr nc,-      ;                   |                    |
                add hl,de    ; l = remainder     |                    |
            pop de           ;                   |                    |
            call _OutputDigitA ;                 |                    |
            push de          ;                   |                    |
                ld d,-1      ;                   |                    |
                ld a,l       ;                   |                    |
              -:sub 10       ;                   |                    |
                inc d        ; d = l/10          |                    |
                jr nc,-      ;                   |                    |
                add a,10     ;                   |                    |
                ld l,a       ; l = remainder     |                    |
                ld a,d       ;                   |                    |
            pop de           ;                   |                    |
            call _OutputDigitA ;                 |                    |
            push de          ;                   |                    |
                ld d,-1      ;                   |                    |
                ld a,l       ;                   |                    |
              -:sub 1        ;                   |                    |
                inc d        ; d = l/1 (??? why?)|                    |
                jr nc,-      ;                   |                    |
                ld a,d       ;                   |                    |
                ld c,1       ; Force output if 0 |                    |
            pop de           ;                   |                    |
            call _OutputDigitA ;                 |                    |
            ld a,b     ; preserve digit counter  |                    |
        pop bc         ; through pop             |                    |
        ld b,a         ;                         |                    |
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
  +:ld c,$01           ; Set low bit of c to signify that zeroes should be displayed after this digit
    di                 ;
    push de            ;
        push af        ;
            SetVRAMAddressToDE
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
            SetVRAMAddressToDE
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
        ld a,(hl)      ; peek at next data
        cp $58         ; ExitAfterButton -> no return
        jr z,+         ; ------------------------+
    pop af             ;                         |
    dec a              ; dec counter             |
    jp nz,_DrawALetters; repeat until a=0        |
    ret                ;                         |
+:  pop af             ; <-----------------------+
    ret                ; return


ShowNarrativeText:      ; $34a5
    ld a,:DialogueText
    ld (Frame2Paging),a ; can't use SetPage because I have to preserve hl

    TileMapAddressDE 6,16 ; where to start drawing text from
    ld bc,$0000        ; reset b & c
 --:push de
      -:call _DrawLetter ; modifies b and c sometimes for its own re-use
        ld a,(hl)      ; check for special bytes
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
        SetVRAMAddressToDE
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
        SetVRAMAddressToDE
        ld a,(hl)      ; get data (lower half of letter)
        add a,a
        ld bc,TileNumberLookup+1
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
      +:out (VDPData),a
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
    ld de,$7d4e        ; TileMapAddressDE 7,21
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
  -:ld a,$0a           ; VBlankFunction_Enemy
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $3762
.section "Output digit in a" overwrite
OutputDigit:           ; $3762
; outputs digit in a to VRAM (address already set)
; unless a=0 when the value in bc determines which tile is output
    and $0f            ; cut a down to a single digit
    jp z,+             ; if non-zero,
    ld bc,$c110        ; add to $c1 = index of tile '0'
  +:add a,b            ; else add to whatever bc was already
    out (VDPData),a
    push af
    pop af
    ld a,c
    out (VDPData),a    ; output
    ret
.ends
.orga $3773

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $3adb
.section "Show savegame list and get selection" overwrite
GetSavegameSelection:  ; $3adb
    ld a,SRAMPagingOn  ; Draw menu from tilemap in SRAM
    ld (SRAMPaging),a
    ld hl,x8100
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

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
 --:push bc
        di
        SetVRAMAddressToDE
        ld b,c
        ld c,VDPData
      -:outi           ; output c bytes
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
 --:push bc
        SetVRAMAddressToDE
        ld b,c
        ld c,VDPData
      -:outi           ; output
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
     --:push bc
            SetVRAMAddressToDE (for reading)
            ld b,c
            ld c,VDPData
          -:ini        ; input from VRAM
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
DefaultSRAMData: ; Default data for SRAM
.include "Other data\Default SRAM data.inc"
DefaultSRAMDataEnd:
.ends
.orga $3cc0

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $3e41
.section "Sprite palette(s) (?)" overwrite
SpritePaletteStart:
.db $00,$00,$3F,$30,$38,$03,$0B,$0F
.ends
.orga $3e49

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $3e6b
.section "Scene data loader" overwrite
LoadSceneData:         ; $3e6b
    ld a,(SceneType)
    cp 32
    jr c,_LoadSceneData ; if SceneType<32 then load data

    ld hl,TileMapData
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

_SceneData:            ; $3ec2+8 = $3eca
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
; must be given as part of the data structure... so they out $16. My macro puts 0, so I have
; to do the data structure explicitly; the macro works 100% though.
; SceneDataStruct AirCastleFull     ,AirCastle          ,AirCastle         ; 0f
.db $16
.dw PaletteAirCastleFull,TilesAirCastle
 PageAndOffset TilemapAirCastle
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

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

    ld de,(NameEntryCharIndex)   ; 004006 ED 5B 81 C7   ; else, it's a char. Get the address to write to (this opcode could have been ld e,(NameEntryCharIndex))
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
+:  ld hl,NameEntryCharIndex     ; 004020 21 81 C7
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
    ld hl,$c700                  ; 00405F 21 00 C7
    ld de,$c740                  ; 004062 11 40 C7
-:  ld a,(hl)                    ; 004065 7E         ; read byte
    or a                         ; 004066 B7
    jr z,+                       ; 004067 28 07

    exx                          ; 004069 D9         ; if non-zero, look up corresponding byte in the table
    ld l,a                       ; 00406A 6F
    ld h,$00                     ; 00406B 26 00
    add hl,de                    ; 00406D 19
    ld a,(hl)                    ; 00406E 7E
    exx                          ; 00406F D9

+:  ld (de),a                    ; 004070 12         ; write byte to de
    inc hl                       ; 004071 23
    inc de                       ; 004072 13
    djnz -                       ; 004073 10 F0      ; repeat for $38 bytes

    ld hl,FunctionLookupIndex    ; 004075 21 02 C2
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

    ld hl,$d19a                  ; 004091 21 9A D1   ; TileMapAddress location of (13,6) (top row of name)
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

    ld a,(xc316)                 ; 0040AF 3A 16 C3   ; ???
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
    jr c,_UpHeld                 ; 0040CC 38 3E
    rra                          ; 0040CE 1F
    jr c,_DownHeld               ; 0040CF 38 52
    rra                          ; 0040D1 1F
    jr c,_LeftHeld               ; 0040D2 38 66
    rra                          ; 0040D4 1F
    jr c,_RightHeld              ; 0040D5 38 1E
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
-:  ldbc $c8,+8                  ; 0040E9 01 08 C8      ; stop/delta for cursor sprite coordinate
    ld de,+2                     ; 0040EC 11 02 00      ; delta for tilemap address
    ld iy,NameEntryCursorX       ; 0040EF FD 21 84 C7   ; which cursor sprite coordinate to change
    jr _NameEntryNoButtonPressed_DoneWithInput
_RightHeld:
    ld a,24                      ; 0040F5 3E 18
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 0040FA 18 ED

_UpNew:
    call _DecrementKeyRepeatCounter ;40FC CD 7B 41
    ret nz                       ; 0040FF C0
-:  ldbc $68,-16                 ; 004100 01 F0 68
    ld de,-$80                   ; 004103 11 80 FF
    ld iy,NameEntryCursorY       ; 004106 FD 21 85 C7
    jr _NameEntryNoButtonPressed_DoneWithInput
_UpHeld:
    ld a,24
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 004111 18 ED

_DownNew:
    call _DecrementKeyRepeatCounter ;4113 CD 7B 41
    ret nz                       ; 004116 C0
-:  ldbc $b8,+16                 ; 004117 01 10 B8
    ld de,+$80                   ; 00411A 11 80 00
    ld iy,NameEntryCursorY       ; 00411D FD 21 85 C7
    jr _NameEntryNoButtonPressed_DoneWithInput
_DownHeld:
    ld a,24
    ld (NameEntryKeyRepeatCounter),a
    jr -                         ; 004128 18 ED

_LeftNew:
    call _DecrementKeyRepeatCounter ;412A CD 7B 41
    ret nz                       ; 00412D C0
-:  ldbc $28,-8                  ; 00412E 01 F8 28
    ld de,-2                     ; 004131 11 FE FF
    ld iy,NameEntryCursorX       ; 004134 FD 21 84 C7
    jr _NameEntryNoButtonPressed_DoneWithInput
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

    cp $4e                       ; 00415D FE 4E      ; check if it was a control char, in which case snap to its left char
    ret c                        ; 00415F D8


    ld c,$88                     ; 004160 0E 88      ; values for jump to Next ($4e)
    ld hl,$d5a2                  ; 004162 21 A2 D5
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


; decrement keypress repeat counter, set to 5 if zero
_DecrementKeyRepeatCounter: ; 417b
    ld hl,$c789                  ; 00417B 21 89 C7
    dec (hl)                     ; 00417E 35
    ret nz                       ; 00417F C0
    ld (hl),$05                  ; 004180 36 05
    ret                          ; 004182 C9

LoadNameEntryScreen: ; $4183
    call FadeOutFullPalette      ; 004183 CD A8 7D   ; go to name entry screen

    TileMapAddressDE 0,0         ; 004186 11 00 78   ; clear name table
    ld bc,$0300                  ; 004189 01 00 03
    ld hl,$0000                  ; 00418C 21 00 00
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

    ldbc 2,16                    ; 0041CA 01 10 02   ; ld bc,$0210
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
    ld hl,_NameEntryCursorSprite ; 0041F8 21 76 43
    ld bc,32                     ; 0041FB 01 20 00   ; load cursor sprite
    di                           ; 0041FE F3
      call OutputToVRAM          ; 0041FF CD DE 03
    ei                           ; 004202 FB

    ld de,NameEntryCursorX       ; 004203 11 84 C7
    ld hl,_NameEntryCursorInitialValues ; 004206 21 21 42
    ld bc,_NameEntryCursorInitialValuesEnd-_NameEntryCursorInitialValues ; load cursor initial values
    ldir                         ; 00420C ED B0

    xor a                        ; 00420E AF         ; zero some stuff
    ld (VScroll),a               ; 00420F 32 04 C3
    ld (HScroll),a               ; 004212 32 00 C3
    ld (TextBox20x6Open),a       ; 004215 32 D3 C2

    ld de,$8006                  ; 004218 11 06 80
    di                           ; 00421B F3
    SetVRAMAddressToDE           ; 00421C CF
    ei                           ; 00421D FB
    jp ClearSpriteTableAndFadeInWholePalette         ; and ret



_NameEntryCursorInitialValues: ; 4221
.db $28 ; selected char cursor sprite X
.db $68 ; selected char cursor sprite Y
.dw $D30A ; selected char TileMapData address (5, 12)
.db $01 ; currently pointed char
_NameEntryCursorInitialValuesEnd:


_DrawCursorSprites: ; 4226
; sets sprites for cursors
    call _GetTileMapDataAddressForCharAInHL          ; get address of editing char tile for "current tile" indicator
    ld de,$3040                  ; 004229 11 40 30   ; $3000 means it'll wipe out the $D000 prefix, $40 is because we want a constant offset of 1 row (the cursor is exactly below the relevant tile)
    add hl,de                    ; 00422C 19         ; add them on and multiply by 4 to get h = row number + 1, l = pixel x coordinate
    add hl,hl                    ; 00422D 29
    add hl,hl                    ; 00422E 29
    ld de,SpriteTable            ; 00422F 11 00 C9
    ld a,h                       ; 004232 7C         ; now a = row number in tilemap, but for a sprite it's a pixel count -> multiply by 8
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
    ld bc,$0300                  ; 00424F 01 00 03   ; b = maximum width of cursor (3), c = sprite number for cursor (0)
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
    ld hl,NameEntryCharIndex     ; 004261 21 81 C7
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
    ld l,a                       ; 004292 6F         ; hl += a*2, now points to TileMapData address for currently editing char

    ld a,c                       ; 004293 79
    rra                          ; 004294 1F
    rra                          ; 004295 1F         ; a /= 4
    and $06                      ; 004296 E6 06      ; now it'll be 0, 2 or 4 for each of the 3 sections of the row
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
      ld hl,-$40                 ; 0042AE 21 C0 FF
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
    SetVRAMAddressToDE           ; 0042BE CF
    ld a,b                       ; 0042BF 78
    out (VDPData),a              ; 0042C0 D3 BE      ; write lower part
    ld hl,-$40                   ; 0042C2 21 C0 FF
    add hl,de                    ; 0042C5 19
    ex de,hl                     ; 0042C6 EB
    SetVRAMAddressToDE           ; 0042C7 CF
    ld a,c                       ; 0042C8 79
    out (VDPData),a              ; 0042C9 D3 BE      ; write upper part
    ret                          ; 0042CB C9

; Decompress data from NameEntryTilemapData to TileMapData(0,6)
DecompressNameEntryTilemapData: ; $42cc
    ld hl,NameEntryTilemapData   ; 0042CC 21 06 44
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
    ld de,$f301                  ; 004305 11 01 F3   ; tile data to write (vertical bar, left)
    call _DrawVerticalLine       ; 004308 CD 28 43

    inc hl                       ; 00430B 23
    ldbc $1d,5                   ; 00430C 01 05 1D   ; flip bottom edge vertically
    call _SetLineFlip            ; 00430F CD 35 43

    ld (hl),$07                  ; 004312 36 07      ; flip bottom-right corner
    ld hl,$d0fd                  ; 004314 21 FD D0   ; (30,3)
    ld (hl),$03                  ; 004317 36 03      ; flip top-right corner
    ld hl,$d0c3                  ; 004319 21 C3 D0   ; (1,3)
    ldbc $1d,1                   ; 00431C 01 01 1D   ; no flip on top edge, but it's still the high tileset
    call _SetLineFlip            ; 00431F CD 35 43
    ld hl,$d13c                  ; 004322 21 3C D1   ; (1,7)
    ld de,$f303                  ; 004325 11 03 F3   ; vertical bar, right
    ; fall through

_DrawVerticalLine: ; 4328
; draws data de to address hl every 32 words, for a rows
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
; unused, does nothing? ##################
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
; no tile flipping data, that's fixed up in code
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

    SetPage PaletteSpace
    ld hl,PaletteSpace
    ld de,TargetPalette
    ld bc,PaletteSpaceEnd-PaletteSpace
    ldir               ; Load palette

    ld hl,TilesSpace
    TileAddressDE 0    ; tile 0
    call LoadTiles4BitRLE

    SetPage TilemapSpace
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

  -:ld a,$0e           ; VBlankFunction_OutsideScrolling
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

  +:xor a              ; zero ScrollDirection and ScrollScreens
    ld (ScrollDirection),a
    ld (ScrollScreens),a
    call FadeOutFullPalette
    ld a,$08
    ld (SceneType),a    ; Palma Town
    call LoadSceneData

    SetPage TilesFont

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

    SetPage IntroBox1
    ld hl,IntroBox1
    TileMapAddressDE 3,2
    ld bc,IntroBox1Dimensions
    call OutputTilemapBoxWipe

    call Pause3Seconds
    call FadeToPictureFrame

    ld a,$00
    call FadeToNarrativePicture

    ld hl,TextIntro1      ; You little bastard - poking your nose into LaShiec's business like that!
    call ShowNarrativeText ; Maybe from now on you'll try to mind your manners!
                          ; Nero! What happened?! Hang on!

    ld a,$01
    call FadeToNarrativePicture

    ld hl,TextIntro2      ; ...Alisa... listen...
    call ShowNarrativeText ; ...LaShiec has brought an enormous calamity upon our world...
                          ; ...The world is facing ruin...
                          ; ...I tried to find out what LaShiec is planning...
                          ; ...But by myself, I wasn't able to do anything...
                          ; ...I heard rumors of a mighty warrior named 'Tairon' during my journey...
                          ; ...If you combine forces, you might be able to defeat LaShiec... and restore peace...
                          ; ...Alisa...
                          ; ...It¨s too late for me...
                          ; ...Please forgive me... for leaving you alone...

    ld a,$02
    call FadeToNarrativePicture

    ld hl,TextIntro3      ; I will go and fight to ensure that my brother did not die in vain!
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
  +:ld (VScroll),a
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
.orga $467b

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $48d7
.section "Load picture frame" overwrite
FadeToPictureFrame:      ; $48d7
    call FadeOutFullPalette

    SetPage TilesFont  ; load font
    ld hl,TilesFont
    TileAddressDE $c0
    call LoadTiles4BitRLE

    ld hl,TilesExtraFont
    TileAddressDE $1f0
    call LoadTiles4BitRLE

    SetPage PaletteFrame

    ld hl,TargetPalette
    ld de,TargetPalette+1
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

        SetPage NarrativeTilemaps ; while we've got hl free
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

_NarrativeGraphicsLookup: ; page, palette+tiles offset, raw tiles offset
 NarrativeGraphicsData IntroNero1
 NarrativeGraphicsData IntroNero2
 NarrativeGraphicsData IntroAlis
 NarrativeGraphicsData Alis
 NarrativeGraphicsData Myau
 NarrativeGraphicsData Odin
 NarrativeGraphicsData Noah
 NarrativeGraphicsData MyauWings1
 NarrativeGraphicsData MyauWings2
.ends
.orga $49a6

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

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
fn59ca:                ; $59ca
    ld hl,_text        ; Dunno what it says
    call TextBox20x6
    jp Close20x6TextBox
_text:
.db $1f $3d $00 $49 $2b $35 $27 $21 $33 $00 $40 $07 $13 $02 $1f $0e $2e $4c $58
; MaDa PuRoGuRaMuGa DeKiTeIMaSeN.[Exit after button press]
; The program is not made yet.
; or
; This feature hasn't been coded yet.
.ends
; followed by
.orga $59e6
.section "Sort sprite entity table and update sprite table" overwrite
SpriteHandler:         ; $59e6
    ld hl,xc289
    ld (xc289Pointer),hl ; Set xc289Pointer to xc289 (first entry)
    ld de,xc289+2
    ld bc,$e
    ld (hl),$00
    inc hl
    ld (hl),$ff
    dec hl
    ldir               ; Fill xc289 with $00, $ff

    ld hl,SpriteTable
    ld (NextSpriteY),hl ; Set NextSpriteY to first entry
    ld hl,SpriteTable+$80
    ld (NextSpriteX),hl ; Set NextSpriteX to first entry
    ld iy,CharacterSpriteAttributes
    ld bc,$0800        ; b = 8, c = 0
  -:ld a,(iy+$00)      ; CharacterSpriteAttributes+00 = ???
    and $7f            ; strip high bit
    jr z,+             ; if rest is 0 then skip -------------------------+
    push bc            ;                                                 |
        ld hl,FunctionLookup5aa3-2 ;                                     |
        call FunctionLookup ;                                            |
    pop bc             ;                                                 |
    or a               ; if result == 0 then skip again -----------------+
    jp z,+             ;                                                 |
    ld hl,(xc289Pointer) ;                                               |
    ld a,(iy+2)        ; CharacterSpriteAttributes+2 = ???               |
    ld (hl),a          ; Copy to hl                                      |
    inc hl             ;                                                 |
    ld (hl),c          ; 0?                                              |
    inc hl             ;                                                 |
    ld (xc289Pointer),hl ; Update xc289Pointer                           |
  +:ld de,32           ;                                 <---------------+
    add iy,de          ; Move iy to next CharacterSpriteAttributes
    inc c              ; and inc c
    djnz -             ; repeat 8 times???

    ld de,xc289        ; Sort xc289 into increasing numerical order by 1st byte in each entry (?)
    ld b,3             ; counter
 --:push bc            ; <-----------------------------+
        ld l,e         ; hl = de                       |
        ld h,d         ;                               |
        inc hl         ; hl = de+2                     |
        inc hl         ;                               |
      -:ld a,(de)      ; <---------------------------+ |
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
      +:inc hl         ; move hl forward 1 word      | |
        inc hl         ;                             | |
        djnz -         ; repeat 3 times -------------+ |
        inc de         ; then move de forward 1 word   |
        inc de         ;                               |
    pop bc             ;                               |
    djnz --            ; and repeat 3 times -----------+

    ld hl,xc289+1      ; second byte in xc289 entry 0
    ld b,8             ; counter (number of entries in xc289)
  -:ld a,(hl)          ; If (hl)==$ff then skip:
    cp $ff
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
      +:ld (Frame2Paging),a ; Set page
        call UpdateSprites
    pop hl
    pop bc
 ++:inc hl             ; Move to next entry in xc289
    inc hl
    djnz -             ; and repeat
    ld hl,(NextSpriteY)
    ld (hl),208        ; Set last sprite y to 208 = no more sprites
    ret
.ends
; followed by
.orga $5a94
.section "Zero iy structure +1 to +31" overwrite
ZeroIYStruct: ; $5a94
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
; followed by
.orga $5aa3
.section "Unknown function lookup table" overwrite
FunctionLookup5aa3:        ; $5aa3
.dw $5c1b
.dw $5c50
.dw $5c5c
.dw $5c61
.dw $5c6d
.dw $5c72
.dw $5c7e
.dw $5c83
.dw $5ccb
.dw $5cec
.dw $5e03
.dw $5e4a
.dw $5edf
.dw $5f15
.dw $601c
.dw $60a7
.dw $60aa
.dw $60ee
.dw $612a
.dw $6166
.dw $5fac
.dw $5fd7
.ends
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
      -:ld a,(hl)
        add a,c
        ld (de),a      ; set (de) to next byte + sprite base y
        inc de
        inc hl
        djnz -         ; repeat
        ld (NextSpriteY),de  ; Update NextSpriteY
    pop bc
    ld de,(NextSpriteX)
    ld c,(iy+4)        ; Character sprites base X position
  -:ld a,(hl)          ; repeat with x positions and tile numbers of sprites
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
    SetVRAMAddressToDE
    ld c,VDPData
    call outi64
    ld hl,SpriteTable+$80
    ld de,SpriteTableAddress+$80
    SetVRAMAddressToDE
.ends
; depends on being followed by
.orga $5b1a
.section "outi block" overwrite
; outi instruction 128/64/32 times to output 128/64/32 bytes
outi128:               ; $5b1a
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
fn5c1b:
    ld b,$01
_5c1d:
    push bc
        call ZeroIYStruct
        inc (iy+0)
    pop bc
    ld (iy+2),$60      ; ???
    ld a,(xc2ea)
    and $03            ; if xc2ea is a multiple of 4
    ld a,$84           ; then a=$84
    jr nz,+
    ld a,$80           ; else a=$80
  +:ld (iy+$04),a
    ld (iy+$12),$01
    ld (iy+$01),b      ; depends on lookup function
    ld (iy+$11),$01
    ld a,c             ; 005C42 79
    or a               ; 005C43 B7
    ld a,$00           ; 005C44 3E 00
    jr nz,+
    ld a,$03           ; 005C48 3E 03
  +:ld (iy+$0a),a      ; 005C4A FD 77 0A
    ld a,$ff           ; 005C4D 3E FF
    ret                ; 005C4F C9
.ends
.orga $5c50

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $627a
.section "Enemy data loader" overwrite
LoadEnemy:             ; $627a
    ld hl,Frame2Paging
    ld (hl),$03        ; for enemy data

    ld hl,CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes+1
    ld bc,255
    ld (hl),$00
    ldir               ; blank CharacterSpriteAttributes

    ld hl,CharacterStatsEnemies
    ld de,CharacterStatsEnemies+1
    ld bc,127
    ld (hl),$00
    ldir               ; blank CharacterStatsEnemies (128 bytes)

    ld a,(EnemyNumber)
    ld a,a             ; ################
    and $7f
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

    ld de,xc258
    ld bc,8
    ldir               ; Next 8 bytes -> xc258

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
    ld a,:data8fdf
    ld (Frame2Paging),a
    ld a,(hl)          ; a = next byte
    push hl
        call fndata8fdfloader
    pop hl
    inc hl
    ld a,$3            ; reset paging
    ld (Frame2Paging),a
    ld a,(hl)          ; a = next byte
    bit 7,a            ; if bit 7 set then skip next block
    jr nz,+            ; ------------------------------+
    and $f             ;                               |
    ld b,a             ; low nibble -> b               |
    ld a,(xc4f0)       ; get xcf40                     |
    inc a              ; add 1                         |
    add a,a            ; and double                    |
    cp b               ;                               |
    jr nc,_f           ;                               |
    ld b,a             ; if (xc4f0+1)*2<b then b=that  |
 __:call GetRandomNumber ;                             |
    and 7              ;                               |
    cp b               ;                               |
    jp nc,_b           ; get a random number <b        |
    inc a              ; add 1                         |
  +:and $f             ; <-----------------------------+
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
      -:ld (ix+0),1    ; alive = 1
        ld (ix+1),a    ; HP = a
        ld (ix+6),a    ; Max HP = a
        ld (ix+8),h    ; Attack = h
        ld (ix+9),l    ; Defence = l
        add ix,de      ; repeat for each enemy
        djnz -
    pop hl
    ld a,(hl)          ; next byte in xc2df
    ld (xc2df),a
    inc hl             ; next word in de
    ld e,(hl)
    inc hl
    ld d,(hl)
    push hl
        ld a,(NumEnemies)
        ld c,a
        ld b,$00
        call Multiply16
        ld (xc2dd),hl  ; xc2dd = NumEnemies*de
    pop hl
    inc hl
    ld a,(hl)          ; Next byte in xc2e0
    ld (xc2e0),a
    inc hl             ; next word in de
    ld e,(hl)
    inc hl
    ld d,(hl)
    push hl
        ld a,(NumEnemies)
        ld c,a
        ld b,$00
        call Multiply16
        ld (xc2d0),hl  ; xc2d0 = NumEnemies*de
    pop hl
    inc hl
    ld a,(hl)
    ld (xc2e8),a       ; Next byte in xc2e8
    inc hl
    ld a,(hl)
    ld (xc2e7),a       ; Next byte in xc2e7

    ld hl,$c500
    ld ($c2e1),hl      ; $c500 -> xc2e1

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
fndata8fdfloader:      ; $6379
; loads ath data from structures at data8fdf
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    ld e,l
    ld d,h
    add hl,hl
    add hl,de
    ld de,data8fdf-24
    add hl,de          ; hl = $8fc7 + a*24

    ld de,$c880
    ld bc,3
    ldir               ; Copy 3 bytes from there to $c880

    inc de             ; skip 1 byte
    ldi                ; and copy 1 more

    ld de,$c894
    ld bc,9
    ldir               ; next 9 to $c894

    ld a,($c898)
    ld ($c88e),a       ; copy $c898 to $c88e

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
        ld h,(hl)      ; data: cbedah
        ld l,c         ;       l
        ld c,a         ;           c
        ld a,h         ;            a
        ld h,b         ;        h
        ld b,a         ;            b
                       ; hl = bc; bc = ah
        or c           ; test c
        ld a,$18       ; page for ???
        ld (Frame2Paging),a
        call nz,_DataCopier ; if c!=0 then call _DataCopier
    pop hl
    inc hl

    ld a,$03           ; Reset paging
    ld (Frame2Paging),a

    ld de,$c8a0
    ld bc,3
    ldir               ; Next 3 bytes -> $ca80
    inc de             ; skip 1
    ldi                ; copy 1
    ld a,(hl)
    ld ($c2f1),a       ; next byte -> $c2f1
    ret

_DataCopier:           ; $63d6
; Copies data from hl to de
; data format: fdd
; if f=0 then dd is skipped
; parses b data blocks (? does ldi dec b?)
; then adds 64 to original value of de
; repeats c times
 --:push bc
        push de
            ld c,$ff
          -:ld a,(hl)
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $6471
.section "Load character animation tiles" overwrite
; Load raw character animation tiles from ROM
AnimCharacterSprites:  ; $6471
    SetPage CharacterSprites
    ld ix,CharacterSpriteAttributes
    ld b,4             ; counter - only first 4
  -:ld a,(ix+16)       ; if 16 bytes after (currentanimframe)
    cp (ix+17)         ; != 17 bytes after (lastanimframe)
    jp z,+             ; then:
    ld (ix+17),a           ; make it equal
    ld d,a                 ; save in d
    ld a,(ix+$01)          ; get 1 byte after = character number
    or a                   ; set flags with it (why?) ###############
    ld hl,_FunctionTable-2 ; -2 because 0 is not used
    jp nz,FunctionLookup
  +:ld de,32           ; move to next data
    add ix,de
    djnz -
    ret
_FunctionTable:
.dw _Alis
.dw _Noah
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
    SetVRAMAddressToDE
    ld c,VDPData
    call outi128       ; output 192 bytes = 6 tiles
    jp outi64          ; and ret

_Noah:                 ; $64c2
    ld e,$00
    srl d
    rr e
    ld l,e
    ld h,d
    srl d
    rr e
    add hl,de
    ld de,NoahSprites
    add hl,de          ; hl = NoahSprites + (ix+$10)*192
    ld de,$7600        ; tile $1b0
    SetVRAMAddressToDE
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
    add hl,de          ; hl = NoahSprites + (ix+$10)*192
    ld de,$76c0        ; tile $1b6
    SetVRAMAddressToDE
    ld c,VDPData
    call outi128       ; output 192 bytes = 6 tiles
    jp outi64          ; and ret

_Myau:                 ; $64fc
    ld e,$00
    srl d
    rr e
    ld hl,MyauSprites
    add hl,de          ; hl = MyauSprite + (ix+$10)*128
    ld de,$7780        ; tile $1bc
    SetVRAMAddressToDE
    ld c,VDPData
    jp outi128         ; output 128 bytes = 4 tiles and ret

_Vehicle:              ; $650f
    ld a,(FunctionLookupIndex)
    cp $05             ; if FunctionLookupIndex==5 or 9 then pass
    jr z,+
    cp $09
    ret nz
  +:SetPage VehicleSprites
    ld l,$00
    ld h,d
    add hl,hl          
    ld de,VehicleSprites
    add hl,de          ; hl = VehicleSprites + (ix+$10)*512
    ld de,$7540        ; tile $1aa
    SetVRAMAddressToDE
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
    SetPage TilesOutsideAnimation

    ld hl,OutsideAnimCounters+4*0
    ld de,_AnimSeaShoreFrames
    ld bc,(12 << 8) | ($04*4) ; 12 tiles, tile $04
    call _CountAndAnimate

    ld hl,OutsideAnimCounters+4*1
    ld de,_AnimSeaFrames
    ld bc,( 3 << 8) | ($10*4) ; 3 tiles, tile $10
    call _CountAndAnimate

    ld hl,OutsideAnimCounters+4*2
    ld de,_AnimSmokeFrames
    ld bc,( 4 << 8) | ($13*4) ; 4 tiles, tile $13
    call _CountAndAnimate

    ld hl,OutsideAnimCounters+4*3
    ld de,_AnimRoadwayFrames
    ld bc,( 6 << 8) | ($17*4) ; 6 tiles, tile $17
    call _CountAndAnimate

    ld hl,OutsideAnimCounters+4*4
    ld de,_AnimLavaPitFrames
    ld bc,( 8 << 8) | ($1d*4) ; 8 tiles, tile $1d
    call _CountAndAnimate

    ld hl,OutsideAnimCounters+4*5
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
    ld a,(xc2e9)
    cp $04             ; if xc2e9>=4
    jr c,+
    dec (hl)           ; then decrement Counter
    jr ++
  +:inc (hl)           ; else increment Counter
 ++:ld a,(hl)
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
    SetVRAMAddressToDE
    ld c,VDPData
    ld a,b             ; counter = b = number of tiles
 --:ld b,$20           ; counter = 32 bytes = 1 tile
  -:outi               ; output from hl to (c)
    nop                ; delay
    jp nz,-
    dec a
    jp nz,--
    pop hl             ; why?
    ret

_AnimSeaShoreFrames:   ; $65c1
.dw TilesOutsideSeaShore+12*32*0 ; 12 tiles x 32 bytes per tile x frame number
.dw TilesOutsideSeaShore+12*32*0
.dw TilesOutsideSeaShore+12*32*1
.dw TilesOutsideSeaShore+12*32*2
.dw TilesOutsideSeaShore+12*32*2
.dw TilesOutsideSeaShore+12*32*1
.dw TilesOutsideSeaShore+12*32*3
.dw TilesOutsideSeaShore+12*32*4
_AnimSeaFrames:        ; $65d1
.dw TilesOutsideSea+3*32*0 ; 3 tiles x 32 bytes per tile x frame number
.dw TilesOutsideSea+3*32*0
.dw TilesOutsideSea+3*32*1
.dw TilesOutsideSea+3*32*1
.dw TilesOutsideSea+3*32*2
.dw TilesOutsideSea+3*32*2
.dw TilesOutsideSea+3*32*3
.dw TilesOutsideSea+3*32*3
_AnimSmokeFrames:      ; $65e1
.dw TilesSmoke+4*32*0  ; 4 tiles x 32 bytes per tile x frame number
.dw TilesSmoke+4*32*0
.dw TilesSmoke+4*32*1
.dw TilesSmoke+4*32*1
.dw TilesSmoke+4*32*2
.dw TilesSmoke+4*32*2
.dw TilesSmoke+4*32*1
.dw TilesSmoke+4*32*1
_AnimRoadwayFrames:    ; $65f1
.dw TilesRoadway+6*32*0 ; 6 tiles x 32 bytes per tiles x frame number
.dw TilesRoadway+6*32*0
.dw TilesRoadway+6*32*1
.dw TilesRoadway+6*32*1
.dw TilesRoadway+6*32*2
.dw TilesRoadway+6*32*2
.dw TilesRoadway+6*32*3
.dw TilesRoadway+6*32*3
_AnimLavaPitFrames:    ; $6601
.dw TilesLavaPit+8*32*0 ; 8 tiles x 32 bytes per tile x frame number
.dw TilesLavaPit+8*32*0
.dw TilesLavaPit+8*32*1
.dw TilesLavaPit+8*32*1
.dw TilesLavaPit+8*32*2
.dw TilesLavaPit+8*32*2
.dw TilesLavaPit+8*32*1
.dw TilesLavaPit+8*32*1
_AnimAntlionHillFrames: ; $6611
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
  +:ld (hl),a
    SetPage TilesAnimSea
    ld hl,AnimSeaWaveInFrames ; table
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
    cp $0e
    jr c,+             ; if not <14
    xor a              ; then zero -> 0-13
  +:ld (hl),a
    SetPage TilesAnimSea
    ld hl,AnimSeaInOutFrames ; table
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
        SetVRAMAddressToDE
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
          -:outi       ; Output 128 bytes from table to VDPData (4 tiles)
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
  +:ld (hl),a
    SetPage TilesBubblingStuff
    add a,a
    ld b,a
    add a,a
    add a,b
    ld e,a             ; AnimFrameCounter*6
    ld d,$00
    ld hl,AnimLavaPitFrames
    add hl,de          ; AnimLavaPitFrames + AnimFrameCounter*6
    ld de,$4020        ; tile 1
    SetVRAMAddressToDE
    ld b,$04           ; number of sets of tiles
 --:push bc
        ld d,(hl)      ; get word which was looked up
        inc hl
        ld e,$00
        srl d
        rr e           ; Multiply by 128
        ld bc,TilesBubblingStuff ; Add to BubblingStuffTiles
        ex de,hl
        add hl,bc
        ld bc,$80be    ; output 128 bytes (4 tiles) to VDPData
      -:outi
        jp nz,-
    pop bc
    ex de,hl           ; get back hl = offset
    djnz --            ; loop
    ld b,$02           ; and 2 more seta of tiles...
 --:push bc
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
      -:outi
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
    SetVRAMAddressToDE
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
  -:outi               ; output
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
    SetVRAMAddressToDE
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
  -:outi               ; output
    jp nz,-
    ld hl,UnknownPalette+8
    add hl,de          ; and again (?)
    ld b,$04
  -:outi
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

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
    jp m,+             ; if bit 8 is set then ---------------+ |
                       ; else:                               | |
    ld c,a             ; put it in c -> bc = data count      | |
    inc hl             ; move hl pointer to next byte (data) | |
  -:ldi                ; copy 1 byte from hl to de, <------+ | |
                       ; inc hl, inc de, dec bc            | | |
    dec hl             ; move hl pointer back (RLE)        | | |
    inc de             ; skip dest byte                    | | |
    jp pe,-            ; if bc!=0 then repeat -------------+ | |
    inc hl             ; move past RLE'd byte                | |
    jp _b              ; repeat -----------------------------|-+
  +:and $7f            ; (if bit 8 is set:) unset it <-------+ |
    ld c,a             ; put it in c -> bc = data count        |
    inc hl             ; move hl pointer to next byte (data)   |
  -:ldi                ; copy 1 byte from hl to de, <--------+ |
                       ; inc hl, inc de, dec bc              | |
    inc de             ; skip dest byte                      | |
    jp pe,-            ; if bc!=0 then repeat ---------------+ |
    jp _b              ; repeat -------------------------------+
.ends
.orga $6e31

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $74e0
.section "Decompress (scrolling tilemap?) data to xcc00-xcfff" overwrite
DecompressScrollingTilemapData: ; $74e0
    ld a,(xc262)
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
    ld hl,(xc260)
    add hl,de          ; hl = xc260 + VLocation high byte * 18 + HLocation high byte * 2
    ld a,(hl)          ;    = pos
    inc hl
    push hl
        ld h,(hl)
        ld l,a         ; hl = word there (pos+0,1) = compressed data offset
        ld de,xcc00
        call _DecompressToDE
    pop hl
    push hl
        inc hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a         ; hl = next word (pos+2,3) = next compressed data offset
        ld de,xcd00
        call _DecompressToDE
    pop hl
    ld de,17
    add hl,de
    ld a,(hl)
    inc hl
    push hl
        ld h,(hl)
        ld l,a         ; hl = 17 bytes later = pos+20,21
        ld de,xce00
        call _DecompressToDE
    pop hl
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a             ; hl = next word = pos+22,23
    ld de,xcf00
    ; fall through
_DecompressToDE:
    ld b,$00
 --:ld a,(hl)          ; get header <--------------------------+
    or a               ;                                       |
    ret z              ; exit when zero                        |
    jp m,+             ; If high bit is set ----------------+  |
    ld b,a             ; b = count                          |  |
    inc hl             ;                                    |  |
    ld a,(hl)          ; get data                           |  |
  -:ld (de),a          ; copy to de  <-----------+          |  |
    inc de             ; (RLE)                   |          |  |
    djnz -             ; repeat b times ---------+          |  |
    inc hl             ; move to next header                |  |
    jp --              ; -----------------------------------|--+
  +:and $7f            ; Strip high bit --------------------+  |
    ld c,a             ; c = count                             |
    inc hl             ; next data                             |
    ldir               ; copy c bytes to de (not RLE)          |
    jp --              ; --------------------------------------+
.ends
.orga $7549

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $7673
.section "Update scrolling tilemap" overwrite
; Update scrolling tilemap
UpdateScrollingTilemap: ; $7673
    ld a,(ScrollDirection) ; check ScrollDirection (%----RLDU)
    and $0f
    ret z              ; return if not scrolling
    ld b,a             ; b = ScrollDirection
    and $03
    ld a,(xc263)
    ld (Frame2Paging),a ; Set to page xc263 - why?
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
  +:ld a,(HLocation)
    add a,c            ; a = low HLocation + c (0 or 8)
    rrca               ; shift right by 2 (ie. divide by 4)
    rrca
    and %00111110
    ld e,a
    ld l,a
    ld d,$78           ; de = tilemap     + (low HLocation + c)/4
    ld h,$d0           ; hl = TileMapData + (low HLocation+ c)/4
    ld bc,$1cbe        ; counter = $1c = 28 rows; c = VDPData
  -:push bc
        SetVRAMAddressToDE
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
  +:ld b,$c0           ; b = $c0
    add a,b            ; a = VScroll + $c0 + ($20 if VScroll>=$20)
 ++:and %11111000      ; zero low 3 bits -> now it's the offset into the RAM tilemap
    ld l,a             ; put in hl
    ld h,$00
    add hl,hl          ; multiply by 8
    add hl,hl
    add hl,hl
    ld a,h
    add a,$78
    ld d,a             ; de = tilemap + a*8
    ld e,l
    SetVRAMAddressToDE
    ld a,h
    add a,$d0
    ld h,a             ; hl = TileMapData + a*8
    ld bc,$40be        ; counter = $40 = 64 bytes = 32 tiles; c = VDPData
  -:outi               ; output byte
    nop                ; delay
    jp nz,-
    ret
.ends
; followed by
.orga $76ee
.section "Fill tilemap from compressed data? Not understood :(" overwrite
FillTilemap:          ; $76ee
    call fn78a5       ; ???
    ld a,(xc263)
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
    add a,$d0
    ld d,a             ; de = $d000+hl

    ld a,(VLocation)
    and $f0            
    ld l,a
    ld a,(HLocation)
    rrca
    rrca
    rrca
    rrca
    and $0f
    add a,l
    ld l,a
    ld h,$cc           ; hl = $ccyn where y = high nibble of y location, x = high nibble of x location

    ld b,$0c           ; counter (12)
 --:push bc
        push hl
            ld b,$10   ; counter (16)
          -:push bc
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
                    and $3f
                    jr nz,+            ; If e is a multiple of $40
                    ld a,e             
                    sub $40            ; then subtract $40
                    ld e,a
              +:pop hl
                ld a,l
                and $f0                
                ld b,a                 ; b = high nibble of l
                inc l                  
                ld a,l                 
                and $f0                
                cp b                   ; if adding 1 doesn't change the high nibble (so low=$f???)
                jr z,+
                inc h                  ; inc h
                ld l,b                 ; and strip l to high nibble
          +:pop bc     
            djnz -     ; repeat 16 times
            
            ld a,$80
            add a,e
            ld e,a
            adc a,d
            sub e      ; de = de + $80
            sub $d7    ; if de < $d700
            jr nc,+
            add a,$07  ; then subtract $d000
          +:add a,$d0  ; else subtract $0700
            ld d,a
        pop hl
        ld a,$10       ; add 16 to l
        add a,l
        cp $c0         ; when it exceeds 192
        jr c,+
        sub $c0        ; subtract 192
        inc h          ; and add 2 to h
        inc h
      +:ld l,a
    pop bc             
    djnz --            ; repeat 12 times
    ld a,$12           ; refresh full tilemap
    jp ExecuteFunctionIndexAInNextVBlank ; and ret
.ends
.orga $7787

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $78a5
.section "fn78a5 (???)" overwrite
fn78a5:                ; $78a5
    ld a,(xc308)
    cp $02
    ret nz             ; Only do this if xc308==2
    ld a,(xc30e)
    cp $0c             ; and xc30e==$c
    ret nz
    ld a,$0a
    call +
    ld a,$0c
    call +
    ld a,$12
    call +
    ld a,$14
    ; fall through
  +:ld hl,Table7d30
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a             ; hl = Table7d30 + a
    ld c,(hl)
    inc hl
    ld b,(hl)          ; bc = (hl) = x,y to add?
    ld h,$cc
    ld a,(VLocation)
    add a,c            ; a=lo(VLocation)+c
    jr c,+
    cp $c0             ; if a is between $c0 and $ff then it's OK (?)
    jr c,++
  +:add a,$40          ; if a is >=$100 (borrow) then add $40
    inc h
    inc h              ; and add 2 to h -> $ce
 ++:and $f0            ; Strip a to high nibble
    ld l,a             ; -> l
    ld a,(HLocation)
    add a,b            ; Add b to lo(HLocation)
    jr nc,+
    inc h              ; if it's over $100 then hl++
  +:rrca
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
.ends
.orga $78f9

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $7a07
.section "Get data from a table based on the current H/VLocation" overwrite
GetLocationUnknownData: ; $7a07
    ld hl,Table7d30
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a             ; hl = Table7d30 + a
    ld c,(hl)
    inc hl
    ld b,(hl)          ; bc = word there
    ld h,$cc
    ld a,(VLocation)   ; a = c + lo(VLocation)
    add a,c
    jr c,+             ; if a>$ff
    cp $c0
    jr c,++            ; or <=$c0
  +:add a,$40          ; then add $40
    inc h              ; and add 2 to h -> $ce
    inc h
 ++:and $f0            ; strip to high nibble
    ld l,a             ; and keep in l
    ld a,(HLocation)   ; Add b to lo(HLocation)
    add a,b
    jr nc,+            ; if >$ff
    inc h              ; then inc h
  +:rrca
    rrca
    rrca
    rrca
    and $0f            ; divide by 16
    add a,l            ; put in l
    ld l,a
    ld a,(hl)          ; get data
    ld (xc2e5),a       ; put that in xc2e5
    ld hl,Frame2Paging
    ld (hl),$03        ; ???
    ld hl,$bc6f        ; table
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a             ; hl = bc6f + a
    ld a,(xc308)
    cp 4
    jr c,+
    inc h              ; if xc308>=4 then inc h (add 256)
  +:ld a,(hl)          ; get data in a
    ret
.ends
.orga $7a4f

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $7b1e
.section "???" overwrite
fn7b1e: ; $7b1e
    ld a,(hl)          ; get byte at hl (eg 01)
    ld (xc308),a       ; save in xc308 nd xc309
    ld (xc309),a
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
  +:sub $40            ; subtract $40
    dec h              ; and take 1 from h
 ++:ld l,a             ; Put it back in hl
    ld a,h
    and $07            ; trim to 00000hhh
    ld h,a
    ld (VLocation),hl
    ld (xc311),hl
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
    ld (xc313),hl
    xor a              ; zero xc30e
    ld (xc30e),a
    jp +++

fn7b60:
    cp $0a             ; 007B60 FE 0A
    jp nz,+
    ld (FunctionLookupIndex),a       ; 007B65 32 02 C2
    inc hl              ; 007B68 23
    ld d,(hl)          ; 007B69 56
    inc hl              ; 007B6A 23
    ld e,(hl)          ; 007B6B 5E
    ld ($c30c),de      ; 007B6C ED 53 0C C3
    inc hl              ; 007B70 23
    ld a,(hl)          ; 007B71 7E
    ld ($c30a),a       ; 007B72 32 0A C3
    ld hl,($c311)      ; 007B75 2A 11 C3
    ld ($c305),hl      ; 007B78 22 05 C3
    ld hl,($c313)      ; 007B7B 2A 13 C3
    ld ($c301),hl      ; 007B7E 22 01 C3
    xor a               ; 007B81 AF
    ld ($c30e),a       ; 007B82 32 0E C3
    jp +++
  +:cp $0c             ; 007B88 FE 0C
    ret nz              ; 007B8A C0
    ld (FunctionLookupIndex),a       ; 007B8B 32 02 C2
    inc hl              ; 007B8E 23
    ld a,(hl)          ; 007B8F 7E
    ld ($c29e),a       ; 007B90 32 9E C2
    inc hl              ; 007B93 23
    ld a,(hl)          ; 007B94 7E
    inc hl              ; 007B95 23
    ld h,(hl)          ; 007B96 66
    ld l,a             ; 007B97 6F
    ld ($c2db),hl      ; 007B98 22 DB C2
    xor a               ; 007B9B AF
    ld ($c29d),a       ; 007B9C 32 9D C2
    ld hl,($c311)      ; 007B9F 2A 11 C3
    ld ($c305),hl      ; 007BA2 22 05 C3
    ld hl,($c313)      ; 007BA5 2A 13 C3
    ld ($c301),hl      ; 007BA8 22 01 C3

+++:ld a,(CharacterSpriteAttributes+16) ; CharacterSpriteAttributes[0].currentanimframe
    ld (xc2d7),a

    ld hl,OutsideAnimCounters ; Zero OutsideAnimCounters
    ld de,OutsideAnimCounters+1
    ld bc,24-1
    ld (hl),0
    ldir

    ld hl,CharacterSpriteAttributes ; Zero CharacterSpriteAttributes
    ld de,CharacterSpriteAttributes+1
    ld bc,$100-1
    ld (hl),0
    ldir

    pop hl              ; pop number pushed before call into hl
    ret
.ends
.org $7bcd

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $7d30
.section "Lookup table $7d30" overwrite
Table7d30:             ; $7d30
; Pairs of y,x amounts???
.db $40,$60,$40,$70,$40,$80,$40,$90,$50,$60,$50,$70,$50,$80,$50,$90
.db $60,$60,$60,$70,$60,$80,$60,$90,$70,$60,$70,$70,$70,$80,$70,$90
.db $80,$70,$80,$80,$80,$90,$50,$a0,$60,$a0,$70,/*stop???*/$a0,$91,$01,$92,$01
.db $93,$01,$94,$01,$00,$39,$55,$00,$39,$55,$00,$48,$49,$00,$47,$38
.db $00,$66,$55,$00,$25,$42,$00,$14,$0f,$00,$41,$1a,$00,$66,$75,$00
.db $38,$66,$01,$27,$64,$01,$53,$73,$01,$27,$64,$01,$71,$5a,$01,$26
.db $29,$02,$5b,$2c,$02,$38,$49,$02,$5b,$2c,$02,$38,$49,$00,$16,$6a
.ends
; followed by
.orga $7da0
.section "Fade out full palette (and wait)" overwrite
FadeOutTilePalette:   ; $7da0
    ld  hl,$1009
    ld (PaletteFadeControl),hl ; PaletteFadeControl = fade out/counter=9; PaletteSize=16
    jr _FadeOutPalette

FadeOutFullPalette:   ; $7da8
    ld hl,$2009
    ld (PaletteFadeControl),hl ; PaletteFadeControl = fade out/counter=9; PaletteSize=32

_FadeOutPalette:
    ld a,$16           ; VBlankFunction_PaletteEffects
    call ExecuteFunctionIndexAInNextVBlank
    ld a,($c21b)       ; wait for palette to fade out
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
    ld de,ActualPalette+1
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
  -:call _FadeOut      ; process PaletteSize bytes from ActualPalette
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
  +:ld a,(hl)
    and %00001100      ; check green
    jr z,+
    ld a,(hl)
    sub $04            ; If non-zero, decrement
    ld (hl),a
    ret
  +:ld a,(hl)
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
  +:dec (hl)           ; Decrement it (PaletteFadeControl)
    inc hl
    ld b,(hl)          ; PaletteSize
    ld hl,TargetPalette
    ld de,ActualPalette
  -:call _FadePaletteEntry ; compare PaletteSize bytes from ActualPalette
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
  +:ld (de),a          ; else save that
    ret
 ++:ld a,(de)
    add a,%00000100    ; increment green
    cp (hl)
    jr z,+
    jr nc,++           ; if it's too far then try red
  +:ld (de),a          ; else save that
    ret
 ++:ex de,hl
    inc (hl)           ; increment red
    ex de,hl
    ret
.ends
.orga $7e4f

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

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
  +:ld hl,(PaletteFlashCount) ; else set palette entries to white
    ld b,h             ; b = PaletteFlashCount
    ld a,l             ; a = PaletteFlashStart
    ld hl,ActualPalette
    add a,l
    ld l,a             ; hl = [PaletteFlashStart]th palette entry
    ld a,$3f           ; White
  -:ld (hl),a          ; Set palette entry to white
    inc hl
    djnz -
    ret
.ends
; followed by
.orga $7ebb
.section "Palette rotation" overwrite
PaletteRotate:
    ld a,(xc30e)       ; Check xc30e
    or a
    ret z
    cp $10             ; Handle values 16 and 17 specially
    jp z,_ResetPalette
    cp $11
    jp z,_ResetPalette
    cp $0e             ; Do nothing if >=14
    ret nc
    ld b,a             ; still xc30e
    ld c,$d1           ;
    cp $08             ; if it's 8...
    jp z,+             ; skip this bit:
    ld c,$d0           ; change c
    ld a,(PaletteRotateEnabled) ; check PaletteRotateEnabled is not zero
    or a
    ret z              ; if it is, exit
  +:ld hl,PaletteRotateCounter
    dec (hl)           ; decrement PaletteRotateCounter
    ret p              ; exit while >= 0
    ld (hl),$03        ; reset to 3 -> pass 1 call in 4 -> 15 per second
    dec hl             ; hl = PaletteRotatePos
    ld a,c             ; $d1 or $d0
    ld ($c004),a       ; music number?
    ld a,(hl)          ; check (PaletteRotatePos)
    inc a              ; increment
    cp $03             ; if >=3
    jr c,+
    xor a              ; then zero -> 0-2
  +:ld (hl),a          ; put back in PaletteRotatePos
    ld c,a
    ld a,b
    cp $08             ; if xc30e==8 then
    ld hl,_Palette1    ; this palette data
    ld de,PaletteAddress+29 ; palette entries 29-31
    jp nz,+            ; else
    ld hl,_Palette2    ; this palette data
    ld de,PaletteAddress+23 ; palette entry 23-25
  +:ld b,$00
    add hl,bc          ; add PaletteRotatePos to hl -> rotate palette left
    SetVRAMAddressToDE
    ld bc,$03be        ; count 3 bytes, output to VDPData
  -:outi
    jp nz,-
    ret

_Palette1:             ; $7f10
.db cl332,cl222,cl112
.db cl332,cl222,cl112
_Palette2:             ; $7f16
.db cl033,cl332,cl222
.db cl033,cl332,cl222
; Palettes are repeated to allow shifting to achieve a circular effect

_ResetPalette:
    ld hl,ActualPalette
    ld de,PaletteAddress
    SetVRAMAddressToDE
    ld c,VDPData
    jp outi32          ; and ret
.ends
; followed by
.orga $7f28
.section "Flash palette 1" overwrite
fn7f28:
    ld hl,Palettefn7f28
    ld a,$6f           ; counter - when low nibble is 0, it changes the palette (so 7 palettes total); and stops when it's all counted down.
  -:push af
        and $0f
        ld de,ActualPalette+32-8
        ld bc,8
        jr nz,+       
        ldir           ; copy 8 colours to palette
      +:ld a,$16       ; VBlankFunction_PaletteEffects
        call ExecuteFunctionIndexAInNextVBlank
    pop af
    dec a
    jr nz,-
    ret
.ends
; followed by
.orga $7f44
.section "Palette animation 1" overwrite
fn7f44:
    ld hl,Frame2Paging
    ld (hl),3
    ld hl,Palettefn7f44
    ld de,ActualPalette+32-5
    ld bc,5
    ldir
    ld a,$16           ; VBlankFunction_PaletteEffects
    jp ExecuteFunctionIndexAInNextVBlank ; and ret
.ends
; followed by
.orga $7f59
.section "Palette animation 2" overwrite
fn7f59:
    ld hl,Frame2Paging
    ld (hl),3
    call _fn7f8f       ; cycle palette 3 times
    call _fn7f8f
    call _fn7f8f
    ld hl,$be52
    ld b,13            ; animation steps
 --:push bc
        ld de,ActualPalette+10
        ld bc,6        ; # of colours
        ldir
        ld b,8         ; frames to delay
      -:ld a,$16       ; VBlankFunction_PaletteEffects
        call ExecuteFunctionIndexAInNextVBlank
        djnz -
    pop bc
    djnz --
    ret

fn7f82:
    ld hl,Frame2Paging
    ld (hl),3
    ld hl,Palettefn7f82
    ld bc,$0918        ; b = 9 steps of palette animation; c = 24 = number of frames to delay
    jr _f

_fn7f8f:
    ld hl,Palettefn7f8f
    ld bc,$1803        ; b = $18 = 24 steps of palette animation; c = 3 = number of frames to delay
 __:push bc
        ld a,(hl)      ; get colour
        ld (ActualPalette+0),a ; put it in colour 0
        ld b,6
        ld de,ActualPalette+10
      -:ld (de),a      ; and 10-16
        inc de
        djnz -
        inc hl         ; get next colour
        ld a,(hl)
        ld (ActualPalette+7),a ; put it in colour 7
        inc hl         ; move to next colour
        ld b,c
      -:ld a,$16       ; VBlankFunction_PaletteEffects
        call ExecuteFunctionIndexAInNextVBlank
        djnz -
    pop bc
    djnz _b
    ret
.ends
; followed by
.orga $7fb5
.section "Palette animation 1 data" overwrite
Palettefn7f28:         ; $7fb5 Palette fade cyan/blue/white-white-various
.db cl033 cl023 cl033 cl033 cl333 cl033 cl023 cl023
.db cl233 cl033 cl233 cl233 cl333 cl233 cl033 cl033
.db cl333 cl233 cl333 cl333 cl333 cl333 cl233 cl233
.db cl333 cl322 cl330 cl332 cl332 cl233 cl033 cl330
.db cl332 cl210 cl320 cl331 cl330 cl033 cl023 cl320
.db cl322 cl100 cl210 cl330 cl320 cl222 cl112 cl210
.ends
; blank until end of slot

;=======================================================================================================
; Bank 1: $7ff0 - $7fff - rom header
;=======================================================================================================
.bank 1 slot 1
;.unbackground $7ff0 $8000
;.smstag

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
.include "text\text1.inc"
.ends
.orga $bf9c


;=======================================================================================================
; Bank 3: $c000 - $ffff
;=======================================================================================================
.bank 3 slot 2

.orga $869f
.section "Enemy data" overwrite
; Structure:
; 8 bytes = name
; 8 bytes = ??? xc258
; 1 byte = sprite tiles page
; 1 word = sprite tiles offset
; 1 byte = index into data8fdf for ???
; 3 bytes = HP, AP, DP
EnemyData:
.db $23 $2e $0d $10 $4d $1c $27 $02 ; 1 MoNSuTa-HuRaI = Monster Fly? (Sworm)
.db $2a $25 $05 $0a $08 $04 $0c $2f
 PageAndOffset TilesFly
.db $12 $08 $08,$0d,$09 $00
.dw $0003
.db $0c
.dw $0002
.db $38 $ff

.db $35 $28 $4d $2e $0d $27 $02 $21 ; 2 GuRi-NSuRaIMu = Green Slime
.db $10 $04 $0c $0e $00 $00 $00 $00
 PageAndOffset TilesSlime
.db $02 $06 $12,$12,$0d $00
.dw $0008
.db $0c
.dw $0004
.db $30 $cc

.db $03 $02 $2e $35 $01 $02 $58 $00 ; 3 UINGuAI = Wing Eye
.db $00 $3e $00 $3e $3c $34 $30 $00
 PageAndOffset TilesWingEye
.db $23 $06 $0b,$0c,$0a $00
.dw $0006
.db $0f
.dw $0002
.db $38 $7f

.db $1f $2e $02 $4d $10 $4d $58 $00 ; 4 MaNI-Ta- = Man-eater
.db $00 $00 $05 $0a $33 $21 $37 $00
 PageAndOffset TilesManEater
.db $17 $05 $10,$0c,$0a $00
.dw $000d
.db $0f
.dw $0003
.db $30 $ff

.db $0d $0a $4d $48 $27 $0d $58 $00 ; 5 SuKo-PiRaSu = Scorpion
.db $2a $25 $02 $03 $08 $00 $00 $37
 PageAndOffset TilesScorpion
.db $0f $04 $0c,$0e,$0c $00
.dw $000d
.db $0f
.dw $0004
.db $38 $cc

.db $27 $4d $39 $24 $4d $37 $58 $00 ; 6 Ra-ZiYa-Go = ??? (G. Scorpion)
.db $2a $25 $05 $0a $08 $00 $00 $2f
 PageAndOffset TilesScorpion
.db $0f $04 $14,$14,$11 $00
.dw $000b
.db $99
.dw $0005
.db $38 $7f

.db $44 $29 $4d $0d $27 $02 $21 $58 ; 7 BuRu-SuRaIMu = Blue Slime
.db $20 $30 $38 $3c $00 $00 $00 $00
 PageAndOffset TilesSlime
.db $02 $06 $28,$1a,$14 $00
.dw $0013
.db $0f
.dw $0005
.db $32 $99

.db $23 $10 $43 $01 $2e $19 $4d $1c ; 8 MoTaBiANNo-Hu = North Motabian (North Farmer)
.db $20 $30 $34 $38 $01 $06 $0a $0f
 PageAndOffset TilesFarmer
.db $19 $05 $26,$25,$25 $24
.dw $0008
.db $00
.dw $0005
.db $f0 $b2

.db $40 $43 $29 $42 $2f $14 $58 $00 ; 9 DeBiRuBatuTo = ??? (Owl Bear)
.db $00 $0f $00 $0b $07 $03 $01 $00
 PageAndOffset TilesWingEye
.db $23 $04 $12,$16,$12 $00
.dw $000c
.db $0c
.dw $0005
.db $38 $99

.db $07 $27 $4d $49 $27 $2e $14 $58 ; 10 KiRa-PuRaNTo = Killer Plant (Dead Tree)
.db $00 $00 $02 $03 $0c $08 $2e $00
 PageAndOffset TilesManEater
.db $17 $03 $17,$17,$19 $00
.dw $0015
.db $28
.dw $0004
.db $30 $cc

.db $42 $02 $10 $4d $1c $27 $02 $58 ; 11 BaITa-HuRaI = ??? (Scorpius)
.db $0c $08 $24 $25 $08 $00 $00 $2a
 PageAndOffset TilesScorpion
.db $0f $05 $16,$19,$14 $00
.dw $001b
.db $0f
.dw $0008
.db $39 $66

.db $23 $10 $43 $01 $2e $02 $43 $29 ; 12 MoTaBiANIBiRu = East Motabian (East Farmer)
.db $20 $30 $34 $38 $01 $03 $07 $0f
 PageAndOffset TilesFarmer
.db $1b $05 $2a,$1b,$28 $00
.dw $001e
.db $0f
.dw $0009
.db $f0 $cc

.db $1d $2a $2f $08 $0d $58 $00 $00 ; 13 HeRetuKuSu = ??? (Giant Fly)
.db $2a $25 $02 $03 $02 $01 $03 $0b
 PageAndOffset TilesFly
.db $12 $04 $19,$1e,$15 $00
.dw $0020
.db $0f
.dw $0007
.db $3c $66

.db $0b $2e $41 $2c $4d $21 $58 $00 ; 14 SaNDoWa-Mu = Sandworm (Crawler)
.db $02 $06 $0a $0e $01 $03 $2f $00
 PageAndOffset TilesSandWorm
.db $22 $03 $28,$1f,$20 $00
.dw $001e
.db $0f
.dw $0009
.db $30 $7f

.db $23 $10 $43 $01 $2e $1f $16 $01 ; 15 MoTaBiANMaNiA = Motabian ??? (Barbarian)
.db $20 $30 $34 $38 $04 $08 $0c $0f
 PageAndOffset TilesFarmer
.db $1a $08 $36,$23,$32 $24
.dw $0059
.db $14
.dw $000a
.db $f0 $4c

.db $37 $4d $29 $41 $2a $2e $3a $58 ; 16 Go-RuDoReNZu = Goldlens
.db $00 $2a $00 $2f $0a $06 $01 $00
 PageAndOffset TilesWingEye
.db $23 $04 $1c,$24,$23 $00
.dw $0018
.db $0f
.dw $0009
.db $38 $7f

.db $2a $2f $41 $0d $27 $02 $21 $58 ; 17 RetuDoSuRaIMu = Red Slime
.db $01 $13 $33 $3a $00 $00 $00 $00
 PageAndOffset TilesSlime
.db $02 $03 $1d,$25,$19 $00
.dw $001f
.db $0f
.dw $000b
.db $31 $99

.db $42 $2f $14 $1f $2e $58 $00 $00 ; 18 BatuToMaN = Bat Man (Were Bat)
.db $20 $34 $38 $3c $03 $02 $00 $00
 PageAndOffset TilesBat
.db $24 $04 $32,$25,$23 $00
.dw $003f
.db $0f
.dw $000b
.db $3b $7f

.db $06 $44 $14 $33 $16 $58 $00 $00 ; 19 KaBuToGaNi = ??? (Big Club)
.db $01 $02 $03 $07 $0b $00 $00 $00
 PageAndOffset TilesClub
.db $08 $02 $2e,$28,$24 $00
.dw $0028
.db $0f
.dw $0009
.db $30 $cc

.db $0c $30 $4d $07 $2e $58 $00 $00 ; 20 Siya-KiN = ??? (Fishman)
.db $05 $39 $0a $13 $33 $0f $3f $00
 PageAndOffset TilesFishMan
.db $07 $05 $2a,$2a,$28 $00
.dw $002a
.db $0f
.dw $000b
.db $30 $99

.db $28 $2f $11 $58 $00 $00 $00 $00 ; 21 RituTi = ??? (Evil Dead)
.db $02 $03 $34 $01 $04 $08 $0e $38
 PageAndOffset TilesEvilDead
.db $21 $03 $1e,$2b,$24 $00
.dw $0008
.db $0c
.dw $000e
.db $30 $e5

.db $10 $27 $2e $11 $31 $27 $58 $00 ; 22 TaRaNTiyuRa = Tarantula
.db $2a $01 $2a $05 $08 $04 $0c $2f
 PageAndOffset TilesTarantula
.db $11 $02 $32,$32,$2b $00
.dw $0033
.db $26
.dw $000a
.db $71 $99

.db $1f $2e $11 $0a $01 $58 $00 $00 ; 23 MaNTiKoA = Manticor
.db $01 $03 $07 $0b $28 $2d $2f $20
 PageAndOffset TilesManticor
.db $14 $03 $3c,$35,$2c $00
.dw $0031
.db $0f
.dw $000f
.db $5c $99

.db $0d $09 $29 $14 $2e $58 $00 $00 ; 24 SuKeRuToN = Skeleton
.db $3f $2f $2a $25 $20 $3c $00 $00
 PageAndOffset TilesSkeleton
.db $0c $05 $35,$3a,$29 $00
.dw $0019
.db $0f
.dw $000d
.db $30 $cc

.db $01 $28 $39 $37 $08 $58 $00 $00 ; 25 ARiZiGoKu = ??? (Antlion)
.db $2a $00 $25 $00 $06 $01 $0a $2f
 PageAndOffset TilesTarantula
.db $11 $01 $42,$3b,$34 $00
.dw $0007
.db $0c
.dw $0008
.db $31 $b2

.db $1f $4d $0c $4d $3a $58 $00 $00 ; 26 Ma-Si-Zu = ??? (Merman)
.db $21 $3c $36 $04 $2c $3a $07 $00
 PageAndOffset TilesFishMan
.db $07 $06 $3a,$43,$32 $00
.dw $002b
.db $0f
.dw $000e
.db $30 $7f

.db $40 $3c $28 $01 $2e $58 $00 $00 ; 27 DeZoRiAN = Dezorian
.db $02 $3c $0a $04 $2c $01 $08 $2f
 PageAndOffset TilesDezorian
.db $0a $05 $4c,$4d,$3f $00
.dw $0069
.db $0c
.dw $0012
.db $f0 $7f

.db $40 $38 $4d $14 $28 $4d $11 $58 ; 28 DeZa-ToRi-Ti = ??? (Leech)
.db $08 $22 $33 $37 $04 $0c $2f $06
 PageAndOffset TilesSandWorm
.db $22 $04 $46,$43,$2f $00
.dw $002f
.db $0c
.dw $000f
.db $33 $a5

.db $08 $27 $02 $05 $2e $58 $00 $00 ; 29 KuRaION = ??? (Vampire)
.db $01 $06 $0a $2f $2a $25 $00 $2a
 PageAndOffset TilesBat
.db $24 $02 $43,$44,$2e $27
.dw $0047
.db $0c
.dw $000f
.db $38 $cc

.db $43 $2f $35 $19 $4d $3a $58 $00 ; 30 BituGuNo-Zu = Big-nose (Elephant)
.db $22 $33 $37 $3b $2d $2f $2a $0c
 PageAndOffset TilesElephant
.db $03 $05 $56,$3e,$30 $00
.dw $0026
.db $0c
.dw $0011
.db $20 $cc

.db $35 $4d $29 $58 $00 $00 $00 $00 ; 31 Gu-Ru = Ghoul
.db $0b $03 $34 $38 $37 $33 $31 $3c
 PageAndOffset TilesGhoul
.db $13 $03 $44,$40,$2f $00
.dw $001a
.db $0c
.dw $0010
.db $30 $b2

.db $01 $2e $23 $15 $02 $14 $58 $00 ; 32 ANMoNaITo = Ammonite (Shellfish)
.db $03 $3a $2b $22 $33 $0f $07 $3f
 PageAndOffset TilesAmmonite
.db $09 $03 $3e,$4d,$34 $00
.dw $002e
.db $14
.dw $0010
.db $30 $e5

.db $04 $35 $3b $07 $31 $4d $14 $58 ; 33 EGuZeKiyu-To = Executer
.db $01 $04 $08 $0c $0f $00 $00 $00
 PageAndOffset TilesClub
.db $08 $03 $3e,$49,$32 $00
.dw $003f
.db $35
.dw $000c
.db $30 $66

.db $2c $02 $14 $58 $00 $00 $00 $00 ; 34 WaITo = Wight
.db $08 $0c $03 $04 $02 $03 $07 $0f
 PageAndOffset TilesEvilDead
.db $21 $03 $32,$40,$30 $00
.dw $0028
.db $0c
.dw $0012
.db $31 $b2

.db $0d $06 $29 $0f $29 $39 $30 $4d ; 35 SuKaRuSoRuZiya- = ??? (Skull-en)
.db $3f $0f $0d $06 $00 $0c $00 $00
 PageAndOffset TilesSkeleton
.db $0d $03 $39,$4b,$35 $00
.dw $0025
.db $0c
.dw $0012
.db $30 $b2

.db $1f $02 $1f $02 $58 $00 $00 $00 ; 36 MaIMaI = ??? (Ammonite)
.db $04 $3e $0c $38 $3c $0f $08 $3f
 PageAndOffset TilesAmmonite
.db $09 $02 $5a,$58,$3c $00
.dw $0047
.db $3f
.dw $0013
.db $30 $99

.db $1f $2e $11 $0a $4d $14 $58 $00 ; 37 MaNTiKo-To = ??? (Sphinx)
.db $01 $03 $07 $0b $0a $0f $2f $20
 PageAndOffset TilesManticor
.db $14 $04 $4e,$50,$41 $27
.dw $003a
.db $0c
.dw $0015
.db $58 $cc

.db $0b $4d $4a $2e $14 $58 $00 $00 ; 38 Sa-PeNTo = Serpent
.db $22 $32 $33 $37 $3b $00 $00 $00
 PageAndOffset TilesSnake
.db $10 $01 $50,$64,$42 $00
.dw $0060
.db $0f
.dw $0017
.db $38 $b2

.db $28 $42 $02 $01 $0b $2e $58 $00 ; 39 RiBaIASaN = ??? (Sandworm)
.db $0a $34 $38 $3c $05 $0f $2f $06
 PageAndOffset TilesSandWorm
.db $22 $03 $52,$6b,$3f $00
.dw $0081
.db $0f
.dw $0014
.db $30 $99

.db $41 $29 $4d $39 $31 $58 $00 $00 ; 40 DoRu-Ziyu = ??? (Lich)
.db $31 $35 $08 $21 $23 $33 $37 $0e
 PageAndOffset TilesEvilDead
.db $21 $02 $3c,$54,$3e $00
.dw $0021
.db $0c
.dw $0016
.db $31 $cc

.db $05 $08 $14 $47 $0d $58 $00 $00 ; 41 OKuToPaSu = Octopus
.db $02 $00 $00 $22 $33 $01 $00 $3f
 PageAndOffset TilesOctopus
.db $05 $01 $5a,$55,$44 $00
.dw $0040
.db $0c
.dw $0014
.db $30 $bf

.db $1f $2f $41 $0d $14 $4d $06 $4d ; 42 MatuDoSuTo-Ka- = Mad Stalker
.db $3f $3d $37 $33 $00 $0f $00 $00
 PageAndOffset TilesSkeleton
.db $0e $04 $4f,$5a,$4b $00
.dw $0057
.db $0f
.dw $0016
.db $30 $e5

.db $40 $3c $28 $01 $2e $1d $2f $41 ; 43 DeZoRiANHetuDo = Dezorian ??? (EvilDead)
.db $02 $3c $03 $04 $2c $01 $08 $07
 PageAndOffset TilesDezorian
.db $0a $03 $56,$76,$4d $00
.dw $0088
.db $0f
.dw $0014
.db $f0 $7f

.db $3c $2e $43 $58 $00 $00 $00 $00 ; 44 ZoNBi = Zombie
.db $2a $25 $05 $0a $08 $08 $0c $2f
 PageAndOffset TilesGhoul
.db $13 $04 $57,$6c,$3a $00
.dw $001b
.db $0f
.dw $0014
.db $30 $99

.db $43 $31 $4d $14 $58 $00 $00 $00 ; 45 Biyu-To = ??? (Battalion)
.db $03 $02 $25 $2a $03 $02 $07 $03
 PageAndOffset TilesGhoul
.db $13 $03 $64,$70,$40 $00
.dw $003b
.db $0c
.dw $0015
.db $30 $cc

.db $2b $46 $2f $14 $4b $28 $0d $58 ; 46 RoBotuToPoRiSu = Robot Police (RobotCop)
.db $25 $2a $2f $3f $03 $26 $20 $00
 PageAndOffset TilesRobotCop
.db $15 $01 $6e,$87,$5a $00
.dw $009c
.db $0f
.dw $0019
.db $00 $66

.db $0b $02 $46 $4d $35 $22 $02 $39 ; 47 SaIBo-GuMeIZ = ??? (Sorceror)
.db $01 $31 $35 $39 $3d $03 $23 $02
 PageAndOffset TilesSorceror
.db $04 $02 $6e,$79,$4a $00
.dw $0078
.db $33
.dw $001a
.db $34 $cc

.db $1c $2a $4d $21 $28 $38 $4d $41 ; 48 HuRe-MuRiZa-Do = ??? (Nessie)
.db $04 $08 $0c $2f $3f $00 $00 $00
 PageAndOffset TilesSnake
.db $10 $02 $5d,$7e,$4d $00
.dw $0065
.db $0c
.dw $001c
.db $38 $cc

.db $10 $39 $21 $58 $00 $00 $00 $00 ; 49 TaZiMu = Tarzimal
.db $2b $20 $06 $2a $25 $3e $01 $0f
 PageAndOffset TilesTarzimal
.db $06 $01 $7d,$78,$64 $00
.dw $0000
.db $0c
.dw $0000
.db $14 $00

.db $33 $02 $01 $58 $00 $00 $00 $00 ; 50 GaIA = ??? (Golem)
.db $01 $02 $03 $34 $30 $00 $00 $00
 PageAndOffset TilesGolem
.db $1f $02 $8c,$79,$60 $00
.dw $0096
.db $0c
.dw $0018
.db $20 $b2

.db $1f $0c $4d $2e $33 $4d $3d $4d ; 51 MaSi-NGa-Da- = Machine Guard? (AndroCop)
.db $02 $03 $07 $3f $3c $03 $02 $00
 PageAndOffset TilesRobotCop
.db $15 $02 $78,$91,$59 $00
.dw $007b
.db $0c
.dw $001d
.db $00 $7f

.db $43 $2f $35 $02 $4d $10 $4d $58 ; 52 BituGuI-Ta- = ??? (Tentacle)
.db $00 $00 $00 $20 $25 $30 $00 $0b
 PageAndOffset TilesOctopus
.db $05 $01 $76,$76,$57 $00
.dw $0062
.db $0c
.dw $001b
.db $30 $b2

.db $10 $2b $0d $58 $00 $00 $00 $00 ; 53 TaRoSu = ??? (Giant)
.db $04 $08 $0c $03 $02 $00 $00 $00
 PageAndOffset TilesGolem
.db $1f $02 $78,$7a,$58 $00
.dw $0077
.db $0c
.dw $001e
.db $20 $7f

.db $0d $18 $4d $08 $2b $4d $41 $58 ; 54 SuNe-KuRo-Do = Snake ??? (Wyvern)
.db $01 $05 $1a $2f $3f $00 $00 $00
 PageAndOffset TilesSnake
.db $10 $01 $6e,$7b,$54 $00
.dw $007d
.db $0c
.dw $001a
.db $38 $7f

.db $40 $0d $45 $01 $27 $4d $58 $00 ; 55 DeSuBeARa- = ??? (Reaper)
.db $20 $25 $2a $2f $3f $02 $01 $30
 PageAndOffset TilesReaper
.db $1e $01 $b9,$87,$66 $00
.dw $00fe
.db $33
.dw $001e
.db $23 $cc

.db $06 $05 $0d $0f $4d $0b $27 $4d ; 56 KaOSuSo-SaRa- = ??? Sorceror (Magician)
.db $00 $25 $25 $2a $2f $08 $0c $04
 PageAndOffset TilesSorceror
.db $04 $01 $8a,$91,$5a $00
.dw $00bb
.db $0c
.dw $0020
.db $35 $7f

.db $0e $2e $14 $4d $29 $58 $00 $00 ; 57 SeNTo-Ru = Centaur (HorseMan)
.db $20 $30 $34 $38 $3c $10 $0c $2f
 PageAndOffset TilesCentaur
.db $1d $02 $82,$7e,$59 $27
.dw $0094
.db $00
.dw $001e
.db $44 $59

.db $01 $02 $0d $1f $2e $58 $00 $00 ; 58 AISuMaN = Ice-man (FrostMan)
.db $20 $30 $34 $38 $3c $3f $3a $3e
 PageAndOffset TilesIceMan
.db $1c $01 $8c,$8a,$62 $00
.dw $0080
.db $14
.dw $0024
.db $10 $bf

.db $42 $29 $06 $2e $58 $00 $00 $00 ; 59 BaRuKaN = ??? (Amundsen)
.db $01 $02 $03 $07 $0b $0f $0b $0f
 PageAndOffset TilesIceMan
.db $1c $01 $85,$8c,$62 $00
.dw $0078
.db $0c
.dw $0020
.db $10 $b2

.db $2a $2f $41 $41 $27 $37 $2e $58 ; 60 RetuDoDoRaGoN = Red Dragon?
.db $01 $20 $34 $02 $03 $07 $30 $38
 PageAndOffset TilesDragon
.db $01 $01 $af,$a0,$69 $00
.dw $00c1
.db $0f
.dw $0041
.db $58 $7f

.db $35 $28 $4d $2e $41 $27 $37 $2e ; 61 GuRi-NDoRaGoN = Green Dragon
.db $04 $03 $0b $08 $0c $0e $07 $0f
 PageAndOffset TilesDragon
.db $01 $01 $a0,$91,$5f $00
.dw $00b0
.db $0c
.dw $0035
.db $58 $99

.db $27 $0c $4d $08 $58 $00 $00 $00 ; 62 RaSi-Ku = ??? (Shadow)
.db $20 $30 $34 $38 $25 $2a $2f $00
 PageAndOffset TilesShadow
.db $18 $01 $a5,$ac,$68 $00
.dw $0000
.db $0c
.dw $003c
.db $30 $7f

.db $1f $2e $23 $0d $58 $00 $00 $00 ; 63 MaNMoSu = Mammoth
.db $31 $35 $39 $3d $23 $2f $2a $02
 PageAndOffset TilesElephant
.db $03 $05 $b4,$9a,$64 $00
.dw $007d
.db $0f
.dw $0028
.db $20 $b2

.db $07 $2e $35 $0e $02 $42 $4d $58 ; 64 KiNGuSeIBa- = ??? (Centaur)
.db $06 $07 $0b $0f $2f $03 $0b $0f
 PageAndOffset TilesCentaur
.db $1d $01 $be,$9b,$64 $00
.dw $0085
.db $28
.dw $001f
.db $41 $7f

.db $3d $4d $08 $1f $2b $4d $3d $4d ; 65 Da-KuMaRo-Da- = Dark Marauder (Marauder)
.db $10 $20 $30 $34 $38 $03 $02 $00
 PageAndOffset TilesReaper
.db $1e $01 $87,$86,$58 $00
.dw $00ad
.db $0f
.dw $001e
.db $25 $b2

.db $37 $4d $2a $21 $58 $00 $00 $00 ; 66 Go-ReMu = Golem(Titan)
.db $01 $06 $0a $2a $25 $00 $00 $00
 PageAndOffset TilesGolem
.db $1f $02 $be,$92,$61 $00
.dw $008a
.db $21
.dw $0020
.db $20 $7f

.db $22 $40 $31 $4d $0b $58 $00 $00 ; 67 MeDeyu-Sa = Medusa
.db $01 $12 $37 $2b $32 $02 $22 $10
 PageAndOffset TilesMedusa
.db $20 $01 $c8,$a6,$67 $27
.dw $00c2
.db $00
.dw $0032
.db $26 $99

.db $1c $2b $0d $14 $41 $27 $37 $2e ; 68 HuRoSuToDoRaGoN = ??? Dragon (White Dragon)
.db $34 $3c $3f $38 $3c $2f $3f $3f
 PageAndOffset TilesDragon
.db $01 $01 $c8,$b4,$68 $00
.dw $00ea
.db $0f
.dw $004b
.db $48 $99

.db $41 $27 $37 $2e $2c $02 $3a $58 ; 69 DoRaGoNWaIZu = Dragon ??? (Blue Dragon)
.db $20 $3e $3f $25 $2a $2f $3f $3f
 PageAndOffset TilesDragon
.db $01 $01 $d2,$9b,$5a $00
.dw $00b2
.db $0c
.dw $0058
.db $48 $99

.db $37 $4d $29 $41 $41 $2a $02 $08 ; 70 Go-RuDoDoReIKu = Gold Dragon
.db $03 $07 $0b $0f $25 $2a $2f $00
 PageAndOffset TilesGoldDragonHead
.db $16 $01 $aa,$c8,$62 $00
.dw $0000
.db $00
.dw $0064
.db $0a $00

.db $1f $2f $41 $41 $08 $10 $4d $58 ; 71 MatuDoDoKuTa- = Mad? Doctor (Dr. Mad)
.db $38 $3c $3e $3f $25 $2a $2f $00
 PageAndOffset TilesShadow
.db $18 $01 $e9,$b4,$55 $00
.dw $008c
.db $00
.dw $0019
.db $30 $66

.db $27 $0c $4d $08 $58 $00 $00 $00 ; 72 RaSi-Ku = Lassic
.db $01 $06 $34 $30 $2f $0f $0b $02
 PageAndOffset TilesLassic
.db $26 $01 $ee,$e6,$b4 $00
.dw $0000
.db $00
.dw $0000
.db $07 $00

.db $3d $4d $08 $1c $4e $29 $0d $58 ; 73 Da-KuHu[4E]RuSu = Dark Force
.db $20 $30 $34 $38 $3c $02 $03 $01
 PageAndOffset TilesDarkForceFlame
.db $27 $82 $ff,$ff,$96 $00
.dw $0000
.db $00
.dw $0000
.db $00 $00

.db $15 $02 $14 $22 $01 $58 $00 $00 ; 74 NaIToMeA = Nightmare? (Succubus)
.db $20 $25 $2a $2f $3f $02 $03 $01
 PageAndOffset TilesSuccubus
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

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $96f4
.section "Character sprite data table" overwrite
CharacterSpriteData:   ; $96f4
.include "Other data\Sprite data 1.inc"
.ends
.orga $a935

; ---------------------------------------------------------------------------------------
;                    A r e a   n o t   y e t   p r o c e s s e d
; ---------------------------------------------------------------------------------------

.orga $b8a7
.section "Character level stats" overwrite
LevelStats:
;    ,,------------------------------ Max HP
;    ||  ,,-------------------------- Attack boost
;    ||  ||  ,,---------------------- Defence boost
;    ||  ||  ||  ,,------------------ Max MP
;    ||  ||  ||  ||  ,,-------------- ?
;    ||  ||  ||  ||  ||  ,,---------- ?
;    ||  ||  ||  ||  ||  ||  ,,------ Magics known
;    ||  ||  ||  ||  ||  ||  ||  ,,-- ?
LevelStatsAlis:
.db $00,$00,$00,$00,$00,$00,$00,$00
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
.db $d6,$24,$76,$37,$60,$ea,$04,$03
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
LevelStatsNoah:
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
.ends
; followed by
.orga $bc67
.section "Unknown data 2" overwrite
.db $c3,$4b,$7b,$53,$50,$c3,$05,$05,$12
.db $12,$12,$12,$12,$12,$12,$22,$22,$12,$8a,$8a,$8a,$8a,$22,$13,$13
.db $13,$13,$13,$13,$13,$13,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52
.db $12,$12,$12,$12,$b2,$52,$9a,$9a,$9a,$9a,$13,$13,$13,$13,$13,$13
.db $13,$13,$13,$13,$1a,$13,$40,$40,$40,$40,$41,$41,$41,$41,$41,$41
.db $41,$41,$31,$31,$52,$52,$52,$52,$32,$32,$32,$32,$32,$32,$32,$32
.db $32,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a,$12,$12,$22,$26,$74,$74
.db $74,$74,$74,$13,$13,$13,$13,$13,$13,$53,$53,$5a,$5a,$63,$63,$6a
.db $6a,$13,$13,$13,$13,$9a,$9a,$9a,$9a,$1a,$1a,$1a,$1a,$1a,$1a,$1a
.db $1a,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12
.db $12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12
.db $12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12
.db $12,$12,$12,$12,$12,$12,$12,$12,$12,$13,$13,$13,$13,$13,$13,$13
.db $13,$62,$56,$56,$56,$56,$b6,$12,$12,$12,$12,$12,$12,$b6,$b6,$b6
.db $b6,$43,$42,$42,$42,$42,$66,$63,$63,$63,$63,$63,$63,$63,$63,$12
.db $12,$12,$12,$12,$12,$12,$12,$1a,$1a,$1a,$1a,$12,$12,$12,$62,$c2
.db $12,$43,$43,$43,$43,$6a,$10,$10,$10,$10,$10,$10,$10,$10,$10,$82
.db $82,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$8a,$8a,$83,$83,$8a
.db $8a,$83,$83,$8a,$8a,$83,$83,$8a,$8a,$83,$83,$8a,$8a,$83,$83,$8a
.db $8a,$83,$83,$83,$83,$83,$83,$83,$83,$83,$82,$82,$83,$83,$83,$83
.db $83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83
.db $83,$83,$83,$83,$83,$8a,$83,$8a,$82,$82,$82,$a4,$a3,$a3,$a3,$a3
.db $a3,$a3,$aa,$aa,$aa,$aa,$a2,$a2,$a2,$a2,$12,$a3,$a2,$aa,$a2,$83
.db $83,$8a,$8a,$83,$8a,$83,$93,$93,$93,$93,$93,$93,$93,$93,$93,$93
.db $93,$93,$93,$93,$93,$93,$92,$93,$93,$9a,$9a,$93,$93,$9a,$9a,$93
.db $93,$9a,$9a,$93,$93,$9a,$9a,$93,$93,$9a,$9a,$93,$9a,$93,$9a,$93
.db $9a,$a2,$a3,$a2,$aa,$83,$83,$83,$83,$1a,$1a,$1a,$1a,$83,$83,$83
.db $83,$83,$8a,$8a,$83,$83,$a2,$a2,$a2,$92,$92,$92,$16
; followed by
Palettefn7f44: ; $fe1d
.db $0c,$08,$04,$03,$0b ; Green darkening fade, red, orange
; followed by
Palettefn7f8f: ; $fe22 Palette cycle for two colours - blue-green-yellow-red-purple-blue and blue-cyan-blue
.db cl013 cl023
.db cl113 cl033
.db cl023 cl233
.db cl033 cl233
.db cl133 cl233
.db cl032 cl233
.db cl231 cl233
.db cl030 cl233
.db cl230 cl233
.db cl330 cl233
.db cl321 cl233
.db cl320 cl233
.db cl310 cl233
.db cl312 cl233
.db cl313 cl233
.db cl323 cl233
.db cl223 cl233
.db cl213 cl233
.db cl113 cl233
.db cl013 cl233
.db cl023 cl233
.db cl113 cl033
.db cl013 cl023
.db cl003 cl222 ; grey at end?

Palettefn7f59: ; $fe52 Palette fade - blue-white-various
.db cl013 cl013 cl013 cl013 cl013 cl013
.db cl113 cl113 cl113 cl113 cl113 cl113
.db cl023 cl023 cl023 cl023 cl023 cl023
.db cl023 cl023 cl023 cl023 cl033 cl023
.db cl023 cl033 cl023 cl033 cl233 cl023
.db cl023 cl233 cl033 cl233 cl333 cl023
.db cl033 cl333 cl233 cl333 cl333 cl033
.db cl233 cl333 cl333 cl333 cl333 cl233
.db cl333 cl333 cl333 cl333 cl333 cl333
.db cl332 cl333 cl332 cl333 cl333 cl133
.db cl331 cl332 cl330 cl332 cl333 cl032
.db cl221 cl330 cl320 cl331 cl332 cl032
.db cl111 cl320 cl210 cl221 cl332 cl022

Palettefn7f82: ; $fea0 Palette cycle for two colours - blue-cyan-white-cyan-blue and grey + cyan-white-cyan
.db cl003 cl222
.db cl013 cl023
.db cl023 cl233
.db cl033 cl233
.db cl233 cl333
.db cl333 cl333
.db cl233 cl333
.db cl033 cl233
.db cl023 cl233
.ends
; followed by
.orga $beb2            ; $feb2
.section "Unknown menu" overwrite
; raw tilemap data
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
.db $01,$01,$01,$0f,$08,$01,$01,$01
.db $0f,$04,$01,$01,$08,$01,$0f,$04,$04,$01,$08,$01,$01,$0f,$04,$01
.db $01,$08,$01,$0f,$02,$02,$00,$08,$01,$01,$0f,$04,$01,$01,$01,$01
.db $02,$04,$0f,$02,$02,$02,$08,$01,$01,$01,$01,$04,$0f,$08,$08,$0f
.db $08,$01,$01,$08,$01,$01,$01,$01,$01,$01,$01,$08,$02,$02,$04,$0f
.db $04,$01,$01,$00,$0f,$04,$04,$01,$01,$08,$01,$0f,$02,$02,$02,$02
.db $08,$0f,$02,$04,$04,$01,$01,$01,$08,$01,$01,$01,$01,$0f
.ends
; Blank until end of slot

;=======================================================================================================
; Bank 4: $10000 - $13fff
;=======================================================================================================
.bank 4 slot 2

; space

.org $10906-$10000
.section "Tilemap data 1 - dungeon" overwrite
.incbin "Tilemaps\10906tilemap.dat"
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

.orga $8000
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
;.org 16a27
; Unknown data

;=======================================================================================================
; Bank 6: $18000 - $1bfff
;=======================================================================================================
.bank 6 slot 2

; space

.org $1bb80-$18000
.section "Tile data 1" overwrite
.incbin "Tiles\1BB80compr.dat"
;.org $1bffb
; Blank until end of bank
.ends

;=======================================================================================================
; Bank 7: $1c000 - $1ffff
;=======================================================================================================
.bank 7 slot 2

; space

;=======================================================================================================
; Bank 8: $20000 - $23fff
;=======================================================================================================
.bank 8 slot 2

; space

;=======================================================================================================
; Bank 9: $24000 - $27fff
;=======================================================================================================
.bank 9 slot 2

; space

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
.orga $8000
.section "Sound engine initialisation" overwrite
SoundInitialise:       ; 0e/8000
    push hl
    push de
    push bc
        call _ZeroC003toC00D
        ld b,$0f       ; counter (15 columns below)
        ld hl,$c00e    ; start
        xor a          ; 0 -> a
      -:ld (hl),a      ; 0 -> c00e,c02e,c04e ... c1ee
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
        ld c,PSG
        ld b,_SilencePSGDataEnd-_SilencePSGData
        otir
    pop bc
    pop hl

SilenceFM:             ; 0e/802c
    push bc
    push de
        ld b,$06       ; 6 channels
        ld d,$20       ; YM2413 registers $20-$26
      -:ld a,d
        inc d
        call ZeroYM2413Channel
        djnz -
    pop de
    pop bc
    ret ; from SoundInitialise, SilencePSG or SilenceFM

_ZeroC003toC00D:       ; Zero $c003-$c00d
    xor a
    ld hl,$c003
    ld (hl),a
    ld de,$c004
    ld bc,$000a
    ldir
    ret

_SilencePSGData:
.db $80,$00            ; ch 0 freq $000
.db $A0,$00            ; ch 1 freq $000
.db $C0,$00            ; ch 2 freq $000
.db $E5,$FF            ; ch 3 freq %101 then %111 = white, ch 2
_SilencePSGDataEnd:
.ends
; followed by
.orga $8052
.section "Sound update" overwrite
SoundUpdate:           ; 0e/8052
    ld a,(HasFM)
    or a
    ex af,af'          ; 030056 08
    ld hl,$c00c        ; 030057 21 0C C0
    exx                ; 03005A D9
    call Sound8135     ; 03005B CD 35 81
    call Sound815c     ; 03005E CD 5C 81
    call $8466         ; 030061 CD 66 84
    call Sound8110     ; 030064 CD 10 81
    ld a,(HasFM)
    or a
    jp z,SoundUpdatePSG
    ; FM music:
    ld a,($c002)       ; 03006E 3A 02 C0
    or a               ; 030071 B7
    jp m,++            ; 030072 FA 9A 80
    ld ix,$c00e        ; 030075 DD 21 0E C0
    ld b,$0a           ; 030079 06 0A
  -:push bc            ; 03007B C5
      ld a,$04         ; 03007C 3E 04
      cp b             ; 03007E B8
      jr z,+           ; 03007F 28 10
      bit 7,(ix+$00)   ; 030081 DD CB 00 7E
      call nz,$8664    ; 030085 C4 64 86
--:   ld de,$0020      ; 030088 11 20 00
      add ix,de        ; 03008B DD 19
    pop bc             ; 03008D C1
    djnz -             ; 03008E 10 EB
    ret                ; 030090 C9

+:  bit 7,(ix+$00)               ; 030091 DD CB 00 7E
    call nz,$8608                ; 030095 C4 08 86
    jr --                        ; 030098 18 EE

++: ld ix,$c0ee                  ; 03009A DD 21 EE C0
    ld b,$08                     ; 03009E 06 08
-:  push bc                      ; 0300A0 C5
      ld a,$01                   ; 0300A1 3E 01
      cp b                       ; 0300A3 B8
      jr z,+                     ; 0300A4 28 10
      bit 7,(ix+$00)             ; 0300A6 DD CB 00 7E
      call nz,$8664              ; 0300AA C4 64 86
--:   ld de,$0020                ; 0300AD 11 20 00
      add ix,de                  ; 0300B0 DD 19
    pop bc                       ; 0300B2 C1
    djnz -                       ; 0300B3 10 EB
    ret                          ; 0300B5 C9

+:  bit 7,(ix+$00)               ; 0300B6 DD CB 00 7E
    call nz,$8608                ; 0300BA C4 08 86
    jr --                        ; 0300BD 18 EE

SoundUpdatePSG:
    ld a,($c002)                 ; 0300BF 3A 02 C0
    or a                         ; 0300C2 B7
    jp m,++                      ; 0300C3 FA EB 80
    ld ix,$c06e                  ; 0300C6 DD 21 6E C0
    ld b,$07                     ; 0300CA 06 07
-:  push bc                      ; 0300CC C5
      ld a,$04                   ; 0300CD 3E 04
      cp b                       ; 0300CF B8
      jr z,+                     ; 0300D0 28 10
      bit 7,(ix+$00)             ; 0300D2 DD CB 00 7E
      call nz,$8bd9              ; 0300D6 C4 D9 8B
--:   ld de,$0020                ; 0300D9 11 20 00
      add ix,de                  ; 0300DC DD 19
    pop bc                       ; 0300DE C1
    djnz -                       ; 0300DF 10 EB
    ret                          ; 0300E1 C9

+:  bit 7,(ix+$00)               ; 0300E2 DD CB 00 7E
    call nz,$8b37                ; 0300E6 C4 37 8B
    jr --                        ; 0300E9 18 EE
++: ld ix,$c0ee                  ; 0300EB DD 21 EE C0
    ld b,$08                     ; 0300EF 06 08
-:  push bc                      ; 0300F1 C5
      ld a,$01                   ; 0300F2 3E 01
      cp b                       ; 0300F4 B8
      jr z,+                     ; 0300F5 28 10
      bit 7,(ix+$00)             ; 0300F7 DD CB 00 7E
      call nz,$8bd9              ; 0300FB C4 D9 8B
--:   ld de,$0020                ; 0300FE 11 20 00
      add ix,de                  ; 030101 DD 19
    pop bc                       ; 030103 C1
    djnz -                       ; 030104 10 EB
    ret                          ; 030106 C9

+:  bit 7,(ix+$00)               ; 030107 DD CB 00 7E
    call nz,$8b37                ; 03010B C4 37 8B
    jr --                        ; 03010E 18 EE

.ends
; followed by
.orga $8110
.section "More music code" overwrite
Sound8110:
    ld hl,$c12e                  ; 030110 21 2E C1
    bit 7,(hl)                   ; 030113 CB 7E
    ret z                        ; 030115 C8
    ld a,($c10e)                 ; 030116 3A 0E C1
    or a                         ; 030119 B7
    jp m,++                      ; 03011A FA 32 81
    bit 6,(hl)                   ; 03011D CB 76
    jr z,+                       ; 03011F 28 0B

    inc hl                       ; 030121 23
    ld a,(hl)                    ; 030122 7E
    cp $e0                       ; 030123 FE E0
    jr nz,+                      ; 030125 20 05
    ld hl,$c06e                  ; 030127 21 6E C0
    set 2,(hl)                   ; 03012A CB D6

+:  ld hl,$c0ae                  ; 03012C 21 AE C0
    set 2,(hl)                   ; 03012F CB D6
    ret                          ; 030131 C9

++: set 2,(hl)                   ; 030132 CB D6
    ret                          ; 030134 C9

Sound8135:
    ld hl,$c001                  ; 030135 21 01 C0
    ld a,(hl)                    ; 030138 7E
    or a                         ; 030139 B7
    ret z                        ; 03013A C8
    dec (hl)                     ; 03013B 35
    ret nz                       ; 03013C C0
    ld a,($c002)                 ; 03013D 3A 02 C0
    or a                         ; 030140 B7
    res 7,a                      ; 030141 CB BF
    ld (hl),a                    ; 030143 77
    ld hl,$c018                  ; 030144 21 18 C0
    ld de,$0020                  ; 030147 11 20 00
    ld b,$07                     ; 03014A 06 07
    jp m,+                       ; 03014C FA 57 81
    ld hl,$c158                  ; 03014F 21 58 C1
    ld de,$0020                  ; 030152 11 20 00
    ld b,$05                     ; 030155 06 05
+:
-:  inc (hl)                     ; 030157 34
    add hl,de                    ; 030158 19
    djnz -                       ; 030159 10 FC
    ret                          ; 03015B C9

Sound815c:
    ld a,($c00a)                 ; 03015C 3A 0A C0
    or a                         ; 03015F B7
    ret z                        ; 030160 C8
    jp m,+++                     ; 030161 FA D0 81
    ld a,($c00b)                 ; 030164 3A 0B C0
    dec a                        ; 030167 3D
    jr z,+                       ; 030168 28 04

    ld ($c00b),a                 ; 03016A 32 0B C0
    ret                          ; 03016D C9

+:  ld a,($c009)                 ; 03016E 3A 09 C0
    ld ($c00b),a                 ; 030171 32 0B C0
    ld a,($c00a)                 ; 030174 3A 0A C0
    inc a                        ; 030177 3C
    cp $0c                       ; 030178 FE 0C
    ld ($c00a),a                 ; 03017A 32 0A C0
    jr nz,++                     ; 03017D 20 1C
    xor a                        ; 03017F AF
    ld ($c00a),a                 ; 030180 32 0A C0
    ld a,($c002)                 ; 030183 3A 02 C0
    cp $7f                       ; 030186 FE 7F
    jr nz,+                      ; 030188 20 05
    ld a,$85                     ; 03018A 3E 85
    jp $84ad                     ; 03018C C3 AD 84
+:  or a                         ; 03018F B7
    jp p,SoundInitialise         ; 030190 F2 00 80
    ld a,($c006)                 ; 030193 3A 06 C0
    or a                         ; 030196 B7
    ret z                        ; 030197 C8
    jp $8218                     ; 030198 C3 18 82

++: ld ix,$c00e                  ; 03019B DD 21 0E C0
    ld de,$0020                  ; 03019F 11 20 00
    ld b,$06                     ; 0301A2 06 06
    ld a,($c002)                 ; 0301A4 3A 02 C0
    or a                         ; 0301A7 B7
    jp p,$81b1                   ; 0301A8 F2 B1 81
    ld ix,$c14e                  ; 0301AB DD 21 4E C1
    ld b,$04                     ; 0301AF 06 04
-:  ld a,(ix+$08)                ; 0301B1 DD 7E 08
    inc a                        ; 0301B4 3C
    cp $10                       ; 0301B5 FE 10
    jr z,++                      ; 0301B7 28 0A
    ld (ix+$08),a                ; 0301B9 DD 77 08
    ld a,($c000)                 ; 0301BC 3A 00 C0
    or a                         ; 0301BF B7
    call nz,+                    ; 0301C0 C4 C8 81
++: add ix,de                    ; 0301C3 DD 19
    djnz -                       ; 0301C5 10 EA
    ret                          ; 0301C7 C9

+:
    bit 2,(ix+$00)               ; 0301C8 DD CB 00 56
    ret nz                       ; 0301CC C0
    jp $8748                     ; 0301CD C3 48 87
+++:ld a,($c00b)                 ; 0301D0 3A 0B C0
    dec a                        ; 0301D3 3D
    jr z,+                       ; 0301D4 28 04
    ld ($c00b),a                 ; 0301D6 32 0B C0
    ret                          ; 0301D9 C9
+:  ld a,$0a                     ; 0301DA 3E 0A
    ld ($c00b),a                 ; 0301DC 32 0B C0
    ld a,($c00a)                 ; 0301DF 3A 0A C0
    inc a                        ; 0301E2 3C
    cp $8b                       ; 0301E3 FE 8B
    ld ($c00a),a                 ; 0301E5 32 0A C0
    jr nz,+                      ; 0301E8 20 0A
    xor a                        ; 0301EA AF
    ld ($c00a),a                 ; 0301EB 32 0A C0
    ld hl,$c0ce                  ; 0301EE 21 CE C0
    res 2,(hl)                   ; 0301F1 CB 96
    ret                          ; 0301F3 C9
+:  ld ix,$c00e                  ; 0301F4 DD 21 0E C0
    ld de,$0020                  ; 0301F8 11 20 00
    ld b,$06                     ; 0301FB 06 06
-:  ld a,(ix+$08)                ; 0301FD DD 7E 08
    dec a                        ; 030200 3D
    jp m,$8213                   ; 030201 FA 13 82
    cp (ix+$17)                  ; 030204 DD BE 17
    jr c,+                       ; 030207 38 0A
    ld (ix+$08),a                ; 030209 DD 77 08
    ld a,($c000)                 ; 03020C 3A 00 C0
    or a                         ; 03020F B7
    call nz,$8748                ; 030210 C4 48 87
+:  add ix,de                    ; 030213 DD 19
    djnz -                       ; 030215 10 E6
    ret                          ; 030217 C9
    
    call SilencePSGandFM         ; 030218 CD 1F 80
    ld a,($c005)                 ; 03021B 3A 05 C0
    ld ($c002),a                 ; 03021E 32 02 C0
    ld a,$80                     ; 030221 3E 80
    ld ($c00a),a                 ; 030223 32 0A C0
    ld a,$0a                     ; 030226 3E 0A
    ld ($c00b),a                 ; 030228 32 0B C0
    ld hl,$c0ce                  ; 03022B 21 CE C0
    set 2,(hl)                   ; 03022E CB D6
    push ix                      ; 030230 DD E5
      ld ix,$c00e                ; 030232 DD 21 0E C0
      ld b,$06                   ; 030236 06 06
      ld de,$0020                ; 030238 11 20 00
-:    ld a,(ix+$08)              ; 03023B DD 7E 08
      ld (ix+$17),a              ; 03023E DD 77 17
      ld a,$09                   ; 030241 3E 09
      ld (ix+$08),a              ; 030243 DD 77 08
      add ix,de                  ; 030246 DD 19
      djnz -                     ; 030248 10 F1
    pop ix                       ; 03024A DD E1
    jp $85f9                     ; 03024C C3 F9 85
    ld a,$0a                     ; 03024F 3E 0A
    ld ($c00b),a                 ; 030251 32 0B C0
    ld ($c009),a                 ; 030254 32 09 C0
    ld a,$03                     ; 030257 3E 03
    ld ($c00a),a                 ; 030259 32 0A C0
    ld a,($c002)                 ; 03025C 3A 02 C0
    or a                         ; 03025F B7
    jp m,$8267                   ; 030260 FA 67 82
    xor a                        ; 030263 AF
    ld ($c0ce),a                 ; 030264 32 CE C0
    ld a,$ff                     ; 030267 3E FF
    out ($7f),a                  ; 030269 D3 7F
    xor a                        ; 03026B AF
    ld ($c1ce),a                 ; 03026C 32 CE C1
    jp $85f9                     ; 03026F C3 F9 85
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
    xor a                        ; 03027B AF
    ld ($c12e),a                 ; 03027C 32 2E C1
    ld a,$df                     ; 03027F 3E DF
    out ($7f),a                  ; 030281 D3 7F
    ld a,$ff                     ; 030283 3E FF
    out ($7f),a                  ; 030285 D3 7F
    ld a,$25                     ; 030287 3E 25
    out ($f0),a                  ; 030289 D3 F0
    call $8b34                   ; 03028B CD 34 8B
    xor a                        ; 03028E AF
    out ($f1),a                  ; 03028F D3 F1
    ret                          ; 030291 C9

    push bc                      ; 030292 C5
      ld b,$12                   ; 030293 06 12
      ld hl,$8312                ; 030295 21 12 83
      ld c,$f1                   ; 030298 0E F1
    -:dec c                      ; 03029A 0D
      outi                       ; 03029B ED A3
      inc c                      ; 03029D 0C
      call $8b34                 ; 03029E CD 34 8B
      outi                       ; 0302A1 ED A3
      call $8b34                 ; 0302A3 CD 34 8B
      jr nz,-                    ; 0302A6 20 F2
    pop bc                       ; 0302A8 C1
    ret                          ; 0302A9 C9
    ld a,($c002)                 ; 0302AA 3A 02 C0
    cp $7f                       ; 0302AD FE 7F
    jp z,$824f                   ; 0302AF CA 4F 82
    ld a,$80                     ; 0302B2 3E 80
    ld ($c006),a                 ; 0302B4 32 06 C0
    jp $824f                     ; 0302B7 C3 4F 82
    xor a                        ; 0302BA AF
    ld ($c10e),a                 ; 0302BB 32 0E C1
    ld ($c0ee),a                 ; 0302BE 32 EE C0
    ld hl,$c08e                  ; 0302C1 21 8E C0
    call $8307                   ; 0302C4 CD 07 83
    ld hl,$c1ae                  ; 0302C7 21 AE C1
    call $8307                   ; 0302CA CD 07 83
    ex af,af'                    ; 0302CD 08
    jr nz,+                      ; 0302CE 20 0D
    ex af,af'                    ; 0302D0 08
    ld hl,$804a                  ; 0302D1 21 4A 80
    ld c,$7f                     ; 0302D4 0E 7F
    ld b,$08                     ; 0302D6 06 08
    otir                         ; 0302D8 ED B3
    jp $85f9                     ; 0302DA C3 F9 85
+:  ex af,af'                    ; 0302DD 08
    ld a,$25                     ; 0302DE 3E 25
    call ZeroYM2413Channel       ; 0302E0 CD 72 82
    call $8b34                   ; 0302E3 CD 34 8B
    ld a,$24                     ; 0302E6 3E 24
    call ZeroYM2413Channel       ; 0302E8 CD 72 82
    ld a,($c002)                 ; 0302EB 3A 02 C0
    or a                         ; 0302EE B7
    jp m,$85f9                   ; 0302EF FA F9 85
    push ix                      ; 0302F2 DD E5
      ld ix,$c08e                ; 0302F4 DD 21 8E C0
      call $8748                 ; 0302F8 CD 48 87
      ld ix,$c0ae                ; 0302FB DD 21 AE C0
      call $8748                 ; 0302FF CD 48 87
    pop ix                       ; 030302 DD E1
    jp $85f9                     ; 030304 C3 F9 85
    ld de,$0020                  ; 030307 11 20 00
    ld b,$03                     ; 03030A 06 03
-:  res 2,(hl)                   ; 03030C CB 96
    add hl,de                    ; 03030E 19
    djnz -                       ; 03030F 10 FB
    ret                          ; 030311 C9
.ends
.org $30312-$30000

;;;;

.org $30466-$30000
.section "more sound code again" overwrite
    ld a,($c004)                 ; 030466 3A 04 C0
    bit 7,a                      ; 030469 CB 7F
    jp z,$8000                   ; 03046B CA 00 80
    cp $a0                       ; 03046E FE A0
    jr c,++                      ; 030470 38 3B
    cp $d0                       ; 030472 FE D0
    jp c,$8524                   ; 030474 DA 24 85
    cp $d5                       ; 030477 FE D5
    jp c,$8490                   ; 030479 DA 90 84
    cp $da                       ; 03047C FE DA
    jp nc,$8000                  ; 03047E D2 00 80
    sub $d5                      ; 030481 D6 D5
    add a,a                      ; 030483 87
    ld c,a                       ; 030484 4F
    ld b,$00                     ; 030485 06 00
    ld hl,$845c                  ; 030487 21 5C 84
    add hl,bc                    ; 03048A 09
    ld a,(hl)                    ; 03048B 7E
    inc hl                       ; 03048C 23
    ld h,(hl)                    ; 03048D 66
    ld l,a                       ; 03048E 6F
    jp (hl)                      ; 03048F E9
    ld hl,$8452                  ; 030490 21 52 84
    sub $d0                      ; 030493 D6 D0
    ex af,af'                    ; 030495 08
    jr nz,+                      ; 030496 20 03
    ld hl,$83c0                  ; 030498 21 C0 83
+:  ex af,af'                    ; 03049B 08
    call $85ff                   ; 03049C CD FF 85
    ld de,$c12e                  ; 03049F 11 2E C1
    ld a,$ff                     ; 0304A2 3E FF
    out ($7f),a                  ; 0304A4 D3 7F
    ld a,$df                     ; 0304A6 3E DF
    out ($7f),a                  ; 0304A8 D3 7F
    jp $85c6                     ; 0304AA C3 C6 85
++: cp $95                       ; 0304AD FE 95
    jp nc,$85f9                  ; 0304AF D2 F9 85
    sub $81                      ; 0304B2 D6 81
    ret m                        ; 0304B4 F8
    ld b,$00                     ; 0304B5 06 00
    ld c,a                       ; 0304B7 4F
    ld hl,$8324                  ; 0304B8 21 24 83
    add hl,bc                    ; 0304BB 09
    push af                      ; 0304BC F5
    ld a,($c002)                 ; 0304BD 3A 02 C0
    and $7f                      ; 0304C0 E6 7F
    ld ($c005),a                 ; 0304C2 32 05 C0
    ld a,(hl)                    ; 0304C5 7E
    ld ($c001),a                 ; 0304C6 32 01 C0
    ld ($c002),a                 ; 0304C9 32 02 C0
    push af                      ; 0304CC F5
    ld a,($c00a)                 ; 0304CD 3A 0A C0
    or a                         ; 0304D0 B7
    jp p,$84e7                   ; 0304D1 F2 E7 84
    ld ix,$c00e                  ; 0304D4 DD 21 0E C0
    ld de,$0020                  ; 0304D8 11 20 00
    ld b,$06                     ; 0304DB 06 06
-:  ld a,(ix+$17)                ; 0304DD DD 7E 17
    ld (ix+$08),a                ; 0304E0 DD 77 08
    add ix,de                    ; 0304E3 DD 19
    djnz -                       ; 0304E5 10 F6
    call $803c                   ; 0304E7 CD 3C 80
    call $801f                   ; 0304EA CD 1F 80
    pop af                       ; 0304ED F1
    ex af,af'                    ; 0304EE 08
    jr nz,+                      ; 0304EF 20 13
    ex af,af'                    ; 0304F1 08
    ld de,$c14e                  ; 0304F2 11 4E C1
    or a                         ; 0304F5 B7
    jp m,$84ff                   ; 0304F6 FA FF 84
    call $8000                   ; 0304F9 CD 00 80
    ld de,$c06e                  ; 0304FC 11 6E C0
    ld hl,$8338                  ; 0304FF 21 38 83
    jr ++                        ; 030502 18 19
+:  ex af,af'                    ; 030504 08
    call $8292                   ; 030505 CD 92 82
    ld de,$c14e                  ; 030508 11 4E C1
    or a                         ; 03050B B7
    jp m,$8517                   ; 03050C FA 17 85
    ld de,$c00e                  ; 03050F 11 0E C0
    call $8000                   ; 030512 CD 00 80
    jr +                         ; 030515 18 03
    call $802c                   ; 030517 CD 2C 80
+:  ld hl,$83ca                  ; 03051A 21 CA 83
++: pop af                       ; 03051D F1
    call $85ff                   ; 03051E CD FF 85
    jp $85c6                     ; 030521 C3 C6 85
    sub $a0                      ; 030524 D6 A0
    ld hl,$8360                  ; 030526 21 60 83
    ex af,af'                    ; 030529 08
    jr z,+                       ; 03052A 28 03
    ld hl,$83f2                  ; 03052C 21 F2 83
+:  ex af,af'                    ; 03052F 08
    call $85ff                   ; 030530 CD FF 85
    ld h,b                       ; 030533 60
    ld l,c                       ; 030534 69
    inc hl                       ; 030535 23
    inc hl                       ; 030536 23
    ld a,(hl)                    ; 030537 7E
    ex af,af'                    ; 030538 08
    jr z,+++                     ; 030539 28 2C
    ex af,af'                    ; 03053B 08
    cp $10                       ; 03053C FE 10
    jr z,+                       ; 03053E 28 0B
    cp $14                       ; 030540 FE 14
    jr z,++                      ; 030542 28 0F
    ld de,$c10e                  ; 030544 11 0E C1
    ld a,$25                     ; 030547 3E 25
    jr ++++                      ; 030549 18 12
+:  call $8000                   ; 03054B CD 00 80
    ld de,$c00e                  ; 03054E 11 0E C0
    jr _05c6                     ; 030551 18 73
++: ld de,$c0ee                  ; 030553 11 EE C0
    ld a,$24                     ; 030556 3E 24
    ld hl,$c08e                  ; 030558 21 8E C0
    set 2,(hl)                   ; 03055B CB D6
++++:
    ld hl,$c0ae                  ; 03055D 21 AE C0
    set 2,(hl)                   ; 030560 CB D6
    call ZeroYM2413Channel       ; 030562 CD 72 82
    jr _05c6                     ; 030565 18 5F

+++:ex af,af'                    ; 030567 08
    cp $c0                       ; 030568 FE C0
    jr z,+                       ; 03056A 28 1F
    cp $e0                       ; 03056C FE E0
    jr z,++                      ; 03056E 28 0E
    cp $a0                       ; 030570 FE A0
    jr z,+++                     ; 030572 28 1C
    push bc                      ; 030574 C5
    call $8000                   ; 030575 CD 00 80
    pop bc                       ; 030578 C1
    ld de,$c06e                  ; 030579 11 6E C0
    jr _05c6                     ; 03057C 18 48

++: ld a,$df                     ; 03057E 3E DF
    out ($7f),a                  ; 030580 D3 7F
    ld hl,$c0ce                  ; 030582 21 CE C0
    set 2,(hl)                   ; 030585 CB D6
    ld a,$e7                     ; 030587 3E E7
    out ($7f),a                  ; 030589 D3 7F
+:  ld de,$c10e                  ; 03058B 11 0E C1
    jr +                         ; 03058E 18 28
+++:ld de,$0009                  ; 030590 11 09 00
    add hl,de                    ; 030593 19
    ld a,(hl)                    ; 030594 7E
    cp $e0                       ; 030595 FE E0
    jr nz,++                     ; 030597 20 12
    ld a,$e7                     ; 030599 3E E7
    out ($7f),a                  ; 03059B D3 7F
    ld hl,$c0ce                  ; 03059D 21 CE C0
    set 2,(hl)                   ; 0305A0 CB D6
    ld hl,$c1ce                  ; 0305A2 21 CE C1
    set 2,(hl)                   ; 0305A5 CB D6
    ld a,$df                     ; 0305A7 3E DF
    out ($7f),a                  ; 0305A9 D3 7F
++: ld de,$c0ee                  ; 0305AB 11 EE C0
    ld hl,$c08e                  ; 0305AE 21 8E C0
    set 2,(hl)                   ; 0305B1 CB D6
    ld hl,$c18e                  ; 0305B3 21 8E C1
    set 2,(hl)                   ; 0305B6 CB D6
+:  ld a,$ff                     ; 0305B8 3E FF
    out ($7f),a                  ; 0305BA D3 7F
    ld hl,$c0ae                  ; 0305BC 21 AE C0
    set 2,(hl)                   ; 0305BF CB D6
    ld hl,$c1ae                  ; 0305C1 21 AE C1
    set 2,(hl)                   ; 0305C4 CB D6
_05c6:
    ld h,b                       ; 0305C6 60
    ld l,c                       ; 0305C7 69
    ld b,(hl)                    ; 0305C8 46
    inc hl                       ; 0305C9 23
-:  push bc                      ; 0305CA C5
    push hl                      ; 0305CB E5
    pop ix                       ; 0305CC DD E1
    ld bc,$0009                  ; 0305CE 01 09 00
    ldir                         ; 0305D1 ED B0
    ld a,$20                     ; 0305D3 3E 20
    ld (de),a                    ; 0305D5 12
    inc de                       ; 0305D6 13
    ld a,$01                     ; 0305D7 3E 01
    ld (de),a                    ; 0305D9 12
    inc de                       ; 0305DA 13
    xor a                        ; 0305DB AF
    ld (de),a                    ; 0305DC 12
    inc de                       ; 0305DD 13
    ld (de),a                    ; 0305DE 12
    inc de                       ; 0305DF 13
    ld (de),a                    ; 0305E0 12
    push hl                      ; 0305E1 E5
    ld hl,$0013                  ; 0305E2 21 13 00
    add hl,de                    ; 0305E5 19
    ex de,hl                     ; 0305E6 EB
    pop hl                       ; 0305E7 E1
    ld bc,$85f6                  ; 0305E8 01 F6 85
    push bc                      ; 0305EB C5
    ld a,($c000)                 ; 0305EC 3A 00 C0
    or a                         ; 0305EF B7
    jp nz,$8748                  ; 0305F0 C2 48 87
    jp $8cce                     ; 0305F3 C3 CE 8C
    pop bc                       ; 0305F6 C1
    djnz -                       ; 0305F7 10 D1
    ld a,$80                     ; 0305F9 3E 80
    ld ($c004),a                 ; 0305FB 32 04 C0
    ret                          ; 0305FE C9
    add a,a                      ; 0305FF 87
    ld b,$00                     ; 030600 06 00
    ld c,a                       ; 030602 4F
    add hl,bc                    ; 030603 09
    ld c,(hl)                    ; 030604 4E
    inc hl                       ; 030605 23
    ld b,(hl)                    ; 030606 46
    ret                          ; 030607 C9
    inc (ix+$0b)                 ; 030608 DD 34 0B
    ld a,(ix+$0a)                ; 03060B DD 7E 0A
    sub (ix+$0b)                 ; 03060E DD 96 0B
    jr nz,+                      ; 030611 20 14
    call $8636                   ; 030613 CD 36 86
    bit 2,(ix+$00)               ; 030616 DD CB 00 56
    ret nz                       ; 03061A C0
    ld a,$0e                     ; 03061B 3E 0E
    out ($f0),a                  ; 03061D D3 F0
    ld a,(ix+$10)                ; 03061F DD 7E 10
    or $20                       ; 030622 F6 20
    out ($f1),a                  ; 030624 D3 F1
    ret                          ; 030626 C9

+:  cp $02                       ; 030627 FE 02
    ret nz                       ; 030629 C0
    ld a,$0e                     ; 03062A 3E 0E
    out ($f0),a                  ; 03062C D3 F0
    call $8b34                   ; 03062E CD 34 8B
    ld a,$20                     ; 030631 3E 20
    out ($f1),a                  ; 030633 D3 F1
    ret                          ; 030635 C9
    ld e,(ix+$03)                ; 030636 DD 5E 03
    ld d,(ix+$04)                ; 030639 DD 56 04
    ld a,(de)                    ; 03063C 1A
    inc de                       ; 03063D 13
    cp $e0                       ; 03063E FE E0
    jp nc,$865a                  ; 030640 D2 5A 86
    cp $7f                       ; 030643 FE 7F
    jp c,$880b                   ; 030645 DA 0B 88
    bit 5,a                      ; 030648 CB 6F
    jr z,+                       ; 03064A 28 02
    or $01                       ; 03064C F6 01
+:  bit 2,a                      ; 03064E CB 57
    jr z,+                       ; 030650 28 02
    or $10                       ; 030652 F6 10
+:  ld (ix+$10),a                ; 030654 DD 77 10
    jp $87fd                     ; 030657 C3 FD 87
    ld hl,$8660                  ; 03065A 21 60 86
    jp $88ae                     ; 03065D C3 AE 88
    inc de                       ; 030660 13
    jp $863c                     ; 030661 C3 3C 86
    inc (ix+$0b)                 ; 030664 DD 34 0B
    ld a,(ix+$0a)                ; 030667 DD 7E 0A
    sub (ix+$0b)                 ; 03066A DD 96 0B
    call z,$87b9                 ; 03066D CC B9 87
    ld ($c00c),a                 ; 030670 32 0C C0
    cp $80                       ; 030673 FE 80
    jp z,$86cd                   ; 030675 CA CD 86
    bit 5,(ix+$00)               ; 030678 DD CB 00 6E
    jp z,$86cd                   ; 03067C CA CD 86
    exx                          ; 03067F D9
    ld (hl),$80                  ; 030680 36 80
    exx                          ; 030682 D9
    bit 3,(ix+$00)               ; 030683 DD CB 00 5E
    jp nz,$86ad                  ; 030687 C2 AD 86
    ld a,(ix+$11)                ; 03068A DD 7E 11
    bit 7,a                      ; 03068D CB 7F
    jr z,+                       ; 03068F 28 0E
    add a,(ix+$0e)               ; 030691 DD 86 0E
    jr c,++                      ; 030694 38 34
    dec (ix+$0f)                 ; 030696 DD 35 0F
    dec (ix+$0f)                 ; 030699 DD 35 0F
    jp $86c6                     ; 03069C C3 C6 86
+:  add a,(ix+$0e)               ; 03069F DD 86 0E
    jr nc,++                     ; 0306A2 30 26
    inc (ix+$0f)                 ; 0306A4 DD 34 0F
    inc (ix+$0f)                 ; 0306A7 DD 34 0F
    jp $86c6                     ; 0306AA C3 C6 86
    ld a,(ix+$11)                ; 0306AD DD 7E 11
    bit 7,a                      ; 0306B0 CB 7F
    jr z,+                       ; 0306B2 28 0A
    add a,(ix+$0e)               ; 0306B4 DD 86 0E
    jr c,++                      ; 0306B7 38 11
    dec (ix+$0f)                 ; 0306B9 DD 35 0F
    jr +++                       ; 0306BC 18 08
+:  add a,(ix+$0e)               ; 0306BE DD 86 0E
    jr nc,++                     ; 0306C1 30 07
    inc (ix+$0f)                 ; 0306C3 DD 34 0F
+++:set 1,(ix+$07)               ; 0306C6 DD CB 07 CE
++: ld (ix+$0e),a                ; 0306CA DD 77 0E
    bit 2,(ix+$00)               ; 0306CD DD CB 00 56
    ret nz                       ; 0306D1 C0
    ld a,(ix+$13)                ; 0306D2 DD 7E 13
    cp $1f                       ; 0306D5 FE 1F
    ret z                        ; 0306D7 C8
    ld a,($c00c)                 ; 0306D8 3A 0C C0
    bit 0,(ix+$07)               ; 0306DB DD CB 07 46
    jr nz,+                      ; 0306DF 20 05
    cp $02                       ; 0306E1 FE 02
    jp c,$875e                   ; 0306E3 DA 5E 87
+:  or a                         ; 0306E6 B7
    jp m,$86f7                   ; 0306E7 FA F7 86
    bit 7,(ix+$14)               ; 0306EA DD CB 14 7E
    ret nz                       ; 0306EE C0
    ld a,(ix+$06)                ; 0306EF DD 7E 06
    dec a                        ; 0306F2 3D
    jp p,$86fb                   ; 0306F3 F2 FB 86
    ret                          ; 0306F6 C9
    ld a,(ix+$06)                ; 0306F7 DD 7E 06
    dec a                        ; 0306FA 3D
    ld l,(ix+$0e)                ; 0306FB DD 6E 0E
    ld h,(ix+$0f)                ; 0306FE DD 66 0F
    jp m,$870e                   ; 030701 FA 0E 87
    ex de,hl                     ; 030704 EB
    ld hl,$b805                  ; 030705 21 05 B8
    call $876b                   ; 030708 CD 6B 87
    call $8778                   ; 03070B CD 78 87
    bit 3,(ix+$00)               ; 03070E DD CB 00 5E
    call nz,$8855                ; 030712 C4 55 88
    ld c,$f1                     ; 030715 0E F1
    ld a,(ix+$01)                ; 030717 DD 7E 01
    out ($f0),a                  ; 03071A D3 F0
    add a,$10                    ; 03071C C6 10
    call $8b34                   ; 03071E CD 34 8B
    out (c),l                    ; 030721 ED 69
    call $8b34                   ; 030723 CD 34 8B
    exx                          ; 030726 D9
    bit 7,(hl)                   ; 030727 CB 7E
    exx                          ; 030729 D9
    out ($f0),a                  ; 03072A D3 F0
    jr nz,+                      ; 03072C 20 0F
    bit 0,(ix+$07)               ; 03072E DD CB 07 46
    jr z,+                       ; 030732 28 09
    bit 1,(ix+$07)               ; 030734 DD CB 07 4E
    ret z                        ; 030738 C8
    res 1,(ix+$07)               ; 030739 DD CB 07 8E
+:  bit 2,(ix+$07)               ; 03073D DD CB 07 56
    jr z,+                       ; 030741 28 02
    set 5,h                      ; 030743 CB EC
+:  out (c),h                    ; 030745 ED 61
    ret                          ; 030747 C9

    ld a,(ix+$01)                ; 030748 DD 7E 01
    add a,$20                    ; 03074B C6 20
    out ($f0),a                  ; 03074D D3 F0
    ld a,(ix+$07)                ; 03074F DD 7E 07
    and $f0                      ; 030752 E6 F0
    ld c,a                       ; 030754 4F
    ld a,(ix+$08)                ; 030755 DD 7E 08
    and $0f                      ; 030758 E6 0F
    or c                         ; 03075A B1
    out ($f1),a                  ; 03075B D3 F1
    ret                          ; 03075D C9
    ld a,(ix+$01)                ; 03075E DD 7E 01
    add a,$10                    ; 030761 C6 10
    call ZeroYM2413Channel       ; 030763 CD 72 82
    ld (ix+$13),$1f              ; 030766 DD 36 13 1F
    ret                          ; 03076A C9
    ld c,a                       ; 03076B 4F
    ld b,$00                     ; 03076C 06 00
    add hl,bc                    ; 03076E 09
    add hl,bc                    ; 03076F 09
    ld a,(hl)                    ; 030770 7E
    inc hl                       ; 030771 23
    ld h,(hl)                    ; 030772 66
    ld l,a                       ; 030773 6F
    ret                          ; 030774 C9

-:  ld (ix+$0d),a                ; 030775 DD 77 0D
    push hl                      ; 030778 E5
    ld c,(ix+$0d)                ; 030779 DD 4E 0D
    ld b,$00                     ; 03077C 06 00
    add hl,bc                    ; 03077E 09
    ld c,l                       ; 03077F 4D
    ld b,h                       ; 030780 44
    pop hl                       ; 030781 E1
    ld a,(bc)                    ; 030782 0A
    bit 7,a                      ; 030783 CB 7F
    jp z,$879e                   ; 030785 CA 9E 87
    cp $83                       ; 030788 FE 83
    jr z,+                       ; 03078A 28 0B
    cp $80                       ; 03078C FE 80
    jr z,++                      ; 03078E 28 0B
    ld a,$ff                     ; 030790 3E FF
    ld (ix+$14),a                ; 030792 DD 77 14
    pop hl                       ; 030795 E1
    ret                          ; 030796 C9

+:  inc bc                       ; 030797 03
    ld a,(bc)                    ; 030798 0A
    jr -                         ; 030799 18 DA
++: xor a                        ; 03079B AF
    jr -                         ; 03079C 18 D7
    inc (ix+$0d)                 ; 03079E DD 34 0D
    ld l,a                       ; 0307A1 6F
    ld h,$00                     ; 0307A2 26 00
    add hl,de                    ; 0307A4 19
    ld a,($c000)                 ; 0307A5 3A 00 C0
    or a                         ; 0307A8 B7
    jr z,+                       ; 0307A9 28 0A
    ld a,h                       ; 0307AB 7C
    cp (ix+$10)                  ; 0307AC DD BE 10
    jr z,+                       ; 0307AF 28 04
    set 1,(ix+$07)               ; 0307B1 DD CB 07 CE
+:  ld (ix+$10),a                ; 0307B5 DD 77 10
    ret                          ; 0307B8 C9
    ld e,(ix+$03)                ; 0307B9 DD 5E 03
    ld d,(ix+$04)                ; 0307BC DD 56 04
    ld a,(de)                    ; 0307BF 1A
    inc de                       ; 0307C0 13
    cp $e0                       ; 0307C1 FE E0
    jp nc,$88ab                  ; 0307C3 D2 AB 88
    bit 3,(ix+$00)               ; 0307C6 DD CB 00 5E
    jp nz,$8834                  ; 0307CA C2 34 88
    cp $80                       ; 0307CD FE 80
    jp c,$880b                   ; 0307CF DA 0B 88
    jr nz,+                      ; 0307D2 20 00        ; does nothing
+:  call $8894                   ; 0307D4 CD 94 88
    ld a,(hl)                    ; 0307D7 7E
    ld (ix+$0e),a                ; 0307D8 DD 77 0E
    inc hl                       ; 0307DB 23
    ld a,(hl)                    ; 0307DC 7E
    ld (ix+$0f),a                ; 0307DD DD 77 0F
    bit 5,(ix+$00)               ; 0307E0 DD CB 00 6E
    jp z,$87fd                   ; 0307E4 CA FD 87
    ld a,(de)                    ; 0307E7 1A
    inc de                       ; 0307E8 13
    ld (ix+$12),a                ; 0307E9 DD 77 12
    ld (ix+$11),a                ; 0307EC DD 77 11
    bit 3,(ix+$00)               ; 0307EF DD CB 00 5E
    ld a,(de)                    ; 0307F3 1A
    jr nz,+                      ; 0307F4 20 14
    ld (ix+$11),a                ; 0307F6 DD 77 11
    inc de                       ; 0307F9 13
    ld a,(de)                    ; 0307FA 1A
    jr +                         ; 0307FB 18 0D
    ld a,(de)                    ; 0307FD 1A
    or a                         ; 0307FE B7
    jp p,$880a                   ; 0307FF F2 0A 88
    ld a,(ix+$15)                ; 030802 DD 7E 15
    ld (ix+$0a),a                ; 030805 DD 77 0A
    jr ++                        ; 030808 18 11
+:  inc de                       ; 03080A 13
    ld b,(ix+$02)                ; 03080B DD 46 02
    dec b                        ; 03080E 05
    jr z,+                       ; 03080F 28 04
    ld c,a                       ; 030811 4F
-:  add a,c                      ; 030812 81
    djnz -                       ; 030813 10 FD
+:  ld (ix+$0a),a                ; 030815 DD 77 0A
    ld (ix+$15),a                ; 030818 DD 77 15
++: xor a                        ; 03081B AF
    ld (ix+$0c),a                ; 03081C DD 77 0C
    ld (ix+$0d),a                ; 03081F DD 77 0D
    ld (ix+$0b),a                ; 030822 DD 77 0B
    ld (ix+$13),a                ; 030825 DD 77 13
    ld (ix+$14),a                ; 030828 DD 77 14
    ld (ix+$03),e                ; 03082B DD 73 03
    ld (ix+$04),d                ; 03082E DD 72 04
    ld a,$80                     ; 030831 3E 80
    ret                          ; 030833 C9
    ld h,a                       ; 030834 67
    ld a,(de)                    ; 030835 1A
    inc de                       ; 030836 13
    ld l,a                       ; 030837 6F
    ld a,(ix+$05)                ; 030838 DD 7E 05
    or a                         ; 03083B B7
    jr z,+                       ; 03083C 28 0E
    jp p,$8847                   ; 03083E F2 47 88
    add a,l                      ; 030841 85
    jr c,++                      ; 030842 38 07
    dec h                        ; 030844 25
    jr ++                        ; 030845 18 04
    add a,l                      ; 030847 85
    jr nc,++                     ; 030848 30 01
    inc h                        ; 03084A 24
++: ld l,a                       ; 03084B 6F
+:  ld (ix+$0e),l                ; 03084C DD 75 0E
    ld (ix+$0f),h                ; 03084F DD 74 0F
    jp $87e0                     ; 030852 C3 E0 87
    push de                      ; 030855 D5
_0856:
    ld a,h                       ; 030856 7C
    or a                         ; 030857 B7
    jr z,+                       ; 030858 28 0E
    cp $02                       ; 03085A FE 02
    ld a,$12                     ; 03085C 3E 12
    jr c,++                      ; 03085E 38 21
    srl h                        ; 030860 CB 3C
    rr l                         ; 030862 CB 1D
    ld a,$10                     ; 030864 3E 10
    jr ++                        ; 030866 18 19
+:  ld a,l                       ; 030868 7D
    or a                         ; 030869 B7
    jp z,$8892                   ; 03086A CA 92 88
    ld bc,$0400                  ; 03086D 01 00 04
-:  rlca                         ; 030870 07
    inc c                        ; 030871 0C
    jr c,+                       ; 030872 38 02
    djnz -                       ; 030874 10 FA
+:  ld b,c                       ; 030876 41
    ld a,$12                     ; 030877 3E 12
-:  inc a                        ; 030879 3C
    inc a                        ; 03087A 3C
    sla l                        ; 03087B CB 25
    rl h                         ; 03087D CB 14
    djnz -                       ; 03087F 10 F8
++: ld de,$0757                  ; 030881 11 57 07
    ex de,hl                     ; 030884 EB
    or a                         ; 030885 B7
    sbc hl,de                    ; 030886 ED 52
    bit 1,h                      ; 030888 CB 4C
    jr z,+                       ; 03088A 28 02
    set 0,h                      ; 03088C CB C4
+:  ld d,a                       ; 03088E 57
    ld e,$00                     ; 03088F 1E 00
    add hl,de                    ; 030891 19
    pop de                       ; 030892 D1
    ret                          ; 030893 C9
    sub $80                      ; 030894 D6 80
    jr z,+                       ; 030896 28 03
    add a,(ix+$05)               ; 030898 DD 86 05
+:  ld hl,$8cdb                  ; 03089B 21 DB 8C
    ex af,af'                    ; 03089E 08
    jr z,+                       ; 03089F 28 03
    ld hl,$8d6d                  ; 0308A1 21 6D 8D
+:  ex af,af'                    ; 0308A4 08
    ld c,a                       ; 0308A5 4F
    ld b,$00                     ; 0308A6 06 00
    add hl,bc                    ; 0308A8 09
    add hl,bc                    ; 0308A9 09
    ret                          ; 0308AA C9
    ld hl,$88be                  ; 0308AB 21 BE 88
    push hl                      ; 0308AE E5
    sub $ee                      ; 0308AF D6 EE
    ld hl,$88c2                  ; 0308B1 21 C2 88
    add a,a                      ; 0308B4 87
    ld c,a                       ; 0308B5 4F
    ld b,$00                     ; 0308B6 06 00
    add hl,bc                    ; 0308B8 09
    ld c,(hl)                    ; 0308B9 4E
    inc hl                       ; 0308BA 23
    ld h,(hl)                    ; 0308BB 66
    ld l,c                       ; 0308BC 69
    jp (hl)                      ; 0308BD E9
    inc de                       ; 0308BE 13
    jp $87bf                     ; 0308BF C3 BF 87
    ret p                        ; 0308C2 F0
    adc a,b                      ; 0308C3 88
    ld hl,$3989                  ; 0308C4 21 89 39
    adc a,c                      ; 0308C7 89
    and $88                      ; 0308C8 E6 88
    jr c,_0856                   ; 0308CA 38 8A
    ld (hl),a                    ; 0308CC 77
    adc a,c                      ; 0308CD 89
    xor c                        ; 0308CE A9
    adc a,c                      ; 0308CF 89
    adc a,e                      ; 0308D0 8B
    adc a,c                      ; 0308D1 89
    add a,$89                    ; 0308D2 C6 89
    inc e                        ; 0308D4 1C
    adc a,e                      ; 0308D5 8B
    xor $8a                      ; 0308D6 EE 8A
    add hl,bc                    ; 0308D8 09
    adc a,e                      ; 0308D9 8B
    ld h,c                       ; 0308DA 61
    adc a,c                      ; 0308DB 89
    ld d,b                       ; 0308DC 50
    adc a,c                      ; 0308DD 89
    call z,$2989                 ; 0308DE CC 89 29
    adc a,d                      ; 0308E1 8A
    inc e                        ; 0308E2 1C
    adc a,c                      ; 0308E3 89
    ret m                        ; 0308E4 F8
    adc a,b                      ; 0308E5 88
    ld a,(de)                    ; 0308E6 1A
    ld ($c009),a                 ; 0308E7 32 09 C0
    ld ($c00b),a                 ; 0308EA 32 0B C0
    jp $8257                     ; 0308ED C3 57 82
    ld a,(de)                    ; 0308F0 1A
    add a,(ix+$02)               ; 0308F1 DD 86 02
    ld (ix+$02),a                ; 0308F4 DD 77 02
    ret                          ; 0308F7 C9
    ld a,(ix+$01)                ; 0308F8 DD 7E 01
    add a,$10                    ; 0308FB C6 10
    out ($f0),a                  ; 0308FD D3 F0
    call $8b34                   ; 0308FF CD 34 8B
    xor a                        ; 030902 AF
    out ($f1),a                  ; 030903 D3 F1
    call $8b34                   ; 030905 CD 34 8B
    ld h,d                       ; 030908 62
    ld l,e                       ; 030909 6B
    ld b,$08                     ; 03090A 06 08
    ld c,$f1                     ; 03090C 0E F1
-:  out ($f0),a                  ; 03090E D3 F0
    inc a                        ; 030910 3C
    call $8b34                   ; 030911 CD 34 8B
    outi                         ; 030914 ED A3
    jr nz,-                      ; 030916 20 F6
    ld d,h                       ; 030918 54
    ld e,l                       ; 030919 5D
    dec de                       ; 03091A 1B
    ret                          ; 03091B C9
    ld a,($c000)                 ; 03091C 3A 00 C0
    or a                         ; 03091F B7
    ret z                        ; 030920 C8
    ld a,($c00a)                 ; 030921 3A 0A C0
    or a                         ; 030924 B7
    jp m,$892f                   ; 030925 FA 2F 89
    ld a,(de)                    ; 030928 1A
    add a,(ix+$08)               ; 030929 DD 86 08
    jp $8966                     ; 03092C C3 66 89
    ld a,(de)                    ; 03092F 1A
    add a,(ix+$17)               ; 030930 DD 86 17
    and $0f                      ; 030933 E6 0F
    ld (ix+$17),a                ; 030935 DD 77 17
    ret                          ; 030938 C9
    ld a,(de)                    ; 030939 1A
    cp $01                       ; 03093A FE 01
    jr z,+                       ; 03093C 28 09
    res 0,(ix+$07)               ; 03093E DD CB 07 86
    res 1,(ix+$07)               ; 030942 DD CB 07 8E
    ret                          ; 030946 C9

+:  set 0,(ix+$07)               ; 030947 DD CB 07 C6
    set 1,(ix+$07)               ; 03094B DD CB 07 CE
    ret                          ; 03094F C9
    ex af,af'                    ; 030950 08
    jr nz,+                      ; 030951 20 05
    ex af,af'                    ; 030953 08
    ld a,(de)                    ; 030954 1A
    inc de                       ; 030955 13
    jr ++                        ; 030956 18 02
+:  inc de                       ; 030958 13
    ld a,(de)                    ; 030959 1A
++: add a,(ix+$05)               ; 03095A DD 86 05
    ld (ix+$05),a                ; 03095D DD 77 05
    ret                          ; 030960 C9
    ld a,(de)                    ; 030961 1A
    ld (ix+$02),a                ; 030962 DD 77 02
    ret                          ; 030965 C9
    and $0f                      ; 030966 E6 0F
    ld (ix+$08),a                ; 030968 DD 77 08
    ex af,af'                    ; 03096B 08
    jp nz,$8973                  ; 03096C C2 73 89
    ex af,af'                    ; 03096F 08
    jp $8cce                     ; 030970 C3 CE 8C
    ex af,af'                    ; 030973 08
    jp $8748                     ; 030974 C3 48 87
    ld a,(de)                    ; 030977 1A
    or $e0                       ; 030978 F6 E0
    out ($7f),a                  ; 03097A D3 7F
    or $fc                       ; 03097C F6 FC
    inc a                        ; 03097E 3C
    jr nz,+                      ; 03097F 20 05
    res 6,(ix+$00)               ; 030981 DD CB 00 B6
    ret                          ; 030985 C9

+:  set 6,(ix+$00)               ; 030986 DD CB 00 F6
    ret                          ; 03098A C9

    ex af,af'                    ; 03098B 08
    jr nz,+                      ; 03098C 20 0A
    ex af,af'                    ; 03098E 08
    ld a,(de)                    ; 03098F 1A
    inc de                       ; 030990 13
    cp $80                       ; 030991 FE 80
    ret z                        ; 030993 C8
    ld (ix+$07),a                ; 030994 DD 77 07
    ret                          ; 030997 C9

+:  ex af,af'                    ; 030998 08
    inc de                       ; 030999 13
    ld a,(de)                    ; 03099A 1A
    cp $04                       ; 03099B FE 04
    ret z                        ; 03099D C8
    ld (ix+$07),a                ; 03099E DD 77 07
    ld a,($c00a)                 ; 0309A1 3A 0A C0
    or a                         ; 0309A4 B7
    ret nz                       ; 0309A5 C0
    jp $8748                     ; 0309A6 C3 48 87
    ld a,(de)                    ; 0309A9 1A
    ld (ix+$06),a                ; 0309AA DD 77 06
    ret                          ; 0309AD C9
    ld b,$00                     ; 0309AE 06 00
    ld c,$1c                     ; 0309B0 0E 1C
    push ix                      ; 0309B2 DD E5
    pop hl                       ; 0309B4 E1
    add hl,bc                    ; 0309B5 09
    ld a,(hl)                    ; 0309B6 7E
    or a                         ; 0309B7 B7
    jr nz,+                      ; 0309B8 20 06
    ld a,(de)                    ; 0309BA 1A
    dec a                        ; 0309BB 3D
    ld (hl),a                    ; 0309BC 77
    inc de                       ; 0309BD 13
    inc de                       ; 0309BE 13
    ret                          ; 0309BF C9

+:  inc de                       ; 0309C0 13
    dec (hl)                     ; 0309C1 35
    jr z,+                       ; 0309C2 28 02
    inc de                       ; 0309C4 13
    ret                          ; 0309C5 C9

+:  ex de,hl                     ; 0309C6 EB
    ld e,(hl)                    ; 0309C7 5E
    inc hl                       ; 0309C8 23
    ld d,(hl)                    ; 0309C9 56
    dec de                       ; 0309CA 1B
    ret                          ; 0309CB C9
    ld a,(de)                    ; 0309CC 1A
    cp $01                       ; 0309CD FE 01
    jr nz,++                     ; 0309CF 20 2E
    set 5,(ix+$00)               ; 0309D1 DD CB 00 EE
    ld a,(ix+$01)                ; 0309D5 DD 7E 01
    ex af,af'                    ; 0309D8 08
    jr nz,+                      ; 0309D9 20 0D
    ex af,af'                    ; 0309DB 08
    ld a,(ix+$08)                ; 0309DC DD 7E 08
    or a                         ; 0309DF B7
    ret z                        ; 0309E0 C8
    dec (ix+$08)                 ; 0309E1 DD 35 08
    dec (ix+$08)                 ; 0309E4 DD 35 08
    ret                          ; 0309E7 C9

+:  ex af,af'                    ; 0309E8 08
    cp $13                       ; 0309E9 FE 13
    ret nc                       ; 0309EB D0
    dec (ix+$08)                 ; 0309EC DD 35 08
    dec (ix+$08)                 ; 0309EF DD 35 08
    ld a,(ix+$07)                ; 0309F2 DD 7E 07
    ld (ix+$16),a                ; 0309F5 DD 77 16
    ld (ix+$07),$53              ; 0309F8 DD 36 07 53
    jp $8748                     ; 0309FC C3 48 87

++:
    res 5,(ix+$00)               ; 0309FF DD CB 00 AE
    ld a,(ix+$01)                ; 030A03 DD 7E 01
    ex af,af'                    ; 030A06 08
    jr nz,+                      ; 030A07 20 0D
    ex af,af'                    ; 030A09 08
    ld a,(ix+$08)                ; 030A0A DD 7E 08
    or a                         ; 030A0D B7
    ret z                        ; 030A0E C8
    inc (ix+$08)                 ; 030A0F DD 34 08
    inc (ix+$08)                 ; 030A12 DD 34 08
    ret                          ; 030A15 C9

+:
    ex af,af'                    ; 030A16 08
    cp $13                       ; 030A17 FE 13
    ret nc                       ; 030A19 D0
    inc (ix+$08)                 ; 030A1A DD 34 08
    inc (ix+$08)                 ; 030A1D DD 34 08
    ld a,(ix+$16)                ; 030A20 DD 7E 16
    ld (ix+$07),a                ; 030A23 DD 77 07
    jp $8748                     ; 030A26 C3 48 87
    ld a,(de)                    ; 030A29 1A
    cp $01                       ; 030A2A FE 01
    jr nz,+                      ; 030A2C 20 05
    set 3,(ix+$00)               ; 030A2E DD CB 00 DE
    ret                          ; 030A32 C9

+:  res 3,(ix+$00)               ; 030A33 DD CB 00 9E
    ret                          ; 030A37 C9
    ld hl,$c12e                  ; 030A38 21 2E C1
    res 2,(hl)                   ; 030A3B CB 96
    xor a                        ; 030A3D AF
    ld ($c008),a                 ; 030A3E 32 08 C0
    ld (ix+$00),a                ; 030A41 DD 77 00
    ex af,af'                    ; 030A44 08
    jp nz,$8a9d                  ; 030A45 C2 9D 8A
    ex af,af'                    ; 030A48 08
    ld a,(ix+$01)                ; 030A49 DD 7E 01
    add a,$1f                    ; 030A4C C6 1F
    out ($7f),a                  ; 030A4E D3 7F
    ld a,$e5                     ; 030A50 3E E5
    out ($7f),a                  ; 030A52 D3 7F
    ld a,($c08e)                 ; 030A54 3A 8E C0
    and $80                      ; 030A57 E6 80
    jr z,+                       ; 030A59 28 12
    ld hl,$c09c                  ; 030A5B 21 9C C0
    ld a,(hl)                    ; 030A5E 7E
    inc hl                       ; 030A5F 23
    ld h,(hl)                    ; 030A60 66
    ld l,a                       ; 030A61 6F
    ld a,($c08f)                 ; 030A62 3A 8F C0
    call $8c79                   ; 030A65 CD 79 8C
    ld hl,$c08e                  ; 030A68 21 8E C0
    res 2,(hl)                   ; 030A6B CB 96
    
+:  ld hl,$c18e                  ; 030A6D 21 8E C1
    res 2,(hl)                   ; 030A70 CB 96
    ld hl,$c1ce                  ; 030A72 21 CE C1
    res 2,(hl)                   ; 030A75 CB 96
    ld hl,$c0ce                  ; 030A77 21 CE C0
    res 2,(hl)                   ; 030A7A CB 96
    ld a,($c0ae)                 ; 030A7C 3A AE C0
    and $80                      ; 030A7F E6 80
    jr z,+                       ; 030A81 28 12
    ld hl,$c0bc                  ; 030A83 21 BC C0
    ld a,(hl)                    ; 030A86 7E
    inc hl                       ; 030A87 23
    ld h,(hl)                    ; 030A88 66
    ld l,a                       ; 030A89 6F
    ld a,($c0af)                 ; 030A8A 3A AF C0
    call $8c79                   ; 030A8D CD 79 8C
    ld hl,$c0ae                  ; 030A90 21 AE C0
    res 2,(hl)                   ; 030A93 CB 96
+:  ld hl,$c1ae                  ; 030A95 21 AE C1
    res 2,(hl)                   ; 030A98 CB 96
    pop hl                       ; 030A9A E1
    pop hl                       ; 030A9B E1
    ret                          ; 030A9C C9
    ex af,af'                    ; 030A9D 08
    ld a,(ix+$01)                ; 030A9E DD 7E 01
    push af                      ; 030AA1 F5
    add a,$10                    ; 030AA2 C6 10
    out ($f0),a                  ; 030AA4 D3 F0
    call $8b34                   ; 030AA6 CD 34 8B
    xor a                        ; 030AA9 AF
    out ($f1),a                  ; 030AAA D3 F1
    pop af                       ; 030AAC F1
    cp $15                       ; 030AAD FE 15
    jr z,+                       ; 030AAF 28 15
    call $8b34                   ; 030AB1 CD 34 8B
    ld hl,$c08e                  ; 030AB4 21 8E C0
    res 2,(hl)                   ; 030AB7 CB 96
    ld a,$34                     ; 030AB9 3E 34
    out ($f0),a                  ; 030ABB D3 F0
    ld hl,$c095                  ; 030ABD 21 95 C0
    call $8ae2                   ; 030AC0 CD E2 8A
    jp $8a9a                     ; 030AC3 C3 9A 8A
+:  ld hl,$c0ae                  ; 030AC6 21 AE C0
    res 2,(hl)                   ; 030AC9 CB 96
    ld a,($c12e)                 ; 030ACB 3A 2E C1
    or a                         ; 030ACE B7
    ld hl,$c0b5                  ; 030ACF 21 B5 C0
    jp p,$8ad8                   ; 030AD2 F2 D8 8A
    ld hl,$c135                  ; 030AD5 21 35 C1
    ld a,$35                     ; 030AD8 3E 35
    out ($f0),a                  ; 030ADA D3 F0
    call $8ae2                   ; 030ADC CD E2 8A
    jp $8a9a                     ; 030ADF C3 9A 8A
    ld a,(hl)                    ; 030AE2 7E
    and $f0                      ; 030AE3 E6 F0
    ld c,a                       ; 030AE5 4F
    inc hl                       ; 030AE6 23
    ld a,(hl)                    ; 030AE7 7E
    and $0f                      ; 030AE8 E6 0F
    or c                         ; 030AEA B1
    out ($f1),a                  ; 030AEB D3 F1
    ret                          ; 030AED C9
    ld a,(de)                    ; 030AEE 1A
    ld c,a                       ; 030AEF 4F
    inc de                       ; 030AF0 13
    ld a,(de)                    ; 030AF1 1A
    ld b,a                       ; 030AF2 47
    push bc                      ; 030AF3 C5
    push ix                      ; 030AF4 DD E5
    pop hl                       ; 030AF6 E1
    dec (ix+$09)                 ; 030AF7 DD 35 09
    ld c,(ix+$09)                ; 030AFA DD 4E 09
    dec (ix+$09)                 ; 030AFD DD 35 09
    ld b,$00                     ; 030B00 06 00
    add hl,bc                    ; 030B02 09
    ld (hl),d                    ; 030B03 72
    dec hl                       ; 030B04 2B
    ld (hl),e                    ; 030B05 73
    pop de                       ; 030B06 D1
    dec de                       ; 030B07 1B
    ret                          ; 030B08 C9
    push ix                      ; 030B09 DD E5
    pop hl                       ; 030B0B E1
    ld c,(ix+$09)                ; 030B0C DD 4E 09
    ld b,$00                     ; 030B0F 06 00
    add hl,bc                    ; 030B11 09
    ld e,(hl)                    ; 030B12 5E
    inc hl                       ; 030B13 23
    ld d,(hl)                    ; 030B14 56
    inc (ix+$09)                 ; 030B15 DD 34 09
    inc (ix+$09)                 ; 030B18 DD 34 09
    ret                          ; 030B1B C9
    ld a,(de)                    ; 030B1C 1A
    inc de                       ; 030B1D 13
    add a,$18                    ; 030B1E C6 18
    ld c,a                       ; 030B20 4F
    ld b,$00                     ; 030B21 06 00
    push ix                      ; 030B23 DD E5
    pop hl                       ; 030B25 E1
    add hl,bc                    ; 030B26 09
    ld a,(hl)                    ; 030B27 7E
    or a                         ; 030B28 B7
    jr nz,+                      ; 030B29 20 02
    ld a,(de)                    ; 030B2B 1A
    ld (hl),a                    ; 030B2C 77
+:  inc de                       ; 030B2D 13
    dec (hl)                     ; 030B2E 35
    jp nz,$89c6                  ; 030B2F C2 C6 89
    inc de                       ; 030B32 13
    ret                          ; 030B33 C9
.ends

.org $30b34-$30000
.section "FM delay function" overwrite
SoundFMDelay:                    ; Delay for use between YM2413 writes
    push hl
    pop hl
    ret
.ends
.org $30b37-$30000
.section "and more sound code" overwrite
    inc (ix+$0b)                 ; 030B37 DD 34 0B
    ld a,(ix+$0a)                ; 030B3A DD 7E 0A
    sub (ix+$0b)                 ; 030B3D DD 96 0B
    call z,$8b60                 ; 030B40 CC 60 8B
    bit 2,(ix+$00)               ; 030B43 DD CB 00 56
    ret nz                       ; 030B47 C0
    bit 4,(ix+$13)               ; 030B48 DD CB 13 66
    ret nz                       ; 030B4C C0
    ld a,(ix+$07)                ; 030B4D DD 7E 07
    dec a                        ; 030B50 3D
    ret m                        ; 030B51 F8
    ld hl,$b766                  ; 030B52 21 66 B7
    call $876b                   ; 030B55 CD 6B 87
    call $8c8e                   ; 030B58 CD 8E 8C
    or $f0                       ; 030B5B F6 F0
    out ($7f),a                  ; 030B5D D3 7F
    ret                          ; 030B5F C9
    ld e,(ix+$03)                ; 030B60 DD 5E 03
    ld d,(ix+$04)                ; 030B63 DD 56 04
    ld a,(de)                    ; 030B66 1A
    inc de                       ; 030B67 13
    cp $e0                       ; 030B68 FE E0
    jp nc,$8b8a                  ; 030B6A D2 8A 8B
    cp $80                       ; 030B6D FE 80
    jp c,$880b                   ; 030B6F DA 0B 88
    call $8b94                   ; 030B72 CD 94 8B
    ld a,(de)                    ; 030B75 1A
    inc de                       ; 030B76 13
    cp $80                       ; 030B77 FE 80
    jp c,$880b                   ; 030B79 DA 0B 88
    dec de                       ; 030B7C 1B
    ld a,(ix+$15)                ; 030B7D DD 7E 15
    ld (ix+$0a),a                ; 030B80 DD 77 0A
    jp $881b                     ; 030B83 C3 1B 88
    dec de                       ; 030B86 1B
    jp $881b                     ; 030B87 C3 1B 88
    ld hl,$8b90                  ; 030B8A 21 90 8B
    jp $88ae                     ; 030B8D C3 AE 88
    inc de                       ; 030B90 13
    jp $8b66                     ; 030B91 C3 66 8B
    bit 3,a                      ; 030B94 CB 5F
    jr nz,+                      ; 030B96 20 19
    bit 5,a                      ; 030B98 CB 6F
    jr nz,++                     ; 030B9A 20 1C
    bit 1,a                      ; 030B9C CB 4F
    jr nz,++                     ; 030B9E 20 18
    bit 0,a                      ; 030BA0 CB 47
    jr nz,+++                    ; 030BA2 20 22
    bit 2,a                      ; 030BA4 CB 57
    jr nz,+++                    ; 030BA6 20 1E
    ld (ix+$07),$00              ; 030BA8 DD 36 07 00
    ld a,$ff                     ; 030BAC 3E FF
    out ($7f),a                  ; 030BAE D3 7F
    ret                          ; 030BB0 C9

+:  ex af,af'                    ; 030BB1 08
    ld a,$02                     ; 030BB2 3E 02
    ld b,$04                     ; 030BB4 06 04
    jr +                         ; 030BB6 18 13

++: ld c,$04                     ; 030BB8 0E 04
    bit 0,a                      ; 030BBA CB 47
    jr nz,++                     ; 030BBC 20 02
    ld c,$03                     ; 030BBE 0E 03
++: ex af,af'                    ; 030BC0 08
    ld a,c                       ; 030BC1 79
    ld b,$05                     ; 030BC2 06 05
    jr +                         ; 030BC4 18 05

+++:ex af,af'                    ; 030BC6 08
    ld a,$01                     ; 030BC7 3E 01
    ld b,$06                     ; 030BC9 06 06
+:  ld (ix+$07),a                ; 030BCB DD 77 07
    ex af,af'                    ; 030BCE 08
    bit 2,a                      ; 030BCF CB 57
    jr z,+                       ; 030BD1 28 02
    dec b                        ; 030BD3 05
    dec b                        ; 030BD4 05
+:  ld (ix+$08),b                ; 030BD5 DD 70 08
    ret                          ; 030BD8 C9

_8bd9: ; $30bd9, $8bd9
    inc (ix+$0b)                 ; 030BD9 DD 34 0B
    ld a,(ix+$0a)                ; 030BDC DD 7E 0A
    sub (ix+$0b)                 ; 030BDF DD 96 0B
    call z,$87b9                 ; 030BE2 CC B9 87
    ld ($c00c),a                 ; 030BE5 32 0C C0
    cp $80                       ; 030BE8 FE 80
    jp z,$8c14                   ; 030BEA CA 14 8C
    bit 5,(ix+$00)               ; 030BED DD CB 00 6E
    jp z,$8c14                   ; 030BF1 CA 14 8C
    exx                          ; 030BF4 D9
    ld (hl),$80                  ; 030BF5 36 80
    exx                          ; 030BF7 D9
    ld a,(ix+$12)                ; 030BF8 DD 7E 12
    bit 7,a                      ; 030BFB CB 7F
    jr z,+                       ; 030BFD 28 0A
    add a,(ix+$0e)               ; 030BFF DD 86 0E
    jr c,++                      ; 030C02 38 0D
    dec (ix+$0f)                 ; 030C04 DD 35 0F
    jr ++                        ; 030C07 18 08
+:  add a,(ix+$0e)               ; 030C09 DD 86 0E
    jr nc,++                     ; 030C0C 30 03
    inc (ix+$0f)                 ; 030C0E DD 34 0F
++: ld (ix+$0e),a                ; 030C11 DD 77 0E
    bit 2,(ix+$00)               ; 030C14 DD CB 00 56
    ret nz                       ; 030C18 C0
    ld a,(ix+$13)                ; 030C19 DD 7E 13
    cp $1f                       ; 030C1C FE 1F
    ret z                        ; 030C1E C8
    jr nz,+                      ; 030C1F 20 00       ; does nothing
+:  ld a,(ix+$13)                ; 030C21 DD 7E 13
    cp $ff                       ; 030C24 FE FF
    jp z,$8c40                   ; 030C26 CA 40 8C
    ld a,(ix+$07)                ; 030C29 DD 7E 07
    dec a                        ; 030C2C 3D
    jp m,$8c40                   ; 030C2D FA 40 8C
    ld hl,$b766                  ; 030C30 21 66 B7
    call $876b                   ; 030C33 CD 6B 87
    call $8c8e                   ; 030C36 CD 8E 8C
    or (ix+$01)                  ; 030C39 DD B6 01
    add a,$10                    ; 030C3C C6 10
    out ($7f),a                  ; 030C3E D3 7F
    ld a,($c00c)                 ; 030C40 3A 0C C0
    or a                         ; 030C43 B7
    jp m,$8c54                   ; 030C44 FA 54 8C
    bit 7,(ix+$14)               ; 030C47 DD CB 14 7E
    ret nz                       ; 030C4B C0
    ld a,(ix+$06)                ; 030C4C DD 7E 06
    dec a                        ; 030C4F 3D
    jp p,$8c58                   ; 030C50 F2 58 8C
    ret                          ; 030C53 C9
    ld a,(ix+$06)                ; 030C54 DD 7E 06
    dec a                        ; 030C57 3D
    ld l,(ix+$0e)                ; 030C58 DD 6E 0E
    ld h,(ix+$0f)                ; 030C5B DD 66 0F
    jp m,$8c6b                   ; 030C5E FA 6B 8C
    ex de,hl                     ; 030C61 EB
    ld hl,$b805                  ; 030C62 21 05 B8
    call $876b                   ; 030C65 CD 6B 87
    call $8778                   ; 030C68 CD 78 87
    bit 6,(ix+$00)               ; 030C6B DD CB 00 76
    ret nz                       ; 030C6F C0
    ld a,(ix+$01)                ; 030C70 DD 7E 01
    cp $e0                       ; 030C73 FE E0
    jr nz,+                      ; 030C75 20 02
    ld a,$c0                     ; 030C77 3E C0
+:  ld c,a                       ; 030C79 4F
    ld a,l                       ; 030C7A 7D
    and $0f                      ; 030C7B E6 0F
    or c                         ; 030C7D B1
    out ($7f),a                  ; 030C7E D3 7F
    ld a,l                       ; 030C80 7D
    and $f0                      ; 030C81 E6 F0
    or h                         ; 030C83 B4
    rrca                         ; 030C84 0F
    rrca                         ; 030C85 0F
    rrca                         ; 030C86 0F
    rrca                         ; 030C87 0F
    out ($7f),a                  ; 030C88 D3 7F
    ret                          ; 030C8A C9

-:  ld (ix+$0c),a                ; 030C8B DD 77 0C
    push hl                      ; 030C8E E5
    ld c,(ix+$0c)                ; 030C8F DD 4E 0C
    ld b,$00                     ; 030C92 06 00
    add hl,bc                    ; 030C94 09
    ld c,l                       ; 030C95 4D
    ld b,h                       ; 030C96 44
    pop hl                       ; 030C97 E1
    ld a,(bc)                    ; 030C98 0A
    bit 7,a                      ; 030C99 CB 7F
    jr z,+                       ; 030C9B 28 25
    cp $82                       ; 030C9D FE 82
    jr z,++                      ; 030C9F 28 0C
    cp $81                       ; 030CA1 FE 81
    jr z,+++                     ; 030CA3 28 17
    cp $80                       ; 030CA5 FE 80
    jr z,++++                    ; 030CA7 28 10
    inc bc                       ; 030CA9 03
    ld a,(bc)                    ; 030CAA 0A
    jr -                         ; 030CAB 18 DE

++: pop hl                       ; 030CAD E1
    ld a,$1f                     ; 030CAE 3E 1F
    ld (ix+$13),a                ; 030CB0 DD 77 13
    add a,(ix+$01)               ; 030CB3 DD 86 01
    out ($7f),a                  ; 030CB6 D3 7F
    ret                          ; 030CB8 C9

++++:
    xor a                        ; 030CB9 AF
    jr -                         ; 030CBA 18 CF

+++:ld (ix+$13),$ff              ; 030CBC DD 36 13 FF
    pop hl                       ; 030CC0 E1
    ret                          ; 030CC1 C9

+:  inc (ix+$0c)                 ; 030CC2 DD 34 0C
    add a,(ix+$08)               ; 030CC5 DD 86 08
    bit 4,a                      ; 030CC8 CB 67
    ret z                        ; 030CCA C8
    ld a,$0f                     ; 030CCB 3E 0F
    ret                          ; 030CCD C9
    ld a,(ix+$08)                ; 030CCE DD 7E 08
    and $0f                      ; 030CD1 E6 0F
    or (ix+$01)                  ; 030CD3 DD B6 01
    add a,$10                    ; 030CD6 C6 10
    out ($7f),a                  ; 030CD8 D3 7F
    ret                          ; 030CDA C9
.ends
.org $30cdb-$30000

;;;; music data?

;=======================================================================================================
; Bank 13: $34000 - $37fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 13 slot 2

.orga $8000
.section "WorldData1" overwrite
WorldData1:
.dw $80a2,$80e8,$8118,$8141,$818d,$81dc,$824a,$82d6
.dw $80a2,$8371,$8404,$84a6,$8548,$85da,$8672,$8718
.dw $87d5,$8371,$8887,$8906,$89b2,$8a43,$8aee,$8ba8
.dw $8c2c,$8cda,$8887,$8d57,$8dbd,$8e69,$8f02,$8fb5
.dw $9049,$90ea,$917b,$8d57,$91c8,$91ff,$9299,$9302
.dw $93bd,$9453,$94d6,$9595,$91c8,$963c,$968d,$9731
.dw $97df,$9895,$9934,$99e1,$9a80,$963c,$9add,$9b1d
.dw $9bd1,$9c93,$9d4f,$9e11,$9ec5,$9f0c,$9add,$9f6c
.dw $9fb2,$a03d,$a0cb,$a15a,$a1aa,$a204,$a23d,$9f6c
.dw $80a2,$80e8,$8118,$8141,$818d,$81dc,$824a,$82d6
.dw $80a2
; All of this data is wrong! It's not 2-byte interleaved, it's 1, so there should be twice as many.
.incbin "Tilemaps\340A2tilemap.dat"
.incbin "Tilemaps\34118tilemap.dat"
.incbin "Tilemaps\3418Dtilemap.dat"
.incbin "Tilemaps\3424Atilemap.dat"
.incbin "Tilemaps\34371tilemap.dat"
.incbin "Tilemaps\344A6tilemap.dat"
.incbin "Tilemaps\345DAtilemap.dat"
.incbin "Tilemaps\34718tilemap.dat"
.incbin "Tilemaps\34887tilemap.dat"
.incbin "Tilemaps\349B2tilemap.dat"
.incbin "Tilemaps\34AEEtilemap.dat"
.incbin "Tilemaps\34C2Ctilemap.dat"
.incbin "Tilemaps\34D57tilemap.dat"
.incbin "Tilemaps\34E69tilemap.dat"
.incbin "Tilemaps\34FB5tilemap.dat"
.incbin "Tilemaps\350EAtilemap.dat"
.incbin "Tilemaps\351C8tilemap.dat"
.incbin "Tilemaps\35299tilemap.dat"
.incbin "Tilemaps\353BDtilemap.dat"
.incbin "Tilemaps\354D6tilemap.dat"
.incbin "Tilemaps\3563Ctilemap.dat"
.incbin "Tilemaps\35731tilemap.dat"
.incbin "Tilemaps\35895tilemap.dat"
.incbin "Tilemaps\359e1tilemap.dat"
.incbin "Tilemaps\35ADDtilemap.dat"
.incbin "Tilemaps\35BD1tilemap.dat"
.incbin "Tilemaps\35D4Ftilemap.dat"
.incbin "Tilemaps\35ec5tilemap.dat"
.incbin "Tilemaps\35F6Ctilemap.dat"
.incbin "Tilemaps\3603Dtilemap.dat"
.incbin "Tilemaps\3615Atilemap.dat"
.incbin "Tilemaps\36204tilemap.dat"
.ends
; followed by
.org $36276-$34000
.section "WorldData2" overwrite
; Another table referring to compressed data after it
WorldData2:
.dw $a318 $a32f $a357 $a3b4 $a46e $a523 $a5b1 $a619
.dw $a318 $a66b $a682 $a6b8 $a745 $a7f9 $a8a5 $a958
.dw $aa01 $a66b $aac2 $ab1b $ab6b $abbc $ac51 $ac9d
.dw $acff $ad8c $aac2 $ae4d $ae6a $aebe $af33 $af52
.dw $af75 $affc $b05b $ae4d $b108 $b138 $b1a0 $b222
.dw $b2d7 $b34f $b409 $b4b1 $b108 $b570 $b5b7 $b623
.dw $b6c8 $b781 $b7e1 $b7fc $b82a $b570 $b86d $b8a3
.dw $b8f5 $b9a1 $ba43 $babf $baf6 $bb22 $b86d $bb4d
.dw $bb7c $bba7 $bc08 $bc80 $bcd0 $bd3a $bd78 $bb4d
.dw $a318 $a32f $a357 $a3b4 $a46e $a523 $a5b1 $a619
.dw $a318
; All of this data is wrong! It's not 2-byte interleaved, it's 1, so there should be twice as many.
_d01:.incbin "Tilemaps\36318tilemap.dat"
_d02:.incbin "Tilemaps\36357tilemap.dat"
_d03:.incbin "Tilemaps\3646Etilemap.dat"
_d04:.incbin "Tilemaps\365B1tilemap.dat"
_d05:.incbin "Tilemaps\3666Btilemap.dat"
_d06:.incbin "Tilemaps\366B8tilemap.dat"
_d07:.incbin "Tilemaps\367F9tilemap.dat"
_d08:.incbin "Tilemaps\36958tilemap.dat"
_d09:.incbin "Tilemaps\36AC2tilemap.dat"
_d10:.incbin "Tilemaps\36B6Btilemap.dat"
_d11:.incbin "Tilemaps\36C51tilemap.dat"
_d12:.incbin "Tilemaps\36CFFtilemap.dat"
_d13:.incbin "Tilemaps\36E4Dtilemap.dat"
_d14:.incbin "Tilemaps\36EBEtilemap.dat"
_d15:.incbin "Tilemaps\36F52tilemap.dat"
_d16:.incbin "Tilemaps\36FFCtilemap.dat"
_d17:.incbin "Tilemaps\37108tilemap.dat"
_d18:.incbin "Tilemaps\371A0tilemap.dat"
_d19:.incbin "Tilemaps\372D7tilemap.dat"
_d20:.incbin "Tilemaps\37409tilemap.dat"
_d21:.incbin "Tilemaps\37570tilemap.dat"
_d22:.incbin "Tilemaps\37623tilemap.dat"
_d23:.incbin "Tilemaps\37781tilemap.dat"
_d24:.incbin "Tilemaps\377FCtilemap.dat"
_d25:.incbin "Tilemaps\3786Dtilemap.dat"
_d26:.incbin "Tilemaps\378F5tilemap.dat"
_d27:.incbin "Tilemaps\37A43tilemap.dat"
_d28:.incbin "Tilemaps\37AF6tilemap.dat"
_d29:.incbin "Tilemaps\37B4Dtilemap.dat"
_d30:.incbin "Tilemaps\37BA7tilemap.dat"
_d31:.incbin "Tilemaps\37C80tilemap.dat"
_d32:.incbin "Tilemaps\37D3Atilemap.dat"
; 768 tiles
TilemapDarkForce:
.incbin "Tilemaps\37DB1tilemap.dat" ; Dark Force
.ends
;.org 37fda
; Blank until end of bank

;=======================================================================================================
; Bank 14: $38000 - $3bfff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 14 slot 2
.orga $8000
.section "WorldData3" overwrite
WorldData3:
.dw $80a2 $80cd $8176 $8239 $82f7 $83ba $8431 $84f0
.dw $80a2 $8521 $85aa $8618 $8680 $86b7 $8715 $87b4
.dw $8819 $8521 $88bd $896b $89d7 $8a35 $8a62 $8ade
.dw $8b45 $8bf2 $88bd $8c77 $8d2c $8ddd $8e6a $8f2d
.dw $8fd1 $907d $90de $8c77 $9123 $91b2 $9216 $92bc
.dw $936b $942e $9487 $948c $9123 $94a1 $9533 $95ea
.dw $9679 $973e $9801 $98ab $98b2 $94a1 $992b $99e8
.dw $9a98 $9b2f $9beb $9cae $9d71 $9e29 $992b $9ee3
.dw $9f2d $9fe6 $a09d $a161 $a21e $a2e1 $a3a3 $9ee3
.dw $80a2 $80cd $8176 $8239 $82f7 $83ba $8431 $84f0
.dw $80a2
.incbin "Tilemaps\380a2tilemap.dat"
.incbin "Tilemaps\38176tilemap.dat"
.incbin "Tilemaps\382F7tilemap.dat"
.incbin "Tilemaps\38431tilemap.dat"
.incbin "Tilemaps\38521tilemap.dat"
.incbin "Tilemaps\38618tilemap.dat"
.incbin "Tilemaps\386B7tilemap.dat"
.incbin "Tilemaps\387B4tilemap.dat"
.incbin "Tilemaps\388BDtilemap.dat"
.incbin "Tilemaps\389D7tilemap.dat"
.incbin "Tilemaps\38A62tilemap.dat"
.incbin "Tilemaps\38B45tilemap.dat"
.incbin "Tilemaps\38C77tilemap.dat"
.incbin "Tilemaps\38DDDtilemap.dat"
.incbin "Tilemaps\38F2Dtilemap.dat"
.incbin "Tilemaps\3907Dtilemap.dat"
.incbin "Tilemaps\39123tilemap.dat"
.incbin "Tilemaps\39216tilemap.dat"
.incbin "Tilemaps\3936Btilemap.dat"
.incbin "Tilemaps\39487tilemap.dat"
.incbin "Tilemaps\394A1tilemap.dat"
.incbin "Tilemaps\395EAtilemap.dat"
.incbin "Tilemaps\3973Etilemap.dat"
.incbin "Tilemaps\398ABtilemap.dat"
.incbin "Tilemaps\3992Btilemap.dat"
.incbin "Tilemaps\39A98tilemap.dat"
.incbin "Tilemaps\39BEBtilemap.dat"
.incbin "Tilemaps\39D71tilemap.dat"
.incbin "Tilemaps\39EE3tilemap.dat"
.incbin "Tilemaps\39FE6tilemap.dat"
.incbin "Tilemaps\3A161tilemap.dat"
.incbin "Tilemaps\3A2E1tilemap.dat"
.ends
; followed by
.orga $a3e8
.section "Outside area tile animations" overwrite
TilesOutsideAnimation:
TilesOutsideSeaShore:  ; $3a3e8
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

; space

.org $3fdee-$3c000
.section "Tile data 6" overwrite
.incbin "Tiles\3fdeecompr.dat" ; curly font (for credits)
.ends
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
; Bank 18: $48000 - $4bfff   =========================== Fully accounted for ===========================
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
NarrativeGraphicsNoah:
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
PaletteDarkForce:
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
.section "Tile data 12" overwrite
.db $12,$06,$1A,$01,$25,$2F,$2A,$02 ; ???
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
.ends
;.org 53dbc

; (credits)

;.org 53f9a
; Blank to end of slot

;=======================================================================================================
; Bank 21: $54000 - $57fff   =========================== Fully accounted for ===========================
;=======================================================================================================
.bank 21 slot 2
.org $54000-$54000
.section "Enemy sprite data offset table" overwrite
EnemySpriteDataTable:
.include "Other data\Sprite data 2.inc"
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

; space

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
PaletteSpaceEnd:       ; must be followed by 
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

.org $62484-$60000
.section "Picture frame data" overwrite
TilemapFrame:
.incbin "Tilemaps\62484tilemap.dat" ; must be in same frame as palette and tiles
PaletteFrame:
.db $00,$00,$3F,$0F,$0B,$06,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
TilesFrame:
.incbin "Tiles\6258acompr.dat" ; 4
.ends
.org $625e0-$60000

; space

.orga $a782 ; $62782
.section "Mark III logo data" overwrite
MarkIIILogoTilemap:    ; $62782
  .include "Tilemaps\62782 Mark III logo low.inc"
MarkIIILogoTilemapEnd:
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

; space

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
NoahSprites:
.include "Tiles\70a80 Noah sprites.inc"
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

; space

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
.db $30,$00,$3F,$38,$3E,$27,$01,$0F,$2B,$0B,$06,$2A,$25,$2F,$3B,$3C ; palette
.db $30 ; ???
.incbin "Tiles\7d687compr.dat" ; 159 ending picture
TilesTitleScreen:      ; $7e8bd
.incbin "Tiles\7E8BDcompr Title screen tiles.dat" ; 256 title
.ends
; to end :)
