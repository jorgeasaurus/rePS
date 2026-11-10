@{
    Id           = 'adv-foreach-parallel'
    Title        = 'Parallel processing'
    Topic        = 'Advanced'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('parallel', 'runspaces', 'using-scope')
    FunctionName = 'Invoke-ParallelSquare'
    Author       = 'rePS'
    Prompt       = @'
Write Invoke-ParallelSquare so it squares every number in -Number using
ForEach-Object -Parallel, with at most -ThrottleLimit running at once.
Each item first sleeps -DelayMilliseconds (to simulate slow work).

Output objects with Number and Square properties, in the SAME ORDER as the input,
even though parallel results come back in any order.

    Invoke-ParallelSquare -Number 3, 1, 2 -ThrottleLimit 3
    # Number 3 Square 9, Number 1 Square 1, Number 2 Square 4
'@
    Hints        = @(
        'Parallel scriptblocks run in separate runspaces. Read outer variables with $using:DelayMilliseconds.'
        'Output order is not guaranteed. Pipe indexes (0..($Number.Count - 1)) through it and look up ($using:Number)[$_].'
        'Emit an Index with each result, then Sort-Object Index | Select-Object Number, Square.'
    )
}
