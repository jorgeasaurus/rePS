param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Invoke-SafeDivide' {
    It 'divides' {
        Invoke-SafeDivide -Dividend 10 -Divisor 2 | Should -Be 5
    }
    It 'returns fractional results' {
        Invoke-SafeDivide -Dividend 1 -Divisor 4 | Should -Be 0.25
    }
    It 'does not throw on divide by zero' {
        { Invoke-SafeDivide -Dividend 1 -Divisor 0 -WarningAction SilentlyContinue } | Should -Not -Throw
    }
    It 'returns $null on divide by zero' {
        Invoke-SafeDivide -Dividend 1 -Divisor 0 -WarningAction SilentlyContinue | Should -BeNullOrEmpty
    }
    It 'writes a warning mentioning divide by zero' {
        $null = Invoke-SafeDivide -Dividend 1 -Divisor 0 -WarningVariable warnings -WarningAction SilentlyContinue
        $warnings | Should -Not -BeNullOrEmpty
        "$warnings" | Should -Match 'divide by zero'
    }
    It 'does not warn on success' {
        $null = Invoke-SafeDivide -Dividend 4 -Divisor 2 -WarningVariable warnings
        $warnings | Should -BeNullOrEmpty
    }
}
