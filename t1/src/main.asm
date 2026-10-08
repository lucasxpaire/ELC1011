#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Programa principal da aplicação de criptografia e descriptografia
#            de arquivos utilizando o algoritmo S-AES. Apresenta interface via terminal.
# Assembler: MARS
#*******************************************************************************

.data
.align 2
# Buffers estáticos de memória
buffer_nome_entrada:    .space 128
buffer_nome_saida:      .space 128
buffer_chave:           .space 64
buffer_opcao:           .space 16

# Mensagens de texto da interface com o usuário
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
# Procedimento principal (main)
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | argumentos das chamadas de procedimentos e syscalls
# | $a1   | argumentos secundários                        |
# | $a2   | endereço base das subchaves                   |
# | $a3   | modo de operação (1 = Cifra, 2 = Decifra)     |
# | $t0   | endereço base do buffer da opção              |
# | $t1   | caractere da opção lida do teclado            |
# | $t2   | constante de comparação de opção ('0', '1', '2')
# | $v0   | código de serviço do sistema (syscall)        |
# +-------+-----------------------------------------------+
###############################################################################
main:
# corpo do procedimento
            # Apresenta o banner de inicialização
            li      $v0, 4              # serviço 4: imprime string
            la      $a0, msg_banner     # $a0 <- endereço do banner
            syscall

laco_menu_principal:
            # Apresenta o menu de opções
            li      $v0, 4
            la      $a0, msg_menu       # $a0 <- endereço do texto do menu
            syscall

            # Lê a opção do usuário via serviço 8 (leitura de string)
            li      $v0, 8              # serviço 8: lê string
            la      $a0, buffer_opcao   # $a0 <- buffer para a opção
            li      $a1, 16             # limite de 16 caracteres
            syscall

            # Inspeciona o primeiro caractere digitado
            la      $t0, buffer_opcao
            lbu     $t1, 0($t0)         # $t1 <- caractere digitado

            # Opção '0': Encerrar
            li      $t2, '0'
            beq     $t1, $t2, executa_encerramento

            # Opção '1': Criptografar
            li      $t2, '1'
            beq     $t1, $t2, executa_criptografia

            # Opção '2': Descriptografar
            li      $t2, '2'
            beq     $t1, $t2, executa_descriptografia

            # Opção Inválida
            li      $v0, 4
            la      $a0, msg_opcao_invalida
            syscall
            j       laco_menu_principal

# ------------------------------------------------------------------------------
# Ramo de Criptografia (Opção 1)
# ------------------------------------------------------------------------------
executa_criptografia:
            # 1. Solicita nome do arquivo de entrada
            li      $v0, 4
            la      $a0, msg_pede_entrada_cifra
            syscall

            li      $v0, 8
            la      $a0, buffer_nome_entrada
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_entrada
            jal     remove_quebra_linha # sanitiza removendo '\n'

            # 2. Solicita nome do arquivo de saída
            li      $v0, 4
            la      $a0, msg_pede_saida_cifra
            syscall

            li      $v0, 8
            la      $a0, buffer_nome_saida
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_saida
            jal     remove_quebra_linha

            # 3. Solicita chave/senha de acesso
            li      $v0, 4
            la      $a0, msg_pede_chave
            syscall

            li      $v0, 8
            la      $a0, buffer_chave
            li      $a1, 64
            syscall
            la      $a0, buffer_chave
            jal     remove_quebra_linha

            # 4. Derivação e expansão da chave
            la      $a0, buffer_chave
            jal     deriva_chave        # $v0 <- chave de 16 bits gerada

            move    $a0, $v0            # $a0 <- chave mestre
            la      $a1, subchaves      # $a1 <- endereço do vetor de subchaves
            jal     expande_chave       # computa K0, K1 e K2

            # 5. Processamento do arquivo em modo de criptografia (modo 1)
            la      $a0, buffer_nome_entrada
            la      $a1, buffer_nome_saida
            la      $a2, subchaves
            li      $a3, 1              # 1 = Criptografia
            jal     processa_arquivo

            bnez    $v0, falha_criptografia # se retorno != 0, ocorreu erro

            li      $v0, 4
            la      $a0, msg_sucesso_cifra
            syscall
            j       laco_menu_principal

falha_criptografia:
            li      $v0, 4
            la      $a0, msg_falha_operacao
            syscall
            j       laco_menu_principal

# ------------------------------------------------------------------------------
# Ramo de Descriptografia (Opção 2)
# ------------------------------------------------------------------------------
executa_descriptografia:
            # 1. Solicita nome do arquivo cifrado
            li      $v0, 4
            la      $a0, msg_pede_entrada_decifra
            syscall

            li      $v0, 8
            la      $a0, buffer_nome_entrada
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_entrada
            jal     remove_quebra_linha

            # 2. Solicita nome do arquivo decifrado
            li      $v0, 4
            la      $a0, msg_pede_saida_decifra
            syscall

            li      $v0, 8
            la      $a0, buffer_nome_saida
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_saida
            jal     remove_quebra_linha

            # 3. Solicita chave/senha de acesso
            li      $v0, 4
            la      $a0, msg_pede_chave
            syscall

            li      $v0, 8
            la      $a0, buffer_chave
            li      $a1, 64
            syscall
            la      $a0, buffer_chave
            jal     remove_quebra_linha

            # 4. Derivação e expansão da chave
            la      $a0, buffer_chave
            jal     deriva_chave

            move    $a0, $v0
            la      $a1, subchaves
            jal     expande_chave

            # 5. Processamento do arquivo em modo de descriptografia (modo 2)
            la      $a0, buffer_nome_entrada
            la      $a1, buffer_nome_saida
            la      $a2, subchaves
            li      $a3, 2              # 2 = Descriptografia
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

# ------------------------------------------------------------------------------
# Encerramento do Programa (Opção 0)
# ------------------------------------------------------------------------------
executa_encerramento:
            li      $v0, 4
            la      $a0, msg_despedida
            syscall

            li      $v0, 10             # serviço 10: encerra o programa
            syscall

# ==============================================================================
# Inclusão dos Módulos Especializados
# ==============================================================================
.include "saes_tables.asm"
.include "saes.asm"
.include "utils.asm"
.include "file_io.asm"
