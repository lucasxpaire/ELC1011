//*******************************************************************************
// ex-000-051.c                Copyright (C) 2022 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// Descrição: Exemplo de um código usando uma sentença com if. Neste exemplo,
//            a variável a é incrementada de 0 a 9.
//*******************************************************************************
 
int a;

int main(void)
{
    a = 0;              // inicializamos a variável a com zero
l0:                     // inicio das instruções quando a != 0
    a = a + 1;          // incrementamos a
    if(a == 9) goto l1; // se a = 9 então desvie para l1
    goto l0;            // salto incondicional para l0
l1:                     // 
    return 0;           // termina o programa retornando 0
}
 
