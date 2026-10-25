# Tasks: Padrões de Codificação e Estilo para o T2

> feature: t2-padroes-codigo

## T-004 — Extração e consolidação do guia de padrões em t2/docs/padroes_codificacao.md [concluida]
- Refs: US-003, AC-006
- Arquivos: t2/docs/padroes_codificacao.md
- Notas: Sintetizar as regras de Spec-07 e Spec-08 em documento claro contendo exemplos de cabeçalhos de arquivo e de procedimento, regras de nomenclatura em português e snake_case, eliminação de código C e molduras ASCII, notação de comentários com seta (<-) e convenções de alinhamento.

## T-005 — Refatoração e naturalização estilística de q1.asm [concluida]
- Refs: US-004, AC-007, AC-008
- Arquivos: t2/src/q1.asm
- Notas: Remover blocos de código C comentados antes dos procedimentos; eliminar mapas em moldura ASCII; adotar cabeçalhos diretos com Entrada, Retorno, Registradores e Pilha; incluir seções explícitas # prologo, # corpo do procedimento e # epilogo; uniformizar comentários com seta (<-); assegurar alinhamento por colunas e verificar que o MARS segue imprimindo "O resultado e 17".

## T-006 — Suíte de testes de conformidade estilística e integridade funcional [concluida]
- Refs: US-003, US-004, AC-006, AC-007, AC-008
- Arquivos: t2/tests/trabalho2.test.js
- Notas: Adicionar asserções de verificação para AC-006 (existência do guia e seções-chave), AC-007 (ausência de trechos de código C, ausência de molduras artificiais e presença de comentários com seta) e AC-008 (execução intacta de q1.asm no simulador MARS).
