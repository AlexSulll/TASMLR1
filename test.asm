.model      small
.186
.stack      100h
.data
    A           db      73
    B           db      73
    C           db      10
    countA      db      -128d
    countB      db      -128d
    countC      db      -128d
    idfile      dw      ?
    fileName    db      'overflow.txt',0
    zapis       db      'A = +000, B = +000, C = +000' ;28 simvolov

.code
Start:
    mov     ax,@data
    mov     ds,ax
    mov     al,[C] ; al = C
    or      al,[A] ; A = C
    jnz     Answer ; if A != 0 and C != 0 goto Answer
    mov     [a],-128
    
    
CreateFile:
    mov     ah,3Ch
    mov     cx,00100000b
    mov     dx,offset fileName
    int     21h
    mov     idfile,ax
   

a_loop:
    
b_loop:
    
c_loop:
    
Answer:
    ;znamenatel
    mov     al,B
    cbw
    mov     bl,A
    xchg    ax,bx   ; ax-A,bx-B
    cbw             ; al to ax
    imul    bx      ; ax=A*B(ax*bx)
    imul    ax,6    ; ax = 6*ax (6*A*B)
    mov     cl,C    ; cl = C
    xchg    ax,cx   ; ax(al) - C,cx - 6*A*B
    cbw             ; al to cbw ax
    add     cx,ax   ;cx = cx + ax
    jo  Write_A     ;TODO!!!
    ;chislitel
    mov     ax,28   ; ax = 28
    imul    bx      ; ax = ax * bx
    imul    bx
    imul    bx      ; ax = 28*b^3
    mov     bl,C
    xchg    ax,bx   ; bx=28*b^3, al = C
    cbw             ; ax
    add     ax,bx
    sub     ax,19
    cwd             ; dx:ax = ax
    idiv    cx
    
Write_A:
    mov     al,A
    cmp     al,0
    jl      otr_A
    jmp     Chislo_A

Write_B:
    mov     al,B
    cmp     al,0
    jl      otr_B
    jmp     Chislo_B
    
Write_C:
    mov     al,C
    cmp     al,0
    jl      otr_C
    jmp     Chislo_C
    
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
    
    jmp     Write_B

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
    
    jmp     Write_C

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
    
    jmp     Write
    
Write:
    mov     ah,40h
    mov     bx,idfile
    mov     dx,offset zapis
    mov     cx,28
    int     21h
    jmp     Exit

otr_A:
    mov     [zapis + 4],"-"
    jmp     Chislo_A
    
otr_B:
    mov     [zapis + 14],"-"
    jmp     Chislo_B
    
otr_C:
    mov     [zapis + 24],"-"
    jmp     Chislo_C
    
Exit:
    mov     ah,04ch
    mov     al,0
    int     21h
    end     Start