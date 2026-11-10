# rePS

<div class="reps-hero">
  <ascii-art piece="reps-rept-loop" aria-label="Animation of the rePS loop: rept runs the tests, one fails, the fix goes in, and the next rept passes"></ascii-art>
</div>

**Practice reps for PowerShell.** Ask for a random exercise, solve it in your editor,
and let Pester tell you when you've got it. It's inspired by
[PSKoans](https://github.com/vexx32/PSKoans), but built for quick drop-in sessions:
one exercise at a time, in any order.

## Install

```powershell
Install-Module -Name rePS -Scope CurrentUser
```

You need PowerShell 7.2 or later and Pester 5.5 or later. Pester is installed
automatically as a dependency.

!!! warning "Windows: Pester 3.4"
    Windows ships an old Pester 3.4 that `Install-Module` can refuse to replace. If the
    install complains, run `Install-Module Pester -Force -SkipPublisherCheck` first.

## A rep in 30 seconds

```powershell
reps            # random exercise: writes ~/.reps/workspace/<id>.ps1 and opens it in VS Code
# ...edit the function in the file...
rept            # run the tests
reph            # stuck? reveal the next hint
repsol          # still stuck? show the reference solution
repp            # progress per topic
```

## How it works

1. `Start-RePSExercise` copies the exercise's **stub** to your workspace. The file
   starts with a comment holding the brief.
2. You implement the function.
3. `Test-RePSExercise` runs the exercise's Pester tests against your file in a
   **separate `pwsh` process**. Your code (and any infinite loop) never touches
   your session.
4. The result goes into `~/.reps/progress.json`: `Started`, `Failed`,
   `Passed` or `Assisted` (passed after viewing the solution).

Filters let you target practice:

```powershell
reps -Topic Pipeline -Level 2      # intermediate pipeline work
reps -Unseen                       # something new
reps -Review                       # retry what you failed or needed the solution for
reps -Tag regex                    # by tag
```

Exercises that only work on one OS (for example registry exercises on Windows) are
skipped automatically on other platforms.

## Update notices

rePS checks the PowerShell Gallery for a newer version **weekly**, using the same approach as
[tiPS](https://github.com/deadlydog/PowerShell.tiPS). The check runs in a background
thread job when the module loads, so it never slows you down. If a newer version exists,
`reps` shows a one-line notice once per session:

```text
  rePS 0.2.0 is available (you have 0.1.0). Update with: Update-Module rePS
```

rePS never updates itself. You decide when to run `Update-Module`.

```powershell
Set-RePSConfiguration -UpdateCheck Daily     # Never | Daily | Weekly | BiWeekly | Monthly
Get-RePSConfiguration                         # cadence, last check, latest version, data paths
```

Checks are skipped when `REPS_NO_UPDATE_CHECK` is set or in CI (`CI`, `GITHUB_ACTIONS`, `TF_BUILD`).

## Configuration

| Environment variable | Effect |
| --- | --- |
| `REPS_HOME` | Data folder (default `~/.reps`) |
| `REPS_NO_OPEN` | Set to any value to never open the editor |
| `REPS_NO_UPDATE_CHECK` | Set to any value to never check for updates |
