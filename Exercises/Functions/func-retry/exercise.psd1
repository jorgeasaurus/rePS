@{
    Id           = 'func-retry'
    Title        = 'Retry with finally'
    Topic        = 'Functions'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('errors', 'scriptblocks', 'try-catch-finally')
    FunctionName = 'Invoke-WithRetry'
    Author       = 'rePS'
    Prompt       = @'
Write Invoke-WithRetry so it runs -ScriptBlock and returns its output.
  - If the scriptblock throws, retry it, up to -MaxAttempts runs in total.
  - Wait -DelayMilliseconds between attempts (default 0).
  - If every attempt fails, rethrow the LAST error (the original exception).
  - Write a verbose message ("Attempt N failed") for each failure.

    $n = 0
    Invoke-WithRetry -MaxAttempts 3 -ScriptBlock { $script:n++; if ($n -lt 3) { throw 'flaky' }; 'ok' }
    # ok   (after 2 failures)
'@
    Hints        = @(
        'Loop for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) with try { return & $ScriptBlock } inside.'
        'In catch, $_ is the ErrorRecord. Keep it, and rethrow it after the loop with throw $lastError.'
        'Inside a catch block, a bare throw rethrows the current error. After the loop you need to keep it yourself.'
    )
}
