param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-Shout' {
    It 'returns the text unchanged by default' {
        Get-Shout -Text 'hello' | Should -BeExactly 'hello'
    }
    It 'shouts with -Loud' {
        Get-Shout -Text 'hello' -Loud | Should -BeExactly 'HELLO!'
    }
    It 'respects -Loud:$false' {
        Get-Shout -Text 'hi' -Loud:$false | Should -BeExactly 'hi'
    }
    It 'declares Loud as a [switch]' {
        (Get-Command Get-Shout).Parameters['Loud'].SwitchParameter | Should -BeTrue
    }
}
