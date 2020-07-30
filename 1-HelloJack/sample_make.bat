ca65 init_template.asm -o init_template.o --debug-info
ld65 init_template.o -o init_template.nes -t nes
fceux init_template.nes