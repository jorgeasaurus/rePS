param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'New-Counter' {
    It 'returns a scriptblock' {
        New-Counter | Should -BeOfType [scriptblock]
    }
    It 'counts from 0 by 1 by default' {
        $c = New-Counter
        (& $c), (& $c), (& $c) | Should -Be @(0, 1, 2)
    }
    It 'honours Start and Step' {
        $c = New-Counter -Start 10 -Step 5
        (& $c), (& $c) | Should -Be @(10, 15)
    }
    It 'keeps independent state per counter' {
        $a = New-Counter
        $b = New-Counter -Start 100
        $null = & $a; $null = & $a
        & $b | Should -Be 100
        & $a | Should -Be 2
    }
    It 'does not depend on caller variables' {
        $c = New-Counter -Start 1
        $state = 'caller value'
        $Start = 999
        & $c | Should -Be 1
    }
}
