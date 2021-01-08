# Phantasy Star English Retranslation v2.01

Phantasy Star is a landmark game for the Sega Master System, first released in Japan on 20th December 1987. 
This project is an unofficial retranslation/relocalisation based on that first Japanese version, with some enhancements.

For more information and screenshots see https://www.smspower.org/Translations/PhantasyStar-SMS-EN

Changelog (in reverse chronological order):
- v2.02 released 2021/??/??
  - added French translation from ichigobankai, Wil76 and Vingazole
- v2.01 released 2020/12/20
  - script improvements:
    - some after-the-deadline changes from Frank Cifaldi
    - tyop correctoins
    - further naming inconsistencies cleared up for all names/locations
  - bugs fixed:
    - occasional temporary glitch in enemy name box on real hardware (#49)
    - script error when you don't have money for shortcake (#47)
    - Myau attack stat at level 30 is corrected - this is a bug in the Japanese version of the game, fixed in the official English translation (#48)
  - added "original names" version with mostly original names for some characters, spells and items
- v2.00 released 2020/05/25
  - script improvements:
    - script updates from Frank Cifaldi
    - fixed naming inconsistencies in the script, e.g. Dezoris/Dezolis, Roadpass/roadpass/road pass
  - bugs fixed:
    - fixed issue with 10-letter item names in inventory (#2)
    - fixed bug with pluralisation (#5)
    - fixed missing script in Aerocastle Gardens (#3)
    - fixed screen corruption when closing menus (#1)
  - interface improvements:
    - support long enemy names (#9)
    - menus converted to single-spacing, and widened to fit all item names
    - save game names widened (#15)
    - additional save slots enabled (using existing 8KB save RAM) (#16)
    - changed game save handling to menus from title screen (#20)
    - added music test (#18)
    - doubled walking and vehicle speed (#8)
    - added options menu for walking speed, experience and money multipliers (#19)
    - added option to change Alisa's sprite hair colour (#38)
  - technical improvements:
    - rebuilt tools and assembly process, including some C++ modernisation and x64 support
    - optimised space usage to make it easier for further translations (or script improvements) to fit without expanding the ROM
  - new font by [DamienG](https://damieng.com/typography/zx-origins/polaris)
- v1.02 released 2008/01/31
  - fixed lockup when you visit Tajim
- v1.01 released 2007/12/22
  - checksum fixed for play on a real system
  - fixed a bug with the Pause button mod
- v1.00 released 2007/12/20
  - minor script bugfixes
  - spell menu expansion
  - minor bugfix for sound chip selector
- v0.91 released 2006/12/22
  - minor script clean-ups
  - checksum fixed
- v0.90 released 2006/12/20
  - first release

The script was originally based on the Phantasy Star Original Dialogue Version Japanese to English Retranslation by Paul Jensen.

## What is Phantasy Star

Phantasy Star is a ground-breaking RPG from 1987. It was the first console RPG released in the US; it was one of the first sci-fi-based RPGs, although has a unique mix of fantasy and sci-fi; and it introduced many concepts to the genre.

It was ground-breakingly large - taking place across three planets, with large, colourful, animated monsters. It was one of the first (and only) games to feature a female protagonist with real characterisation and character development, without resorting to videogaming's female stereotypes.

If you want to learn more about the game, check out some of the web links below.

## Contents

The following changes are made to the game engine:

- Narrative formatting
- Window expansion
- Replaced 8x8 font
- Use of adapting indefinite articles
- Reworked name entry screen
- FM/PSG switching
- Extended save slots names, count and interface
- "Quality of life" improvements to reduce grinding

## Instructions

This patch requires that you download a program that can apply it to a properly dumped ROM-image of the game. "Floating IPS" is recommended for Windows.

The original, unmodified game has the following characteristics:

Size:  512KB (524,288 bytes)

CRC32: `6605D36A`

MD5:   `DFEBC48DFE8165202B7F002D8BAC477B`

There is only one known Japanese version of the game. The patch will NOT work with the US/European versions, or any other game on any platform. If you use the BPS patch it will verify that you are using the correct file.

A copier is suggested to obtain your legal backup. Always make sure to have an original backup of your game. And only apply the patch to a clean, unmodified ROM image.

Changes made between version numbers may adversely affect emulator save states. In such event, please use the in-game save feature to gain any new features.

## Credits

### Z80 Gaiden
- Core hacking and programming
### Maxim
- Project manager, final hacking/programming
### Paul Jensen
- Script translator, editor
### satsu
- Additional translations
### Frank Cifaldi (TheRedEye)
- Localization and script enhancements
## Damien Guard
- Polaris font, see also https://damieng.com/typography/zx-origins/

Special thanks to:

### Sega Japan
- Original publisher, developer, creative content
- Phantasy Star Gaiden, Phantasy Star 1-4
### Team Sonic
- Shining Force Gaiden: Final Conflict (scripting engine is based on code from this game)

### Bock (Omar Cornut)
- Meka is an excellent debugging emulator (used extensively for the hacking work): https://www.smspower.org/meka/
### Ville Helin
- WLA DX is an excellent assembler and enables a lot of the adaptations for the translation. I hope to see more translation patches with published source using it.

Also thanks to the following for various contributions to item naming, etc.
- DJ Squarewave
- TheGZeus
- idrougge
- Namida
- LEADKUN
- Mia
- vivify93
- MandrasX
- Joe Redifer

## Authors' notes

### Z80 Gaiden (2004)

Paul Jensen had posted a translated script with a good majority of the lists in 2001-2002. I wasn't aware of its existence until someone mentioned a retranslation project that didn't make fully it to completion yet.

The game proved to be an interesting task - lack of useful padding space. Narrative and items fitting into a mere 15.67 KB. Need patience with this one.

So this project was designed to keep the FM music intact while squeezing in more full item descriptions and textual script content.

Not enough thanks can be directed to Mr. Jensen for his care in posting his retranslation publicly online and keeping it freely accessible for all this time.

This author releases copyright ownership in the patch and produces it under the banner of the original team of Maxim and Paul Jensen: SMS Power!.

### Maxim (2006)

This has been a long time coming. When I received the near-complete translation from Z80 Gaiden (who goes by several names and has done amazing work on translations before) I was amazed - it was 90% done. Unfortunately, as the aphorism says,

"The first 90% of the code accounts for the first 90% of the development time. The remaining 10% of the code accounts for the other 90% of the development time."

Over the last 2 years or so I have worked on it on and off, and while I'm fairly confident that I've fixed most of the bugs, it's sadly not been tested as much as I'd like; so I'm committed to keep working on it.

I hope you all enjoy TheRedEye's script changes. We've approached this project with the aim of bringing you the experience of the original Japanese version, but there have been a few minor changes to bring the script alive, rather than do it word-for-word. We'd like to think this is what the original translation should have been, 18 years ago.

It's also a great framework for further (re-)translation into more languages. Please get in touch if you can do some serious work on that. You will need to provide a translator *and* a Z80 coder.

### Maxim (2020)

When I first worked on this, I was quite a lot less experienced. I had not learned much C and thus was using the programs from Z80 Gaiden blindly, and this made it difficult to understand what was going on. However, I've always been the sort of person who needs to understand how things work (that's how I got into Master System development in the first place), and I eventually decided to come back to this project and make a few pointless technical changes - rewriting the support programs in slightly more modern C++, with comments so I can understand them. Along the way I was able to throw away some very verbose code and replace it with much more elegant equivalents thanks to language advances. I realised a lot of the things done in code were possible to do in WLA DX, and often more easily - e.g. inserting new code as assembly instead of hex, mapping text to the game's character codes, and applying patches using labels. This also enabled more use of comments. Furthermore, the original was using the venerable tasm assembler - which is not easy to run on modern 64-bit Windows.

As is often the case, I then got a bit hooked. I strove to remove as much of the original C code as possible - all that's really left is the bitmap decoder and script encoder. Up to this point I was always producing a bit-identical output to the 1.02 release. Then I started to move to mapping out the chunks of code and data which had been replaced, marking them as free space and then letting WLA DX deal with placing the patches and enhancements in the available space. Doing this allowed me to gain confidence in the availability of "free space" for further enhancements. This allowed me to start making some of the improvements (and bug fixes) I'd been thinking of for the last decade or so. (When I said "I'm committed to keep working on it", I didn't give any promises as to *when*...)

A big thing I wanted to do was deal with the wrapping in menus. The original used two-line menus mainly due to a common hack for katakana-based games - so it can save tiles by putting the diacritics on the row above. The characters "ヒビピ" are somewhat analagous to characters like "eèéêë" in European languages. Placing the modifiers on the row above reduces the number of tiles needed, which is a big deal for Master System games' limited VRAM space. However to swap to single-line menus I'd also need to widen them to make room for the names (many of which were split over two lines in order to fit). This meant dealing with the game's "window RAM buffers", which was a complicated task. I needed to map out every "menu window" that the game ever opens, determine which could be open at the same time, and allocate them all space in memory such that we never use the same space for two things at the same time. This was quite difficult and has a correspondingly large comment in the source explaining it. However, the end result is not only the removal of all unnecessary wrapping, but also a more pleasant experience (I think) as there's less blank black on the screen.

Having sorted all that out, it also meant I could extend the title screen to use menus instead of a black background when leading and saving, and a sound test which is of course a great thing given the game's soundtrack.

As I posted updates online people asked for some "quality of life" improvements - inspired by some of the "official" changes made in the Switch port, to speed up walking, reduce random enemy battles and reduce the amount of grinding for money and experience. This was put inside another menu.

I also got a welcome message from Frank Cifaldi (TheRedEye, also the founder of the Video Game History Foundation) offering to do further script enhancements on top of his script from 2006. This could take advantage of the bigger text boxes to really expand the story. I think you'll find the enhancements really help the story.

I also reached out to DamienG and he came up with an awesome new font. Note that the "AW2284" font is a tweaked version of the font from Phantasy Star IV's English release, with the numbers from Phantasy Star III, as used in the earlier releases of this translation.

## Technical notes

The Git history contains many documents written by Z80 Gaiden during his hacking work.
These became less relevant later so they are no longer present.

The code is designed to build in a Visual Studio developer command prompt, with WLA DX
available. It uses Microsoft's NMAKE too for the makefile; it is unlikely to work with
GNU Make without modifications, but otherwise the build process is fairly simple.

There are several programs included, some of which are not part of the build process but are retained for historical purposes. The main ones are:

### word_count

This takes the script and generates a file listing the most commonly-used words, weighted by length, in descending order. It breaks words on apostrophes, so we can avoid counting "Alisa" and "Alisa's" separately.

### substring_formatter

This takes the word list and uses it to substitute the common words with a single byte. It generates a TBL file, and assembly code for the word list.

The optimal number of words to substitute this way for a given script is complicated, as substituting more words adds complexity to the next compression steps; but to maximise the script space overall, we should maximise the word count, which means selecting the 164 most common words. (This number could be increased a little, or reduced if we needed more characters.)

It then converts the whole script into encoded data (for the substituted words, the non-substituted letters and some control codes). Next it applies "adaptive Huffman compression" to each script entry - for every byte in the script, we have a Huffman tree for each subsequent byte. This means the individual trees can be quite small (so the encoded tree path is smaller), but there are up to 256 of them.

Finally, it emits the Huffman trees and encoded script data as assembly, and also emits patches for all the locations where the original game references a script entry. Note that the game originally had script entries referenced by index; we instead patch with direct pointers.

### menu_creater

The menus themselves are encoded as raw tilemap data. This program takes the UTF-8 text in menus.txt (all the menus/windows) and opening.txt (the one window used in the opening) and converts them to the tilemap data. Note that we use a "16-bit" TBL file for this part, with some extra characters used for the menu borders.

Changing the menu dimensions is far from trivial. In order to act like overlapping windows, the game caches the tilemap data from under each one as it is drawn, and then restores it. This is done using fixed RAM areas, rather than some kind of stack, and these areas need to overlap (due to RAM restrictions), so we need to ensure only windows which are never used at the same time overlap in memory.

### bitmap_decode

In order to free up space in the ROM, we re-encode some of the graphics (tile) data with a more efficient (but slower) compression method - namely, the algorithm used in Phantasy Star Gaiden. We first decode the data using bitmap_decode, which puts it into the raw VRAM tile format, and then re-encode it using BMP2Tile.

Note that the PS Gaiden compression yields smaller results than other algorithms like ZX7 and aPLib.

Note also that the original game has two versions of the tile decoder - one for use when VBlanks are disabled (i.e. when loading new scenes) and one for use "in-game" (e.g. for loading enemy tiles). We replace only the first one of these; this allows us to free up enough space while also reducing the number of places we need to re-encode the graphics.

### new_graphics

In a few places we insert new graphics - the title screen and fonts. We render these as PNG files and use BMP2Tile to convert to the necessary formats. We also have a duplicate tileset for Alisa with brown hair.

### ROM building

Finally we have the assembly file itself, `ps1jert.asm`. ("Phantasy Star 1 Japanese to English ReTranslation", later simplified to "psrp" (Phantasy Star Retranslation Project)). We use WLA DX as it offers several useful features that avoid us needing to write custom code:

- We "background" the original ROM, so that we can build a ROM image based on it
- We then "unbackground" various areas that are either replaced code/data, unused code/data (e.g. there are vestiges of a password system), or just unused areas of ROM.
- Next we can define some helper macros for various tasks:
  - `CopyFromOriginal` is useful for where we are moving a chunk of of data to a different location.
  - `ROMPosition` allows us to set the assembly position in ROM space, useful for patching specific addresses.
  - `PatchB` and `PatchW` allow us to patch bytes and words at specific addresses. This is used for many of the generated "patch" files.
  - `LoadPagedTiles` is used for a repeated pattern of mapping in some tile data and loading t to VRAM.
  - `String` is used to encode various bits of text in the game (especially the lists). We use WLA DX's `.asciitable` to help with the mapping to avoid needing another monstrous macro like `TextToTilemap`.
- We define some names for various RAM locations used by the game, as well as locations used by the new script engine code (which re-use areas used by the old engine).
- Next we start defining a mixture of new code and patches to the old code to call into the new code. We use WLA DX's `.section` syntax to define chunks of code and data and give WLA DX hints about where they need to be placed; this allows it to deal with packing the chunks into the available space for us.
 - Some is marked as `overwrite`, where we are patching over the original code at the address given.
 - `force` sections also go exactly where we have said, but these can only be placed if we have also `unbackgrounded` the space.
 - `free` sections can go anywhere in the current bank. This is useful for functions or data that are referenced from the same bank.
 - Some data can go literally anywhere as it's always accessed via paging; these are `superfree`.
- Note that we relocate and repopulate (using labels and macro) the "`SceneDataStruct`", in order to map in the majority of our recompressed and relocated graphics data. The tilemaps and palettes are all copied from the original ROM, the latter are relocated too.
- The name entry screen is patched quite manually, including making data for a screen-specific run-oriented tilemap encoding.
- For the credits, we inject new credits at the original data location. Note: please do not erase any credits on derived versions.
- Finally, there are a few original things added to the code...
  1. We fix a bug in the original game where the same text is used in both of the "liar" villages
  2. We add menus to the title screen for our sound and options menus, and the game save management
  3. We remove some of the waits for button presses
  4. We change the main "Idle loop" to use the halt instruction, which allows much more efficient emulation
  5. We replace the game load/delete menus (with awkward yes/no menus and black background) with menus from the title screen
  6. We add in "quality of life" options, and a sound test

## Disclaimer

This translation is unofficial and not supported by Sega Japan.

It is provided "as-is" with no warranty.

Any enclosed files are offered at no charge and must be distributed together in
original condition.

These files _may not_ be released for commercial sales without explicit
authorisation from all parties who own copyright ownership.

Sega Japan, Phantasy Star and Shining Force are registered trademarks of their
respective companies.

No breach of copyright is intended with the release of this translation.

## Game Credits

````
TOTAL PLANNING
OSSALE KOHTA (Kotaro Hayashida)

STORY BY
APRIL FOOL

SCENARIO WRITER
OSSALE KOHTA (Kotaro Hayashida)

ASSISTANT COORDINATORS
OTEGAMI CHIE (Chieko Aoki)
GAMER MIKI (Miki Morimoto)

TOTAL DESIGN
PHOEHIX RIE (Rieko Kodama)

MONSTER DESIGN
CHAOTIC KAZ

DESIGN
ROCKHY NAO (Naoto Ohshima)
SADAMORIAN (Koki Sadamori)
MYAU CHOKO (Takako Kawaguchi)
G CHIE
YONESAN (Hitoshi Yoneda)

SOUND
BO (Tokuhiko Uwabo)

SOFT CHECK
WORKS NISHI (Akinori Nishiyama)

ASSISTANT PROGRAMMERS
COM BLUE
M WAKA (Masahiro Wakayama)
ASI

MAIN PROGRAM
MUUUU YUJI (Yuji Naka)
````

Do you know who some of the other people are? Please get in touch.

## Web links

Fan pages:
- [Home of Phantasy Star](http://www.wolfgangarchive.com/psi-web/)
- [Algol Star System](https://web.archive.org/web/20060803085931/http://algol-star-system.net/)
- [The Phantasy Star Pages](http://www.phantasy-star.net)
- [Phantasy Star Cave](http://www.pscave.com)

Official distribution page for this patch:
- http://www.smspower.org/Translations/PhantasyStar-SMS-EN

Source code:
- https://github.com/maxim-zhao/psrp

## Translation notes

The goal of this translation is to produce a blend between "what the original Japanese version was like" and "what a good localisation would have been in 1987".
This means some effort is needed to adapt the intent of the original Japanese more or less literally as needed.
As a result, some of the character dialogue is extended beyond what was in the original Japanese, occasionally adding some hints, sometimes adding some extra style to some of the bare-bones dialogue where we are able to extend things beyond the space restrictions that also limited the Japanese script.

***Spoilers ahead***

Telling you the names of all the things in the game is a kind of spoiler, so don't look here unless you're OK with that.

### Characters
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
アリサ|arisa|ALIS|Alis|Alisa|Transliteration. Later games use "Alis" but the "a" is there in the original.
チョウコオネーサン|choukoonēsan|<not present>|<not present>|Choko Oneesan|Transliteration
ダモア|damoa|DAMOR|Damor|Damoa|Transliteration
エスパー|esupā|ESPAR|Espar|Esper(s)|Transliteration
ゲーマーノ ミキチャン|gēmāno mikichan|MIKI|Miki|Gamer Miki-chan|Transliteration
ソウトク|soutoku|GOVERNOR|Governor|Governor-General|Translation (総督)
ラシーク|rashīku|LASSIC|Lassic|LaShiec|Transliteration. [Fits with later translations.](https://phantasystar.fandom.com/wiki/Lashiec)
ルツ|rutsu|LUTZ|Lutz|Lutz|Transliteration
ルベノ|rubeno|LUVENO|Luveno|Luveno|Transliteration (unchanged)
メデューサ|mede~yūsa|MEDUSA|Medusa|Medusa|Transliteration (unchanged)
ミャウ|myau|MYAU|Myau|Myau|Transliteration (and onomatopoeia) (unchanged)
ネキセ|nekise|NEKISE|Nekise|Nekise|Transliteration (unchanged). Could be "Nekiseh" to imply the correct pronunciation.
ネロ|nero|NERO|Nero|Nero|Transliteration (unchanged)
オテガミ チエチャン|otegami chiechan|<not present>|<not present>|Otegami Chie-chan|Transliteration
スエロ|suero|SUELO|Suelo|Suelo|Transliteration (unchanged)
タジム|tajimu|TAJIM|Tajim|Tajim|Transliteration (unchanged)
タイロン|tairon|ODIN|Odin|Tylon|Transliteration. Controversial - could also be "Tairon", "Tyrone", "Tyron", ...

### Locations
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
アルゴル|arugoru|ALGOL|Algol|Algol|Transliteration (unchanged)
アルチプラノ|aruchipurano|ALTIPLANO|Altiplano|Altiplano|Transliteration (unchanged)
アビオン|abion|ABION|Abion|Avion|Transliteration
バルテボ|barutebo|BORTEVO|Bortevo|Bartevo|Transliteration
バヤ マーレ|baya māre|BAYA MALAY|Baya Malay|Baya Marlay|Transliteration
カミニート|kaminīto|CAMINEET|Camineet|Camineet|Transliteration (unchanged)
カスバ|kasuba|CASBA|Casba|Casba|Transliteration (unchanged)
コロナ|korona|CORONA|Corona|Corona|Transliteration (unchanged)
デゾリス|dezorisu|DEZORIS|Dezoris|Dezoris|Transliteration (unchanged)
ドラスゴー |dorasugō|DRASGOW|Drasgow|Drasgo|Transliteration
エピ|epi|EPPI|Eppi|Eppi|Transliteration (unchanged)
ガシコ|gashiko|GOTHIC|Gothic|Gothic|Transliteration (unchanged)
グアラン|guaran|GUARON|Guaron|Guaran|Transliteration
イアラ|iara|IALA|Iala|Iala|Transliteration (unchanged)
マハル|maharu|MAHARU|Maharu|Mahal|Transliteration
モタビア|motabia|MOTAVIA|Motavia|Motavia|Transliteration (unchanged)
ナウラ|naura|NAULA|Naula|Naula|Transliteration (unchanged)
パルマ|paruma|PALMA|Palma|Palma|Transliteration (unchanged)
パロリト|parorito|PAROLIT|Parolit|Parolit|Transliteration (unchanged)
パセオ|paseo|PASEO|Paseo|Paseo|Transliteration (unchanged)
シオン|shion|SCION|Shion|Shion|Transliteration
スクレ|sukure|SKURE|Skure|Skray|Transliteration
ソピア|sopia|SOPIA|Sopia|Sopia|Transliteration (unchanged)
トリアダ|toriada|TRIADA|Triada|Triada|Transliteration (unchanged)
ウーゾ|ūzo|UZO|Uzo|Uzo|Transliteration (unchanged)

### Weapons
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
セラミックソード|seramikkusōdo|CRC. SWD|Ceramic Sword|Ceramic Sword|Transliteration (unchanged)
ヒートガン|ītogan|HEAT.GUN|Heat Gun|Heat Gun|Transliteration (unchanged)
アイアンアクス|aianakusu|IRN. AXE|Iron Axe|Iron Axe|Transliteration (unchanged)
アイアンソード|aiansōdo|IRN. SWD|Iron Sword|Iron Sword|Transliteration (unchanged)
ラコニアンアクス|rakonianakusu|LAC. AXE|Laconian Axe|Laconian Axe|Transliteration (unchanged)
ラコニアンソード|rakoniansōdo|LAC. SWD|Laconian Sword|Laconian Sword|Transliteration (unchanged)
レーザーガン|rēzāgan|LASR.GUN|Laser Gun|Laser Gun|Transliteration (unchanged)
ライトセイバー|raitoseibā|LGT.SABR|Light Saber|Light Saber|Transliteration (unchanged)
ニードルガン|nīdorugan|NEEDLGUN|Needle Gun|Needle Gun|Transliteration (unchanged)
サイコウォンド|saikowondo|WAND|Wand|Psycho Wand|Transliteration
サーベルクロー|sāberukurō|SIL.FANG|Silver Fang|Saber Claw|Transliteration. Sega translation changed the meaning.
ショートソード|shōtosōdo|SHT. SWD|Short Sword|Short Sword|Transliteration (unchanged)
シルバータスク|shirubātasuku|IRN.FANG|Iron Fang|Silver Tusk|Transliteration. Sega translation changed the meaning, see also "SIL. FANG".
チタニウムソード|chitaniumusōdo|TIT. SWD|Titanium Sword|Titanium Sword|Transliteration (unchanged)
ウッドケイン|uddokein|WOODCANE|Wood Cane|Wood Cane|Transliteration (unchanged)

### Armour
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
ダイヤノヨロイ|daiyanoyoroi|DMD.ARMR|Diamond Armor|Diamond Armor|Transliteration + translation (ダイヤの鎧)
フラードマント|furādomanto|FRD.MANT|Frad Mantle|Frad Mantle|Transliteration
アイアンアーマ|aianāma|IRN.ARMR|Iron Armor|Iron Armor|Transliteration (unchanged)
ラコニアアーマ|rakoniāama|LAC.ARMR|Laconian Armor|Laconian Armor|Transliteration
レザークロス|rezākurosu|LTH.ARMR|Leather Armor|Leather Clothes|Transliteration
ライトスーツ|raitosūtsu|LGT.SUIT|Light Suit|Light Suit|Transliteration (unchanged)
トゲリスノケガワ|togerisunokegawa|THCK.FUR|Thick Fur|Spiky Squirrel Fur|Translation (トゲリスの毛皮)
ホワイトマント|howaitomanto|WHT.MANT|White Mantle|White Mantle|Transliteration (unchanged)
ジルコニアメイル|jirukoniameiru|ZIR.ARMR|Zirconian Armour|Zirconia Mail|Transliteration. Note that zirconia is a cheaper version of diamond.

### Shields
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
アニマルグラブ|animarugurabu|GLOVE|Glove|Animal Glove|Transliteration
ボロンシールド|boronshīrudo|IRN. SLD|Iron Shield|Bronze Shield|Transliteration. Swapped with Iron Shield in Sega translation.
セラミックノタテ|seramikkunotate|CRC. SLD|Ceramic Shield|Ceramic Shield|Transliteration + translation (セラミックの盾)
アイアンシールド|aianshīrudo|BRNZ.SLD|Bronze Shield|Iron Shield|Transliteration. Swapped with Bronze Shield in Sega translation.
ラコニアシールド|rakoniashīrudo|LAC. SLD|Laconian Shield|Laconian Shield|Transliteration
レーザーバリア|rēzābaria|LASR.SLD|Laser Shield|Laser Barrier|Transliteration
レザーシールド|rezāshīrudo|LTH. SLD|Leather Shield|Leather Shield|Transliteration
ペルセウスノタテ|peruseusunotate|MIRR.SLD|Mirror Shield|Shield of Perseus|Transliteration + translation (ペルセウスの盾)

### Vehicles
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
フロームーバー|furōmūbā|HOVRCRFT|Hovercraft|FlowMover|Transliteration
アイスデッカー|aisudekkā|ICE DIGR|Ice Digger|IceDecker|Transliteration
ランドマスター|randomasutā|LANDROVR|Land Rover|LandMaster|Transliteration

### Items
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
エアロプリズム|earopurizumu|PRISM|Prism|Aeroprism|Transliteration
アルシュリン|arushurin|ALSULIN|Alsulin|Alsuline|Transliteration. Not sure if there is some reason for the name.
カーバンクルアイ|kābankuruai|AMBR EYE|Amber Eye|Carbuncle Eye|Transliteration
コンパス|konpasu|COMPASS|Compass|Compass|Transliteration
ダモアクリスタル|damoakurisutaru|CRYSTAL|Crystal|Damoa's Crystal|Transliteration
ダンジョンキー|danjonkī|DUGN KEY|Dungeon Key|Dungeon Key|Transliteration
イクリプストーチ|ikuripusutōchi|TORCH|Torch|Eclipse Torch|Transliteration
エスケープクロス|esukēpukurosu|ESCAPER|Escaper|Escape Cloth|Transliteration
ガスクリア|gasukuria|GAS. SLD|Gas Shield|GasClear|Transliteration
ソウトクノテガミ|soutokunotegami|LETTER|Letter|Governor[-General]'s Letter|Translation (総督の手紙)
ハプスビー|hapusubī|HAPSBY|Hapsby|Hapsby|Transliteration
ラコニアンポット|rakonianpotto|LAC. POT|Laconian Pot|Laconian Pot|Transliteration
ラエルマベリー|raerumaberī|NUTS|Nuts|Laerma Berries|Transliteration
ライトペンダント|raitopendanto|MAG.LAMP|Magic Lamp|Light Pendant|Transliteration
マジックハット|majikkuhatto|MAGC HAT|Magic Hat|Magic Hat|Transliteration
マスターシステム|masutāshisutemu|M SYSTEM|Master System|Master System|Transliteration
ミラクルキー|mirakurukī|MRCL KEY|Miracle Key|Miracle Key|Transliteration
パスポート|pasupōto|PASSPORT|Passport|Passport|Transliteration
ペロリーメイト|perorīmeito|COLA|Cola|PelorieMate|Transliteration. This is a play on "CalorieMate", a Japanese brand of "energy bar"
ポリメテラール|porimeterāru|POLYMTRL|Polymeteral|Polymeteral|Transliteration
ロードパス|rōdopasu|ROADPASS|Roadpass|Road Pass|Transliteration
ルオギニン|ruoginin|BURGER|Burger|Ruoginin|Transliteration. Similar to PelorieMate, this is a corruption of Arginine V (アルギニンV, aruginin V), a Japanese brand of "energy drink"
サーチライト|sāchiraito|FLASH|Flash|Searchlight|Transliteration
ヒミツノモノ|himitsunomono|SECRET|Secret|Secret Thing|Translation (秘密の物)
ショートケーキ|shōtokēki|CAKE|Cake|Shortcake|Transliteration
スーズフルート|sūzufurūto|FLUTE|Flute|Soothe Flute|Transliteration
テレパシーボール|terepashībōru|SPHERE|Sphere|Telepathy Ball|Transliteration
トランカーペット|torankāpetto|TRANSER|Transer|TranCarpet|Transliteration
ジリオン|jirion|ZILLION|Zillion|Zillion|Transliteration

### Spells
Japanese|Romaji|Sega original translation (in-game)|Sega original translation (interpretation)|Retranslation|Notes
:---|:---|:---|:---|:---|:---
ビンドワ|bindowa|ROPE|Rope|Bind|"Binds" enemy so it can't attack. Transliteration.
スルト|suruto|EXIT|Exit|Bypass|Exit dungeon. Suruto means something like "and then...". May also come from "するっと", meaning to pass somewhere easily.
フレエリ|fureeri|FIRE|Fire|Fire|Fire attack (-10DP x 2). Transliteration (unchanged).
ヒール|hiiru|HEAL|Heal|Heal|+20HP. Transliteration (unchanged)
ムオーデ|muoode|OPEN|Open|Magic Unseal|Open sealed doors. "Mu" prefix for "magic"; the word "oode" can mean "to open one's arms wide".
ムワーラ|muwaara|PROT|Protect|Magic Waller|Creates a "wall" that blocks attacks and magic. "Mu" prefix for "magic", plus transliteration.
パウマ|pauma|HELP|Help|Power Boost|Boosts AP. "Pow" transliteration.
ラクスタ|rakusuta|BYE|Bye|Quick Dash|Exit a battle. "Raku" means 'comfort, ease', and "sutasuta" is sound-symbolic for 'quickly running'.
リーバス|riibasu|RISE|Rise|Rebirth|Resurrects a dead person to full life. Transliteration.
ドヒール|dohiiru|CURE|Cure|Super Heal|+80HP. "Do" prefix for "super" spells, plus transliteration.
テレパス|telepasu|TELE|Tele|Telepathy|Talk to enemies. Transliteration.
テルル|teruru|TERR|Terr|Terror|Decreases enemy DP. Transliteration.
タンドレ|tandore|THUN|Thunder|Thunder|Lightning attack (-30DP to all enemies). Transliteration.
ペヤラク|peyaraku|CHAT|Chat|Transrate|Talk to enemies, but does not always work - hence a "bad" translation. Might be a play on the words "perapera" ('fluent') and "yaku" ('translation'), created by taking the word "perayaku" ("fluent/perfect translation") and switching the second and third syllables. Similar to "raputto", this also makes sense if you consider that the spell allows you to talk to certain monsters. Also, since the name of the spell isn't a perfect rendering of "peyaraku", it makes sense that the spell doesn't work on all monsters. 
トルーパ|toruupa|FLY|Fly|Troop|Return to last church. Transliteration.
ラプット|raputto|TRAP|Trap|Untrap|Disarms traps. "Raputto" is a jumpled-up "torappu", which is transliterated.
ワーラ|waara|WALL|Wall|Waller|Creates a "wall" that blocks attacks. Transliteration (unchanged)
ヒューン|hyuun|WIND|Wind|Wind|Wind attack (-10DP x 3). Original is opomatopoeic for a strong gust of wind but there's no good English equivalent.

## Contact

PLEASE get in touch if you find a bug or you think you can help correct a
mistake.

You can post on the SMS Power! forums:

http://www.smspower.org/forums/

or raise issues at

https://github.com/maxim-zhao/psrp/issues
