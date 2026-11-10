function ConvertTo-SnakeCase {
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text
    )

    ($Text -creplace '(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', '_').ToLowerInvariant()
}
