param(
    [string]$RepoSource = "",
    [string]$RepoUrl = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  -> $Message" -ForegroundColor DarkGray
}

function Resolve-WingetCommand {
    $candidate = Get-Command winget -ErrorAction SilentlyContinue
    if ($candidate) {
        return $candidate.Path
    }

    $candidate = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($candidate) {
        return $candidate.Path
    }

    return $null
}

function Install-WingetPackage {
    param(
        [string]$WingetPath,
        [string]$Id
    )

    & $WingetPath install --exact --id $Id --accept-package-agreements --accept-source-agreements --silent
}

function Test-CommandExists {
    param([string]$CommandName)

    return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

Write-Step "Verificando winget"
$wingetPath = Resolve-WingetCommand
if (-not $wingetPath) {
    throw "winget nao encontrado no PATH desta sessao. Confirme se o App Installer/winget esta instalado e acessivel neste PowerShell."
}
Write-Info "winget: $wingetPath"

Write-Step "Instalando dependencias Windows"
$packages = @(
    @{ Id = "Alacritty.Alacritty"; Command = "alacritty.exe" },
    @{ Id = "LGUG2Z.komorebi"; Command = "komorebic.exe" },
    @{ Id = "LGUG2Z.whkd"; Command = "whkd.exe" },
    @{ Id = "AmN.yasb"; Command = "yasb.exe" },
    @{ Id = "twpayne.chezmoi"; Command = "chezmoi.exe" }
)

foreach ($package in $packages) {
    if (Test-CommandExists -CommandName $package.Command) {
        Write-Info "$($package.Id) ja disponivel como $($package.Command); pulando instalacao"
        continue
    }

    Install-WingetPackage -WingetPath $wingetPath -Id $package.Id
}

Write-Step "Aplicando dotfiles Windows com chezmoi"
$chezmoi = Get-Command chezmoi -ErrorAction SilentlyContinue
if (-not $chezmoi) {
    throw "chezmoi nao encontrado apos instalacao"
}

if ($RepoSource -and (Test-Path $RepoSource)) {
    & $chezmoi.Path apply --source $RepoSource
    exit $LASTEXITCODE
}

if ($RepoUrl) {
    & $chezmoi.Path init --apply $RepoUrl
    exit $LASTEXITCODE
}

throw "nenhuma source do repo foi fornecida para o chezmoi"
