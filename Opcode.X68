*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
*DO NOT USE  
*A5 (Starting Address),
*A6 (ending address) 
*A7 (stack pointer)
        
      
                                *Requires the data to be put into D1
        MOVE.W #%0010100100001101, D1   *Data might need to be swapped SWAP D1
        
*-------------------------------------INSTRUCTION FORMAT [WORD]
  
*-----------------------NOP     
        CMPI.W #%0100111001110001,D1       
                BEQ NOP_CODE
                
*-----------------------RTS            
        CMPI.W #%0100111001110101,D1       
                BEQ RTS_CODE

        AND #%11111111,D1       *Converts Word Into Byte
*-------------------------------------INSTRUCTION FORMAT [BYTE]

*-----------------------BRA            
        CMPI.W #%01100000,D1       
                BEQ BRA_CODE
                
*-----------------------CMPI           
        CMPI.W #%00001100,D1       
                BEQ CMPI_CODE                
        
*-----------------------NEG          
        CMPI.W #%01000100,D1       
                BEQ NEG_CODE
                
*-----------------------ORI         
        CMPI.W #%00000000,D1       
                BEQ ORI_CODE
        
        AND #%1111,D1           *Convert Byte Into Nybble
*-------------------------------------INSTRUCTION FORMAT [BYTE]

*-----------------------BCC         
        CMPI.W #%0110,D1       
                BEQ BCC_CODE

*-----------------------CMP         
        CMPI.W #%1011,D1       
                BEQ CMP_CODE
                
*-----------------------ROR/ROL         
        CMPI.W #%1110,D1       
                BEQ ROR_OR_ROL_CODE
                
*-----------------------EOR        
        CMPI.W #%1011,D1       
                BEQ EOR_CODE            
     
*-----------------------OR        
        CMPI.W #%1000,D1       
                BEQ OR_CODE  

*-----------------------LEA        
        CMPI.W #%0100,D1       
                BEQ LEA_CODE   

*-----------------------MULS        
        CMPI.W #%1100,D1       
                BEQ MULS_CODE 

*-----------------------SUBQ        
        CMPI.W #%0101,D1       
                BEQ SUBQ_CODE

*-----------------------SUB        
        CMPI.W #%1001,D1       
                BEQ SUB_CODE 

*-----------------------ADD_OR_ADDA       
        CMPI.W #%1101,D1       
                BEQ ADD_OR_ADDA_CODE 

     
        AND #%11,D1             *Gets the last BIT
        
        
        
        CMPI.W #%0000,D1        *Compare with all possible opCodes
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
*-------------------------------------MOVE
CODE_MOVE
        LEA MOVEMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVEMESS DC.B 'MOVE INSTRUCTION',0
*-------------------------------------MOVEA
MOVEA_CODE
        LEA MOVEAMESS, A1
        MOVE #14, D0
        TRAP #15
        RTS

MOVEAMESS DC.B 'MOVEA INSTRUCTION',0

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
