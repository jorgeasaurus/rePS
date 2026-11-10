@{
    Id           = 'pipe-sales-summary'
    Title        = 'Summarise sales by region'
    Topic        = 'Pipeline'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('group-object', 'measure-object', 'sort-object')
    FunctionName = 'Get-SalesSummary'
    Author       = 'rePS'
    Prompt       = @'
Write Get-SalesSummary so it takes sale objects (-Sale) with Region, Product and
Amount properties and outputs one object per region with:
  Region      - the region name
  Total       - sum of Amount in that region
  TopProduct  - the product with the highest total Amount in that region
Sort the output by Total descending.

    Get-SalesSummary -Sale $sales
    # Region: West  Total: 900  TopProduct: Laptop
'@
    Hints        = @(
        'Group-Object Region gives you one group per region. Each group''s .Group holds its sales.'
        'Inside each region, group again by Product and sum the Amount of each product group.'
        'Sort-Object -Descending | Select-Object -First 1 picks the top product.'
    )
}
