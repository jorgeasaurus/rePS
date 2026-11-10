#Requires -Version 7.2
<#
.SYNOPSIS
    Runs one exercise's Pester tests against a solution file in an isolated process.
.DESCRIPTION
    Invoked by Test-RePSExercise in a child pwsh process, so user code (functions, classes,
    infinite loops) never pollutes or hangs the caller's session. Writes a JSON summary to
    -ResultPath for the caller to read.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TestPath,

    [Parameter(Mandatory)]
    [string]$SolutionPath,

    [Parameter(Mandatory)]
    [string]$ResultPath,

    [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
    [string]$Verbosity = 'Detailed',

    [switch]$Ansi
)

$ErrorActionPreference = 'Stop'
if ($Ansi -and $PSStyle) { $PSStyle.OutputRendering = 'Ansi' }

Import-Module -Name Pester -MinimumVersion 5.5.0 -ErrorAction Stop

$config = New-PesterConfiguration
$config.Run.Container = New-PesterContainer -Path $TestPath -Data @{ SolutionPath = $SolutionPath }
$config.Run.PassThru = $true
$config.Output.Verbosity = $Verbosity

$result = Invoke-Pester -Configuration $config

[ordered]@{
    Result       = $result.Result
    TotalCount   = $result.TotalCount
    PassedCount  = $result.PassedCount
    FailedCount  = $result.FailedCount + $result.FailedBlocksCount + $result.FailedContainersCount
    SkippedCount = $result.SkippedCount
    Failed       = @($result.Failed | ForEach-Object { $_.ExpandedName })
} | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $ResultPath -Encoding utf8
