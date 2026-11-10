#Requires -Modules Pester

BeforeAll {
    $manifestPath = Join-Path $PSScriptRoot '..' 'rePS.psd1'
    Import-Module $manifestPath -Force

    $script:originalHome = $env:REPS_HOME
    $script:originalNoOpen = $env:REPS_NO_OPEN
    $env:REPS_NO_OPEN = '1'

    function Reset-TestHome {
        $env:REPS_HOME = Join-Path $TestDrive ([guid]::NewGuid())
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
