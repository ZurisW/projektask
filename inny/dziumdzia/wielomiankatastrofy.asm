[bits 32]

extern   _scanf
extern   _printf
extern   _exit

section  .data
format  db "x = ", 0
formatx  db "%lf", 0
format2  db "n = ", 0
formatn  db "%d", 0
format3 db "a%d = ", 0
formata  db "%lf", 0
formatxx  db "W(%lf) = %lf", 0

section  .text

global   _main

_main:

;        esp -> [ret] ; ret - adres powrotu do asmloader

         push format

;        esp -> [format][ret]

         call _printf  ; printf("x = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [ret]

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][ret]

         push esp  ; esp -> stack

;        esp -> [addr_x][][][ret]

         push formatx

;        esp -> [formatx][addr_x][][][ret]

         call _scanf  ; scanf("%lf", &x)

;        esp -> [formatx][addr_x][x][][ret]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][ret]

         push format2

;        esp -> [format2][x][][ret]

         call _printf  ; printf("n = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][ret]

         sub esp, 4  ; esp = esp - 4

;        esp -> [][x][][ret]

         push esp  ; esp -> stack

;        esp -> [addr_n][][x][][ret]

         push formatn

;        esp -> [formatn][addr_n][][x][][ret]

         call _scanf  ; scanf("%d", &n)

         add esp, 2*4  ; esp = esp + 8
         
;        esp -> [n][x][][ret]

         cmp dword [esp], 0  ; *(int*)esp - 0 = n - 0
         jns dalej           ; jump if not signed set     ; SF = 0

         neg dword [esp]     ; *(int*)esp = - (*(*int*)esp)

dalej:

         mov ecx, dword [esp]  ; ecx = *(int*)esp = n

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][ret]

         finit  ; fpu init

         fldz  ; st = [st0] = [0]

;        st = [st0]

         fld qword [esp]  ; st = [st0, st1] = [x, suma]

;        st = [st0, st1]

         mov eax, [esp]  ; eax = *(int*)esp = x

_loop:

         mov esi, ecx  ; store ecx
               
         push ecx  ; ecx -> stack

;        esp -> [ecx][x][][ret]

         push format3

;        esp -> [format3][ecx][x][][ret]
         
         call _printf  ; printf("a%d = ");

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][ret]

         mov ecx, esi  ; ecx = esi

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][x][][ret]

         push esp  ; esp -> stack

;        esp -> [addr_a][][][x][][ret]

         push formata

;        esp -> [formata][addr_a][][][x][][ret]

         call _scanf  ; scanf("%lf", &a);

         add esp, 2*4  ; esp = esp + 8

;        esp -> [a][][x][][ret]

         fld qword [esp]  ; st = [st0, st1, st2] = [a, x, suma]

;        st = [st0, st1, st2]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][ret]

         mov ecx, esi  ; ecx = esi

_loop2:

         mov edi, ecx   ; edi = ecx

         test ecx, ecx  ; ecx^ecx
         je dalej2      ; jump if equal  ; ZF = 1

         fmul st1       ; st = [st0, st1, st2] = [a*x, x, suma]
         
;        st = [st0, st1, st2]

dalej2:

         mov ecx, edi  ; ecx = edi  ; store ecx

         dec ecx       ; ecx--
         jnle _loop2   ; jump if not less or equal  ; ZF and SF affected

         faddp st2     ; st = [st0, st1] = [x, suma + a*x]
         
;        st = [st0, st1]

         mov ecx, esi  ; ecx = esi
         dec ecx       ; ecx--
         jns _loop     ; jump if not signed  ; SF affected

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][x][][ret]

         fstp qword [esp]    ; *(int*)esp = x
         
;        st = [st0] = [suma + a*x]

         fstp qword [esp+8]  ; *(int*)(esp+8) = suma

;        st = []

;        esp -> [x][][suma][][ret]

         push formatxx

;        esp -> [formatxx][x][][suma][][ret]

         call _printf  ; printf("W(%lf) = %lf", x, suma);

         add esp, 5*4  ; esp = esp - 20

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call _exit  ; exit 0;

;        nasm wielomian.asm -o wielomian.o -f win32
;        gcc wielomian.o -o wielomian.exe -m32
;        .\wielomian.exe