param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'ConvertTo-Boolean' {
    It 'maps <Value> to $true' -ForEach @(
        @{ Value = 'true' }, @{ Value = 'YES' }, @{ Value = 'y' }, @{ Value = '1' }, @{ Value = 'On' }
    ) {
        ConvertTo-Boolean -Value $Value | Should -BeTrue
    }
    It 'maps <Value> to $false' -ForEach @(
        @{ Value = 'false' }, @{ Value = 'No' }, @{ Value = 'n' }, @{ Value = '0' }, @{ Value = 'OFF' }
    ) {
        ConvertTo-Boolean -Value $Value | Should -BeFalse
    }
    It 'trims whitespace' {
        ConvertTo-Boolean -Value '  no  ' | Should -BeFalse
    }
    It 'returns a [bool]' {
        ConvertTo-Boolean -Value 'yes' | Should -BeOfType [bool]
    }
    It 'throws for <Value>' -ForEach @(
        @{ Value = 'maybe' }, @{ Value = '2' }, @{ Value = 'truthy' }
    ) {
        { ConvertTo-Boolean -Value $Value } | Should -Throw
    }
}
