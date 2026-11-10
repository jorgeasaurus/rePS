function ConvertFrom-LogLine {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string[]]$Line
    )

    process {
        # TODO: parse matching lines into Timestamp/Level/Message objects
        throw 'Not implemented'
    }
}
