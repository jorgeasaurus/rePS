function Get-Square {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [double[]]$Number
    )

    process {
        foreach ($n in $Number) {
            $n * $n
        }
    }
}
