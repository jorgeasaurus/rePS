param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Invoke-ParallelSquare' {
    It 'squares every number in input order' {
        $r = Invoke-ParallelSquare -Number 3, 1, 2 -ThrottleLimit 3
        $r.Number | Should -Be @(3, 1, 2)
        $r.Square | Should -Be @(9, 1, 4)
    }
    It 'keeps order even when items finish out of order' {
        $r = Invoke-ParallelSquare -Number (20..1) -ThrottleLimit 10
        $r.Number | Should -Be @(20..1)
    }
    It 'actually runs in parallel' {
        $elapsed = Measure-Command {
            $null = Invoke-ParallelSquare -Number (1..10) -ThrottleLimit 10 -DelayMilliseconds 600
        }
        $elapsed.TotalSeconds | Should -BeLessThan 4.5
    }
    It 'uses ForEach-Object -Parallel' {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($SolutionPath, [ref]$null, [ref]$null)
        $parallel = $ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.GetCommandName() -in 'ForEach-Object', 'foreach', '%' -and
                ($node.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -like 'Pa*' })
            }, $true)
        @($parallel).Count | Should -BeGreaterThan 0
    }
}
