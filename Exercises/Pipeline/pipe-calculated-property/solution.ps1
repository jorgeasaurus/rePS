function Add-FullName {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject[]]$Person
    )

    process {
        $Person | Select-Object First, Last, @{ Name = 'FullName'; Expression = { "$($_.First) $($_.Last)" } }
    }
}
