#*******************************************************************************
# exercicio051.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Tradução de:
# int a;

# int main(void)
# {
#     a = 0;              // inicializamos a variável a com zero
# l0:                     // inicio das instruções quando a != 0
#     a = a + 1;          // incrementamos a
#     if(a == 9) goto l1; // se a = 9 então desvie para l1
#     goto l0;            // salto incondicional para l0
# l1:                     // 
#     return 0;           // termina o programa retornando 0
# }
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
# *** Mapa de Registradores ***
# $s0 <- a
# $t0 <- endereço de a
# a = 0; // inicializamos a variável a
            la    $t0, varA     # $t0 <- endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0. 
            sw    $s0, 0($t0)   # a = 0
# l0:
l0:                             #
# a = a + 1; // incrementamos a variável a         
            addi  $s0, $s0, 1   # $s0 <- $s0 + 1
            sw    $s0, 0($t0)   # a = a + 1
################ início do if
# if(a == 9) goto l1; // se a == 9 desvie para l1
if_teste_condicao:
            # verificamos se a condição do if, (a==9), é verdadeira
            addi  $t1, $zero, 9 # carregamos 9 no registrador $t1
            # se a == 9 (condição verdadeira) desviamos para if_condicao_verdadeira
            # se a != 9 (condicao falsa), desviamos para if_fim, testamos a 
            # condição falsa para economizar uma instrução j.
            bne   $s0, $t1, if_fim # se condição é falsa não execute o código em if
            # se a condição é verdadeira, executamos o código em if_condicao_verdadeira
if_condicao_verdadeira:         # se a condição do if é verdadeira
            j l1                # goto l1
if_fim:
################ fim do if       
# goto l0;  // desvie incondicionalmente para l0
            j l0                # Esta instrução é executada se a != 9. Desvie para l0
l1:                             #
#r eturn 0; // termine o programa
            addi  $v0, $zero, 17 # serviço 17 - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é 0 - sucesso
            syscall             # fazemos uma chamada ao serviço 17 do sistema - exit2
.data 
# int a;
varA:       .word 0             # variável varA =  a, global

