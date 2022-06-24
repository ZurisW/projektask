
        [bits 32]

         mov ebp, ebx  ; kopiujê rejestr ebx do ebp

         finit  ; fpu init

;        esp -> [ret]  ; ret - adres powrotu do asmloader

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][ret]  ; ret - adres powrotu do asmloader

         call getx  ; push on the stack the run-time address of format1

format1  db "x = ", 0

getx:

;        esp -> [format1][][][ret]

         call [ebp + 3*4]  ; printf("x = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [][][ret]

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][][][ret]

         push esp

;        esp -> [addr_x][][][][][ret]

         call getx1  ; push on the stack the run-time address of format2

format2  db "%lf", 0

getx1:

;        esp -> [format2][addr_x][][][][][ret]

         call [ebp + 4*4]  ; scanf("%f", &x)

;        esp -> [format2][addr_x][x][][][][ret]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][][][ret]

         call getn  ; push on the stack the run-time address of format3

format3  db 0xA, "n = ", 0

getn:

;        esp -> [format3][x][][][][ret]

         call [ebp + 3*4]  ; printf("n = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][][][ret]

         sub esp, 4  ; esp = esp - 4

;        esp -> [][x][][][][ret]

         push esp

;        esp -> [addr_n][][x][][][][ret]

         call getn1  ; push on the stack the run-time address of format4

format4  db "%d", 0

getn1:

;        esp -> [format4][addr_n][][x][][][][ret]

         call [ebp + 4*4]  ; scanf("%d", &n)

;        esp -> [format4][addr_n][n][x][][][][ret]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [n][x][][][][ret]

         cmp dword [esp], 0      ; n - 0
         jns bez   ; jump if not signed set     ; SF = 0

         neg dword [esp]

bez:

         mov ecx, dword [esp]  ; ecx = *(int*)esp = n

         inc ecx  ; ecx = ecx + 1

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][][][ret]

         fldz  ; st = [st0] = [0] ;

         fld qword [esp]  ; st = [st0, st1] = [x, suma]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [][][ret]

petla:

;        esp -> [][][ret]  ; st = [st0, st1] = [x, suma]

         dec ecx  ; ecx = ecx - 1

         mov ebx, ecx  ; ebx = ecx

         push ecx

;        esp -> [ecx][][][ret]

         call getaddr_a  ; push on the stack the run-time address of format_a

format_a db "a%d = ", 0

getaddr_a:

;        esp -> [format_a][ecx][][][ret]

         call [ebp + 3*4]  ; printf("an = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [ecx][][][ret]

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][ecx][][][ret]

         push esp

;        esp -> [addr_a][][][ecx][][][ret]

         call getaddr_a1  ; push on the stack the run-time address of format_a1

format_a1  db "%lf", 0

getaddr_a1:

;        esp -> [format_a1][addr_a][][][ecx][][][ret]

         call [ebp + 4*4]  ; scanf("%f", &a)

;        esp -> [format_a1][addr_a][a][][ecx][][][ret]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [a][][ecx][][][ret]

         fld qword [esp]  ; st = [st0, st1, st2] = [a, x, suma]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [ecx][][][ret]

warunek:

         cmp ebx, 0  ; ebx - 0           ; SF ZF PF CF OF AF affected
         jne petla2  ; jump if not equal ; ZF = 0
         je dalej    ; jump if equal     ; ZF = 1

petla2:

         fmul st1     ; st = = [st0, st1, st2] = [a*x, x, suma]
         sub ebx, 1   ; ebx = ebx - 1
         jmp warunek  ; jump warunek

dalej:

         faddp st2  ; st = [st0, st1] = [x, suma + a*x*x]

;        esp -> [ecx][][][ret]

         pop ecx

         inc ecx  ; ecx = ecx + 1

;        esp -> [][][ret]  ; st = [st0, st1] = [x, suma]

         loop petla

         sub esp, 2*4  ; esp = esp - 8
         
;        esp -> [][][][][ret]

         fstp qword [esp]  ; st = [st0] = [suma]

;        esp -> [x][][][][ret]

         fstp qword [esp + 2*4]  ; st = [] = []
         
;        esp -> [x][][suma][][ret]

         call print  ; push on the stack the run-time address of formatp

formatp  db "w(%f) = %f", 0

print:

;        esp -> [formatp][x][][suma][][ret]

         call [ebp + 3*4]  ; printf (w(x) = suma)

         add esp, 5*4      ; esp = esp + 20

         push 0            ; esp -> [0][ret]
         call [ebp + 0*4]  ; exit(0);
         
zero     call getaddrzero  ; push on the stack the run-time address of format_a1

format_zero  db "Nie mozna dzielic przez zero", 0
getaddrzero:

;        esp -> [format_zero][x][][][][ret]

         call [ebp + 3*4]  ; printf (format_zero)

         add esp, 5*4  ; esp = esp + 20

         push 0            ; esp -> [0][ret]
         call [ebp + 0*4]  ; exit(0);



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
