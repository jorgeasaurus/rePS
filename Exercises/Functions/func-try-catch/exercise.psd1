@{
    Id           = 'func-try-catch'
    Title        = 'Catch and warn'
    Topic        = 'Functions'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('errors', 'try-catch')
    FunctionName = 'Invoke-SafeDivide'
    Author       = 'rePS'
    Prompt       = @'
Write Invoke-SafeDivide so it returns [int] -Dividend divided by [int] -Divisor.
When the division fails (divide by zero), it must NOT throw. Instead it should:
  - write a warning containing the words "divide by zero"
  - return $null

    Invoke-SafeDivide -Dividend 10 -Divisor 2   # 5
    Invoke-SafeDivide -Dividend 1 -Divisor 0    # WARNING: Cannot divide by zero ...
'@
    Hints        = @(
        'Integer division by a zero literal fails at parse time, but with variables it throws [System.DivideByZeroException] at runtime.'
        'Wrap the division in try { } catch { }.'
        'Write-Warning writes to the warning stream. Return $null explicitly afterwards.'
    )
}
