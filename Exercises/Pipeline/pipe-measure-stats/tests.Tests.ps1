param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-NumberStatistic' {
    BeforeAll {
        $stats = Get-NumberStatistic -Numbers 2, 4, 6, 8
    }
    It 'returns a single object' {
        @(Get-NumberStatistic -Numbers 1, 2).Count | Should -Be 1
    }
    It 'computes Count and Sum' {
        $stats.Count | Should -Be 4
        $stats.Sum | Should -Be 20
    }
    It 'computes Minimum and Maximum' {
        $stats.Minimum | Should -Be 2
        $stats.Maximum | Should -Be 8
    }
    It 'computes Average' {
        $stats.Average | Should -Be 5
    }
    It 'has exactly the five expected properties' {
        $stats.PSObject.Properties.Name | Sort-Object | Should -Be @('Average', 'Count', 'Maximum', 'Minimum', 'Sum')
    }
}
