function Set-RePSConfiguration {
    <#
    .SYNOPSIS
        Changes rePS settings.
    .DESCRIPTION
        Sets how often rePS checks the PowerShell Gallery for a newer version. The check
        runs in a background job when the module is imported, so it never slows you down.
        When a newer version exists, Start-RePSExercise shows a one-line notice (once per
        session). rePS never updates itself: you decide when to run Update-Module.

        Checks are also skipped when $env:REPS_NO_UPDATE_CHECK is set or when running in CI.
    .PARAMETER UpdateCheck
        How often to check for updates: Never, Daily, Weekly (default), BiWeekly or Monthly.
    .EXAMPLE
        Set-RePSConfiguration -UpdateCheck Daily
    .EXAMPLE
        Set-RePSConfiguration -UpdateCheck Never
        Turns update notices off.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Never', 'Daily', 'Weekly', 'BiWeekly', 'Monthly')]
        [string]$UpdateCheck
    )

    $config = Get-RePSConfig
    if ($PSCmdlet.ShouldProcess('rePS configuration', "Set UpdateCheck to $UpdateCheck")) {
        $config.UpdateCheck = $UpdateCheck
        Save-RePSConfig -Config $config
    }
}
