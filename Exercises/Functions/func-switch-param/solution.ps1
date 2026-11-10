function Get-Shout {
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [switch]$Loud
    )

    if ($Loud) { "$($Text.ToUpper())!" } else { $Text }
}
