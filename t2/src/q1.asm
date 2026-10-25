#*******************************************************************************
# Disciplina: ELC1011 - Organização de Computadores
# Professor:  Giovani Baratto
# Aluno:      Lucas Xavier Pairé
# Trabalho 2 - Parte 1 - Questão 1
# Arquivo:    q1.asm
# Descrição:  Tradução do programa em C (Listagem 1) para Assembly MIPS.
#             Demonstra manipulação de ponteiros, variáveis locais na pilha,
#             variável global no segmento .data, chamadas de procedimentos
#             folha e não-folha, e rotina de printf simplificado.
# Assembler:  MARS 4.5
#*******************************************************************************

################################################################################
# Segmento de Dados
################################################################################
.data

# Variável global x (declarada fora de funções no programa em C)
x:              .word   0

# Strings para a função de impressão simplificada (printf)
str_msg:        .asciiz "O resultado e "
str_newline:    .asciiz "\n"

################################################################################
# Segmento de Texto (Código)
################################################################################
.text
.globl main
.globl media3x2y
.globl troca

#/*=============================================================================
# Procedimento: main
#
# int main(void)
# {
#     int y;
#     int z;
#
#     x = 5;
#     y = 10;
#
#     z = media3x2y(x, y);
#
#     printf("O resultado e %d\n", z);
#
#     return 0;
# }
#=============================================================================*/
################################################################################
# Mapa da memória da pilha para `main`
#
#  | $ra | $sp + 12   Endereço de retorno para o SO / chamador
#  |  z  | $sp + 4    Variável local z
#  |  y  | $sp + 0    Variável local y
################################################################################
main:
        # Prólogo: aloca o quadro na pilha e salva o endereço de retorno
        addiu   $sp, $sp, -16           # Reserva 16 bytes na pilha
        sw      $ra, 12($sp)            # Salva $ra

        # x = 5; (variável global alocada no segmento .data)
        li      $t0, 5                  # Carrega a constante 5
        sw      $t0, x                  # Armazena 5 em x (.data)

        # y = 10; (variável local alocada na pilha)
        li      $t1, 10                 # Carrega a constante 10
        sw      $t1, 0($sp)             # Armazena 10 em y ($sp + 0)

        # z = media3x2y(x, y);
        lw      $a0, x                  # $a0 <- x (primeiro argumento)
        lw      $a1, 0($sp)             # $a1 <- y (segundo argumento)
        jal     media3x2y               # Chama media3x2y(x, y)
        sw      $v0, 4($sp)             # z = valor de retorno ($v0)

        # printf("O resultado e %d\n", z);
        lw      $a0, 4($sp)             # Passa o valor de z em $a0
        jal     printf_simplificado     # Chama a rotina simplificada de impressão

        # Epílogo: restaura o endereço de retorno e desaloca a pilha
        lw      $ra, 12($sp)            # Restaura $ra
        addiu   $sp, $sp, 16            # Libera o espaço da pilha

        # Encerramento limpo do programa via syscall
        li      $v0, 10                 # Serviço 10: exit
        syscall


#/*=============================================================================
# Procedimento: media3x2y
#
# int media3x2y(int x, int y)
# {
#     int a;
#     int b;
#
#     a = 3 * x;
#     b = 2 * y;
#     if (x < y) {
#         troca(&a, &b);
#     }
#     while (a > b) {
#         a = a - 1;
#         b = b + 1;
#     }
#     return a;
# }
#=============================================================================*/
################################################################################
# Mapa da memória da pilha para `media3x2y`
#
#  | $ra | $sp + 20   Endereço de retorno (procedimento não-folha)
#  | $s1 | $sp + 16   Preservação do registrador salvo $s1 (usado para b/y)
#  | $s0 | $sp + 12   Preservação do registrador salvo $s0 (usado para a/x)
#  | (v) | $sp + 8    Alinhamento da pilha (múltiplo de 8 bytes)
#  |  b  | $sp + 4    Variável local b (endereçável na memória: &b)
#  |  a  | $sp + 0    Variável local a (endereçável na memória: &a)
################################################################################
media3x2y:
        # Prólogo: aloca quadro de pilha de 24 bytes e preserva registradores
        addiu   $sp, $sp, -24           # Ajusta o ponteiro de pilha
        sw      $ra, 20($sp)            # Salva o endereço de retorno
        sw      $s1, 16($sp)            # Salva $s1
        sw      $s0, 12($sp)            # Salva $s0

        # Copia parâmetros de entrada para registradores seguros
        move    $s0, $a0                # $s0 <- x
        move    $s1, $a1                # $s1 <- y

        # a = 3 * x;
        # Como o trabalho aborda soma e subtração, computamos 3*x como (x << 1) + x
        sll     $t0, $s0, 1             # $t0 = 2 * x
        addu    $t0, $t0, $s0           # $t0 = 2 * x + x = 3 * x
        sw      $t0, 0($sp)             # Armazena na variável local a ($sp + 0)

        # b = 2 * y;
        # Computado como y << 1
        sll     $t1, $s1, 1             # $t1 = 2 * y
        sw      $t1, 4($sp)             # Armazena na variável local b ($sp + 4)

        # if (x < y) { troca(&a, &b); }
        slt     $t2, $s0, $s1           # $t2 = 1 se x < y; senão 0
        beq     $t2, $zero, fim_if      # Se x não é menor que y, desvia para fim_if

        # Prepara ponteiros: endereços das variáveis locais no stack
        addiu   $a0, $sp, 0             # $a0 = &a (endereço de a na pilha)
        addiu   $a1, $sp, 4             # $a1 = &b (endereço de b na pilha)
        jal     troca                   # Chama troca(&a, &b)

fim_if:
        # Carrega os valores atualizados de a e b para o laço while
        lw      $s0, 0($sp)             # $s0 <- a
        lw      $s1, 4($sp)             # $s1 <- b

        # while (a > b)
while_loop:
        # A condição (a > b) é logicamente equivalente a (b < a)
        slt     $t0, $s1, $s0           # $t0 = 1 se b < a (ou seja, a > b); senão 0
        beq     $t0, $zero, fim_while   # Se a não é maior que b, sai do laço

        # a = a - 1;
        addiu   $s0, $s0, -1            # Decrementa a

        # b = b + 1;
        addiu   $s1, $s1, 1             # Incrementa b

        j       while_loop              # Repete o laço

fim_while:
        # Atualiza as variáveis na pilha com os valores finais
        sw      $s0, 0($sp)             # Atualiza a na pilha
        sw      $s1, 4($sp)             # Atualiza b na pilha

        # return a;
        move    $v0, $s0                # Coloca o valor de retorno a em $v0

        # Epílogo: restaura registradores preservados e desaloca o stack frame
        lw      $s0, 12($sp)            # Restaura $s0
        lw      $s1, 16($sp)            # Restaura $s1
        lw      $ra, 20($sp)            # Restaura $ra
        addiu   $sp, $sp, 24            # Desaloca a pilha
        jr      $ra                     # Retorna ao chamador


#/*=============================================================================
# Procedimento: troca
#
# void troca(int* x, int* y)
# {
#     int tmp;
#
#     tmp = *x;
#     *x = *y;
#     *y = tmp;
# }
#=============================================================================*/
################################################################################
# Mapa da memória da pilha para `troca`
#
# Procedimento folha (leaf). Não chama outros procedimentos.
# Os parâmetros recebidos são ponteiros (endereços de memória de inteiros):
#   $a0: int* x
#   $a1: int* y
# Não há necessidade de salvar $ra. As operações ocorrem diretamente
# desreferenciando os ponteiros recebidos.
################################################################################
troca:
        # tmp = *x;
        lw      $t0, 0($a0)             # Carrega o valor apontado por x para $t0 (tmp)

        # *x = *y;
        lw      $t1, 0($a1)             # Carrega o valor apontado por y para $t1
        sw      $t1, 0($a0)             # Armazena o valor de *y no endereço apontado por x

        # *y = tmp;
        sw      $t0, 0($a1)             # Armazena tmp (*x original) no endereço apontado por y

        # Retorno ao chamador
        jr      $ra


#/*=============================================================================
# Procedimento auxiliar: printf_simplificado
#
# Imprime a mensagem formatada "O resultado e <z>\n" usando as chamadas
# de sistema do MARS.
# Parâmetro de entrada:
#   $a0: valor inteiro a ser impresso (<z>)
#=============================================================================*/
printf_simplificado:
        # Prólogo
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)
        sw      $a0, 0($sp)             # Salva o valor de z

        # Imprime o prefixo texto: "O resultado e "
        la      $a0, str_msg            # Endereço da string
        li      $v0, 4                  # Syscall 4: print_string
        syscall

        # Imprime o número inteiro z
        lw      $a0, 0($sp)             # Recupera o valor de z
        li      $v0, 1                  # Syscall 1: print_int
        syscall

        # Imprime a quebra de linha "\n"
        la      $a0, str_newline        # Endereço da quebra de linha
        li      $v0, 4                  # Syscall 4: print_string
        syscall

        # Epílogo
        lw      $a0, 0($sp)
        lw      $ra, 4($sp)
        addiu   $sp, $sp, 8
        jr      $ra
