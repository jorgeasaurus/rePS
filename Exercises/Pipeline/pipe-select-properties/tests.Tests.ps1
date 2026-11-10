param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Select-UserSummary' {
    BeforeAll {
        $users = @(
            [pscustomobject]@{ Id = 1; Name = 'Ada'; Email = 'ada@example.com'; Department = 'R&D' }
            [pscustomobject]@{ Id = 2; Name = 'Linus'; Email = 'linus@example.com'; Department = 'Ops' }
        )
    }
    It 'keeps only Name and Email' {
        $result = Select-UserSummary -User $users
        $result[0].PSObject.Properties.Name | Should -Be @('Name', 'Email')
    }
    It 'keeps the values' {
        $result = Select-UserSummary -User $users
        $result[1].Name | Should -Be 'Linus'
        $result[1].Email | Should -Be 'linus@example.com'
    }
    It 'accepts pipeline input' {
        $result = @($users | Select-UserSummary)
        $result.Count | Should -Be 2
        $result[0].Name | Should -Be 'Ada'
    }
}
