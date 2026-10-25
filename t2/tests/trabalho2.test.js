import test from 'node:test';
import assert from 'node:assert/strict';
import { execSync } from 'node:child_process';
import { readFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..', '..');
const marsJar = path.join(rootDir, 't2', 'Mars4_5.jar');
const q1Asm = path.join(rootDir, 't2', 'src', 'q1.asm');
const padroesDoc = path.join(rootDir, 't2', 'docs', 'padroes_codificacao.md');

// Funções auxiliares para manipulação de ponto fixo Q7.4 (11 bits com sinal)
function toSignedQ74(val11Bits) {
  if (val11Bits & (1 << 10)) {
    return (val11Bits - 2048) / 16;
  }
  return val11Bits / 16;
}

function formatQ74Binary(val11Bits) {
  const bin = (val11Bits & 0x7ff).toString(2).padStart(11, '0');
  return `${bin.slice(0, 7)}.${bin.slice(7)}`;
}

// -----------------------------------------------------------------------------
// Testes da Feature 1: t2-parte-01
// -----------------------------------------------------------------------------
test('Alocação de variáveis globais e locais e conformidade com o simulador MARS @spec:AC-001', () => {
  const cmd = `java -jar "${marsJar}" nc sm "${q1Asm}"`;
  const output = execSync(cmd, { cwd: rootDir, encoding: 'utf-8' });
  assert.ok(output, 'A execução no simulador MARS deve gerar saída.');
  assert.match(output, /O resultado e/i, 'A execução deve concluir sem lançar exceções no MARS.');
});

test('Retorno correto da função media3x2y e impressão simplificada @spec:AC-002', () => {
  const cmd = `java -jar "${marsJar}" nc sm "${q1Asm}"`;
  const output = execSync(cmd, { cwd: rootDir, encoding: 'utf-8' });
  const trimmed = output.trim();
  assert.equal(trimmed, 'O resultado e 17', 'A rotina de impressão deve imprimir "O resultado e 17".');
});

test('Conversão e representação de A e B em ponto fixo com sinal @spec:AC-003', () => {
  const bVal = (10 << 4) | 4; // 164
  assert.equal(formatQ74Binary(bVal), '0001010.0100');
  assert.equal(toSignedQ74(bVal), 10.25);

  const aMag = (27 << 4) | 4; // 436
  const aVal = (2048 - aMag) & 0x7ff; // 1612
  assert.equal(formatQ74Binary(aVal), '1100100.1100');
  assert.equal(toSignedQ74(aVal), -27.25);
});

test('Subtração D = A - B com tabela de vem-uns e análise de overflow @spec:AC-004', () => {
  const aVal = 1612;
  const bVal = 164;
  const negB = (2048 - bVal) & 0x7ff;

  assert.equal(formatQ74Binary(negB), '1110101.1100');

  const carries = new Array(12).fill(0);
  let c = 0;
  for (let i = 0; i < 11; i++) {
    const bitA = (aVal >> i) & 1;
    const bitNegB = (negB >> i) & 1;
    const sum = bitA + bitNegB + c;
    c = sum >> 1;
    carries[i + 1] = c;
  }

  const dVal = (aVal + negB) & 0x7ff;
  assert.equal(formatQ74Binary(dVal), '1011010.1000');
  assert.equal(toSignedQ74(dVal), -37.5);

  const cInSign = carries[10];
  const cOutSign = carries[11];
  assert.equal(cInSign, 1, 'Carry que entra no bit de sinal deve ser 1.');
  assert.equal(cOutSign, 1, 'Carry que sai do bit de sinal deve ser 1.');
  const overflow = cInSign !== cOutSign;
  assert.equal(overflow, false, 'Não deve haver overflow.');
});

test('Soma E = D + B e análise de igualdade com A @spec:AC-005', () => {
  const dVal = 1448;
  const bVal = 164;
  const aVal = 1612;

  const eVal = (dVal + bVal) & 0x7ff;
  assert.equal(eVal, aVal, 'O valor binário de E deve ser idêntico ao valor de máquina de A.');
  assert.equal(formatQ74Binary(eVal), '1100100.1100');
  assert.equal(toSignedQ74(eVal), -27.25);

  const valorOriginal = -27.3;
  const erroTruncamento = Math.abs(toSignedQ74(eVal) - valorOriginal);
  assert.ok(Math.abs(erroTruncamento - 0.05) < 1e-6, 'A diferença entre E e o decimal original A decorre do erro de truncamento de 0.05.');
});

// -----------------------------------------------------------------------------
// Testes da Feature 2: t2-padroes-codigo
// -----------------------------------------------------------------------------
test('Guia formal de padrões de codificação do T2 @spec:AC-006', () => {
  assert.ok(existsSync(padroesDoc), 'O arquivo t2/docs/padroes_codificacao.md deve existir.');
  const content = readFileSync(padroesDoc, 'utf-8');

  assert.match(content, /Lucas Xavier Pairé/i, 'Deve identificar o autor Lucas Xavier Pairé.');
  assert.doesNotMatch(content, /Miguel Brondani/i, 'Não deve conter o nome Miguel Brondani.');
  assert.match(content, /snake_case/i, 'Deve estipular a convenção snake_case.');
  assert.match(content, /# prologo/i, 'Deve especificar a seção # prologo.');
  assert.match(content, /# corpo do procedimento/i, 'Deve especificar a seção # corpo do procedimento.');
  assert.match(content, /# epilogo/i, 'Deve especificar a seção # epilogo.');
  assert.match(content, /<-/, 'Deve estipular a notação de comentários com seta.');
});

test('Conformidade estilística e estrutural de q1.asm @spec:AC-007', () => {
  assert.ok(existsSync(q1Asm), 'O arquivo t2/src/q1.asm deve existir.');
  const content = readFileSync(q1Asm, 'utf-8');

  assert.match(content, /Autor:\s*Lucas Xavier Pairé/i, 'O cabeçalho deve conter apenas Lucas Xavier Pairé.');
  assert.doesNotMatch(content, /Miguel Brondani/i, 'Não deve conter o nome Miguel Brondani.');
  assert.doesNotMatch(content, /#\/\*|int main\s*\(/i, 'Não deve conter blocos de código C comentados.');
  assert.doesNotMatch(content, /\+-------|\+===/i, 'Não deve conter molduras decorativas ASCII.');
  assert.match(content, /# prologo/i, 'Deve conter a seção explícita # prologo.');
  assert.match(content, /# corpo do procedimento/i, 'Deve conter a seção explícita # corpo do procedimento.');
  assert.match(content, /# epilogo/i, 'Deve conter a seção explícita # epilogo.');
  assert.match(content, /<-/, 'Deve utilizar comentários com seta de atribuição.');
});

test('Preservação da corretude funcional e execução no MARS @spec:AC-008', () => {
  const cmd = `java -jar "${marsJar}" nc sm "${q1Asm}"`;
  const output = execSync(cmd, { cwd: rootDir, encoding: 'utf-8' });
  const trimmed = output.trim();
  assert.equal(trimmed, 'O resultado e 17', 'A execução refatorada deve manter a impressão "O resultado e 17".');
});
