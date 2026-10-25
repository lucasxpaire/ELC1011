# Plano de execução — t2-padroes-codigo

> gerado por `onp-spec plano` em 2026-10-25 20:33 — NÃO edite à mão;
> mudou tasks.md ou a config? Regenere: `onp-spec plano t2-padroes-codigo`

## Resumo — o que vai acontecer

- **3 tarefa(s) pendente(s)**: 3 em 3 faixa(s) paralela(s) + 0 sequencial(is)
- **1 faixa = 1 worktree + 1 branch + 1 janela de contexto limpa** — faixas não compartilham nenhum arquivo entre si
- prefere outra seleção ou uma após a outra? Regenere com `onp-spec plano t2-padroes-codigo --paralelizar T-xxx,T-yyy` ou `--sequencial`
- tudo acontece na branch de trabalho `spec/t2-padroes-codigo`; levar para a main é decisão sua

## Faixas e ondas

### Onda 1 — faixa-1 ∥ faixa-2 ∥ faixa-3

#### faixa-1 — branch `spec/t2-padroes-codigo-faixa-1` — worktree `../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-1`

| tarefa | título | modelo | esforço | arquivos |
|---|---|---|---|---|
| T-004 | Extração e consolidação do guia de padrões em t2/docs/padroes_codificacao.md | `claude-sonnet-5` | medium | `t2/docs/padroes_codificacao.md` |

#### faixa-2 — branch `spec/t2-padroes-codigo-faixa-2` — worktree `../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-2`

| tarefa | título | modelo | esforço | arquivos |
|---|---|---|---|---|
| T-005 | Refatoração e naturalização estilística de q1.asm | `claude-sonnet-5` | medium | `t2/src/q1.asm` |

#### faixa-3 — branch `spec/t2-padroes-codigo-faixa-3` — worktree `../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-3`

| tarefa | título | modelo | esforço | arquivos |
|---|---|---|---|---|
| T-006 | Suíte de testes de conformidade estilística e integridade funcional | `claude-sonnet-5` | medium | `t2/tests/trabalho2.test.js` |

## Gestão de branches e commits

1. branch de trabalho `spec/t2-padroes-codigo` criada do ponto atual (se ainda não existir)
2. cada faixa nasce dela como branch própria e roda no seu worktree — **1 tarefa = 1 commit** (`T-xxx feature: título`)
3. terminou a onda → merge `--no-ff` de cada faixa de volta, na ordem; conflito interrompe a faixa e pede resolução humana
4. faixa mesclada → worktree removido, branch apagada, tarefa marcada `[concluida]` no tasks.md
5. gate final na branch de trabalho: `onp-spec verify t2-padroes-codigo` + `onp-spec audit --ci` — **exit 0 ou não está pronto**

## Como executar

### ▶ Paralelo nativo no Antigravity (janelas limpas, sem Claude CLI)

1. **Prepare a branch de trabalho e os worktrees** (terminal, na raiz do repositório):

```bash
git checkout -b spec/t2-padroes-codigo   # ou: git checkout spec/t2-padroes-codigo
git worktree add ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-1 -b spec/t2-padroes-codigo-faixa-1
git worktree add ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-2 -b spec/t2-padroes-codigo-faixa-2
git worktree add ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-3 -b spec/t2-padroes-codigo-faixa-3
```

2. **Abra um agente NOVO por faixa** (janela limpa) e cole o prompt da faixa:

#### Prompt — faixa-1

```
Você executa as tarefas da faixa-1 da feature "t2-padroes-codigo" (fluxo onp-spec, spec-anchored).
Trabalhe SOMENTE dentro do worktree ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-1 (branch spec/t2-padroes-codigo-faixa-1) — já preparado.
Leia primeiro: .spec/features/t2-padroes-codigo/spec.md, .spec/features/t2-padroes-codigo/tasks.md e .spec/constituicao.md.

Execute NESTA ORDEM (1 tarefa = 1 commit):
T-004 — "Extração e consolidação do guia de padrões em t2/docs/padroes_codificacao.md"
  critérios/refs: AC-006 (Guia formal de padrões de codificação do T2)
  arquivos permitidos (e seus testes): t2/docs/padroes_codificacao.md
  mensagem de commit: "T-004 t2-padroes-codigo: Extração e consolidação do guia de padrões em t2/docs/padroes_codificacao.md"

Regras inegociáveis:
- Todo critério de aceite referenciado vira teste com @spec:AC-xxx no título.
- NUNCA enfraqueça, pule (skip/todo) ou apague um teste para passar — teste pulado não é prova e o audit acusa.
- Rode os testes localmente com `node --test --test-reporter=tap t2/tests/trabalho2.test.js` até passarem.
- NÃO edite tasks.md, NÃO rode onp-spec verify/audit e NÃO toque em outras tarefas — o orquestrador cuida disso.
- Ao final de CADA tarefa: `git add` só no que você tocou e um commit próprio.
Quando a última tarefa estiver commitada, PARE e informe o resultado — a mesclagem é do orquestrador.
```

#### Prompt — faixa-2

```
Você executa as tarefas da faixa-2 da feature "t2-padroes-codigo" (fluxo onp-spec, spec-anchored).
Trabalhe SOMENTE dentro do worktree ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-2 (branch spec/t2-padroes-codigo-faixa-2) — já preparado.
Leia primeiro: .spec/features/t2-padroes-codigo/spec.md, .spec/features/t2-padroes-codigo/tasks.md e .spec/constituicao.md.

Execute NESTA ORDEM (1 tarefa = 1 commit):
T-005 — "Refatoração e naturalização estilística de q1.asm"
  critérios/refs: AC-007 (Conformidade estilística e estrutural de q1.asm), AC-008 (Preservação da corretude funcional e execução no MARS)
  arquivos permitidos (e seus testes): t2/src/q1.asm
  mensagem de commit: "T-005 t2-padroes-codigo: Refatoração e naturalização estilística de q1.asm"

Regras inegociáveis:
- Todo critério de aceite referenciado vira teste com @spec:AC-xxx no título.
- NUNCA enfraqueça, pule (skip/todo) ou apague um teste para passar — teste pulado não é prova e o audit acusa.
- Rode os testes localmente com `node --test --test-reporter=tap t2/tests/trabalho2.test.js` até passarem.
- NÃO edite tasks.md, NÃO rode onp-spec verify/audit e NÃO toque em outras tarefas — o orquestrador cuida disso.
- Ao final de CADA tarefa: `git add` só no que você tocou e um commit próprio.
Quando a última tarefa estiver commitada, PARE e informe o resultado — a mesclagem é do orquestrador.
```

#### Prompt — faixa-3

```
Você executa as tarefas da faixa-3 da feature "t2-padroes-codigo" (fluxo onp-spec, spec-anchored).
Trabalhe SOMENTE dentro do worktree ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-3 (branch spec/t2-padroes-codigo-faixa-3) — já preparado.
Leia primeiro: .spec/features/t2-padroes-codigo/spec.md, .spec/features/t2-padroes-codigo/tasks.md e .spec/constituicao.md.

Execute NESTA ORDEM (1 tarefa = 1 commit):
T-006 — "Suíte de testes de conformidade estilística e integridade funcional"
  critérios/refs: AC-006 (Guia formal de padrões de codificação do T2), AC-007 (Conformidade estilística e estrutural de q1.asm), AC-008 (Preservação da corretude funcional e execução no MARS)
  arquivos permitidos (e seus testes): t2/tests/trabalho2.test.js
  mensagem de commit: "T-006 t2-padroes-codigo: Suíte de testes de conformidade estilística e integridade funcional"

Regras inegociáveis:
- Todo critério de aceite referenciado vira teste com @spec:AC-xxx no título.
- NUNCA enfraqueça, pule (skip/todo) ou apague um teste para passar — teste pulado não é prova e o audit acusa.
- Rode os testes localmente com `node --test --test-reporter=tap t2/tests/trabalho2.test.js` até passarem.
- NÃO edite tasks.md, NÃO rode onp-spec verify/audit e NÃO toque em outras tarefas — o orquestrador cuida disso.
- Ao final de CADA tarefa: `git add` só no que você tocou e um commit próprio.
Quando a última tarefa estiver commitada, PARE e informe o resultado — a mesclagem é do orquestrador.
```

3. **Todas terminaram? Mescle na ordem e marque as tarefas** (na árvore principal):

```bash
git merge --no-ff spec/t2-padroes-codigo-faixa-1 -m "merge faixa-1 (t2-padroes-codigo)"
git worktree remove ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-1 && git branch -d spec/t2-padroes-codigo-faixa-1
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs tarefa t2-padroes-codigo T-004 concluida
git merge --no-ff spec/t2-padroes-codigo-faixa-2 -m "merge faixa-2 (t2-padroes-codigo)"
git worktree remove ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-2 && git branch -d spec/t2-padroes-codigo-faixa-2
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs tarefa t2-padroes-codigo T-005 concluida
git merge --no-ff spec/t2-padroes-codigo-faixa-3 -m "merge faixa-3 (t2-padroes-codigo)"
git worktree remove ../onp-worktrees/ELC1011-t2-padroes-codigo-faixa-3 && git branch -d spec/t2-padroes-codigo-faixa-3
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs tarefa t2-padroes-codigo T-006 concluida
```

5. **Gate final** (exit 0 ou não está pronto):

```bash
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs verify t2-padroes-codigo
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs audit --ci
```

6. **Acompanhamento (a cada ~1 min, enquanto os agentes trabalham)**: avise ANTES
   de despachar os agentes que o trabalho roda em background e que o resumo
   completo vem ao final. Marque cada tarefa no ledger quando um agente começa
   e quando termina (é disso que a tabela é feita):

```bash
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs evento --run ELC1011-t2-padroes-codigo-mvoaccnv --tipo tarefa --tarefa <T-xxx> --faixa <faixa-N> --estado executando
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs evento --run ELC1011-t2-padroes-codigo-mvoaccnv --tipo tarefa --tarefa <T-xxx> --faixa <faixa-N> --estado concluida
```

   E a cada ~1 min poste no chat a TABELA de andamento + um parágrafo curto,
   registrando o texto no ledger:

```bash
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs resumo t2-padroes-codigo --tabela   # a tabela — cole no chat
node .agents/skills/onp-spec-driven/scripts/onp-spec.mjs resumo t2-padroes-codigo --gravar --origem ia --texto "<2 a 4 frases do que está rolando>"
```

