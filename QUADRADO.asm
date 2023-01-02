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
msgDividendo DB 'Dividendo: $'   
msgRadicando DB 'Radicando: $'
msgResultado DB 'Resultado: $'
msgResto DB 'Resto: $'
inputCounter DW ? ; 1: Dividendo, 2: Divisor; 3: Radicando  
                                           
; Algoritmo da divisão
dividArray DB 10 dup(10)
divisArray DB 10 dup(10) 
newDivisor DW 0
dividCount DW 0
divisCount DW 0
HIGHORDER DW 0  
IMULT DW 0 
RESTO DW 0 
QUOCIENTE DW 0  
ARRAYPOS DW -2 
ARRAYPOSINPUT DW -2  
CALCQUOCIENTERESTO DW 0  
INPUTDIGITDIVISOR DW 0 
ARRAYRESULTDIVISAO DW 6 DUP(0) 
QCOUNT DW -2 
NEGATIVO DW 0


; Algoritmo da divisão
radicandoArray DB 10 dup(10)
radicandoCount DW 0  
HIGHORDER1 DW 0  
HIGHORDER2 DW 0
I  DW -1
J  DW -1
NALGARISMO DW 0
NDIGITSHIGHORDER DW -1   
ARRAYPOSATUAL DW -2
RESULTFINAL DW 0 
AUX DW 0  
NDIGITOSRADICANDO DW 0  
ARRAYRESULTRAIZ DW 6 DUP(0)

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
    MOV x, 20
    MOV y, 100
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
    CALL WELCOMEWINDOW
    CALL insideSquareText   
    CALL desenhaQuadrados    
    CALL recebeMouseKeyboardInput
    
    ; Deteta qual numero foi pressionado, e verifica se está dentro dos valores possiveis
    CMP input, 1
    JE execute
    
    CMP input, 2
    JE execute
    
    RET
    execute:   
    CALL INPUTSCREEN         
RET
endp 
        
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
    MOV AH, 2
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
    MOV CX, 3       ; CX representa o número de linhas a adicionar
    CALL NEWLINE
    
    drawTopNumbers:
    MOV CX, 4       ; CX representa o número de espaços a adicionar
    CALL ESPACOS
    MOV DL, currentAscii
    INC currentAscii
    INT 21H
    CMP currentAscii, 52
    JLE drawTopNumbers
    
    MOV CX, 5       ; CX representa o número de espaços a adicionar
    CALL ESPACOS
    MOV DL, 45
    INT 21H
    
    MOV CX, 5       ; CX representa o número de espaços a adicionar
    CALL ESPACOS
    MOV DL, 174
    INT 21H                                                                                                                       
    
    MOV CX, 5       ; CX representa o número de linhas a adicionar
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

; Desenha o texto de divisor dentro da tela de input
DRAWDIVISOR PROC    
    MOV CX, 4
    CALL ESPACOS

    MOV CX, 2
    CALL NEWLINE
    
    MOV AH, 9
    MOV DX, OFFSET msgDivisor
    INT 21H
        
RET
ENDP   

; Desenha o texto de dividendo dentro da tela de input
DRAWDIVIDENDO PROC
    MOV CX, 4
    CALL ESPACOS

    MOV CX, 6
    CALL NEWLINE
    
    MOV AH, 9
    MOV DX, OFFSET msgDividendo
    INT 21H
        
RET
ENDP

; Desenha o texto de radicando dentro da tela de input
DRAWRADICANDO PROC
    MOV CX, 4
    CALL ESPACOS

    MOV CX, 6
    CALL NEWLINE
    
    MOV AH, 9
    MOV DX, OFFSET msgRadicando
    INT 21H
        
RET
ENDP 

KBHANDLER_AFTEREXEC PROC
   kbLoopAfterExec:
   MOV AH, 00H
   INT 16H
   
   CMP AX, 1C0DH ;Enter
   JNE kbLoopAfterExec   
RET
ENDP


; Realiza a leitura do teclado dentro da tela de input e faz a verificação do input
KBHANDLER_INPUTSCREEN PROC
    kbLoop:         ; Ativa a leitura do teclado
    MOV AH, 00H
    INT 16H
    
    ; Comparações do input dado com os valores permitidos  
    CMP AX, 011BH       ; Verifica se foi clicado no Esc
    JE goBack
    
    CMP AX, 1C0DH ;Enter
    JE finish:
    
    CMP AX, 0E08H ;backspace
    JE backspace
    
    CMP AL, 45 ; menos
    JE makeNegativo    
    
    ; Verificação entre os numeros 0-9
    CMP AX, 0231H
    JL kbLoop
    
    CMP AX, 0B30H
    JG kbLoop
    
    JMP acceptedInput
    
    goBack:
        CALL CLEARSCREEN
        CALL SOFTRESET
        CALL showMainScreen
    
    makeNegativo:
        CMP inputCounter, 1
        JE dividNegativo
    
        CMP inputCounter, 2
        JE divisNegativo
        
        JMP kbLoop
        dividNegativo:
            CMP dividCount, 0
            JNE kbLoop 
            CMP negativo, 1
            JE kbLoop
            INC negativo
            
            MOV DL, 45
            MOV AH, 2H
            INT 21H
            
            JMP kbLoop
            
        divisNegativo:
            CMP divisCount, 0
            JNE kbLoop 
            CMP negativo, 2
            JE kbLoop
            INC negativo
            
            MOV DL, 45
            MOV AH, 2H
            INT 21H
                            
            JMP kbLoop    
    
    acceptedInput:
        CMP input, 2
        JE raizInput
        
        divInput:
            CMP inputCounter, 1
            JE dividInput
        
            CMP inputCounter, 2
            JE divisInput
        
            dividInput:                          
                MOV SI, dividCount
                SUB AL, 48             
                MOV dividArray[SI], AL
                ADD dividCount, 1
                
                MOV AH, 2
                MOV DL, dividArray[SI] 
                ADD DL, 48
                INT 21H
                
                JMP kbLoop
 
            divisInput:            
                MOV SI, divisCount
                SUB AL, 48 
                MOV divisArray[SI], AL
                ADD divisCount, 1
                
                MOV AH, 2
                MOV DL, divisArray[SI] 
                ADD DL, 48
                
                INT 21H
                
                ; Converte o array de divisor para um número de forma a ser compativel com o algoritmo da divisão previamente desenvolvido
                MOV AX, newDivisor
                MOV CX, 10
                MUL CX
                
                ; "Converte" o array de 8bits para um array de 16bits
                MOV CH, 0
                MOV CL, divisArray[SI]
                
                ADD AX, CX
                MOV newDivisor, AX  
                                
                JMP kbLoop
        
        raizInput:
            MOV SI, radicandoCount
            SUB AL, 48
            MOV radicandoArray[SI], AL
            ADD radicandoCount, 1
            
            MOV AH, 2
            MOV DL, radicandoArray[SI]  
            ADD DL, 48   
            INT 21H
            JMP kbLoop
        
    backspace:    
        ; Decrementa a contagem do respetivo array
        CMP inputCounter, 1
        JE decDivid
        CMP inputCounter, 2
        JE decDivis
        CMP inputCounter, 3
        JE decRaiz       
        
        decDivid:           
            ; Verifica se é possivel remover mais algum digito
            CMP dividCount, 0
            JNE notNegativo
            
            CMP negativo, 1
            JNE notNegativo
            JE removeNegativo
            
            notNegativo:
            SUB dividCount, 1
            JMP removeChar
            
        decDivis:
            ; Verifica se é possivel remover mais algum digito
            CMP divisCount, 0
            JE kbLoop
            
            MOV DX, 0
            MOV AX, newDivisor
            MOV BX, 10
            DIV BX
            MOV newDivisor, AX
            
            continue:
            SUB divisCount, 1
            JMP removeChar
            
        decRaiz:
            ; Verifica se é possivel remover mais algum digito
            CMP radicandoCount, 0
            JE kbLoop        
        
            SUB radicandoCount, 1
            JMP removeChar
        
        
        removeNegativo:
        DEC negativo
        removeChar:
        ; Remove o ultimo caracter
        MOV AH, 2
        MOV DL, 8 ;backspace
        INT 21H
        
        MOV DL, 32 ; espaço
        INT 21H 
        
        MOV DL, 8 ;backspace
        INT 21H
        JMP kbLoop
    
    finish:       
RET
ENDP

RESULTADODIV PROC
    ;MOSTRA O RESULTADO DA DIVISAO
    MOV CX, 3
    CALL NEWLINE
    MOV DX, OFFSET MSGRESULTADO
    MOV AH, 09H
    INT 21H
    
    ;SEPARA OS DIGITOS DO QUOCIENTE E GUARDA NUM ARRAY ARRAYRESULTDIVISAO
    SEPARADIGITOS: 
        MOV DX,0
        MOV AX, QUOCIENTE
        MOV BX, 10
        DIV BX
        MOV QUOCIENTE,AX
        ADD QCOUNT, 2
        MOV BX, QCOUNT
        MOV ARRAYRESULTDIVISAO[BX], DX
        CMP QUOCIENTE, 0
        JG SEPARADIGITOS
        
        ;SE FOR NEGATIVO ADICIONA - AO QUOCIENTE
        CMP NEGATIVO,1
        JNE MOSTRAQUOCIENTE0
        
        MOV DL,0F0H
        MOV AH, 06H
        INT 21H 
        
        ;MOSTRA O QUOCIENTE 
        MOSTRAQUOCIENTE0:
        ADD QCOUNT, 2
        MOSTRAQUOCIENTE:
        SUB QCOUNT, 2
        MOV BX, QCOUNT
        MOV AX, ARRAYRESULTDIVISAO[BX]
        MOV DX, AX
        ADD DX, 130H
        MOV AH, 06H
        INT 21H
        CMP QCOUNT, 0
        JNE MOSTRAQUOCIENTE
        
        ;separa resto digito a digito 
        MOV CX, 1
        CALL NEWLINE
        MOV QCOUNT, -2
        SEPARARESTO:
        MOV DX,0
        MOV AX, RESTO
        MOV BX, 10
        DIV BX
        MOV RESTO,AX
        ADD QCOUNT, 2
        MOV BX, QCOUNT
        MOV ARRAYRESULTDIVISAO[BX], DX
        CMP RESTO, 0
        JG SEPARARESTO
        
        MOV DX, OFFSET msgResto
        MOV AH,09H
        INT 21H
        
        ;MOSTRA O RESTO
        MOSTRARESTO0:
        ADD QCOUNT, 2
        MOSTRARESTO:
        SUB QCOUNT, 2
        MOV BX, QCOUNT
        MOV AX, ARRAYRESULTDIVISAO[BX]
        MOV DX, AX
        ADD DX, 130H
        MOV AH, 06H
        INT 21H
        CMP QCOUNT, 0
        JNE MOSTRARESTO
RET
ENDP

;MOSTRA RESULTADO DA RAIZ QUADRADA
MOSTRARESULTSQRT PROC
    MOV CX, 1
    CALL NEWLINE
    MOV DX, OFFSET msgResultado
    MOV AH, 09H
    INT 21H
    
    ;SEPARA OS DIGITOS DO QUOCIENTE E GUARDA NUM ARRAY ARRAYRESULTDIVISAO
    SEPARADIGITOSRAIZ: 
        MOV DX,0
        MOV AX, RESULTFINAL
        MOV BX, 10
        DIV BX
        MOV RESULTFINAL,AX
        ADD QCOUNT, 2
        MOV BX, QCOUNT
        MOV ARRAYRESULTRAIZ[BX], DX
        CMP RESULTFINAL, 0
        JG SEPARADIGITOSRAIZ
        
        ;MOSTRA O QUOCIENTE 
        MOSTRARAIZ0:
        ADD QCOUNT, 2
        MOSTRARAIZ:
        SUB QCOUNT, 2
        MOV BX, QCOUNT
        MOV AX, ARRAYRESULTRAIZ[BX]
        MOV DX, AX
        ADD DX, 130H
        MOV AH, 06H
        INT 21H
        CMP QCOUNT, 0
        JNE MOSTRARAIZ
    RET
ENDP



; Mostra a tela de input, fazendo as alterações necessárias consoante o algoritmo escolhido
INPUTSCREEN PROC
    CALL CLEARSCREEN
    
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
    
    CMP input, 1
    JE inputDivisao 
    
    CMP input, 2
    JE inputRaiz
    
    
    inputDivisao:
        MOV inputCounter, 1
        CALL DRAWDIVIDENDO
        CALL KBHANDLER_INPUTSCREEN
        MOV inputCounter, 2
        CALL DRAWDIVISOR
        CALL KBHANDLER_INPUTSCREEN
        CALL DIVISAO
        CALL RESULTADODIV
        CALL KBHANDLER_AFTEREXEC
        JMP finalExecucao
        
    inputRaiz:
        MOV inputCounter, 3
        CALL DRAWRADICANDO
        CALL KBHANDLER_INPUTSCREEN
        CALL SQRTALGORITMO
        CALL MOSTRARESULTSQRT
        CALL KBHANDLER_AFTEREXEC
        
    finalExecucao:
        CALL CLEARSCREEN
        CALL SOFTRESET
        CALL showMainScreen            
RET
ENDP 
    
CLEARSCREEN PROC
    mov ah, 0               ; Inicialização do modo gráfico
    mov al, 13h
    int 10h    
RET
ENDP

SOFTRESET PROC
    MOV verticalDrawn, 0
    MOV horizontalDrawn, 0
    MOV x, 10
    MOV y, 10
    MOV drawnSquares, 0
    MOV currentAscii, 48
    MOV width, 35
    MOV height, 35  
    MOV input, 0
   
    ; Variáveis da divisão  
    MOV dividCount, 0
    MOV divisCount ,0
    MOV HIGHORDER, 0
    MOV IMULT, 0
    MOV RESTO, 0
    MOV QUOCIENTE, 0
    MOV ARRAYPOS, -2
    MOV ARRAYPOSINPUT, -2
    MOV CALCQUOCIENTERESTO, 0
    MOV INPUTDIGITDIVISOR, 0
    MOV QCOUNT, -2
    MOV NEGATIVO, 0      
    
    ; Variáveis da raiz
    MOV radicandoCount, 0
    MOV HIGHORDER1, 0
    MOV HIGHORDER2, 0
    MOV I, -1
    MOV J, -1
    MOV NALGARISMO, 0
    MOV NDIGITSHIGHORDER, -1
    MOV ARRAYPOSATUAL, -2
    MOV RESULTFINAL, 0
    MOV AUX, 0
    MOV NDIGITOSRADICANDO, 0
RET
ENDP

;ALGORITMO DA DIVISAO
DIVISAO PROC 
    INICIO:     
    ;OBTÉM O PRIMEIRO HIGH ORDER DO DIVIDENDO   
    GETHIGHORDER:
        ADD ARRAYPOS, 1 
        MOV BX, ARRAYPOS
        MOV AH,0 
        MOV AL, DividArray[BX] 
        CMP AX, 10
        JB COMPARAHIGHORDER
        JAE OVERFLOW
    
    ;COMPARA O HIGH ORDER COM O DIVISOR. SE O HIGH ORDER FOR MENOR DO QUE DIVISOR, PASSA PARA A LABEL "CONCATHIGHORDER". SE FOR MAIOR OU IGUAL PASSA PARA A LABEL "FLAG"    
    COMPARAHIGHORDER:
        MOV HIGHORDER, AX
        MOV RESTO, AX
        CMP AX, newDivisor
        JB CONCATHIGHORDER 
        JAE FLAG          
    
    ;CONCATENA O HIGH ORDER SEGUINTE, CASO O DIVISOR SEJA MAIOR DO QUE O HIGH ORDER INICIAL    
    CONCATHIGHORDER:
        
        ;CERTIFICA-SE DE QUE A POSIÇÃO NO ARRAY A SEGUIR À ATUAL NÃO É 10, SENDO QUE 10 DETERMINA O FIM DO ARRAY
        ADD ARRAYPOS, 1
        MOV BX, ARRAYPOS
        MOV CH, 0
        MOV CL, DividArray[BX]
        CMP CX, 10     
        ;SE A POSICAO A SEGUIR FOR 10, PASSA PARA A LABEL "FLAG", SENÃO PASSA PARA A LABEL "NEXT" 
        JNE NEXT
        JE FLAG
        
        NEXT:    
        MOV CX, 10
        MOV DX, 0 
        MUL CX
        MOV CH, 0
        MOV CL, DividArray[BX]
        ADD AX, CX         
        MOV HIGHORDER, AX
        MOV RESTO, AX 
    
    FLAG:
    ;INICIALIZA IMULT A -1 PARA NÃO SER FEITA 1 ITERAÇÃO A MAIS DENTRO DE "QUOCIENTECALC"                        
    MOV IMULT, -1 
    
    ;ITERA ATÉ ENCONTRAR UM VALOR PARA IMULT MAIOR DO QUE O RESTO. SE IMULT FOR IGUAL AO RESTO, PASSA PARA A LABEL "CALCOPERRESTO". QUANDO IMULT FOR MAIOR DO QUE O RESTO, SALTA PARA A LABEL "ITERANTERIOR"
    QUOCIENTECAL:
        INC IMULT
        MOV CX, IMULT
        MOV AX, newDivisor
        MOV DX, 0
        MUL CX 
        CMP AX, RESTO
        JB QUOCIENTECAL
        JE CALCOPERRESTO 
    
    ;ITERA O VALOR DE IMULT ANTERIOR QUE RESPEITE A CONDIÇÃO IMULT * DIVISOR < RESTO     
    ITERANTERIOR:
        DEC IMULT 
    
    ;CALCULA O VALOR QUE VAI SER SUBTRAIDO PELO RESTO 
    CALCOPERRESTO:
        MOV AX, IMULT
        MUL newDivisor
        MOV BX, RESTO
        MOV CALCQUOCIENTERESTO, AX
    
    ;EFETUA A OPERAÇÃO RESTO - CALCQUOCIENTERESTO    
    OPERACAORESTO:
        MOV AX, RESTO
        SUB AX, CALCQUOCIENTERESTO
        MOV RESTO, AX
    
    ;ESTRUTURA DE CONTROLO DO QUOCIENTE   
    CALCQUOCIENTE2:
        ;CERTIFICA-SE DE QUE A POSIÇÃO NO ARRAY A SEGUIR À ATUAL NÃO É 10, SENDO QUE 10 DETERMINA O FIM DO ARRAY
        MOV BX, ARRAYPOS
        ADD BX,1
        CMP DividArray[BX], 10
        ;SE A POSICAO A SEGUIR FOR 10, PASSA PARA A LABEL "CONCATQUOCIENTE", SENÃO PASSA PARA A LABEL "FLAG2" 
        JNE FLAG2
        JE  CONCATQUOCIENTE
            
        FLAG2:
        MOV DX, 0 
        MOV AX, RESTO
        MOV BX, 10
        MUL BX
        MOV RESTO, AX
        
        ;CERTIFICA-SE DE QUE A POSIÇÃO NO ARRAY A SEGUIR À ATUAL NÃO É 10, SENDO QUE 10 DETERMINA O FIM DO ARRAY 
        MOV BX, ARRAYPOS
        ADD BX,1
        CMP DividArray[BX], 10
        ;SE A POSICAO A SEGUIR NÃO FOR 10, PASSA PARA A LABEL "CONCATRESTO"
        JNE CONCATRESTO
    
    ;CONCATENA O VALOR CALCULADO ANTERIORMENTE AO RESTO
    CONCATRESTO:
        MOV AX, RESTO 
        MOV CH, 0
        MOV CL, DividArray[BX]
        ADD AX, CX 
        MOV RESTO, AX
    
    ;CONCATENA O VALOR CALCULADO ANTERIORMENTE AO QUOCIENTE
    CONCATQUOCIENTE:
        MOV AX, 10
        MUL QUOCIENTE
        ADD AX, IMULT
        MOV QUOCIENTE, AX
    
    ;VERIFICA SE A POSICAO ATUAL É A ULTIMA POSICAO DO ARRAY          
    CONDICAOJUMP:
        MOV IMULT, -1
        MOV BX, ARRAYPOS
        ADD BX,1
        ADD ARRAYPOS,1
        CMP DividArray[BX], 10
        JNE QUOCIENTECAL
        JE  OVERFLOW                        
    OVERFLOW:
        RET
ENDP

;ALGORITMO DA RAIZ QUADRADA
SQRTALGORITMO PROC
    NDIGITOS: ;DEVOLVE O NÚMERO DE ALGARISMO DO RADICANDO
       ADD ARRAYPOS, 1 
       INC NALGARISMO 
       MOV BX, ARRAYPOS
       MOV AH, 0
       MOV AL, radicandoArray[BX] 
       MOV CX, ARRAYPOS
       ADD CX, 1
       MOV BX, CX
       MOV CH, 0
       MOV CL, radicandoArray[BX]
       CMP CX, 10
       JE ISEVEN
       JNE NDIGITOS
    
    ISEVEN: ;VERIFICA SE O NUMERO DE DIGITOS É PAR
        MOV DX,0  
        MOV BX, 2 
        MOV AX, NALGARISMO
        DIV BX  
        CMP DX, 0
        JNE GETHIGHORDERPAIRIFNOTEVEN
        JE  GETHIGHORDERPAIRIFEVEN
        
    GETHIGHORDERPAIRIFNOTEVEN:  ;OBTEM O HIGH ORDER SE NALGARISMO FOR IMPAR   
        ADD ARRAYPOSATUAL, 1
        MOV BX, ARRAYPOSATUAL
        MOV AH, 0
        MOV AL, radicandoArray[BX] 
        MOV HIGHORDER1, AX
        DEC NALGARISMO
        JMP ITERACAO1    
     
    GETHIGHORDERPAIRIFEVEN:   ;OBTEM O HIGH ORDER SE NALGARISMO FOR PAR
        ADD ARRAYPOSATUAL, 1
        MOV BX, ARRAYPOSATUAL
        MOV AH, 0
        MOV AL, radicandoArray[BX] 
        MOV CX, 10
        MUL CX
        MOV BX, ARRAYPOSATUAL
        ADD BX, 1
        MOV ARRAYPOSATUAL, BX
        MOV CH, 0
        MOV CL, radicandoArray[BX]
        ADD AX, CX        
        MOV HIGHORDER1, AX       
      
    ITERACAO1: ;DESCOBRE QUAL O VALOR DE I QUE É MAIOR DO QUE O VALOR DO HIGHORDER1
        INC I
        MOV AX,I
        MUL AX
        CMP AX, HIGHORDER1
        JA DECREMENT 
        JBE ITERACAO1
    
    DECREMENT: ;DECREMENTA I PARA UTILIZARMOS O VALOR CORRETO
        DEC I 
    
    SUBTRACAO:  ;SUBTRAI O HIGHORDER AO VALOR GUARDADO EM AX MULTIPLICADO POR I
        MOV AX, ARRAYPOSATUAL
        ADD AX, 1      
        MOV BX,AX
        CMP radicandoArray[BX], 10
        JE FINALRESULT1
        
        MOV AX, I
        MUL AX
        SUB HIGHORDER1, AX 
    
    GETNEXTHIGHORDERPAIR:   ;OBTEM O HIGH ORDER SE NALGARISMO FOR PAR
        ADD ARRAYPOSATUAL, 1
        MOV BX, ARRAYPOSATUAL
        MOV AH, 0
        MOV AL, radicandoArray[BX] 
        MOV CX, 10
        MUL CX
        MOV BX, ARRAYPOSATUAL
        ADD BX, 1
        MOV ARRAYPOSATUAL, BX
        MOV CH, 0
        MOV CL, radicandoArray[BX]
        ADD AX, CX        
        MOV HIGHORDER2, AX
        
            
    MOV AX, HIGHORDER2
    GETHIGHORDERNDIGITS: ;OBTEM O NUMERO DE DIGITOS DO HIGHORDER
        MOV DX, 0
        INC NDIGITSHIGHORDER
        MOV BX, 10
        DIV BX
        CMP AX, 0       
        JNE GETHIGHORDERNDIGITS
    
    ELEVADO: ;VERIFICA QUAL É A POTENCIA DE 10 MAIS ADEQUADA PARA O PASSO SEGUINTE
        MOV AX, 10
        MUL AX
        MOV CX, NDIGITSHIGHORDER
        DEC NDIGITSHIGHORDER
        CMP CX, 0
        JNE ELEVADO

    
    CONCATHIGHORDERRAIZ:   ;CONCATENA O PROXIMO HIGHORDER AO HIGHORDER ATUAL
        MOV BX, HIGHORDER1
        MUL BX
        ADD AX, HIGHORDER2 
        MOV HIGHORDER1, AX 
        
    OPER1: ;OPERACAO (2*I*10)
        MOV AX,I
        MOV BX, 2
        MUL BX
        MOV BX, 10
        MUL BX
        MOV AUX, AX
    
    DESCOBREJ:  ;DESCOBRE O J MAIOR DO QUE O NECESSARIO PARA A PROXIMA OPERACAO
        INC J
        MOV BX, J
        MOV AX, AUX
        ADD AX, BX
        MUL BX
        MOV BX, HIGHORDER1
        CMP AX, BX
        JG DECREMENTAJ
        JLE DESCOBREJ
    
    DECREMENTAJ: ;DECREMENTA J PARA O VALOR NECESSARIO
        DEC J
    
    OPER2: ; ADICIONA J À VARIAVEL "AUX" E MULTIPLICA POR J O RESULTADO EM AX.
        MOV AX,AUX
        MOV BX, J
        ADD AX, J
        MUL J
        MOV AUX,AX
        
    SUBTRACAO2:
        MOV AX, HIGHORDER1
        MOV BX, AUX
        SUB AX, BX
        MOV HIGHORDER1, AX
    
    CONCATI: ;CONCATENA O I AO I ANTERIOR
        MOV AX, I
        MOV BX, 10
        MUL BX     
        ADD AX, J
        MOV I, AX
        
        MOV BX, ARRAYPOSATUAL
        ADD BX, 1
        CMP radicandoArray[BX],10        
        JNE GETNEXTHIGHORDERPAIR
        JE FINALRESULT1
    
    FINALRESULT1: ;MOSTRA O RESULTADO FINAL
        MOV RESULTFINAL,0
        MOV AX,I
        MOV RESULTFINAL, AX 
    
    MOV ARRAYPOS,0
    MOV BX, ARRAYPOS
    CMP radicandoArray[BX],0
    JE FINAL   
             
    FINAL:
    RET
ENDP
    
    
MAIN PROC
    MOV DX, @DATA           ; Variaveis
    MOV DS, DX
                             
    
    CALL CLEARSCREEN
    
    CALL showMainScreen                           
ENDP
END MAIN                                                    

