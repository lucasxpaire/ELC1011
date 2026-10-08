########################################################################################################################
# Descrição: Traduzindo:
#            variavelA = 10;
#            variavelB = 1000000;
#            As variáveis variavelA e variavelB são globais do tipo int.
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #


.text
# Atribuindo o valor 10 à variável variavelA
# Este valor pode ser representado com 16 bits (0x0000_000A)
            addiu $t0, $zero, 10    # Carrega o valor 10 no registrador $t0
            # Alternativamente, poderíamos usar a pseudoinstrução:
            # li $t0, 10            # Carrega o valor 10 no registrador $t0
            la    $t1, variavelA    # Carrega o endereço de variavelA no registrador $t1
            sw    $t0, 0($t1)       # Armazena o valor de $t0 (10) na posição de memória de variavelA

# Atribuindo o valor 1000000 à variável variavelB
# Este valor requer 32 bits para ser representado (0x000F_4240)
            lui   $t0, 0x000F       # Carrega a parte alta (16 bits mais significativos) de 1000000 em $t0
            ori   $t0, $t0, 0x4240  # Adiciona a parte baixa (16 bits menos significativos) ao valor em $t0
            # Alternativamente, poderíamos usar a pseudoinstrução:
            # li $t0, 1000000       # Carrega o valor 1000000 diretamente no registrador $t0
            la    $t1, variavelB    # Carrega o endereço de variavelB no registrador $t1
            sw    $t0, 0($t1)       # Armazena o valor de $t0 (1000000) na posição de memória de variavelB

.data
# Declaração das variáveis globais
# int variavelA;
# int variavelB;

variavelA:  .word 0                # Reserva espaço para variavelA e inicializa com 0
variavelB:  .word 0                # Reserva espaço para variavelB e inicializa com 0
