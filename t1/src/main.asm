#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Programa principal da aplicacao de criptografia e descriptografia S-AES
#*******************************************************************************

.data
.align 2
buffer_nome_entrada:    .space 128
buffer_nome_saida:      .space 128
buffer_chave:           .space 64
buffer_opcao:           .space 16

msg_banner:
    .asciiz "\n=========================================================\n       ELC1011 - Criptografia de Arquivos S-AES\n       Autores: Lucas Xavier Pairé e Miguel Brondani\n=========================================================\n"

msg_menu:
    .asciiz "\nSelecione a operacao desejada:\n  (1) Criptografar arquivo\n  (2) Descriptografar arquivo\n  (0) Encerrar programa\nEscolha: "

msg_pede_entrada_cifra:
    .asciiz "\nDigite o nome do arquivo de entrada (texto claro): "

msg_pede_saida_cifra:
    .asciiz "Digite o nome do arquivo de saida (texto cifrado): "

msg_pede_entrada_decifra:
    .asciiz "\nDigite o nome do arquivo de entrada (texto cifrado): "

msg_pede_saida_decifra:
    .asciiz "Digite o nome do arquivo de saida (texto decifrado): "

msg_pede_chave:
    .asciiz "Digite a chave/senha de acesso: "

msg_sucesso_cifra:
    .asciiz "\n[SUCESSO] Arquivo criptografado com exito!\n"

msg_sucesso_decifra:
    .asciiz "\n[SUCESSO] Arquivo descriptografado com exito!\n"

msg_falha_operacao:
    .asciiz "\n[FALHA] Nao foi possivel completar a operacao com o arquivo.\n"

msg_opcao_invalida:
    .asciiz "\n[AVISO] Opcao invalida! Digite 1, 2 ou 0.\n"

msg_despedida:
    .asciiz "\nEncerrando o programa. Ate logo!\n\n"

.text
.globl main

###############################################################################
# main
# Interface com o usuario e coordenacao das operacoes de cifra e decifra.
###############################################################################
main:
            # Exibe o banner inicial
            li      $v0, 4
            la      $a0, msg_banner
            syscall

laco_menu_principal:
            # Menu de opcoes
            li      $v0, 4
            la      $a0, msg_menu
            syscall

            # Le opcao do usuario
            li      $v0, 8
            la      $a0, buffer_opcao
            li      $a1, 16
            syscall

            la      $t0, buffer_opcao
            lbu     $t1, 0($t0)

            li      $t2, '0'
            beq     $t1, $t2, executa_encerramento

            li      $t2, '1'
            beq     $t1, $t2, executa_criptografia

            li      $t2, '2'
            beq     $t1, $t2, executa_descriptografia

            # Opcao invalida
            li      $v0, 4
            la      $a0, msg_opcao_invalida
            syscall
            j       laco_menu_principal

executa_criptografia:
            # Arquivo de entrada
            li      $v0, 4
            la      $a0, msg_pede_entrada_cifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_entrada
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_entrada
            jal     remove_quebra_linha

            # Arquivo de saida
            li      $v0, 4
            la      $a0, msg_pede_saida_cifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_saida
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_saida
            jal     remove_quebra_linha

            # Chave de acesso
            li      $v0, 4
            la      $a0, msg_pede_chave
            syscall
            li      $v0, 8
            la      $a0, buffer_chave
            li      $a1, 64
            syscall
            la      $a0, buffer_chave
            jal     remove_quebra_linha

            # Deriva chave e calcula subchaves
            la      $a0, buffer_chave
            jal     deriva_chave
            move    $a0, $v0
            la      $a1, subchaves
            jal     expande_chave

            # Criptografa o arquivo (modo 1)
            la      $a0, buffer_nome_entrada
            la      $a1, buffer_nome_saida
            la      $a2, subchaves
            li      $a3, 1
            jal     processa_arquivo

            bnez    $v0, falha_criptografia
            li      $v0, 4
            la      $a0, msg_sucesso_cifra
            syscall
            j       laco_menu_principal

falha_criptografia:
            li      $v0, 4
            la      $a0, msg_falha_operacao
            syscall
            j       laco_menu_principal

executa_descriptografia:
            # Arquivo de entrada (cifrado)
            li      $v0, 4
            la      $a0, msg_pede_entrada_decifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_entrada
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_entrada
            jal     remove_quebra_linha

            # Arquivo de saida (decifrado)
            li      $v0, 4
            la      $a0, msg_pede_saida_decifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_saida
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_saida
            jal     remove_quebra_linha

            # Chave de acesso
            li      $v0, 4
            la      $a0, msg_pede_chave
            syscall
            li      $v0, 8
            la      $a0, buffer_chave
            li      $a1, 64
            syscall
            la      $a0, buffer_chave
            jal     remove_quebra_linha

            # Deriva chave e calcula subchaves
            la      $a0, buffer_chave
            jal     deriva_chave
            move    $a0, $v0
            la      $a1, subchaves
            jal     expande_chave

            # Descriptografa o arquivo (modo 2)
            la      $a0, buffer_nome_entrada
            la      $a1, buffer_nome_saida
            la      $a2, subchaves
            li      $a3, 2
            jal     processa_arquivo

            bnez    $v0, falha_descriptografia
            li      $v0, 4
            la      $a0, msg_sucesso_decifra
            syscall
            j       laco_menu_principal

falha_descriptografia:
            li      $v0, 4
            la      $a0, msg_falha_operacao
            syscall
            j       laco_menu_principal

executa_encerramento:
            li      $v0, 4
            la      $a0, msg_despedida
            syscall
            li      $v0, 10             # encerra execucao
            syscall

.include "saes_tables.asm"
.include "saes.asm"
.include "utils.asm"
.include "file_io.asm"
