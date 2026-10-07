# Q02: Tratamento de Padding em Arquivos de Tamanho Ímpar

## Status
**Em Aberto (Decisão Provisória Adotada)**

---

## 1. Contexto do Problema
O algoritmo **S-AES** é uma cifra de bloco que opera estritamente sobre blocos de **16 bits (2 bytes)**.
Arquivos de texto reais podem ter um número arbitrário de bytes. Se o tamanho total do arquivo de entrada for um número **ímpar** (por exemplo, 15 bytes), o último bloco conterá apenas 1 byte válido.

É necessário definir uma estratégia de preenchimento (*padding*) para completar o bloco final de 16 bits tanto na criptografia quanto na descriptografia.

---

## 2. Opções Analisadas

### Opção 1: Zero-Padding (Preenchimento com `0x00`) [Adotada Provisoriamente]
- Se houver 1 byte restante no final da leitura, o segundo byte do bloco de 16 bits é preenchido com `0x00`.
- O bloco completo de 2 bytes é cifrado e gravado no arquivo de saída.
- Na descriptografia, o bloco é decifrado normalmente. Se o arquivo decifrado for lido como texto em C/MIPS/visualizadores, o byte `0x00` atua naturalmente como terminador de string nulo.

**Vantagens:**
- Implementação direta, robusta e com custo quase nulo em Assembly MIPS.
- Não requer metadados adicionais nem expansão arbitrária do arquivo.

**Desvantagens:**
- O arquivo de texto decifrado terá 1 byte a mais (`0x00`) no final em relação ao arquivo original se o tamanho original for ímpar. Se for par, o tamanho é exatamente idêntico.

### Opção 2: Padding PKCS#7 Adaptado para 2 Bytes
- Se faltar 1 byte para fechar 2 bytes, adiciona `0x01`.
- Se o arquivo já tiver tamanho par, adiciona um bloco inteiro `0x02, 0x02`.
- Na descriptografia, remove os bytes conforme o valor do último byte.

**Desvantagens:**
- Aumenta o tamanho de todos os arquivos pares em 2 bytes.
- Adiciona complexidade na decodificação de buffer em Assembly para verificar e truncar o arquivo na escrita.

### Opção 3: Suposição de Arquivos de Teste Pares
- Comum em trabalhos de graduação: os arquivos de teste do professor (`texto1.txt`, `texto2.txt`) podem ter sido elaborados previamente com número par de caracteres (ou terminados com quebra de linha `\r\n` totalizando tamanho par).

---

## 3. Decisão Provisória e Arquitetura
1. Adotar a **Opção 1 (Zero-Padding)**:
   - Se ao final da leitura restar 1 byte no buffer, armazena `0x00` na posição seguinte e cifra os 2 bytes.
   - Isso garante que a integridade e legibilidade do texto sejam mantidas sem falha de acesso à memória.

---

## 4. Ação Recomendada
- Verificar o tamanho dos arquivos `texto1.txt` e `texto2.txt` quando forem disponibilizados no Moodle pelo professor.
- Questionar o professor:
  > *"Professor, para o S-AES, se o arquivo de texto tiver tamanho ímpar de bytes, qual estratégia de preenchimento (padding) devemos adotar no último bloco de 16 bits?"*
