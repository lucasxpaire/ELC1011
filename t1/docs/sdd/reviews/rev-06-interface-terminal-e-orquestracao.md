# Spec de Revisão 06: Interface de Terminal e Orquestração (main.asm)

- **Arquivo Auditado:** `src/main.asm`
- **Total de Linhas:** 270
- **Status Geral:** **[CONFORME - 100%]**

---

## Bloco 5.1: Buffers Estáticos e Mensagens de Texto (.data)

### Código Inspecionado
```mips
.data
.align 2
buffer_nome_entrada:    .space 128
buffer_nome_saida:      .space 128
buffer_chave:           .space 64
buffer_opcao:           .space 16

msg_banner:
    .asciiz "\n=========================================================\n       ELC1011 - Criptografia de Arquivos S-AES\n       Autores: Lucas Xavier Pairé e Miguel Brondani\n=========================================================\n"

msg_menu:
    .asciiz "\nSelecione a operacao desejada:\n  (1) Criptografar arquivo\n  (2) Descriptografar arquivo\n  (0) Encerrar programa\nEscolha: "
```

### Critérios de Auditoria e Verificação
1. **Dimensionamento de Memória:**
   - 128 bytes para nomes de arquivo: comporta caminhos relativos ou absolutos longos (ex: `tests/data/texto1.txt`).
   - 64 bytes para a senha: mais que suficiente para senhas típicas (ex: `"ELC1011"`).
   - 16 bytes para a opção: lê com folga a escolha do menu.
2. **Textos:** Todas as strings terminadas em nulo com `.asciiz` e alinhamento de 4 bytes (`.align 2`).

- **Veredito:** **[CONFORME]**

---

## Bloco 5.2: Menu Principal e Leitura de Opções

### Código Inspecionado
```mips
laco_menu_principal:
            li      $v0, 4
            la      $a0, msg_menu
            syscall

            li      $v0, 8              # serviço 8: lê string do teclado
            la      $a0, buffer_opcao
            li      $a1, 16
            syscall

            la      $t0, buffer_opcao
            lbu     $t1, 0($t0)         # examina primeiro caractere

            li      $t2, '0'
            beq     $t1, $t2, executa_encerramento

            li      $t2, '1'
            beq     $t1, $t2, executa_criptografia

            li      $t2, '2'
            beq     $t1, $t2, executa_descriptografia

            # Opção Inválida
            li      $v0, 4
            la      $a0, msg_opcao_invalida
            syscall
            j       laco_menu_principal
```

### Critérios de Auditoria e Verificação
1. **Robustez na Entrada:** O uso do serviço 8 (leitura de string) em vez do serviço 5 (leitura de inteiro) previne quebras catastróficas (*crashes*) do MARS se o usuário digitar letras ou pressionar Enter acidentalmente.
2. **Tratamento de Caractere:** Examina o primeiro byte não nulo (`$t1`), comparando com `'0'`, `'1'` e `'2'`.
3. **Resiliência:** Em caso de entrada inválida, exibe mensagem informativa amigável e retorna ao menu sem abortar a execução.

- **Veredito:** **[CONFORME]**

---

## Bloco 5.3: Fluxo de Criptografia (Opção 1)

### Código Inspecionado
```mips
executa_criptografia:
            # 1. Pede nome de entrada
            li      $v0, 4
            la      $a0, msg_pede_entrada_cifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_entrada
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_entrada
            jal     remove_quebra_linha

            # 2. Pede nome de saída
            li      $v0, 4
            la      $a0, msg_pede_saida_cifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_saida
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_saida
            jal     remove_quebra_linha

            # 3. Pede chave de acesso (sem máscara, leitura padrão)
            li      $v0, 4
            la      $a0, msg_pede_chave
            syscall
            li      $v0, 8
            la      $a0, buffer_chave
            li      $a1, 64
            syscall
            la      $a0, buffer_chave
            jal     remove_quebra_linha

            # 4. Deriva e expande
            la      $a0, buffer_chave
            jal     deriva_chave
            move    $a0, $v0
            la      $a1, subchaves
            jal     expande_chave

            # 5. Processa arquivo
            la      $a0, buffer_nome_entrada
            la      $a1, buffer_nome_saida
            la      $a2, subchaves
            li      $a3, 1              # modo 1 = Cifra
            jal     processa_arquivo

            bnez    $v0, falha_criptografia
            li      $v0, 4
            la      $a0, msg_sucesso_cifra
            syscall
            j       laco_menu_principal
```

### Critérios de Auditoria e Verificação
1. **Requisito Obrigatório 1 (Nomes de Arquivo):** Solicita arquivo de entrada (texto claro) e arquivo de saída (texto cifrado).
2. **Requisito Obrigatório 2 (Senha):** Solicita chave de acesso e lê diretamente via serviço 8, atendendo à dispensa da máscara de asteriscos autorizada pelo professor.
3. **Sanitização de Strings:** Aplica `remove_quebra_linha` imediatamente após cada chamada ao serviço 8.
4. **Cadeia de Chamadas:** Executa na ordem estrita: `deriva_chave` $\to$ `expande_chave` $\to$ `processa_arquivo`.
5. **Retorno ao Menu:** Após o término com sucesso ou falha, o fluxo retorna ao menu principal.

- **Veredito:** **[CONFORME]**

---

## Bloco 5.4: Fluxo de Descriptografia (Opção 2)

### Código Inspecionado
```mips
executa_descriptografia:
            # 1. Entrada (cifrado)
            li      $v0, 4
            la      $a0, msg_pede_entrada_decifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_entrada
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_entrada
            jal     remove_quebra_linha

            # 2. Saída (decifrado)
            li      $v0, 4
            la      $a0, msg_pede_saida_decifra
            syscall
            li      $v0, 8
            la      $a0, buffer_nome_saida
            li      $a1, 128
            syscall
            la      $a0, buffer_nome_saida
            jal     remove_quebra_linha

            # 3. Senha
            li      $v0, 4
            la      $a0, msg_pede_chave
            syscall
            li      $v0, 8
            la      $a0, buffer_chave
            li      $a1, 64
            syscall
            la      $a0, buffer_chave
            jal     remove_quebra_linha

            # 4. Derivação e expansão
            la      $a0, buffer_chave
            jal     deriva_chave
            move    $a0, $v0
            la      $a1, subchaves
            jal     expande_chave

            # 5. Processamento em modo 2 (Decifra)
            la      $a0, buffer_nome_entrada
            la      $a1, buffer_nome_saida
            la      $a2, subchaves
            li      $a3, 2              # modo 2 = Decifra
            jal     processa_arquivo

            bnez    $v0, falha_descriptografia
            li      $v0, 4
            la      $a0, msg_sucesso_decifra
            syscall
            j       laco_menu_principal
```

### Critérios de Auditoria e Verificação
1. **Requisito Obrigatório (Interface de Decifra):** Solicita nome do arquivo cifrado e nome do arquivo de saída (decifrado).
2. **Passagem de Parâmetros:** Passa `$a3 = 2` para `processa_arquivo`, instruindo a decodificação dos blocos através de `decifra_bloco`.
3. **Tratamento de Falha:** Desvia para `falha_descriptografia` se `processa_arquivo` retornar código negativo.

- **Veredito:** **[CONFORME]**

---

## Bloco 5.5: Encerramento e Modularização (.include)

### Código Inspecionado
```mips
executa_encerramento:
            li      $v0, 4
            la      $a0, msg_despedida
            syscall

            li      $v0, 10             # serviço 10: encerra programa
            syscall

# Inclusão dos Módulos Especializados
.include "saes_tables.asm"
.include "saes.asm"
.include "utils.asm"
.include "file_io.asm"
```

### Critérios de Auditoria e Verificação
1. **Terminação Segura:** Encerra graciosamente através do serviço 10 (`exit`), sem cair em instruções posteriores.
2. **Inclusão Direta:** As diretivas `.include` incluem todos os 4 módulos necessários. Isso permite que qualquer pessoa (incluindo o professor) abra diretamente o arquivo `src/main.asm` no MARS 4.5 e clique em *Assemble and Run* sem qualquer configuração adicional de múltiplos arquivos.

- **Veredito:** **[CONFORME]**
