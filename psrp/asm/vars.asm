;
; Global variables
;
; Written in TASM 3.0.1
;

#define DICT      $7d8d		; dictionary lookup code
#define DICT_2    $7d8d+$8	; dictionary lookup code (words)
#define DECODER   $bed0		; huffman decoder
#define CACHE     $7ed0		; substring lookup

#define ITEMS	  $aba6+$0000	; table entry points
#define NAMES	  $aba6+$0391 ; see list_creater\log.txt
#define ENEMY	  $aba6+$03a7

#define WORDS	  $bc00

#define TREE_PTR  $80b0		; index to tree pointer table

; ---------------------------------------------------------

#define STR       $DFB0		; pointer to WRAM string
#define LEN       $DFB2		; length of substring in WRAM
#define TEMP_STR  $DFC0 + $08	; dictionary RAM ($DFC0-DFEF)
#define FULL_STR  $DFC0

#define POST_LEN  $DFB3		; post-string hint (ex. <Herb>...)
#define LINE_NUM  $DFB4		; # of lines drawn
#define FLAG 	  $DFB5		; auto-wait flag
#define ARTICLE   $DFB6		; article category #
#define SUFFIX    $DFB7		; suffix flag

#define LETTER_S  $37		; suffix letter ('s')

#define NEWLINE   $54		; carraige-return
#define EOS       $56		; end-of-string

; ---------------------------------------------------------

; $DFB8

#define HLIMIT    $DFB9		; horizontal chars left
#define VLIMIT    $DFBA		; vertical line limit
#define SCRIPT    $DFBB		; pointer to script
#define BANK      $DFBD		; bank holding script
#define BARREL    $DFBE		; current Huffman encoding barrel
#define TREE      $DFBF		; current Huffman tree
