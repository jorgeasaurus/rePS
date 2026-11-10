#Requires -Version 7.2
#Requires -Modules InvokeBuild

<#
.SYNOPSIS
    InvokeBuild script for rePS.
.DESCRIPTION
    Defines build tasks for analyzing, testing, building, and publishing the module.
#>

$ModuleName = 'rePS'
$SourcePath = $BuildRoot
$BuildPath = Join-Path -Path $BuildRoot -ChildPath 'build'
$ModuleBuildPath = Join-Path -Path $BuildPath -ChildPath $ModuleName
$TestResultsPath = Join-Path -Path $BuildPath -ChildPath 'TestResults'
$ManifestPath = Join-Path -Path $SourcePath -ChildPath "$ModuleName.psd1"
$ChangelogPath = Join-Path -Path $SourcePath -ChildPath 'CHANGELOG.md'

# Files and folders shipped in the module
$ModuleFiles = @(
    'rePS.psd1'
    'rePS.psm1'
    'LICENSE'
)

$ModuleFolders = @(
    'Public'
    'Private'
    'Runner'
    'Exercises'
)

function Get-ChangelogSection {
    param([string]$Version)

    $lines = Get-Content -LiteralPath $ChangelogPath
    $start = $lines.IndexOf(($lines | Where-Object { $_ -match "^## \[$([regex]::Escape($Version))\]" } | Select-Object -First 1))
    if ($start -lt 0) { throw "CHANGELOG.md has no section for version $Version" }
    $section = foreach ($line in $lines[($start + 1)..($lines.Count - 1)]) {
        if ($line -match '^## \[') { break }
        $line
    }
    ($section -join "`n").Trim()
}

# Synopsis: Remove build artifacts
Task Clean {
    if (Test-Path -Path $BuildPath) {
        Write-Build Yellow "Removing build directory: $BuildPath"
        Remove-Item -Path $BuildPath -Recurse -Force
    }
}

# Synopsis: Run PSScriptAnalyzer
Task Analyze {
    Write-Build White 'Running PSScriptAnalyzer...'

    $analyzerParams = @{
        Recurse     = $true
        ExcludeRule = @(
            'PSAvoidUsingWriteHost'                      # Interactive tool: host output is the UI
            'PSUseShouldProcessForStateChangingFunctions' # Exercise functions (New-*) are not state-changing
        )
        Severity    = @('Error', 'Warning')
    }

    $excludePaths = @(
        (Join-Path $SourcePath 'build')
    )

    $results = Get-ChildItem -Path $SourcePath -Include '*.ps1', '*.psm1', '*.psd1' -Recurse -File |
        Where-Object {
            $file = $_
            $excluded = $excludePaths | Where-Object { $file.FullName.StartsWith($_) }
            # Stubs are intentionally incomplete (unused params, TODOs)
            -not $excluded -and $file.Name -ne 'stub.ps1'
        } |
        ForEach-Object { Invoke-ScriptAnalyzer -Path $_.FullName @analyzerParams }

    if ($results) {
        $results | Format-Table -AutoSize
        $errorCount = @($results | Where-Object { $_.Severity -eq 'Error' }).Count
        $warningCount = @($results | Where-Object { $_.Severity -eq 'Warning' }).Count

        Write-Build Yellow "PSScriptAnalyzer found $errorCount errors and $warningCount warnings"

        if ($errorCount -gt 0) {
            throw "PSScriptAnalyzer found $errorCount errors. Please fix them before building."
        }
    } else {
        Write-Build Green 'PSScriptAnalyzer found no issues'
    }
}

# Synopsis: Run module and schema Pester tests
Task TestModule {
    Write-Build White 'Running Pester tests...'

    if (-not (Test-Path -Path $TestResultsPath)) {
        New-Item -Path $TestResultsPath -ItemType Directory -Force | Out-Null
    }

    $pesterConfig = New-PesterConfiguration
    $pesterConfig.Run.Path = Join-Path -Path $SourcePath -ChildPath 'Tests'
    $pesterConfig.Run.Exit = $false
    $pesterConfig.Run.PassThru = $true
    $pesterConfig.Output.Verbosity = 'Detailed'
    $pesterConfig.TestResult.Enabled = $true
    $pesterConfig.TestResult.OutputPath = Join-Path -Path $TestResultsPath -ChildPath 'TestResults.xml'
    $pesterConfig.TestResult.OutputFormat = 'NUnitXml'

    $testResult = Invoke-Pester -Configuration $pesterConfig

    if (($testResult.FailedCount + $testResult.FailedBlocksCount + $testResult.FailedContainersCount) -gt 0) {
        throw "Pester run failed: $($testResult.FailedCount) failed test(s), $($testResult.FailedBlocksCount) failed block(s), $($testResult.FailedContainersCount) failed container(s), of $($testResult.TotalCount) total tests"
    }

    Write-Build Green "All $($testResult.PassedCount) tests passed"
}

# Synopsis: Validate exercises (solutions pass, stubs fail) on this OS
Task TestExercises {
    if (-not (Test-Path -Path $TestResultsPath)) {
        New-Item -Path $TestResultsPath -ItemType Directory -Force | Out-Null
    }
    $script = Join-Path -Path $SourcePath -ChildPath 'scripts/Test-Exercises.ps1'
    $pwsh = (Get-Process -Id $PID).Path

    # Separate processes: stubs and solutions may define the same classes.
    Write-Build White 'Checking reference solutions pass...'
    exec { & $pwsh -NoProfile -NonInteractive -File $script -Mode Solution -ResultPath (Join-Path $TestResultsPath 'ExerciseResults.xml') }

    Write-Build White 'Checking stubs fail...'
    exec { & $pwsh -NoProfile -NonInteractive -File $script -Mode Stub }
}

# Synopsis: Run all tests
Task Test TestModule, TestExercises

# Synopsis: Build the module for distribution
Task Build Clean, {
    Write-Build White "Building module to: $ModuleBuildPath"

    New-Item -Path $ModuleBuildPath -ItemType Directory -Force | Out-Null

    foreach ($file in $ModuleFiles) {
        $sourceFilePath = Join-Path -Path $SourcePath -ChildPath $file
        if (Test-Path $sourceFilePath) {
            Copy-Item -Path $sourceFilePath -Destination $ModuleBuildPath -Force
            Write-Build Gray "  Copied: $file"
        } else {
            Write-Build Yellow "  Warning: $file not found"
        }
    }

    foreach ($folder in $ModuleFolders) {
        $sourceFolderPath = Join-Path -Path $SourcePath -ChildPath $folder
        if (Test-Path $sourceFolderPath) {
            $destFolderPath = Join-Path -Path $ModuleBuildPath -ChildPath $folder
            Copy-Item -Path $sourceFolderPath -Destination $destFolderPath -Recurse -Force
            Write-Build Gray "  Copied: $folder/"
        } else {
            throw "Required folder $folder/ not found"
        }
    }

    Write-Build White 'Validating built module...'
    $builtManifest = Join-Path -Path $ModuleBuildPath -ChildPath "$ModuleName.psd1"
    $manifestData = Test-ModuleManifest -Path $builtManifest -ErrorAction Stop
    $exerciseCount = @(Get-ChildItem -Path (Join-Path $ModuleBuildPath 'Exercises') -Filter 'exercise.psd1' -Recurse).Count
    Write-Build Green "Module validated: $($manifestData.Name) v$($manifestData.Version) with $exerciseCount exercises"
}

# Synopsis: Publish module to PSGallery
Task Publish Build, {
    Write-Build White 'Publishing to PSGallery...'

    $apiKey = $env:PSGALLERY_API_KEY
    if (-not $apiKey) {
        throw 'PSGALLERY_API_KEY environment variable not set'
    }

    Publish-Module -Path $ModuleBuildPath -NuGetApiKey $apiKey -Repository PSGallery -ErrorAction Stop
    Write-Build Green 'Module published to PSGallery'
}

# Synopsis: Get module version from manifest
Task GetVersion {
    $version = (Import-PowerShellDataFile -Path $ManifestPath).ModuleVersion
    Write-Build Green "Module version: $version"

    if ($env:GITHUB_OUTPUT) {
        "version=$version" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    }
}

# Synopsis: Get release notes for the manifest version from CHANGELOG.md
Task GetReleaseNotes {
    $version = (Import-PowerShellDataFile -Path $ManifestPath).ModuleVersion
    $notes = Get-ChangelogSection -Version $version

    Write-Build White "Release Notes for v${version}:"
    Write-Build Gray $notes

    if ($env:GITHUB_OUTPUT) {
        $delimiter = "EOF_$([guid]::NewGuid().ToString('N'))"
        "release_notes<<$delimiter" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        $notes | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        $delimiter | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    }
}

# Synopsis: Regenerate docs/exercises.md from exercise metadata
Task Docs {
    & (Join-Path $SourcePath 'scripts/New-ExerciseCatalog.ps1')
}

# Synopsis: Default task - analyze, test and build
Task . Analyze, Test, Build

# Synopsis: CI task - full validation without publishing
Task CI Analyze, Test, Build

# Synopsis: Release task - validate, build and publish
Task Release Analyze, Test, Publish
