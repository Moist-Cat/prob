%if 0

Funcion MergeSort(A)
    Si longitud(A) > 1 entonces
        medio = longitud(A) / 2
        L = A[0, medio]
        R = A[medio, longitud(A)]
        MergeSort(L)
        MergeSort(R)
        Merge(A, L, R)
    Fin Si
Fin Función

Funcion Merge(A, L, R)
    i = 0
    j = 0
    k = 0
    Mientras i < longitud(L) y j < longitud(R) hacer
        Si L[i] <= R[j] entonces
            A[k] = L[i]
            i = i + 1
        Sino
            A[k] = R[j]
            j = j + 1
        Fin Si
        k = k + 1
    Fin Mientras
    Mientras i < longitud(L) hacer
        A[k] = L[i]
        i = i + 1
        k = k + 1
    Fin Mientras
    Mientras j < longitud(R) hacer
        A[k] = R[j]
        j = j + 1
        k = k + 1
    Fin Mientras
Fin Funcion

%endif

%include "asm_io.inc"

%define ARRAY_SIZE 100

; locals for merge
%define i                  ebp - 4
%define j                  ebp - 8
%define k                  ebp - 12

; params for merge
%define A                  ebp + 8
%define A_len              ebp + 12
%define L                  ebp + 16
%define L_len              ebp + 20
%define R                  ebp + 24
%define R_len              ebp + 28

; locals for merge sort
%define mid                  ebp - 4

; params for merge sort
%define A                  ebp + 8
%define A_len              ebp + 12

segment .data
Message         db      "Init... ", 0
Blank         db      " ", 0

n_1             dd      4
array_1         dd      1, 3, 5, 7
n_2             dd      4
array_2         dd      2, 4, 6, 8

ua              dd      5, 4, 3, 2, 1
ua_len          dd      5

array_len       resd    ARRAY_SIZE ; 0, 1, 2, 3, 4, 5, 6, 7
array           resd    ARRAY_SIZE ; 1, 2, 3, 4, 5, 6, 7, 8

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

        mov eax, 0
        add eax, [n_1]
        add eax, [n_2]

        mov [array_len], eax

        ; params
        push dword [n_2]
        push array_2
        push dword [n_1]
        push array_1
        push dword [array_len]
        push array

        call merge


        ; pop params
        pop eax
        pop eax
        pop eax
        pop eax
        pop eax
        pop eax

        push dword [array_len]
        push array

        call print_array

        pop eax
        pop eax

        %if 0  ; full merge_sort

        push dword [ua_len]
        push ua

        call merge_sort

        pop eax
        pop eax

        push dword [ua_len]
        push ua

        call print_array

        pop eax
        pop eax

        %endif

        jmp end

; MERGE_SORT
; (A, A_len)
merge_sort:
    push ebp
    mov ebp, esp   

    ; L, R, mid
    sub esp, 4

    mov dword [mid], 0 ; mid

    mov eax, [A_len]
    shr eax, 1  ; divide by 2

    jz end_merge_sort ; end loop if A_len << 1 == 0

    mov [mid], eax

    ; recursive merge_sort (left)
    push eax   ; L_len
    push dword [A]   ; same array

    call merge_sort

    pop eax
    pop eax

    ; recursive merge_sort (right)
    ; move array pointer "mid" units
    mov eax, [mid]
    shl eax, 2
    add eax, [A]
    ; now eax is R

    mov ebx, [A_len]
    sub ebx, [mid]

    push ebx ; R_len
    push eax ; R

    call merge_sort

    pop eax
    pop eax

    ; call MERGE
    mov eax, [mid]
    shl eax, 2
    ;add eax, eax ; x2
    ;add eax, eax ; x4
    add eax, [A]
    ; now eax is R
    mov ebx, [A_len]
    sub ebx, [mid]

    ; params
    ; R
    push ebx
    push eax
    ; L
    push dword [mid]
    push dword [A]
    ; merge in temp array to avoid changing
    ; L and R
    push dword [A_len]
    push array

    call merge

    ; pop params
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    ; copy temp to real array
    push dword [A_len]
    push dword [A]
    push array

    call copy

    pop eax
    pop eax
    pop eax

    mov eax, 0

    jmp end_merge_sort

end_merge_sort:
    mov esp, ebp
    pop ebp

    ret


; MERGE
merge:
    push ebp
    mov ebp, esp
    ; reserve dd*3 bits for local vars
    sub esp, 12

    ; init i = j = k = 0
    mov dword [i], 0   ; i = 0
    mov dword [j], 0   ; j = 0
    mov dword [k], 0   ; k = 0

    jmp main_loop

main_loop:

    ; i < longitud(L) y j < longitud(R) is equivalent to
    ; not [i - L_len >= 0 OR j - R_len >= 0 ]
    ; thus if any of these is true we jump--otherwise we continue
    mov ebx, 0
    add ebx, [i]
    sub ebx, [L_len]
    jns finish_n_1 

    mov ebx, 0
    add ebx, [j]
    sub ebx, [R_len]
    jns finish_n_1 

    ; if we didn't jump, continue

    ; index L[i]
    mov ebx, 0
    add ebx, [i]
    add ebx, [i]
    add ebx, [i]
    add ebx, [i]

    add ebx, [L]

    ; R[j]
    mov edx, 0
    add edx, [j]
    add edx, [j]
    add edx, [j]
    add edx, [j]

    add edx, [R]

    ; L[i] <= R[j] is equivalent to
    ; 0 + R[j] - L[i] > 0
    mov eax, 0
    add eax, [edx] ; the value at R[j] not R + 4*j (address)
    sub eax, [ebx]

    jns main_if ; not signed
    jmp main_else
    
main_if:
    ; A[k]
    mov eax, 0

    add eax, [k]
    add eax, [k]
    add eax, [k]
    add eax, [k]

    add eax, [A]

    ; L[i] is in ebx
    mov edx, [ebx]
    mov [eax], edx

    inc dword [i]

    inc dword [k]

    jmp main_loop

main_else:
    ; A[k]
    ; this is common for both if and else
    mov eax, 0

    add eax, [k]
    add eax, [k]
    add eax, [k]
    add eax, [k]

    add eax, [A]

    ; R[j] is in edx
    mov ebx, [edx]
    mov [eax], ebx

    inc dword [j]

    inc dword [k]

    jmp main_loop

finish_n_1:
    ; i < longitud(L)
    mov ebx, 0

    add ebx, [i]
    sub ebx, [L_len]
    jns finish_n_2

    ; A[k]
    mov eax, 0

    add eax, [k]
    add eax, [k]
    add eax, [k]
    add eax, [k]

    add eax, [A]


    ; index L[i]
    mov ebx, 0
    add ebx, [i]
    add ebx, [i]
    add ebx, [i]
    add ebx, [i]

    add ebx, [L]

    ; L[i] is in ebx
    mov edx, [ebx]
    mov [eax], edx

    inc dword [i]
    inc dword [k]

    jmp finish_n_1
finish_n_2:
    ; 
    mov ebx, 0
    add ebx, [j]
    sub ebx, [R_len]
    jns end_merge

    ; A[k]
    mov eax, 0

    add eax, [k]
    add eax, [k]
    add eax, [k]
    add eax, [k]

    add eax, [A]


    ; R[j]
    mov edx, 0
    add edx, [j]
    add edx, [j]
    add edx, [j]
    add edx, [j]

    add edx, [R]

    ; R[j] is in edx
    mov ebx, [edx]
    mov [eax], ebx

    inc dword [j]
    inc dword [k]

    jmp finish_n_2

end_merge:
    mov esp, ebp
    pop ebp

    ret

copy:
    push ebp
    mov ebp, esp

    mov ecx, [ebp + 16] ; A_len
    dec ecx             ; - 1
    shl ecx, 2          ; dword <=> *4

copy_loop:
    mov eax, 0
    mov ebx, 0

    mov ebx, [ebp + 12]
    mov eax, [ebp + 8]

    add eax, ecx
    add ebx, ecx

    mov edx, [eax]
    mov [ebx], edx

    add ecx, 0  ; meme call to update ALU flags
    jz end_copy

    sub ecx, 4

    jmp copy_loop

end_copy:
    mov esp, ebp
    pop ebp

    ret

; print array
print_array:
    push ebp
    mov ebp, esp
    
    mov esi, 0                    ; esi = 0
    mov ecx, [ebp+12]             ; ecx = n
    mov ebx, [ebp+8]              ; ebx = address of array

    jmp print_loop

print_loop:
    mov eax, [ebx + 4*esi]
    call print_int
    mov eax, Blank
    call print_string

    inc     esi
    loop    print_loop

    mov esp, ebp
    pop ebp
    ret
        
end:
        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret
