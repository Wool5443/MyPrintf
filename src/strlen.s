global MyStrLen

section .text

;-----------------------------------------------------------------------
; Finds the length of null-terminated string
; Entry: rdi -> str
; Result: rax - length
; Destroys: rdi, rax, rcx
;-----------------------------------------------------------------------
MyStrLen:
    mov  rcx, rdi
    mov  al, 0
    repne scasb
    mov  rax, rdi
    sub  rax, rcx
    shr  rax, 1 ; since while repne rcx-- and rdi++
    dec  rax
    ret
