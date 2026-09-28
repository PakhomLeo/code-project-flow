<#
.SYNOPSIS
    Install the code-project-flow skill into a Qoder skills directory.

.DESCRIPTION
    Clones the repository into <SkillsRoot>\code-project-flow, or fast-forwards
    it when it is already a git checkout. Never deletes existing files.

    Console messages are English on purpose: Windows PowerShell 5.1 decodes a
    BOM-less UTF-8 script as ANSI, which would mangle translated output.

.PARAMETER SkillsRoot
    Target skills directory. Auto-detected when omitted.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -SkillsRoot C:\path\to\skills
#>
[CmdletBinding()]
param(
    [string]$SkillsRoot
)

$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/PakhomLeo/code-project-flow.git'
$SkillName = 'code-project-flow'

if (-not $SkillsRoot) {
    $qoderCn = Join-Path $HOME '.qoder-cn\skills'
    $qoder = Join-Path $HOME '.qoder\skills'
    if (Test-Path $qoder) { $SkillsRoot = $qoder } else { $SkillsRoot = $qoderCn }
}

$Target = Join-Path $SkillsRoot $SkillName

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git is required but was not found on PATH.'
    exit 1
}

if (Test-Path (Join-Path $Target '.git')) {
    Write-Host "Already installed, updating: $Target"
    git -C $Target pull --ff-only
    Write-Host 'Done. Start a new agent session for it to take effect.'
    exit 0
}

if (Test-Path $Target) {
    Write-Error @"
Target exists and is not a git checkout: $Target
Rename or remove it yourself, then run this script again.
"@
    exit 1
}

New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
git clone --depth 1 $RepoUrl $Target
Write-Host "Installed: $Target"
Write-Host 'Start a new agent session for it to take effect.'
