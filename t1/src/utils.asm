#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: Utilitarios para tratamento de strings e derivacao de chave
#*******************************************************************************

.text
.globl remove_quebra_linha
.globl deriva_chave

###############################################################################
# remove_quebra_linha
# Remove delimitadores de fim de linha ('\n' = 10 e '\r' = 13) substituindo por '\0'.
#
# Entrada:
#   $a0: endereco da string terminada em nulo
# Retorno:
#   $v0: comprimento util da string
# Registradores usados: $t0, $t1, $t2
###############################################################################
remove_quebra_linha:
            move    $t0, $a0
            li      $v0, 0              # contador de caracteres

laco_varre_string:
            lbu     $t1, 0($t0)
            beqz    $t1, fim_varredura

            # Verifica se encontrou '\n' ou '\r'
            li      $t2, 10
            beq     $t1, $t2, trunca_delimitador
            li      $t2, 13
            beq     $t1, $t2, trunca_delimitador

            addi    $t0, $t0, 1
            addi    $v0, $v0, 1
            j       laco_varre_string

trunca_delimitador:
            sb      $zero, 0($t0)       # substitui por '\0'

fim_varredura:
            jr      $ra


###############################################################################
# deriva_chave
# Converte a senha em uma chave de 16 bits por dobramento XOR:
#   - Byte Alto: XOR dos caracteres de indices pares
#   - Byte Baixo: XOR dos caracteres de indices impares
#
# Entrada:
#   $a0: endereco da string da senha
# Retorno:
#   $v0: chave de 16 bits gerada
# Registradores usados: $t0, $t1, $t2, $t3, $t4, $t5
###############################################################################
deriva_chave:
            move    $t0, $a0            # ponteiro para a senha
            li      $t1, 0              # acumulador par
            li      $t2, 0              # acumulador impar
            li      $t3, 0              # indice do caractere

laco_deriva_chave:
            lbu     $t4, 0($t0)
            beqz    $t4, fim_derivacao

            # Testa se o indice e par ou impar
            andi    $t5, $t3, 1
            beqz    $t5, acumula_par

            # Indice impar
            xor     $t2, $t2, $t4
            j       avanca_indice

acumula_par:
            # Indice par
            xor     $t1, $t1, $t4

avanca_indice:
            addi    $t0, $t0, 1
            addi    $t3, $t3, 1
            j       laco_deriva_chave

fim_derivacao:
            andi    $t1, $t1, 0xFF
            andi    $t2, $t2, 0xFF

            # Concatena em palavra de 16 bits: (t1 << 8) | t2
            sll     $v0, $t1, 8
            or      $v0, $v0, $t2
            jr      $ra
