########################################################################################################################
# Descrição: traduzindo a operação:
#            vetorA[2] = vetorA[4] + vetorA[1];
#            VetorA é um vetor global de inteiros, com 10 elementos e valores iniciais de 0 a 9.
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #


.text                                           # Segmento de texto: contém o código executável
# vetorA[2] = vetorA[4] + vetorA[1];
            # Para acessar um elemento do vetor, usamos a fórmula:
            # endereço_elemento_i = endereço_base + (i * tamanho_em_bytes_do_elemento)
            # Onde:
            # - endereço_base é o endereço inicial do vetor.
            # - i é o índice do elemento no vetor.
            # - tamanho_em_bytes_do_elemento é o tamanho de cada elemento (4 bytes para inteiros).
            
            # Carregamos o endereço base do vetor vetorA no registrador $t0.
            la      $t0, vetorA                 # $t0 <- endereço base de vetorA
            
            # Carregamos o valor do elemento vetorA[4] no registrador $t1.
            # O deslocamento para vetorA[4] é 4 * 4 = 16 bytes.
            lw      $t1, 16($t0)                # $t1 <- vetorA[4]
            
            # Carregamos o valor do elemento vetorA[1] no registrador $t2.
            # O deslocamento para vetorA[1] é 1 * 4 = 4 bytes.
            lw      $t2, 4($t0)                 # $t2 <- vetorA[1]
            
            # Realizamos a soma dos valores armazenados em $t1 e $t2.
            add     $t3, $t1, $t2               # $t3 <- vetorA[4] + vetorA[1]
            
            # Armazenamos o resultado da soma no elemento vetorA[2].
            # O deslocamento para vetorA[2] é 2 * 4 = 8 bytes.
            sw      $t3, 8($t0)                 # vetorA[2] = vetorA[4] + vetorA[1]

.data                                           # Segmento de dados: contém as variáveis globais
# Declaração do vetorA como um vetor de inteiros (4 bytes por elemento).
# int vetorA[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

vetorA: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

