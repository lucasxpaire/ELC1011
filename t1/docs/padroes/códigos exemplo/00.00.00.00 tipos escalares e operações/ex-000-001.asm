#######################################################################################################################
# Descrição : Tradução da operação:
#             variavelA = variavelB + variavelC;
#             Todas as variáveis são globais.
# Autor     : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail    : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #


.data
# Declaração das variáveis globais
# int variavelA;
# int variavelB = 1;
# int variavelC = 2;
variavelA:  .word  0                            # variável inteira A. Por padrão, as variáveis globais são inicializadas com 0
variavelB:  .word  1                            # variável inteira B, inicializada com 1
variavelC:  .word  2                            # variável inteira C, inicializada com 2

.text

# *** Mapeamento dos registradores ***
# Registrador  | Variável associada
# ---------------------------------
# $s1          | variavelA
# $s2          | variavelB
# $s3          | variavelC

# Início do programa
main:
            # Carregar os valores das variáveis globais nos registradores
            la      $t0, variavelB              # Carregar o endereço de variavelB em $t0
            lw      $s2, 0($t0)                 # Carregar o valor de variavelB em $s2

            la      $t0, variavelC              # Carregar o endereço de variavelC em $t0
            lw      $s3, 0($t0)                 # Carregar o valor de variavelC em $s3

            # Realizar a soma: variavelA = variavelB + variavelC
            add     $s1, $s2, $s3               # $s1 <- $s2 + $s3 (variavelA = variavelB + variavelC)

            # Armazenar o resultado de variavelA na memória
            la      $t0, variavelA              # Carregar o endereço de variavelA em $t0
            sw      $s1, 0($t0)                 # Armazenar o valor de $s1 em variavelA



