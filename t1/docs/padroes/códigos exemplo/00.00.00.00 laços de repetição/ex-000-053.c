//*******************************************************************************
// ex-000-053.c                Copyright (C) 2022 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// Descrição: Exemplo de um código usando uma sentença com while. Neste exemplo,
//            a variável a é incrementada de 0 a 9.
//*******************************************************************************
 
int a;

int main(void)
{
    a = 0;              // inicializamos a variável a com o valor zero
    while (a != 9){     // enquanto a variável a é diferente de 9, faça
        a = a + 1;      // incremente a variável a
    }                   // 
    return 0;           // termina o programa retornando 0
}
 
