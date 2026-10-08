#*******************************************************************************
# ex-000-081.asm              Copyright (C) 2022 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Tradução de:
# int a, b, c, d;

# int main(void) {
#   a = 0; // Atribuímos valores iniciais para as variáveis a, b, c e d
#   b = 4;
#   c = 7;
#   d = 9;
#   if ((a == 0) && ((b < 6) || (c >= 7))) { // se a condição é verdadeira
#     d = 0;
#   } else { // senão
#     d = 1;
#   }
#   return 0; // termina o programa retornando 0
# }
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                 #

# int a, b, c, d;
.data
var_a: .word 0
var_b: .word 0
var_c: .word 0
var_d: .word 0

.text

init:
            jal main                # executamos o procedimento principal main
finit:      
            li      $v0, 17         # serviço 17: exit2
            li      $a0, 0          # retornamos o valor 0
            syscall                 # chamada ao serviço do sistema: terminamos o programa

# int main(void)
# {
################################################################################
main:
################################################################################
# Mapa de registradores
# $t0: a
# $t1: b
# $t2: c
# $t3: d
# $t4: valores temporários
# $t5: valor booleano de a == 0
# $t6: valor booleano de b < 6
# $t7: valor booleano de c >= 7
# $t8: resultado da expressão de if
# prólogo
# corpo do programa
#     a = 0;              // Atribuímos valores iniciais para as variáveis a, b, c e d
#     b = 4;
#     c = 7;
#     d = 9;
            li      $t0, 0          # $t0 <- 0
            la      $t4, var_a      # $t4 <- endereço da variável a
            sw      $t0, 0($t4)     # a = 0
            li      $t1, 4          # $t1 <- 4
            la      $t4, var_b      # $t4 <- endereço da variável b
            sw      $t1, 0($t4)     # b = 4
            li      $t2, 7          # $t2 <- 7
            la      $t4, var_c      # $t4 <- endereço da variável c
            sw      $t2, 0($t4)     # c = 7
            li      $t3, 9          # $t3 <- 9
            la      $t4, var_a      # $t4 <- endereço da variável d
            sw      $t3, 0($t4)     # d = 9
# if ((a == 0) & ((b < 6) | (c >= 7))) {
# verificamos os valores booleanos para as expressões a==0, b<6 e c>=7
# a == 0
            # poderia ter usado a pseudo instrução seq $t5, $t0, 0
            subu    $t5, $t0, $zero # $t5 <- a - 0
            sltiu   $t5, $t5, 1     # $t5 <- (a-0)<1? (0 ou 1)
# b < 6     
            slti    $t6, $t1, 6     # $t6 <- b<6? (0 ou 1)
# c >= 7 
            slti    $t7, $t2, 7     # $t7 <- c<7? (0 ou 1)
            addiu   $t4, $zero, 1   # $t4 <- 1 
            subu    $t7, $t4, $t7   # $t7 <- NOT($t7)     

# (b < 6) | (c >= 7)
            or      $t8, $t6, $t7   # (b < 6) | (c >= 7)
# (a == 0) && ((b < 6) || (c >= 7))
            and     $t8, $t5, $t8   # (a == 0) && ((b < 6) || (c >= 7))
# if ((a == 0) && ((b < 6) || (c >= 7))) {
            bne     $t8, $zero, if_codigo_V
# se a condição de if é falsa
if_codigo_F:
#     d = 1;
            la      $t4, var_d      # $t4 <- endereço da variável d
            li      $t3, 1          # $t3 <- 1
            sw      $t3, 0($t4)     # d = 0
# se a condição da construção if é verdadeira
if_codigo_V: 
#     d = 0;
            la      $t4, var_d      # $t4 <- endereço da variável d
            li      $t3, 0          # $t3 <- 0
            sw      $t3, 0($t4)     # d = 0
if_fim:
# epílogo
# return 0;
            # não utilizamos a pilha
            jr		$ra             # retornamos ao procedimento chamador
            
