function Invoke-ParallelSquare {
    param(
        [Parameter(Mandatory)]
        [int[]]$Number,

        [ValidateRange(1, 64)]
        [int]$ThrottleLimit = 5,

        [ValidateRange(0, 10000)]
        [int]$DelayMilliseconds = 0
    )

    0..($Number.Count - 1) |
        ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
            if ($using:DelayMilliseconds -gt 0) { Start-Sleep -Milliseconds $using:DelayMilliseconds }
            $n = ($using:Number)[$_]
            [pscustomobject]@{ Index = $_; Number = $n; Square = $n * $n }
        } |
        Sort-Object -Property Index |
        Select-Object -Property Number, Square
}
