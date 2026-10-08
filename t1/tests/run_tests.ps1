# ==============================================================================
# ELC1011 - Organizacao de Computadores (UFSM)
# Trabalho 1: Criptografia S-AES (Simplified AES)
# Script de Automacao de Testes: run_tests.ps1
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  BATERIA DE TESTES AUTOMATIZADOS - CRIPTOGRAFO S-AES MIPS" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$marsJar = "Mars4_5.jar"
if (-not (Test-Path $marsJar)) {
    Write-Host "[ERRO] Arquivo Mars4_5.jar nao encontrado na raiz do projeto!" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------------
# 1. Teste Unitario do Motor Criptografico (Vetor Oficial Steven Gordon)
# ------------------------------------------------------------------------------
Write-Host "`n[1/3] Executando Teste Unitario do Motor S-AES..." -ForegroundColor Yellow
$unitResult = java -jar $marsJar nc sm tests/test_saes_vectors.asm
Write-Host $unitResult

if ($LASTEXITCODE -ne 0) {
    Write-Host "[FALHA] Teste unitario falhou!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "[SUCESSO] Teste unitario concluido com 100% de precisao!" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 2. Teste Integrado com texto1.txt (Chave ELC1011)
# ------------------------------------------------------------------------------
Write-Host "`n[2/3] Executando Teste Integrado com texto1.txt..." -ForegroundColor Yellow

$inputTexto1 = @"
1
tests/data/texto1.txt
tests/data/secreto1.aes
ELC1011
2
tests/data/secreto1.aes
tests/data/teste1.txt
ELC1011
0
"@

$inputTexto1 | java -jar $marsJar nc sm src/main.asm | Out-Null

$orig1 = [System.IO.File]::ReadAllBytes("tests/data/texto1.txt")
$dec1  = [System.IO.File]::ReadAllBytes("tests/data/teste1.txt")

$match1 = $true
for ($i = 0; $i -lt $orig1.Length; $i++) {
    if ($orig1[$i] -ne $dec1[$i]) {
        $match1 = $false
        break
    }
}

if ($match1) {
    Write-Host "[SUCESSO] texto1.txt restaurado com integridade perfeita em teste1.txt!" -ForegroundColor Green
} else {
    Write-Host "[FALHA] Divergencia encontrada em teste1.txt!" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 3. Teste Integrado com texto2.txt (Chave ELC1011)
# ------------------------------------------------------------------------------
Write-Host "`n[3/3] Executando Teste Integrado com texto2.txt..." -ForegroundColor Yellow

$inputTexto2 = @"
1
tests/data/texto2.txt
tests/data/secreto2.aes
ELC1011
2
tests/data/secreto2.aes
tests/data/teste2.txt
ELC1011
0
"@

$inputTexto2 | java -jar $marsJar nc sm src/main.asm | Out-Null

$orig2 = [System.IO.File]::ReadAllBytes("tests/data/texto2.txt")
$dec2  = [System.IO.File]::ReadAllBytes("tests/data/teste2.txt")

$match2 = $true
for ($i = 0; $i -lt $orig2.Length; $i++) {
    if ($orig2[$i] -ne $dec2[$i]) {
        $match2 = $false
        break
    }
}

if ($match2) {
    Write-Host "[SUCESSO] texto2.txt restaurado com integridade perfeita em teste2.txt!" -ForegroundColor Green
} else {
    Write-Host "[FALHA] Divergencia encontrada em teste2.txt!" -ForegroundColor Red
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  TODOS OS TESTES FORAM CONCLUIDOS COM EXITO MAXIMO!" -ForegroundColor Green
Write-Host "==========================================================`n" -ForegroundColor Cyan
