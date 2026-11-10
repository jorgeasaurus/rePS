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
        $first = 1..100000 | Get-Square | Select-Object -First 1
        $first | Should -Be 1
    }
    It 'binds the Number parameter from the pipeline' {
        $p = (Get-Command Get-Square).Parameters['Number'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
        $p.ValueFromPipeline | Should -BeTrue
    }
}
