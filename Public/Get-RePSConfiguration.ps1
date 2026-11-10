function Get-RePSConfiguration {
    <#
    .SYNOPSIS
        Shows the current rePS settings and data locations.
    .DESCRIPTION
        Returns the update-check cadence, when the last update check ran, the latest
        version seen on the PowerShell Gallery, and where rePS stores its data.
    .EXAMPLE
        Get-RePSConfiguration
    #>
    [CmdletBinding()]
    param()

    $config = Get-RePSConfig

    $lastCheck = $null
    $lastCheckPath = Get-RePSUpdatePath -Kind LastCheck
    if (Test-Path -LiteralPath $lastCheckPath) {
        $parsed = [datetime]::MinValue
        if ([datetime]::TryParse((Get-Content -LiteralPath $lastCheckPath -Raw).Trim(), [ref]$parsed)) { $lastCheck = $parsed }
    }

    $latest = $null
    $latestPath = Get-RePSUpdatePath -Kind Latest
    if (Test-Path -LiteralPath $latestPath) {
        try { $latest = [version](Get-Content -LiteralPath $latestPath -Raw | ConvertFrom-Json).Version } catch { $latest = $null }
    }

    [pscustomobject]@{
        PSTypeName           = 'RePS.Configuration'
        UpdateCheck          = $config.UpdateCheck
        UpdateCheckDisabled  = Test-RePSUpdateCheckDisabled
        LastUpdateCheck      = $lastCheck
        InstalledVersion     = $script:ModuleVersion
        LatestGalleryVersion = $latest
        DataPath             = Get-RePSHome
        WorkspacePath        = Get-RePSWorkspacePath
    }
}
