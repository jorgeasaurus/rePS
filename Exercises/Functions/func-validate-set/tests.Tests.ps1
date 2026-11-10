param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Format-LogMessage' {
    It 'formats the message with an uppercase level' {
        Format-LogMessage -Message 'Disk full' -Level Error | Should -BeExactly '[ERROR] Disk full'
    }
    It 'defaults to INFO' {
        Format-LogMessage -Message 'Started' | Should -BeExactly '[INFO] Started'
    }
    It 'rejects unknown levels with a validation error' {
        { Format-LogMessage -Message 'x' -Level Fatal } | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
    }
    It 'declares exactly the four allowed values' {
        $set = (Get-Command Format-LogMessage).Parameters['Level'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
        $set.ValidValues | Sort-Object | Should -Be @('Debug', 'Error', 'Info', 'Warning')
    }
}
