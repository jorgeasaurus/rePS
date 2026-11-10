@{
    Id           = 'pipe-group-extension'
    Title        = 'Count files by extension'
    Topic        = 'Pipeline'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('group-object', 'sort-object')
    FunctionName = 'Get-ExtensionCount'
    Author       = 'rePS'
    Prompt       = @'
Write Get-ExtensionCount so it takes file names (-FileName) and outputs one object
per extension with Extension and Count properties.
  - Extensions are lowercase and include the dot ('.ps1').
  - Names without an extension are grouped as '(none)'.
  - Sort by Count descending, then by Extension ascending.

    Get-ExtensionCount -FileName 'a.ps1', 'b.PS1', 'c.txt', 'README'
    # .ps1 2, (none) 1, .txt 1
'@
    Hints        = @(
        '[System.IO.Path]::GetExtension(''b.PS1'') returns ''.PS1''. Lowercase it.'
        'Group-Object can group on a scriptblock: Group-Object { ... }. Each group has Name and Count.'
        'Sort-Object accepts several sort keys: @{ Expression = ''Count''; Descending = $true }, ''Extension'''
    )
}
