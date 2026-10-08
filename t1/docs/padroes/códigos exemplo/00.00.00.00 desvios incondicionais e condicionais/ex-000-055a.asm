#*******************************************************************************
# ex-000-055a.asm              Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Tradução de:
# int a;
# int main(void)
# {
#     a = 2;              // colocamos em a um valor para teste
#     switch (a){         // selecionamos um case, usando o valor de a
#         case 0:         // se a = 0
#             a = 10;     // fazemos a = 10
#             break;      // saímos da estrutura switch-case
#         case 1:         // se a = 1 
#             a = 20;     // fazemos a = 20
#             break;      // saímos da estrutura switch-case
#         case 2:         // se a = 2
#             a = 30;     // fazemos a = 30
#             break;      // saímos da estrutura switch-case
#         case 3:         // se a = 3
#             a = 40;     // fazemos a = 40
#             break;      // saímos da estrutura switch-case
#     }                   // fim da construção switch-case
#     return 0;           // termina o programa retornando 0
# }
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
# a = 2;              // colocamos em a um valor para teste
            la    $t0, varA     # $t0 <- endereço de a
            addi  $s0, $zero, 2 # $s0 <- 2
            sw    $s0, 0($t0)   # a = 2
################## início do switch            
#switch (a){         // selecionamos um case, usando o valor de a
            # verificamos se a = 0
            addi  $t1, $zero, 0 # $t1  <- 0
            beq   $s0, $t1, l0  # se a=0, desvie para l0 (case 0:)
            # verificamos se a = 1
            addi  $t1, $zero, 1 # $t1 <- 1
            beq   $s0, $t1, l1  # se a=1, desvie para l1 (case 1:)
            # verificamos se a = 2
            addi  $t1, $zero, 2 # $t1 <- 2
            beq   $s0, $t1, l2  # se a=2, desvie para l2 (case 2:)
            # verificamos se a = 3
            addi  $t1, $zero, 3 # $t1 <- 3
            beq   $s0, $t1, l3  # se a=3, desvie para l3 (case 3:)
            # Quando a < 0 ou se a > 3 saimos da estrutura switch
            j     fim_switch
# case 0:         // se a = 0
l0:
# a = 10;           // fazemos a = 10
            addi  $s0, $zero, 10 # $s0 <- 10
            sw    $s0, 0($t0)   # a = 10
# break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
# case 1:           // se a = 1 
l1:            
# a = 20;           // fazemos a = 20
            addi  $s0, $zero, 20 # $s0 <- 20
            sw    $s0, 0($t0)   # a = 20
# break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
# case 2:           // se a = 2
l2:            
# a = 30;           // fazemos a = 30
            addi  $s0, $zero, 30 # $s0 <- 30
            sw    $s0, 0($t0)   # a = 30
# break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
# case 3:           // se a = 3
l3:            
# a = 40;           // fazemos a = 40
            addi  $s0, $zero, 40 # $s0 <- 40
            sw    $s0, 0($t0)   # a = 40
# break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
fim_switch:                     # fim da construção switch-case
################## fim do switch  
# return 0;         // termina o programa retornando 0
            addi  $v0, $zero, 17 # serviço 17 do sistema - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é zero
            syscall             # chamamos o serviço 17 do sistema com o valor 0
.data 
# int a;
varA:       .word 0             # variável varA = a, global


