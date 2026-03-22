Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
    [string]$RepoSource = "",
    [string]$RepoUrl = ""
)

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Green
}

function Install-WingetPackage {
    param([string]$Id)

    winget install --exact --id $Id --accept-package-agreements --accept-source-agreements --silent
}

Write-Step "Verificando winget"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget nao encontrado no Windows"
}

Write-Step "Instalando dependencias Windows"
$packages = @(
    "Alacritty.Alacritty",
    "LGUG2Z.komorebi",
    "LGUG2Z.whkd",
    "AmN.yasb",
    "twpayne.chezmoi"
)

foreach ($package in $packages) {
    Install-WingetPackage -Id $package
}

Write-Step "Aplicando dotfiles Windows com chezmoi"
$chezmoi = Get-Command chezmoi -ErrorAction SilentlyContinue
if (-not $chezmoi) {
    throw "chezmoi nao encontrado apos instalacao"
}

if ($RepoSource -and (Test-Path $RepoSource)) {
    & $chezmoi.Source apply --source $RepoSource
    exit $LASTEXITCODE
}

if ($RepoUrl) {
    & $chezmoi.Source init --apply $RepoUrl
    exit $LASTEXITCODE
}

throw "nenhuma source do repo foi fornecida para o chezmoi"
