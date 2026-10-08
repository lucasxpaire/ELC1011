#*******************************************************************************
# exercicio075.asm               Copyright (C) 2021 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Apresentamos alguns serviços para o MIPS, oferecidos pelo simulador MARS
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    05.01.2021     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O               #

# segmento de dados estático
.data
# strings usadas nos exemplos
str_digite_string:              .asciiz "Digite uma string: "
str_digite_inteiro:             .asciiz "Digite um número inteiro: "
str_string_digitada:            .asciiz "Você digitou a seguinte string:\n"
str_inteiro_digitado:           .asciiz "Você digitou o seguinte número inteiro:\n"
str_string_mensagem_aviso:      .asciiz "Digite um caractere"
buffer:                         .space 256 # armazena temporariamente um dado lido

# segmento de texto (código)
.text                                   
.globl      main

###############################################################################
main:
###############################################################################
# exemplos do uso de serviços

            jal     le_imprime_string_caractere
            jal     le_imprime_inteiro
            jal     termina_programa
            
            

###############################################################################            
le_imprime_string_caractere:
###############################################################################
# prólogo
# corpo do programa

# serviço 4: impressão de uma string
# $a0: endereço da string
            la      $a0, str_digite_string # $a0: endereço da string
            li      $v0, 4          # serviço 4, impressão de uma string
            syscall                 # executamos o serviço
# serviço 8, read string, leitura de uma string para um buffer
# $a0: endereço do buffer
# $a1 número máximo de carcateres que serão lidos
            la      $a0, buffer     # $a0: endereço do buffer
            li      $a1, 256        # $a1: número máximo de carcateres lidos
            li      $v0, 8          # serviço 8: leia string
            syscall                 # executamos o serviço
# serviço 4: impressão de uma string
# $a0: endereço da string
            la      $a0, buffer # $a0: endereço da string
            li      $v0, 4          # serviço 4, impressão de uma string
            syscall                 # executamos o serviço    
# serviço 54: InputDialogString, janela de diálogo para entrada da string
# $a0: string terminada com um nulo com uma mensagem ao usuário
# $a1: endereço do buffer de entrada
# $a2: número máximo de carcateres que serão lidos
            la      $a0, str_digite_string # $a0:endereço da mensagem ao usuário
            la      $a1, buffer     # $a1: endereço do buffer de entrada
            li      $a2, 256        # $a2: número máximo de caracteres lidos
            li      $v0, 54         # serviço 54, janela de diálogo para entrada de string
            syscall
            
# serviço 59, MessageDialogString, janela de diálogo apresentando uma string
# $a0: string terminada com um nulo com tipo da mensagem para o usuário
# $a1: string terminada com um nulo, apresentada após a primeira string
            la      $a0, str_string_digitada # $a0: endereço da mensagem 1
            la      $a1, buffer     # $a1: endereço da mensagem 2
            li      $v0, 59         # serviço 59, janela de diálogo com mensagem (string)
            syscall
            
# serviço 55, MessageDialog, janela de diálogo para a apresentar uma mensagem (string)
# $a0: string terminada com nulo com a mensagem para o usuário
# $a1: ícone que indica o tipo da mensagem
#      0: mensagem de erro
#      1: mensagem de aviso
#      2: mensagem de questão
#      outros: nenhum ícone é apresentado
            la      $a0, str_string_mensagem_aviso # $a0: endereço da mensagem (string)
            li      $a1, 1          # $a1: tipo da mensagem
            li      $v0, 55         # serviço 55, janela de diálogo com mensagem (string)
            syscall
# serviço 12, read character, leia um caractere
# $v0: carcatere lido 
            li      $v0, 12
            syscall
# serviço 11, print character, imprime um caractere
# $a0: caractere que será impresso
            move    $a0, $v0
            li      $v0, 11
            syscall
# epílogo   
            jr      $ra

###############################################################################            
le_imprime_inteiro:            
###############################################################################
# prólogo
# corpo do programa
# serviço 4, print string, impressão de uma string
# $a0: endereço da string
            la      $a0, str_digite_inteiro # $a0: endereço da string
            li      $v0, 4          # serviço 4, impressão de uma string
            syscall                 # executamos o serviço
# serviço 5, read integer, lê um número inteiro
# $v0: inteiro lido
            li      $v0, 5          # serviço 5, leitura de um inteiro
            syscall                 # executamos o serviço
# serviço 1, print integer, imprime um número inteiro
# $a0: inteiro para imprimir
            move    $a0, $v0        # $a0: número inteiro
            li      $v0, 1          # serviço 1, leitura de um inteiro
            syscall                 # executamos o serviço    
# serviço 11, print character, imprime um caractere
# $a0: caractere que será impresso
            # uma nova linha
            li      $a0, '\n'       # $a0 = '\n', nova linha
            li      $v0, 11
            syscall   
#serviço 34. print integer in hexadecimal, imprime um inteiro em hexadecimal
# $a0: inteiro para imprimir
            li      $a0, 12345      # $a0: inteiro para imprimir
            li      $v0, 34         # serviço 34, imprime um inteiro em hexadecimal
            syscall                 # executa o serviço
# serviço 11, print character, imprime um caractere
# $a0: caractere que será impresso
            # uma nova linha
            li      $a0, '\n'       # $a0 = '\n', nova linha
            li      $v0, 11
            syscall   
#serviço 35. print integer in binary, imprime um inteiro em binário
# $a0: inteiro para imprimir
            li      $a0, 12345      # $a0: inteiro para imprimir
            li      $v0, 35         # serviço 35, imprime um inteiro em binário
            syscall                 # executa o serviço            
# serviço 11, print character, imprime um caractere
# $a0: caractere que será impresso
            # uma nova linha
            li      $a0, '\n'       # $a0 = '\n', nova linha
            li      $v0, 11
            syscall      
#serviço 36. print integer as unsigned, imprime um inteiro sem sinal
# $a0: inteiro para imprimir
            li      $a0, 12345      # $a0: inteiro para imprimir
            li      $v0, 36         # serviço 36, imprime um inteiro sem sinal
            syscall                 # executa o serviço  
# serviço 11, print character, imprime um caractere
# $a0: caractere que será impresso
            # uma nova linha
            li      $a0, '\n'       # $a0 = '\n', nova linha
            li      $v0, 11
            syscall   
# serviço 40, set seed, configura a semente do gerador pseudoaleatório
# use este serviço se quiser gerar uma sequência pseudoaleatória previsível
# $a0: id(identificação) do gerador de números aleatórios (um inteiro)
# $a1: semente do gerador com o id dado por $a0
            li      $a0, 0          # $a0: identificador do gerador pseudoaleatório
            li      $a1, 1234       # $a1: valor da semente
            li      $v0, 40         # serviço 40, configuração da semente dos geradores pseudoaleatórios
            syscall
# serviço 41, random int, gera um valor inteiro pseudoaleatório uniformemente distribuído
# $a0 id(identificador, um inteiro) do gerador da sequência pseudoaleatória (número aleatório)
# retorna $a0: número pseudoaleatório
            li      $a0, 0          # $a0: identificador do gerador pseudoaleatório
            li      $v0, 41         # serviço 41, gera um número pseudoaleatório
            syscall
# serviço 1, print integer, imprime um número inteiro
# $a0: inteiro para imprimir
            # $a0: número inteiro
            li      $v0, 1          # serviço 1, leitura de um inteiro
            syscall                 # executamos o serviço    
# serviço 11, print character, imprime um caractere
# $a0: caractere que será impresso
            # uma nova linha
            li      $a0, '\n'       # $a0 = '\n', nova linha
            li      $v0, 11
            syscall      
# serviço 42, random int range, gera um valor inteiro pseudoaleatório uniformemente distribuído
# entre 0 e o valor em $a1
# $a0 id(identificador, um inteiro) do gerador da sequência pseudoaleatória (número aleatório)
# $a1: máximo valor inteiro gerado por este serviço
# retorna $a0: número pseudoaleatório
            li      $a0, 0          # $a0: identificador do gerador pseudoaleatório
            li      $a1, 10         # $a1: máximo valor gerado
            li      $v0, 42         # serviço 42, gera um número pseudoaleatório
            syscall
# serviço 1, print integer, imprime um número inteiro
# $a0: inteiro para imprimir
            # $a0: número inteiro
            li      $v0, 1          # serviço 1, leitura de um inteiro
            syscall                 # executamos o serviço               
# serviço 51, InputDialogInt, Janela de diálogo para entrar com um inteiro
# $a0: endereço da string terminada com um nulo com a mensagem ao usuário
# retorna $a0: o inteiro lido
# retorna $a1: o estado de retorno
#   0: O número inteiro foi corretamente lido
#   -1: O número não pôde ser corretamente analisado
#   -2: O botão cancela foi pressionado
#   -3: O botão OK foi pressionado mas nenhum inteiro foi digitado no campo
            la      $a0, str_digite_inteiro # $a0: endereço da mensagem ao usuário
            li      $v0, 51         # serviço 51, janela de diálogo para entrar com um inteiro
            syscall                 # executamos o serviço
# serviço 56, MessageDialogInt, janela de diálogo para apresentar um inteiro
# $a0: endereço de uma string terminada com nulo com uma mensagem ao usuário
# $a1: valor inteiro a ser apresentado
            move    $a1, $a0        # $a1: inteiro a ser apresentado na janela de diálogo
            la      $a0, str_inteiro_digitado # $a0: endereço da string com uma mensagem ao usuário
            li      $v0, 56         # serviço 56, janela de diálogo para apresentar um inteiro
            syscall                 # executamos o serviço
# epílogo
            jr      $ra             # retornamos ao procedimento chamador
            
###############################################################################           
termina_programa:
###############################################################################
# prólogo
# corpo do programa
# serviço 17: exit2, termina com um valor de retorno
# $a0: valor de retorno. Usamos o valor 0 para indicar que a execução do programa foi
# realizada com sucesso e um valor diferente de 0 para indicar que a execução terminou
# com erro
            li      $a0, 0          # $a0 -> valor de retorno do programa
            li      $v0, 17         # serviço 17, terminamos o programa com valor de retorno
            syscall                 # executamos o serviço


# serviço 10: exit, termina a execução do programa
            li      $v0, 10         # serviço 10, terminamos o programa
            syscall                 # executamos o serviço
# epílogo
            jr      $ra         
                       
