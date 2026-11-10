function New-Counter {
    [OutputType([scriptblock])]
    param(
        [int]$Start = 0,
        [int]$Step = 1
    )

    $state = @{ Next = $Start; Step = $Step }
    {
        $current = $state.Next
        $state.Next += $state.Step
        $current
    }.GetNewClosure()
}
