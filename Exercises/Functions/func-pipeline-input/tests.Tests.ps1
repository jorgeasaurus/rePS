param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-Square' {
    It 'squares piped numbers' {
        1..3 | Get-Square | Should -Be @(1, 4, 9)
    }
    It 'squares an array passed by name' {
        Get-Square -Number 4, 5 | Should -Be @(16, 25)
    }
    It 'streams (first result arrives before input ends)' {
        $script:consumed = 0
        $first = 1..1000 | ForEach-Object { $script:consumed++; $_ } | Get-Square | Select-Object -First 1
        $first | Should -Be 1
        $script:consumed | Should -BeLessThan 1000 -Because 'a buffering function (end block only) reads all input before emitting anything'
    }
    It 'binds the Number parameter from the pipeline' {
        $p = (Get-Command Get-Square).Parameters['Number'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
        $p.ValueFromPipeline | Should -BeTrue
    }
}
