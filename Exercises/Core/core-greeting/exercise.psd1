@{
    Id           = 'core-greeting'
    Title        = 'Say hello'
    Topic        = 'Core'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('strings', 'parameters')
    FunctionName = 'Get-Greeting'
    Author       = 'rePS'
    Prompt       = @'
Write Get-Greeting so it returns "Hello, <Name>!".
When -Name is not supplied it should default to "World".

    Get-Greeting -Name 'Ada'   # Hello, Ada!
    Get-Greeting               # Hello, World!
'@
    Hints        = @(
        'Give the parameter a default value: [string]$Name = ''World''.'
        'Double-quoted strings expand variables: "Hello, $Name!"'
    )
}
