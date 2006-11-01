; Menu box lines
; I make use of GB2312 encoding in this file because that's the locale of the system I'm using :P
; Shift-JIS would be more logical but it's too late now.
; You should be able to see it in Japanese in your web browser if you choose the right encoding setting.
; WLA DX is happy to use its component characters as .defines
; Notes:
;   All tiles are set in front of sprites
;   In the .dw statements, a normal ASCII space separates each GB character
;   The GB space is used but is not easily visible if your system understands GB - it's twice the width
;     of a regular space.
;   The modifier characters will appear too high, because they're on the row above the character to
;     which they refer.


;                %----FPVHnnnnnnnnn
.define base     %00001000000000000 ; in front of sprites
.define vflip    %00000010000000000
.define hflip    %00000001000000000

; tiles:
.define cursor $1f0  ; with vline
.define corner $1f1  ; top left
.define hline  $1f2
.define vline  $1f3

; .defines are local to the file they are mentioned in so I don't need to undefine these :)

.define TL base+corner               ; $11f1
.define TT base+hline                ; $11f2
.define TR base+corner+hflip         ; $13f1
.define BL base+corner+vflip         ; $15f1
.define BR base+corner+vflip+hflip   ; $17f1
.define BB base+hline+vflip          ; $15f2
.define LL base+vline                ; $11f3
.define RR base+vline+hflip          ; $13f3

.enum $10c0
¡¡ db ; S-JIS fullwidth space
£° db
£± db
£² db
£³ db
£´ db
£µ db
£¶ db
£· db
£¸ db
£¹ db
¥¡ db
¥¤ db
¥¦ db
¥¨ db
¥ª db
¥« db
¥­ db
¥¯ db
¥± db
¥³ db
¥µ db
¥· db
¥¹ db
¥» db
¥½ db
¥¿ db
¥Á db
¥Ä db
¥Æ db
¥È db
¥Ê db
¥Ë db
¥Ì db
¥Í db
¥Î db
¥Ï db
¥Ò db
¥Õ db
¥Ø db
¥Û db
¥Þ db
¥ß db
¥à db
¥á db
¥â db
¥ä db
¥æ db
¥è db
¥é db
¥ê db
¥ë db
¥ì db
¥í db
¥ï db
¥ò db
¥ó db
¥Ã db
¥ã db
¥å db
¥ç db
©a db ; " modifier
©b db ; circle modifier
£­ db
.ende

; $b40b
.dw TL TT TT TT TT TR
.dw LL ¥¡ ¥ê ¥µ ¡¡ RR
.dw BL BB BB BB BB BR

; b42f
.dw TL TT TT TT TT TR
.dw LL ¥ß ¥ã ¥¦ ¡¡ RR
.dw BL BB BB BB BB BR

; b453
.dw TL TT TT TT TT TR
.dw LL ¥¿ ¥¤ ¥í ¥ó RR
.dw BL BB BB BB BB BR

; b477
.dw TL TT TT TT TT TR
.dw LL ¥ë ¥Ä ¡¡ ¡¡ RR
.dw BL BB BB BB BB BR

MenuBox8Bottom:        ; b49b
.dw BL BB BB BB BB BB BB BR

MenuBox8Top:           ; b4ab
.dw TL TT TT TT TT TT TT TR
.dw LL ¡¡ ¥¡ ¥ê ¥µ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR

; b4db
.dw TL TT TT TT TT TT TT TR
.dw LL ¡¡ ¥ß ¥ã ¥¦ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR

; b50b
.dw TL TT TT TT TT TT TT TR
.dw LL ¡¡ ¥¿ ¥¤ ¥í ¥ó ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR

; b53b
.dw TL TT TT TT TT TT TT TR
.dw LL ¡¡ ¡¡ ¥ë ¥Ä ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR

MenuCombat:            ; b56b
.dw TL TT TT TT TT TR
.dw LL ¥¿ ¥¿ ¥« ¥¦ RR  ; Attack
.dw LL ¡¡ ©a ¡¡ ¡¡ RR
.dw LL ¥Þ ¥· ¥Ã ¥¯ RR  ; Magic
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¡ ¥¤ ¥Æ ¥à RR  ; Item
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Ï ¥Ê ¥¹ ¡¡ RR  ; Talk
.dw LL ¡¡ ©a ¡¡ ¡¡ RR
.dw LL ¥Ë ¥± ¥ë ¡¡ RR  ; Run
.dw BL BB BB BB BB BR

MenuBox20x6:           ; $b5ef
.dw TL TT TT TT TT TT TT TT TT TT TT TT TT TT TT TT TT TT TT TR
.dw LL
Menu18Blanks:          ; $b619
.dw    ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw BL BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BR

; b6df
.dw TL TT TT TT TT TR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Ò £­ ¥ë ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥é ¥¯ ¥¹ ¥¿ RR
.dw LL ©b ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Ø ¥ä ¥é ¥¯ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Õ ¥ì ¥¨ ¥ê RR
.dw LL ©a ¡¡ ©a ¡¡ RR
.dw LL ¥Ò ¥ó ¥È ¥ï RR
.dw BL BB BB BB BB BR

; b76f
.dw TL TT TT TT TT TR
.dw LL ©a ¡¡ ¡¡ ¡¡ RR
.dw LL ¥È ¥Ò £­ ¥ë RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Æ ¥ë ¥ë ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥ï £­ ¥é ¡¡ RR
.dw LL ©b ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Ï ¥¦ ¥Þ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw BL BB BB BB BB BR

; b7ff
.dw TL TT TT TT TT TR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Õ ¥ì ¥¨ ¥ê RR
.dw LL ¡¡ ¡¡ ©b ¡¡ RR
.dw LL ¥Æ ¥ì ¥Ï ¥¹ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Ò ¥å £­ ¥ó RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥à ¥ï £­ ¥é RR
.dw LL ¡¡ ¡¡ ©a ¡¡ RR
.dw LL ¥¿ ¥ó ¥È ¥ì RR
.dw BL BB BB BB BB BR

; b88f
.dw TL TT TT TT TT TR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥Ò £­ ¥ë ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ©b RR
.dw LL ¥È ¥ë £­ ¥Ï RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw BL BB BB BB BB BR

; b91f
.dw TL TT TT TT TT TR
.dw LL ©a ¡¡ ¡¡ ¡¡ RR
.dw LL ¥È ¥Ò £­ ¥ë RR
.dw LL ¡¡ ©b ¡¡ ¡¡ RR
.dw LL ¥é ¥Õ ¥Ã ¥È RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¹ ¥ë ¥È ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw BL BB BB BB BB BR

; b9af
.dw TL TT TT TT TT TR
.dw LL ©a ¡¡ ¡¡ ¡¡ RR
.dw LL ¥È ¥Ò £­ ¥ë RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¹ ¥ë ¥È ¡¡ RR
.dw LL ¡¡ ¡¡ ©b ¡¡ RR
.dw LL ¥Æ ¥ì ¥Ï ¥¹ RR
.dw LL ¡¡ ¡¡ ¡¡ ©a RR
.dw LL ¥à ¥ª £­ ¥Æ RR
.dw LL ¡¡ ¡¡ ©a ¡¡ RR
.dw LL ¥ê £­ ¥Ï ¥¹ RR
.dw BL BB BB BB BB BR

; ba3f
.dw TL TT TT TT TT TR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw BL BB BB BB BB BR

Menu10Top:             ; bacf
.dw TL TT TT TT TT TT TT TT TT TR

Menu10Bottom:          ; bae3
.dw BL BB BB BB BB BB BB BB BB BR

; baf7
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR

; bb08
.dw LL ¥Û ¥« ¥Î ¡¡ ¥â ¥Á ¥â ¥Î RR

; bb1f
.dw TL TT TT TT TT TR
.dw LL ¥¡ ¥ê ¥µ ¡¡ RR  ;
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥ß ¥ã ¥¦ ¡¡ RR  ;
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¿ ¥¤ ¥í ¥ó RR  ;
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥ë ¥Ä ¡¡ ¡¡ RR  ;
.dw BL BB BB BB BB BR

; bb8b
.dw TL TT TT TT TT TR
.dw LL ¥Ä ¥è ¥µ ¡¡ RR  ; Strength
.dw LL ¡¡ ©a ¡¡ ¡¡ RR
.dw LL ¥Þ ¥· ¥Ã ¥¯ RR  ; Magic
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¡ ¥¤ ¥Æ ¥à RR  ; Item
.dw LL ¡¡ ¡¡ ©a ¡¡ RR
.dw LL ¥· ¥é ¥Ø ¥ë RR  ; Search
.dw LL ¡¡ ¡¡ ©a ¡¡ RR
.dw LL ¥» £­ ¥Õ ¡¡ RR  ; Save
.dw BL BB BB BB BB BR

MenuUseEquipDiscard:   ; $bc0f
.dw TL TT TT TT TR
.dw LL ¥Ä ¥« ¥¦ RR     ; Use
.dw LL ¡¡ ¡¡ ©a RR
.dw LL ¥½ ¥¦ ¥Ò RR     ; Equip
.dw LL ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¹ ¥Æ ¥ë RR     ; Discard
.dw BL BB BB BB BR

MenuBuySell:           ; $bc55
.dw TL TT TT TT TT TR
.dw LL ¥« ¥¤ ¥¿ ¥¤ RR  ; Buy
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¦ ¥ê ¥¿ ¥¤ RR  ; Sell
.dw BL BB BB BB BB BR

MenuYesNo:             ; $bc91
.dw TL TT TT TT TR
.dw LL ¥Ï ¥¤ ¡¡ RR     ; Yes
.dw LL ¡¡ ¡¡ ¡¡ RR
.dw LL ¥¤ ¥¤ ¥¨ RR     ; No
.dw BL BB BB BB BR

; bcc3
.dw TL TT TT TT TT TT TT TT TT TT TT TR
.dw LL ¡¡ ¡¡ ©a ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw LL ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ ¡¡ RR
.dw BL BB BB BB BB BB BB BB BB BB BB BR

; bd23
.dw TL TT TT TT TT TT TT TT TT TT TT TT TT TT TT TR

; bd43
.dw BL BB BB BB BB BB BB BB BB BB BB BB BB BB BB BR

; bd63
