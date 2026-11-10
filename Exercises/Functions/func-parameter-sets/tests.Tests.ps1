param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Convert-Temperature' {
    It 'converts Celsius to Fahrenheit' {
        Convert-Temperature -Celsius 100 | Should -Be 212
        Convert-Temperature -Celsius -40 | Should -Be -40
    }
    It 'converts Fahrenheit to Celsius' {
        Convert-Temperature -Fahrenheit 32 | Should -Be 0
        Convert-Temperature -Fahrenheit 100 | Should -Be 37.78
    }
    It 'rejects both parameters together' {
        { Convert-Temperature -Celsius 1 -Fahrenheit 1 } | Should -Throw
    }
    It 'defines two parameter sets' {
        (Get-Command Convert-Temperature).ParameterSets.Count | Should -Be 2
    }
}
