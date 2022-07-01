[bits 32]

extern   _scanf
extern   _printf
extern   _exit

section  .data

format   db "liczby: ", 0
format_x db "%d", 0
format2  db "posortowane: %d %d %d %d %d", 0

section  .text

global   _main

_main:

;        esp -> [ret]

         push format

;        esp -> [format][ret]

         call _printf  ; printf("liczby: ");
         add esp, 4    ; esp = esp + 4

;        esp -> [ret]

         mov ecx, 5  ; ecx = 5

_loop:

         mov esi, ecx  ; esi = ecx ; store ecx

         sub esp, 4    ; esp = esp - 4
         
;        esp -> [][ret]

         push esp  ; esp -> stack

;        esp -> [addr_x][][ret]

         push format_x

;        esp -> [format_x][addr_x][][ret]

         call _scanf   ; scanf("%d", &addr_x)
         add esp, 2*4  ; esp = esp + 8
         
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

         push format2

;        esp -> [format2][x][x][x][x][x][ret]

         call _printf  ; printf("posortowane: %d %d %d %d %d", x, x, x, x, x);
         add esp, 6*4  ; esp = esp + 24

;        esp -> [ret]

         push 0      ; esp -> [0][ret]
         call _exit  ; exit 0;
         
;        nasm bubble_relokowalnie.asm -o bubble_relokowalnie.o -f win32
;        gcc -m32 bubble_relokowalnie.o -o bubble_relokowalnie.exe
;        ./bubble_relokowalnie.exe