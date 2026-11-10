function ConvertTo-InventoryItem {
    param(
        [Parameter(Mandatory)]
        [string]$Csv
    )

    $Csv | ConvertFrom-Csv | ForEach-Object {
        $quantity = [int]$_.Quantity
        $price = [decimal]$_.Price
        [pscustomobject]@{
            Name     = [string]$_.Name
            Quantity = $quantity
            Price    = $price
            Total    = $quantity * $price
        }
    }
}
