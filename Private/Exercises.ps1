function Get-RePSPlatform {
    <#
    .SYNOPSIS
        Returns the current platform name as used in exercise metadata.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($IsWindows) { 'Windows' } elseif ($IsMacOS) { 'MacOS' } else { 'Linux' }
}

function Get-RePSExerciseData {
    <#
    .SYNOPSIS
        Loads every exercise.psd1 under Exercises/ (cached per session).
    #>
    [CmdletBinding()]
    param(
        [string]$Path = $script:ExercisesPath,

        [switch]$Refresh
    )

    if ($script:ExerciseCache -and -not $Refresh -and $Path -eq $script:ExercisesPath) {
        return $script:ExerciseCache
    }

    $exercises = foreach ($manifest in Get-ChildItem -Path $Path -Filter 'exercise.psd1' -Recurse -File) {
        $data = Import-PowerShellDataFile -LiteralPath $manifest.FullName
        $folder = $manifest.Directory.FullName
        [pscustomobject]@{
            PSTypeName   = 'RePS.ExerciseData'
            Id           = $data.Id
            Title        = $data.Title
            Topic        = $data.Topic
            Level        = [int]$data.Level
            Platforms    = @($data.Platforms)
            Tags         = @($data.Tags)
            FunctionName = $data.FunctionName
            Prompt       = $data.Prompt
            Hints        = @($data.Hints)
            Author       = $data.Author
            Folder       = $folder
            StubPath     = Join-Path $folder 'stub.ps1'
            SolutionPath = Join-Path $folder 'solution.ps1'
            TestPath     = Join-Path $folder 'tests.Tests.ps1'
        }
    }
    $exercises = @($exercises | Sort-Object Topic, Level, Id)

    if ($Path -eq $script:ExercisesPath) { $script:ExerciseCache = $exercises }
    $exercises
}

function Resolve-RePSExercise {
    <#
    .SYNOPSIS
        Resolves an exercise by id, or the current exercise from progress when no id is given.
    #>
    [CmdletBinding()]
    param(
        [string]$Id,

        [hashtable]$Progress = (Read-RePSProgress)
    )

    if (-not $Id) {
        $Id = $Progress.Current
        if (-not $Id) {
            throw 'No current exercise. Run Start-RePSExercise (alias: reps) first, or pass -Id.'
        }
    }

    $exercise = Get-RePSExerciseData | Where-Object Id -EQ $Id
    if (-not $exercise) {
        throw "Exercise '$Id' not found. Run Get-RePSExercise to list available exercises."
    }
    $exercise
}

function Open-RePSFile {
    <#
    .SYNOPSIS
        Opens a file in VS Code when the 'code' command is available.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if ($env:REPS_NO_OPEN) { return $false }
    $code = Get-Command -Name 'code' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $code) { return $false }
    & $code.Source $Path
    $true
}

function Write-RePSPrompt {
    <#
    .SYNOPSIS
        Writes the exercise brief to the host.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Exercise
    )

    $stars = ('*' * $Exercise.Level).PadRight(3, '.')
    Write-Host ''
    Write-Host "  $($Exercise.Title)" -ForegroundColor Cyan
    Write-Host "  [$($Exercise.Topic)] level $stars  id: $($Exercise.Id)" -ForegroundColor DarkGray
    Write-Host ''
    foreach ($line in ($Exercise.Prompt.Trim() -split '\r?\n')) {
        Write-Host "  $line"
    }
    Write-Host ''
}

function New-RePSWorkspaceContent {
    <#
    .SYNOPSIS
        Builds the workspace file text: a comment header with the brief, followed by the stub.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        $Exercise
    )

    $promptLines = ($Exercise.Prompt.Trim() -split '\r?\n') -replace '#>', '# >'
    $header = @(
        '<#'
        "    rePS exercise: $($Exercise.Title)"
        "    Id: $($Exercise.Id)  |  Topic: $($Exercise.Topic)  |  Level: $($Exercise.Level)"
        ''
        ($promptLines | ForEach-Object { "    $_".TrimEnd() })
        ''
        '    Check your work:  Test-RePSExercise   (alias: rept)'
        '    Need a nudge?     Get-RePSHint        (alias: reph)'
        '#>'
        ''
    ) -join [Environment]::NewLine

    $header + (Get-Content -LiteralPath $Exercise.StubPath -Raw)
}
