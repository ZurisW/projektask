[bits 32]

extern   _scanf
extern   _printf
extern   _exit

section  .data

formatError   db "Niepoprawna ocena, wpisz liczbe z listy [3.0, 3.5, 4.0, 4.5, 5.0]", 0xA, 0

format2       db "Podaj twoje oceny w formacie [4.5] aby policzyc srednia, aby przerwac wpisywanie ocen wpisz 0:", 0xA, 0
format3       db  "%f",0
format4       db  "Dodaje ocene:%f", 0xA, 0
format5       db  "Srednia:%f", 0xA, 0

section  .text

global   _main

_main:

         finit
         
a             equ __?float32?__(0.000000)
b             equ __?float32?__(0.000000)
c             equ 0

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
         mov eax,[esp]

         fld dword [eax]

         sub esp, 8

         fstp qword [esp]
         
         push format2

         call _printf

         add esp, 4*4
         push 0
         call _exit

;        esp -> [ret]  ;
