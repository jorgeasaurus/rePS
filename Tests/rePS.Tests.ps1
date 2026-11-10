#Requires -Modules Pester

BeforeAll {
    $manifestPath = Join-Path $PSScriptRoot '..' 'rePS.psd1'

    $script:originalHome = $env:REPS_HOME
    $script:originalNoOpen = $env:REPS_NO_OPEN
    $script:originalNoUpdate = $env:REPS_NO_UPDATE_CHECK
    $env:REPS_NO_OPEN = '1'
    $env:REPS_NO_UPDATE_CHECK = '1'   # never touch the network from tests
    $env:REPS_HOME = Join-Path $TestDrive 'import-home'

    Import-Module $manifestPath -Force

    function Reset-TestHome {
        $env:REPS_HOME = Join-Path $TestDrive ([guid]::NewGuid())
    }

    function Get-RePSPlatformName {
        if ($IsWindows) { 'Windows' } elseif ($IsMacOS) { 'MacOS' } else { 'Linux' }
    }

    function Get-TestProgress {
        Get-Content (Join-Path $env:REPS_HOME 'progress.json') -Raw | ConvertFrom-Json -AsHashtable
    }

    $script:sampleId = 'core-greeting'
    $script:sampleFolder = Join-Path $PSScriptRoot '..' 'Exercises' 'Core' $sampleId
}

AfterAll {
    $env:REPS_HOME = $script:originalHome
    $env:REPS_NO_OPEN = $script:originalNoOpen
    $env:REPS_NO_UPDATE_CHECK = $script:originalNoUpdate
    Remove-Module rePS -Force -ErrorAction SilentlyContinue
}

Describe 'Module manifest' {
    BeforeAll {
        $manifest = Test-ModuleManifest -Path $manifestPath
    }
    It 'is valid' {
        $manifest | Should -Not -BeNullOrEmpty
    }
    It 'requires PowerShell 7.2+' {
        $manifest.PowerShellVersion | Should -Be ([version]'7.2')
    }
    It 'requires Pester 5.5+' {
        $pester = $manifest.RequiredModules | Where-Object Name -EQ 'Pester'
        $pester.Version | Should -BeGreaterOrEqual ([version]'5.5.0')
    }
    It 'exports every public function and nothing else' {
        $public = (Get-ChildItem (Join-Path $PSScriptRoot '..' 'Public') -Filter '*.ps1').BaseName | Sort-Object
        ($manifest.ExportedFunctions.Keys | Sort-Object) | Should -Be $public
    }
    It 'exports the short aliases' {
        $manifest.ExportedAliases.Keys | Sort-Object | Should -Be ('reps', 'rept', 'reph', 'repsol', 'repp' | Sort-Object)
    }
    It 'has a matching CHANGELOG entry' {
        $changelog = Get-Content (Join-Path $PSScriptRoot '..' 'CHANGELOG.md') -Raw
        $changelog | Should -Match ([regex]::Escape("## [$($manifest.Version)]"))
    }
}

Describe 'Comment-based help' {
    It '<_> has a synopsis, description and example' -ForEach @(
        (Get-ChildItem (Join-Path $PSScriptRoot '..' 'Public') -Filter '*.ps1').BaseName
    ) {
        $help = Get-Help $_ -Full
        $help.Synopsis | Should -Not -BeNullOrEmpty
        $help.Synopsis | Should -Not -Match '^\s*\w+-\w+\s*$' -Because 'the synopsis should not just be the generated syntax'
        $help.Examples.Example | Should -Not -BeNullOrEmpty
    }
}

Describe 'Get-RePSExercise' {
    BeforeEach { Reset-TestHome }

    It 'lists exercises for the current platform with Unseen status' {
        $all = @(Get-RePSExercise)
        $all.Count | Should -BeGreaterThan 0
        $all.Status | Sort-Object -Unique | Should -Be 'Unseen'
    }
    It 'filters by topic and level' {
        $r = @(Get-RePSExercise -Topic Core -Level 1)
        $r.Count | Should -BeGreaterThan 0
        $r.Topic | Sort-Object -Unique | Should -Be 'Core'
        $r.Level | Sort-Object -Unique | Should -Be 1
    }
    It 'hides other-platform exercises unless -AllPlatforms' {
        $platform = if ($IsWindows) { 'Windows' } elseif ($IsMacOS) { 'MacOS' } else { 'Linux' }
        (Get-RePSExercise).Platforms | Should -Contain $platform
        foreach ($e in Get-RePSExercise) { $e.Platforms | Should -Contain $platform }
        @(Get-RePSExercise -AllPlatforms).Count | Should -BeGreaterOrEqual @(Get-RePSExercise).Count
    }
    It 'returns a single exercise by id' {
        (Get-RePSExercise -Id $sampleId).Id | Should -Be $sampleId
    }
}

Describe 'Start-RePSExercise' {
    BeforeEach { Reset-TestHome }

    It 'writes the stub with a header to the workspace' {
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        $file = Join-Path $env:REPS_HOME 'workspace' "$sampleId.ps1"
        $file | Should -Exist
        $content = Get-Content $file -Raw
        $content | Should -Match 'rePS exercise: Say hello'
        $content | Should -Match 'function Get-Greeting'
    }
    It 'records the exercise as current and Started' {
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        $p = Get-TestProgress
        $p.Current | Should -Be $sampleId
        $p.Exercises[$sampleId].Status | Should -Be 'Started'
    }
    It 'resumes an existing workspace file instead of overwriting it' {
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        $file = Join-Path $env:REPS_HOME 'workspace' "$sampleId.ps1"
        'my work' | Set-Content $file
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        Get-Content $file -Raw | Should -Match 'my work'
    }
    It 'overwrites with -Force' {
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        $file = Join-Path $env:REPS_HOME 'workspace' "$sampleId.ps1"
        'my work' | Set-Content $file
        Start-RePSExercise -Id $sampleId -NoOpen -Force 6>$null
        Get-Content $file -Raw | Should -Not -Match 'my work'
    }
    It 'picks a random exercise within the filters' {
        $e = Start-RePSExercise -Topic Pipeline -Level 2 -NoOpen -PassThru 6>$null
        $e.Topic | Should -Be 'Pipeline'
        $e.Level | Should -Be 2
    }
    It 'does not repeat the current exercise when others match' {
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        foreach ($i in 1..5) {
            $e = Start-RePSExercise -Topic Core -Level 1 -NoOpen -PassThru 6>$null
            $e.Id | Should -Not -Be $sampleId
            Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        }
    }
    It '-Unseen skips exercises already started' {
        $ids = (Get-RePSExercise -Topic Core -Level 1).Id
        foreach ($id in $ids | Select-Object -Skip 1) { Start-RePSExercise -Id $id -NoOpen 6>$null }
        $e = Start-RePSExercise -Topic Core -Level 1 -Unseen -NoOpen -PassThru 6>$null
        $e.Id | Should -Be $ids[0]
    }
    It 'warns when nothing matches' {
        $null = Start-RePSExercise -Review -NoOpen -WarningVariable w -WarningAction SilentlyContinue 6>$null
        $w | Should -Not -BeNullOrEmpty
    }
    It 'throws for an unknown id' {
        { Start-RePSExercise -Id 'nope-nope' -NoOpen 6>$null } | Should -Throw '*not found*'
    }
    It 'refuses an exercise for another OS' {
        $other = Get-RePSExercise -AllPlatforms | Where-Object { (Get-RePSPlatformName) -notin $_.Platforms } | Select-Object -First 1
        if (-not $other) { Set-ItResult -Skipped -Because 'every exercise supports this OS'; return }
        { Start-RePSExercise -Id $other.Id -NoOpen 6>$null } | Should -Throw '*only runs on*'
        { Test-RePSExercise -Id $other.Id -Quiet 6>$null } | Should -Throw '*only runs on*'
    }
}

Describe 'Test-RePSExercise' {
    BeforeEach {
        Reset-TestHome
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        $workspaceFile = Join-Path $env:REPS_HOME 'workspace' "$sampleId.ps1"
    }

    It 'fails the untouched stub and records Failed' {
        $r = Test-RePSExercise -Quiet -PassThru 6>$null
        $r.Passed | Should -BeFalse
        $r.FailedCount | Should -BeGreaterThan 0
        (Get-TestProgress).Exercises[$sampleId].Status | Should -Be 'Failed'
    }
    It 'passes the reference solution and records Passed' {
        Copy-Item (Join-Path $sampleFolder 'solution.ps1') $workspaceFile -Force
        $r = Test-RePSExercise -Quiet -PassThru 6>$null
        $r.Passed | Should -BeTrue
        $r.Status | Should -Be 'Passed'
        $p = (Get-TestProgress).Exercises[$sampleId]
        $p.Attempts | Should -Be 1
        $p.PassedAt | Should -Not -BeNullOrEmpty
    }
    It 'records Assisted when the solution was shown first' {
        $null = Show-RePSSolution -PassThru
        Copy-Item (Join-Path $sampleFolder 'solution.ps1') $workspaceFile -Force
        (Test-RePSExercise -Quiet -PassThru 6>$null).Status | Should -Be 'Assisted'
    }
    It 'does not downgrade a pass when a later attempt fails' {
        Copy-Item (Join-Path $sampleFolder 'solution.ps1') $workspaceFile -Force
        $null = Test-RePSExercise -Quiet 6>$null
        'function Get-Greeting { "broken" }' | Set-Content $workspaceFile
        $null = Test-RePSExercise -Quiet 6>$null
        (Get-TestProgress).Exercises[$sampleId].Status | Should -Be 'Passed'
    }
    It 'tests an explicit -Path' {
        $r = Test-RePSExercise -Id $sampleId -Path (Join-Path $sampleFolder 'solution.ps1') -Quiet -PassThru 6>$null
        $r.Passed | Should -BeTrue
    }
    It 'isolates user code from the calling session' {
        Copy-Item (Join-Path $sampleFolder 'solution.ps1') $workspaceFile -Force
        $null = Test-RePSExercise -Quiet 6>$null
        Get-Command Get-Greeting -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
    It 'reports a solution that does not parse as a failure' {
        'function Get-Greeting {' | Set-Content $workspaceFile
        (Test-RePSExercise -Quiet -PassThru 6>$null).Passed | Should -BeFalse
    }
    It 'times out an infinite loop, records a failure, and does not hang' {
        'function Get-Greeting { while ($true) { } }' | Set-Content $workspaceFile
        $elapsed = Measure-Command { $script:r = Test-RePSExercise -Quiet -PassThru -TimeoutSeconds 8 6>$null }
        $r.Passed | Should -BeFalse
        $r.Failed | Should -Match 'Timed out'
        $elapsed.TotalSeconds | Should -BeLessThan 30
        (Get-TestProgress).Exercises[$sampleId].Status | Should -Be 'Failed'
    }
    It 'handles a solution path containing spaces' {
        $dir = Join-Path $TestDrive 'with space'
        $null = New-Item -ItemType Directory -Path $dir -Force
        $file = Join-Path $dir 'my solution.ps1'
        Copy-Item (Join-Path $sampleFolder 'solution.ps1') $file
        (Test-RePSExercise -Id $sampleId -Path $file -Quiet -PassThru 6>$null).Passed | Should -BeTrue
    }
    It 'keeps progress written by another session during the run' {
        # The solution runs inside the test process, so it can play "another session"
        # that reveals the solution while the tests are running.
        $sideEffect = @'
$progressPath = Join-Path $env:REPS_HOME 'progress.json'
$p = Get-Content $progressPath -Raw | ConvertFrom-Json -AsHashtable
$p.Exercises['core-greeting'].SolutionShown = $true
$p | ConvertTo-Json -Depth 5 | Set-Content $progressPath
'@
        (Get-Content (Join-Path $sampleFolder 'solution.ps1') -Raw) + "`n" + $sideEffect | Set-Content $workspaceFile
        (Test-RePSExercise -Quiet -PassThru 6>$null).Status | Should -Be 'Assisted' -Because 'a stale snapshot would overwrite SolutionShown and record Passed'
    }
    It 'throws without a current exercise' {
        Reset-TestHome
        { Test-RePSExercise -Quiet 6>$null } | Should -Throw '*No current exercise*'
    }
}

Describe 'Get-RePSHint' {
    BeforeEach {
        Reset-TestHome
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        $hintCount = (Import-PowerShellDataFile (Join-Path $sampleFolder 'exercise.psd1')).Hints.Count
    }
    It 'reveals one more hint per call' {
        Get-RePSHint 6>$null
        (Get-TestProgress).Exercises[$sampleId].HintsUsed | Should -Be 1
        Get-RePSHint 6>$null
        (Get-TestProgress).Exercises[$sampleId].HintsUsed | Should -Be ([Math]::Min(2, $hintCount))
    }
    It 'stops counting at the number of hints' {
        foreach ($i in 1..($hintCount + 3)) { Get-RePSHint 6>$null }
        (Get-TestProgress).Exercises[$sampleId].HintsUsed | Should -Be $hintCount
    }
    It 'writes the hint text to the host' {
        $out = Get-RePSHint 6>&1 | Out-String
        $out | Should -Match 'Hint 1/'
    }
}

Describe 'Show-RePSSolution' {
    BeforeEach {
        Reset-TestHome
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
    }
    It 'returns the reference solution with -PassThru' {
        Show-RePSSolution -PassThru | Should -Be (Get-Content (Join-Path $sampleFolder 'solution.ps1') -Raw)
    }
    It 'flags the solution as shown' {
        $null = Show-RePSSolution -PassThru
        (Get-TestProgress).Exercises[$sampleId].SolutionShown | Should -BeTrue
    }
}

Describe 'Get-RePSProgress' {
    BeforeEach { Reset-TestHome }
    It 'summarises per topic' {
        $p = @(Get-RePSProgress)
        $p.Topic | Should -Contain 'Core'
        ($p | Where-Object Topic -EQ 'Core').Unseen | Should -Be ($p | Where-Object Topic -EQ 'Core').Total
    }
    It 'counts started exercises' {
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        (Get-RePSProgress | Where-Object Topic -EQ 'Core').Started | Should -Be 1
    }
}

Describe 'Reset-RePSProgress' {
    BeforeEach {
        Reset-TestHome
        Start-RePSExercise -Id $sampleId -NoOpen 6>$null
        Start-RePSExercise -Id 'core-fizzbuzz' -NoOpen 6>$null
    }
    It 'resets one exercise and its workspace file' {
        Reset-RePSProgress -Id $sampleId -IncludeWorkspace -Confirm:$false
        $p = Get-TestProgress
        $p.Exercises.ContainsKey($sampleId) | Should -BeFalse
        $p.Exercises.ContainsKey('core-fizzbuzz') | Should -BeTrue
        Join-Path $env:REPS_HOME 'workspace' "$sampleId.ps1" | Should -Not -Exist
    }
    It 'resets everything' {
        Reset-RePSProgress -Confirm:$false
        $p = Get-TestProgress
        $p.Exercises.Count | Should -Be 0
        $p.Current | Should -BeNullOrEmpty
    }
    It 'rejects ids that could escape the workspace' {
        $outside = Join-Path $env:REPS_HOME 'outside.ps1'
        'keep me' | Set-Content $outside
        { Reset-RePSProgress -Id '../outside' -IncludeWorkspace -Confirm:$false } | Should -Throw
        $outside | Should -Exist
    }
    It 'does nothing with -WhatIf' {
        Reset-RePSProgress -WhatIf
        (Get-TestProgress).Exercises.Count | Should -Be 2
    }
}

Describe 'Progress file resilience' {
    BeforeEach { Reset-TestHome }
    It 'recovers from a corrupt progress file' {
        $null = New-Item -ItemType Directory -Path $env:REPS_HOME -Force
        '{ not json' | Set-Content (Join-Path $env:REPS_HOME 'progress.json')
        { Start-RePSExercise -Id $sampleId -NoOpen -WarningAction SilentlyContinue 6>$null } | Should -Not -Throw
        (Get-TestProgress).Current | Should -Be $sampleId
    }
}

Describe 'Update check' {
    BeforeEach {
        Reset-TestHome
        $null = New-Item -ItemType Directory -Path $env:REPS_HOME -Force
        InModuleScope rePS { $script:UpdateNoticeShown = $false }
    }

    It 'is due after <Days> days on a <Cadence> cadence: <Expected>' -ForEach @(
        @{ Cadence = 'Never'; Days = 365; Expected = $false }
        @{ Cadence = 'Daily'; Days = 0; Expected = $false }
        @{ Cadence = 'Daily'; Days = 1; Expected = $true }
        @{ Cadence = 'Weekly'; Days = 6; Expected = $false }
        @{ Cadence = 'Weekly'; Days = 7; Expected = $true }
        @{ Cadence = 'BiWeekly'; Days = 13; Expected = $false }
        @{ Cadence = 'BiWeekly'; Days = 14; Expected = $true }
        @{ Cadence = 'Monthly'; Days = 29; Expected = $false }
        @{ Cadence = 'Monthly'; Days = 30; Expected = $true }
    ) {
        InModuleScope rePS -Parameters @{ Cadence = $Cadence; Days = $Days } {
            $now = [datetime]'2026-06-01'
            Test-RePSUpdateCheckDue -Cadence $Cadence -LastChecked $now.AddDays(-$Days) -Now $now
        } | Should -Be $Expected
    }

    It 'is always due when it has never run' {
        InModuleScope rePS { Test-RePSUpdateCheckDue -Cadence Monthly } | Should -BeTrue
    }

    Context 'Start-RePSUpdateCheck' {
        BeforeEach {
            $script:savedEnv = @{ NoUpdate = $env:REPS_NO_UPDATE_CHECK; CI = $env:CI; GHA = $env:GITHUB_ACTIONS; TF = $env:TF_BUILD }
            $env:REPS_NO_UPDATE_CHECK = $null; $env:CI = $null; $env:GITHUB_ACTIONS = $null; $env:TF_BUILD = $null
            Mock -ModuleName rePS Start-ThreadJob { }
        }
        AfterEach {
            $env:REPS_NO_UPDATE_CHECK = $savedEnv.NoUpdate; $env:CI = $savedEnv.CI
            $env:GITHUB_ACTIONS = $savedEnv.GHA; $env:TF_BUILD = $savedEnv.TF
        }

        It 'starts a background job and records the check date when due' {
            InModuleScope rePS { Start-RePSUpdateCheck }
            Should -Invoke -ModuleName rePS Start-ThreadJob -Times 1 -Exactly
            Join-Path $env:REPS_HOME 'update-lastcheck.txt' | Should -Exist
        }
        It 'does not check again before the cadence elapses' {
            InModuleScope rePS { Start-RePSUpdateCheck; Start-RePSUpdateCheck }
            Should -Invoke -ModuleName rePS Start-ThreadJob -Times 1 -Exactly
        }
        It 'does nothing when set to Never' {
            Set-RePSConfiguration -UpdateCheck Never
            InModuleScope rePS { Start-RePSUpdateCheck }
            Should -Invoke -ModuleName rePS Start-ThreadJob -Times 0 -Exactly
        }
        It 'does nothing when <Name> is set' -ForEach @(@{ Name = 'REPS_NO_UPDATE_CHECK' }, @{ Name = 'CI' }) {
            Set-Item -Path "env:$Name" -Value '1'
            InModuleScope rePS { Start-RePSUpdateCheck }
            Should -Invoke -ModuleName rePS Start-ThreadJob -Times 0 -Exactly
        }
        It 'never throws' {
            Mock -ModuleName rePS Start-ThreadJob { throw 'boom' }
            { InModuleScope rePS { Start-RePSUpdateCheck } } | Should -Not -Throw
        }
    }

    Context 'Show-RePSUpdateNotice' {
        BeforeAll {
            function Set-CachedLatest([string]$Version) {
                @{ Version = $Version; CheckedAt = (Get-Date).ToString('o') } | ConvertTo-Json |
                    Set-Content (Join-Path $env:REPS_HOME 'update-latest.json')
            }
        }

        It 'announces a newer version' {
            Set-CachedLatest '99.0.0'
            $out = InModuleScope rePS { Show-RePSUpdateNotice } 6>&1 | Out-String
            $out | Should -Match 'rePS 99\.0\.0 is available'
            $out | Should -Match 'Update-Module rePS'
        }
        It 'shows the notice only once per session' {
            Set-CachedLatest '99.0.0'
            $null = InModuleScope rePS { Show-RePSUpdateNotice } 6>&1
            InModuleScope rePS { Show-RePSUpdateNotice } 6>&1 | Out-String | Should -Not -Match 'available'
        }
        It 'stays quiet when up to date' {
            Set-CachedLatest '0.0.1'
            InModuleScope rePS { Show-RePSUpdateNotice } 6>&1 | Out-String | Should -Not -Match 'available'
        }
        It 'stays quiet when set to Never' {
            Set-CachedLatest '99.0.0'
            Set-RePSConfiguration -UpdateCheck Never
            InModuleScope rePS { Show-RePSUpdateNotice } 6>&1 | Out-String | Should -Not -Match 'available'
        }
        It 'ignores a corrupt cache' {
            '{ nope' | Set-Content (Join-Path $env:REPS_HOME 'update-latest.json')
            { InModuleScope rePS { Show-RePSUpdateNotice } 6>$null } | Should -Not -Throw
        }
        It 'is shown by Start-RePSExercise' {
            Set-CachedLatest '99.0.0'
            Start-RePSExercise -Id $sampleId -NoOpen 6>&1 | Out-String | Should -Match 'is available'
        }
    }

    Context 'Get-RePSLatestVersion runner' {
        BeforeAll {
            $runner = Join-Path $PSScriptRoot '..' 'Runner' 'Get-RePSLatestVersion.ps1'
            function New-Feed([string[]]$Entries) {
                $body = foreach ($e in $Entries) {
                    $v, $pre = $e -split ':'
                    "<entry><m:properties><d:Version>$v</d:Version><d:IsPrerelease m:type=`"Edm.Boolean`">$pre</d:IsPrerelease></m:properties></entry>"
                }
                $path = Join-Path $TestDrive "feed-$([guid]::NewGuid()).xml"
                @"
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">$($body -join '')</feed>
"@ | Set-Content $path
                $path
            }
        }

        It 'caches the highest stable version' {
            $out = Join-Path $TestDrive 'latest.json'
            & $runner -ModuleName rePS -OutputPath $out -FeedFile (New-Feed '0.2.0:false', '0.10.0:false', '1.0.0-beta1:true')
            (Get-Content $out -Raw | ConvertFrom-Json).Version | Should -Be '0.10.0'
        }
        It 'writes nothing when the module is not on the gallery' {
            $out = Join-Path $TestDrive 'none.json'
            & $runner -ModuleName rePS -OutputPath $out -FeedFile (New-Feed @())
            $out | Should -Not -Exist
        }
        It 'fails silently when the lookup fails' {
            $out = Join-Path $TestDrive 'fail.json'
            { & $runner -ModuleName rePS -OutputPath $out -FeedFile (Join-Path $TestDrive 'missing.xml') } | Should -Not -Throw
            $out | Should -Not -Exist
        }
    }
}

Describe 'Set-RePSConfiguration / Get-RePSConfiguration' {
    BeforeEach { Reset-TestHome }
    It 'defaults to a weekly update check' {
        (Get-RePSConfiguration).UpdateCheck | Should -Be 'Weekly'
    }
    It 'persists the update cadence' {
        Set-RePSConfiguration -UpdateCheck Monthly
        (Get-RePSConfiguration).UpdateCheck | Should -Be 'Monthly'
        Get-Content (Join-Path $env:REPS_HOME 'config.json') -Raw | Should -Match 'Monthly'
    }
    It 'rejects unknown cadences' {
        { Set-RePSConfiguration -UpdateCheck Hourly } | Should -Throw
    }
    It 'supports -WhatIf' {
        Set-RePSConfiguration -UpdateCheck Never -WhatIf
        (Get-RePSConfiguration).UpdateCheck | Should -Be 'Weekly'
    }
    It 'reports the installed version' {
        (Get-RePSConfiguration).InstalledVersion | Should -Be ([version](Import-PowerShellDataFile $manifestPath).ModuleVersion)
    }
}

Describe 'scripts/New-Exercise.ps1' {
    It 'produces a valid manifest when the author has an apostrophe' {
        $root = Join-Path $TestDrive 'scaffold'
        $scripts = Join-Path $root 'scripts'
        $null = New-Item -ItemType Directory -Path $scripts -Force
        Copy-Item (Join-Path $PSScriptRoot '..' 'scripts' 'New-Exercise.ps1') $scripts
        & (Join-Path $scripts 'New-Exercise.ps1') -Id 'core-quote-test' -Topic Core -Level 1 -FunctionName 'Get-QuoteTest' -Author "O'Brien" 6>$null
        $data = Import-PowerShellDataFile (Join-Path $root 'Exercises' 'Core' 'core-quote-test' 'exercise.psd1')
        $data.Author | Should -BeExactly "O'Brien"
    }
}
