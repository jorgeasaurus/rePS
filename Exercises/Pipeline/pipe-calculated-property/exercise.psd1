@{
    Id           = 'pipe-calculated-property'
    Title        = 'Calculated properties'
    Topic        = 'Pipeline'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('select-object', 'calculated-properties')
    FunctionName = 'Add-FullName'
    Author       = 'rePS'
    Prompt       = @'
Write Add-FullName so it takes person objects (-Person) with First and Last
properties and outputs objects with First, Last AND a new FullName property
("First Last"). Use a calculated property with Select-Object.

    [pscustomobject]@{ First = 'Ada'; Last = 'Lovelace' } | Add-FullName
    # First: Ada  Last: Lovelace  FullName: Ada Lovelace
'@
    Hints        = @(
        'A calculated property is a hashtable: @{ Name = ''FullName''; Expression = { ... } }'
        'Inside Expression, $_ is the current input object.'
        'Pass it alongside normal property names: Select-Object First, Last, @{ ... }'
    )
}
