param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Compare-List' {
    It 'finds added and removed items' {
        $r = @(Compare-List -Reference 'a', 'b', 'c' -Difference 'b', 'c', 'd')
        $r.Count | Should -Be 2
        ($r | Where-Object Value -EQ 'a').Change | Should -Be 'Removed'
        ($r | Where-Object Value -EQ 'd').Change | Should -Be 'Added'
    }
    It 'sorts by Value' {
        (Compare-List -Reference 'z', 'm' -Difference 'a').Value | Should -Be @('a', 'm', 'z')
    }
    It 'outputs nothing for identical lists' {
        @(Compare-List -Reference 'x', 'y' -Difference 'y', 'x').Count | Should -Be 0
    }
    It 'handles an empty reference' {
        (Compare-List -Reference @() -Difference 'new').Change | Should -Be 'Added'
    }
}
