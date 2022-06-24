[bits 32]

;        esp -> [ret]
         call getaddrX

formatX  db "x = ", 0
getaddrX call [ebx + 3*4]

;        esp -> [][][ret]
         sub esp, 4

         push esp
         call getaddr

format   db "%lf", 0
getaddr  call [ebx + 4*4]
;        esp -> [format][addr_x][x][][][][ret]

         add esp, 2*4
;        esp -> [x][][][][ret]

         cmp dword [esp+4], 0
         jz zero

         call getaddr2

format2  db 0xA, "n = ", 0
getaddr2 call [ebx + 3*4]
;        esp -> [][x][][][][ret]

         push esp
;        esp -> [addr_n][][x][][][][ret]

         call getaddr3

format3  db "%d", 0
getaddr3 call [ebx + 4*4]
;        esp -> [format3][addr_n][n][x][][][][ret]

         add esp, 2*4
;        esp -> [n][x][][][][ret]

         cmp dword [esp], 0      ; n - 0
         jns abc   ; jump if not signed set     ; SF = 0

         neg dword [esp]  

abc:

         mov ecx, dword [esp]
         inc ecx
         add esp, 4

;        esp -> [x][][][][ret]

         fld1
         fld1
;        sprawdzic to dziwne jest
         fsubp

         fld qword[esp]

;        fstp qword[esp+2*4]

petla:
;        esp -> [x][][1][][ret]  ; st = [x, sum]

         sub ecx, 1
         push ecx

;        esp -> [ecx][x][][1][][ret]

         call getaddr_a

format_a db 0xA, "a%d = ", 0
getaddr_a:

         call [ebx + 3*4]
         add esp, 4
         
         sub esp, 2*4
;        esp -> [][][ecx][x][][1][][ret]

         push esp
;        esp -> [addr_a][][][ecx][x][][1][][ret]

         call getaddr_a1

format_a1 db "%lf", 0
getaddr_a1:

         call [ebx + 4*4]
         add esp, 2*4
;        esp -> [a][][ecx][x][][1][][ret]

         fld qword [esp]  ; st = [a, x, sum]
         add esp, 2*4
;        esp -> [ecx][x][][1][][ret]

         fadd st2, st0    ; st = [a, x, sum + a]
         fstp st0         ; st = [x, sum + a]
         fxch st1         ; st = [sum + a, x]
         fmul st1         ; st = [(sum + a)*x, x]
         fxch st1         ; st = [x, (sum + a)*x]

;        esp -> [ecx][x][][1][][ret]

         pop ecx
         add ecx, 1

;        esp -> [x][][1][][ret]  ; st = [x, sum]

         loop petla

         fdiv st1, st0
         fstp st0
         fstp qword [esp + 2*4]

         call getaddrW

formatW  db 0xA, "W(%f) = %f", 0xA, 0
getaddrW:

;        esp -> [formatW][x][][1][][ret]

         call [ebx + 3*4]
         add esp, 5*4




         push 0         ; esp -> [0][ret]
         call [ebx+0*4] ; exit(0);
         
zero     call getaddrzero  ; push on the stack the run-time address of format_a1

format_zero  db "Nie mozna dzielic przez zero", 0
getaddrzero:

;        esp -> [format_zero][x][][][][ret]

         call [ebx + 3*4]  ; printf (format_zero)

         add esp, 5*4  ; esp = esp + 20

         push 0            ; esp -> [0][ret]
         call [ebx + 0*4]  ; exit(0);

; asmloader API
;
; ESP wskazuje na prawidlowy stos
; argumenty funkcji wrzucamy na stos
; EBX zawiera pointer na tablice API
;
; call [ebx + NR_FUNKCJI*4] ; wywolanie funkcji API
;
; NR_FUNKCJI:
;
; 0 - exit
; 1 - putchar
; 2 - getchar
; 3 - printf
; 4 - scanf
;
; To co funkcja zwróci jest w EAX.
; Po wywolaniu funkcji sciagamy argumenty ze stosu.

; https://gynvael.coldwind.pl/?id=38