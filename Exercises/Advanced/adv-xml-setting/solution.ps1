function Get-XmlSetting {
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Xml,

        [Parameter(Mandatory)]
        [string]$Key
    )

    $doc = [xml]$Xml
    $node = $doc.SelectNodes('//appSettings/add') | Where-Object { $_.GetAttribute('key') -ceq $Key } | Select-Object -First 1
    if ($node) { $node.GetAttribute('value') } else { $null }
}
