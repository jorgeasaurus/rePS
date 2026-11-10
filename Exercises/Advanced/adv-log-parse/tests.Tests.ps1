param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'ConvertFrom-LogLine' {
    BeforeAll {
        $lines = @(
            '2026-01-05 12:00:01 [ERROR] Disk full on C:'
            'garbage line'
            '2026-01-05 12:00:02 [info] Service started [pid 42]'
            ''
            '2026-13-99 bad date [WARN] nope'
            '2026-02-30 12:00:00 [WARN] impossible date'
        )
        $entries = @($lines | ConvertFrom-LogLine)
    }
    It 'skips lines that do not match' {
        $entries.Count | Should -Be 2
    }
    It 'parses the timestamp as [datetime]' {
        $entries[0].Timestamp | Should -BeOfType [datetime]
        $entries[0].Timestamp | Should -Be ([datetime]::new(2026, 1, 5, 12, 0, 1))
    }
    It 'uppercases the level' {
        $entries.Level | Should -Be @('ERROR', 'INFO')
    }
    It 'keeps the full message, including brackets and colons' {
        $entries[0].Message | Should -BeExactly 'Disk full on C:'
        $entries[1].Message | Should -BeExactly 'Service started [pid 42]'
    }
    It 'accepts -Line by name' {
        @(ConvertFrom-LogLine -Line $lines).Count | Should -Be 2
    }
}
