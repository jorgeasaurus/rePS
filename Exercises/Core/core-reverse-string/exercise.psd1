@{
    Id           = 'core-reverse-string'
    Title        = 'Reverse a string'
    Topic        = 'Core'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('strings', 'arrays')
    FunctionName = 'Get-ReversedString'
    Author       = 'rePS'
    Prompt       = @'
Write Get-ReversedString so it returns -InputString with its characters reversed.

    Get-ReversedString -InputString 'hello'   # olleh
    Get-ReversedString -InputString ''        # (empty string)
'@
    Hints        = @(
        'A string can be turned into a char array with .ToCharArray().'
        '[array]::Reverse() reverses an array in place; -join glues characters back together.'
        'An alternative: index the string backwards, $s[($s.Length - 1)..0], but watch out for the empty string.'
    )
}
