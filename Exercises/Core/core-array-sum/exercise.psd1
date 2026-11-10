@{
    Id           = 'core-array-sum'
    Title        = 'Sum an array'
    Topic        = 'Core'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('arrays', 'loops')
    FunctionName = 'Get-ArraySum'
    Author       = 'rePS'
    Prompt       = @'
Write Get-ArraySum so it returns the sum of the integers in -Numbers.
An empty array sums to 0.

    Get-ArraySum -Numbers 1, 2, 3   # 6
    Get-ArraySum -Numbers @()       # 0
'@
    Hints        = @(
        'Start an accumulator at 0 and add each number with a foreach loop.'
        'Or let the pipeline do it: ($Numbers | Measure-Object -Sum).Sum. Check what that returns for an empty array.'
    )
}
