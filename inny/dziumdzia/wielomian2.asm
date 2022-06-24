         [bits 32]

;        eap -> [ret] ; ret - adres powrotu do asmloader

         call getaddr

format  db "x = ", 0

getaddr:


;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("x = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [ret]

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][ret]

         push esp

;        esp -> [addr_x][][][ret]

         call getx  ; push on the stack the run-time address of format2

formatx  db "%lf", 0

getx:

;        esp -> [formatx][addr_x][][][ret]

         call [ebx + 4*4]  ; scanf("%f", &x)

;        esp -> [formatx][addr_x][x][][ret]

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x][][ret]

         call getaddr2

format2  db "n = ", 0

getaddr2:


;        esp -> [format2][x][][ret]

         call [ebx + 3*4]  ; printf("x = ")

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][ret]

         sub esp, 4  ; esp = esp - 8

;        esp -> [][x][][ret]

         push esp

;        esp -> [addr_n][][x][][ret]

         call getn  ; push on the stack the run-time address of format2

formatn  db "%d", 0

getn:

;        esp -> [formatn][addr_n][][x][][ret]

         call [ebx + 4*4]  ; scanf("%f", &x)

         add esp, 2*4  ; esp = esp + 8
         
;        esp -> [n][x][][ret]

         cmp dword [esp], 0  ; n - 0
         jns dalej         ; jump if not signed set     ; SF = 0

         neg dword [esp]

dalej:

         mov ecx, dword [esp]  ; ecx = *(int*)esp = n

         add esp, 4  ; esp = esp + 4

;        esp -> [x][][ret]

         finit  ; fpu init

         fldz  ; st = [st0] = [0]

;        st = [st0]

         fld qword [esp]  ; st = [st0, st1] = [x, suma]

;        st = [st0, st1]

         mov eax, [esp]  ; eax = *(int*)esp = addr_x

_loop:

         mov esi, ecx  ; store ecx

         push ecx
         
;        esp -> [ecx][x][][ret]

         call getaddr3  ; push on the stack the run-time address of format_a

format3 db "a%d = ", 0

getaddr3:

;        esp -> [format3][ecx][x][][ret]
         
         call [ebx + 3*4]  ; printf("an = ")
         
         add esp, 2*4  ; esp = esp + 4

;        esp -> [x][][ret]

         mov ecx, esi



         sub esp, 2*4  ; esp = esp - 8

;        esp -> [][][x][][ret]

         push esp

;        esp -> [addr_a][][][x][][ret]

         call geta  ; push on the stack the run-time address of format2

formata  db "%lf", 0

geta:

;        esp -> [formata][addr_a][][][x][][ret]

         call [ebx + 4*4]  ; scanf("%f", &x)

         add esp, 2*4  ; esp = esp + 8

;        esp -> [a][][x][][ret]

         call getXC  ; push on the stack the run-time address of format2

formatXC  db "WYNIK: %lf KURWA X %lf", 0xA, 0

getXC:
          
         call [ebx + 3*4]

         add esp, 3*4

         dec ecx

         test ecx, ecx

         jns _loop



         sub esp, 2*4

;        esp -> [][][x][][ret]

         fstp
         fstp qword [esp]

;        st = []

;        esp -> [suma][][x][][ret]



         call getxx  ; push on the stack the run-time address of format2

formatxx  db "W(%lf) = %lf", 0

getxx:

         call [ebx + 3*4]


         push 0
         call [ebx+0*4]