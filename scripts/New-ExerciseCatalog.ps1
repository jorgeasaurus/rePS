#Requires -Version 7.2
<#
.SYNOPSIS
    Generates docs/exercises.md from exercise metadata.
.DESCRIPTION
    Lists every exercise by topic with level, tags and platforms. Prompts and hints are
    deliberately left out so the docs do not spoil the exercises.
#>
[CmdletBinding()]
param(
    [string]$ExercisesPath = (Join-Path $PSScriptRoot '..' 'Exercises'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..' 'docs' 'exercises.md')
)

$ErrorActionPreference = 'Stop'

$exercises = Get-ChildItem -Path $ExercisesPath -Filter 'exercise.psd1' -Recurse -File |
    ForEach-Object { Import-PowerShellDataFile -LiteralPath $_.FullName } |
    Sort-Object Level, Id

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Exercise catalog')
$lines.Add('')
$lines.Add("rePS ships **$(@($exercises).Count) exercises**. Start one with ``Start-RePSExercise -Id <id>``,")
$lines.Add('or let `reps` pick one at random.')
$lines.Add('')
$lines.Add('!!! note "Generated file"')
$lines.Add('    This page is generated from `exercise.psd1` files by `scripts/New-ExerciseCatalog.ps1`. Do not edit it by hand.')

foreach ($topic in 'Core', 'Pipeline', 'Functions', 'Advanced') {
    $topicExercises = @($exercises | Where-Object Topic -EQ $topic)
    if (-not $topicExercises) { continue }
    $lines.Add('')
    $lines.Add("## $topic")
    $lines.Add('')
    $lines.Add('| Id | Title | Level | Tags | Platforms |')
    $lines.Add('| --- | --- | --- | --- | --- |')
    foreach ($e in $topicExercises) {
        $platforms = if (@($e.Platforms).Count -eq 3) { 'All' } else { $e.Platforms -join ', ' }
        $lines.Add("| ``$($e.Id)`` | $($e.Title) | $('★' * $e.Level) | $($e.Tags -join ', ') | $platforms |")
    }
}

$null = New-Item -Path (Split-Path $OutputPath) -ItemType Directory -Force
$lines | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host "Wrote $OutputPath ($(@($exercises).Count) exercises)"
