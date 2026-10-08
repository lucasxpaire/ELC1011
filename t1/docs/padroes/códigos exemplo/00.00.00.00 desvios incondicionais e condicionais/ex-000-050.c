//*******************************************************************************
// ex-000-050.c                 Copyright (C) 2022 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// Descrição: Exemplo de um programa em C, com um desvio incondicional. Uma variável
//            a é incrementada em um laço infinito. A linha return 0 não deve ser
//            executada.
//*******************************************************************************
 
int a;

int main(void)
{
    a = 0;      // inicializamos a com 0
l0:             // inicio do laço infinito
    a = a + 1;  // incrementamos a
    goto l0;    // desvio incondicional para l0
    return 0;   // fim do programa. Esta instrução não é executada
}
 
