*-----------------------------------------------------------------------------------------------
*                                  Disassembler program
*                                      Winter 2018
* Description: A program to disassemble selected instructions from the Motorola 68k IS opcodes
*                         
*                          Sean Coulter, Corin Ennis, Antony Mbugua
*-----------------------------------------------------------------------------------------------            
            
CR         EQU   $0D
LF         EQU   $0A
stack      EQU   $7000
start_addr EQU   $1000
           
start      ORG     start_addr             
              
 *----------------*display starting information for user, capture start and end addresses, error check on addresses------------------------------
*----------------for each ascii character the user enters, if that character is outside [30,40) (40,46], its an invalid character---------------
    *A2: points to starting address
    *A3: points to ending address
    *A4: points to ascii/hex string table
    
    *D1: sentinel exit value
    *D2: index of MSB
    *D3: holds the next byte of the user starting address
    *D4: offset of string table value
    *D6: ascii value holding MSB
    *D7: max valid input

              LEA     stack, SP         *put the stack in the stack pointer
              
              adda.l #$12000,a5
              adda.l #$13000,a6
              
              
*------------------At this point, A5 holds starting address and A6 holds ending address. --------------------------------
*A5: start
*A6: end
*A4: pointer to hex_1 table and bcc_tbl
*D1: holds the next hex to be read in instruction
*D2: holds the instruction


              
              CLR      D4                 *register used in address calculation
              CLR      D7                 *register used for address calculation

prep          CMPA.L   A5,A6              *have we read from start-end?
              BLT      done               * yes-end            
              MOVE.B   #5,D0              *pause for user to hit enter
              TRAP     #15
              LEA      nl,A1              *make an new line
              MOVE.B   #14,D0
              TRAP     #15
              LEA      hex_1,A4           *pointer to hex_1 table in A4
              MOVEA.L  #0,A1              *clearing variables
              MOVE.L   #0,SIZECODE
              MOVE.L   #0,INST_NAME_EXT
              *EOR      D0,D0
              CLR.L    D0
              CLR.L    D1
              CLR.L    D2
              CLR.L    D3
              CLR.L    D4
              CLR.L    D5
              CLR.L    D6
              CLR.L    D7            
              MOVE.W   (A5),D1            *move the instruction thats pointed to by starting address
              MOVE.L   D1,A3              *and copy it to A3
              SWAP     D1
              ROL.L    #4,D1              *isolate the first hex digit
             
check_first   CMP.B   (A4)+,D1            *compare with the next value in the hex table
              BEQ     match_found         *theres a match with the value in the table
              ADDA    #1,A4               *increment the pointer to the table
              CMP.B   #$FF,(A4)           *have we reached the end of the hex table?
              BEQ     inv_handler         * yes-no matches (so output DATA)
              BRA     check_first         *keep searching through the table for a match           
     
*-----------------------------------------------------------------------------
* inv_handler
* handles unsupported instruction names
* prints DATA for instruction name 
                
inv_handler   MOVE.L  DAT,INST_NAME
              MOVE.L  A,INST_NAME_EXT
              JSR     disp_instr
              MOVE.L  A3,A0
              JSR     hex_2_ascii       *convert/display the unsupported opcode
              ADDA    #word_len,A5
              BRA     prep
              
* /inv_handler
*-----------------------------------------------------------------------------

**below functions handle instructions that are supported in this program**

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
              CMP.B   #5,D1
              BEQ     _5_handler
              BRA     inv_handler

*The following functions determine where to go if the first hex value is shared between instructions             
*---------------           
_1_handler    CLR.B   D1
              MOVE.L  MOV,INST_NAME
              MOVE.L  SIZEB,SIZECODE
              MOVE.B  #0,(A2)        *flag data as byte
              ROL.L   #3,D1          *isolate dest. An or Dn bits (t.b.d. if MOVE or MOVEA)
              MOVE.B  D1,D2          *and move them to D2
              CLR.B   D1
              ROL.L   #3,D1          *isolate dest. mode bits in D1.B
              CMP.B   #1,D1          *is mode == 001?
              BEQ     movea_handler * yes- its movea
              
move_handler MOVE.L  E,INST_NAME_EXT
             BRA     move_ea

movea_handler MOVE.L EA,INST_NAME_EXT     

move_ea       MOVE.B D1,D4         *save dest mode bits to D4
              CLR.B  D1
              ROL.L  #3,D1
              MOVE.L D1,D3         *save source mode/reg bits in D3
              JSR    disp_instr    *print MOVEA.(X) or MOVE.(X)
              JSR    EA_SRC_beg    *print source information
              
              ROR.L  #3,D2         *roll dest register bits to left fringe
              MOVE.B D4,D2         *move dest mode bits to right fringe
              MOVE.L D2,D3         *move these same bits to D3
              JSR    print_comma
              JSR    EA_SRC        *prints destination mode/register
              BRA    prep

*--------------- 
*---------------
_3_handler    CLR.B   D1
              MOVE.L  MOV,INST_NAME
              MOVE.L  SIZEW,SIZECODE
              MOVE.B  #1,(A2)        *flag data as word
              ROL.L   #3,D1          *isolate dest. An or Dn bits (t.b.d. if MOVE or MOVEA)
              MOVE.B  D1,D2          *and move them to D2
              CLR.B   D1
              ROL.L   #3,D1          *isolate dest. mode bits in D1.B
              CMP.B   #1,D1          *is mode == 001?
              BEQ     movea_handler * yes- its movea (function is subset of _1_handler)
              BRA     move_handler  * no- its move (function is subset of _1_handler)
              
*--------------- 
*--------------- 
_2_handler    CLR.B   D1
              MOVE.L  MOV,INST_NAME
              MOVE.L  SIZEL,SIZECODE
              MOVE.B  #2,(A2)        *flag data as long
              ROL.L   #3,D1          *isolate dest. An or Dn bits (t.b.d. if MOVE or MOVEA)
              MOVE.B  D1,D2          *and move them to D2
              CLR.B   D1
              ROL.L   #3,D1          *isolate dest. mode bits in D1.B
              CMP.B   #1,D1          *is mode == 001?
              BEQ     movea_handler * yes- its movea (function is subset of _1_handler)
              BRA     move_handler  * no- its move (function is subset of _1_handler)

*--------------- 
*--------------- 
_4_handler    CMP.W   #$4E71,A3        *is it nop
              BEQ     nop_handler      * its nop
              CMP.W   #$4E75,A3        *is it rts
              BEQ     rts_handler      * its rts
              CLR.B   D1               *get byte space ready for next digit
              ROL.L   #4,D1            *get the next digit
              MOVE.L  D1,D2            *make a temp copy
              ROL.L   #2,D2            *get another 3 bits
              CMP.B   #$3A,D2          *is 3A in the byte position
              BEQ     jsr_handler      * yes its jsr
              CMP.B   #4,D1            *is the next digit 4
              BEQ     neg_resolve      * neg or MOVE to CCR
              BRA     _4_resolve       *now its either lea,movem,unsupported
neg_resolve   CLR.B   D2
              ROL.B   #2,D2
              CMP.B   #3,D2
              BLT     neg_handler
              BRA     inv_handler                                       
_4_resolve    MOVE.L  D1,D2            *make a full copy to D2
              MOVE.L  D1,D4            *make another full copy
              LSR.B   #1,D2            *lea and movem differentiated by current MSB        
              BCS     lea_resolve      * carry set- lea or unsupported
              BRA     movem_resolve    * carry not set-movem or unsupported
lea_resolve   CLR.B   D2
              ROL.L   #2,D2            *lea is unique in bits d8 to d6. use previous copy D2
              LSL.B   #6,D2            *shift out 0 pad and remaining An bits
              CMP.B   #$C0,D2          *is result 11000000?
              BEQ     lea_handler      * lea
              BRA     inv_handler      * unsupported
movem_resolve ROL.L   #1,D4
              CMP.B   #25,D4
              BNE     movem_check      *last check on movem
is_it_movem   CLR.B   D4               *this is either MOVEM register to memory or EXT
              ROL.L   #3,D4            *get ea mode into d2
              CMP.B   #0,D4            *is the ea mode 000?
              BEQ     inv_handler      * yes-ea mode is data register-- cant be movem
              BRA     movem_handler    * no-its movem
              
movem_check   CMP.B   #17,D4          
              BNE     inv_handler      *we can be sure its not movem now
              BRA     is_it_movem      *EXT or MOVEM
                      
*--------------- 
*--------------- 
_13_handler     CLR.B   D1
                ROL.L   #4,D1
                MOVE.L  D1,D2          *make a copy
                CLR.B   D2             *clear byte space for next roll
                ROL.L   #2,D2          *get size bits
                CMP.B   #3,D2          *are size bits 11?
                BEQ     adda_handler
                BRA     add_handler

*--------------- 
*--------------- 
_0_handler      CLR.B D1
                ROL.L #4,D1         *the next 4 bits will determine the instruction exactly
                CMP.B #0,D1
                BEQ   ori_handler
                CMP.B #4,D1
                BEQ   subi_handler
                CMP.B #$A,D1
                BEQ   eori_handler
                CMP.B #8,D1
                BEQ   bclr_static
                CMP.B #$C,D1
                BEQ   cmpi_handler
                CMP.B #6,D1
                BEQ   addi_handler
                                    *at this point its BCLR or its unsupported
                MOVE.L D1,D2        *make a copy
                CLR.B  D2
                ROL.L  #2,D2        *get next 2 hardcoded bits
                CMP.B  #2,D2        *BCLR bits defined as 10
                BEQ    bclr_dynamic  *BCLR with a Dn (dynamic)
                BRA    inv_handler   *unsupported instruction

*--------------- 
*--------------- 
_11_handler     CLR.B   D1          
                ROL.L   #4,D1      *get next hex digit
                MOVE.L  D1,D2      *make a temp copy
                LSR.B   #1,D2      * eor and cmp can be differentiated by lsb in 2nd digit. check carry
                BCS     _11_resolve  *check if its eor,cpma(long), or cmpm(unsupported)
                BRA     cmpa_or_cmp  *its cmp or cmpa
_11_resolve     MOVE.L  D1,D2       *make a copy
                CLR.B   D2
                ROL.L   #2,D2
                CMP.B   #3,D2
                BEQ     cmpa_handler    *its cmpa (long)
                CLR.B   D2              *down to eor or cmpm
                ROL.L   #3,D2           *get EA mode
                CMP.B   #1,D2
                BEQ     inv_handler     *cmpm
                BRA     eor_handler     *eor
cmpa_or_cmp     CLR.B   D2
                ROL.L   #2,D2           *get the size code
                CMP.B   #3,D2           *whats the size code
                BEQ     cmpa_handler    * size code 11-cmpa
                BRA     cmp_handler     * size code !11-cmp

*---------------
*---------------
_8_handler      CLR.B   D1
                ROL.L   #4,D1
                MOVE.L  D1,D2
                LSR.B   #1,D2
                BCS     _8_check              
                CLR.B   D2                  *carry not set- OR or DIVU
                ROL.L   #2,D2
                CMP.B   #3,D2
                BEQ     inv_handler         *DIVU
                BRA     or_handler
                
_8_check        CLR.B   D2                  *its OR, DIVS, or SBCD
                ROL.L   #2,D2
                CMP.B   #3,D2
                BEQ     divsw_handler       *between or and divs.w, only divs.w can have a size 11
                CLR.B   D2
                BRA     or_handler          *figure out if its OR or SBCD in here
                    
*---------------
*--------------- 
_5_handler      CLR.B   D1
                ROL.L   #4,D1
                MOVE.B  D1,D2               *D2 now holds the immediate data
                LSR.B   #1,D2               *check if carry is set-- this will determine branch
                BCS     subq_handler
                BRA     addq_handler
                
*---------------
*--------------- 

*we can go directly to the function since the first hex val maps directly to an instruction
get_data      CMP.B   #6,D1
              BEQ     bcc_handler
              CMP.B   #$E,D1
              BEQ     _shift_roll_handler
              CMP.B   #9,D1
              BEQ     sub_handler
              CMP.B   #5,D1
              BEQ     subq_handler
              CMP.B   #$C,D1
              BEQ     muls_handler
*----------------------------------------------------------------------------
*----------------------------------------------------------------------------              
*----------------------------------------------------------------------------
*nop_handler
*handles 'NOP'

nop_handler   MOVE.L  NOP,INST_NAME 
              ADDA    #word_len,A5         *nop took up a word- set A5 to the next instruction
              JSR     disp_instr
              BRA     prep

* /nop_handler
*----------------------------------------------------------------------------


*----------------------------------------------------------------------------
*adda_handler
*handles 'ADDA'

adda_handler       MOVE.L ADD,INST_NAME  *we know its valid instr ADDA
adda_beg           MOVE.W A,INST_NAME_EXT
                   LSR.B  #1,D1                *send the size bit to carry
                   BCS    adda_long_handler    *carry is set->ADDA.W
                   BRA    adda_word_handler    *carry not set->ADDA.L
                   
adda_word_handler  MOVE.L SIZEW,SIZECODE
                   MOVE.B #1,(A2)
                   BRA    adda_save_data
                   
adda_long_handler  MOVE.L SIZEL,SIZECODE
                   MOVE.B #2,(A2)
                            
adda_save_data     JSR    disp_instr
                   MOVE.B D1,D5             *move the 3 An bits to D5 temporarily
                   ROL.L  #2,D1             *get hardcoded size bits
                   CLR.B  D1                *and clear the byte space
                   ROL.L  #3,D1
                   MOVE.L D1,D3             *send EA bits to D3
                   JSR    EA_SRC_beg
                   JSR    print_comma
                   EXG    D3,D5             *send An bits to D3 for function call
                   JSR    PRINT_INNER_An
                   BRA    prep                     

* /adda_handler
*----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* suba_handler
* handles 'SUBA'

*uses adda_handler due to similar bit layout

suba_handler       MOVE.L   SUB,INST_NAME
                   BRA      adda_beg

* /suba_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* cmpa_handler
* handles 'CMPA'

*uses adda_handler due to similar bit layout

cmpa_handler       MOVE.L   CMP,INST_NAME
                   BRA      adda_beg

* /cmpa_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*or_handler
*handles 'OR'

*D7 holds the direction flag
*D5 holds source/destination bits
*D4 holds the 2 size bits
*D3 holds the parameters used for jumps to EA handlers

*Dn_left means the Dn is the dest
*Dn_right means the Dn is the source

or_handler     ROL.L    #2,D2
               CMP.B    #0,D2
               BEQ      inv_handler    *SBCD
               MOVE.L   OR,INST_NAME
               LSR.B    #1,D1          *shift the direction bit to carry-- D1 now also holds the data register of the operation
               MOVE.B   D1,D5          *move source/destination (undertermined) Dn bits to D5
               BCS      or_Dn_right    * <ea> OR Dn
               BRA      or_Dn_left     * Dn OR <ea>
               
or_Dn_right    CLR.B    D1
               ROL.L    #2,D1
               MOVE.B   D1,D4          *D4 holds the size of the operation
               BRA      or_size

or_Dn_left     MOVE.B   #1,D7          *flag operation as Dn_left
               CLR.B    D1
               ROL.L    #2,D1
               MOVE.B   D1,D4          *D4 holds the size of the operation
or_size        CMP.B    #0,D4
               BEQ      or_byte
               CMP.B    #1,D4
               BEQ      or_word
               CMP.B    #2,D4
               BEQ      or_long
               
or_byte        MOVE.L   SIZEB,SIZECODE
               MOVE.B   #0,(A2)        *flag data as byte sized
               BRA      or_ea

or_word        MOVE.L   SIZEW,SIZECODE
               MOVE.B   #1,(A2)        *flag data as word sized
               BRA      or_ea

or_long        MOVE.L   SIZEL,SIZECODE
               MOVE.B   #2,(A2)        *flag data as long sized

or_ea          JSR      disp_instr
               CLR.B    D1
               ROL.L    #3,D1          *D1 holds the EA bits         
               MOVE.L   D1,D3          *move EA source bits to D3
               CMP.B    #1,D7
               BEQ      or_left_print
               MOVE.L   D3,D6          *temp store D3 bits in D6 for next function call
               MOVE.L   D5,D3
               JSR      DR_CMP         *print Dn bits
               JSR      print_comma
               MOVE.L   D6,D3
               JSR      EA_SRC_beg
               BRA      prep
               
or_left_print  JSR      EA_SRC_beg     *print EA bits
               MOVE.L   D5,D3          *get D5 bits in D3 for function call
               JSR      print_comma
               JSR      DR_CMP         *print Dn bits
               BRA      prep

* /or_handler
*-----------------------------------------------------------------------------


*----------------------------------------------------------------------------
*add_handler
*handles 'ADD'
* heavily uses the or_handler function as the instruction formats are equivalent after the first nibble

add_handler    MOVE.L  ADD,INST_NAME
               LSR.B   #1,D1
               MOVE.B  D1,D5        *isolate direction bits
               BCS     or_Dn_right  *<ea> + Dn -> <ea>
               BRA     or_Dn_left   *Dn + <ea> -> Dn
       
* /add_handler
*----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*sub_handler
* handles 'SUB'

sub_handler         MOVE.L  SUB,INST_NAME
                    CLR.B   D1
                    ROL.L   #4,D1
                    MOVE.L  D1,D2         *make a copy
                    CLR     D2
                    ROL.L   #2,D2
                    BEQ     suba_handler  *its suba (hardcoded size bits)
                    LSR.B   #1,D1         *determine direction of sub
                    MOVE.B  D1,D5         *move Dn and direction bits to D5
                    BCS     or_Dn_right   * <ea> SUB Dn -> <ea>
                    BRA     or_Dn_left    * Dn SUB <ea> -> Dn            

* /sub_handler
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
 * eor_handler  
 * handles 'EOR'

eor_handler         MOVE.L   EOR,INST_NAME
                    LSR.B    #1,D1           *get rid of direction bit--we know its 1
                    MOVE.B   D1,D5           *copy data register number in d1 to d5
                    BRA      or_Dn_right
                    
* /eor_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* cmp_handler
* handles 'CMP'

cmp_handler         MOVE.L   CMP,INST_NAME
                    LSR.B    #1,D1        *get rid of hardcoded 0
                    MOVE.B   D1,D5        *save Dn bits to D5
                    BRA      or_Dn_left

* /cmp_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*divsw_handler
*handles 'DIVS'(.W)
* .W is implicit

divsw_handler   MOVE.L DIV,INST_NAME
                MOVE.W S,INST_NAME_EXT
divsw_beg       JSR    disp_instr
                LSR.B  #1,D1        *get rid of hardcoded bit
                CLR.L  D2           *clear space in D2
                MOVE.B D1,D2        *save Dn destination register to D2
                MOVE.L D2,D4        *get them into D4 for use after next function call
                CLR.B  D1
                LSL.L  #2,D1        *Shift out size bits--we already know its a word
                ROL.L  #3,D1        *D1 now holds the EA bits
                MOVE.L D1,D3        *and move them to D3
                JSR    EA_SRC_beg   *print source EA info
                JSR    print_comma
                MOVE.L D4,D3        *move the destination register bits to D3 for next call
                JSR    DR_CMP       *print the data register
                BRA    prep

* /divsw_handler
*-----------------------------------------------------------------------------

                  
*-----------------------------------------------------------------------------
*muls_handler
* handles 'MULS'

*uses divsw function as layout is similar after first 4 bits

muls_handler      CLR.B   D1
                  ROL.L   #4,D1             *get the next hex digit after 0xC
                  MOVE.L  D1,D2
                  LSR.B   #1,D2
                  BCC     inv_handler       *unsupported opcode
                  CLR.B   D2
                  ROL.L   #2,D2             *get the size bits of the operation
                  CMP.B   #3,D2
                  BNE     inv_handler       *unsupported if size code != 11 at this point
                  MOVE.L  MUL,INST_NAME     *now were sure its muls
                  MOVE.L  S,INST_NAME_EXT
                  JSR     divsw_beg

*/muls_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*subq_handler
* handles 'SUBQ' (data [1,8])

subq_handler       MOVE.L  SUB,INST_NAME
subq_det           MOVE.L  Q,INST_NAME_EXT
                   CLR.B   D1
                   ROL.L   #2,D1            *isolate size bits
                   CMP.B   #0,D1
                   BEQ     subq_byte
                   CMP.B   #1,D1
                   BEQ     subq_word
                   CMP.B   #2,D1
                   BEQ     subq_long
                   BRA     inv_handler     *size > 2 means it's an unsupported opcode
subq_byte          MOVE.L  SIZEB,SIZECODE
                   MOVE.B  #0,(A2)
                   BRA     subq_ea
subq_word          MOVE.L  SIZEW,SIZECODE
                   MOVE.B  #1,(A2)            *flag it as a word
                   BRA     subq_ea
subq_long          MOVE.L  SIZEL,SIZECODE
                   MOVE.L  #2,(A2)            *flag it as a long
                   BRA     subq_ea 

subq_ea            CLR.B   D1               *prep byte space
                   ROL.L   #3,D1            *get EA bits
                   MOVE.L  D1,D3            *put them in D3
                   MOVE.L  D2,D1            *move immediate data bits back to D1 for display
                   JSR     disp_instr
                   CMP.B   #0,D1
                   BEQ     case_quick8     *8 (base 0) is represented as 000 in data field.
q_prints           LEA     imm_sign, A1    *load and print '#' character
                   MOVE.B  #14,D0
                   TRAP    #15
                   MOVE.B  #3,D0
                   TRAP    #15              *display immediate [1-8] data 
                   JSR     print_comma               
                   JSR     EA_SRC_beg
                   BRA     prep
           
case_quick8        MOVE.B  #8,D1           *move the number 8 to D1, replacing 0  
                   BRA     q_prints     

* /subq_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*addq_handler
*handles 'ADDQ', or adds with data [1,8]

*uses subq_handler due to similar bit layout

addq_handler      MOVE.L  ADD,INST_NAME
                  BRA     subq_det          *SUBQ and ADDQ equivalent instruction layout hereafter   

* /addq_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* cmpi_handler
* handles cmpi

*D1 holds instruction info, then EA info (mode & reg)
*D2: holds the size of the operation (b,w,l)

*size bits also indicate the size of immediate data after the instruction

cmpi_handler       MOVE.L   CMP,INST_NAME
                   MOVE.B   I,INST_NAME_EXT
                   CLR.B    D1
                   ROL.L    #2,D1               *isolate the size bits
                   MOVE.B   D1,D4               *move size bits to D4
                   CMP.B    #0,D4
                   BEQ      cmpi_byte
                   CMP.B    #1,D4
                   BEQ      cmpi_word
                   CMP.B    #2,D4
                   BEQ      cmpi_long
cmpi_byte          MOVE.L   SIZEB,SIZECODE      *indicate the operation is a byte
                   MOVE.B   #0,(A2)
                   BRA      cmpi_ret
cmpi_word          MOVE.L   SIZEW,SIZECODE      *indicate the operation is a word
                   MOVE.B   #1,(A2)      
                   BRA      cmpi_ret
cmpi_long          MOVE.L   SIZEL,SIZECODE      *indicate the operation is a long
                   MOVE.B   #2,(A2)  
cmpi_ret           ADDA     #word_len,A5        *set pointer to next word- all data in cmpi is either next word or next 2 words(long)
                   JSR      disp_instr
                   CLR.B    D1
                   JSR      DATA_MODE           *determine and print the immediate data based on size
                   CMP.B    #2,(A2)
                   ROL.L    #3,D1               *isolate EA info in D1
                   MOVE.L   D1,D3
                   JSR      print_comma
                   JSR      EA_SRC              *obtain and print the destination information
                   BRA      prep
                   
* /cmpi_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*bclr_static and bclr_dynamic
*(bclr_handler)
*handles 'BCLR' with a data register or its static counterpart (no register)

bclr_static       ROL.L     #2,D1          *get 2 more bits-- are we sure its BCLR?
                  CMP.B     #34,D1         *static BCLR bits 11 to 6
                  BNE       inv_handler    *unsupported opcode
                  MOVE.L    BCL,INST_NAME  *we now know its bclr
                  MOVE.L    R,INST_NAME_EXT
                  JSR       disp_instr
                  CLR.B     D1             
                  ROL.L     #3,D1          *isolate the EA mode and register
                  MOVE.L    D1,D3
                  ADDA      #word_len,A5   *get the trailing immediate data
                  CLR.L     D1
                  *MOVE.W    (A5),D1        *move it to D1
                  JSR       DATA_MODE      *and print it
                  SUBA      #word_len,A5   *return to instruction
                  JSR       print_comma
                  JSR       EA_SRC_beg     *print EA dest information
                  BRA       prep    

bclr_dynamic      LSR.B     #1,D1          *discard hardcoded bit 
                  MOVE.L    BCL,INST_NAME
                  MOVE.L    R,INST_NAME_EXT
                  JSR       disp_instr
                  MOVE.B    D1,D3          *store Dn bits in D3
                  JSR       DR_CMP         *print appropriate data register
                  JSR       print_comma
                  CLR.B     D1
                  LSL.L     #2,D1          *clear hardcoded bits
                  ROL.L     #3,D1          *get ea bits
                  MOVE.L    D1,D3          *put them in D3
                  JSR       EA_SRC_beg     *print EA info
                  BRA       prep
                 

* /bclr_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*ori_handler
*handles 'ORI'
    
*heavily uses cmpi_handler due to similar layout in bits d7 to d0

ori_handler       MOVE.L   ORI,INST_NAME
                  CLR.B    D1
                  ROL.L    #2,D1           *0 currently occupies the byte, so can immediately roll
                  MOVE.B   D1,D4           *move size bits to D2
                  CLR.B    D2
                  ROL.L    #3,D2           *get EA mode bits
                  CMP.B    #7,d2           *are EA mode bits 111?
                  BEQ      inv_handler     *invalid ORI type (SR,CCR)
                  CMP.B    #0,D4
                  BEQ      cmpi_byte
                  CMP.B    #1,D4
                  BEQ      cmpi_word
                  CMP.B    #2,D4
                  BEQ      cmpi_long

* /ori_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* addi_handler
* handles 'ADDI'

*heavily uses cmpi_handler due to similar layout in bits d7 to d0

addi_handler      MOVE.L   ADD,INST_NAME
                  MOVE.L   I,INST_NAME_EXT
                  CLR.B    D1
                  ROL.L    #2,D1           *0 currently occupies the byte, so can immediately roll
                  MOVE.B   D1,D4           *move size bits to D2
                  CMP.B    #0,D4
                  BEQ      cmpi_byte
                  CMP.B    #1,D4
                  BEQ      cmpi_word
                  CMP.B    #2,D4
                  BEQ      cmpi_long

* /addi_handler
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
* eori_handler
* handles 'EORI'

*heavily uses cmpi_handler due to similar layout in bits d7 to d0

eori_handler      MOVE.L   EOR,INST_NAME
                  MOVE.L   I,INST_NAME_EXT
                  CLR.B    D1
                  ROL.L    #2,D1           *0 currently occupies the byte, so can immediately roll
                  MOVE.B   D1,D4           *move size bits to D2
                  CMP.B    #0,D4
                  BEQ      cmpi_byte
                  CMP.B    #1,D4
                  BEQ      cmpi_word
                  CMP.B    #2,D4
                  BEQ      cmpi_long



* /eori_handler
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
* subi_handler
* handles 'SUBI'

*heavily uses cmpi_handler due to similar layout in bits d7 to d0

subi_handler     MOVE.L   SUB,INST_NAME
                 MOVE.L   I,INST_NAME_EXT
                 CLR.B    D1
                 ROL.L    #2,D1           *0 currently occupies the byte, so can immediately roll
                 MOVE.B   D1,D4           *move size bits to D2
                 CMP.B    #0,D4
                 BEQ      cmpi_byte
                 CMP.B    #1,D4
                 BEQ      cmpi_word
                 CMP.B    #2,D4
                 BEQ      cmpi_long

* /subi_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*neg_handler
*handles neg

*D1: holds opcode
*D4: holds size of operation (b,w,l)

neg_handler      MOVE.L   NEG,INST_NAME
                 CLR.B    D1   
                 ROL.L    #2,D1           *0 currently occupies the byte, so can immediately roll
                 MOVE.B   D1,D4           *move size bits to D4
                 CMP.B    #0,D4           *determine size based on bits (00=byte) (01=word) (10=long)
                 BEQ      neg_byte
                 CMP.B    #1,D4
                 BEQ      neg_word
                 CMP.B    #2,D4
                 BEQ      neg_long
  
neg_byte         MOVE.L   SIZEB,SIZECODE
                 BRA      neg_ret
neg_word         MOVE.L   SIZEW,SIZECODE
                 BRA      neg_ret
neg_long         MOVE.L   SIZEL,SIZECODE   
neg_ret          JSR      disp_instr
                 ROL.L    #3,D1           *isolate EA bits
                 MOVE.L   D1,D3           *move those EA bits to D3
                 JSR      EA_SRC_beg      *display EA info we're negating


* /neg_handler
*-----------------------------------------------------------------------------


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
              MOVE.B  D1,D3          *copy condition value to D3
              LEA     bcc_tbl,A4     *A4 now points to the bcc_tbl
bcc_cond      CMP.B   #-1,(A4)       *have we reached the end of the table
              BEQ     inv_bcc_handler  * yes-invalid branch
              CMP.B   (A4)+,D3       *compare the next table value
              BEQ     bcc_determiner * there's a match
              BRA     bcc_cond       *continue looping through the table

bcc_determiner  CMP.B  #5,-(a4)      *determine path based on condition code from table (in data section)
                BEQ    bcs_handler
                CMP.B  #12,(a4)
                BEQ    bge_handler
                CMP.B  #13,(a4)
                BEQ    blt_handler
                CMP.B  #8,(a4)
                BEQ    bvc_handler
                CMP.B  #0,(a4)
                BEQ    bra_handler
                CMP.B  #4,(a4)
                BEQ    bccd_handler
                CMP.B  #6,(a4)
                BEQ    bne_handler
                CMP.B  #7,(a4)
                BEQ    beq_handler
                CMP.B  #9,(a4)
                BEQ    bvs_handler
                CMP.B  #$E,(a4)
                BEQ    bgt_handler
                CMP.B  #$F,(a4)
                BEQ    ble_handler
                BRA    inv_bcc_handler      *before displaying unsupported opcode message,advance address pointer
                                            *to account for known displacement after this unsupported branch
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
bccd_handler  MOVE.L  BCC,INST_NAME
              BRA     bcc_dispm
bne_handler   MOVE.L  BNE,INST_NAME
              BRA     bcc_dispm
beq_handler   MOVE.L  BEQ,INST_NAME
              BRA     bcc_dispm
bvs_handler   MOVE.L  BVS,INST_NAME
              BRA     bcc_dispm
bgt_handler   MOVE.L  BGT,INST_NAME
              BRA     bcc_dispm
ble_handler   MOVE.L  BLE,INST_NAME
              BRA     bcc_dispm

bcc_dispm     MOVE.L  A5,D4            *copy current address to D4
              ADDA    #word_len,A5     *all Bcc instructions took up a word         
              CLR.B   D1               *now find the displacement- (A5 +- last 2 nibbles)
              ROL.L   #8,D1            *get the last 2 displacement nibbles
              CMP.B   #0,D1            *are the 8 displacement bits all 0?
              BEQ     bcc_word_handler * yes- get the following displacement word
              CMP.B   #$F,D1           *are all displacement bits 1?
              BEQ     bcc_long_handler * yes-get the displacement long
bcc_calc      NOT.L   D1               *ones complement
              ADDI.L  #1,D1            *twos complement 
              ADDI.B  #2,D4            *account for PC displacement 2 bytes ahead of current address
              SUB.W   D1,D4            *calculate displacement address  ****.L OR .W
              BRA     bcc_complete
              
bcc_word_handler  MOVE.W (A5)+,D1    *put 16 displacement bits in D1
                  BRA     bcc_calc
                  
bcc_long_handler  MOVE.L (A5)+,D1    *put 32 displacement bits in D1
                  BRA     bcc_calc

bcc_complete  JSR     disp_instr
              MOVE.L  D4,A0      *move displacement address to A0 for next function
              JSR     print_addr_sgn
              JSR     hex_2_ascii
              BRA     prep
                   
inv_bcc_handler    CLR.B D1         
                   ROL.L #8,D1          *get the 8 bit displacement of this unsupported branch
                   CMP.B #0,D1          *did the branch need a word displacement
                   BEQ   inv_bcc_word   * branch included a trailing word displacement
                   CMP.B #$FF,D0        *did the branch need a long displacement
                   BEQ   inv_bcc_long   * branch included a trailing long displacement
                   BRA   inv_handler    *branch instruction was self-contained
inv_bcc_word       ADDA #word_len,A5    *skip over the word displacement
                   BRA  inv_handler
inv_bcc_long       ADDA #long_len,A5    *skip over the long displacement
                   BRA  inv_handler

 */bcc_handler            
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
 * shift_roll_handler   
 * handles 'LSR','LSL','ASR','ASL','ROL','ROR'

 
 *A5: holds the current address of this instruction
 *D2: used to check if its a shift or roll, immediate or register
 *D3: holds the size (b,w,l) of the operation
 *D4: holds the immediate data (1-7) or the register number of the source
 *D5: flags source as immediate or register 1=reg, 0=imm (only used in sr_reg)
 
_shift_roll_handler  CLR.B    D1
                     ROL.L    #4,D1            *get next 4 bits in this shift/roll
                     MOVE.L   D1,D2
                     LSR.B    #1,D2            *set the carry to be the direction of this shift/rotate
                     BCS      sr_type_resolve  * carry is set- its leftwards
                     MOVE.L   R,INST_NAME_EXT  *we know its a rightwards operation
                     BRA      sr_type_resolve_beg  * carry is set- rightwards

*now determine if its a memory or register shift                  
sr_type_resolve      MOVE.L   L,INST_NAME_EXT   *we know its a leftwards operation
sr_type_resolve_beg  MOVE.B   D2,D4          *D4 now holds the count/register bits
                     CLR.B    D2
                     ROL.L    #2,D2          *get next 2 (size) bits
                     MOVE.B   D2,D3          *move size bits to D3 
                     CLR.B    D2             *clear size bits from D2
                     CMP.B    #3,D3          *are size bits 11?
                     BEQ      sr_mem         * yes-memory shift
                     BRA      sr_reg         * no-register shift
                     
*its a memory shift/roll,so exact instruction lies in D4. First get type, then get direction later        
sr_mem               CMP.B   #0,D4          *D4 holds instruction type. which one is it?
                     BEQ     as_handler
                     CMP.B   #1,D4
                     BEQ     ls_handler
                     CMP.B   #3,D4
                     BEQ     ro_handler
                     BRA     inv_handler    *unsupported
                     
as_handler           MOVE.L  AS,INST_NAME   *its AS(R/L)
                     BRA     sr_mem_ret
ls_handler           MOVE.L  LS,INST_NAME   *its LS(R/L)
                     BRA     sr_mem_ret
ro_handler           MOVE.L  RO,INST_NAME   *its RO(R/L)
                     BRA     sr_mem_ret

sr_mem_ret           JSR     disp_instr     *display the instruction (eg 'ASR','ROL')  
                     ROL.L   #3,D2          *partition EA bits            
                     MOVE.B  D2,D3          *and send them to D3 for next function call
                     JSR     EA_SRC_beg     *display EA info
                     BRA     prep

*its a register shift/roll so D4 holds the register/immediate shift count
sr_reg               LSL.L   #1,D2          *send i/r bit to carry
                     BCS     sr_reg_type
                     MOVE.B  #0,D5              *flag operation as immediate shift on register
                     BRA     sr_reg_type_beg
                     
sr_reg_type          MOVE.B  #1,D5              *flag operation as register shift on register
sr_reg_type_beg      CLR.B   D2 
                     CMP.B   #0,D3              *compare size bits to determine operation size
                     BEQ     sr_byte    
                     CMP.B   #1,D3
                     BEQ     sr_word    
                     CMP.B   #2,D3
                     BEQ     sr_long

sr_byte              MOVE.L  SIZEB,SIZECODE     *its a byte operation
                     BRA     sr_reg_ret
sr_word              MOVE.L  SIZEW,SIZECODE     *itsva a word operation
                     BRA     sr_reg_ret
sr_long              MOVE.L  SIZEL,SIZECODE     *its a long operation
                     BRA     sr_reg_ret  

sr_reg_ret           CLR.B   D2
                     ROL.L   #2,D2              *get the 2 type identifying bits
                     CMP.B   #0,D2
                     BEQ     as_reg
                     CMP.B   #1,D2
                     BEQ     ls_reg
                     CMP.B   #3,D2
                     BEQ     ro_reg
                     BRA     inv_handler        *its unsupported
                     
as_reg               MOVE.L  AS,INST_NAME       *its AS(L/R)
                     BRA     sr_reg_final

ls_reg               MOVE.L  LS,INST_NAME       *its LS(L/R)
                     BRA     sr_reg_final
                     
ro_reg               MOVE.L  RO,INST_NAME       *its RO(L/R)
                     BRA     sr_reg_final

sr_reg_print_src     MOVE.B  D4,D3              *move source bits to D3
                     MOVE.L  D4,D1              *and to D1
                     CMP.B   #1,D5
                     BEQ     sr_reg_print_Dn
                     CMP.B   #0,D1              *we know source is immediate-- is it 000(= #8)?
                     BEQ     rs_0_shift_handler * yes-load D1 with appropriate dislay data 
sr_reg_print_imm     *JSR     data_mode_print        *identify and print immediate data
                     LEA     imm_sign,A1        *load up the pound sign
                     MOVE.B  #14,D0
                     TRAP    #15
                     MOVE.B  #3,D0              *prep the shift count for display
                     TRAP    #15
                     RTS                      
sr_reg_print_Dn      JSR     DR_CMP                 *identify and print dest register
                     RTS

rs_0_shift_handler   MOVE.B  #8,D1
                     BRA     sr_reg_print_imm
              
sr_reg_final         JSR     disp_instr
                     CLR.B   D2
                     ROL.L   #3,D2          *get dest Dn bits in D2
                     JSR     sr_reg_print_src   *determine if source is register/immediate based on D5 flag, print
                     JSR     print_comma
                     MOVE.B  D2,D3          *move dest bits to D3
                     JSR     DR_CMP         *print destination register
                     ADDA    #word_len,A5   *reg shift/roll took up a word
                     BRA     prep           
                                    
 * /_shift_roll_handler  
*-----------------------------------------------------------------------------

                        
*-----------------------------------------------------------------------------
* lea_handler
* handles lea

*D1: holds opcode instruction
*D2: holds register bits

lea_handler       LSR.B     #1,D1          *hardcoded bit
                  MOVE.L    D1,D2          *save dest An bits to D2
                  CLR.B     D1
                  LSL.L     #2,D1          *hardcoded bits
                  ROL.L     #3,D1
                  MOVE.L    D1,D3          *get EA bits into D3
                  MOVE.L    LEA,INST_NAME
                  JSR       disp_instr       
                  JSR       EA_SRC_beg
                  JSR       print_comma
                  MOVE.L    D2,D3
                  JSR       PRINT_INNER_An     
                  BRA       prep
                  
                  
* /lea_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*jsr_handler
*handles 'JSR'

jsr_handler       MOVE.L  JSR,INST_NAME
                  JSR     disp_instr
                  CLR.B   D2            *clear byte space for next few bits
                  ROL.L   #3,D2         *save EA bits into D2
                  MOVE.L  D2,D3
                  JSR     EA_SRC_beg
                  BRA     prep

* /jsr_handler
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*movem_handler
*handles 'MOVEM'

*An list corresponds to higher byte
*Dn list corresponds to lower byte

*D2:holds first register in sublist
*D3:holds the number of successive 1's shifted out of a list (register train)
*D4:holds number of iterations for shifting out the bits in the list bytes. also the register number.
*D5:holds the An list byte
*D6:holds the Dn list byte

movem_handler  MOVE.L  MOV,INST_NAME
               MOVE.L  EM,INST_NAME_EXT
               CMP.B   #$8,D1
               BEQ     movem_dn
movem_an       CLR.B   D1
               LSL.L   #2,D1
               BCS     movem_long
               
movem_word     MOVE.L  SIZEW,SIZECODE
               BRA     movem_list
movem_long     MOVE.L  SIZEL,SIZECODE
               BRA     movem_list

movem_dn       CLR.B   D1
               LSL.L   #2,D1
               BCS     movem_long
               BRA     movem_word

movem_list     JSR     disp_instr
               ADDA    #word_len,A5                 *get to register list word
               MOVE.W  (A5),D5                      *move entire list to D5
               MOVE.B  D5,D6                        *move lower order byte (Dn list) to D6
               LSR.W   #word_len*4,D5               *shift the An list to the lower order of D5                  
               MOVE.L  #1,D4                        *init loop counter/register number
               CLR.L   D2                           *clear D2, which is holding first register in train
               CLR.L   D3                           *set train counter to 1
               BRA     movem_dn_list_loop           *first take care or the Dn list
   
movem_dn_list_loop     CMP.B  #word_len*4,D4        *have we done the register list [d0,d6]?
                       BEQ    movem_dn_last         * yes get the last register bit (d7)
                       LSR.B  #1,D6                 *shift out a (Dn) bit. 1 if its in the list, 0 if not
                       BCS    movem_dn_list_status_1  *a register was identified--check status of register train
                       ADDI   #1,D4
                       BRA    movem_dn_list_loop    *check status
                    
movem_dn_list_status_1 EXG    D3,D4                 *print appropriate data register corresponding to shifted out bit
                       SUBI   #1,D3
                       JSR    DR_CMP
                       JSR    print_slash
                       ADDI   #1,D3
                       EXG    D3,D4
                       ADDI   #1,D4
                       BRA    movem_dn_list_loop   *return to the loop                                   
                        
movem_dn_last          LSR.B  #1,D6
                       BCS    movem_d7_print
                       BRA    movem_an_list_prep
                        
movem_d7_print         MOVE.B #7,D3
                       MOVE.B #1,D0                 *flag d7 as having been printed for next round of An's
                       JSR    DR_CMP
                       
movem_an_list_prep     EXG    D5,D6                 *get higher order (an) byte
                       MOVE.L #1,D4                 *init loop
                       CLR.B  D3   
movem_an_list_loop     CMP.B  #word_len*4,D4        *have we done the register list [d0,d6]?
                       BEQ    movem_an_last         * yes get the last register bit (d7)
                       LSR.B  #1,D6                 *shift out a (Dn) bit. 1 if its in the list, 0 if not
                       BCS    movem_an_list_status_1  *a register was identified--check status of register train
                       ADDI   #1,D4
                       BRA    movem_an_list_loop    *check status
                    
movem_an_list_status_1 EXG    D3,D4                 *continue in same way as Dn loop
                       SUBI   #1,D3
                       JSR    print_slash
                       JSR    PRINT_INNER_AN
                       ADDI   #1,D3
                       EXG    D3,D4
                       ADDI   #1,D4
                       BRA    movem_an_list_loop                                      
                        
movem_an_last          LSR.B  #1,D6
                       BCS    movem_a7_print
                       BRA    movem_ea
                        
movem_a7_print         MOVE.B #7,D3
                       JSR    print_slash
                       JSR    PRINT_INNER_AN
              
             
movem_ea       JSR     print_comma
               CLR.B   D1
               ROL.L   #3,D1            *get EA bits
               MOVE.L  D1,D3            *and put them into D3
               JSR     EA_SRC_beg       *identify and print destination
               BRA     prep

* /movem_handler
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
* rts_handler
* handles 'RTS'

rts_handler    CLR.L  D1                    *rts all hardcoded
               MOVE.L RTS,INST_NAME
               JSR    disp_instr
               ADDA   #word_len,A5          *rts took up a word
               BRA    prep

* /rts_handler
*-----------------------------------------------------------------------------



*below functions also increment address pointer A5 depending on data fetch size for immediate,absolute addresses

EA_SRC_beg  ADDA   #word_len,A5             *increment pointer to next word in address range

            *(xxx).W, (xxx).L, #<data>        
EA_SRC      CMPI.B #$7, D3            *Compares if its 111
               BEQ FILTER_EA_MODE

            *Dn
            CMPI.B #$0, D3           *Compares if its 000
                
                BEQ DATA_REGISTER
                
            CMPI.B #1, D3               *001
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
                
                BNE INVALID_MODE      *e.g. ARI,PCI

FILTER_EA_MODE
        *Rotate to get register as byte
        CLR.B  D3
        ROL.L  #3,D3
         
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


INVALID_MODE    *unsupported mode eg PCD,PCI
    MOVE.L  #INV,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    ADDA    #2,A5   ******* inv opcodes take up a word
    
    RTS
    
*An
ADDRESS_MODE  *Get register to get what Dn to go to
    CLR.B  D3
    ROL.L  #3,D3
    BRA    PRINT_INNER_An

* Dn
DATA_REGISTER    *Get register to get what Dn to go to
    CLR.B  D3
    ROL.L  #3,D3
    
DR_CMP  CMPI.B #0, D3
        BEQ PRINT_D0
    CMPI.B #1, D3
        BEQ PRINT_D1
    CMPI.B #2, D3
        BEQ PRINT_D2
    CMPI.B #3, D3
        BEQ PRINT_D3
    CMPI.B #4, D3
        BEQ PRINT_D4
    CMPI.B #5, D3
        BEQ PRINT_D5
    CMPI.B #6, D3
        BEQ PRINT_D6
    CMPI.B #7, D3
        BEQ PRINT_D7
    
* (An)
CLOSED_PARAN  *Get register to get what Dn to go to
    CLR.B  D3
    ROL.L  #3,D3
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
    CLR.B  D3
    ROL.L  #3,D3
    
    *Prints '('
    LEA open_paren, A1
    MOVE.B #14, D0
    TRAP #15

    
    *Print The appropriate value of An
    JSR PRINT_INNER_An
    
    *Prints ')'
    LEA closed_paren, A1
    MOVE.B #14, D0
    TRAP #15
    
     *Prints '+'
    LEA plus_sign, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
    
*-(An)
PREFIX_MINUS   CLR.B  D3
    ROL.L  #3,D3
    
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
WORD_MODE  MOVEM.L  D1,-(SP)      *save calling state of D1
           CLR.L    D1
           *ADDA     #word_len,A5  *increment the pointer to the next address by the length of the next WORD fetched from memory
           JSR      print_addr_sgn
           MOVE.W   (A5)+,A0      *move that word value to A0 for display
           JSR      hex_2_ascii   *convert/display the word
           MOVEM.L  (SP)+,D1      *restore D1
           RTS
    
*(xxx).L 
LONG_MODE  MOVEM.L  D1,-(SP)      *save calling state of D1
           CLR.L    D1
           *ADDA     #long_len,A5 *increment the pointer to the next address by the length of the next LONG fetched from memory
           JSR      print_addr_sgn
           MOVE.L   (A5)+,A0      *move that long value to A0 for display
           JSR      hex_2_ascii   *convert/display the long in A0
           MOVEM.L  (SP)+,D1      *restore D1
           RTS
           

*#<data>
DATA_MODE  MOVEM.L  D1,-(SP)        *save calling state of D1
           CLR.L    D1 
           CMP.B    #1,(A2)         *is immediate data flagged as a word?
           BEQ      word_data_handler
           CMP.B    #2,(A2)         *is immediate data flagged as a long?
           BEQ      long_data_handler         

                                    *then its a byte held as a word 

*byte_data_handler *ADDA     #byte_len,A5
 *                 MOVE.B   (A5)+,D1     *get immediate byte data and increment address by a byte
  *                BRA      data_mode_print
                
word_data_handler *ADDA     #word_len,A5
                  MOVE.W   (A5)+,D1     *get immediate word data and increment address by a word
                  BRA      data_mode_print

long_data_handler *ADDA     #long_len,A5
                  MOVE.L   (A5)+,D1     *get immediate long data and increment address by a long
                  BRA      data_mode_print

data_mode_print   LEA      imm_sign, A1    *load and print '#' character
                  MOVE.B   #14, D0
                  TRAP     #15  
                  MOVE.L   D1,A0
                  JSR      hex_2_ascii  *print the hex data
                  MOVEM.L  (SP)+,D1     *restore D1
                  RTS

PRINT_D0 LEA D0_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D0_MESS  DC.W 'D0',0


PRINT_D1 LEA D1_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D1_MESS  DC.W 'D1',0


PRINT_D2 LEA D2_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D2_MESS  DC.W 'D2',0


PRINT_D3 LEA D3_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D3_MESS  DC.W 'D3',0


PRINT_D4 LEA D4_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D4_MESS  DC.W 'D4',0


PRINT_D5 LEA D5_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D5_MESS  DC.W 'D5',0


PRINT_D6 LEA D6_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D6_MESS  DC.W 'D6',0

PRINT_D7 LEA D7_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
D7_MESS  DC.W 'D7',0
    

PRINT_A0 LEA A0_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A0_MESS DC.W 'A0',0

PRINT_A1 LEA A1_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A1_MESS DC.W 'A1',0

PRINT_A2 LEA A2_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A2_MESS DC.W 'A2',0

PRINT_A3 LEA A3_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A3_MESS DC.W 'A3',0

PRINT_A4 LEA A4_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A4_MESS DC.W 'A4',0

PRINT_A5 LEA A5_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A5_MESS DC.W 'A5',0

PRINT_A6 LEA A6_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A6_MESS DC.W 'A6',0

PRINT_A7 LEA A7_MESS, A1
    MOVE.B #14, D0
    TRAP #15
    RTS
A7_MESS DC.W 'A7',0
              
*-----------------------------------------------------------------------------------------
*disp_instr
* displays the instruction name in assembly and the address of the instruction

disp_instr    MOVEM.L D1, -(SP)     *save state of D1 before using it below

              JSR     print_addr_sgn *print '$'
              MOVEA.L A5,A0          *load A0 with the current address for the next function
              JSR     hex_2_ascii    *convert the hex addr to ascii to print
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA.L   INST_NAME,A1  *move the (assembly) name of this instruction into A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     INST_NAME_EXT,A1  *if the instruction name was longer than 32 bits
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA.L   SIZECODE,A1       *print size of operation
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              
              MOVEM.L  (SP)+,D1         *restore D1
              RTS
              
* /disp_instr
*-----------------------------------------------------------------------------------------  


*----------------------------------------------------------------------------------------- 
*hex_2_ascii
* converts a hex number to its ascii string equivalent (0s in MSB positions).

* move A0 into D3 and split first part of address and second part of address 
*   to D3 and D4 respectively

*D3:less significant word of address
*D4:more significant word of address 
*D5:holds iteration number
*D6:index into table

h2a_regs        REG     D1/D3-D6/A0/A4

hex_2_ascii     MOVEM.L h2a_regs,-(SP)  *save state of registers before call                                
                CLR.L   D5              *clear iteration counter
                CLR.L   D1
                CLR.L   D6
                MOVE.L  A0,D4           *save address in D4
                MOVE.L  D4,D3           *and move it to D3
                CLR.W   D4              
                SWAP    D3              *partition the first and second long of the address
                CLR.W   D3
h2a_prep        LEA.L   string_tbl,A4
                ROL.L   #4,D4           *roll first byte over for analysis
h2a_loop        CMP.B   1(A4,D6.L),D4   *find hex/ascii match in table
                BEQ     h2a_match
                cmp.b   #32,d6
                BGE     h2a_f 
                ADDI.L  #2,D6
                BRA     h2a_loop
h2a_f           MOVE.B  #$F,D1
                BRA     h2a_match_cont        
h2a_match       MOVE.B  (A4,D6.W),D1    *move the match to D1
h2a_match_cont  MOVE.B  #6,D0           *display the value in D1
                TRAP    #15
                CLR.B   D4
                CLR.B   D6
                ADDI    #1,D5           *increment loop counter
                CMP.B   #h2a_its,D5     *have we done every nibble
                BGE     h2a_ret
                CMP.B   #h2a_its-4,D5   *are we halfway done (time to get second part of addr?)
                BEQ     h2a_swap
                BRA     h2a_prep
h2a_swap        MOVE.L  D3,D4           *move second part of word to D4 
                CLR.L   D6              *clear the index into the string table               
                BRA     h2a_prep

h2a_ret         MOVEM.L  (SP)+,h2a_regs   *restore state of registers 
                RTS
                
h2a_its         EQU     8

* /hex_2_ascii
*----------------------------------------------------------------------------------------- 
* the following functions print characters commonly used by this program

print_comma   MOVEM.L A1,-(SP)
              LEA     comma,A1
              MOVE.B  #14,D0
              TRAP    #15    
              MOVEM.L (SP)+,A1
              RTS    
              
print_addr_sgn MOVEM.L A1,-(SP)
               LEA     addr_sign,A1
               MOVE.B  #14,D0
               TRAP    #15    
               MOVEM.L (SP)+,A1
               RTS    
               
print_slash    MOVEM.L A1,-(SP)
               LEA     slash,A1
               MOVE.B  #14,D0
               TRAP    #15    
               MOVEM.L (SP)+,A1
               RTS    
               
print_hyphen   MOVEM.L A1,-(SP)
               LEA     neg_sign,A1
               MOVE.B  #14,D0
               TRAP    #15    
               MOVEM.L (SP)+,A1
               RTS                 
               
done          LEA     nl,A1
              MOVE.B  #14,D0
              TRAP    #15
              LEA     done_msg,A1
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
              *BRA     disp_msg      *go back to welcome msg
                         
fatal_err     LEA     imm_sign,A1   *load the error msg into A1
              MOVE.B  #14,D0       *indicate output
              TRAP    #15
              LEA     nl,A1        *load new line into A1
              MOVE.B  #14,D0        *indicate output
              TRAP    #15
              CLR.L   D2            *reset msb index for further iterations
              BRA     done         *go back to welcome msg
              
*-------------------------------------------------------------------------------------------------------------------------------------------              
data          ORG     $4000
              
*string table for converting user input addresses from ascii to hex      
string_tbl    DC.B    $30,$0      *{ascii,hex}
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
              
             *hex_1
             *contains first hex digit of the instruction with corresponding mappings
             *also contains all supported instructions in the comment field
              * 1 means the mapping is ambiguous (and we have to read more bits in instruction) 0 means its not.
              * -1 means the instruction isnt one that can be disassembled in this program             
hex_1         DC.B    $01,$01  * 'MOVE.B','MOVEA.B'
              DC.B    $03,$01  * 'MOVE.W','MOVEA.W'
              DC.B    $02,$01  * 'MOVEA.L','MOVEA.L'
              DC.B    $04,$01  * 'MOVEM','LEA','NEG','JSR','RTS','NOP'
              DC.B    $0D,$01  * 'ADD','ADDA'
              DC.B    $00,$01  * 'ORI','BCLR','CMPI','ADDI','EORI','SUBI'
              DC.B    $0B,$01  * 'EOR','CMP'
              DC.B    $0E,$00  * 'LSR','LSL','ASR','ASL','ROL','ROR' (determined in shift_roll_handler)
              DC.B    $06,$00  * Bcc('BCS','BGE','BLT','BVC','BRA','BCC','BNE','BEQ','BVS','BGT','BLE')
              DC.B    $09,$00  * 'SUB','SUBA' (determined in sub_handler)
              DC.B    $05,$01  * 'SUBQ','ADDQ'
              DC.B    $0C,$00  * 'MULS'
              DC.B    $08,$01  * 'OR','DIVS(word)'
              DC.B    -1,-1    * unsupported instruction-first hex val is not one in the table above

*below table holds ascii codes for instruction printing
*MOVEA         DC.L    'MOVEA',0
*MOVEM         DC.L    'MOVEM',0              
MOV           DC.L    'MOV',0
LEA           DC.L    'LEA',0
NEG           DC.L    'NEG',0 
JSR           DC.L    'JSR',0
RTS           DC.L    'RTS',0
NOP           DC.L    'NOP',0
ADD           DC.L    'ADD',0
BCL           DC.L    'BCL',0
*ADDA          DC.L    'ADDA',0
ORI           DC.L    'ORI',0
*BCLR          DC.L    'BCLR',0
*CMPI          DC.L    'CMPI',0
EOR           DC.L    'EOR',0
CMP           DC.L    'CMP',0
LS            DC.W    'LS',0    *LSL,LSR
AS            DC.W    'AS',0    *ASL,ASR
RO            DC.W    'RO',0    *ROL,ROR
BCS           DC.L    'BCS',0
BGE           DC.L    'BGE',0
BLT           DC.L    'BLT',0
BVC           DC.L    'BVC',0
BRA           DC.L    'BRA',0
BCC           DC.L    'BCC',0
BNE           DC.L    'BNE',0
BEQ           DC.L    'BEQ',0
BVS           DC.L    'BVS',0
BGT           DC.L    'BGT',0
BLE           DC.L    'BLE',0
SUB           DC.L    'SUB',0
MUL           DC.L    'MUL',0
DIV           DC.L    'DIV',0
OR            DC.W    'OR',0
DAT           DC.L    'DAT',0   *DATA
INV           DC.L    'INV',0   *used for displaying unsupported addressing modes e.g --  MOVE.L 8(A4,D0),5(A4)

*below holds extended codes to append to the instruction
A             DC.B    'A',0
I             DC.B    'I',0
R             DC.B    'R',0
M             DC.B    'M',0
L             DC.B    'L',0
Q             DC.B    'Q',0
S             DC.B    'S',0
E             DC.B    'E',0
EM            DC.W    'EM',0
EA            DC.W    'EA',0

*below holds ascii size strings to load to variable SIZECODE            
SIZEB         DC.W    '.B',00
SIZEW         DC.W    '.W',0
SIZEL         DC.W    '.L',00
SIZECODE      DS.L    1

*below establishes lengths of data units
byte_len      EQU     1
word_len      EQU     2
long_len      EQU     4            
              
* holds the condition of each branch                
bcc_tbl       DC.B    %0101 *BCS
              DC.B    %1100 *BGE
              DC.B    %1101 *BLT
              DC.B    %1000 *BVC
              DC.B    %0000 *BRA  
              DC.B    %0100 *BCC
              DC.B    %0110 *BNE
              DC.B    %0111 *BEQ
              DC.B    %1001 *BVS
              DC.B    %1110 *BGT
              DC.B    %1111 *BLE   
              DC.B    -1    *invalid branch type
              
*below holds shift counts for arithmetic/logical shifts
shift_tbl     DC.B    %000
              DC.B    %001
              DC.B    %010
              DC.B    %011
              DC.B    %100
              DC.B    %101
              DC.B    %110
              DC.B    %111                              

*below variables hold the name of the instruction
INST_NAME     DS.L    2         *holds the instruction to be printed (e.g. ADD.L; MOVE.B)
INST_NAME_EXT DS.L    1         *holds any part of instruction over 32 bits (eg last M in MOVEM)

*below characters are used for printing
addr_sign     DC.B    '$',0
imm_sign      DC.B    '#',0
open_paren    DC.B    '(',0
closed_paren  DC.B    ')',0
plus_sign     DC.B    '+',0
neg_sign      DC.B    '-',0
comma         DC.B    ',',0
slash         DC.B    '/',0
nl            DC.B    '',CR,LF,0
space         DC.B    '    ',0

*below holds intro messages to user                       
display_start DC.B    'Please enter a maximum 32-bit starting memory address in hex (-1 to quit): ',0
display_end   DC.B    'Please enter a maximum 32-bit ending memory address in hex (-1 to quit): ',0
bad_addr      DC.B    'Please enter a valid address',CR,LF,0


*below variables store the starting and ending addresses the user provides
user_start    DS.L    1
user_end      DS.L    1

exit_val      DC.W    $2D31  *sentinel exit value
             
done_msg      DC.B    'done',0


              END     start






























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
