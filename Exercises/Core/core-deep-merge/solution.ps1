function Merge-Hashtable {
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Base,

        [Parameter(Mandatory)]
        [hashtable]$Override
    )

    $result = @{}
    foreach ($key in $Base.Keys) {
        $value = $Base[$key]
        $result[$key] = if ($value -is [hashtable]) { Merge-Hashtable -Base $value -Override @{} } else { $value }
    }
    foreach ($key in $Override.Keys) {
        $value = $Override[$key]
        if ($value -is [hashtable] -and $result[$key] -is [hashtable]) {
            $result[$key] = Merge-Hashtable -Base $result[$key] -Override $value
        } elseif ($value -is [hashtable]) {
            $result[$key] = Merge-Hashtable -Base $value -Override @{}
        } else {
            $result[$key] = $value
        }
    }
    $result
}
