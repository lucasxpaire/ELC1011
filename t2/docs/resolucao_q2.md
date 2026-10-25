# Resolução Analítica: Trabalho 2 - Parte 1 - Questão 2

**Universidade Federal de Santa Maria (UFSM)**  
**Centro de Tecnologia (CT) — Departamento de Eletrônica e Computação (DELC)**  
**Disciplina:** ELC1011 – Organização de Computadores  
**Professor:** Giovani Baratto  
**Aluno:** Lucas Xavier Pairé  

---

## Enunciado da Questão 2

> *Represente os números decimais $A = -27,30$ e $B = 10,25$ em complemento de 2 (em ponto fixo com sinal), usando 7 bits para a parte inteira e 4 bits para a parte fracionária. Mostre as etapas da conversão dos números de decimal para binário. Apresente a subtração $D = A - B$ em binário, como apresentado em sala de aula. Apresente os operandos, o resultado e todos os vem-uns. Houve overflow na operação de subtração? Por quê? Faça a soma $E = D + B$. Qual o valor de E? Este valor é igual a A? Comente o resultado de E e A.*

---

## 1. Especificação do Formato de Ponto Fixo (Q7.4 com Sinal)

O formato estabelecido possui um total de $7 + 4 = 11$ bits:
- **Parte inteira (7 bits com sinal):** $b_6 b_5 b_4 b_3 b_2 b_1 b_0$, onde o bit mais significativo $b_6$ é o bit de sinal com peso negativo $-2^6 = -64$.
- **Parte fracionária (4 bits):** $b_{-1} b_{-2} b_{-3} b_{-4}$, com pesos correspondentes a $2^{-1}, 2^{-2}, 2^{-3}, 2^{-4}$.

### Pesos posicionais de cada bit:

| Bit | $b_6$ (sinal) | $b_5$ | $b_4$ | $b_3$ | $b_2$ | $b_1$ | $b_0$ | . | $b_{-1}$ | $b_{-2}$ | $b_{-3}$ | $b_{-4}$ |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Peso Decimal** | $-64$ | $+32$ | $+16$ | $+8$ | $+4$ | $+2$ | $+1$ | . | $0,5$ | $0,25$ | $0,125$ | $0,0625$ |

- **Resolução fracionária (LSB):** $2^{-4} = 0,0625$.
- **Intervalo de representação (faixa dinâmica):**
  $$\left[-2^6, \; +2^6 - 2^{-4}\right] = [-64,0, \; +63,9375]$$

---

## 2. Conversão dos Números Decimais para Binário

### 2.1. Conversão do Número $B = +10,25$

Como $B$ é positivo, o bit de sinal é $0$.

#### Etapa 1: Conversão da parte inteira ($10_{10}$) por divisões sucessivas por 2
- $10 \div 2 = 5$ com resto **$0$** (bit $b_0$)
- $5 \div 2 = 2$ com resto **$1$** (bit $b_1$)
- $2 \div 2 = 1$ com resto **$0$** (bit $b_2$)
- $1 \div 2 = 0$ com resto **$1$** (bit $b_3$)

Lendo os restos de baixo para cima e preenchendo 7 bits com sinal:
$$10_{10} = 0001010_2$$

#### Etapa 2: Conversão da parte fracionária ($0,25_{10}$) por multiplicações sucessivas por 2
- $0,25 \times 2 = \mathbf{0},50 \implies$ parte inteira: **$0$** (bit $b_{-1}$)
- $0,50 \times 2 = \mathbf{1},00 \implies$ parte inteira: **$1$** (bit $b_{-2}$), parte fracionária restante $0,00$
- $0,00 \times 2 = \mathbf{0},00 \implies$ parte inteira: **$0$** (bit $b_{-3}$)
- $0,00 \times 2 = \mathbf{0},00 \implies$ parte inteira: **$0$** (bit $b_{-4}$)

Lendo os dígitos de cima para baixo:
$$0,25_{10} = .0100_2$$

#### Representação final de $B$:
$$B = 0001010.0100_2 \quad (+10,25_{10})$$

---

### 2.2. Conversão do Número $A = -27,30$

Como $A$ é negativo, primeiro converte-se sua magnitude positiva $+27,30$ e, em seguida, aplica-se a operação de complemento de 2.

#### Etapa 1: Conversão da parte inteira ($27_{10}$) por divisões sucessivas por 2
- $27 \div 2 = 13$ com resto **$1$** (bit $b_0$)
- $13 \div 2 = 6$ com resto **$1$** (bit $b_1$)
- $6 \div 2 = 3$ com resto **$0$** (bit $b_2$)
- $3 \div 2 = 1$ com resto **$1$** (bit $b_3$)
- $1 \div 2 = 0$ com resto **$1$** (bit $b_4$)

Preenchendo para 7 bits (com sinal positivo inicial):
$$27_{10} = 0011011_2$$

#### Etapa 2: Conversão da parte fracionária ($0,30_{10}$) por multiplicações sucessivas por 2
- $0,30 \times 2 = \mathbf{0},60 \implies$ parte inteira: **$0$** (bit $b_{-1}$)
- $0,60 \times 2 = \mathbf{1},20 \implies$ parte inteira: **$1$** (bit $b_{-2}$)
- $0,20 \times 2 = \mathbf{0},40 \implies$ parte inteira: **$0$** (bit $b_{-3}$)
- $0,40 \times 2 = \mathbf{0},80 \implies$ parte inteira: **$0$** (bit $b_{-4}$)
*(A multiplicação seguinte geraria $0,80 \times 2 = 1,60 \to 1$, resultando na dízima periódica $0,0100110011..._2$).*

Aplicando o **truncamento simples** para os 4 bits fracionários solicitados:
$$0,30_{10} \approx .0100_2 \quad (= 0,25_{10})$$

Magnitude positiva truncada em ponto fixo:
$$|A| = 0011011.0100_2 \quad (+27,25_{10})$$

#### Etapa 3: Obtenção do Complemento de 2 de $A$
1. Inversão bit a bit (Complemento de 1):
   $$\sim |A| = 1100100.1011_2$$
2. Adição de 1 na posição menos significativa ($+ 0000000.0001_2$):
   $$\begin{array}{r@{\quad}l}
     & 1100100.1011_2 \\
   + & 0000000.0001_2 \\
   \hline
     & 1100100.1100_2
   \end{array}$$

#### Conferência do valor em decimal:
$$\text{Valor}(A) = -64\cdot(1) + 32\cdot(1) + 4\cdot(1) + 0,5\cdot(1) + 0,25\cdot(1) = -64 + 36 + 0,75 = -27,25_{10}$$

#### Representação final de $A$:
$$A = 1100100.1100_2 \quad (-27,25_{10})$$

---

## 3. Subtração $D = A - B$ em Binário

Em aritmética de complemento de 2, a subtração $A - B$ é calculada através da adição de $A$ com o oposto aditivo de $B$:
$$D = A - B = A + (-B)$$

### 3.1. Obtenção de $-B$ em Complemento de 2
- $B = 0001010.0100_2 \quad (+10,25_{10})$
- Inversão de bits ($\sim B$): $1110101.1011_2$
- Soma de 1 no LSB:
  $$\begin{array}{r@{\quad}l}
    & 1110101.1011_2 \\
  + & 0000000.0001_2 \\
  \hline
    & 1110101.1100_2 \quad (-10,25_{10})
  \end{array}$$

Portanto:
$$-B = 1110101.1100_2$$

---

### 3.2. Operação de Adição $A + (-B)$ com Todos os Vem-uns

Apresentamos a operação armada, exibindo o vetor completo de transportes (*vem-uns*):

$$\begin{array}{lcccccccccccc}
\text{Vem-uns:} & \mathbf{1} & \mathbf{1} & \mathbf{0} & \mathbf{0} & \mathbf{1} & \mathbf{0} & \mathbf{0} & & \mathbf{1} & \mathbf{1} & \mathbf{0} & \mathbf{0} & \\
\text{Posições:} & c_{11} & c_{10} & c_9 & c_8 & c_7 & c_6 & c_5 & & c_4 & c_3 & c_2 & c_1 & c_0 \\
\hline
\text{Operando } A: & & 1 & 1 & 0 & 0 & 1 & 0 & 0 & . & 1 & 1 & 0 & 0 & (-27,25_{10}) \\
\text{Operando } (-B): & + & 1 & 1 & 1 & 0 & 1 & 0 & 1 & . & 1 & 1 & 0 & 0 & (-10,25_{10}) \\
\hline
\text{Resultado } D: & & \mathbf{1} & \mathbf{0} & \mathbf{1} & \mathbf{1} & \mathbf{0} & \mathbf{1} & \mathbf{0} & \mathbf{.} & \mathbf{1} & \mathbf{0} & \mathbf{0} & \mathbf{0} & (-37,50_{10})
\end{array}$$

*(O bit de transporte que sai além do tamanho da palavra, $c_{11} = 1$, é descartado na aritmética de 11 bits).*

### Detalhamento dos vem-uns coluna por coluna (do LSB para o MSB):
- **Coluna $b_{-4}$:** $0 + 0 + 0 = 0$ (soma $0$, vem-um $c_1 = 0$)
- **Coluna $b_{-3}$:** $0 + 0 + c_1(0) = 0$ (soma $0$, vem-um $c_2 = 0$)
- **Coluna $b_{-2}$:** $1 + 1 + c_2(0) = 2_{10} = 10_2$ (soma $0$, vem-um $c_3 = 1$)
- **Coluna $b_{-1}$:** $1 + 1 + c_3(1) = 3_{10} = 11_2$ (soma $1$, vem-um $c_4 = 1$)
- **Coluna $b_0$:** $0 + 1 + c_4(1) = 2_{10} = 10_2$ (soma $0$, vem-um $c_5 = 1$)
- **Coluna $b_1$:** $0 + 0 + c_5(1) = 1$ (soma $1$, vem-um $c_6 = 0$)
- **Coluna $b_2$:** $1 + 1 + c_6(0) = 2_{10} = 10_2$ (soma $0$, vem-um $c_7 = 1$)
- **Coluna $b_3$:** $0 + 0 + c_7(1) = 1$ (soma $1$, vem-um $c_8 = 0$)
- **Coluna $b_4$:** $0 + 1 + c_8(0) = 1$ (soma $1$, vem-um $c_9 = 0$)
- **Coluna $b_5$:** $1 + 1 + c_9(0) = 2_{10} = 10_2$ (soma $0$, vem-um $c_{10} = 1$)
- **Coluna $b_6$ (bit de sinal):** $1 + 1 + c_{10}(1) = 3_{10} = 11_2$ (soma $1$, vem-um de saída $c_{11} = 1$)

#### Conferência do valor decimal de $D$:
$$\text{Valor}(D) = -64\cdot(1) + 16\cdot(1) + 8\cdot(1) + 2\cdot(1) + 0,5\cdot(1) = -64 + 26 + 0,5 = -37,50_{10}$$

$$D = 1011010.1000_2 \quad (-37,50_{10})$$

---

## 4. Análise de Overflow na Operação de Subtração

**Resposta:** **NÃO houve overflow na operação de subtração.**

### Justificativas Formais:

1. **Critério dos sinais dos operandos:**
   A operação realizada foi a soma de dois números estritamente negativos:
   $$A < 0 \quad (-27,25) \quad \text{e} \quad (-B) < 0 \quad (-10,25)$$
   O resultado obtido $D$ possui bit de sinal $b_6 = 1$, sendo portanto negativo ($-37,50$). Em complemento de 2, o overflow em somas só ocorre quando operandos de mesmo sinal geram resultado com sinal oposto (por exemplo, dois negativos gerando um positivo). Como dois negativos geraram um negativo, **não houve overflow**.

2. **Critério dos transportes (carries) no bit de sinal:**
   Em uma ULA, o indicador de overflow $V$ é dado pelo XOR entre o carry que entra no bit de sinal ($c_{in} = c_{10}$) e o carry que sai do bit de sinal ($c_{out} = c_{11}$):
   $$V = c_{10} \oplus c_{11} = 1 \oplus 1 = 0$$
   Como $c_{in} = c_{out} = 1$, confirma-se formalmente a **ausência de overflow**.

3. **Critério da faixa dinâmica:**
   O valor resultante $-37,50_{10}$ encontra-se perfeitamente contido no intervalo representável do formato $Q7.4$:
   $$-37,50 \in [-64,0, \; +63,9375]$$

---

## 5. Soma $E = D + B$ em Binário

Executamos agora a soma do resultado obtido $D$ com o operando $B$:
$$D = 1011010.1000_2 \quad (-37,50_{10})$$
$$B = 0001010.0100_2 \quad (+10,25_{10})$$

### 5.1. Operação Armada com Todos os Vem-uns:

$$\begin{array}{lcccccccccccc}
\text{Vem-uns:} & \mathbf{0} & \mathbf{0} & \mathbf{0} & \mathbf{0} & \mathbf{0} & \mathbf{0} & \mathbf{0} & & \mathbf{0} & \mathbf{0} & \mathbf{0} & \mathbf{0} & \\
\text{Posições:} & c_{11} & c_{10} & c_9 & c_8 & c_7 & c_6 & c_5 & & c_4 & c_3 & c_2 & c_1 & c_0 \\
\hline
\text{Operando } D: & & 1 & 0 & 1 & 1 & 0 & 1 & 0 & . & 1 & 0 & 0 & 0 & (-37,50_{10}) \\
\text{Operando } B: & + & 0 & 0 & 0 & 1 & 0 & 1 & 0 & . & 0 & 1 & 0 & 0 & (+10,25_{10}) \\
\hline
\text{Resultado } E: & & \mathbf{1} & \mathbf{1} & \mathbf{0} & \mathbf{0} & \mathbf{1} & \mathbf{0} & \mathbf{0} & \mathbf{.} & \mathbf{1} & \mathbf{1} & \mathbf{0} & \mathbf{0} & (-27,25_{10})
\end{array}$$

### Detalhamento dos vem-uns:
- Nesta soma direta, as posições dos bits $1$ de $D$ e de $B$ não geram transporte (cada soma de bits resulta em $0$ ou $1$), logo todos os vem-uns são $0$ ($c_0 = \dots = c_{11} = 0$).

#### Valor resultante:
$$E = 1100100.1100_2 \quad (-27,25_{10})$$

---

## 6. Comparação e Comentário sobre o Resultado de $E$ e $A$

### 6.1. Qual o valor de $E$?
O valor obtido para $E$ é:
- Em binário: **$1100100.1100_2$**
- Em decimal: **$-27,25_{10}$**

### 6.2. Este valor é igual a $A$?
- **Sim, no nível da representação em máquina:** O valor binário de $E$ (`1100100.1100`) é **exatamente idêntico** ao valor binário de $A$ armazenado no formato $Q7.4$ (`1100100.1100`).
- **Não, em relação ao valor decimal original:** O valor decimal de $E$ ($-27,25$) difere do valor decimal teórico original de $A$ ($-27,30$) por uma discrepância de $0,05_{10}$.

### 6.3. Comentário Crítico sobre o Resultado
A análise deste resultado evidencia dois conceitos centrais de arquitetura e sistemas de numeração:

1. **Reversibilidade Algébrica Exata:**
   Como a operação de subtração $D = A - B$ não causou *overflow*, a álgebra em complemento de 2 é exata e linear. Ao somar $B$ de volta ao resultado $D$, a operação $E = D + B = (A - B) + B = A$ reconstitui perfeitamente a palavra binária original de $A$. Isso demonstra a propriedade de preservação de informação do complemento de 2 quando as operações permanecem dentro da faixa dinâmica representável.

2. **Erro de Quantização e Limitação de Base:**
   A fração decimal $0,30_{10}$ não possui representação binária exata finita (é uma fração não diádica que resulta em dízima periódica: $0,0100110011..._2$). Ao discretizar a magnitude para apenas 4 bits fracionários via truncamento simples, os bits de peso inferior a $2^{-4} = 0,0625$ foram descartados, retendo-se apenas $.0100_2 = 0,25_{10}$.
   
   Dessa forma, o erro absoluto de truncamento introduzido na conversão inicial foi de:
   $$\text{Erro} = |-27,30 - (-27,25)| = 0,05_{10}$$
   
   Portanto, a máquina preservou fidedignamente o seu estado interno representável ($-27,25$), mas a limitação de resolução da palavra impediu a representação exata do valor real original ($-27,30$).
