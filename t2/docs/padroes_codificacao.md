# Padrões de Codificação e Estilo em Assembly MIPS

**Universidade Federal de Santa Maria (UFSM)**  
**Centro de Tecnologia (CT) — Departamento de Eletrônica e Computação (DELC)**  
**Disciplina:** ELC1011 – Organização de Computadores  
**Professor:** Giovani Baratto  
**Autor:** Lucas Xavier Pairé  

---

## 1. Visão Geral

Este documento consolida as diretrizes de codificação, nomenclatura, documentação e naturalização estabelecidas para os trabalhos em Assembly MIPS na disciplina ELC1011, compilando os princípios das especificações `spec-07` e `spec-08`.

O objetivo é garantir consistência estilística, clareza didática e máxima aderência aos padrões praticados pelo professor nos códigos de exemplo da disciplina.

---

## 2. Cabeçalho Padronizado dos Arquivos

Todo arquivo `.asm` deve iniciar com o cabeçalho padronizado de identificação, sem uso de "e comercial" (`&`) e sem régua numérica de colunas:

```assembly
#*******************************************************************************
# Autor: Lucas Xavier Pairé
# Disciplina: ELC1011 - Organização de Computadores
# Professor: Giovani Baratto
# Descrição: [Descrição concisa e clara da finalidade do arquivo]
# Assembler: MARS
#*******************************************************************************
```

---

## 3. Nomenclatura e Idioma

1. **Português Estrito:** Todos os procedimentos, rótulos de desvio/controle e variáveis alocadas no segmento `.data` devem ser escritos estritamente em português.
2. **Convenção `snake_case`:** Todos os identificadores utilizam letras minúsculas separadas por sublinhado:
   - Procedimentos: `media3x2y`, `troca`, `imprime_resultado`.
   - Rótulos de controle: `laco_while`, `fim_while`, `desvia_troca`, `fim_se`.
   - Variáveis e buffers: `var_x`, `str_mensagem`, `buffer_dados`.

---

## 4. Estrutura e Naturalização dos Procedimentos

Para assegurar naturalidade e legibilidade técnica:

1. **Eliminação de Código C Redundante:** Não utilizar blocos de código C comentados antes dos procedimentos (`/* ... */`).
2. **Eliminação de Grades ASCII Artificiais:** Evitar caixas com molduras decorativas (`+-------+-------+`). Adotar cabeçalhos diretos e limpos.
3. **Formato Padrão de Cabeçalho de Procedimento:**
   - Procedimentos Não-Folha:
     ```assembly
     ###############################################################################
     # [nome_do_procedimento]
     # [Descrição sucinta de uma linha]
     #
     # Entrada:
     #   $a0: [descrição do parâmetro]
     #   $a1: [descrição do parâmetro]
     # Retorno:
     #   $v0: [descrição do valor retornado]
     # Registradores preservados: $s0, $s1 (ou conforme aplicável)
     # Pilha: [N] bytes ($ra em $sp+X, $s0 em $sp+Y, ...)
     ###############################################################################
     ```
   - Procedimentos Folha:
     ```assembly
     ###############################################################################
     # [nome_do_procedimento]
     # [Descrição sucinta de uma linha]
     #
     # Entrada:
     #   $a0: [descrição do parâmetro]
     #   $a1: [descrição do parâmetro]
     # Retorno:
     #   $v0: [descrição do valor retornado] (ou nenhum)
     # Registradores usados: $t0, $t1
     ###############################################################################
     ```

---

## 5. Organização Interna e Comentários

1. **Seções Obrigatórias:**
   - `# prologo`: Ajuste do ponteiro de pilha e salvamento de `$ra` e registradores `$sX`.
   - `# corpo do procedimento`: Instruções de processamento lógico/aritmético.
   - `# epilogo`: Restauração dos registradores salvos, desalocação da pilha e instrução de retorno (`jr $ra`).

2. **Operador de Atribuição por Seta (`<-`):**
   Comentários ao lado das instruções devem adotar a notação padrão do professor:
   - `# $t0 <- 5`
   - `# $s0 <- x`
   - `# salva $ra na pilha`
   - `# se x >= y desvia para fim_se`
   - `# restaura $ra da pilha`
   - `# retorna ao chamador`

3. **Alinhamento em Colunas:**
   - **Coluna 1:** Rótulos de procedimentos e desvios.
   - **Coluna 13:** Mnemônicos das instruções (`addiu`, `sw`, `lw`, etc.).
   - **Coluna 21:** Operandos da instrução.
   - **Comentários:** Alinhados à direita com `#`.
