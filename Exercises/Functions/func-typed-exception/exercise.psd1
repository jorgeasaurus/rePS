@{
    Id           = 'func-typed-exception'
    Title        = 'Throw specific exceptions'
    Topic        = 'Functions'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('errors', 'exceptions', 'json')
    FunctionName = 'Read-JsonConfig'
    Author       = 'rePS'
    Prompt       = @'
Write Read-JsonConfig so it reads the JSON file at -Path and returns it as a
hashtable. Callers should be able to catch specific failures:
  - missing file  -> throw [System.IO.FileNotFoundException]
  - invalid JSON  -> throw [System.FormatException]  (include the path in the message)

    try { Read-JsonConfig -Path ./nope.json }
    catch [System.IO.FileNotFoundException] { 'no config' }
'@
    Hints        = @(
        'You can throw an exception object: throw [System.IO.FileNotFoundException]::new("Config not found: $Path", $Path)'
        'ConvertFrom-Json -AsHashtable returns a hashtable. Put it in a try/catch to detect bad JSON.'
        'Inside catch, rethrow as the type you want: throw [System.FormatException]::new("Invalid JSON in ${Path}: $($_.Exception.Message)")'
    )
}
