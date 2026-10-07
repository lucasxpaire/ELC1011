# Q01: Derivação de Chave de 16 bits a partir de String

## Status
**Em Aberto (Decisão Provisória Adotada)**

---

## 1. Contexto do Problema
O documento de requisitos estabelece:
> *"Para testes e validação, serão fornecidos pelo professor dois arquivos: texto1.txt e texto2.txt. O programa deverá ser testado realizando a criptografia destes arquivos utilizando a chave ELC1011..."*

Entretanto:
- O algoritmo **S-AES** opera com uma chave estrita de **16 bits (2 bytes)**.
- A string `"ELC1011"` possui **7 caracteres ASCII** (`0x45`, `0x4C`, `0x43`, `0x31`, `0x30`, `0x31`, `0x31`), totalizando 56 bits.
- Não há no enunciado a regra explícita de conversão da string em 16 bits para o S-AES (ao passo que o RC4 suporta chaves de tamanho arbitrário).

---

## 2. Opções Analisadas

### Opção 1: Dobramento por XOR (*XOR-folding Hash*) [Adotada Provisoriamente]
Dobra toda a cadeia de caracteres da senha sobre 2 bytes (16 bits):
- `Key[15:8] = str[0] ^ str[2] ^ str[4] ^ str[6]...`
- `Key[7:0]  = str[1] ^ str[3] ^ str[5] ^ str[7]...`

**Para a chave `"ELC1011"`:**
- Byte Alto: `'E' ^ 'C' ^ '0' ^ '1' = 0x45 ^ 0x43 ^ 0x30 ^ 0x31 = 0x07`
- Byte Baixo: `'L' ^ '1' ^ '1' = 0x4C ^ 0x31 ^ 0x31 = 0x4C`
- Chave de 16 bits resultante: `0x074C`

**Vantagens:**
- Simples e elegante de implementar em MIPS (poucas instruções em loop).
- Cada caractere digitado altera a chave final.
- Suporta senhas de qualquer tamanho digitadas pelo usuário.

### Opção 2: Truncamento Simples (Primeiros 2 Bytes)
Considera apenas os dois primeiros caracteres da string:
- `Key[15:8] = str[0]` (`'E'` = `0x45`)
- `Key[7:0]  = str[1]` (`'L'` = `0x4C`)
- Chave de 16 bits resultante: `0x454C`

**Desvantagens:**
- Ignora o restante da senha `"C1011"`. Qualquer senha começando com `"EL"` produziria o mesmo texto cifrado.

### Opção 3: Parsing Hexadecimal
O programa esperaria que a chave fosse digitada como 4 dígitos hexadecimais (ex: `"4AF5"` $\rightarrow$ `0x4AF5`).

**Desvantagens:**
- Incompatível com o exemplo do enunciado, onde a chave é textualmente `"ELC1011"`.

---

## 3. Decisão Provisória e Arquitetura
1. Implementar a rotina isolada `derive_key_16bit` em `src/utils.asm` utilizando a **Opção 1 (XOR Folding)**.
2. Como a função é totalmente modular, caso o professor esclareça no fórum ou em aula uma regra específica de derivação, apenas o corpo de `derive_key_16bit` precisará ser ajustado, sem impacto em nenhuma outra parte do sistema.

---

## 4. Ação Recomendada
- Consultar o professor Giovani Baratto ou monitor da disciplina:
  > *"Professor, no S-AES a chave do algoritmo possui 16 bits, mas o teste especifica a chave 'ELC1011' (7 caracteres). Como o senhor espera que a string da chave seja convertida nos 16 bits do S-AES?"*
