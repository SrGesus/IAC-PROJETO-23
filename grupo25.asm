; *****************************************************************************
; * IST-UL
; * IAC - Projeto Beyond Mars
; * Grupo 25:
; * IAC - Projeto Beyond Mars
; * Grupo 25:
; * - Joao Miguel Figueiredo Barros               106063- Joao Miguel Figueiredo Barros               106063
; * - Guilherme Vaz Rocha                         106171 - Guilherme Vaz Rocha                         106171
; * - Gabriel dos Reis Fonseca Castelo Ferreira   107030 - Gabriel dos Reis Fonseca Castelo Ferreira   107030
; *****************************************************************************
;
; *****************************************************************************
; * Constantes
; *****************************************************************************
  DISPLAYS        EQU 0A000H    ; endereço do periférico dos Displays
  TEC_LIN         EQU 0C000H    ; endereço do periférico do PIN (linhas teclado)
  TEC_COL         EQU 0E000H    ; endereço do periférico do POUT-2 (colunas teclado)
  LINHA           EQU 01111H    ; Vai rodar entre 1111H-2222H-4444H-8888H-1111H
  MASCARA         EQU 0000FH    ; Máscara bits 0-3

  LINHA_PAINEL    EQU 27  ; linha onde se encontra o painel
  COLUNA_PAINEL   EQU 25  ; coluna onde se encontra o painel

  ECRÃ_PAINEL     EQU 0
  ECRÃ_ASTEROIDES EQU 1
  ECRÃ_SONDAS     EQU 2

  LINHA_SONDA     EQU 27  ; linha inicial da sonda
  LIMITE_SONDA    EQU 38  ; linha final   da sonda
  COLUNA_SONDA    EQU 32  ; linha inicial da sonda

  LIMITE_ESQUERDO EQU 0   ; limite esquerdo dos objetos
  LIMITE_DIREITO  EQU 81  ; limite direito dos objetos
  LIMITE_SUPERIOR EQU 0   ; limite superior dos objetos
  LIMITE_INFERIOR EQU 63  ; limite inferior dos objetos

  COMANDOS				EQU	6000H	  ; endereço de base dos comandos do MediaCenter
  SEL_ECRÃ        EQU COMANDOS + 04H  ; endereço do comando para selecionar ecrã
  MOSTRA_ECRÃ     EQU COMANDOS + 06H  ; endereço do comando para mostrar ecrã
  DEFINE_LINHA    EQU COMANDOS + 0AH	; endereço do comando para definir a linha
  DEFINE_COLUNA   EQU COMANDOS + 0CH	; endereço do comando para definir a coluna
  DEFINE_PIXEL    EQU COMANDOS + 12H	; endereço do comando para escrever um pixel
  APAGA_AVISO     EQU COMANDOS + 40H	; endereço do comando para apagar o aviso de nenhum cenário selecionado
  APAGA_ECRÃ	 		EQU COMANDOS + 00H	; endereço do comando para apagar um dado ecrã
  APAGA_ECRÃS	 		EQU COMANDOS + 02H	; endereço do comando para apagar todos os pixels já desenhados
  SEL_CEN_FUNDO   EQU COMANDOS + 42H	; endereço do comando para selecionar uma imagem de fundo
  TOCA_SOM				EQU COMANDOS + 5AH	; endereço do comando para tocar um som


; *****************************************************************************
; * Alocação da Stacks
; * Reservados 512 bytes (100H words)
; *****************************************************************************
  PLACE 1000H

  STACK 100H  ; Stack do processo principal
SP_inicial:

  STACK 100H  ; Stack do processo do varrimento do teclado
SP_teclado:

  STACK 100H  ; Stack do processo de executar comandos
SP_control:

  STACK 100H  ; Stack do processo que desenha o ecrã
SP_gráficos:

; *****************************************************************************
; * Variáveis
; *****************************************************************************

tecla_premida:
  LOCK 0  ; Valor correspondente à tecla premida de 0H a FH

atualiza_ecrã:
  LOCK 0  ; Valor irrelevante

atualiza_painel:
  WORD 0  ; Valor == 0 causa o painel a ser redesenhado
atualiza_sondas:
  WORD 0  ; Valor == 0 causa as sondas a ser redesenhadas
atualiza_asteroides:
  WORD 0  ; Valor == 0 causa os asteroides a ser redesenhados

    ; *************************************************************************
    ; * Rotinas correspondentes a cada tecla
    ; *************************************************************************
LISTA_ROTINAS:
  WORD LISTA_ROTINAS_JOGO ; Lista rotinas default

LISTA_ROTINAS_JOGO:
  WORD faz_nada           ; Tecla 0
  WORD move_sonda         ; Tecla 1
  WORD faz_nada           ; Tecla 2
  WORD faz_nada           ; Tecla 3
  WORD faz_nada           ; Tecla 4
  WORD move_asteroide     ; Tecla 5
  WORD faz_nada           ; Tecla 6
  WORD faz_nada           ; Tecla 7
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

SONDA_BONECO:
  WORD 1
  WORD 1

  WORD 0FF00H

PAINEL_BONECO:
  WORD 15   ; Largura painel
  WORD 5    ; Altura painel
  WORD 0A29FH, 0A29FH, 0A9DEH, 0A29FH, 0A29FH , 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A0BEH , 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A8C4H, 0A2B4H, 0ACD3H, 0A29FH
  WORD 0A9DEH, 0A9DEH, 0A0BEH, 0A9DEH, 0A9DEH , 0A0BEH, 0ABBBH, 0A0BEH, 0ABBBH, 0ABBBH, 0ABBBH, 0AF80H, 0AFF0H, 0A2B4H, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A0BEH , 0A0BEH, 0ABBBH, 0A0BEH, 0A0BEH, 0ABBBH, 0A0BEH, 0A2B4H, 0AD22H, 0A8C4H, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A9DEH , 0A9DEH, 0A46FH, 0A9DEH, 0A46FH, 0A46FH, 0A46FH, 0A9DEH, 0A9DEH, 0A9DEH, 0A29FH

    ; *************************************************************************
    ; * Objetos
    ; *************************************************************************


  WORD 1    ; Estado de Ativação do Asteroid_0
ASTEROID_0:
  WORD 0000H, 0000H     ; Posição: Primeira word é linha, segundo coluna
  WORD 0001H, 0001H     ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

  WORD 0    ; Estado de Ativação do Asteroid_1
ASTEROID_1:
  WORD 0000H, 0000H     ; Posição: Primeira word é linha, segundo coluna
  WORD 0001H, 0001H     ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

  WORD 0    ; Estado de Ativação do Asteroid_2
ASTEROID_2:
  WORD 0000H, 0000H     ; Posição: Primeira word é linha, segundo coluna
  WORD 0001H, 0001H     ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

  WORD 0  ; Estado de Ativação do Asteroid_3
ASTEROID_3:
  WORD 0000H, 0000H     ; Posição: Primeira word é linha, segundo coluna
  WORD 0001H, 0001H     ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

  WORD 1  ; Estado de Ativação da Sonda_0
SONDA_0:  ; Sonda diagonal-esquerda
  WORD LINHA_SONDA, COLUNA_SONDA-6  ; Posição: Primeiro word é linha, segundo coluna
  WORD -1, -1                       ; Direção do movimento
  WORD SONDA_BONECO                 ; Boneco

  WORD 0    ; Estado de Ativação da Sonda_1
SONDA_1:    ; Sonda vertical-cima
  WORD LINHA_SONDA, COLUNA_SONDA  ; Posição: Primeiro word é linha, segundo coluna
  WORD -1, 0                      ; Direção do movimento
  WORD SONDA_BONECO               ; Boneco

  WORD 0    ; Estado de Ativação da Sonda_2
SONDA_2:    ; Sonda diagonal-direita
  WORD LINHA_SONDA, COLUNA_SONDA+6  ; Posição: Primeiro word é linha, segundo coluna
  WORD -1, 1                        ; Direção do movimento
  WORD SONDA_BONECO                 ; Boneco

PAINEL_OBJETO:
  WORD LINHA_PAINEL, COLUNA_PAINEL
  WORD 0000H, 0000H
  WORD PAINEL_BONECO

    ; *************************************************************************
    ; * Listas de objetos
    ; *************************************************************************

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
  MOV [R4], R0       ; Escreve 0 no display

; *****************************************************************************
; * PROCESSO
; * TECLADO - Processo varre o teclado em ciclo para a variável tecla_premida
; *   e faz yield em cada ciclo.
; *****************************************************************************
PROCESS SP_teclado
teclado:
  MOV   R0, 0         ; Registo da coluna/tecla premida
  MOV   R1, LINHA     ; Linha toma valor inicial 1111H
  MOV   R2, TEC_LIN   ; endereço do periférico das  linhas do teclado
  MOV   R3, TEC_COL   ; endereço do periférico das colunas do teclado
  MOV   R4, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

espera_tecla: ; Ciclo enquanto a tecla NÃO estiver a ser premida
  WAIT        ; Adormece quando os outros processos estão bloqueados e não há teclas/interrupções ativas
  ROL   R1,   1       ; Roda o valor da linha (representado pelo least significant nibble)
  MOVB  [R2], R1      ; Escreve no periférico das linhas do teclado
  MOVB  R0,   [R3]    ; lê para R0 a coluna
  AND   R0,   R4      ; descarta todos bits exceto 0-3
  CMP   R0,   0       ; nenhuma tecla premida é coluna = 0
  JZ    espera_tecla  ; se nenhuma tecla for premida continuar ciclo

  CALL valor_teclado  ; R0 <- Valor da tecla
  MOV [tecla_premida], R0 ; Escreve na var LOCK tecla_premida

ha_tecla: ; Ciclo enquanto a tecla estiver a ser premida
  YIELD   ; Há uma tecla premida então nunca vai adormecer (logo não usar WAIT)
  MOVB  [R2], R1      ; Escreve no periférico das linhas do teclado
  MOVB  R0,   [R3]    ; lê para R0 a coluna
  AND   R0,   R4      ; descarta todos bits exceto 0-3
  CMP   R0,   0       ; nenhuma tecla premida é coluna = 0
  JNZ   ha_tecla      ; se tecla ainda estiver premida continuar ciclo
  JMP   espera_tecla  ; se não, voltar a ler todas as linhas

; *****************************************************************************
; * VALOR_TECLADO - Rotina para converter linha e coluna para valor 
; *   0H até FH sem loops
; * Argumentos:
; *   R0: Valor da coluna (Valor é consumido)
; *   R1: Valor da linha
; *   R5: Valor é consumido
; * Retorno:
; *   R0: Valor da tecla premida (0H a FH)
; *****************************************************************************
valor_teclado:
  PUSH  R1      ; guarda o valor do R1
  PUSH  R2      ; guarda o valor do R2

  AND   R1, R4  ; descarta todos bits exceto 0-3

  ; Converter o nibble linha 1-2-4-8 para 0-1-2-3
  SHR   R1, 1
  MOV   R5, R1
  SHR   R5, 2
  SUB   R1, R5
  ; mesmo processo para coluna
  SHR   R0, 1
  MOV   R5, R0
  SHR   R5, 2
  SUB   R0, R5

  SHL   R1, 2   ; Multiplica linha por 4
  ADD   R0, R1  ; 4*linha + coluna = valor

  POP   R2      ; R2 volta a tomar valor anterior
  POP   R1      ; R1 volta a tomar valor anterior
  RET


; *****************************************************************************
; * PROCESSO
; * CONTROL - Processo que executa o commando correspondente a cada tecla
; *****************************************************************************
PROCESS SP_control
control:
  MOV   R0, [tecla_premida] ; lê LOCK (bloqueia), espera por tecla 
  MOV   R1, [LISTA_ROTINAS] ; Seleciona a lista de rotinas adequada

  SHL   R0, 1    ; multiplica por 2, porque uma word é 2 bytes
  ADD   R1, R0   ; salta para o comando corresponde 
  MOV   R0, [R1] ; 
  CALL  R0       ; call lista_rotinas[valor]

  JMP   control

; *****************************************************************************
; * Rotina que não faz nada para quando tecla não corresponde a nenhuma ação
; *****************************************************************************
faz_nada:
  RET

faz_nada_RFE:
  RFE

; *****************************************************************************
; * INCREMENTA_DISPLAY - Incrementa o Display por um valor
; * Argumentos:
; *   R0, R1: Valor é consumido
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
; *   R0, R1: Valor é consumido
; *   R4: Endereço do display
; *   R6: Valor do display
; *****************************************************************************
decrementa_display:
  SUB R6, 1
  MOV R0, 10
  CALL escreve_display
  CMP R6, 3
  RFE
; *****************************************************************************
; * ECRÃ_SEM_ENERGIA - Decrementa o Display em 3 valores
; * Argumentos:
; *****************************************************************************
ecrã_sem_energia:
  PUSH R1
  MOV R1, 1
  MOV R6, 0
  MOV [DISPLAYS], R6
  MOV [SEL_CEN_FUNDO], R1
  POP R1
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
  MOV   R1,   R6

  MOD   R1,   R0  ; unidades em base 10 no nibble low
  DIV   R6,   R0  ; Remove unidades

  MOV   R2,   R6  ; R2 <- Valor sem unidades
  MOD   R2,   R0  ; dezenas em base 10 no nibble low
  DIV   R6,   R0  ; Remove dezenas
  
  SHL   R6,   4   ; R6 0000
  OR    R6,   R2  ; R6 R2 
  SHL   R6,   4   ; R6 R2 0000
  OR    R6,   R1  ; R6 R2 R1

  MOV   [R4], R6  ; escreve valor decimal no display

  POP R2
  POP R6
  RET

; *****************************************************************************
; * MOVE_SONDA - Move, apaga, e desenha a sonda 
; *****************************************************************************
move_sonda:
  PUSH R3

  MOV   R3, 0
  MOV   [atualiza_ecrã],  R3 ; Escreve para LOCK, desbloqueia processo gráfico
  MOV   [atualiza_sondas], R3 ; Declara sondas como desatualizados (0)

  MOV  R3, SONDA_0
  CALL move_objeto

  POP  R3
  RET

; *****************************************************************************
; * PROCESSO
; * GRÁFICOS - desenha o painel da nave, as sondas, e os
; * asteroides nas suas posições iniciais. Interrupções desativadas no processo.
; *****************************************************************************
PROCESS SP_gráficos
gráficos:
  MOV   R3, [atualiza_ecrã] ; LOCK até ecrã necessitar atualização

gráficos_painel:
  MOV   R3, [atualiza_painel]
  CMP   R3, 0
  JNZ   gráficos_asteroides  ; if(atualiza_painel == 0) desenha_painel();
  CALL  desenha_painel

gráficos_asteroides:
  MOV   R3, [atualiza_asteroides]
  CMP   R3, 0
  JNZ   gráficos_sondas      ; if(atualiza_asteroides == 0) desenha_asteroides();
  CALL  desenha_asteroides

gráficos_sondas:
  MOV   R3, [atualiza_sondas]
  CMP   R3, 0
  JNZ   gráficos             ; if(atualiza_sondas == 0) desenha_sondas();
  CALL  desenha_sondas

  JMP   gráficos

; *****************************************************************************
; * DESENHA_PAINEL - desenha o objeto painel no ecrã 0
; *****************************************************************************
desenha_painel:
  MOV   R3,           ECRÃ_PAINEL
  MOV   [SEL_ECRÃ],   R3          ; Seleciona ecrã 0
  MOV   [APAGA_ECRÃ], R3          ; Apaga todos os pixéis neste ecrã

  MOV   R3, PAINEL_OBJETO
  CALL  desenha_objeto

  MOV   [atualiza_painel], R3 ; R3 é sempre != de 0, logo marca painel como atualizado
  RET

; *****************************************************************************
; * DESENHA_ASTEROIDES - desenha todos os asteroides no ecrã 1
; *****************************************************************************
desenha_asteroides:
  MOV   R3,           ECRÃ_ASTEROIDES 
  MOV   [SEL_ECRÃ],   R3              ; Seleciona ecrã 1
  MOV   [APAGA_ECRÃ], R3              ; Apaga todos os pixéis neste ecrã

  MOV   R3, ASTEROID_0
  CALL  desenha_objeto

  MOV   [atualiza_painel], R3 ; R3 é sempre != de 0, logo marca asteroides como atualizados
  RET

; *****************************************************************************
; * DESENHA_SONDAS - desenha todas as sondas no ecrã 2
; *****************************************************************************
desenha_sondas:
  MOV   R3,           ECRÃ_SONDAS
  MOV   [SEL_ECRÃ],   R3          ; Seleciona ecrã 2
  MOV   [APAGA_ECRÃ], R3          ; Apaga todos os pixéis neste ecrã

  MOV   R3, SONDA_0
  CALL  desenha_objeto

  MOV   [atualiza_painel], R3 ; R3 é sempre != de 0, logo marca sondas como atualizadas
  RET


; *****************************************************************************
; * DESENHA_OBJETO - desenha um objeto
; * Argumentos:
; *   R3: Tabela do objeto
; *   R0, R1, R2, R4, R5, R6, R7: Valores são consumidos
; *****************************************************************************
desenha_objeto:

  MOV   R0, [R3]  ; R0 <- Linha inicial do objeto (Word)
  MOV   R1, [R3+2]  ; R1 <- Coluna inicial do objeto (Word)
  MOV   R4, [R3+8]  ; R4 <- endereço do boneco do asteroide (Word)
  CALL  desenha_boneco

  RET

; *****************************************************************************
; * DESENHA_BONECO - Desenha um boneco na sua linha e coluna
;	*   com a forma e cor definidas na tabela.
; * Argumentos:
; *   R0: Linha (Valor é consumido)
; *   R1: Coluna (Valor é consumido)
; *   R4: Tabela que define o boneco (Valor é consumido)
; *   R2, R5, R6, R7: Valores são consumidos
; *****************************************************************************
desenha_boneco:
  MOV   R6, [R4]  ; guarda a largura do boneco
  ADD   R4, 2			; endereço da altura do boneco (2 porque a largura é uma word)
  MOV   R7, [R4]  ; obtem a altura do boneco
  ADD   R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
  ADD   R1, R6
proxima_linha:
  MOV	  R5, R6    ; obtém a largura do boneco
  SUB   R1, R5    ; reseta a coluna 
desenha_linha:    ; desenha uma linha de pixels do boneco a partir da tabela
  MOV	  R2, [R4]	; obtém a cor do próximo pixel do boneco
  CMP   R2, 0     ; salta este pixel se for completamente transparente
  JZ próximo_pixel
  CALL	escreve_pixel
próximo_pixel:
  ADD	  R4, 2		  ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
  ADD   R1, 1     ; próxima coluna
  SUB   R5, 1  	  ; menos uma coluna para tratar
  JNZ   desenha_linha   ; continua até percorrer toda a largura da linha
  ADD   R0, 1     ; próxima linha
  SUB   R7, 1     ; menos uma linha para tratar	
  JNZ   proxima_linha

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