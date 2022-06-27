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

         finit
         



         mov ecx, 1 ; a
_loop:

         mov esi, ecx  ; store ecx
               
         push ecx

;        esp -> [ecx][ret]

         fild dword [esp] ; st = [st0] = [a]

         fmul st0  ; st = [st0] = [a*a]

         ;sub esp, 4
         ;fistp dword [esp]

         call getaddr123

format123  db "petla1 = %d", 0xA, 0

getaddr123:


;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 2*4
	 


         mov ecx, 2  ; b
         
         
         ; loop ; ;; ; loop ;; ; ;
_loop2:

         mov ebp, ecx
         
         push ecx

         fild dword [esp] ; st = [st0, st1] = [b, a*a]

         fmul st0  ; st = [st0, st1] = [b*b, a*a]

         faddp st1 ; st = [st0] = [b*b + a*a]

         call getaddr1234

format1234  db "        petla2 = %d", 0xA, 0

getaddr1234:


;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 2*4
	 
	 ; LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOP

         mov ecx, 3  ; c

_loop3:

         push ecx

         fild dword [esp] ; st = [st0, st1] = [c, b*b + a*a]

         fmul st0  ; st = [st0, st1] = [c*c, b*b + a*a]

         sub esp, 2*4
         
         fistp dword [esp]   ; c*c
         fist dword [esp+4]  ; b*b + a*a

         mov eax, [esp]
         mov edx, [esp+4]
         
         push edx
         push eax

                  call getaddr123456

format123456  db "                 c*c = %d,  a*a+b*b = %d", 0xA, 0

getaddr123456:

             call [ebx + 3*4]  ; printf("n = ")


         add esp, 5*4

         cmp eax, edx
         jne nie


         call getaddr12345

format12345  db "                  zwyciestwo", 0xA, 0

getaddr12345:


;        esp -> [format12345][ecx][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 4

nie:

         mov ecx, [esp]
         add esp, 4




         cmp ecx, edi
         je dalej2

         inc ecx

         jne _loop3




dalej2:

         sub esp, 4
         fistp dword [esp]
         sub esp, 4
         fld1
         fld1

         mov ecx, ebp


         inc ecx

         cmp ecx, edi
         je dalej1


         jne _loop2


dalej1:
          
         mov ecx, esi

         inc ecx

         cmp ecx, edi
         je dalejwyjscie

         jne _loop

dalejwyjscie:



;        esp -> [ret]

         push 0
         call [ebx+0*4]