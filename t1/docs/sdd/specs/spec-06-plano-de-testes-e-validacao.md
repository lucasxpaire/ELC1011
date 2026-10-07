# Spec-06: Plano de Testes, Validação e Automação

## 1. Visão Geral
Esta especificação descreve a estratégia de garantia de qualidade (QA) para o sistema criptográfico S-AES, dividida em **Testes Unitários de Algoritmo** e **Testes de Integração de Arquivos**, com automação via linha de comando no simulador **MARS 4.5**.

---

## 2. Nível 1: Testes Unitários do Motor S-AES (`tests/test_saes_vectors.asm`)

### 2.1 Cenário de Teste Padrão (Vetor de Steven Gordon)
Baseado no documento oficial [docs/simplified-aes-example.pdf](../simplified-aes-example.pdf):
- **Entrada (Texto Claro):** `0xD728` (`1101 0111 0010 1000_2`)
- **Chave Mestre:** `0x4AF5` (`0100 1010 1111 0101_2`)

### 2.2 Critérios de Sucesso (Asserts em Assembly)
1. **Subchaves Geradas:**
   - $Key_0 == 0x4AF5$
   - $Key_1 == 0xDD28$
   - $Key_2 == 0x87AF$
2. **Criptografia de Bloco:**
   - `saes_encrypt_block(0xD728)` deve retornar exatamente `0x24EC`.
3. **Descriptografia de Bloco:**
   - `saes_decrypt_block(0x24EC)` deve retornar exatamente `0xD728`.

Se todos os asserts passarem, o programa imprime:
`[OK] TODOS OS TESTES UNITARIOS DO S-AES PASSARAM COM SUCESSO!`
e finaliza com Syscall 10 (código 0). Caso contrário, imprime falha com os valores divergentes.

### 2.3 Comando de Execução Unitária
```powershell
java -jar Mars4_5.jar nc sm tests/test_saes_vectors.asm
```

---

## 3. Nível 2: Testes de Integração com Arquivos

### 3.1 Arquivos e Parâmetros
Conforme o enunciado:
- Arquivos de entrada: `texto1.txt` e `texto2.txt`
- Chave de teste: `"ELC1011"`
- Arquivos cifrados esperados: `secreto1.aes` e `secreto2.aes`
- Arquivos decifrados esperados: `teste1.txt` e `teste2.txt`

### 3.2 Protocolo de Validação de Integridade
1. Criptografar `texto1.txt` usando a chave `"ELC1011"` $\rightarrow$ gera `secreto1.aes`.
2. Descriptografar `secreto1.aes` usando a chave `"ELC1011"` $\rightarrow$ gera `teste1.txt`.
3. Executar verificação de hash SHA-256 ou comparação binária:
   ```powershell
   $h1 = (Get-FileHash -Algorithm SHA256 texto1.txt).Hash
   $h2 = (Get-FileHash -Algorithm SHA256 teste1.txt).Hash
   if ($h1 -eq $h2) {
       Write-Host "Integridade Perfeita: texto1.txt == teste1.txt" -ForegroundColor Green
   } else {
       Write-Host "FALHA DE INTEGRIDADE!" -ForegroundColor Red
   }
   ```
4. Repetir o mesmo procedimento com `texto2.txt`.

---

## 4. Nível 3: Script de Automação (`tests/run_tests.ps1`)

Um script PowerShell orquestrador que:
1. Monta e executa os testes unitários no MARS via CLI.
2. Gera arquivos de teste sintéticos com conteúdo ASCII diversificado (caso os arquivos do professor ainda não estejam no diretório).
3. Executa o fluxo completo do `main.asm` passando as entradas via redirecionamento de entrada (`stdin`).
4. Valida as assinaturas criptográficas e emite o relatório de teste.
