function Get-SalesSummary {
    param(
        [Parameter(Mandatory)]
        [psobject[]]$Sale
    )

    $Sale | Group-Object -Property Region | ForEach-Object {
        $top = $_.Group |
            Group-Object -Property Product |
            ForEach-Object { [pscustomobject]@{ Product = $_.Name; Total = ($_.Group | Measure-Object Amount -Sum).Sum } } |
            Sort-Object -Property Total -Descending |
            Select-Object -First 1

        [pscustomobject]@{
            Region     = $_.Name
            Total      = ($_.Group | Measure-Object -Property Amount -Sum).Sum
            TopProduct = $top.Product
        }
    } | Sort-Object -Property Total -Descending
}
