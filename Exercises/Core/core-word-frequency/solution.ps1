function Get-WordFrequency {
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text
    )

    $frequency = @{}
    foreach ($word in ($Text -split '[\W_]+')) {
        if (-not $word) { continue }
        $frequency[$word.ToLowerInvariant()]++
    }
    $frequency
}
