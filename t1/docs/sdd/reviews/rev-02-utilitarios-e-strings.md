# Spec de Revisão 02: Utilitários e Strings (utils.asm)

- **Arquivo Auditado:** `src/utils.asm`
- **Total de Linhas:** 116
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 2.1: Sanitização de Strings (`remove_quebra_linha`)

### Código Inspecionado
```mips
remove_quebra_linha:
# corpo do procedimento
            move    $t0, $a0            # $t0 <- ponteiro para o início da string
            li      $v0, 0              # $v0 <- contador de caracteres = 0

laco_varre_string:
            lbu     $t1, 0($t0)         # carrega byte da posição atual
            beqz    $t1, fim_varredura  # se encontrou '\0', encerra

            # Verifica caractere '\n' (código ASCII 10)
            li      $t2, 10             # $t2 <- 10 ('\n')
            beq     $t1, $t2, trunca_delimitador

            # Verifica caractere '\r' (código ASCII 13)
            li      $t2, 13             # $t2 <- 13 ('\r')
            beq     $t1, $t2, trunca_delimitador

            addi    $t0, $t0, 1         # avança para o próximo caractere
            addi    $v0, $v0, 1         # incrementa o comprimento útil
            j       laco_varre_string   # repete o laço

trunca_delimitador:
            sb      $zero, 0($t0)       # substitui o delimitador por '\0'

fim_varredura:
            jr      $ra                 # retorna ao procedimento chamador
```

### Critérios de Auditoria e Verificação
1. **Natureza do Procedimento:** Procedimento folha (*leaf procedure*). Não invoca nenhum outro procedimento via `jal`.
2. **Convenção de Registradores (ABI):**
   - Utiliza exclusivamente `$t0`, `$t1`, `$t2` (temporários caller-saved) e `$v0` (retorno).
   - Não modifica nenhum registrador callee-saved (`$s0-$s7`).
   - Não altera `$sp` nem necessita salvar `$ra`.
3. **Robustez a Delimitadores de Linha:**
   - O serviço 8 do MARS insere `\n` (10) no final das strings digitadas.
   - Ambientes Windows adicionam sequências `\r\n` (13 e 10).
   - O procedimento verifica ambos os caracteres (10 e 13) e substitui o primeiro encontrado por `\0`, sanitizando com sucesso caminhos de arquivos tanto em Linux quanto em Windows.
4. **Casos de Borda:**
   - *String Vazia (`""`):* `lbu` lê imediatamente `\0`, desviando para `fim_varredura` com retorno `$v0 = 0`. Seguro.
   - *String sem delimitador:* Percorre até o terminador nulo existente e retorna o comprimento correto.

- **Veredito:** **[CONFORME]**

---

## Bloco 2.2: Derivação de Chave de 16 bits (`deriva_chave`)

### Código Inspecionado
```mips
deriva_chave:
# corpo do procedimento
            move    $t0, $a0            # $t0 <- endereço inicial da senha
            li      $t1, 0              # $t1 <- acumulador par = 0
            li      $t2, 0              # $t2 <- acumulador ímpar = 0
            li      $t3, 0              # $t3 <- índice inicial = 0

laco_deriva_chave:
            lbu     $t4, 0($t0)         # lê caractere da memória
            beqz    $t4, fim_derivacao  # se atingiu '\0', encerra

            # Testa se o índice é par ou ímpar (isolando o bit menos significativo)
            andi    $t5, $t3, 1         # $t5 <- bit 0 do índice
            beqz    $t5, acumula_par    # se for zero, o índice é par

            # Índice ímpar: acumula em $t2
            xor     $t2, $t2, $t4       # $t2 <- $t2 ^ caractere
            j       avanca_indice

acumula_par:
            # Índice par: acumula em $t1
            xor     $t1, $t1, $t4       # $t1 <- $t1 ^ caractere

avanca_indice:
            addi    $t0, $t0, 1         # avança ponteiro da string
            addi    $t3, $t3, 1         # incrementa índice
            j       laco_deriva_chave   # repete o laço

fim_derivacao:
            # Garante que cada acumulador contenha exatamente 8 bits
            andi    $t1, $t1, 0xFF      # isola byte alto
            andi    $t2, $t2, 0xFF      # isola byte baixo

            # Concatena em uma palavra de 16 bits: (t1 << 8) | t2
            sll     $v0, $t1, 8         # $v0 <- byte alto posicionado nos bits 15..8
            or      $v0, $v0, $t2       # $v0 <- concatena byte baixo nos bits 7..0
            jr      $ra                 # retorna ao procedimento chamador
```

### Critérios de Auditoria e Verificação
1. **Definição Algorítmica (Q01-derivacao-chave):**
   - O S-AES requer exatamente 16 bits de chave, mas a senha solicitada (`"ELC1011"`) possui 7 bytes.
   - Aplica a técnica de *folding* por XOR:
     * Byte alto: caracteres de índices $0, 2, 4 \dots$
     * Byte baixo: caracteres de índices $1, 3, 5 \dots$
2. **Validação com a Chave Oficial `"ELC1011"`:**
   - Índices pares (0, 2, 4, 6): `'E'` (0x45), `'C'` (0x43), `'0'` (0x30), `'1'` (0x31)
     $$\text{Byte Alto} = 0x45 \oplus 0x43 \oplus 0x30 \oplus 0x31 = 0x06 \oplus 0x01 = 0x07$$
   - Índices ímpares (1, 3, 5): `'L'` (0x4C), `'1'` (0x31), `'1'` (0x31)
     $$\text{Byte Baixo} = 0x4C \oplus 0x31 \oplus 0x31 = 0x4C$$
   - Chave gerada: `0x074C` (determinística, reversível e independente do tamanho da senha).
3. **Convenção de Registradores (ABI):**
   - Procedimento folha. Utiliza apenas `$t0-$t5` e `$v0`.
   - Preserva todos os registradores `$s` e a integridade de `$ra`.
4. **Casos de Borda:**
   - Senha de 1 caractere: byte alto recebe o caractere, byte baixo recebe 0x00.
   - Senha vazia: retorna `0x0000`.

- **Veredito:** **[CONFORME]**
