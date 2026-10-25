# Spec: Padrões de Codificação e Estilo para o T2

> feature: t2-padroes-codigo
> status: pronta

## Contexto

Extração sistemática das diretrizes de codificação, nomenclatura, documentação e naturalização estabelecidas no Trabalho 1 (especificações `spec-07` e `spec-08`), e aplicação rigorosa na base de código e documentação do Trabalho 2 (`t2/`), assegurando uniformidade estilística, clareza didática e naturalidade acadêmica no padrão do Prof. Giovani Baratto.

## Histórias

### US-003 — Extração e consolidação do guia de estilo do T1 para o T2

Como estudante e desenvolvedor de Organização de Computadores, quero consolidar as regras de estilo de código de `t1/` em um documento de referência em `t2/docs/padroes_codificacao.md`, para que todos os programas do Trabalho 2 sigam os mesmos padrões de nomenclatura, cabeçalho e organização interna.

#### AC-006 — Guia formal de padrões de codificação do T2

- **Dado** as especificações de estilo existentes em `t1/docs/sdd/specs/spec-07-padroes-de-codificacao-e-estilo.md` e `t1/docs/sdd/specs/spec-08-refinamento-e-naturalizacao-do-codigo.md`
- **Quando** o documento `t2/docs/padroes_codificacao.md` é compilado
- **Então** ele deve descrever formalmente: (1) cabeçalho de arquivo sem `&` e sem régua numérica; (2) nomenclatura de procedimentos, rótulos e variáveis estritamente em português e `snake_case`; (3) cabeçalhos limpos de procedimentos sem blocos de código C e sem grades ASCII artificiais; (4) seções obrigatórias `# prologo`, `# corpo do procedimento` e `# epilogo`; (5) comentários linha a linha com operador de atribuição por seta `<-`; e (6) alinhamento padronizado de instruções e operandos.

### US-004 — Aplicação e naturalização do código-fonte q1.asm

Como revisor de código da disciplina, quero refatorar o arquivo `t2/src/q1.asm` aplicando as diretrizes consolidadas, para que o código seja limpo, natural, livre de artefatos sintéticos e preserve 100% da sua corretude funcional no simulador MARS.

#### AC-007 — Conformidade estilística e estrutural de q1.asm

- **Dado** o código-fonte `t2/src/q1.asm`
- **Quando** o arquivo é inspecionado estruturalmente
- **Então** ele não deve conter trechos de código C antes das rotinas (`/* ... */`), não deve possuir bordas ASCII com molduras (`+---+`), deve adotar cabeçalhos limpos (`Entrada:`, `Retorno:`, `Registradores:`, `Pilha:`), deve explicitar as seções `# prologo`, `# corpo do procedimento` e `# epilogo`, e deve utilizar comentários com seta `<-` para operações de registrador.

#### AC-008 — Preservação da corretude funcional e execução no MARS

- **Dado** o arquivo `t2/src/q1.asm` refatorado
- **Quando** é executado no simulador MARS 4.5 via linha de comando (`java -jar t2/Mars4_5.jar nc sm t2/src/q1.asm`)
- **Então** a execução termina com código 0 e a saída no terminal permanece exatamente `"O resultado e 17"`, mantendo total conformidade com o enunciado da Questão 1.

## Fora de escopo

- Alteração da lógica matemática ou dos procedimentos da Questão 1 além da refatoração de estilo e documentação.
- Modificação dos relatórios matemáticos da Questão 2 já validados.

## Suposições

| ID | Suposição | Status | Resolução |
|---|---|---|---|
| ASM-004 | Os padrões de estilo estabelecidos na Spec-07 e Spec-08 do T1 representam a convenção definitiva e aprovada para a disciplina ELC1011 e devem ser preservados integralmente no T2. | confirmada | Confirmado pela estrutura e histórico de entregas do projeto. |

## Perguntas em aberto

| ID | Pergunta | Status | Resposta |
|---|---|---|---|
| Q-002 | No cabeçalho de autoria do arquivo, deve constar apenas Lucas Xavier Pairé ou Lucas Xavier Pairé e Miguel Brondani (como no T1)? | respondida | Como a autoria observada em `q1.asm` anterior utilizava Lucas Xavier Pairé, manteremos a autoria com menção individual ou aos autores da disciplina conforme convenção de entrega do aluno. |
