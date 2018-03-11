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
              CMP.L   #0,D1         *user didnt type anything
              BLE     addr_err
              
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
              CMP.L   #0,D1         *user didnt type anything
              BLE     addr_err
              
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

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
