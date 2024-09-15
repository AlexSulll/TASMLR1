.model small
.186
.stack 100h
.data
    A   db  ?
    B   db  ?
    C   db  ?
    countA  db  -128d
    countB  db  -128d
    countC  db  -128d
    idfile  dw   ?
    stroka  db  'ttt.txt',0
    zapis   db    'IGORIGOR'

.code
Start:
    mov ax,@data
    mov ds,ax

CreateFile:
    mov ah, 3Ch
    mov cx, 00100000b
    mov dx, offset stroka
    int 21h
    mov idfile, ax
   

A_LOOP:
    
    ;mov ax, 000fh
    ;aam
    ;or ax, 3030h
    ;mov [zapis], ah
    ;mov [zapis+1], al
    ;mov [zapis+2], '$'
    ;mov dx, offset zapis

Answer:
    ;znamenatel
    mov al, B
    cbw
    mov bl, A
    xchg ax,bx;ax-A,bx-B
    cbw;al to ax
    imul bx; ax=A*B(ax*bx)
    imul ax,6; ax = 6*ax (6*A*B)
    mov cl, C; cl = C
    xchg ax,cx; ax(al) - C,cx - 6*A*B
    cbw; al to cbw ax
    add cx,ax;cx = cx + ax
    ;chislitel
    mov ax,28; ax = 28
    imul bx; ax = ax * bx
    imul bx
    imul bx; ax = 28*b^3
    mov bl,C
    xchg ax,bx; bx=28*b^3, al = C
    cbw; ax
    add ax,bx
    sub ax,19
    cwd; dx:ax = ax
    idiv cx

WriteFile:
    mov ah, 40h
    mov bx, idfile
    mov dx, offset zapis
    mov cx, 3
    int 21h

    mov ah,04ch
    int 21h
    
end Start