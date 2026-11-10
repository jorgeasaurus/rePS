function Get-ArraySum {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [int[]]$Numbers
    )

    $total = 0
    foreach ($number in $Numbers) {
        $total += $number
    }
    $total
}
