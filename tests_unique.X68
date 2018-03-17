T       EQU 4           *00000004

START   ORG $12000
        
        
        
        
        MOVEM  D0-D3/D5/D7,(A3)
        movem  d0/d1/d2/d3/d4/d5/d6/d7,(a3)
        
        OR.B 2(A4,D6),D3
        ADD.L 2(A2,D2),D5
        MULS  (7,A1,D7),D2
        
        movem  a0, $547435
        movem  d4-d6/d7/a4/a6,$3434524
        movem  a0,(a1)
        movem  a1,(a1)
        movem  a2,(a1)
        movem  a3,(a1)
        movem  a4,(a1)
        movem  a5,(a1)
        movem  a6,(a1)
        movem  d7/a7,(a1)
        
        
        rol.l #8,d0
        rol $5000
        lsr #5,d7
        lsl #8,d2
        asr #6,d3
        asl $3000
        ASR.B D0,D0
        LSR.B D6,D7
        ROL.B #2,D4
        ROR.B #8,D6
        ROR.L D6,D4
    
        MULS   D4,D5
        MULS.W  D1,D6
        MULS   #2341,D6
        MULS   -(A2),D4
        MULS   (SP)+,D0
        MULS   #1,D0
        MULS   #0,D0
        
        MULS #255,D3
        DIVS   D4,D5
        DIVS.W  D1,D6
        DIVS   #2341,D6
        DIVS   -(A2),D4
        DIVS   (SP)+,D0
        DIVS   #1,D0
        DIVS   #0,D0
        
        DIVS #255,D3
        
        
            

        
        JSR    A
        
        cmp    $400,A4
        cmpa   $400,a4
        cmp    $300,d0
        
        LEA $8000,SP
       

        
        EXT.W D0
        
        sub    #3,a3
        sub    #3,d0
        sub    #423,a4
        movem  d3/d4,$5000

        
        *move.W D3,4(A0)
        move.w $400,a4
        
        MOVE.L #$12345678,-(SP)
        MOVE.W (SP)+,D3

        MOVE.B #$67,D0
        MOVE.B D0,-(SP)
        CLR    D0
        MOVE.W (SP)+,D0 
       
        CLR    D0
        MOVE.W #$80,D0
        MOVE.W D0,-(SP)
        CLR    D0
        MOVE.W (SP)+,D0 

************************************************************************** /stack_test 

        MOVE.W #$C034,D1
        MOVE.W $334,$C034
        MOVE.W $C034,A1
        MOVE.W $10003000,$0EEEAA1
        MOVE.B #T,D1    *NEED # SYMBOL NEXT TO T
        
        MOVE.L A,D2     *08080808 OK
        
        MOVE.B #$D4,24  *MOVE #$D4 TO ADDRESS 24 BASE 10
        MOVE.B #24,D0
        MOVE.B 24,D0
        MOVE.B $24,D0   *MOVE BYTE AT ADDRESS 24 BASE 10 TO D0
        MOVE.B #$21,T   *OVERWRITE OK
        MOVE.B T,D1     *05 TO D1
        
        MOVE.B B,D3     *00000003
        MOVE.B #$4,B
        MOVE.B B,D3     *WORKS? 00000004
        
        *MOVE.W $673,D2   *CRASH: ODD WORD, EVEN IF ITS THE MIDDLE(NOT BOUNDARY)
        
        MOVE.W #$5,A      
        MOVE.L A,D2       *BYTE: 0508FFFF IS IN D2
                          *LONG: 00000005 IS IN D2
                          *WORD: 00050808 IS IN D2
A       DCB.B 4,8
B       DC.B  3
        
        
        
        MOVE.B #9,D0
        TRAP   #15

        END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
