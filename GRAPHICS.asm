.model small
.stack 100h
.data

.data?

.code
start:
    
    mov ax, @data
    mov es, ax
    mov ds, ax      ;define DATA segment

    jmp main

main:
    
    ; Set intermediate graphic mode
    ;mov ax, 006ah   ; 
    mov ax, 0013h
    mov bx, 13      ;
    int 10h

    ;plot 50 pixel horizontal line
    mov dx,0
    mov ax, 96h
    mov bx, 64h
    mov cx, 0002h

makeLine:
    push ax
    push ax
    push bx
    push cx
    call printPixel
    pop ax
    inc dx
    inc ax

    cmp dx, 32h
    jnz makeLine 

    ;pause until enter, input without echo until CR
pause:
    mov ah, 8
    int 21h          ; Read in al without echo
    cmp al, 13
    jnz pause

    ;switch back to text mode
    mov ax, 4f02h
    mov bx, 3
    int 10

    jmp exit



printPixel:
;Receive 3 arguments:
; word Xval
; word Yval
; word colour
    
    x1 EQU ss:[bp+8]
    y1 EQU ss:[bp+6]
    color EQU ss:[bp+4]

    
    push bp         ; save Base Pointer
    mov bp, sp      ; get the stack pointer

    push ax
    push bx
    push cx
    push dx


    mov ax, color
    mov cx, x1
    mov dx, y1
    

    ;DX=ROW     CX=Column      AL=Colour
    mov ah, 0ch
    mov bh, 0
    int 10h


    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp      ;restore original SP
    pop bp

    ret 6           ; pop 3 word from the stack (For the arguments)

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
