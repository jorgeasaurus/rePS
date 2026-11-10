#Requires -Version 7.2
<#
.SYNOPSIS
    Scaffolds a new exercise folder with all four required files.
.DESCRIPTION
    Creates Exercises/<Topic>/<Id>/ with exercise.psd1, stub.ps1, solution.ps1 and
    tests.Tests.ps1 pre-filled with the expected structure. Fill in the TODOs, then run
    ./build.ps1 -Task Test to validate.
.EXAMPLE
    ./scripts/New-Exercise.ps1 -Id core-title-case -Topic Core -Level 1 -FunctionName ConvertTo-TitleCase
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)+$')]
    [string]$Id,

    [Parameter(Mandatory)]
    [ValidateSet('Core', 'Pipeline', 'Functions', 'Advanced')]
    [string]$Topic,

    [Parameter(Mandatory)]
    [ValidateRange(1, 3)]
    [int]$Level,

    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Z][a-zA-Z]+-[A-Z][a-zA-Z0-9]+$')]
    [string]$FunctionName,

    [ValidateSet('Windows', 'Linux', 'MacOS')]
    [string[]]$Platforms = @('Windows', 'Linux', 'MacOS'),

    [string]$Author = 'rePS'
)

$ErrorActionPreference = 'Stop'
$folder = Join-Path $PSScriptRoot '..' 'Exercises' $Topic $Id
if (Test-Path $folder) { throw "Exercise folder already exists: $folder" }
if (-not $PSCmdlet.ShouldProcess($folder, 'Create exercise')) { return }

$null = New-Item -Path $folder -ItemType Directory -Force
$platformList = ($Platforms | ForEach-Object { "'$_'" }) -join ', '
$authorLiteral = $Author -replace "'", "''"

@"
@{
    Id           = '$Id'
    Title        = 'TODO: short title'
    Topic        = '$Topic'
    Level        = $Level
    Platforms    = @($platformList)
    Tags         = @('todo')
    FunctionName = '$FunctionName'
    Author       = '$authorLiteral'
    Prompt       = @'
TODO: Describe what $FunctionName must do, with an example:

    $FunctionName -Example 'input'   # expected output
'@
    Hints        = @(
        'TODO: a gentle nudge'
        'TODO: a more specific hint'
    )
}
"@ | Set-Content -Path (Join-Path $folder 'exercise.psd1') -Encoding utf8

@"
function $FunctionName {
    param(
        # TODO: parameters the learner starts with
    )

    # TODO: describe what to implement
    throw 'Not implemented'
}
"@ | Set-Content -Path (Join-Path $folder 'stub.ps1') -Encoding utf8

@"
function $FunctionName {
    param(
    )

    # TODO: reference solution
}
"@ | Set-Content -Path (Join-Path $folder 'solution.ps1') -Encoding utf8

@"
param([Parameter(Mandatory)][string]`$SolutionPath)

BeforeAll {
    . `$SolutionPath
}

Describe '$FunctionName' {
    It 'TODO: describes one behaviour' {
        $FunctionName | Should -Be 'TODO'
    }
}
"@ | Set-Content -Path (Join-Path $folder 'tests.Tests.ps1') -Encoding utf8

Write-Host "Created $folder"
Write-Host 'Next: fill in the TODOs, then run ./build.ps1 -Task Test'
