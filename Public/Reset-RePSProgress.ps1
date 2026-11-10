function Reset-RePSProgress {
    <#
    .SYNOPSIS
        Clears progress for one exercise or for all of them.
    .PARAMETER Id
        Exercise id to reset. Omit to reset everything.
    .PARAMETER IncludeWorkspace
        Also delete the matching workspace file(s).
    .EXAMPLE
        Reset-RePSProgress -Id core-reverse-string -IncludeWorkspace
    .EXAMPLE
        Reset-RePSProgress -Confirm:$false
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Position = 0)]
        [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)+$')]
        [string]$Id,

        [switch]$IncludeWorkspace
    )

    $progress = Read-RePSProgress
    $target = if ($Id) { "exercise '$Id'" } else { 'all exercises' }
    if (-not $PSCmdlet.ShouldProcess($target, 'Reset rePS progress')) { return }

    if ($Id) {
        $progress.Exercises.Remove($Id)
        if ($progress.Current -eq $Id) { $progress.Current = $null }
        if ($IncludeWorkspace) {
            Remove-Item -LiteralPath (Get-RePSWorkspacePath -Id $Id) -Force -ErrorAction SilentlyContinue
        }
    } else {
        $progress.Exercises = @{}
        $progress.Current = $null
        if ($IncludeWorkspace) {
            Get-ChildItem -LiteralPath (Get-RePSWorkspacePath) -Filter '*.ps1' -File | Remove-Item -Force
        }
    }
    Save-RePSProgress -Progress $progress
}
