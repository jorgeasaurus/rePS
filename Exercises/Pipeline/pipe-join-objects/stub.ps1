function Join-Object {
    param(
        [Parameter(Mandatory)]
        [psobject[]]$Left,

        [Parameter(Mandatory)]
        [psobject[]]$Right,

        [Parameter(Mandatory)]
        [string]$On
    )

    # TODO: inner-join Left and Right on the $On property using a lookup table
    throw 'Not implemented'
}
