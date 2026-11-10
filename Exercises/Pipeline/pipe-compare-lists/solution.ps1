function Compare-List {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Reference,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Difference
    )

    $change = @{ '<=' = 'Removed'; '=>' = 'Added' }
    Compare-Object -ReferenceObject $Reference -DifferenceObject $Difference |
        ForEach-Object { [pscustomobject]@{ Value = $_.InputObject; Change = $change[$_.SideIndicator] } } |
        Sort-Object -Property Value
}
