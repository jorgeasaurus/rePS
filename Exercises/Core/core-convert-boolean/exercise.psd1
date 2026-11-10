@{
    Id           = 'core-convert-boolean'
    Title        = 'Parse a boolean'
    Topic        = 'Core'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('types', 'switch', 'errors')
    FunctionName = 'ConvertTo-Boolean'
    Author       = 'rePS'
    Prompt       = @'
[bool]'false' is $true in PowerShell, because any non-empty string casts to $true.
Write ConvertTo-Boolean so it parses -Value properly (case-insensitive, trimmed):

  'true', 'yes', 'y', '1', 'on'   -> $true
  'false', 'no', 'n', '0', 'off'  -> $false
  anything else                   -> throw an error

    ConvertTo-Boolean -Value ' No '   # False
'@
    Hints        = @(
        'Trim the input first: $Value.Trim().'
        'switch is case-insensitive by default and can match several values per clause: { $_ -in ''true'',''yes'' }'
        'Use throw in the default branch.'
    )
}
