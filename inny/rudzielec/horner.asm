         [bits 32]
;        esp -> [ret]

         call getaddr_x  ; push on the stack the run-time address of formatX

format:
         db "x = ", 0
getaddr_x:

;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("x = ")

         sub esp, 4  ; esp = esp - 4

;        esp -> [][format][ret]

         push esp  ; esp -> stack

;        esp -> [addr_x][][format][ret]

         call getaddr2  ; push on the stack the run-time address of format
format2:
         db "%lf", 0
getaddr2:

;        esp -> [format2][addr_x][][format][ret]

         call [ebx + 4*4]  ; scanf("%lf", &addr_x)

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][format][ret]

         call getaddr_n  ; push on the stack the run-time address of format2

format3:
         db 0xA, "n = ", 0
getaddr_n:

;        esp -> [format3][x][format][ret]

         call [ebx + 3*4]  ; printf("n = ");

         push esp

;        esp -> [addr_n][format3][x][format][ret]

         call getaddr4  ; push on the stack the run-time address of format3

format4:
         db "%d", 0
getaddr4:

;        esp -> [format4][addr_n][format3][x][format][ret]

         call [ebx + 4*4]

         add esp, 2*4

;        esp -> [n][x][format][ret]

         cmp dword [esp], 0  ; n - 0
         jns abc             ; jump if not signed set     ; SF = 0

         neg dword [esp]

abc:
         
         mov ecx, dword [esp]        ; ecx = *(int*)esp = n
         inc ecx                     ; ecx = ecx + 1
         add esp, 4                  ; esp = esp + 4

;        esp -> [x][format][ret]

         fld1  ; 1 -> st; FPU load integer

;        st = [st0] = [1]

         fld1  ; 1 -> st; FPU load integer

;        st = [st0, st1] = [1, 1]

         fsubp st1 ; [st0, st1] => [st0-st1] = [1 - 1]

;        st = [st0] = [0]

         fld qword[esp]

;        st = [st0, st1] = [x, suma]

petla:

;        esp -> [x][format][ret]

         dec ecx   ; ecx--
         push ecx  ; ecx -> stack

;        esp -> [ecx][x][format][ret]

         call getaddr_a  ; push on the stack the run-time address of format_a

format5:
         db 0xA, "a%d = ", 0
getaddr_a:

;        esp -> [format5][ecx][x][format][ret]

         call [ebx + 3*4]  ; printf(a%d = )
         add esp, 4        ; esp = esp + 4

;        esp -> [ecx][x][format][ret]

         sub esp, 2*4
;        esp -> [][][ecx][x][format][ret]

         push esp
;        esp -> [addr_a][][][ecx][x][format][ret]

         call getaddr6  ; push on the stack the run-time address of format_a1

format6:
         db "%lf", 0
getaddr6:

;        esp -> [format6][addr_a][][][ecx][x][format][ret]

         call [ebx + 4*4]  ; scanf("%lf", &addr_a)
         add esp, 2*4

;        esp -> [a][][ecx][x][format][ret]

         fld qword [esp]  ; a -> st; FPU load
         fst qword [esp+20]

;        st = [st0, st1, st2] = [a, x, suma]

         add esp, 2*4

;        esp -> [ecx][x][format][ret]

         fadd st2, st0    ; [st0, st1, st2] => [a, x, suma + a]
         fstp st0         ; a <- st = [x, suma + a]
         fxch st1         ; [st0, st1] = [sum + a, x]
         fmul st1         ; [st0, st1] = [(sum + a)*x, x]
         fxch st1         ; [st0, st1] = [x, (sum + a)*x]

         pop ecx
         
;        esp -> [x][format][ret]

         add ecx, 1

         loop petla
         
         sub esp, 4

;        esp -> [yœ][x][format][ret]

         fist dword [esp]

         cmp dword [esp], 0

         je niedziel

         fdiv st1, st0           ; [st0, st1] = [x, (((sum + a)*x)/x)]

         fstp st0                ; x <- st = [((sum + a)*x)/x)]
         fstp qword [esp + 3*4]  ; st = []

niedziel:
         add esp, 4
;        esp -> [x][(((sum + a)*x)/x)][ret]

         call getaddr_w  ; push on the stack the run-time address of formatW

format7:
         db 0xA, "W(%f) = %f", 0xA, 0
getaddr_w:

;        esp -> [format7][x][(((sum + a)*x)/x)][ret]

         call [ebx + 3*4]  ; printf(format7)
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