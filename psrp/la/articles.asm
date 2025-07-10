; TODO

      ld de,ArticlesLower
      cp $01      ; article = a,an,the
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      ; a = $02 = article = A,An,The
      jp _Start_Art

; Order is:
; - Indefinite (starting with consonant)
; - Indefinite (starting with vowel)
; - Definite
ArticlesLower:        .dw _a, _an, _the
ArticlesInitialUpper: .dw _A, _An, _The
_a:   Article " a"
_an:  Article " na"
_the: Article " eht"
_A:   Article " A"
_An:  Article " nA"
_The: Article " ehT"
