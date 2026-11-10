param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Test-EmailAddress' {
    It 'accepts <Address>' -ForEach @(
        @{ Address = 'ada@example.com' }
        @{ Address = 'a.b+tag@sub.example.co.uk' }
        @{ Address = 'X@Y.IO' }
    ) {
        Test-EmailAddress -Address $Address | Should -BeTrue
    }
    It 'rejects <Address>' -ForEach @(
        @{ Address = 'no-at-sign.com' }
        @{ Address = 'two@@example.com' }
        @{ Address = 'a@b@example.com' }
        @{ Address = 'space in@example.com' }
        @{ Address = '@example.com' }
        @{ Address = 'ada@localhost' }
        @{ Address = 'ada@example.c' }
        @{ Address = 'ada@example.com ' }
        @{ Address = '' }
    ) {
        Test-EmailAddress -Address $Address | Should -BeFalse
    }
}
