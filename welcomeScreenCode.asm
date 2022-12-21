.DATA 
;welcome screen variables
x DW 20
y DW 100
input DW 0
welcomeString DB '               ALGORITMOS$' 
startString DB '           PRESSIONE UM BOTAO$'
buttonString DB '     DIVISAO             RAIZ QUADRADA$'
paramX DW ?
paramY DW ?
comprimentoLim DW ?
larguraLim DW ?

;METER O RATO A FUNCIONAR COM O BOTAO DA RAIZ QUADRADA TAMBEM

.CODE
welcomeWindow proc
    ;alinha a welcomeString no sitio pretendido
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    
    ;mostra welcomeString
    mov dx, offset welcomeString
    mov ah, 09h
    int 21h  
    
    call CH_NEXTLINE
    call CH_NEXTLINE
    
    ;mostra startString
    mov dx, offset startString
    mov ah, 09h
    int 21h   
    ret 
endp 

;texto dentro dos botoes
insideSquareText proc 
    call CH_NEXTLINE 
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    call CH_NEXTLINE
    mov dx, offset buttonString
    mov ah, 09h
    int 21h 
endp

;escrever na proxima linha
CH_NEXTLINE PROC   
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H 
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H 
    RET
ENDP

verticalLines proc
    writeVertical:
    mov ah,0ch
    mov al, 0fh ;color
    mov cx, x ; x co-ordinate
    mov dx, y ; y co-ordinate
    mov bh,1    ; page no - critical while animating  
    INC y
    int 10h
    MOV AX, larguraLim 
    CMP y, AX
    JBE writeVertical
    
    MOV AX, paramX
    MOV BX, paramY 
    
    MOV x, AX
    MOV y, BX
    
    writeVertical2:
    mov ah,0ch;
    mov al, 0fh ;color
    mov cx, x ; x co-ordinate
    mov dx, y ; y co-ordinate
    mov bh,1    ; page no - critical while animating  
    INC y
    int 10h
    MOV AX, larguraLim 
    CMP y, AX
    JBE writeVertical2
    ret
endp 

horizontalLines proc 
    writeHorizontal:
    mov ah,0ch;
    mov al, 0fh ;color
    mov cx, x ; x co-ordinate
    mov dx, y ; y co-ordinate
    mov bh,1    ; page no - critical while animating  
    INC x
    int 10h
    MOV AX, comprimentoLim 
    CMP x, AX 
    JBE writeHorizontal
    
    MOV AX, paramX
    MOV BX, paramY
     
    MOV x, AX
    MOV y, BX
    
    writeHorizontal2:
    mov ah,0ch;
    mov al, 0fh ;color
    mov cx, x ; x co-ordinate
    mov dx, y ; y co-ordinate
    mov bh,1    ; page no - critical while animating  
    INC x
    int 10h 
    MOV AX, comprimentoLim 
    CMP x, AX 
    JBE writeHorizontal2
    ret
endp


;desenha o quadrado
desenhaQuadrados proc
    ;desenha botao da divisao
    MOV paramX,120
    MOV paramY,100
    MOV larguraLim,135
    MOV comprimentoLim,120
    CALL verticalLines
    
    MOV x, 20
    MOV y, 100
    MOV paramX,20
    MOV paramY,135
    CALL horizontalLines
    
    ;desenha botao da raiz quadrada
    mov x, 190
    mov y, 100
    MOV paramX,310
    MOV paramY,100
    MOV larguraLim,135
    MOV comprimentoLim,310
    CALL verticalLines
    
    MOV x, 190
    MOV y, 100
    MOV paramX,190
    MOV paramY,135
    CALL horizontalLines 
      
    ret   
endp

recebeMouseKeyboardInput proc      
    ;se o utilizador pressionar 1, permite escolher o algoritmo pelo teclado, se pressionar 2 , permite escolher o algoritmo pelo rato     
    choiceError:
    mov ah,00h
    int 16h
    
    CMP al,031H
    JE keyboardInput 
    
    CMP al,032H
    JE mouseLoop
    JNE choiceError
    
    keyboardInput:
    mov ah,00h
    int 16h
    
    CMP al, 031H
    JE confirmDivision
    
    CMP al, 032H
    JE confirmSqrt
    JNE keyBoardInput
     
    ;inicializa o rato 
    MOV AX,00H
    INT 33H  
    
    mouseLoop: 
    ;mostra cursor
    MOV AX, 01H
    INT 33H   
    
    ;recebe a posicao do cursor
    MOV AX, 03H
    INT 33H
    
    ;verifica se foi clicado no botao esquerdo do rato
    CMP BX, 1 
    JNE mouseLoop
    
    ;verifica as coordenadas X para ver se está dentro do botão esquerdo
    CMP CX, 028H
    JL checkRightButton
        
    CMP CX, 0F0H
    JG checkRightButton
    
       
    ;verifica as coordenadas Y para ver se está dentro do botão esquerdo
    CMP DX, 064H 
    JL checkRightButton
    
    CMP DX, 086H
    JG checkRightButton
    
    jmp confirmDivision
        
    checkRightButton:        
    ;verifica as coordenadas X para ver se está dentro do botão
    CMP CX, 017EH
    JL mouseLoop
    
    CMP CX, 026AH
    JG mouseLoop
    
    ;verifica as coordenadas Y para ver se está dentro do botão esquerdo
    CMP DX, 064H 
    JL mouseLoop
    
    CMP DX, 086H
    JG mouseLoop
    JMP confirmSqrt
    
    
    confirmDivision:
    ;se estiver input = 1 
    ADD input,1 
    JMP fimProc 
    
    confirmSqrt:
    ADD input,2
    
    fimproc:
    ret
endp

;mostra o ecra principal do programa
showMainScreen proc
    CALL welcomeWindow
    CALL desenhaQuadrados    
    CALL insideSquareText   
    CALL recebeMouseKeyboardInput
    ret
endp

MAIN PROC FAR
    MOV DX, @DATA
    MOV DS, DX
    
    ;começa o modo gráfico
    MOV AH, 00H ; Set video mode
    MOV AL, 13H ; Mode 13h
    INT 10H 
       
    CALL showMainScreen 
    
    ;começa o modo gráfico
    MOV AH, 00H ; Set video mode
    MOV AL, 13H ; Mode 13h
    INT 10H 
ENDP
END MAIN