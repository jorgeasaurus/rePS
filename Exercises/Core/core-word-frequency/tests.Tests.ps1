param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-WordFrequency' {
    It 'returns a hashtable' {
        Get-WordFrequency -Text 'a b' | Should -BeOfType [hashtable]
    }
    It 'counts case-insensitively' {
        $f = Get-WordFrequency -Text 'The cat and THE hat. the end'
        $f['the'] | Should -Be 3
        $f['cat'] | Should -Be 1
    }
    It 'uses lowercase keys' {
        $f = Get-WordFrequency -Text 'Hello HELLO'
        $f.Keys | Should -Be @('hello')
    }
    It 'ignores punctuation' {
        $f = Get-WordFrequency -Text 'yes, yes! no?'
        $f.Count | Should -Be 2
        $f['yes'] | Should -Be 2
    }
    It 'treats underscores as separators' {
        $f = Get-WordFrequency -Text 'one_two one'
        $f['one'] | Should -Be 2
        $f['two'] | Should -Be 1
    }
    It 'returns an empty hashtable for empty text' {
        (Get-WordFrequency -Text '').Count | Should -Be 0
    }
}
