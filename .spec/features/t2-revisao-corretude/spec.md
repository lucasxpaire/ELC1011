# Spec: Revisão e Auditoria de Corretude do Trabalho 2

> feature: t2-revisao-corretude
> status: pronta

## Contexto

Auditoria técnica e revisão detalhada de corretude dos códigos e resoluções do Trabalho 2 - Parte 1 (disciplina ELC1011 - Organização de Computadores - UFSM), abrangendo a verificação da tradução MIPS Assembly (Questão 1), a correção matemática de transportes da soma de ponto fixo Q7.4 (Questão 2), e a expansão da suíte automatizada de testes para blindagem contra erros conceituais e estruturais.

## Histórias

### US-005 — Revisão e auditoria rigorosa de corretude das Questões 1 e 2

Como estudante e revisor de Organização de Computadores, quero realizar uma auditoria rigorosa das soluções propostas para as Questões 1 e 2 do Trabalho 2, corrigindo inconsistências analíticas na resolução matemática e expandindo as asserções de teste automatizadas, mantendo os padrões de nomenclatura em português estrito para garantir nota máxima e total conformidade com as diretrizes do Prof. Giovani Baratto.

#### AC-009 — Validação de conformidade estrutural e convenções em q1.asm

- **Dado** o arquivo de código-fonte `t2/src/q1.asm` estruturado com as convenções de pilha e registradores MIPS e nomenclatura em português
- **Quando** o arquivo é analisado estilística e funcionalmente no simulador MARS 4.5
- **Então** ele deve manter o procedimento `imprime_resultado` estritamente em português conforme o guia de padrões, preservar adequadamente os registradores salvos (`$s0`, `$s1`) e de retorno (`$ra`), manipular ponteiros via desreferenciação em `troca`, e produzir a saída `"O resultado e 17"` sem exceções de tempo de execução.

#### AC-010 — Correção matemática e detalhamento dos vem-uns da soma E = D + B em resolucao_q2.md

- **Dado** o relatório analítico `t2/docs/resolucao_q2.md` com a resolução da Questão 2
- **Quando** a seção 5 relativa à soma $E = D + B$ é inspecionada
- **Então** o vetor completo de transportes (*vem-uns*) deve refletir fielmente a aritmética binária da adição $1011010.1000_2 + 0001010.0100_2$, demonstrando os transportes gerados nas colunas $b_1$ ($c_6=1$), $b_3$ ($c_8=1$) e $b_4$ ($c_9=1$), eliminando a afirmação errônea de que "todos os vem-uns são 0", e confirmando que o resultado $E = 1100100.1100_2$ reconstitui perfeitamente a representação interna de $A$.

#### AC-011 — Expansão dos testes automatizados com validação estrita de vem-uns e conformidade geral

- **Dado** a suíte de testes `t2/tests/trabalho2.test.js`
- **Quando** a suíte é executada através do executor de testes Node.js (`node --test`)
- **Então** ela deve conter asserções dedicadas para verificar: (1) a preservação do procedimento `imprime_resultado` e a execução correta no MARS com saída `"O resultado e 17"`, e (2) o cálculo exato bit a bit de cada um dos bits de transporte (*carries*) para a soma $E = D + B$, atestando conformidade com AC-009, AC-010 e AC-011.

## Fora de escopo

- Implementação de alias ou símbolos adicionais como `printf:` em `q1.asm` (o procedimento permanece `imprime_resultado` conforme decisão do usuário).
- Resolução de exercícios das Partes 2 e 3 do Trabalho 2.
- Alteração da convenção de truncamento simples já consolidada para a parte fracionária na Questão 2.

## Suposições

| ID | Suposição | Status | Resolução |
|---|---|---|---|
| ASM-005 | O procedimento de impressão deve manter a nomenclatura em português estrito (`imprime_resultado`) definida no guia de padrões da disciplina, sem aliases adicionais. | confirmada | Confirmado expressamente pelo usuário. |

## Perguntas em aberto

| ID | Pergunta | Status | Resposta |
|---|---|---|---|
| Q-003 | Deve ser implementada dupla compatibilidade criando o rótulo `printf:` em `q1.asm`? | respondida | Não. Manter exclusivamente o procedimento `imprime_resultado` conforme o guia de padrões de codificação da disciplina. |
