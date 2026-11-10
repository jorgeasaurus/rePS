function Test-Palindrome {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    $clean = ($Text -replace '[^a-zA-Z0-9]', '').ToLowerInvariant()
    $chars = $clean.ToCharArray()
    [array]::Reverse($chars)
    $clean -eq (-join $chars)
}
