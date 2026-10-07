# Spec-02: Tabelas e Constantes Criptográficas do S-AES

## 1. Visão Geral
Esta especificação descreve as tabelas estáticas de substituição e multiplicação no corpo finito $GF(2^4)$ necessárias para o algoritmo **S-AES (Simplified AES)**. Todas as tabelas serão armazenadas na seção `.data` do módulo [src/saes_tables.asm](../../src/saes_tables.asm).

---

## 2. Tabela de Substituição (S-Box)
A S-Box do S-AES mapeia um nibble de entrada de 4 bits ($0x0$ a $0xF$) para um nibble de saída de 4 bits.

### 2.1 Mapeamento Hexadecimal
| Entrada (Hex) | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
| :--- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Saída (Hex)** | **9** | **4** | **A** | **B** | **D** | **1** | **8** | **5** | **6** | **2** | **0** | **3** | **C** | **E** | **F** | **7** |

### 2.2 Declaração em MIPS Assembly
```mips
.data
.align 0
sbox:
    .byte 0x09, 0x04, 0x0A, 0x0B, 0x0D, 0x01, 0x08, 0x05
    .byte 0x06, 0x02, 0x00, 0x03, 0x0C, 0x0E, 0x0F, 0x07
```

---

## 3. Tabela Inversa de Substituição (InvS-Box)
Utilizada na fase de descriptografia para desfazer o mapeamento da S-Box.

### 3.1 Mapeamento Hexadecimal
| Entrada (Hex) | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
| :--- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Saída (Hex)** | **A** | **5** | **9** | **B** | **1** | **7** | **8** | **F** | **6** | **0** | **2** | **3** | **C** | **4** | **D** | **E** |

### 3.2 Declaração em MIPS Assembly
```mips
.data
.align 0
inv_sbox:
    .byte 0x0A, 0x05, 0x09, 0x0B, 0x01, 0x07, 0x08, 0x0F
    .byte 0x06, 0x00, 0x02, 0x03, 0x0C, 0x04, 0x0D, 0x0E
```

---

## 4. Constantes de Rodada (Round Constants - RCON)
Utilizadas na rotina de expansão de chaves (`Key Expansion`):
- $\text{RCON}(1) = 0x80$ (`1000 0000_2`)
- $\text{RCON}(2) = 0x30$ (`0011 0000_2`)

---

## 5. Aritmética no Corpo Finito $GF(2^4)$
As matrizes de difusão do S-AES são:
- **MixColumns:**
  $$M_e = \begin{bmatrix} 1 & 4 \\ 4 & 1 \end{bmatrix}$$
- **InvMixColumns:**
  $$M_d = \begin{bmatrix} 9 & 2 \\ 2 & 9 \end{bmatrix}$$

As operações ocorrem em $GF(2^4)$ sob o polinômio irredutível $P(x) = x^4 + x + 1$ (`10011_2` = $0x13$).
- A **adição** em $GF(2^4)$ é a operação bitwise `XOR`.
- A **multiplicação** por constantes (2, 4 e 9) é pré-computada em tabelas de 16 bytes para eliminar rotinas de divisão polinomial em tempo de execução, garantindo desempenho e corretude absoluta.

### 5.1 Tabela de Multiplicação por 2 ($GF(2^4)$)
Corresponde a multiplicar por $x$ com redução por $x^4 + x + 1$:
```mips
.data
.align 0
gf16_mult2:
    .byte 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E
    .byte 0x03, 0x01, 0x07, 0x05, 0x0B, 0x09, 0x0F, 0x0D
```

### 5.2 Tabela de Multiplicação por 4 ($GF(2^4)$)
Corresponde a aplicar a multiplicação por 2 duas vezes:
```mips
.data
.align 0
gf16_mult4:
    .byte 0x00, 0x04, 0x08, 0x0C, 0x03, 0x07, 0x0B, 0x0F
    .byte 0x06, 0x02, 0x0E, 0x0A, 0x05, 0x01, 0x0D, 0x09
```

### 5.3 Tabela de Multiplicação por 9 ($GF(2^4)$)
Corresponde a $(x \cdot 8) \oplus x$:
```mips
.data
.align 0
gf16_mult9:
    .byte 0x00, 0x09, 0x01, 0x08, 0x02, 0x0B, 0x03, 0x0A
    .byte 0x04, 0x0D, 0x05, 0x0C, 0x06, 0x0F, 0x07, 0x0E
```

---

## 6. Validação Cruzada com o Documento de Referência
Os valores acima foram verificados diretamente contra os cálculos intermediários de [docs/simplified-aes-example.pdf](../simplified-aes-example.pdf):
- $4 \times E (14) = 0xD$ $\rightarrow$ `gf16_mult4[14] = 0x0D` *(Página 3)*
- $9 \times F (15) = 0xE$ $\rightarrow$ `gf16_mult9[15] = 0x0E` *(Página 4)*
- $9 \times 6 = 0x3$ $\rightarrow$ `gf16_mult9[6] = 0x03` *(Página 4)*
- $9 \times 3 = 0x8$ $\rightarrow$ `gf16_mult9[3] = 0x08` *(Página 4)*
- $2 \times 6 = 0xC$ $\rightarrow$ `gf16_mult2[6] = 0x0C` *(Página 4)*
- $2 \times F (15) = 0xD$ $\rightarrow$ `gf16_mult2[15] = 0x0D` *(Página 4)*
