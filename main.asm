BasicUpstart2(Entry)


#define ENABLE_SNOWFLAKE_GRAVITY
//#define DISABLE_SNOWFLAKE_ANIMATIONS
//#define SHOW_ONLY_ONE_SNOWFLAKE

*=$5000

// Timer for each snowflake. Tracks how many frames have elapsed before requireing an update.
Timers:
    .fill $12, $00                  

// Current animation frame for each snowflake
CurrentFrame:
    .fill $12, $00                  

// This is effectively the number of frames before the snowflake gets an update
// When a new snowflake is generated it gets this timer
StartTimerValues:
    .byte $05,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$04,$04,$04,$03,$02

// Y position for each snowflake.
// These are spread out so the snowflakes are not bunched up together
SnowflakeYPosition:
    .byte $09, $21, $39, $51, $68, $81, $a5, $29, $85, $61, $97, $55, $15, $a9, $a1, $38, $7e, $7e

// Frame count per snowflake
// Originally from: is $887e
FrameCount:
    .byte $07,$07,$09,$07,$07,$09,$07,$07,$09,$07,$07,$09,$07,$09,$07,$07,$07,$07,$07,$70

// There are 7 different types of snowflakes
// Snowflake frame offsets into static snowflake data
// Region is from taken from: $8181 to $81bc
// Each row is a snowflake animation sequence.
.align $100                                             // Align to nearest page boundary
AnimationFrameOffsets:
    .byte $04,$08,$0c,$10,$0c,$08,$04                   // 0            -> Showflake #1
    .byte $00,$18,$14,$18,$1c,$20,$24,$20,$1c           // 8            -> Snowflake #2
    .byte $38,$34,$30,$2c,$28,$2c,$30,$34               // 16 ($10)
    .byte $2c,$30,$34,$38,$34,$30,$2c,$28               // 24 ($18)
    .byte $40,$44,$48,$4c,$50,$4c,$48,$44,$40           // 32 ($20)
    .byte $3c,$4c,$50,$4c,$48,$44,$40,$3c,$40,$44,$48   // 42 ($2a)
    .byte $60,$64,$60,$5c,$58,$54,$58,$5c               // 52 ($34)     -> Showflake #7

// This should be an offset to the start of the AnimationFrameOffsets array for the Nth snowflake
ShowflakeFrameOffset:
    // .byte $89,$91,$a1,$b5,$99,$ab,$91,$89,$ab,$99,$b5,$a1,$91,$a1,$89,$89,$81,$81    // - Original array as in memory
    .byte $08,$10,$20,$34,$18,$2a,$10,$08,$2a,$18,$34,$20,$10,$20,$08,$08,$00,$34       // - array after subtracting the base address ($81) - these are now offsets from zero
    // Offsets are
    // Decimal = 0, 8, 16, 24, 32, 42, 52
    // Hex     = 0, 8, 10, 18 ,20, 2a, 34 

// Count of processed showflakes this frame
NumProcessed:
    .byte $00

MainLoopIndex:
    .byte $00


// AnimatedSnowflakeBuffer.
// There are 18 animated snowflakes. They are animated and copied here, before being copied into the final animated buffer
*=$5200
.align $100                 
AnimatedSnowflakeBuffer:
    .fill $59, $00

// The final snowflake column is here. This is where all the animated snowflakes are copied to.
// This lives at the start of character data ($2000).
*=$2000
FinalSnowflakeBuffer:
    .fill $C0, $00                  // 176 bytes (22 characters) of character rom

// Static snowflake frames. Located here $8ff2
// Taken from creatures2
StaticSnowflakeFrames:
    .import binary "snowflake_frames.bin"

#import "helpers.asm"

/*
====================
InitialiseScreenMemoryForSnow
 Sets up the character indexes to be decending columns between 0-16
====================
*/
InitialiseScreenMemoryForSnow:
{
    ldx #0
    lda #0
loop:
    pha
    jsr InitialiseSnowColumn
    pla

    tay
    iny
    tya
    cpy #40
    bne loop
    rts
}


/*
====================
GenerateRandomNumber
 Uses a LFSR to generate a number between 0 and 16
====================
*/
GenerateRandomNumber:
{
    lda seed 
    asl             
    bcc skip        
    eor #$1d        
skip:
    sta seed 
    and #$0f                    // and a with $0f to mask off the upper bits
    clc  
    rts  

seed:
    .byte $7f                   // LFSR seed
}

/*
====================
InitialiseSnowColumn
 Fills a screen column with ascending tile indexes for the snow effect.
 Assumes the screen is at $0400
 A = column (0 = left side, 40 = right)
====================
*/
InitialiseSnowColumn:
{
    // Set start address
    sta address + 1 
    lda #$04            
    sta address + 2

    ldy #26             // 25 chars per column (store in low byte)

    // Start each char index at a random number between 0 and 16
    jsr GenerateRandomNumber
    tax

loop:
    dey

address:
    stx $0400           // This address will be modified as we fill the column

    inx
    cpx #22             // Snow columns are 22 chars tall. Wrap around to 0.
    bne wrapX 
    lda #0
    tax
wrapX:

    // Increment the address to the next cell down (Add screen width 40 ($28))
    // 16-bit addition.
    clc
    lda address + 1     // add 28 to the low byte (current char + $28 is the character underneath us)
    adc #$28
    sta address + 1
    bcc skip
    inc address + 2     // add carry to high byte
skip:

    cpy #1
    bne loop
    rts
}

/*
====================
InitialiseScreen
 Clears memory, sets colors and initialises the char map for snow
====================
*/
InitialiseScreen:
{
    // Set screen to 0x400 and Character at $2000
    lda #$18
    sta $d018

    // Border to black and screen color to light grey.
    lda #$00
    sta $d020
    lda #$0f
    sta $d021

    // Clear all color cells to be white
    lda #$1
    jsr c64_ClearColorMemory

    // Setup chars for snow
    jsr InitialiseScreenMemoryForSnow

    rts
}

/*
====================
Entry
 Main loop of program 
====================
*/
Entry:
{
    jsr InitialiseScreen
main:
    jsr SnowflakeRoutine


    ldx #4
again:
    jsr c64_waitForNextFrame
    dex
    cpx #0
    bne again

    jmp main
    rts
}


*=$6000
/*
====================
SnowflakeRoutine
 Reverse engineered code from Creatures2 snow levels that animates the snow.
====================
*/
SnowflakeRoutine:
{
    lda #0
    sta NumProcessed

    // Loop through all 18 snowflakes.
    // For each snowflake, decrement the animation timer. 
    // If timer is < 0, then reset frame timer and process current snowflake.
    // If timer is > 0, then move to the next snowflake.
    ldx #$11                                                // 11 = 17 decimal = 18 array elements

mainLoopStart:

    // Decrement timer and process current snowflake if timer < 0
    dec Timers,x
    bmi processSnowflake
    jmp nextSnowflake

processSnowflake:
    inc NumProcessed
    lda NumProcessed

#if SHOW_ONLY_ONE_SNOWFLAKE
    cmp #$11
#else
    cmp #$5                                                 
#endif

    // If 5 snowflakes have been processed already, skip processing this one.    
    // Possibly done to reduce frame time
    bcc startProcess
    jmp nextSnowflake

startProcess:

#if SHOW_ONLY_ONE_SNOWFLAKE
    txa
    cmp #0
    bne skipA
    jmp nextSnowflake
skipA:
#endif

    // reset the animation timer
    lda StartTimerValues,x
    sta Timers,x
    ldy SnowflakeYPosition,x

    // save current snowflak index
    txa 
    pha 

    // x is in a.
    asl 
    asl 
    tax 
    inx 
    inx 
    inx 
    inx 
    // multiply x by 4, and add 4
    // X now contains the END location of the current snowflake

    stx endAnimatedSnowflakeBufferPosition + 1
    tax 
    stx startAnimatedSnowflakeBufferPosition + 1 

    // A = the start position for the current snowflake in the AnimatedSnowflakeBuffer
    // X = the same as A
    // Y = the position of the snowflake

    // Removes the current snowflake from the final buffer by creating a bitmask from the inverse of the
    // AnimatedSnowflakeBuffers bits, then ANDing the FinalSnowflakeBuffer with this mask.
eraseSnowflakeFromFinalBufferLoop:
    lda AnimatedSnowflakeBuffer, x
    eor #$ff
    sta mask + 1
    lda FinalSnowflakeBuffer, y

mask:
    and #$ff          // ands with mask (not ff)

    sta FinalSnowflakeBuffer,y
    jsr IncrementYWithClamp
    inx 
endAnimatedSnowflakeBufferPosition:
    cpx #$ff                                        // ff is replaced with comparexA. Compare x with (snowflakeIndex * 4 + 4)
    bcc eraseSnowflakeFromFinalBufferLoop


    pla 
    tax 
    // X is now the snowflake index again

    // Update snowflake position and wrap around if it goes beyond 22 cells
    ldy SnowflakeYPosition,x
#if ENABLE_SNOWFLAKE_GRAVITY
    jsr IncrementYWithClamp
#endif
    tya 
    sta SnowflakeYPosition,x

    // A = snowflakeyposition 
    pha 
    stx MainLoopIndex                               // The mainLoop index is stored here

    // Decrements the current frame and resets it to FrameCount if its < 0
    ldy CurrentFrame,x
    dey 
    bpl skipInit
    ldy FrameCount,x

skipInit:
    tya 
    sta CurrentFrame,x
    lda ShowflakeFrameOffset,x                      // Load the LSB of the frame offset
    sta loadAddress + 1    

    #if DISABLE_SNOWFLAKE_ANIMATIONS
    ldy #0
    #endif

loadAddress:
    ldx AnimationFrameOffsets, y 

    // Add 4 to the AnimationFrameOffset to get the end of this snowflakes data.
    // This value is stored in endStaticSnowflakeFrameData and controls the loop
    txa 
    inx 
    inx 
    inx 
    inx     
    stx endStaticSnowflakeFrameData + 1             // Self modifying code. Modify endSnowflakeData 
    tax 
    
    startAnimatedSnowflakeBufferPosition:
    ldy #$ff                                        // Y = startOfAnimatedSnowflakeBuffer position

    // Copy the static frame to the animated buffer
staticToAnimatedCopyLoop:
    lda StaticSnowflakeFrames,x             
    sta AnimatedSnowflakeBuffer,y
    iny 
    inx 

    endStaticSnowflakeFrameData:
    cpx #$ff                                        // (Self Modified) - Keep copying until the end of the data is reached.
    bcc staticToAnimatedCopyLoop

    // This whole section calculates:
    // X = snowflakeIndex * 4 + 4
    pla 
    tay 
    lda MainLoopIndex 
    asl 
    asl 
    tax 
    inx 
    inx 
    inx 
    inx 
    stx endAnimatedSnowflakeBuffer + 1
    tax 

    // Copy animated buffer to final. The y position wraps around to the start of the
    // Final buffer if > 22 chars
animatedToFinalCopyLoop:
    lda FinalSnowflakeBuffer,y
    ora AnimatedSnowflakeBuffer,x
    sta FinalSnowflakeBuffer,y
    jsr IncrementYWithClamp
    inx 
    endAnimatedSnowflakeBuffer:
    cpx #$ff                            // (Self Modified) - Will be the end of the animated buffer
    bcc animatedToFinalCopyLoop

    // Restore the current snowflake
    ldx MainLoopIndex            

    // Next snowflake!
nextSnowflake:
    dex 
    bmi finish
    jmp mainLoopStart
finish:
    rts 
}

/*
====================
IncrementYWithClamp
 Increments Y register and wraps around to 176
 This is because the animated snow column is 22 chars tall. Each char is 8 bytes so: 176 / 8 = 22.
====================
*/
IncrementYWithClamp: 
{
    iny 
    cpy #$b0
    bcc skip 
    ldy #$00
skip:
    rts
}
