########################################################################################################################
# Descrição: Traduzindo a operação:
#            variavelA = variavelB;
#            As variáveis são globais.
#            Este exemplo demonstra como carregar e armazenar valores em memória
#            usando registradores no processador MIPS.
#
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #

.text
            # ...
# Traduzindo a operação: variavelA = variavelB;
# Passo 1: Carregar o endereço de variavelB no registrador $t0
            la    $t0, variavelB    # $t0 <- endereço de variavelB
# Passo 2: Carregar o valor armazenado em variavelB para o registrador $t1
            lw    $t1, 0($t0)       # $t1 <- valor de variavelB
# Passo 3: Carregar o endereço de variavelA no registrador $t0
            la    $t0, variavelA    # $t0 <- endereço de variavelA
# Passo 4: Armazenar o valor de $t1 (valor de variavelB) no endereço de variavelA
            sw    $t1, 0($t0)       # variavelA <- valor de $t1 (variavelB)
            # ...
.data
# Declaração das variáveis globais
# variavelA: variável inteira inicializada com 0
# variavelB: variável inteira inicializada com 1234

variavelA:  .word 0                 # Espaço reservado para variavelA (4 bytes)
variavelB:  .word 1234              # Inicializa variavelB com o valor 1234
