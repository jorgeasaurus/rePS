function Read-JsonConfig {
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw [System.IO.FileNotFoundException]::new("Config not found: $Path", $Path)
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    try {
        $raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    } catch {
        throw [System.FormatException]::new("Invalid JSON in ${Path}: $($_.Exception.Message)")
    }
}
