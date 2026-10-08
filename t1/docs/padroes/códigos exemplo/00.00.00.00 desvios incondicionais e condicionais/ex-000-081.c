//*******************************************************************************
// ex-000-081.c                Copyright (C) 2022 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// Descrição:
//*******************************************************************************

int a, b, c, d;

int main(void) {
  a = 0; // Atribuímos valores iniciais para as variáveis a, b, c e d
  b = 4;
  c = 7;
  d = 9;
  if ((a == 0) && ((b < 6) || (c >= 7))) { // se a condição é verdadeira
    d = 0;
  } else { // senão
    d = 1;
  }
  return 0; // termina o programa retornando 0
}
