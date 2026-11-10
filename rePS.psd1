@{
    RootModule           = 'rePS.psm1'
    ModuleVersion        = '0.1.0'
    CompatiblePSEditions = @('Core')
    GUID                 = '181a34b3-4ccd-41c4-98d2-11710e7c1b05'
    Author               = 'Jorge Suarez'
    CompanyName          = 'Community'
    Copyright            = '(c) 2026 Jorge Suarez. All rights reserved.'
    Description          = 'PowerShell practice reps. Get a random exercise, solve it in your editor, and check it with Pester.'
    PowerShellVersion    = '7.2'

    RequiredModules      = @(
        @{ ModuleName = 'Pester'; ModuleVersion = '5.5.0' }
    )

    FunctionsToExport    = @(
        'Start-RePSExercise'
        'Test-RePSExercise'
        'Get-RePSHint'
        'Show-RePSSolution'
        'Get-RePSExercise'
        'Get-RePSProgress'
        'Reset-RePSProgress'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @('reps', 'rept', 'reph', 'repsol', 'repp')

    PrivateData          = @{
        PSData = @{
            Tags         = @('PowerShell', 'Learning', 'Practice', 'Exercises', 'Koans', 'Pester', 'Training', 'PSEdition_Core', 'Windows', 'Linux', 'MacOS')
            LicenseUri   = 'https://github.com/jorgeasaurus/rePS/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/jorgeasaurus/rePS'
            ReleaseNotes = 'See https://github.com/jorgeasaurus/rePS/blob/main/CHANGELOG.md'
        }
    }
}
