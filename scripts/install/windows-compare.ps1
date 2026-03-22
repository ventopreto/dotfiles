param(
    [string]$RepoSource = (Get-Location).Path,
    [string]$OutputDir = (Join-Path (Get-Location).Path "tmp\windows-compare"),
    [switch]$ShowDiff
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

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-SafeName {
    param([string]$Value)

    return ($Value -replace '[^A-Za-z0-9._-]', '-')
}

function Backup-FileIfPresent {
    param(
        [string]$SourcePath,
        [string]$BackupPath
    )

    if (Test-Path $SourcePath) {
        Copy-Item $SourcePath $BackupPath -Force
        return $true
    }

    return $false
}

function Render-ChezmoiTarget {
    param(
        [string]$ChezmoiPath,
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$RenderedPath
    )

    $renderedContent = & $ChezmoiPath --source $SourcePath cat $DestinationPath
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($RenderedPath, ($renderedContent -join [Environment]::NewLine), $utf8NoBom)
}

function Write-GitDiffFile {
    param(
        [string]$LocalPath,
        [string]$RenderedPath,
        [string]$DiffPath
    )

    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        return $false
    }

    $oldEap = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $git.Path diff --no-index -- $LocalPath $RenderedPath *> $DiffPath
        return $true
    } finally {
        $ErrorActionPreference = $oldEap
    }
}

$chezmoi = Get-Command chezmoi -ErrorAction SilentlyContinue
if (-not $chezmoi) {
    throw "chezmoi nao encontrado no PATH desta sessao"
}

if (-not (Test-Path $RepoSource)) {
    throw "RepoSource nao encontrado: $RepoSource"
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runDir = Join-Path $OutputDir $timestamp
$backupDir = Join-Path $runDir "backup"
$renderedDir = Join-Path $runDir "rendered"
$diffDir = Join-Path $runDir "diff"

Ensure-Directory $backupDir
Ensure-Directory $renderedDir
Ensure-Directory $diffDir

$targets = @(
    @{
        Name = "komorebi"
        DestinationPath = (Join-Path $HOME "komorebi.json")
        RelativeOutput = "komorebi.json"
    },
    @{
        Name = "whkd"
        DestinationPath = (Join-Path $HOME ".config\whkdrc")
        RelativeOutput = "whkdrc"
    },
    @{
        Name = "yasb config"
        DestinationPath = (Join-Path $HOME ".config\yasb\config.yaml")
        RelativeOutput = "yasb-config.yaml"
    },
    @{
        Name = "yasb styles"
        DestinationPath = (Join-Path $HOME ".config\yasb\styles.css")
        RelativeOutput = "yasb-styles.css"
    }
)

$results = @()

Write-Step "Comparando arquivos Windows locais com a renderizacao do chezmoi"
Write-Info "source: $RepoSource"
Write-Info "artifacts: $runDir"

foreach ($target in $targets) {
    $safeName = Get-SafeName $target.RelativeOutput
    $backupPath = Join-Path $backupDir $safeName
    $renderedPath = Join-Path $renderedDir $safeName
    $diffPath = Join-Path $diffDir "$safeName.diff"

    try {
        $localExists = Backup-FileIfPresent -SourcePath $target.DestinationPath -BackupPath $backupPath
        Render-ChezmoiTarget -ChezmoiPath $chezmoi.Path -SourcePath $RepoSource -DestinationPath $target.DestinationPath -RenderedPath $renderedPath
        $renderedExists = Test-Path $renderedPath

        if (-not $localExists -and -not $renderedExists) {
            $status = "missing-both"
        } elseif (-not $localExists) {
            $status = "only-repo"
        } elseif (-not $renderedExists) {
            $status = "only-local"
        } else {
            $leftHash = (Get-FileHash $target.DestinationPath -Algorithm SHA256).Hash
            $rightHash = (Get-FileHash $renderedPath -Algorithm SHA256).Hash
            $status = if ($leftHash -eq $rightHash) { "same" } else { "different" }
        }

        $usedGitDiff = $false
        if ($status -eq "different" -and $localExists -and $renderedExists) {
            $usedGitDiff = Write-GitDiffFile -LocalPath $target.DestinationPath -RenderedPath $renderedPath -DiffPath $diffPath
        }

        $result = [PSCustomObject]@{
            Name = $target.Name
            Status = $status
            DestinationPath = $target.DestinationPath
            BackupPath = if ($localExists) { $backupPath } else { "" }
            RenderedPath = if ($renderedExists) { $renderedPath } else { "" }
            DiffPath = if ($usedGitDiff) { $diffPath } else { "" }
        }
        $results += $result

        switch ($status) {
            "same" {
                Write-Host "[same] $($target.Name): $($target.DestinationPath)" -ForegroundColor Cyan
            }
            "different" {
                Write-Host "[diff] $($target.Name): $($target.DestinationPath)" -ForegroundColor Yellow
                if ($usedGitDiff) {
                    Write-Info "diff salvo em $diffPath"
                    if ($ShowDiff) {
                        Get-Content $diffPath | Select-Object -First 120 | ForEach-Object {
                            Write-Host "     $_"
                        }
                    }
                }
            }
            "only-repo" {
                Write-Host "[only-repo] $($target.Name): $($target.DestinationPath)" -ForegroundColor Yellow
            }
            "only-local" {
                Write-Host "[only-local] $($target.Name): $($target.DestinationPath)" -ForegroundColor Yellow
            }
            default {
                Write-Host "[missing] $($target.Name): $($target.DestinationPath)" -ForegroundColor DarkYellow
            }
        }
    } catch {
        Write-Host "[error] $($target.Name): $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Name = $target.Name
            Status = "error"
            DestinationPath = $target.DestinationPath
            BackupPath = if (Test-Path $backupPath) { $backupPath } else { "" }
            RenderedPath = if (Test-Path $renderedPath) { $renderedPath } else { "" }
            DiffPath = if (Test-Path $diffPath) { $diffPath } else { "" }
        }
    }
}

Write-Step "Resumo"
$results | Select-Object Name, Status, DestinationPath, BackupPath, DiffPath | Format-Table -AutoSize

Write-Info "revise os arquivos em '$runDir' antes de decidir o que sobe para o repo"
