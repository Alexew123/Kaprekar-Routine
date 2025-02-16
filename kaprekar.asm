data segment para public 'DATA'
    in_msg db "Starting from: $"
    iter_msg db "Iterations: $"
    again_msg db "Again? (y/n): $"
    error_msg db "Wrong input, try again!$"
    mode_msg db "Interaction or Automatic mode? (i/a): $"
    done_msg db "Done!$"
    filename db "output.txt",0
    fhandle dw ?        ; variable to store the file handle
    num dw 0            ; variable to store the number entered by user
    num1 dw 0           ; variable to store the number sorted in descending order
    num2 dw 0           ; variable to store the number sorted in ascending order
    iter dw 0           ; variable to store the number of iterations
    buffer db "0000",0  ; buffer to store the number as a string for printing in file
    num_auto dw 0       ; variable to store the number for automatic mode
    newline db 13, 10, '$' ; Newline characters
    space db ' ',0          ; Space character
    mode db 'i',0           ; variable to store the mode of the program
data ENDS


PRINTMSG MACRO msg
    mov dx, offset msg ; print message
    mov ah, 09h
    int 21h
ENDM

READNR MACRO
    mov ah,01h ; read 1st digit from user input
    int 21h

    sub al,'0' ; transform the digit from ascii to decimal to see if it is a digit or not
    cmp al,9   ; if its above 9 it means its not a digit
    ja error   ; if the input is not a digit print error message
    add al,'0' ; bring al back to original value

    mov ah,0   ; clear ah

    sub ax,'0'  ; transform the digit from ascii to decimal
    mov bx,1000 ; prepare bx for multiplication
    mul bx      ; multiply the digit by 1000
    mov num, ax ; move 1st digit to the thousands place

    mov ah,01h  ; read 2nd digit from user
    int 21h

    sub al,'0' ; transform the digit from ascii to decimal to see if it is a digit or not
    cmp al,9   ; if its above 9 it means its not a digit
    ja error   ; if the input is not a digit print error message
    add al,'0' ; bring al back to original value

    mov ah,0 ; clear ah

    sub ax,'0' ; transform the digit from ascii to decimal
    mov bx,100  ; prepare bx for multiplication
    mul bx      ; multiply the digit by 100
    add num, ax ; move 2nd digit to the hundreds place

    mov ah,01h  ; read 3rd digit from user
    int 21h

    sub al,'0' ; transform the digit from ascii to decimal to see if it is a digit or not
    cmp al,9   ; if its above 9 it means its not a digit
    ja error ; if the input is not a digit print error message
    add al,'0' ; bring al back to original valu

    mov ah,0 ; clear ah

    sub ax,'0'  ; transform the digit from ascii to decimal
    mov bx,10   ; prepare bx for multiplication
    mul bx      ; multiply the digit by 10
    add num, ax ; move 3nd digit to the tens place

    mov ah,01h ; read 4th digit from user
    int 21h

    sub al,'0' ; transform the digit from ascii to decimal to see if it is a digit or not
    cmp al,9   ; if its above 9 it means its not a digit
    ja error   ; if the input is not a digit print error message
    add al,'0' ; bring al back to original valu

    mov ah,0 ; clear ah

    sub ax,'0' ; transform the digit from ascii to decimal
    add num, ax ; move the number read from the user to the num variable so we can use it later
   
    PRINTNL ; print new line

    jmp skip_error ; jump over the error message

error:
    PRINTNL ; print new line
    PRINTMSG error_msg ; print error message
    PRINTNL ; print new line
    jmp start_loop

skip_error:
ENDM

PRINTNL MACRO
    mov dl, 10 ;print new line
    mov ah, 02h 
    int 21h
ENDM

READCH MACRO
    mov ah,01h ; read the user input
    int 21h
ENDM

code segment para public 'CODE'
    assume cs:CODE
DISPLNR PROC FAR
	push bp		; standard access
	mov bp,sp	; sequence
	push dx
	push ax		; we will work with these registers in the 
			    ; procedure so we save them 
	push bx

	mov ax,[bp+6]  ; to get the number from stack we have to add by 6 the base pointer because
                    ; we pushed dx,ax,bx after we have pushed the number on the stack
                    ; this acts like moving the base pointer up by 3 positions

	cmp ax, 10		; if ax<10 then we have only one digit
	mov dl, al      ; incase we have only one digit move the digit to dl for printing
	jb display_1	; jump to display (we have only one number)

	mov bx, 10		; general case (ax>=10)
	mov dx, 0		; calculates ax/10 and ax mod 10
	div bx			; ax=ax/10;
					; dl=ax mod 10
	push ax			; recursive call with n/10 parameter
	call far ptr displnr
display_1:

	add dl, '0'		; transform the number to ascii for printing
	mov ah, 02h		; dos function for display
	int	21h			; display	

	pop	bx			; restoring
	pop	ax          ; registers
	pop dx
	pop	bp
	retf 2		;  far type return
displnr endp

DECR_SORT proc FAR

    mov cx,0    ; init the counter register
dig_on_stack:   ; place all the digits on the stack
    mov bx, 10  ; prepare bx for division
    mov dx,0    ; clear dx before division
    div bx      ; divide by 10
    push dx     ; the last digit will be found in dx so we push it onto the stack
    inc cx      ; increment counter register
    cmp cx,4    ; loop condition
    jne dig_on_stack


    mov cx,4

outer_loop:
    mov bx,3    ; bx will be used as a counter for the inner loop
    mov bp,sp   ; bp will be used as a pointer to the stack
    dec cx      ; decrement the counter register

cmp_loop:
    mov al,[bp] ; move 1st digit in al for cmp
    mov dl,[bp+2] ; move 2nd in dl for cmp

    cmp al,dl ; cmp the 2 digits

    jge no_swap ;if al>=dl don't swap

    mov [bp],dl ; if al<dl swap the 2 of them on the stack
    add bp,2
    mov [bp],al
    sub bp,2

no_swap:
    add bp,2    ; move the pointer to the next digit if no swap has occured
    dec bx      ; decrement the inner loop counter
    cmp cx,0    ; check if the outer loop has finished
    je pop_dig  ; if yes, the number is sorted and we got to extract it from the stack

    cmp bx,0    ; check if the inner loop has finished
    jnz cmp_loop    ; if not, jump to the inner loop
    jmp outer_loop  ; if yes, jump to the outer loop

pop_dig:
    mov bp,sp   ; init the bp with the sp
    mov ax,0    ; init ax
    mov bx,1000 ; prepare bx for multiplication
    mov dx,0    ; clear dx for multiplication
pop_dig_loop:
    mov ax,[bp] ; move the digit to ax

    mul bx      ; multiply the digit by 1000/100/10/1

    cmp cx,0
    je skip_pop
    pop dx

skip_pop:
    add bp,2     ; move to the next digit
    add dx,ax    ; add the result of the multiplication to dx

    push dx      ; DIV and MUL changes the value of dx so we save it onto the stack

    mov ax,bx    ; move the value of bx to ax so we can divide it by 10
    mov bx,10    ; prepare bx for division
    mov dx,0     ; clear dx for division
    div bx       ; divide by 10
    mov bx,ax    ; move the result of the division to bx


    inc cx       ; increment the counter register
    cmp cx,4     ; check if we have extracted all the digits
    jne pop_dig_loop  ; if not, jump to the loop

    pop dx       ; if yes, pop the number from the stack into dx

    add sp,8     ; return the stack to the original value

    RETF
DECR_SORT ENDP

ASC_SORT proc FAR

    mov cx,0   ; init the counter register
dig_on_stack_asc:  ; place all the digits on the stack
    mov bx, 10 ; prepare bx for division
    mov dx,0   ; clear dx before division
    div bx     ; divide by 10
    push dx    ; the last digit will be found in dx so we push it onto the stack
    inc cx     ; increment counter register
    cmp cx,4   ; loop condition
    jne dig_on_stack_asc


    mov cx,4   ; init the counter register for outer loop

outer_loop_asc:
    mov bx,3   ; bx will act as a counter for the inner loop
    mov bp,sp  ; init the pointer to the stack
    dec cx     ; decrement the counter register every time the outer loop is called

cmp_loop_asc:
    mov al,[bp] ; move 1st digit in al for cmp
    mov dl,[bp+2] ; move 2nd in dl for cmp

    cmp al,dl ; cmp the 2 digits

    jle no_swap_asc ;if al>=dl don't swap

    mov [bp],dl ; if al<dl swap the 2 of them on the stack
    add bp,2
    mov [bp],al
    sub bp,2

no_swap_asc:
    add bp,2   ; move the pointer to the next digit if no swap has occured
    dec bx     ; decrement the inner loop counter
    cmp cx,0   ; check if the outer loop has finished
    je pop_dig_asc ; if yes, pop the sorted digits from the stack

    cmp bx,0           ; check if the inner loop has finished
    jnz cmp_loop_asc   ; if not, jump to the inner loop
    jmp outer_loop_asc ; if yes, jump to the outer loop 

pop_dig_asc:
    mov bp,sp     ; init the bp with the sp
    mov ax,0      ; init ax to 0
    mov bx,1000   ; init bx to 1000 for multiplication
    mov dx,0      ; init dx to 0 for multiplication
pop_dig_loop_asc:
    mov ax,[bp]   ; move the 1st digit to ax

    mul bx        ; multiply the digit by 1000/100/10/1

    cmp cx,0
    je skip_pop_asc
    pop dx

skip_pop_asc:
    add bp,2  ; move to the next digit
    add dx,ax ; add the result of the multiplication to dx

    push dx ; DIV and MUL changes the value of dx so we save it onto the stack

    mov ax,bx ; move the value of bx to ax so we can divide it by 10
    mov bx,10 ; prepare bx for division
    mov dx,0  ; clear dx for division
    div bx    ; divide by 10
    mov bx,ax ; move the result of the division to bx


    inc cx    ; increment the counter register
    cmp cx,4  ; check if we have extracted all the digits
    jne pop_dig_loop_asc ; if not, jump to the loop

    pop dx    ; if yes, pop the number from the stack into dx
    add sp,8  ; return the stack to the original value

    RETF 
ASC_SORT ENDP


IntToStr proc far
    push ax              ; Save registers
    push bx
    push cx
    push dx

    mov bx, 10           ; prepare bx for division
    mov di, offset buffer + 3 ; move destination index at the end of the buffer string

DivideLoop:
    mov dx, 0            ; clear dx for division
    div bx               ; divide ax by 10
    add dl, '0'          ; convert remainder to ascii
    mov [di], dl         ; Store ascii value in buffer
    dec di               ; Move to the next position in buffer
    inc cx               ; increment digit counter
    cmp ax, 0            ; check if quotient is zero
    jne DivideLoop       ; if not, continue dividing

    pop dx               ; Restore registers
    pop cx
    pop bx
    pop ax

    retf
IntToStr endp



start proc FAR
    assume cs:CODE, ds:DATA
    push DS        ; init data segment
    xor ax,AX
    push ax
    mov ax, data
    mov ds,ax
    mov ax,0       ; clear ax

mode_select:
    PRINTMSG mode_msg ; print the message for the user to input a mode
    
    READCH            ; read the user input

    mov mode,al       ; save the user input(mode) in the mode variable

    cmp mode,'i'      ; check if the user wants Interaction mode
    je start_loop_far ; if yes, jump to the start of the interaction program

    cmp mode,'a'      ; check if the user wants Automatic mode
    je automatic_loop ; if yes, jump to the start of the automatic program

    PRINTNL           ; print new line
    jmp mode_select   ; if the input is neither i nor a, ask again

start_loop_far:
    jmp start_loop    ; start_loop is too far to be accesed by je so we use jmp

automatic_loop:
    mov ah, 3Ch       ; create file
    lea dx, filename  ; move to dx the file name
    mov cx, 0         ; normal file (read/write)
    int 21h

    mov fhandle, ax    ; save the file handle into the variable fhandle

    jnc fwrite_loop    ; if the file created successfully, jump to the fwrite_loop
    jmp end_program    ; else, end the program

fwrite_loop:

    mov ax,num_auto       ; move the number to ax

    call far ptr IntToStr ; convert the number to string

    mov ah, 40h           ; write to file
    mov bx, fhandle       ; file handle into bx
    lea dx, buffer        ; move to dx the numbers 0000-9999
    mov cx,4              ; number of bytes to write
    int 21h

    mov ah, 40h           ; write to file
    mov bx, fhandle       ; file handle into bx
    lea dx, space         ; print space
    mov cx,1              ; number of bytes to write
    int 21h

    mov ax,num_auto       ; move the number to ax
    mov num,ax            ; move ax to num so we can use it in the kaprekar loop to get the iterations

    mov iter,0            ; init the iteration counter
    jmp main_loop         ; jump to the kaprekar loop to get iter

iter_value:
    add iter,'0'    ; convert the number of iterations to ascii for writing in file

    mov ah, 40h     ; write to file
    mov bx, fhandle ; file handle into bx
    lea dx, iter    ; print the number of iterations
    mov cx,1        ; number of bytes to write
    int 21h
    

    add num_auto, 1 ; increment number

    mov ah, 40h ; write newline to file
    mov bx, fhandle
    lea dx, newline
    mov cx,2
    int 21h

    cmp num_auto, 10000 ; check if the buffer is 9999
    jne fwrite_loop     ; if not, loop

    mov ah, 3Eh         ; if yes, close file and end program
    mov bx,fhandle
    int 21h

    PRINTNL             ; print new line
    PRINTMSG done_msg   ; print done message

    mov ax, 4c00h ; end program
    int 21h



start_loop:
    PRINTNL         ; print new line
    PRINTMSG in_msg ; print input message

    READNR          ; read number from user

    mov iter,0      ; init the iteration counter
main_loop:

    mov ax,num        ; sort the number in descending order
    call far ptr DECR_SORT
    mov num1,dx       ; place the sorted(decreasing) number in num1

    cmp mode,'a'      ; check if the mode is automatic
    je skip_1         ; if yes, skip the print of the number and the - sign

    mov ax,num1       ; print the sorted number
    push ax
    call far ptr DISPLNR

    mov dl,'-'        ; print - sign
    mov ah,02h
    int 21h

skip_1:
    mov ax,num         ; sort the number in ascending order
    call far ptr ASC_SORT
    mov num2,dx        ; place the sorted(ascending) number in num2

    cmp mode,'a'       ; check if the mode is automatic
    je skip_2          ; if yes, skip the print of the number

    mov ax,num2        ; print the sorted number
    push ax
    call far ptr DISPLNR

skip_2:
    mov ax,num2        ; use ax as a buffer so we can use sub instruction
    sub num1,ax        ; subtract the 2 numbers

    cmp mode,'a'       ; check if the mode is automatic
    je skip_3          ; if yes, skip the print of the number and the = sign

    mov dl, '='        ; print = sign
    mov ah,02h
    int 21h


    mov ax,num1        ; print the result of subtraction
    push ax
    call far ptr DISPLNR

    PRINTNL            ; print new line

skip_3:
    mov ax,num1        ; use ax as a buffer for mov instruction
    mov num,ax         ; move the result of subtraction to num so we can loop

    add iter,1         ; increment the iteration counter

    cmp num,6174       ; check if the number is 6174(Kaprekar's constant)
    jne cmp_zero       ; if not, compare with 0

    jmp print_iter     ; if it is, end the program

cmp_zero:
    cmp num,0          ; check if the number is 0
    jne main_loop      ; if not, loop
                       ; if yes, print nr of iterations

print_iter:

    cmp mode,'a'       ; check if the mode is automatic
    je iter_value_far  ; if yes, jump to the start of the automatic program to loop again
                       ; if not, print the number of iterations

    PRINTMSG iter_msg  ; print the message for the number of iterations

    mov ax,iter        ; print the number of iterations
    push ax
    call far ptr DISPLNR

    PRINTNL            ; print new line
again:
    PRINTNL            ; print new line
    PRINTMSG again_msg ; print the message for the user to input y/n

    READCH             ; read the user input to see if he wants to input another number

    cmp al,'y'         ; check if the user wants to input another number
    jne end_program    ; if no, end program
                       ; if yes ask for another number

    PRINTNL ; print new line
    call far ptr start_loop
    
end_program:
    cmp al,'n'         ; check if the user wants to end the program
    jne again          ; if the answer is neither y nor n ask again
                       ; if answer is 'n', end the program

    mov ax, 4c00h ; call dos to end program
    int 21h

iter_value_far:
    jmp iter_value     ; iter_value is too far to be accesed by je so we use jmp


start ENDP
code ENDS
end start