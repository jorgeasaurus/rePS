function Get-RePSProgress {
    <#
    .SYNOPSIS
        Summarizes your rePS progress per topic.
    .DESCRIPTION
        Counts exercises by status for each topic available on the current OS.
        Use Get-RePSExercise -Status to see the individual exercises.
    .EXAMPLE
        repp
    #>
    [CmdletBinding()]
    param()

    $exercises = @(Get-RePSExercise)
    foreach ($group in ($exercises | Group-Object Topic)) {
        $counts = $group.Group | Group-Object Status -AsHashTable -AsString
        $count = { param($name) if ($counts -and $counts.ContainsKey($name)) { $counts[$name].Count } else { 0 } }
        [pscustomobject]@{
            PSTypeName = 'RePS.Progress'
            Topic      = $group.Name
            Total      = $group.Count
            Passed     = & $count 'Passed'
            Assisted   = & $count 'Assisted'
            Failed     = & $count 'Failed'
            Started    = & $count 'Started'
            Unseen     = & $count 'Unseen'
        }
    }
}
