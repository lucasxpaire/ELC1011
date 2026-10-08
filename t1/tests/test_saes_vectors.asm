#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Teste unitário automatizado do algoritmo S-AES.
#            Validação da expansão de chaves, cifragem e decifragem contra o
#            vetor oficial de teste (Steven Gordon / William Stallings).
# Assembler: MARS
#*******************************************************************************

.data
str_cabecalho:   .asciiz "\n=== EXECUTANDO TESTE UNITARIO DO MOTOR S-AES ===\n"
str_k0_ok:       .asciiz "[OK] Subchave Key0 = 0x4AF5 conferida!\n"
str_k1_ok:       .asciiz "[OK] Subchave Key1 = 0xDD28 conferida!\n"
str_k2_ok:       .asciiz "[OK] Subchave Key2 = 0x87AF conferida!\n"
str_cif_ok:      .asciiz "[OK] Criptografia de 0xD728 resultou em 0x24EC!\n"
str_dec_ok:      .asciiz "[OK] Descriptografia de 0x24EC retornou 0xD728!\n"
str_todos_ok:    .asciiz "\n>>> [SUCESSO TOTAL] O ALGORITMO S-AES ESTA 100% CORRETO! <<<\n\n"
str_falha:       .asciiz "\n[ERRO CRITICO] O teste falhou no passo: "
str_falha_val:   .asciiz " | Valor retornado: "
str_nova_linha:  .asciiz "\n"

.text
.globl main

# Procedimento principal do teste unitario
main:
    # prólogo
    # (procedimento raiz)

    # corpo do procedimento
    # Imprime cabecalho do teste
    li   $v0, 4                                 # $v0 <- 4 (serviço de impressão de string)
    la   $a0, str_cabecalho                     # $a0 <- str_cabecalho
    syscall

    # --------------------------------------------------------------------------
    # 1. Teste da Expansão de Chaves
    # Chave mestre K = 0x4AF5
    # Esperado: Key0 = 0x4AF5, Key1 = 0xDD28, Key2 = 0x87AF
    # --------------------------------------------------------------------------
    li   $a0, 0x4AF5                            # $a0 <- chave mestre 0x4AF5
    la   $a1, subchaves                         # $a1 <- endereço do vetor de subchaves
    jal  expande_chave

    # Valida Subchave 0 (Key0)
    la   $a1, subchaves                         # $a1 <- endereço do vetor de subchaves
    lhu  $t0, 0($a1)                            # $t0 <- subchaves[0]
    li   $t1, 0x4AF5                            # $t1 <- 0x4AF5
    bne  $t0, $t1, rotulo_falha_k0
    li   $v0, 4                                 # $v0 <- 4
    la   $a0, str_k0_ok                         # $a0 <- str_k0_ok
    syscall

    # Valida Subchave 1 (Key1)
    la   $a1, subchaves                         # $a1 <- endereço do vetor de subchaves
    lhu  $t0, 2($a1)                            # $t0 <- subchaves[1]
    li   $t1, 0xDD28                            # $t1 <- 0xDD28
    bne  $t0, $t1, rotulo_falha_k1
    li   $v0, 4                                 # $v0 <- 4
    la   $a0, str_k1_ok                         # $a0 <- str_k1_ok
    syscall

    # Valida Subchave 2 (Key2)
    la   $a1, subchaves                         # $a1 <- endereço do vetor de subchaves
    lhu  $t0, 4($a1)                            # $t0 <- subchaves[2]
    li   $t1, 0x87AF                            # $t1 <- 0x87AF
    bne  $t0, $t1, rotulo_falha_k2
    li   $v0, 4                                 # $v0 <- 4
    la   $a0, str_k2_ok                         # $a0 <- str_k2_ok
    syscall

    # --------------------------------------------------------------------------
    # 2. Teste de Cifragem de Bloco
    # Bloco claro P = 0xD728
    # Esperado: C = 0x24EC
    # --------------------------------------------------------------------------
    li   $a0, 0xD728                            # $a0 <- bloco de texto claro 0xD728
    la   $a1, subchaves                         # $a1 <- endereço do vetor de subchaves
    jal  cifra_bloco
    move $s0, $v0                               # $s0 <- texto cifrado gerado

    li   $t1, 0x24EC                            # $t1 <- valor esperado 0x24EC
    bne  $s0, $t1, rotulo_falha_cif
    li   $v0, 4                                 # $v0 <- 4
    la   $a0, str_cif_ok                        # $a0 <- str_cif_ok
    syscall

    # --------------------------------------------------------------------------
    # 3. Teste de Decifragem de Bloco
    # Bloco cifrado C = 0x24EC
    # Esperado: P = 0xD728
    # --------------------------------------------------------------------------
    move $a0, $s0                               # $a0 <- bloco cifrado (0x24EC)
    la   $a1, subchaves                         # $a1 <- endereço do vetor de subchaves
    jal  decifra_bloco
    move $s1, $v0                               # $s1 <- texto decifrado obtido

    li   $t1, 0xD728                            # $t1 <- valor esperado 0xD728
    bne  $s1, $t1, rotulo_falha_dec
    li   $v0, 4                                 # $v0 <- 4
    la   $a0, str_dec_ok                        # $a0 <- str_dec_ok
    syscall

    # Sucesso em todos os passos
    li   $v0, 4                                 # $v0 <- 4
    la   $a0, str_todos_ok                      # $a0 <- str_todos_ok
    syscall

    # epílogo
    li   $v0, 10                                # $v0 <- 10 (saída do programa com sucesso)
    syscall

rotulo_falha_k0:
    li   $v0, 4
    la   $a0, str_falha
    syscall
    li   $v0, 1
    li   $a0, 1
    syscall
    j    rotulo_saida_erro

rotulo_falha_k1:
    li   $v0, 4
    la   $a0, str_falha
    syscall
    li   $v0, 1
    li   $a0, 2
    syscall
    j    rotulo_saida_erro

rotulo_falha_k2:
    li   $v0, 4
    la   $a0, str_falha
    syscall
    li   $v0, 1
    li   $a0, 3
    syscall
    j    rotulo_saida_erro

rotulo_falha_cif:
    li   $v0, 4
    la   $a0, str_falha
    syscall
    li   $v0, 1
    li   $a0, 4
    syscall
    j    rotulo_saida_erro

rotulo_falha_dec:
    move $s1, $v0
    li   $v0, 4
    la   $a0, str_falha
    syscall
    li   $v0, 1
    li   $a0, 5
    syscall
    li   $v0, 4
    la   $a0, str_falha_val
    syscall
    li   $v0, 34                                # $v0 <- 34 (imprime hexadecimal)
    move $a0, $s1
    syscall
    j    rotulo_saida_erro

rotulo_saida_erro:
    li   $v0, 4
    la   $a0, str_nova_linha
    syscall
    li   $v0, 17                                # $v0 <- 17 (exit2 com código de erro)
    li   $a0, 1
    syscall

# Inclusão dos módulos do S-AES
.include "../src/saes_tables.asm"
.include "../src/saes.asm"
