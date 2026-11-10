@{
    Id           = 'pipe-top-n'
    Title        = 'Top N values'
    Topic        = 'Pipeline'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('sort-object', 'select-object')
    FunctionName = 'Get-TopNumber'
    Author       = 'rePS'
    Prompt       = @'
Write Get-TopNumber so it outputs the -Count largest values from -Numbers,
largest first. If -Count is larger than the input, output everything (sorted).

    Get-TopNumber -Numbers 5, 1, 9, 3 -Count 2   # 9, 5
'@
    Hints        = @(
        'Sort-Object -Descending sorts largest first.'
        'Select-Object -First takes the first N items and does not complain when there are fewer.'
    )
}
