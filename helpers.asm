

/*
====================
c64_ClearColorMemory
 Clear memory region between $d800 and dbe7
====================
*/
c64_ClearColorMemory:
{
    ldy #0
clrmem1:
    sta $d800, y
    sta $d900, y
    sta $da00, y
    iny
    cpy #0
    bne clrmem1

    ldy #0 
clrmem2:
    sta $db00, y
    iny
    cpy #$e8
    bne clrmem2
    rts
}

/*
====================
c64_ClearScreen
 clears color screen ($400-$800) to accumulator
====================
*/
c64_ClearScreen:
{
    ldx #$00
clrmem:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne clrmem
    rts
}

/*
====================
c64_waitForNextFrame
 waits for vblank 
====================
*/
c64_waitForNextFrame:
     bit $d011
     bpl c64_waitForNextFrame
     lda $d012
wait:   
     cmp $d012
     bmi wait
     rts




