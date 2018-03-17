START ORG $600

      ADD.W (6,A0,D4),D4
      add.w d0,a0
      add.l a0,d0
      add.w a0,d0
      add.w a0,a0

      add.l #9999999,(a0)
      add #$493,(a1)
      add #$493,-(a1)
      add #5,d0
      add.w #5,d0
      add.l #5,d0
      add  %01,d0

      add.b d0,a0
      add.b a0,d0   *invalid size
      add    d0,#5

      END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
