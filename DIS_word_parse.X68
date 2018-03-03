*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

*notes:
* -an instruction we dont need to know (eg DIVS) could be a false positive when parsing the hex_1 table

CR         EQU   $0D
LF         EQU   $0A
stack      EQU   $7000

    ORG    $1000
    
START:        LEA      $400,A5            *start addr (TEST)
              LEA      $700,A6            *end addr (TEST)
              
prep          LEA      hex_1,A4           *pointer to hex_1 table in A4
              MOVE.W   #16,D2             *put 16 bits in D2 for the LSL instruction thats in 2 lines
              MOVE.W   (A5),D1            *move the instruction to be pointed to by address 400
              LSL.L    D2,D1              *shift the word to the left
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


inst_parse    CLR.B   D1                  *keep reading the opcode to identify which instruction it is 
              ROL.L   #4,D1               *get the next hex val


get_data                                  *use jump table to find corresponding function


                    
err           LEA     data_msg,A1   *load the error msg into A1
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

              
              
data          ORG     $3000
                           
                           
                           
                           
              *first hex digit of the instruction with corresponding mappings
              *1 means the mapping is ambiguous (and we have to read more bits in instruction) 0 means its not.
              * -1 means the instruction isnt one that can be disassembled in this program
              
              
hex_1         DC.B    $04,$01  * 'MOVEM','LEA','NEG','JSR','RTS','NOP'
              DC.B    $0D,$01  * 'ADD','ADDA'
              DC.B    $00,$01  * 'ORI','BCLR','CMPI'
              DC.B    $0B,$01  * 'EOR','CMP'
              DC.B    $0E,$01  * 'LSR','LSL','ASR','ASL','ROL','ROR'   
              DC.B    $06,$01  * 'BCS','BGE','BLT','BVC','BRA'   
              DC.B    $09,$00  * 'SUB'
              DC.B    $05,$00  * 'SUBQ'
              DC.B    $0C,$00  * 'MULS'
              DC.B    $08,$00  * 'OR'  
              DC.B    -1,-1    * invalid-first hex val is not one in the table above
              
                       *MOVE,MOVEA need to be added to this table
                 
                              
                
nl            DC.B    '',CR,LF,0
display_start DC.B    'Enter the starting 32-bit memory address in hex (-1 to quit): ',0
display_end   DC.B    'Enter ending 32-bit memory address in hex (-1 to quit): ',0
data_msg      DC.B    'DATA',CR,LF,0

exit_val      DC.W    $2D31  *sentinel exit value
done_msg      DC.B    'done',0
              
user_start    DS.L    0
user_end      DS.L    0


_end
         END     start



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
