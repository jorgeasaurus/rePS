param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-LetterGrade' {
    It 'returns <Expected> for <Score>' -ForEach @(
        @{ Score = 100; Expected = 'A' }
        @{ Score = 90; Expected = 'A' }
        @{ Score = 89; Expected = 'B' }
        @{ Score = 80; Expected = 'B' }
        @{ Score = 75; Expected = 'C' }
        @{ Score = 60; Expected = 'D' }
        @{ Score = 59; Expected = 'F' }
        @{ Score = 0; Expected = 'F' }
    ) {
        Get-LetterGrade -Score $Score | Should -BeExactly $Expected
    }
    It 'returns exactly one value' {
        @(Get-LetterGrade -Score 95).Count | Should -Be 1
    }
    It 'throws for <Score>' -ForEach @(
        @{ Score = 101 }
        @{ Score = -1 }
    ) {
        { Get-LetterGrade -Score $Score } | Should -Throw
    }
}
