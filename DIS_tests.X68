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
      addq.w   #0,d3
      addq.b   #6,d0
      addq.w   #8,d3
      addq.l   #2,d7
      subq.b   #3,d2
      subq.w   #7,d3
      subq.l   #4,d4
      
      move.l   #$533,d0
      MOVE.B   #9,D1
      ADD.B #4,D5
      movea.w  $4000,a3
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
