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
      
    lsl.w #3,d1
    asr.l #2,d1
    bra   start
    
      
      end start











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
