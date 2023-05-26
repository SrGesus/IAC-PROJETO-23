; *****************************************************************************
; * IST-UL
; * IAC - Projeto Beyond Mars
; * Grupo 25:
; * - Joao Miguel Figueiredo Barros               106063
; * - Guilherme Vaz Rocha                         106171
; * - Gabriel dos Reis Fonseca Castelo Ferreira   107030
; *****************************************************************************
;
; *****************************************************************************
; * Constantes
; *****************************************************************************
  DISPLAYS  EQU 0A000H
  TEC_LIN   EQU 0C000H
  TEC_COL   EQU 0E000H
  LINHA     EQU 01111H    ; Vai rodar entre 1111H-2222H-4444H-8888H-1111H
  MASCARA   EQU 0FH

  LINHA_PAINEL    EQU 27  ; linha onde se encontra o painel
  COLUNA_PAINEL   EQU 25  ; coluna onde se encontra o painel

  LINHA_SONDA     EQU 26  ; linha inicial da sonda
  COLUNA_SONDA    EQU 32  ; linha inicial da sonda

  COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

  SEL_ECRÃ        EQU COMANDOS + 04H  ; endereço do comando para selecionar ecrã
  MOSTRA_ECRÃ     EQU COMANDOS + 06H  ; endereço do comando para mostrar ecrã
  DEFINE_LINHA    EQU COMANDOS + 0AH	; endereço do comando para definir a linha
  DEFINE_COLUNA   EQU COMANDOS + 0CH	; endereço do comando para definir a coluna
  DEFINE_PIXEL    EQU COMANDOS + 12H	; endereço do comando para escrever um pixel
  APAGA_AVISO     EQU COMANDOS + 40H	; endereço do comando para apagar o aviso de nenhum cenário selecionado
  APAGA_ECRÃ	 		EQU COMANDOS + 02H	; endereço do comando para apagar todos os pixels já desenhados
  SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
  TOCA_SOM				EQU COMANDOS + 5AH		  ; endereço do comando para tocar um som




; *****************************************************************************
; * Alocação da Stack
; * Reservados 512 bytes (100H words)
; *****************************************************************************
  PLACE 1000H
pilha:
  STACK 100H
SP_inicial:



; *****************************************************************************
; * Variáveis
; *****************************************************************************

    ; *************************************************************************
    ; * Rotinas correspondentes a cada tecla
    ; *************************************************************************
LISTA_ROTINAS:
  WORD faz_nada           ; Tecla 0
  WORD move_sonda         ; Tecla 1
  WORD faz_nada           ; Tecla 2
  WORD incrementa_display ; Tecla 3
  WORD faz_nada           ; Tecla 4
  WORD move_asteroide     ; Tecla 5
  WORD faz_nada           ; Tecla 6
  WORD decrementa_display ; Tecla 7
  WORD faz_nada           ; Tecla 8
  WORD faz_nada           ; Tecla 9
  WORD faz_nada           ; Tecla A
  WORD faz_nada           ; Tecla B
  WORD faz_nada           ; Tecla C
  WORD faz_nada           ; Tecla D
  WORD faz_nada           ; Tecla E
  WORD faz_nada           ; Tecla F



    ; *************************************************************************
    ; * Bonecos
    ; *************************************************************************
ASTEROIDE_BONECO:
  WORD 5    ; Largura boneco
  WORD 5    ;  Altura boneco

  WORD 0,      0F777H, 0FBBBH, 0F999H, 0
  WORD 0F999H, 0FBBBH, 0FBBBH, 0FBBBH, 0F999H
  WORD 0F999H, 0F777H, 0FBBBH, 0F999H, 0F777H
  WORD 0FBBBH, 0FBBBH, 0F999H, 0F999H, 0F777H
  WORD 0,      0FBBBH, 0F777H, 0F777H, 0

ASTEROIDE_MINERAVEL_BONECO:
  WORD 5    ; Largura boneco
  WORD 5    ;  Altura boneco

  WORD 0,      0A9DEH, 0FBBBH, 0F999H, 0
  WORD 0F999H, 0FBBBH, 0FBBBH, 0A9DEH, 0A9DEH
  WORD 0A9DEH, 0A9DEH, 0FBBBH, 0F999H, 0A9DEH
  WORD 0FBBBH, 0FBBBH, 0F999H, 0A9DEH, 0F777H
  WORD 0,      0FBBBH, 0A9DEH, 0F777H, 0

ASTEROID_0:
  WORD 0000H, 0000H         ; Posição: Primeira word é linha, segundo coluna
  WORD 0001H, 0001H         ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

SONDA_BONECO:
  WORD 1
  WORD 1

  WORD 0FF00H

SONDA_OBJETO:
  WORD LINHA_SONDA, COLUNA_SONDA  ; Posição: Primeiro word é linha, segundo coluna
  WORD 0FFFFH, 0000H                ; Direção do movimento
  WORD SONDA_BONECO               ; Boneco

PAINEL_BONECO:
  WORD 15   ; Largura painel
  WORD 5    ; Altura painel
  WORD 0A29FH, 0A29FH, 0A9DEH, 0A29FH, 0A29FH , 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A0BEH , 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A8C4H, 0A2B4H, 0ACD3H, 0A29FH
  WORD 0A9DEH, 0A9DEH, 0A0BEH, 0A9DEH, 0A9DEH , 0A0BEH, 0ABBBH, 0A0BEH, 0ABBBH, 0ABBBH, 0ABBBH, 0AF80H, 0AFF0H, 0A2B4H, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A0BEH , 0A0BEH, 0ABBBH, 0A0BEH, 0A0BEH, 0ABBBH, 0A0BEH, 0A2B4H, 0AD22H, 0A8C4H, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A9DEH , 0A9DEH, 0A46FH, 0A9DEH, 0A46FH, 0A46FH, 0A46FH, 0A9DEH, 0A9DEH, 0A9DEH, 0A29FH

PAINEL_OBJETO:
  WORD LINHA_PAINEL, COLUNA_PAINEL
  WORD 0000H, 0000H
  WORD PAINEL_BONECO


; *****************************************************************************
; * Inicializações dos Registos e Stack Pointer
; *****************************************************************************
  PLACE 0000H

inicio:
  MOV SP, SP_inicial

  MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
  MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
  MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo

  MOV  R2, TEC_LIN   ; endereço do periférico das linhas
  MOV  R3, TEC_COL   ; endereço do periférico das colunas
  MOV  R4, DISPLAYS  ; endereço do periférico dos displays
  MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
  MOV  R6, 0000H     ; reseta o valor do display para 0
  MOV  [R4], R0      ; Escreve 0 no display

  CALL desenha_objetos_iniciais


; *****************************************************************************
; * Lê o teclado em ciclo e executa as rotinas para cada tecla
; *****************************************************************************
ler_teclado:
  MOV   R1, LINHA ; Linha toma valor inicial 1111H
  MOV   R0, 0

espera_tecla:
  ROL   R1, 1         ; Roda o valor da linha representado pelo least significant nibble
  MOVB  [R2], R1      ; Escreve no periférico das linhas do teclado
  MOVB  R0, [R3]      ; lê para R0 a coluna
  AND   R0, R5        ; descarta todos bits exceto 0-3
  CMP   R0, 0         ; nenhuma tecla premida é coluna = 0
  JZ    espera_tecla  ; se nenhuma tecla for premida continuar ciclo

  CALL valor_teclado
  CALL executa_comando

ha_tecla: ; Ciclo enquanto a tecla estiver a ser premida
  MOVB  [R2], R1      ; Escreve no periférico das linhas do teclado
  MOVB  R0, [R3]      ; lê para R0 a coluna
  AND   R0, R5        ; descarta todos bits exceto 0-3
  CMP   R0, 0         ; nenhuma tecla premida é coluna = 0
  JNZ   ha_tecla      ; se tecla ainda estiver premida continuar ciclo
  JMP   ler_teclado   ; se não, voltar a ler todas as linhas

; *****************************************************************************
; * VALOR_TECLADO - Rotina para converter linha e coluna para valor 
; *   0H até FH sem loops
; * Argumentos:
; *   R0: Valor da coluna e Registo de retorno do valor
; *   R1: Valor da linha
; *****************************************************************************
valor_teclado:
  PUSH  R1      ; guarda o valor do R1
  PUSH  R2      ; guarda o valor do R2

  AND   R1, R5  ; descarta todos bits exceto 0-3

  ; Converter o nibble linha 1-2-4-8 para 0-1-2-3
  SHR   R1, 1
  MOV   R2, R1
  SHR   R2, 2
  SUB   R1, R2
  ; mesmo processo para coluna
  SHR   R0, 1
  MOV   R2, R0
  SHR   R2, 2
  SUB   R0, R2

  SHL   R1, 2     ; Multiplica linha por 4
  ADD   R0, R1    ; 4*linha + coluna = valor

  POP   R2      ; R2 volta a tomar valor anterior
  POP   R1      ; R1 volta a tomar valor anterior
  RET

; *****************************************************************************
; * EXECUTA_COMANDO - Rotina que executa o commando correspondente a cada tecla
; * Argumentos: 
; *   R0: Valor da tecla na gama 0000H-000FH (Valor é consumido)
; *****************************************************************************
executa_comando:
  PUSH R1
  
  MOV  R1, LISTA_ROTINAS
  SHL  R0, 1    ; multiplica por 2, porque uma word é 2 bytes
  ADD  R1, R0   ; salta para o comando corresponde 
  MOV  R0, [R1] ; 
  CALL R0       ; call lista_rotinas[valor]
  
  POP R1
  RET


; *****************************************************************************
; * Rotina que não faz nada para quando tecla não corresponde a nenhuma ação
; *****************************************************************************
faz_nada:
  RET

; *****************************************************************************
; * INCREMENTA_DISPLAY - Incrementa o Display por um valor
; * Argumentos:
; *   R0: Valor é consumido
; *   R1: Valor é consumido
; *   R4: Endereço do display
; *   R6: Valor do display
; *****************************************************************************
incrementa_display:
  ADD R6, 1
  MOV R0, 10  ; Escolhe base 10
  CALL escreve_display
  RET

; *****************************************************************************
; * DECREMENTA_DISPLAY - Decrementa o Display por um valor
; * Argumentos:
; *   R0: Valor é consumido
; *   R1: Valor é consumido
; *   R4: Endereço do display
; *   R6: Valor do display
; *****************************************************************************
decrementa_display:
  SUB R6, 1
  MOV R0, 10  ; Escolhe base 10
  CALL escreve_display
  RET

; *****************************************************************************
; * ESCREVE_DISPLAY - Transforma valor Hex noutra base (de 1 a 16), num limite 
; *   de 3 dígitos para base 10 é válido de 0 a 999 (0H a 3E7H) 
; *   e representa-o no display.
; * Argumentos:
; *   R0: Base (Denominador das divisões)
; *   R1: Valor é consumido
; *   R4: Endereço do display
; *   R6: Valor do display
; *****************************************************************************
escreve_display:
  PUSH R6
  PUSH R2

converte_decimal: ; converte o número no display num número decimal
  MOV R1, R6

  MOD   R1, R0    ; unidades em base 10
  DIV   R6, R0

  MOV R2, R6
  
  MOD   R2, R0    ; dezenas em base 10
  DIV   R6, R0    ; o resto vai para as centenas
  
  SHL   R6, 4     ; R6 <- 0000
  OR    R6, R2    ; R6 R2 

  SHL   R6, 4     ; R6 R2 0000
  OR    R6, R1    ; R6 R2 R1

  MOV   [R4], R6  ; escreve valor decimal no display

  POP R2
  POP R6
  RET

; *****************************************************************************
; * MOVE_SONDA - Move, apaga, e desenha a sonda 
; *****************************************************************************
move_sonda:
  PUSH R3

  MOV  R3, SONDA_OBJETO
  CALL move_objeto

  POP  R3
  RET

; *****************************************************************************
; * DESENHA_OBJETO - desenha um objeto
; * Argumentos:
; *   R3: Tabela do objeto
; *****************************************************************************
desenha_objeto:
  PUSH  R0
  PUSH  R1
  PUSH  R3
  PUSH  R4

  MOV   R0, [R3]  ; R0 <- Linha inicial do objeto (Word)
  ADD   R3, 2     ; próxima word
  MOV   R1, [R3]  ; R1 <- Coluna inicial do objeto (Word)
  ADD   R3, 6     ; salta 3 words
  MOV   R4, [R3]  ; R4 <- endereço do boneco do asteroide (Word)
  CALL  desenha_boneco

  POP   R4
  POP   R3
  POP   R1
  POP   R0
  RET

; *****************************************************************************
; * DESENHA_OBJETOS_INICIAIS - desenha o painel da nave, a sonda, e o
; * asteroide na sua posição inicial.
; *****************************************************************************
  desenha_objetos_iniciais:
  PUSH  R3

  MOV   R3, 0
  MOV   [SEL_ECRÃ], R3
  MOV   R3, PAINEL_OBJETO
  CALL  desenha_objeto
  MOV   R3, 1
  MOV   [SEL_ECRÃ], R3
  MOV   R3, 0
  MOV   [MOSTRA_ECRÃ], R3
  MOV   R3, SONDA_OBJETO
  CALL  desenha_objeto
  MOV   R3, ASTEROID_0
  CALL  desenha_objeto

  POP   R3
  RET

; *****************************************************************************
; * MOVE_ASTEROIDE - Move e desenha os asteroides
; *****************************************************************************
move_asteroide:
  PUSH  R3

  MOV   R3, 0           ; som número 0
  MOV   [TOCA_SOM], R3  ; comando para tocar o som
  MOV   R3, ASTEROID_0  ; R3 <- endereço do asteroide inicial (Temp)
  CALL  move_objeto

  POP   R3
  RET
; *****************************************************************************
; * MOVE_OBJETO - Apaga, move, e desenha um objeto representado 
; *   por uma determinada tabela.
; * Argumentos:
; *   R3 - Objeto
; *****************************************************************************
move_objeto:
  PUSH  R0
  PUSH  R1
  PUSH  R2
  PUSH  R3
  PUSH  R4
  PUSH  R5

  MOV   R0, [R3]  ; R0 <- Linha inicial do objeto (Word)
  ADD   R3, 2     ; próxima word
  MOV   R1, [R3]  ; R1 <- Coluna inicial do objeto (Word)
  ADD   R3, 2     ; próxima word
  MOV   R2, [R3]  ; Direção de movimento vertical (Word)
  ADD   R3, 2     ; próxima word
  MOV   R5, [R3]  ; Direção de movimento horizontal (Word)

  ADD   R3, 2     ; próxima word
  MOV   R4, [R3]  ; R4 <- endereço do boneco do asteroide (Word)

  CALL  apaga_boneco
 
  ADD   R0, R2    ; Adiciona direção vertical (cima, baixo)
  ADD   R1, R5    ; Adiciona direção horizontal (esquerda, direita, nenhuma)

  SUB   R3, 6     ; Endereço da coluna
  MOV  [R3], R1
  SUB   R3, 2     ; Endereço da linha
  MOV  [R3], R0
  
  CALL desenha_boneco

  POP  R5
  POP  R4
  POP  R3
  POP  R2
  POP  R1
  POP  R0
  RET

; *****************************************************************************
; * DESENHA_BONECO - Desenha um boneco na sua linha e coluna
;	*   com a forma e cor definidas na tabela.
; * Argumentos:
; *   R0 - Linha (Valor é consumido)
; *   R1 - Coluna (Valor é consumido)
; *   R4 - Tabela que define o boneco
; *****************************************************************************
desenha_boneco:
	PUSH	R2  
	PUSH	R4  
	PUSH	R5  
  PUSH  R6  
  PUSH  R7

  MOV   R6, [R4]  ; guarda a largura do boneco
	ADD	  R4, 2			; endereço da altura do boneco (2 porque a largura é uma word)
	MOV   R7, [R4]  ; obtem a altura do boneco
  ADD	  R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
  ADD   R1, R6
proxima_linha:
	MOV	  R5, R6    ; obtém a largura do boneco
  SUB   R1, R5    ; reseta a coluna 
desenha_linha:    ; desenha uma linha de pixels do boneco a partir da tabela
	MOV	  R2, [R4]	; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel
	ADD	  R4, 2		  ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
  ADD   R1, 1     ; próxima coluna
  SUB   R5, 1  	  ; menos uma coluna para tratar
  JNZ   desenha_linha   ; continua até percorrer toda a largura da linha
  ADD   R0, 1     ; próxima linha
  SUB   R7, 1     ; menos uma linha para tratar	
  JNZ   proxima_linha

  POP   R7 
  POP   R6 
  POP   R5 
  POP   R4 
  POP   R2
  RET

; *****************************************************************************
; * APAGA_BONECO - Desenha um boneco na sua linha e coluna
;	*   com a forma e cor definidas na tabela.
; * Argumentos:
; *   R0 - Linha
; *   R1 - Coluna
; *   R4 - Tabela que define o boneco
; *****************************************************************************
apaga_boneco:
  PUSH  R0
  PUSH  R1
	PUSH	R2
	PUSH	R4
	PUSH	R5
  PUSH  R6
  PUSH  R7
  

  MOV   R6, [R4]  ; guarda a largura do boneco (Para alterar R5 e R4 livremente)
	ADD	  R4, 2			; endereço da altura do boneco (2 porque a largura é uma word)
	MOV   R7, [R4]  ; obtem a altura do boneco
  ADD   R1, R6    ; 
apaga_proxima_linha:
	MOV	  R5, R6    ; obtém a largura do boneco
  SUB   R1, R5    ; reseta a coluna 
apaga_linha:      ; desenha uma linha de pixels do boneco a partir da tabela
	MOV	  R2, 0	    ; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
  ADD   R1, 1     ; próxima coluna
  SUB   R5, 1  	  ; menos uma coluna para tratar
  JNZ   apaga_linha      ; continua até percorrer toda a largura da linha
  ADD   R0, 1     ; próxima linha
  SUB   R7, 1     ; menos uma linha para tratar	
  JNZ   apaga_proxima_linha

  POP   R7
  POP   R6
  POP   R5
  POP   R4
  POP   R2
  POP   R1
  POP   R0
  RET



; *****************************************************************************
; * ESCREVE_PIXEL - Escreve pixel na linha e coluna dos argumentos 
; * Argumentos:
; *   R0 - linha
; *   R1 - coluna
; *   R2 - Cor do Pixel
; *****************************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R0		; seleciona a linha
	MOV  [DEFINE_COLUNA], R1	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R2		; altera a cor do pixel na linha e coluna já selecionadas
	RET