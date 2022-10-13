         [bits 32] ; rodzaj kompilacji 32 bitowy

;        esp -> [ret]

         call getaddr  ; push on the stack the run-time address of format
format:
         db "liczby: ", 0
getaddr:

;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf("liczby: ");
         add esp, 4        ; esp = esp + 4

;        esp -> [ret]

         mov ecx, 5  ; ecx = 5

_loop:

         mov esi, ecx  ; esi = ecx ; store ecx

         sub esp, 4    ; esp = esp - 4

;        esp -> [][ret]

         push esp  ; esp -> stack

;        esp -> [addr_x][][ret]


         call getaddr_x  ; push on the stack the run-time address of format_x
format_x:
         db "%d", 0
getaddr_x:

;        esp -> [format_x][addr_x][][ret]

         call [ebx + 4*4]  ; scanf("%d", &addr_x)
         add esp, 2*4      ; esp = esp + 8
         
;        esp -> [x][ret]

         mov ecx, esi  ; ecx = esi  ; restore ecx

         loop _loop

;        esp -> [x][x][x][x][x][ret]

         mov ecx, 0  ; ecx = 0

_loopouter:
         
         mov esi, ecx  ; esi = ecx ; store ecx

         mov ecx, 0  ; ecx = 0

_loopinner:

         mov edi, ecx  ; edi = ecx ; store ecx

         mov eax, [esp + 4*ecx]      ; eax = *(int*)(esp + 4*ecx)
         mov edx, [esp + 4*ecx + 4]  ; edx = *(int*)(esp + 4*ecx + 4)

         cmp eax, edx  ; eax - edx
         jng mniejsza  ; jump if not greater ; SF affected

         mov dword [esp+4*ecx], edx    ; *(int*)(esp + 4*ecx) = edx = *(int*)(esp + 4*ecx + 4)
         mov dword [esp+4*ecx+4], eax  ; *(int*)(esp + 4*ecx + 4) = eax = *(int*)(esp + 4*ecx)

mniejsza:

         mov ecx, edi    ; ecx = edi ; restore ecx

         inc ecx         ; ecx++
         cmp ecx, 5      ; ecx - 5
         jne _loopinner  ; jump if not equal ; ZF affected

         mov ecx, esi    ; ecx = esi ; restore ecx

         inc ecx         ; ecx++
         cmp ecx, 5      ; ecx - 5
         jne _loopouter  ; jump if not equal ; ZF affected

         call getaddr2
format2:
         db "posortowane: %d %d %d %d %d", 0
getaddr2:

;        esp -> [format2][x][x][x][x][x][ret]

         call [ebx + 3*4]  ; printf("posortowane: %d %d %d %d %d", x, x, x, x, x);
         add esp, 6*4      ; esp = esp + 24

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call [ebx+0*4]  ; exit 0;

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
;
; https://gynvael.coldwind.pl/?id=387

%ifdef COMMENT

ebx    -> [ ][ ][ ][ ] -> exit
ebx+4  -> [ ][ ][ ][ ] -> putchar
ebx+8  -> [ ][ ][ ][ ] -> getchar
ebx+12 -> [ ][ ][ ][ ] -> printf
ebx+16 -> [ ][ ][ ][ ] -> scanf

%endif
