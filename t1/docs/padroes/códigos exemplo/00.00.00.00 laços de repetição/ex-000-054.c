//*******************************************************************************
// ex-000-054.c              Copyright (C) 2022 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// Descrição: Exemplo de um código usando uma sentença com do-while. Neste exemplo,
//            a variável a é incrementada de 0 a 9.
//*******************************************************************************

 
int a;

int main(void)
{
    a = 0;              // inicializamos a variável a com o valor zero
    do{                 // início do laço do-while
        a = a + 1;      // incrementamos a variável a
    }while (a != 9 );   // repita o laço do-while enquanto a != 9
    return 0;           // termina o programa retornando 0
}
 
