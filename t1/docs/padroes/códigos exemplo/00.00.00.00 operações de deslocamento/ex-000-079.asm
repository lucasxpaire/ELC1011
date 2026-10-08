#*******************************************************************************
# exercicio0.s               Copyright (C) 2021Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Mostramos como usar operações de deslocamento para multiplicar e dividir
# um número sem sinal por 2^(n). Um deslocamento para a esquerda de n bits corresponde
# a uma multiplicação por 2^(n). Um deslocamento para a direita de n bits corresponde a
# uma divisão por 2^(n) bits.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    15.12.2021     GBTO   versão inicial
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                   #
.text
.globl      main
main:
# Para os testes vamos usar o registrador $t0, com o valor 10000 = 0x00002710
            lui     $t0, 0x0000        # $t0 <- 0x0000
            ori     $t0, $t0, 0x2710    # $t0 <- 0x00002710 = 10000

# vamos usar operações de deslocamento para multiplicarmos o valor de $t0 por 2^(6) = 64
# cada deslocamento para a esquerda corresponde a uma multiplicação sem sinal. Para um
# número sem sinal, cada deslocamento de 1 bit para a esquerda corresponde a uma
# multiplicação por 2. Se desejamos multiplicar por 2^(n) um número sem sinal, realizamos
# o deslocamento de n bits para a esquerda.
            sll     $t0, $t0, 6         # ($t0 = 0x00002710) << 6 : $t0 -> 0x0009C400 = 640000
# A divisão de um número sem sinal por 2^(n) pode ser realizada com um deslocamento lógico
# para a direita de n bits. Vamos dividir o valor de $t0 = 0x0009C400 = 640000 por 8 = 2^(3).
            srl     $t0, $t0, 3         # ($t0 = 0x0009C400) >> 3 : $t0 -> 0x00013880 = 80000
.data 

