param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Split-Array' {
    It 'creates the right number of chunks' {
        @(Split-Array -InputObject (1..5) -Size 2).Count | Should -Be 3
    }
    It 'keeps items in order inside each chunk' {
        $chunks = @(Split-Array -InputObject (1..5) -Size 2)
        $chunks[0] -join ',' | Should -Be '1,2'
        $chunks[1] -join ',' | Should -Be '3,4'
        @($chunks[2]) -join ',' | Should -Be '5'
    }
    It 'returns one chunk (not its items) when everything fits' {
        $chunks = @(Split-Array -InputObject 1, 2 -Size 5)
        $chunks.Count | Should -Be 1
        $chunks[0].Count | Should -Be 2
    }
    It 'handles an exact multiple' {
        $chunks = @(Split-Array -InputObject (1..6) -Size 3)
        $chunks.Count | Should -Be 2
        $chunks[1] -join ',' | Should -Be '4,5,6'
    }
    It 'handles size 1' {
        @(Split-Array -InputObject 'a', 'b', 'c' -Size 1).Count | Should -Be 3
    }
}
