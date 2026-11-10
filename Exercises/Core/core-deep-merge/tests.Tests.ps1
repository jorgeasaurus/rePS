param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Merge-Hashtable' {
    BeforeEach {
        $base = @{ Name = 'app'; Settings = @{ Debug = $false; Port = 80; Tls = @{ Enabled = $false } } }
        $override = @{ Version = 2; Settings = @{ Debug = $true; Tls = @{ Enabled = $true } } }
    }
    It 'keeps keys from both sides' {
        $r = Merge-Hashtable -Base $base -Override $override
        $r.Name | Should -Be 'app'
        $r.Version | Should -Be 2
    }
    It 'lets Override win' {
        (Merge-Hashtable -Base @{ A = 1 } -Override @{ A = 2 }).A | Should -Be 2
    }
    It 'merges nested hashtables recursively' {
        $r = Merge-Hashtable -Base $base -Override $override
        $r.Settings.Debug | Should -BeTrue
        $r.Settings.Port | Should -Be 80
        $r.Settings.Tls.Enabled | Should -BeTrue
    }
    It 'does not modify Base' {
        $null = Merge-Hashtable -Base $base -Override $override
        $base.Settings.Debug | Should -BeFalse
        $base.Settings.Tls.Enabled | Should -BeFalse
        $base.ContainsKey('Version') | Should -BeFalse
    }
    It 'keeps arrays intact, including single-item and empty ones' {
        $r = Merge-Hashtable -Base @{ Ports = @(80); None = @(); Many = @(1, 2) } -Override @{ Extra = @(443) }
        , $r.Ports | Should -BeOfType [array]
        $r.Ports.Count | Should -Be 1
        , $r.None | Should -BeOfType [array]
        $r.None.Count | Should -Be 0
        $r.Many.Count | Should -Be 2
        , $r.Extra | Should -BeOfType [array]
    }
    It 'returns a copy, not a reference to Base' {
        $r = Merge-Hashtable -Base $base -Override @{}
        $r.Settings.Port = 443
        $base.Settings.Port | Should -Be 80
    }
}
