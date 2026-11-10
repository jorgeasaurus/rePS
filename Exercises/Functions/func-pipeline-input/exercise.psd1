@{
    Id           = 'func-pipeline-input'
    Title        = 'Accept pipeline input'
    Topic        = 'Functions'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('pipeline', 'begin-process-end')
    FunctionName = 'Get-Square'
    Author       = 'rePS'
    Prompt       = @'
Write Get-Square so it squares numbers coming from the pipeline AND from the
-Number parameter (which accepts an array).

    1..3 | Get-Square           # 1, 4, 9
    Get-Square -Number 4, 5     # 16, 25

Make it stream: output each square as soon as it is computed.
'@
    Hints        = @(
        '[Parameter(ValueFromPipeline)] binds each piped item to the parameter.'
        'Code in a process { } block runs once per pipeline item. Without one, only the last item is processed.'
        'Inside process, loop over $Number. It holds one item when piped and the whole array when passed by name.'
    )
}
