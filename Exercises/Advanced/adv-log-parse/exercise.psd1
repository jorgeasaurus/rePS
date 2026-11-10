@{
    Id           = 'adv-log-parse'
    Title        = 'Parse log lines'
    Topic        = 'Advanced'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('regex', 'named-captures', 'datetime', 'pipeline')
    FunctionName = 'ConvertFrom-LogLine'
    Author       = 'rePS'
    Prompt       = @'
Write ConvertFrom-LogLine so it takes log lines from the pipeline (or -Line) in the format

    2026-01-05 12:00:01 [ERROR] Disk full on C:

and outputs objects with:
  Timestamp  [datetime]
  Level      [string]  (uppercase: INFO, WARN, ERROR ...)
  Message    [string]
Lines that do not match the format are silently skipped.
'@
    Hints        = @(
        'Named captures: (?<Level>[A-Za-z]+) puts the match in $Matches.Level after a successful -match.'
        'Parse dates without depending on the culture: [datetime]::ParseExact($s, ''yyyy-MM-dd HH:mm:ss'', [cultureinfo]::InvariantCulture)'
        'Use a process block and only output when -match is $true.'
    )
}
