# Spec-03: Núcleo Criptográfico S-AES (Simplified AES)

## 1. Visão Geral
Esta especificação descreve a implementação completa do motor de criptografia e descriptografia **S-AES** de 16 bits para MIPS no arquivo [src/saes.asm](../../src/saes.asm).

---

## 2. Representação do Estado (State Matrix)

Um bloco de 16 bits $S = [b_{15} \dots b_0]$ é decomposto em 4 nibbles de 4 bits organizados em uma matriz $2 \times 2$ no formato *column-major*:

$$\begin{bmatrix} S_{0,0} & S_{0,1} \\ S_{1,0} & S_{1,1} \end{bmatrix}$$

- $S_{0,0} = S[15:12]$ (Nibble mais significativo da coluna 0)
- $S_{1,0} = S[11:8]$  (Nibble menos significativo da coluna 0)
- $S_{0,1} = S[7:4]$   (Nibble mais significativo da coluna 1)
- $S_{1,1} = S[3:0]$   (Nibble menos significativo da coluna 1)

---

## 3. Rotinas e Contratos de Interface (MIPS)

### 3.1 Expansão de Chaves (`saes_key_expansion`)
- **Objetivo:** A partir da chave mestre de 16 bits ($K$), computar as três subchaves de rodada: $Key_0, Key_1, Key_2$ (16 bits cada).
- **Entrada:**
  - `$a0`: Chave inicial de 16 bits ($K = w_0 w_1$)
- **Saída:**
  - `$v0`: Subchave $Key_0$ ($w_0 w_1$)
  - `$v1`: Subchave $Key_1$ ($w_2 w_3$)
  - Registrador temporário / memória: Subchave $Key_2$ ($w_4 w_5$).
  *(Para permitir acesso rápido, `saes_key_expansion` armazena as 3 subchaves em um pequeno buffer na memória `.data` `round_keys: .half 0, 0, 0` ou as retorna diretamente).*
- **Algoritmo:**
  1. $w_0 = K[15:8]$, $w_1 = K[7:0]$
  2. $w_2 = w_0 \oplus 0x80 \oplus \text{SubNib}(\text{RotNib}(w_1))$
     - $\text{RotNib}(w_1)$: troca nibble alto e baixo de $w_1$: $((w_1 \ll 4) \ \&\ 0xF0) \mid ((w_1 \gg 4) \ \&\ 0x0F)$.
     - $\text{SubNib}$: passa cada nibble pela tabela `sbox`.
  3. $w_3 = w_2 \oplus w_1$
  4. $w_4 = w_2 \oplus 0x30 \oplus \text{SubNib}(\text{RotNib}(w_3))$
  5. $w_5 = w_4 \oplus w_3$
  6. $Key_0 = (w_0 \ll 8) \mid w_1$
  7. $Key_1 = (w_2 \ll 8) \mid w_3$
  8. $Key_2 = (w_4 \ll 8) \mid w_5$

---

### 3.2 Cifra de Bloco (`saes_encrypt_block`)
- **Entrada:**
  - `$a0`: Bloco de texto claro (16 bits)
  - `$a1`: Endereço base do array de chaves de rodada (`round_keys`)
- **Saída:**
  - `$v0`: Bloco de texto cifrado (16 bits)
- **Passos da Execução:**
  1. **AddRoundKey(Key0):** $\text{State} = \text{Bloco} \oplus Key_0$.
  2. **Rodada 1:**
     - `NibbleSub`: substitui os 4 nibbles via `sbox`.
     - `ShiftRows`: troca nibble 1 ($S_{1,0}$) com nibble 3 ($S_{1,1}$).
     - `MixColumns`:
       - $S'_{0,0} = S_{0,0} \oplus \text{gf16\_mult4}[S_{1,0}]$
       - $S'_{1,0} = \text{gf16\_mult4}[S_{0,0}] \oplus S_{1,0}$
       - $S'_{0,1} = S_{0,1} \oplus \text{gf16\_mult4}[S_{1,1}]$
       - $S'_{1,1} = \text{gf16\_mult4}[S_{0,1}] \oplus S_{1,1}$
     - `AddRoundKey(Key1)`: $\text{State} = \text{State} \oplus Key_1$.
  3. **Rodada 2 (Final):**
     - `NibbleSub`: substitui os 4 nibbles via `sbox`.
     - `ShiftRows`: troca nibble 1 com nibble 3.
     - `AddRoundKey(Key2)`: $\text{State} = \text{State} \oplus Key_2$.
  4. Retorna `$v0 = \text{State}`.

---

### 3.3 Decifra de Bloco (`saes_decrypt_block`)
- **Entrada:**
  - `$a0`: Bloco cifrado (16 bits)
  - `$a1`: Endereço base do array de chaves de rodada (`round_keys`)
- **Saída:**
  - `$v0`: Bloco original restaurado (16 bits)
- **Passos da Execução (Inversão Exata):**
  1. **AddRoundKey(Key2):** $\text{State} = \text{Bloco Cifrado} \oplus Key_2$.
  2. **Rodada 1 Inversa:**
     - `InvShiftRows`: troca nibble 1 com nibble 3 (idêntico ao ShiftRows para matriz $2 \times 2$).
     - `InvNibbleSub`: substitui os 4 nibbles via `inv_sbox`.
     - `AddRoundKey(Key1)`: $\text{State} = \text{State} \oplus Key_1$.
     - `InvMixColumns`:
       - $S''_{0,0} = \text{gf16\_mult9}[S'_{0,0}] \oplus \text{gf16\_mult2}[S'_{1,0}]$
       - $S''_{1,0} = \text{gf16\_mult2}[S'_{0,0}] \oplus \text{gf16\_mult9}[S'_{1,0}]$
       - $S''_{0,1} = \text{gf16\_mult9}[S'_{0,1}] \oplus \text{gf16\_mult2}[S'_{1,1}]$
       - $S''_{1,1} = \text{gf16\_mult2}[S'_{0,1}] \oplus \text{gf16\_mult9}[S'_{1,1}]$
  3. **Rodada 2 Inversa:**
     - `InvShiftRows`: troca nibble 1 com nibble 3.
     - `InvNibbleSub`: substitui os 4 nibbles via `inv_sbox`.
     - `AddRoundKey(Key0)`: $\text{State} = \text{State} \oplus Key_0$.
  4. Retorna `$v0 = \text{State}`.

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

Este vetor servirá como suíte de verificação automatizada em `tests/test_saes_vectors.asm`.
