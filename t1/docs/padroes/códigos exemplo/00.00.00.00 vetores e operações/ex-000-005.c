// Declaração das variáveis globais
int variavel_I;
int variavel_J;
int variavel_K;

// Declaração do vetor global com 10 inteiros
int vetorA[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

/* 
   Este trecho de código será traduzido para assembly.
   Ele realiza as seguintes operações:
   - Atribui valores às variáveis `variavel_I`, `variavel_J` e `variavel_K`.
   - Utiliza os valores dessas variáveis como índices para acessar elementos do vetor `vetorA`.
   - Calcula a soma dos elementos de `vetorA` nos índices especificados por `variavel_I` e `variavel_J`.
   - Armazena o resultado da soma no índice especificado por `variavel_K` no vetor `vetorA`.
*/

// Atribuição de valores às variáveis
variavel_I = 1; 
variavel_J = 2;
variavel_K = 0;
// operação de soma de 2 elementos do vetor e atribuição do resultado a outro elemento. 
// Usamos as variáveis como índice do vetor.
vetorA[variavel_K] = vetorA[variavel_I] + vetorA[variavel_J]

/* 
... 
*/
