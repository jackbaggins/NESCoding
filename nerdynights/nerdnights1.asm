;iNES header
    .inesprg 1 ; 1. 16kb bank of prg code
    .ineschr 1 ; 1x 8KB bank of chr data
    .inesmap 0 ; mapper = 0 NROM, no bank swapping
    .inesmir 1 ; background mirroring

    ; nesasm arranges everything in 8kb code and 8kb graphics banks
    ; to fill the 16kb prg space, two banks are needed

; bank 0 starts at $C000
    .bank 0
    .org $C000

RESET:
    SEI ; disable IRQs
    CLD ; disable decimal mode
    LDX #$40
    STX $4017 ; disable APU frame IRQ
    LDX #$FF
    TXS ; set up stack - transfer X to stack pointer
    INX ; now X = 0
    STX $2000 ; disable NMI - PPU register
    STX $2001 ; disable rendering - PPU register
    STX $4010 ; disable PCM IRQs, disable sound

vblankwait1: ; first wait for vblank to ensure PPU is ready
    BIT $2002 ; BIT grabs bit 7 from address
    BPL vblankwait1 ; BLP is branch or "jump" to address specified

clrmem: ; clear all memory
    LDA #$00
    STA $0000, X
    STA $0100, X
    STA $0200, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FE
    STA $0300, X
    INX
    BNE clrmem    

vblankwait2: ; 2nd vblank, PPU will be ready after this
    BIT $2002
    BPL vblankwait2

    LDA #%10000000
    STA $2001

Forever:
    JMP Forever ; jump back to forever, infinite loop

NMI:
    RTI

;;;;;;;;;;;;;;;;;;;;
; bank 1 starts at $FFFA - 8KB higher than bank 0
    .bank 1
    .org $E000
    .dw NMI

    .dw RESET

    .dw 0

; bank 2 starts at 0

    .bank 2
    .org $0000
;graphics here
    .incbin "hellomario.chr" ; includes 8KB graphics file from smb1







