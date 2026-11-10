function Get-NumberList {
    param(
        [ValidateRange(0, 1000000)]
        [int]$Count
    )

    $list = [System.Collections.Generic.List[int]]::new()
    for ($i = 1; $i -le $Count; $i++) {
        $list.Add($i)
    }
    Write-Output -NoEnumerate -InputObject $list
}
