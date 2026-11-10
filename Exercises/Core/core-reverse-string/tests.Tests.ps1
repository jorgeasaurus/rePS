param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-ReversedString' {
    It 'reverses a word' {
        Get-ReversedString -InputString 'hello' | Should -BeExactly 'olleh'
    }
    It 'keeps spaces and case' {
        Get-ReversedString -InputString 'Power Shell' | Should -BeExactly 'llehS rewoP'
    }
    It 'handles a single character' {
        Get-ReversedString -InputString 'x' | Should -BeExactly 'x'
    }
    It 'returns an empty string for empty input' {
        Get-ReversedString -InputString '' | Should -BeExactly ''
    }
    It 'returns a [string]' {
        Get-ReversedString -InputString 'abc' | Should -BeOfType [string]
    }
}
