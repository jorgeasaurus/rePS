param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Test-Palindrome' {
    It 'detects a simple palindrome' {
        Test-Palindrome -Text 'racecar' | Should -BeTrue
    }
    It 'ignores case' {
        Test-Palindrome -Text 'RaceCar' | Should -BeTrue
    }
    It 'ignores spaces and punctuation' {
        Test-Palindrome -Text 'A man, a plan, a canal: Panama' | Should -BeTrue
    }
    It 'rejects a non-palindrome' {
        Test-Palindrome -Text 'PowerShell' | Should -BeFalse
    }
    It 'handles digits' {
        Test-Palindrome -Text '12321' | Should -BeTrue
        Test-Palindrome -Text '12345' | Should -BeFalse
    }
    It 'returns a [bool]' {
        Test-Palindrome -Text 'abc' | Should -BeOfType [bool]
    }
}
