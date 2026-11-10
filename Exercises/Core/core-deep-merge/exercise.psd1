@{
    Id           = 'core-deep-merge'
    Title        = 'Deep-merge hashtables'
    Topic        = 'Core'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('hashtables', 'recursion')
    FunctionName = 'Merge-Hashtable'
    Author       = 'rePS'
    Prompt       = @'
Write Merge-Hashtable so it returns a NEW hashtable combining -Base and -Override:
  - Keys from both are present; values from -Override win.
  - When both values for a key are hashtables, merge them recursively.
  - Neither input may be modified.

    $base     = @{ Name = 'app'; Settings = @{ Debug = $false; Port = 80 } }
    $override = @{ Settings = @{ Debug = $true } }
    Merge-Hashtable -Base $base -Override $override
    # @{ Name = 'app'; Settings = @{ Debug = $true; Port = 80 } }
'@
    Hints        = @(
        'Start with a copy, not a reference: $result = @{}; foreach ($k in $Base.Keys) { ... }'
        'Hashtables are reference types. Copying $Base[''Settings''] into the result and then changing it changes $Base too.'
        'Recurse: if ($a -is [hashtable] -and $b -is [hashtable]) { Merge-Hashtable -Base $a -Override $b }'
    )
}
