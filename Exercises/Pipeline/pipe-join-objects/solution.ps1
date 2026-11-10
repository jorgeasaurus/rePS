function Join-Object {
    param(
        [Parameter(Mandatory)]
        [psobject[]]$Left,

        [Parameter(Mandatory)]
        [psobject[]]$Right,

        [Parameter(Mandatory)]
        [string]$On
    )

    $lookup = @{}
    foreach ($item in $Right) {
        $key = $item.$On
        if (-not $lookup.ContainsKey($key)) {
            $lookup[$key] = [System.Collections.Generic.List[psobject]]::new()
        }
        $lookup[$key].Add($item)
    }

    foreach ($leftItem in $Left) {
        $matched = $lookup[$leftItem.$On]
        if (-not $matched) { continue }
        foreach ($rightItem in $matched) {
            $merged = [ordered]@{}
            foreach ($p in $leftItem.PSObject.Properties) { $merged[$p.Name] = $p.Value }
            foreach ($p in $rightItem.PSObject.Properties) {
                if (-not $merged.Contains($p.Name)) { $merged[$p.Name] = $p.Value }
            }
            [pscustomobject]$merged
        }
    }
}
