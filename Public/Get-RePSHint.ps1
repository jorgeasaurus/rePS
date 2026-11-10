function Get-RePSHint {
    <#
    .SYNOPSIS
        Reveals the next hint for an exercise.
    .DESCRIPTION
        Each call reveals one more hint and shows every hint revealed so far.
    .PARAMETER Id
        Exercise id. Defaults to the current exercise.
    .EXAMPLE
        reph
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [string]$Id
    )

    $progress = Read-RePSProgress
    $exercise = Resolve-RePSExercise -Id $Id -Progress $progress
    $entry = Get-RePSProgressEntry -Progress $progress -Id $exercise.Id

    $total = $exercise.Hints.Count
    $used = [int]$entry.HintsUsed
    if ($used -lt $total) {
        $used++
        $entry.HintsUsed = $used
        Save-RePSProgress -Progress $progress
    }

    Write-Host ''
    for ($i = 0; $i -lt $used; $i++) {
        Write-Host "  Hint $($i + 1)/${total}: $($exercise.Hints[$i])" -ForegroundColor Yellow
    }
    if ($used -ge $total) {
        Write-Host '  No more hints. Show-RePSSolution (repsol) reveals the answer.' -ForegroundColor DarkGray
    }
    Write-Host ''
}
