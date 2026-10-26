# Tasks: Revisão e Auditoria de Corretude do Trabalho 2

> feature: t2-revisao-corretude

## T-007 — Correção analítica da tabela de vem-uns da soma E = D + B em resolucao_q2.md [pendente]
- Refs: US-005, AC-010
- Arquivos: t2/docs/resolucao_q2.md
- Notas: Corrigir a tabela e a explicação dos transportes da soma E = D + B nas seções 5 e 5.1 de t2/docs/resolucao_q2.md, documentando com rigor matemático os transportes gerados nas colunas b1 (c6=1), b3 (c8=1) e b4 (c9=1), eliminando a afirmação de que todos os vem-uns eram zero.

## T-008 — Expansão da suíte de testes com asserções detalhadas de vem-uns e conformidade [pendente]
- Refs: US-005, AC-009, AC-010, AC-011
- Arquivos: t2/tests/trabalho2.test.js
- Notas: Adicionar testes automatizados anotados com @spec:AC-009, @spec:AC-010 e @spec:AC-011, verificando: (1) conformidade de q1.asm mantendo imprime_resultado e execução no MARS com saída "O resultado e 17", (2) teste bit a bit de todos os 12 bits de transporte (carries c0 a c11) da soma E = D + B, e (3) integridade geral da suíte de testes.
