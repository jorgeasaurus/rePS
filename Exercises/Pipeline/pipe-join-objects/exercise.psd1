@{
    Id           = 'pipe-join-objects'
    Title        = 'Join two object sets'
    Topic        = 'Pipeline'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('hashtables', 'performance', 'objects')
    FunctionName = 'Join-Object'
    Author       = 'rePS'
    Prompt       = @'
Write Join-Object so it performs an INNER join of -Left and -Right on the property
named by -On, outputting merged objects with every property from both sides.
If a property exists on both sides, the -Left value wins.

Do it in roughly linear time: build a lookup table instead of nesting
Where-Object inside ForEach-Object.

    $users  = [pscustomobject]@{ Id = 1; Name = 'Ada' }
    $orders = [pscustomobject]@{ Id = 1; Total = 30 }, [pscustomobject]@{ Id = 2; Total = 5 }
    Join-Object -Left $users -Right $orders -On Id
    # Id 1, Name Ada, Total 30
'@
    Hints        = @(
        'Build a hashtable of the Right objects keyed by $_.$On. Use a list per key because keys can repeat.'
        'For each Left object, look up the matches in O(1) and emit one merged object per match.'
        'Build the output with an [ordered] hashtable: add the Left properties first, then any Right properties not already present. Cast to [pscustomobject] at the end.'
    )
}
