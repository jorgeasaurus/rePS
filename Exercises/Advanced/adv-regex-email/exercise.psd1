@{
    Id           = 'adv-regex-email'
    Title        = 'Validate with regex'
    Topic        = 'Advanced'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('regex')
    FunctionName = 'Test-EmailAddress'
    Author       = 'rePS'
    Prompt       = @'
Write Test-EmailAddress so it returns $true when -Address looks like an email:
  - exactly one '@'
  - no whitespace anywhere
  - at least one character before the '@'
  - a domain containing a dot, ending in 2+ letters ('.com', '.io', '.co.uk')

    Test-EmailAddress -Address 'ada@example.com'   # True
    Test-EmailAddress -Address 'ada@localhost'     # False
'@
    Hints        = @(
        '-match returns $true or $false. Anchor the pattern so the whole string has to match.'
        '[^@\s]+ means "one or more characters that are not @ or whitespace".'
        'Escape the dot: \. matches a literal dot. [A-Za-z]{2,} matches 2+ letters.'
        'Gotcha: $ also matches just before a trailing newline. \A and \z anchor the absolute start and end of the input.'
    )
}
