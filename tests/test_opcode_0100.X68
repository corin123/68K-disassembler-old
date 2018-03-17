* -----------------------------------------------------------------------------
* Title      : Test 0100
* Written by : Sean Coulter, Corin Ennis, Antony Mbugua
* Date       : 
* Description: Test MOVEM, MULS.L, LEA, NEG, JSR, RTS
* -----------------------------------------------------------------------------
CR                  EQU             $0D
LF                  EQU             $0A
stack               EQU             $00007000

START               ORG             $12000       ; first instruction of program

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
test_0100           MOVE.B #255,D3                      ; max Byte size
                    MOVE.W #65535,D4                    ; max Word size
                    MOVE.L #4294967295,D5               ; max Long size
                    MOVE.L #2147483646,D6
                    
                    MOVE.L #3425345,D7
                    
                    MOVEA.W $12000,A4
                    MOVEA.L $12000,A5
                    
                    * MOVEM < list > , < ea >
                    * MOVEM < ea > , < list >
                    * Size = (Word, Long)               ; only need Word, Long
                    MOVEM.W A4-A5,(A6)
                    MOVEM.W D3/A5,(A6)
                    MOVEA.W $12000,A5
                    MOVEM.W A4,(A5)
                    MOVEM.W A5,-(A5)
                    
                    MOVEM.L A4-A5,(A6)
                    MOVEM.L D3/A5,(A6)
                    MOVEA.L $12000,A5
                    MOVEM.L A4,(A5)
                    MOVEM.L A5,-(A5)

                    * ORI # < data > , < ea >
                    * Size = (Byte, Word, Long)         ; only need Word, Long
                    ;MULS.L

                    * ORI # < data > , < ea >
                    * Size = (Byte, Word, Long)         ; only need Word, Long
                    ;LEA

                    * ORI # < data > , < ea >
                    * Size = (Byte, Word, Long)         ; only need Word, Long
                    ;NEG

                    * ORI # < data > , < ea >
                    * Size = (Byte, Word, Long)         ; only need Word, Long
                    ;JSR

                    * ORI # < data > , < ea >
                    * Size = (Byte, Word, Long)         ; only need Word, Long
                    ;RTS
                    
                    SIMHALT                                     ; halt simulator

* Put variables and constants here

                    END             START                       ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
