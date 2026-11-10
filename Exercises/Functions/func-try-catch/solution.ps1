function Invoke-SafeDivide {
    param(
        [Parameter(Mandatory)]
        [int]$Dividend,

        [Parameter(Mandatory)]
        [int]$Divisor
    )

    try {
        $Dividend / $Divisor
    } catch [System.DivideByZeroException] {
        Write-Warning "Cannot divide by zero ($Dividend / $Divisor)."
        $null
    }
}
