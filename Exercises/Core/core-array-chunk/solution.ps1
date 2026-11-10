function Split-Array {
    param(
        [Parameter(Mandatory)]
        [object[]]$InputObject,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Size
    )

    for ($i = 0; $i -lt $InputObject.Count; $i += $Size) {
        $last = [Math]::Min($i + $Size, $InputObject.Count) - 1
        , @($InputObject[$i..$last])
    }
}
