param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'ConvertTo-InventoryItem' {
    BeforeAll {
        $csv = "Name,Quantity,Price`nWidget,10,2.50`nGadget,9,0.10`nGizmo,3,0.20"
        $items = @(ConvertTo-InventoryItem -Csv $csv)
    }
    It 'outputs one object per row' {
        $items.Count | Should -Be 3
    }
    It 'types Quantity as [int]' {
        $items[0].Quantity | Should -BeOfType [int]
    }
    It 'types Price and Total as [decimal]' {
        $items[0].Price | Should -BeOfType [decimal]
        $items[0].Total | Should -BeOfType [decimal]
    }
    It 'computes Total' {
        $items[0].Total | Should -Be 25
        $items[1].Total | Should -Be 0.9
    }
    It 'sorts numerically, not as text' {
        ($items | Sort-Object Quantity -Descending)[0].Name | Should -Be 'Widget'
    }
    It 'is exact with decimals' {
        ($items[1].Price + $items[2].Price) | Should -Be ([decimal]'0.30')
    }
}
