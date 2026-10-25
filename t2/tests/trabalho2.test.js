import test from 'node:test';
import assert from 'node:assert/strict';
import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..', '..');
const marsJar = path.join(rootDir, 't2', 'Mars4_5.jar');
const q1Asm = path.join(rootDir, 't2', 'src', 'q1.asm');

// Funções auxiliares para manipulação de ponto fixo Q7.4 (11 bits com sinal)
function toSignedQ74(val11Bits) {
  // val11Bits entre 0 e 2047
  if (val11Bits & (1 << 10)) {
    return (val11Bits - 2048) / 16;
  }
  return val11Bits / 16;
}

function formatQ74Binary(val11Bits) {
  const bin = (val11Bits & 0x7ff).toString(2).padStart(11, '0');
  return `${bin.slice(0, 7)}.${bin.slice(7)}`;
}

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
  // Representação de B = +10.25 em Q7.4 (11 bits)
  // Inteiro: 10 = 0001010_2
  // Fracionário: 0.25 = 0100_2
  // Binário: 0001010.0100_2 = 0x0A4 = 164
  const bVal = (10 << 4) | 4; // 164
  assert.equal(formatQ74Binary(bVal), '0001010.0100');
  assert.equal(toSignedQ74(bVal), 10.25);

  // Representação de A = -27.30 em Q7.4 com truncamento simples
  // Inteiro: 27 = 0011011_2
  // Fracionário: 0.30 truncado a 4 bits: 0.3*2=0.6(0), 0.6*2=1.2(1), 0.2*2=0.4(0), 0.4*2=0.8(0) => 0100_2 (0.25)
  // Magnitude positiva: 27.25 = 0011011.0100_2 = 436
  // Complemento de 2 (11 bits): 2048 - 436 = 1612 (0x64C) = 11001001100_2
  const aMag = (27 << 4) | 4; // 436
  const aVal = (2048 - aMag) & 0x7ff; // 1612
  assert.equal(formatQ74Binary(aVal), '1100100.1100');
  assert.equal(toSignedQ74(aVal), -27.25);
});

test('Subtração D = A - B com tabela de vem-uns e análise de overflow @spec:AC-004', () => {
  const aVal = 1612; // A = -27.25 em Q7.4
  const bVal = 164;  // B = +10.25 em Q7.4
  const negB = (2048 - bVal) & 0x7ff; // -B = 1884 (1110101.1100)

  assert.equal(formatQ74Binary(negB), '1110101.1100');

  // Cálculo da soma A + (-B) com vem-uns bit a bit
  const carries = new Array(12).fill(0);
  let c = 0;
  for (let i = 0; i < 11; i++) {
    const bitA = (aVal >> i) & 1;
    const bitNegB = (negB >> i) & 1;
    const sum = bitA + bitNegB + c;
    c = sum >> 1;
    carries[i + 1] = c;
  }

  const dVal = (aVal + negB) & 0x7ff; // 1448 (1011010.1000)
  assert.equal(formatQ74Binary(dVal), '1011010.1000');
  assert.equal(toSignedQ74(dVal), -37.5);

  // Verificação de overflow: carry que entra no sinal (bit 10) vs carry que sai do sinal (bit 11)
  const cInSign = carries[10];
  const cOutSign = carries[11];
  assert.equal(cInSign, 1, 'Carry que entra no bit de sinal deve ser 1.');
  assert.equal(cOutSign, 1, 'Carry que sai do bit de sinal deve ser 1.');
  const overflow = cInSign !== cOutSign;
  assert.equal(overflow, false, 'Não deve haver overflow pois c_in == c_out e -37.5 está no intervalo [-64, +63.9375].');
});

test('Soma E = D + B e análise de igualdade com A @spec:AC-005', () => {
  const dVal = 1448; // D = -37.50
  const bVal = 164;  // B = +10.25
  const aVal = 1612; // A = -27.25

  const eVal = (dVal + bVal) & 0x7ff;
  assert.equal(eVal, aVal, 'O valor binário de E deve ser idêntico ao valor de máquina de A.');
  assert.equal(formatQ74Binary(eVal), '1100100.1100');
  assert.equal(toSignedQ74(eVal), -27.25);

  // Comparação com o valor decimal original
  const valorOriginal = -27.3;
  const erroTruncamento = Math.abs(toSignedQ74(eVal) - valorOriginal);
  assert.ok(Math.abs(erroTruncamento - 0.05) < 1e-6, 'A diferença entre E e o decimal original A decorre do erro de truncamento de 0.05.');
});
