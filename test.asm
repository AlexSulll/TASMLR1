.model      small
.186
.stack      100h
MIN     =   -128d
MAX     =   127d
.data
    fileName    db      'overflow.txt',0
    zapis       db      'A = 0000, B = 0000, C = 0000', 0Dh, 0ah ;30 simvolov
    A           db      ?
    B           db      ?
    C           db      ?
    result      dw      ?
.code
Start:
    mov     ax,@data
    mov     ds,ax
    mov     bx,word ptr [A]
    mov     ch,[C]
    mov     al,ch
    or      al,bh
    or      al,bl
    jnz     Answer   
CreateFile:
    mov     ah,3Ch
    mov     cx,00100000b
    mov     dx,offset fileName
    int     21h
    mov     cl,al  
setvalue:
    mov     bx,MIN
    mov     bh,bl
    mov     ch,bl  
Answer:
    mov     al,bh
    cbw
    mov     dl,bl
    xchg    ax,dx
    cbw
    mov     bp,ax
    sal     bp,1
    sal     ax,2
    add     ax,bp ;ax = 6ab
    
    
    
    ;mov     al,B
    ;cbw
    ;mov     bl,A
    ;xchg    ax,bx   ; ax-A,bx-B
    ;cbw             ; al to ax
    ;imul    bx      ; ax=A*B(ax*bx)
    ;sal     ax,1    ; ax = 2*ax
    ;mov     cx,ax   ; cx = 2*ax
    ;sal     ax,1    ; ax = 4*ax
    ;add     cx,ax   ; cx = cx + ax (6*A*B)
    ;mov     al,C    ; al = C
    ;cbw             ; al to cbw ax
    ;add     cx,ax   ; cx = cx + ax
    ;jcxz    Write_A
    ;jo      Write_A ;TODO!!!
    ;chislitel
    ;mov     ax,bx   ; ax = bx(B)
    ;imul    bx      ; ax = ax * bx (B^2)
    ;imul    bx      ; ax = ax * bx (B^3)
    ;mov     bx,ax   ; bx = B^3
    ;sal     ax,5    ; ax = 32*ax
    ;sal     bx,2    ; bx = 4*bx (4*ax)
    ;sub     ax,bx   ; ax = 28*B^3
    ;mov     bl,C
    ;xchg    ax,bx   ; bx=28*b^3, al = C
    ;cbw             ; ax
    ;add     ax,bx
    ;sub     ax,19
    ;cwd             ; dx:ax = ax
    ;idiv    cx      ; ax = answer
    ;or      di,00000h
    ;jnz     not_exit
    ;jmp     Exit  
   jmp Write_A 
not_exit:
    jmp next_itter
Write_A:
    mov     al,bl
    cmp     al,0
    jl      otr_A
    mov     [zapis + 4],"+"
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
    mov     al,bh
    cmp     al,0
    jl      otr_B
    mov     [zapis + 14],"+" 
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
    mov     al,ch
    cmp     al,0
    jl      otr_C
    mov     [zapis + 24],"+"
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
    mov     bp,cx
    mov     di,bx
    mov     ah,40h
    mov     bl,cl
    xor     bh,bh
    mov     dx,offset zapis
    mov     cx,30
    int     21h
    mov     cx,bp
    mov     bx,di
    jmp     next_itter
otr_A:
    neg     al
    mov     [zapis + 4],"-"
    jmp     Chislo_A
otr_B:
    neg     al
    mov     [zapis + 14],"-"
    jmp     Chislo_B
otr_C:
    neg     al
    mov     [zapis + 24],"-"
    jmp     Chislo_C
next_itter:
    cmp     ch,MAX
    jl      c_iter
    cmp     bh,MAX
    jl      b_iter
    cmp     bl,MAX
    jnl     Exit
a_iter:
    inc     bl
    mov     bh,MIN-1
b_iter:
    inc     bh
    mov     ch,MIN-1
c_iter:
    inc     ch
not_max:
    jmp     Answer
Exit:
    mov     ah,04ch
    mov     al,0
    int     21h
    end     Start   