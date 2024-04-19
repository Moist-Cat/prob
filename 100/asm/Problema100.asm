;Iterativo
%include "io.inc"
section .data
    array1 db 1,0,1,1 ; Array de entrada 1
    array2 db 1,0 ; Array de entrada 2
    len1 db 4 ; Longitud del array 1
    len2 db 2 ; Longitud del array 2
    operations db 0 ; Contador de operaciones
    pos db 0 ; Posición actual en los arrays
    format db "%d "

section .text
    extern printf 
    global main

main:
    mov ebp, esp; for correct debugging
    ; Inicializa los registros
    movzx eax, byte [len1]
    movzx ebx, byte [len2]
    movzx ecx, byte [operations]
    movzx edx, byte [pos]

    ; Comienza el bucle principal
loop:
    cmp edx, eax ; Compara pos con len1
    jge end ; Si pos >= len1, salta a 'end'
    cmp edx, ebx ; Compara pos con len2
    jge end ; Si pos >= len2, salta a 'end'

    ; Compara los elementos actuales de los arrays
    movzx esi, byte [array1 + edx]
    movzx edi, byte [array2 + edx]
    cmp esi, edi
    je equal ; Si son iguales, salta a 'equal'

    ; Si no son iguales, incrementa operations
    inc ecx

equal:
    ; Incrementa pos y continúa el bucle
    inc edx
    jmp loop

end:
    ; Calcula el número de operaciones restantes
    sub eax, edx ; len1 - pos
    sub ebx, edx ; len2 - pos
    cmp eax, ebx
    jge finish ; Si len1 - pos >= len2 - pos, salta a 'finish'

    ; Si len1 - pos < len2 - pos, suma len2 - pos a operations
    add ecx, ebx
    jmp finish

finish:
    ; Suma len1 - pos a operations
    add ecx, eax

    ; Aquí, ecx contiene el número final de operaciones de Levenshtein
    push ecx
    push format
    PRINT_UDEC 2 , ecx
    add esp, 8 ; Limpia la pila

    ; Termina el programa
    mov eax, 1
    xor ebx, ebx
    int 0x80
