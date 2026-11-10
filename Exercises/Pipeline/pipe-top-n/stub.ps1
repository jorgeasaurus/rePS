function Get-TopNumber {
    param(
        [Parameter(Mandatory)]
        [int[]]$Numbers,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$Count = 3
    )

    # TODO: output the $Count largest numbers, largest first
    throw 'Not implemented'
}
