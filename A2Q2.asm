.model small
.stack 100h
.data
    msg1 db  "Please, input your name: ",0
    msg2 db  "Your name is: ",0

    int1 db  "Input first integer: ",0
    int2 db  "Input second integer: ",0
    int3 db  "Input third integer: ",0
    sub1 db  "First int - second int: ",0
    sub2 db  "Second int - third int: ",0

    noVesa db "Error: No VESA found",0
    info1 db "SVGA info - Signature: ",0
    info2 db "SVGA info - VersionL: ",0
    info3 db "SVGA info - VersionG: ",0
    info4 db "SVGA info - OEMStringPtr: ",0
    mode1 db "Mode info - X Resolution: ",0
    mode2 db "Mode info - Y Resolution: ",0
    mode3 db "Mode info - X Character size: ",0
    mode4 db "Mode info - Y Character size: ",0
    mode5 db "Mode info - Bits per pixel: ",0
    mode6 db "Mode info - NumberOfBanks: ",0
    mode7 db "Mode info - Memory Model: ",0


.data?
    ;inputstr db 100 dup(?)

    SVGA_Info STRUC
        Signature       dd ?
        VersionL        db ?
        VersionH        db ?
        OEMStringPtr    dd ?
        CapableOf       dd ?
        VidModePtr      dd ?
        TotalMemory     dw ?
        OEMSoftwareVersion  dw ?
        VendorName      dd ?
        ProductName     dd ?
        ProductRevisionStr  dd ?
        Reserved        db 512 dup(?)
    SVGA_Info ENDS

    svga_i  SVGA_Info<>

    SVGA_ModeInfo STRUC
        ModeAttributes      dw ?        ; mode attributes
        WinAAttributes      db ?    ; window A attributes
        WinBAttributes      db ?    ; window B attributes
        WinGranularity      dw ?    ; window granularity
        WinSize             dw ?    ; window size
        WinASegment         dw ?    ; window A start segment
        WinBSegment         dw ?    ; window B start segment
        WinFuncPtr          dd ?        ; pointer to window function
        BytesPerScanLine    dw ?    ; bytes per scan line
        XResolution         dw ?    ; horizontal
        resolutionYResolution         dw ?    ; vertical resolution
        XCharSize           db ?    ; character cell width
        YCharSize           db ?    ; character cell height
        NumberOfPlanes      db ?    ; number of memory planes
        BitsPerPixel        db ?    ; bits per pixel
        NumberOfBanks       db ?    ; number of banks
        MemoryModel         db ?    ; memory model type
        BankSize            db ?    ; bank size in kb
        NumberOfImagePages  db ?    ; number of images
        Reserved1           db ?    ; reserved for page function
        RedMaskSize         db ?    ; size of direct color red mask in bits
        RedFieldPosition    db ?    ; bit position of LSB of red mask
        GreenMaskSize       db ?    ; size of direct color green mask in bits
        GreenFieldPosition  db ?    ; bit position of LSB of green mask
        BlueMaskSize        db ?    ; size of direct color blue mask in bits
        BlueFieldPosition   db ?    ; bit position of LSB of blue mask
        RsvdMaskSize        db ?    ; size of direct color reserved mask in bits
        DirectColorModeInfo db ?    ; Direct Color mode attributes
        Reserved2           db 216 DUP(?)   ; remainder of ModeInfoBloc
    SVGA_ModeInfo ENDS

    svga_mi SVGA_ModeInfo <>
        

.code
start:
    
    mov ax, @data
    mov ds, ax      ;define DATA segment
    mov es, ax

    jmp main

main:
    ; Get information about graphic card
    ; i.e. SVFA_INFO  &  SVGA_ModeInfo
    ; Print and comment

    ;--SVGA info (VESA)--
    mov ax, 4f00h
    mov cx, bx
    mov di, offset svga_i
    int 10h
    ;--------------------
    ;Check if Vesa was found
    cmp ax, 004fh
    jz vesaPresent
    
    ;Vesa call returned error, exit with error message

    lea ax, noVesa
    push ax
    call puts
    jmp exit

vesaPresent:

    ;Print info
    ;info[1]
    lea ax, info1
    push ax
    call puts
    ;print the info
    mov al, byte ptr [di]
    push ax
    call putch
    mov al, byte ptr [di+1]
    push ax
    call putch
    mov al, byte ptr [di+2]
    push ax
    call putch
    mov al, byte ptr [di+3]
    push ax
    call putch
    call println

    ;info[2]
    lea ax, info2
    push ax
    call puts
    ;print the info
    mov al, byte ptr [di+4]
    push ax
    call printInt
    call println

    ;info[3]
    lea ax, info3
    push ax
    call puts
    ;print the info
    mov al, byte ptr [di+5]
    push ax
    call printInt
    call println

    ;info[4]
    lea ax, info4
    push ax
    call puts
    ;print the info
    mov ax, word ptr [di+6]
    ;mov ah,0
    push ax
    call printInt
    ;mov al, byte ptr [di+7]
    ;mov ah,0
    ;push ax
    call printInt
    mov ax, word ptr [di+8]
    ;mov ah,0
    push ax
    call printInt
    ;mov al, byte ptr [di+8]
    ;mov ah,0
    ;push ax
    ;call putch
    call println

    ;--SVGA Mode Info--
    mov ax, 4f01h
    mov cx, bx
    mov di, offset svga_mi
    int 10h
    ;------------------

    ;modeInfo:
    ;Xresolution
    lea ax, mode1
    push ax
    call puts
    ;print the info
    mov ax, word ptr [di+12h]
    push ax
    call printInt
    call println

    ;Yresolution
    lea ax, mode2
    push ax
    call puts
    mov ax, word ptr [di+14h]
    push ax
    call printInt
    call println

    ;XcharSize
    lea ax, mode3
    push ax
    call puts
    mov al, byte ptr [di+16h]
    mov ah,0
    push ax
    call printInt
    call println
    ;YcharSize
    lea ax, mode4
    push ax
    call puts
    mov al, byte ptr [di+17h]
    mov ah,0
    push ax
    call printInt
    call println
    ;BitsPerPixel
    lea ax, mode5
    push ax
    call puts
    mov al, byte ptr [di+19h]
    mov ah,0
    push ax
    call printInt
    call println
    ;NumberOfBanks
    lea ax, mode6
    push ax
    call puts
    mov al, byte ptr [di+1ah]
    mov ah,0
    push ax
    call printInt
    call println
    ;MemoryModel
    lea ax, mode7
    push ax
    call puts
    mov al, byte ptr [di+1bh]
    mov ah,0
    push ax
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
