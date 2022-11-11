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
; $8217                       +-----------------+
;                             (Space here for new options)
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
  .define \1_VRAM TileMapWriteAddress(x, y)
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

  DefineWindow INVENTORY        max(ENEMY_STATS_end, PLAYER_SELECT_end)       InventoryMenuDimensions_width InventoryMenuDimensions_height  31-InventoryMenuDimensions_width      1
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
  DefineWindow ContinueWindow   $d700                 ContinueMenu_width            ContinueMenu_height             18                                    15

; The game puts the stack in a space from $cba0..$caff. The RAM window cache
; therefore can extend as far as $dffb (inclusive) - $dffc+ are used
; to "mirror" paging register writes. (The original game stops at $de65 inclusive.)
; However the game uses two lone bytes at $df00 (Port $3E value, typically 0)
; and $df01 (set to $ff, never read). We therefore need to move the former
; (and ignore the latter) to free up some space.
  ; See Initialisation later for the first bit
  PatchW $03a5 Port3EValue
  PatchW $03cc Port3EValue
  PatchW $00a6 Port3EValue

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

