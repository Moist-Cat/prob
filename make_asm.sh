nasm -f elf $1.asm && gcc -m32 -c -o driver.o driver.c && nasm -f elf -d ELF_TYPE asm_io.asm && gcc -m32 $1.o driver.o asm_io.o -o $1
