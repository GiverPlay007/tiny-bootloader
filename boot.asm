bits 16

mov ax, 0x07C0
mov ds, ax
mov ax, 0x07E0   ; 0x07E0 = (0x7C00 + 0x200) / 0x10, beginning of stack segment
mov ss, ax
mov sp, 0x2000   ; 8k of stack

call clearscreen

push 0x0000
call movecursor
add sp, 2

push msg
call print
add sp, 2

cli
hlt

clearscreen:
  push bp
  mov  bp, sp
  pusha

  mov ah, 0x07    ; Tells BIOS to scroll down window
  mov al, 0x00    ; Clear entire window
  mov bh, 0x07    ; White on black
  mov cx, 0x00    ; Specifies top left of screen as (0, 0)
  mov dh, 0x18    ; 24 rows of chars
  mov dl, 0x4F    ; 79 columns of chars
  int     0x10    ; Calls video interrupt

  popa
  mov sp, bp
  pop bp
  ret


movecursor:
  push bp
  mov  bp, sp
  pusha

  mov dx, [bp + 4]  ; Get the argument from the stack
  mov ah, 0x02      ; Set cursor position
  mov bh, 0x00      ; Page 0
  int     0x10      ; Calls video interrupt

  popa
  mov sp, bp
  pop bp
  ret


print:
  push bp
  mov  bp, sp
  pusha

  mov si, [bp + 4]   ; Grab the pointer to the data
  mov bh, 0x00       ; Page number, 0 again
  mov bl, 0x00       ; Foreground color
  mov ah, 0x0E       ; Print character to TTY

.char:
  mov al, [si]       ; Get the current character from our pointer position
  add si, 1          ; Keep incrementing si until we see a null character, 0
  or  al, 0
  je .return         ; End if the string is done
  int 0x10           ; Print the character if we're done
  jmp .char          ; Next character

.return:
  popa
  mov sp, bp
  pop bp
  ret


msg: db "Oh, this is amazing!", 0

times 510 - ($ - $$) db 0  ; Padding binary to a length of 510 bytes
dw    0xAA55               ; Boot signature ends in 0xAA55