#Requires -Version 7.2
<#
.SYNOPSIS
    Validates exercise content by running each exercise's tests against its own files.
.DESCRIPTION
    -Mode Solution : every solution.ps1 must pass all of its tests.
    -Mode Stub     : every stub.ps1 must FAIL at least one test (proves the tests check something).

    Exercises whose Platforms do not include the current OS are skipped, so CI validates
    Windows-only exercises on the Windows runner only. Run each mode in its own process:
    stubs and solutions can define the same classes.
.EXAMPLE
    ./scripts/Test-Exercises.ps1 -Mode Solution
.EXAMPLE
    ./scripts/Test-Exercises.ps1 -Mode Stub -Id core-greeting
#>
[CmdletBinding()]
param(
    [ValidateSet('Solution', 'Stub')]
    [string]$Mode = 'Solution',

    [string[]]$Id,

    [string]$ExercisesPath = (Join-Path $PSScriptRoot '..' 'Exercises'),

    [string]$ResultPath
)

$ErrorActionPreference = 'Stop'
Import-Module -Name Pester -MinimumVersion 5.5.0

$platform = if ($IsWindows) { 'Windows' } elseif ($IsMacOS) { 'MacOS' } else { 'Linux' }
$fileName = if ($Mode -eq 'Solution') { 'solution.ps1' } else { 'stub.ps1' }

$containers = foreach ($manifest in Get-ChildItem -Path $ExercisesPath -Filter 'exercise.psd1' -Recurse -File) {
    $data = Import-PowerShellDataFile -LiteralPath $manifest.FullName
    if ($Id -and $data.Id -notin $Id) { continue }
    if ($platform -notin $data.Platforms) {
        Write-Host "Skipping $($data.Id) (platforms: $($data.Platforms -join ', '))" -ForegroundColor DarkGray
        continue
    }
    $folder = $manifest.Directory.FullName
    New-PesterContainer -Path (Join-Path $folder 'tests.Tests.ps1') -Data @{ SolutionPath = (Join-Path $folder $fileName) }
}

if (-not $containers) { throw 'No exercises found to test.' }

$config = New-PesterConfiguration
$config.Run.Container = @($containers)
$config.Run.PassThru = $true
$config.Output.Verbosity = if ($Mode -eq 'Solution') { 'Normal' } else { 'None' }
if ($ResultPath -and $Mode -eq 'Solution') {
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = $ResultPath
    $config.TestResult.OutputFormat = 'NUnitXml'
}

$result = Invoke-Pester -Configuration $config

if ($Mode -eq 'Solution') {
    $failed = $result.FailedCount + $result.FailedBlocksCount + $result.FailedContainersCount
    if ($failed -gt 0) {
        throw "$failed reference solution check(s) failed across $(@($containers).Count) exercises."
    }
    Write-Host "All $(@($containers).Count) reference solutions pass ($($result.PassedCount) tests)." -ForegroundColor Green
} else {
    $tooEasy = foreach ($container in $result.Containers) {
        $failures = @($container.Blocks.Tests | Where-Object Result -EQ 'Failed').Count
        $blockFailed = $container.Result -eq 'Failed' -and $failures -eq 0
        if ($failures -eq 0 -and -not $blockFailed) { Split-Path -Path $container.Item.Directory -Leaf }
    }
    if ($tooEasy) {
        throw "These stubs pass all their tests (the tests do not check anything): $($tooEasy -join ', ')"
    }
    Write-Host "All $(@($containers).Count) stubs fail their tests, as they should." -ForegroundColor Green
}
