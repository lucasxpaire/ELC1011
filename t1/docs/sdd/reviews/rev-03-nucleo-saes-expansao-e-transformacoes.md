# Spec de Revisão 03: Núcleo S-AES - Expansão de Chaves e Transformações (saes.asm - Parte 1)

- **Arquivo Auditado:** `src/saes.asm` (linhas 1 a 320)
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 3.1: Procedimento Auxiliar `rotaciona_substitui_byte`

### Código Inspecionado
```mips
rotaciona_substitui_byte:
# corpo do procedimento
            srl     $t8, $a0, 4         # desloca 4 bits para a direita
            andi    $t8, $t8, 0x0F      # $t8 <- nibble mais significativo original
            andi    $t9, $a0, 0x0F      # $t9 <- nibble menos significativo original

            la      $v1, tabela_sbox    # $v1 <- endereço base da tabela_sbox

            # S-Box aplicada ao nibble inferior (torna-se o superior)
            addu    $v0, $v1, $t9       # $v0 <- endereço do elemento na S-Box
            lbu     $t9, 0($v0)         # $t9 <- S(n_baixo)

            # S-Box aplicada ao nibble superior (torna-se o inferior)
            addu    $v0, $v1, $t8       # $v0 <- endereço do elemento na S-Box
            lbu     $t8, 0($v0)         # $t8 <- S(n_alto)

            sll     $v0, $t9, 4         # posiciona o novo nibble alto
            or      $v0, $v0, $t8       # $v0 <- (S(n_baixo) << 4) | S(n_alto)
            jr      $ra                 # retorna ao procedimento chamador
```

### Critérios de Auditoria e Verificação
1. **Definição Funcional:** Executa $\text{SubNib}(\text{RotNib}(w))$, onde $w = [n_{alto}, n_{baixo}]$.
   - RotNib: inverte os nibbles $\implies [n_{baixo}, n_{alto}]$.
   - SubNib: substitui cada nibble via S-Box $\implies [S(n_{baixo}), S(n_{alto})]$.
2. **Conferência da Lógica:**
   - O código isola $n_{alto}$ em `$t8$` e $n_{baixo}$ em `$t9$`.
   - Consulta a S-box para ambos e remonta `(S(n_baixo) << 4) | S(n_alto)` em `$v0`.
3. **ABI e Registradores:** Procedimento folha. Utiliza apenas `$t8, $t9, $v1, $v0`. Nenhum registrador salvo é alterado. Retorna via `jr $ra`.

- **Veredito:** **[CONFORME]**

---

## Bloco 3.2: Procedimento `expande_chave`

### Código Inspecionado
```mips
expande_chave:
# prólogo
            addi    $sp, $sp, -24       # aloca espaço na pilha para 6 palavras
            sw      $ra, 20($sp)        # salva endereço de retorno
            sw      $s0, 16($sp)        # salva $s0
            sw      $s1, 12($sp)        # salva $s1
            sw      $s2, 8($sp)         # salva $s2
            sw      $s3, 4($sp)         # salva $s3
            sw      $s4, 0($sp)         # salva $s4

# corpo do procedimento
            bnez    $a1, exp_destino_ok # se $a1 != 0 usa o endereço fornecido
            la      $a1, subchaves      # caso contrário, carrega o endereço padrão
exp_destino_ok:
            move    $s0, $a0            # $s0 <- chave mestre K
            move    $s1, $a1            # $s1 <- ponteiro para subchaves

            # Extração de w0 e w1 a partir da chave mestre
            srl     $t0, $s0, 8
            andi    $t0, $t0, 0xFF      # $t0 <- w0 (bits 15..8 de K)
            andi    $t1, $s0, 0xFF      # $t1 <- w1 (bits 7..0 de K)

            sh      $s0, 0($s1)         # subchaves[0] <- K0

            # Cálculo de w2 e w3 (Subchave K1)
            move    $a0, $t1
            jal     rotaciona_substitui_byte
            move    $t2, $v0

            xor     $t3, $t0, 0x80      # $t3 <- w0 ^ RCON(1)
            xor     $t3, $t3, $t2       # $t3 <- w0 ^ RCON(1) ^ rot_sub(w1) = w2
            andi    $t3, $t3, 0xFF

            xor     $t4, $t3, $t1       # $t4 <- w2 ^ w1 = w3
            andi    $t4, $t4, 0xFF

            sll     $t5, $t3, 8
            or      $t5, $t5, $t4       # $t5 <- K1 = (w2 << 8) | w3
            sh      $t5, 2($s1)         # subchaves[1] <- K1

            # Cálculo de w4 e w5 (Subchave K2)
            move    $a0, $t4
            jal     rotaciona_substitui_byte
            move    $t6, $v0

            xor     $t7, $t3, 0x30      # $t7 <- w2 ^ RCON(2)
            xor     $t7, $t7, $t6       # $t7 <- w2 ^ RCON(2) ^ rot_sub(w3) = w4
            andi    $t7, $t7, 0xFF

            xor     $t8, $t7, $t4       # $t8 <- w4 ^ w3 = w5
            andi    $t8, $t8, 0xFF

            sll     $t9, $t7, 8
            or      $t9, $t9, $t8       # $t9 <- K2 = (w4 << 8) | w5
            sh      $t9, 4($s1)         # subchaves[2] <- K2

            move    $v0, $s0            # $v0 <- K0
            move    $v1, $t5            # $v1 <- K1

# epílogo
            lw      $s4, 0($sp)
            lw      $s3, 4($sp)
            lw      $s2, 8($sp)
            lw      $s1, 12($sp)
            lw      $s0, 16($sp)
            lw      $ra, 20($sp)
            addi    $sp, $sp, 24
            jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Correção Matemática da Expansão:**
   - $w_0 = K[15..8], w_1 = K[7..0]$
   - $K_0 = (w_0 \ll 8) \mid w_1 = K$
   - $w_2 = w_0 \oplus \text{RCON}(1) \oplus \text{SubNib}(\text{RotNib}(w_1))$ com $\text{RCON}(1) = 0x80$ (1000 0000 em binário).
   - $w_3 = w_2 \oplus w_1 \implies K_1 = (w_2 \ll 8) \mid w_3$.
   - $w_4 = w_2 \oplus \text{RCON}(2) \oplus \text{SubNib}(\text{RotNib}(w_3))$ com $\text{RCON}(2) = 0x30$ (0011 0000 em binário).
   - $w_5 = w_4 \oplus w_3 \implies K_2 = (w_4 \ll 8) \mid w_5$.
   - **Vetor Oficial de Validação:** Para $K = \text{0x4AF5}$:
     * $K_0 = \text{0x4AF5}$
     * $K_1 = \text{0xDD28}$
     * $K_2 = \text{0x87AF}$
     * Conferido com 100% de precisão nos testes.
2. **Gerenciamento de Pilha:**
   - Aloca 24 bytes (múltiplo de 4).
   - Salva e restaura `$ra, $s0, $s1, $s2, $s3, $s4` exatamente nas mesmas posições de memória.
   - `$sp` retoma rigorosamente o valor original antes do retorno.
3. **Escrita em Memória:**
   - `sh` em offsets 0, 2 e 4 do vetor de subchaves (alinhamento garantido por `.align 1`).

- **Veredito:** **[CONFORME]**

---

## Bloco 3.3: Procedimentos `substitui_nibbles` e `substitui_nibbles_inv`

### Código Inspecionado
```mips
substitui_nibbles:
# corpo do procedimento
            la      $t0, tabela_sbox    # $t0 <- endereço base da tabela_sbox

            # Nibble 0 (bits 15..12) - posição S00
            srl     $t1, $a0, 12
            andi    $t1, $t1, 0x0F
            addu    $t5, $t0, $t1
            lbu     $t1, 0($t5)

            # Nibble 1 (bits 11..8) - posição S10
            srl     $t2, $a0, 8
            andi    $t2, $t2, 0x0F
            addu    $t5, $t0, $t2
            lbu     $t2, 0($t5)

            # Nibble 2 (bits 7..4) - posição S01
            srl     $t3, $a0, 4
            andi    $t3, $t3, 0x0F
            addu    $t5, $t0, $t3
            lbu     $t3, 0($t5)

            # Nibble 3 (bits 3..0) - posição S11
            andi    $t4, $a0, 0x0F
            addu    $t5, $t0, $t4
            lbu     $t4, 0($t5)

            # Reconstrução da palavra de 16 bits
            sll     $v0, $t1, 12
            sll     $t6, $t2, 8
            or      $v0, $v0, $t6
            sll     $t6, $t3, 4
            or      $v0, $v0, $t6
            or      $v0, $v0, $t4
            jr      $ra
```
*(O procedimento `substitui_nibbles_inv` segue idêntica estrutura substituindo `tabela_sbox` por `tabela_inv_sbox`).*

### Critérios de Auditoria e Verificação
1. **Mapeamento de Matriz:**
   $$\begin{pmatrix} S_{00} & S_{01} \\ S_{10} & S_{11} \end{pmatrix} \equiv \text{Bits } [15..12, 7..4, 11..8, 3..0]$$
   - Extrai nibble 0 (bits 15..12), nibble 1 (bits 11..8), nibble 2 (bits 7..4), nibble 3 (bits 3..0).
   - Aplica a substituição em cada nibble de forma totalmente independente.
2. **Reconstrução dos 16 bits:** Posiciona os nibbles substituídos de volta nas posições originais `(t1 << 12) | (t2 << 8) | (t3 << 4) | t4`.
3. **Preservação de Registradores:** Procedimento folha, utiliza exclusivamente registradores temporários `$t0-$t6`. Sem impacto na pilha.

- **Veredito:** **[CONFORME]**

---

## Bloco 3.4: Procedimentos `desloca_linhas` e `desloca_linhas_inv`

### Código Inspecionado
```mips
desloca_linhas:
desloca_linhas_inv:
# corpo do procedimento
            srl     $t0, $a0, 12
            andi    $t0, $t0, 0x0F      # $t0 <- nibble 0 (permanece na posição S00)

            srl     $t1, $a0, 8
            andi    $t1, $t1, 0x0F      # $t1 <- nibble 1 (vai para a posição S11)

            srl     $t2, $a0, 4
            andi    $t2, $t2, 0x0F      # $t2 <- nibble 2 (permanece na posição S01)

            andi    $t3, $a0, 0x0F      # $t3 <- nibble 3 (vai para a posição S10)

            # Reconstrução: [n0, n3, n2, n1]
            sll     $v0, $t0, 12        # nibble 0 nos bits 15..12
            sll     $t4, $t3, 8         # nibble 3 nos bits 11..8
            or      $v0, $v0, $t4
            sll     $t4, $t2, 4         # nibble 2 nos bits 7..4
            or      $v0, $v0, $t4
            or      $v0, $v0, $t1       # nibble 1 nos bits 3..0
            jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Propriedade Matemática da Matriz $2 \times 2$:**
   - Linha 0 ($S_{00}, S_{01}$): deslocamento de 0 posições $\implies$ inalterada.
   - Linha 1 ($S_{10}, S_{11}$): deslocamento circular de 1 nibble $\implies$ troca $S_{10} \leftrightarrow S_{11}$.
   - Como trocar dois elementos é uma involução ($f(f(x)) = x$), a operação inversa `desloca_linhas_inv` é matematicamente idêntica à direta, justificando o compartilhamento do mesmo rótulo.
2. **Reconstrução:**
   - Posição 0 (bits 15..12) recebe nibble 0.
   - Posição 1 (bits 11..8) recebe nibble 3.
   - Posição 2 (bits 7..4) recebe nibble 2.
   - Posição 3 (bits 3..0) recebe nibble 1.
3. **Eficiência e ABI:** Procedimento folha, execução puramente combinacional em registradores sem acesso a memória.

- **Veredito:** **[CONFORME]**
