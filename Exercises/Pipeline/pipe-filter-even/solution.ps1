function Get-EvenNumber {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [int[]]$Numbers
    )

    $Numbers | Where-Object { $_ % 2 -eq 0 }
}
