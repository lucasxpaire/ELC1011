#***********************************************************************************************************************
# ex-000-090.asm               Copyright (C) 2023 Giovani Baratto
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Escrevemos no arquivo teste.bin os inteiros 0x14B4820 e 0x8CA40010, armazenados no buffer_escrita. Depois, 
# realizamos a leitura destes inteiros do arquivo teste.bin e armazenamos no buffer_leitura.
#***********************************************************************************************************************


#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                       # 

.text
#  _____               _ _             _                    _            
# | ____|___  ___ _ __(_) |_ __ _     / \   _ __ __ _ _   _(_)_   _____  
# |  _| / __|/ __| '__| | __/ _` |   / _ \ | '__/ _` | | | | \ \ / / _ \ 
# | |___\__ \ (__| |  | | || (_| |  / ___ \| | | (_| | |_| | |\ V / (_) |
# |_____|___/\___|_|  |_|\__\__,_| /_/   \_\_|  \__, |\__,_|_| \_/ \___/ 
#                                                  |_| 

# Abrimos um arquivo para a escrita dos inteiros 0x14B4820 e 0x8CA40010
# Para abrir um arquivo para escrita, usamos o serviço 13:
#   (i) Armazenamos em $a0 o endereço da string, terminada com um nulo, com o nome do arquivo
#  (ii) Armazenamos em $a1 os flags (sinalizadores). Usamos o valor 0 para $a1 se desejamos abrir o arquivo para a 
#       leitura. Utilizamos o valor 1 se desejamos abrir o arquivo para a escrita. Os valores anteriores do arquivo são 
#       perdidos. Usamos o valor 9 se desejamos anexar ao arquivo novos dados. Neste caso os dados anteriores são 
#       preservados. Se o arquivo não existe para a escrita, ele é criado. 
# (iii) Armazenamos em $a2 o modo. O modo não é usado. Escrevemos em $a2 sempre o valor 0.
#  (iv) Armazenamos em $v0 o valor 13, indicando o serviço para a abertura de um arquivo.
#   (v) Realizamos uma chamada ao sistema, para executarmos o serviço de abertura do arquivo.
#  (vi) Armazenamos o descritor do arquivo, retornado pelo registrador $v0, para utilizar nas operações de leitura, 
#       escrita ou para fechar o arquivo.
            la	    $a0, nome_do_arquivo    # $a0 <- endereço da string com o nome do arquivo
            li      $a1, 1                  # $a1 <- flag igual a 1: abre o arquivo e escreve do início.
            li      $a2, 0                  # $a2 <- modo. Não é usado
            li      $v0, 13                 # $v0 <- serviço 13: abre arquivo para leitura ou escrita
            syscall                         # realizamos uma chamada ao sistema, para a abertura do arquivo
            la      $t0, descritor_arquivo  # $t0 <- endereço onde será armazenado o descritor do arquivo
            sw      $v0, 0($t0)             # armazenamos em descritor_arquivo o descritor encontrado na abertura do arquivo
# TODO: Fazer a verificação se houve erro na abertura do arquivo. Em caso de erro, o descritor será um inteiro negativo
# Preenchemos o buffer de escrita com dados, os inteiros 0x14B4820 e 0x8CA40010. O buffer pode ser imaginado como um 
# vetor temporário de bytes
            la      $t0, buffer_escrita     # $t0 <- endereço base do buffer para a escrita
            lui     $t1, 0x014B             # $t1 <- 0x014B_0000
            ori     $t1, $t1, 0x4B20        # $t1 <- 0x014B_4820
            sw	    $t1, 0($t0)             # buffer[0] = 0x01, buffer[1] = 0x4B, buffer[2] = 0x48 e buffer[3]=0x20
            lui     $t1, 0x8CA4             # $t1 <- 0x8CA4_0000
            ori     $t1, $t1, 0x0010        # $t1 <- 0x8CA4_0010
            sw	    $t1, 4($t0)             # buffer[4] = 0x8C, buffer[5] = 0xA4, buffer[6] = 0x00 e buffer[7]=0x10
# Escrevemos os inteiros 0x14B4820 e 0x8CA40010, armazenados no buffer_escrita.  Para a escrita, usamos o serviço 15:
#   (i) Armazenamos em $a0 o descritor do arquivo.
#  (ii) Armazenamos em $a1 o endereço do buffer de escrita
# (iii) Armazenamos em $a2 o número de bytes que serão escritos do buffer de escrita para o arquivo.
#  (iv) Armazenamos em $v0 o número do serviço para a escrita em arquivo: 15
#   (v) Realizamos uma chamada ao sistema (syscall) para executarmos a escrita dos dados do buffer de escrita para o 
#       arquivo. 
            la      $t0, descritor_arquivo  # $t0 <- endereço do descritor do arquivo
            lw      $a0, 0($t0)             # $a0 <- descritor do arquivo
            la	    $a1, buffer_escrita     # $a1 <- endereço do buffer com os dados que serão escritos
            li      $a2, 8                  # $a2 <- número de caracteres (bytes) que serão escritos do buffer para o arquivo
            li      $v0, 15                 # $v0 <- serviço 15: escreve em um arquivo
            syscall                         # realiza uma chamada ao sistema, escrevendo 8 caracteres do buffer no arquivo
# TODO: Fazer a verificação se houve erro na escrita do arquivo. $v0 retorna com o número de caracteres escritos e com 
# um valor negativo se ocorreu algum erro de escrita.
# Fechamos o arquivo com o serviço 16:
#   (i) Carregamos em $a0 o descritor do arquivo
#  (ii) Carregamos em $v0 o número do serviço para fechar o arquivo: 16
# (iii) Realizamos uma chamada ao sistema para executarmos o fechamento do arquivo.
            # $a0 é carregado com o descritor do arquivo. $a0 está carregado com o descritor quando escrevemos as instruções
            li      $v0, 16                 # $v0 <- serviço 16: fechamos o arquivo com o descritor em $a0
            syscall                         # realizamos uma chamada ao sistema, fechando o arquivo com o descritor em $a0


#  _         _ _                        _                    _            
# | |    ___(_) |_ _   _ _ __ __ _     / \   _ __ __ _ _   _(_)_   _____  
# | |   / _ \ | __| | | | '__/ _` |   / _ \ | '__/ _` | | | | \ \ / / _ \ 
# | |__|  __/ | |_| |_| | | | (_| |  / ___ \| | | (_| | |_| | |\ V / (_) |
# |_____\___|_|\__|\__,_|_|  \__,_| /_/   \_\_|  \__, |\__,_|_| \_/ \___/ 
#                                                   |_| 
# Abrimos um arquivo para a leitura
            la	    $a0, nome_do_arquivo    # $a0 <- endereço da string com o nome do arquivo
            li      $a1, 0                  # $a1 <- flag igual a 0: abre o arquivo para leitura.
            li      $a2, 0                  # $a2 <- modo. Não é usado
            li      $v0, 13                 # $v0 <- serviço 13: abre arquivo para leitura ou escrita
            syscall                         # realizamos uma chamada ao sistema, para a abertura do arquivo
            la      $t0, descritor_arquivo  # $t0 <- endereço onde será armazenado o descritor do arquivo
            sw      $v0, 0($t0)             # armazenamos em descritor_arquivo o descritor encontrado na abertura do arquivo
# TODO: Fazer a verificação se houve erro na abertura do arquivo. Em caso de erro, o descritor será um inteiro negativo
# Lemos os inteiros 0x14B4820 e 0x8CA40010 e armazenamos em buffer_leitura. Para a leitura do arquivo, usamos o serviço 14:
#   (i) Carregamos em $a0 o descritor do arquivo.
#  (ii) Carregamos em $a1 o endereço do buffer de leitura
# (iii) Carregamos em $a2 o número de bytes lidos do arquivo para o bufer de leitura
#  (iv) Carregamos em $v0 o número do serviço: 14
#   (v) Realizamos uma chamada ao sistema para executarmos a leitura do arquivo 
            lw      $a0, 0($t0)             # $a0 <- descritor do arquivo. $t0 contém o endereço do descritor_arquivo
            la	    $a1, buffer_leitura     # $a1 <- endereço do buffer com os dados que serão escritos
            li      $a2, 8                  # $a2 <- número de caracteres (bytes) que serão lidos do arquivo para o buffer
            li      $v0, 14                 # $v0 <- serviço 14: leia um arquivo
            syscall                         # realiza uma chamada ao sistema, lendo 8 caracteres para o buffer no arquivo      
# TODO: Fazer a verificação da leitura do arquivo. O registrador $v0 contém o número de caracteres lidos. Se o valor de 
# $v0 é zero, encontramos o final do arquivo (end-of-file). Se o valor do registrador $v0 é negativo, ocorreu algum
# erro de leitura                 
# Fechamos o arquivo
            # $a0 é carregado com o descritor do arquivo. $a0 está carregado com o descritor quando lemos as instruções
            li      $v0, 16                 # $v0 <- serviço 16: fechamos o arquivo com o descritor em $a0
            syscall                         # realizamos uma chamada ao sistema, fechando o arquivo com o descritor em $a0
.data
descritor_arquivo: .word 0                  # descritor do arquivo: um inteiro não negativo
nome_do_arquivo: .asciiz "teste.bin"        # nome do arquivo 
.align 2                                    # Alinhamos o endereço de buffer para ser múltiplo de 4, senão erro: 
                                            # "store address not aligned on word boundary" ou endereço de armazenamento
                                            # não está alinhado com os limites da palavra
buffer_escrita: .space 32                   # buffer com os dados que serão escritos no arquivo
buffer_leitura: .space 32                   # buffer para a leitura do arquivo

