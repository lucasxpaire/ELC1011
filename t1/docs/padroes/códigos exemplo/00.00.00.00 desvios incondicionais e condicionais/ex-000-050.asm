#*******************************************************************************
# ex-000-050.asm              Copyright (C) 2022 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Tradução de:
# int a;
#
# int main(void)
# {
#     a = 0;      // inicializamos a com 0
# l0:             // inicio do laço infinito
#     a = a + 1;  // incrementamos a
#     goto l0;    // desvio incondicional para l0
#     return 0;   // fim do programa. Esta instrução não é executada
# }
#*******************************************************************************


#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #


.text
.globl      main
main:
# a = 0;    
            la    $t0, varA     # $t0 <- endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0
                                # para zerarmos um registrador poderíamos ter usado outras instruções:
                                # add   $s0, $zero, $zero
                                # addi  $s0, $zero, 0
                                # sub   $s0, $s0, $s0
            sw    $s0, 0($t0)   # a = 0
#l0:
l0:                             # inicio do laço infinito
# a = a + 1;  // incrementamos a
            addi  $s0, $s0, 1   # $s0 <- a + 1
            sw    $s0, 0($t0)   # a = a + 1
# goto l0;    // desvio incondicional para l0
            j     l0            # desvio incondicional para l0           
# return 0;   // fim do programa. 
            addi  $v0, $zero, 17 # $v0 = serviço 17 - exit2
            addi  $a0, $zero, 0 #  $a0 = valor de retorno do programa: 0 - sucesso
            syscall             # chamada ao serviço 17 do sistema - exit2
.data 
#   int a;
varA:       .word 0             # variável a

