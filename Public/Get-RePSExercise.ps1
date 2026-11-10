function Get-RePSExercise {
    <#
    .SYNOPSIS
        Lists rePS exercises and your status on each.
    .DESCRIPTION
        Browses the catalog without starting anything. By default only exercises that run
        on the current OS are listed; use -AllPlatforms to include the rest.
    .PARAMETER Id
        Return a specific exercise.
    .PARAMETER Topic
        Filter by topic.
    .PARAMETER Level
        Filter by difficulty level (1-3).
    .PARAMETER Tag
        Filter by tag.
    .PARAMETER Status
        Filter by your progress status.
    .PARAMETER AllPlatforms
        Include exercises that do not run on the current OS.
    .EXAMPLE
        Get-RePSExercise -Topic Core -Level 1
    .EXAMPLE
        Get-RePSExercise -Status Failed, Assisted
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Id,

        [ValidateSet('Core', 'Pipeline', 'Functions', 'Advanced')]
        [string[]]$Topic,

        [ValidateRange(1, 3)]
        [int[]]$Level,

        [string[]]$Tag,

        [ValidateSet('Unseen', 'Started', 'Failed', 'Passed', 'Assisted')]
        [string[]]$Status,

        [switch]$AllPlatforms
    )

    $progress = Read-RePSProgress
    $platform = Get-RePSPlatform
    $exercises = Get-RePSExerciseData

    if ($Id) { $exercises = @($exercises | Where-Object Id -EQ $Id) }
    elseif (-not $AllPlatforms) { $exercises = @($exercises | Where-Object { $platform -in $_.Platforms }) }
    if ($Topic) { $exercises = @($exercises | Where-Object Topic -In $Topic) }
    if ($Level) { $exercises = @($exercises | Where-Object Level -In $Level) }
    if ($Tag) { $exercises = @($exercises | Where-Object { $_.Tags | Where-Object { $_ -in $Tag } }) }

    foreach ($exercise in $exercises) {
        $entry = $progress.Exercises[$exercise.Id]
        $exerciseStatus = if ($entry) { $entry.Status } else { 'Unseen' }
        if ($Status -and $exerciseStatus -notin $Status) { continue }

        [pscustomobject]@{
            PSTypeName = 'RePS.Exercise'
            Id         = $exercise.Id
            Title      = $exercise.Title
            Topic      = $exercise.Topic
            Level      = $exercise.Level
            Status     = $exerciseStatus
            Tags       = $exercise.Tags
            Platforms  = $exercise.Platforms
            Attempts   = if ($entry) { [int]$entry.Attempts } else { 0 }
            HintsUsed  = if ($entry) { [int]$entry.HintsUsed } else { 0 }
            Prompt     = $exercise.Prompt
        }
    }
}
