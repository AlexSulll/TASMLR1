; 28b^3+c-19    <-- тут проблема куб 28*(-128)*^3 = очень много (БУДУТ ПРОБЛЕМЫ С ДЕЛЕНИЕМ (РЕЗ слишком большой для АХ)), ЛЕЙЛА ПИСАЛА ПО ЭТОМУ ПОВОДУ ТАГИРУ
; -------------
; 6ab+c         <-- 6*ab может дать переполнение,  С --- нет.
; макс значение в положительную 32767+128 (тое есть 6ab = 32767+128 + C(=-128) не переполнение, в отрицательную сторону логика та же
; надо делать проверку вначале после a*b, т.е. 6*a*b = 32767+128 => a*b = (32767+128)/6  ...

.model      small
.186
.stack      100h
.data
    fileName    db      'overflow.txt',0
    zapis       db      'A = 0000, B = 0000, C = 0000', 0ah ;29 simvolov
    A           db      ?
    B           db      ?
    C           db      ?
    countA      db      ?
    countB      db      ?
    countC      db      ?
    idfile      dw      ?

.code
Start:
    mov     ax,@data
    mov     ds,ax
    mov     al,[C] ; al = C
    or      al,[A] ; A = C
    jnz     Answer ; if A != 0 and C != 0 goto Answer
    mov     [A],-128
    mov     [countA],255
    
CreateFile:
    mov     ah,3Ch
    mov     cx,00100000b
    mov     dx,offset fileName
    int     21h
    mov     [idfile],ax
    mov     di,[idfile]
   
a_loop:
    mov     [countB],255
    mov     [B],-128
    
b_loop:
    mov     [countC],255
    mov     [C],-128
    
c_loop:
    ;go to answer
    
Answer:
    ;znamenatel
    mov     al,B
    cbw
    mov     bl,A
    xchg    ax,bx   ; ax-A,bx-B
    cbw             ; al to ax
    imul    bx      ; ax=A*B(ax*bx)
    sal     ax,1    ; ax = 2*ax
    mov     cx,ax   ; cx = 2*ax
    sal     ax,1    ; ax = 4*ax
    add     cx,ax   ; cx = cx + ax (6*A*B)
    mov     al,C    ; al = C
    cbw             ; al to cbw ax
    add     cx,ax   ; cx = cx + ax
    jcxz    Write_A
    jo      Write_A ;TODO!!!
    ;chislitel
    mov     ax,bx   ; ax = bx(B)
    imul    bx      ; ax = ax * bx (B^2)  ; всё ок
    imul    bx      ; ax = ax * bx (B^3)  ; всё ок
    mov     bx,ax   ; bx = B^3            ; НЕ ОК (результат может быть в dx:ax!!!, а не только в ax)
    sal     ax,5    ; ax = 32*ax          ; 32 это много, а СДВИГ не двигает в dx:ax!!!, то есть старшие разряды просто исчезают (ну и рез в dx:ax так-то)
    sal     bx,2    ; bx = 4*bx (4*ax)    ; ну дальше понятно, что неправильно считает
    sub     ax,bx   ; ax = 28*B^3
    mov     bl,C
    xchg    ax,bx   ; bx=28*b^3, al = C
    cbw             ; ax
    add     ax,bx
    sub     ax,19
    cwd             ; dx:ax = ax        ; это не нужно, просто убивает dx.
    idiv    cx      ; ax = answer
    ; числитель это двойное слово, поэтому нужно оперировать им(dx:ax)
    or      di,00000h
    jnz     not_exit
    jmp     Exit
    
not_exit:
    jmp next_itter

Write_A:
    mov     [zapis + 4],"+"
    mov     al,A
    test    al,080h
    jns     Chislo_A
    neg     al
    mov     [zapis + 4],"-"
    ;cmp     al,0
    ;jl      otr_A
    
Chislo_A:
    aam
    or      al,30h
    mov     [zapis + 7], al
    mov     al,ah
    aam
    or      al,30h
    mov     [zapis + 6], al
    or      ah,30h
    mov     [zapis + 5], ah
       
Write_B:
    mov     [zapis + 14],"+"
    mov     al,B
    test    al,080h
    jns     Chislo_B
    neg     al
    mov     [zapis + 14],"-"
    ;cmp     al,0
    ;jl      otr_B
    
Chislo_B:
    aam
    or      al,30h
    mov     [zapis + 17], al
    mov     al,ah
    aam
    or      al,30h
    mov     [zapis + 16], al
    or      ah,30h
    mov     [zapis + 15], ah
    
Write_C:
    mov     [zapis + 24],"+"
    mov     al,C
    test    al,080h
    jns     Chislo_C
    neg     al
    mov     [zapis + 24],"-"
    ;cmp     al,0
    ;jl      otr_C

Chislo_C:
    aam
    or      al,30h
    mov     [zapis + 27], al
    mov     al,ah
    aam
    or      al,30h
    mov     [zapis + 26], al
    or      ah,30h
    mov     [zapis + 25], ah
      
Write:
    mov     ah,40h
    mov     bx,idfile
    mov     dx,offset zapis
    mov     cx,29
    int     21h
    jmp     next_itter

;otr_A:
;    mov     [zapis + 4],"-"
;    jmp     Chislo_A
;    
;otr_B:
;    mov     [zapis + 14],"-"
;    jmp     Chislo_B
;    
;otr_C:
;    mov     [zapis + 24],"-"
;    jmp     Chislo_C
    
next_itter:
    inc     [C]
    dec     [countC]
    cmp     [countC],-1
    jz      cCount_0
    jmp     c_loop
        
cCount_0:  
    inc     [B]
    dec     [countB]
    cmp     [countB],-1
    jz      bCount_0
    jmp     b_loop
    
bCount_0:
    inc     [A]
    dec     [countA]
    cmp     [countA],-1
    jz      aCount_0
    jmp     a_loop
    
aCount_0:
    
    
Exit:
    mov     ah,04ch
    mov     al,0
    int     21h
    end     Start
