global IntToStrDec

NUMBER_BUFFER equ 10

section .text

;-----------------------------------------------------------------------
; Entry:  rdi - buffer, rsi - int number 
; Result: [rdi] as a string
;-----------------------------------------------------------------------
IntToStrDec:
    sub  rsp, NUMBER_BUFFER

    mov  rax, rsi ; rax = number
    mov  r11,  10

    mov  r9,  rdi ; save rdi
    mov  rdi, rsp ; rdi -> number buffer

    .loopToDec:
        xor  rdx, rdx
        div  r11

        add  dl, '0'
        mov  [rdi], dl
        inc  rdi

        cmp  rax, 0
        jne  .loopToDec
    
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
