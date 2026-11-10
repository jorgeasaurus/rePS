function ConvertTo-Boolean {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    switch ($Value.Trim()) {
        { $_ -in 'true', 'yes', 'y', '1', 'on' } { return $true }
        { $_ -in 'false', 'no', 'n', '0', 'off' } { return $false }
        default { throw "Cannot convert '$Value' to a boolean." }
    }
}
