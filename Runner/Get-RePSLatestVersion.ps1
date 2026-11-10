#Requires -Version 7.2
<#
.SYNOPSIS
    Looks up the latest stable version of a module on the PowerShell Gallery and caches it.
.DESCRIPTION
    Run by Start-RePSUpdateCheck in a background thread job, so it never blocks the session.
    Writes {"Version": "x.y.z", "CheckedAt": "..."} to -OutputPath. Any failure (offline,
    timeout, gallery down) is silent: the cache is left untouched and no notice is shown.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [string]$GalleryUri = 'https://www.powershellgallery.com/api/v2',

    # Read an OData feed from disk instead of the network (used by tests).
    [string]$FeedFile
)

try {
    $entries = if ($FeedFile) {
        ([xml](Get-Content -LiteralPath $FeedFile -Raw -ErrorAction Stop)).feed.entry
    } else {
        $uri = "$GalleryUri/FindPackagesById()?id='$ModuleName'&`$filter=IsLatestVersion"
        Invoke-RestMethod -Uri $uri -TimeoutSec 15 -ErrorAction Stop
    }

    $text = { param($value) if ($value -is [System.Xml.XmlElement]) { $value.InnerText } else { "$value" } }

    $latest = @($entries) |
        Where-Object { $_ -and (& $text $_.properties.IsPrerelease) -ne 'true' } |
        ForEach-Object {
            $parsed = $null
            if ([version]::TryParse((& $text $_.properties.Version), [ref]$parsed)) { $parsed }
        } |
        Sort-Object -Descending |
        Select-Object -First 1

    if ($latest) {
        @{ Version = $latest.ToString(); CheckedAt = (Get-Date).ToString('o') } |
            ConvertTo-Json | Set-Content -LiteralPath $OutputPath -Encoding utf8
    }
} catch {
    Write-Verbose "rePS update check failed: $($_.Exception.Message)"
}
