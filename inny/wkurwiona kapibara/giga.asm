 [bits 32]
         finit
a        equ __?float32?__(3.141592)

;        esp -> [ret]  ;

        call getaddr
format:
       db "Podaj twoje oceny w formacie [4.5] aby policzyc srednia,aby przerwac wpisywanie ocen wpisz 0:", 0xA, 0
getaddr:
         call [ebx + 3*4]
;        esp -> [format][ret]  ;

         call getaddr0
addr_a   dd a  ;
getaddr0:

;        esp -> [addr_a][format][ret]  ;

        call getaddr2
format1:
        db  "%f",0
getaddr2:
         call [ebx + 4*4]
         add esp, 4
        mov eax,[esp]
        sub esp, 4*2
;        esp -> [][][addr_a][format][ret]  ;
        fld dword [eax]
        fstp qword [esp]
;        esp -> [h_a][l_a][addr_a][format][ret]  ;
        
;        esp -> [x][format][ret]  ;

        call getaddr3
format2:
        db  "giga:%.15f", 0xA, 0
getaddr3:
        call [ebx + 4*3]

;        esp -> [format2][x][format][ret]  ;


        add esp, 4*3
        push 0
        call [ebx + 0*4]

;        esp -> [ret]  ;

;        jnz calculate




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