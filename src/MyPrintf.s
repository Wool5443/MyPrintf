global MyPrintf

extern IntToStr

BUFFER_SIZE equ 1024

section .text

;-----------------------------------------------------------------------
; Analog to printf, supports %d
; Entry: rdi - const char* fmt, ends with \0
;        rsi, rdx, rcx, r8, r9, stack - args
;-----------------------------------------------------------------------
MyPrintf:
    mov  r10, rsp ; *r10 = r9 - where rcx must jump to stack args
    push r9
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

        mov  rdx, [rcx]
        cmp  rcx, r10
        cmove rcx, r10 ; if rcx == rsp rcx -> stack args
        add  rcx, 8 ; rcx -> next arg
        call HandleSpecifer

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

    ret

;-----------------------------------------------------------------------
; Handles the specifer
; Entry:   rdi - buffer, rsi - fmt, rdx - argument
; Assumes: *rsi = '%'
;-----------------------------------------------------------------------
HandleSpecifer:
    inc  rsi
    cmp  byte [rsi], 'd'
    je   .handleInt

    .handleInt:
        mov  r8, rsi ; save rsi
        mov  rsi, rdx
        call IntToStr
        mov  rsi, r8
    inc  rsi
    ret
