param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-ArraySum' {
    It 'adds positive numbers' {
        Get-ArraySum -Numbers 1, 2, 3 | Should -Be 6
    }
    It 'handles negatives' {
        Get-ArraySum -Numbers 10, -4, -6 | Should -Be 0
    }
    It 'returns 0 for an empty array' {
        Get-ArraySum -Numbers @() | Should -Be 0
    }
    It 'handles a single number' {
        Get-ArraySum -Numbers 42 | Should -Be 42
    }
}
