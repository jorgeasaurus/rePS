function ConvertTo-CompactJson {
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$InputObject
    )

    ConvertTo-Json -InputObject $InputObject -Depth 20 -Compress
}
