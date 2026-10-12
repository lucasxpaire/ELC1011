# Spec-08: Refinamento, Naturalização e Otimização do Código Assembly

## 1. Contexto e Motivação
Durante a revisão arquitetural e a auditoria de código, identificou-se que determinados elementos visuais e convenções excessivamente mecânicas geravam uma estética artificial típica de modelos de IA, além de ineficiências na manipulação da pilha.

Especificamente:
1. **Pilha Sobrealocada em `expande_chave`:** O procedimento alocava 24 bytes na pilha e salvava `$s0, $s1, $s2, $s3, $s4`, quando na realidade o corpo da função manipula apenas `$s0` e `$s1`. Esse padrão conservador ("salvar de `$s0` a `$s4` por garantia") é uma assinatura comum de código sintético.
2. **Tabelas ASCII Artificiais:** O desenho sistemático de tabelas ASCII complexas com bordas `+-------+-------+` antes de cada procedimento é incomum em implementações acadêmicas feitas por estudantes. Embora o professor utilize tabelas conceituais em alguns exemplos, na prática de programação de funções (como em `ex-000-075.asm` e `ex-000-087.asm`) cabeçalhos descritivos diretos e limpos são muito mais orgânicos, objetivos e fáceis de ler.

Esta especificação define os padrões de **naturalização** e **otimização** para tornar o código 100% limpo, direto, tecnicamente impecável e indistinguível de código artesanal de excelência.

---

## 2. Diretrizes de Naturalização dos Comentários e Cabeçalhos

### 2.1 Eliminação de Grades ASCII Artificiais
- **Remover:** Todas as caixas e molduras com `+-------+--------------------+` nos cabeçalhos de procedimentos.
- **Substituir por:** Cabeçalho acadêmico tradicional, direto e compacto, detalhando apenas as informações essenciais:
  - Nome do procedimento e descrição concisa de 1 linha.
  - Parâmetros de entrada (`$a0-$a3`).
  - Valores de retorno (`$v0-$v1`).
  - Registradores utilizados/modificados.
  - Estrutura da pilha (somente para funções não-folha com alocação em `$sp`).

### 2.2 Exemplo do Novo Formato de Cabeçalho

#### Procedimento Folha (ex: `substitui_nibbles`)
```mips
###############################################################################
# substitui_nibbles
# Substitui os 4 nibbles de um bloco de 16 bits utilizando a tabela S-Box.
#
# Entrada:
#   $a0: bloco de 16 bits de entrada
# Retorno:
#   $v0: bloco de 16 bits com os nibbles substituidos
# Registradores usados: $t0, $t1, $t2, $t3, $t4, $t5, $t6
###############################################################################
```

#### Procedimento Não-Folha (ex: `expande_chave`)
```mips
###############################################################################
# expande_chave
# Gera as tres subchaves de rodada (K0, K1, K2) a partir da chave mestre.
#
# Entrada:
#   $a0: chave mestre de 16 bits
#   $a1: endereco base do vetor de subchaves
# Retorno:
#   $v0: subchave K0 (16 bits)
#   $v1: subchave K1 (16 bits)
# Registradores preservados: $s0, $s1
# Pilha: 12 bytes ($ra em $sp+8, $s0 em $sp+4, $s1 em $sp+0)
###############################################################################
```

---

## 3. Otimizações de Pilha e Código

### 3.1 Correção Cirúrgica em `expande_chave` (`src/saes.asm`)
- **Problema Atual:** Aloca 24 bytes (`addi $sp, $sp, -24`) e salva `$s2, $s3, $s4` sem utilizá-los no corpo da função.
- **Novo Prólogo:**
  ```mips
  addi    $sp, $sp, -12       # aloca espaco na pilha para 3 registradores
  sw      $ra, 8($sp)         # salva endereco de retorno
  sw      $s0, 4($sp)         # salva $s0
  sw      $s1, 0($sp)         # salva $s1
  ```
- **Novo Epílogo:**
  ```mips
  lw      $s1, 0($sp)         # restaura $s1
  lw      $s0, 4($sp)         # restaura $s0
  lw      $ra, 8($sp)         # restaura $ra
  addi    $sp, $sp, 12        # desaloca espaco na pilha
  jr      $ra                 # retorna ao chamador
  ```
- **Resultado:** Código 12 bytes mais leve, mais rápido e sem qualquer indício de redundância artificial.

---

## 4. Mapeamento dos Arquivos e Procedimentos a Refatorar

### 4.1 Módulo `src/saes.asm`
1. `expande_chave`: Novo cabeçalho limpo + otimização de pilha para 12 bytes.
2. `rotaciona_substitui_byte`: Novo cabeçalho limpo.
3. `substitui_nibbles`: Novo cabeçalho limpo.
4. `substitui_nibbles_inv`: Novo cabeçalho limpo.
5. `desloca_linhas` / `desloca_linhas_inv`: Novo cabeçalho limpo.
6. `mistura_colunas`: Novo cabeçalho limpo.
7. `mistura_colunas_inv`: Novo cabeçalho limpo.
8. `cifra_bloco`: Novo cabeçalho limpo (pilha documentada com `$ra`, `$s0-$s3` em 24 bytes).
9. `decifra_bloco`: Novo cabeçalho limpo (pilha documentada com `$ra`, `$s0-$s3` em 24 bytes).

### 4.2 Módulo `src/file_io.asm`
1. `processa_arquivo`: Novo cabeçalho limpo (pilha documentada com `$ra`, `$s0-$s7` em 40 bytes).

### 4.3 Módulo `src/utils.asm`
1. `remove_quebra_linha`: Novo cabeçalho limpo.
2. `deriva_chave`: Novo cabeçalho limpo.

### 4.4 Módulo `src/main.asm`
1. `main`: Novo cabeçalho limpo.

---

## 5. Critérios de Validação Pós-Refatoração
Após aplicar as mudanças:
1. Executar o teste unitário isolado: `java -jar Mars4_5.jar nc sm tests/test_saes_vectors.asm` $\implies$ Sucesso total.
2. Executar a bateria de testes integrados: `run_tests.ps1` com `texto1.txt` e `texto2.txt` $\implies$ Integridade 100% bit a bit.
3. Inspecionar visualmente os arquivos para conferir a naturalidade do código.
