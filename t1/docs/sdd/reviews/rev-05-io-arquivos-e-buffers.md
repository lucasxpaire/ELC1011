# Spec de Revisão 05: I/O de Arquivos, Buffers e Zero-Padding (file_io.asm)

- **Arquivo Auditado:** `src/file_io.asm`
- **Total de Linhas:** 245
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 4.1: Definição de Buffers e Mensagens de Erro

### Código Inspecionado
```mips
.data
.align 2
buffer_io:                  .space 512

msg_erro_abertura_entrada:  .asciiz "\n[ERRO] Falha ao abrir o arquivo de entrada para leitura!\n"
msg_erro_abertura_saida:    .asciiz "\n[ERRO] Falha ao criar/abrir o arquivo de saida para gravacao!\n"
msg_erro_gravacao:          .asciiz "\n[ERRO] Falha durante a gravacao dos dados no arquivo de saida!\n"
```

### Critérios de Auditoria e Verificação
1. **Alinhamento do Buffer:** `.align 2` alinha a palavra em múltiplo de 4 bytes, evitando qualquer desalinhamento ao transferir blocos de meia palavra ou palavra completa.
2. **Capacidade do Buffer:** 512 bytes. Permite ler arquivos de qualquer dimensão em múltiplos blocos contínuos de até 512 bytes, sem sobrecarregar a memória estática do simulador.

- **Veredito:** **[CONFORME]**

---

## Bloco 4.2: Abertura de Arquivos (Serviço 13) e Checagem de Erro

### Código Inspecionado
```mips
            # 1. Abertura do arquivo de entrada (leitura)
            li      $v0, 13             # serviço 13: abre arquivo
            move    $a0, $s4            # nome de entrada
            li      $a1, 0              # flag 0: somente leitura
            li      $a2, 0              # modo ignorado
            syscall
            bltz    $v0, erro_abertura_entrada
            move    $s0, $v0            # descritor de entrada

            # 2. Abertura/criação do arquivo de saída (escrita)
            li      $v0, 13
            move    $a0, $s5            # nome de saída
            li      $a1, 1              # flag 1: escrita com criação/truncamento
            li      $a2, 0
            syscall
            bltz    $v0, erro_abertura_saida
            move    $s1, $v0            # descritor de saída
```

### Critérios de Auditoria e Verificação
1. **Flags do MARS:** No MARS, a flag `0` abre para leitura (`O_RDONLY`) e a flag `1` abre para escrita com truncamento e criação (`O_WRONLY | O_CREAT | O_TRUNC`).
2. **Detecção de Falha:** O MARS retorna um descritor negativo (ex: `-1`) em caso de arquivo inexistente ou caminho inválido. A instrução `bltz $v0` captura o erro imediatamente.
3. **Prevenção de Vazamento de Descritores:** Se a abertura da saída falhar (`erro_abertura_saida`), o código fecha explicitamente o arquivo de entrada (`$s0`) antes de encerrar o procedimento.

- **Veredito:** **[CONFORME]**

---

## Bloco 4.3: Streaming de Buffer e Detecção de Fim de Arquivo (Serviço 14)

### Código Inspecionado
```mips
laco_leitura_buffer:
            li      $v0, 14             # serviço 14: leitura
            move    $a0, $s0            # descritor
            la      $a1, buffer_io      # buffer de destino
            li      $a2, 512            # tamanho máximo
            syscall

            blez    $v0, fim_processamento # se bytes lidos <= 0, encerra o fluxo
            move    $s6, $v0            # $s6 <- bytes lidos
```

### Critérios de Auditoria e Verificação
1. **Condição de Parada (EOF):** O serviço 14 retorna `0` ao atingir o fim do arquivo, ou valor negativo em caso de falha de leitura. A instrução `blez $v0` trata ambos os cenários com segurança.
2. **Suporte a Arquivos Grandes:** O laço permite processar arquivos arbitrariamente maiores que 512 bytes em múltiplas iterações contínuas até esgotar o conteúdo do arquivo.

- **Veredito:** **[CONFORME]**

---

## Bloco 4.4: Preenchimento de Bytes Ímpares (*Zero-Padding*)

### Código Inspecionado
```mips
            # Ajuste de preenchimento (padding) em caso de tamanho ímpar na cifra
            bne     $s3, 1, sem_ajuste_padding # se não for cifra, não ajusta padding
            andi    $t0, $s6, 1         # testa se a contagem é ímpar (bit 0 == 1)
            beqz    $t0, sem_ajuste_padding

            # Preenche o último byte com zero (zero-padding)
            la      $t1, buffer_io      # endereço base
            addu    $t1, $t1, $s6       # endereço do byte excedente
            sb      $zero, 0($t1)       # armazena 0x00 para fechar bloco de 16 bits
            addi    $s6, $s6, 1         # incrementa a contagem de bytes
sem_ajuste_padding:
```

### Critérios de Auditoria e Verificação
1. **Requisito Criptográfico (Q02-padding-arquivos-impares):**
   - O S-AES opera estritamente em blocos de 16 bits (2 bytes).
   - Se um arquivo de texto possuir número ímpar de bytes (por exemplo, `texto1.txt` com 111 bytes), o último byte não fecharia um bloco.
2. **Lógica de Aplicação:**
   - O preenchimento com zero (`0x00`) é realizado exclusivamente no modo de cifra (`$s3 == 1`).
   - Se a contagem for ímpar (`andi $t0, $s6, 1`), o código grava `0x00` na posição excedente e ajusta a contagem (`$s6 + 1`), garantindo que todos os blocos sejam de 16 bits.
   - Na decifra, o arquivo cifrado resultante já possui dimensão par (112 bytes).

- **Veredito:** **[CONFORME]**

---

## Bloco 4.5: Laço de Processamento de Blocos de 16 bits

### Código Inspecionado
```mips
            li      $s7, 0              # índice no buffer = 0

laco_processa_blocos:
            bge     $s7, $s6, grava_buffer_disco

            la      $t0, buffer_io
            addu    $t0, $t0, $s7       # endereço do bloco atual

            lbu     $t1, 0($t0)         # byte alto (bits 15..8)
            lbu     $t2, 1($t0)         # byte baixo (bits 7..0)
            sll     $a0, $t1, 8
            or      $a0, $a0, $t2       # $a0 <- bloco de 16 bits montado

            move    $a1, $s2            # $a1 <- endereço das subchaves

            beq     $s3, 2, chama_decifra
            jal     cifra_bloco
            j       armazena_bloco_processado

chama_decifra:
            jal     decifra_bloco

armazena_bloco_processado:
            la      $t0, buffer_io
            addu    $t0, $t0, $s7

            srl     $t1, $v0, 8
            andi    $t1, $t1, 0xFF
            sb      $t1, 0($t0)         # grava byte alto transformado

            andi    $t2, $v0, 0xFF
            sb      $t2, 1($t0)         # grava byte baixo transformado

            addi    $s7, $s7, 2         # avança 2 bytes (1 bloco)
            j       laco_processa_blocos
```

### Critérios de Auditoria e Verificação
1. **Endianness e Montagem de Blocos:**
   - Big-endian lógico: primeiro byte do arquivo $\to$ bits 15..8; segundo byte $\to$ bits 7..0.
   - Após a cifra/decifra, os bytes são reescritos no buffer na mesma ordem, preservando a compatibilidade de formato.
2. **Avanço de Índice:** Avança estritamente de 2 em 2 bytes (`addi $s7, $s7, 2`), conferido contra o total `$s6`.

- **Veredito:** **[CONFORME]**

---

## Bloco 4.6: Gravação em Disco (Serviço 15) e Fechamento (Serviço 16)

### Código Inspecionado
```mips
grava_buffer_disco:
            li      $v0, 15             # serviço 15: escreve em arquivo
            move    $a0, $s1            # descritor de saída
            la      $a1, buffer_io      # dados
            move    $a2, $s6            # tamanho a gravar
            syscall
            bltz    $v0, erro_gravacao

            j       laco_leitura_buffer # próximo buffer

fim_processamento:
            li      $v0, 16             # fecha arquivo
            move    $a0, $s0
            syscall

            li      $v0, 16
            move    $a0, $s1
            syscall

            li      $v0, 0              # código 0: sucesso
            j       epilogo_arquivo
```

### Critérios de Auditoria e Verificação
1. **Validação da Escrita:** Se o serviço 15 retornar valor negativo (`bltz $v0`), aborta desviando para `erro_gravacao`, fechando ambos os descritores e emitindo diagnóstico.
2. **Fechamento Completo:** Em encerramento normal com sucesso, ambos os descritores (`$s0` e `$s1`) são fechados via serviço 16, garantindo a descarga (*flush*) dos dados pelo sistema operacional.

- **Veredito:** **[CONFORME]**

---

## Bloco 4.7: Gerenciamento da Pilha e ABI

### Código Inspecionado
```mips
# Prólogo:
addi    $sp, $sp, -40
sw      $ra, 36($sp)
sw      $s0, 32($sp)
sw      $s1, 28($sp)
sw      $s2, 24($sp)
sw      $s3, 20($sp)
sw      $s4, 16($sp)
sw      $s5, 12($sp)
sw      $s6, 8($sp)
sw      $s7, 4($sp)

# Epílogo:
lw      $s7, 4($sp)
lw      $s6, 8($sp)
lw      $s5, 12($sp)
lw      $s4, 16($sp)
lw      $s3, 20($sp)
lw      $s2, 24($sp)
lw      $s1, 28($sp)
lw      $s0, 32($sp)
lw      $ra, 36($sp)
addi    $sp, $sp, 40
jr      $ra
```

### Critérios de Auditoria e Verificação
1. **Alocação e Desalocação:** 40 bytes alocados no prólogo (`addi $sp, $sp, -40`) e exatamente 40 bytes liberados no epílogo (`addi $sp, $sp, 40`).
2. **Preservação de Todos os Registradores Callee-Saved:** Todos os registradores `$s0` a `$s7` utilizados no procedimento são salvos e restaurados em seus respectivos slots de pilha. `$ra` é preservado, permitindo retorno perfeito ao chamador.

- **Veredito:** **[CONFORME]**
