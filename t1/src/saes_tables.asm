#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Tabelas estáticas para o algoritmo S-AES:
#            - Tabela de substituição de nibbles (S-Box) e inversa (InvS-Box)
#            - Tabelas de multiplicação no corpo finito GF(16) mod (x^4 + x + 1)
#            - Vetor para armazenamento das subchaves de rodada
# Assembler: MARS
#*******************************************************************************

.data
.globl tabela_sbox
.globl tabela_inv_sbox
.globl tabela_mult2
.globl tabela_mult4
.globl tabela_mult9
.globl subchaves

# ------------------------------------------------------------------------------
# 1. Tabela de Substituição (S-Box)
# Substitui nibbles de 4 bits (valores de 0x0 a 0xF)
# ------------------------------------------------------------------------------
.align 0
tabela_sbox:
            .byte 0x09, 0x04, 0x0A, 0x0B, 0x0D, 0x01, 0x08, 0x05
            .byte 0x06, 0x02, 0x00, 0x03, 0x0C, 0x0E, 0x0F, 0x07

# ------------------------------------------------------------------------------
# 2. Tabela Inversa de Substituição (InvS-Box)
# Desfaz a substituição da S-Box durante a descriptografia
# ------------------------------------------------------------------------------
.align 0
tabela_inv_sbox:
            .byte 0x0A, 0x05, 0x09, 0x0B, 0x01, 0x07, 0x08, 0x0F
            .byte 0x06, 0x00, 0x02, 0x03, 0x0C, 0x04, 0x0D, 0x0E

# ------------------------------------------------------------------------------
# 3. Tabela de Multiplicação por 2 em GF(16)
# ------------------------------------------------------------------------------
.align 0
tabela_mult2:
            .byte 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E
            .byte 0x03, 0x01, 0x07, 0x05, 0x0B, 0x09, 0x0F, 0x0D

# ------------------------------------------------------------------------------
# 4. Tabela de Multiplicação por 4 em GF(16)
# Utilizada na etapa de mistura de colunas (mistura_colunas)
# ------------------------------------------------------------------------------
.align 0
tabela_mult4:
            .byte 0x00, 0x04, 0x08, 0x0C, 0x03, 0x07, 0x0B, 0x0F
            .byte 0x06, 0x02, 0x0E, 0x0A, 0x05, 0x01, 0x0D, 0x09

# ------------------------------------------------------------------------------
# 5. Tabela de Multiplicação por 9 em GF(16)
# Utilizada na etapa inversa de mistura de colunas (mistura_colunas_inv)
# ------------------------------------------------------------------------------
.align 0
tabela_mult9:
            .byte 0x00, 0x09, 0x01, 0x08, 0x02, 0x0B, 0x03, 0x0A
            .byte 0x04, 0x0D, 0x05, 0x0C, 0x06, 0x0F, 0x07, 0x0E

# ------------------------------------------------------------------------------
# 6. Vetor de Subchaves de Rodada
# Armazena K0, K1 e K2 (cada subchave possui 16 bits = 2 bytes)
# ------------------------------------------------------------------------------
.align 1
subchaves:
            .half 0x0000, 0x0000, 0x0000
