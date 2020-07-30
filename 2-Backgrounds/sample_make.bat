ca65 backgrounds.asm -o backgrounds.o --debug-info
ld65 backgrounds.o -o backgrounds.nes -t nes
fceux backgrounds.nes