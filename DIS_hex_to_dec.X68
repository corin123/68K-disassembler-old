START       ORG     $400

           adda     #$600,a5

           LEA      imm_sign, A1    *load and print '#' character
           MOVE.B   #14, D0
           TRAP     #15    
           move.b   #1,(a1)
           CMP.B    #1,(A1)         *is immediate data flagged as a word?
           BEQ      word_data_handler
           CMP.B    #2,(A1)         *is immediate data flagged as a long?
           BEQ      long_data_handler          
 
byte_data_handler ADDA     #byte_len,A5
                  MOVE.B   (A5)+,D1     *get immediate byte data and increment address by a byte
                  BRA      data_mode_print
                  
word_data_handler ADDA     #word_len,A5
                  MOVE.W   (A5)+,D1     *get immediate word data and increment address by a word
                  BRA      data_mode_print

long_data_handler ADDA     #long_len,A5
                  MOVE.L   (A5)+,D1     *get immediate long data and increment address by a long
                  BRA      data_mode_print

data_mode_print   MOVE.B   #3,D0        *print the immediate data
                  TRAP     #15 

            
imm_sign  DC.B '#',0   
byte_len equ 1
word_len equ 2
long_len equ 4         
            
DONE   
            END     START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
