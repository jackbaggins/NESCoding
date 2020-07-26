; http://www.6502.org/tutorials/6502opcodes.html


; header segment needed for emulators, not required for real hardware
.segment "HEADER"
.byte "NES" ; Header ASCII value "NES"
.byte $1a ; signature of iNES header
.byte $02 ; 2 * 16KB program ROM chips
.byte $01 ; 1 * 8KB CHR ROM chips
.byte %00000000 ; https://wiki.nesdev.com/w/index.php/INES (flags 6)
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes

.segment "ZEROPAGE" ; LSB (least significant byte) 0 - FF
.segment "STARTUP"

Reset: ; what happens when reset button is pressed
    SEI ; Disable all interrupts
    CLD ; Disable decimal mode (NES CPU is 6502 clone with no decimal mode)

    ; Disable sound IRQ
    LDX #$40
    STX $4017

    ; Initialize the stack register
    LDX #$FF
    TXS ; Transfer X to stack pointer

    INX ; #$FF + 1 => #$00 - this resets the X register by overflowing to #$00

    ; Now that X is #$00
    ; Zero out the PPU (picture processing unit) registers
    STX $2000
    STX $2001

    ; Disable PCM - pulse code modulation - channel (additional sound channel disable)
    STX $4010

; Draw a blank screen, wait for vblank
; register $2002 tells if PPU is drawing or in vblank
; BIT opcode grabs bit 7 from given memory address
; if value of $2002 is 1, in vblank
; if value of $2002 is 0, not in vblank
:
    BIT $2002
    BPL :-

    TXA

CLEARMEM:
    ; loop through all addresses $0000-07000 and set
    ; all to 00, except $0200 - $02FF, that's set to FF
    STA $0000, X
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    ; set aside range $0200-$02FF for sprite data
    LDA #$FF
    STA $0200, X
    LDA #$00
    INX
    BNE CLEARMEM ; loop back to CLEARMEM if value is not #$00

; get PPU ready
; wait for vblank
:
    BIT $2002
    BPL :-

    LDA #$02
    STA $4014
    NOP ; no operation, burn a cycle

    ; When writing to $2006, have to write twice
    ; $3F00 ends up in the register, 
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00

LoadPalettes:
    LDA PaletteData, X
    STA $2007 ; $3F00, $3F01, $3F02 => #3F1F
    INX
    CPX #$20
    BNE LoadPalettes

    LDX #$00

LoadSprites:
    LDA SpriteData, X
    STA $0200, X
    INX
    CPX #$20 ; (compare to 0x20 32 decimal)
    BNE LoadSprites

; Enable Interrupts
    CLI

    LDA #%10010000 ; enable NMI change background to use second CHR set of tiles ($1000)
    STA $2000
    ; enabling sprites and background for left most 8 pixels
    ; enabling sprites and background
    LDA #%00011110
    STA $2001

Loop:
    JMP Loop

NMI:
    LDA #$02 ; copy sprite data from $0200 => PPU memory for display
    STA $4014
    RTI
; Not sure what a lot of this data is, but the first 4 bytes of the second byte line 
; determine the pallette
PaletteData:
    .byte $22,$29,$1A,$0F,$22,$36,$17,$0F,$22,$30,$21,$0F,$22,$27,$17,$0F
    .byte $22,$14,$23,$37,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17

; y position, tile number, attributes, x position
SpriteData:
    .byte $08, $00, $00, $08
    .byte $08, $01, $00, $10
    .byte $10, $02, $00, $08
    .byte $10, $03, $00, $10
    .byte $18, $04, $00, $08
    .byte $18, $05, $00, $10
    .byte $20, $06, $00, $08
    .byte $20, $07, $00, $10

.segment "VECTORS" ; code that handles what to do when interrupts happen
    .word NMI
    .word Reset
    ;
.segment "CHARS" ; Where to pull graphics data from
    .incbin "hellojack.chr"