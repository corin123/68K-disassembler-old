START ORG $600

*D3:SECOND PART TO PRINT
*D4:FIRST PART 
*D5:holds iteration number
*D6:index into table

*move A0 into D3 and split first part of address and second part of address to D3 and D4 respectively
*

                ADDA.L  #$12345678,A0

hex_2_ascii     *MOVEM   h2a_regs,-(SP)  *save state of registers before call                                
                CLR.L   D5              *clear iteration counter
                MOVE.L  A0,D4
                MOVE.W  D4,D3
                CLR.W   D4
                SWAP    D3
                LEA     string_tbl,A4
h2a_prep        ROL.L   #4,D4           *roll first byte over for analysis
h2a_loop        CMP.B   1(A4,D6.W),D4
                BEQ     h2a_match   
                ADDI    #2,D6
                BRA     h2a_loop        
h2a_match       MOVE.B  (A4,D6.W),D1
                MOVE.B  #6,D0
                TRAP    #15
                CLR.B   D4
                CLR.B   D6
                ADDI    #1,D5
                CMP.B   #its,D5
                BGE     h2a_ret
                CMP.B   #its-4,D5
                BEQ     h2a_swap
                BRA     h2a_prep
h2a_swap        MOVE.L  D3,D4           *move second part of word to D4                
                BRA     h2a_prep

 
h2a_ret        * MOVEM   (SP)+,h2a_regs   *restore state of registers 
                RTS

long_len      equ 4
its           equ 8

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

              END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
