Adding translations
===================

The codebase is designed to make it relatively easy to add translations. There are a few places where you need to add or edit files or text, and a small amount of code.

The language-specific parts are mostly gathered into per-language directories, with the exception of the main script and menu definitions. For example, the English translation has files in the `en` directory. In the descriptions below, I'll use `xx` as a placeholder for the language. The items are somewhat ordered logically rather than alphabetically.

`xx`/font*.png
--------------

These files define the fonts used in the game - two selectable fonts for the main game, and the credits font. The ["Polaris" font is by DamienG](https://damieng.com/typography/zx-origins/polaris) and made specifically for this translation. The AW2664 is based on the fonts used in later Mega Drive Phantasy Star games.

There are precisely 70 8x8 tiles available for text (letters, numbers, punctuation and space), and four for the menu borders. If your language needs more - for example, accented characters - then it is tricky to find space. It is possible to use the same tile for some very similar characters - for example, l and 1, and 0 and O. With some redesigning of the font, it is possible to make more characters reusable by flipping. See the pt-br font images (and comments in `tilemap.pt-br.tbl`) for an example of that.

`xx`/tilemap.tbl
----------------

This is a "table file" defining how characters you want to use map to tiles to the tileset defined by the images above. Each value is two hex bytes which correspond to the Master System VDP tilemap format. In here you can specify things like tile flipping to get more characters out of the available tiles.

Any characters used in the menus.yaml file have to be specified in here. You can map accented characters to the same values as unaccented characters as necessary.

`xx`/script.tbl
---------------

This is a "table file" defining how the UTF-8 characters in the script map to unique characters in the script data. The script compression algorithm also maps entire words to many of the unused byte values.

Any characters used in your script.yaml file have to be specified in here. You can map accented characters to the same values as unaccented characters as necessary; this allows you to have "perfect" characters in the script even if you have to remove some of them to fit in the font space.

script.yaml
-----------

This is the main script. It is in YAML form, and includes every language at the same time. This means you can look at the Japanese text, literal translation, English localization, and other translations for each script element at the same time. Some entries have comments to explain why things are the way they are. This file contains UTF-8 text and you should use all characters for your language in the text - let script.xx.tbl handle any removal of accents.

menus.yaml
----------

This contains the menus used in the game. The box drawing characters are important, and if you increase the size of any menu then it is important to manage the RAM caches - see below.

`xx`/articles.asm
-----------------

These contain the definitions of articles (see the articles section below) and code to manage the selection of them. The indices used need to match those used in tools.py.

`xx`/lists.asm
--------------

These contain the names of items in the game: inventory items, characters and enemies. These include markers to determine the correct articles for each. Add a new version for a new language.

`xx`/plurals.asm
-----------------

In the script you sometimes want to pluralise a noun in a script entry like "You gained 10 experience points". The script engine lets you do this with the `<s>` tag, but this file defines which letter is actually used. If you need more complex pluralisation, some more development work will be needed. 

`xx`/pronouns.asm
-----------------

In most languages we sometimes use pronouns like "her" and "she" in the script when referring to the party members. Here we define the pronouns for the female (`_PronounsF`) and male (`_PronounsM`) characters for each language.

`xx`/options-menu.asm
---------------------

The title screen options menu has values drawn in at runtime. These are localised per-language here. Each value needs to be the same length as the other values that are used in the same place, e.g. the text for "Fast" has to be left-padded to make it the same length as "Normal".

`xx`/stats-hp-mp.asm
--------------------

This is the text for "HP" and "MP" in stats windows for both players and enemies.

`xx`/stats-window.asm
---------------------

This is the main stats window seen in-game when choosing "Status". The rows that have numbers shown are padded with exactly enough spaces so that the number renderer will fill the remaining space.

`xx`/name-entry-data.asm
------------------------

The save game name entry screen layout is defined here. There are three parts: text, mask and cursor limits.

In the first part, NameEntryText defines what is shown on the screen and where, in the form `x, y, "text"`. If there are more than three spaces in a row then it saves a tiny amount of ROM space to split the text into multiple entries. 

In the second part, NameEntryMask defines which parts of the text are the Back, Next, Space and Save buttons.

Finally we define the X, Y limits of the screen so the cursor knows where to stop.

`xx`/credits.asm
----------------

This contains data for the credits at the end of the game. We have squeezed some of the original credits together in order to make space for a couple of screens for retranslation credits. As it is all capitals, any accents are placed as separate text on the row above or below as needed.

`xx`/titlescreen.png
--------------------

This is just the localised part of the title screen. You should look at titlescreen.psd (and maybe add a layer) to see how this works. I tend to tweak these for consistency.

asm/ps1jert.sms.asm
-------------------

This is where most of the code goes, although much of it is also pulled in from additional files in the `asm` directory. Some work may be needed in here to implement new functionality needed for new languages.

makefile
--------

The script is compressed in two ways: first by assigning bytes to entire words, favouring those that are used a lot; and second by Huffman compressing the byte sequences using a series of Huffman trees. The words that get assigned bytes are selected based on both their length and frequency of use. The number of words chosen affects both the total ROM space and the size of certain parts of the data, and it can be a tricky trade-off to make.

In order to maximise the space available for the script overall, potentially at the cost of a larger ROM overall (or more difficulty to fit other changes), the maximum word count of 148 should be used. However, this adds more complexity to the Huffman trees and enlarges the dictionary. In order to maximise the space available for the ROM in general - for example to allow a more detailed title screen - then only trial and error can help you find the "best" value. Iterating over all values is needed to determine this via a target `sizes.xx.txt` in the makefile.

The word count is assigned to a value in the makefile, or can be set in the make parameters.

Resizing menus
--------------

Many of the menus have been sized to it the text that goes in them. For example, item names and spell names both determine the size of menus and windows they appear in. If you want to make them narrower, that is fine; you will also save some ROM space. If you want to make them wider, that is more tricky because of the way the game manages the "window cache" when drawing menus and windows over things on the screen. The allocation is automated but based on some assumptions that may not hold if you resize things more than expected.

Look at the comments in `asm/window-ram-management.asm` for an overview of how this works.

Adding script "articles"
------------------------

The "articles" (by which I mean those words that are linked to the noun they go with in a sentence, like item and enemy names) available to you are stored in the script as indices for the article handling assembly code to use at runtime. You can specify one by index using the code <use article xx> where xx is a hexadecimal number. However, it is nice to define "words" for these values too. These are added to script.xx.tbl and then also to `parse_tag()` in tools.py. Then you need to add appropriate handlers to ps1jert.sms.asm. It helps to build a table of noun types × word types, for example:

English:

|                      |Mid-sentence|Start of sentence
|----------------------|------------|-----------------
|Indefinite            | a          | A
|Indefinite with vowel | an         | An
|Definite              | the        | The

French:

|                            |Mid-sentence article|Start of sentence article|Possessive|Directive
|----------------------------|--------------------|-------------------------|----------|---------
|Starts with vowel           | l'                 | L'                      | de l'    | à l'
|Feminine                    | le                 | Le                      | du       | au
|Masculine                   | la                 | La                      | de la    | à la
|Plural                      | les                | Les                     | des      | aux
|Name starting with vowel    |                    |                         | d'       | à
|Name starting with consonant|                    |                         | de       | à

Brazilian Portuguese:

|                            |Mid-sentence article|Start of sentence article|Possessive
|----------------------------|--------------------|-------------------------|----------
|Masculine single indefinite | um                 | Um                      | do
|Masculine plural indefinite | uns                | Uns                     | da
|Feminine single indefinite  | uma                | Uma                     | dos
|Feminine plural indefinite  | umas               | Umas                    | das
|Masculine single definite   | o                  | O                       | do
|Masculine plural definite   | a                  | A                       | da
|Feminine single definite    | os                 | Os                      | dos
|Feminine plural definite    | as                 | As                      | das
|Name                        |                    |                         | de

Catalan:

|                            |Mid-sentence article|Start of sentence article|Possessive
|----------------------------|--------------------|-------------------------|----------
|Masculine single indefinite | un                 | Un                      | de un
|Masculine plural indefinite | uns                | Uns                     | de uns
|Feminine single indefinite  | una                | Una                     | de una
|Feminine plural indefinite  | unes               | Unes                    | de unes
|Starts with vowel definite  | l'                 | L'                      | de l'
|Masculine single definite   | el                 | El                      | del
|Feminine single definite    | la                 | La                      | de la
|Masculine plural definite   | els                | Els                     | dels
|Feminine plural definite    | les                | Les                     | de les
|Masculine name              | en                 | En                      | d'en
|Feminine name               | na                 | Na                      | de na

German:

|                              |Start of sentence nominative|Mid-sentence genitive|Mid-sentence dative|Mid-sentence accusative
|------------------------------|----------------------------|---------------------|-------------------|-----------------------
|Definite masculine singular   | Der                        | des                 | dem               | den
|Definite feminine singular    | Die                        | der                 | der               | die
|Definite neuter singular      | Das                        | des                 | dem               | das
|Indefinite masculine singular | Ein                        | eines               | einem             | einen
|Indefinite feminine singular  | Eine                       | einer               | einer             | eine
|Indefinite neuter singular    | Ein                        | eines               | einem             | ein

Building
--------

To build, you need:

1. GNU Make
2. Python 3
3. [WLA DX](https://github.com/vhelin/wla-dx)
4. [BMP2Tile](https://github.com/maxim-zhao/bmp2tile) and its set of [compressors](https://github.com/maxim-zhao/bmp2tilecompressors)
5. (Optionally) Flips, to create patch files
6. A copy of the original Phantasy Star ROM

Parts 1 and 3-5 are included in my [SMS Build tools package](https://github.com/maxim-zhao/sms-build-tools/); you are likely to need a recent version as I am using relatively recent WLA DX features.

You may edit the makefile or set environment variables to set the path to the tools necessary, then invoke the makefile. For example, to build in pt-br mode you might invoke
```
make ps1jert.pt-br.sms
```

Giving back
-----------

This source code is open and you are welcome to make re-retranslations from it into any language you like. If you do, you must also publish your source with the same lack of restrictions, and I would prefer to merge your translation into the official source repository so it can benefit from any future enhancements.
