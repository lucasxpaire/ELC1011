#***********************************************************************************************************************
# ex-000-087.asm               Copyright (C) 2023 Giovani Baratto
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Leitura de um número inteiro usando o serviço 5 do sistema e apresentação de um número usando o serviço 1
#***********************************************************************************************************************


#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                       # 

.text
# Exemplo: Lemos no terminal RUN I/O do simulador Mars um número inteiro, usando o serviço 5, e, armazenamos o valor em 
# $s0. Um cursor irá piscar no terminal, esperando que o número seja digitado.
#   (i) colocar em $v0 o número do serviço: 5
#  (ii) Realizar uma chamada ao sistema com a instrução  syscall      
# (iii) Fazer a leitura do inteiro no registrador $v0  
            li      $v0, 5                  # carregamos em $v0 o número do serviço: 5 (i)
            syscall                         # chamada ao sistema para executar o serviço 5 (ii)
            move    $s0, $v0                # $s0 <- $v0, guardamos em $s0 o inteiro lido (iii)
# Exemplo: Apresentamos no terminal Run I/O do simulador Mars um número inteiro armazenado em $s0, usando o serviço 1
#   (i) colocar em $a0 o número inteiro que será apresentado
#  (ii) colocar em $v0 o número do serviço: 1
# (iii) Realizar uma chamada ao sistema com a instrução  syscall
            move	$a0, $s0                # carregamos em $a0 o número armazenado em $s0 (i)
            li      $v0, 1                  # carregamos em $v0 o número do serviço (ii)
            syscall                         # realizamos a chamada ao sistema para executar o serviço 1. (iii)


