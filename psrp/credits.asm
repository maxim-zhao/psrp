; Changed credits -------------------------
; Point to maybe relocated data
  PatchB $70b4 :CreditsData
  PatchW $70ba CreditsData-4
; Code treats values >64 as
.slot 2
.section "Credits" superfree
CreditsData:
.dw CreditsScreen1, CreditsScreen2, CreditsScreen3, CreditsScreen4, CreditsScreen5, CreditsScreen6, CreditsScreen7, CreditsScreen8, CreditsScreen9, CreditsScreen10, CreditsScreen11, CreditsScreen12, CreditsScreen13, CreditsScreen14

.stringmaptable credits "credits.tbl"

.macro CreditsEntry args x, y, text
.dw $d000 + ((y * 32) + x) * 2
.db _credits_\@_end - _credits_\@
_credits_\@:
.stringmap credits text
_credits_\@_end:
.endm

.if LANGUAGE == "en" || LANGUAGE == "literal"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 13,10,"STAFF"
CreditsScreen2: .db 5
  CreditsEntry 5,5,"TOTAL"
  CreditsEntry 6,7,"PLANNING"
  CreditsEntry 17,5,"OSSALE KOHTA"
  CreditsEntry 17,6,"(KOTARO"
  CreditsEntry 20,7,   "HAYASHIDA)"
CreditsScreen3: .db 7
  CreditsEntry 6,6,"STORY BY"
  CreditsEntry 17,6,"APRIL FOOL"
  CreditsEntry 6,14,"SCENARIO"
  CreditsEntry 7,16,"WRITER"
  CreditsEntry 17,14,"OSSALE KOHTA"
  CreditsEntry 17,15,"(KOTARO"
  CreditsEntry 20,16,   "HAYASHIDA)"
CreditsScreen4: .db 8
  CreditsEntry 4,5,"ASSISTANT"
  CreditsEntry 3,7,"COORDINATORS"
  CreditsEntry 18,6,"FINOS PATA"
  CreditsEntry 10,10,"OTEGAMI CHIE"
  CreditsEntry 10,11,"(CHIEKO AOKI)"
  CreditsEntry 18,14, "GAMER MIKI"
  CreditsEntry 17,15,"(MIKI"
  CreditsEntry 21,16,    "MORIMOTO)"
CreditsScreen5: .db 9
  CreditsEntry 3,6,"TOTAL DESIGN"
  CreditsEntry 18,5, "PHOENIX RIE"
  CreditsEntry 17,6,"(RIEKO"
  CreditsEntry 23,7,      "KODAMA)"
  CreditsEntry 5,14,"MONSTER"
  CreditsEntry 5,16,"DESIGN"
  CreditsEntry 17,14,"CHAOTIC KAZ"
  CreditsEntry 17,15,"(KAZUYUKI"
  CreditsEntry 22,16,     "SHIBATA)"
CreditsScreen6: .db 7
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 9,11,"(NAOTO"
  CreditsEntry 15,12,     "OHSHIMA)"
  CreditsEntry 17,14,"SADAMORIAN"
  CreditsEntry 17,15,"(KOKI"
  CreditsEntry 21,16,    "SADAMORI)"
CreditsScreen7: .db 8
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 11,10, "MYAU CHOKO"
  CreditsEntry 9,11,"(TAKAKO"
  CreditsEntry 13,12,   "KAWAGUCHI)"
  CreditsEntry 8,15,"G CHIE"
  CreditsEntry 18,14, "YONESAN"
  CreditsEntry 17,15,"(HITOSHI"
  CreditsEntry 23,16,      "YONEDA)"
CreditsScreen8: .db 8
  CreditsEntry 9,6,"SOUND"
  CreditsEntry 18,5, "BO"
  CreditsEntry 17,6,"(TOKUHIKO"
  CreditsEntry 24,7,       "UWABO)"
  CreditsEntry 4,15,"SOFT CHECK"
  CreditsEntry 18,14, "WORKS NISHI"
  CreditsEntry 17,15,"(AKINORI"
  CreditsEntry 20,16,   "NISHIYAMA)"
CreditsScreen9: .db 7
  CreditsEntry 3,5,"ASSISTANT"
  CreditsEntry 4,7,"PROGRAMMERS"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,14,  "M WAKA"
  CreditsEntry 2,15,"(MASAHIRO"
  CreditsEntry 6,16,    "WAKAYAMA)"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 3
  CreditsEntry 2,6,"MAIN PROGRAM"
  CreditsEntry 17,5,"MUUUU YUJI"
  CreditsEntry 17,7,"(YUJI NAKA)"
CreditsScreen11: .db 1
  CreditsEntry 9,10,"RETRANSLATION"
CreditsScreen12: .db 4
  CreditsEntry 3,6,"TRANSLATION"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 13,10,"SATSU"
  CreditsEntry 18,15,"POPFAN"
CreditsScreen13: .db 5
  CreditsEntry 2,6,"LOCALISATION"
  CreditsEntry 17,6,"FRANK CIFALDI"
  CreditsEntry 13,10,"CODE"
  CreditsEntry 4,15,"Z80 GAIDEN"
  CreditsEntry 18,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "fr"
CreditsScreen1: .db 2 ; entry count
  CreditsEntry 13,9, "/"
  CreditsEntry 13,10,"EQUIPE"
CreditsScreen2: .db 5
  CreditsEntry 3,5,"GESTION DE"
  CreditsEntry 6,7,"PLANNING"
  CreditsEntry 17,5,"OSSALE KOHTA"
  CreditsEntry 17,6,"(KOTARO"
  CreditsEntry 20,7,   "HAYASHIDA)"
CreditsScreen3: .db 7
  CreditsEntry 2,6,"HISTOIRE PAR"
  CreditsEntry 17,6,"APRIL FOOL"
  CreditsEntry 6,14,  "/"
  CreditsEntry 4,15,"SCENARISTES"
  CreditsEntry 17,14,"OSSALE KOHTA"
  CreditsEntry 17,15,"(KOTARO"
  CreditsEntry 20,16,   "HAYASHIDA)"
CreditsScreen4: .db 8
  CreditsEntry 4,5,"ASSISTANTS"
  CreditsEntry 2,7,"COORDINATEURS"
  CreditsEntry 18,6,"FINOS PATA"
  CreditsEntry 10,10,"OTEGAMI CHIE"
  CreditsEntry 10,11,"(CHIEKO AOKI)"
  CreditsEntry 18,14, "GAMER MIKI"
  CreditsEntry 17,15,"(MIKI"
  CreditsEntry 21,16,    "MORIMOTO)"
CreditsScreen5: .db 9
  CreditsEntry 2,6,"DESIGN GLOBAL"
  CreditsEntry 18,5, "PHOENIX RIE"
  CreditsEntry 17,6,"(RIEKO"
  CreditsEntry 23,7,      "KODAMA)"
  CreditsEntry 4,14,"DESIGN DES"
  CreditsEntry 5,16,"MONSTRES"
  CreditsEntry 17,14,"CHAOTIC KAZ"
  CreditsEntry 17,15,"(KAZUYUKI"
  CreditsEntry 22,16,     "SHIBATA)"
CreditsScreen6: .db 7
  CreditsEntry 4,6,"DESIGNEURS"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 9,11,"(NAOTO"
  CreditsEntry 15,12,     "OHSHIMA)"
  CreditsEntry 17,14,"SADAMORIAN"
  CreditsEntry 17,15,"(KOKI"
  CreditsEntry 21,16,    "SADAMORI)"
CreditsScreen7: .db 8
  CreditsEntry 4,6,"DESIGNEURS"
  CreditsEntry 11,10, "MYAU CHOKO"
  CreditsEntry 9,11,"(TAKAKO"
  CreditsEntry 13,12,   "KAWAGUCHI)"
  CreditsEntry 8,15,"G CHIE"
  CreditsEntry 18,14, "YONESAN"
  CreditsEntry 17,15,"(HITOSHI"
  CreditsEntry 23,16,      "YONEDA)"
CreditsScreen8: .db 9
  CreditsEntry 9,6,"AUDIO"
  CreditsEntry 18,5, "BO"
  CreditsEntry 17,6,"(TOKUHIKO"
  CreditsEntry 24,7,       "UWABO)"
  CreditsEntry 6,15, "/"
  CreditsEntry 5,15,"DEBOGAGE"
  CreditsEntry 18,14, "WORKS NISHI"
  CreditsEntry 17,15,"(AKINORI"
  CreditsEntry 20,16,   "NISHIYAMA)"
CreditsScreen9: .db 7
  CreditsEntry 3,5,"ASSISTANTS"
  CreditsEntry 3,7,"PROGRAMMEURS"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,14,  "M WAKA"
  CreditsEntry 2,15,"(MASAHIRO"
  CreditsEntry 6,16,    "WAKAYAMA)"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 4
  CreditsEntry 3,5,"PROGRAMMEUR"
  CreditsEntry 5,7,  "PRINCIPAL"
  CreditsEntry 17,5,"MUUUU YUJI"
  CreditsEntry 17,7,"(YUJI NAKA)"
CreditsScreen11: .db 1
  CreditsEntry 10,10,"RETRADUCTION"
CreditsScreen12: .db 10
  CreditsEntry 12,2,"ANGLAIS"
  CreditsEntry 3,6,"PAUL JENSEN"
  CreditsEntry 17,5,"SATSU"
  CreditsEntry 22,7,"POPFAN"
  CreditsEntry 12,10,"FRANCAIS"
  CreditsEntry 16,11,    "'"
  CreditsEntry 2,15,"ICHIGOBANKAI"
  CreditsEntry 17,14,"WIL76"
  CreditsEntry 24,16,"ELZ"
  CreditsEntry 11,19,"VINGAZOLE"
CreditsScreen13: .db 3
  CreditsEntry 13,10,"CODE"
  CreditsEntry 4,15,"Z80 GAIDEN"
  CreditsEntry 18,15,"MAXIM"
CreditsScreen14: .db 4
  CreditsEntry 12,9,   "/    /"
  CreditsEntry 10,10,"PRESENTE PAR"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "pt-br"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 13,10,"EQUIPE"
CreditsScreen2: .db 3
  CreditsEntry 3,5,"PLANEJAMENTO"
  CreditsEntry 6,7,"TOTAL"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 5
  CreditsEntry 6,6,"CENARISTA"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 11,14,   "/"
  CreditsEntry 7,15,"HISTORIA"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 6
  CreditsEntry 4,6,"AUXILIAR DE"
  CreditsEntry 26,5,         "~"
  CreditsEntry 17,6,"COORDENACAO"
  CreditsEntry 25,7,        "'"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 5
  CreditsEntry 3,6,"DESIGN TOTAL"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"DESIGN DE"
  CreditsEntry 7,16,"MONSTRO"
  CreditsEntry 17,15,"CHAOTIC KAZ"
CreditsScreen6: .db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"
CreditsScreen7: .db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"
CreditsScreen8: .db 4
  CreditsEntry 11,6,"SOM"
  CreditsEntry 18,6,"BO"
  CreditsEntry 9,15,"TESTE"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 7
  CreditsEntry 4,6,"AUXILIAR DE"
  CreditsEntry 26,5,         "~"
  CreditsEntry 17,6,"PROGRAMACAO"
  CreditsEntry 25,7,        "'"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 3
  CreditsEntry 6,5,"PROGRAMA"
  CreditsEntry 5,7,"PRINCIPAL"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 3
  CreditsEntry 19,9,         "~"
  CreditsEntry 11,10,"RETRADUCAO"
  CreditsEntry 18,11,       "'"
CreditsScreen12: .db 9
  CreditsEntry 7,5,    "^"
  CreditsEntry 3,6,"INGLES"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 10,14,      "^"
  CreditsEntry 3,15,"PORTUGUES"
  CreditsEntry 3,16,"DO BRASIL"
  CreditsEntry 18,15,"AJKMETIUK"
CreditsScreen13: .db 4
  CreditsEntry 7,5, "/"
  CreditsEntry 6,6,"CODIGO"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 4
  CreditsEntry 11,10,"APRESENTADO"
  CreditsEntry 14,11,"PELA"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "ca"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 13,10,"STAFF"
CreditsScreen2: .db 3
  CreditsEntry 5,5,"TOTAL"
  CreditsEntry 6,7,"PLANNING"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 5
  CreditsEntry 6,5,"SCENARIO"
  CreditsEntry 7,7,"WRITER"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 9,15,"STORY"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 4
  CreditsEntry 4,5,"ASSISTANT"
  CreditsEntry 3,7,"COORDINATORS"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 5
  CreditsEntry 3,6,"TOTAL DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"MONSTER"
  CreditsEntry 7,16,"DESIGN"
  CreditsEntry 17,15,"CHAOTIC KAZ"
CreditsScreen6: .db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"
CreditsScreen7: .db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"
CreditsScreen8: .db 4
  CreditsEntry 9,6,"SOUND"
  CreditsEntry 18,6,"BO"
  CreditsEntry 4,15,"SOFT CHECK"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 5
  CreditsEntry 3,5,"ASSISTANT"
  CreditsEntry 4,7,"PROGRAMMERS"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 2
  CreditsEntry 2,6,"MAIN PROGRAM"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 1
  CreditsEntry 10,10,"RETRADUCTION"
CreditsScreen12: .db 8
  CreditsEntry 7,5,    "/"
  CreditsEntry 3,6,"ANGLES"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 8,14,     "`"
  CreditsEntry 3,15,"CATALA"
  CreditsEntry 18,15,"KUSFO"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "es"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 13,10,"STAFF"
CreditsScreen2: .db 3
  CreditsEntry 5,5,"TOTAL"
  CreditsEntry 6,7,"PLANNING"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 5
  CreditsEntry 6,5,"SCENARIO"
  CreditsEntry 7,7,"WRITER"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 9,15,"STORY"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 4
  CreditsEntry 4,5,"ASSISTANT"
  CreditsEntry 3,7,"COORDINATORS"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 5
  CreditsEntry 3,6,"TOTAL DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"MONSTER"
  CreditsEntry 7,16,"DESIGN"
  CreditsEntry 17,15,"CHAOTIC KAZ"
CreditsScreen6: .db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"
CreditsScreen7: .db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"
CreditsScreen8: .db 4
  CreditsEntry 9,6,"SOUND"
  CreditsEntry 18,6,"BO"
  CreditsEntry 4,15,"SOFT CHECK"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 5
  CreditsEntry 3,5,"ASSISTANT"
  CreditsEntry 4,7,"PROGRAMMERS"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 2
  CreditsEntry 2,6,"MAIN PROGRAM"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 1
  CreditsEntry 10,10,"RETRADUCTION"
CreditsScreen12: .db 8
  CreditsEntry 7,5,    "/"
  CreditsEntry 3,6,"INGLES"
  CreditsEntry 18,6,"PAUL JENSEN"
  CreditsEntry 10,10,"FRANK CIFALDI"
  CreditsEntry 25,10,"SATSU"
  CreditsEntry 8,14,     "`"
  CreditsEntry 3,15,"CASTELLANO"
  CreditsEntry 18,15,"KUSFO"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 3
  CreditsEntry 10,10,"PRESENTED BY"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.if LANGUAGE == "de"
CreditsScreen1: .db 1 ; entry count
  CreditsEntry 10,10,"MITWIRKENDE"
CreditsScreen2: .db 3
  CreditsEntry 4,5,"KOMPLETTE"
  CreditsEntry 8,7,"PLANUNG"
  CreditsEntry 17,6,"OSSALE KOHTA"
CreditsScreen3: .db 4
  CreditsEntry 4,6,"SZENARIO"
  CreditsEntry 17,6,"OSSALE KOHTA"
  CreditsEntry 4,15,"HANDLUNG"
  CreditsEntry 17,15,"APRIL FOOL"
CreditsScreen4: .db 4
  CreditsEntry 1,5,"KOORDINATIONS-"
  CreditsEntry 6,7,"ASSISTENZ"
  CreditsEntry 10,11,"OTEGAMI CHIE"
  CreditsEntry 18,15,"GAMER MIKI"
CreditsScreen5: .db 6
  CreditsEntry 3,5,"KOMPLETTES"
  CreditsEntry 8,7,"DESIGN"
  CreditsEntry 18,6,"PHOENIX RIE"
  CreditsEntry 5,14,"MONSTER-"
  CreditsEntry 7,16,"DESIGN"
  CreditsEntry 17,15,"CHAOTIC KAZ"
CreditsScreen6: .db 3
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"ROCKHY NAO"
  CreditsEntry 17,15,"SADAMORIAN"
CreditsScreen7: .db 4
  CreditsEntry 8,6,"DESIGN"
  CreditsEntry 9,10,"MYAU CHOKO"
  CreditsEntry 17,15,"G CHIE"
  CreditsEntry 9,19,"YONESAN"
CreditsScreen8: .db 7
  CreditsEntry 10,6,"TON"
  CreditsEntry 18,6,"BO"
  CreditsEntry 4,14,"SOFTWARE-"
  CreditsEntry 3,15,"¨"
  CreditsEntry 9,15,      "¨"
  CreditsEntry 3,16,"UBERPRUFUNG"
  CreditsEntry 18,15,"WORKS NISHI"
CreditsScreen9: .db 5
  CreditsEntry 3,5,"PROGRAMMIER-"
  CreditsEntry 4,7,"ASSISTENZ"
  CreditsEntry 9,10,"COM BLUE"
  CreditsEntry 4,15,"M WAKA"
  CreditsEntry 19,15,"ASI"
CreditsScreen10: .db 3
  CreditsEntry 4,5,"HAUPT-"
  CreditsEntry 2,7,"PROGRAMMIERER"
  CreditsEntry 17,6,"MUUUU YUJI"
CreditsScreen11: .db 6
  CreditsEntry 2,5,"ENGLISCHE"
  CreditsEntry 4,6,   "¨"
  CreditsEntry 1,7,"NEUUBERSETZUNG"
  CreditsEntry 10,10,"PAUL JENSEN"
  CreditsEntry 2,15,"FRANK CIFALDI"
  CreditsEntry 21,15,"SATSU"
CreditsScreen12: .db 4
  CreditsEntry 2,5,"DEUTSCHE"
  CreditsEntry 4,6,"¨"
  CreditsEntry 4,7,"UBERSETZUNG"
  CreditsEntry 19,6,"POPFAN"
CreditsScreen13: .db 3
  CreditsEntry 6,6,"CODE"
  CreditsEntry 11,10,"Z80 GAIDEN"
  CreditsEntry 9,15,"MAXIM"
CreditsScreen14: .db 5
  CreditsEntry 12,9,   "¨"
  CreditsEntry 10,10,"PRASENTIERT"
  CreditsEntry 14,12,"VON"
  CreditsEntry 10,15,"SEGA"
  CreditsEntry 18,15,"SMS POWER!"
.endif
.ends

  ROMPosition $488a
.section "Credits hack" overwrite ; not movable
  ld (hl),:CreditsFont
  ld hl,$5820 ; VRAM address
  ld de,CreditsFont
  call LoadTiles
.ends

.slot 2
.section "Credits font" superfree
CreditsFont:
.incbin "generated/font-credits.psgcompr"
.ends
