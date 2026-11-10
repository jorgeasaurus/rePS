function Show-RePSSolution {
    <#
    .SYNOPSIS
        Shows the reference solution for an exercise.
    .DESCRIPTION
        Displays one valid solution. If you have not passed the exercise yet, a later pass is
        recorded as 'Assisted' and the exercise stays eligible for Start-RePSExercise -Review.
    .PARAMETER Id
        Exercise id. Defaults to the current exercise.
    .PARAMETER PassThru
        Output the solution text instead of writing it to the host.
    .EXAMPLE
        repsol
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [string]$Id,

        [switch]$PassThru
    )

    $progress = Read-RePSProgress
    $exercise = Resolve-RePSExercise -Id $Id -Progress $progress
    $entry = Get-RePSProgressEntry -Progress $progress -Id $exercise.Id
    # Peeking after an unassisted pass does not downgrade it.
    if ($entry.Status -ne 'Passed') {
        $entry.SolutionShown = $true
        Save-RePSProgress -Progress $progress
    }

    $solution = Get-Content -LiteralPath $exercise.SolutionPath -Raw
    if ($PassThru) { return $solution }

    Write-Host ''
    Write-Host "  Reference solution: $($exercise.Title)" -ForegroundColor Cyan
    Write-Host '  (One valid approach - yours can differ and still pass.)' -ForegroundColor DarkGray
    Write-Host ''
    Write-Host $solution
}
