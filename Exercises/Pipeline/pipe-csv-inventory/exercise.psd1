@{
    Id           = 'pipe-csv-inventory'
    Title        = 'Typed objects from CSV'
    Topic        = 'Pipeline'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('csv', 'types', 'pscustomobject')
    FunctionName = 'ConvertTo-InventoryItem'
    Author       = 'rePS'
    Prompt       = @'
Write ConvertTo-InventoryItem so it takes CSV text (-Csv) with a header row
Name,Quantity,Price and outputs objects with:
  Name [string], Quantity [int], Price [decimal], Total [decimal] (Quantity * Price)

ConvertFrom-Csv gives you strings only, so '10' -gt '9' is $false. Fix the types.

    ConvertTo-InventoryItem -Csv "Name,Quantity,Price`nWidget,10,2.50"
    # Name: Widget  Quantity: 10  Price: 2.50  Total: 25.00
'@
    Hints        = @(
        'ConvertFrom-Csv parses the text into objects whose properties are all strings.'
        'Cast while building a new object: [int]$_.Quantity, [decimal]$_.Price'
        'Use [decimal] rather than [double] for money: 0.1 + 0.2 is exact with [decimal].'
    )
}
