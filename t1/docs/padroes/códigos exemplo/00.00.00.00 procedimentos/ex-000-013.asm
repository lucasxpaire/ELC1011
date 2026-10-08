#*******************************************************************************
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: programa para calcular o fatorial de um número: versão não recursiva
# Documentação:
# Assembler: MARS
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #

###############################################################################
.text
.globl      main                    # main pode ser referenciado em outros arquivos
###############################################################################

# definição dos valores numéricos com a diretiva .eqv
.eqv        SERVICO_IMPRIME_INTEIRO     1
.eqv        SERVICO_TERMINA_PROGRAMA    17
.eqv        SUCESSO                     0

###############################################################################
main:
###############################################################################
    # void main(void)
    # {     
    #     int k;     
    #     k = 5;     
    #     k = fact2(k);     
    #     printf("%d",k); 
    #     return 0;
    # }

#    mapa da pilha
#    -------------
#    $ra  : $sp + 8
#    $s0  : $sp + 4
#    k    : $sp + 0
#    --------------
#
#    mapa dos registradores
#    ----------------------
#    k      : $s0
#    ----------------------
#
###############################################################################
# prólogo
            addiu $sp, $sp, -12     # ajustamos a pilha, criando o quadro do procedimento
            sw    $s0, 4($sp)       # salvamos o registrador $s0
# corpo do procedimento
            #     k = 5;
            addiu $s0, $zero, 5     # $s0 <-5;
            sw    $s0, 0($sp)       # k = 5
            #     k = fact2(k);
            addu  $a0, $zero, $s0   # a0 <- k, a0 argumento da função
            jal   fact2             # chama a função fact - fatorial
            addu  $s0, $zero, $v0   # $s0 <- fact(k)
            sw    $s0, 0($sp)       # k = fact(k)
            # printf("%d",k);
            # criamos um procedimento simplificador para o procedimento
            # printf, para a impressão de k
            addu  $a0, $zero, $s0   # $a0 <- $s0
            jal   printf            # chamamos o procedimento printf
# epílogo
            # return 0
            lw    $s0, 4($sp)       # restauramos o registrador $s0
            addiu $sp, $sp, 12      # restauramos a pilha
            #jr    $ra              # excepcionalmente no procedimento main terminamos o programa
            # termina o programa
            addiu $v0, $zero, SERVICO_TERMINA_PROGRAMA # serviço 17 - término do programa
            addiu $a0, $zero, SUCESSO # resultado da execução do programa 0: sucesso
            syscall                 # chamada ao sistema
    
    
################################################################################
printf:
# Comentários: Esta função foi simplificada.
################################################################################
# prólogo
# corpo do procedimento
            # imprimimos k
            addiu $v0, $zero, SERVICO_IMPRIME_INTEIRO # serviço 1: imprime um inteiro
            syscall                 # chamada ao serviço do sistema
#epílogo
            jr    $ra               # retornamos ao procedimento chamador
################################################################################



###############################################################################
fact2:
#------------------------------------------------------------------------------
    # procedimento fact2 - retorna o fatorial de um inteiro
    # função não recursiva
    # n deve ser maior ou igual a zero
    # n deve ser menor que 12 para registradores de 32 bits    
#------------------------------------------------------------------------------
    # int fact2(int n)
    # {
    # int tmp;
    # tmp = 1;
    # if(n==0) return 1;     
    # else {
    #     tmp = n;
    #    while(n>1){
    #        n = n-1;
    #        tmp = tmp*n;
    #    }
    #    return tmp;
    #    }
    # }
#
#
#         mapa da pilha
#       -----------------
#        tmp   : $sp + 0
#       -----------------
#
#      mapa dos registradores
#     -----------------------
#         n   : $a0
#         tmp : $t0
#     -----------------------
#
#------------------------------------------------------------------------------
# prólogo
            addiu $sp, $sp, -4          # ajustamos a pilha
# corpo do procedimento    
            # tmp = 1;
            addiu $t0, $zero, 1         # $t0 <- 1
            sw    $t0, 0($sp)           # tmp = 1
            # if(n==0) return 1;

    beq     $a0, $zero, N_EQ_0          # se n==0 desvie para N_EQ_0
N_NEQ_0:
    # $t0 <- n
    # $t1 <- tmp
    add     $t0, $zero, $a0             # $t0 <- n;
    add     $t1, $zero, $a0             # $t1 <- n;
        
LOOP:        
    sgt     $t2, $t0, 1                 # $t2 <- 1 se n>1 senão 0
    beq     $t2, $zero, END_LOOP        # se t2 = 0 (n<=1) saia do laço
    
    subi    $t0, $t0, 1                 # n = n - 1;
    mul     $t1, $t1,$t0                # tmp <- tmp*n
    j         LOOP                      # continua o laço
END_LOOP:
    move    $v0, $t1                    # guarda o valor de retorno
    j         EXIT                      # vai para o encerramento do procedimento    
N_EQ_0:
    addi    $v0, $zero, 1               # fact <- 1
EXIT:
# epílogo
# retorna ao procedimento chamador
    jr      $ra                         # retorna para a funcao chamadora
# fim do procedimento fact2    
###############################################################################    
