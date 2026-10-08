#*******************************************************************************
# ex-000-084.asm              Copyright (C) 2022 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (giovani.baratto@ufsm.br)
# Descrição: Este programa faz a leitura de uma string, remove o carcatere line 
# feed '\n', se existir, e imprime a string entre aspas duplas. Um programa 
# semelhante na linguagem C é apresentado no exemplo ex-000-084.c. Na versão em 
# assembly não implementamos as funções printf e fgets: usamos os serviços de
# impressão e leitura de uma string do programa MARS.
#
# void remove_nova_linha(char *buffer) {
#   char ch;
#   while ((ch = *buffer) != '\0') {
#     if (ch == '\n') {
#       *buffer = '\0';
#       break;
#     }
#     buffer++;
#   }
# }

# int main(void) {
#   char buffer[8];
#   printf("Entre com uma string: ");
#   fgets(buffer, sizeof(buffer), stdin);
#   remove_nova_linha(buffer);
#   printf("\"%s\"\n", buffer);

#   return 0;
# }	
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                   #
.text
.eqv SERVICO_IMPRIME_STRING     4
.eqv SERVICO_LEIA_STRING        8
.eqv SERVICO_IMPRIME_CARACTERE  11
.eqv SERVICO_EXIT2              17

init:
            jal     main                # executamos o procedimento main
finit:
            move    $a0, $v0            # $a0 <- valor de retorno do procedimento main
            li      $v0, SERVICO_EXIT2  # $v0 <- 17, serviço exit2
            syscall                     # encerramos o programa


# void remove_nova_linha(char *buffer) {
remove_nova_linha:
# Mapa da Pilha
# $sp + 0 | ch

# Mapa dos Registradores
# $a0     | * buffer
# $t0     | ch
# $t1     | caractere '\n'

# prólogo
#   char ch;
            addiu   $sp, $sp, -4        # ajustamos a pilha
# corpo do programa
#   while ((ch = *buffer) != '\0') {
rnl_while_inicio:
            j       rnl_while_verifica_condicao # verificamos se o laço while será executado
rnl_while_codigo:
rnl_if_inicio:
#     if (ch == '\n') {
            li      $t1, '\n'           # $t1 <- '\n'
            bne     $t0, $t1, rnl_if_fim # se ch != '\n' não execute o código em if                           
#       *buffer = '\0';
            sb      $zero, 0($a0)       # trocamos o caractere '\n' por '\0'
#       break;
            j       rnl_while_fim       # saímos do laço while
#     }
rnl_if_fim:
#     buffer++;
            addi    $a0, $a0, 1         # incrementamos o ponteiro buffer
#   }
rnl_while_verifica_condicao:
#   while ((ch = *buffer) != '\0') {
            lbu     $t0, 0($a0)         # $t0 <- *buffer
            sb      $t0, 0($sp)         # ch = *buffer
            bne     $t0, $zero, rnl_while_codigo # se a condição é verdadeira execute o código
rnl_while_fim:
# epílogo
            addiu   $sp, $sp, 4         # ajustamos a pilha
            jr      $ra                 # retornamos ao procedimento chamador


# int main(void) {
main:
# Mapa da Pilha
# $sp + 32| $ra
# $sp + 0 | buffer

# prólogo
#   char buffer[32];
            addiu   $sp, $sp, -36       # ajustamos a pilha
            sw		$ra, 32($sp)	    # armazenamos na pilha o endereço de retorno em $ra
# corpo do programa
#   printf("Entre com uma string: ");
            li      $v0, SERVICO_IMPRIME_STRING # serviço 4, imprime uma string
            la      $a0, str_01         # $a0 <- endereço da string
            syscall                     # imprimimos a string
#   fgets(buffer, sizeof(buffer), stdin);
            li      $v0, SERVICO_LEIA_STRING # serviço 8, leia uma string
            addi    $a0, $sp, 0         # endereço do buffer $a0 <- $sp + 0
            li      $a1, 32             # tamanho do buffer
            syscall                     # Uma string é lida e armazenada em buffer
#   remove_nova_linha(buffer);
            addi    $a0, $sp, 0         # $a0 <- endereço do buffer
            jal     remove_nova_linha   # chamamos o procedimento remove_nova_linha
#   printf("\"%s\"\n", buffer);
            # imprimimos o caractere '"'
            li      $v0, SERVICO_IMPRIME_CARACTERE # serviço 11, imprime um carcatere
            li      $a0, '"'            # caractere impresso '"'
            syscall                     # imprimimos o carcatere '"'
            # imprimimos a string lida em buffer
            li      $v0, SERVICO_IMPRIME_STRING # serviço 4, imprime uma string
            addi    $a0, $sp, 0         # $a0 <- endereço do buffer
            syscall                     # imprimimos a string buffer
            # imprimimos o caractere '"'
            li      $v0, SERVICO_IMPRIME_CARACTERE # serviço 11, imprime um carcatere
            li      $a0, '"'            # caractere impresso '"'
            syscall                     # imprimimos o carcatere '"'
            # imprimimos o caractere '\n'
            li      $v0, SERVICO_IMPRIME_CARACTERE # serviço 11, imprime um carcatere
            li      $a0, '\n'           # $a0 <- nova linha
            syscall                     # desviamos para uma nova linha
# epílogo  
#   return 0;   
            li      $v0, 0              # retornamos o valor 0
            lw		$ra, 32($sp)		# restauramos o endereço de retorno
            addiu   $sp, $sp, 36        # ajustamos a pilha
            jr		$ra					# retornamos ao procedimento chamador
            
            

.data 
str_01: .asciiz "Entre com uma string: "
