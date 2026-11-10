function Invoke-ParallelSquare {
    param(
        [Parameter(Mandatory)]
        [int[]]$Number,

        [ValidateRange(1, 64)]
        [int]$ThrottleLimit = 5,

        [ValidateRange(0, 10000)]
        [int]$DelayMilliseconds = 0
    )

    # TODO: use ForEach-Object -Parallel; keep the input order
    throw 'Not implemented'
}
