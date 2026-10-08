#*******************************************************************************
# exercicio0.s               Copyright (C) 2021 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Mostramos como usar operações de deslocamento para isolar e ajustar
# um grupo de bits para uma posição.
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
# Para os testes vamos usar o registrador $t0, com o valor 0xABCDEF98
            lui     $t0, 0xABCD         # $t0 <- 0xABCD
            ori     $t0, $t0, 0xEF98    # $t0 <- 0xABCDEF98
# vamos usar operações de deslocamento para isolarmos D e colocarmos na posição de F:
# 0xABCDEF98 -> 0x00000D00
# 1) Fazemos um deslocamento lógico para a esquerda de 12 bits ($t0<<12)
            sll     $t0, $t0, 12        # ($t0 = 0xABCDEF98) << 12 : $t0 -> 0xDEF98000
# 2) Deslocamos 28 bits para a direita
            srl     $t0, $t0, 28        # ($t0 = 0xDEF98000) >> 28 : $t0 -> 0x0000000D
# 3) Realizamos um deslocamento lógico para a esqueda de 8 bits
            sll     $t0, $t0, 8         # ($t0 = 0x0000000D) << 8  : $t0 -  0x00000D00
.data 

