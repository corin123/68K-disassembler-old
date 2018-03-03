*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*Stack pointer @ 7000
* ORG data @ 3000
* ORG start @1000
* Put program code here
*DO NOT USE  
*A5 (Starting Address),
*A6 (ending address) 
*A7 (stack pointer)
        
      
                                *Requires the data to be put into D3
        *create a copy of the original value
        MOVE.W #%0100100001000000, A5 

        *Copy value to manipulate in D3  
        MOVE.W A5, D3
*-------------------------------------INSTRUCTION FORMAT [WORD]
  
*-----------------------NOP     
        CMPI.W #$4E71,D3       
                BEQ NOP_CODE
                
*-----------------------RTS            
        CMPI.W #$4E75,D3       
                BEQ RTS_CODE

        LSR.W #8,D3       *Gets first Byte [FFXX]
*-------------------------------------INSTRUCTION FORMAT [BYTE]

*-----------------------BRA            
        CMPI.W #$60,D3       
                BEQ BRA_CODE
                
*-----------------------CMPI           
        CMPI.W #$C,D3       
                BEQ CMPI_CODE                
        
*-----------------------NEG          
        CMPI.W #$44,D3       
                BEQ NEG_CODE
                
*-----------------------ORI         
        CMPI.W #$0,D3       
                BEQ ORI_CODE
        
        LSR #4,D3           *Convert Byte Into Nybble
*-------------------------------------INSTRUCTION FORMAT [NYBBLE]

*-----------------------[0000]
        CMPI.B #%0000,D3
            BEQ NYBBLE_CODE_0000

*-----------------------[0001]
        CMPI.B #%0001,D3
            BEQ NYBBLE_CODE_0001            
            
*-----------------------[0010]
        CMPI.B #%0010,D3
            BEQ NYBBLE_CODE_0010

*-----------------------[0011]
        CMPI.B #%0011,D3
            BEQ NYBBLE_CODE_0011 

*-----------------------[0100]
        CMPI.B #%0100,D3
            BEQ NYBBLE_CODE_0100   

*-----------------------[0101]
        CMPI.B #%0101,D3
            BEQ NYBBLE_CODE_0101  

*-----------------------[0110]
        CMPI.B #%0110,D3
            BEQ NYBBLE_CODE_0110 
            
*-----------------------[0111]
        CMPI.B #%0111,D3
            BEQ NYBBLE_CODE_0111

*-----------------------[1000]
        CMPI.B #%1000,D3
            BEQ NYBBLE_CODE_1000 

*-----------------------[1001]
        CMPI.B #%1001,D3
            BEQ NYBBLE_CODE_1001 

*-----------------------[1010]
        CMPI.B #%1010,D3
            BEQ NYBBLE_CODE_1010 

*-----------------------[1011]
        CMPI.B #%1011,D3
            BEQ NYBBLE_CODE_1011

*-----------------------[1100]
        CMPI.B #%1100,D3
            BEQ NYBBLE_CODE_1100

*-----------------------[1100]
        CMPI.B #%1100,D3
            BEQ NYBBLE_CODE_1100

*-----------------------[1101]
        CMPI.B #%1101,D3
            BEQ NYBBLE_CODE_1101

*-----------------------[1110]
        CMPI.B #%1110,D3
            BEQ NYBBLE_CODE_1110

*-----------------------[1111]
        CMPI.B #%1111,D3
            BEQ NYBBLE_CODE_1111         


*-------------------------------------NYBBLE_CODE_FUNCTIONS
*   D4
*-----------------------[0000]
NYBBLE_CODE_0000
*----ORI,CMPI,BCLR
    MOVE.W A5, D3
    LSR #4, D3
    
    CMPI.W #%0000,D3
        BEQ ORI_CODE
    
    CMPI.W #%1100,D3
        BEQ CMPI_CODE
    
    
    CMPI.W #%1000,D3
        BEQ BLCR_STATIC_CODE
       
       
        MOVE.W A5, D3
        
        * get bit [6 - 8]
        LSL #7,D3
        LSR #8,D3
        LSR #4,D3
     
        *check the byte equal [1100]
        CMPI.B #$C, D3
        BEQ BLCR_DYNAMIC_CODE
        BNE INVALID_DATA

*-----------------------[0001]
NYBBLE_CODE_0001
*----

*-----------------------[0010]
NYBBLE_CODE_0010
*----MOVE.L,MOVEA.L

*-----------------------MOVEA.L
        MOVE.W A5, D3
        
        LSL #7, D3
        LSL #8, D3
        LSR #5, D3
        
        CMPI.W #1, D3
        BEQ MOVEA_L_CODE
        BNE MOVE_L_CODE

*-----------------------MOVE.L

*-----------------------[0011]
NYBBLE_CODE_0011
*---- MOVE.W, MOVEA.W

        MOVE.W A5, D3
        
        *get bits [6 - 8] to check if its MOVEA.W or MOVE.W
        LSL #7,D3
        LSR #8,D3
        LSR #5, D3
        
        
        CMPI.W #1, D3
        BEQ MOVEA_W_CODE
        BNE MOVE_W_CODE 

*-----------------------[0100]
NYBBLE_CODE_0100
*----LEA,NEG

*-----------------------NEG
        *Get the next Nybble
        ANDI.W #$F,D3  
        CMPI.W #%0100,D3       
                BEQ NEG_CODE
*-----------------------LEA        
        CMPI.W #%0100,D3       
                BEQ LEA_CODE
                BNE INVALID_DATA
*-----------------------[0101]
NYBBLE_CODE_0101
*----SUBQ

*-----------------------SUBQ        
        CMPI.W #%0101,D3       
                BEQ SUBQ_CODE

*-----------------------[0110]
NYBBLE_CODE_0110
*----BCC,BRA

*-----------------------BCC         
        CMPI.W #%0110,D3       
                BEQ BCC_CODE

*-----------------------[0111]
NYBBLE_CODE_0111
*----

*-----------------------[1000]
NYBBLE_CODE_1000
*----DIVS,OR

*-----------------------OR        
        CMPI.W #%1000,D3       
                BEQ OR_CODE 

*-----------------------[1001]
NYBBLE_CODE_1001
*----SUB, MOVEM

        MOVE.W A5, D3
        
        LSR #8,D3
        LSR #3, D3
        
        CMPI #$9 ,D3
        BNE SUB_CODE
        
        LSR #8, D3
        LSR #1, D3
        
        LSL #8, D3
        LSL #7, D3
       
*-----------------------SUB        
        CMPI.W #%1001,D3       
                BEQ SUB_CODE

*-----------------------[1010]
NYBBLE_CODE_1010
*----

*-----------------------[1011]
NYBBLE_CODE_1011
*----EOQ,CMP

*-----------------------CMP         
        CMPI.W #%1011,D3       
                BEQ CMP_CODE
                
*-----------------------EOR        
        CMPI.W #%1011,D3       
                BEQ EOR_CODE                 

*-----------------------[1100]
NYBBLE_CODE_1100
*----MULS

*-----------------------MULS        
        CMPI.W #%1100,D3       
                BEQ MULS_CODE

*-----------------------[1101]
NYBBLE_CODE_1101
*----ADD,ADDA

*-----------------------ADD_OR_ADDA       
        CMPI.W #%1101,D3       
                BEQ ADD_OR_ADDA_CODE 

*-----------------------[1110]
NYBBLE_CODE_1110
*----ROR,ROL,LSR,LSL,ASR,ASL

*-----------------------ROR/ROL         
        CMPI.W #%1110,D3       
                BEQ ROR_OR_ROL_CODE

*-----------------------[1111]
NYBBLE_CODE_1111
*----




                

                
           
     
 

   

 



 



     
        ANDI #%11,D3             *Gets the last BIT
        
        
        
        CMPI.W #%0000,D3        *Compare with all possible opCodes
        BEQ MOVEBYTEINSTRUCTION
                
INVALID_DATA
       LEA INVALIDMESSAGE, A1
       move #14, D0
       TRAP #15
       RTS       
INVALIDMESSAGE DC.B 'Invalid Data',0
       
    SIMHALT             ; halt simulator

* Put variables and constants here
EQUAL
        LEA mess,A1
        move #14, D0
        TRAP #15
        RTS
             
MOVEBYTEINSTRUCTION
       LEA message, A1
       move #14, D0
       TRAP #15
       RTS
*-------------------------------------MOVE.W
MOVE_W_CODE
        LEA MOVE_W_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVE_W_MESS DC.B 'MOVE.W INSTRUCTION',0

*-------------------------------------MOVE.L
MOVE_L_CODE
        LEA MOVE_L_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVE_L_MESS DC.B 'MOVE.L INSTRUCTION',0
*-------------------------------------MOVEA.W
MOVEA_W_CODE
        LEA MOVEA_W_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVEA_W_MESS DC.B 'MOVEA.W INSTRUCTION',0

*-------------------------------------MOVEA.L
MOVEA_L_CODE
        LEA MOVEA_L_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVEA_L_MESS DC.B 'MOVEA.L INSTRUCTION',0
*-------------------------------------ADD
ADD_OR_ADDA_CODE
        LEA ADD_OR_ADDAMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS
ADD_OR_ADDAMESS DC.B 'ADD_OR_ADDA INSTRUCTION',0

*-------------------------------------MOVEM
MOVEM_CODE
        LEA MOVEMMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVEMMESS DC.B 'MOVEM INSTRUCTION',0

*-------------------------------------BLCR_DYNAMIC
BLCR_DYNAMIC_CODE
        *ERROR!!!!MUST GET THE MIDDLE 3 BITS TO VALIDATE ITS DYNAMIC OTHERWISE INVALID DATA
        * FIXED ERROR HOPEFULLY
        
        *---------------------
        *This gets the bit [6 -8](110) which indicates if truly is dynamic
        
        MOVE.W A5, D3
        
        * get bit [6 - 8]
        LSL #7,D3
        LSR #8,D3
        LSR #4,D3
     
        *check the byte equal [1100]
        CMPI.B #$C, D3
        BEQ EQUAL
        BNE INVALID_DATA
        
        *-----------------------
        
        LEA BLCR_DYNAMICMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

BLCR_DYNAMICMESS DC.B 'BLCR_DYNAMIC INSTRUCTION',0

*-------------------------------------BLCR_STATIC
BLCR_STATIC_CODE
        LEA BLCR_STATICMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

BLCR_STATICMESS DC.B 'BLCR_STATIC INSTRUCTION',0  
*-------------------------------------SUB
SUB_CODE

*-------------------------------------SUBQ
SUBQ_CODE

*-------------------------------------MULS
MULS_CODE

*-------------------------------------DIVS
DIVS_CODE

*-------------------------------------LEA
LEA_CODE

*-------------------------------------OR
OR_CODE

*-------------------------------------ORI
ORI_CODE

*-------------------------------------NEG
NEG_CODE

        LEA NEGMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

NEGMESS DC.B 'NEG INSTRUCTION',0

*-------------------------------------EOR
EOR_CODE

*-------------------------------------LSR
LSR_CODE

*-------------------------------------LSL
LSL_CODE

*-------------------------------------ASR
ASR_CODE

*-------------------------------------ASL
ASL_CODE

*-------------------------------------ROR
ROR_OR_ROL_CODE

*-------------------------------------BCLR
BCLR_CODE

*-------------------------------------CMP
CMP_CODE

*-------------------------------------CMPI
CMPI_CODE

*-------------------------------------BCC
BCC_CODE

*-------------------------------------BCS
BCS_CODE

*-------------------------------------BGE
BGE_CODE

*-------------------------------------BLT
BLT_CODE

*-------------------------------------BVC
BVC_CODE

*-------------------------------------BRA
BRA_CODE

*-------------------------------------JSR
JSR_CODE

*-------------------------------------RTS
RTS_CODE

*-------------------------------------NOP
NOP_CODE
        LEA NOPMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS
NOPMESS DC.B 'NOP INSTRUCTION',0
       
Message DC.B 'IT WORKS',0
mess DC.B 'EQUAL',0
m DC.B 'AFTER',0
BYTECODE 
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
