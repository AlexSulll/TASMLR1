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
    mov     ah,03Ch
    xor     cx,cx
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
    mov     bp,ax
    sal     bp,2
    sal     ax,1
    add     bp,ax
    mov     al,bl
    cbw
    imul    bp
    or      dx,dx
    jz      positive_6ab
    cmp     dx, 0ffffh
    jz      negative_6ab
    jmp     SHORT Write_A
positive_6ab:
    xchg    si,ax
    mov     al,ch
    cbw
    or      ax,ax
    js      negative_c1
    add     si,ax
    js      Write_A
    jc      Write_A
    jmp     cycle_or_params    
negative_6ab:    
    xchg    si,ax
    mov     al,ch
    cbw
    or      ax,ax
    js      negative_c2
    add     si,ax
    lahf
    test    ah,10000001b
    jz      Write_A
    jmp     cycle_or_params
negative_c1:
    neg     ax
    sub     si,ax
    jc      cycle_or_params
    js      Write_A
    jmp     cycle_or_params
negative_c2:
    neg     ax
    sub     si,ax
    jns     Write_A
    jc      Write_A
cycle_or_params:
    cmp     cl,0
    jnz     jump_to_nextitter
    jmp     jump_to_chislitel
Write_A:
    mov     al,bl
    mov     [zapis + 4],"+"
    or      al,al
    jge     Chislo_A
    neg     al
    mov     [zapis + 4],"-"
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
    mov     [zapis + 14],"+"
    or      al,al
    jge     Chislo_B
    neg     al
    mov     [zapis + 14],"-"
    jmp     Chislo_B
jump_to_nextitter:
   jmp      jump_to_next_itter2
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
    mov     [zapis + 24],"+"
    or      al,al
    jge     Chislo_C
    neg     al
    mov     [zapis + 24],"-"
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
jump_to_next_itter2:
    jmp     next_itter
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
jump_to_chislitel:
    jmp     chislitel
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
chislitel:
    mov     al,ch
    cbw
    mov     bp,ax
    mov     al,bh
    cbw
    mov     di,ax
    mov     dx,ax
    sal     di,5
    sal     dx,2
    sub     di,dx
    imul    ax
    imul    di
    sub     bp,19
    jns     pos_c
    jz      division
neg_c:
    neg     bp
    sub     ax,bp
    sbb     dx,0
    jmp     division
pos_c:
    add     ax,bp
    adc     dx,0
division:
    idiv    si
    mov     [result],ax
Exit:
    mov     ah,04ch
    mov     al,0
    int     21h
    end     Start   
