# Phantasy Star English Retranslation v2.3

Phantasy Star is a landmark game for the Sega Master System, first released in Japan on 20th December 1987. 
This project is an unofficial retranslation/relocalisation based on that first Japanese version, with some enhancements.

For more information and screenshots see https://www.smspower.org/Translations/PhantasyStar-SMS-EN

Changelog (in reverse chronological order):
- v2.4 release 2023/12/20
  - Updated and expanded French script with a great deal of extra hints and lore added, tying into later games in the series
  - Amended translation notes to better explain certain spells
  - Some script amendments regarding the words Laconian and Zirconian in most languages
  - Spanish:
    - Typo fixes
  - English:
    - Fixed missing wait for button press when talking to Tajim (en)
    - Renamed Dorougue to Druj. Look it up!
    - Renamed Ant-lion to Antlion
  - French:
    - Fixed sometimes corrupted enemy names in French
    - Added more accented letters
    - Extended save game name entry screen to show "Sauvegarder"
  - Technical work: 
    - Recompressed all sprite art to make more room for script
    - Script it now stored across the entire ROM space, removing the previous 16KB (compressed) limit

- v2.3.2 released 2023/02/12
  - Fixed errors in Catalan and Portuguese Brazilian ending credits

- v2.3.1 released 2023/01/17
  - Fixed graphics error on Dezorian enemies (#101)

- v2.3 released 2022/12/20
  - Phantasy Star 35th anniversary!
  - Added Spanish translation from kusfo
  - Added German translation from Popfan
  - Added literal English translation variant
  - Updates to the Brazilian Portuguese script from ajkmetiuk
  - Much work on converting the original Katakana script to use Hiragana and Kanji where appropriate, and then re-retranslating in a few areas
  - Much work on annotating the script with where each line is used/reused
  - Some shared lines split up to enable better translation
  - Fixed some very old mistranslations
  - Fixed areas of the script that incorrectly make assumptions about which character is alive
  - Quite a lot of work done on the disassembly 
  - When you buy weapons/armor, you can optionally equip it immediately (#50)
  - Changed name entry screen to support a cursor on wider words (#70)
  - Shop drawing now uses a smaller Meseta window (#72) and dynamic-width inventories (#79)
  - Added support for dynamic pronouns in the script (#80)
  - Fixed a bug that could cause blank lines in the script after a prompt (#82)
  - Fixed some "soft lock" situations in the original game (#84)
  - Added an option to speed up scene transitions (palette fades)
  - Added an option to speed up text drawing in the main script window
  - Button 1 more usage is now more consistently a "cancel" or "no" action (#96)
  - Extended the credits sequence so the original credits are now left untouched

<details>
<summary>Click for more history</summary>

- v2.2 released 2021/12/20
  - Phantasy Star 34th anniversary!
  - Fixed a bug with articles for some languages
  - Fixed issue with emulators not supporting cartridge RAM
  - Fixed glitches in enemy name border drawing on some hardware (#63)
  - Fixed some script inconsistencies in English (#61)
  - Added Catalan translation from kusfo
  - Improved the translation tools based on issues found with the Catalan translation
    - More languages are welcome! [Contact me](https://www.smspower.org/Home/Contact) if you want to contribute.
  - Ported the build system to GNU Make
- v2.1 released 2021/01/31
  - added French translation from ichigobankai, Wil76 and Vingazole
  - added Brazilian Portuguese translation from ajkmetiuk
  - fixed some bugs relating to the needs of these translations
  - ported script processing tools to Python
  - widened in-game and narrative script boxes
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
</details>

## What is Phantasy Star

Phantasy Star is a ground-breaking RPG from 1987. It was the first console RPG released in the US; it was one of the first sci-fi-based RPGs, although has a unique mix of fantasy and sci-fi; and it introduced many concepts to the genre.

It was ground-breakingly large - taking place across three planets, with large, colourful, animated monsters. It was one of the first (and only) games to feature a female protagonist with real characterisation and character development, without resorting to videogaming's female stereotypes.

If you want to learn more about the game, check out some of the web links below.

## Contents

The following changes are made to the game engine:

- Narrative formatting
- Window expansion
- Replaced 8x8 font
- Use of adapting word tokens for articles, pronouns, and other grammatical constructs for specific languages
- Reworked name entry screen
- FM/PSG switching
- Extended save slots names, count and interface
- "Quality of life" improvements to reduce grinding

## Instructions

This patch requires that you download a program that can apply it to a properly dumped ROM-image of the game. "Floating IPS" is recommended for Windows.

The original, unmodified game has the following characteristics:

Attribute|Value
---------|----
Size     | 512KB (524,288 bytes)
CRC32    |`6605d36a`
CRC64    |`8c8383b83a0d6ecc`
MD5      |`dfebc48dfe8165202b7f002d8bac477b`
SHA1     |`c9a40ddd217c58dddcd6b5c0fe66c3a50d3e68e4`
SHA256   |`1d8554202f313d97c4f48c6acf9b312853a1aca3c04fab9077743d7943a45ebb`
BLAKE2sp |`9e006166eb172cd5a1c98483128e4d871924a2777da5514cad42cbfe6652d94b`

There is only one known Japanese version of the game. The patch will NOT work with the US/European versions, or any other game on any platform. If you use the BPS patch it will verify that you are using the correct file.

A copier is suggested to obtain your legal backup. Always make sure to have an original backup of your game. And only apply the patch to a clean, unmodified ROM image.

Changes made between version numbers may adversely affect emulator save states. In such event, please use the in-game save feature to gain any new features.

## Credits

### Z80 Gaiden
- Core hacking and programming
### Maxim
- Project manager, final hacking/programming
  - https://www.smspower.org/maxim
### Paul Jensen
- Script translator, editor
### satsu
- Additional translations
### Frank Cifaldi (TheRedEye)
- Localization and script enhancements
  - https://twitter.com/frankcifaldi
  - https://gamehistory.org
### Damien Guard
- Polaris font
  - https://damieng.com
### Popfan
- German translation, Kanji/hiragana/katakana script, literal script improvements
  - https://twitter.com/gensakudan
### kusfo
- Catalan and Spanish translations
  - https://twitter.com/jordimontornes
### ajkmetiuk
- Portuguese Brazilian translation
### ichigobankai, Wil76, Vingazole
- French translation

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
### Calindro
- Emulicious is another excellent debugging emulator (invaluable for the later disassembly work): https://emulicious.net

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

A big thing I wanted to do was deal with the wrapping in menus. The original used two-line menus mainly due to a common hack for katakana-based games - so it can save tiles by putting the diacritics on the row above. The characters "ヒビピ" are somewhat analogous to characters like "eèéêë" in European languages. Placing the modifiers on the row above reduces the number of tiles needed, which is a big deal for Master System games' limited VRAM space. However to swap to single-line menus I'd also need to widen them to make room for the names (many of which were split over two lines in order to fit). This meant dealing with the game's "window RAM buffers", which was a complicated task. I needed to map out every "menu window" that the game ever opens, determine which could be open at the same time, and allocate them all space in memory such that we never use the same space for two things at the same time. This was quite difficult and has a correspondingly large comment in the source explaining it. However, the end result is not only the removal of all unnecessary wrapping, but also a more pleasant experience (I think) as there's less blank black on the screen.

Having sorted all that out, it also meant I could extend the title screen to use menus instead of a black background when leading and saving, and a sound test which is of course a great thing given the game's soundtrack.

As I posted updates online people asked for some "quality of life" improvements - inspired by some of the "official" changes made in the Switch port, to speed up walking, reduce random enemy battles and reduce the amount of grinding for money and experience. This was put inside another menu.

I also got a welcome message from Frank Cifaldi (TheRedEye, also the founder of the Video Game History Foundation) offering to do further script enhancements on top of his script from 2006. This could take advantage of the bigger text boxes to really expand the story. I think you'll find the enhancements really help the story.

I also reached out to DamienG and he came up with an awesome new font. Note that the "AW2284" font is a tweaked version of the font from Phantasy Star IV's English release, with the numbers from Phantasy Star III, as used in the earlier releases of this translation.

### Maxim (2022)

In the last few years we've continued to add more languages and thus more language grammar features to the code. Many thanks to the people helping with the translation work and their patience to explain the grammatical issues to me so I can implement the functionality needed to make first-class translations.

In the interests of better portability, buildability and understandability, all of the utility programs that were ported from C to C++ were further ported to Python. This was mostly in the interests of making these utilities (performing tasks like encoding the script) a little bit more understandable, but also removing the need for a C++ compiler to build the project from scratch.

I spent a chunk of time to merge the ancient disassembly work I did in the early 2000s into a modern Emulicious disassembly. It's still far from complete but it was a big step forward in terms of understanding more of the code and how the script is used, to allow us to make sure the script lines flow properly and even extend it so lines shared between multiple places in Japanese can diverge to suit the characters. We even took the opportunity to add a few hints into the script regarding some lesser-known uses of objects.

We have also had a great amount of work from Popfan to "re-retranslate" the raw Katakana script into Katakana/Hiragaga/Kanji, and offer corrections for some of the original translation work from 2001-2002. His questions about the script were a great motivator on my side to understand all the usages.

We still have plans for things to do for version 3.0, and new translations are still welcome. I'd love to have dozens of languages covered for this one game!

### Popfan (2022)

I owe a lot to Phantasy Star. It's the reason I started learning Japanese in the first place, and I've made many a friendship and/or unforgettable memory with the game (or the series at a whole). You could probably also imagine my surprise when I found out that this retranslation, which I'd first tried out about 14 years ago, is still being worked on to this day. My own eventual involvement with the project happened mostly by pure chance, but I was happy for the opportunity to give back to it.

Starting with the German translation, which I'd had an itching to do for nearly as long as I've been aware of the retranslation itself. It took a while to get myself acclimated to the work environment, but it was immensely rewarding seeing it all come together little by little, and Maxim was a wonderful person to work with, able to implement just about any code-related change I requested, whether it be for supporting German grammar or just the odd quality-of-life or visual presentation touch-up I could think of.

As I was working my way through the script, though, I was also fixing mistakes in the literal English translation of the Japanese script, as well as using the full range of the Japanese writing system to make a proper transcription of the katakana-only in-game text. I myself could read it just fine, but I figured it'd help with any ambiguity there may have been. This, in turn, led to Maxim getting the idea to have literal English as its own language with its own patch, putting me in charge of that, too.

My personal philosophy as a (non-professional) translator is to keep as close to the source text as possible while also making sure that the translation reads like something a native speaker would actually say. This is especially prevalent with the German translation, though I still used the retranslation as a base wherever I thought a little extra fluff would be appropriate. The literal translation, on the other hand, might inadvertently sound a little more stilted, but I also thought I'd throw long-time fans of the series a bone by translating certain spell names after the equivalents of how they've been translated in Phantasy Star IV.

By the way, one of the things planned for the future is a complete overhaul of the manual, along with translations into all the other languages. This was supposed to be done in time for the v2.3 release, but unfortunately the deadline crept up on us a little too fast.

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
FINOS PATA
OTEGAMI CHIE (Chieko Aoki)
GAMER MIKI (Miki Morimoto)

TOTAL DESIGN
PHOEHIX RIE (Rieko Kodama)

MONSTER DESIGN
CHAOTIC KAZ (Kazuyuki Shibata)

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

## Contact

PLEASE get in touch if you find a bug or you think you can help correct a
mistake.

You can post on the SMS Power! forums:

http://www.smspower.org/forums/

or raise issues at

https://github.com/maxim-zhao/psrp/issues
