function Get-ExistingPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Path
    )

    foreach ($item in $Path) {
        if (Test-Path -LiteralPath $item) {
            $item
        } else {
            Write-Error -Message "Path not found: $item" -Category ObjectNotFound -TargetObject $item
        }
    }
}
