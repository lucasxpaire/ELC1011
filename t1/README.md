# ELC1011 - Trabalho 1: Criptografia S-AES em MIPS

**Disciplina:** ELC1011 Organização de Computadores (UFSM)  
**Professor:** Giovani Baratto  
**Alunos:** Lucas Xavier Pairé e Miguel Brondani  

---

## Estrutura do Arquivo de Entrega (.zip)

O arquivo compactado `.zip` para envio no Moodle deve conter:

1. **`relatorio.pdf`**: Relatório técnico em PDF (gerado a partir de `docs/relatorio.tex` no Overleaf).
2. **`Mars4_5.jar`**: Simulador MARS 4.5 para execução dos arquivos.
3. **`src/`**: Todos os arquivos de código-fonte Assembly comentados:
   * `main.asm` (Interface de terminal e menu interativo)
   * `file_io.asm` (Processamento de arquivos e buffers)
   * `saes.asm` (Algoritmo e transformações do S-AES)
   * `saes_tables.asm` (Tabelas estáticas S-Box e multiplicação em GF(16))
   * `utils.asm` (Sanitização de strings e derivação da chave por XOR)
4. **`tests/`**: Arquivos de teste e dados de validação (excluindo apenas o script `run_tests.ps1`):
   * `test_saes_vectors.asm` (Teste unitário com vetores oficiais de Steven Gordon e William Stallings)
   * `data/texto1.txt` (Arquivo de teste 1 fornecido)
   * `data/texto2.txt` (Arquivo de teste 2 fornecido)
   * `data/secreto1.aes` (Cifrado com a chave `ELC1011`)
   * `data/secreto2.aes` (Cifrado com a chave `ELC1011`)
   * `data/teste1.txt` (Descriptografado para conferência de integridade)
   * `data/teste2.txt` (Descriptografado para conferência de integridade)

> **Nota:** O script `run_tests.ps1` é utilizado apenas localmente para automação dos testes e **não** deve ser incluído no `.zip` final.

---

## Estrutura de Diretórios no .zip

```text
trabalho1.zip
├── relatorio.pdf
├── Mars4_5.jar
├── src/
│   ├── file_io.asm
│   ├── main.asm
│   ├── saes.asm
│   ├── saes_tables.asm
│   └── utils.asm
└── tests/
    ├── test_saes_vectors.asm
    └── data/
        ├── secreto1.aes
        ├── secreto2.aes
        ├── teste1.txt
        ├── teste2.txt
        ├── texto1.txt
        └── texto2.txt
```

---

## Como Executar no MARS

### 1. Interface Gráfica
1. Abra o `Mars4_5.jar`.
2. Em **Settings**, marque a opção **Initialize Program Counter to global 'main' if defined** (ou abra diretamente `src/main.asm`).
3. Monte o programa (**F3**) e execute (**F5**).
4. Utilize o menu no terminal integrado do MARS:
   * Opção `1`: Criptografar arquivo.
   * Opção `2`: Descriptografar arquivo.
   * Opção `0`: Encerrar.

### 2. Linha de Comando (CLI)
Para executar diretamente via terminal sem interface:
```bash
java -jar Mars4_5.jar nc sm src/main.asm
```

Para rodar o teste unitário dos vetores do S-AES:
```bash
java -jar Mars4_5.jar nc sm tests/test_saes_vectors.asm
```
