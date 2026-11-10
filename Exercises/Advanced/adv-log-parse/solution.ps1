function ConvertFrom-LogLine {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string[]]$Line
    )

    begin {
        $pattern = '^(?<Timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(?<Level>[A-Za-z]+)\] (?<Message>.*)$'
    }
    process {
        foreach ($text in $Line) {
            if ($text -notmatch $pattern) { continue }
            $timestamp = [datetime]::MinValue
            $valid = [datetime]::TryParseExact($Matches.Timestamp, 'yyyy-MM-dd HH:mm:ss', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$timestamp)
            if (-not $valid) { continue }
            [pscustomobject]@{
                Timestamp = $timestamp
                Level     = $Matches.Level.ToUpperInvariant()
                Message   = $Matches.Message
            }
        }
    }
}
