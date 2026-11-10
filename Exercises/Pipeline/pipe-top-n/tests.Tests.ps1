param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-TopNumber' {
    It 'returns the largest values, largest first' {
        Get-TopNumber -Numbers 5, 1, 9, 3 -Count 2 | Should -Be @(9, 5)
    }
    It 'defaults to 3 items' {
        @(Get-TopNumber -Numbers (1..10)).Count | Should -Be 3
    }
    It 'returns everything sorted when Count exceeds the input' {
        Get-TopNumber -Numbers 2, 7 -Count 10 | Should -Be @(7, 2)
    }
    It 'keeps duplicates' {
        Get-TopNumber -Numbers 4, 4, 1 -Count 2 | Should -Be @(4, 4)
    }
}
