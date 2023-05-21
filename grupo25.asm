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

; *****************************************************************************
; * Alocação da Stack
; * Reservados 512 bytes (100H words)
; *****************************************************************************
  PLACE 1000H
pilha:
  STACK 100H
SP_inicial:



; *****************************************************************************
; * Rotinas correspondentes a cada tecla
; *****************************************************************************
LISTA_ROTINAS:
  WORD faz_nada ; Tecla 0
  WORD faz_nada ; Tecla 1
  WORD faz_nada ; Tecla 2
  WORD incrementa_display ; Tecla 3
  WORD faz_nada ; Tecla 4
  WORD faz_nada ; Tecla 5
  WORD faz_nada ; Tecla 6
  WORD decrementa_display ; Tecla 7
  WORD faz_nada ; Tecla 8
  WORD faz_nada ; Tecla 9
  WORD faz_nada ; Tecla A
  WORD faz_nada ; Tecla B
  WORD faz_nada ; Tecla C
  WORD faz_nada ; Tecla D
  WORD faz_nada ; Tecla E
  WORD faz_nada ; Tecla F


; *****************************************************************************
; * Inicializações dos Registos e Stack Pointer
; *****************************************************************************
  PLACE 0000H

inicio:
  MOV SP, SP_inicial
  MOV  R2, TEC_LIN   ; endereço do periférico das linhas
  MOV  R3, TEC_COL   ; endereço do periférico das colunas
  MOV  R4, DISPLAYS  ; endereço do periférico dos displays
  MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
  MOV  R6, 0000H     ; reseta o valor do display para 0
  MOV [R4], R0  ; Escreve 0 no display

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
; * Rotina para converter linha e coluna para valor 0H até FH sem loops
; * R0: Valor da coluna e Registo de retorno do valor
; * R1: Valor da linha
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
; Rotina que executa o commando correspondente a cada tecla
; R0: Valor da tecla na gama 0000H-000FH
; *****************************************************************************
executa_comando:
  PUSH R1
  PUSH R0
  
  MOV R1, LISTA_ROTINAS
  SHL R0, 1
  ADD R1, R0
  MOV R0, [R1]
  CALL R0
  
  POP R0
  POP R1
  RET


; *****************************************************************************
; * Rotina que não faz nada para quando tecla não corresponde a nenhuma ação
; *****************************************************************************
faz_nada:
  RET

; *****************************************************************************
; * Incrementa o Display por um valor
; * R4: Endereço do display
; * R6: Valor do display
; *****************************************************************************
incrementa_display:
  ADD R6, 1
  CALL escreve_display
  RET

; *****************************************************************************
; * Decrementa o Display por um valor
; * R4: Endereço do display
; * R6: Valor do display
; *****************************************************************************
decrementa_display:
  SUB R6, 1
  CALL escreve_display
  RET

; *****************************************************************************
; * Transforma valor Hex em decimal de 0 a 999 e representa-o no display
; * R4: Endereço do display
; * R6: Valor do display
; *****************************************************************************
escreve_display:
  PUSH R6
  PUSH R3
  PUSH R2
  PUSH R1

  MOV R3, 10 ; Denominador das divisões, pois queremos base 10
  
converte_decimal:
  MOV R1, R6

  MOD R1, R3 ; unidades em base 10
  DIV R6, R3

  MOV R2, R6
  
  MOD R2, R3 ; dezenas em base 10
  DIV R6, R3 ; o resto vai para as dezenas
  
  SHL R6, 4 ; R6 0000
  OR R6, R2 ; R6 R2 

  SHL R6, 4 ; R6 R2 0000
  OR R6, R1 ; R6 R2 R1

  MOV [R4], R6 ; escreve valor decimal no display

  POP R1
  POP R2
  POP R3
  POP R6
  RET


