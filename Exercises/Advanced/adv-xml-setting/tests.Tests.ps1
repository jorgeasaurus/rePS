param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-XmlSetting' {
    BeforeAll {
        $xml = @"
<configuration>
  <appSettings>
    <add key="Environment" value="Prod" />
    <add key="MaxRetries" value="5" />
    <add key="Owner" value="O'Brien &amp; Co" />
  </appSettings>
</configuration>
"@
    }
    It 'returns a value by key' {
        Get-XmlSetting -Xml $xml -Key 'Environment' | Should -BeExactly 'Prod'
    }
    It 'returns other keys' {
        Get-XmlSetting -Xml $xml -Key 'MaxRetries' | Should -Be '5'
    }
    It 'decodes XML entities' {
        Get-XmlSetting -Xml $xml -Key 'Owner' | Should -BeExactly "O'Brien & Co"
    }
    It 'returns $null for a missing key' {
        Get-XmlSetting -Xml $xml -Key 'Nope' | Should -BeNullOrEmpty
    }
    It 'matches keys case-sensitively' {
        Get-XmlSetting -Xml $xml -Key 'environment' | Should -BeNullOrEmpty
    }
}
