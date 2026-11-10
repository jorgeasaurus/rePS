function Get-ReversedString {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$InputString
    )

    $chars = $InputString.ToCharArray()
    [array]::Reverse($chars)
    -join $chars
}
