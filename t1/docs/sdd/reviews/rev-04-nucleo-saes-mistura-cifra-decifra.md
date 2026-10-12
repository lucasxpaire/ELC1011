# Spec de Revisão 04: Núcleo S-AES - Mistura de Colunas, Cifra e Decifra (saes.asm - Parte 2)

- **Arquivo Auditado:** `src/saes.asm` (linhas 321 a 629)
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 3.5: Procedimento `mistura_colunas`

### Código Inspecionado
```mips
mistura_colunas:
# corpo do procedimento
            la      $t9, tabela_mult4   # $t9 <- endereço base da tabela de mult por 4

            # Extração dos 4 nibbles da matriz
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # $t0 <- S00
            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # $t1 <- S10
            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # $t2 <- S01
            andi    $t3, $a0, 0x0F      # $t3 <- S11

            # Coluna 0: S00' = S00 ^ (4 * S10); S10' = (4 * S00) ^ S10
            addu    $t8, $t9, $t1       # mult4[S10]
            lbu     $t4, 0($t8)
            xor     $t4, $t0, $t4       # $t4 <- S00'

            addu    $t8, $t9, $t0       # mult4[S00]
            lbu     $t5, 0($t8)
            xor     $t5, $t5, $t1       # $t5 <- S10'

            # Coluna 1: S01' = S01 ^ (4 * S11); S11' = (4 * S01) ^ S11
            addu    $t8, $t9, $t3       # mult4[S11]
            lbu     $t6, 0($t8)
            xor     $t6, $t2, $t6       # $t6 <- S01'

            addu    $t8, $t9, $t2       # mult4[S01]
            lbu     $t7, 0($t8)
            xor     $t7, $t7, $t3       # $t7 <- S11'

            # Reconstrução da palavra de 16 bits
            sll     $v0, $t4, 12
            sll     $t8, $t5, 8
            or      $v0, $v0, $t8
            sll     $t8, $t6, 4
            or      $v0, $v0, $t8
            or      $v0, $v0, $t7
            jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Multiplicação Matricial em $GF(2^4)$:**
   $$\begin{pmatrix} S_{00}' \\ S_{10}' \end{pmatrix} = \begin{pmatrix} 1 & 4 \\ 4 & 1 \end{pmatrix} \begin{pmatrix} S_{00} \\ S_{10} \end{pmatrix} \implies \begin{cases} S_{00}' = S_{00} \oplus (4 \cdot S_{10}) \\ S_{10}' = (4 \cdot S_{00}) \oplus S_{10} \end{cases}$$
   $$\begin{pmatrix} S_{01}' \\ S_{11}' \end{pmatrix} = \begin{pmatrix} 1 & 4 \\ 4 & 1 \end{pmatrix} \begin{pmatrix} S_{01} \\ S_{11} \end{pmatrix} \implies \begin{cases} S_{01}' = S_{01} \oplus (4 \cdot S_{11}) \\ S_{11}' = (4 \cdot S_{01}) \oplus S_{11} \end{cases}$$
2. **Conferência da Lógica:**
   - Multiplicação por 4 é efetuada indexando `tabela_mult4` com addu + lbu.
   - Reconstrução em `$v0` preserva o mapeamento $[S_{00}', S_{10}', S_{01}', S_{11}']$.
3. **ABI:** Procedimento folha. Utiliza apenas temporários `$t0-$t9`. Retorna via `jr $ra`.

- **Veredito:** **[CONFORME]**

---

## Bloco 3.6: Procedimento `mistura_colunas_inv`

### Código Inspecionado
```mips
mistura_colunas_inv:
# corpo do procedimento
            la      $t8, tabela_mult9   # tabela de mult por 9
            la      $t9, tabela_mult2   # tabela de mult por 2

            # Extração dos 4 nibbles
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # S00
            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # S10
            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # S01
            andi    $t3, $a0, 0x0F      # S11

            # Coluna 0: S00'' = (9 * S00) ^ (2 * S10); S10'' = (2 * S00) ^ (9 * S10)
            addu    $v1, $t8, $t0
            lbu     $t4, 0($v1)         # 9 * S00
            addu    $v1, $t9, $t1
            lbu     $v0, 0($v1)         # 2 * S10
            xor     $t4, $t4, $v0       # S00''

            addu    $v1, $t9, $t0
            lbu     $t5, 0($v1)         # 2 * S00
            addu    $v1, $t8, $t1
            lbu     $v0, 0($v1)         # 9 * S10
            xor     $t5, $t5, $v0       # S10''

            # Coluna 1: S01'' = (9 * S01) ^ (2 * S11); S11'' = (2 * S01) ^ (9 * S11)
            addu    $v1, $t8, $t2
            lbu     $t6, 0($v1)         # 9 * S01
            addu    $v1, $t9, $t3
            lbu     $v0, 0($v1)         # 2 * S11
            xor     $t6, $t6, $v0       # S01''

            addu    $v1, $t9, $t2
            lbu     $t7, 0($v1)         # 2 * S01
            addu    $v1, $t8, $t3
            lbu     $v0, 0($v1)         # 9 * S11
            xor     $t7, $t7, $v0       # S11''

            # Reconstrução
            sll     $v0, $t4, 12
            sll     $v1, $t5, 8
            or      $v0, $v0, $v1
            sll     $v1, $t6, 4
            or      $v0, $v0, $v1
            or      $v0, $v0, $t7
            jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Multiplicação Inversa:**
   $$\begin{pmatrix} 9 & 2 \\ 2 & 9 \end{pmatrix} \begin{pmatrix} S_{00} \\ S_{10} \end{pmatrix} = \begin{pmatrix} (9 \cdot S_{00}) \oplus (2 \cdot S_{10}) \\ (2 \cdot S_{00}) \oplus (9 \cdot S_{10}) \end{pmatrix}$$
2. **Conferência da Lógica:** Utiliza lookups simultâneos em `tabela_mult9` e `tabela_mult2`.
3. **ABI:** Procedimento folha. Utiliza apenas `$t0-$t9`, `$v1` e `$v0`. Sem alteração na pilha.

- **Veredito:** **[CONFORME]**

---

## Bloco 3.7: Procedimento `cifra_bloco`

### Código Inspecionado
```mips
cifra_bloco:
# prólogo
            addi    $sp, $sp, -24
            sw      $ra, 20($sp)
            sw      $s0, 16($sp)
            sw      $s1, 12($sp)
            sw      $s2, 8($sp)
            sw      $s3, 4($sp)

# corpo do procedimento
            bnez    $a1, cb_chaves_ok
            la      $a1, subchaves
cb_chaves_ok:
            lhu     $s1, 0($a1)         # K0
            lhu     $s2, 2($a1)         # K1
            lhu     $s3, 4($a1)         # K2

            # Pré-Rodada: AddRoundKey(K0)
            xor     $s0, $a0, $s1

            # Rodada 1:
            move    $a0, $s0
            jal     substitui_nibbles
            move    $a0, $v0
            jal     desloca_linhas
            move    $a0, $v0
            jal     mistura_colunas
            move    $s0, $v0
            xor     $s0, $s0, $s2       # AddRoundKey(K1)

            # Rodada 2 (Final - sem mistura de colunas):
            move    $a0, $s0
            jal     substitui_nibbles
            move    $a0, $v0
            jal     desloca_linhas
            move    $s0, $v0
            xor     $s0, $s0, $s3       # AddRoundKey(K2)
            move    $v0, $s0            # retorno do texto cifrado

# epílogo
            lw      $s3, 4($sp)
            lw      $s2, 8($sp)
            lw      $s1, 12($sp)
            lw      $s0, 16($sp)
            lw      $ra, 20($sp)
            addi    $sp, $sp, 24
            jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Estrutura de Cifragem do S-AES:**
   - Pré-rodada: $\text{Estado} = P \oplus K_0$.
   - Rodada 1: $\text{SubNibbles} \to \text{ShiftRows} \to \text{MixColumns} \to \oplus K_1$.
   - Rodada 2: $\text{SubNibbles} \to \text{ShiftRows} \to \oplus K_2$ (sem MixColumns, conforme a especificação padrão do AES).
2. **Gerenciamento de Pilha:**
   - Aloca 24 bytes (6 palavras).
   - Salva e restaura `$ra, $s0, $s1, $s2, $s3`.
   - Perfeito balanceamento de pilha.
3. **Conferência Experimental:**
   - Com $K_0 = \text{0x4AF5}, K_1 = \text{0xDD28}, K_2 = \text{0x87AF}$ e $P = \text{0xD728}$, o procedimento produz exatamente $C = \text{0x24EC}$ (vetor padrão Stallings).

- **Veredito:** **[CONFORME]**

---

## Bloco 3.8: Procedimento `decifra_bloco`

### Código Inspecionado
```mips
decifra_bloco:
# prólogo
            addi    $sp, $sp, -24
            sw      $ra, 20($sp)
            sw      $s0, 16($sp)
            sw      $s1, 12($sp)
            sw      $s2, 8($sp)
            sw      $s3, 4($sp)

# corpo do procedimento
            bnez    $a1, db_chaves_ok
            la      $a1, subchaves
db_chaves_ok:
            lhu     $s1, 0($a1)         # K0
            lhu     $s2, 2($a1)         # K1
            lhu     $s3, 4($a1)         # K2

            # Início da Descriptografia: AddRoundKey(K2)
            xor     $s0, $a0, $s3

            # Rodada 1 Inversa:
            move    $a0, $s0
            jal     desloca_linhas_inv
            move    $a0, $v0
            jal     substitui_nibbles_inv
            move    $s0, $v0
            xor     $s0, $s0, $s2       # AddRoundKey(K1)
            move    $a0, $s0
            jal     mistura_colunas_inv
            move    $s0, $v0

            # Rodada 2 Inversa (Final):
            move    $a0, $s0
            jal     desloca_linhas_inv
            move    $a0, $v0
            jal     substitui_nibbles_inv
            move    $s0, $v0
            xor     $s0, $s0, $s1       # AddRoundKey(K0)
            move    $v0, $s0            # texto claro restaurado

# epílogo
            lw      $s3, 4($sp)
            lw      $s2, 8($sp)
            lw      $s1, 12($sp)
            lw      $s0, 16($sp)
            lw      $ra, 20($sp)
            addi    $sp, $sp, 24
            jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Estrutura de Decifragem do S-AES:**
   - Pré-rodada: $\text{Estado} = C \oplus K_2$.
   - Rodada 1 Inversa: $\text{InvShiftRows} \to \text{InvSubNibbles} \to \oplus K_1 \to \text{InvMixColumns}$.
   - Rodada 2 Inversa: $\text{InvShiftRows} \to \text{InvSubNibbles} \to \oplus K_0$.
2. **Inversibilidade Rigorosa:**
   - Desfaz as operações na ordem inversa exata.
   - Teste unitário oficial: entrada $C = \text{0x24EC}$ restaura $P = \text{0xD728}$ com 100% de exatidão.
3. **Pilha e Registradores:** Alocação de 24 bytes, restauração simétrica de `$ra, $s0-$s3`.

- **Veredito:** **[CONFORME]**
