function Select-UserSummary {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject[]]$User
    )

    process {
        $User | Select-Object -Property Name, Email
    }
}
