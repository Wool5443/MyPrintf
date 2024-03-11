global MyPrintf

extern IntToStr

BUFFER_SIZE equ 1024

section .text

;-----------------------------------------------------------------------
; Analog to printf, supports %d
; Entry: rdi - const char* fmt, ends with \0
;        stack - args
;-----------------------------------------------------------------------
MyPrintf:
    push rbp
    mov  rbp, rsp

    sub  rsp, BUFFER_SIZE ; allocate buffer
    mov  rsi, rdi ; rsi -> fmt
    mov  rdi, rsp ; rdi -> buffer

    .loop:
        cmp  byte [rsi], 0 ; if *rsi == 0 terminate
        je  .end

        cmp  byte [rsi], '%' ; if *rsi == '%' handle specifer
        jne  .loopEnd
        call HandleSpecifer

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

    add  sp, BUFFER_SIZE ; free buffer
    pop  rbp

    ret

;-----------------------------------------------------------------------
; Handles the specifer
; Entry:   rdi - argument
; Assumes: *rsi = '%'
;-----------------------------------------------------------------------
HandleSpecifer:
    inc  rsi
    cmp  byte [rsi], 'd'
    je   .handleInt

    .handleInt:
    
    call IntToStr

    ret
