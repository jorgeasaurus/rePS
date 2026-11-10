param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-ExistingPath' {
    BeforeAll {
        $existing = (New-Item -Path (Join-Path $TestDrive 'here.txt') -ItemType File -Force).FullName
        $missing1 = Join-Path $TestDrive 'missing1.txt'
        $missing2 = Join-Path $TestDrive 'missing2.txt'
    }
    It 'outputs existing paths' {
        Get-ExistingPath -Path $existing | Should -Be $existing
    }
    It 'continues past missing paths' {
        $out = Get-ExistingPath -Path $missing1, $existing -ErrorAction SilentlyContinue
        $out | Should -Be $existing
    }
    It 'records one error per missing path' {
        $null = Get-ExistingPath -Path $missing1, $existing, $missing2 -ErrorAction SilentlyContinue -ErrorVariable errs
        $errs.Count | Should -Be 2
    }
    It 'mentions the missing path in the error' {
        $null = Get-ExistingPath -Path $missing1 -ErrorAction SilentlyContinue -ErrorVariable errs
        "$($errs[0])" | Should -Match ([regex]::Escape('missing1.txt'))
    }
    It 'becomes terminating with -ErrorAction Stop' {
        { Get-ExistingPath -Path $missing1 -ErrorAction Stop } | Should -Throw
    }
}
