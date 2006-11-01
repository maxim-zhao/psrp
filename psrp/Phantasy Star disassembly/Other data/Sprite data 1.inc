; Sprite data 1
; Table of structures, followed by structures themselves, for various sprites
; giving their y, x and tile numbers
; for use when updating the sprite table in RAM and then VRAM

.dw _980c,_980c,_981f,_9832,_9845,_9852,_9883,_9890
.dw _989d,_98b3,_98c6,_98cd,_98da,_98f3,_9909,_9910
.dw _9917,_991b,_9925,_992c,_9939,_9952,_9965,_9972
.dw _9976,_997a,_9981,_998e,_999b,_99a2,_99a6,_99aa
.dw _99ae,_99b2,_99b9,_99c6,_99df,_99ec,_99f3,_99f7
.dw _99fe,_9a05,_9a0c,_9a19,_9a2f,_9a3f,_9a52,_9a5c
.dw _9a60,_9a64,_9a68,_9a6f,_9a7c,_9a95,_9aae,_9abb
.dw _9abf,_9ac6,_9d5c,_9da2,_9de8,_9e3d,_9e80,_9ec3
.dw _9f06,_9f55,_9fc8,_a011,_a054,_a097,_a0e0,_9c9b
.dw _9ca2,_9ca9,_9cb0,_9cba,_9ccd,_9cda,_9ce1,_9ce1
.dw _a13b,_a199,_a1fd,_a26d,_a2d7,_a34d,_a3b7,_a41e
.dw _a49d,_a58f,_a53a,_a60b,_a681,_a6f7,_a788,_9aca
.dw _9ad7,_9aea,_9b03,_9b13,_9b20,_9b33,_9b4c,_9b62
.dw _9b7b,_9b8e,_9ba7,_9bb4,_9bc1,_9bc8,_9bdb,_9bf1
.dw _9bf8,_9c0b,_9c15,_9c22,_9c2f,_9c3f,_9c4c,_9c5f
.dw _9c78,_9c8e,_9cee,_9cf5,_9cfc,_9d09,_9d1c,_9d3b
.dw _9d48,_9d4f,_a816,_a874,_a8d2,_a8e2,_a8f2,_a8e2
.dw _a902,_a912,_a922,_a912
_980c:
.db 6 ; count
.db  -9    , -9    , -1    , -1    ,  7    ,  7     ; y positions
.db   0,$AA,  8,$AB,  0,$AC,  8,$AD,  0,$AE,  8,$AF ; x positions/tile numbers
_981f:
.db 6 ; count
.db  -9    , -9    , -1    , -1    ,  7    ,  7     ; y positions
.db   0,$B0,  8,$B1,  0,$B2,  8,$B3,  0,$B4,  8,$B5 ; x positions/tile numbers
_9832:
.db 6 ; count
.db  -9    , -9    , -1    , -1    ,  7    ,  7     ; y positions
.db   0,$B6,  8,$B7,  0,$B8,  8,$B9,  0,$BA,  8,$BB ; x positions/tile numbers
_9845:
.db 4 ; count
.db  -1    , -1    ,  7    ,  7     ; y positions
.db   0,$BC,  8,$BD,  0,$BE,  8,$BF ; x positions/tile numbers
_9852:
.db 16 ; count
.db -17    ,-17    ,-17    ,-17    , -9    , -9    , -9    , -9    , -1    , -1    , -1    , -1    ,  7    ,  7    ,  7    ,  7     ; y positions
.db -16,$AA, -8,$AB,  0,$AC,  8,$AD,-16,$AE, -8,$AF,  0,$B0,  8,$B1,-16,$B2, -8,$B3,  0,$B4,  8,$B5,-16,$B6, -8,$B7,  0,$B8,  8,$B9 ; x positions/tile numbers
_9883:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  20,$A0, 15,$A1, 11,$A2,  7,$A3 ; x positions/tile numbers
_9890:
.db 4 ; count
.db  -4    , -4    ,  4    ,  4     ; y positions
.db   0,$A4,  8,$A5, -1,$A6,  7,$A7 ; x positions/tile numbers
_989d:
.db 7 ; count
.db  -4    , -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   0,$A8,  8,$A9,  1,$AA, -5,$AB, -8,$AC,-12,$AD,-16,$A0 ; x positions/tile numbers
_98b3:
.db 6 ; count
.db  -4    , -4    ,  4    , 20    , 28    , 36     ; y positions
.db   0,$AE, 13,$AF,  3,$B0, -8,$B1,-12,$B2,-16,$B3 ; x positions/tile numbers
_98c6:
.db 2 ; count
.db  96    ,104     ; y positions
.db  45,$A0, 45,$A1 ; x positions/tile numbers
_98cd:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers
_98da:
.db 8 ; count
.db  72    , 72    , 80    , 80    , 88    , 88    , 96    , 96     ; y positions
.db  35,$A6, 43,$A7, 36,$A8, 44,$A9, 39,$AA, 47,$AB, 42,$AC, 50,$AD ; x positions/tile numbers
_98f3:
.db 7 ; count
.db  40    , 48    , 48    , 56    , 56    , 64    , 64     ; y positions
.db  21,$AE, 23,$AF, 31,$A7, 26,$B0, 34,$B1, 29,$B2, 37,$B3 ; x positions/tile numbers
_9909:
.db 2 ; count
.db  24    , 32     ; y positions
.db  14,$B4, 16,$B5 ; x positions/tile numbers
_9910:
.db 2 ; count
.db   8    , 16     ; y positions
.db   8,$B6, 10,$B7 ; x positions/tile numbers
_9917:
.db 1 ; count
.db   8     ; y positions
.db   5,$B8 ; x positions/tile numbers
_991b:
.db 3 ; count
.db   0    ,  8    ,  8     ; y positions
.db   4,$B9,  2,$BA, 10,$BB ; x positions/tile numbers
_9925:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers
_992c:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers
_9939:
.db 8 ; count
.db  56    , 64    , 72    , 80    , 80    , 88    , 88    , 96     ; y positions
.db  26,$A6, 30,$A7, 32,$A8, 35,$A9, 43,$AA, 38,$AB, 46,$AC, 44,$AD ; x positions/tile numbers
_9952:
.db 6 ; count
.db  24    , 32    , 40    , 40    , 48    , 56     ; y positions
.db  13,$AE, 17,$AF, 19,$B0, 27,$B1, 22,$B2, 27,$B3 ; x positions/tile numbers
_9965:
.db 4 ; count
.db   0    ,  8    , 16    , 24     ; y positions
.db   6,$B4,  7,$B5, 10,$B6, 16,$B7 ; x positions/tile numbers
_9972:
.db 1 ; count
.db   0     ; y positions
.db   2,$B8 ; x positions/tile numbers
_9976:
.db 1 ; count
.db   0     ; y positions
.db   0,$B9 ; x positions/tile numbers
_997a:
.db 2 ; count
.db  96    ,104     ; y positions
.db  45,$A0, 46,$A1 ; x positions/tile numbers
_9981:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 42,$A4, 50,$A5 ; x positions/tile numbers
_998e:
.db 4 ; count
.db  72    , 72    , 80    , 80     ; y positions
.db  34,$A6, 42,$A7, 36,$A8, 44,$A9 ; x positions/tile numbers
_999b:
.db 2 ; count
.db  40    , 40     ; y positions
.db  19,$AA, 27,$AB ; x positions/tile numbers
_99a2:
.db 1 ; count
.db  16     ; y positions
.db  10,$AC ; x positions/tile numbers
_99a6:
.db 1 ; count
.db   0     ; y positions
.db   5,$AD ; x positions/tile numbers
_99aa:
.db 1 ; count
.db   0     ; y positions
.db   2,$AE ; x positions/tile numbers
_99ae:
.db 1 ; count
.db   0     ; y positions
.db   0,$AF ; x positions/tile numbers
_99b2:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers
_99b9:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers
_99c6:
.db 8 ; count
.db  56    , 56    , 64    , 64    , 72    , 80    , 80    , 88     ; y positions
.db  24,$A6, 32,$A7, 25,$A8, 33,$A9, 32,$AA, 35,$AB, 43,$AC, 41,$AD ; x positions/tile numbers
_99df:
.db 4 ; count
.db  24    , 24    , 32    , 40     ; y positions
.db  13,$AE, 22,$AF, 16,$B0, 19,$B1 ; x positions/tile numbers
_99ec:
.db 2 ; count
.db   8    , 16     ; y positions
.db   7,$B2, 12,$B3 ; x positions/tile numbers
_99f3:
.db 1 ; count
.db   0     ; y positions
.db   2,$B4 ; x positions/tile numbers
_99f7:
.db 2 ; count
.db   0    ,  0     ; y positions
.db   0,$B5,  8,$B6 ; x positions/tile numbers
_99fe:
.db 2 ; count
.db   0    ,  8     ; y positions
.db   2,$B7,  0,$B8 ; x positions/tile numbers
_9a05:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers
_9a0c:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers
_9a19:
.db 7 ; count
.db  56    , 64    , 72    , 80    , 88    , 96    , 96     ; y positions
.db  34,$A6, 40,$A7, 41,$A8, 40,$A9, 40,$AA, 41,$AB, 49,$AC ; x positions/tile numbers
_9a2f:
.db 5 ; count
.db  24    , 32    , 40    , 48    , 56     ; y positions
.db  32,$AD, 32,$AE, 32,$AF, 33,$B0, 34,$B1 ; x positions/tile numbers
_9a3f:
.db 6 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 24     ; y positions
.db  16,$B2, 24,$B3, 16,$B4, 24,$B5, 27,$B6, 32,$B7 ; x positions/tile numbers
_9a52:
.db 3 ; count
.db   0    ,  0    ,  8     ; y positions
.db   3,$B8, 11,$B9,  8,$BA ; x positions/tile numbers
_9a5c:
.db 1 ; count
.db   0     ; y positions
.db   2,$BB ; x positions/tile numbers
_9a60:
.db 1 ; count
.db   0     ; y positions
.db   0,$BC ; x positions/tile numbers
_9a64:
.db 1 ; count
.db   0     ; y positions
.db   0,$BD ; x positions/tile numbers
_9a68:
.db 2 ; count
.db  96    ,104     ; y positions
.db  44,$A0, 44,$A1 ; x positions/tile numbers
_9a6f:
.db 4 ; count
.db  96    , 96    ,104    ,104     ; y positions
.db  40,$A2, 48,$A3, 40,$A4, 48,$A5 ; x positions/tile numbers
_9a7c:
.db 8 ; count
.db  64    , 64    , 72    , 72    , 80    , 80    , 88    , 88     ; y positions
.db  29,$A6, 37,$A7, 29,$A8, 37,$A9, 31,$AA, 39,$AB, 32,$AC, 40,$AD ; x positions/tile numbers
_9a95:
.db 8 ; count
.db  32    , 32    , 40    , 40    , 48    , 48    , 56    , 56     ; y positions
.db  17,$AE, 25,$AF, 19,$B0, 27,$B1, 21,$B2, 29,$B3, 23,$B4, 31,$B5 ; x positions/tile numbers
_9aae:
.db 4 ; count
.db   8    , 16    , 16    , 24     ; y positions
.db   9,$B6,  9,$B7, 17,$B8, 13,$B9 ; x positions/tile numbers
_9abb:
.db 1 ; count
.db   0     ; y positions
.db   6,$BA ; x positions/tile numbers
_9abf:
.db 2 ; count
.db   0    ,  0     ; y positions
.db   0,$BB,  8,$BC ; x positions/tile numbers
_9ac6:
.db 1 ; count
.db   0     ; y positions
.db   4,$BD ; x positions/tile numbers
_9aca:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  18,$A0, 14,$A1, 10,$A1,  6,$A1 ; x positions/tile numbers
_9ad7:
.db 6 ; count
.db -20    ,-12    , -4    , -4    ,  4    ,  4     ; y positions
.db  12,$A2,  7,$A3, -4,$A4,  4,$A5, -2,$A6,  6,$A7 ; x positions/tile numbers
_9aea:
.db 8 ; count
.db  -4    , -4    ,  4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   1,$A8,  9,$A9, -5,$AA,  3,$AB, -6,$A1,-10,$A1,-14,$A1,-14,$AC ; x positions/tile numbers
_9b03:
.db 5 ; count
.db  -4    ,  4    , 20    , 28    , 36     ; y positions
.db   3,$AD,  0,$AD, -8,$AE,-12,$AF,-16,$B0 ; x positions/tile numbers
_9b13:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  19,$A0, 15,$A1,  9,$A2,  6,$A3 ; x positions/tile numbers
_9b20:
.db 6 ; count
.db -12    , -4    , -4    ,  4    ,  4    , 12     ; y positions
.db   5,$A4, -1,$A5,  7,$A6, -4,$A7,  4,$A8, -5,$A9 ; x positions/tile numbers
_9b33:
.db 8 ; count
.db  -4    , -4    ,  4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db  -3,$AA,  5,$AB,  0,$AC,  8,$AD, -6,$AE, -9,$AF,-13,$A1,-15,$B0 ; x positions/tile numbers
_9b4c:
.db 7 ; count
.db -12    , -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   3,$B1,  3,$B2, -3,$B3,  4,$B1, -9,$B4,-12,$B4,-16,$B5 ; x positions/tile numbers
_9b62:
.db 8 ; count
.db -40    ,-32    ,-32    ,-24    ,-24    ,-16    ,-16    , -8     ; y positions
.db  16,$A0, 12,$A1, 20,$A2,  7,$A3, 15,$A4,  5,$A5, 13,$A6,  7,$A7 ; x positions/tile numbers
_9b7b:
.db 6 ; count
.db -16    , -8    , -8    ,  0    ,  0    ,  8     ; y positions
.db   3,$A8, -1,$A9,  7,$AA, -3,$AB,  5,$AC,  1,$AD ; x positions/tile numbers
_9b8e:
.db 8 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24     ; y positions
.db  -5,$AE,  3,$AF, -8,$B0,  0,$B1,-12,$B2, -4,$B3,-14,$B4, -6,$B5 ; x positions/tile numbers
_9ba7:
.db 4 ; count
.db   8    , 24    , 24    , 32     ; y positions
.db  -6,$B6,-16,$B7, -8,$B8,-16,$B9 ; x positions/tile numbers
_9bb4:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db  18,$A0, 14,$A1, 10,$A1,  8,$A2 ; x positions/tile numbers
_9bc1:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   2,$A3,  0,$A2 ; x positions/tile numbers
_9bc8:
.db 6 ; count
.db  -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   0,$A4,  0,$A5, -6,$A3,-10,$A1,-14,$A1,-16,$A6 ; x positions/tile numbers
_9bdb:
.db 7 ; count
.db -36    ,-28    ,-20    ,-12    , 20    , 28    , 36     ; y positions
.db -16,$A7,-14,$A8,-10,$A8, -6,$A9, -7,$AA,-12,$AB,-16,$AC ; x positions/tile numbers
_9bf1:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   0,$AD,  2,$A9 ; x positions/tile numbers
_9bf8:
.db 6 ; count
.db  -4    ,  4    , 12    , 20    , 28    , 36     ; y positions
.db   0,$AE,  0,$AF,  8,$AD, 10,$A8, 14,$A8, 18,$B0 ; x positions/tile numbers
_9c0b:
.db 3 ; count
.db  20    , 28    , 36     ; y positions
.db  13,$B1, 15,$B2, 18,$B3 ; x positions/tile numbers
_9c15:
.db 4 ; count
.db -36    ,-28    ,-20    ,-12     ; y positions
.db -16,$A0,-12,$A1,-10,$A2, -6,$A2 ; x positions/tile numbers
_9c22:
.db 4 ; count
.db -12    , -4    ,  4    , 12     ; y positions
.db  -4,$A1, -2,$A2,  2,$A2,  6,$A3 ; x positions/tile numbers
_9c2f:
.db 5 ; count
.db  -4    ,  4    , 12    , 20    , 28     ; y positions
.db   0,$A4,  0,$A5,  6,$A2, 10,$A2, 14,$A3 ; x positions/tile numbers
_9c3f:
.db 4 ; count
.db  -4    ,  4    , 28    , 36     ; y positions
.db   3,$A6, -3,$A6, 16,$A7, 20,$A8 ; x positions/tile numbers
_9c4c:
.db 6 ; count
.db -36    ,-28    ,-20    ,-20    ,-12    ,-12     ; y positions
.db -16,$A0,-12,$A1,-10,$A2, -2,$A3, -8,$A4,  0,$A5 ; x positions/tile numbers
_9c5f:
.db 8 ; count
.db -12    ,-12    , -4    , -4    ,  4    ,  4    , 12    , 12     ; y positions
.db  -8,$A4,  0,$A5, -3,$A6,  5,$A7,  0,$A8,  8,$A7,  4,$A9, 12,$AA ; x positions/tile numbers
_9c78:
.db 7 ; count
.db  -4    ,  4    , 12    , 12    , 20    , 20    , 28     ; y positions
.db   0,$AB,  0,$AC,  4,$A9, 12,$AA,  8,$AD, 16,$A3, 14,$AE ; x positions/tile numbers
_9c8e:
.db 4 ; count
.db  -4    ,  4    , 28    , 36     ; y positions
.db   4,$AF, -4,$AF, 14,$B0, 20,$B1 ; x positions/tile numbers
_9c9b:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   2,$A0,  2,$A1 ; x positions/tile numbers
_9ca2:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers
_9ca9:
.db 2 ; count
.db   4    , 12     ; y positions
.db   4,$A4,  3,$A5 ; x positions/tile numbers
_9cb0:
.db 3 ; count
.db  12    , 20    , 28     ; y positions
.db   1,$A6, -1,$A7, -3,$A8 ; x positions/tile numbers
_9cba:
.db 6 ; count
.db  44    , 52    , 60    , 60    , 68    , 68     ; y positions
.db   2,$A9,  1,$AA, -3,$AB,  5,$AC, -3,$AD,  5,$AE ; x positions/tile numbers
_9ccd:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -3,$AF,  5,$B0, -4,$B1,  4,$B2 ; x positions/tile numbers
_9cda:
.db 2 ; count
.db  68    , 76     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers
_9ce1:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -4,$B3,  4,$B4, -4,$B5,  4,$B6 ; x positions/tile numbers
_9cee:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   2,$A0,  2,$A1 ; x positions/tile numbers
_9cf5:
.db 2 ; count
.db  -4    ,  4     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers
_9cfc:
.db 4 ; count
.db  -4    ,  4    ,  4    , 12     ; y positions
.db   2,$A0,  2,$A4, 10,$A5,  3,$A6 ; x positions/tile numbers
_9d09:
.db 6 ; count
.db   4    , 12    , 20    , 28    , 28    , 36     ; y positions
.db  -4,$A7, -4,$A8, -4,$A9, -3,$AA,  5,$AB,  2,$AC ; x positions/tile numbers
_9d1c:
.db 10 ; count
.db  12    , 20    , 20    , 28    , 36    , 44    , 44    , 52    , 60    , 68     ; y positions
.db   3,$AD, -1,$AE,  7,$AF, -2,$B0,  3,$B0, -2,$B1,  6,$B2, -3,$B3,  0,$B4,  0,$A3 ; x positions/tile numbers
_9d3b:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -3,$B5,  5,$B6, -4,$B7,  4,$B8 ; x positions/tile numbers
_9d48:
.db 2 ; count
.db  68    , 76     ; y positions
.db   0,$A2,  0,$A3 ; x positions/tile numbers
_9d4f:
.db 4 ; count
.db  68    , 68    , 76    , 76     ; y positions
.db  -4,$B9,  4,$BA, -4,$BB,  4,$BC ; x positions/tile numbers
_9d5c:
.db 23 ; count
.db  16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  12,$00, 20,$01, 28,$02, 36,$03, 44,$04, 10,$05, 18,$06, 26,$07, 34,$08, 42,$09, 50,$0A, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_9da2:
.db 23 ; count
.db  16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  12,$16, 20,$17, 28,$18, 36,$19, 44,$1A, 11,$1B, 19,$1C, 27,$1D, 35,$1E, 43,$1F, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_9de8:
.db 28 ; count
.db   8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  15,$21, 23,$22, 31,$22, 39,$23, 47,$24, 15,$25, 23,$26, 31,$26, 39,$27, 47,$28, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_9e3d:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_9e80:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$2F, 35,$30, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_9ec3:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$31, 24,$32, 32,$33, 40,$34, 11,$35, 19,$36, 27,$37, 35,$38, 43,$39, 51,$3A, 11,$3B, 19,$3C, 27,$3D, 35,$3E, 43,$3F, 51,$40,  8,$41, 16,$42, 24,$43, 32,$43, 40,$44, 48,$45 ; x positions/tile numbers
_9f06:
.db 26 ; count
.db   8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  24,$46, 32,$47, 40,$48, 16,$49, 24,$4A, 32,$4B, 40,$4C, 48,$4D, 11,$4E, 19,$4F, 27,$50, 35,$51, 43,$52, 51,$53,  8,$54, 16,$55, 24,$56, 32,$57, 40,$58, 48,$59,  8,$5A, 16,$5B, 24,$5C, 32,$5D, 40,$5E, 48,$5F ; x positions/tile numbers
_9f55:
.db 38 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  13,$60, 21,$61, 35,$62, 43,$63,  9,$64, 17,$65, 25,$66, 33,$67, 41,$68, 49,$69,  8,$6A, 16,$6B, 24,$6C, 32,$6D, 40,$6E, 48,$6F,  8,$70, 16,$71, 24,$72, 32,$73, 40,$74, 48,$75,  1,$76,  9,$77, 17,$78, 25,$79, 33,$7A, 41,$7B, 49,$7C, 57,$7D,  0,$7E,  8,$7F, 16,$80, 24,$81, 32,$82, 40,$83, 48,$84, 56,$85 ; x positions/tile numbers
_9fc8:
.db 24 ; count
.db  16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db   8,$86, 16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$87, 27,$88, 35,$1E, 43,$2B, 51,$89, 59,$8A, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_a011:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$8B, 35,$8C, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$13, 32,$13, 40,$14, 48,$15 ; x positions/tile numbers
_a054:
.db 22 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$8D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$8E, 35,$8F, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$90, 32,$91, 40,$14, 48,$15 ; x positions/tile numbers
_a097:
.db 24 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$92, 32,$93, 40,$14, 48,$15, 24,$94, 32,$95 ; x positions/tile numbers
_a0e0:
.db 30 ; count
.db  16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64     ; y positions
.db  16,$2C, 24,$2D, 32,$2D, 40,$2E, 11,$29, 19,$2A, 27,$1D, 35,$1E, 43,$2B, 51,$20, 11,$0B, 19,$0C, 27,$0D, 35,$0E, 43,$0F, 51,$10,  8,$11, 16,$12, 24,$96, 32,$97, 40,$14, 48,$15, 26,$98, 34,$99, 19,$9A, 27,$9B, 35,$9C, 43,$9D, 24,$9E, 32,$9F ; x positions/tile numbers
_a13b:
.db 31 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80     ; y positions
.db  10,$00, 18,$01,  8,$02, 16,$03,  6,$04, 14,$05, 22,$06,  4,$07, 12,$08, 20,$09, 28,$0A,  2,$0B, 10,$0C, 18,$0D, 26,$0E,  0,$0F,  8,$10, 16,$11, 24,$12,  0,$13,  8,$14, 16,$15,  9,$16, 17,$17, 10,$18, 18,$19, 10,$1A, 18,$1B,  4,$1C, 12,$1D, 20,$1E ; x positions/tile numbers
_a199:
.db 33 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   9,$1F, 17,$20,  9,$21, 17,$22,  3,$23, 11,$24, 19,$25, 27,$26,  3,$27, 11,$28, 19,$29, 27,$2A,  5,$2B, 13,$2C, 21,$2D,  6,$2E, 14,$2F, 22,$30,  6,$31, 14,$32, 22,$33,  6,$34, 17,$35, 25,$36,  6,$37, 18,$38,  6,$39, 19,$3A, 27,$3B,  0,$3C,  8,$3D, 16,$3E, 24,$3F ; x positions/tile numbers
_a1fd:
.db 37 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  10,$40, 18,$01,  8,$41, 16,$42,  6,$43, 14,$44, 22,$45,  3,$46, 11,$47, 19,$48, 27,$49,  2,$4A, 10,$4B, 18,$4C, 26,$4D,  0,$4E,  8,$4F, 16,$50,  0,$51,  8,$52, 16,$53, 24,$54,  4,$55, 12,$56, 20,$57,  1,$58,  9,$59, 17,$5A, 25,$5B,  2,$5C, 10,$5D, 18,$5E, 26,$5F,  3,$60, 11,$61, 19,$62, 27,$63 ; x positions/tile numbers
_a26d:
.db 35 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   9,$64, 17,$65,  9,$66, 17,$67,  2,$68, 10,$69, 18,$6A, 26,$6B,  0,$6C,  8,$6D, 16,$6E, 24,$6F,  0,$70,  8,$71, 16,$72, 24,$73,  3,$74, 11,$75, 19,$76, 27,$77,  6,$78, 14,$79, 22,$7A,  5,$7B, 13,$7C, 21,$7D,  4,$7E, 12,$7F, 20,$80,  3,$81, 20,$82,  0,$83,  8,$84, 16,$85, 24,$86 ; x positions/tile numbers
_a2d7:
.db 39 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$00, 19,$01, 27,$02, 10,$03, 18,$04, 26,$05, 34,$06,  8,$07, 16,$08, 24,$09, 32,$0A,  8,$0B, 16,$0C, 24,$0D, 32,$0E,  6,$0F, 14,$10, 22,$11, 30,$12, 38,$13,  6,$14, 14,$15, 22,$16, 30,$17,  8,$18, 16,$19, 24,$1A, 32,$1B, 12,$1C, 20,$1D, 28,$1E, 12,$1F, 27,$20, 11,$21, 28,$22,  8,$23, 16,$24, 24,$25, 32,$26 ; x positions/tile numbers
_a34d:
.db 35 ; count
.db   8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  10,$27, 18,$28,  3,$29, 11,$2A, 19,$2B, 27,$2C,  2,$2D, 10,$2E, 18,$2F, 26,$30,  2,$31, 10,$32, 18,$33, 26,$34,  5,$35, 13,$36, 21,$37,  3,$38, 11,$39, 19,$3A,  2,$3B, 10,$3C, 18,$3D, 26,$3E,  2,$3F, 10,$40, 18,$41, 26,$42,  4,$43, 12,$44, 20,$45,  0,$46,  8,$47, 16,$48, 24,$49 ; x positions/tile numbers
_a3b7:
.db 34 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 64    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  11,$4A, 19,$4B,  8,$4C, 16,$4D,  4,$4E, 12,$4F, 20,$50,  2,$51, 10,$52, 18,$53, 26,$54,  2,$55, 10,$56, 18,$57, 26,$58,  4,$59, 12,$5A, 20,$5B,  4,$5C, 12,$5D, 20,$5E,  5,$5F, 13,$60, 21,$61,  6,$62, 14,$63, 22,$64,  5,$65, 13,$66, 21,$67,  4,$68, 12,$69, 20,$6A, 28,$6B ; x positions/tile numbers
_a41e:
.db 42 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   5,$00, 13,$01, 21,$02,  6,$03, 14,$04, 22,$05,  1,$06,  9,$07, 17,$08, 25,$09,  0,$0A,  8,$0B, 16,$0C, 24,$0D,  0,$0E,  8,$0F, 16,$10, 24,$11,  2,$12, 10,$13, 18,$14, 26,$15,  2,$16, 10,$17, 18,$18, 26,$19,  1,$1A,  9,$1B, 17,$1C, 25,$1D,  1,$1E,  9,$1F, 17,$20, 25,$21,  3,$22, 11,$23, 19,$24, 27,$25,  0,$26,  8,$27, 16,$28, 24,$29 ; x positions/tile numbers
_a49d:
.db 52 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  11,$00, 19,$01, 27,$02, 35,$03, 11,$04, 19,$05, 27,$06, 35,$07, 11,$08, 19,$09, 27,$0A, 35,$07, 10,$0B, 18,$0C, 26,$0D, 34,$0E, 10,$0F, 18,$10, 26,$11, 34,$12,  3,$13, 11,$14, 19,$15, 27,$16, 35,$17, 43,$18,  2,$19, 10,$1A, 18,$1B, 26,$1C, 34,$1D, 42,$1E,  5,$1F, 13,$20, 21,$21, 29,$22, 37,$23,  4,$24, 12,$25, 20,$26, 28,$27, 36,$28,  4,$29, 12,$2A, 20,$2B, 28,$2C, 36,$2D,  4,$2E, 12,$2F, 20,$30, 28,$31, 36,$32 ; x positions/tile numbers
_a53a:
.db 28 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48     ; y positions
.db   9,$00, 17,$01, 25,$02,  4,$03, 12,$04, 20,$05, 28,$06,  4,$07, 12,$08, 20,$09, 28,$0A,  5,$0B, 13,$0C, 21,$0D, 29,$0E,  4,$0F, 12,$10, 20,$11, 28,$12,  4,$13, 12,$14, 20,$15, 28,$16,  2,$17, 10,$18, 18,$19, 26,$1A, 34,$1B ; x positions/tile numbers
_a58f:
.db 41 ; count
.db   0    ,  0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 48    , 48    , 48     ; y positions
.db  16,$1C, 24,$1D, 32,$1E, 40,$1F,  8,$20, 16,$21, 24,$22, 32,$23, 40,$24, 48,$25,  8,$26, 16,$27, 24,$28, 32,$29, 40,$2A, 48,$2B,  1,$2C,  9,$2D, 17,$2E, 25,$2F, 33,$30, 41,$31,  8,$32, 16,$33, 24,$34, 32,$35, 40,$36,  0,$37,  8,$38, 16,$39, 24,$3A, 32,$3B, 40,$3C, 48,$3D,  0,$3E,  8,$3F, 16,$40, 24,$41, 32,$42, 40,$43, 48,$44 ; x positions/tile numbers
_a60b:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db   8,$00, 16,$01,  5,$02, 13,$03, 21,$04,  4,$05, 12,$06, 20,$07, 28,$08,  1,$09,  9,$0A, 17,$0B, 25,$0C,  0,$0D,  8,$0E, 16,$0F, 24,$10,  1,$11,  9,$12, 17,$13, 25,$14,  0,$0D,  8,$0E, 16,$0F, 24,$10,  1,$11,  9,$12, 17,$13, 25,$14,  1,$15,  9,$16, 17,$17, 25,$18,  8,$19, 16,$1A,  0,$1B,  8,$1C, 16,$1D, 24,$1E ; x positions/tile numbers
_a681:
.db 39 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80     ; y positions
.db  10,$00, 18,$01, 10,$02, 18,$03,  5,$04, 13,$05, 21,$06,  0,$07,  8,$08, 16,$09, 24,$0A,  0,$0B,  8,$0C, 16,$0D, 24,$0E,  0,$0F,  8,$10, 16,$11, 24,$12,  0,$13,  8,$14, 16,$15, 24,$16,  0,$17,  8,$18, 16,$19, 24,$1A,  0,$1B,  8,$18, 16,$1C, 24,$1D,  0,$1E,  8,$18, 16,$19, 24,$1F,  0,$20,  8,$21, 16,$22, 24,$23 ; x positions/tile numbers
_a6f7:
.db 48 ; count
.db   0    ,  0    ,  0    ,  8    ,  8    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  14,$00, 22,$01, 30,$02,  1,$03,  9,$04, 17,$05, 25,$06, 33,$07,  1,$08,  9,$09, 17,$0A, 25,$0B, 33,$0C,  0,$0D,  8,$0E, 16,$0F, 24,$10, 32,$11,  0,$12, 10,$13, 18,$14, 26,$15, 34,$16,  1,$17,  9,$18, 17,$19, 25,$1A,  6,$1B, 14,$1C, 22,$1D, 30,$1E,  4,$1F, 12,$20, 23,$21, 31,$22,  2,$23, 10,$24, 23,$25, 31,$26,  2,$27, 10,$28, 24,$29, 32,$2A,  0,$2B,  8,$2C, 16,$2D, 24,$2E, 32,$2F ; x positions/tile numbers
_a788:
.db 47 ; count
.db   0    ,  0    ,  8    ,  8    ,  8    , 16    , 16    , 16    , 16    , 24    , 24    , 24    , 24    , 32    , 32    , 32    , 32    , 40    , 40    , 40    , 40    , 48    , 48    , 48    , 48    , 56    , 56    , 56    , 56    , 56    , 64    , 64    , 64    , 64    , 64    , 72    , 72    , 72    , 72    , 72    , 72    , 80    , 80    , 80    , 80    , 80    , 80     ; y positions
.db  18,$00, 26,$01, 15,$02, 23,$03, 31,$04, 12,$05, 20,$06, 28,$07, 36,$08, 10,$09, 18,$0A, 26,$0B, 34,$0C, 10,$0D, 18,$0E, 26,$0F, 34,$10, 10,$11, 18,$12, 26,$13, 34,$14, 10,$15, 18,$16, 26,$17, 34,$18,  7,$19, 15,$1A, 23,$1B, 31,$1C, 39,$1D,  4,$1E, 12,$1F, 20,$20, 28,$21, 36,$22,  2,$23, 10,$24, 18,$25, 26,$26, 34,$27, 42,$28,  2,$29, 10,$2A, 18,$2B, 26,$2C, 34,$2D, 42,$2E ; x positions/tile numbers
_a816:
.db 31 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    ,  8    , 16    , 24    , 32    , 40     ; y positions
.db   8,$00, 16,$01,  6,$02, 14,$03,  8,$04, 16,$05,  8,$06, 16,$07,  8,$08, 16,$09,  5,$0A, 13,$0B, 21,$0C,  4,$0D, 12,$0E, 20,$0F,  5,$10, 13,$11, 21,$12,  5,$13, 13,$14,  6,$15, 14,$16,  0,$17,  8,$18, 16,$19,  1,$1A,  0,$1B,  0,$1C,  0,$1D,  2,$1E ; x positions/tile numbers
_a874:
.db 31 ; count
.db   0    ,  0    ,  8    ,  8    , 16    , 16    , 24    , 24    , 32    , 32    , 40    , 40    , 40    , 48    , 48    , 48    , 56    , 56    , 56    , 64    , 64    , 72    , 72    , 80    , 80    , 80    ,  8    , 16    , 24    , 32    , 40     ; y positions
.db   8,$00, 16,$01,  6,$02, 14,$03,  8,$04, 16,$05,  8,$06, 16,$07,  8,$08, 16,$09,  5,$0A, 13,$0B, 21,$0C,  4,$0D, 12,$0E, 20,$0F,  5,$10, 13,$11, 21,$12,  5,$13, 13,$14,  6,$15, 14,$16,  0,$17,  8,$18, 16,$19,  2,$2E,  2,$2F,  1,$30,  0,$29,  2,$1E ; x positions/tile numbers
_a8d2:
.db 5 ; count
.db   0    ,  0    ,  0    ,  8    ,  8     ; y positions
.db   0,$00,  8,$01, 16,$02,  8,$03, 16,$04 ; x positions/tile numbers
_a8e2:
.db 5 ; count
.db   0    ,  0    ,  8    ,  8    ,  8     ; y positions
.db   4,$05, 12,$06,  0,$07,  8,$08, 16,$09 ; x positions/tile numbers
_a8f2:
.db 5 ; count
.db   0    ,  0    ,  8    ,  8    ,  8     ; y positions
.db   6,$0A, 14,$0B,  2,$0C, 10,$0D, 18,$0E ; x positions/tile numbers
_a902:
.db 5 ; count
.db   0    ,  8    ,  8    ,  8    , 16     ; y positions
.db  11,$0F,  1,$10,  9,$11, 17,$12,  8,$13 ; x positions/tile numbers
_a912:
.db 5 ; count
.db   0    ,  8    ,  8    ,  8    , 16     ; y positions
.db  11,$0F,  1,$14,  9,$15, 17,$16,  8,$13 ; x positions/tile numbers
_a922:
.db 6 ; count
.db   4    ,  0    ,  0    ,  8    ,  8    , 16     ; y positions
.db  16,$17,  2,$18, 11,$0F,  3,$19, 11,$1A,  8,$13 ; x positions/tile numbers

