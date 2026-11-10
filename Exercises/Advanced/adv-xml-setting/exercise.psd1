@{
    Id           = 'adv-xml-setting'
    Title        = 'Read XML settings'
    Topic        = 'Advanced'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('xml', 'xpath')
    FunctionName = 'Get-XmlSetting'
    Author       = 'rePS'
    Prompt       = @'
Write Get-XmlSetting so it reads app settings from XML text (-Xml) shaped like

    <configuration>
      <appSettings>
        <add key="Environment" value="Prod" />
      </appSettings>
    </configuration>

and returns the value for -Key, or $null when the key does not exist.
Key matching is case-sensitive (XML is).

    Get-XmlSetting -Xml $text -Key 'Environment'   # Prod
'@
    Hints        = @(
        'Cast the text with [xml]$Xml to get an XmlDocument.'
        'XPath selects nodes: $doc.SelectSingleNode("//appSettings/add[@key=''Environment'']")'
        'The attribute value is on the node: $node.value or $node.GetAttribute(''value'').'
    )
}
