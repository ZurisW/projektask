[bits 32]

;        esp -> [ret] ; ret - adres powrotu do asmloader

         call getaddr ; push on the stack the run-time address of format

format  db "n = ", 0

getaddr:

;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("n = ")

         push esp  ; esp -> stack

;        esp -> [addr_n][format][ret]

         call getn  ; push on the stack the run-time address of formatn

formatn  db "%d", 0

getn:

;        esp -> [formatn][addr_n][format][ret]

         call [ebx + 4*4]  ; scanf("%d", &addr_n)

         add esp, 2*4  ; esp = esp + 8
         
;        esp -> [n][ret]

         cmp dword [esp], 0  ; *(int*)esp - 0 = n - 0
         jns dalej           ; jump if not signed set ; SF = 0

         neg dword [esp]     ; *(int*)esp = - (*(*int*)esp)

dalej:

         mov edi, dword [esp]  ; ecx = *(int*)esp = n

         add esp, 4  ; esp = esp + 4
         
;        esp -> [ret]

         cmp edi, 2
         jle dalejwyjscie

         mov ebp, 0  ; ebp = 0

         mov ecx, 1  ; ecx = 1 ; a
_loop:
         push ecx  ; ecx -> stack
         
;        esp -> [a][ret]

         mov esi, ecx

         mov ecx, 2  ; ecx = 2 ; b

_loop2:

         finit  ; fpu init
         
         fild dword [esp] ; st = [st0] = [a]

         fmul st0  ; st = [st0] = [a*a]

         push ecx  ; ecx -> stack
         
;        esp -> [b][a][ret]

         fild dword [esp] ; st = [st0, st1] = [b, a*a]

         fmul st0  ; st = [st0, st1] = [b*b, a*a]

         faddp st1 ; st = [st0] = [b*b + a*a]

         mov ecx, 3  ; ecx = 3 ; c

_loop3:

         push ecx  ; ecx -> stack
         
;        esp -> [c][b][a][ret]

         fild dword [esp] ; st = [st0, st1] = [c, b*b + a*a]

         fmul st0  ; st = [st0, st1] = [c*c, b*b + a*a]

         sub esp, 2*4  ; esp = esp - 8
         
;        esp -> [][][c][b][a][ret]         

         fistp dword [esp]   ; *(int*)esp = c*c
         fist dword [esp+4]  ; *(int*)(esp + 4) = b*b + a*a
          
;        st = [st0] = [b*b + a*a]

;        esp -> [c*c][b*b + a*a][c][b][a][ret]

         mov eax, dword [esp]    ; eax = *(int*)esp
         mov edx, dword [esp+4]  ; edx = *(int*)(esp + 4)

         add esp, 2*4  ; esp = esp + 8

;        esp -> [c][b][a][ret]

         cmp eax, edx  ; eax - edx
         jne nie       ; jump if not equal ; ZF affected

         mov eax, dword [esp+4]  ; eax = *(int*)(esp + 4) = b
         cmp dword [esp+8], eax  ; *(int*)(esp + 8) - eax = a - b
         jns nie                 ; jump if not signed ; SF affected

         push dword [esp+4]   ; b -> stack
         push dword [esp+12]  ; a -> stack
         
;        esp -> [a][b][c][b][a][ret]

         call getaddr2

format2  db "%d, %d, %d ", 0xA, 0

getaddr2:

;        esp -> [format2][a][b][c][b][a][ret]

         call [ebx + 3*4]  ; printf("%d, %d, %d", a, b, c)

	     add esp, 3*4  ; esp = esp + 12
	 
;        esp -> [c][b][a][ret]

	     mov ebp, dword [esp]  ; ebp - (*(int*)esp)
	     jmp dalej1            ; jump dalej1

nie:

         mov ecx, dword [esp]  ; ecx = *(int*)esp ; restore ecx
         add esp, 4            ; esp = esp + 4

;        esp -> [b][a][ret]

         cmp ecx, edi  ; ecx - edi
         je dalej2     ; jump if equal ; ZF affected

         inc ecx  ; ecx++

         jne _loop3  ; jump if not equal ; ZF affected

dalej2:
         mov ecx, dword [esp]  ; ecx = *(int*)esp  ; restore ecx
         add esp, 4            ; esp = esp + 4
         
;        esp -> [a][ret]

         inc ecx  ; ecx++

         cmp ecx, edi  ; ecx - edi
         je dalej1     ; jump if equal ; ZF affected

         jne _loop2  ; jump if not equal ; ZF affected

dalej1:

         mov ecx, esi  ; ecx = esi ; restore ecx
         add esp, 4    ; esp = esp + 4

;        esp -> [ret]

         inc ecx  ; ecx++

         cmp ecx, edi     ; ecx - edi
         je dalejwyjscie  ; jump if equal ; ZF affected

         jne _loop  ; jump if not equal ; ZF affected

dalejwyjscie:

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call [ebx+0*4]  ; exit 0;