@{
    Id           = 'core-letter-grade'
    Title        = 'Letter grades with switch'
    Topic        = 'Core'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('switch', 'conditionals', 'errors')
    FunctionName = 'Get-LetterGrade'
    Author       = 'rePS'
    Prompt       = @'
Write Get-LetterGrade so it converts a numeric -Score (0-100) to a letter:
  90-100 A, 80-89 B, 70-79 C, 60-69 D, below 60 F

Scores outside 0-100 must throw a terminating error.
Try to use a switch statement rather than an if/elseif chain.

    Get-LetterGrade -Score 85   # B
'@
    Hints        = @(
        'A switch clause can be a scriptblock: { $_ -ge 90 } { ''A''; break }'
        'Without break, switch keeps testing the remaining clauses and can output several letters.'
        '[ValidateRange(0, 100)] on the parameter handles the out-of-range requirement for you.'
    )
}
