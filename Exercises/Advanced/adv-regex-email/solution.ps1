function Test-EmailAddress {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Address
    )

    $Address -match '^[^@\s]+@[^@\s]+\.[A-Za-z]{2,}$'
}
