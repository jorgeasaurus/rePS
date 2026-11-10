@{
    Id           = 'core-palindrome'
    Title        = 'Palindrome check'
    Topic        = 'Core'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('strings', 'regex')
    FunctionName = 'Test-Palindrome'
    Author       = 'rePS'
    Prompt       = @'
Write Test-Palindrome so it returns $true when -Text reads the same forwards and
backwards, ignoring case, spaces and punctuation. Otherwise return $false.

    Test-Palindrome -Text 'A man, a plan, a canal: Panama'   # True
    Test-Palindrome -Text 'PowerShell'                       # False
'@
    Hints        = @(
        'Normalise first: -replace ''[^a-z0-9]'', '''' strips everything that is not a letter or digit.'
        'PowerShell operators like -replace and -eq are case-insensitive by default; .ToLower() makes it explicit.'
        'Compare the cleaned string with its reverse.'
    )
}
