CreditsScreen1:
.db 1
  CreditsEntry 11,10,"MITWIRKENDE"

CreditsScreen2:
.db 3
  CreditsEntry 4,5,"KOMPLETTE"
  CreditsEntry 8,7,"PLANUNG"
  CreditsEntry 17,6,"OSSALE KOHTA"
  ; We don't have real names in the German credits...

CreditsScreen3:
.db 2
  CreditsEntry 6,15,"HANDLUNG"
  CreditsEntry 17,15,"APRIL FOOL"

CreditsScreen4:
.db 2
  CreditsEntry 6,6,"SZENARIO"
  CreditsEntry 17,6,"OSSALE KOHTA"

CreditsScreen5:
.db 5
  CreditsEntry 1,6,"KOORDINATIONS-" ; overwrites edge a bit, not safe area?
  CreditsEntry 17,6,"ASSISTENZ"
  CreditsEntry 11,11, "FINOS PATA"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"

; Pitfall to green

CreditsScreen6:
.db 3
  CreditsEntry 3,5,"KOMPLETTES"
  CreditsEntry 8,7,"DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"

CreditsScreen7:
.db 3
  CreditsEntry 5,14,"MONSTER-"
  CreditsEntry 5,16,"DESIGN"
  CreditsEntry 17,15,"CHAOTIC KAZ"
  
CreditsScreen8:
.db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"

CreditsScreen9:
.db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"

; Stairs to blue

CreditsScreen10:
.db 2
  CreditsEntry 11,6,"TON"
  CreditsEntry 18,6,"BO"

; Pitfall to green

CreditsScreen11:
.db 2
  CreditsEntry 5,15,"TESTER"
  CreditsEntry 18,15,"WORKS NISHI"

CreditsScreen12:
.db 5
  CreditsEntry 3,5,"PROGRAMMIER-"
  CreditsEntry 4,7,"ASSISTENZ"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
  
CreditsScreen13:
.db 3
  CreditsEntry 4,5,"HAUPT-"
  CreditsEntry 2,7,"PROGRAMMIERER"
  CreditsEntry 17,6,"MUUUU YUJI"

; Stairs to blue

CreditsScreen14:
.db 3
  CreditsEntry 3,14,"PRASENTIERT"
  CreditsEntry 11,16,"VON"
  CreditsEntry 18,15,"SEGA"
  
; New credits here

CreditsScreen15:
.db 2
  CreditsEntry 12,9,   "¨"
  CreditsEntry 9,10,"NEUUBERSETZUNG"

CreditsScreen16:
.db 6
  CreditsEntry 3,5,"ENGLISCHE"
  CreditsEntry 4,6,   "¨"
  CreditsEntry 1,7,"NEUUBERSETZUNG"
  CreditsEntry 18,6, "PAUL JENSEN"
  CreditsEntry 13,10, "SATSU"
  CreditsEntry 18,15, "POPFAN"

CreditsScreen17:
.db 4
  CreditsEntry 3,5,"DEUTSCHE"
  CreditsEntry 4,6,"¨"
  CreditsEntry 4,7,"UBERSETZUNG"
  CreditsEntry 17,6,"POPFAN"

CreditsScreen18:
.db 3
  CreditsEntry 13,10, "CODE"
  CreditsEntry 4,15, "Z80 GAIDEN"
  CreditsEntry 18,15, "MAXIM"

CreditsScreen19:
.db 4
  CreditsEntry 3,14,"PRASENTIERT"
  CreditsEntry 11,16,"VON"
  CreditsEntry 18,15, "SMS Power! (top)"
  CreditsEntry 18,16, "SMS Power! (bottom)"
