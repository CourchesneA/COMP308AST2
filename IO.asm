.model small
.stack 100h
.data
    msg1 db  "Please, input your name: ",0
    msg2 db  "Your name is: "

.data?
    inputstr db 100 dup(?)

.code
start:
    
    mov ax, @data
    mov ds, ax      ;define DATA segment

    jmp main

main:
    
    ;call getche
    
    ; value is in dx, 
    ; store input on stack to pass it as a param
    ;push dx
    ; display prompt
    lea ax, msg1     ; load the string address
    push ax         ; pass the string address as argument
    call puts

    ; take input with echo
    lea ax, inputstr
    push ax
    call gets

    ; print new line
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h

    ; display second message
    lea ax, msg2
    push ax
    call puts

    ; display name
    lea ax, inputstr
    push ax
    call puts
    

    jmp exit



getche:             ; Read, echo and return character

    push ax         ; Save the register that we are going to use on the stack

    mov ah, 8
    int 21h          ; Read in al without echo
    mov dl, al
    mov ah, 2
    int 21h          ; Display read character

    pop ax          ; restore registers
    
    ret             ; To return the value, we will use the DL register

putch:
; Receive a char, display it and update cursor
; Input is a word on the stack
    
    push bp         ; save Base Pointer
    mov bp, sp      ; get the stack pointer

    push dx

    mov dx, word ptr ss:[bp+4]  ; get argument

    push ax                     ; save register

    mov ah, 2       ; char to print is in dl
    int 21h
        
    pop ax
    pop dx

    mov sp, bp      ;restore original SP
    pop bp

    ret 2           ; pop a word from the stack (For the argument)

gets:               
; fct that take a string input until enter and adds \0
; assume input str pointer is pushed on the stack

    push bp     ;save BP
    mov bp, sp  ; Set base Pointer
    
    push si     ; we will use dx for the address of the string
    mov si, word ptr ss:[bp+4]  ; get argument
    push ax     ; ax will be used for the character
    

loop2:
    ; get input from getche
    push si
    call getche
    pop si

    mov ax, dx  ; get returned value from getche

    ;mov al, byte ptr [si] 
    
    ;compare character with CR
    cmp al, 13

    ;If charcater is "CR", end the loop
    je endl2

    ;if not, store character, increment pointer than loop
    mov [si], al

    inc si      ; increment cx to the next address
    jmp loop2    ; loop back


endl2:
    ;add null terminator to string
    mov al, 0
    mov [si], al

    pop ax
    pop si
    mov sp, bp  ; restore original SP
    pop bp

    ret 2

    
puts:
; given a string pointer, output the str
; Assume input is pushed on the stack before IP

    push bp     ;save BP
    mov bp, sp  ; Set base Pointer
    
    push si     ; we will use dx for the address of the string
    mov si, word ptr ss:[bp+4]  ; get argument
    push ax     ; ax will be used for the character
    

loop1:
    ;Get the character at position CX
    mov al, byte ptr [si] 
    
    ;compare character with \0
    cmp al, 0

    ;If charcater is "\0", end the loop
    je endl1

    ;if not, call putch, increment pointer than loop
    push ax     ; Give the character as argument
    call putch

    inc si      ; increment cx to the next char
    jmp loop1    ; loop back


endl1:
    pop ax
    pop si
    mov sp, bp  ; restore original SP
    pop bp

    ret 2


exit:
    mov ax, 4c00h    ; Exit function
    int 21h

END start
