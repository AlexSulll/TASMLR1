.model      small
.186
.stack      100h
.data
   A db 127

.code
Start:
    mov     ax,@data
    mov     ds,ax
    mov     al,[A]
    
    aam 
    end Start