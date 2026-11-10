param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-EvenNumber' {
    It 'keeps only even numbers in order' {
        Get-EvenNumber -Numbers (1..10) | Should -Be @(2, 4, 6, 8, 10)
    }
    It 'treats negatives and zero correctly' {
        Get-EvenNumber -Numbers -3, -2, 0, 7 | Should -Be @(-2, 0)
    }
    It 'outputs nothing when there are no even numbers' {
        @(Get-EvenNumber -Numbers 1, 3, 5).Count | Should -Be 0
    }
    It 'outputs nothing for an empty array' {
        @(Get-EvenNumber -Numbers @()).Count | Should -Be 0
    }
}
