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

         mov ebp, 0

         mov ecx, 1 ; a
_loop:
         push ecx
         
         mov esi, ecx

;        esp -> [a][ret]

         mov ecx, 2  ; b

_loop2:

         finit
         
         fild dword [esp] ; st = [st0] = [a]

         fmul st0  ; st = [st0] = [a*a]

         push ecx
         
;        esp -> [b][a][ret]

         fild dword [esp] ; st = [st0, st1] = [b, a*a]

         fmul st0  ; st = [st0, st1] = [b*b, a*a]

         faddp st1 ; st = [st0] = [b*b + a*a]

;        esp -> [b][a][ret]

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

;        esp -> [][][c][b][a][ret]

         mov eax, dword [esp]
         mov edx, dword [esp+4]

         add esp, 2*4
                                                       ; jak slysze techno stercza mi sutki mam mokro na pewno
;        esp -> [c][b][a][ret]                         ; ktos mowi ze chce wodki
                                                       ; musi sie wylewac z kieliiiiszka
         cmp eax, edx
         jne nie 
         
         cmp dword [esp], ebp  ; jak juz wystepowalo to zapisuje ostatni w pamieci na doel a tu porownuje se
         je nie                                   ;najebalem sie w chuj nie czuje nog nog nog nog nog nog nog

         push dword [esp+4]
         push dword [esp+12]
         
;        esp -> [a][b][c][b][a][ret]                                                 ; gdzie sa moi ludziee
                                                       ; JESTESMY TUUUUUU
         call getaddr12345                             ; moje crew cie pochowa i zbezczesci grob
                                                       ; moj styl to bbw jestem podly wiesz
format12345  db "%d, %d, %d ", 0xA, 0                  ; niby patrzysz z obrzydeniem ale cos w nim jest

getaddr12345:


;        esp -> [format12345][a][b][c][b][a][ret]

         call [ebx + 3*4]  ; printf("n = ")

	 add esp, 3*4
	 
;        esp -> [c][b][a][ret]

	 mov ebp, dword [esp]                          ; moje crew cie pochowa i zbezczesci grob
                                                       ; moj styl to bbw jestem podly wiesz
	 jmp dalej1                                    ; niby patrzysz z obrzydeniem ale cos w nim jest

nie:

         mov ecx, dword [esp]
         add esp, 4

;        esp -> [b][a][ret]

         cmp ecx, edi
         je dalej2

         inc ecx

         jne _loop3

dalej2:
         mov ecx, dword [esp]

         add esp, 4
         
;        esp -> [a][ret]

         inc ecx

         cmp ecx, edi
         je dalej1

         jne _loop2

dalej1:

         mov ecx, esi

         add esp, 4

;        esp -> [ret]

         inc ecx

         cmp ecx, edi
         je dalejwyjscie

         jne _loop

dalejwyjscie:

;        esp -> [ret]

         push 0
         call [ebx+0*4]