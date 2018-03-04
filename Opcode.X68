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
        
        *Opcodes Implemented
        *- Move.W
        *- Move.L
        *- MoveM
      
                                *Requires the data to be put into D3
        *create a copy of the original value
        MOVE.W #%0100000111000000, A5 

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

        MOVE.W A5, D3 
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
*----LEA, MOVEM

        MOVE.W A5, D3 
*-----------------------LEA 
        
        LSL #7, D3 
        LSR #8, D3
        LSR #5, D3
       
        CMPI.W #$7,D3       
          BEQ LEA_CODE
          
*-----------------------MOVEM

        LSL #6, D3
        LSR #8, D3
        LSR #5, D3
        
        CMPI.W #$1,D3
            BEQ MOVEM_CODE
            BNE INVALID_DATA
          
*-----------------------[0101]
NYBBLE_CODE_0101
*----SUBQ
        MOVE.W A5, D3 
*-----------------------SUBQ  
        
        LSL #7, D3
        LSR #8, D3
        LSR #7, D3
        
        CMPI.W #$1,D3       
            BEQ SUBQ_CODE
            BNE INVALID_DATA

*-----------------------[0110]
NYBBLE_CODE_0110
*----BCC,BRA

        MOVE.W A5, D3 
*-----------------------BCC         
        CMPI.W #%0110,D3       
                BEQ BCC_CODE

*-----------------------[0111]
NYBBLE_CODE_0111
*----
        MOVE.W A5, D3 

*-----------------------[1000]
NYBBLE_CODE_1000
*----DIVS,OR
        MOVE.W A5, D3 
        
        LSL #7, D3
        LSR #8, D3
        LSR #5, D3
*-----------------------DIVS.W
         CMPI.W #$7,D3       
           BEQ DIVS_W_CODE
   
*-----------------------OR        
            BNE OR_CODE

*-----------------------[1001]
NYBBLE_CODE_1001
*----SUB

*-----------------------SUB
        MOVE.W A5, D3
        
        LSR #8,D3       *MIGHT NOT BE NEEDED AS ITS ALREADY 1001
        LSR #3, D3
        
        CMPI #$9 ,D3
            BEQ SUB_CODE
            BNE INVALID_DATA
            
*-----------------------[1010]
NYBBLE_CODE_1010
*----
        MOVE.W A5, D3 
*-----------------------[1011]
NYBBLE_CODE_1011
*----EOQ,CMP

        MOVE.W A5, D3 
*-----------------------CMP         
        CMPI.W #%1011,D3       
                BEQ CMP_CODE
                
*-----------------------EOR        
        CMPI.W #%1011,D3       
                BEQ EOR_CODE                 

*-----------------------[1100]
NYBBLE_CODE_1100
*----MULS
        MOVE.W A5, D3 
*-----------------------MULS  
        LSL #7, D3  *look for the [111]
        LSR #8, D3
        LSR #5, D3   
   
        CMPI.W #$7,D3       
           BEQ MULS_CODE
           BNE INVALID_DATA 
*-----------------------[1101]
NYBBLE_CODE_1101
*----ADD,ADDA
        *MOVE.W A5, D3 
*-----------------------ADD_OR_ADDA       
        CMPI.W #$D,D3       
                BEQ ADD_OR_ADDA_CODE 

*-----------------------[1110]
NYBBLE_CODE_1110
*----ROR,ROL,LSR,LSL,ASR,ASL
        MOVE.W A5, D3 
*-----------------------ROR/ROL         
        CMPI.W #%1110,D3       
                BEQ ROR_OR_ROL_CODE

*-----------------------[1111]
NYBBLE_CODE_1111
*----
        MOVE.W A5, D3 



                

                
           
     
 

   

 



 



     
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
*-------------------------------------ADD_OR_ADDA
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
        LEA SUB_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

SUB_MESS DC.B 'SUB INSTRUCTION',0
*-------------------------------------SUBQ
SUBQ_CODE
       
        LEA SUBQ_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

SUBQ_MESS DC.B 'SUBQ INSTRUCTION',0
*-------------------------------------MULS
MULS_CODE

       
        LEA MULS_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MULS_MESS DC.B 'MULS INSTRUCTION',0
*-------------------------------------DIVS.W
DIVS_W_CODE

        LEA DIVS_W_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

DIVS_W_MESS DC.B 'DIVS.W INSTRUCTION',0

*-------------------------------------DIVS.L
DIVS_L_CODE

        LEA DIVS_L_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

DIVS_L_MESS DC.B 'DIVS.L INSTRUCTION',0
*-------------------------------------LEA
LEA_CODE

        LEA LEA_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

LEA_MESS DC.B 'LEA INSTRUCTION',0
*-------------------------------------OR
OR_CODE
        LEA OR_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

OR_MESS DC.B 'OR INSTRUCTION',0
*-------------------------------------ORI
ORI_CODE

        LEA ORI_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

ORI_MESS DC.B 'ORI INSTRUCTION',0
*-------------------------------------NEG
NEG_CODE

        LEA NEG_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

NEG_MESS DC.B 'NEG INSTRUCTION',0

*-------------------------------------EOR
EOR_CODE

        LEA EOR_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

EOR_MESS DC.B 'EOR INSTRUCTION',0
*-------------------------------------LSR
LSR_CODE

        LEA LSR_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

LSR_MESS DC.B 'LSR INSTRUCTION',0
*-------------------------------------LSL
LSL_CODE

        LEA LSL_MESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

LSL_MESS DC.B 'LSL INSTRUCTION',0
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
