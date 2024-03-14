global MyPrintf
global flush

extern IntToStr
extern IntToStr2Base
extern MyStrLen

BUFFER_SIZE equ 256

section .text

;-----------------------------------------------------------------------
; Analog to printf, supports %d
; Entry: rdi - const char* fmt, ends with \0
;        rsi, rdx, rcx, r8, r9, r10, stack - args
; Destroys: rdi, rsi, rdx, rcx, r8, r9, rdx
; Result: rax - error code 0 - ok, 1 - not ok
;-----------------------------------------------------------------------
MyPrintf:
    pop  r10 ; r10 = ret addr

    push r9
    push r8
    push rcx
    push rdx
    push rsi ; now all regs are continious in stack

    push rbp

    lea  rbp, [rsp + 8] ; rbp -> first arg

    push rbx
    push r12
    push r13 ; save regs
    push r10 ; save ret addr

    sub  rsp, BUFFER_SIZE ; allocate buffer
    mov  rbx, BUFFER_SIZE ; rbx = space left in buffer
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

        mov  rdx, [rbp] ; load argument to rdx
        add  rbp, 8 ; rbp -> next arg

        call HandleSpecifer
        test rax, rax ; if rax != 0 error
        jnz  .error

        jmp  .loop

        .loopEnd:
        movsb ; else (*rdi++) = (*rsi++)
        dec  rbx
        test rbx, rbx ; if rbx == 0 flush buffer
        jnz  .loop
        
        mov  rdi, rsp ; rdi -> buffer start
        mov  r8, rsi ; r8 -> fmt
        mov  rsi, BUFFER_SIZE
        call flush
        mov  rsi, r8 ; rsi -> fmt
        mov  rbx, BUFFER_SIZE ; rbx = buffer free space
        mov  rdi, rsp ; rdi -> buffer

        jmp  .loop

    .end:

    mov  rdi, rsp ; rdi -> buffer start
    mov  rsi, BUFFER_SIZE
    sub  rsi, rbx ; rsi = buffer length
    call flush
    xor  rax, rax

    .error:

    add  rsp, BUFFER_SIZE ;

    pop  r8
    pop  r13
    pop  r12
    pop  rbx
    pop  rbp

    add  rsp, 5 * 8 ; free push args
    push r8 ; ret addr back in place

    ret

;-----------------------------------------------------------------------
; Handles the specifer
; Entry: rdi - buffer, rsi - fmt, rdx - argument
; Assumes: *rsi = specifier, rbx - space left in buf
; Result: rax - error, 0 - ok, 1 - not ok
; Destroys: r8, r9, r10, rax, rdx
;-----------------------------------------------------------------------
HandleSpecifer:
    xor  rax, rax
    mov  al, [rsi]
    sub  al, 'b' ; 'b' - minimun specifier as a number

    cmp  al, 0
    jl   .error
    cmp  al, 'x' - 'b'
    jg   .error

    lea  r10, [rsi + 1] ; r10 -> fmt + 1
    mov  rsi, rdx ; rsi = argument

    jmp  [rax * 8 + jumpTable]

    .handleChar:
        mov  al, dl ; al = arg char
        stosb
        dec  rbx ; update free buffer size
        test rbx, rbx ; if buffer finished flush
        jnz  .end

        sub  rdi, BUFFER_SIZE ; rdi -> buffer start
        mov  r8, rdi ; r8 -> buffer
        mov  rsi, BUFFER_SIZE ; rsi = buffer size
        call flush
        mov  rdi, r8

        jmp  .end
    .handleStr:
        mov  r9, rdi ; rdi -> buffer
        mov  rdi, rdx ; rdi -> str
        call MyStrLen
        mov  rdi, r9

        mov  rcx, rax ; rcx = strlen
        cmp  rcx, rbx ; if rax=strlen <= rbx just print it to buf
        ja   HandleSpecifer.handleLongString

        mov  rsi, rdx ; rsi -> str
        sub  rbx, rcx ; update buffer free space
        rep  movsb

        test rbx, rbx ; if rbx == 0 flush
        jnz  .end

        sub  rdi, BUFFER_SIZE ; rdi -> buffer start
        mov  r8, rdi ; r8 -> buffer start
        mov  rsi, BUFFER_SIZE ; rsi = buffer length
        call flush
        mov  rdi, r8 ; rdi -> buffer start

        jmp  .end
     .handleLongString:
        mov  rsi, BUFFER_SIZE
        sub  rsi, rbx ; rsi = buffer size
        sub  rdi, rsi ; rdi -> buffer start
        mov  r8, rdi ; r8 -> buffer start
        call flush

        mov  rdi, rdx ; rdi -> str
        mov  rsi, rcx ; rsi = strlen
        call flush
        mov  rdi, r8 ; rdi -> buffer start
        jmp .end

    .handleBin:
        mov  ax, '0b'
        stosw
        mov  rdx, 1
        jmp  .continueBasedHandle
    .handleOct:
        mov  ax, '0o'
        stosw
        mov  rdx, 3
        jmp  .continueBasedHandle
    .handleDec:
        mov  rax, rdx
        cdqe ; extend edx

        mov  rsi, rax ; rsi = argument
        mov  rdx, 10
        call IntToStr
        jmp  .end
    .handleHex:
        mov  ax, '0x'
        stosw
        mov  rdx, 4
    .continueBasedHandle:
        sub  rbx, 2 ; for 0b, 0x etc.
        call IntToStr2Base

    .end:
    mov  rsi, r10 ; rsi -> fmt + 1
    xor  rax, rax
    ret

    .error:
    mov  rax, 1
    ret

;-----------------------------------------------------------------------
; Prints buffer to stdout
; Entry: rdi - buffer to flush, rsi - length
; Destroys: rax, rdx, rdi, rsi
;-----------------------------------------------------------------------
flush:
    mov  rax, 0x01

    mov  rdx, rsi ; rdx = length
    mov  rsi, rdi ; rsi -> buffer
    mov  rdi, 1 ; std out

    syscall ; print buffer
ret

jumpTable: ; 0xeb - short jump
        dq HandleSpecifer.handleBin ; b
        dq HandleSpecifer.handleChar ; c
        dq HandleSpecifer.handleDec ; d
        times('o' - 'd' - 1) dq HandleSpecifer.error
        dq HandleSpecifer.handleOct ; o
        dq HandleSpecifer.handleHex ; p
        times('s' - 'p' - 1) dq HandleSpecifer.error
        dq HandleSpecifer.handleStr ; s
        times('x' - 's' - 1) dq HandleSpecifer.error
        dq HandleSpecifer.handleHex ; x
