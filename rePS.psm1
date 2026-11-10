#Requires -Version 7.2

<#
.SYNOPSIS
    Root module for rePS.
.DESCRIPTION
    PowerShell practice tool: random exercises, solved in your editor, validated with Pester.
#>

$script:ModuleRoot = $PSScriptRoot
$script:ExercisesPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Exercises'
$script:RunnerPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Runner/Invoke-RePSTestRun.ps1'
$script:ValidTopics = @('Core', 'Pipeline', 'Functions', 'Advanced')
$script:ValidPlatforms = @('Windows', 'Linux', 'MacOS')
$script:ExerciseCache = $null
$script:ModuleVersion = [version](Import-PowerShellDataFile -LiteralPath (Join-Path $script:ModuleRoot 'rePS.psd1')).ModuleVersion

foreach ($folder in 'Private', 'Public') {
    $folderPath = Join-Path -Path $script:ModuleRoot -ChildPath $folder
    foreach ($file in Get-ChildItem -Path $folderPath -Filter '*.ps1' -File -ErrorAction SilentlyContinue) {
        try {
            . $file.FullName
        } catch {
            throw "Failed to import $($file.FullName): $_"
        }
    }
}

$aliases = @{
    reps   = 'Start-RePSExercise'
    rept   = 'Test-RePSExercise'
    reph   = 'Get-RePSHint'
    repsol = 'Show-RePSSolution'
    repp   = 'Get-RePSProgress'
}
foreach ($alias in $aliases.GetEnumerator()) {
    Set-Alias -Name $alias.Key -Value $alias.Value -Scope Script
}

Update-TypeData -TypeName 'RePS.Exercise' -DefaultDisplayPropertySet 'Id', 'Title', 'Topic', 'Level', 'Status' -Force

# Background, non-blocking check for a newer version (see Private/UpdateCheck.ps1).
Start-RePSUpdateCheck

Export-ModuleMember -Function (Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1').BaseName -Alias @($aliases.Keys)
