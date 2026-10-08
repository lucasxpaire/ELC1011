//*******************************************************************************
// exercicio0.c                 Copyright (C) 2018 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// versão: 0.1
// Descrição:
// Documentação:
// Assembler: MARS
// Revisões:
// Rev #  Data           Nome   Comentários
// 0.1    12.04.2017     GBTO   versão inicial
//*******************************************************************************
//       1         2         3         4         5         6         7         8
// 345678901234567890123456789012345678901234567890123456789012345678901234567890

/**
 * @file ex-000-084.c
 * @author Giovani Baratto (Giovani.Baratto@ufsm.br)
 * @brief Imprimimos uma string entrada pelo fluxo stdin. A string é apresentada
 * entre aspas duplas. O caractere '\n', se houver, é removido da string.
 * @version 0.1
 * @date 2022-07-01
 *
 * @copyright Copyright (c) 2022
 *
 */
#include <stdio.h>

/**
 * @brief Removemos o caractere '\n' da string buffer. O caractere '\n', se
 * houver, é substituído com o '\0', marcando o final da string.
 *
 * @param buffer ponteiro da string.
 */
void remove_nova_linha(char *buffer) {
  char ch;
  while ((ch = *buffer) != '\0') {
    if (ch == '\n') {
      *buffer = '\0';
      break;
    }
    buffer++;
  }
}

/**
 * @brief Imprimimos uma string entrada pelo fluxo stdin. O caractere '\n', se
 * houver, é removido da string.
 *
 * @return int retorna 0 se o programa foi executado sem erros
 */
int main(void) {
  char buffer[8];
  printf("Entre com uma string: ");
  fgets(buffer, sizeof(buffer), stdin);
  remove_nova_linha(buffer);
  printf("\"%s\"\n", buffer);

  return 0;
}
