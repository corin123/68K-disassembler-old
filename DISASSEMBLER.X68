*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Sean Coulter, Corin Ennis, Antony Mbugua
* Date       : Winter 2018
* Description: A disassembler program for Motorola 68K source files
*-----------------------------------------------------------

 *notes:
* -an instruction we dont need to know could be a false positive when parsing the hex_1 table
*   due to sharing a same first hex digit
              
*something to be aware of:
* -for some instructions 68k will change the execution type without telling you e.g:
*         ADD <immediate>, <ea>
*         uses the ADDQ, which is an entirely different opcode

* MOVE.B  'ASCIISTRING',(A5) is a valid opcode (wut)

*manual: "ADDA is used when the destination is an address register. ADDI
*          and ADDQ are used when the source is immediate data. Most
*          assemblers automatically make this distinction."

             
              ***************************************
              * TODO for initial user input for start/end addresses:
              *   check if the starting address is odd
              *   //(not sure about this)check if first line of data S file contains 36384B50524F47202020323043524541544544204259204541535936384B6D (68kprog created by easy68k in ASCII) so its not x86 or something
              *   check if user- inputted end address is after program is loaded (ENDed) ?
              *   odd address inputted
              ****************************************
                     
            *D1: sentinel exit value
            *D2: index of MSB
            *D3: length of user input string
            *D4: index of pointer to string table
            *D6: ascii value holding MSB
            *D7: max valid input
            
            
CR         EQU   $0D
LF         EQU   $0A
stack      EQU   $7000
start_addr EQU   $1000
              
start         ORG     start_addr             
              
*----------------*display starting information for user, capture start and end addresses, error check on addresses------------------------------
*----------------for each ascii character the user enters, if that character is outside [30,40) (40,46], its an invalid character---------------
    *A2: points to starting address
    *A3: points to ending address
    *A4: points to ascii/hex string table
    
    *D3: holds the next byte of the user starting address
    *D3: holds length of user input
    *D4: offset of string table value

              LEA     stack, SP         *put the stack in the stack pointer
              
disp_msg      LEA     display_start,A1  *load intro msg to A1
              MOVE.B  #14,D0            *indicate output
              TRAP    #15
              
              LEA     string_tbl,A4 *load A4 with the string table
              
              LEA     user_start,A1 *load user input variable address to A1
              MOVE.B  #2,D0         *indicate saving user input to loaded variable in A1
              TRAP    #15
              
              MOVE.W  exit_val,D0
              CMP.W   user_start,D0  *did the user want to quit?
              BEQ     done           * yes-quit
              
              CMP.L   #8,D1         *is the starting address <= 8 hex digits?
              BGT     addr_err      * no-invalid
              
              MOVE.B  D1,D3         *store length of start address (task #2) in D3
              CLR     D1            *clear D1 for use in the folllowing subroutine
              JSR     conversion    *enter loop to convert ascii string to hex
              ADDA.L  D7,A5          *store start address in A5
              BRA     end_addr      *we've converted the valid string to hex--get the end address now     
           
*********************SUBROUTINE converts user input (ascii) to hex**********************************************
conversion    CLR.L  D7
              MOVEA  #0,A6         *clear the address register being used to store the conversion data
              
get_next_byte MOVE.B (A1)+,D2      *move next byte of input address to D2
              CLR    D4            *reset index offset in string table
              SUBI.B #1,D3         *decrement the loop counter (length of user string)
              CMP.B  #-1,D3        *have we converted the whole address?
              BEQ    end_conv      * yes-return from the subroutine
              BRA    char_convert  * no-convert the next character from ascii -> hex
              
char_convert  CMP.B   (A4,D4.W),D2 *compare this byte with the next value in string table
              BEQ     push_byte    *we found the corresponding hex
              ADDI    #2,D4          *Next index of string table
              CMP.B   #31,D4         *check if we're outside the table (indicates invalid hex input)
              BGT     addr_err       * we're outside the table, so user input character wasn't hex-convertible
              BRA     char_convert   *check the next string table value
              
push_byte     MOVE.B 1(A4,D4.W),D1
              ADD.L  D1,D7
              CMP.B  #0,D3
              BEQ    end_conv
              LSL.L  #4,D7
              BRA    get_next_byte      
end_conv      RTS
******************************************************************************************************************  
      
*------------------- by this point, the starting address is valid and stored in A5.*--------------------------------
              
end_addr      CLR.L   D1
              LEA     display_end,A1
              MOVE.B  #14,D0        *indicate display
              TRAP    #15
              
              LEA     user_end,A1
              MOVE.B  #2,D0         * trap user ending address   
              TRAP    #15
              
              MOVE.W  exit_val,D0
              CMP.W   user_end,D0  *did the user want to quit?
              BEQ     done          * yes-quit
              
              CMP.L   #8,D1         *is the starting address 8 hex digits?
              BGT     addr_err      * no-invalid
              
              MOVE.B  D1,D3         *store length of start address (task #2) in D3
              JSR     conversion    *convert(above) the ending address from ascii to hex
              ADDA.L  D7,A6         *store end address in A5
              BRA     prep          *begin initial steps before parsing data at user address

*------------------At this point, A5 holds starting address and A6 holds ending address. --------------------------------
*A5: start
*A6: end
*A4: pointer to hex_1 table and bcc_tbl
*D1: holds the next hex to be read in instruction
*D2: holds the instruction

prep          CMPA.L   A5,A6              *have we read from start-end?
              BLT      done               * yes-end
              LEA      hex_1,A4           *pointer to hex_1 table in A4
              CLR      D4                 *register used in address calculation
              CLR      D7                 *register used for address calculation
              MOVEA.L  #0,A1
              MOVE.W   #16,D0             *put 16 bits in D0 for the LSL instruction thats in 2 lines
              MOVE.W   (A5),D1            *move the instruction thats pointed to by starting address
              MOVE.W   D1,D2              *and copy it to D2
              LSL.L    D0,D1              *shift the word to the left
              ROL.L    #4,D1              *isolate the first hex digit
             
 
check_first   CMP.B   (A4)+,D1            *compare with the next value in the hex table
              BEQ     match_found         *theres a match with the value in the table
              ADDA    #1,A4               *increment the pointer to the table
              CMP.B   #$FF,(A4)           *have we reached the end of the hex table?
              BEQ     fatal_err           * yes-were at the end of the table with no matches
              BRA     check_first         *keep searching through the table for a match           
     

match_found   CMP.B   #1,(A4)             *check if the mapping is ambiguous
              BEQ     inst_parse          * it is- get the next hex digit
              BRA     get_data            * its not-- just branch straight to the corresponding function


inst_parse    CMP.B   #1,D1            *based on the first digit, decide how to decode next value.
              BEQ     _1_handler
              CMP.B   #3,D1
              BEQ     _3_handler
              CMP.B   #2,D1
              BEQ     _2_handler
              CMP.B   #4,D1
              BEQ     _4_handler
              CMP.B   #13,D1
              BEQ     _13_handler
              CMP.B   #0,D1
              BEQ     _0_handler
              CMP.B   #11,D1
              BEQ     _11_handler
              CMP.B   #8,D1
              BEQ     _8_handler

*The following functions determine where to go if the first hex value is shared between instructions             
*---------------   
*MOVE.B, MOVEA.B(inv)        
_1_handler    CLR.B   D1
              ROL.L   #3,D1
              MOVE.L  D1,D2
              CLR.B   D2
              ROL.L   #3,D2

*--------------- 
*---------------
_3_handler

*--------------- 
*--------------- 
_2_handler

*--------------- 
*--------------- 
_4_handler    CMP.W   #$4E71,D1        *is it nop
              BEQ     nop_handler      * its nop
              CMP.W   #$4E75,D1        *is it rts
              *BEQ     rts_handler     * its rts 
              CLR.B   D1               *get byte space ready for next digit
              ROL.L   #4,D1            *get the next digit
              CMP.B   #$E,D1           *is the next digit E (but we know its not rts,nop)
              BEQ     jsr_handler      * its jsr
              *now its either movem,lea,neg
              MOVE.L  D1,D2            *make a copy
              CLR.B   D2
              ROL.L   #2,D2            *save bits of 3rd digit to d2
              MOVE.L  D2,D3            *make another copy
              CMP.B   #3,D2            *if its 11, not neg (can only be 00,01,10)
              BEQ     _4_not_neg       * not 11- either lea or movem
              BRA     _4_continue      * still undetermined (lea,movem, or neg)
_4_not_neg    LSL.L   #1,D2            *lea and movem differentiated by current MSB        
              BCS     lea_handler      * carry set- lea
              *BRA     movem_handler    * carry not set-movem
_4_continue   LSL.L   #1,D2

*--------------- 
*--------------- 
_13_handler     ROL.L   #4,D1
                MOVE.L  D1,D2
                CLR.B   D2
                ROL.L   #2,D2
                CMP.B   #3,D2
                BEQ     adda_handler
                BRA     add_handler

*--------------- 
*--------------- 
_0_handler      CLR.B D1
                ROL.L #4,D1
                CMP.B #0,D1
                BEQ   ori_handler
                CMP.B #8,D1
                BEQ   bclr_handler
                BRA   cmpi_handler

*--------------- 
*--------------- 
_11_handler     CLR.B D1          
                ROL.L #4,D1    *get next hex digit
                LSR.B #1,D1    * eor and cmp can be differentiated by lsb in 2nd digit. check carry
                BCS   eor_handler
                BRA   cmp_handler

*--------------- 
*--------------- 
_8_handler      CLR.B   D1
                ROL.L   #4,D1
                MOVE.L  D1,D2
                CLR.B   D2
                ROL.L   #2,D2
                CMP.B   #3,D2
                BEQ     divsw_handler       *between or and divs.w, only divs.w can have a size 11
                BRA     or_handler
               
*--------------- 
*--------------- 

*we can go directly to the function since the first hex val maps directly to an instruction
get_data      CMP.B   #6,D1
              BEQ     bcc_handler
              CMP.B   #$E,D1
              BEQ     _shift_roll_handler
              CMP.B   #9,D1
              *BEQ    sub_handler
              CMP.B   #5,D1
              *BEQ     subq_handler
              CMP.B   #$C,D1
              *BEQ     muls_handler
*----------------------------------------------------------------------------
*----------------------------------------------------------------------------              
*----------------------------------------------------------------------------
*nop_handler
*handles 'NOP'

*A5: holds the current address of this instruction

nop_handler   MOVEA.W A5,A2         *store the address of this word instruction in A2
              MOVE.L  NOP,INST_NAME 
              MOVE.L  #0,OP_NAMES
              ADDA    #2,A5         *nop took up a word- set A5 to the next instruction
              BRA     disp_instr

* /nop_handler
*----------------------------------------------------------------------------


*----------------------------------------------------------------------------
*adda_handler
*handles 'ADDA'

adda_handler    LSR.B  #1,D1        *send the size bit to carry
                BCS    adda_word_handler    *carry is set->ADDA.W
                BRA    adda_long_handler    *carry not set->ADDA.L
                
adda_word_handler   *save .w 
                BRA adda_save_data
adda_long_handler   *save .l 
                BRA adda_save_data

                
adda_save_data  MOVE.B D1,OP_NAMES       *move the 3 An bits
                   CLR.B  D1                *done with second 4 bits
                   ROL.L  #2,D1             *move and clear size bits-- we already know them
                   CLR.B  D1
                   ROL.L  #6,D1             *get 6 EA bits
                          

* /adda_handler
*----------------------------------------------------------------------------

*----------------------------------------------------------------------------
*add_handler
*handles 'ADD'

add_handler    LSR.B  #1,D1              *isolate direction bit
               BCS    add_right_handler  *<ea> + Dn -> <ea>
               BRA    add_left_handler   *Dn + <ea> -> Dn
               
add_right_handler   *adjust operands ^
                    BRA  save_data_add

add_left_handler    *adjust operands ^
                    BRA  save_data_add
                    
add_byte_handler    *move .b to opnames

add_word_handler    *move .w to opnames

add_long_handler    *move .l to opnames

save_data_add       MOVE.L D1,OP_NAMES      *save Dn bits
                    CLR.B  D1
                    ROL.L  #2,D1            *get size bits in byte position
                    CMP.B  #1,D1            *whats the size of the add?
                    BLT    add_byte_handler
                    BGT    add_long_handler
                    BEQ    add_word_handler
                    
add_get_ea          ROL.L  #6,D1            *get EA bits

* /add_handler
*----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*bcc_handler
*handles 'BCS','BGE','BLT','BVC','BRA'

*D1: holds the condition, displacement nibbles of instruction
*D3: holds the condition of instruction
*D4: holds the current address of this instruction
*A4: holds the pointer to bcc_tbl
*A5: holds the current address of this instruction

bcc_handler   CLR.B   D1
              ROL.L   #4,D1
              MOVE.B  D1,D3         *copy condition value to D3
              LEA     bcc_tbl,A4    *A4 now points to the bcc_tbl
bcc_cond      CMP.B   #-1,(A4)      *have we reached the end of the table
              BEQ     fatal_err     * yes-invalid branch
              CMP.B   (A4)+,D3       *compare the next table value
              BEQ     bcc_determiner * there's a match
              BRA     bcc_cond      *continue looping through the table

bcc_determiner  CMP.B  #5,-(a4)
                BEQ    bcs_handler
                CMP.B  #12,(a4)
                BEQ    bge_handler
                CMP.B  #13,(a4)
                BEQ    blt_handler
                CMP.B  #8,(a4)
                BEQ    bvc_handler
                CMP.B  #0,(a4)
                BEQ    bra_handler
                BRA    fatal_err


bcs_handler   MOVE.L  BCS,INST_NAME
              BRA     bcc_dispm
bge_handler   MOVE.L  BGE,INST_NAME
              BRA     bcc_dispm
blt_handler   MOVE.L  BLT,INST_NAME
              BRA     bcc_dispm
bvc_handler   MOVE.L  BVC,INST_NAME
              BRA     bcc_dispm
bra_handler   MOVE.L  BRA,INST_NAME
              BRA     bcc_dispm

              
bcc_dispm     CLR.B   D1            *now find the displacement- (A5 +- last 2 nibbles)
              ROL.L   #8,D1         *get the last 2 nibbles
              MOVE.L  (A5),D4       *copy current address to D4. **Bcc takes up a word, move it forward             
              ADDI.B  #2,D4         *and get to where the PC is
              SUB.L   D1,D4         *calculate displacement address
              
              MOVE.L  D4,OP_NAMES   *store the displacement address in ops_msg
              ADDA    #2,A5         *all Bcc took up a word- set A5 to the next instruction
              
              CLR.L   D3            *clear registers used in the Bcc subroutine
              CLR.L   D4
                         
              BRA     disp_instr
              
 */bcc_handler            
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
 * shift_roll_handler   
 * handles 'LSR','LSL','ASR','ASL','ROL','ROR'

 
 *A5: holds the current address of this instruction
 *D2: used to check if its a shift or roll, immediate or register
 *D3: holds the size (b,w,l) of the operation
 *D4: holds the immediate data (1-7) or the register number of the source
 *D5: holds the destination register being shifted/rotated
 *D6: holds invalid destination flag
 *D7: holds invalid source flag
 
_shift_roll_handler  CLR.B    D1
                     ROL.L    #4,D1
                     MOVE.B   D1,D2
                     ASR.B    #1,D2          *set the carry to be the direction of this shift/rotate
                     BCS      _left_handler  * carry is set- its leftwards
                     BRA      _right_handler * carry is set- rightwards
                     
*------------------
*------------------                    
_right_handler       MOVE.L   D1,D2          *recopy D1 to D2
                     CLR.B    D2             *clear instruction data not needed now
                     MOVE.L   D2,D3          *copy instruction data used later to D3
                     ROL.L    #3,D2          *shift and roll bits until we isolate the type (asr,lsr,ror)
                     CLR.B    D2             *""
                     ROL.L    #2,D2          *At this point we've isolated the type
                     CMP.B    #0,D2
                     BEQ      asr_handler    *its asr
                     CMP.B    #1,D2
                     BEQ      lsr_handler    *its lsr
                     CMP.B    #3,D2
                     BEQ      ror_handler    *its ror
                     BRA      fatal_err      *its invalid
*------------------
                    
asr_handler          MOVE.L   ASR,INST_NAME
                     LSL.L    #3,D3          *shift until the mode bit is set to carry. D3 now holds size of operation
                     BCS      reg_asr        * carrys on- its a register source
                     *CMP.B    #8,D3          * carrys off- is the immediate data too large?
                     *BGT      flag_source    
                     BRA      imm_asr        * go to immediate data handler
flag_source
                    
reg_asr              JSR      save_srh_data
                     
                     BRA      prep_srh_disp

imm_asr              JSR      save_srh_data  *saves source(imm) data, destination register
                     
                     
                     BRA      prep_srh_disp  
*------------------

lsr_handler          MOVE.L   LSR,INST_NAME
                     LSL.L    #3,D3
                     BCS      reg_lsr
                     BRA      imm_lsr
                     
reg_lsr              JSR      save_srh_data
                     
                     BRA      prep_srh_disp

imm_lsr              JSR      save_srh_data  *saves source(imm) data, destination register
                     
                     BRA      prep_srh_disp
*------------------

ror_handler          MOVE.L   ROR,INST_NAME
                     LSL.L    #3,D3
                     BCS      reg_ror
                     BRA      imm_ror

reg_ror              JSR      save_srh_data
                     
                     BRA      prep_srh_disp

imm_ror              JSR      save_srh_data  *saves source(imm) data, destination register
                     
                     BRA      prep_srh_disp
*------------------
*------------------
_left_handler        MOVE.L   D1,D2          *recopy D1 to D2
                     CLR.B    D2
                     MOVE.L   D2,D3
                     ROL.L    #3,D2
                     CLR.B    D2
                     ROL.L    #2,D2
                     CMP.B    #0,D2
                     BEQ      asl_handler
                     CMP.B    #1,D2
                     BEQ      lsl_handler
                     CMP.B    #3,D2
                     BEQ      rol_handler
                     BRA      fatal_err    
*------------------


asl_handler          MOVE.L   ASL,INST_NAME
                     LSL.L    #3,D3
                     BCS      reg_asl
                     BRA      imm_asl       
                     
reg_asl              JSR      save_srh_data
                     
                     BRA      prep_srh_disp

imm_asl              JSR      save_srh_data  *saves source(imm) data, destination register
                     
                     BRA      prep_srh_disp
*------------------        
                              

lsl_handler          MOVE.L   LSL,INST_NAME
                     LSL.L    #3,D3
                     BCS      reg_lsl
                     BRA      imm_lsl
                     
reg_lsl              JSR      save_srh_data
                     
                     BRA      prep_srh_disp

imm_lsl              JSR      save_srh_data  *saves source(imm) data, destination register
                     
                     BRA      prep_srh_disp
*------------------


rol_handler          MOVE.L   ROL,INST_NAME
                     LSL.L    #3,D3
                     BCS      reg_rol
                     BRA      imm_rol
                     
reg_rol              JSR      save_srh_data
                     
                     BRA      prep_srh_disp

imm_rol              JSR      save_srh_data  *saves source(imm) data, destination register
                     
                     BRA      prep_srh_disp
*------------------                    
                                     
                     
save_srh_data        MOVE.L   D1,D2          *recopy D1 to D2
                     LSR.B    #1,D2          *isolate the 3 source bits
                     MOVE.B   D2,D4          *save the source bits to D4
                     CLR.B    D1             *prep the byte space
                     ROR.L    #5,D1
                     CLR.B    D1
                     ROR.L    #3,D1          *get the last 3 bits of the instruction
                     MOVE.B   D1,D5          *D5 now holds the destination register
                     
                     *load source bits to a2
                     *load dest bits to a3
                     
                     ADDA     #2,A5
                     
                     RTS
                     
prep_srh_disp        BRA      disp_instr             
            
 * /_shift_roll_handler  
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
 * eor_handler  
 * handles eor
 *   branches to EORI when source is immediate
 
 *D2: holds source data register
 *D3: holds operation size (b,w,l)
 *D4: holds EA info (mode,register)
 
eor_handler         MOVE.B   D1,D2        *copy data register number in d1 to d2
                    CLR.B    D1
                    ROL.L    #2,D1         
                    MOVE.B   D1,D3        *save size bits to d3         
                    CLR.B    D1 
                    ROL.L    #6,D1        *save EA bits to d1
                    
* /eor_handler
*-----------------------------------------------------------------------------
                    

*-----------------------------------------------------------------------------
* cmp_handler
* handles cmp
*   branches to CMPA when destination is address register
*   branches to CMPI when source is immediate

 *D2: holds source data register
 *D3: holds operation size (b,w,l)
 *D4: holds EA info (mode,register)

cmp_handler         MOVE.B   D1,D2        *save Dn bits to D2
                    CLR.B    D1           *ready byte position of D1
                    ROL.L    #2,D1        *isolate size bits
                    MOVE.B   D1,D3        *save size bits to D2
                    CLR.B    D1           *ready byte position of D1
                    ROL.L    #6,D1        *isolate EA bits


* /cmp_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* cmpi_handler
* handles cmpi

*D1 holds instruction info, then EA info (mode & reg)
*D2: holds the size of the operation (b,w,l)

cmpi_handler       CMP.B     #$C,D1
                   BNE       fatal_err       *CMPI has bits d11 to d8 hardcoded as C
                   CLR.B     D1
                   ROL.L     #2,D1     *isolate the size bits
                   MOVE.B    D1,D2
                   CLR.B     D1
                   ROL.L     #6,D1     isolate EA info in D1
                   
* /cmpi_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*bclr_handler
*handles bclr (dynamic and static source)

*D1: holds the opcode
*D2:
    *-static: none
    *dynamic: holds register bits
*D3:
    *-static: none
    *-dynamic: holds EA info

bclr_handler      CMP.B     #8,D1          *static (immediate) source defined exactly in 68K manual
                  BEQ       bclr_static
                  BRA       bclr_dynamic

bclr_static       ROL.L     #2,D1          *we know its immediate data at this point. shifting and discarding hardcoded info
                  CLR.B     D1             
                  ROL.L     #6,D1          *isolate the EA mode and register

bclr_dynamic      MOVE.L    D1,D2          *copy instruction opcode into D2
                  LSR.W     #1,D2          *isolate the register bits in the byte of D2
                  MOVE.L    D1,D3          *copy instruction opcode to D3
                  ROL.L     #2,D3
                  CLR.B     D3
                  ROL.L     #6,D3          *save EA info in D3

* /bclr_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*ori_handler
*handles ori

ori_handler       ROL.L    #2,D1           *0 currently occupies the byte, so can immediately roll
                  MOVE.B   D1,D2           *move size bits to D2
                  CLR.B    D1
                  ROL.L    #6,D1
                  MOVE.B   D1,D3           *save size bits to D3

* /ori_handler
*-----------------------------------------------------------------------------



*-----------------------------------------------------------------------------
* lea_handler
* handles lea

*D1: holds opcode instruction
*D2: holds register bits

lea_handler       LSR.B     #1,D1          *isolate register bits in D1
                  MOVE.B    D1,D2          *move register bits to D2
                  ROL.L     #2,D1
                  CLR.B     D1
                  ROL.L     #6,D1          *shift EA mode and register to the byte of D1
                  
                  
* /lea_handler
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*neg_handler
*handles neg

*D1: holds opcode
*D2: holds size of operation (b,w,l)

neg_handler       CLR.B    D1              *clear hardcoded bits
                  ROL.L    #2,D1           *isolate size
                  MOVE.B   D1,D2           *move size to D2
                  CLR.B    D1
                  ROL.L    #6,D1           *shift EA mode and register bits in D1

* /neg_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*jsr_handler
*handles 'JSR'

jsr_handler       ROL.L   #2,D1
                  CLR.B   D1        *we already know its jsr. get rid of hardcoded bits
                  ROL.L   #6,D1     *save EA bits into D1

* /jsr_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*or_handler
*handles 'OR'

or_handler     MOVE.L   D1,D2
               LSR.B    #1,D2          *shift the direction bit to carry-- D2 now also holds the data register of the operation
               BCS      or_Dn_right    <ea> OR Dn -> <ea>
               BRA      or_Dn_left     Dn OR <ea> -> Dn
               
or_Dn_right    CLR.B    D1
               ROL.L    #2,D1
               MOVE.B   D1,D3          *D3 holds the size of the operation
               CLR.B    D1
               ROL.B    #6,D1          *D1 holds the EA bits

or_Dn_left     CLR.B    D1
               ROL.L    #2,D1
               MOVE.B   D1,D3          *D3 holds the size of the operation
               CLR.B    D1
               ROL.B    #6,D1          *D1 holds the EA bits


* /or_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*divsw_handler
*handles divsw

divsw_handler   LSR.B  #1,D1        *get rid of hardcoded bit
                MOVE.B D1,D2        *save Dn number of operation to D2
                LSL.L  #2,D1        *Shift out size bits--we already know its a word
                ROL.L  #6,D1        *D1 now holds the EA bits

* /divsw_handler
*-----------------------------------------------------------------------------


disp_instr    LEA     addr_sign,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              MOVE.L  A5,D1         *move the address of this instruction into D1
              MOVE.B  #3,D0              
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA.L   INST_NAME,A1  *move the (assembly) name of this instruction into A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              MOVE.L  OP_NAMES,D1    *move the name of operands into A1
              MOVE.B  #3,D0
              TRAP    #15
              
              LEA     nl,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              BRA     prep

              
      
done          LEA     done_msg,A1
              MOVE.B  #14,D0
              TRAP    #15
              MOVE.B  #9,D0         *indicate end of simulation
              TRAP    #15
              
addr_err      LEA     bad_addr,A1   *load the error msg into A1
              MOVE.B  #14,D0       *indicate output
              TRAP    #15
              LEA     nl,A1        *load new line into A1
              MOVE.B  #14,D0        *indicate output
              TRAP    #15
              CLR.L   D2            *reset msb index for further iterations
              BRA     disp_msg      *go back to welcome msg
              
              
fatal_err     LEA     imm_sign,A1   *load the error msg into A1
              MOVE.B  #14,D0       *indicate output
              TRAP    #15
              LEA     nl,A1        *load new line into A1
              MOVE.B  #14,D0        *indicate output
              TRAP    #15
              CLR.L   D2            *reset msb index for further iterations
              BRA     done      *go back to welcome msg
              
*-------------------------------------------------------------------------------------------------------------------------------------------              
data          ORG     $4000
              
*string table for converting user input addresses from ascii to hex      
string_tbl    DC.B    $30,$0      *{hex,ascii}
              DC.B    $31,$1          
              DC.B    $32,$2 
              DC.B    $33,$3
              DC.B    $34,$4
              DC.B    $35,$5
              DC.B    $36,$6
              DC.B    $37,$7
              DC.B    $38,$8
              DC.B    $39,$9            
              DC.B    $41,$A
              DC.B    $42,$B
              DC.B    $43,$C
              DC.B    $44,$D
              DC.B    $45,$E
              DC.B    $46,$F
              
              
             *first hex digit of the instruction with corresponding mappings
              *1 means the mapping is ambiguous (and we have to read more bits in instruction) 0 means its not.
              * -1 means the instruction isnt one that can be disassembled in this program
              
hex_1         DC.B    $01,$01  * 'MOVE.B','MOVEA.B'
              DC.B    $03,$01  * 'MOVE.W','MOVEA.W'
              DC.B    $02,$01  * 'MOVEA.L','MOVEA.L'
              DC.B    $04,$01  * 'MOVEM','LEA','NEG','JSR','RTS','NOP'
              DC.B    $0D,$01  * 'ADD','ADDA'
              DC.B    $00,$01  * 'ORI','BCLR','CMPI'
              DC.B    $0B,$01  * 'EOR','CMP'
              DC.B    $0E,$00  * 'LSR','LSL','ASR','ASL','ROL','ROR'   
              DC.B    $06,$00  * Bcc('BCS','BGE','BLT','BVC','BRA') 
              DC.B    $09,$00  * 'SUB'
              DC.B    $05,$00  * 'SUBQ'
              DC.B    $0C,$00  * 'MULS'
              DC.B    $08,$01  * 'OR','DIVS(word)'
              DC.B    -1,-1    * invalid-first hex val is not one in the table above

MOVEA         DC.L    'MOVEA',0
MOVEM         DC.L    'MOVEM',0              
MOVE          DC.L    'MOVE',0
LEA           DC.L    'LEA',0
NEG           DC.L    'NEG',0 
JSR           DC.L    'JSR',0
RTS           DC.L    'RTS',0
NOP           DC.L    'NOP',0
ADD           DC.L    'ADD',0
ADDA          DC.L    'ADDA',0
ORI           DC.L    'ORI',0
BCLR          DC.L    'BCLR',0
CMPI          DC.L    'CMPI',0
EOR           DC.L    'EOR',0
CMP           DC.L    'CMP',0
LSR           DC.L    'LSR',0
LSL           DC.L    'LSL',0
ASR           DC.L    'ASR',0
ASL           DC.L    'ASL',0
ROL           DC.L    'ROL',0
ROR           DC.L    'ROR',0
BCS           DC.L    'BCS',0
BGE           DC.L    'BGE',0
BLT           DC.L    'BLT',0
BVC           DC.L    'BVC',0
BRA           DC.L    'BRA',0
SUB           DC.L    'SUB',0
SUBQ          DC.L    'SUBQ',0
MULS          DC.L    'MULS',0
DIVS          DC.L    'DIVS',0
OR            DC.L    'OR',0
INV           DC.L    'DATA',0
               
SIZEB         DC.W    '.B',0
SIZEW         DC.W    '.W',0
SIZEL         DC.W    '.L',0
              
regs          DC.B    'D0','D1','D2','D3','D4','D5','D6','D7','A0','A1','A2','A3','A4','A5','A6','A7','SP'
              
              
 
* holds the condition of each instruction                
bcc_tbl       DC.B    %0101 *BCS
              DC.B    %1100 *BGE
              DC.B    %1101 *BLT
              DC.B    %1000 *BVC
              DC.B    %0000 *BRA     
              DC.B    -1    *invalid branch type

shift_tbl     DC.B    %000
              DC.B    %001
              DC.B    %010
              DC.B    %011
              DC.B    %100
              DC.B    %101
              DC.B    %110
              DC.B    %111
                                   

INST_NAME     DS.L    2         *holds the instruction to be printed (e.g. ADD.L; MOVE.B)
INST_NAME_EXT DS.L    1         *holds any part of instruction over 32 bits (eg last M in MOVEM)
OP_NAMES      DS.L    7         *holds the operands to be printed (e.g. #5,D3; (A3),(A4)+

addr_sign     DC.B    '$',0
imm_sign      DC.B    'FIX##',0
open_paren    DC.B    '(',0
closed_paren  DC.B    ')',0
plus_sign     DC.B    '+',0
neg_sign      DC.B    '-',0
comma         DC.B    ',',0
space         DC.B    '   ',0
                            
nl            DC.B    '',CR,LF,0
display_start DC.B    'Please enter a maximum 32-bit starting memory address in hex (-1 to quit): ',0
display_end   DC.B    'Please enter a maximum 32-bit ending memory address in hex (-1 to quit): ',0
bad_addr      DC.B    'Please enter a valid address',CR,LF,0

user_start    DS.L    1
user_end      DS.L    1
exit_val      DC.W    $2D31  *sentinel exit value

done_msg      DC.B    'done',0
             



              END     start














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
