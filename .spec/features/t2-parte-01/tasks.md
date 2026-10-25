# Tasks: Trabalho 2 - Parte 1 (ELC1011)

> feature: t2-parte-01

## T-001 — Implementação do programa MIPS Assembly q1.asm [concluida]
- Refs: US-001, AC-001, AC-002
- Arquivos: t2/src/q1.asm
- Notas: Implementar conforme o padrão do Prof. Giovani Baratto (comentários didáticos, mapas de pilha, prólogos e epílogos explícitos). Alocar a variável global x no segmento .data; alocar variáveis locais de main, media3x2y e troca no stack; implementar a rotina de troca por ponteiros, a função media3x2y com a chamada condicional e laço while, e printf simplificado com chamadas ao sistema MARS.

## T-002 — Criação da suíte de testes de verificação automatizada [concluida]
- Refs: US-001, US-002, AC-001, AC-002, AC-003, AC-004, AC-005
- Arquivos: t2/tests/trabalho2.test.js
- Notas: Implementar testes executáveis com Node.js (compatíveis com onp-spec verify e reporter tap) contendo tags @spec para todos os critérios de aceite (AC-001 a AC-005). O teste executará o MARS 4.5 via CLI para validar a saída de q1.asm e verificará os cálculos aritméticos da Questão 2.

## T-003 — Elaboração do relatório analítico com resolução da Questão 2 [concluida]
- Refs: US-002, AC-003, AC-004, AC-005
- Arquivos: t2/docs/resolucao_q2.md
- Notas: Documentar todas as conversões passo a passo para o formato Q7.4 com sinal em complemento de 2, utilizando truncamento simples na parte fracionária de A (4 bits fracionários via multiplicações sucessivas). Montar as tabelas completas de transporte (vem-uns) bit a bit para D = A - B e E = D + B, demonstrar formalmente a ausência de overflow e redigir a discussão conceitual sobre a igualdade de E e A (recuperação do valor de máquina e perda por truncamento).
