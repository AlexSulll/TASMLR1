%TITLE    "Lab1"
    ;--------------------------------------------------------------|
    ; d = (a + 12*b*c+6) / (65*c+7*a^2)   |       12 688 332       |
    ;--------------------------------------------------------------|
    ; overflow is when the resulting value is bigger than 16bits(S)|
    ;--------------------------------------------------------------|
.186
.model    small
.stack    100h

.data
    path       db    'OUTPUT.TXT', 0
    buffer     db    "A = 0000, B = 0000, C = 0000", 0ah ; 29 chars
    count_a    db    ?
    count_b    db    ?
    count_c    db    ?
    a          db    ?
    b          db    ?
    c          db    ?
    handle     dw    ?
    
.code 
Start:
    mov    ax,    @data 
    mov    ds,    ax
    mov    al,    [a]           ; mov al <- a
    or     al,    [c]           ; is a = c 
    jnz    calc                 ; if a != 0 and c != 0
    mov    [a],    -128         ; a <- -128
    mov    [count_a], 255       ; count_a <- 255
    
mkFile:
    mov    dx,    offset path
    mov    ah,    03Ch
    xor    cx,    cx
    int    21h
    mov    [handle],    ax      ; ax <- handle (0005h)
    mov    di,    [handle]      ; di <- ax

loop_a: 
    mov    [count_b],    255    ; count_b <- 255
    mov    [b],     -128        ; b <- -128
loop_b:
    mov    [count_c],    255    ; count_c <- 255
    mov    [c],    -128         ; c <- -128
loop_c:    
    ; d = (a + 12*b*c+6) / (65*c+7*a^2)
calc:
    mov    al,    [a]           ; al <- a
    cbw                         ; ax <- a
    mov    bx,    ax            ; bx <- a
    sal    ax,    3             ; ax <- 8*a
    sub    ax,    bx            ; ax <- 7*a
    imul   bx                   ; ax:dx <- 7*a^2, dx is undefined
    jo     wrBuffer
    mov    cx,    ax            ; cx <- 7*a^2  
    mov    al,    [c]           ; al <- c 
    cbw                         ; ax <- c 
    mov    dx,    ax            ; dx <- c 
    sal    dx,    6             ; dx <- 64*c 
    add    dx,    ax            ; dx <- 65*c 
    add    cx,    dx            ; cx <- cx + ax
    jnz    continue             ; if denominator is zero
    jmp    loop_iter            ;    skip loop
continue:
    jo     wrBuffer             ; if overflow
    sal    ax,    2             ; ax <- 4*c
    mov    dx,    ax            ; dx <- 4*c
    sal    ax,    1             ; ax <- 8*c    
    add    dx,    ax            ; dx <- 12*c <=> (4*c + 8*c)
    mov    al,    [b]           ; al <- b
    cbw                         ; ax <- b
    imul   dx                   ; ax(:dx) <- 12*b*c, dx is undefined 
    jo     wrBuffer
    add    ax,    6             ; ax <- 12*b*c+6
    jo     wrBuffer
    add    ax,    bx            ; ax <- a+12*b*c+6
    cwd                         ; ax:dx <- a+12*b*c+6
    idiv   cx                   ; ax:dx/cx
    or     di,    00000h        ; is di = 0000h
    jnz    not_exit             ;    if no then continue
    jmp    Exit                 ;    else Exit 
not_exit:
    jmp    loop_iter 
    
wrBuffer:
        ;----------|
        ; write a  |
        ;----------|
    mov    al,    [a]
    test   al,    080h          ; is a negative?
    jns    posA
    neg    al                   ; get absolute value of a
    mov    [buffer+4],    2dh   ; A = 1000, B = 0000, C = 0000\n
posA:
    aam
    or     al,    30h
    mov    [buffer+7],    al    ; A = 0001, B = 0000, C = 0000\n
    mov    al,    ah
    aam
    or     ax,    3030h
    mov    [buffer+6],    al    ; A = 0010, B = 0000, C = 0000\n
    mov    [buffer+5],    ah    ; A = 0100, B = 0000, C = 0000\n
        ;----------|
        ; write b  |
        ;----------|
    mov    al,    [b]
    test   al,   080h           ; is b negative?
    jns    posB
    neg    al                   ; get abs_value of b
    mov    [buffer+14],    2dh  ; A = 0000, B = 1000, C = 0000\n
posB:
    aam
    or     al,    30h
    mov    [buffer+17],    al   ; A = 0000, B = 0001, C = 0000\n
    mov    al,    ah
    aam
    or     ax,    3030h
    mov    [buffer+16],    al   ; A = 0000, B = 0010, C = 0000\n
    mov    [buffer+15],    ah   ; A = 0000, B = 0100, C = 0000\n
        ;----------|
        ; write c  |
        ;----------|
    mov    al,    [c]
    test   al,   080h           ; is c negative?
    jns    posC
    neg    al                   ; abs val of c
    mov    [buffer+24],    2dh  ; A = 0000, B = 0000, C = 1000\n
posC:
    aam
    or     al,    30h
    mov    [buffer+27],    al   ; A = 0000, B = 0000, C = 1000\n
    mov    al,    ah
    aam
    or     ax,    3030h
    mov    [buffer+26],    al   ; A = 0000, B = 0000, C = 0001\n
    mov    [buffer+25],    ah   ; A = 0000, B = 0000, C = 0010\n
    
wrFile:
    mov    dx,    offset buffer
    mov    cx,    29
    mov    ah,    40h
    mov    bx,    handle
    int    21h
    mov    [buffer+4],     030h ; A = 1000, B = 0000, C = 0000\n
    mov    [buffer+14],    030h ; A = 0000, B = 1000, C = 0000\n
    mov    [buffer+24],    030h ; A = 0000, B = 0000, C = 1000\n
    
loop_iter:
    inc    [c]
    dec    [count_c]
    cmp    [count_c],    -1
    jz     cCount_0
    jmp    loop_c
cCount_0:  
    inc    [b]
    dec    [count_b]
    cmp    [count_b],    -1
    jz     bCount_0
    jmp    loop_b
bCount_0:
    inc    [a]
    dec    [count_a]
    cmp    [count_a],    -1    
    jz     aCount_0
    jmp    loop_a
aCount_0:
    
clFile:
    mov    ah,    3Eh
    mov    bx,    [handle]
    int    21h
    
Exit:
    mov    ah,    04Ch
    mov    al,    0
    int    21h
    End    Start
    
    