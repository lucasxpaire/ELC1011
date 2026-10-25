# Spec: Trabalho 2 - Parte 1 (ELC1011)

> feature: t2-parte-01
> status: pronta

## Contexto

Resolução completa e verificável da Parte 1 do Trabalho 2 da disciplina ELC1011 (Organização de Computadores - UFSM), abrangendo a tradução de código C para MIPS Assembly com procedimentos e ponteiros (Questão 1) e a representação e operações aritméticas em complemento de 2 em ponto fixo Q7.4 (Questão 2).

## Histórias

### US-001 — Tradução e execução de procedimentos em MIPS Assembly (Questão 1)

Como estudante de Organização de Computadores, quero traduzir o programa em C com ponteiros, procedimentos e laços para Assembly MIPS (`q1.asm`), para que o simulador MARS execute o código corretamente respeitando as convenções de chamada da arquitetura e exibindo o resultado esperado da função `media3x2y` (17).

#### AC-001 — Alocação de variáveis globais e locais e conformidade com o simulador MARS

- **Dado** o arquivo de código-fonte `t2/src/q1.asm` estruturado com as convenções de pilha e registradores MIPS (seção `.data` para a variável global `x`, e pilha de execução para variáveis locais `y`, `z`, `a`, `b`)
- **Quando** o arquivo é montado e executado no simulador MARS 4.5 via linha de comando (`java -jar t2/Mars4_5.jar nc sm t2/src/q1.asm`)
- **Então** o programa executa sem erros de tempo de execução (*runtime exceptions*) e termina com código de saída normal.

#### AC-002 — Retorno correto da função media3x2y e impressão simplificada

- **Dado** o programa montado e executado com `x = 5` e `y = 10`
- **Quando** a função `media3x2y(x, y)` conclui suas chamadas à função `troca(&a, &b)` e executa o laço `while (a > b)`
- **Então** o valor retornado no registrador de retorno é `17` e a rotina simplificada de impressão imprime na saída padrão a mensagem contendo `"O resultado e 17"` (ou `"O resultado é 17"`).

### US-002 — Resolução analítica de aritmética em ponto fixo e complemento de 2 (Questão 2)

Como estudante de Organização de Computadores, quero apresentar os cálculos detalhados de conversão decimal-binário em ponto fixo Q7.4 com sinal em complemento de 2 para $A = -27,30$ e $B = 10,25$, bem como a subtração $D = A - B$, a análise de *overflow* e a soma $E = D + B$, para demonstrar o entendimento das operações e limitações de precisão.

#### AC-003 — Conversão e representação de A e B em ponto fixo com sinal

- **Dado** os valores decimais $A = -27,30$ e $B = 10,25$ no formato Q7.4 (7 bits inteiros incluindo sinal e 4 bits fracionários)
- **Quando** é realizada a conversão passo a passo da parte inteira por divisões sucessivas, da parte fracionária por multiplicações sucessivas (com truncamento simples nos 4 bits fracionários) e a aplicação do complemento de 2 para o valor negativo
- **Então** a representação binária de $B$ é determinada exatamente como `0001010.0100` ($+10,25_{10}$) e a de $A$ é expressa exatamente como `1100100.1100` (representação interna em complemento de 2 truncada, correspondente a $-27,25_{10}$).

#### AC-004 — Subtração D = A - B com tabela de vem-uns e análise de overflow

- **Dado** os operandos $A$ e $-B$ em complemento de 2 no formato Q7.4
- **Quando** a operação de subtração $D = A - B$ é executada na forma $A + (-B)$
- **Então** todos os bits de vem-um (*carries*) da coluna fracionária menos significativa até a coluna de sinal são demonstrados, obtendo-se o resultado $D$, e comprova-se formalmente que não houve *overflow* ($c_{in} = c_{out}$ no bit de sinal e resultado dentro da faixa representável $[-64, +63.9375]$).

#### AC-005 — Soma E = D + B e análise de igualdade com A

- **Dado** o resultado $D$ e o operando $B$ em complemento de 2
- **Quando** é efetuada a soma $E = D + B$ com todos os vem-uns
- **Então** o valor resultante $E$ é calculado em binário e decimal, demonstrando que coincide com a representação de máquina de $A$, e explicando conceitualmente por que difere do valor decimal original $-27,30$ devido à discretização/quantização da base binária com 4 bits fracionários.

## Fora de escopo

- Implementação das Partes 2 (multiplicação, divisão e ponto flutuante) e 3 (monociclo/multiciclo) do Trabalho 2.
- Emulação gráfica ou periféricos além do terminal padrão MARS.

## Suposições

| ID | Suposição | Status | Resolução |
|---|---|---|---|
| ASM-001 | A variável `x` na Listagem 1 em C é global (declarada fora do escopo de qualquer função) e portanto deve ser alocada no segmento `.data`, enquanto `y` e `z` em `main` são locais e devem residir na pilha de execução. | confirmada | Confirmado pela listagem 1 (linha 28 fora de funções). |
| ASM-002 | O simulador padrão a ser utilizado para validação e execução é o MARS 4.5 (`Mars4_5.jar`), já disponível no repositório. | confirmada | Presente em `t1/Mars4_5.jar` e `t2/Mars4_5.jar`. |
| ASM-003 | A Questão 2 deve ser apresentada em relatório técnico legível (Markdown e/ou LaTeX/PDF) com todas as etapas algébricas e tabelas de transporte (vem-uns). | confirmada | Padrão dos trabalhos da disciplina com entrega no Moodle. |

## Perguntas em aberto

| ID | Pergunta | Status | Resposta |
|---|---|---|---|
| Q-001 | Na conversão de $0,30$ fracionário (dízima periódica em binário $0,01001100...$) para 4 bits na Questão 2, deve-se adotar truncamento simples ou arredondamento? | respondida | Decidido: adotar truncamento simples direto dos 4 primeiros bits fracionários ($0,0100_2 = 0,25_{10}$), método padrão apresentado em sala de aula, dispensando explicação de método alternativo por arredondamento. |
