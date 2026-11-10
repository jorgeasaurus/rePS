function Convert-Temperature {
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'FromCelsius')]
        [double]$Celsius,

        [Parameter(Mandatory, ParameterSetName = 'FromFahrenheit')]
        [double]$Fahrenheit
    )

    switch ($PSCmdlet.ParameterSetName) {
        'FromCelsius' { [Math]::Round($Celsius * 9 / 5 + 32, 2) }
        'FromFahrenheit' { [Math]::Round(($Fahrenheit - 32) * 5 / 9, 2) }
    }
}
