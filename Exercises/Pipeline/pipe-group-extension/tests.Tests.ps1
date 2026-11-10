param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-ExtensionCount' {
    BeforeAll {
        $result = @(Get-ExtensionCount -FileName 'a.ps1', 'b.PS1', 'c.txt', 'README', 'd.ps1', 'e.md', 'LICENSE')
    }
    It 'returns one object per extension' {
        $result.Count | Should -Be 4
    }
    It 'counts case-insensitively with lowercase names' {
        ($result | Where-Object Extension -EQ '.ps1').Count | Should -Be 3
    }
    It 'groups names without an extension as (none)' {
        ($result | Where-Object Extension -EQ '(none)').Count | Should -Be 2
    }
    It 'sorts by Count descending, then Extension' {
        $result.Extension | Should -Be @('.ps1', '(none)', '.md', '.txt')
    }
    It 'outputs only Extension and Count' {
        $result[0].PSObject.Properties.Name | Should -Be @('Extension', 'Count')
    }
}
