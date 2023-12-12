## Technical notes

The Git history contains many documents written by Z80 Gaiden during his hacking work.
These became less relevant later so they are no longer present.

The code is designed to build in a Windows command prompt, with WLA DX and BMP2Tile
available. It uses GNU Make for the makefile, and Python for custom tools related to the game.

The custom tools are used to perform certain tasks needed to build the final script:

### tools.py generate_words

This takes the script (from script.yaml, filtered to the target language) and generates a file listing the most commonly-used words, weighted by length, in descending order. It breaks words on apostrophes, so we can avoid counting "Alisa" and "Alisa's" separately. It then takes this word list and uses it to substitute the common words with a single byte. It generates a TBL file, and assembly code for the word list.

The optimal number of words to substitute this way for a given script is complicated, as substituting more words adds complexity to the next compression steps; but to maximise the script space overall, we should maximise the word count; the current limit is about 147 words, but the optimal numbers are found by brute force.

### tools.py script_inserter

This converts the whole script into encoded data (for the substituted words, the non-substituted letters and some control codes). Next it applies "adaptive Huffman compression" to each script entry - for every byte in the script, we have a Huffman tree for each subsequent byte. This means the individual trees can be quite small (so the encoded tree path is smaller), but there are many such trees.

Finally, it emits the Huffman trees and encoded script data as assembly, and also emits patches for all the locations where the original game references a script entry. We introduce a lookup table to allow script entries to be stored in multiple banks; this could be more efficient (it costs us three bytes per script entry) but make script expansion much easier. The original English retranslation had no need for this, but some other languages benefit from the additional space.

### tools.py menu_creator

The menus themselves are encoded as raw tilemap data. This program takes the UTF-8 text in menus.yaml and converts them to the tilemap data. Note that we use a "16-bit" TBL file for this part, with some extra characters used for the menu borders.

Changing the menu dimensions is far from trivial. In order to act like overlapping windows, the game caches the tilemap data from under each one as it is drawn, and then restores it. This is done using fixed RAM areas, rather than some kind of stack, and these areas need to overlap (due to RAM restrictions), so we need to ensure only windows which are never used at the same time overlap in memory. Careful use of assembly-time calculations allows us to enforce the necessary alignment of memory areas.

We might consider changing menu drawing to use a more efficient format - i.e. the script encoding - to save ROM space in future.

### tools.py bitmap_decode

In order to free up space in the ROM, we re-encode the graphics (tile) data with a more efficient compression method - namely, the algorithm used in Phantasy Star Gaiden. We first decode the data using bitmap_decode, which puts it into the raw VRAM tile format, and then re-encode it using BMP2Tile.

Note that the PS Gaiden compression yields smaller results than other algorithms like ZX7, yet faster decompression than the original game.

### new_graphics directory

In a few places we insert new graphics - the title screen, fonts, and tiles for the "shop" and "exit" signs. We render these as PNG files and use BMP2Tile to convert to the necessary formats. We also have a duplicate tileset for Alisa with brown hair.

### ps1jert.sms.asm

Next we have the assembly file itself, `ps1jert.sms.asm`. ("Phantasy Star 1 Japanese to English ReTranslation", later simplified to "psrp" (Phantasy Star Retranslation Project)). We use WLA DX as it offers several useful features that avoid us needing to write custom code:

- We "background" the original ROM, so that we can build a ROM image based on it
- We then "unbackground" various areas that are either replaced code/data, unused code/data (e.g. there are vestiges of a password system), or just unused areas of ROM.
- Next we can define some helper macros for various tasks:
  - `CopyFromOriginal` is useful for where we are moving a chunk of of data to a different location.
  - `ROMPosition` allows us to set the assembly position in ROM space, useful for patching specific addresses.
  - `PatchB` and `PatchW` allow us to patch bytes and words at specific addresses. This is used for many of the generated "patch" files.
  - `LoadPagedTiles` is used for a repeated pattern of mapping in some tile data and loading t to VRAM.
  - `String` is used to encode various bits of text in the game (especially the lists). We use WLA DX's `.stringmap` to help with the mapping.
- We define some names for various RAM locations used by the game, as well as locations used by the new script engine code (which re-use areas used by the old engine).
- Next we start defining a mixture of new code and patches to the old code to call into the new code. We use WLA DX's `.section` syntax to define chunks of code and data and give WLA DX hints about where they need to be placed; this allows it to deal with packing the chunks into the available space for us.
 - Some is marked as `overwrite`, where we are patching over the original code at the address given.
 - `force` sections also go exactly where we have said, but these can only be placed if we have also `unbackgrounded` the space.
 - `free` sections can go anywhere in the current bank. This is useful for functions or data that are referenced from the same bank.
 - Some data can go literally anywhere as it's always accessed via paging; these are `superfree`.
- Note that we relocate and repopulate (using labels and macro) the "`SceneDataStruct`", in order to map in the majority of our recompressed and relocated graphics data. The tilemaps and palettes are all copied from the original ROM, the latter are relocated too.
- We inject additional source files via `.include`; some of these are language-specific. We use the compile-time definition `LANGUAGE` to control these and other language-specific aspects.
- The name entry screen is reimplemented almost entirely from scratch.
- For the credits, we inject new credits at the original data location.
- Finally, there are a few original things added to the code...
  1. We fix a bug in the original game where the same text is used in both of the "liar" villages
  2. We fix a bug in the original game which causes Myau's stats to get worse at the highest level
  3. We fix various bugs in the original game which manifest as losing track of the number of lines already written to the script box, as we are now much less likely to have already reached the bottom.
  3. We add menus to the title screen for our sound and options menus, and the game save management
  4. We remove some of the waits for button presses
  5. We change the main "Idle loop" to use the halt instruction, which allows much more efficient emulation
  6. We replace the game load/delete menus (with awkward yes/no menus and black background) with menus from the title screen
  7. We add in "quality of life" options, and a sound test

### makefile

Finally we have a makefile which ties everything together. This makefile is relatively complicated in order to make an efficient incremental build system, while also making use of WLA DX's makefile generation feature. We mostly put intermediate files in the `generated` directory to make cleaning up easy.
