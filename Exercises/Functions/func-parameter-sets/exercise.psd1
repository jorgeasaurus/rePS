@{
    Id           = 'func-parameter-sets'
    Title        = 'Parameter sets'
    Topic        = 'Functions'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('parameters', 'parameter-sets')
    FunctionName = 'Convert-Temperature'
    Author       = 'rePS'
    Prompt       = @'
Write Convert-Temperature with two parameter sets:
  -Celsius <double>     returns the Fahrenheit value   (C * 9/5 + 32)
  -Fahrenheit <double>  returns the Celsius value      ((F - 32) * 5/9)

Exactly one of the two must be given: both, or neither, is an error.
Round results to 2 decimal places.

    Convert-Temperature -Celsius 100      # 212
    Convert-Temperature -Fahrenheit 32    # 0
'@
    Hints        = @(
        '[Parameter(Mandatory, ParameterSetName = ''FromCelsius'')] puts a parameter in a set.'
        'When each set has a mandatory parameter, PowerShell rejects calls that mix the sets.'
        'Branch on $PSCmdlet.ParameterSetName. That needs [CmdletBinding()]. [Math]::Round(x, 2) rounds the result.'
    )
}
