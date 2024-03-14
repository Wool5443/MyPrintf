global IntToStr
global IntToStr2Base

extern flush

BUFFER_SIZE equ 256
NUMBER_BUFFER equ 64

section .text

;-----------------------------------------------------------------------
; Entry:  rdi - buffer, rsi - int number, rdx - shift for 2base
; Result: [rdi] as a string
; Destroys: rax, rcx, r8, r9, rsi
;-----------------------------------------------------------------------
IntToStr2Base:
    sub  rsp, NUMBER_BUFFER ; allocate buffer
    mov  r9, rdi ; r9 -> buffer
    mov  rdi, rsp ; rdi -> number buffer

    mov  cl, dl ; cl = shift
    .loopInt:
        mov  r8, rsi ; rsi - number, r8 - remainder
        shr  rsi, cl
        shl  rsi, cl
        sub  r8, rsi
        shr  rsi, cl
        mov  al, [r8 + ALPHABET]
        stosb

        test rsi, rsi
        jne  .loopInt

    mov  rsi, rdi ; rsi -> number buffer
    mov  rcx, rsi
    sub  rcx, rsp ; rcx = num len
    dec  rsi ; rsi -> first digit in number buffer
    mov  rdi, r9 ; rdi -> buffer

    cmp  rcx, rbx ; if rcx <= rbx just print else flush
    jle  .noOverflow

    mov  r8, rsi ; rsi -> number buffer
    mov  rsi, BUFFER_SIZE
    sub  rsi, rbx ; rsi = buffer size

    sub  rdi, rsi ; rdi -> buffer start
    mov  r9, rdi ; r9 -> buffer start
    
    call flush

    mov  rdi, r9 ; rdi -> buffer start
    mov  rsi, r8 ; rsi -> number buffer
    mov  rbx, BUFFER_SIZE ; reset buffer size

    .noOverflow:

    sub  rbx, rcx ; update buffer free space

    .loopToBuf:
        mov  al, [rsi]
        mov  [rdi], al
        inc  rdi
        dec  rsi
        loop .loopToBuf

    test rbx, rbx
    jnz  .end

    mov  r8, rdi ; r8 -> buffer
    sub  rdi, BUFFER_SIZE ; rdi -> buffer start
    mov  rsi, BUFFER_SIZE
    call flush
    mov  rdi, r8

    .end:

    add  rsp, NUMBER_BUFFER
ret

;-----------------------------------------------------------------------
; Entry:  rdi - buffer, rsi - int number, rdx - base 
; Result: [rdi] as a string
; Destroys: rax, r8, r9, rcx, rdx
;-----------------------------------------------------------------------
IntToStr:
    sub  rsp, NUMBER_BUFFER

    test rsi, 1 << 30 ; sign bit
    jz   .continue
    mov  al, '-'
    stosb
    dec  rbx
    neg  rsi

    .continue:

    mov  rax, rsi ; rax = number
    mov  r9,  rdx ; r9 = base

    mov  r8,  rdi ; r8 -> buffer
    mov  rdi, rsp ; rdi -> number buffer

    .loopToInt:
        xor  rdx, rdx
        div  r9

        mov  dl, [ALPHABET + rdx]
        mov  [rdi], dl
        inc  rdi

        test rax, rax
        jne  .loopToInt
    
    mov  rsi, rdi ; rsi -> num buffer
    mov  rcx, rsi
    sub  rcx, rsp ; rcx = num len
    dec  rsi ; rsi -> first digit in buffer
    mov  rdi, r8 ; rdi -> buffer

    cmp  rcx, rbx ; if rcx <= rbx continue else flush
    jle  .noOverflow

    mov  r9, rsi ; r9 -> number buffer
    mov  rsi, BUFFER_SIZE
    sub  rsi, rbx ; rsi = buffer length

    sub  rdi, rsi ; rdi -> buffer start
    mov  r8, rdi ; r8 -> buffer start

    call flush

    mov  rdi, r8 ; rdi -> buffer start
    mov  rsi, r9 ; rsi -> number buffer
    mov  rbx, BUFFER_SIZE ; reset buffer size

    .noOverflow:

    sub  rbx, rcx ; update buffer free space

    .loopToBuf:
        mov  al, [rsi]
        mov  [rdi], al
        inc  rdi
        dec  rsi
        loop .loopToBuf

    test rbx, rbx
    jnz  .end

    mov  r8, rdi ; r8 -> buffer
    sub  rdi, BUFFER_SIZE ; rdi -> buffer start
    mov  rsi, BUFFER_SIZE
    call flush
    mov  rdi, r8

    .end:

    add  rsp, NUMBER_BUFFER
ret

section .data
ALPHABET db '0123456789abcdefghijklmnopqrstuvwxyz'
