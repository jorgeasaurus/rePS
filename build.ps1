#Requires -Version 7.2

<#
.SYNOPSIS
    Bootstrap script for the rePS build process.
.DESCRIPTION
    Installs required build dependencies (InvokeBuild, Pester, PSScriptAnalyzer)
    and optionally invokes the build process.
.PARAMETER Task
    The build task(s) to run. If not specified, runs the default task (Analyze, Test, Build).
.PARAMETER NoBuild
    Only install dependencies, don't run any build tasks.
.EXAMPLE
    ./build.ps1
    Installs dependencies and runs the default task.
.EXAMPLE
    ./build.ps1 -Task Test
    Runs module tests and exercise validation.
.EXAMPLE
    ./build.ps1 -Task Analyze, Test, Build
    Installs dependencies and runs multiple tasks.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string[]]$Task,

    [Parameter()]
    [switch]$NoBuild
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

Write-Information '=== rePS Build Bootstrap ==='

$requiredModules = @(
    @{ Name = 'InvokeBuild'; MinimumVersion = '5.10.0' }
    @{ Name = 'Pester'; MinimumVersion = '5.5.0' }
    @{ Name = 'PSScriptAnalyzer'; MinimumVersion = '1.21.0' }
)

foreach ($module in $requiredModules) {
    $installed = Get-Module -Name $module.Name -ListAvailable |
        Where-Object { $_.Version -ge [version]$module.MinimumVersion } |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if (-not $installed) {
        Write-Information "Installing $($module.Name) >= $($module.MinimumVersion)..."
        Install-Module -Name $module.Name -MinimumVersion $module.MinimumVersion -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck -ErrorAction Stop
        # Install-Module can fail without throwing (e.g. a blocked download), so verify.
        $installed = Get-Module -Name $module.Name -ListAvailable |
            Where-Object { $_.Version -ge [version]$module.MinimumVersion } |
            Select-Object -First 1
        if (-not $installed) {
            throw "Failed to install $($module.Name) >= $($module.MinimumVersion). Check access to the PowerShell Gallery."
        }
        Write-Information "  Installed $($module.Name) v$($installed.Version)"
    } else {
        Write-Information "Found $($module.Name) v$($installed.Version)"
    }
}

Write-Information 'Bootstrap complete.'

if (-not $NoBuild) {
    if (-not $Task) {
        $Task = @('.')
    }

    Write-Information ''
    Write-Information "Running build tasks: $($Task -join ', ')"

    $buildScript = Join-Path -Path $PSScriptRoot -ChildPath 'rePS.build.ps1'
    if (-not (Test-Path $buildScript)) {
        throw "Build script not found: $buildScript"
    }

    Import-Module InvokeBuild -Force
    Invoke-Build -File $buildScript -Task $Task
}
