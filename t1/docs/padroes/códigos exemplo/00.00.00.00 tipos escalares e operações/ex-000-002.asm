#######################################################################################################################
# Descrição: traduzimos o seguinte trecho de código:
#            variavelA = variavelB + variavelC + variavelD + variavelE;
#            Todas estas variáveis são globais. As variáveis variavelB a 
#            variavelE são feitas inicialmente iguais a 1, 2, 3 e 4 respectivamente.
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #

.text                                           # Segmento de texto: contém o código executável

# *** Mapa dos Registradores ***
# Registrador | Variável    | Descrição
# --------------------------------------
# $s1         | variavelA   | Resultado final da soma
# $s2         | variavelB   | Valor inicial: 1
# $s3         | variavelC   | Valor inicial: 2
# $s4         | variavelD   | Valor inicial: 3
# $s5         | variavelE   | Valor inicial: 4

            # Carregamos os valores das variáveis globais da memória para os registradores
            la      $t0, variavelB              # Carrega o endereço de variavelB em $t0
            lw      $s2, 0($t0)                 # Carrega o valor de variavelB em $s2
            la      $t0, variavelC              # Carrega o endereço de variavelC em $t0
            lw      $s3, 0($t0)                 # Carrega o valor de variavelC em $s3
            la      $t0, variavelD              # Carrega o endereço de variavelD em $t0
            lw      $s4, 0($t0)                 # Carrega o valor de variavelD em $s4
            la      $t0, variavelE              # Carrega o endereço de variavelE em $t0
            lw      $s5, 0($t0)                 # Carrega o valor de variavelE em $s5

            # Realizamos a soma das variáveis
            add     $t0, $s2, $s3               # Soma variavelB ($s2) e variavelC ($s3), resultado em $t0
            add     $t1, $s4, $s5               # Soma variavelD ($s4) e variavelE ($s5), resultado em $t1
            add     $s1, $t0, $t1               # Soma os resultados intermediários ($t0 e $t1), resultado final em $s1

            # Armazenamos o resultado final (variavelA) de volta na memória
            la      $t0, variavelA              # Carrega o endereço de variavelA em $t0
            sw      $s1, 0($t0)                 # Armazena o valor de $s1 (resultado final) em variavelA

.data                               # Segmento de dados: contém as variáveis globais
# Declaração e inicialização das variáveis globais
variavelA:          .word  0                    # Variável inteira variavelA, inicializada com 0
variavelB:  .word  1                            # Variável inteira variavelB, inicializada com 1
variavelC:  .word  2                            # Variável inteira variavelC, inicializada com 2
variavelD:  .word  3                            # Variável inteira variavelD, inicializada com 3
variavelE:  .word  4                            # Variável inteira variavelE, inicializada com 4
