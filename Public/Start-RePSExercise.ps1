function Start-RePSExercise {
    <#
    .SYNOPSIS
        Starts a random (or specific) rePS exercise.
    .DESCRIPTION
        Picks an exercise matching the filters and the current OS, writes its stub to
        ~/.reps/workspace/<id>.ps1, shows the brief, and opens the file in VS Code when
        the 'code' command is available. An existing workspace file is resumed, not
        overwritten, unless -Force is used.
    .PARAMETER Id
        Start a specific exercise instead of a random one.
    .PARAMETER Topic
        Limit the random pick to one or more topics.
    .PARAMETER Level
        Limit the random pick to one or more difficulty levels (1-3).
    .PARAMETER Tag
        Limit the random pick to exercises with any of these tags.
    .PARAMETER Unseen
        Only pick exercises you have never started.
    .PARAMETER Review
        Only pick exercises you failed or solved with the solution revealed.
    .PARAMETER NoOpen
        Do not open the workspace file in an editor.
    .PARAMETER Force
        Overwrite an existing workspace file with a fresh stub.
    .PARAMETER PassThru
        Output the exercise object.
    .EXAMPLE
        reps
        Starts a random exercise.
    .EXAMPLE
        Start-RePSExercise -Topic Pipeline -Level 1, 2 -Unseen
        Starts a random unseen beginner/intermediate pipeline exercise.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Random')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', Position = 0)]
        [string]$Id,

        [Parameter(ParameterSetName = 'Random')]
        [ValidateSet('Core', 'Pipeline', 'Functions', 'Advanced')]
        [string[]]$Topic,

        [Parameter(ParameterSetName = 'Random')]
        [ValidateRange(1, 3)]
        [int[]]$Level,

        [Parameter(ParameterSetName = 'Random')]
        [string[]]$Tag,

        [Parameter(ParameterSetName = 'Random')]
        [switch]$Unseen,

        [Parameter(ParameterSetName = 'Random')]
        [switch]$Review,

        [switch]$NoOpen,

        [switch]$Force,

        [switch]$PassThru
    )

    $progress = Read-RePSProgress

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        $exercise = Resolve-RePSExercise -Id $Id -Progress $progress
    } else {
        $platform = Get-RePSPlatform
        $pool = @(Get-RePSExerciseData | Where-Object { $platform -in $_.Platforms })
        if ($Topic) { $pool = @($pool | Where-Object Topic -In $Topic) }
        if ($Level) { $pool = @($pool | Where-Object Level -In $Level) }
        if ($Tag) { $pool = @($pool | Where-Object { $_.Tags | Where-Object { $_ -in $Tag } }) }
        if ($Unseen) { $pool = @($pool | Where-Object { -not $progress.Exercises.ContainsKey($_.Id) }) }
        if ($Review) {
            $pool = @($pool | Where-Object {
                    $entry = $progress.Exercises[$_.Id]
                    $entry -and $entry.Status -in 'Failed', 'Assisted'
                })
        }

        if ($pool.Count -eq 0) {
            Write-Warning 'No exercises match those filters. Try fewer filters, or Get-RePSExercise to browse.'
            return
        }
        if ($pool.Count -gt 1 -and $progress.Current) {
            $pool = @($pool | Where-Object Id -NE $progress.Current)
        }
        $exercise = $pool | Get-Random
    }

    $workspaceFile = Get-RePSWorkspacePath -Id $exercise.Id
    $resumed = (Test-Path -LiteralPath $workspaceFile) -and -not $Force
    if (-not $resumed) {
        New-RePSWorkspaceContent -Exercise $exercise | Set-Content -LiteralPath $workspaceFile -Encoding utf8 -NoNewline
    }

    $null = Get-RePSProgressEntry -Progress $progress -Id $exercise.Id
    $progress.Current = $exercise.Id
    Save-RePSProgress -Progress $progress

    Write-RePSPrompt -Exercise $exercise
    $verb = if ($resumed) { 'Resuming' } else { 'Workspace' }
    Write-Host "  ${verb}: $workspaceFile" -ForegroundColor Yellow
    Write-Host '  Edit the file, then run Test-RePSExercise (rept). Stuck? Get-RePSHint (reph).' -ForegroundColor DarkGray
    Write-Host ''

    Show-RePSUpdateNotice

    if (-not $NoOpen) { $null = Open-RePSFile -Path $workspaceFile }

    if ($PassThru) { Get-RePSExercise -Id $exercise.Id }
}
