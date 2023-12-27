_NameEntryItems:
.db 12 ; count of following lines
  NameEntryText  8,  1,      "Entrez votre nom"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "àéêèçù 0123456789 .,-!?‘’"
  NameEntryText  3, 17, "Précédent"
  NameEntryText 22, 17,                    "Suivant"
  NameEntryText  3, 19, "Espace"
  NameEntryText 23, 19,                     "Sauver"
  NameEntryText  1,  3, "┌─"
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 9, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 17, 7, "N" ; Next
  NameEntryMask  3, 19, 6, "S" ; Space
  NameEntryMask 23, 19, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19
