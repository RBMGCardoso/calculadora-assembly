.DATA  
width DW 35
height DW 35
limHeight DW ? 
limWidth DW ?
x DW 10
y DW 10
verticalDrawn DB 0h 
horizontalDrawn DB 0h   
drawnSquares DB 0h
currentAscii DB 48

.CODE        
DESENHAQUADRADO PROC
    MOV AX, y              
    ADD AX, height          
    MOV limHeight, AX       
    
    drawVLine:              ; Inicia o desenho de uma linha vertical
    mov ah, 0Ch             ; Modo da INT 10h para desenhar pixeis
    mov al, 0fh             ; Cor a ser utilizada no desenho
    mov bh, 0               ; Página a ser utilizada no desenho  
    mov cx, X               ; Posição x do pixel
    mov dx, y               ; Posição y do pixel
    INT 10h                 ; Interrupção da BIOS
    
    ADD y, 1                ; Aumenta a var Y de forma a descer um pixel
    MOV AX, Y               ; Fix memory to memory
    
    CMP AX, limHeight       ; Verifica se a variavel Y chegou á altura limite
    JB drawVLine
                       
    ADD verticalDrawn, 1    ; Incrementa a flag verticalDrawn
    MOV AX, y               ;                                
    SUB AX, height          ;                                
    MOV y, AX               ; Volta á posição y inicial      
    MOV AX, x               ; Adiciona a width do quadrado á variavel x
    ADD AX, width
    MOV x, AX    
    CMP verticalDrawn,2     ; Desenha outra linha caso a primeira não tenha sido desenhada
    JNE drawVLine 
    
    MOV AX, x
    SUB AX, width           ; Reseta posição x removendo 2*Width para compensar a width adicionada na ultima execução de drawVLine
    SUB AX, width
    MOV x, AX  
    
    MOV AX, x
    ADD AX, width           ; Adiciona width á posição atual de x de forma a obter a nova largura limite
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
    MOV BX, 0
    espaço: 
    MOV DL, ' '
    INT 21H
    INC BX
    CMP BX, CX
    JL espaço
    RET
ENDP

NEWLINE PROC
    MOV AH, 2
    MOV DL, 10
    INT 21H
    MOV DL, 13
    INT 21H
RET
ENDP


MAIN PROC  
    MOV DX, @DATA           ; Variaveis
    MOV DS, DX           
    
    mov ah, 0               ; Inicialização do modo gráfico
    mov al, 13h
    int 10h
        
    CALL NEWLINE
    CALL NEWLINE
    CALL NEWLINE
    
    drawNumbers:
    MOV CX, 4 
    CALL ESPACOS
    MOV DL, currentAscii
    INC currentAscii
    INT 21H
    CMP currentAscii, 52
    JLE drawNumbers
    
    MOV CX, 5
    CALL ESPACOS
    MOV DL, 45
    INT 21H
    
    MOV CX, 5
    CALL ESPACOS
    MOV DL, 174
    INT 21H
    
    CALL NEWLINE
    CALL NEWLINE
    CALL NEWLINE
    CALL NEWLINE
    CALL NEWLINE
    
    drawNumbers2:
    MOV CX, 4 
    CALL ESPACOS
    MOV DL, currentAscii
    INC currentAscii
    INT 21H
    CMP currentAscii, 57
    JLE drawNumbers2
    
    MOV CX, 5
    CALL ESPACOS
    MOV DL, 61
    INT 21H
    
    CALL PRINTINPUTSCREEN 
                            
ENDP
END MAIN                                                    

