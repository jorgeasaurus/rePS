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

    $lastError = $null
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            return & $ScriptBlock
        } catch {
            $lastError = $_
            Write-Verbose "Attempt $attempt failed: $($_.Exception.Message)"
            if ($attempt -lt $MaxAttempts -and $DelayMilliseconds -gt 0) {
                Start-Sleep -Milliseconds $DelayMilliseconds
            }
        }
    }
    throw $lastError
}
