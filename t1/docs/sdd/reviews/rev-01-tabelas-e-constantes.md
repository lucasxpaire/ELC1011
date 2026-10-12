# Spec de Revisão 01: Tabelas Estáticas e Constantes (saes_tables.asm)

- **Arquivo Auditado:** `src/saes_tables.asm`
- **Total de Linhas:** 71
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 1.1: Tabela de Substituição Direta (`tabela_sbox`)

### Código Inspecionado
```mips
.align 0
tabela_sbox:
    .byte 0x09, 0x04, 0x0A, 0x0B, 0x0D, 0x01, 0x08, 0x05
    .byte 0x06, 0x02, 0x00, 0x03, 0x0C, 0x0E, 0x0F, 0x07
```

### Critérios de Auditoria e Verificação
1. **Definição Matemática:** A S-Box mapeia cada nibble de 4 bits ($0x0 \dots 0xF$) segundo a inversão multiplicativa em $GF(2^4)$ seguida de transformação afim.
2. **Conferência Elemento a Elemento:**
   - $S[0]=0x9, S[1]=0x4, S[2]=0xA, S[3]=0xB$
   - $S[4]=0xD, S[5]=0x1, S[6]=0x8, S[7]=0x5$
   - $S[8]=0x6, S[9]=0x2, S[A]=0x0, S[B]=0x3$
   - $S[C]=0xC, S[D]=0xE, S[E]=0xF, S[F]=0x7$
3. **Bijetividade:** Todos os 16 nibbles possíveis aparecem exatamente uma vez.
4. **Alinhamento e Diretiva:** `.align 0` e `.byte` adequados para acesso indexado por deslocamento de byte.

- **Veredito:** **[CONFORME]**

---

## Bloco 1.2: Tabela de Substituição Inversa (`tabela_inv_sbox`)

### Código Inspecionado
```mips
.align 0
tabela_inv_sbox:
    .byte 0x0A, 0x05, 0x09, 0x0B, 0x01, 0x07, 0x08, 0x0F
    .byte 0x06, 0x00, 0x02, 0x03, 0x0C, 0x04, 0x0D, 0x0E
```

### Critérios de Auditoria e Verificação
1. **Propriedade Inversa:** Deve satisfazer $\text{InvS}[S[x]] = x$ para todo $x \in \{0 \dots 15\}$.
2. **Conferência Cruzada:**
   - $S[0]=9 \implies \text{InvS}[9]=0$ (Conferido)
   - $S[1]=4 \implies \text{InvS}[4]=1$ (Conferido)
   - $S[2]=A \implies \text{InvS}[A]=2$ (Conferido)
   - $S[3]=B \implies \text{InvS}[B]=3$ (Conferido)
   - $S[4]=D \implies \text{InvS}[D]=4$ (Conferido)
   - $S[5]=1 \implies \text{InvS}[1]=5$ (Conferido)
   - $S[6]=8 \implies \text{InvS}[8]=6$ (Conferido)
   - $S[7]=5 \implies \text{InvS}[5]=7$ (Conferido)
   - $S[8]=6 \implies \text{InvS}[6]=8$ (Conferido)
   - $S[9]=2 \implies \text{InvS}[2]=9$ (Conferido)
   - $S[A]=0 \implies \text{InvS}[0]=A$ (Conferido)
   - $S[B]=3 \implies \text{InvS}[3]=B$ (Conferido)
   - $S[C]=C \implies \text{InvS}[C]=C$ (Conferido - ponto fixo)
   - $S[D]=E \implies \text{InvS}[E]=D$ (Conferido)
   - $S[E]=F \implies \text{InvS}[F]=E$ (Conferido)
   - $S[F]=7 \implies \text{InvS}[7]=F$ (Conferido)

- **Veredito:** **[CONFORME]**

---

## Bloco 1.3: Tabelas de Multiplicação em GF(16) mod ($x^4 + x + 1$)

### Código Inspecionado
```mips
# Multiplicação por 2
tabela_mult2:
    .byte 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E
    .byte 0x03, 0x01, 0x07, 0x05, 0x0B, 0x09, 0x0F, 0x0D

# Multiplicação por 4 (usada em mistura_colunas)
tabela_mult4:
    .byte 0x00, 0x04, 0x08, 0x0C, 0x03, 0x07, 0x0B, 0x0F
    .byte 0x06, 0x02, 0x0E, 0x0A, 0x05, 0x01, 0x0D, 0x09

# Multiplicação por 9 (usada em mistura_colunas_inv)
tabela_mult9:
    .byte 0x00, 0x09, 0x01, 0x08, 0x02, 0x0B, 0x03, 0x0A
    .byte 0x04, 0x0D, 0x05, 0x0C, 0x06, 0x0F, 0x07, 0x0E
```

### Critérios de Auditoria e Verificação
1. **Polinômio Irredutível:** $P(x) = x^4 + x + 1 \equiv 0x13$.
2. **Multiplicação por 2:** $2 \cdot x = (x \ll 1) \oplus (0x13 \text{ se bit 3 estava ativo})$.
   - Exemplo $2 \cdot 8 = 0x10 \oplus 0x13 = 0x03$ (Posição 8 = `0x03`).
3. **Multiplicação por 4:** $4 \cdot x = 2 \cdot (2 \cdot x)$.
   - Exemplo $4 \cdot 4 = 2 \cdot (8) = 0x03$ (Posição 4 = `0x03`).
4. **Multiplicação por 9:** $9 \cdot x = (8 \cdot x) \oplus x = 2 \cdot (4 \cdot x) \oplus x$.
   - Exemplo $9 \cdot 2 = (x^3 + 1) \cdot x = x^4 + x \equiv 1$ (Posição 2 = `0x01`).
5. **Propriedade Inversa das Matrizes:**
   $$\begin{pmatrix} 1 & 4 \\ 4 & 1 \end{pmatrix} \begin{pmatrix} 9 & 2 \\ 2 & 9 \end{pmatrix} = \begin{pmatrix} (9 \oplus 8) & (2 \oplus 0x24) \\ (36 \oplus 2) & (8 \oplus 9) \end{pmatrix} = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$$
   Garante inversibilidade matemática rigorosa da matriz de mistura de colunas.

- **Veredito:** **[CONFORME]**

---

## Bloco 1.4: Vetor de Subchaves (`subchaves`)

### Código Inspecionado
```mips
.align 1
subchaves:
    .half 0x0000, 0x0000, 0x0000
```

### Critérios de Auditoria e Verificação
1. **Tamanho e Tipo:** 3 subchaves de 16 bits ($K_0, K_1, K_2$) $\implies$ $3 \times 2 = 6$ bytes.
2. **Alinhamento:** `.align 1` alinha em múltiplos de 2 bytes (halfword). Instruções `lhu` e `sh` acessam offsets 0, 2 e 4 com segurança total sem gerar exceção de barramento (*unaligned access*).
3. **Escopo:** Declarado com `.globl subchaves` permitindo compartilhamento entre módulos e testes unitários.

- **Veredito:** **[CONFORME]**
