global IntToStr
global IntToStr2Base

NUMBER_BUFFER equ 64

section .text

;-----------------------------------------------------------------------
; Entry:  rdi - buffer, rsi - int number, rdx - shift for 2base
; Result: [rdi] as a string
; Destroys: rax, r9, r11, rcx
;-----------------------------------------------------------------------
IntToStr2Base:
    sub  rsp, NUMBER_BUFFER ; allocate buffer
    mov  r11, rdi
    mov  rdi, rsp

    mov  cl, dl ; cl - shift
    .loopInt:
        mov  r9, rsi ; rsi - number, r9 - remainder
        shr  rsi, cl
        shl  rsi, cl
        sub  r9, rsi
        shr  rsi, cl
        mov  al, [r9 + ALPHABET]
        stosb

        test rsi, rsi
        jne  .loopInt


    mov  rsi, rdi
    mov  rcx, rsi
    sub  rcx, rsp ; rcx = num len
    dec  rsi ; rsi -> last first digit
    mov  rdi, r11 ; rdi -> buffer

    .loopToBuf: ; r9 -> buffer, rdi -> num buffer
        mov  al, [rsi]
        mov  [rdi], al
        inc  rdi
        dec  rsi
        loop .loopToBuf

    add  rsp, NUMBER_BUFFER

ret

;-----------------------------------------------------------------------
; Entry:  rdi - buffer, rsi - int number, rdx - base 
; Result: [rdi] as a string
; Destroys: rax, r9, r11, rcx
;-----------------------------------------------------------------------
IntToStr:
    sub  rsp, NUMBER_BUFFER

    mov  rax, rsi ; rax = number
    mov  r11,  rdx

    mov  r9,  rdi ; save rdi
    mov  rdi, rsp ; rdi -> number buffer

    .loopToInt:
        xor  rdx, rdx
        div  r11

        mov  dl, [ALPHABET + rdx]
        mov  [rdi], dl
        inc  rdi

        test rax, rax
        jne  .loopToInt
    
    mov  rsi, rdi
    mov  rcx, rsi
    sub  rcx, rsp ; rcx = num len
    dec  rsi ; rsi -> last first digit
    mov  rdi, r9 ; rdi -> buffer

    .loopToBuf: ; r9 -> buffer, rdi -> num buffer
        mov  al, [rsi]
        mov  [rdi], al
        inc  rdi
        dec  rsi
        loop .loopToBuf

    add  rsp, NUMBER_BUFFER

ret

section .data
ALPHABET db '0123456789abcdefghijklmnopqrstuvwxyz'
