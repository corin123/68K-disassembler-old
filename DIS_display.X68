
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
              MOVE.B  #1,D0
              TRAP    #15
              
              LEA     space,A1
              MOVE.B  #14,D0
              TRAP    #15
              
              LEA     OP_NAMES,A1    *move the name of operands into A1
              MOVE.B  #0,D0
              TRAP    #15
                    
              BRA     prep



MOVE          DC.B    'MOVE',0
MOVEA         DC.B    'MOVEA',0
MOVEM         DC.B    'MOVEM',0
LEA           DC.B    'LEA',0
NEG           DC.B    'NEG',0 
JSR           DC.B    'JSR',0
RTS           DC.B    'RTS',0
NOP           DC.B    'NOP',0
ADD           DC.B    'ADD',0
ADDA          DC.B    'ADDA',0
ORI           DC.B    'ORI',0
BCLR          DC.B    'BCLR',0
CMPI          DC.B    'CMPI',0
EOR           DC.B    'EOR',0
CMP           DC.B    'CMP',0
LSR           DC.B    'LSR',0
LSL           DC.B    'LSL',0
ASR           DC.B    'ASR',0
ASL           DC.B    'ASL',0
ROL           DC.B    'ROL',0
ROR           DC.B    'ROR',0
BCS           DC.B    'BCS',0
BGE           DC.B    'BGE',0
BLT           DC.B    'BLT',0
BVC           DC.B    'BVC',0
BRA           DC.B    'BRA',0
SUB           DC.B    'SUB',0
SUBQ          DC.B    'SUBQ',0
MULS          DC.B    'MULS',0
DIVS          DC.B    'DIVS',0
OR            DC.B    'OR',0
INV           DC.B    'DATA',0
              
SIZEb         DC.B    '.B',0
SIZEw         DC.B    '.W',0
SIZEl         DC.B    '.L',0
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
