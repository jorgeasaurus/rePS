@{
    Id           = 'func-mandatory-params'
    Title        = 'Mandatory, typed parameters'
    Topic        = 'Functions'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('parameters', 'validation')
    FunctionName = 'Get-RectangleArea'
    Author       = 'rePS'
    Prompt       = @'
Write Get-RectangleArea so it returns -Width multiplied by -Height.
  - Both parameters are mandatory and typed [double].
  - Both must be greater than zero (use a validation attribute).
  - Width is position 0 and Height is position 1.

    Get-RectangleArea 2 3.5   # 7
'@
    Hints        = @(
        '[Parameter(Mandatory, Position = 0)] goes above the parameter.'
        '[ValidateRange(''Positive'')] rejects 0 and negative numbers (PowerShell 7+).'
    )
}
