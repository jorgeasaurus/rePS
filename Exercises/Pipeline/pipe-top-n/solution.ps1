function Get-TopNumber {
    param(
        [Parameter(Mandatory)]
        [int[]]$Numbers,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$Count = 3
    )

    $Numbers | Sort-Object -Descending | Select-Object -First $Count
}
