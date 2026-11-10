param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-Greeting' {
    It 'greets by name' {
        Get-Greeting -Name 'Ada' | Should -BeExactly 'Hello, Ada!'
    }
    It 'defaults to World' {
        Get-Greeting | Should -BeExactly 'Hello, World!'
    }
    It 'accepts the name positionally' {
        Get-Greeting 'Grace' | Should -BeExactly 'Hello, Grace!'
    }
}
