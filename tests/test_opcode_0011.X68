* -----------------------------------------------------------------------------
* Title      : Test 0011
* Written by : Sean Coulter, Corin Ennis, Antony Mbugua
* Date       : 
* Description: Test MOVE.W, MOVEA.W
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
test_0011           MOVE.W #65535,D4
                    MOVE.W $600,A5
                    MOVE.W #$600,A4
                    * MOVE # < ea > , < ea >
                    * Size = (Byte, Word, Long)         ; only need Word, Long
                    MOVE.W #65535,D5                    ; #<data>,Dn
                    MOVE.W D4,D5                        ; Dn,Dn
                    MOVE.W A4,D5                        ; An,Dn
                    MOVE.W (A4),D5                      ; (An),Dn
                    MOVE.W -(A4),D5                     ; -(An),Dn
                    MOVE.W (A4)+,D5                     ; (An)+,Dn

                    MOVE.W #$600,(A5)                   ; #<data>,(An)
                    MOVE.W D5,(A5)                      ; Dn,(An)
                    MOVE.W A4,(A5)                      ; An,(An)
                    MOVE.W (A4),(A5)                    ; (An),(An)
                    MOVE.W -(A4),(A5)                   ; -(An),(An)
                    MOVE.W (A4)+,(A5)                   ; (An)+,(An)

                    MOVE.W #$600,-(A5)                  ; #<data>,-(An)
                    MOVE.W D5,-(A5)                     ; Dn,-(An)
                    MOVE.W A4,-(A5)                     ; An,-(An)
                    MOVE.W (A4),-(A5)                   ; (An),-(An)
                    MOVE.W -(A4),-(A5)                  ; -(An),-(An)
                    MOVE.W (A4)+,-(A5)                  ; (An)+,-(An)

                    MOVE.W #$600,(A5)+                  ; #<data>,(An)+
                    MOVE.W D5,(A5)+                     ; Dn,(An)+
                    MOVE.W A4,(A5)+                     ; An,(An)+
                    MOVE.W (A4),(A5)+                   ; (An),(An)+
                    MOVE.W -(A4),(A5)+                  ; -(An),(An)+
                    MOVE.W (A4)+,(A5)+                  ; (An)+,(An)+

                    * MOVEA # < ea > , An
                    * Size = (Word, Long)               ; only need Word, Long
                    MOVEA.W #65535,A5                   ; #<data>,An
                    MOVEA.W $600,A5
                    MOVEA.W #$600,A5
                    MOVEA.W D5,A5                       ; Dn,An
                    MOVEA.W A4,A5                       ; An,An
                    MOVEA.W (A4),A5                     ; (An),An
                    MOVEA.W -(A5),A6                    ; -(An),An
                    MOVEA.W (A5)+,A6                    ; (An)+,An
                    
                    SIMHALT                                     ; halt simulator

* Put variables and constants here

                    END             START                       ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
