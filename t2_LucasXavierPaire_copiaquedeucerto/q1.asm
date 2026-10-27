#*******************************************************************************
# Autor: Lucas Xavier Pairé
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Tradução de programa em C com ponteiros e procedimentos para MIPS
# Assembler: MARS
#*******************************************************************************

.data
x:                  .word   0
str_resultado:      .asciiz "O resultado e "
str_quebra_linha:   .asciiz "\n"

.text
.globl main
.globl media3x2y
.globl troca
.globl imprime_resultado

# main: inicializa variáveis, chama media3x2y e imprime o resultado
main:
# prologo
            addiu   $sp, $sp, -16       # ajusta a pilha
            sw      $ra, 12($sp)        # salva $ra na pilha

# corpo do procedimento
            # x = 5 (global)
            li      $t0, 5
            sw      $t0, x

            # y = 10 (local na pilha)
            li      $t1, 10
            sw      $t1, 0($sp)

            # z = media3x2y(x, y)
            lw      $a0, x              # primeiro argumento: x
            lw      $a1, 0($sp)         # segundo argumento: y
            jal     media3x2y
            sw      $v0, 4($sp)         # salva retorno em z

            # imprime_resultado(z)
            lw      $a0, 4($sp)
            jal     imprime_resultado

# epilogo
            lw      $ra, 12($sp)        # restaura $ra da pilha
            addiu   $sp, $sp, 16        # restaura a pilha

            li      $v0, 10             # encerra o programa (syscall exit)
            syscall


# media3x2y: implementa a funcao media3x2y da listagem 1
# Entrada: $a0 = x, $a1 = y
# Retorno: $v0 = a
media3x2y:
# prologo
            addiu   $sp, $sp, -24       # aloca quadro na pilha
            sw      $ra, 20($sp)
            sw      $s1, 16($sp)
            sw      $s0, 12($sp)

# corpo do procedimento
            move    $s0, $a0            # $s0 <- x
            move    $s1, $a1            # $s1 <- y

            # a = 3 * x = (x << 1) + x
            sll     $t0, $s0, 1
            addu    $t0, $t0, $s0
            sw      $t0, 0($sp)         # guarda a na pilha

            # b = 2 * y = y << 1
            sll     $t1, $s1, 1
            sw      $t1, 4($sp)         # guarda b na pilha

            # if (x < y) troca(&a, &b)
            slt     $t2, $s0, $s1
            beq     $t2, $zero, fim_se

            addiu   $a0, $sp, 0         # $a0 <- &a
            addiu   $a1, $sp, 4         # $a1 <- &b
            jal     troca

fim_se:
            lw      $s0, 0($sp)         # recupera valor de a
            lw      $s1, 4($sp)         # recupera valor de b

laco_while:
            # while (a > b) -> encerra se a <= b
            slt     $t0, $s1, $s0
            beq     $t0, $zero, fim_while

            addiu   $s0, $s0, -1        # a = a - 1
            addiu   $s1, $s1, 1         # b = b + 1
            j       laco_while

fim_while:
            sw      $s0, 0($sp)
            sw      $s1, 4($sp)
            move    $v0, $s0            # retorno a em $v0

# epilogo
            lw      $s0, 12($sp)
            lw      $s1, 16($sp)
            lw      $ra, 20($sp)
            addiu   $sp, $sp, 24
            jr      $ra


# troca: troca os valores apontados por *x e *y
troca:
# prologo
            # procedimento folha (nao precisa de pilha)

# corpo do procedimento
            lw      $t0, 0($a0)         # tmp = *x
            lw      $t1, 0($a1)         # carrega *y
            sw      $t1, 0($a0)         # *x = *y
            sw      $t0, 0($a1)         # *y = tmp

# epilogo
            jr      $ra


# imprime_resultado: exibe "O resultado e <z>\n"
imprime_resultado:
# prologo
            # procedimento folha (nao precisa de pilha)

# corpo do procedimento
            move    $t0, $a0            # guarda o valor de z

            la      $a0, str_resultado
            li      $v0, 4              # imprime texto
            syscall

            move    $a0, $t0            # recupera z para impressao
            li      $v0, 1              # imprime z
            syscall

            la      $a0, str_quebra_linha
            li      $v0, 4              # quebra de linha
            syscall

# epilogo
            jr      $ra
