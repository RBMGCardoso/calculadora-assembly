.DATA
; Welcome screen variables
input DW 0
welcomeString DB '               ALGORITMOS$' 
startString DB '           PRESSIONE UM BOTAO$'
buttonString DB '     DIVISAO             RAIZ QUADRADA$'
paramX DW ?
paramY DW ?
comprimentoLim DW ?
larguraLim DW ?

; Input screen  
width DW 35
height DW 35
limHeight DW ? 
limWidth DW ?
x DW 20
y DW 100
verticalDrawn DB 0h 
horizontalDrawn DB 0h   
drawnSquares DB 0h
currentAscii DB 48
msgDivisor DB 'Divisor: $'
msgDividendo DB 'DIvidendo: $'
msgResultado DB 'Resultado: $'

.CODE
WELCOMEWINDOW proc
    ;alinha a welcomeString no sitio pretendido
    MOV CX, 7
    CALL NEWLINE
    
    ;mostra welcomeString
    mov dx, offset welcomeString
    mov ah, 09h
    int 21h  
    
    MOV CX, 2
    call NEWLINE
    
    ;mostra startString
    mov dx, offset startString
    mov ah, 09h
    int 21h   
ret 
ENDP

INSIDESQUARETEXT PROC
    MOV CX, 5 
    call NEWLINE 
    mov dx, offset buttonString
    mov ah, 09h
    int 21h
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
    
    ;verifica as coordenadas X para ver se est� dentro do bot�o esquerdo
    CMP CX, 028H
    JL checkRightButton
        
    CMP CX, 0F0H
    JG checkRightButton
    
       
    ;verifica as coordenadas Y para ver se est� dentro do bot�o esquerdo
    CMP DX, 064H 
    JL checkRightButton
    
    CMP DX, 086H
    JG checkRightButton
    
    jmp confirmDivision
        
    checkRightButton:        
    ;verifica as coordenadas X para ver se est� dentro do bot�o
    CMP CX, 017EH
    JL mouseLoop
    
    CMP CX, 026AH
    JG mouseLoop
    
    ;verifica as coordenadas Y para ver se est� dentro do bot�o esquerdo
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
    CALL WELCOMEWINDOW
    CALL desenhaQuadrados    
    CALL insideSquareText   
    CALL recebeMouseKeyboardInput
    
    CMP input, 1
    JE jmpDivis
    
    CMP input, 2
    JE jmpRaiz
       
    jmpDivis:
    CALL INPUTSCREEN  
    RET
    
    jmpRaiz:
    CALL INPUTSCREEN
    RET    
     
RET
endp 
        
DESENHAQUADRADO PROC
    MOV AX, y              
    ADD AX, height          
    MOV limHeight, AX       
    
    drawVLine:              ; Inicia o desenho de uma linha vertical
    mov ah, 0Ch             ; Modo da INT 10h para desenhar pixeis
    mov al, 0fh             ; Cor a ser utilizada no desenho
    mov bh, 0               ; P�gina a ser utilizada no desenho  
    mov cx, X               ; Posi��o x do pixel
    mov dx, y               ; Posi��o y do pixel
    INT 10h                 ; Interrup��o da BIOS
    
    ADD y, 1                ; Aumenta a var Y de forma a descer um pixel
    MOV AX, Y               ; Fix memory to memory
    
    CMP AX, limHeight       ; Verifica se a variavel Y chegou � altura limite
    JB drawVLine
                       
    ADD verticalDrawn, 1    ; Incrementa a flag verticalDrawn
    MOV AX, y               ;                                
    SUB AX, height          ;                                
    MOV y, AX               ; Volta � posi��o y inicial      
    MOV AX, x               ; Adiciona a width do quadrado � variavel x
    ADD AX, width
    MOV x, AX    
    CMP verticalDrawn,2     ; Desenha outra linha caso a primeira n�o tenha sido desenhada
    JNE drawVLine 
    
    MOV AX, x
    SUB AX, width           ; Reseta posi��o x removendo 2*Width para compensar a width adicionada na ultima execu��o de drawVLine
    SUB AX, width
    MOV x, AX  
    
    MOV AX, x
    ADD AX, width           ; Adiciona width � posi��o atual de x de forma a obter a nova largura limite
    MOV limWidth, AX                              
                                
    drawHLine:
    mov ah, 0Ch        
    mov al, 0fh
    mov bh, 0   
    mov cx, X      
    mov dx, y 
    INT 10h 
    
    ADD x, 1 
    MOV AX, x  
    CMP AX, limWidth
    JB drawHLine
      
    ADD horizontalDrawn, 1  
    MOV AX, x
    SUB AX, width
    MOV x, AX
    MOV AX, y
    ADD AX, height
    MOV y, AX    
    
    CMP horizontalDrawn,2  
    JNE drawHLine
    
    MOV AX, y
    SUB AX, height 
    SUB AX, height
    MOV y, AX  
RET
ENDP

   

PRINTINPUTSCREEN PROC   
    drawTopSquares:         ; Desenha os 7 quadrados de cima (0-9 ; "," ; backspace)
        MOV horizontalDrawn, 0h ; Reset das flags de contagem de linhas
        MOV verticalDrawn, 0h   ; Reset das flags de contagem de linhas
        
        CALL DESENHAQUADRADO    ; Desenha um quadrado tendo as vars X,Y como ponto top-right e height, width como altura e largura
        MOV AX, x
        ADD AX, width
        ADD AX, 9               ; Margem entre quadrados
        MOV x, AX 
        INC drawnSquares    ; Incrementa drawnSquares de modo a contar quandos quadrados foram desenhados
    CMP drawnSquares, 7 
    JL drawTopSquares
    
    MOV drawnSquares, 0
    MOV Y, 10
    MOV X, 10
    
    MOV AX, Y
    ADD AX, height
    ADD AX, 9
    MOV Y, AX
          
    drawBottomSquares:
        MOV horizontalDrawn, 0h ; Reset das flags de contagem de linhas
        MOV verticalDrawn, 0h   ; Reset das flags de contagem de linhas
        
        CALL DESENHAQUADRADO    ; Desenha um quadrado tendo as vars X,Y como ponto top-right e height, width como altura e largura
        MOV AX, x
        ADD AX, width
        ADD AX, 9               ; Margem entre quadrados
        MOV x, AX 
        INC drawnSquares    ; Incrementa drawnSquares de modo a contar quandos quadrados foram desenhados
        
        CMP drawnSquares, 5
        JL drawBottomSquares
        MOV AX, width   
        MOV BX, 2
        MUL BX
        ADD AX, 9
        MOV width, AX
    CMP drawnSquares, 6
    JL drawBottomSquares    
RET
ENDP

ESPACOS PROC
    MOV AH, 2
    MOV BX, 0
    espa�o: 
    MOV DL, ' '
    INT 21H
    INC BX
    CMP BX, CX
    JL espa�o
    RET
ENDP

NEWLINE PROC
    MOV BX, 0
    newLineLoop:
        MOV AH, 2
        MOV DL, 10
        INT 21H
        MOV DL, 13
        INT 21H
        INC BX
    CMP BX, CX
    JL newLineLoop
RET
ENDP

DRAWNUMBERS PROC    
    MOV CX, 3       ; CX representa o n�mero de linhas a adicionar
    CALL NEWLINE
    
    drawTopNumbers:
    MOV CX, 4       ; CX representa o n�mero de espa�os a adicionar
    CALL ESPACOS
    MOV DL, currentAscii
    INC currentAscii
    INT 21H
    CMP currentAscii, 52
    JLE drawTopNumbers
    
    MOV CX, 5       ; CX representa o n�mero de espa�os a adicionar
    CALL ESPACOS
    MOV DL, 45
    INT 21H
    
    MOV CX, 5       ; CX representa o n�mero de espa�os a adicionar
    CALL ESPACOS
    MOV DL, 174
    INT 21H
    
    MOV CX, 5       ; CX representa o n�mero de linhas a adicionar
    CALL NEWLINE
    
    drawBotNumbers:
    MOV CX, 4 
    CALL ESPACOS
    MOV DL, currentAscii
    INC currentAscii
    INT 21H
    CMP currentAscii, 57
    JLE drawBotNumbers
    
    MOV CX, 5
    CALL ESPACOS
    MOV DL, 61
    INT 21H
RET
ENDP

DRAWDIVISOR PROC    
    MOV CX, 4
    CALL ESPACOS

    MOV CX, 6
    CALL NEWLINE
    
    MOV AH, 9
    MOV DX, OFFSET msgDivisor
    INT 21H
        
RET
ENDP

DRAWDIVIDENDO PROC
    MOV CX, 4
    CALL ESPACOS

    MOV CX, 2
    CALL NEWLINE
    
    MOV AH, 9
    MOV DX, OFFSET msgDividendo
    INT 21H
        
RET
ENDP

DRAWRESULTADO PROC
    MOV CX, 4
    CALL ESPACOS

    MOV CX, 3
    CALL NEWLINE
    
    MOV AH, 9
    MOV DX, OFFSET msgResultado
    INT 21H
        
RET
ENDP

INPUTSCREEN PROC
    mov ah, 0               ; Inicializa��o do modo gr�fico
    mov al, 13h
    int 10h
    
    MOV AX, 0
    MOV BX, 0
    MOV CX, 0
    MOV DX, 0
    
    MOV width, 35
    MOV height, 35 
    MOV x, 10
    MOV y, 10
    
    CALL DRAWNUMBERS
    CALL PRINTINPUTSCREEN
    CALL DRAWDIVISOR
    
    CALL DRAWDIVIDENDO
    CALL DRAWRESULTADO
RET
ENDP 

MAIN PROC  
    MOV DX, @DATA           ; Variaveis
    MOV DS, DX                             
    
    mov ah, 0               ; Inicializa��o do modo gr�fico
    mov al, 13h
    int 10h
    
    CALL showMainScreen                           
ENDP
END MAIN                                                    
