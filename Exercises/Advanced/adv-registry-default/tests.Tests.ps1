param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-RegistryValueOrDefault' {
    BeforeAll {
        $key = "HKCU:\Software\rePS-Tests\$([guid]::NewGuid())"
        $null = New-Item -Path $key -Force
        $null = New-ItemProperty -Path $key -Name 'Color' -Value 'Green' -PropertyType String
        $null = New-ItemProperty -Path $key -Name 'Zero' -Value 0 -PropertyType DWord
    }
    AfterAll {
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
    }
    It 'returns an existing value' {
        Get-RegistryValueOrDefault -Path $key -Name 'Color' -Default 'Blue' | Should -Be 'Green'
    }
    It 'returns a zero value instead of the default' {
        Get-RegistryValueOrDefault -Path $key -Name 'Zero' -Default 99 | Should -Be 0
    }
    It 'returns the default for a missing value' {
        Get-RegistryValueOrDefault -Path $key -Name 'Nope' -Default 'Blue' | Should -Be 'Blue'
    }
    It 'returns the default for a missing key' {
        Get-RegistryValueOrDefault -Path "$key\Missing" -Name 'Color' -Default 'Blue' | Should -Be 'Blue'
    }
    It 'does not record errors' {
        $Error.Clear()
        $null = Get-RegistryValueOrDefault -Path "$key\Missing" -Name 'Color'
        $null = Get-RegistryValueOrDefault -Path $key -Name 'Nope'
        $Error.Count | Should -Be 0
    }
}
