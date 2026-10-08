# Spec-04: I/O de Arquivos e Streaming por Buffer

## 1. Visão Geral
Esta especificação define o subsistema de entrada e saída em disco implementado no módulo [src/file_io.asm](../../src/file_io.asm). Ele é responsável por ler os arquivos de entrada, processar os dados em fluxo contínuo através de buffers e gravar os arquivos resultantes utilizando as chamadas de sistema (**Syscalls**) do simulador **MARS 4.5**, conforme diretrizes da [Spec-07](spec-07-padroes-de-codificacao-e-estilo.md).

---

## 2. Syscalls do Simulador MARS Utilizadas

| Syscall | Código (`$v0`) | Argumentos (`$a0-$a2`) | Retorno (`$v0`) | Descrição |
| :--- | :-: | :--- | :--- | :--- |
| **Open File** | `13` | `$a0` = Caminho do arquivo (string terminada em zero)<br>`$a1` = Flags (`0` = Leitura, `1` = Escrita com criação/truncamento)<br>`$a2` = Modo (`0`) | Descritor do arquivo (`>= 0`) ou negativo em caso de erro | Abre ou cria o arquivo no sistema de arquivos do host. |
| **Read File** | `14` | `$a0` = Descritor do arquivo<br>`$a1` = Endereço do buffer em memória<br>`$a2` = Número máximo de bytes a ler | Número de bytes efetivamente lidos (`0` = EOF, `< 0` = erro) | Lê blocos de dados do arquivo para a memória. |
| **Write File** | `15` | `$a0` = Descritor do arquivo<br>`$a1` = Endereço do buffer com os dados<br>`$a2` = Número de bytes a gravar | Número de bytes gravados (`< 0` = erro) | Grava dados da memória no arquivo de saída. |
| **Close File** | `16` | `$a0` = Descritor do arquivo | Nenhum | Fecha o descritor e libera os recursos do sistema operacional. |

---

## 3. Arquitetura de Streaming por Buffer (Chunking)

Para evitar problemas comuns em Assembly MIPS (como tentar carregar o arquivo inteiro de uma só vez), o sistema adota **processamento em fluxo por blocos**:

- **Tamanho do Buffer:** 512 bytes (256 blocos de 16 bits por iteração).
- **Buffer de Trabalho:** Alocado na seção `.data`:
  ```mips
  .data
  .align 2
  buffer_io: .space 512
  ```

### 3.1 Procedimento `processa_arquivo`
- **Entrada:**
  - `$a0`: Endereço da string do nome do arquivo de entrada.
  - `$a1`: Endereço da string do nome do arquivo de saída.
  - `$a2`: Modo de operação (`1` para criptografar, `2` para descriptografar).
- **Retorno:**
  - `$v0`: `0` em caso de sucesso, `-1` ou `-2` em caso de erro de abertura de arquivo.

### 3.2 Fluxo do Laço de Processamento
1. Abre o arquivo de entrada (`$a1 = 0`). Se erro (`$v0 < 0`), retorna `-1`.
2. Abre/cria o arquivo de saída (`$a1 = 1`). Se erro, fecha o arquivo de entrada e retorna `-2`.
3. **Laço de Streaming (`laco_leitura`):**
   - Invoca Syscall 14 solicitando a leitura de até 512 bytes para `buffer_io`.
   - Se bytes lidos $\le 0$, encerra o laço (`fim_leitura`).
   - Se o modo for **Criptografia** e a quantidade de bytes lidos for ímpar:
     - Adiciona byte nulo `0x00` no byte seguinte para fechar o alinhamento de 16 bits (ver [Q02](../questions/Q02-padding-arquivos-impares.md)).
     - Incrementa a contagem de bytes em 1 (`ajusta_impar`).
   - Itera sobre o buffer de 2 em 2 bytes (`laco_processa_blocos`):
     - Carrega 16 bits: `byte_alto = buffer[i]`, `byte_baixo = buffer[i+1]`, compondo `(byte_alto << 8) | byte_baixo`.
     - Invoca `cifra_bloco` ou `decifra_bloco`.
     - Escreve os 16 bits resultantes de volta no `buffer_io`.
   - Invoca Syscall 15 para gravar a quantidade processada no arquivo de saída.
4. Ao final da leitura, fecha ambos os descritores via Syscall 16.
5. Retorna status de sucesso (`$v0 = 0`) para a interface principal.

---

## 4. Tratamento de Erros de I/O
O módulo intercepta e trata os seguintes cenários de falha:
- **Arquivo de entrada não encontrado / sem permissão:** `$v0 < 0` na abertura. Retorna `-1`.
- **Falha na criação do arquivo de saída:** Impossibilidade de escrita no diretório. Retorna `-2`.
- **Encerramento seguro:** Fecha os descritores abertos antes de retornar código de erro para evitar descritores órfãos no host.
