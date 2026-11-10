@{
    Id           = 'adv-json-depth'
    Title        = 'JSON without truncation'
    Topic        = 'Advanced'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('json', 'serialization')
    FunctionName = 'ConvertTo-CompactJson'
    Author       = 'rePS'
    Prompt       = @'
ConvertTo-Json only serialises 2 levels deep by default. Anything deeper turns
into a type name string like "System.Collections.Hashtable".

Write ConvertTo-CompactJson so it returns -InputObject as single-line (compressed)
JSON, at least 20 levels deep, with no truncation warnings.

    ConvertTo-CompactJson -InputObject @{ a = @{ b = @{ c = @{ d = 1 } } } }
    # {"a":{"b":{"c":{"d":1}}}}
'@
    Hints        = @(
        'ConvertTo-Json has a -Depth parameter.'
        '-Compress removes whitespace and newlines.'
    )
}
