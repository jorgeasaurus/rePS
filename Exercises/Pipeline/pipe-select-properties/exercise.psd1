@{
    Id           = 'pipe-select-properties'
    Title        = 'Pick properties'
    Topic        = 'Pipeline'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('select-object', 'objects')
    FunctionName = 'Select-UserSummary'
    Author       = 'rePS'
    Prompt       = @'
Write Select-UserSummary so it takes user objects (-User) that have Id, Name, Email
and Department properties, and outputs objects with ONLY Name and Email.

    $users | Select-UserSummary   # objects with Name and Email only
'@
    Hints        = @(
        'Select-Object -Property chooses which properties to keep.'
        'The function must accept pipeline input: add ValueFromPipeline to the parameter and use a process block.'
    )
}
