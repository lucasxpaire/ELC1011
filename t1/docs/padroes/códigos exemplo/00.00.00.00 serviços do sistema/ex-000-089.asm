#***********************************************************************************************************************
# ex-000-089.asm               Copyright (C) 2023 Giovani Baratto
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Usamos os serviços 34, 1, 36 para apresentar um valor em hexadecimal, decimal e decimal sem sinal.
# Usamos o serviço 11 para apresentar o caractere espaço, nova linha, 0 e x.
#***********************************************************************************************************************


#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                       # 

.text
# Usamos o serviço 34 para apresentar o número 0xAAAABBBB em hexadecimal
#   (i) Carregamos em $a0 o número que será apresentado em hexadecimal
#  (ii) Carregamos em $v0 o número do serviço: 34
# (iii) Realizamos uma chamada ao sistema com a instrução syscall 
            la      $t0, numero_teste       # $t0 <- endereço de numero_teste
            lw      $a0, 0($t0)             # $a0 <- número que será apresentado no terminal Run I/O
            li      $v0, 34                 # carregamos em $v0 o número do serviço: 34
            syscall                         # realizamos a chamada ao sistema para executar o serviço 34
# Enviamos o caractere espaço para o terminal. Usamos o serviço 11
#   (i) Carregamos em $a0 o caractere que será apresentado. É utilizado o byte menos significativo de $a0 e utilizada a
#       codificação ASCII.
#  (ii) Carregamos em $v0 o número do serviço
# (iii) Realizamos uma chamada ao sistema para executar o serviço
            li      $a0, ' '                # carregamos em $a0 o caractere espaço = ' ' = 0x20   
            li      $v0, 11                 # carregamos em $v0 o valor 11: serviço para apresentar o caractere de $a0
            syscall                         # realizamos uma chamada ao sistema para apresentar o caractere espaço
# Usamos o serviço 1 para apresentar o número com um inteiro decimal (com sinal)
#   (i) Carregamos em $a0 o número que será apresentado no terminal
#  (ii) Carregamos em $v0 o número do serviço, para apresentar um número decimal com sinal: 1
# (iii) Realizamos uma chamada ao sistema para executar o serviço
            lw      $a0, 0($t0)             # $a0 <- inteiro que será apresentado no terminal em decimal
            li      $v0, 1                  # $v0 <- 1: serviço para imprimir o valor decimal do inteiro em $a0
            syscall                         # realizamos uma chamada ao sistema para imprimir o número inteiro em decimal
#      
# Enviamos o caractere espaço para o terminal. Usamos o serviço 11
#   (i) Carregamos em $a0 o caractere que será apresentado. É utilizado o byte menos significativo de $a0 e utilizada a
#       codificação ASCII.
#  (ii) Carregamos em $v0 o número do serviço
# (iii) Realizamos uma chamada ao sistema para executar o serviço
            li      $a0, ' '                # carregamos em $a0 o caractere espaço = ' ' = 0x20   
            li      $v0, 11                 # carregamos em $v0 o valor 11: serviço para apresentar o caractere de $a0
            syscall                         # realizamos uma chamada ao sistema para apresentar o caractere espaço
# Usamos o serviço 36 para apresentar o número com um inteiro decimal sem sinal
#   (i) Carregamos em $a0 o número sem sinal que será apresentado no terminal
#  (ii) Carregamos em $v0 o número do serviço, para apresentar um número decimal sem sinal: 36
# (iii) Realizamos uma chamada ao sistema para executar o serviço
            lw      $a0, 0($t0)             # $a0 <- inteiro que será apresentado no terminal em decimal
            li      $v0, 36                 # $v0 <- 36: serviço para imprimir o valor decimal sem sinal do inteiro em $a0
            syscall                         # realizamos uma chamada ao sistema para imprimir o número decimal sem sinal               
.data
numero_teste: .word 0xAAAABBBB     # um número para testar os serviços. Este número equivale ao decimal -1431651397 ou 
                                   # ao decimal sem sinal 2863315899. 

