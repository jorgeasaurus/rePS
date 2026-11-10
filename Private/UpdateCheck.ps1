# Update notifications, modelled on tiPS' automatic update: a cadence setting, a
# last-check date file, and a background job at import so startup is never blocked.
# Unlike tiPS, rePS only looks up the latest version and tells you; it never runs
# Update-Module for you.

$script:UpdateCadences = @('Never', 'Daily', 'Weekly', 'BiWeekly', 'Monthly')
$script:UpdateJobName = 'rePS.UpdateCheck'
$script:UpdateNoticeShown = $false

function Get-RePSConfig {
    <#
    .SYNOPSIS
        Loads config.json with defaults for missing or invalid values.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $config = @{ UpdateCheck = 'Weekly' }
    $path = Join-Path -Path (Get-RePSHome) -ChildPath 'config.json'
    if (Test-Path -LiteralPath $path) {
        try {
            $stored = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
            if ($stored.UpdateCheck -in $script:UpdateCadences) { $config.UpdateCheck = $stored.UpdateCheck }
        } catch {
            Write-Verbose "Ignoring unreadable config '$path': $($_.Exception.Message)"
        }
    }
    $config
}

function Save-RePSConfig {
    <#
    .SYNOPSIS
        Persists the config hashtable to config.json.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    $path = Join-Path -Path (Get-RePSHome) -ChildPath 'config.json'
    $Config | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding utf8
}

function Get-RePSUpdatePath {
    <#
    .SYNOPSIS
        Returns the path of the last-check date file or the cached latest-version file.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('LastCheck', 'Latest')]
        [string]$Kind
    )

    $name = if ($Kind -eq 'LastCheck') { 'update-lastcheck.txt' } else { 'update-latest.json' }
    Join-Path -Path (Get-RePSHome) -ChildPath $name
}

function Test-RePSUpdateCheckDue {
    <#
    .SYNOPSIS
        Returns $true when the cadence has elapsed since the last check.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Never', 'Daily', 'Weekly', 'BiWeekly', 'Monthly')]
        [string]$Cadence,

        [datetime]$LastChecked = [datetime]::MinValue,

        [datetime]$Now = [datetime]::Now
    )

    $days = ($Now - $LastChecked).Days
    switch ($Cadence) {
        'Never' { $false }
        'Daily' { $days -ge 1 }
        'Weekly' { $days -ge 7 }
        'BiWeekly' { $days -ge 14 }
        'Monthly' { $days -ge 30 }
    }
}

function Test-RePSUpdateCheckDisabled {
    <#
    .SYNOPSIS
        Returns $true when update checks are disabled by environment (opt-out or CI).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    [bool]($env:REPS_NO_UPDATE_CHECK -or $env:CI -or $env:TF_BUILD -or $env:GITHUB_ACTIONS)
}

function Start-RePSUpdateCheck {
    <#
    .SYNOPSIS
        Starts a background lookup of the latest gallery version when one is due.
    .DESCRIPTION
        Called at module import. Never throws and never blocks: the lookup runs in a
        thread job, and the check date is recorded up front (like tiPS) so a failing
        network does not trigger a lookup on every import.
    #>
    [CmdletBinding()]
    param()

    try {
        if (Test-RePSUpdateCheckDisabled) { return }

        $config = Get-RePSConfig
        if ($config.UpdateCheck -eq 'Never') { return }

        $lastCheckPath = Get-RePSUpdatePath -Kind LastCheck
        $lastChecked = [datetime]::MinValue
        if (Test-Path -LiteralPath $lastCheckPath) {
            $null = [datetime]::TryParse((Get-Content -LiteralPath $lastCheckPath -Raw).Trim(), [ref]$lastChecked)
        }
        if (-not (Test-RePSUpdateCheckDue -Cadence $config.UpdateCheck -LastChecked $lastChecked)) { return }
        if (Get-Job -Name $script:UpdateJobName -ErrorAction Ignore | Where-Object State -EQ 'Running') { return }

        [datetime]::Now.Date.ToString('o') | Set-Content -LiteralPath $lastCheckPath -Encoding utf8 -NoNewline

        $runner = Join-Path -Path $script:ModuleRoot -ChildPath 'Runner/Get-RePSLatestVersion.ps1'
        $null = Start-ThreadJob -Name $script:UpdateJobName -FilePath $runner -ArgumentList 'rePS', (Get-RePSUpdatePath -Kind Latest)
    } catch {
        Write-Verbose "rePS update check could not start: $($_.Exception.Message)"
    }
}

function Show-RePSUpdateNotice {
    <#
    .SYNOPSIS
        Writes a one-line notice (once per session) when a newer rePS is on the gallery.
    #>
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    # Tidy up the finished background job so it does not linger in Get-Job.
    Get-Job -Name $script:UpdateJobName -ErrorAction Ignore |
        Where-Object State -NE 'Running' |
        Remove-Job -Force -ErrorAction Ignore

    if ($script:UpdateNoticeShown -and -not $Force) { return }
    if ((Get-RePSConfig).UpdateCheck -eq 'Never') { return }

    $latestPath = Get-RePSUpdatePath -Kind Latest
    if (-not (Test-Path -LiteralPath $latestPath)) { return }

    try {
        $cached = Get-Content -LiteralPath $latestPath -Raw | ConvertFrom-Json -ErrorAction Stop
        $latest = [version]$cached.Version
    } catch {
        return
    }

    if ($latest -gt $script:ModuleVersion) {
        $script:UpdateNoticeShown = $true
        Write-Host "  rePS $latest is available (you have $($script:ModuleVersion)). Update with: Update-Module rePS" -ForegroundColor Magenta
        Write-Host '  Turn these notices off with: Set-RePSConfiguration -UpdateCheck Never' -ForegroundColor DarkGray
        Write-Host ''
    }
}
