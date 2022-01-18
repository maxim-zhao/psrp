Adding translations
===================

The codebase is designed to make it relatively easy to add translations. There are a few places where you need to add or edit files or text, and a small amount of code.

new_graphics/font*.xx.png
-------------------------

Where xx = the language code. These files define the fonts used in the game - two selectable fonts for the main game, and the credits font. The ["Polaris" font is by DamienG](https://damieng.com/typography/zx-origins/polaris) and made specifically for this translation. The AW2664 is based on the fonts used in later Mega Drive Phantasy Star games.

There are precisely 70 8x8 tiles available for text (letters, numbers, punctuation and space), and four for the menu borders. If your language needs more - for example, accented characters - then it is tricky to find space. It is possible to use the same tile for some very similar characters - for example, l and 1, and 0 and O. With some redesigning of the font, it is possible to make more characters reusable by flipping. See the pt-br font images (and comments in `tilemap.pt-br.tbl`) for an example of that.

tilemap.xx.tbl
--------------

This maps characters to the tileset. Each value is two hex bytes which correspond to the Master System VDP tilemap format. In here you specify things like tile flipping to get more characters out of the available tiles.

Any characters used in your menus.yaml file have to be specified in here. You can map accented characters to the same values as unaccented characters as necessary.

script.xx.tbl
-------------

This is a "table file" defining how the UTF-8 characters in the script map to unique characters in the script data. The script compression algorithm also maps entire words to many of the unused byte values.

Any characters used in your script.yaml file have to be specified in here. You can map accented characters to the same values as unaccented characters as necessary.

script.yaml
-----------

This is the main script. It is in YAML form, and includes every language at the same time. This means you can look at the Japanese text, literal translation, English localisation, and other translations for each script element at the same time. Some entries have comments to explain why things are the way they are. This file contains UTF-8 text and you should use all characters for your language in the text - let script.xx.tbl handle any removal of accents.

menus.yaml
----------

This contains the menus used in the game. The box drawing characters are important, and if you increase the size of any menu then it is important to manage the RAM caches - see below.

ps1jert.sms.asm
---------------

This is where most of the code goes. There are some important parts. You will need to implement them all. Each section is surrounded by a condition based on the LANGUAGE variable; search for this to find all the parts.

- Table loading: add variants to load the table files for your language.
- Articles handling: this is where we map some of the script elements to words which differ based on the noun they go with. For example, in English is determines whether an inventory item goes with "the", "a", "an", "some". In French it is used for possessive (de) and directive (à) forms for different nouns.
- Items and names: these are the inventory items, characters and enemies. These include markers to determine the correct articles for each.
- Stats window: these strings are localised here.
- Save game name entry: these similarly define the text shown on the name entry screen.
- Credits: there is a space to enter your translation credits.
- Font lookup: here we must map the tilemap characters to the script indices. In other words, it holds the characters in exactly the numerical order they appear in script.xx.tbl, in order to be mapped by tilemap.xx.tbl.
- Options menu: We have words in the options menu to describe some of the option states.

new_graphics/titlescreen.xx.png
-------------------------------

This is just the localised part of the title screen. You should look at titlescreen.psd (and add a layer) to see how this works. You should leave this to the end as it can be very costly in terms of ROM space.

makefile
--------

The script is compressed in two ways: first by assigning bytes to entire words, favouring those that are used a lot; and second by Huffman compressing the byte sequences using a series of Huffman trees. The words that get assigned bytes are selected based on both their length and frequency of use. The number of words chosen affects both the total ROM space and the size of certain parts of the data, and it can be a tricky trade-off to make.

In order to maximise the space available for the script overall, potentially at the cost of a larger ROM overall (or more difficulty to fit other changes), the maximum word count of 148 should be used. However, this adds more complexity to the Huffman trees and enlarges the dictionary. In order to maximise the space available for the ROM in general - for example to allow a more detailed title screen - then only trial and error can help you find the best value. Iterating over all values is possible to determine the best value.

The word count is assigned to a value in the makefile, or can be set in the make parameters.

Resizing menus
--------------

Many of the menus have been sized to it the text that goes in them. For example, item names and spell names both determine the size of menus and windows they appear in. If you want to make them narrower, that is fine; you will also save some ROM space. If you want to make them wider, that is more tricky because of the way the game manages the "window cache" when drawing menus and windows over things on the screen. The allocation is automated but based on some assumptions that may not hold if you resize things more than expected.

Look at the "Window RAM cache" comments in ps1jert.sms.asm for an overview of how this works.

Adding script "articles"
------------------------

The "articles" (by which I mean those words that are linked to the noun they go with in a sentence, like item and enemy names) available to you are stored in the script as indices for the article handling assembly code to use at runtime. You can specify one by index using the code <use article xx> where xx is a hexadecimal number. However, it is nice to define "words" for these values too. These are added to script.xx.tbl and then also to `parse_tag()` in tools.py. Then you need to add appropriate handlers to ps1jert.sms.asm. It helps to build a table of noun types x word types, for example:

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


Building
--------

To build, you need:

1. GNU Make
2. Python 3
3. [WLA DX](https://github.com/vhelin/wla-dx) - a version newer than 3 Dec 2020
4. [BMP2Tile](https://github.com/maxim-zhao/bmp2tile) and its set of [compressors](https://github.com/maxim-zhao/bmp2tilecompressors)
5. (Optionally) Flips, to create patch files
6. A copy of the original Phantasy Star ROM

Parts 1 and 3-5 are included in my [SMS Build tools package](https://github.com/maxim-zhao/sms-build-tools/) from version 1.0.102 onwards.

You may edit the makefile or set environment variables to set the path to the tools necessary, then invoke the builder from #1. For example, to build in pt-br mode you might invoke
```
make LANGUAGE=pt-br ps1jert.sms
```

Giving back
-----------

This source code is open and you are welcome to make re-retranslations from it into any language you like. If you do, you must also publish your source with the same lack of restrictions, and I would prefer to merge your translation into the official source repository so it can benefit from any future enhancements.