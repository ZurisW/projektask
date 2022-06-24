         [bits 32] ;rodzaj kompilacji 32 bitowy

;        esp -> [ret]


         call getaddr
format:
         db "Podaj liczbe elementow w tablicy.", 0xA, "n = ", 0
getaddr:

;        esp -> [format][ret]

         call [ebx + 3*4]  ; printf(format)

         push esp

;        esp -> [addr_n][n][ret]

         call getaddr2
format2:
         db "%d",0
getaddr2:

;        esp -> [format2][addr_n][n][ret]

         call [ebx+4*4]  ; scanf("%d", &n);
         add esp, 2*4    ; esp = esp + 8;

;        esp -> [n][ret]



;        zrobic negacje jesli <0
         mov ecx, dword [esp]  ; ecx = *(int*)esp = n
         mov ebp, ecx          ; ebp = ecx = n



;        scanf
petla:

         call getaddr3  ; push on the stack the run-time address of format_a
format3:
         db "Podaj wartosc: ", 0
getaddr3:

;        esp -> [format3][n][ret]

         mov esi, ecx  ; esi = ecx ; store ecx

         call [ebx + 3*4]  ; printf("Podaj wartosc: ")

         push esp

;        esp -> [addr_x][x][n][ret]

         call getaddr_x  ; push on the stack the run-time address of format_a1
format_x:
          db "%d", 0
getaddr_x:

;        esp -> [format_x][addr_x][x][n][ret]

         call [ebx + 4*4]  ; scanf("%d", &x)

         add esp, 2*4  ; esp = esp + 8

;        esp -> [x]...[x][n][ret]

         mov ecx, esi  ;ecx = esi  ; restore ecx

         loop petla


;        prinf






         mov ecx, ebp  ; ecx = ebp = n

petla2:

         call getaddr4  ; push on the stack the run-time address of format_a
format4:
         db "%d "
         db 0
getaddr4:

;        esp -> [format4][x]...[x][n][ret]

         mov esi, ecx  ; esi = ecx ; store ecx

         mov eax, [esp + 1*4]

         push eax
         call [ebx + 3*4]  ; printf("%d ") 

         mov ecx, esi  ;ecx = esi  ; restore ecx

         loop petla2





;        esp -> [ret]

         push 0  ; esp -> [0][ret]
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
