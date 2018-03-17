start org $600

        
hi      sbcd -(a3),-(a1)
        move.b #9,d0
        or.b D1,-(A3)
        

      BNE  done 
       bra.w hi
      bcs   $4000
      bne done
    
done     
  
      end start




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
