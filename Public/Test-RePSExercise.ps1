function Test-RePSExercise {
    <#
    .SYNOPSIS
        Checks your workspace solution against the exercise's Pester tests.
    .DESCRIPTION
        Runs the tests in a separate pwsh process (so your code cannot affect this session)
        and records the result in your progress file. Passing after revealing the solution
        is recorded as 'Assisted'.
    .PARAMETER Id
        Exercise to test. Defaults to the current exercise.
    .PARAMETER Path
        Test a specific file instead of the workspace file.
    .PARAMETER Quiet
        Only show the summary line, not each test.
    .PARAMETER PassThru
        Output a result object.
    .EXAMPLE
        rept
        Tests the current exercise.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Id,

        [string]$Path,

        [switch]$Quiet,

        [switch]$PassThru
    )

    $progress = Read-RePSProgress
    $exercise = Resolve-RePSExercise -Id $Id -Progress $progress

    if (-not $Path) { $Path = Get-RePSWorkspacePath -Id $exercise.Id }
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Solution file '$Path' not found. Run Start-RePSExercise -Id $($exercise.Id) to create it."
    }
    $Path = (Resolve-Path -LiteralPath $Path).ProviderPath

    $resultFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath "reps-$([guid]::NewGuid()).json"
    $pwsh = (Get-Process -Id $PID).Path
    $runnerArgs = @(
        '-NoProfile', '-NonInteractive', '-File', $script:RunnerPath
        '-TestPath', $exercise.TestPath
        '-SolutionPath', $Path
        '-ResultPath', $resultFile
        '-Verbosity', $(if ($Quiet) { 'None' } else { 'Detailed' })
    )
    if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) { $runnerArgs += '-Ansi' }

    try {
        & $pwsh @runnerArgs | Out-Host
        if (-not (Test-Path -LiteralPath $resultFile)) {
            throw "Test runner did not produce a result (exit code $LASTEXITCODE)."
        }
        $summary = Get-Content -LiteralPath $resultFile -Raw | ConvertFrom-Json
    } finally {
        Remove-Item -LiteralPath $resultFile -Force -ErrorAction SilentlyContinue
    }

    $passed = $summary.Result -eq 'Passed' -and $summary.FailedCount -eq 0 -and $summary.PassedCount -gt 0

    $entry = Get-RePSProgressEntry -Progress $progress -Id $exercise.Id
    $entry.Attempts = [int]$entry.Attempts + 1
    $entry.LastAttempt = (Get-Date).ToString('o')
    if ($passed) {
        $entry.Status = if ($entry.SolutionShown) { 'Assisted' } else { 'Passed' }
        if (-not $entry.PassedAt) { $entry.PassedAt = $entry.LastAttempt }
    } elseif ($entry.Status -ne 'Passed') {
        $entry.Status = 'Failed'
    }
    Save-RePSProgress -Progress $progress

    Write-Host ''
    if ($passed) {
        $note = if ($entry.Status -eq 'Assisted') { ' (assisted)' } else { '' }
        Write-Host "  PASSED$note - $($summary.PassedCount)/$($summary.TotalCount) tests. Next rep: reps" -ForegroundColor Green
    } else {
        Write-Host "  NOT YET - $($summary.FailedCount) failing, $($summary.PassedCount) passing. Stuck? reph" -ForegroundColor Red
    }
    Write-Host ''

    if ($PassThru) {
        [pscustomobject]@{
            PSTypeName  = 'RePS.TestResult'
            Id          = $exercise.Id
            Passed      = $passed
            Status      = $entry.Status
            PassedCount = [int]$summary.PassedCount
            FailedCount = [int]$summary.FailedCount
            TotalCount  = [int]$summary.TotalCount
            Failed      = @($summary.Failed)
            Path        = $Path
        }
    }
}
