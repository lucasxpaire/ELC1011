# Spec de Revisão 07: Padrões do Prof. Baratto, Testes e Entrega

- **Arquivo Auditado:** Diretrizes Acadêmicas, `tests/test_saes_vectors.asm` e `tests/run_tests.ps1`
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 6.1: Conformidade com o Padrão do Prof. Giovani Baratto

### Critérios de Auditoria e Verificação
1. **Cabeçalho Padronizado:**
   - Todo arquivo inicia com o cabeçalho padronizado:
     ```mips
     #*******************************************************************************
     # Autores: Lucas Xavier Pairé e Miguel Brondani
     # Disciplina: ELC1011 - Organização de Computadores
     # Professor: Giovani Baratto
     # Descrição: ...
     # Assembler: MARS
     #*******************************************************************************
     ```
   - **Verificação:** Nenhum arquivo utiliza o caractere `&` (usa a conjunção "e"), nem réguas numéricas desnecessárias.
2. **Nomenclatura Estritamente em Português:**
   - Procedimentos: `expande_chave`, `cifra_bloco`, `decifra_bloco`, `substitui_nibbles`, `desloca_linhas`, `mistura_colunas`, `processa_arquivo`, `remove_quebra_linha`, `deriva_chave`.
   - Tabelas e Variáveis: `tabela_sbox`, `tabela_inv_sbox`, `tabela_mult2`, `tabela_mult4`, `tabela_mult9`, `subchaves`, `buffer_io`, `buffer_nome_entrada`, `buffer_nome_saida`, `buffer_chave`.
   - Rótulos de Desvios: `laco_leitura_buffer`, `laco_processa_blocos`, `executa_criptografia`, `fim_processamento`.
   - **Verificação:** 100% dos identificadores em assembly estão em português e no padrão `snake_case`.
3. **Notação de Comentários Linha a Linha:**
   - Todas as instruções com comentário explicativo utilizam a seta de atribuição (`<-`):
     * `# $t0 <- endereço base da tabela_sbox`
     * `# $v0 <- serviço 13: abre arquivo`
     * `# se $t1 == 0 desvia para fim_laco`
   - **Verificação:** Plena conformidade com os exemplos didáticos do professor em `docs/padroes/códigos exemplo/`.
4. **Mapas de Registradores e da Pilha:**
   - Todos os procedimentos com alocação em `$sp` apresentam tabelas ASCII explícitas do mapa de registradores e do mapa relativo a `$sp` (`$sp + 0`, `$sp + 4`...).
   - Ausência de trechos de código C antes das funções.

- **Veredito:** **[CONFORME]**

---

## Bloco 6.2: Teste Unitário Automatizado do Motor S-AES (`tests/test_saes_vectors.asm`)

### Código Inspecionado e Execução
```mips
# Vetor oficial da literatura (Stallings / Gordon)
# Chave mestre K = 0x4AF5
# Esperado: Key0 = 0x4AF5, Key1 = 0xDD28, Key2 = 0x87AF
# Bloco Claro P = 0xD728 -> Cifrado C = 0x24EC
# Bloco Cifrado C = 0x24EC -> Decifrado P = 0xD728
```

### Resultados da Execução no MARS CLI:
```text
=== EXECUTANDO TESTE UNITARIO DO MOTOR S-AES ===
[OK] Subchave Key0 = 0x4AF5 conferida!
[OK] Subchave Key1 = 0xDD28 conferida!
[OK] Subchave Key2 = 0x87AF conferida!
[OK] Criptografia de 0xD728 resultou em 0x24EC!
[OK] Descriptografia de 0x24EC retornou 0xD728!

>>> [SUCESSO TOTAL] O ALGORITMO S-AES ESTA 100% CORRETO! <<<
```

### Critérios de Auditoria e Verificação
1. As 3 subchaves geradas por `expande_chave` são comparadas byte a byte contra os valores exatos da especificação matemática.
2. A transformação completa de `cifra_bloco` e a reversão de `decifra_bloco` fecham perfeitamente no vetor de referência sem discrepâncias.

- **Veredito:** **[CONFORME]**

---

## Bloco 6.3: Teste Integrado com Arquivos Oficiais (`tests/run_tests.ps1`)

### Validação de Ponta a Ponta:
1. **Arquivo `texto1.txt` (111 bytes - tamanho ímpar):**
   - Criptografado com a senha `"ELC1011"` gerando `secreto1.aes` (112 bytes com zero-padding).
   - Descriptografado com a senha `"ELC1011"` gerando `teste1.txt` (112 bytes).
   - Verificação byte a byte contra o conteúdo original de 111 bytes: **100% idêntico**.
2. **Arquivo `texto2.txt` (238 bytes - tamanho par):**
   - Criptografado com a senha `"ELC1011"` gerando `secreto2.aes` (238 bytes).
   - Descriptografado com a senha `"ELC1011"` gerando `teste2.txt` (238 bytes).
   - Verificação byte a byte: **100% idêntico**.

### Resultado da Bateria de Testes:
```text
[1/3] Executando Teste Unitario do Motor S-AES... [SUCESSO]
[2/3] Executando Teste Integrado com texto1.txt... [SUCESSO]
[3/3] Executando Teste Integrado com texto2.txt... [SUCESSO]
TODOS OS TESTES FORAM CONCLUIDOS COM EXITO MAXIMO!
```

- **Veredito:** **[CONFORME]**

---

## Bloco 6.4: Requisitos Obrigatórios de Entrega (Moodle)

| Requisito do Enunciado | Situação Atual | Ação Necessária |
| :--- | :--- | :--- |
| **Entrega via arquivo `.zip`** | Estrutura pronta para compactação | Compactar arquivos `.asm` e o PDF final antes da submissão. |
| **Código `.asm` comentado para MARS** | [CONFORME] | Todos os 5 módulos prontos, testados e comentados no padrão Baratto. |
| **Relatório em PDF com as 7 seções obrigatórias** | Pendente de compilação | Redigir e compilar o PDF com as seções: *Introdução, Objetivos, Referencial Teórico, Metodologia, Experimentos e Resultados, Discussão, Conclusões e Perspectivas*. |
| **Arguição sobre a implementação** | Preparado | O particionamento em blocos das specs de revisão serve como guia de estudo completo para a arguição com o professor. |

- **Veredito:** **[CONFORME / RELATÓRIO PENDENTE DE COMPILAÇÃO FINAL]**
