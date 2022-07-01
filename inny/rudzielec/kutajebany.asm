[bits 32]
;        esp -> [ret]

         call getaddrX     ; push on the stack the run-time address of formatX

formatX  db "x = ", 0
getaddrX call [ebx + 3*4]  ; printf(x =)

;        esp -> [formatX][ret]

         sub esp, 4  ; esp = esp - 4

;        esp -> [][formatX][ret]

         push esp  ; esp -> stack

;        esp -> [addr_x][][formatX][ret]

         call getaddr      ; push on the stack the run-time address of format
format   db "%lf", 0
getaddr:

;        esp -> [format][addr_x][][formatX][ret]

         call [ebx + 4*4]  ; scanf("%lf", &addr_x)

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][formatX][ret]

         call getaddr2           ; push on the stack the run-time address of format2

format2  db 0xA, "n = ", 0
getaddr2 call [ebx + 3*4]  ; printf(n = )

;        esp -> [format2][x][formatX][ret]

         push esp

;        esp -> [addr_n][format2][x][formatX][ret]

         call getaddr3           ; push on the stack the run-time address of format3

format3  db "%d", 0
getaddr3:

;        esp -> [format3][addr_n][format2][x][formatX][ret]

         call [ebx + 4*4]

         add esp, 2*4

;        esp -> [n][x][formatX][ret]

         cmp dword [esp], 0  ; n - 0
         jns abc             ; jump if not signed set     ; SF = 0

         neg dword [esp]

abc:

         mov ecx, dword [esp]        ; ecx = *(int*)esp = n
         inc ecx                     ; ecx = ecx + 1
         add esp, 4                  ; esp = esp + 4

;        esp -> [x][formatX][ret]

         fld1  ; 1 -> st; FPU load integer

;        st = [st0] = [1]

         fld1  ; 1 -> st; FPU load integer

;        st = [st0, st1] = [1, 1]

         fsubp st1 ; [st0, st1] => [st0-st1] = [1 - 1]

;        st = [st0] = [0]

         fld qword[esp]

;        st = [st0, st1] = [x, suma]

petla:

;        esp -> [x][formatX][ret]

         dec ecx   ; ecx--
         push ecx  ; ecx -> stack

;        esp -> [ecx][x][formatX][ret]

         call getaddr_a                 ; push on the stack the run-time address of format_a

format_a db 0xA, "a%d = ", 0
getaddr_a:

;        esp -> [format_a][ecx][x][formatX][ret]

         call [ebx + 3*4]  ; printf(a%d = )
         add esp, 4        ; esp = esp + 4

;        esp -> [ecx][x][formatX][ret]

         sub esp, 2*4
;        esp -> [][][ecx][x][formatX][ret]

         push esp
;        esp -> [addr_a][][][ecx][x][formatX][ret]

         call getaddr_a1                 ; push on the stack the run-time address of format_a1

format_a1 db "%lf", 0
getaddr_a1:

;        esp -> [format_a1][addr_a][][][ecx][x][formatX][ret]

         call [ebx + 4*4]  ; scanf("%lf", &addr_a)
         add esp, 2*4

;        esp -> [a][][ecx][x][formatX][ret]

         fld qword [esp]  ; a -> st; FPU load integer

;        st = [st0, st1, st2] = [a, x, suma]

         add esp, 2*4

;        esp -> [ecx][x][formatX][ret]

         fadd st2, st0    ; [st0, st1, st2] => [a, x, suma + a]
         fstp st0         ; a <- st = [x, suma + a]
         fxch st1         ; [st0, st1] = [sum + a, x]
         fmul st1         ; [st0, st1] = [(sum + a)*x, x]
         fxch st1         ; [st0, st1] = [x, (sum + a)*x]

         pop ecx
         
;        esp -> [x][formatX][ret]

         add ecx, 1

         loop petla

         fdiv st1, st0           ; [st0, st1] = [x, (((sum + a)*x)/x)]
         fstp st0                ; x <- st = [((sum + a)*x)/x)]
         fstp qword [esp + 2*4]  ; st = []

;        esp -> [x][(((sum + a)*x)/x)][ret]

         call getaddrW                               ; push on the stack the run-time address of formatW

formatW  db 0xA, "W(%f) = %f", 0xA, 0
getaddrW:

;        esp -> [formatW][x][(((sum + a)*x)/x)][ret]

         call [ebx + 3*4]  ; printf(formatW)
         add esp, 3*4

;        esp -> [ret]

         push 0         ; esp -> [0][ret]
         call [ebx+0*4] ; exit(0);


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