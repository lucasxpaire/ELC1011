#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Procedimentos utilitários de manipulação de strings e derivação
#            de chave criptográfica de 16 bits para o algoritmo S-AES.
# Assembler: MARS
#*******************************************************************************

.text
.globl remove_quebra_linha
.globl deriva_chave

###############################################################################
# Procedimento: remove_quebra_linha
# Descrição: Remove caracteres delimitadores de fim de linha ('\n' = 10 e '\r' = 13)
#            inseridos pelo serviço 8 do sistema, substituindo por '\0'.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | endereço base da string terminada em nulo     |
# | $t0   | ponteiro para o caractere atual da string     |
# | $t1   | caractere lido da memória                     |
# | $t2   | constante de comparação (10 para '\n' e 13)   |
# | $v0   | comprimento da string útil retornado          |
# +-------+-----------------------------------------------+
###############################################################################
remove_quebra_linha:
# corpo do procedimento
            move    $t0, $a0            # $t0 <- ponteiro para o início da string
            li      $v0, 0              # $v0 <- contador de caracteres = 0

laco_varre_string:
            lbu     $t1, 0($t0)         # carrega byte da posição atual
            beqz    $t1, fim_varredura  # se encontrou '\0', encerra

            # Verifica caractere '\n' (código ASCII 10)
            li      $t2, 10             # $t2 <- 10 ('\n')
            beq     $t1, $t2, trunca_delimitador

            # Verifica caractere '\r' (código ASCII 13)
            li      $t2, 13             # $t2 <- 13 ('\r')
            beq     $t1, $t2, trunca_delimitador

            addi    $t0, $t0, 1         # avança para o próximo caractere
            addi    $v0, $v0, 1         # incrementa o comprimento útil
            j       laco_varre_string   # repete o laço

trunca_delimitador:
            sb      $zero, 0($t0)       # substitui o delimitador por '\0'

fim_varredura:
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: deriva_chave
# Descrição: Converte uma string de tamanho qualquer em uma chave de 16 bits
#            para o algoritmo S-AES através da técnica de dobramento por XOR.
#            - Byte Alto (bits 15..8): XOR de caracteres de índices pares (0, 2, 4...)
#            - Byte Baixo (bits 7..0): XOR de caracteres de índices ímpares (1, 3, 5...)
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | endereço da string da senha terminada em nulo |
# | $t0   | ponteiro para o caractere atual               |
# | $t1   | acumulador do byte alto (índices pares)       |
# | $t2   | acumulador do byte baixo (índices ímpares)    |
# | $t3   | índice do caractere atual (0, 1, 2, 3...)     |
# | $t4   | valor do caractere lido                       |
# | $t5   | indicador de paridade do índice (bit 0)       |
# | $v0   | chave de 16 bits gerada                       |
# +-------+-----------------------------------------------+
###############################################################################
deriva_chave:
# corpo do procedimento
            move    $t0, $a0            # $t0 <- endereço inicial da senha
            li      $t1, 0              # $t1 <- acumulador par = 0
            li      $t2, 0              # $t2 <- acumulador ímpar = 0
            li      $t3, 0              # $t3 <- índice inicial = 0

laco_deriva_chave:
            lbu     $t4, 0($t0)         # lê caractere da memória
            beqz    $t4, fim_derivacao  # se atingiu '\0', encerra

            # Testa se o índice é par ou ímpar (isolando o bit menos significativo)
            andi    $t5, $t3, 1         # $t5 <- bit 0 do índice
            beqz    $t5, acumula_par    # se for zero, o índice é par

            # Índice ímpar: acumula em $t2
            xor     $t2, $t2, $t4       # $t2 <- $t2 ^ caractere
            j       avanca_indice

acumula_par:
            # Índice par: acumula em $t1
            xor     $t1, $t1, $t4       # $t1 <- $t1 ^ caractere

avanca_indice:
            addi    $t0, $t0, 1         # avança ponteiro da string
            addi    $t3, $t3, 1         # incrementa índice
            j       laco_deriva_chave   # repete o laço

fim_derivacao:
            # Garante que cada acumulador contenha exatamente 8 bits
            andi    $t1, $t1, 0xFF      # isola byte alto
            andi    $t2, $t2, 0xFF      # isola byte baixo

            # Concatena em uma palavra de 16 bits: (t1 << 8) | t2
            sll     $v0, $t1, 8         # $v0 <- byte alto posicionado nos bits 15..8
            or      $v0, $v0, $t2       # $v0 <- concatena byte baixo nos bits 7..0
            jr      $ra                 # retorna ao procedimento chamador
