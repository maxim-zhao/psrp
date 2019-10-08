# Phantasy Star English Retranslation v1.03

Phantasy Star
- Sega Master System + YM-2413 FM

Original Game © 1987
- Sega Japan
- released 1987/12/20

Unofficial Translation 2005-2019
- SMS Power!
- v0.90 released 2006/12/20
  - first release
- v0.91 released 2006/12/22
  - minor script clean-ups
  - checksum fixed
- v1.00 released 2007/12/20
  - minor script bugfixes
  - spell menu expansion
  - minor bugfix for sound chip selector
- v1.01 released 2007/12/22
  - checksum fixed for play on a real system
  - fixed a bug with the Pause button mod
- v1.02 released 2008/01/31
  - fixed lockup when you visit Tajim
- v1.03 released 2019/??/??
  - rebuilt tools and assembly process
  - fixed issue with 10-letter item names in inventory (#2)
  - fixed bug with pluralisation (#4)

Phantasy Star Original Dialogue Version 
Japanese to English Retranslation © 2001-2002
- Paul Jensen

## What is Phantasy Star

Phantasy Star is a ground-breaking RPG from 1987. It was the first console RPG
released in the US; it was one of the first sci-fi-based RPGs, although has a
unique mix of fantasy and sci-fi; and it introduced many concepts to the genre.

It was ground-breakingly large - taking place across three planets, with large,
colourful, animated monsters. It was one of the first (and only) games to
feature a female protagonist with real characterisation and character
development, without resorting to videogaming's female stereotypes.

If you want to learn more about the game, check out some of the web links below.

## Contents

The following changes are made to the game engine:

- 2-line naming terminology
- Narrative formatting
- Window expansion
- Replaced 8x8 font
- Use of adapting indefinite articles
- Reworked name entry screen
- FM/PSG switching (press Pause on the title screen)

## Instructions

This IPS patch requires that you download a program that can apply it to a
properly dumped ROM-image of the game. "Floating IPS" is recommended for 
Windows.

The original, unmodified game has the following characteristics:

Size:  512KB (524,288 bytes)

CRC32: `6605D36A`

MD5:   `DFEBC48DFE8165202B7F002D8BAC477B`

There is only one known Japanese version of the game. The patch will NOT work
with the US/European versions, or any other game on any platform.

A copier is suggested to obtain your legal backup. Always make sure to have 
an original backup of your game. And only apply the patch to a clean, 
unmodified ROM image.

Changes made between version numbers may adversely affect emulator save states.
In such event, please use the in-game save feature to gain any new features.

## Credits

### Z80 Gaiden
- Core hacking and programming
### Maxim
- Project manager, final hacking/programming
### Paul Jensen
- Script translator, editor
### satsu
- Additional translations
### Frank Cifaldi
- Localization

Special thanks to:

### Sega Japan
- Original publisher, developer, creative content
- Phantasy Star Gaiden, Phantasy Star 1-4
### Team Sonic
- Shining Force Gaiden: Final Conflict

### Bock (Omar Cornut)
- Meka is an excellent debugging emulator
### Charles MacDonald
- Open-source SMS/GG emulator
### Forgotten
- Functional Z80 disassembler from his GB/GBA emulator
### Gregory Montoir
- Open-source SDL port of first-mentioned program
### KingMike
- Concise DTE tutorial
### SnowBro
- Versatile tile editor

Also thanks to the following for various contributions to item naming, etc.
- DJ Squarewave
- TheGZeus
- idrougge
- Namida
- LEADKUN
- Mia

## Authors' notes

### Z80 Gaiden (2004)

Paul Jensen had posted a translated script with a good majority of the lists in
2001-2002. I wasn't aware of its existence until someone mentioned a
retranslation project that didn't make fully it to completion yet.

The game proved to be an interesting task - lack of useful padding space.
Narrative and items fitting into a mere 15.67 KB. Need patience with this one.

So this project was designed to keep the FM music intact while squeezing in
more full item descriptions and textual script content.

Not enough thanks can be directed to Mr. Jensen for his care in posting his
retranslation publicly online and keeping it freely accessible for all this
time.

This author releases copyright ownership in the patch and produces it under the
banner of the original team of Maxim and Paul Jensen: SMS Power!.

### Maxim (2006)

This has been a long time coming. When I received the near-complete translation
from Z80 Gaiden (who goes by several names and has done amazing work on
translations before) I was amazed - it was 90% done. Unfortunately, as the
aphorism says,

"The first 90% of the code accounts for the first 90% of the development time.
The remaining 10% of the code accounts for the other 90% of the development
time."

Over the last 2 years or so I have worked on it on and off, and while I'm
fairly confident that I've fixed most of the bugs, it's sadly not been tested
as much as I'd like; so I'm committed to keep working on it.

I hope you all enjoy TheRedEye's script changes. We've approached this project
with the aim of bringing you the experience of the original Japanese version,
but there have been a few minor changes to bring the script alive, rather than
do it word-for-word. We'd like to think this is what the original translation
should have been, 18 years ago.

It's also a great framework for further (re-)translation into more languages.
Please get in touch if you can do some serious work on that. You will need to
provide a translator *and* a Z80 coder.

## Technical notes

The Git history contains many documents written by Z80 Gaiden during his hacking work.
These became less relevant later so they are no longer present.

The code is designed to build in a VIsual Studio developer command prompt, with WLA DX
available. It uses Microsoft's NMAKE too for the makefile; it is unlikely to work with
GNU Make without modifications, but otherwise the build process is fairly simple.

There are several programs included, some of which are not part of the build process but are retained for historical purposes. The main ones are:

### word_count

This takes the script (which lives in its directory) and generates a words.txt listing the most commonly-used words, weighted by length, in descending order.

### substring_formatter

This takes the word list and uses it to substitute the common words with a single byte. It generates a TBL file, and assembly code for the word list.

The optimal number of words to substitute this way for a given script is complicated, as substituting more words adds complexity to the next compression steps; but to maximise the script space overall, we should maximise the word count, which means selecting the 164 most common words (unless we find some more symbol space).

It then converts the whole script into encoded data (for the substituted words, the non-substituted letters and some control codes). Next it applies "adaptive Huffman compression" to each script entry - for every byte in the script, we have a Huffman tree for each subsequent byte. This means the individual trees can be quite small (so the encoded tree path is smaller), but there are up to 256 of them.

Finally, it emits the Huffman trees and encoded script data as assembly, and also emits patches for all the locations where the original game references a script entry. Note that the game originally had script entries referenced by index; we instead patch with direct pointers.

### menu_creater

The menus themselves are encoded as raw tilemap data. This program takes the UTF-8 text in menus.txt (all the menus/windows) and opening.txt (the one window used in the opening) and converts them to the tilemap data. Note that we use a "16-bit" TBL file for this part, with some extra characters used for the menu borders.

Changing the menu dimensions is far from trivial. In order to act like overlapping windows, the game caches the tilemap data from under each one as it is drawn, and then restores it. This is done using fixed RAM areas, rather than some kind of stack, and these areas need to overlap (due to RAM restrictions), so we need to ensure only windows which are never used at the same time overlap in memory.

One future enhancement may be to take the menus which currently "double-space" entries (often with wrapping), like the items menu, and make them twice as wide and half as high. This will require a great deal of rearranging the screen and RAM positions, and may increase RAM pressure.

### bitmap_decode

In order to free up space in the ROM, we re-encode some of the graphics (tile) data with a more efficient (but slower) compression method - namely, the algorithm used in Phantasy Star Gaiden. We first decode the data using bitmap_decode, which puts it into the raw VRAM tile format, and then re-encode it using BMP2Tile.

Note that the PS Gaiden compression yields smaller results than other algorithms like ZX7 and aPLib.

Note also that the original game has two versions of the tile decoder - one for use when VBlanks are disabled (i.e. when loading new scenes) and one for use "in-game" (e.g. for loading enemy tiles). We replace only the first one of these; this allows us to free up enough space while also reducing the number of places we need to re-encode the graphics.

### new_graphics

In a few places we insert new graphics - the title screen and fonts. We render these as PNG files and use BMP2Tile to convert to the necessary formats.

### ROM building

Finally we have the assembly file itself, `ps1jert.asm`. ("Phantasy Star 1 Japanese to English ReTranslation", later simplified to "psrp" (Phantasy Star Retranslation Project)). We use WLA DX as it offers several useful features that avoid us needing to write custom code:

- We "background" the original ROM, so that we can build a ROM image based on it
- We then "unbackground" various areas that are either replaced code/data, unused code/data (e.g. there are vestiges of a password system), or just unused areas of ROM.
- Next we can define some helper macros for various tasks:
  - **`CopyFromOriginal`** is useful for where we are moving a chunk of of data to a different location.
  - **`ROMPosition`** allows us to set the assembly position in ROM space, useful for patching specific addresses.
  - **`PatchB`** and **`PatchW`** allow us to patch bytes and words at specific addresses. This is used for many of the generated "patch" files.
  - **`TextToTilemap`** is a fairly large macro that simply converts a string to tilemap data. This is used for various places where the game draws stats menus, and the name entry screen. 
  - **`LoadPagedTiles`** is used for a repeated pattern of mapping in some tile data and loading t to VRAM.
  - **`String`** is used to encode various bits of text in the game (especially the lists). We use WLA DX's `.asciitable` to help with the mapping to avoid needing another monstrous macro like `TextToTilemap`.
- We define some names for various RAM locations used by the game, as well as locations used by the new script engine code (which re-use areas used by the old engine).
- Next we start defining a mixture of new code and patches to the old code to call into the new code. We use WLA DX's "section" syntax to define chunks of code and data and give WLA DX hints about where they need to be placed; this allows it to deal with packing the chunks into the available space for us.
 - Some is marked as "overwrite", where we are patching over the original code at the address given.
 - "force" sections also go exactly where we have said, but these can only be placed if we have also "unbackgrounded" the space.
 - "free" sections can go anywhere in the current bank. This is useful for functions or data that are referenced from the same bank.
 - Some data can go literally anywhere as it's always accessed via paging; these are "superfree".
- Note that we relocate and repopulate (using labels and macro) the "`SceneDataStruct`", in order to map in the majority of our recompressed and relocated graphics data. The tilemaps and palettes are all copied from the original ROM, the latter are relocated too.
- The name entry screen is patched quite manually, including making data for a screen-specific run-oriented tilemap encoding.
- Likewise for the credits. Note: please do not erase any credits on derived versions.

## Disclaimer

This translation is unofficial and not supported by Sega Japan.

It is provided "as-is" with no warranty.

Any enclosed files are offered at no charge and must be distributed together in
original condition.

These files -may not- be released for commercial sales without explicit
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
SADAMORIAN
MYAU CHOKO
G CHIE
YONESAN (Hitoshi Yoneda)

SOUND
BO (Tokuhiko Uwabo)

SOFT CHECK
WORKS NISHI (Akinori Nishiyama)

ASSISTANT PROGRAMMERS
COM BLUE
M WAKA
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
- [Phantasy STar Cave](http://www.pscave.com)

Official distribution page for this patch:
- http://www.smspower.org/Translations/PhantasyStar-SMS-EN

Source code:
- https://github.com/maxim-zhao/psrp

## Contact

PLEASE get in touch if you find a bug or you think you can help correct a
mistake.

You can post on the SMS Power! forums:

http://www.smspower.org/forums/

or raise issues at

https://github.com/maxim-zhao/psrp/issues 
