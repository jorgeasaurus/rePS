@{
    Id           = 'pipe-filter-even'
    Title        = 'Filter even numbers'
    Topic        = 'Pipeline'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('where-object', 'filtering')
    FunctionName = 'Get-EvenNumber'
    Author       = 'rePS'
    Prompt       = @'
Write Get-EvenNumber so it outputs only the even numbers from -Numbers, in their
original order. Use the pipeline.

    Get-EvenNumber -Numbers 1..10   # 2, 4, 6, 8, 10
'@
    Hints        = @(
        'Pipe the array into Where-Object.'
        'Inside the Where-Object scriptblock $_ is the current item: { $_ % 2 -eq 0 }'
    )
}
