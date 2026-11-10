# Commands

Every command has full comment-based help: `Get-Help <command> -Full`.

| Command | Alias | Purpose |
| --- | --- | --- |
| `Start-RePSExercise` | `reps` | Start a random or specific exercise |
| `Test-RePSExercise` | `rept` | Check your solution |
| `Get-RePSHint` | `reph` | Reveal the next hint |
| `Show-RePSSolution` | `repsol` | Show the reference solution |
| `Get-RePSProgress` | `repp` | Progress summary per topic |
| `Get-RePSExercise` | | Browse the catalog (no side effects) |
| `Reset-RePSProgress` | | Clear progress (supports `-WhatIf`) |
| `Get-RePSConfiguration` | | Settings, update status, data paths |
| `Set-RePSConfiguration` | | Change the update-check cadence |

## Start-RePSExercise

```powershell
Start-RePSExercise [-Topic <Core|Pipeline|Functions|Advanced>[]] [-Level <1..3>[]] [-Tag <string[]>]
                   [-Unseen] [-Review] [-NoOpen] [-Force] [-PassThru]
Start-RePSExercise -Id <string> [-NoOpen] [-Force] [-PassThru]
```

- When you started an exercise before, its workspace file is **resumed**. `-Force` resets it to the stub.
- A random pick never repeats the current exercise if anything else matches.
- `-Review` picks from exercises with status `Failed` or `Assisted`.

## Test-RePSExercise

```powershell
Test-RePSExercise [[-Id] <string>] [-Path <string>] [-Quiet] [-TimeoutSeconds <int>] [-PassThru]
```

The run is stopped after `-TimeoutSeconds` (default 60), so an accidental infinite loop is
recorded as a failure instead of hanging your session.

Tests the current exercise by default. `-Path` tests any file, for example a scratch
copy. `-PassThru` returns a `RePS.TestResult` object (`Passed`, `Status`,
`PassedCount`, `FailedCount`, `Failed`).

A pass is never downgraded: if you pass and later break your file, the status stays `Passed`.

## Get-RePSHint / Show-RePSSolution

Each `Get-RePSHint` call reveals one more hint and repeats the earlier ones.
`Show-RePSSolution` prints the reference solution. If you have not passed the exercise
yet, your eventual pass is recorded as `Assisted`.

## Get-RePSExercise

```powershell
Get-RePSExercise [[-Id] <string>] [-Topic ...] [-Level ...] [-Tag ...]
                 [-Status <Unseen|Started|Failed|Passed|Assisted>[]] [-AllPlatforms]
```

## Get-RePSProgress

Outputs one row per topic: `Total`, `Passed`, `Assisted`, `Failed`, `Started`, `Unseen`.

## Reset-RePSProgress

```powershell
Reset-RePSProgress [[-Id] <string>] [-IncludeWorkspace] [-WhatIf] [-Confirm]
```

Asks for confirmation by default (`ConfirmImpact = High`).

## Get-RePSConfiguration / Set-RePSConfiguration

```powershell
Set-RePSConfiguration -UpdateCheck <Never|Daily|Weekly|BiWeekly|Monthly> [-WhatIf]
Get-RePSConfiguration
```

`UpdateCheck` (default `Weekly`) controls how often rePS looks up the latest version on the
PowerShell Gallery in the background. `Get-RePSConfiguration` shows the cadence, the last
check, the installed and latest versions, and the data and workspace paths.
