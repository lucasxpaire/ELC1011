#*******************************************************************************
# Autor: Lucas Xavier Pairé
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Tradução do programa com ponteiros e procedimentos para MIPS
# Assembler: MARS
#*******************************************************************************

################################################################################
# Segmento de Dados
################################################################################
.data

# Variável global x (declarada com escopo externo no código em C)
x:                  .word   0

# Mensagens textuais formatadas para o serviço de impressão
str_resultado:      .asciiz "O resultado e "
str_quebra_linha:   .asciiz "\n"

################################################################################
# Segmento de Texto (Código)
################################################################################
.text
.globl main
.globl media3x2y
.globl troca
.globl imprime_resultado

###############################################################################
# main
# Ponto de entrada: inicializa variáveis, chama media3x2y e imprime o resultado
#
# Entrada: nenhuma
# Retorno: nenhum
# Registradores usados: $t0, $t1, $a0, $a1, $v0
# Pilha: 16 bytes ($ra em $sp+12, z em $sp+4, y em $sp+0)
###############################################################################
main:
# prologo
            addiu   $sp, $sp, -16       # ajusta a pilha para 4 palavras
            sw      $ra, 12($sp)        # salva $ra na pilha

# corpo do procedimento
            # x = 5 (variável global)
            li      $t0, 5              # $t0 <- 5
            sw      $t0, x              # x <- 5

            # y = 10 (variável local)
            li      $t1, 10             # $t1 <- 10
            sw      $t1, 0($sp)         # y <- 10

            # z = media3x2y(x, y)
            lw      $a0, x              # $a0 <- x (primeiro argumento)
            lw      $a1, 0($sp)         # $a1 <- y (segundo argumento)
            jal     media3x2y           # $v0 <- media3x2y(x, y)
            sw      $v0, 4($sp)         # z <- $v0

            # imprime_resultado(z)
            lw      $a0, 4($sp)         # $a0 <- z
            jal     imprime_resultado   # exibe o resultado no terminal MARS

# epilogo
            lw      $ra, 12($sp)        # restaura $ra da pilha
            addiu   $sp, $sp, 16        # restaura o ponteiro de pilha

            # encerra a execução do programa no MARS
            li      $v0, 10             # $v0 <- serviço 10: exit
            syscall


###############################################################################
# media3x2y
# Calcula media ponderada ajustada via laço e troca condicional por ponteiros
#
# Entrada:
#   $a0: parâmetro x
#   $a1: parâmetro y
# Retorno:
#   $v0: resultado do cálculo (esperado: 17)
# Registradores preservados: $s0, $s1
# Pilha: 24 bytes ($ra em $sp+20, $s1 em $sp+16, $s0 em $sp+12, b em $sp+4, a em $sp+0)
###############################################################################
media3x2y:
# prologo
            addiu   $sp, $sp, -24       # aloca 24 bytes no quadro da pilha
            sw      $ra, 20($sp)        # salva $ra na pilha
            sw      $s1, 16($sp)        # salva $s1 na pilha
            sw      $s0, 12($sp)        # salva $s0 na pilha

# corpo do procedimento
            move    $s0, $a0            # $s0 <- x
            move    $s1, $a1            # $s1 <- y

            # a = 3 * x = (x << 1) + x
            sll     $t0, $s0, 1         # $t0 <- 2 * x
            addu    $t0, $t0, $s0       # $t0 <- 3 * x
            sw      $t0, 0($sp)         # variável local a <- 3 * x

            # b = 2 * y = y << 1
            sll     $t1, $s1, 1         # $t1 <- 2 * y
            sw      $t1, 4($sp)         # variável local b <- 2 * y

            # se x < y chama troca(&a, &b)
            slt     $t2, $s0, $s1       # $t2 <- 1 se x < y; senão 0
            beq     $t2, $zero, fim_se  # se x >= y desvia para fim_se

            addiu   $a0, $sp, 0         # $a0 <- endereço de a (&a)
            addiu   $a1, $sp, 4         # $a1 <- endereço de b (&b)
            jal     troca               # troca(&a, &b)

fim_se:
            # recupera valores atualizados de a e b
            lw      $s0, 0($sp)         # $s0 <- a
            lw      $s1, 4($sp)         # $s1 <- b

laco_while:
            # laço while (a > b) <=> while (b < a)
            slt     $t0, $s1, $s0       # $t0 <- 1 se b < a (a > b); senão 0
            beq     $t0, $zero, fim_while # se a <= b encerra o laço

            addiu   $s0, $s0, -1        # $s0 <- a - 1
            addiu   $s1, $s1, 1         # $s1 <- b + 1

            j       laco_while          # repete o laço

fim_while:
            sw      $s0, 0($sp)         # a <- $s0 (valor final)
            sw      $s1, 4($sp)         # b <- $s1 (valor final)

            move    $v0, $s0            # $v0 <- retorno a

# epilogo
            lw      $s0, 12($sp)        # restaura $s0 da pilha
            lw      $s1, 16($sp)        # restaura $s1 da pilha
            lw      $ra, 20($sp)        # restaura $ra da pilha
            addiu   $sp, $sp, 24        # desaloca espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# troca
# Permuta dois inteiros na memória desreferenciando seus ponteiros
#
# Entrada:
#   $a0: ponteiro para o primeiro inteiro (*x)
#   $a1: ponteiro para o segundo inteiro (*y)
# Retorno: nenhum
# Registradores usados: $t0, $t1
###############################################################################
troca:
# prologo
            # procedimento folha: sem alocação de quadro na pilha

# corpo do procedimento
            lw      $t0, 0($a0)         # $t0 <- *x (tmp = *x)
            lw      $t1, 0($a1)         # $t1 <- *y
            sw      $t1, 0($a0)         # *x <- *y
            sw      $t0, 0($a1)         # *y <- tmp

# epilogo
            jr      $ra                 # retorna ao procedimento chamador


###############################################################################
# imprime_resultado
# Exibe a mensagem formatada "O resultado e <z>\n" no terminal MARS
#
# Entrada:
#   $a0: valor inteiro a ser impresso (<z>)
# Retorno: nenhum
# Registradores usados: $v0, $a0
# Pilha: 8 bytes ($ra em $sp+4, z em $sp+0)
###############################################################################
imprime_resultado:
# prologo
            addiu   $sp, $sp, -8        # aloca 8 bytes na pilha
            sw      $ra, 4($sp)         # salva $ra na pilha
            sw      $a0, 0($sp)         # salva valor de z na pilha

# corpo do procedimento
            # exibe texto prefixo
            la      $a0, str_resultado  # $a0 <- endereço de "O resultado e "
            li      $v0, 4              # $v0 <- serviço 4: print_string
            syscall

            # exibe inteiro z
            lw      $a0, 0($sp)         # $a0 <- z
            li      $v0, 1              # $v0 <- serviço 1: print_int
            syscall

            # exibe quebra de linha
            la      $a0, str_quebra_linha # $a0 <- endereço de "\n"
            li      $v0, 4              # $v0 <- serviço 4: print_string
            syscall

# epilogo
            lw      $a0, 0($sp)         # restaura $a0 da pilha
            lw      $ra, 4($sp)         # restaura $ra da pilha
            addiu   $sp, $sp, 8         # desaloca espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador
