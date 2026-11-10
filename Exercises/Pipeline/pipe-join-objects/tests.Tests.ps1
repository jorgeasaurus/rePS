param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Join-Object' {
    BeforeAll {
        $users = @(
            [pscustomobject]@{ Id = 1; Name = 'Ada'; Source = 'users' }
            [pscustomobject]@{ Id = 2; Name = 'Linus'; Source = 'users' }
            [pscustomobject]@{ Id = 3; Name = 'Grace'; Source = 'users' }
        )
        $orders = @(
            [pscustomobject]@{ Id = 1; Total = 30; Source = 'orders' }
            [pscustomobject]@{ Id = 1; Total = 12; Source = 'orders' }
            [pscustomobject]@{ Id = 3; Total = 7; Source = 'orders' }
            [pscustomobject]@{ Id = 9; Total = 99; Source = 'orders' }
        )
        $joined = @(Join-Object -Left $users -Right $orders -On Id)
    }
    It 'returns one row per match (inner join)' {
        $joined.Count | Should -Be 3
    }
    It 'excludes rows without a match on either side' {
        $joined.Id | Should -Not -Contain 2
        $joined.Id | Should -Not -Contain 9
    }
    It 'includes properties from both sides' {
        $row = $joined | Where-Object Id -EQ 3
        $row.Name | Should -Be 'Grace'
        $row.Total | Should -Be 7
    }
    It 'lets Left win on conflicting properties' {
        $joined[0].Source | Should -Be 'users'
    }
    It 'handles thousands of rows quickly' {
        $big = 1..5000 | ForEach-Object { [pscustomobject]@{ Id = $_; V = $_ } }
        $elapsed = Measure-Command { $null = Join-Object -Left $big -Right $big -On Id }
        $elapsed.TotalSeconds | Should -BeLessThan 10
    }
}
