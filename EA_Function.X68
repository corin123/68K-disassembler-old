*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

*--------HOW TO USE THE FUNCTION----------------------
*EA_MODE should be in bits 2-0 [0000000000000XXX]
*EA_REGISTER should be in bits 15-13 [XXX00000000000]
*-----------------------------------------------------
*Never move byte, only move word or long
*Ex.      ADDA #2, A5
         *MOVE.W/L A5,D3
    ORG    $1000
START:                 

        *DIVS.W D2, D7
        MOVE.W #%1000111111001111, D3
        
            *clear all data before bit 6 to 0
            LSL #8, D3
            LSL #2, D3

            *move the Mode & Reg to bit [0-5] to rotate
            LSR #8, D3
            LSR #2, D3
            
            *rotate the register bits to bit [15 -12]
            ROR #3 ,D3
            
            *Only call if the value of mode is valid for that opcode
            JSR SET_EA

            *To get the second parameter

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here
* Register must be in bits [15-12] Mode must be in bits [2-0]
SET_EA           
            *Dn
            CMPI.B #$0, D3           *Compares if its 000
                
                BEQ DATA_REGISTER
                
            CMPI.B #1, D3
                BEQ ADDRESS_MODE
                
            *(An)
            CMPI.B #$2, D3            *Compares if its 010
                BEQ CLOSED_PARAN
                
            *(An)+
            CMPI.B #$3, D3            *Compares if its 011
                BEQ POSTFIX_PLUS
                
            *-(An)                  *Compares if its 100
            CMPI.B #$4, D3
                BEQ PREFIX_MINUS
                
            *(xxx).W, (xxx).L, #<data>
            CMPI.B #$7, D3            *Compares if its 111
               BEQ FILTER_EA_MODE
               BNE INVALID_EA
    RTS
    
 

    
FILTER_EA_MODE

        *Rotate to get register as byte
        LSR.W #8, D3
        LSR.W #5, D3
        
        
        *(xxx).W
        CMPI.B #$0, D3
            BEQ WORD_MODE
            
        *(xxx).L
        CMPI.B #$1, D3
            BEQ LONG_MODE
            
        *# <data>
        CMPI.B #$4, D3
            BEQ DATA_MODE
            BNE INVALID_MODE
    RTS


INVALID_EA
*Display error accordingly
    RTS

INVALID_MODE
    RTS

*An

ADDRESS_MODE
*Get register to get what Dn to go to
    LSR.W #8, D3
    LSR.W #5, D3 
    JSR PRINT_INNER_An
    RTS
*#<data>
DATA_MODE

    *Print '#'
    LEA imm_sign, A1
    MOVE.B #14, D0
    TRAP #15
    
    *Determin what Data register (Dn) To output
    MOVE.B #11, D4
    MOVE.B #31,-(A1)
    MOVE.B #13,-(A1)
    MOVE.B D4, -(A1)
    
    MOVE.B (A1)+, D0
    MOVE.B (A1)+, D1
    MOVE.B (A1)+, D2
    MOVE.B (A1)+, D3
    RTS
   
* Dn
DATA_REGISTER
    *Get register to get what Dn to go to
    LSR.W #8, D3
    LSR.W #5, D3 
    
    CMPI.W #0, D3
        BEQ PRINT_D0
    CMPI.W #1, D3
        BEQ PRINT_D1
    CMPI.W #2, D3
        BEQ PRINT_D2
    CMPI.W #3, D3
        BEQ PRINT_D3
    CMPI.W #4, D3
        BEQ PRINT_D4
    CMPI.W #5, D3
        BEQ PRINT_D5
    CMPI.W #6, D3
        BEQ PRINT_D6
    CMPI.W #7, D3
        BEQ PRINT_D7
    RTS
    
* (An)
CLOSED_PARAN
    
    *Get register to get what Dn to go to
    LSR.W #8, D3
    LSR.W #5, D3
    
    *Prints '('
    LEA open_paren, A1
    MOVE.B #14, D0
    TRAP #15
    
    *Print The appropriate value of An *Needed to use JSR & RTS
    JSR PRINT_INNER_An
   
    *Prints ')'
    LEA closed_paren, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
    
 *Prints the An in (An) and returns to the original method   
PRINT_INNER_An
    CMPI  #0, D3
        BEQ    PRINT_A0
    CMPI #1, D3
        BEQ PRINT_A1
    CMPI #2, D3
        BEQ PRINT_A2
    CMPI #3, D3
        BEQ PRINT_A3
    CMPI #4, D3
        BEQ PRINT_A4
    CMPI #5, D3
        BEQ PRINT_A5
    CMPI #6, D3
        BEQ PRINT_A6
    CMPI #7, D3
        BEQ PRINT_A7


* (An)+
POSTFIX_PLUS

    LSR.W #8, D3
    LSR.W #5, D3
    
    *Prints '('
    LEA open_paren, A1
    MOVE.B #14, D0
    TRAP #15

    
    *Print The appropriate value of An *Needed to use JSR & RTS
    JSR PRINT_INNER_An
    
    *Prints ')'
    LEA closed_paren, A1
    MOVE.B #14, D0
    TRAP #15
    
     *Prints '+'
    LEA plus, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
*-(An)
PREFIX_MINUS

    *parse for 
    LSR.W #8, D3
    LSR.W #5, D3
    
    
     *Prints '-'
    LEA neg_sign, A1
    MOVE.B #14, D0
    TRAP #15
    
    *Prints '('
    LEA open_paren, A1
    MOVE.B #14, D0
    TRAP #15
    
    *Print The appropriate value of An *Needed to use JSR & RTS
    JSR PRINT_INNER_An
    
    
    *Prints ')'
    LEA closed_paren, A1
    MOVE.B #14, D0
    TRAP #15

    
    RTS
    
*(xxx).W 
WORD_MODE
    RTS
    
*(xxx).L 
LONG_MODE
    
    RTS
    
OP_NAMES      DS.L    7         *holds the operands to be printed (e.g. #5,D3; (A3),(A4)+

PRINT_D0 LEA D0_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D0_MESS  DC.B 'D0',0


PRINT_D1 LEA D1_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D1_MESS  DC.B 'D1',0


PRINT_D2 LEA D2_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D2_MESS  DC.B 'D2',0


PRINT_D3 LEA D3_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D3_MESS  DC.B 'D3',0


PRINT_D4 LEA D4_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D4_MESS  DC.B 'D4',0


PRINT_D5 LEA D0_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D5_MESS  DC.B 'D0',0


PRINT_D6 LEA D6_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D6_MESS  DC.B 'D6',0

PRINT_D7 LEA D7_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D7_MESS  DC.B 'D7',0
    

PRINT_A0 LEA A0_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A0_MESS DC.B 'A0',0

PRINT_A1 LEA A1_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A1_MESS DC.B 'A1',0

PRINT_A2 LEA A2_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A2_MESS DC.B 'A2',0

PRINT_A3 LEA A3_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A3_MESS DC.B 'A3',0

PRINT_A4 LEA A4_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A4_MESS DC.B 'A4',0

PRINT_A5 LEA A5_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A5_MESS DC.B 'A5',0

PRINT_A6 LEA A6_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A6_MESS DC.B 'A6',0

PRINT_A7 LEA A7_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A7_MESS DC.B 'A7',0

addr_sign     DC.B    '$',0     
imm_sign      DC.B    '#',0
open_paren    DC.B    '(',0
closed_paren  DC.B    ')',0
plus_sign     DC.B    '+',0
neg_sign      DC.B    '-',0
comma         DC.B    ',',0
plus          DC.B    '+',0
space         DC.B    '   ',0

done_msg      DC.B    'done',0
nl            DC.B    '',CR,LF,0
CR         EQU   $0D
LF         EQU   $0A
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
