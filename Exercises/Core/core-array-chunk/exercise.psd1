@{
    Id           = 'core-array-chunk'
    Title        = 'Split an array into chunks'
    Topic        = 'Core'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('arrays', 'unrolling')
    FunctionName = 'Split-Array'
    Author       = 'rePS'
    Prompt       = @'
Write Split-Array so it splits -InputObject into chunks of -Size items and outputs
each chunk as an array (the last chunk may be shorter).

The catch: PowerShell unrolls arrays written to the pipeline. Your function must
still return a list of chunks even when there is only ONE chunk.

    $chunks = Split-Array -InputObject (1..5) -Size 2
    $chunks.Count          # 3
    $chunks[2]             # 5
    @(Split-Array -InputObject 1, 2 -Size 5).Count   # 1  (one chunk holding 2 items)
'@
    Hints        = @(
        'Loop with for ($i = 0; $i -lt $InputObject.Count; $i += $Size) and slice with $InputObject[$i..($i + $Size - 1)].'
        'Writing an array to the output stream sends its items one by one. The unary comma operator ,$chunk wraps it so it survives as a single item.'
        'Watch the end of the slice: indexes past the end return nothing, so slicing is safe, but use [Math]::Min to be explicit.'
    )
}
