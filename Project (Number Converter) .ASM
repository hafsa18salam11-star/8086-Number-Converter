.model small
.stack 100h

.data
    msg_input   db 0dh,0ah,'enter a 2-digit number (00-99): $'
    msg_menu    db 0dh,0ah,'1=binary 2=hex 3=octal 0=exit: $'
    msg_invalid db 0dh,0ah,'invalid! try again: $'
    msg_exit    db 0dh,0ah,'goodbye!$'
    msg_binary  db 0dh,0ah,'binary: $'
    msg_hex     db 0dh,0ah,'hex: $'
    msg_octal   db 0dh,0ah,'octal: $'
    msg_again   db 0dh,0ah,'try another number? (y/n): $'

.code

; -------------------------------------------------------
; print_nibble: prints AH as a single hex character
; defined FIRST so call print_nibble is always a
; short forward reference from do_hex
; -------------------------------------------------------
print_nibble proc
    cmp  ah, 9
    jle  pn_digit
    add  ah, 'A' - 10
    jmp  pn_print
pn_digit:
    add  ah, '0'
pn_print:
    mov  dl, ah
    push ax
    mov  ah, 02
    int  21h
    pop  ax
    ret
print_nibble endp

main proc
    mov  ax, @data
    mov  ds, ax

; -------------------------------------------------------
; get a 2-digit number, store result in BH
; -------------------------------------------------------
main_loop:
    lea  dx, msg_input
    mov  ah, 09
    int  21h

    mov  ah, 01h
    int  21h
    sub  al, '0'
    mov  bl, 10
    mul  bl
    mov  bh, al

    mov  ah, 01h
    int  21h
    sub  al, '0'
    add  bh, al

; -------------------------------------------------------
; show menu — read choice into CL
; -------------------------------------------------------
show_menu:
    lea  dx, msg_menu
    mov  ah, 09
    int  21h

    mov  ah, 01h
    int  21h
    mov  cl, al

    cmp  cl, '0'
    je   do_exit
    cmp  cl, '1'
    je   do_binary
    cmp  cl, '2'
    je   do_hex
    cmp  cl, '3'
    je   do_octal

    lea  dx, msg_invalid
    mov  ah, 09
    int  21h
    jmp  show_menu          ; show_menu is only ~20 bytes back - fine

; -------------------------------------------------------
; exit — right after menu keeps je do_exit short
; -------------------------------------------------------
do_exit:
    lea  dx, msg_exit
    mov  ah, 09
    int  21h
    mov  ah, 4ch
    int  21h

; -------------------------------------------------------
; binary
; -------------------------------------------------------
do_binary:
    lea  dx, msg_binary
    mov  ah, 09
    int  21h

    mov  al, bh
    mov  dh, 8

bin_loop:
    rol  al, 1
    pushf
    mov  dl, '0'
    jnc  b_zero
    mov  dl, '1'
b_zero:
    push ax
    mov  ah, 02
    int  21h
    pop  ax
    popf
    dec  dh
    jnz  bin_loop           ; ~14 bytes back - always fine
    jmp  ask_again

; -------------------------------------------------------
; hex
; -------------------------------------------------------
do_hex:
    lea  dx, msg_hex
    mov  ah, 09
    int  21h

    mov  al, bh
    mov  ah, al
    shr  ah, 1
    shr  ah, 1
    shr  ah, 1
    shr  ah, 1
    call print_nibble

    mov  al, bh
    mov  ah, al
    and  ah, 0fh
    call print_nibble
    jmp  ask_again

; -------------------------------------------------------
; octal
; -------------------------------------------------------
do_octal:
    lea  dx, msg_octal
    mov  ah, 09
    int  21h

    mov  al, bh
    mov  ah, 0
    mov  bl, 64
    div  bl
    add  al, '0'
    mov  dl, al
    push ax
    mov  ah, 02
    int  21h
    pop  ax

    mov  al, ah
    mov  ah, 0
    mov  bl, 8
    div  bl
    add  al, '0'
    mov  dl, al
    push ax
    mov  ah, 02
    int  21h
    pop  ax

    mov  al, ah
    add  al, '0'
    mov  dl, al
    mov  ah, 02
    int  21h

    ; fall through to ask_again

; -------------------------------------------------------
; ask continue — all three conversions land here
; ask_again is BELOW all conversions so every
; jmp ask_again is a short forward jump
; -------------------------------------------------------
ask_again:
    lea  dx, msg_again
    mov  ah, 09
    int  21h

    mov  ah, 01
    int  21h

    ; jump to main_loop if y/Y — but main_loop is far above
    ; so we flip the logic: if NOT y, fall to exit (3 bytes)
    ; if yes, we need a near jump — use 'jmp near ptr main_loop'
    cmp  al, 'y'
    je   go_again
    cmp  al, 'Y'
    je   go_again

    ; not y/Y — exit
    lea  dx, msg_exit
    mov  ah, 09
    int  21h
    mov  ah, 4ch
    int  21h

go_again:
    ; main_loop is far, but unconditional JMP is always near (3 bytes)
    ; MASM uses near jump automatically for unconditional JMP
    jmp  main_loop

main endp
END main
