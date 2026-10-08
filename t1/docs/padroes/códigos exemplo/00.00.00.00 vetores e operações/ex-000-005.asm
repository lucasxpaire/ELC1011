########################################################################################################################
# Descrição: Este trecho de programa atribui valores a variáveis:
#               variavel_I = 1;
#               variavel_J = 2;
#               variavel_K = 0;
#            Realiza a operação com elementos de um vetor:
#               vetorA[variavel_K] = vetorA[variavel_I] + vetorA[variavel_J];
#            Todas as variáveis usadas no programa são globais
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #

.text                                           # Segmento de texto: contém o código executável
main: 
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $s0   | variavel_I (índice I do vetor)                |
# | $s1   | variavel_J (índice J do vetor)                |
# | $s2   | variavel_K (índice K do vetor)                |
# | $t0   | endereço base do vetor vetorA                 |
# | $t1   | endereço de vetorA[i], vetorA[j] ou vetorA[k] |
# | $t2   | valor de vetorA[i]                            |
# | $t3   | valor de vetorA[j]                            |
# | $t4   | soma de vetorA[i] e vetorA[j]                 |
# +-------+-----------------------------------------------+

# Inicialização das variáveis globais
# variavel_I = 1;
            addi    $s0, $zero, 1               # Carrega o valor 1 no registrador $s0 (variavel_I)
            la      $t0, variavel_I             # Carrega o endereço de variavel_I no registrador $t0
            sw      $s0, 0($t0)                 # Armazena o valor de $s0 em variavel_I na memória

# variavel_J = 2;
            addi    $s1, $zero, 2               # Carrega o valor 2 no registrador $s1 (variavel_J)
            la      $t0, variavel_J             # Carrega o endereço de variavel_J no registrador $t0
            sw      $s1, 0($t0)                 # Armazena o valor de $s1 em variavel_J na memória

# variavel_K = 0;
            addi    $s2, $zero, 0               # Carrega o valor 0 no registrador $s2 (variavel_K)
                                                # Alternativamente: add $s2, $zero, $zero ou xor $s2, $s2, $s2
            la      $t0, variavel_K             # Carrega o endereço de variavel_K no registrador $t0
            sw      $s2, 0($t0)                 # Armazena o valor de $s2 em variavel_K na memória
            
# vetorA[k] = vetorA[i] + vetorA[j]
# Calcula o endereço efetivo e realiza a soma
            la      $t0, vetorA                 # Carrega o endereço base do vetor vetorA no registrador $t0
    
            # Carrega o valor de vetorA[i]
            sll     $t1, $s0, 2                 # Calcula o deslocamento: variavel_I * 4 (4 é o tamanho de um inteiro em bytes)
            add     $t1, $t0, $t1               # Soma o deslocamento ao endereço base para obter o endereço de vetorA[i]
            lw      $t2, 0($t1)                 # Carrega o valor de vetorA[i] no registrador $t2

            # Carrega o valor de vetorA[j]
            sll     $t1, $s1, 2                 # Calcula o deslocamento: variavel_J * 4
            add     $t1, $t0, $t1               # Soma o deslocamento ao endereço base para obter o endereço de vetorA[j]
            lw      $t3, 0($t1)                 # Carrega o valor de vetorA[j] no registrador $t3
            
            # Soma os valores de vetorA[i] e vetorA[j]
            add     $t4, $t2, $t3               # Soma os valores: $t4 = vetorA[i] + vetorA[j]
            
            # Armazena o resultado em vetorA[k]
            sll     $t1, $s2, 2                 # Calcula o deslocamento: variavel_K * 4
            add     $t1, $t0, $t1               # Soma o deslocamento ao endereço base para obter o endereço de vetorA[k]
            sw      $t4, 0($t1)                 # Armazena o resultado da soma em vetorA[k]

.data                                           # Segmento de dados: contém as variáveis globais
# Declaração das variáveis globais
# int variavel_I;
# int variavel_J;
# int variavel_K;
variavel_I: .word 0                             # Inicializa variavel_I com 0
variavel_J: .word 0                             # Inicializa variavel_J com 0
variavel_K: .word 0                             # Inicializa variavel_K com 0

# Declaração do vetor
# int vetorA[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
vetorA:     .word  0, 1, 2, 3, 4, 5, 6, 7, 8, 9 # Inicializa vetorA com valores de 0 a 9
