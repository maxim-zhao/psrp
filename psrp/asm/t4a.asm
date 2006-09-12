;
; Semi-adaptive Huffman decoder
; - Shining Force Gaiden: Final Conflict
;
; Written in TASM 3.0.1
;

; Start of decoder
;
; Note:
; The Z80 uses one set of registers for decoding the Huffman input data
; The other context is used to traverse the Huffman tree itself
;
; Encoded Huffman data is in page 2
;
; Huffman tree data is in page 2
; The symbols for the tree are stored in backwards linear order


#include "vars.asm"

#define TREE_BANK $02		; bank containing Huffman trees ($8000-$BFFF)


.org $7ed0			; $bed0-bf4f

	; PUSH BC		; Save stack
	; PUSH DE
	PUSH HL

	LD A,($FFFE)		; Save current page 1
	PUSH AF

	LD A,$6f000/$4000	; Load in script bank #2
	LD ($FFFE),A

	LD HL,(SCRIPT)		; Set Huffman data location
	LD A,(BARREL)		; Load Huffman barrel

	EX AF,AF'		; Context switch to tree mode
	EXX
	LD A,(TREE)		; Load in tree / last symbol

	; PUSH HL
	; LD HL,$FFFF		; Page in Huffman tree data
	; LD (HL),TREE_BANK
	; POP HL

	PUSH AF
	LD BC,TREE_PTR		; Set physical address of tree data
	LD H,$00		; 8 -> 16
	LD L,A
	ADD HL,HL		; 2-byte indices
	ADD HL,BC		; add offset

	LD A,(HL)		; grab final offset
	INC HL
	LD H,(HL)
	LD L,A
	POP AF

	LD A,$80		; Initialise the tree barrel data
	LD D,H			; Point to symbol data
	LD E,L
	DEC DE			; Symbol data starts one behind the tree

	JR Tree_Shift1		; Grab first bit

Tree_Mode1:
	EX AF,AF'		; Context switch to tree mode
	EXX

Tree_Shift1:
	ADD A,A			; Shift out next tree bit to carry flag
	JR NZ,Check_Tree1	; Check for empty tree barrel

	LD A,(HL)		; Shift out next tree bit to carry flag
	INC HL			; Bump tree pointer

	ADC A,A			; Note: We actually shift in a '1' by doing this!
				;       Clever trick to use all 8 bits for tree codes

Check_Tree1:
	JR C,Decode_Done	; 0 -> tree node = continue looking
				; 1 -> root node = symbol found

	EX AF,AF'		; Switch to Huffman data processing = full context switch
	EXX

	ADD A,A			; Read in Huffman bit
	JR NZ,Check_Huffman1	; Check Huffman barrel status

	LD A,(HL)		; Reload 8-bit Huffman barrel
	INC HL			; Bump Huffman data pointer
	ADC A,A			; Re-grab bit

Check_Huffman1:
	JR NC,Tree_Mode1	; 0 -> travel left, 1 -> travel right

	EX AF,AF'		; Switch back to tree mode
	EXX

	LD C,$01		; Start counting how many symbols to skip in the linear
				; list since we are traversing the right sub-tree

Tree_Shift2:
	ADD A,A			; Check if tree data needs refreshing
	JR NZ,Check_Tree2

	LD A,(HL)		; Refresh tree barrel again
	INC HL			; Bump tree pointer
	ADC A,A			; Grab new tree bit

Check_Tree2:
	JR C,Bump_Symbol	; 0 -> tree, 1 -> symbol

	INC C			; Need to bypass one more node
	JR Tree_Shift2		; Keep bypassing symbols

Bump_Symbol:
	DEC DE			; Bump pointer in symbol list backwards
	DEC C			; One less node/symbol to skip

	JR NZ,Tree_Shift2	; Check for full exhaustion of left subtree nodes

	JR Tree_Shift1		; Need status of termination

Decode_Done:
	POP AF			; Restore old page 1
	LD ($FFFE),A

	LD A,(DE)		; Find symbol
	LD (TREE),A		; Save decoded byte

	; PUSH HL
	; LD HL,$FFFF		; Page in old page 2
	; LD (HL),OLD_BANK
	; POP HL

	EX AF,AF'		; Go to Huffman mode
	EXX
	LD (SCRIPT),HL		; Save script pointer
	LD (BARREL),A		; Save Huffman barrel

	EX AF,AF'		; Go to Tree mode
	; EXX

	POP HL			; Restore stack and exit
	; POP DE
	; POP BC
	RET

	.end			; TASM-only
