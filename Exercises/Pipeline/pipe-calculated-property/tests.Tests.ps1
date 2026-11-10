param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Add-FullName' {
    BeforeAll {
        $people = @(
            [pscustomobject]@{ First = 'Ada'; Last = 'Lovelace' }
            [pscustomobject]@{ First = 'Alan'; Last = 'Turing' }
        )
    }
    It 'adds FullName' {
        (Add-FullName -Person $people[0]).FullName | Should -BeExactly 'Ada Lovelace'
    }
    It 'keeps First and Last' {
        $r = Add-FullName -Person $people[1]
        $r.First | Should -Be 'Alan'
        $r.Last | Should -Be 'Turing'
    }
    It 'works on the pipeline' {
        ($people | Add-FullName).FullName | Should -Be @('Ada Lovelace', 'Alan Turing')
    }
    It 'outputs First, Last, FullName in that order' {
        (Add-FullName -Person $people[0]).PSObject.Properties.Name | Should -Be @('First', 'Last', 'FullName')
    }
}
