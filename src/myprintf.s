global MyPrintf

extern IntToStr
extern IntToStr2Base
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
        test rax, rax
        jne  .error
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

    .error:

    add  rsp, BUFFER_SIZE + 5 * 8 ; free buffer and pushed args

    pop  r13
    pop  r12

    ret

;-----------------------------------------------------------------------
; Handles the specifer
; Entry: rdi - buffer, rsi - fmt, rdx - argument
; Assumes: *rsi = specifier
; Result: rax - error, 0 - ok, 1 - not ok
; Destroys: r8, r9, r11, rax, rcx
;-----------------------------------------------------------------------
HandleSpecifer:
    xor  rcx, rcx
    mov  cl, [rsi]
    sub  cl, 'b' ; 'b' - minimun specifier as a number

    cmp  cl, 0
    jl   error
    cmp  cl, 'x' - 'b'
    jg   error

    jmp  [rcx * 8 + jumpTable]

    handleChar:
        mov  al, dl
        stosb
        jmp  endHandle
    handleStr:
        mov  r8, rdi
        mov  rdi, rdx ; rdi -> str
        call MyStrLen
        mov  rcx, rax ; rcx = strlen
        mov  rdi, r8 ; rdi = buffer
        mov  r8,  rsi ; save rsi
        mov  rsi, rdx ; rsi -> str
        rep  movsb
        mov  rsi, r8
        jmp  endHandle
    handlePercent:
        mov  byte [rdi], '%'
        jmp  endHandle
    handleBin:
        mov  ax, '0b'
        stosw

        mov  r8, rsi ; save rsi
        mov  rsi, rdx
        mov  rdx, 1
        call IntToStr2Base
        mov  rsi, r8
        jmp  endHandle
    handleOct:
        mov  ax, '0o'
        stosw

        mov  r8, rsi ; save rsi
        mov  rsi, rdx
        mov  rdx, 3
        call IntToStr2Base
        mov  rsi, r8
        jmp  endHandle
     handleDec:
        mov  rax, rdx
        cdqe ; extend edx

        mov  r8, rsi ; save rsi
        mov  rsi, rax
        mov  rdx, 10
        call IntToStr
        mov  rsi, r8
        jmp  endHandle
    handleHex:
        mov  ax, '0x'
        stosw

        mov  r8, rsi ; save rsi
        mov  rsi, rdx
        mov  rdx, 4
        call IntToStr2Base
        mov  rsi, r8
        jmp  endHandle
    endHandle:
    inc  rsi
    xor  rax, rax
    ret

    error:
    mov  rax, 1
    ret

section .data
jumpTable: ; 0xeb - short jump
        dq handleBin ; b
        dq handleChar ; c
        dq handleDec ; d
        times(10) dq error
        dq handleOct ; o
        dq handleHex ; p
        times(2) dq error
        dq handleStr ; s
        times(4) dq error
        dq handleHex ; x
