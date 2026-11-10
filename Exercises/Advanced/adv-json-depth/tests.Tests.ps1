param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'ConvertTo-CompactJson' {
    BeforeAll {
        $deep = [ordered]@{ a = [ordered]@{ b = [ordered]@{ c = [ordered]@{ d = [ordered]@{ e = 1 } } } } }
    }
    It 'serialises nested objects fully' {
        ConvertTo-CompactJson -InputObject $deep | Should -BeExactly '{"a":{"b":{"c":{"d":{"e":1}}}}}'
    }
    It 'returns a single line' {
        ConvertTo-CompactJson -InputObject ([ordered]@{ x = 1; y = @(1, 2) }) | Should -Not -Match '\r?\n'
    }
    It 'does not emit truncation warnings' {
        $null = ConvertTo-CompactJson -InputObject $deep -WarningVariable w -WarningAction SilentlyContinue
        $w | Should -BeNullOrEmpty
    }
    It 'round-trips through ConvertFrom-Json' {
        $json = ConvertTo-CompactJson -InputObject $deep
        ($json | ConvertFrom-Json).a.b.c.d.e | Should -Be 1
    }
}
