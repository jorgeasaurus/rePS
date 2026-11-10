function Get-RectangleArea {
    [OutputType([double])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateRange('Positive')]
        [double]$Width,

        [Parameter(Mandatory, Position = 1)]
        [ValidateRange('Positive')]
        [double]$Height
    )

    $Width * $Height
}
