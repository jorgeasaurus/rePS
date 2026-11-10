param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-FizzBuzz' {
    It 'returns Max items' {
        @(Get-FizzBuzz -Max 20).Count | Should -Be 20
    }
    It 'produces the first 15 correctly' {
        $expected = '1', '2', 'Fizz', '4', 'Buzz', 'Fizz', '7', '8', 'Fizz', 'Buzz', '11', 'Fizz', '13', '14', 'FizzBuzz'
        Get-FizzBuzz -Max 15 | Should -Be $expected
    }
    It 'outputs strings, not integers' {
        (Get-FizzBuzz -Max 1) | Should -BeOfType [string]
    }
    It 'handles Max = 1' {
        Get-FizzBuzz -Max 1 | Should -BeExactly '1'
    }
}
