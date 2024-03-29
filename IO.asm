.model small
.stack 100h
.data
    msg1 db  "Please, input your name: ",0
    msg2 db  "Your name is: "
    int1 db  "Input first integer: ",0
    int2 db  "Input second integer: ",0
    int3 db  "Input third integer: ",0
    sub1 db  "First int - second int: ",0
    sub2 db  "Second int - third int: ",0

.data?
    inputstr db 100 dup(?)

.code
start:
    
    mov ax, @data
    mov ds, ax      ;define DATA segment

    jmp main

main:
    ;--------------------ast 1 
    ;call getche
    
    ; value is in dx, 
    ; store input on stack to pass it as a param
    ;push dx
    ; display prompt
    ;lea ax, msg1     ; load the string address
    ;push ax         ; pass the string address as argument
    ;call puts

    ; take input with echo
    ;lea ax, inputstr
    ;push ax
    ;call gets

    ; print new line
    ;mov dl, 10
    ;mov ah, 02h
    ;int 21h
    ;mov dl, 13
    ;mov ah, 02h
    ;int 21h

    ; display second message
    ;lea ax, msg2
    ;push ax
    ;call puts

    ; display name
    ;lea ax, inputstr
    ;push ax
    ;call puts

    ;---------------------ast 2
    ;Read first integer
    lea ax, int1
    push ax
    call puts
    call getche     ;value in dl
    call println
    mov ax, dx
    mov ah,0        ;Char a in ax

    ;Read second integer
    push ax     ;Save A
    lea ax, int2
    push ax
    call puts
    pop ax
    call getInt
    call println   
    mov bx, dx      ;int B in bx

    ;Read third integer
    push ax     ;Save A
    lea ax, int3
    push ax
    call puts
    pop ax
    call getInt
    call println
    mov cx, dx       ;int C in cx

    call println

    ; compute A-B
    push ax
    lea ax, sub1
    push ax
    call puts
    pop ax
    ;;print a-b
    mov dx, ax  ;use dx for computations
    sub dx, bx
    push dx
    call printInt

    call println

    ;compute B-C
    push ax
    lea ax, sub2
    push ax
    call puts
    pop ax
    ;;print B-C
    mov dx, bx  ;use dx for computations
    sub dx, cx
    push dx
    call printInt

    call println
    

    jmp exit


println:
    ; print new line
    push ax
    push dx
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    pop dx
    pop ax
    ret

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


getInt:
    ;Take input ascii from the keyboard and return its integer value

    push ax

    mov ah, 8
    int 21h
    mov dl, al
    mov ah, 2
    int 21h

    pop ax

    sub dl, '0' ; Convert to integer

    ret         ; value will be in dl

printInt:
    ; take a 16 bits integer as argument on the stack,
    ; return ascii characters using putch

    push bp     ; save Base Pointer
    mov bp, sp  ; get the stack pointer

    push dx     ; Save register

    mov dx, word ptr ss:[bp+4]  ; get argument 

    push ax     ; Save register
    push bx
    push cx

    ;add dx, '0'     ; convert input to ascii

    ; Now we want to print each digit
    ; bx will contain the digits to prints
    ; we will shift dx
    
    mov ax, dx
    ;handle the case of integer is zero in the beginning:
    cmp dx,0
    jz zeroInt
    mov ax, -1
    push ax
    jmp intLoop

zeroInt:
    mov ax, '0'
    push ax
    call putch
    jmp intEnd

intLoop:
    ; compare with zero
    cmp dx, 0
    jz intLoop2
    
    mov ax, dx
    mov ah,0        ; To handle run-time only division overflow
    ;not zero, shift (base 10)
    mov cl, 10
    div cl
    
    ; al = ax / 10
    ; ah = ax % 10
    mov dl, al  ;save al in dx for future iterations
    mov dh, 0
    
    ; print number in al 
    mov al, ah  ; put digit to print in al
    mov ah, 0   ; clear ah
    add ax, '0'     ; convert input to ascii
    push ax     ; push ax for puche
    ;call putch

    jmp intLoop




intLoop2:
    ; Unroll the stack and print them
    pop ax
    cmp ax, -1
    jz intEnd

    push ax
    call putch
    jmp intLoop2
    
intEnd:

    pop cx
    pop bx
    pop ax      ; load user registers
    pop dx

    mov sp, bp      ; restore SP
    pop bp

    ret 2       ; pop a word from the stack (from the argument) 
 

exit:
    mov ax, 4c00h    ; Exit function
    int 21h

END start
