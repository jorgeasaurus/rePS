@{
    Id           = 'pipe-measure-stats'
    Title        = 'Basic statistics'
    Topic        = 'Pipeline'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('measure-object', 'pscustomobject')
    FunctionName = 'Get-NumberStatistic'
    Author       = 'rePS'
    Prompt       = @'
Write Get-NumberStatistic so it returns ONE object with Count, Sum, Minimum,
Maximum and Average properties for -Numbers.

    Get-NumberStatistic -Numbers 2, 4, 6
    # Count: 3  Sum: 12  Minimum: 2  Maximum: 6  Average: 4
'@
    Hints        = @(
        'Measure-Object has -Sum, -Minimum, -Maximum and -Average switches, and you can use them all at once.'
        'Measure-Object returns its own object type with some extra empty properties. Build a [pscustomobject] with just the five you need.'
    )
}
