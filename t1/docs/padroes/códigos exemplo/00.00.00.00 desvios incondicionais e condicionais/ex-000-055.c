//*******************************************************************************
// ex-000-055.c               Copyright (C) 2022 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// Descrição: Exemplo de um código usando uma sentença com switch-case. 
//            Neste exemplo, se a tem um valor entre 0 e 3, o valor de a
//            é modificado para os valores 10, 20 , 30 e 40, respectivamente.
//*******************************************************************************

 
int a;

int main(void)
{
    a = 2;              // colocamos em a um valor para teste
    switch (a){         // selecionamos um case, usando o valor de a
        case 0:         // se a = 0
            a = 10;     // fazemos a = 10
            break;      // saímos da estrutura switch-case
        case 1:         // se a = 1 
            a = 20;     // fazemos a = 20
            break;      // saímos da estrutura switch-case
        case 2:         // se a = 2
            a = 30;     // fazemos a = 30
            break;      // saímos da estrutura switch-case
        case 3:         // se a = 3
            a = 40;     // fazemos a = 40
            break;      // saímos da estrutura switch-case
    }                   // fim da construção switch-case
    return 0;           // termina o programa retornando 0
}
 
