#*******************************************************************************
# exercicio035.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: 
# exemplo do uso de operações lógicas
# Este programa faz a leitura de um registro (aluno1a) com 4 campos (Cada campo
# ocupa uma palavra) e guarda estes campos em um registro com uma única
# palavra (aluno1b).
#
# Formato do registro em aluno1b
# bit   |31    24|23    16|15    8|7    0|
# campo |   ID   |   P1   |   P2  |exame |
# ID - número de identificação do aluno 1
# P1 e P2 - notas das provas 1 e 2, respectivamente, do aluno 1
# exame - nota do exame do aluno 1
#
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    19.09.2018     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                   #



.text
.globl main

################################################################################ 
main:
################################################################################
            la      $a0, aluno1a        # endereço do registro do aluno 1 (usando 4 palavras)
            jal     construa_registro_usando_1palavra
            la      $a0, aluno1b
            jal     imprime_registro_1palavra
# termina o programa
            li      $a0, 0              # $a0 <- 0. retorna 0 para o programa chamador
            li      $v0, 17             # serviço 17: termina a execução do programa
            syscall                     # faz a chamada ao serviço do sistema
################################################################################    



################################################################################
construa_registro_usando_1palavra:
# Este procedimento faz a leitura de um registro contendo 4 campos, armazenado
# em palavras, e, armazena em uma única palavra
################################################################################
# prólogo
# corpo do procedimento
# Lendo o registro do aluno 1 (usando 4 palavras)
            lw      $t2, 0($a0)         # $t2 <- ID do aluno 1
            lw      $t3, 4($a0)         # $t3 <- nota da prova 1 do aluno 1
            lw      $t4, 8($a0)         # $t4 <- nota da prova 2 do aluno 1
            lw      $t5, 12($a0)        # $t5 <- nota do exame do aluno 1
# construindo o registro do aluno 1 (usando 1 palavra)
            xor     $t6, $t6, $t6       # zera o registrador $t6
            sll     $t7, $t2, 24        # desloca ID para o campo
            or      $t6, $t7, $t6       # guarda o valor de ID no registro
            sll     $t7, $t3, 16        # desloca prova 1 para o campo
            or      $t6, $t7, $t6       # guarda o valor de prova 1 no registro
            sll     $t7, $t4, 8         # desloca prova 2 para o campo
            or      $t6, $t7, $t6       # guarda o valor de prova 2 no registro
            # o campo exame não precisa de deslocamento
            or      $t6, $t5, $t6       # guarda o valor exame no registro
            la      $t1, aluno1b        # endereço do registro aluno 1 (usando 1 palavra)
            sw      $t6, 0($t1)         # guarda o registro de aluno 1 (usando 1 palavra)
# epílogo
            jr      $ra                 # retornamos ao procedimento chamador
################################################################################


################################################################################
imprime_registro_1palavra:
################################################################################
# prólogo
# corpo do programa
# lendo o registro de aluno1 (usando 1 palavra)
            la      $t1, aluno1b        # carrega o endereço do registro
            lw      $t2, 0($t1)         # carrega em $t2 o registro
# extraindo e imprimindo os campos ID e exame
            move    $t3, $t2            # carrega em $t3 o registro
            srl     $t3, $t3, 24        # desloca ID para a direita do registrador
            # imprime a string ID:
            la      $a0, str_ID         # carrega o endereço da string ID:
            li      $v0, 4              # serviço 4: imprime uma string
            syscall                     # chamada ao serviço do sistema
            # imprime o valor de ID do aluno 1
            move    $a0, $t3            # $a0 <- ID
            li      $v0, 1              # serviço 1: imprime um inteiro
            syscall                     # chamada ao serviço do sistema
            # pula para a próxima linha
            li      $a0, '\n'           # $a0 <- LF (line feed = 0x0A)
            li      $v0, 11             # serviço 11: imprime o caracter em $a0
            syscall                     # chamada ao serviço do sistema
            # Extrai o campo com a nota de exame
            move    $t3, $t2            # carrega em $t3 o registro
            li      $t4, 0x000000FF     # $t4 <- máscara para o campo exame
            and     $t3, $t3, $t4       # isola o campo exame
            # imprime a string exame:
            la      $a0, str_exame      # $a0 <- endereço da string exame:
            li      $v0, 4              # serviço 4: imprime uma string com o endereço em $a0
            syscall                     # chamada ao serviço do sistema
            # imprime a nota do exame
            move    $a0, $t3            # $a0 <- nota do exame
            li      $v0, 1              # seviço 1: imprime o inteiro em $a0
            syscall                     # faz a chamada ao serviço do sistema
            # pula para a próxima linha
            li      $a0, '\n'           # $a0 <- LF (0x0A)
            li      $v0, 11             # serviço 11: imprime o caracater em $a0
            syscall                     # faz a chamada ao serviço do sistema
# epílogo
################################################################################




################################################################################
.data
################################################################################
# registro do aluno1 (aluno1a), armazenado em 4 palavras
aluno1a:    .word 170               # ID
            .word 72                # nota da prova 1
            .word 50                # nota da prova 2
            .word 95                # nota do exame
# O registro do aluno1 (aluno1b), armazenado em campos em uma única palavra
# Formato do registro em aluno1b
# bit   |31    24|23    16|15    8|7    0|
# campo |   ID   |   P1   |   P2  |exame |
aluno1b:    .space 4
# Strings usadas na impressão da identificação e das notas
    .align 2
str_ID:     .asciiz "ID: "
str_prova1: .asciiz "Nota da prova 1: "
str_prova2: .asciiz "Nota da prova 2: "
str_exame:  .asciiz "Nota do exame: "

    
