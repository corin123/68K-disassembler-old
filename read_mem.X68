* --------------------------------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
* --------------------------------------------------------------------------------
CR                  EQU             $0D
LF                  EQU             $0A
stack               EQU             $000A0000

START               ORG             $1000       ; first instruction of program

* B is 8 bits
* W is 16 bits
* L is 32 bits
* 32bit machine

* Assumption that the *.X68 compiles, this allows us to read every 16 bit and then know how to
* parse information
* We are going to have to know for each op code how much extra memory needs to be read.
*
* The 68000 stack "grows" toward low memory. This means that to allocate stack space you should subtract
* from the stack pointer: SUB #size,SP. To deallocate space (or to discard previously pushed values),
* add to the stack pointer. Equally confusing, when allocating local storage with the LINK instruction,
* you must specify a negative displacement to be added to the stack pointer.
* Clear addresses and registers
* Can make into subroutine if we are repeating program several times
* Remove whichever address is holding our stack pointer from loop. A7?
* --------------------------------------------------------------------------------
clear_registers     MOVEA.L         $0,A0                       ; can also use SUBA.L A0,A0
                    MOVEA.L         $0,A1                       ; open
                    MOVEA.L         $0,A2                       ; open
                    MOVEA.L         $0,A3                       ; open
                    MOVEA.L         $0,A4                       ; open
                    MOVEA.L         $0,A5                       ; starting address and current value of address
                    MOVEA.L         $0,A6                       ; ending address
                    MOVEA.L         $0,A7                       ; SP
                    CLR             D0                          ; easy68k reserved
                    CLR             D1                          ; easy68k reserved
                    CLR             D2                          ; easy68k reserved
                    CLR             D3
                    CLR             D4
                    CLR             D5
                    CLR             D6
                    CLR             D7

                    MOVE.L         #$00001000,A5                ; initialize starting address
                    MOVE.L         #$00002000,A6                ; initialize temp ending address
                    ; function to check that A5 is < A6
                    ; and other error checks
                    LEA             stack,SP
                    MOVEM.L         D7,-(SP)
                    
                    MOVEA.W         (A5)+,A5                     ; move value from a5 memory into a5
                    MOVE.W          A5,D3
                    LSR.W                   #8,D3                       ; shift by a total of 12 bits to get just the opcode
                    LSR.W                   #4,D3
                    ; D3 now contains the beginning 4 bits of the op code
                    
                    LEA             opcode_table,A4
                    JSR             8(A4,D3)                                ; need to multiply by 6 or 8 to get the right conversion
                                                                            ; 6 makes an ORI call, 8 a MOVE.B call, why?
* --------------------------------------------------------------------------------
* Jumps to the functions
opcode_table            JMP                     op0000                      ; ORI, BCLR, CMPI
                        JMP                     op0001                      ; no operands
                        JMP                     op0010                      ; MOVE.L, MOVEA.L
                        JMP                     op0011                      ; MOVE.W, MOVEA.W
                        JMP                     op0100                      ; MOVEM, MULS.L, LEA, NEG, JSR, RTS
                        JMP                     op0101                      ; SUBQ
                        JMP                     op0110                      ; Bcc, BRA
                        JMP                     op0111                      ; no operands
                        JMP                     op1000                      ; DIVS.W, OR
                        JMP                     op1001                      ; SUB
                        JMP                     op1010                      ; no operands
                        JMP                     op1011                      ; EOR, CMP
                        JMP                     op1100                      ; MULS.W
                        JMP                     op1101                      ; ADD, ADDA
                        JMP                     op1110                      ; LSL, LSR, ASL, ASR, ROL, ROR
                        JMP                     op1111                      ; no operands

* --------------------------------------------------------------------------------
* ORI, BCLR, CMPI
op0000                  LEA                     MESSAGE,A2                  ; comment
                        RTS

* --------------------------------------------------------------------------------
* No operand
op0001                  LEA                     MESSAGE2,A2                 ; comment
                        RTS

* --------------------------------------------------------------------------------
* MOVE.L, MOVEA.L
op0010              LEA             MESSAGE,A2                          ; comment
                    JMP             clear_registers

* --------------------------------------------------------------------------------
* MOVE.W, MOVEA.W
op0011              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* MOVEM, MULS.L, LEA, NEG, JSR, RTS
op0100              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* SUBQ
op0101              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* Bcc, BRA
op0110              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* No operand
op0111              LEA             MESSAGE2,A2                         ; comment
                    RTS

* --------------------------------------------------------------------------------
* DIVS.W, OR
op1000              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* SUB
op1001              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* No operand
op1010              LEA             MESSAGE2,A2                         ; comment
                    RTS

* --------------------------------------------------------------------------------
* EOR, CMP
op1011              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* MULS.W
op1100              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* ADD, ADDA
op1101              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* LSL, LSR, ASL, ASR, ROL, ROR
op1110              LEA             MESSAGE,A2                          ; comment
                    RTS

* --------------------------------------------------------------------------------
* No operand
op1111              LEA             MESSAGE2,A2                         ; comment
                    RTS


                    SIMHALT                                     ; halt simulator

* Put variables and constants here
MESSAGE             DC.L            'Valid opcode', 0
MESSAGE2            DC.L            'Invalid opcode', 0

                    END             START                       ; last line of source
; http://www.easy68k.com/paulrsm/doc/trick68k.htm

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
