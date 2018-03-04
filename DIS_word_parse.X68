*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

*notes:
* -an instruction we dont need to know (eg DIVS) could be a false positive when parsing the hex_1 table

              
*something to be aware of:
* -for some instructions 68k will change the execution type without telling you e.g:
*         ADD <immediate>, <ea> 
*         uses the ADDQ, which is an entirely different opcode

* MOVE.B  'ASCIISTRING',(A5) is a valid opcode (wut)

*manual: "ADDA is used when the destination is an address register. ADDI
*          and ADDQ are used when the source is immediate data. Most
*          assemblers automatically make this distinction."


*A5: start
*A6: end
*A4: pointer to hex_1 table and bcc_tbl
*D1: holds the next hex to be read in instruction
*D2: holds the instruction


          * include io.s

CR         EQU   $0D
LF         EQU   $0A
stack      EQU   $7000

    ORG    $1000
    
START:        LEA      $600,A5            *start addr (TEST)
              LEA      $700,A6            *end addr (TEST)
              LEA      stack,SP
              
              
prep          CMPA.L   A5,A6              *have we read from start-end?
              BLT      done               * yes-end
              LEA      hex_1,A4           *pointer to hex_1 table in A4
              MOVE.W   #16,D0             *put 16 bits in D0 for the LSL instruction thats in 2 lines
              MOVE.W   (A5),D1            *move the instruction thats pointed to by starting address
              MOVE.W   D1,D2              *and copy it to D2
              LSL.L    D0,D1              *shift the word to the left
              ROL.L    #4,D1              *isolate the first hex digit
             
 
check_first   CMP.B   (A4)+,D1            *compare with the next value in the hex table
              BEQ     match_found         *theres a match with the value in the table
              ADDA    #1,A4               *increment the pointer to the table
              CMP.B   #$FF,(A4)           *have we reached the end of the hex table?
              BEQ     err                 * yes-were at the end of the table with no matches
              BRA     check_first         *keep searching through the table for a match           
     

match_found   CMP.B   #1,(A4)             *check if the mapping is ambiguous
              BEQ     inst_parse          * it is- get the next hex digit
              BRA     get_data            * its not-- just branch straight to the corresponding function


inst_parse    LEA     hex_1,A4            *reload pointer to hex_1 table
              CLR.B   D1                  *keep reading the opcode to identify which instruction it is 
              ROL.L   #4,D1               *get the next hex val
              BRA     _shift_roll_handler ********************

*use jump table to directly go to corresponding function
get_data      CMP.W   $4E71,D2            *is it nop
              BEQ     nop_handler         * its nop
              
              
*----------------------------------------------------------------------------
*nop_handler
*handles 'NOP'

*A5: holds the current address of this instruction

nop_handler   MOVEA.W A5,A2         *store the address of this word instruction in A2
              ADDA    #2,A5         *nop took up a word- set A5 to the next instruction
              BRA     disp_instr

* /nop_handler
*----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*bcc_handler
*handles 'BCS','BGE','BLT','BVC','BRA'

*D1: holds the condition, displacement nibbles of instruction
*D3: holds the condition of instruction
*D4: holds the current address of this instruction
*A4: holds the pointer to bcc_tbl
*A5: holds the current address of this instruction

bcc_handler         
              *first isolate the condition of this branch ('CS','GE','LT','VC','RA')   
              MOVE.B  D1,D3         *copy condition value to D3
              LEA     bcc_tbl,A4    *A4 now points to the bcc_tbl
bcc_cond      CMP.B   #-1,(A4)      *have we reached the end of the table
              BEQ     err           * yes-invalid branch
              CMP.B   (A4)+,D3      *compare the next table value
              BEQ     bcc_dispm     * there's a match
              BRA     bcc_cond      *continue looping through the table
bcc_dispm     CLR.B   D1            *now find the displacement- (A5 +- last 2 nibbles)
              ROL.L   #8,D1         *get the last 2 nibbles
              MOVE.L  A5,D4         *copy current address to D4
              ADDI.B  #2,D4         *and get to where the PC is
              ADD.L   D4,D1         *calculate displacement address
              
              MOVE.L  D1,ops_msg    *store the displacement address in ops_msg
              MOVE.B  names,instr_name
              MOVEA.W A5,A2         *store the address of this word instruction in A2
              ADDA    #2,A5         *all Bcc took up a word- set A5 to the next instruction
              
              CLR     D3            *clear registers used in the Bcc subroutine
              CLR     D4
              
              
              BRA     disp_instr
              
 */bcc_handler            
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
 * shift_roll_handler   
 * handles 'LSR','LSL','ASR','ASL','ROL','ROR'

 
 *A5: holds the current address of this instruction
 *D2: a copy of D1
 
_shift_roll_handler  MOVE.B   D1,D2
                     ASR.L    #1,D2          *set the carry to be the direction of this shift/rotate
                     BCS      _right_handler * carry is not set- its rightwards
                     BRA      _left_handler  * carry is set- leftwards
                     
_right_handler       CLR.B    D2
                     ROR.L    #4,D2
                     ASR.B    #2,D2
                     CMP.B    #0,D2
                     BEQ      asr_handler
                     CMP.B    #1,D2
                     BEQ      lsr_handler
                     CMP.B    #3,D2
                     BEQ      ror_handler
                     BRA      err
                     
asr_handler
                     

lsr_handler


ror_handler


_left_handler        CLR.B    D2
                     ROR.L    #4,D2
                     ASR.B    #2,D2
                     CMP.B    #0,D2
                     BEQ      asl_handler
                     CMP.B    #1,D2
                     BEQ      lsl_handler
                     CMP.B    #3,D2
                     BEQ      rol_handler
                     BRA      err      

asl_handler


lsl_handler


rol_handler
           
 * /_shift_roll_handler  
*-----------------------------------------------------------------------------

disp_instr    LEA     addr_sign,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              MOVE.L  A2,D1          *move the address of this instruction into D1              
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     instr_name,A1  *move the (assembly) name of this instruction into A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     ops_msg,A1    *move the name of operands into A1
              MOVE.B  #14,D0
              TRAP    #15
                    
              BRA     prep
                   
                   
err           LEA     instr_name,A1   *load the error msg into A1
              MOVE.B  #14,D0       *indicate output
              TRAP    #15
              LEA     nl,A1        *load new line into A1
              MOVE.B  #14,D0        *indicate output
              TRAP    #15
              CLR.L   D2            *reset msb index for further iterations
              BRA     done
              
              
done          LEA     done_msg,A1
              MOVE.B  #14,D0
              TRAP    #15
              MOVE.B  #9,D0         *indicate end of simulation
              TRAP    #15
           
              
data          ORG     $2000
                                                   
                          
              *first hex digit of the instruction with corresponding mappings
              *1 means the mapping is ambiguous (and we have to read more bits in instruction) 0 means its not.
              * -1 means the instruction isnt one that can be disassembled in this program
              
              *MOVE,MOVEA need to be added to this table
              
hex_1         DC.B    $04,$01  * 'MOVEM','LEA','NEG','JSR','RTS','NOP'
              DC.B    $0D,$01  * 'ADD','ADDA'
              DC.B    $00,$01  * 'ORI','BCLR','CMPI'
              DC.B    $0B,$01  * 'EOR','CMP'
              DC.B    $0E,$01  * 'LSR','LSL','ASR','ASL','ROL','ROR'   
              DC.B    $06,$01  * Bcc('BCS','BGE','BLT','BVC','BRA')  
              DC.B    $09,$00  * 'SUB'
              DC.B    $05,$00  * 'SUBQ'
              DC.B    $0C,$00  * 'MULS'
              DC.B    $08,$00  * 'OR'  
              DC.B    -1,-1    * invalid-first hex val is not one in the table above
              
              
 
* holds the condition of each instruction                
bcc_tbl       DC.B    %0101   *BCS
              DC.B    %1100   *BGE
              DC.B    %1101   *BLT
              DC.B    %1000   *BVC
              DC.B    %0000   *BRA     
              DC.B    -1      *invalid branch   

shift_tbl     DC.B    %000
              DC.B    %001
              DC.B    %010
              DC.B    %011
              DC.B    %100
              DC.B    %101
              DC.B    %110
              DC.B    %111
                     
names         DC.B    'BRA'               

instr_name    DS.L    0          *holds the instruction to be printed (e.g. ADD.L; MOVE.B)
ops_msg       DS.L    0          *holds the operands to be printed (e.g. #5,D3; (A3),(A4)+
addr_sign     DC.B    '$',0
space         DC.B    '   ',0

done_msg      DC.B    'done',0
nl            DC.B    '',CR,LF,0

_end
         END     start



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
