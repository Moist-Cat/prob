%if 0

def solve(arr, n):
    merge_sort(arr, len(arr))
    index = 0
    for i, item in enumerate(arr):
        if item == n:
            index = i + 1
    return arr[:index], arr[index:]

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
na dd 5
array dd 23, 56, 98, 14, 99
n dd 56

_array dd 0, 0, 0, 0, 0  ; temp array for merge sort clashed with "array"

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

        push dword [na] ; len
        push array

        call merge_sort

        pop eax
        pop eax

        push dword [na] ; len
        push array

        ;call print_array
        ;call print_nl

        pop eax
        pop eax

        push dword [n]
        push dword [na] ; len
        push array

        call solve
        ; pop params
        mov ecx, eax

        pop eax
        pop eax
        pop eax

        push ecx
        mov esi, ecx
        push array

        call print_array
        call print_nl

        pop eax
        pop eax

        mov eax, dword [n]
        mov ebx, array
        mov edx, [ebx + esi*4]
        cmp eax, edx

        je ignore
        jmp continue
ignore:
    inc esi
    jmp continue
continue:
        mov eax, dword [na]
        sub eax, esi

        mov ebx, array
        ; x4
        add ebx, esi
        add ebx, esi
        add ebx, esi
        add ebx, esi

        push eax
        push ebx

        call print_array

        pop eax
        pop eax

        jmp end

solve:
    push ebp
    mov ebp, esp

    sub esp, 8

    mov eax, [ebp + 8]; a
    mov [ebp - 4], eax
    mov eax, [ebp + 12]; a_len
    mov [ebp - 8], eax

    mov eax, 0
    mov ecx, [ebp + 12]
    
    jmp solve_loop

solve_loop:
    mov ebx, [ebp + 8]
    mov eax, [ebx + 4*ecx]
    cmp eax, [ebp + 16]
    jl solve_if

    loop solve_loop

    jmp end_solve
    

solve_if:
    mov eax, ecx  ; mov address to return
    inc eax

    jmp end_solve

end_solve:
    mov esp, ebp
    pop ebp
    ret 


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
    push _array

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
    push _array

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
