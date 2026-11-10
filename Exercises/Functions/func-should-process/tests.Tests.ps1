param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Remove-StaleFile' {
    BeforeEach {
        $dir = Join-Path $TestDrive ([guid]::NewGuid())
        $null = New-Item -Path $dir -ItemType Directory
        $old = New-Item -Path (Join-Path $dir 'old.log') -ItemType File
        $old.LastWriteTime = (Get-Date).AddDays(-40)
        $new = New-Item -Path (Join-Path $dir 'new.log') -ItemType File
        $sub = New-Item -Path (Join-Path $dir 'archive') -ItemType Directory
        $sub.LastWriteTime = (Get-Date).AddDays(-400)
    }
    It 'supports -WhatIf' {
        (Get-Command Remove-StaleFile).Parameters.ContainsKey('WhatIf') | Should -BeTrue
    }
    It 'deletes only stale files' {
        $null = Remove-StaleFile -Path $dir -Days 30 -Confirm:$false
        Test-Path (Join-Path $dir 'old.log') | Should -BeFalse
        Test-Path (Join-Path $dir 'new.log') | Should -BeTrue
    }
    It 'leaves folders alone' {
        $null = Remove-StaleFile -Path $dir -Days 30 -Confirm:$false
        Test-Path (Join-Path $dir 'archive') | Should -BeTrue
    }
    It 'outputs the deleted files' {
        $out = @(Remove-StaleFile -Path $dir -Days 30 -Confirm:$false)
        $out.Count | Should -Be 1
        $out[0].Name | Should -Be 'old.log'
    }
    It 'deletes nothing and outputs nothing with -WhatIf' {
        $out = @(Remove-StaleFile -Path $dir -Days 30 -WhatIf)
        $out.Count | Should -Be 0
        Test-Path (Join-Path $dir 'old.log') | Should -BeTrue
    }
}
