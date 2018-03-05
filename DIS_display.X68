* do this:
*   move.l  <name>,INST_NAME    and <name> is saved to INST_NAME

*   eg  move.l   JSR,INST_NAME

*dont do 4 letter words yet



disp_instr    LEA     addr_sign,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              MOVE.L  A5,D1         *move the address of this instruction into D1
              MOVE.B  #3,D0              
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     INST_NAME,A1  *move the (assembly) name of this instruction into A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     OP_NAMES,A1    *move the name of operands into A1
              MOVE.B  #0,D0
              TRAP    #15
                    
              BRA     prep



MOVE          DC.L    'MOVE',0
MOVEA         DC.L    'MOVEA',0
MOVEM         DC.L    'MOVEM',0
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
              
SIZEb         DC.B    '.B',0
SIZEw         DC.B    '.W',0
SIZEl         DC.B    '.L',0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
