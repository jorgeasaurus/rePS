function Get-ExtensionCount {
    param(
        [Parameter(Mandatory)]
        [string[]]$FileName
    )

    $FileName |
        ForEach-Object {
            $ext = [System.IO.Path]::GetExtension($_).ToLowerInvariant()
            if ($ext) { $ext } else { '(none)' }
        } |
        Group-Object |
        ForEach-Object { [pscustomobject]@{ Extension = $_.Name; Count = $_.Count } } |
        Sort-Object -Property @{ Expression = 'Count'; Descending = $true }, @{ Expression = 'Extension'; Ascending = $true }
}
