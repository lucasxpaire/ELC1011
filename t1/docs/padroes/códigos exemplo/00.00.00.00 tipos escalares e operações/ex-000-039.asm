########################################################################################################################
# Descrição: Exemplo que demonstra como:
#     (a) carregar dados da memória para registradores do processador MIPS
#     (b) armazenar dados de registradores na memória
#     Os dados utilizados incluem uma palavra (4 bytes), uma meia palavra (2 bytes) e um byte.
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #

.text
# Exemplo de como carregar dados de um endereço de memória para registradores
            # Carrega o endereço base da variável 'memory' no registrador $s0
            la      $s0, memory                 # $s0 <- endereço base da variável memory
            
            # Carrega uma palavra (4 bytes) da memória para o registrador $t0 com extensão de sinal
            lw      $t0, 0($s0)                 # $t0 <- mem[$s0+0] (conteúdo de 'memory')
            # Nota: Poderíamos usar a pseudo-instrução: lw $t0, memory
            
            # Carrega uma meia palavra (2 bytes) da memória para o registrador $t1 com extensão de sinal
            lh      $t1, 0($s0)                 # $t1 <- mem[$s0+0] (16 bits com extensão de sinal)
            
            # Carrega um byte da memória para o registrador $t2 com extensão de sinal
            lb      $t2, 0($s0)                 # $t2 <- mem[$s0+0] (8 bits com extensão de sinal)
            
            # Carrega uma meia palavra (2 bytes) da memória para o registrador $t3 sem extensão de sinal
            lhu     $t3, 0($s0)                 # $t3 <- mem[$s0+0] (16 bits sem extensão de sinal)
            
            # Carrega um byte da memória para o registrador $t4 sem extensão de sinal
            lbu     $t4, 0($s0)                 # $t4 <- mem[$s0+0] (8 bits sem extensão de sinal)
            
# Exemplo de como armazenar dados de registradores em endereços de memória
            # Armazena o valor do registrador $t0 (palavra completa) no endereço 'dataw'
            la    $s0, dataw                    # Carrega o endereço de 'dataw' no registrador $s0
            sw    $t0, 0($s0)                   # mem[$s0+0] <- $t0 (armazena 32 bits)
            # Nota: Poderíamos usar a pseudo-instrução: sw $t0, dataw
            
            # Armazena os dois bytes menos significativos de $t1 (meia palavra) no endereço 'datah'
            la    $s0, datah                    # Carrega o endereço de 'datah' no registrador $s0
            sh    $t1, 0($s0)                   # mem[$s0+0] <- $t1 (armazena 16 bits)
            # Nota: Poderíamos usar a pseudo-instrução: sh $t1, datah
            
            # Armazena o byte menos significativo de $t2 no endereço 'datab'
            la    $s0, datab                    # Carrega o endereço de 'datab' no registrador $s0
            sb    $t2, 0($s0)                   # mem[$s0+0] <- $t2 (armazena 8 bits)
            # Nota: Poderíamos usar a pseudo-instrução: sb $t2, datab

.data 
# Declaração de variáveis na memória
memory:     .word  0xABCDE080                   # Variável 'memory' inicializada com 0xABCDE080 (formato little endian)

dataw:      .word 0                             # Variável 'dataw' para armazenar uma palavra (32 bits)
datah:      .half 0                             # Variável 'datah' para armazenar uma meia palavra (16 bits)
datab:      .byte 0                             # Variável 'datab' para armazenar um byte (8 bits)
