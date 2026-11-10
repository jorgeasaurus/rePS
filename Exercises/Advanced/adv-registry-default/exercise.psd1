@{
    Id           = 'adv-registry-default'
    Title        = 'Registry value with fallback'
    Topic        = 'Advanced'
    Level        = 2
    Platforms    = @('Windows')
    Tags         = @('registry', 'windows', 'errors')
    FunctionName = 'Get-RegistryValueOrDefault'
    Author       = 'rePS'
    Prompt       = @'
Write Get-RegistryValueOrDefault so it returns the registry value -Name under the
key -Path (e.g. 'HKCU:\Software\Contoso'), or -Default when either the key or the
value does not exist.

It must not throw, and must not add anything to $Error, when the key or value
is missing.

    Get-RegistryValueOrDefault -Path 'HKCU:\Software\Nope' -Name 'Color' -Default 'Blue'   # Blue
'@
    Hints        = @(
        'Get-ItemProperty -LiteralPath $Path -Name $Name returns an object with the value as a property.'
        '-ErrorAction SilentlyContinue hides the error but still records it in $Error. -ErrorAction Ignore does not.'
        'A value can legitimately be 0 or an empty string. Check for $null, not for "truthy".'
    )
}
