param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'Get-SalesSummary' {
    BeforeAll {
        $sales = @(
            [pscustomobject]@{ Region = 'West'; Product = 'Laptop'; Amount = 500 }
            [pscustomobject]@{ Region = 'West'; Product = 'Mouse'; Amount = 150 }
            [pscustomobject]@{ Region = 'West'; Product = 'Mouse'; Amount = 150 }
            [pscustomobject]@{ Region = 'West'; Product = 'Laptop'; Amount = 100 }
            [pscustomobject]@{ Region = 'East'; Product = 'Mouse'; Amount = 90 }
            [pscustomobject]@{ Region = 'East'; Product = 'Mouse'; Amount = 80 }
            [pscustomobject]@{ Region = 'East'; Product = 'Laptop'; Amount = 100 }
            [pscustomobject]@{ Region = 'North'; Product = 'Cable'; Amount = 1000 }
        )
        $summary = @(Get-SalesSummary -Sale $sales)
    }
    It 'returns one row per region' {
        $summary.Count | Should -Be 3
    }
    It 'sums per region' {
        ($summary | Where-Object Region -EQ 'West').Total | Should -Be 900
        ($summary | Where-Object Region -EQ 'East').Total | Should -Be 270
    }
    It 'picks the top product by total amount, not by count or single sale' {
        ($summary | Where-Object Region -EQ 'West').TopProduct | Should -Be 'Laptop'
        ($summary | Where-Object Region -EQ 'East').TopProduct | Should -Be 'Mouse'
    }
    It 'sorts by Total descending' {
        $summary.Region | Should -Be @('North', 'West', 'East')
    }
}
