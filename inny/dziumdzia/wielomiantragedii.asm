[bits 32]

;        esp -> [ret] ; ret - adres powrotu do asmloader

         call getaddr

format  db "x = ", 0

getaddr:


;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("x = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [ret]

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][ret]

         push esp  ; esp -> stack

;        esp -> [addr_x][][][ret]

         call getx  ; push on the stack the run-time address of formatx

formatx  db "%lf", 0

getx:

;        esp -> [formatx][addr_x][][][ret]

         call [ebx + 4*4]  ; scanf("%lf", &x)

;        esp -> [formatx][addr_x][x][][ret]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][ret]

         call getaddr2

format2  db "n = ", 0

getaddr2:


;        esp -> [format2][x][][ret]

         call [ebx + 3*4]  ; printf("n = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][ret]

         sub esp, 4  ; esp = esp - 4

;        esp -> [][x][][ret]

         push esp  ; esp -> stack

;        esp -> [addr_n][][x][][ret]

         call getn

formatn  db "%d", 0

getn:

;        esp -> [formatn][addr_n][][x][][ret]

         call [ebx + 4*4]  ; scanf("%d", &n)

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

         call getaddr3

format3 db "a%d = ", 0

getaddr3:

;        esp -> [format3][ecx][x][][ret]
         
         call [ebx + 3*4]  ; printf("a%d = ");

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][ret]

         mov ecx, esi  ; ecx = esi

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][x][][ret]

         push esp  ; esp -> stack

;        esp -> [addr_a][][][x][][ret]

         call geta

formata  db "%lf", 0

geta:

;        esp -> [formata][addr_a][][][x][][ret]

         call [ebx + 4*4]  ; scanf("%lf", &a);

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



         call getxx  ; push on the stack the run-time address of format2

formatxx  db "W(%lf) = %lf", 0

getxx:

;        esp -> [formatxx][x][][suma][][ret]

         call [ebx + 3*4]  ; printf("W(%lf) = %lf", x, suma);

         add esp, 5*4  ; esp = esp - 20

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call [ebx+0*4]  ; exit 0;