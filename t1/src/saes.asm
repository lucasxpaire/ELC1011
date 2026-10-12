#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Criptografia e descriptografia do algoritmo S-AES
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
# expande_chave
# Gera as tres subchaves de rodada (K0, K1, K2) a partir da chave mestre.
#
# Entrada:
#   $a0: chave mestre de 16 bits
#   $a1: endereco base do vetor de subchaves
# Retorno:
#   $v0: subchave K0 (16 bits)
#   $v1: subchave K1 (16 bits)
# Registradores preservados: $s0, $s1
# Pilha: 12 bytes ($ra em $sp+8, $s0 em $sp+4, $s1 em $sp+0)
###############################################################################
expande_chave:
# prólogo
            addi    $sp, $sp, -12
            sw      $ra, 8($sp)
            sw      $s0, 4($sp)
            sw      $s1, 0($sp)

# corpo do procedimento
            bnez    $a1, exp_destino_ok
            la      $a1, subchaves
exp_destino_ok:
            move    $s0, $a0            # chave mestre
            move    $s1, $a1            # vetor de subchaves

            # Extrai w0 e w1 da chave mestre
            srl     $t0, $s0, 8
            andi    $t0, $t0, 0xFF      # w0 = bits 15..8
            andi    $t1, $s0, 0xFF      # w1 = bits 7..0

            # Subchave K0 = K
            sh      $s0, 0($s1)

            # Subchave K1: w2 = w0 ^ RCON(1) ^ SubNib(RotNib(w1))
            move    $a0, $t1
            jal     rotaciona_substitui_byte
            move    $t2, $v0

            xor     $t3, $t0, 0x80      # RCON(1) = 0x80
            xor     $t3, $t3, $t2
            andi    $t3, $t3, 0xFF      # w2

            # w3 = w2 ^ w1
            xor     $t4, $t3, $t1
            andi    $t4, $t4, 0xFF      # w3

            # K1 = (w2 << 8) | w3
            sll     $t5, $t3, 8
            or      $t5, $t5, $t4
            sh      $t5, 2($s1)

            # Subchave K2: w4 = w2 ^ RCON(2) ^ SubNib(RotNib(w3))
            move    $a0, $t4
            jal     rotaciona_substitui_byte
            move    $t6, $v0

            xor     $t7, $t3, 0x30      # RCON(2) = 0x30
            xor     $t7, $t7, $t6
            andi    $t7, $t7, 0xFF      # w4

            # w5 = w4 ^ w3
            xor     $t8, $t7, $t4
            andi    $t8, $t8, 0xFF      # w5

            # K2 = (w4 << 8) | w5
            sll     $t9, $t7, 8
            or      $t9, $t9, $t8
            sh      $t9, 4($s1)

            move    $v0, $s0            # retorna K0
            move    $v1, $t5            # retorna K1

# epílogo
            lw      $s1, 0($sp)
            lw      $s0, 4($sp)
            lw      $ra, 8($sp)
            addi    $sp, $sp, 12
            jr      $ra


###############################################################################
# rotaciona_substitui_byte
# Inverte os dois nibbles de um byte (RotNib) e aplica a S-Box (SubNib).
#
# Entrada:
#   $a0: byte de entrada [nibble_alto, nibble_baixo]
# Retorno:
#   $v0: byte resultante apos substituicao
# Registradores usados: $t8, $t9, $v1
###############################################################################
rotaciona_substitui_byte:
            srl     $t8, $a0, 4
            andi    $t8, $t8, 0x0F      # nibble alto
            andi    $t9, $a0, 0x0F      # nibble baixo

            la      $v1, tabela_sbox

            # S-Box no nibble inferior (vai para o superior)
            addu    $v0, $v1, $t9
            lbu     $t9, 0($v0)

            # S-Box no nibble superior (vai para o inferior)
            addu    $v0, $v1, $t8
            lbu     $t8, 0($v0)

            sll     $v0, $t9, 4
            or      $v0, $v0, $t8
            jr      $ra


###############################################################################
# substitui_nibbles
# Substitui os 4 nibbles de um bloco de 16 bits utilizando a tabela S-Box.
#
# Entrada:
#   $a0: bloco de 16 bits de entrada
# Retorno:
#   $v0: bloco de 16 bits com nibbles substituidos
# Registradores usados: $t0, $t1, $t2, $t3, $t4, $t5, $t6
###############################################################################
substitui_nibbles:
            la      $t0, tabela_sbox

            # Nibble 0 (bits 15..12)
            srl     $t1, $a0, 12
            andi    $t1, $t1, 0x0F
            addu    $t5, $t0, $t1
            lbu     $t1, 0($t5)

            # Nibble 1 (bits 11..8)
            srl     $t2, $a0, 8
            andi    $t2, $t2, 0x0F
            addu    $t5, $t0, $t2
            lbu     $t2, 0($t5)

            # Nibble 2 (bits 7..4)
            srl     $t3, $a0, 4
            andi    $t3, $t3, 0x0F
            addu    $t5, $t0, $t3
            lbu     $t3, 0($t5)

            # Nibble 3 (bits 3..0)
            andi    $t4, $a0, 0x0F
            addu    $t5, $t0, $t4
            lbu     $t4, 0($t5)

            # Remonta bloco de 16 bits
            sll     $v0, $t1, 12
            sll     $t6, $t2, 8
            or      $v0, $v0, $t6
            sll     $t6, $t3, 4
            or      $v0, $v0, $t6
            or      $v0, $v0, $t4
            jr      $ra


###############################################################################
# substitui_nibbles_inv
# Substitui os 4 nibbles de um bloco utilizando a tabela inversa (InvS-Box).
#
# Entrada:
#   $a0: bloco de 16 bits de entrada
# Retorno:
#   $v0: bloco de 16 bits restaurado
# Registradores usados: $t0, $t1, $t2, $t3, $t4, $t5, $t6
###############################################################################
substitui_nibbles_inv:
            la      $t0, tabela_inv_sbox

            # Nibble 0 (bits 15..12)
            srl     $t1, $a0, 12
            andi    $t1, $t1, 0x0F
            addu    $t5, $t0, $t1
            lbu     $t1, 0($t5)

            # Nibble 1 (bits 11..8)
            srl     $t2, $a0, 8
            andi    $t2, $t2, 0x0F
            addu    $t5, $t0, $t2
            lbu     $t2, 0($t5)

            # Nibble 2 (bits 7..4)
            srl     $t3, $a0, 4
            andi    $t3, $t3, 0x0F
            addu    $t5, $t0, $t3
            lbu     $t3, 0($t5)

            # Nibble 3 (bits 3..0)
            andi    $t4, $a0, 0x0F
            addu    $t5, $t0, $t4
            lbu     $t4, 0($t5)

            # Remonta bloco de 16 bits
            sll     $v0, $t1, 12
            sll     $t6, $t2, 8
            or      $v0, $v0, $t6
            sll     $t6, $t3, 4
            or      $v0, $v0, $t6
            or      $v0, $v0, $t4
            jr      $ra


###############################################################################
# desloca_linhas / desloca_linhas_inv
# Permuta a segunda linha da matriz 2x2 de nibbles (troca n1 com n3).
# Na matriz 2x2, a transformacao direta e inversa sao identicas.
#
# Entrada:
#   $a0: bloco de 16 bits de entrada [n0, n1, n2, n3]
# Retorno:
#   $v0: bloco com linhas permutadas [n0, n3, n2, n1]
# Registradores usados: $t0, $t1, $t2, $t3, $t4
###############################################################################
desloca_linhas:
desloca_linhas_inv:
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # n0 permanece em S00

            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # n1 vai para S11

            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # n2 permanece em S01

            andi    $t3, $a0, 0x0F      # n3 vai para S10

            # Remonta [n0, n3, n2, n1]
            sll     $v0, $t0, 12
            sll     $t4, $t3, 8
            or      $v0, $v0, $t4
            sll     $t4, $t2, 4
            or      $v0, $v0, $t4
            or      $v0, $v0, $t1
            jr      $ra


###############################################################################
# mistura_colunas
# Multiplica cada coluna pela matriz Me = [[1, 4], [4, 1]] em GF(16).
#
# Entrada:
#   $a0: bloco de 16 bits de entrada
# Retorno:
#   $v0: bloco resultante de 16 bits
# Registradores usados: $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9
###############################################################################
mistura_colunas:
            la      $t9, tabela_mult4

            # Extrai nibbles da matriz
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # S00
            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # S10
            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # S01
            andi    $t3, $a0, 0x0F      # S11

            # Coluna 0: S00' = S00 ^ (4 * S10); S10' = (4 * S00) ^ S10
            addu    $t8, $t9, $t1
            lbu     $t4, 0($t8)
            xor     $t4, $t0, $t4

            addu    $t8, $t9, $t0
            lbu     $t5, 0($t8)
            xor     $t5, $t5, $t1

            # Coluna 1: S01' = S01 ^ (4 * S11); S11' = (4 * S01) ^ S11
            addu    $t8, $t9, $t3
            lbu     $t6, 0($t8)
            xor     $t6, $t2, $t6

            addu    $t8, $t9, $t2
            lbu     $t7, 0($t8)
            xor     $t7, $t7, $t3

            # Remonta palavra de 16 bits
            sll     $v0, $t4, 12
            sll     $t8, $t5, 8
            or      $v0, $v0, $t8
            sll     $t8, $t6, 4
            or      $v0, $v0, $t8
            or      $v0, $v0, $t7
            jr      $ra


###############################################################################
# mistura_colunas_inv
# Multiplica cada coluna pela matriz inversa Md = [[9, 2], [2, 9]] em GF(16).
#
# Entrada:
#   $a0: bloco de 16 bits de entrada
# Retorno:
#   $v0: bloco resultante de 16 bits
# Registradores usados: $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $v1
###############################################################################
mistura_colunas_inv:
            la      $t8, tabela_mult9
            la      $t9, tabela_mult2

            # Extrai nibbles
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # S00
            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # S10
            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # S01
            andi    $t3, $a0, 0x0F      # S11

            # Coluna 0: S00'' = (9 * S00) ^ (2 * S10); S10'' = (2 * S00) ^ (9 * S10)
            addu    $v1, $t8, $t0
            lbu     $t4, 0($v1)
            addu    $v1, $t9, $t1
            lbu     $v0, 0($v1)
            xor     $t4, $t4, $v0

            addu    $v1, $t9, $t0
            lbu     $t5, 0($v1)
            addu    $v1, $t8, $t1
            lbu     $v0, 0($v1)
            xor     $t5, $t5, $v0

            # Coluna 1: S01'' = (9 * S01) ^ (2 * S11); S11'' = (2 * S01) ^ (9 * S11)
            addu    $v1, $t8, $t2
            lbu     $t6, 0($v1)
            addu    $v1, $t9, $t3
            lbu     $v0, 0($v1)
            xor     $t6, $t6, $v0

            addu    $v1, $t9, $t2
            lbu     $t7, 0($v1)
            addu    $v1, $t8, $t3
            lbu     $v0, 0($v1)
            xor     $t7, $t7, $v0

            # Remonta palavra de 16 bits
            sll     $v0, $t4, 12
            sll     $v1, $t5, 8
            or      $v0, $v0, $v1
            sll     $v1, $t6, 4
            or      $v0, $v0, $v1
            or      $v0, $v0, $t7
            jr      $ra


###############################################################################
# cifra_bloco
# Criptografa um bloco de 16 bits utilizando o algoritmo S-AES.
#
# Entrada:
#   $a0: bloco de texto claro (16 bits)
#   $a1: endereco base do vetor de subchaves
# Retorno:
#   $v0: bloco criptografado (16 bits)
# Registradores preservados: $s0, $s1, $s2, $s3
# Pilha: 24 bytes ($ra em $sp+20, $s0 em $sp+16, $s1 em $sp+12, $s2 em $sp+8, $s3 em $sp+4)
###############################################################################
cifra_bloco:
# prólogo
            addi    $sp, $sp, -24
            sw      $ra, 20($sp)
            sw      $s0, 16($sp)
            sw      $s1, 12($sp)
            sw      $s2, 8($sp)
            sw      $s3, 4($sp)

# corpo do procedimento
            bnez    $a1, cb_chaves_ok
            la      $a1, subchaves
cb_chaves_ok:
            lhu     $s1, 0($a1)         # subchave K0
            lhu     $s2, 2($a1)         # subchave K1
            lhu     $s3, 4($a1)         # subchave K2

            # Pre-Rodada: AddRoundKey(K0)
            xor     $s0, $a0, $s1

            # Rodada 1: SubNibbles -> ShiftRows -> MixColumns -> AddRoundKey(K1)
            move    $a0, $s0
            jal     substitui_nibbles
            move    $a0, $v0

            jal     desloca_linhas
            move    $a0, $v0

            jal     mistura_colunas
            move    $s0, $v0

            xor     $s0, $s0, $s2

            # Rodada 2 final: SubNibbles -> ShiftRows -> AddRoundKey(K2)
            move    $a0, $s0
            jal     substitui_nibbles
            move    $a0, $v0

            jal     desloca_linhas
            move    $s0, $v0

            xor     $s0, $s0, $s3
            move    $v0, $s0            # texto cifrado

# epílogo
            lw      $s3, 4($sp)
            lw      $s2, 8($sp)
            lw      $s1, 12($sp)
            lw      $s0, 16($sp)
            lw      $ra, 20($sp)
            addi    $sp, $sp, 24
            jr      $ra


###############################################################################
# decifra_bloco
# Descriptografa um bloco de 16 bits cifrado com o algoritmo S-AES.
#
# Entrada:
#   $a0: bloco de texto cifrado (16 bits)
#   $a1: endereco base do vetor de subchaves
# Retorno:
#   $v0: bloco de texto claro restaurado (16 bits)
# Registradores preservados: $s0, $s1, $s2, $s3
# Pilha: 24 bytes ($ra em $sp+20, $s0 em $sp+16, $s1 em $sp+12, $s2 em $sp+8, $s3 em $sp+4)
###############################################################################
decifra_bloco:
# prólogo
            addi    $sp, $sp, -24
            sw      $ra, 20($sp)
            sw      $s0, 16($sp)
            sw      $s1, 12($sp)
            sw      $s2, 8($sp)
            sw      $s3, 4($sp)

# corpo do procedimento
            bnez    $a1, db_chaves_ok
            la      $a1, subchaves
db_chaves_ok:
            lhu     $s1, 0($a1)         # subchave K0
            lhu     $s2, 2($a1)         # subchave K1
            lhu     $s3, 4($a1)         # subchave K2

            # Pre-Rodada inversa: AddRoundKey(K2)
            xor     $s0, $a0, $s3

            # Rodada 1 inversa: InvShiftRows -> InvSubNibbles -> AddRoundKey(K1) -> InvMixColumns
            move    $a0, $s0
            jal     desloca_linhas_inv
            move    $a0, $v0

            jal     substitui_nibbles_inv
            move    $s0, $v0

            xor     $s0, $s0, $s2

            move    $a0, $s0
            jal     mistura_colunas_inv
            move    $s0, $v0

            # Rodada 2 inversa final: InvShiftRows -> InvSubNibbles -> AddRoundKey(K0)
            move    $a0, $s0
            jal     desloca_linhas_inv
            move    $a0, $v0

            jal     substitui_nibbles_inv
            move    $s0, $v0

            xor     $s0, $s0, $s1
            move    $v0, $s0            # texto claro restaurado

# epílogo
            lw      $s3, 4($sp)
            lw      $s2, 8($sp)
            lw      $s1, 12($sp)
            lw      $s0, 16($sp)
            lw      $ra, 20($sp)
            addi    $sp, $sp, 24
            jr      $ra
