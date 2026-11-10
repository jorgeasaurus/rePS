@{
    Id           = 'func-validate-set'
    Title        = 'ValidateSet'
    Topic        = 'Functions'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('parameters', 'validation')
    FunctionName = 'Format-LogMessage'
    Author       = 'rePS'
    Prompt       = @'
Write Format-LogMessage so it returns "[LEVEL] Message", with the level in
uppercase.
  - -Level only accepts Debug, Info, Warning or Error (tab-completable!).
  - -Level defaults to Info.

    Format-LogMessage -Message 'Disk full' -Level Error   # [ERROR] Disk full
    Format-LogMessage -Message 'Started'                  # [INFO] Started
'@
    Hints        = @(
        '[ValidateSet(''Debug'', ''Info'', ''Warning'', ''Error'')] restricts the values and enables tab completion.'
        'Call .ToUpper() inside a subexpression: "[$($Level.ToUpper())] $Message"'
    )
}
