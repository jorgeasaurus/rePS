param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Invoke-WithRetry' {
    BeforeEach {
        $script:calls = 0
    }
    It 'returns the output when the first attempt works' {
        Invoke-WithRetry -ScriptBlock { 'ok' } | Should -Be 'ok'
    }
    It 'retries until success' {
        $result = Invoke-WithRetry -MaxAttempts 5 -ScriptBlock {
            $script:calls++
            if ($script:calls -lt 3) { throw 'flaky' }
            'done'
        }
        $result | Should -Be 'done'
        $script:calls | Should -Be 3
    }
    It 'stops after MaxAttempts' {
        { Invoke-WithRetry -MaxAttempts 4 -ScriptBlock { $script:calls++; throw 'nope' } } | Should -Throw
        $script:calls | Should -Be 4
    }
    It 'rethrows the original exception type and message' {
        $sb = { throw [System.TimeoutException]::new('timed out') }
        { Invoke-WithRetry -MaxAttempts 2 -ScriptBlock $sb } | Should -Throw -ExceptionType ([System.TimeoutException]) -ExpectedMessage 'timed out'
    }
    It 'writes a verbose message per failure' {
        $sb = { $script:calls++; if ($script:calls -lt 3) { throw 'x' }; 1 }
        $verbose = Invoke-WithRetry -MaxAttempts 3 -ScriptBlock $sb -Verbose 4>&1 |
            Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
        @($verbose).Count | Should -Be 2
    }
}
