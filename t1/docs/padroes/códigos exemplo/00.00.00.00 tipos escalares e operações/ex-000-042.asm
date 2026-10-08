########################################################################################################################
# Descrição: Implementação em MIPS32 das operações:
#            variavelA = variavelB + 1;
#            variavelC = variavelB + 1000000;
#            Todas as variáveis são globais.
# Autor    : Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail   : giovani.baratto@ufsm.br
########################################################################################################################
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                           #

.text       # Segmento de texto (código executável)

# variavelA = variavelB + 1;
            # Carregar o endereço da variável global variavelB no registrador $t0
            la      $t0, variavelB              # $t0 <- endereço de variavelB
            # Carregar o valor armazenado em variavelB para o registrador $t1
            lw      $t1, 0($t0)                 # $t1 <- valor de variavelB
            # Somar 1 ao valor de variavelB e armazenar o resultado no registrador $t2
            addi    $t2, $t1, 1                 # $t2 <- variavelB + 1
            # Carregar o endereço da variável global variavelA no registrador $t0
            la      $t0, variavelA              # $t0 <- endereço de variavelA
            # Armazenar o valor de $t2 (variavelB + 1) na variável global variavelA
            sw      $t2, 0($t0)                 # variavelA <- $t2 = variavelB + 1 

# variavelC = variavelB + 1000000;
            # Construir a constante 1000000 no registrador $t3
            # O valor 1000000 (0x000F_4240) é muito grande para ser usado diretamente
            lui     $t3, 0x000F                 # $t3 <- 0x000F_0000 (carrega a parte alta do número)
            ori     $t3, $t3, 0x4240            # $t3 <- 0x000F_4240 (adiciona a parte baixa do número)
            # Nota: A pseudoinstrução "li $t3, 1000000" poderia ser usada para simplificar.
            # Somar o valor de variavelB (já armazenado em $t1) com a constante 1000000
            add     $t4, $t1, $t3               # $t4 <- variavelB + 1000000
            # Carregar o endereço da variável global variavelC no registrador $t0
            la      $t0, variavelC              # $t0 <- endereço de variavelC
            # Armazenar o valor de $t4 (variavelB + 1000000) na variável global variavelC
            sw      $t4, 0($t0)                 # variavelC <- $t4 = variavelB + 1000000

.data       # Segmento de dados (variáveis globais)
# Declaração das variáveis globais
# int variavelA;                
# int variavelB = 1234;         
# int variavelC;                
variavelA:  .word 0                             # variável A inicializada com 0
variavelB:  .word 1234                          # variável B inicializada com 1234
variavelC:  .word 0                             # variável C inicializada com 0
