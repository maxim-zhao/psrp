Adding translations
===================

The codebase is designed to make it relatively easy to add translations. There are a few places where you need to add or edit files or text, and a small amount of code.

new_graphics/font*.xx.png
-------------------------

Where xx = the language code. These files define the fonts used in the game. The main files are Polaris font, the "a" variants are the AW2284 font. font3 is the end credits font. 

There are precisely 70 8x8 tiles available for text (letters, numbers, punctuation and space), and four for the menu borders. If your language needs more - for example, accented characters - then it is tricky to find space. Some ideas:

- b, d and p, q may use the same tile with horizontal mirroring
- 0 and O may use the same tile
- 1 and l may use the same tile
- Punctuation like ¿ is just a flipped version of ?
- With substantial font changes, you may be able to increase the amount of tile reuse, for example for M/W, b/f/p/q, S/5.

However it is likely you won't have enough space for everything.

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

In order to maximise the space available for the script overall, potentially at the cost of a larger ROM overall (or more difficulty to fit other changes), the maximum word count of 164 should be used. However, this adds more complexity to the Huffman trees and enlarges the dictionary. In order to maximise the space available for the ROM in general - for example to allow a more detailed title screen - then only trial and error can help you find the best value. Iterating over all values is possible to determine the best value.

The word count is assigned to a value in the makefile, or can be set in the nmake parameters.

Resizing menus
--------------

Many of the menus have been sized to it the text that goes in them. For example, item names and spell names both determine the size of menus and windows they appear in. If you want to make them narrower, that is fine; you will also save some ROM space. If you want to make them wider, that is more tricky because of the way the game manages the "window cache" when drawing menus and windows over things on the screen.

Look at the "Window RAM cache" comments in ps1jert.sms.asm for an overview of how this works.

Adding script keywords
----------------------

The "articles" (by which I mean those words that are linked to the noun they go with in a sentence, like item and enemy names) available to you are stored in the script as indices for the article handling assembly code to use at runtime. You can specify one by index using the code <use article xx> where xx is a hexadecimal number. However, it is nice to define "words" for these values too. See script_inserter\symbols.cpp, function ProcessCode() to see how these are defined for English and French (`<article>`, `<Article>`, `<de>`, `<à>`) and maybe add more.
