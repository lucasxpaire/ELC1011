#*******************************************************************************
# ex-000-055.asm              Copyright (C) 2022 Giovani Baratto
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
# *** mapa de registradores ***
# $s0 <- a

# a = 2;              // colocamos em a um valor para teste
            la    $t0, varA     # $t0 <- enderço da variável a
            addi  $s0, $zero, 2 # $s0 <- 2
            sw    $s0, 0($t0)   # a = 2
################## início do switch        
#switch (a){         // selecionamos um case, usando o valor de a
            # verificamos se o valor de a está entre 0 e 3
            # se a é menor que 0 ou maior que 4 nenhuma sentença case é executada
            slt   $t1, $s0, $zero # $t1 <- 1 se a < 0
            bne   $t1, $zero, fim_switch # se $t1 != 0 (a<0) saia da construção switch
            slti  $t1, $s0, 4   # $t1 = 1 se a < 4 senão 0
            beq   $t1, $zero, fim_switch
            # Aqui o valor de a está entre 0 e 3
            # desviamos para o trecho de código que deve ser executado em função do valor
            # da variável a. Usamos para isso a tabela_desvios. Esta tabela possui os endereços
            # da primeira instrução dos blocos de códigos, função da variável a. Cada endereço
            # é armazenado como uma palavra (4 bytes)
            # Encontramos o endereço que contém o endereço de desvio.
            la    $t1, tabela_desvios # $t1 <- o endereço base da tabela de tabela_desvios
            sll   $t2, $s0, 2   # $t2 <- 4 * a = (nb * i) nb = número de bytes do elemento e i o índice
            addu  $t1, $t1, $t2 # $t1 <- endereço efetivo do endereço do desvio
            lw    $t3, 0($t1)
            # carregamos o item (endereço de desvio), usando o endereço efetivo
            jr    $t3           # desviamos para o endereço do case
# case 0:         // se a = 0
l0:
# a = 10;     // fazemos a = 10
            addi  $s0, $zero, 10 # $s0 <- 10
            sw    $s0, 0($t0)   # a = 10
# break;      // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
# case 1:         // se a = 1 
l1:            
# a = 20;     // fazemos a = 20
            addi  $s0, $zero, 20 # $s0 <- 20
            sw    $s0, 0($t0)   # a = 20
# break;      // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
# case 2:         // se a = 2
l2:            
# a = 30;     // fazemos a = 30
            addi  $s0, $zero, 30 # $s0 <- 30
            sw    $s0, 0($t0)   # a = 30
# break;      // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
# case 3:         // se a = 3
l3:            
 # a = 40;     // fazemos a = 40
            addi  $s0, $zero, 40 # $s0 <- 40
            sw    $s0, 0($t0)   # a = 40
# break;      // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-cas
fim_switch:
################## fim do switch  
# return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # serviço 17 do sistema - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é zero
            syscall             # chamamos o serviço 17 do sistema com o valor 0
.data 
# int a;
varA:           .word 0             # variável varA = a, global
# tabela de saltos para a construção switch-case
# esta tabela é construída como um vetor. Os elementos são os endereços dos blocos
# de código que devem ser executados, em função do valor da variável a. Neste exemplo,
# o valor da variável a é implícito e igual ao índice do vetor. 
# O compilador irá substituir os rótulos l0, l1, l2 e l3 pelo endereço da instrução
# após a declaração do rótulo.
tabela_desvios: .word l0, l1, l2, l3

