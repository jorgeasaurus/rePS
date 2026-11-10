@{
    Id           = 'adv-return-list'
    Title        = 'Return a collection intact'
    Topic        = 'Advanced'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('collections', 'unrolling', 'generics', 'performance')
    FunctionName = 'Get-NumberList'
    Author       = 'rePS'
    Prompt       = @'
Write Get-NumberList so it builds a [System.Collections.Generic.List[int]]
containing 1..-Count and returns THE LIST ITSELF as a single object.

Use .Add() rather than += on an array (+= copies the whole array every time).
Watch out: PowerShell unrolls collections written to the output, so a naive
"return $list" gives the caller loose ints, or $null for an empty list.

    $list = Get-NumberList -Count 3
    $list.GetType().Name   # List`1
    (Get-NumberList -Count 0).Count   # 0, and the result is not $null
'@
    Hints        = @(
        '$list = [System.Collections.Generic.List[int]]::new(), then $list.Add($i) inside a loop.'
        'Write-Output -NoEnumerate -InputObject $list writes the collection as one object.'
        'The unary comma operator also works: , $list wraps it in a one-element array, and only that wrapper gets unrolled.'
    )
}
