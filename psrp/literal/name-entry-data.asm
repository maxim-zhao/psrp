_NameEntryItems:
.db 10
  NameEntryText  8,  1, "Enter your name:"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "0123456789"
  NameEntryText 21, 15,                   ".,:-!?‘’"
  NameEntryText  3, 17, "Back  Next  Space     Save"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
_NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 4, "B" ; X, Y, length, type (Back)
  NameEntryMask  9, 17, 4, "N" ; Next
  NameEntryMask 15, 17, 5, "S" ; Space
  NameEntryMask 25, 17, 4, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 17
