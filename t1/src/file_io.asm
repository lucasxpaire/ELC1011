#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Subsistema de leitura e gravação de arquivos em disco utilizando
#            os serviços 13 (abrir), 14 (ler), 15 (escrever) e 16 (fechar) do MARS.
#            Processa arquivos em fluxo contínuo através de um buffer de 512 bytes.
# Assembler: MARS
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
# Procedimento: processa_arquivo
# Descrição: Realiza o fluxo completo de abertura, leitura em blocos de 512 bytes,
#            processamento criptográfico (cifra ou decifra) e gravação em disco.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | nome do arquivo de entrada (ou argumentos de syscall)
# | $a1   | nome do arquivo de saída (ou flags de syscall)|
# | $a2   | endereço base das subchaves                   |
# | $a3   | modo de operação (1 = Cifra, 2 = Decifra)     |
# | $s0   | descritor do arquivo de entrada               |
# | $s1   | descritor do arquivo de saída                 |
# | $s2   | endereço base das subchaves preservado        |
# | $s3   | modo de operação preservado                   |
# | $s4   | endereço da string do arquivo de entrada      |
# | $s5   | endereço da string do arquivo de saída        |
# | $s6   | quantidade de bytes lidos no buffer atual     |
# | $s7   | índice do bloco atual no buffer (0, 2, 4...)  |
# | $v0   | código de status de retorno (0 = Sucesso)     |
# +-------+-----------------------------------------------+
#
# *** Mapa da pilha ***
# +----------------------------------+
# | Registrador | Endereço na Pilha  |
# +----------------------------------+
# | $ra         | $sp + 36           |
# | $s0         | $sp + 32           |
# | $s1         | $sp + 28           |
# | $s2         | $sp + 24           |
# | $s3         | $sp + 20           |
# | $s4         | $sp + 16           |
# | $s5         | $sp + 12           |
# | $s6         | $sp + 8            |
# | $s7         | $sp + 4            |
# +----------------------------------+
###############################################################################
processa_arquivo:
# prólogo
            addi    $sp, $sp, -40       # aloca espaço na pilha para 9 registradores
            sw      $ra, 36($sp)        # salva endereço de retorno
            sw      $s0, 32($sp)        # salva $s0
            sw      $s1, 28($sp)        # salva $s1
            sw      $s2, 24($sp)        # salva $s2
            sw      $s3, 20($sp)        # salva $s3
            sw      $s4, 16($sp)        # salva $s4
            sw      $s5, 12($sp)        # salva $s5
            sw      $s6, 8($sp)         # salva $s6
            sw      $s7, 4($sp)         # salva $s7

# corpo do procedimento
            move    $s4, $a0            # $s4 <- endereço do nome de entrada
            move    $s5, $a1            # $s5 <- endereço do nome de saída
            move    $s2, $a2            # $s2 <- ponteiro para subchaves
            move    $s3, $a3            # $s3 <- modo (1 = Cifra, 2 = Decifra)

            # ------------------------------------------------------------------
            # 1. Abertura do arquivo de entrada (serviço 13, flag = 0 [leitura])
            # ------------------------------------------------------------------
            li      $v0, 13             # $v0 <- serviço 13: abre arquivo
            move    $a0, $s4            # $a0 <- nome do arquivo de entrada
            li      $a1, 0              # $a1 <- flag 0: somente leitura
            li      $a2, 0              # $a2 <- modo (ignorado)
            syscall                     # chamada ao sistema para abertura
            bltz    $v0, erro_abertura_entrada # descritor negativo indica erro
            move    $s0, $v0            # $s0 <- descritor do arquivo de entrada

            # ------------------------------------------------------------------
            # 2. Abertura/criação do arquivo de saída (serviço 13, flag = 1 [escrita])
            # ------------------------------------------------------------------
            li      $v0, 13             # $v0 <- serviço 13: abre/cria arquivo
            move    $a0, $s5            # $a0 <- nome do arquivo de saída
            li      $a1, 1              # $a1 <- flag 1: escrita com criação/truncamento
            li      $a2, 0              # $a2 <- modo (ignorado)
            syscall                     # chamada ao sistema
            bltz    $v0, erro_abertura_saida # descritor negativo indica erro
            move    $s1, $v0            # $s1 <- descritor do arquivo de saída

            # ------------------------------------------------------------------
            # 3. Laço de Leitura contínua em blocos de até 512 bytes
            # ------------------------------------------------------------------
laco_leitura_buffer:
            li      $v0, 14             # $v0 <- serviço 14: leitura de arquivo
            move    $a0, $s0            # $a0 <- descritor de entrada
            la      $a1, buffer_io      # $a1 <- endereço base do buffer
            li      $a2, 512            # $a2 <- quantidade máxima de bytes a ler
            syscall                     # chamada ao sistema para leitura

            blez    $v0, fim_processamento # se bytes lidos <= 0, encerra o fluxo
            move    $s6, $v0            # $s6 <- bytes efetivamente lidos

            # Ajuste de preenchimento (padding) em caso de tamanho ímpar na cifra
            bne     $s3, 1, sem_ajuste_padding # se não for cifra, não ajusta padding
            andi    $t0, $s6, 1         # testa se a contagem é ímpar (bit 0 == 1)
            beqz    $t0, sem_ajuste_padding

            # Preenche o último byte com zero (zero-padding)
            la      $t1, buffer_io      # $t1 <- endereço base do buffer
            addu    $t1, $t1, $s6       # $t1 <- endereço do byte excedente
            sb      $zero, 0($t1)       # armazena 0x00 para fechar bloco de 16 bits
            addi    $s6, $s6, 1         # incrementa a quantidade de bytes a gravar

sem_ajuste_padding:
            # ------------------------------------------------------------------
            # 4. Laço de processamento dos blocos de 16 bits (de 2 em 2 bytes)
            # ------------------------------------------------------------------
            li      $s7, 0              # $s7 <- índice no buffer = 0

laco_processa_blocos:
            bge     $s7, $s6, grava_buffer_disco # se processou todo o buffer, grava

            la      $t0, buffer_io      # $t0 <- endereço base
            addu    $t0, $t0, $s7       # $t0 <- endereço do bloco atual

            lbu     $t1, 0($t0)         # $t1 <- byte alto da palavra
            lbu     $t2, 1($t0)         # $t2 <- byte baixo da palavra
            sll     $a0, $t1, 8         # posiciona byte alto nos bits 15..8
            or      $a0, $a0, $t2       # $a0 <- bloco completo de 16 bits

            move    $a1, $s2            # $a1 <- endereço base das subchaves

            # Desvia para decifra ou cifra conforme o modo
            beq     $s3, 2, chama_decifra
            jal     cifra_bloco         # executa cifra do bloco
            j       armazena_bloco_processado

chama_decifra:
            jal     decifra_bloco       # executa decifra do bloco

armazena_bloco_processado:
            # Escreve os 16 bits resultantes ($v0) de volta no buffer_io
            la      $t0, buffer_io      # $t0 <- endereço base
            addu    $t0, $t0, $s7       # $t0 <- endereço do bloco atual

            srl     $t1, $v0, 8         # $t1 <- byte alto resultante
            andi    $t1, $t1, 0xFF      # isola 8 bits
            sb      $t1, 0($t0)         # salva byte alto

            andi    $t2, $v0, 0xFF      # $t2 <- byte baixo resultante
            sb      $t2, 1($t0)         # salva byte baixo

            addi    $s7, $s7, 2         # avança 2 bytes (1 bloco)
            j       laco_processa_blocos

grava_buffer_disco:
            # ------------------------------------------------------------------
            # 5. Gravação dos dados processados no arquivo de saída
            # ------------------------------------------------------------------
            li      $v0, 15             # $v0 <- serviço 15: escreve em arquivo
            move    $a0, $s1            # $a0 <- descritor de saída
            la      $a1, buffer_io      # $a1 <- endereço dos dados
            move    $a2, $s6            # $a2 <- quantidade de bytes a gravar
            syscall                     # chamada ao sistema para escrita

            bltz    $v0, erro_gravacao  # se retorno < 0, erro de gravação

            j       laco_leitura_buffer # volta para ler o próximo bloco

fim_processamento:
            # ------------------------------------------------------------------
            # 6. Fechamento de arquivos e encerramento com sucesso
            # ------------------------------------------------------------------
            li      $v0, 16             # $v0 <- serviço 16: fecha arquivo
            move    $a0, $s0            # $a0 <- descritor de entrada
            syscall                     # fecha entrada

            li      $v0, 16             # $v0 <- serviço 16: fecha arquivo
            move    $a0, $s1            # $a0 <- descritor de saída
            syscall                     # fecha saída

            li      $v0, 0              # $v0 <- 0 (sucesso)
            j       epilogo_arquivo

erro_abertura_entrada:
            li      $v0, 4              # serviço 4: imprime string
            la      $a0, msg_erro_abertura_entrada
            syscall
            li      $v0, -1             # código -1: erro na entrada
            j       epilogo_arquivo

erro_abertura_saida:
            # Fecha arquivo de entrada antes de abortar
            li      $v0, 16             # serviço 16: fecha arquivo
            move    $a0, $s0
            syscall

            li      $v0, 4              # serviço 4: imprime string
            la      $a0, msg_erro_abertura_saida
            syscall
            li      $v0, -2             # código -2: erro na saída
            j       epilogo_arquivo

erro_gravacao:
            # Fecha ambos os arquivos antes de abortar
            li      $v0, 16
            move    $a0, $s0
            syscall
            li      $v0, 16
            move    $a0, $s1
            syscall

            li      $v0, 4
            la      $a0, msg_erro_gravacao
            syscall
            li      $v0, -3             # código -3: erro de gravação
            j       epilogo_arquivo

epilogo_arquivo:
# epílogo
            lw      $s7, 4($sp)         # restaura $s7
            lw      $s6, 8($sp)         # restaura $s6
            lw      $s5, 12($sp)        # restaura $s5
            lw      $s4, 16($sp)        # restaura $s4
            lw      $s3, 20($sp)        # restaura $s3
            lw      $s2, 24($sp)        # restaura $s2
            lw      $s1, 28($sp)        # restaura $s1
            lw      $s0, 32($sp)        # restaura $s0
            lw      $ra, 36($sp)        # restaura $ra
            addi    $sp, $sp, 40        # libera espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador
