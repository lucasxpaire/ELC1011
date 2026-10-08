# Spec-03: Núcleo Criptográfico S-AES (Simplified AES)

## 1. Visão Geral
Esta especificação descreve a implementação completa do motor de criptografia e descriptografia **S-AES** de 16 bits para MIPS no arquivo [src/saes.asm](../../src/saes.asm), em conformidade com as diretrizes da [Spec-07](spec-07-padroes-de-codificacao-e-estilo.md).

---

## 2. Representação do Estado (Matriz de Estado)

Um bloco de 16 bits $S = [b_{15} \dots b_0]$ é decomposto em 4 nibbles de 4 bits organizados em uma matriz $2 \times 2$ no formato *column-major*:

$$\begin{bmatrix} S_{0,0} & S_{0,1} \\ S_{1,0} & S_{1,1} \end{bmatrix}$$

- $S_{0,0} = S[15:12]$ (Nibble mais significativo da coluna 0)
- $S_{1,0} = S[11:8]$  (Nibble menos significativo da coluna 0)
- $S_{0,1} = S[7:4]$   (Nibble mais significativo da coluna 1)
- $S_{1,1} = S[3:0]$   (Nibble menos significativo da coluna 1)

---

## 3. Rotinas e Contratos de Interface (MIPS)

### 3.1 Expansão de Chaves (`expande_chave`)
- **Objetivo:** A partir da chave mestre de 16 bits ($K$), computar as três subchaves de rodada: $Key_0, Key_1, Key_2$ (16 bits cada) e armazená-las no vetor `subchaves`.
- **Entrada:**
  - `$a0`: Chave inicial de 16 bits ($K = w_0 w_1$)
  - `$a1`: Endereço de destino das subchaves (`subchaves`)
- **Saída:**
  - `subchaves[0]`: $Key_0$ ($w_0 w_1$)
  - `subchaves[1]`: $Key_1$ ($w_2 w_3$)
  - `subchaves[2]`: $Key_2$ ($w_4 w_5$)
- **Algoritmo:**
  1. $w_0 = K[15:8]$, $w_1 = K[7:0]$
  2. $w_2 = w_0 \oplus 0x80 \oplus \text{SubNib}(\text{RotNib}(w_1))$
     - $\text{RotNib}(w_1)$: troca nibble alto e baixo de $w_1$: $((w_1 \ll 4) \ \&\ 0xF0) \mid ((w_1 \gg 4) \ \&\ 0x0F)$.
     - $\text{SubNib}$: passa cada nibble pela `tabela_sbox` (procedimento `rotaciona_substitui_byte`).
  3. $w_3 = w_2 \oplus w_1$
  4. $w_4 = w_2 \oplus 0x30 \oplus \text{SubNib}(\text{RotNib}(w_3))$
  5. $w_5 = w_4 \oplus w_3$
  6. $Key_0 = (w_0 \ll 8) \mid w_1$
  7. $Key_1 = (w_2 \ll 8) \mid w_3$
  8. $Key_2 = (w_4 \ll 8) \mid w_5$

---

### 3.2 Cifra de Bloco (`cifra_bloco`)
- **Entrada:**
  - `$a0`: Bloco de texto claro (16 bits)
  - `$a1`: Endereço base do array de chaves de rodada (`subchaves`)
- **Saída:**
  - `$v0`: Bloco de texto cifrado (16 bits)
- **Passos da Execução:**
  1. **AddRoundKey(Key0):** $\text{Estado} = \text{Bloco} \oplus Key_0$.
  2. **Rodada 1:**
     - `substitui_nibbles`: substitui os 4 nibbles via `tabela_sbox`.
     - `desloca_linhas`: troca nibble 1 ($S_{1,0}$) com nibble 3 ($S_{1,1}$).
     - `mistura_colunas`:
       - $S'_{0,0} = S_{0,0} \oplus \text{tabela\_mult4}[S_{1,0}]$
       - $S'_{1,0} = \text{tabela\_mult4}[S_{0,0}] \oplus S_{1,0}$
       - $S'_{0,1} = S_{0,1} \oplus \text{tabela\_mult4}[S_{1,1}]$
       - $S'_{1,1} = \text{tabela\_mult4}[S_{0,1}] \oplus S_{1,1}$
     - `AddRoundKey(Key1)`: $\text{Estado} = \text{Estado} \oplus Key_1$.
  3. **Rodada 2 (Final):**
     - `substitui_nibbles`: substitui os 4 nibbles via `tabela_sbox`.
     - `desloca_linhas`: troca nibble 1 com nibble 3.
     - `AddRoundKey(Key2)`: $\text{Estado} = \text{Estado} \oplus Key_2$.
  4. Retorna `$v0 = \text{Estado}`.

---

### 3.3 Decifra de Bloco (`decifra_bloco`)
- **Entrada:**
  - `$a0`: Bloco cifrado (16 bits)
  - `$a1`: Endereço base do array de chaves de rodada (`subchaves`)
- **Saída:**
  - `$v0`: Bloco original restaurado (16 bits)
- **Passos da Execução (Inversão Exata):**
  1. **AddRoundKey(Key2):** $\text{Estado} = \text{Bloco Cifrado} \oplus Key_2$.
  2. **Rodada 1 Inversa:**
     - `desloca_linhas`: troca nibble 1 com nibble 3 (idêntico a InvShiftRows para matriz $2 \times 2$).
     - `substitui_nibbles_inv`: substitui os 4 nibbles via `tabela_inv_sbox`.
     - `AddRoundKey(Key1)`: $\text{Estado} = \text{Estado} \oplus Key_1$.
     - `mistura_colunas_inv`:
       - $S''_{0,0} = \text{tabela\_mult9}[S'_{0,0}] \oplus \text{tabela\_mult2}[S'_{1,0}]$
       - $S''_{1,0} = \text{tabela\_mult2}[S'_{0,0}] \oplus \text{tabela\_mult9}[S'_{1,0}]$
       - $S''_{0,1} = \text{tabela\_mult9}[S'_{0,1}] \oplus \text{tabela\_mult2}[S'_{1,1}]$
       - $S''_{1,1} = \text{tabela\_mult2}[S'_{0,1}] \oplus \text{tabela\_mult9}[S'_{1,1}]$
  3. **Rodada 2 Inversa:**
     - `desloca_linhas`: troca nibble 1 com nibble 3.
     - `substitui_nibbles_inv`: substitui os 4 nibbles via `tabela_inv_sbox`.
     - `AddRoundKey(Key0)`: $\text{Estado} = \text{Estado} \oplus Key_0$.
  4. Retorna `$v0 = \text{Estado}`.

---

## 4. Vetor de Teste Oficial (Referência de Certificação)

Extraído diretamente do documento [docs/simplified-aes-example.pdf](../simplified-aes-example.pdf):

| Etapa | Valor Binário | Valor Hex |
| :--- | :--- | :--- |
| **Texto Claro ($P$)** | `1101 0111 0010 1000` | `0xD728` |
| **Chave Mestre ($K$)** | `0100 1010 1111 0101` | `0x4AF5` |
| **$Key_0$** | `0100 1010 1111 0101` | `0x4AF5` |
| **$Key_1$** | `1101 1101 0010 1000` | `0xDD28` |
| **$Key_2$** | `1000 0111 1010 1111` | `0x87AF` |
| **Saída Cifrada ($C$)** | `0010 0100 1110 1100` | `0x24EC` |
| **Saída Decifrada ($P'$)** | `1101 0111 0010 1000` | `0xD728` |

Este vetor é testado de forma automatizada no módulo `tests/test_saes_vectors.asm`.
