#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Procedimentos de leitura, processamento e gravacao de arquivos
#*******************************************************************************

.data
.align 2
buffer_io:                  .space 512

msg_erro_abertura_entrada:  .asciiz "\n[ERRO] Falha ao abrir o arquivo de entrada para leitura!\n"
msg_erro_abertura_saida:    .asciiz "\n[ERRO] Falha ao criar/abrir o arquivo de saida para gravacao!\n"
msg_erro_gravacao:          .asciiz "\n[ERRO] Falha durante a gravacao dos dados no arquivo de saida!\n"

.text
.globl processa_arquivo
.globl buffer_io

###############################################################################
# processa_arquivo
# Realiza a abertura, leitura em buffer de 512 bytes, processamento criptografico
# (cifra ou decifra bloco a bloco) e gravacao em disco.
#
# Entrada:
#   $a0: endereco do nome do arquivo de entrada
#   $a1: endereco do nome do arquivo de saida
#   $a2: endereco base do vetor de subchaves
#   $a3: modo de operacao (1 = Cifra, 2 = Decifra)
# Retorno:
#   $v0: codigo de status (0 = Sucesso, negativo = Erro)
# Registradores preservados: $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7
# Pilha: 40 bytes ($ra em $sp+36, $s0-$s7 em $sp+32..$sp+4)
###############################################################################
processa_arquivo:
# prólogo
            addi    $sp, $sp, -40
            sw      $ra, 36($sp)
            sw      $s0, 32($sp)
            sw      $s1, 28($sp)
            sw      $s2, 24($sp)
            sw      $s3, 20($sp)
            sw      $s4, 16($sp)
            sw      $s5, 12($sp)
            sw      $s6, 8($sp)
            sw      $s7, 4($sp)

# corpo do procedimento
            move    $s4, $a0            # nome de entrada
            move    $s5, $a1            # nome de saida
            move    $s2, $a2            # vetor de subchaves
            move    $s3, $a3            # modo (1 = Cifra, 2 = Decifra)

            # 1. Abre arquivo de entrada para leitura
            li      $v0, 13
            move    $a0, $s4
            li      $a1, 0              # somente leitura
            li      $a2, 0
            syscall
            bltz    $v0, erro_abertura_entrada
            move    $s0, $v0            # guarda descritor de entrada

            # 2. Cria/abre arquivo de saida para escrita
            li      $v0, 13
            move    $a0, $s5
            li      $a1, 1              # escrita/criacao
            li      $a2, 0
            syscall
            bltz    $v0, erro_abertura_saida
            move    $s1, $v0            # guarda descritor de saida

            # 3. Leitura continua em blocos de ate 512 bytes
laco_leitura_buffer:
            li      $v0, 14
            move    $a0, $s0
            la      $a1, buffer_io
            li      $a2, 512
            syscall

            blez    $v0, fim_processamento # fim de arquivo ou erro
            move    $s6, $v0            # bytes lidos

            # Ajuste de zero-padding para tamanho impar na cifra
            bne     $s3, 1, sem_ajuste_padding
            andi    $t0, $s6, 1
            beqz    $t0, sem_ajuste_padding

            la      $t1, buffer_io
            addu    $t1, $t1, $s6
            sb      $zero, 0($t1)       # adiciona 0x00 para fechar bloco de 16 bits
            addi    $s6, $s6, 1

sem_ajuste_padding:
            # 4. Processa blocos de 16 bits (2 em 2 bytes)
            li      $s7, 0

laco_processa_blocos:
            bge     $s7, $s6, grava_buffer_disco

            la      $t0, buffer_io
            addu    $t0, $t0, $s7

            lbu     $t1, 0($t0)         # byte alto
            lbu     $t2, 1($t0)         # byte baixo
            sll     $a0, $t1, 8
            or      $a0, $a0, $t2       # monta bloco de 16 bits

            move    $a1, $s2            # subchaves

            beq     $s3, 2, chama_decifra
            jal     cifra_bloco
            j       armazena_bloco_processado

chama_decifra:
            jal     decifra_bloco

armazena_bloco_processado:
            la      $t0, buffer_io
            addu    $t0, $t0, $s7

            srl     $t1, $v0, 8
            andi    $t1, $t1, 0xFF
            sb      $t1, 0($t0)         # salva byte alto

            andi    $t2, $v0, 0xFF
            sb      $t2, 1($t0)         # salva byte baixo

            addi    $s7, $s7, 2
            j       laco_processa_blocos

grava_buffer_disco:
            # 5. Grava dados processados no arquivo de saida
            li      $v0, 15
            move    $a0, $s1
            la      $a1, buffer_io
            move    $a2, $s6
            syscall
            bltz    $v0, erro_gravacao

            j       laco_leitura_buffer

fim_processamento:
            # 6. Fecha descritores e encerra com sucesso
            li      $v0, 16
            move    $a0, $s0
            syscall

            li      $v0, 16
            move    $a0, $s1
            syscall

            li      $v0, 0              # sucesso
            j       epilogo_arquivo

erro_abertura_entrada:
            li      $v0, 4
            la      $a0, msg_erro_abertura_entrada
            syscall
            li      $v0, -1
            j       epilogo_arquivo

erro_abertura_saida:
            li      $v0, 16             # fecha entrada antes de abortar
            move    $a0, $s0
            syscall

            li      $v0, 4
            la      $a0, msg_erro_abertura_saida
            syscall
            li      $v0, -2
            j       epilogo_arquivo

erro_gravacao:
            li      $v0, 16
            move    $a0, $s0
            syscall
            li      $v0, 16
            move    $a0, $s1
            syscall

            li      $v0, 4
            la      $a0, msg_erro_gravacao
            syscall
            li      $v0, -3
            j       epilogo_arquivo

epilogo_arquivo:
# epílogo
            lw      $s7, 4($sp)
            lw      $s6, 8($sp)
            lw      $s5, 12($sp)
            lw      $s4, 16($sp)
            lw      $s3, 20($sp)
            lw      $s2, 24($sp)
            lw      $s1, 28($sp)
            lw      $s0, 32($sp)
            lw      $ra, 36($sp)
            addi    $sp, $sp, 40
            jr      $ra
