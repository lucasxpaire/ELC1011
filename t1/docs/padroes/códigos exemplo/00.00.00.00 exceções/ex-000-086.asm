#*******************************************************************************
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
#
# Descrição: Exemplo didático de uma rotina para tratamento de exceções em MIPS.
# O procedimento principal (main) gera propositalmente duas exceções:
#   1. Um trap de igualdade imediata (instrução teqi), gerando a exceção 13 (Trap).
#   2. Um overflow aritmético de soma (instrução add), gerando a exceção 12 (Overflow).
#
# O tratador de exceções (.ktext):
#   - Salva com segurança os registradores que serão modificados (incluindo $at)
#   - Acessa os registradores do Coprocessador 0 (CP0):
#       * $13 (Cause): Para identificar a causa da exceção.
#       * $14 (EPC): Para identificar o endereço da instrução causadora.
#   - Imprime o código da causa e o endereço da instrução em hexadecimal na tela.
#   - Incrementa o EPC em 4 para retornar pulando a instrução que gerou a falha,
#     prevenindo um loop infinito de exceções.
#   - Retorna de modo seguro usando a instrução 'eret', a qual atômica e seguramente
#     restaura o PC para o valor em EPC e limpa o bit de nível de exceção (EXL) no Status.
#
# Referência: Código das páginas A-36 e A-37 do livro do Patterson & Hennessy (5ª ed).
# Simulador: MARS (MIPS Assembler and Runtime Simulator)
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O               #
.text
.globl      main
   .text
main:
            teqi    $zero, 0        # $zero = 0, a exceção é gerada
            la      $a0, msg_retorno_excecao # $a0 <- msg_retorno_excecao
            li      $v0, 4          # serviço para imprimir uma string
            syscall                 # imprime a string em msg_retorno_excecao
            li      $t0,0x80000000	# $t0 <- -2.147.483.648
            add     $t0, $t0, $t0   # temos o overflow da operação de adição e uma execção
            la      $a0, msg_retorno_excecao # $a0 <- msg_retorno_excecao
            li      $v0, 4          # serviço para imprimir uma string
            syscall                 # imprime a string em msg_retorno_excecao
            li      $a0, 0          # $a0 <- valor de retorno do programa 
            li      $v0, 17         # serviço exit2 (código 17)
            syscall                 # terminamos o programa
.data
msg_retorno_excecao: 
            .asciiz     "Retorno da rotina de tratamento da exceção\n-----\n"

# Rotinas para o tratamento das interrupções

.ktext 0x80000180                   # endereço da rotina para tratamento das exceções
            # salvamos os registradores que serão alterados
            move    $k1, $at        # salvamos o registrador $at: usado pelo compilador
            sw      $a0, save0      # salvamos os registradores $a0, $a1 e $v0
            sw      $a1, save1      #
            sw      $v0, save2      #
            # imprimimos o código da exceção em hexadecimal
            la      $a0, msg_codigo_excecao # $a0 <- endereço de msg_endereco_excecao
            li      $v0, 4          # serviço para imprimir uma string
            syscall                 # imprimimos a string msg_endereco_excecao
            mfc0    $k0, $13        # $k0 <- Coprocessor0 Register 13 (Cause)
            srl     $a0, $k0, 2     # deslocamos o campo ExcCode para a direita
            andi    $a0, $a0, 0x1F  # isolamos o campo ExcCode (5 bits)
            li      $v0, 34         # serviço para imprimir um inteiro em hexadecimal
            syscall	               # imprimimos o inteiro em $a0 em hexadecimal
            li      $a0, '\n'       # $a0 <- caractere fim de linha
            li      $v0, 11         # serviço para imprimir o caractere
            syscall                 # imprimimos o caractere de $a0
            # imprimimos o endereço que causou a exceção
            mfc0    $k0, $14        # $k0 <- Coprocessor0 Register 14 (EPC)
            la      $a0, msg_endereco_excecao # $a0 <- endereço de msg_endereco_excecao
            li      $v0, 4          # serviço para imprimir uma string
            syscall 			    # imprimimos a string msg_endereco_excecao
            move    $a0, $k0        # $a0 <- EPC (move é mais legível que addu $a0, $zero, $k0)
            li      $v0, 34         # serviço para imprimir um inteiro em hexadecimal
            syscall	               # imprimimos o inteiro em $a0 em hexadecimal
            li      $a0, '\n'       # $a0 <- caractere fim de linha
            li      $v0, 11         # serviço para imprimir o caractere
            syscall                 # imprimimos o caractere de $a0
handler_exit:
            # Não reexecutamos a instrução que causou a exceção
            mfc0    $k0, $14        # $k0 <- EPC (endereço da instrução que causou a exceção)
            addiu   $k0, $k0, 4     # $k0 <- EPC + 4. Não reexecutamos a instrução que causou a exceção
            mtc0    $k0, $14        # $14 (EPC) <- endereço da próxima instrução
            # zeramos o registrador Cause
            mtc0    $zero, $13      # $13 (Cause) <- 0 (opcional, mas boa prática)
            # zeramos o bit exception level e setamos o bit interrupt enable
            mfc0    $k0, $12        # $k0 <- Coprocessor0 Register 12 (Status)
            andi    $k0, 0xFFFD     # bit exception level (EXL) é zerado
            ori     $k0, 0x0001     # bit interrupt enable é setado: permite interrrupções
            mtc0    $k0, $12        # $12 (Status) <- EXL=0, INE=1
            # restauramos os registradores e retornamos
            lw      $v0, save2      # restauramos os registradores $a0, $a1 e $v0
            lw      $a1, save1      #
            lw      $a0, save0      #
            move    $at, $k1        # restauramos o registrador $at
            eret                    # retorno da exceção

.kdata	
msg_endereco_excecao:
            .asciiz "Endereço da instrução que causou a exceção: "
msg_codigo_excecao:
            .asciiz "código da exceção: "
save0:      .word 0                 # guardamos $a0
save1:      .word 0                 # guardamos $a1   
save2:      .word 0                 # guardamos $v0
