param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-NumberList' {
    It 'returns a List[int]' {
        $r = Get-NumberList -Count 3
        $r | Should -Not -BeNullOrEmpty
        $r.GetType() | Should -Be ([System.Collections.Generic.List[int]])
    }
    It 'contains 1..Count' {
        $r = Get-NumberList -Count 5
        $r.Count | Should -Be 5
        $r[0] | Should -Be 1
        $r[4] | Should -Be 5
    }
    It 'returns a list (not a lone int) for Count 1' {
        $r = Get-NumberList -Count 1
        $r.GetType() | Should -Be ([System.Collections.Generic.List[int]])
    }
    It 'returns an empty list (not $null) for Count 0' {
        $r = Get-NumberList -Count 0
        $null -eq $r | Should -BeFalse
        $r.Count | Should -Be 0
    }
    It 'is fast for large counts' {
        (Measure-Command { $null = Get-NumberList -Count 200000 }).TotalSeconds | Should -BeLessThan 5
    }
}
