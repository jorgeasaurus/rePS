param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Read-JsonConfig' {
    BeforeAll {
        $good = Join-Path $TestDrive 'good.json'
        '{ "name": "app", "port": 8080, "features": { "beta": true } }' | Set-Content -Path $good
        $bad = Join-Path $TestDrive 'bad.json'
        '{ "name": ' | Set-Content -Path $bad
    }
    It 'returns a hashtable' {
        Read-JsonConfig -Path $good | Should -BeOfType [hashtable]
    }
    It 'parses values, including nested ones' {
        $c = Read-JsonConfig -Path $good
        $c.port | Should -Be 8080
        $c.features.beta | Should -BeTrue
    }
    It 'throws FileNotFoundException for a missing file' {
        { Read-JsonConfig -Path (Join-Path $TestDrive 'nope.json') } | Should -Throw -ExceptionType ([System.IO.FileNotFoundException])
    }
    It 'throws FormatException for invalid JSON' {
        { Read-JsonConfig -Path $bad } | Should -Throw -ExceptionType ([System.FormatException])
    }
    It 'includes the path in the FormatException message' {
        { Read-JsonConfig -Path $bad } | Should -Throw -ExpectedMessage '*bad.json*'
    }
}
