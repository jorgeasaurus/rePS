function Invoke-WithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [ValidateRange(1, 100)]
        [int]$MaxAttempts = 3,

        [ValidateRange(0, 60000)]
        [int]$DelayMilliseconds = 0
    )

    # TODO: run $ScriptBlock, retrying on failure; rethrow the last error
    throw 'Not implemented'
}
