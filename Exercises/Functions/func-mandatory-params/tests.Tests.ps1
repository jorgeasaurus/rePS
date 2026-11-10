param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-RectangleArea' {
    BeforeAll {
        $command = Get-Command Get-RectangleArea
    }
    It 'multiplies width by height' {
        Get-RectangleArea -Width 2 -Height 3.5 | Should -Be 7
    }
    It 'accepts positional arguments' {
        Get-RectangleArea 4 5 | Should -Be 20
    }
    It 'makes <Name> mandatory and [double]' -ForEach @(@{ Name = 'Width' }, @{ Name = 'Height' }) {
        $p = $command.Parameters[$Name]
        $p.ParameterType | Should -Be ([double])
        ($p.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }).Mandatory | Should -BeTrue
    }
    It 'rejects zero and negative values' {
        { Get-RectangleArea -Width 0 -Height 2 } | Should -Throw
        { Get-RectangleArea -Width 2 -Height -1 } | Should -Throw
    }
}
