@{
    Id           = 'func-should-process'
    Title        = 'Support -WhatIf'
    Topic        = 'Functions'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('shouldprocess', 'filesystem', 'safety')
    FunctionName = 'Remove-StaleFile'
    Author       = 'rePS'
    Prompt       = @'
Write Remove-StaleFile so it deletes files in the folder -Path whose LastWriteTime
is older than -Days days, and outputs the FileInfo of each file it deletes.
  - It must support -WhatIf and -Confirm: with -WhatIf nothing is deleted and
    nothing is output.
  - Only files directly in the folder (no recursion). Leave folders alone.

    Remove-StaleFile -Path ./logs -Days 30 -WhatIf
    # What if: Performing the operation "Delete stale file" on target "..."
'@
    Hints        = @(
        '[CmdletBinding(SupportsShouldProcess)] adds -WhatIf and -Confirm for you.'
        'Guard the destructive call: if ($PSCmdlet.ShouldProcess($file.FullName, ''Delete stale file'')) { ... }'
        'Get-ChildItem -File returns only files. Compare $_.LastWriteTime with (Get-Date).AddDays(-$Days).'
    )
}
