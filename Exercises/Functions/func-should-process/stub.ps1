function Remove-StaleFile {
    # TODO: add SupportsShouldProcess
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateRange(0, 36500)]
        [int]$Days
    )

    # TODO: delete files older than $Days, honouring -WhatIf, and output the deleted files
    throw 'Not implemented'
}
