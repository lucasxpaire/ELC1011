#*******************************************************************************
# ex-000-054.asm               Copyright (C) 2022 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Exemplo da tradução de uma instrução do-while, de um trecho de 
#            código, do C para assembly. Neste código a variável a é incrementada 
#            de 0 a 9. Segue o código em C.
# int a;
#
#int main(void)
#{
#    a = 0;              // inicializamos a variável a com o valor zero
#    do{                 // início do laço do-while
#        a = a + 1;      // incrementamos a variável a
#    }while (a != 9 )    // repita o laço do-while enquanto a != 9
#    return 0;           // termina o programa retornando 0
#}
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
            la    $t0, varA     # $t0 <- endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0 
            sw    $s0, 0($t0)   # a = 0
################## início do do-while
# do{                 // início do laço do-while
do_while_laco:                  # código do laço do-while (executado pelo menos uma vez)
# a = a + 1;      // incrementamos a variável a
            addi  $s0, $s0, 1    # $s0 <- $s0 + 1
            sw    $s0, 0($t0)    # a = a + 1
# }while (a != 9 )    // repita o laço do-while enquanto a != 9
do_while_verifica_condicao:            
            addi  $t1, $zero, 9  # $t1 <- 9
            bne   $s0, $t1, do_while_laco # se a != 9 desvie incondicionalmente para do_while_laco
            # se a condição do laço do-while for falsa (a==9) termine o laço do-while
do_while_fim:   
################## fim do do-while        
# return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # serviço 17 - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é 0
            syscall             # chamamos o serviço 17 do sistema - exit2, com o valor 0
.data 
# int a;
varA:       .word 0             # variável a

