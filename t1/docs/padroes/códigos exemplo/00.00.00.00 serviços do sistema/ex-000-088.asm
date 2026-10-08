#***********************************************************************************************************************
# ex-000-088.asm               Copyright (C) 2023 Giovani Baratto
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Usamos o serviço 8 para ler uma string e o serviço 4 para apresentar uma string terminada com o caractere
# NULL (0x00)
#***********************************************************************************************************************


#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                       # 

.text
# Será realizada a leitura de uma string pelo terminal Run I/O, usando o serviço 8. Os caracteres lido no terminal são
# colocados temporariamente em uma região da memória (chamada de buffer).
#   (i) Criamos na memória uma região (buffer) para armazenar temporariamente os caracteres lidos do terminal. Neste 
#       problema reservamos no segmento de dados estáticos 32 bytes. O endereço inicial desta região é dada pelo rótulo 
#       buffer.
#  (ii) Colocamos em $a0 o endereço do buffer
# (iii) Colocamos em $a1 o número de caracteres que será lido
#  (iv) Carregamos em $v0 o número do serviço para realizar a leitura da string: 8
#   (v) Realizamos uma chamada ao sistema, solicitando que seja executado o serviço 8
# obs: Um buffer de tamanho n recebe até n-1 caracteres (bytes). Se for entrado n-1 caracteres, o último byte do buffer
# é preenchido com o valor 0x00 (NULL). Se for entrado um número menor que n-1 caracteres, será adicionado os caracteres
# fim de linha (new line, 0x0A) e o caractere NULL (0x00) ao buffer.
            la	    $a0, buffer             # $a0 <- endereço do buffer (ii)
            li      $a1, 32                 # $a1 <- tamanho do buffer (iii)
            li      $v0, 8                  # $v0 <- 8, número do serviço para ler uma string no terminal Run I/O
            syscall                         # chamada ao sistema para executar o serviço 8
# Neste trecho de código, apresentamos no terminal Run I/O uma string, usando o serviço 4
#   (i) colocar em $a0 a string que será apresentada
#  (ii) colocar em $v0 o número do serviço: 4
# (iii) Realizar uma chamada ao sistema com a instrução  syscall
            la      $a0, buffer             # $a0 <- endereço de memória da string a ser apresentada (buffer) (i)
            li      $v0, 4                  # carregamos em $v0 o número do serviço (ii)
            syscall                         # realizamos a chamada ao sistema para executar o serviço 4. (iii)
.data
# Normalmente definimos o buffer como
# buffer: .space 32 # buffer para 31 bytes mais o terminador nulo
# Vamos usar um buffer preenchido com o caractere 'X', para observarmos o seu preenchimento
buffer: .ascii "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"      # um buffer com 32 bytes, preenchido com o caractere 'X' (i)

