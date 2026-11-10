function Split-Array {
    param(
        [Parameter(Mandatory)]
        [object[]]$InputObject,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Size
    )

    # TODO: output each chunk of $Size items as a single array
    throw 'Not implemented'
}
