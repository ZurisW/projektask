[bits 32]

;        esp -> [ret] ; ret - adres powrotu do asmloader

         call getaddr

format  db "n = ", 0

getaddr:

;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("n = ")

         push esp

;        esp -> [addr_n][format][ret]

         call getn  ; push on the stack the run-time address of format2

formatn  db "%d", 0

getn:

;        esp -> [formatn][addr_n][format][ret]

         call [ebx + 4*4]  ; scanf("%f", &x)

         add esp, 2*4  ; esp = esp + 8
         
;        esp -> [n][ret]


         ; ^ trza to inkrementnac +1 to bedzie dzialalo ze [] a nie ()

         cmp dword [esp], 0  ; n - 0
         jns dalej           ; jump if not signed set     ; SF = 0

         neg dword [esp]

dalej:

         mov edi, dword [esp]  ; ecx = *(int*)esp = n

         add esp, 4  ; esp = esp + 4
         
;        esp -> [ret]


         



         mov ecx, 1 ; a
_loop:
         finit
         mov esi, ecx  ; store ecx
               
         push ecx

;        esp -> [a][ret]

call getaddr123457

format123457  db "petla1 = %d ", 0xA, 0

getaddr123457:


;        esp -> [format12345][ecx][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 4


         mov ecx, 2  ; b

_loop2:

         mov ebp, ecx
         
         fild dword [esp] ; st = [st0] = [a]

         fmul st0  ; st = [st0] = [a*a]

         push ecx
         
;        esp -> [b][a][ret]
         
         fild dword [esp] ; st = [st0, st1] = [b, a*a]

         fmul st0  ; st = [st0, st1] = [b*b, a*a]

         faddp st1 ; st = [st0] = [b*b + a*a]

;        esp -> [b][a][ret]

         call getaddr123456

format123456  db "         petla2 = %d", 0xA, 0

getaddr123456:


;        esp -> [format12345][b][a][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 4

         mov ecx, 3  ; c

_loop3:

         push ecx
         
;        esp -> [c][b][a][ret]

         fild dword [esp] ; st = [st0, st1] = [c, b*b + a*a]

         fmul st0  ; st = [st0, st1] = [c*c, b*b + a*a]

         sub esp, 2*4
         
;        esp -> [][][c][b][a][ret]         

         fistp dword [esp]   ; c*c
         fist dword [esp+4]  ; b*b + a*a
          
;        st = [st0] = [b*b + a*a]

         call getaddr123458

format123458  db "                 c*c = %d, a*a+b*b = %d, petla3 = %d", 0xA, 0

getaddr123458:


;        esp -> [format12345][ecx][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 4

;        esp -> [][][c][b][a][ret]

         mov eax, dword [esp]
         mov edx, dword [esp+4]

         add esp, 2*4
         
;        esp -> [c][b][a][ret]

         cmp eax, edx
         jne nie

         call getaddr12345

format12345  db "                                                KURWY   %d, %d, %d ", 0xA, 0

getaddr12345:


;        esp -> [format12345][ecx][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 4

	 jmp dalej1

nie:

         mov ecx, [esp]
         add esp, 4

;        esp -> [b][a][ret]

         cmp ecx, edi
         je dalej2

         inc ecx

         jne _loop3




dalej2:

         add esp, 4
         
;        esp -> [a][ret]

         mov ecx, ebp


         inc ecx

         cmp ecx, edi
         je dalej1

         jne _loop2


dalej1:

         add esp, 4
         
;        esp -> [ret]

         mov ecx, esi

         inc ecx

         cmp ecx, edi
         je dalejwyjscie

         jne _loop

dalejwyjscie:



;        esp -> [ret]

         push 0
         call [ebx+0*4]