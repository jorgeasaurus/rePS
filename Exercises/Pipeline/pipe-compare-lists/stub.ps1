function Compare-List {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Reference,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Difference
    )

    # TODO: output Value/Change objects for the differences, sorted by Value
    throw 'Not implemented'
}
