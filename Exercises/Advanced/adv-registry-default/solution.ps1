function Get-RegistryValueOrDefault {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name,

        [object]$Default = $null
    )

    $item = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction Ignore
    if ($null -ne $item) { $item.$Name } else { $Default }
}
