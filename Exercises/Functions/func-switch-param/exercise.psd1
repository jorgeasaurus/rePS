@{
    Id           = 'func-switch-param'
    Title        = 'Switch parameters'
    Topic        = 'Functions'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('parameters', 'switch')
    FunctionName = 'Get-Shout'
    Author       = 'rePS'
    Prompt       = @'
Write Get-Shout so it returns -Text unchanged, unless the -Loud switch is present,
in which case it returns the text uppercased with '!' appended.

    Get-Shout -Text 'hello'          # hello
    Get-Shout -Text 'hello' -Loud    # HELLO!
'@
    Hints        = @(
        'Declare the parameter as [switch]$Loud. It is $false unless the caller passes it.'
        'Test it like a boolean: if ($Loud) { ... }'
    )
}
