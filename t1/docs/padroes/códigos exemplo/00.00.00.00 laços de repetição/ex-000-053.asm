#*******************************************************************************
# ex-000-053.asm              Copyright (C) 2022 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Exemplo da tradução de uma instrução while, de um trecho de 
#            código, do C para assembly. Neste código a variável a é incrementada 
#            de 0 a 9. Segue o código em C.
# int a;
#
# int main(void)
# {
#     a = 0;              // inicializamos a variável a com o valor zero
#     while (a != 9){     // enquanto a variável a é diferente de 9, faça
#         a = a + 1;      // incremente a variável a
#     }                   // 
#     return 0;           // termina o programa retornando 0
# }
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #

.text
.globl      main
main:
# *** mapa de registradores ***
# $s0 <- a

# a = 0;
            la    $t0, varA     # $t0 -> endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0
            sw    $s0, 0($t0)   # a =0
################## início do while
# while (a != 9){     // enquanto a variável a é diferente de 9, faça
while_inicio:            
            j    while_testa_condicao # verificamos se a condição do laço while é verdadeira
while_codigo:          # inicio das instruções lo laço while se condição é verdadeira
# a = a + 1;      // incremente a variável a
            addi  $s0, $s0, 1   # $s0 <- $s0 + 1
            sw    $s0, 0($t0)   # a = a + 1
while_testa_condicao:                 # testamos se a condição do laço while é verdadeira
# while (a != 9){     // enquanto a variável a é diferente de 9, faça
            addi  $t1, $zero, 9 # carregamos em $t1 o valor 9
            bne   $s0, $t1, while_codigo # se a != 9 execute o código do laço while
            # se a condição é falsa, termina a instrução while
while_fim:   
################## fim do while         
# return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # serviço 17 - exit 2
            addi  $a0, $zero, 0 # o valor de retorno do programa é 0 - sucesso
            syscall             # fazemos uma chamada do serviço 17 do sistema com valor 0
.data 
# int a;
varA:       .word 0             # variável varA = a, global.

