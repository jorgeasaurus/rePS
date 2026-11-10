function Get-RePSHome {
    <#
    .SYNOPSIS
        Returns the rePS data folder ($env:REPS_HOME or ~/.reps), creating it if needed.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $root = if ($env:REPS_HOME) { $env:REPS_HOME } else { Join-Path -Path $HOME -ChildPath '.reps' }
    if (-not (Test-Path -LiteralPath $root)) {
        $null = New-Item -Path $root -ItemType Directory -Force -WhatIf:$false
    }
    $root
}

function Get-RePSWorkspacePath {
    <#
    .SYNOPSIS
        Returns the workspace folder (or the workspace file for an exercise id).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]$Id
    )

    $workspace = Join-Path -Path (Get-RePSHome) -ChildPath 'workspace'
    if (-not (Test-Path -LiteralPath $workspace)) {
        $null = New-Item -Path $workspace -ItemType Directory -Force -WhatIf:$false
    }
    if ($Id) { Join-Path -Path $workspace -ChildPath "$Id.ps1" } else { $workspace }
}

function Read-RePSProgress {
    <#
    .SYNOPSIS
        Loads progress.json as a hashtable. Returns an empty structure when missing or unreadable.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $path = Join-Path -Path (Get-RePSHome) -ChildPath 'progress.json'
    $progress = $null
    if (Test-Path -LiteralPath $path) {
        try {
            $progress = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        } catch {
            Write-Warning "Could not read '$path' ($($_.Exception.Message)). Starting with empty progress."
        }
    }
    if (-not $progress) { $progress = @{} }
    if (-not $progress.ContainsKey('Version')) { $progress.Version = 1 }
    if (-not $progress.ContainsKey('Current')) { $progress.Current = $null }
    if (-not $progress.ContainsKey('Exercises') -or $null -eq $progress.Exercises) { $progress.Exercises = @{} }
    $progress
}

function Save-RePSProgress {
    <#
    .SYNOPSIS
        Persists the progress hashtable to progress.json.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Progress
    )

    $path = Join-Path -Path (Get-RePSHome) -ChildPath 'progress.json'
    $Progress | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $path -Encoding utf8
}

function Get-RePSProgressEntry {
    <#
    .SYNOPSIS
        Returns (creating if needed) the progress entry for an exercise id.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Progress,

        [Parameter(Mandatory)]
        [string]$Id
    )

    if (-not $Progress.Exercises.ContainsKey($Id)) {
        $Progress.Exercises[$Id] = @{
            Status        = 'Started'
            Attempts      = 0
            HintsUsed     = 0
            SolutionShown = $false
            FirstSeen     = (Get-Date).ToString('o')
            LastAttempt   = $null
            PassedAt      = $null
        }
    }
    $Progress.Exercises[$Id]
}
