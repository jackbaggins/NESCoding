    .inesprg 1 ; defines number of 16kb prg banks
    .ineschr 1 ; defines number of 8kb CHR banks
    .inesmap 0 ; defines the mapper to use
    .inesmir 1 ; defines vram mirroring of banks


;defining variables
;rsset defines where in memory variables will be stored
    .rsset $0000 

    ;rs directive is used to define how many bytes are allocated to that variable
    ;in this case, it's one byte
pointerBackgroundLowByte  .rs 1
pointerBackgroundHighByte .rs 1

; define the banks
    .bank 0
    .org $C000


RESET:
    JSR LoadBackground

    LDA #%10000000 ; Enable NMI, sprites and background on table 0
    STA $2000
    LDA #%00011110 ; Enable sprites, enable backgrounds
    STA $2001
    LDA #$00 ; No background scrolling
    STA $2006
    STA $2006
    STA $2005
    STA $2005

InfiniteLoop:
    JMP InfiniteLoop

LoadBackground:

    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDA #LOW(background)
    STA pointerBackgroundLowByte
    LDA #HIGH(background)
    STA pointerBackgroundHighByte

    LDX #$00
    LDY #$00

.Loop:
    LDA [pointerBackgroundLowByte], y
    STA $2007

    INY
    CPY #$00
    BNE .Loop

    INC pointerBackgroundHighByte
    INX
    CPX #$04
    BNE .Loop
    ; return from subroutine, end the method and return to where it was originally called
    RTS


NMI:
    RTI ;return from interrupt


; bank 1, define three interrupt vectors
; dw means data word - this is used to define a word, meaning two bytes of data (16 bits)
    .bank 1
    .org $E000

background:
    .include "graphics/background.asm"


    .org $FFFA
    .dw NMI
    .dw RESET
    .dw 0

; sprites and background graphics bank
    .bank 2
    .org $0000
    .incbin "graphics.chr"

