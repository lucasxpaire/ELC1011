# Spec-07: Padrões de Codificação e Estilo em Assembly MIPS

## 1. Visão Geral
Esta especificação estabelece as diretrizes estritas de estilo de codificação, nomenclatura e documentação interna dos arquivos Assembly MIPS para o Trabalho 1 da disciplina **ELC1011 (Organização de Computadores - UFSM)**, ministrada pelo **Prof. Giovani Baratto**.

O objetivo é assegurar que o código-fonte reflita com fidelidade os padrões acadêmicos adotados nas aulas práticas e nos exemplos de referência da disciplina ([docs/padroes/códigos exemplo](../../padroes/c%C3%B3digos%20exemplo/)), com todos os identificadores em português, eliminação de termos em inglês e comentários técnicos no padrão do professor.

---

## 2. Nomenclatura dos Arquivos Físicos

Por convenção padrão de engenharia de software, a estrutura e os nomes dos arquivos do projeto são **mantidos em inglês**:

- `src/main.asm`: Ponto de entrada e interface interativa com o usuário.
- `src/saes.asm`: Procedimentos do motor criptográfico S-AES.
- `src/saes_tables.asm`: Tabelas estáticas de substituição e corpos finos.
- `src/file_io.asm`: Procedimentos de leitura, escrita e streaming de arquivos.
- `src/utils.asm`: Procedimentos utilitários de tratamento de strings e derivação de chave.

---

## 3. Cabeçalho Padronizado dos Arquivos

Todo arquivo `.asm` deve iniciar com o cabeçalho padronizado contendo a identificação completa dos alunos, disciplina, professor e descrição funcional do arquivo, **sem uso de e comercial (`&`)** e **sem régua numérica de colunas**:

```mips
#*******************************************************************************
# Autores: Lucas Xavier Pairé e Miguel Brondani
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: [Descrição concisa e clara da finalidade do arquivo]
# Assembler: MARS
#*******************************************************************************
```

---

## 4. Nomenclatura de Procedimentos, Rótulos e Variáveis

Todos os procedimentos, rótulos de controle (desvios/laços) e variáveis na seção `.data` devem ser escritos estritamente em **português**, adotando a convenção **`snake_case`**:

### 4.1 Mapeamento de Procedimentos
| Nome Legado | Novo Nome Padronizado (Português) | Arquivo |
| :--- | :--- | :--- |
| `saes_key_expansion` | `expande_chave` | `src/saes.asm` |
| `saes_encrypt_block` | `cifra_bloco` | `src/saes.asm` |
| `saes_decrypt_block` | `decifra_bloco` | `src/saes.asm` |
| `saes_nibble_sub` | `substitui_nibbles` | `src/saes.asm` |
| `saes_inv_nibble_sub` | `substitui_nibbles_inv` | `src/saes.asm` |
| `saes_shift_rows` | `desloca_linhas` | `src/saes.asm` |
| `saes_mix_columns` | `mistura_colunas` | `src/saes.asm` |
| `saes_inv_mix_columns` | `mistura_colunas_inv` | `src/saes.asm` |
| `saes_sub_rot_byte` | `rotaciona_substitui_byte` | `src/saes.asm` |
| `process_file` | `processa_arquivo` | `src/file_io.asm` |
| `trim_newline` | `remove_quebra_linha` | `src/utils.asm` |
| `derive_key_16bit` | `deriva_chave` | `src/utils.asm` |

### 4.2 Mapeamento de Variáveis e Tabelas (`.data`)
| Nome Legado | Novo Nome Padronizado | Arquivo |
| :--- | :--- | :--- |
| `sbox` | `tabela_sbox` | `src/saes_tables.asm` |
| `inv_sbox` | `tabela_inv_sbox` | `src/saes_tables.asm` |
| `gf16_mult2` | `tabela_mult2` | `src/saes_tables.asm` |
| `gf16_mult4` | `tabela_mult4` | `src/saes_tables.asm` |
| `gf16_mult9` | `tabela_mult9` | `src/saes_tables.asm` |
| `round_keys` | `subchaves` | `src/saes_tables.asm` |
| `io_buffer` | `buffer_io` | `src/file_io.asm` |
| `in_filename_buf` | `buffer_nome_entrada` | `src/main.asm` |
| `out_filename_buf` | `buffer_nome_saida` | `src/main.asm` |
| `key_buf` | `buffer_chave` | `src/main.asm` |
| `opt_buf` | `buffer_opcao` | `src/main.asm` |

### 4.3 Rótulos de Desvios e Laços
Rótulos internos devem descrever a ação em português:
- `laco_leitura`, `fim_leitura`, `ajusta_impar`
- `laco_processa_blocos`, `chama_decifra`, `grava_bloco`
- `laco_menu`, `opcao_cifrar`, `opcao_decifrar`, `opcao_sair`, `opcao_invalida`
- `laco_remove_fim`, `substitui_nulo`
- `laco_deriva_chave`, `indice_par`, `indice_impar`

---

## 5. Estrutura Interna dos Procedimentos

### 5.1 Regras de Documentação dos Procedimentos
1. **Sem código em C:** Não utilizar trechos de código C antes das funções.
2. **Mapa de Registradores:** Todo procedimento deve explicitar o papel dos registradores utilizados.
3. **Mapa da Pilha:** Procedimentos que alocam espaço em `$sp` para variáveis ou registradores salvos devem apresentar o mapa de endereçamento relativo a `$sp`.
4. **Divisão em Seções:** Uso explícito das seções `# prólogo`, `# corpo do procedimento` e `# epílogo`.

### 5.2 Notação de Comentários Linha a Linha
Os comentários ao lado das instruções devem adotar a notação padrão do professor com o operador de atribuição por seta (`<-`):
- `# $t0 <- endereço base da tabela_sbox`
- `# $s0 <- $s0 + 1`
- `# $v0 <- serviço 13: abre arquivo para leitura`
- `# se $t1 == 0 desvia para fim_laco`
- `# restaura $ra da pilha`
- `# retorna ao procedimento chamador`

### 5.3 Exemplo de Estrutura de Procedimento
```mips
###############################################################################
# Procedimento: cifra_bloco
# Descrição: Criptografa um bloco de 16 bits utilizando o algoritmo S-AES.
#
# *** Mapa de registradores ***
# +-------+-----------------------------------------------+
# | Reg   | Descrição                                     |
# +-------+-----------------------------------------------+
# | $a0   | bloco de texto claro (16 bits)                |
# | $a1   | endereço base do vetor de subchaves           |
# | $s0   | estado intermediário de 16 bits               |
# | $s1   | subchave K0                                   |
# | $s2   | subchave K1                                   |
# | $s3   | subchave K2                                   |
# | $v0   | bloco criptografado retornado (16 bits)       |
# +-------+-----------------------------------------------+
#
# *** Mapa da pilha ***
# +----------------------------------+
# | Registrador | Endereço na Pilha  |
# +----------------------------------+
# | $ra         | $sp + 20           |
# | $s0         | $sp + 16           |
# | $s1         | $sp + 12           |
# | $s2         | $sp + 8            |
# | $s3         | $sp + 4            |
# +----------------------------------+
###############################################################################
cifra_bloco:
# prólogo
            addi    $sp, $sp, -24       # aloca espaço na pilha para 5 registradores
            sw      $ra, 20($sp)        # salva endereço de retorno
            sw      $s0, 16($sp)        # salva $s0
            sw      $s1, 12($sp)        # salva $s1
            sw      $s2, 8($sp)         # salva $s2
            sw      $s3, 4($sp)         # salva $s3

# corpo do procedimento
            lhu     $s1, 0($a1)         # $s1 <- subchave K0
            lhu     $s2, 2($a1)         # $s2 <- subchave K1
            lhu     $s3, 4($a1)         # $s3 <- subchave K2

            xor     $s0, $a0, $s1       # $s0 <- estado inicial = bloco ^ K0

            # Rodada 1
            move    $a0, $s0            # $a0 <- estado atual
            jal     substitui_nibbles   # executa substituição dos nibbles via S-Box
            move    $a0, $v0            # $a0 <- resultado da substituição

            jal     desloca_linhas      # permuta nibbles da segunda linha
            move    $a0, $v0            # $a0 <- resultado da permutação

            jal     mistura_colunas     # multiplica colunas em GF(16)
            xor     $s0, $v0, $s2       # $s0 <- estado ^ K1

            # Rodada 2 (Final - sem mistura de colunas)
            move    $a0, $s0            # $a0 <- estado atual
            jal     substitui_nibbles   # substituição final
            move    $a0, $v0

            jal     desloca_linhas      # permutação final
            xor     $v0, $v0, $s3       # $v0 <- texto cifrado = estado ^ K2

# epílogo
            lw      $s3, 4($sp)         # restaura $s3
            lw      $s2, 8($sp)         # restaura $s2
            lw      $s1, 12($sp)        # restaura $s1
            lw      $s0, 16($sp)        # restaura $s0
            lw      $ra, 20($sp)        # restaura $ra
            addi    $sp, $sp, 24        # libera espaço da pilha
            jr      $ra                 # retorna ao procedimento chamador
```

---

## 6. Alinhamento de Instruções em Colunas

Seguindo o padrão visual dos exemplos do professor:
- **Coluna 1:** Rótulos de procedimentos e desvios.
- **Coluna 13 (12 espaços de recuo):** Mnemônicos das instruções (`addi`, `sw`, `lw`, `xor`, `jal`, etc.).
- **Coluna 21 (espaçamento após mnemônico):** Operandos da instrução.
- **Comentários:** Alinhados à direita, introduzidos por `#`.
