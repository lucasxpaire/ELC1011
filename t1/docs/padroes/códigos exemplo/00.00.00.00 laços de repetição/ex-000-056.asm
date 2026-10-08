#*******************************************************************************
# ex-000-056.asm              Copyright (C) 2022 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Exemplo da tradução de uma instrução while, de um trecho de 
#            código, do C para assembly. Neste código a variável a é incrementada 
#            de 0 a 9. Segue o código em C.
#int a;
#int i;   
#
#int main(void)
#{
#    a = 0;              // inicializamos a variável a com o valor zero
#    for(i=0; i<9; i++){ // para i de 0 a 8 (repetimos 9 vezes o laço for)
#        a = a + 1;      // incremente a 
#    }
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
# $t2 <- i

# a = 0; // inicializamos a variável a com o valor zero
            la    $t0, varA     # $t0 <- endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0
            sw    $s0, 0($t0)   # a = 0
################## início do laço for
for_inicio:            
# for(i=0; i<10; i++){// para i de 0 a 9 (repetimos 10 vezes o laço for)
            # laço for - inicialização
            # i = 0;
for_inicializacao:            
            la    $t1, VarI     # $t1 <- endereço da variável i
            addi  $t2, $zero, 0 # $t2 <- 0
            sw    $t2, 0($t1)   # i = 0
            # laço for - verificamos a condição
            j     for_verifica_condicao # salto incondicional para a verificação do laço for
            # laço for - código se condição for verdadeira
for_codigo_condicao_verdadeira:
# a = a + 1;      // incremente a
            addi  $s0, $s0, 1   # $s0 <- $s0 + 1
            sw    $s0, 0($t0)   # a = a + 1
for_incremento:                 # incremento do laço for
            # i++
            addi  $t2, $t2, 1   # $t2 <- $t2 + 1
            sw    $t2, 0($t1)   # i = i + 1
for_verifica_condicao: # se a condição do laço for for verdadeira, execute o código em for_codigo_condicao_verdadeira
            # testamos a condição i<9
            slti   $t3, $t2, 9 # $t3 = 1 se i < 9, senão $t3 = 0 
            bne    $t3, $zero, for_codigo_condicao_verdadeira 
for_condicao_falsa: # se a condição é falsa, saímos do laço for          
for_fim:    
################## fim do laço for
# return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # escolhemos o serviço 17 - exit2 - termina o programa
            addi  $a0, $zero, 0 # o valor de retorno do programa é zero
            syscall             # executamos o serviço 17 com uma chamada ao sistema
.data 
# int a;
# int i;
varA:       .word 0             # variável varA = a, global
VarI:       .word 0             # variável VarI = i, global
