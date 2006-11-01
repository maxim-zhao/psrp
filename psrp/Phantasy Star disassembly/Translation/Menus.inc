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

; Use dashed lines for RIGHT and BOTTOM
.define ©³ base+corner               ; $11f1
.define ©¥ base+hline                ; $11f2
.define ©· base+corner+hflip         ; $13f1
.define ©» base+corner+vflip         ; $15f1
.define ©¿ base+corner+vflip+hflip   ; $17f1
.define ©© base+hline+vflip          ; $15f2
.define ©§ base+vline                ; $11f3
.define ©« base+vline+hflip          ; $13f3

.enum $10c0
sp db ; S-JIS fullwidth space
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
xA db
xB db
xC db
xD db
xE db
xF db
xG db
xH db
xI db
xJ db
xK db
xL db
xM db
xN db
xO db
xP db
xQ db
xR db
xS db
xT db
xU db
xV db
xW db
xX db
xY db
xZ db
xa db
xb db
xc db
xd db
xe db
xf db
xg db
xh db
xi db
xj db
xk db
xl db
xm db
xn db
xo db
xp db
xq db
xr db
xs db
xt db
xu db
xv db
xw db
xx db
xy db ; " modifier
xz db ; circle modifier
fs db
.ende

.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xA xl xi xs ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xf xv xC sp ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xP xB xq xt ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xo xR sp sp ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©» ©© ©© ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xA xl xi xs xa sp ©«
.dw ©§ sp sp sp sp sp sp ©«
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp xf xv xC sp sp ©«
.dw ©§ sp sp sp sp sp sp ©«
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp xP xB xq xt sp ©«
.dw ©§ sp sp sp sp sp sp ©«
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp sp xo xR sp sp ©«
.dw ©§ sp sp sp sp sp sp ©«
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xA xt xt sp ©«
.dw ©§ sp xa xc xk ©«
.dw ©§ xe xL xu xH ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xA xB xS xg ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xZ xU xM sp ©«
.dw ©§ sp xy sp sp ©«
.dw ©§ xV xI xo sp ©«
.dw ©» ©© ©© ©© ©© ©¿
MenuBox20x6:           ; $b5ef
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§
Menu18Blanks:          ; $b619
.dw    sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp ©«
.dw ©§ sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp ©«
.dw ©§ sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp ©«
.dw ©§ sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp sp ©«
.dw ©» ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp sp sp sp ©« 
.dw ©§ xa fs xo sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xm xH xM xP ©«
.dw ©§ xz sp sp sp ©«
.dw ©§ xD xj xm xH ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xb xp xD xn ©«
.dw ©§ xy sp xy sp ©«
.dw ©§ xa xt xT xr ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xy sp sp sp ©«
.dw ©§ xT xa fs xo ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xS xo xo sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xr fs xm sp ©«
.dw ©§ xz sp sp sp ©«
.dw ©§ xZ xC xe sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©« 
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp sp sp sp ©«
.dw ©§ xb xp xD xn ©« 
.dw ©§ sp sp xz sp ©«
.dw ©§ xS xp xZ xM ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ xa xw fs xt ©«
.dw ©§ sp sp sp sp ©« 
.dw ©§ xg xr fs xm ©« 
.dw ©§ sp sp xy sp ©«
.dw ©§ xP xt xT xp ©« 
.dw ©» ©© ©© ©© ©© ©¿ 
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp sp sp sp ©«
.dw ©§ xa fs xo sp ©«
.dw ©§ sp sp sp xz ©«
.dw ©§ xT xo fs xZ ©« 
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xy sp sp sp ©«
.dw ©§ xT xa fs xo ©«
.dw ©§ sp xz sp sp ©«
.dw ©§ xm xb xu xT ©« 
.dw ©§ sp sp sp sp ©« 
.dw ©§ xM xo xT sp ©«
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©« 
.dw ©» ©© ©© ©© ©© ©¿ 
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xy sp sp sp ©« 
.dw ©§ xT xa fs xo ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ xM xo xT sp ©« 
.dw ©§ sp sp xz sp ©«
.dw ©§ xS xp xZ xM ©«
.dw ©§ sp sp sp xy ©«
.dw ©§ xg xE fs xS ©«
.dw ©§ sp sp xy sp ©«
.dw ©§ xn fs xZ xM ©«
.dw ©» ©© ©© ©© ©© ©¿ 
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©» ©© ©© ©© ©© ©© ©© ©© ©© ©¿ 
.dw ©§ sp sp sp sp sp sp sp sp ©« 
.dw ©§ xd xF xY sp xi xQ xi xY ©«
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©· 
.dw ©§ xA xn xK sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xf xv xC sp ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xP xB xq xt ©«
.dw ©§ sp sp sp sp ©«
.dw ©§ xo xR sp sp ©«
.dw ©» ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ xS xt xa sp ©«
.dw ©§ sp xt xu xs ©«
.dw ©§ xM xa xg sp ©«
.dw ©§ sp sp xi xc ©«
.dw ©§ xI xt xe sp ©«
.dw ©§ sp sp xm xs ©«
.dw ©§ xS xe xa sp ©«
.dw ©§ sp xr xc xh ©«
.dw ©§ xS xa xv xe ©«
.dw ©» ©© ©© ©© ©© ©¿ 
.dw ©³ ©¥ ©¥ ©¥ ©·
.dw ©§ xR xF xC ©«
.dw ©§ sp sp xy ©«
.dw ©§ xO xC xa ©«
.dw ©§ sp sp sp ©« 
.dw ©§ xM xS xo ©« 
.dw ©» ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©· 
.dw ©§ xF xB xP xB ©« 
.dw ©§ sp sp sp sp ©«
.dw ©§ xC xn xP xB ©« 
.dw ©» ©© ©© ©© ©© ©¿ 
.dw ©³ ©¥ ©¥ ©¥ ©·
.dw ©§ xZ xB sp ©« 
.dw ©§ sp sp sp ©« 
.dw ©§ xB xB xD ©«
.dw ©» ©© ©© ©© ©¿ 
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©§ sp sp xy sp sp sp sp sp sp sp ©«
.dw ©§ sp sp sp sp sp sp sp sp sp sp ©«
.dw ©» ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©¿
.dw ©³ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©¥ ©·
.dw ©» ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©© ©¿

