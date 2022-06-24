%ifdef COMMENT

3.5 * x^2 + 2.0 * x + 1.5
3.5 * (1.5)^2 + 2.0 * 1.5 + 1.5
3.5 * 1.5 * 1.5 + 2.0 * 1.5 + 1.5

%endif

         [bits 32]

;        eap -> [ret] ; ret - adres powrotu do asmloader

         call getaddr

addr_x   dq 1.5  ; x
addr_a0  dq 1.5  ; a0
addr_a1  dq 2.0  ; a1
addr_a2  dq 3.5  ; a2

getaddr:

;        esp -> [addr_x][ret]

         finit  ; fpu init

         mov eax, [esp]  ; eax = *(int*)esp = addr_x

         fld qword [eax]  ; *(double*)addr_x = x

;        st = [st0] = [b]  ; fpu stack

         add eax, 8  ; eax = eax + 8 = addr_x + 8 = addr_a0

         fld qword [eax]  ; *(double*)eax = *(double*)addr_a0 = a0

;        st = [st0, st1] = [a0, x]  ; fpu stack

         add eax, 8  ; eax = eax + 8 = addr_a0 + 8 = addr_a1

         fld qword [eax]  ; *(double*)eax = *(double*)addr_a1 = a1
         
;        st = [st0, st1, st2] = [a1, a0, x]  ; fpu stack

         add eax, 8  ; eax = eax + 8 = addr_a1 + 8 = addr_a2

         fld qword [eax]  ; *(double*)eax = *(double*)addr_a2 = a2
         
;        st = [st0, st1, st2, st3] = [a2, a1, a0, x]  ; fpu stack

         sub esp, 2*4  ; esp = esp - 8

;        esp -> [ ][ ][ ][ ][ret]

         call getaddr2

wynik1:
         db "w(%f) = %f", 0xA, 0

getaddr2:
;                        +4   +12
;        esp -> [wynik1][ ][ ][ ][ ][ret]

;        st = [st0, st1, st2, st3] = [a2, a1, a0, x]  ; fpu stack

         fmul st3  ; st = [st0*st3, st1, st2, st3] = [a2*x, a1, a0, x]  ; fpu stack

         fmul st3  ; st = [st0*st3*st3, st1, st2, st3] = [a2*x*x, a1, a0, x]  ; fpu stack

         faddp st2  ; st = [st0, st1, st2] = [a1, a0 + a2*x*x, x]  ; fpu stack

         fmul st2  ; st = [st0*st2, st1, st2] = [a1*x, a0 + a2*x*x, x]  ; fpu stack

         faddp st1  ; st = [st0, st1] = [a2*x*x + s1*x, x]  ; fpu stack

         fstp qword [esp+12]
         fstp qword [esp+4]

         jmp print

print:
         call[ebx+3*4]
         
         push 0
         call [ebx+0*4]