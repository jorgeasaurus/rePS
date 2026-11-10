function Get-RegistryValueOrDefault {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name,

        [object]$Default = $null
    )

    # TODO: return the value, or $Default when the key/value is missing (no errors)
    throw 'Not implemented'
}
