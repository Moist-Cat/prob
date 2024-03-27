section .data
    array db 0,3,1,0,1,1,6,7,6,2,5 ; Array de entrada 
    format db "%d ", 0 ; Agrega un espacio después del número

section .text
    extern printf
    global main

main:
    mov ebp, esp ; for correct debugging

    ; Carga los valores del array en eax, ebx y edx
    movzx eax, byte [array]
    movzx ebx, byte [array + 2]
    movzx edx, byte [array + 4]

    ; Multiplica por 10 y suma el siguiente valor del array
    imul eax, eax, 10
    movzx ecx, byte [array + 1]
    add eax, ecx
    imul ebx, ebx, 10
    movzx ecx, byte [array + 3]
    add ebx, ecx
    imul edx, edx, 10
    movzx ecx, byte [array + 5]
    add edx, ecx
    
    cmp eax, 24 
    jg greater
    
    add eax, 2000
    jmp end
    
greater:
    add eax, 1900

end:
     ; Imprime dia
    push edx
    push format
    call printf
    add esp, 8 ; Limpia la pila

    ; Imprime mes
    push ebx
    push format
    call printf
    add esp, 8 ; Limpia la pila
    
      ; Imprime año
    push eax
    push format
    call printf
    add esp, 8 ; Limpia la pila

    ; Termina el programa
    mov eax, 1
    xor ebx, ebx
    int 0x80        
