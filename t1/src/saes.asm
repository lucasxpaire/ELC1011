#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Núcleo de criptografia e descriptografia do algoritmo S-AES.
#            Contém os procedimentos de expansão de chave, substituição de nibbles,
#            permutação de linhas, mistura de colunas, cifra e decifra de blocos.
# Assembler: MARS
#*******************************************************************************

.text
.globl expande_chave
.globl cifra_bloco
.globl decifra_bloco
.globl substitui_nibbles
.globl substitui_nibbles_inv
.globl desloca_linhas
.globl desloca_linhas_inv
.globl mistura_colunas
.globl mistura_colunas_inv

###############################################################################
# Procedimento: expande_chave
# Descrição: Expande a chave mestre de 16 bits em 3 subchaves (K0, K1 e K2).
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | chave mestre de 16 bits (0x0000..0xFFFF)      |
# | $a1   | endereço base para o vetor de subchaves       |
# | $s0   | chave mestre preservada                       |
# | $s1   | ponteiro base do vetor de subchaves           |
# | $t0   | palavra w0 (byte mais significativo de K0)    |
# | $t1   | palavra w1 (byte menos significativo de K0)   |
# | $t3   | palavra w2 (byte alto de K1)                  |
# | $t4   | palavra w3 (byte baixo de K1)                 |
# | $t5   | subchave K1 completa de 16 bits               |
# | $t7   | palavra w4 (byte alto de K2)                  |
# | $t8   | palavra w5 (byte baixo de K2)                 |
# | $t9   | subchave K2 completa de 16 bits               |
# | $v0   | subchave K0 retornada (16 bits)               |
# | $v1   | subchave K1 retornada (16 bits)               |
# +-------+-----------------------------------------------+
#
# *** Mapa da pilha ***
# +----------------------------------+
# | Registrador | Endereço na Pilha  |
# +----------------------------------+
# | $ra         | $sp + 20           |
# | $s0         | $sp + 16           |
# | $s1         | $sp + 12           |
# | $s2         | $sp + 8            |
# | $s3         | $sp + 4            |
# | $s4         | $sp + 0            |
# +----------------------------------+
###############################################################################
expande_chave:
# prólogo
            addi    $sp, $sp, -24       # aloca espaço na pilha para 6 palavras
            sw      $ra, 20($sp)        # salva endereço de retorno
            sw      $s0, 16($sp)        # salva $s0
            sw      $s1, 12($sp)        # salva $s1
            sw      $s2, 8($sp)         # salva $s2
            sw      $s3, 4($sp)         # salva $s3
            sw      $s4, 0($sp)         # salva $s4

# corpo do procedimento
            bnez    $a1, exp_destino_ok # se $a1 != 0 usa o endereço fornecido
            la      $a1, subchaves      # caso contrário, carrega o endereço padrão
exp_destino_ok:
            move    $s0, $a0            # $s0 <- chave mestre K
            move    $s1, $a1            # $s1 <- ponteiro para subchaves

            # Extração de w0 e w1 a partir da chave mestre
            srl     $t0, $s0, 8         # desloca 8 bits para a direita
            andi    $t0, $t0, 0xFF      # $t0 <- w0 (bits 15..8 de K)

            andi    $t1, $s0, 0xFF      # $t1 <- w1 (bits 7..0 de K)

            # Subchave K0 = (w0 << 8) | w1 = K
            sh      $s0, 0($s1)         # subchaves[0] <- K0

            # Cálculo de w2 e w3 (Subchave K1)
            # w2 = w0 ^ RCON(1) ^ SubNib(RotNib(w1)), onde RCON(1) = 0x80
            move    $a0, $t1            # $a0 <- w1
            jal     rotaciona_substitui_byte # $v0 <- SubNib(RotNib(w1))
            move    $t2, $v0            # $t2 <- resultado da transformação

            xor     $t3, $t0, 0x80      # $t3 <- w0 ^ RCON(1)
            xor     $t3, $t3, $t2       # $t3 <- w0 ^ RCON(1) ^ rot_sub(w1)
            andi    $t3, $t3, 0xFF      # $t3 <- w2

            # w3 = w2 ^ w1
            xor     $t4, $t3, $t1       # $t4 <- w2 ^ w1
            andi    $t4, $t4, 0xFF      # $t4 <- w3

            # Subchave K1 = (w2 << 8) | w3
            sll     $t5, $t3, 8         # $t5 <- w2 << 8
            or      $t5, $t5, $t4       # $t5 <- (w2 << 8) | w3
            sh      $t5, 2($s1)         # subchaves[1] <- K1

            # Cálculo de w4 e w5 (Subchave K2)
            # w4 = w2 ^ RCON(2) ^ SubNib(RotNib(w3)), onde RCON(2) = 0x30
            move    $a0, $t4            # $a0 <- w3
            jal     rotaciona_substitui_byte # $v0 <- SubNib(RotNib(w3))
            move    $t6, $v0            # $t6 <- resultado da transformação

            xor     $t7, $t3, 0x30      # $t7 <- w2 ^ RCON(2)
            xor     $t7, $t7, $t6       # $t7 <- w2 ^ RCON(2) ^ rot_sub(w3)
            andi    $t7, $t7, 0xFF      # $t7 <- w4

            # w5 = w4 ^ w3
            xor     $t8, $t7, $t4       # $t8 <- w4 ^ w3
            andi    $t8, $t8, 0xFF      # $t8 <- w5

            # Subchave K2 = (w4 << 8) | w5
            sll     $t9, $t7, 8         # $t9 <- w4 << 8
            or      $t9, $t9, $t8       # $t9 <- (w4 << 8) | w5
            sh      $t9, 4($s1)         # subchaves[2] <- K2

            # Valores de retorno
            move    $v0, $s0            # $v0 <- K0
            move    $v1, $t5            # $v1 <- K1

# epílogo
            lw      $s4, 0($sp)         # restaura $s4
            lw      $s3, 4($sp)         # restaura $s3
            lw      $s2, 8($sp)         # restaura $s2
            lw      $s1, 12($sp)        # restaura $s1
            lw      $s0, 16($sp)        # restaura $s0
            lw      $ra, 20($sp)        # restaura $ra
            addi    $sp, $sp, 24        # libera espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: rotaciona_substitui_byte
# Descrição: Troca os dois nibbles de um byte (RotNib) e aplica a S-Box (SubNib).
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | byte de entrada de 8 bits [n_alto, n_baixo]   |
# | $t8   | nibble mais significativo original            |
# | $t9   | nibble menos significativo original           |
# | $v1   | endereço base da tabela_sbox                  |
# | $v0   | byte resultante após substituição             |
# +-------+-----------------------------------------------+
###############################################################################
rotaciona_substitui_byte:
# corpo do procedimento
            srl     $t8, $a0, 4         # desloca 4 bits para a direita
            andi    $t8, $t8, 0x0F      # $t8 <- nibble mais significativo original
            andi    $t9, $a0, 0x0F      # $t9 <- nibble menos significativo original

            la      $v1, tabela_sbox    # $v1 <- endereço base da tabela_sbox

            # S-Box aplicada ao nibble inferior (torna-se o superior)
            addu    $v0, $v1, $t9       # $v0 <- endereço do elemento na S-Box
            lbu     $t9, 0($v0)         # $t9 <- S(n_baixo)

            # S-Box aplicada ao nibble superior (torna-se o inferior)
            addu    $v0, $v1, $t8       # $v0 <- endereço do elemento na S-Box
            lbu     $t8, 0($v0)         # $t8 <- S(n_alto)

            sll     $v0, $t9, 4         # posiciona o novo nibble alto
            or      $v0, $v0, $t8       # $v0 <- (S(n_baixo) << 4) | S(n_alto)
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: substitui_nibbles
# Descrição: Substitui os 4 nibbles de um bloco de 16 bits usando a S-Box.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de 16 bits de entrada                   |
# | $t0   | endereço base da tabela_sbox                  |
# | $t1   | nibble 0 (bits 15..12) substituído            |
# | $t2   | nibble 1 (bits 11..8) substituído             |
# | $t3   | nibble 2 (bits 7..4) substituído              |
# | $t4   | nibble 3 (bits 3..0) substituído              |
# | $v0   | bloco de 16 bits com nibbles substituídos     |
# +-------+-----------------------------------------------+
###############################################################################
substitui_nibbles:
# corpo do procedimento
            la      $t0, tabela_sbox    # $t0 <- endereço base da tabela_sbox

            # Nibble 0 (bits 15..12) - posição S00
            srl     $t1, $a0, 12        # desloca nibble 0 para posição menos significativa
            andi    $t1, $t1, 0x0F      # isola 4 bits
            addu    $t5, $t0, $t1       # calcula endereço efetivo na tabela
            lbu     $t1, 0($t5)         # $t1 <- tabela_sbox[nibble 0]

            # Nibble 1 (bits 11..8) - posição S10
            srl     $t2, $a0, 8         # desloca nibble 1
            andi    $t2, $t2, 0x0F      # isola 4 bits
            addu    $t5, $t0, $t2       # calcula endereço na tabela
            lbu     $t2, 0($t5)         # $t2 <- tabela_sbox[nibble 1]

            # Nibble 2 (bits 7..4) - posição S01
            srl     $t3, $a0, 4         # desloca nibble 2
            andi    $t3, $t3, 0x0F      # isola 4 bits
            addu    $t5, $t0, $t3       # calcula endereço na tabela
            lbu     $t3, 0($t5)         # $t3 <- tabela_sbox[nibble 2]

            # Nibble 3 (bits 3..0) - posição S11
            andi    $t4, $a0, 0x0F      # isola nibble 3
            addu    $t5, $t0, $t4       # calcula endereço na tabela
            lbu     $t4, 0($t5)         # $t4 <- tabela_sbox[nibble 3]

            # Reconstrução da palavra de 16 bits
            sll     $v0, $t1, 12        # posiciona nibble 0 nos bits 15..12
            sll     $t6, $t2, 8         # posiciona nibble 1 nos bits 11..8
            or      $v0, $v0, $t6       # concatena
            sll     $t6, $t3, 4         # posiciona nibble 2 nos bits 7..4
            or      $v0, $v0, $t6       # concatena
            or      $v0, $v0, $t4       # concatena nibble 3 nos bits 3..0
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: substitui_nibbles_inv
# Descrição: Substitui os 4 nibbles de um bloco usando a tabela inversa (InvS-Box).
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de 16 bits de entrada                   |
# | $t0   | endereço base da tabela_inv_sbox              |
# | $t1   | nibble 0 substituído                          |
# | $t2   | nibble 1 substituído                          |
# | $t3   | nibble 2 substituído                          |
# | $t4   | nibble 3 substituído                          |
# | $v0   | bloco de 16 bits restaurado                   |
# +-------+-----------------------------------------------+
###############################################################################
substitui_nibbles_inv:
# corpo do procedimento
            la      $t0, tabela_inv_sbox # $t0 <- endereço base da tabela_inv_sbox

            # Nibble 0 (bits 15..12)
            srl     $t1, $a0, 12
            andi    $t1, $t1, 0x0F
            addu    $t5, $t0, $t1
            lbu     $t1, 0($t5)         # $t1 <- tabela_inv_sbox[nibble 0]

            # Nibble 1 (bits 11..8)
            srl     $t2, $a0, 8
            andi    $t2, $t2, 0x0F
            addu    $t5, $t0, $t2
            lbu     $t2, 0($t5)         # $t2 <- tabela_inv_sbox[nibble 1]

            # Nibble 2 (bits 7..4)
            srl     $t3, $a0, 4
            andi    $t3, $t3, 0x0F
            addu    $t5, $t0, $t3
            lbu     $t3, 0($t5)         # $t3 <- tabela_inv_sbox[nibble 2]

            # Nibble 3 (bits 3..0)
            andi    $t4, $a0, 0x0F
            addu    $t5, $t0, $t4
            lbu     $t4, 0($t5)         # $t4 <- tabela_inv_sbox[nibble 3]

            # Reconstrução da palavra de 16 bits
            sll     $v0, $t1, 12
            sll     $t6, $t2, 8
            or      $v0, $v0, $t6
            sll     $t6, $t3, 4
            or      $v0, $v0, $t6
            or      $v0, $v0, $t4
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: desloca_linhas / desloca_linhas_inv
# Descrição: Permuta a segunda linha da matriz 2x2 de nibbles (troca n1 com n3).
#            Na matriz 2x2, a transformação direta e inversa são idênticas.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de 16 bits de entrada [n0, n1, n2, n3]  |
# | $t0   | nibble 0 (posição S00) preservado             |
# | $t1   | nibble 1 (posição S10) movido para posição 3  |
# | $t2   | nibble 2 (posição S01) preservado             |
# | $t3   | nibble 3 (posição S11) movido para posição 1  |
# | $v0   | bloco com linhas permutadas [n0, n3, n2, n1]  |
# +-------+-----------------------------------------------+
###############################################################################
desloca_linhas:
desloca_linhas_inv:
# corpo do procedimento
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # $t0 <- nibble 0 (permanece na posição S00)

            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # $t1 <- nibble 1 (vai para a posição S11)

            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # $t2 <- nibble 2 (permanece na posição S01)

            andi    $t3, $a0, 0x0F      # $t3 <- nibble 3 (vai para a posição S10)

            # Reconstrução: [n0, n3, n2, n1]
            sll     $v0, $t0, 12        # nibble 0 nos bits 15..12
            sll     $t4, $t3, 8         # nibble 3 nos bits 11..8
            or      $v0, $v0, $t4
            sll     $t4, $t2, 4         # nibble 2 nos bits 7..4
            or      $v0, $v0, $t4
            or      $v0, $v0, $t1       # nibble 1 nos bits 3..0
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: mistura_colunas
# Descrição: Multiplica cada coluna pela matriz Me = [[1, 4], [4, 1]] em GF(16).
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de 16 bits de entrada                   |
# | $t9   | endereço base da tabela_mult4                 |
# | $t0   | nibble S00                                    |
# | $t1   | nibble S10                                    |
# | $t2   | nibble S01                                    |
# | $t3   | nibble S11                                    |
# | $t4   | S00' resultante da coluna 0                   |
# | $t5   | S10' resultante da coluna 0                   |
# | $t6   | S01' resultante da coluna 1                   |
# | $t7   | S11' resultante da coluna 1                   |
# | $v0   | bloco resultante de 16 bits                   |
# +-------+-----------------------------------------------+
###############################################################################
mistura_colunas:
# corpo do procedimento
            la      $t9, tabela_mult4   # $t9 <- endereço base da tabela de mult por 4

            # Extração dos 4 nibbles da matriz
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # $t0 <- S00

            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # $t1 <- S10

            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # $t2 <- S01

            andi    $t3, $a0, 0x0F      # $t3 <- S11

            # Coluna 0: S00' = S00 ^ (4 * S10); S10' = (4 * S00) ^ S10
            addu    $t8, $t9, $t1       # calcula endereço de mult4[S10]
            lbu     $t4, 0($t8)         # $t4 <- 4 * S10
            xor     $t4, $t0, $t4       # $t4 <- S00'

            addu    $t8, $t9, $t0       # calcula endereço de mult4[S00]
            lbu     $t5, 0($t8)         # $t5 <- 4 * S00
            xor     $t5, $t5, $t1       # $t5 <- S10'

            # Coluna 1: S01' = S01 ^ (4 * S11); S11' = (4 * S01) ^ S11
            addu    $t8, $t9, $t3       # calcula endereço de mult4[S11]
            lbu     $t6, 0($t8)         # $t6 <- 4 * S11
            xor     $t6, $t2, $t6       # $t6 <- S01'

            addu    $t8, $t9, $t2       # calcula endereço de mult4[S01]
            lbu     $t7, 0($t8)         # $t7 <- 4 * S01
            xor     $t7, $t7, $t3       # $t7 <- S11'

            # Reconstrução da palavra de 16 bits
            sll     $v0, $t4, 12        # S00' nos bits 15..12
            sll     $t8, $t5, 8         # S10' nos bits 11..8
            or      $v0, $v0, $t8
            sll     $t8, $t6, 4         # S01' nos bits 7..4
            or      $v0, $v0, $t8
            or      $v0, $v0, $t7       # S11' nos bits 3..0
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: mistura_colunas_inv
# Descrição: Multiplica cada coluna pela matriz inversa Md = [[9, 2], [2, 9]].
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de 16 bits de entrada                   |
# | $t8   | endereço base da tabela_mult9                 |
# | $t9   | endereço base da tabela_mult2                 |
# | $t0   | nibble S00                                    |
# | $t1   | nibble S10                                    |
# | $t2   | nibble S01                                    |
# | $t3   | nibble S11                                    |
# | $t4   | S00'' restaurado                              |
# | $t5   | S10'' restaurado                              |
# | $t6   | S01'' restaurado                              |
# | $t7   | S11'' restaurado                              |
# | $v0   | bloco de 16 bits resultante                   |
# +-------+-----------------------------------------------+
###############################################################################
mistura_colunas_inv:
# corpo do procedimento
            la      $t8, tabela_mult9   # $t8 <- endereço base da tabela de mult por 9
            la      $t9, tabela_mult2   # $t9 <- endereço base da tabela de mult por 2

            # Extração dos 4 nibbles
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # $t0 <- S00

            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # $t1 <- S10

            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # $t2 <- S01

            andi    $t3, $a0, 0x0F      # $t3 <- S11

            # Coluna 0: S00'' = (9 * S00) ^ (2 * S10); S10'' = (2 * S00) ^ (9 * S10)
            addu    $v1, $t8, $t0
            lbu     $t4, 0($v1)         # $t4 <- 9 * S00
            addu    $v1, $t9, $t1
            lbu     $v0, 0($v1)         # $v0 <- 2 * S10
            xor     $t4, $t4, $v0       # $t4 <- S00''

            addu    $v1, $t9, $t0
            lbu     $t5, 0($v1)         # $t5 <- 2 * S00
            addu    $v1, $t8, $t1
            lbu     $v0, 0($v1)         # $v0 <- 9 * S10
            xor     $t5, $t5, $v0       # $t5 <- S10''

            # Coluna 1: S01'' = (9 * S01) ^ (2 * S11); S11'' = (2 * S01) ^ (9 * S11)
            addu    $v1, $t8, $t2
            lbu     $t6, 0($v1)         # $t6 <- 9 * S01
            addu    $v1, $t9, $t3
            lbu     $v0, 0($v1)         # $v0 <- 2 * S11
            xor     $t6, $t6, $v0       # $t6 <- S01''

            addu    $v1, $t9, $t2
            lbu     $t7, 0($v1)         # $t7 <- 2 * S01
            addu    $v1, $t8, $t3
            lbu     $v0, 0($v1)         # $v0 <- 9 * S11
            xor     $t7, $t7, $v0       # $t7 <- S11''

            # Reconstrução da palavra de 16 bits
            sll     $v0, $t4, 12
            sll     $v1, $t5, 8
            or      $v0, $v0, $v1
            sll     $v1, $t6, 4
            or      $v0, $v0, $v1
            or      $v0, $v0, $t7
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: cifra_bloco
# Descrição: Criptografa um bloco de 16 bits utilizando o algoritmo S-AES.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de texto claro (16 bits)                |
# | $a1   | endereço base do vetor de subchaves           |
# | $s0   | estado intermediário de 16 bits               |
# | $s1   | subchave K0                                   |
# | $s2   | subchave K1                                   |
# | $s3   | subchave K2                                   |
# | $v0   | bloco criptografado retornado (16 bits)       |
# +-------+-----------------------------------------------+
#
# *** Mapa da pilha ***
# +----------------------------------+
# | Registrador | Endereço na Pilha  |
# +----------------------------------+
# | $ra         | $sp + 20           |
# | $s0         | $sp + 16           |
# | $s1         | $sp + 12           |
# | $s2         | $sp + 8            |
# | $s3         | $sp + 4            |
# +----------------------------------+
###############################################################################
cifra_bloco:
# prólogo
            addi    $sp, $sp, -24       # aloca espaço na pilha
            sw      $ra, 20($sp)        # salva endereço de retorno
            sw      $s0, 16($sp)        # salva $s0
            sw      $s1, 12($sp)        # salva $s1
            sw      $s2, 8($sp)         # salva $s2
            sw      $s3, 4($sp)         # salva $s3

# corpo do procedimento
            bnez    $a1, cb_chaves_ok   # verifica se endereço de chaves foi fornecido
            la      $a1, subchaves      # caso contrário, usa endereço padrão
cb_chaves_ok:
            lhu     $s1, 0($a1)         # $s1 <- subchave K0
            lhu     $s2, 2($a1)         # $s2 <- subchave K1
            lhu     $s3, 4($a1)         # $s3 <- subchave K2

            # Pré-Rodada: AddRoundKey(K0)
            xor     $s0, $a0, $s1       # $s0 <- estado inicial = bloco ^ K0

            # Rodada 1:
            # substitui_nibbles -> desloca_linhas -> mistura_colunas -> AddRoundKey(K1)
            move    $a0, $s0
            jal     substitui_nibbles   # substituição dos 4 nibbles via S-Box
            move    $a0, $v0

            jal     desloca_linhas      # permutação da segunda linha
            move    $a0, $v0

            jal     mistura_colunas     # multiplicação matricial em GF(16)
            move    $s0, $v0

            xor     $s0, $s0, $s2       # $s0 <- estado ^ K1

            # Rodada 2 (Final - sem mistura de colunas):
            # substitui_nibbles -> desloca_linhas -> AddRoundKey(K2)
            move    $a0, $s0
            jal     substitui_nibbles   # substituição final
            move    $a0, $v0

            jal     desloca_linhas      # permutação final
            move    $s0, $v0

            xor     $s0, $s0, $s3       # $s0 <- estado ^ K2
            move    $v0, $s0            # $v0 <- texto cifrado

# epílogo
            lw      $s3, 4($sp)         # restaura $s3
            lw      $s2, 8($sp)         # restaura $s2
            lw      $s1, 12($sp)        # restaura $s1
            lw      $s0, 16($sp)        # restaura $s0
            lw      $ra, 20($sp)        # restaura $ra
            addi    $sp, $sp, 24        # libera espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# Procedimento: decifra_bloco
# Descrição: Descriptografa um bloco de 16 bits cifrado com o algoritmo S-AES.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de texto cifrado (16 bits)              |
# | $a1   | endereço base do vetor de subchaves           |
# | $s0   | estado intermediário                          |
# | $s1   | subchave K0                                   |
# | $s2   | subchave K1                                   |
# | $s3   | subchave K2                                   |
# | $v0   | bloco de texto claro restaurado (16 bits)     |
# +-------+-----------------------------------------------+
#
# *** Mapa da pilha ***
# +----------------------------------+
# | Registrador | Endereço na Pilha  |
# +----------------------------------+
# | $ra         | $sp + 20           |
# | $s0         | $sp + 16           |
# | $s1         | $sp + 12           |
# | $s2         | $sp + 8            |
# | $s3         | $sp + 4            |
# +----------------------------------+
###############################################################################
decifra_bloco:
# prólogo
            addi    $sp, $sp, -24       # aloca espaço na pilha
            sw      $ra, 20($sp)        # salva $ra
            sw      $s0, 16($sp)        # salva $s0
            sw      $s1, 12($sp)        # salva $s1
            sw      $s2, 8($sp)         # salva $s2
            sw      $s3, 4($sp)         # salva $s3

# corpo do procedimento
            bnez    $a1, db_chaves_ok
            la      $a1, subchaves
db_chaves_ok:
            lhu     $s1, 0($a1)         # $s1 <- subchave K0
            lhu     $s2, 2($a1)         # $s2 <- subchave K1
            lhu     $s3, 4($a1)         # $s3 <- subchave K2

            # Início da Descriptografia: AddRoundKey(K2)
            xor     $s0, $a0, $s3       # $s0 <- estado inicial = cifrado ^ K2

            # Rodada 1 Inversa:
            # desloca_linhas_inv -> substitui_nibbles_inv -> AddRoundKey(K1) -> mistura_colunas_inv
            move    $a0, $s0
            jal     desloca_linhas_inv  # desfaz a permutação de linhas
            move    $a0, $v0

            jal     substitui_nibbles_inv # desfaz substituição usando InvS-Box
            move    $s0, $v0

            xor     $s0, $s0, $s2       # $s0 <- estado ^ K1

            move    $a0, $s0
            jal     mistura_colunas_inv # desfaz mistura de colunas em GF(16)
            move    $s0, $v0

            # Rodada 2 Inversa (Final):
            # desloca_linhas_inv -> substitui_nibbles_inv -> AddRoundKey(K0)
            move    $a0, $s0
            jal     desloca_linhas_inv  # permutação final inversa
            move    $a0, $v0

            jal     substitui_nibbles_inv # substituição final inversa
            move    $s0, $v0

            xor     $s0, $s0, $s1       # $s0 <- estado ^ K0
            move    $v0, $s0            # $v0 <- texto claro restaurado

# epílogo
            lw      $s3, 4($sp)         # restaura $s3
            lw      $s2, 8($sp)         # restaura $s2
            lw      $s1, 12($sp)        # restaura $s1
            lw      $s0, 16($sp)        # restaura $s0
            lw      $ra, 20($sp)        # restaura $ra
            addi    $sp, $sp, 24        # libera espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador
