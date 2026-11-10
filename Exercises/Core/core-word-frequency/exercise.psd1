@{
    Id           = 'core-word-frequency'
    Title        = 'Word frequency'
    Topic        = 'Core'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('hashtables', 'strings')
    FunctionName = 'Get-WordFrequency'
    Author       = 'rePS'
    Prompt       = @'
Write Get-WordFrequency so it returns a hashtable mapping each word in -Text to the
number of times it appears.
  - Words are separated by any whitespace or punctuation.
  - Counting is case-insensitive and keys are lowercase.

    $f = Get-WordFrequency -Text 'The cat and the hat.'
    $f['the']   # 2
    $f['cat']   # 1
'@
    Hints        = @(
        '-split ''\W+'' splits on runs of non-word characters. Filter out empty strings afterwards.'
        '\W treats _ as a word character, so ''one_two'' stays one word. A character class like [\W_]+ includes it.'
        'Increment with $table[$word]++. A missing key starts as $null, and $null + 1 is 1.'
        'Lowercase each word before using it as a key.'
    )
}
