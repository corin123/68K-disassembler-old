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
        
      
                                *Requires the data to be put into D3
        MOVE.W #%0010100100001101, D3   *Data might need to be swapped SWAP D3
        
*-------------------------------------INSTRUCTION FORMAT [WORD]
  
*-----------------------NOP     
        CMPI.W #%0100111001110001,D3       
                BEQ NOP_CODE
                
*-----------------------RTS            
        CMPI.W #%0100111001110101,D3       
                BEQ RTS_CODE

        ANDI #%11111111,D3       *Converts Word Into Byte
*-------------------------------------INSTRUCTION FORMAT [BYTE]

*-----------------------BRA            
        CMPI.W #%01100000,D3       
                BEQ BRA_CODE
                
*-----------------------CMPI           
        CMPI.W #%00001100,D3       
                BEQ CMPI_CODE                
        
*-----------------------NEG          
        CMPI.W #%01000100,D3       
                BEQ NEG_CODE
                
*-----------------------ORI         
        CMPI.W #%00000000,D3       
                BEQ ORI_CODE
        
        ANDI #%1111,D3           *Convert Byte Into Nybble
*-------------------------------------INSTRUCTION FORMAT [NYBBLE]

*-----------------------[0000]
        CMPI.W #%0000,D3
            BEQ NYBBLE_CODE_0000

*-----------------------[0001]
        CMPI.W #%0001,D3
            BEQ NYBBLE_CODE_0001            
            
*-----------------------[0010]
        CMPI.W #%0010,D3
            BEQ NYBBLE_CODE_0010

*-----------------------[0011]
        CMPI.W #%0011,D3
            BEQ NYBBLE_CODE_0011 

*-----------------------[0100]
        CMPI.W #%0100,D3
            BEQ NYBBLE_CODE_0100   

*-----------------------[0101]
        CMPI.W #%0101,D3
            BEQ NYBBLE_CODE_0101  

*-----------------------[0110]
        CMPI.W #%0110,D3
            BEQ NYBBLE_CODE_0110 
            
*-----------------------[0111]
        CMPI.W #%0111,D3
            BEQ NYBBLE_CODE_0111

*-----------------------[1000]
        CMPI.W #%1000,D3
            BEQ NYBBLE_CODE_1000 

*-----------------------[1001]
        CMPI.W #%1001,D3
            BEQ NYBBLE_CODE_1001 

*-----------------------[1010]
        CMPI.W #%1010,D3
            BEQ NYBBLE_CODE_1010 

*-----------------------[1011]
        CMPI.W #%1011,D3
            BEQ NYBBLE_CODE_1011

*-----------------------[1100]
        CMPI.W #%1100,D3
            BEQ NYBBLE_CODE_1100

*-----------------------[1100]
        CMPI.W #%1100,D3
            BEQ NYBBLE_CODE_1100

*-----------------------[1101]
        CMPI.W #%1101,D3
            BEQ NYBBLE_CODE_1101

*-----------------------[1110]
        CMPI.W #%1110,D3
            BEQ NYBBLE_CODE_1110

*-----------------------[1111]
        CMPI.W #%1111,D3
            BEQ NYBBLE_CODE_1111         


*-------------------------------------NYBBLE_CODE_FUNCTIONS

*-----------------------[0000]
NYBBLE_CODE_0000
*----ORI,CMPI,BCLR

*-----------------------[0001]
NYBBLE_CODE_0001
*----

*-----------------------[0010]
NYBBLE_CODE_0010
*----

*-----------------------[0011]
NYBBLE_CODE_0011
*----

*-----------------------[0100]
NYBBLE_CODE_0100
*----LEA,NEG

*-----------------------LEA        
        CMPI.W #%0100,D3       
                BEQ LEA_CODE

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
*----SUB

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
