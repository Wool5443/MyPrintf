global MyPrintf

extern IntToStr
extern MyStrLen

BUFFER_SIZE equ 1024

section .text

;-----------------------------------------------------------------------
; Analog to printf, supports %d
; Entry: rdi - const char* fmt, ends with \0
;        rsi, rdx, rcx, r8, r9, stack - args
;-----------------------------------------------------------------------
MyPrintf:
    push r12 ; save r12
    push r13 ; save r13

    lea  r13, [rsp + 8 * 2] ; *r13 = first stack arg, remember that we add rcx, 8

    push r9
    mov  r10, rsp ; *r10 = r9 - where rcx must jump to stack args
    push r8
    push rcx
    push rdx
    push rsi

    mov  rcx, rsp ; *rcx = rsi - first arg

    sub  rsp, BUFFER_SIZE ; allocate buffer
    mov  rsi, rdi ; rsi -> fmt
    mov  rdi, rsp ; rdi -> buffer

    cld
    .loop:
        cmp  byte [rsi], 0 ; if *rsi == 0 terminate
        je  .end

        cmp  byte [rsi], '%' ; if *rsi == '%' handle specifer
        jne  .loopEnd

        inc  rsi
        cmp  byte [rsi], '%'
        je   .loopEnd

        mov  rdx, [rcx]

        cmp  rcx, r10 ; check if reg args ended
        cmove rcx, r13 ; if rcx == r10 rcx -> stack args
        add  rcx, 8 ; rcx -> next arg

        mov  r12, rcx ; save rcx
        call HandleSpecifer
        mov  rcx, r12

        jmp  .loop

        .loopEnd:
        movsb ; else (*rdi++) = (*rsi++)
        jmp  .loop

    .end:
    mov  rax, 0x01

    mov  rsi, rsp ; rsi -> buffer

    mov  rdx, rdi
    sub  rdx, rsp ; rdx = strlen

    mov  rdi, 1 ; std out

    syscall ; print buffer

    add  rsp, BUFFER_SIZE + 5 * 8 ; free buffer and pushed args

    pop  r13
    pop  r12

    ret

;-----------------------------------------------------------------------
; Handles the specifer
; Entry: rdi - buffer, rsi - fmt, rdx - argument
; Assumes: *rsi = specifier
; Destroys: r8, r9, r11, rax, rcx
;-----------------------------------------------------------------------
HandleSpecifer:
    mov  al, [rsi]

    cmp  al, 'c'
    je   .handleChar
    cmp  al, 's'
    je   .handleStr
    cmp  al, '%'
    je   .handlePercent

    jmp  .handleInt

    .handleChar:
        mov  al, dl
        stosb
        jmp  .end
    .handleStr:
        mov  r8, rdi
        mov  rdi, rdx ; rdi -> str
        call MyStrLen
        mov  rcx, rax ; rcx = strlen
        mov  rdi, r8 ; rdi = buffer
        mov  r8,  rsi ; save rsi
        mov  rsi, rdx ; rsi -> str
        rep  movsb
        mov  rsi, r8
        jmp  .end
    .handlePercent:
        mov  byte [rdi], '%'
        jmp  .end
    .handleInt:
        mov  r8, rsi ; save rsi
        mov  rsi, rdx
        mov  rdx, 10
        call IntToStr
        mov  rsi, r8

    .end:
    inc  rsi
    ret
