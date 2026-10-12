# Plano de Revisão e Auditoria em Pequenos Blocos (Specs de Revisão)

Este diretório contém as **Especificações Formais de Revisão e Auditoria** para o Trabalho 1 da disciplina **ELC1011 (Organização de Computadores - UFSM, 2026/1)**.

---

## 1. Objetivo da Metodologia de Revisão

Para garantir a máxima confiabilidade, prevenir alucinações de modelo e evitar a omissão de detalhes críticos de baixo nível (como violações da ABI MIPS, vazamentos de pilha, desvios condicionais incorretos e falhas em casos de borda), o código-fonte foi particionado em **pequenos blocos atômicos e auditáveis**.

Cada especificação de revisão inspeciona um conjunto restrito de linhas e instruções, verificando rigorosamente:
1. **Conformidade com a ABI MIPS:** Preservação estrita dos registradores callee-saved (`$s0-$s7`, `$sp`, `$ra`), uso correto dos caller-saved (`$t0-$t9`) e convenção de retorno (`$v0-$v1`).
2. **Integridade da Pilha (*Stack Frame*):** Alinhamento obrigatório de 4 bytes, balanceamento exato entre alocação no prólogo e desalocação no epílogo, e coerência do mapa de endereçamento em `$sp`.
3. **Correção Algorítmica e Matemática:** Acurácia das tabelas estáticas, operações no corpo finito $GF(2^4)$, permutações de linhas, expansão de chaves e tratamento de blocos de 16 bits.
4. **Tratamento de I/O e Casos de Borda:** Comportamento diante de arquivos vazios, arquivos com quantidade ímpar de bytes (*zero-padding*), descritores inválidos e sanitização de strings.
5. **Estilo e Diretrizes Acadêmicas (Prof. Giovani Baratto):** Cabeçalho sem `&`, identificadores estritamente em português, notação de comentários com seta (`<-`), ausência de trechos em C e separação visual de prólogo/corpo/epílogo.

---

## 2. Matriz de Módulos e Especificações de Revisão

| Spec de Revisão | Módulo Inspecionado | Foco da Auditoria |
| :--- | :--- | :--- |
| [rev-01-tabelas-e-constantes.md](rev-01-tabelas-e-constantes.md) | `src/saes_tables.asm` | S-Box, InvS-Box, multiplicação em GF(16), alinhamentos de memória e vetor `subchaves`. |
| [rev-02-utilitarios-e-strings.md](rev-02-utilitarios-e-strings.md) | `src/utils.asm` | Sanitização de quebra de linha (`\n`, `\r`, `\0`) e derivação de chave de 16 bits por dobramento XOR. |
| [rev-03-nucleo-saes-expansao-e-transformacoes.md](rev-03-nucleo-saes-expansao-e-transformacoes.md) | `src/saes.asm` (Parte 1) | `rotaciona_substitui_byte`, `expande_chave`, `substitui_nibbles` e `desloca_linhas` (diretas e inversas). |
| [rev-04-nucleo-saes-mistura-cifra-decifra.md](rev-04-nucleo-saes-mistura-cifra-decifra.md) | `src/saes.asm` (Parte 2) | `mistura_colunas`, `mistura_colunas_inv`, `cifra_bloco` e `decifra_bloco`. |
| [rev-05-io-arquivos-e-buffers.md](rev-05-io-arquivos-e-buffers.md) | `src/file_io.asm` | Streaming via `buffer_io`, syscalls 13/14/15/16, zero-padding para arquivos ímpares e fechamento de descritores. |
| [rev-06-interface-terminal-e-orquestracao.md](rev-06-interface-terminal-e-orquestracao.md) | `src/main.asm` | Menu interativo, leitura de senha sem asteriscos, fluxo de cifra/decifra e encerramento. |
| [rev-07-padroes-baratto-e-testes.md](rev-07-padroes-baratto-e-testes.md) | Diretrizes e `tests/` | Checklist do Prof. Baratto, teste unitário de vetor oficial e teste integrado de ponta a ponta. |

---

## 3. Critérios de Avaliação de Cada Bloco

Cada item de cada spec de revisão é classificado de acordo com os seguintes estados:
- **[CONFORME]:** O bloco atende integralmente à especificação matemática, convenção de registradores e requisitos acadêmicos.
- **[PONTO DE ATENÇÃO]:** O código funciona corretamente, mas há oportunidade de otimização ou detalhe técnico digno de nota no relatório.
- **[NÃO CONFORME]:** Foi identificada violação funcional, quebra da ABI ou não conformidade de requisitos.
