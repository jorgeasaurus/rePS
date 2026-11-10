function Remove-StaleFile {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateRange(0, 36500)]
        [int]$Days
    )

    $cutoff = (Get-Date).AddDays(-$Days)
    foreach ($file in Get-ChildItem -LiteralPath $Path -File) {
        if ($file.LastWriteTime -ge $cutoff) { continue }
        if ($PSCmdlet.ShouldProcess($file.FullName, 'Delete stale file')) {
            Remove-Item -LiteralPath $file.FullName -Force
            $file
        }
    }
}
