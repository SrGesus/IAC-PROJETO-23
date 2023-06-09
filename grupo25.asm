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
  
  MASCARA         EQU 0000FH    ; Máscara bits 0-3
  TEC_PRIM_LIN    EQU 01111H    ; Vai rodar entre 1111H-2222H-4444H-8888H-1111H
  NULL            EQU 0

  ; Limites do Ecrã de Pixéis Media Center
  LIMITE_ESQUERDO         EQU 0   ; limite esquerdo dos objetos
  LIMITE_DIREITO          EQU 64  ; limite direito dos objetos
  LIMITE_SUPERIOR         EQU 0   ; limite superior dos objetos
  LIMITE_INFERIOR         EQU 32  ; limite inferior dos objetos

  ; Sons
  SOM_SONDA               EQU 0
  SOM_ASTEROIDE           EQU 1
  SOM_ASTEROIDE_MINERAVEL EQU 2
  SOM_GAMEOVER_ENERGIA    EQU 3
  SOM_GAMEOVER_COLISAO    EQU 4
  SOM_BOTAO               EQU 5

  ; Imagens
  FUNDO_PAUSA             EQU 0
  FUNDO_GAMEOVER_ENERGIA  EQU 1
  FUNDO_GAMEOVER_COLISAO  EQU 2
  FUNDO_GAMEOVER          EQU 3
  FUNDO_INICIO            EQU 4
  FUNDO_JOGO              EQU 5

  ; Endereços
  DISPLAYS                EQU 0A000H    ; endereço do periférico dos Displays
  TEC_LIN                 EQU 0C000H    ; endereço do periférico do PIN (linhas teclado)
  TEC_COL                 EQU 0E000H    ; endereço do periférico do POUT-2 (colunas teclado)
  
  ; Endereços Media Center
  COMANDOS				        EQU	6000H	  ; endereço de base dos comandos do MediaCenter
  APAGA_ECRÃ	 		        EQU COMANDOS + 00H	; endereço do comando para apagar um dado ecrã
  APAGA_ECRÃS	 		        EQU COMANDOS + 02H	; endereço do comando para apagar todos os pixels já desenhados
  SEL_ECRÃ                EQU COMANDOS + 04H  ; endereço do comando para selecionar ecrã
  MOSTRA_ECRÃ             EQU COMANDOS + 06H  ; endereço do comando para mostrar ecrã
  DEFINE_LINHA            EQU COMANDOS + 0AH	; endereço do comando para definir a linha
  DEFINE_COLUNA           EQU COMANDOS + 0CH	; endereço do comando para definir a coluna
  DEFINE_PIXEL            EQU COMANDOS + 12H	; endereço do comando para escrever um pixel
  APAGA_AVISO             EQU COMANDOS + 40H	; endereço do comando para apagar o aviso de nenhum cenário selecionado
  SEL_CEN_FUNDO           EQU COMANDOS + 42H	; endereço do comando para selecionar uma imagem de fundo
  APAGA_FRONTAL           EQU COMANDOS + 44H  ; endereço do comando para apagar imagem frontal
  SEL_CEN_FRONTAL         EQU COMANDOS + 46H  ; endereço do comando para selecionar uma imagem frontal
  TOCA_SOM				        EQU COMANDOS + 5AH	; endereço do comando para tocar um som

  ; Painel Nave
  LINHA_PAINEL            EQU 27  ; linha onde se encontra o painel
  COLUNA_PAINEL           EQU 25  ; coluna onde se encontra o painel

  ; Ecrãs
  ECRÃ_PAINEL             EQU 0   ; Ecrã onde está representado o painel
  ECRÃ_ASTEROIDES         EQU 1   ; Ecrã onde está representado os asteroides
  ECRÃ_SONDAS             EQU 2   ; Ecrã onde está representado as sondas

  ; Sonda
  LINHA_SONDA             EQU 27  ; linha inicial da sonda
  LIMITE_SONDA            EQU 13  ; linha final   da sonda
  COLUNA_SONDA            EQU 32  ; linha inicial da sonda

  ; Asteróide
  LARG_ASTEROIDE          EQU 5   ; largura de um asteróide
  ALTU_ASTEROIDE          EQU 5   ; altura de um asteróide
  METADE_ECRÃ             EQU LIMITE_DIREITO/2-LARG_ASTEROIDE/2

  ENERGIA_INICIAL         EQU 100

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

  STACK 100H  ; Stack do processo que escreve no display
SP_display:

; *****************************************************************************
; * Variáveis
; *****************************************************************************

; Variável teclado
tecla_premida:
  LOCK  0 ; Valor correspondente à tecla premida de 0H a FH

; Variáveis display
energia:
  WORD  ENERGIA_INICIAL ; Valor correspondente à energia da nave no display
valor_display:
  LOCK  ENERGIA_INICIAL ; LOCK Valor correspondente à energia da nave no display

; Estado do jogo
estado_jogo:
  WORD 0  ; 1 se estiver a decorrer 0 se não decorrer

; Variáveis gráficos
atualiza_ecrã:
  LOCK  0 ; Valor irrelevante
atualiza_painel:
  WORD  0 ; Valor == 0 causa o painel a ser redesenhado
atualiza_luzes:
  WORD  0 ; Valor == 0 causa as luzes a serem redesenhadas
atualiza_sondas:
  WORD  0 ; Valor == 0 causa as sondas a ser redesenhadas

atualiza_asteroides:
  WORD  0 ; Valor == 0 causa os asteroides a ser redesenhados

    ; *************************************************************************
    ; * Listas
    ; *************************************************************************
; Lista de rotinas em efeito para cada tecla
MAPA_ROTINAS:
  WORD MAPA_ROTINAS_TERMINADO ; Lista rotinas default

; Rotina correspondente a cada tecla durante o jogo normal
MAPA_ROTINAS_JOGO:
  WORD atira_sonda_0      ; Tecla 0
  WORD atira_sonda_1      ; Tecla 1
  WORD atira_sonda_2      ; Tecla 2
  WORD faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada
  WORD pausa              ; Tecla D
  WORD termina_tecla      ; Tecla E
  WORD faz_nada           ; Tecla F

; Rotina correspondente a cada tecla durante a pausa
MAPA_ROTINAS_PAUSA:
  WORD faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada
  WORD continua           ; Tecla D
  WORD termina_tecla      ; Tecla E
  WORD faz_nada

; Rotina correspondente a cada tecla durante o ínicio do jogo
MAPA_ROTINAS_TERMINADO:
  WORD faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada, faz_nada
  WORD começar            ; Tecla C
  WORD faz_nada, faz_nada, faz_nada
  
; Lista de rotinas de interrupção
LISTA_INTERRUP:
  WORD move_asteroide
  WORD move_sonda
  WORD decrementa_energia
  WORD muda_luzes

; Lista de posições e direções iniciais possíveis para gerar asteróide 
; 20% para cada
LISTA_ASTEROIDES_POSSIVEIS:
  WORD 0, 0, 1, 1
  WORD 0, METADE_ECRÃ, 1, 1
  WORD 0, METADE_ECRÃ, 1, -1
  WORD 0, METADE_ECRÃ, 1, 0
  WORD 0, LIMITE_DIREITO-LARG_ASTEROIDE, 1, -1

; Lista de bonecos para gerar asteróide minerável ou não
; 25% chance se ser minerável e 75% de não ser 
LISTA_ASTEROIDES_BONECOS:
  WORD ASTEROIDE_BONECO
  WORD ASTEROIDE_BONECO
  WORD ASTEROIDE_MINERAVEL_BONECO
  WORD ASTEROIDE_BONECO

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

ASTEROIDE_BONECO_DESTRUIDO_0:
  WORD 5    ; Largura boneco
  WORD 5    ;  Altura boneco

  WORD 0,      0,      0FBBBH, 0,      0
  WORD 0,      0FBBBH, 0FBBBH, 0,      0
  WORD 0,      0,      0FBBBH, 0F999H, 0
  WORD 0FBBBH, 0FBBBH, 0F999H, 0,      0
  WORD 0,      0FBBBH, 0,      0,      0

ASTEROIDE_BONECO_DESTRUIDO_1:
  WORD 5    ; Largura boneco
  WORD 5    ;  Altura boneco

  WORD 0,      0,      0, 0, 0
  WORD 0,      0,      0, 0, 0
  WORD 0,      0,      0FBBBH, 0, 0
  WORD 0,      0FBBBH, 0F999H, 0, 0
  WORD 0,      0FBBBH, 0, 0, 0

SONDA_BONECO:
  WORD 1
  WORD 1

  WORD 0A29FH

PAINEL_BONECO:
  WORD 15   ; Largura painel
  WORD 5    ; Altura painel
  WORD 0A29FH, 0A29FH, 0A9DEH, 0A29FH, 0A29FH , 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A0BEH , 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A0BEH, 0A8C4H, 0A2B4H, 0ACD3H, 0A29FH
  WORD 0A9DEH, 0A9DEH, 0A0BEH, 0A9DEH, 0A9DEH , 0A0BEH, 0ABBBH, 0A0BEH, 0ABBBH, 0ABBBH, 0ABBBH, 0AF80H, 0AFF0H, 0A2B4H, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A0BEH , 0A0BEH, 0ABBBH, 0A0BEH, 0A0BEH, 0ABBBH, 0A0BEH, 0A2B4H, 0AD22H, 0A8C4H, 0A29FH
  WORD 0A29FH, 0A0BEH, 0A9DEH, 0A0BEH, 0A9DEH , 0A9DEH, 0A46FH, 0A9DEH, 0A46FH, 0A46FH, 0A46FH, 0A9DEH, 0A9DEH, 0A9DEH, 0A29FH

PAINEL_BONECO_LUZ_0:
  WORD 3   ; Largura luzes
  WORD 3    ; Altura luzes

  WORD 0A8C4H, 0A2B4H, 0ACD3H
  WORD 0AF80H, 0AFF0H, 0A2B4H
  WORD 0A2B4H, 0AD22H, 0A8C4H

PAINEL_BONECO_LUZ_1:
  WORD 3   ; Largura luzes
  WORD 3    ; Altura luzes

  WORD 0AFF0H, 0ACD3H, 0A2B4H
  WORD 0A2B4H, 0AF80H, 0A2B4H
  WORD 0AFF0H, 0A2B4H, 0AD22H

PAINEL_BONECO_LUZ_2:
  WORD 3   ; Largura luzes
  WORD 3    ; Altura luzes

  WORD 0AFF0H, 0A2B4H, 0AFF0H
  WORD 0AF80H, 0AD22H, 0A2B4H
  WORD 0A2B4H, 0A2B4H, 0A8C4H

  WORD 0 ; Index 
; Lista das potenciais luzes da nave
LISTA_PAINEL_LUZ:
  WORD PAINEL_BONECO_LUZ_0
  WORD PAINEL_BONECO_LUZ_1
  WORD PAINEL_BONECO_LUZ_2

    ; *************************************************************************
    ; * Objetos
    ; *************************************************************************

  WORD 0    ; Estado de Ativação do Asteroid_0
ASTEROID_0:
  WORD 0, LIMITE_DIREITO/2-LARG_ASTEROIDE/2             ; Posição: Primeira word é linha, segundo coluna
  WORD 1, 1             ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

; **************

  WORD 0    ; Estado de Ativação do Asteroid_1
ASTEROID_1:
  WORD 0, 0             ; Posição: Primeira word é linha, segundo coluna
  WORD 1, 1             ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

; **************

  WORD 0    ; Estado de Ativação do Asteroid_2
ASTEROID_2:
  WORD 0, 0             ; Posição: Primeira word é linha, segundo coluna
  WORD 1, 1             ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

; **************

  WORD 0  ; Estado de Ativação do Asteroid_3
ASTEROID_3:
  WORD 0, 0             ; Posição: Primeira word é linha, segundo coluna
  WORD 1, 1             ; Direção do movimento
  WORD ASTEROIDE_BONECO ; Boneco

; **************

  WORD COLUNA_SONDA-6 ; Coluna inicial sonda
  WORD 0  ; Estado de Ativação da Sonda_0
SONDA_0:  ; Sonda diagonal-esquerda
  WORD LINHA_SONDA, COLUNA_SONDA-6  ; Posição: Primeiro word é linha, segundo coluna
  WORD -1, -1                       ; Direção do movimento
  WORD SONDA_BONECO                 ; Boneco

; **************

  WORD COLUNA_SONDA   ; Coluna inicial sonda
  WORD 0    ; Estado de Ativação da Sonda_1
SONDA_1:    ; Sonda vertical-cima
  WORD LINHA_SONDA, COLUNA_SONDA  ; Posição: Primeiro word é linha, segundo coluna
  WORD -1, 0                      ; Direção do movimento
  WORD SONDA_BONECO               ; Boneco

; **************

  WORD COLUNA_SONDA+6  ; Coluna inicial sonda
  WORD 0    ; Estado de Ativação da Sonda_2
SONDA_2:    ; Sonda diagonal-direita
  WORD LINHA_SONDA, COLUNA_SONDA+6  ; Posição: Primeiro word é linha, segundo coluna
  WORD -1, 1                        ; Direção do movimento
  WORD SONDA_BONECO                 ; Boneco

; **************

  ; Estado ativação sempre != 0 (SONDA_BONECO)
PAINEL_OBJETO:
  WORD LINHA_PAINEL, COLUNA_PAINEL
  WORD 0, 0   ; Não há movimento
  WORD PAINEL_BONECO

LUZES_OBJETO:
  WORD LINHA_PAINEL+1, COLUNA_PAINEL+11 ; Posição: Primeira word é linha, segundo coluna
  WORD 0, 0                ; Direção do movimento
  WORD PAINEL_BONECO_LUZ_0 ; Boneco

    ; *************************************************************************
    ; * Listas de objetos
    ; *************************************************************************
LISTA_ASTEROIDES:
  WORD ASTEROID_0, ASTEROID_1, ASTEROID_2, ASTEROID_3, NULL

; *****************************************************************************
; * Inicializações dos Registos e Stack Pointer
; *****************************************************************************
  PLACE 0000H

inicio:
  MOV SP,   SP_inicial
  MOV BTE,  LISTA_INTERRUP
  
  ; Reseta energia
  MOV R1, ENERGIA_INICIAL
  MOV [energia], R1
  MOV [valor_display], R1

  ; Cenário de Fundo Inicial
  MOV R1, FUNDO_INICIO
  MOV [SEL_CEN_FUNDO], R1

  ; interrupções desativas para objetos não se moverem enquanto
  ; desenha gráficos e verifica colisões 
  CALL gráficos

  ; Ativar todas as interrupções para os restantes processos
  EI0
  EI1
  EI2
  EI3
  EI

  CALL teclado
  CALL control
  CALL display

; *****************************************************************************
; * "PROCESSO"
; * MAIN - O processo principal trata da geração de asteróides
; *****************************************************************************
main_setup:
  MOV   R1, 5 ; Tamanho de tabela LISTA_ASTEROIDES_POSSIVEIS
  MOV   R2, 4 ; Tamanho de tabela LISTA_ASTEROIDES_BONECOS
  MOV   R4, LISTA_ASTEROIDES_POSSIVEIS
  MOV   R5, LISTA_ASTEROIDES_BONECOS
  MOV   R6, TEC_LIN ; 
main:
  ; só verificar uma colisão a cada duas atualizações de ecrã
  ; para diminui sobreposições
  MOV   R3, [atualiza_ecrã]
  MOV   R3, [atualiza_ecrã]
  MOV   R3, [atualiza_ecrã]
  MOV   R3, [atualiza_ecrã]

  MOV   R3, ASTEROID_0
  CALL  gera_asteroide
  JZ main

  MOV   R3, ASTEROID_1
  CALL  gera_asteroide
  JZ main

  MOV   R3, ASTEROID_2
  CALL  gera_asteroide
  JZ main

  MOV   R3, ASTEROID_3
  CALL  gera_asteroide
  JZ main

  JMP   main

; *****************************************************************************
; * GERA_ASTEROIDE - Gera um asteróide com um posição e direção aleatória
; * Argumentos:
; *   R1: Tamanho de tabela LISTA_ASTEROIDES_POSSIVEIS
; *   R2: Tamanho de tabela LISTA_ASTEROIDES_BONECOS
; *   R3: Objeto Asteróide (Valor é consumido)
; *   R4: Tabela LISTA_ASTEROIDES_POSSIVEIS
; *   R5: Tabela LISTA_ASTEROIDES_BONECOS
; *   R6: Endereço Leitura Teclado.
; *   R0, R7: Valor é consumido
; * Retorno:
; *   R0: é 0 se asteróide foi gerado
; *   Flags: Resultado de CMP R0, 0
; *****************************************************************************
gera_asteroide:
  MOV   R0, [R3-2]  ; Valor de ativação
  CMP   R0, 0
  JNZ   sair_gera_asteroide ; Se não for 0 não gerar

  ; Gera posição e direção aleatória
  CALL numero_aleatório
  MOD   R0, R1    ; i = random() % length_lista_asteroides_possíveis
  SHL   R0, 3     ; Cada elemento tem 4 Words (8 Bytes)
  ADD   R0, R4    ; R0 = &lista_asteróides_possíveis[i]

  ; Escreve Posição inicial e direção no Asteróide R3
  MOV   R7,   [R0]  ; linha inicial
  MOV   [R3],  R7   ; R3 Endereço Linha
  MOV   R7,   [R0+2]    ; coluna inicial
  MOV   [R3+2], R7  ; R3+2 Endereço Coluna
  MOV   R7,   [R0+4]    ; direção linha
  MOV   [R3+4], R7  ; R3+4 Endereço Direção Linha
  MOV   R7,   [R0+6]    ; direção coluna
  MOV   [R3+6], R7  ; R3+6 Endereço Direção Coluna

  ; Gera tipo aleatório (minerável ou não)
  CALL numero_aleatório
  MOD   R0,   R2    ; i = random() % length_lista_asteroides_bonecos
  SHL   R0,   1     ; Cada elemento tem 1 Words (2 Bytes)
  ADD   R0,   R5    ; R0 = &lista_asteróides_possíveis[i]

  ; Escreve boneco asteróide
  MOV   R7,   [R0]  
  MOV   [R3+8], R7  ; R3+8 Endereço Boneco

  ; Ativa asteróide
  MOV   R0, 1
  MOV   [R3-2], R0  ; Estado de ativação = 1, ativa asteróide

  ; Valor de Retorno (0 se Asteróide foi gerado)
  MOV   R0, 0
sair_gera_asteroide:
  CMP   R0, 0
  RET

; *****************************************************************************
; * NUMERO_ALEATÓRIO - Gera um número aleatório de 0 a 15.
; * Argumentos:
; *   R6: Endereço Leitura Teclado.
; * Retorno:
; *   R0: Valor aleatório de 0 a 15
; *****************************************************************************
numero_aleatório:
  MOVB  R0, [R6]  ; Lê input teclado
  SHR   R0, 4     ; Deita o valor da coluna fora
  RET

; *****************************************************************************
; * PROCESSO
; * TECLADO - Processo varre o teclado em ciclo para a variável tecla_premida
; *   e faz yield em cada ciclo, (WAIT no espera_tecla)
; *****************************************************************************
PROCESS SP_teclado
teclado:
  MOV   R0, 0         ; Registo da coluna/tecla premida
  MOV   R1, TEC_PRIM_LIN   ; Linha toma valor inicial 1111H
  MOV   R2, TEC_LIN   ; endereço do periférico das  linhas do teclado
  MOV   R3, TEC_COL   ; endereço do periférico das colunas do teclado
  MOV   R4, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
  MOV   R5, SOM_BOTAO ; Som clicar botão
espera_tecla: ; Ciclo enquanto a tecla NÃO estiver a ser premida
  WAIT        ; Adormece quando os outros processos estão bloqueados e não há teclas/interrupções ativas
  ROL   R1,   1       ; Roda o valor da linha (representado pelo least significant nibble)
  MOVB  [R2], R1      ; Escreve no periférico das linhas do teclado
  MOVB  R0,   [R3]    ; lê para R0 a coluna
  AND   R0,   R4      ; descarta todos bits exceto 0-3
  CMP   R0,   0       ; nenhuma tecla premida é coluna = 0
  JZ    espera_tecla  ; se nenhuma tecla for premida continuar ciclo

  MOV   [TOCA_SOM], R5
  CALL  valor_teclado  ; R0 <- Valor da tecla
  MOV   [tecla_premida], R0 ; Escreve na var LOCK tecla_premida

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
; * DISPLAY - Processo que atualiza display e a energia da nave
; *****************************************************************************
PROCESS SP_display
display:
  MOV   R0, 10  ; Escreve em base 10
display_ciclo:
  MOV   R6, [valor_display] ; LOCK bloqueia até valor ser atualizado
  CALL  escreve_display

  CMP   R6, 0
  JLE   nave_sem_energia

  JMP   display_ciclo

; Se Energia <= 0
nave_sem_energia:
  MOV R6, 0
  MOV R1, FUNDO_GAMEOVER_ENERGIA
  MOV R2, SOM_GAMEOVER_ENERGIA
  MOV R3, MAPA_ROTINAS_TERMINADO

  MOV [estado_jogo],  R6  ; Pausa jogo
  MOV [DISPLAYS],     R6  ; Quando é <= 0 escreve 0
  MOV [APAGA_ECRÃS],  R6  ; apaga todos os pixels já desenhados (o valor de R6 não é relevante)

  ; Efeito gameover_energia
  MOV [SEL_CEN_FUNDO], R1
  MOV [TOCA_SOM], R2

  ; Desativa outros controles do teclado
  MOV [MAPA_ROTINAS], R3

  JMP display_ciclo

; *****************************************************************************
; * ESCREVE_DISPLAY - Transforma valor Hex noutra base (de 1 a 16), num limite 
; *   de 3 dígitos para base 10 é válido de 0 a 999 (0H a 3E7H) 
; *   e representa-o no display.
; * Argumentos:
; *   R0: Base (Denominador das divisões)
; *   R1: Valor é consumido
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

  MOV   [DISPLAYS], R6  ; escreve valor decimal no display

  POP R2
  POP R6
  RET

; *****************************************************************************
; * PROCESSO
; * CONTROL - Processo que executa o commando correspondente a cada tecla
; *****************************************************************************
PROCESS SP_control
control:
  MOV   R0, [tecla_premida] ; lê LOCK (bloqueia), espera por tecla 
  MOV   R1, [MAPA_ROTINAS] ; Seleciona a lista de rotinas adequada

  SHL   R0, 1    ; multiplica por 2, porque uma word é 2 bytes
  ADD   R1, R0   ; salta para o comando corresponde 
  MOV   R0, [R1]
  CALL  R0       ; call lista_rotinas[valor]

  JMP   control

; *****************************************************************************
; * TERMINA_TECLA - Termina o jogo por ordem do utilizador
; *****************************************************************************
termina_tecla:
  MOV   R0, 0
  MOV   R1, FUNDO_GAMEOVER
  MOV   R2, MAPA_ROTINAS_TERMINADO

  ; Pausa jogo
  MOV   [estado_jogo],    R0   

  ; Desativa outros controles do teclado
  MOV   [MAPA_ROTINAS],   R2

  ; Seleciona cenário GAMEOVER genérico
  MOV   [SEL_CEN_FUNDO],  R1
  MOV   [APAGA_FRONTAL],  R1
  MOV   [APAGA_ECRÃS],    R1 ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)

  RET

; *****************************************************************************
; * COMEÇAR - Começa/Reseta o jogo
; *****************************************************************************
começar:
  MOV R0, 0
  MOV R1, FUNDO_JOGO
  MOV R2, MAPA_ROTINAS_JOGO
  MOV R3, ENERGIA_INICIAL

; Reseta Asteróides
  MOV [ASTEROID_0-2], R0
  MOV [ASTEROID_1-2], R0
  MOV [ASTEROID_2-2], R0
  MOV [ASTEROID_3-2], R0

; Reseta Sondas
  MOV [SONDA_0-2],    R0
  MOV [SONDA_1-2],    R0
  MOV [SONDA_2-2],    R0

; Reseta painel da nave
  MOV [atualiza_painel], R0

; Reseta energia
  MOV [energia],        R3
  MOV [valor_display],  R3

; Reseta Fundo
  MOV [SEL_CEN_FUNDO],  R1

; Ativa controles teclado e continua jogo
  MOV [MAPA_ROTINAS],   R2
  MOV [estado_jogo],    R2   ; Valor != de 0
  RET

; *****************************************************************************
; * PAUSA - interrompe o jogo
; *****************************************************************************
pausa:
  MOV R0, 0
  MOV R1, FUNDO_PAUSA
  MOV R2, MAPA_ROTINAS_PAUSA

  ; Pausa jogo
  MOV [estado_jogo], R0 ; Valor == 0

  ; Mostra texto menu pausa (cenário frontal)
  MOV [SEL_CEN_FRONTAL], R1

  ; Desativa outros controles
  MOV [MAPA_ROTINAS], R2

  RET

; *****************************************************************************
; * CONTINUA - despausa o jogo
; *****************************************************************************
continua:
  MOV R1, FUNDO_JOGO
  MOV R2, MAPA_ROTINAS_JOGO
  
  ; Reseta cenário
  MOV [SEL_CEN_FUNDO],  R1
  MOV [APAGA_FRONTAL],  R1 ; Valor irrelevante

  ; Ativa controles jogo
  MOV [MAPA_ROTINAS],   R2

  ; Despausa jogo
  MOV [estado_jogo],    R2 ; Valor != 0
  RET

; *****************************************************************************
; * Rotina que não faz nada para quando tecla não corresponde a nenhuma ação
; *****************************************************************************
faz_nada:
  RET

; *****************************************************************************
; * ATIRA_SONDA_X - Ativa a sonda X e coloca-a na sua respetiva posição
; * Argumentos:
; *   R3: Valor é consumido
; *****************************************************************************
atira_sonda_0:
  MOV   R3, SONDA_0
  JMP   atirar
atira_sonda_1:
  MOV   R3, SONDA_1
  JMP   atirar
atira_sonda_2:
  MOV   R3, SONDA_2
  JMP   atirar
atirar:
  CALL  atira_sonda
  RET

; *****************************************************************************
; * ATIRA_SONDA - Ativa uma sonda 
; * Argumentos:
; *   R0: Valor é consumido
; *   R3: Objeto Sonda
; *****************************************************************************
atira_sonda:
  MOV   R0, [R3-2]  ; Estado de ativação da sonda
  CMP   R0, 0
  JNZ   sair_atira_sonda  ; Se sonda estiver ativa não fazer nada

  MOV   R0, SOM_SONDA     ; som número 0
  MOV   [TOCA_SOM], R0    ; comando para tocar o som

  decrementa_energia_5:
  DI2 ; Desativar interrupção da energia para evitar race condition
  MOV R0, [energia]
  SUB R0, 5
  MOV [energia], R0
  MOV [valor_display], R0
  EI2

  MOV   R0, [R3-4]  ; R0 <- Coluna inicial da sonda
  MOV   [R3+2], R0  ; Reseta coluna da sonda
  MOV   R0, LINHA_SONDA ; R0 <- Linha inicial da sonda
  MOV   [R3], R0    ; Reseta linha da sonda
  MOV   [R3-2], R0  ; Ativa a sonda (verifica-se R0 != 0)
  
sair_atira_sonda:
  RET

; *****************************************************************************
; * PROCESSO
; * GRÁFICOS - trata de colisões, desenha o painel da nave, as sondas, e os
; * asteroides nas suas posições iniciais. Interrupções desativadas no processo.
; *****************************************************************************
PROCESS SP_gráficos
gráficos:
  MOV   R3, [atualiza_ecrã] ; LOCK até ecrã necessitar atualização
  MOV   R9, 1 ; Reseta colisões

gráficos_painel:
  MOV   R3, [atualiza_painel]
  CMP   R3, 0
  JNZ   gráficos_luzes      ; if(atualiza_painel == 0) desenha_painel();
  CALL  desenha_painel

gráficos_luzes:
  MOV   R3, [atualiza_luzes]
  CMP   R3, 0
  JNZ   gráficos_asteroides ; if(atualiza_luzes == 0) desenha_luzes();
  CALL  desenha_luzes

gráficos_asteroides:
  MOV   R3, [atualiza_asteroides]
  CMP   R3, 0
  JNZ   gráficos_sondas     ; if(atualiza_asteroides == 0) desenha_asteroides();
  CALL  desenha_asteroides

gráficos_sondas:
  MOV   R3, [atualiza_sondas]
  CMP   R3, 0
  JNZ   gráficos            ; if(atualiza_sondas == 0) desenha_sondas();
  CALL  desenha_sondas

  JMP   gráficos

; *****************************************************************************
; * DESENHA_PAINEL - desenha o objeto painel no ecrã 0
; *****************************************************************************
desenha_painel:
  MOV   R3,           ECRÃ_PAINEL
  MOV   [SEL_ECRÃ],   R3          ; Seleciona ecrã 0
  ; MOV   [APAGA_ECRÃ], R3          ; Apaga todos os pixéis neste ecrã

  MOV   R3, PAINEL_OBJETO
  CALL  desenha_objeto

  MOV   [atualiza_painel], R3 ; R3 é sempre != de 0, logo marca painel como atualizado
  RET

; *****************************************************************************
; * DESENHA_LUZES - desenha as luzes do painel no ecrã 0
; *****************************************************************************
desenha_luzes:
  MOV   R3, ECRÃ_PAINEL
  MOV   [SEL_ECRÃ],   R3    ; Seleciona ecrã 0

  MOV   R3, LUZES_OBJETO
  CALL  desenha_objeto

  MOV   [atualiza_luzes], R3 ; R3 é sempre != de 0, logo marca painel como atualizado
  RET

; *****************************************************************************
; * DESENHA_ASTEROIDES - desenha todos os asteroides no ecrã 1
; *****************************************************************************
desenha_asteroides:
  MOV   R3,           ECRÃ_ASTEROIDES 
  MOV   [SEL_ECRÃ],   R3              ; Seleciona ecrã 1
  MOV   [APAGA_ECRÃ], R3              ; Apaga todos os pixéis neste ecrã

  MOV   R3, 1
  MOV   [atualiza_asteroides], R3 ; R3 é sempre != de 0, logo marca asteroides como atualizados

  MOV   R10, LISTA_ASTEROIDES
ciclo_desenha_asteroides:
  MOV   R3, [R10]  ; Objeto asteróide
  CMP   R3, NULL
  JZ    sair_desenha_asteroides ; Se lista chegar ao fim, sair

  CALL  verifica_limites_asteroide
  CALL  verifica_colisão_asteroide
  JZ    termina_colisao
  CALL  desenha_objeto
  
  ADD   R10, 2
  JMP   ciclo_desenha_asteroides

sair_desenha_asteroides:
  RET

; Se houver uma colisão Asteróide-painel acabar jogo
termina_colisao:
  MOV   R0, SOM_GAMEOVER_COLISAO
  MOV   R1, FUNDO_GAMEOVER_COLISAO
  MOV   R2, MAPA_ROTINAS_TERMINADO
  MOV   R3, 0

  ; Não continuar a desenhar sondas
  MOV   [atualiza_sondas],  R2 ; R2 é sempre != de 0, logo marca sondas como atualizados

  ; Efeito destruição de nave
  MOV   [TOCA_SOM],       R0
  MOV   [SEL_CEN_FUNDO],  R1
  MOV   [APAGA_ECRÃS],    R1 ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)

  ; Desativar outros controles
  MOV   [MAPA_ROTINAS], R2

  ; Pausa jogo
  MOV   [estado_jogo],  R3
  RET

; *****************************************************************************
; * VERIFICA_LIMITES_ASTEROIDE - verifica se um dado asteróide 
; *   está dentro do ecrã.
; * Argumentos:
; *   R0: Valor é consumido
; *   R3: Objeto Asteróide
; *****************************************************************************
verifica_limites_asteroide:
  MOV   R0,     [R3-2]  ; Estado de ativação do asteróide
  CMP   R0,     0
  JLE    sair_lim_ast  ; Se o estado de Ativação do asteróide for < 0 então sair

  MOV   R0,     [R3]      ; Linha Asteróide
  MOV   R1,     LIMITE_INFERIOR
  CMP   R0,     R1
  JGT   reseta_asteroide  ; reseta Asteróide se estiver abaixo do limite inferior

  RET

sair_lim_ast: ; Estado ativação <= 0
  MOV   R0,     [R3-2]  ; Estado de ativação do asteróide
  CMP   R0,     -2
  JZ  animação_asteróide  ; Se estado de ativação é -2

reseta_asteroide: ; Estado ativação > -2 e <= 0
  MOV   R0,     0
  MOV   [R3-2], R0  ; Estado de ativação asteróide passa a 0
  RET

animação_asteróide: ; Estado ativação = -2, passar próximo frame
  MOV   R0, ASTEROIDE_BONECO_DESTRUIDO_1
  MOV   [R3+8], R0
  MOV   R0,     -1
  MOV   [R3-2], R0
  RET

; *****************************************************************************
; * VERIFICA_COLISÃO_ASTERÓIDE - 
; * Argumentos: 
; *   R3: Objeto Asteróide
; *   R4: Valor é consumido
; * Retorno:
; *   R9: Se for 0 houve colisão asteróide-painel
; *****************************************************************************
verifica_colisão_asteroide:
  MOV   R1, [R3-2] ; Estado ativação asteroide
  CMP   R1, 0
  JLE    sair_verifica_colisão_asteroide ; Saltar se asteróide for inativo

  MOV   R4, SONDA_0
  CALL  verifica_colisão
  JNZ    ver_sonda_1
  CALL destroi_asteróide

ver_sonda_1:
  MOV   R4, SONDA_1
  CALL  verifica_colisão
  JNZ    ver_sonda_2
  CALL destroi_asteróide

ver_sonda_2:
  MOV   R4, SONDA_2
  CALL  verifica_colisão
  JNZ    ver_painel
  CALL destroi_asteróide

ver_painel:
  MOV   R4, PAINEL_OBJETO
  CALL  verifica_colisão

sair_verifica_colisão_asteroide:
  CMP   R9, 0
  RET

; *****************************************************************************
; * DESTROI-ASTERÓIDE - Destrói um asteróide e faz uma ação consoante for
; *   minerável ou não.
; * Argumentos:
; *   R0, R1: Valor é consumido
; *   R3: Objeto asteróide
; *   R4: Objeto Sonda
; *****************************************************************************
destroi_asteróide:
  CMP R9, 0
  JNZ  sair_destroi_asteróide

  MOV R0, -2
  MOV R1,  0
  MOV [R3-2], R0
  MOV [R4-2], R1
  MOV R0, ASTEROIDE_BONECO_DESTRUIDO_0
  MOV [R3+8], R0

  MOV R1, ASTEROIDE_MINERAVEL_BONECO
  CMP R1, R5  ; Verifica se o asteróide é minerável
  JZ asteroide_minerável
  
; Asteróide não minerável
  MOV   R0, SOM_ASTEROIDE ; som do asteróide não minerável
  MOV   [TOCA_SOM], R0    ; reproduz o som

sair_destroi_asteróide:
  RET

; *****************************************************************************
; * VERIFICA_COLISÃO - verifica se dois objetos estão a colidir
; * Argumentos:
; *   R2: Endereço de rotina se houver colisão
; *   R3: Objeto Asteróide (não queremos alterar)
; *   R4: Objeto 2 (
; * Retorno:
; *   R9: é 0 se houve colisão
; *****************************************************************************
verifica_colisão:

  MOV R0, [R4-2]
  MOV R9, 1
  CMP R0, 0
  JZ  sair_verifica_colisão ; Se objeto 2 estiver inativo saltar verificação

  MOV R0, [R3+2]  ; Coluna inicial Obj 1 (Esquerda do obj1)
  MOV R1, [R4+2]  ; Coluna inicial Obj 2
  MOV R5, [R3+8]  ; Boneco 1
  MOV R6, [R4+8]  ; Boneco 2
  MOV R7, [R5]    ; Largura boneco 1
  MOV R8, [R6]    ; Largura boneco 2
  ADD R1, R8      ; Coluna obj2 + largura (Direita do obj2)

; Para colisão, Direita obj2 está há dir da esq de obj1
  CMP R0, R1
  JGE sair_verifica_colisão

  ADD R0, R7      ; Coluna ob1 + largura (Direita do obj1)
  SUB R1, R8      ; Coluna obj2 (Esquerda do obj2)

; Para colisão, Esquerda obj2 está há esq da dir de obj1
  CMP R0, R1
  JLE sair_verifica_colisão

  MOV R0, [R3]    ; Linha inicial Obj 1 (Cima do obj1)
  MOV R1, [R4]    ; Linha inicial Obj 2 (Cima do obj2)
  MOV R7, [R5+2]  ; Altura boneco 1
  MOV R8, [R6+2]  ; Altura boneco 2

  ADD R1, R8      ; Linha obj2 + altura (Baixo obj2)

; Para colisão, Baixo obj2 está a baixo cima obj1
  CMP R0, R1
  JGE sair_verifica_colisão

  SUB R1, R8      ; Linha obj2 (Cima do obj2)
  ADD R0, R7      ; Linha obj1 + altura (Baixo obj1)

; Para colisão, cima obj2 está há cima de baixo de obj1
  CMP R0, R1
  JLE sair_verifica_colisão

; Há colisão
  MOV R9, 0

sair_verifica_colisão:
  CMP R9, 0
  RET


asteroide_minerável:
; Incremente a energia em 25%
  MOV R4 , [energia]
  MOV R1, 25
  ADD R4, R1

  MOV [energia], R4
  MOV [valor_display], R4

; Efeito asteróide minerável
  MOV   R0, SOM_ASTEROIDE_MINERAVEL ; som do asteróide não minerável
  MOV   [TOCA_SOM], R0    ; reproduz o som

  RET

; *****************************************************************************
; * DESENHA_SONDAS - desenha todas as sondas no ecrã 2
; *****************************************************************************
desenha_sondas:
  MOV   R3,           ECRÃ_SONDAS
  MOV   [SEL_ECRÃ],   R3          ; Seleciona ecrã 2
  MOV   [APAGA_ECRÃ], R3          ; Apaga todos os pixéis neste ecrã

  MOV   R3, SONDA_0
  CALL  verifica_limites_sonda
  CALL  desenha_objeto

  MOV   R3, SONDA_1
  CALL  verifica_limites_sonda
  CALL  desenha_objeto

  MOV   R3, SONDA_2
  CALL  verifica_limites_sonda
  CALL  desenha_objeto

  MOV   [atualiza_sondas], R3 ; R3 é sempre != de 0, logo marca sondas como atualizadas
  RET

; *****************************************************************************
; * VERIFICA_LIMITES_SONDA - verifica se uma dada sonda 
; *   está dentro dos limites
; * Argumentos:
; *   R0: Valor é consumido
; *   R3: Objeto sonda
; *****************************************************************************
verifica_limites_sonda:
  MOV   R0,   [R3-2]  ; Estado de ativação da sonda
  CMP   R0,   0
  JZ    sair_lim_sonda  ; Se o estado de Ativação da sonda for 0 então sair

  MOV   R0,   [R3]    ; Linha sonda
  MOV   R1,   LIMITE_SONDA
  CMP   R0,   R1
  JGT   sair_lim_sonda  ; Se sonda estiver dentro de limites então sair

  MOV   R0, 0
  MOV   [R3-2], R0 ; Desativar sonda se estiver fora de limites

sair_lim_sonda:
  RET

; *****************************************************************************
; * DESENHA_OBJETO - desenha um objeto
; * Argumentos:
; *   R3: Tabela do objeto
; *   R0, R1, R2, R4, R5, R6, R7: Valores são consumidos
; *****************************************************************************
desenha_objeto:
  MOV   R0, [R3-2]  ; Estado ativação objeto
  CMP   R0, 0      ; Se estado for 0 não mover objeto
  JZ    sair_desenha_objeto

  MOV   R0, [R3]    ; R0 <- Linha inicial do objeto (Word)
  MOV   R1, [R3+2]  ; R1 <- Coluna inicial do objeto (Word)
  MOV   R4, [R3+8]  ; R4 <- endereço do boneco do asteroide (Word)
  CALL  desenha_boneco

sair_desenha_objeto:
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
; * ESCREVE_PIXEL - Escreve pixel na linha e coluna dos argumentos 
; * Argumentos:
; *   R0: Linha
; *   R1: Coluna
; *   R2: Cor do Pixel
; *****************************************************************************
escreve_pixel:
  MOV   [DEFINE_LINHA],   R0		; seleciona a linha
  MOV   [DEFINE_COLUNA],  R1	  ; seleciona a coluna
  MOV   [DEFINE_PIXEL],   R2		; altera a cor do pixel na linha e coluna já selecionadas
  RET


; *****************************************************************************
; * Interrupções
; *****************************************************************************

; *****************************************************************************
; * INTERRUPÇÃO 0
; * MOVE_ASTEROIDE - Move e desenha os asteroides
; *****************************************************************************
move_asteroide:
  PUSH  R3

  MOV   R3, [estado_jogo]
  CMP   R3, 0
  JZ    sair_move_asteroide

  MOV   R3, 0
  MOV   [atualiza_ecrã],  R3 ; Escreve para LOCK, desbloqueia processo gráfico
  MOV   [atualiza_asteroides], R3 ; Declara asteroides como desatualizados (0)

  MOV   R3, ASTEROID_0
  CALL  move_objeto

  MOV   R3, ASTEROID_1
  CALL  move_objeto

  MOV   R3, ASTEROID_2
  CALL  move_objeto

  MOV   R3, ASTEROID_3
  CALL  move_objeto

sair_move_asteroide:
  POP   R3
  RFE

; *****************************************************************************
; * INTERRUPÇÃO 1
; * MOVE_SONDA - Move as sondas
; *****************************************************************************
move_sonda:
  PUSH  R3

  MOV   R3, [estado_jogo]
  CMP   R3, 0
  JZ    sair_move_sonda

  MOV   R3, 0
  MOV   [atualiza_ecrã],  R3 ; Escreve para LOCK, desbloqueia processo gráfico
  MOV   [atualiza_sondas], R3 ; Declara sondas como desatualizados (0)

  MOV   R3, SONDA_0
  CALL  move_objeto

  MOV   R3, SONDA_1
  CALL  move_objeto

  MOV   R3, SONDA_2
  CALL  move_objeto

sair_move_sonda:
  POP   R3
  RFE


; *****************************************************************************
; * INTERRUPÇÃO 2
; * DECREMENTA_ENERGIA - Decrementa a energia em 3% de 3 em 3 segundos
; *****************************************************************************
decrementa_energia:
  PUSH  R3

  MOV   R3, [estado_jogo]
  CMP   R3, 0
  JZ    sair_decrementa_energia

  MOV   R3, [energia]
  SUB   R3, 3
  MOV   [energia],  R3
  MOV   [valor_display],  R3 ; Valor irrelevante

sair_decrementa_energia:
  POP   R3
  RFE

; *****************************************************************************
; * INTERRUPÇÃO 3
; * MUDA_LUZES - muda as luzes do painel
; *****************************************************************************
muda_luzes:
  PUSH  R1
  PUSH  R3

  MOV   R3, [estado_jogo]
  CMP   R3, 0
  JZ    sair_muda_luzes

  MOV R1, [LISTA_PAINEL_LUZ-2]  ; Index da lista
  CMP R1, 4
  JLT incrementa_lista_luz ; Se for menor que 4

  MOV R1, -2  ; Reseta Index para 0 (-2+2=0)

incrementa_lista_luz:
  ADD R1, 2
  MOV [LISTA_PAINEL_LUZ-2], R1 ; Index lista de bonecos das luzes

  MOV R3, LISTA_PAINEL_LUZ 
  ADD R1, R3

  MOV R3, [R1] ; Boneco Luz
  MOV [LUZES_OBJETO+8], R3
  
  MOV R3, 0
  MOV [atualiza_luzes], R3  ; desenhar luzes
  MOV [atualiza_ecrã], R3   ; atualizar ecrã

sair_muda_luzes:
  POP   R3
  POP   R1
  RFE

; *****************************************************************************
; * MOVE_OBJETO - Apaga, move, e desenha um objeto representado 
; *   por uma determinada tabela.
; * Argumentos:
; *   R3 - Objeto com estado de ativação
; *****************************************************************************
move_objeto:
  PUSH  R0
  PUSH  R1
  PUSH  R2
  PUSH  R4

  MOV   R0, [R3-2]  ; Estado ativação objeto
  CMP   R0, 0      ; Se estado for <= 0 não mover objeto inativo
  JLE    sair_move_objeto

  MOV   R0, [R3]    ; R0 <- Linha inicial do objeto (Word)
  MOV   R1, [R3+2]  ; R1 <- Coluna inicial do objeto (Word)
  MOV   R2, [R3+4]  ; Direção de movimento vertical (Word)
  MOV   R4, [R3+6]  ; Direção de movimento horizontal (Word)

  ADD   R0, R2    ; Adiciona direção vertical (cima, baixo)
  ADD   R1, R4    ; Adiciona direção horizontal (esquerda, direita)

  MOV   [R3], R0
  MOV   [R3+2], R1

sair_move_objeto:
  POP   R4
  POP   R2
  POP   R1
  POP   R0
  RET