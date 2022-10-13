        [bits 32]

extern   _scanf
extern   _printf
extern   _exit

section  .data

a             equ __?float32?__(0.000000)
b             equ __?float32?__(0.000000)
c             equ 0

grades_addr   dd 5.000000, 4.500000, 4.000000, 3.500000, 3.000000  ;  all possible grades
formatError   db "Niepoprawna ocena, wpisz liczbe z listy [3.0, 3.5, 4.0, 4.5, 5.0]", 0xA, 0

format2       db "Podaj twoje oceny w formacie [4.5] aby policzyc srednia, aby przerwac wpisywanie ocen wpisz 0:", 0xA, 0
format3       db  "%f",0
format4       db  "Dodaje ocene:%f", 0xA, 0
format5       db  "Srednia:%f", 0xA, 0

section  .text

global   _main

_main:

         finit

a        equ __?float32?__(0.000000)
b        equ __?float32?__(0.000000)
c        equ 0

;        esp ->[ret]  ;

         call getaddr0
grades_addr:
         dd 5.000000, 4.500000, 4.000000, 3.500000, 3.000000  ;  all possible grades
getaddr0:

;        esp ->[grades_addr][ret]  ;

         call getaddr1
addr_a      dd a
addr_sum    dd b
addr_count  dd c

getaddr1:

;        esp ->[addr_a][grades_addr][ret]  ;

         jmp prompt

validation_error:

         call getaddrError
formatError:
         db "Niepoprawna ocena, wpisz liczbe z listy [3.0, 3.5, 4.0, 4.5, 5.0]", 0xA, 0

getaddrError:
         call [ebx + 3*4]
         add esp, 4

prompt:
         call getaddr2
format2:
         db "Podaj twoje oceny w formacie [4.5] aby policzyc srednia, aby przerwac wpisywanie ocen wpisz 0:", 0xA, 0
getaddr2:
         call [ebx + 3*4]
         add esp, 4

;        esp -> [addr_a][grades_addr][ret]  ;

         call getaddr3
format3:
        db  "%f",0
getaddr3:
         call [ebx + 4*4]
         add esp, 4

;        esp -> [addr_a][grades_addr][ret]  ;

         mov eax,[esp]

         fld dword [eax]

;        st -> [st0, grade]

;check if input is zero then calculate avg
         clc
         ftst               ;test ST(0) by comparing it to +0.0
         fstsw ax           ;copy the StatusWord containing the result to AX
         fwait              ;wait for fpu to insure that previous instruction is completed
         sahf               ;transfer the condition codes to cpu flag register

         jz exit

;check if input is correct
          mov ecx, 5

validation_loop:
          mov esi,ecx

;         esp -> [addr_a][grades_addr][ret]  ;

          mov eax,[esp + 4]    ;  get [grades_addr]
          fld dword [eax+4*(ecx-1)]

;         st -> [st0][st1]

          clc
          fcomp              ;  cmp ST(0), ST(1)
          fstsw ax           ;  copy the StatusWord containing the result to AX
          fwait              ;  wait for fpu to insure that previous instruction is completed
          sahf               ;  transfer the condition codes to cpu flag register

;         st -> [st0]

          jz validation_success            ;  jump if prompt matches allowed grade

          mov ecx, esi

          loop validation_loop

          jmp validation_error

;         esp -> [h_a][l_a][addr_a][grades_addr][ret]  ;

validation_success:
         sub esp, 4*2
         fst qword [esp]

;         st -> [st0]

         call getaddr4
format4:
        db  "Dodaje ocene:%f", 0xA, 0
getaddr4:

;        esp -> [format4][h_a][l_a][addr_a][grades_addr][ret]  ;

         call [ebx + 4*3]
         add esp, 4*3

;        esp -> [addr_a][grades_addr][ret]  ;

         mov eax,[esp]

;        st -> [st0]

         fld dword [eax+4]

;        st -> [st0][st1]

         faddp           ;  [st0]+[st1]

         mov eax,[esp]
         fstp dword [eax+4]

;        esp -> [addr_a][grades_addr][ret]  ;

         mov eax,[esp]
         mov ecx, [eax + 8]

         inc ecx
         mov [eax + 8],ecx

;        esp -> [addr_a][grades_addr][ret]  ;

         jmp prompt
exit:

         mov eax,[esp]

         fld dword [eax+4]
         fild dword [eax+8]

;        st -> [st0(addr_sum), st1(addr_count)]

         clc

         ftst               ;  test ST(0) by comparing it to +0.0
         fstsw ax           ;  copy the StatusWord containing the result to AX
         fwait              ;  wait for fpu to insure that previous instruction is completed
         sahf               ;  transfer the condition codes to cpu flag register
         jz zero

         fdiv       ;  st0 = st0(addr_sum)/ st1(addr_count)

         sub esp, 8

;        esp -> [][][addr_a][grades_addr][ret]  ;

         fstp qword [esp]

;        esp -> [srednia_h][srednia_l][addr_a][grades_addr][ret]  ;

         jmp notzero

zero:
         push 0
         push 0

notzero:

         call getaddr5
format5:
         db  "Srednia:%f", 0xA, 0
getaddr5:
         call [ebx + 4*3]

         add esp, 4*3
         push 0
         call [ebx + 0*4]

;        esp -> [ret]  ;

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