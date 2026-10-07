# Spec-01: Arquitetura Global e Convenções de Montagem MIPS

## 1. Visão Geral
Esta especificação define a organização física dos arquivos, os padrões de codificação assembly para o processador MIPS no simulador **MARS 4.5**, as convenções de chamada de sub-rotinas (ABI), o gerenciamento de registradores e a pilha (*stack frame*).

---

## 2. Estrutura de Diretórios e Arquivos do Projeto

Todo o desenvolvimento está contido estritamente no diretório de trabalho `t1/`:

```
t1/
├── Mars4_5.jar                       # Simulador MARS 4.5
├── docs/                             # Documentação oficial e SDD
│   ├── requisitos                    # Enunciado original
│   ├── trabalho.pdf                  # PDF da descrição do trabalho
│   ├── simplified-aes-example.pdf    # Passo a passo de referência do S-AES
│   └── sdd/                          # Software Design Document
│       ├── README.md                 # Índice geral do SDD
│       ├── questions/                # Decisões e questões em aberto
│       └── specs/                    # Especificações técnicas
├── src/                              # Código-fonte MIPS Assembly
│   ├── main.asm                      # Entrada principal, loop de menu e UI
│   ├── saes_tables.asm               # S-Box, InvS-Box, tabelas GF16 Mult 2, 4, 9
│   ├── saes.asm                      # Motor S-AES: expansão, cifra e decifra
│   ├── file_io.asm                   # Sub-rotinas de arquivo e streaming de buffer
│   └── utils.asm                     # Limpeza de strings, derivação de chave
└── tests/                            # Testes automatizados e vetores
    ├── test_saes_vectors.asm         # Validação do algoritmo contra o exemplo oficial
    ├── run_tests.ps1                 # Script de execução em lote via MARS CLI
    └── data/                         # Arquivos de teste de exemplo
```

---

## 3. Diretivas de Montagem e Modularização no MARS

O MARS permite incluir arquivos assembly através da diretiva `.include "caminho"`.
- O arquivo raiz do programa é [src/main.asm](../../src/main.asm).
- Ele inclui os módulos especializados ao final do arquivo ou conforme escopo:
  ```mips
  .include "saes_tables.asm"
  .include "saes.asm"
  .include "file_io.asm"
  .include "utils.asm"
  ```
- Isso permite que o usuário simplesmente abra `main.asm` no MARS (ou invoque via CLI `java -jar Mars4_5.jar nc sm src/main.asm`) e execute o projeto completo sem necessidade de montar múltiplos arquivos manualmente.

---

## 4. Convenção de Registradores MIPS (ABI)

O projeto segue rigidamente a convenção de registradores MIPS para garantir estabilidade, evitar corrupção de variáveis entre sub-rotinas e facilitar depuração:

| Registrador | Nome / Função | Regra de Uso |
| :--- | :--- | :--- |
| `$zero` | Zero constante | Leitura somente (sempre `0`). |
| `$at` | Assembler Temporary | Reservado para o montador. Não utilizar explicitamente. |
| `$v0 - $v1` | Retornos de Funções / Syscall Code | Valores retornados por sub-rotinas ou identificador de syscall. |
| `$a0 - $a3` | Argumentos de Funções / Syscalls | Parâmetros passados para as sub-rotinas e argumentos de chamadas de sistema. |
| `$t0 - $t9` | Temporários (*Caller-saved*) | Podem ser sobrescritos por sub-rotinas chamadas. Não preservados entre chamadas `jal`. |
| `$s0 - $s7` | Preservados (*Callee-saved*) | Se uma sub-rotina utilizar `$s0-$s7`, **deve obrigatoriamente** salvá-los na pilha (`$sp`) na entrada (prólogo) e restaurá-los antes de retornar (epílogo). |
| `$sp` | Stack Pointer | Ponteiro da pilha de execução. Sempre alinhado em múltiplos de 4 (palavras). |
| `$ra` | Return Address | Endereço de retorno. **Obrigatório** salvar na pilha se a sub-rotina chamar qualquer outra função via `jal`. |

---

## 5. Padrão de Stack Frame (Prólogo e Epílogo)

Toda sub-rotina que utilize registradores `$s`, chame outras sub-rotinas ou aloque variáveis locais segue o padrão:

```mips
subrotina_exemplo:
    # 1. Prólogo: alocar pilha e salvar registradores
    addi $sp, $sp, -12        # Aloca 12 bytes (3 palavras)
    sw   $ra, 8($sp)          # Salva $ra
    sw   $s1, 4($sp)          # Salva $s1
    sw   $s0, 0($sp)          # Salva $s0

    # 2. Corpo da sub-rotina
    # ... operações ...

    # 3. Epílogo: restaurar registradores e desalocar pilha
    lw   $s0, 0($sp)          # Restaura $s0
    lw   $s1, 4($sp)          # Restaura $s1
    lw   $ra, 8($sp)          # Restaura $ra
    addi $sp, $sp, 12         # Libera espaço da pilha
    jr   $ra                  # Retorna ao chamador
```

---

## 6. Padrão de Comentários e Legibilidade
Conforme exigido nas diretrizes do trabalho e na avaliação acadêmica:
1. Toda função deve ter um cabeçalho descritivo com:
   - Propósito da função.
   - Parâmetros de entrada (`$a0-$a3`).
   - Valores de retorno (`$v0-$v1`).
   - Registradores destruídos/utilizados.
2. Instruções complexas (deslocamentos de bits, operações de Galois Field) devem conter comentários explicativos linha a linha.
