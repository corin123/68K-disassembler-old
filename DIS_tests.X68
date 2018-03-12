*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
*consider:
      *move.p #43,d3
      *garbage instruction thats not even encoded
      *just instruction itself (not encoded)
      *movea only L,W
      
start org $600
      
      *movem d4,(sp)
      OR.W #12313,d5
      EOR.l     D7,d3
      MOVEA.L A3,A7
      MOVE.B D3,(A4)
       OR (A3),D3
       OR D3,D6
      
      end start

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
