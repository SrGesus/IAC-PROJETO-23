; *****************************************************************************
; * IST-UL
; * 
; *
; *
; *****************************************************************************
;
; *****************************************************************************
; * Constantes
; *****************************************************************************
  DISPLAYS  EQU 0A000H
  TEC_LIN   EQU 0C000H
  TEC_COL   EQU 0E000H
  LINHA     EQU 01111H  ; Vai rodar entre 1111H-2222H-4444H-8888H-1111H
  MASCARA   EQU 0FH

  LINHA_PAINEL    EQU 27  ; linha onde se encontra o painel
  COLUNA_PAINEL   EQU 25  ; coluna onde se encontra o painel

  LINHA_SONDA     EQU 26
  COLUNA_SONDA    EQU 32
  COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

  DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
  DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
  DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
  APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
  APAGA_ECRÃ	 		EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
  SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
  TOCA_SOM				EQU COMANDOS + 5AH		; endereço do comando para tocar um som




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
  WORD move_objeto        ; Tecla 5
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

  WORD 0FF00H, 0, 0FF00H, 0, 0FF00H
  WORD 0, 0FF00H, 0, 0FF00H, 0
  WORD 0FF00H, 0, 0, 0, 0FF00H
  WORD 0, 0FF00H, 0, 0FF00H, 0
  WORD 0FF00H, 0, 0FF00H, 0, 0FF00H

ASTEROID_0:
  WORD 0000H ; Posição : Primeiro byte é linha, segundo coluna
  WORD 0101H ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco
  ;BYTE  01H, 02H ; Posição : Primeiro byte é linha, segundo coluna
  ;BYTE  01H, 00H ; Direção do movimento (-1 Esquerda, 0 Baixo, 1 Direita)
  ; Segundo byte é padding
  ;WORD  ASTEROIDE_BONECO ; Boneco

PAINEL_NAVE:
  WORD 15   ; Largura painel
  WORD 5    ; Altura painel
  WORD  0C57EH,  0C57EH, 0C57EH, 0C57EH, 0C57EH, 0C57EH, 0C57EH, 0C57EH, 0C57EH, 0A57FH, 0A57FH, 0A57FH, 0A57FH, 0A57FH, 0A57FH
  WORD  0C57EH,  0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0A57FH
  WORD  0C57EH,  0FF00H, 0FF00H, 0FF00H, 0A999H, 0FF00H, 0A999H, 0A999H, 0A999H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0A57FH
  WORD  0C57EH,  0FF00H, 0FF00H, 0FF00H, 0A999H, 0FF00H, 0FF00H, 0A46DH, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0FF00H, 0A57FH
  WORD  0C57EH,  0A9DEH, 0A9DEH, 0A9DEH, 0A46DH, 0A9DEH, 0A46DH, 0A46DH, 0A46DH, 0A9DEH, 0A9DEH, 0A9DEH, 0A9DEH, 0A9DEH, 0A57FH

SONDA:
  WORD 26
  WORD 32
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
  MOV [R4], R0  ; Escreve 0 no display
  MOV R9, LINHA_SONDA

desenha_painel: ;desenha o painel de instrumentos da nave
  PUSH R0 ;guarda o valor de R0
  PUSH R1 ;guarda o valor de R1
  PUSH R4 ;guarda o valor de R4
  MOV R4, PAINEL_NAVE
  MOV R0, LINHA_PAINEL
  MOV R1, COLUNA_PAINEL
  CALL desenha_boneco
  POP R4  ; R4 volta a tomar valor anterior
  POP R1  ; R1 volta a tomar valor anterior
  POP R0  ; R0 volta a tomar valor anterior


; *****************************************************************************
; Lê o teclado em ciclo e executa as rotinas para cada tecla
; *****************************************************************************
ler_teclado:
  MOV R1, LINHA ; Linha toma valor inicial 1111H
  MOV R0, 0

espera_tecla:
  ROL R1, 1     ; Roda o valor da linha representado pelo least significant nibble
  MOVB [R2], R1 ; Escreve no periférico das linhas do teclado
  MOVB R0, [R3] ; lê para R0 a coluna
  AND R0, R5    ; descarta todos bits exceto 0-3
  CMP R0, 0
  JZ espera_tecla ; se nenhuma tecla for premida continuar ciclo
  
  CALL valor_teclado
  CALL executa_comando

ha_tecla: ; Ciclo enquanto a tecla estiver a ser premida
  MOVB [R2], R1 
  MOVB R0, [R3]
  AND R0, R5
  CMP R0, 0
  JNZ ha_tecla
  JMP ler_teclado

; *****************************************************************************
; * VALOR_TECLADO - Rotina para converter linha e coluna para valor 
; *   0H até FH sem loops
; * Argumentos:
; *   R0: Valor da coluna e Registo de retorno do valor
; *   R1: Valor da linha
; *****************************************************************************
valor_teclado:
  PUSH  R1    ; guarda o valor do R1
  PUSH  R2    ; guarda o valor do R2

  AND R1, R5 ; descarta todos bits exceto 0-3

  ; Converter o nibble linha 1-2-4-8 para 0-1-2-3
  SHR R1, 1
  MOV R2, R1
  SHR R2, 2
  SUB R1, R2
  ; mesmo processo para coluna
  SHR R0, 1
  MOV R2, R0
  SHR R2, 2
  SUB R0, R2

  SHL R1, 2   ; Multiplica linha por 4
  ADD R0, R1  ; 4*linha + coluna

  POP   R2    ; R2 volta a tomar valor anterior
  POP   R1    ; R1 volta a tomar valor anterior
  RET



; *****************************************************************************
; * EXECUTA_COMANDO - Rotina que executa o commando correspondente a cada tecla
; * Argumentos: 
; *   R0: Valor da tecla na gama 0000H-000FH (Valor é consumido)
; *****************************************************************************
executa_comando:
  PUSH R1
  
  MOV R1, LISTA_ROTINAS
  SHL R0, 1
  ADD R1, R0
  MOV R0, [R1]
  CALL R0
  
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
  MOV R0, 10
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
  MOV R0, 10
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

converte_decimal:
  MOV R1, R6

  MOD R1, R0 ; unidades em base 10
  DIV R6, R0

  MOV R2, R6
  
  MOD R2, R0 ; dezenas em base 10
  DIV R6, R0 ; o resto vai para as dezenas
  
  SHL R6, 4 ; R6 0000
  OR R6, R2 ; R6 R2 

  SHL R6, 4 ; R6 R2 0000
  OR R6, R1 ; R6 R2 R1

  MOV [R4], R6 ; escreve valor decimal no display

  POP R2
  POP R6
  RET

; *****************************************************************************
; * MOVE_SONDA - Move, apaga, e desenha a sonda 
; * Argumentos:
; *****************************************************************************
move_sonda:
  PUSH R0
  PUSH R1
  PUSH R2
  PUSH R4
  MOV R2, 0
  MOV R1, COLUNA_SONDA
  MOV R0, R9
  CALL escreve_pixel
  SUB R9, 1
  MOV R0, R9
  MOV R2, 0FF00H
  CALL escreve_pixel
  POP R4
  POP R2
  POP R1
  POP R0
  RET
; *****************************************************************************
; * MOVE_OBJETO - Move, apaga, e desenha um objeto representado 
; *   por uma determinada tabela.
; * Argumentos:
; *   R3 - Objeto
; *****************************************************************************
move_objeto:
  PUSH R0
  PUSH R1
  PUSH R3
  PUSH R4
  MOV R8 ,0 ; som número 0
  MOV [TOCA_SOM], R8 ; comando para tocar o som
  MOV R3, ASTEROID_0 ; R3 <- endereço do asteroide inicial

  MOV R0, [R3] ; R0 <- posição do asteroide inicial
  MOV R1, [R3] ; R1 <- posição do asteroide inicial
  SHR R0, 8 ; isola a linha
  SHL R1, 8 ; isola a coluna
  SHR R1, 8 ; mete a coluna no byte à direita
  
  ADD R3, 4 ; R3 <- endereço das características do asteroide
  ; o primeiro sendo a largura 

  MOV R4, [R3] ; R4 <- largura do asteroide

  CALL apaga_boneco
 
  SUB R3, 4

  MOV R0, [R3]
  ADD R3, 2
  
  MOV R1, [R3]
  ADD R0, R1
  SUB R3, 2
  MOV [R3], R0
  MOV R1, R0
  SHR R0, 8
  SHL R1, 8
  SHR R1, 8

  ADD R3, 4
  
 

  CALL desenha_boneco

  POP R4
  POP R3
  POP R1
  POP R0
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
  

  MOV R6, [R4]  ; guarda a largura do boneco
	ADD	R4, 2			; endereço da altura do boneco (2 porque a largura é uma word)
	MOV R7, [R4]  ; obtem a altura do boneco
  ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
  ADD R1, R6
proxima_linha:
	MOV	R5, R6    ; obtém a largura do boneco
  SUB R1, R5    ; reseta a coluna 
desenha_linha:  ; desenha uma linha de pixels do boneco a partir da tabela
	MOV	R2, [R4]	; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2		  ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
  ADD  R1, 1    ; próxima coluna
  SUB  R5, 1  	; menos uma coluna para tratar
  JNZ  desenha_linha      ; continua até percorrer toda a largura da linha
  ADD R0, 1     ; próxima linha
  SUB R7, 1     ; menos uma linha para tratar	
  JNZ proxima_linha

  POP R7
  POP R6
  POP R5
  POP R4
  POP R2
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
	PUSH	R2
	PUSH	R4
	PUSH	R5
  PUSH  R6
  PUSH  R7
  

  MOV R6, [R4]  ; guarda a largura do boneco
	ADD	R4, 2			; endereço da altura do boneco (2 porque a largura é uma word)
	MOV R7, [R4]  ; obtem a altura do boneco
  ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
  ADD R1, R6
apaga_proxima_linha:
	MOV	R5, R6    ; obtém a largura do boneco
  SUB R1, R5    ; reseta a coluna 
apaga_linha:  ; desenha uma linha de pixels do boneco a partir da tabela
	MOV	R2, 0	; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2		  ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
  ADD  R1, 1    ; próxima coluna
  SUB  R5, 1  	; menos uma coluna para tratar
  JNZ  apaga_linha      ; continua até percorrer toda a largura da linha
  ADD R0, 1     ; próxima linha
  SUB R7, 1     ; menos uma linha para tratar	
  JNZ apaga_proxima_linha

  POP R7
  POP R6
  POP R5
  POP R4
  POP R2
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
	MOV  [DEFINE_COLUNA], R1		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R2		; altera a cor do pixel na linha e coluna já selecionadas
	RET