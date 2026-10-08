# Spec-06: Plano de Testes, Validação e Automação

## 1. Visão Geral
Esta especificação descreve a estratégia de garantia de qualidade (QA) para o sistema criptográfico S-AES, dividida em **Testes Unitários de Algoritmo** e **Testes de Integração de Arquivos**, com automação via linha de comando no simulador **MARS 4.5**, de acordo com a [Spec-07](spec-07-padroes-de-codificacao-e-estilo.md).

---

## 2. Nível 1: Testes Unitários do Motor S-AES (`tests/test_saes_vectors.asm`)

### 2.1 Cenário de Teste Padrão (Vetor de Steven Gordon)
Baseado no documento oficial [docs/simplified-aes-example.pdf](../simplified-aes-example.pdf):
- **Entrada (Texto Claro):** `0xD728` (`1101 0111 0010 1000_2`)
- **Chave Mestre:** `0x4AF5` (`0100 1010 1111 0101_2`)

### 2.2 Critérios de Sucesso (Asserts em Assembly)
1. **Subchaves Geradas (`expande_chave`):**
   - $Key_0 == 0x4AF5$
   - $Key_1 == 0xDD28$
   - $Key_2 == 0x87AF$
2. **Criptografia de Bloco (`cifra_bloco`):**
   - `cifra_bloco(0xD728)` deve retornar exatamente `0x24EC`.
3. **Descriptografia de Bloco (`decifra_bloco`):**
   - `decifra_bloco(0x24EC)` deve retornar exatamente `0xD728`.

Se todos os asserts passarem, o programa imprime:
`>>> [SUCESSO TOTAL] O ALGORITMO S-AES ESTA 100% CORRETO! <<<`
e finaliza com Syscall 10 (código 0). Caso contrário, imprime falha com os valores divergentes.

### 2.3 Comando de Execução Unitária
```powershell
java -jar Mars4_5.jar nc sm tests/test_saes_vectors.asm
```

---

## 3. Nível 2: Testes de Integração com Arquivos

### 3.1 Arquivos e Parâmetros
Conforme o enunciado:
- Arquivos de entrada: `tests/data/texto1.txt` e `tests/data/texto2.txt`
- Chave de teste: `"ELC1011"`
- Arquivos cifrados gerados: `tests/data/secreto1.aes` e `tests/data/secreto2.aes`
- Arquivos decifrados gerados: `tests/data/teste1.txt` e `tests/data/teste2.txt`

### 3.2 Protocolo de Validação de Integridade
1. Criptografar `texto1.txt` usando a chave `"ELC1011"` $\rightarrow$ gera `secreto1.aes`.
2. Descriptografar `secreto1.aes` usando a chave `"ELC1011"` $\rightarrow$ gera `teste1.txt`.
3. Executar comparação byte a byte ou verificação de hash SHA-256:
   ```powershell
   $orig = [System.IO.File]::ReadAllBytes("tests/data/texto1.txt")
   $dec  = [System.IO.File]::ReadAllBytes("tests/data/teste1.txt")
   # Comparação byte a byte confirma restauração idêntica
   ```
4. Repetir o mesmo procedimento com `texto2.txt`.

---

## 4. Nível 3: Script de Automação (`tests/run_tests.ps1`)

O script PowerShell orquestrador realiza:
1. Montagem e execução dos testes unitários no MARS via CLI (`test_saes_vectors.asm`).
2. Execução do fluxo completo de `src/main.asm` passando as entradas via redirecionamento de entrada (`stdin`).
3. Validação byte a byte dos arquivos restaurados.
4. Emissão do relatório de execução com cores indicativas no console.
