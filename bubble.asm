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

         mov ecx, 0

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

         call [ebx+2*4] ; eax = getchar();

         push eax       ; eax -> stack

;        esp -> [eax][x][ret]

         add esp, 4

;        esp -> [x][ret]

         mov ecx, esi  ; ecx = esi  ; restore ecx

         inc ecx  ; ecx++

         cmp eax, 0ah  ; eax - 0a ; enter pressed
         je _enter

         jne _loop  ; jump if not equal ; ZF affected
         
_enter:
         
         mov ebp, ecx  ; ebp = ecx

;        esp -> [x][...][ret]

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
         cmp ecx, ebp    ; ecx - n
         jne _loopinner  ; jump if not equal ; ZF affected

         mov ecx, esi    ; ecx = esi ; restore ecx

         inc ecx         ; ecx++
         cmp ecx, ebp    ; ecx - n
         jne _loopouter  ; jump if not equal ; ZF affected

         call getaddr2
format2:
         db "posortowane: ", 0
getaddr2:

;        esp -> [format2][x][...][ret]

         call [ebx + 3*4]  ; printf("posortowane: ");
         add esp, 4      ; esp = esp + 4
         
;        esp -> [format2][x][...][ret]
         
         mov ecx, ebp  ; ecx = ebp
         
_loop2:

         mov esi, ecx  ; esi = ecx ; store ecx

         call getaddr3
format3:
         db "%d ", 0
getaddr3:

;        esp -> [format2][x][...][ret]

         call [ebx + 3*4]  ; printf("%d ");
         add esp, 2*4      ; esp = esp - 8
         
         mov ecx, esi  ; ecx = esi ; restore ecx

         loop _loop2

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
; To co funkcja zwr�ci jest w EAX.
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
