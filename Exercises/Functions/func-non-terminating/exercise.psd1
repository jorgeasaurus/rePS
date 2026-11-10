@{
    Id           = 'func-non-terminating'
    Title        = 'Non-terminating errors'
    Topic        = 'Functions'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('errors', 'erroraction')
    FunctionName = 'Get-ExistingPath'
    Author       = 'rePS'
    Prompt       = @'
Write Get-ExistingPath so it checks every path in -Path:
  - existing paths are output (as given)
  - each missing path produces a NON-terminating error (Write-Error),
    so processing continues with the next path

This makes -ErrorAction and -ErrorVariable work for callers:

    Get-ExistingPath -Path $HOME, '/nope' -ErrorAction SilentlyContinue -ErrorVariable e
    # outputs $HOME; $e holds one error about /nope
'@
    Hints        = @(
        'Test-Path -LiteralPath tells you whether a path exists.'
        'throw stops everything. Write-Error records the error and carries on.'
        'Add [CmdletBinding()] so the function gets -ErrorAction and -ErrorVariable for free.'
    )
}
