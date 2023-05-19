; *******************************************************************************
; * IST-UL
; * 
; *
; *
; *******************************************************************************
;
; *******************************************************************************
; * Constantes
; *******************************************************************************
DISPLAYS  EQU 0A000H
TEC_LIN   EQU 0C000H
TEC_COL   EQU 0E000H
LINHA     EQU 01111H
MASCARA   EQU 0FH

PLACE 1000H
SP_inicial:


PLACE 0000H

  MOV SP, SP_inicial

inicio:
; inicializações
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
  MOV R6, 0F0H

ler_teclado:
  MOV R1, LINHA
  MOV R0, 0
  MOV [R4], R0

espera_tecla:
  ROL R1, 1
  MOVB [R2], R1
  MOVB R0, [R3]
  AND R0, R5
  CMP R0, 0
  JZ espera_tecla
  
  CALL valor_teclado
  MOV [R4], R0 

ha_tecla:
  MOVB [R2], R1
  MOVB R0, [R3]
  AND R0, R5
  CMP R0, 0
  JNZ ha_tecla
  JMP ler_teclado



; *******************************************************************************
; * Rotina para converter linha e coluna para valor 0H até FH sem loops
; * R0: Valor da coluna e Registo de retorno do valor
; * R1: Valor da linha
; *******************************************************************************
valor_teclado:
  PUSH  R1    ; guarda o valor do R1
  PUSH  R2    ; guarda o valor do R2

  AND R1, R5 ; descarta todos bits exceto 0-3

  ; Converter nibble linha 1-2-4-8 para 0-1-2-3
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
  ADD R0, R1  ; 4*linha coluna

  POP   R2    ; R2 volta a tomar valor anterior
  POP   R1    ; R1 volta a tomar valor anterior
  RET

