* -----------------------------------------------------------------------------
* Title      : Test 1000
* Written by : Sean Coulter, Corin Ennis, Antony Mbugua
* Date       : 
* Description: Test DIVS.W, OR
* -----------------------------------------------------------------------------
CR                  EQU             $0D
LF                  EQU             $0A
stack               EQU             $00007000

START               ORG             $600       ; first instruction of program

* Testing opcodes
* 0000 -> ORI, BCLR, CMPI
* 0010 -> MOVE.L, MOVEA.L
* 0011 -> MOVE.W, MOVEA.W
* 0100 -> MOVEM, MULS.L, LEA, NEG, JSR, RTS
* 0101 -> SUBQ
* 0110 -> Bcc, BRA
* 1000 -> DIVS.W, OR
* 1001 -> SUB
* 1011 -> EOR, CMP
* 1100 -> MULS.W
* 1101 -> ADD, ADDA
* 1110 -> LSL, LSR, ASL, ASR, ROL, ROR
* 
* Addressing Mode   Mode    Register
* Dn                000     reg. number:Dn
* An                001     reg. number:An
* (An)              010     reg. number:An
* (An) +            011     reg. number:An
* - (An)            100     reg. number:An
* 
* Addressing Mode   Mode    Register
* (xxx).W           111     000
* (xxx).L           111     001
* #<data>           111     100
* -----------------------------------------------------------------------------
test_1000           MOVE.B #255,D3                      ; max Byte size
                    MOVE.W #65535,D4                    ; max Word size
                    MOVE.L #4294967295,D5               ; max Long size
                    MOVE.L #2147483646,D6
                    
                    MOVEA.W $600,A4
                    MOVEA.L $600,A5
                    
                    * DIVS.W < ea >, Dn
                    * Size = (Word, Long)               ; only need Word, Long
                    DIVS.W D3,D4
                    MOVE.W #65535,D4
                    DIVS.W (A4),D4
                    DIVS.W -(A4),D4
                    DIVS.W (A4)+,D4
                    DIVS.W #2,D4
                    DIVS.W $2,D4
                    DIVS.W #$2,D4

                    * OR
                    * Size = ()                          ; only need Word, Long
                    ;OR
                    
                    SIMHALT                                     ; halt simulator

* Put variables and constants here

                    END             START                       ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
