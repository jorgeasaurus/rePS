# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project overview

rePS is a PowerShell 7.2+ module for practising PowerShell. `Start-RePSExercise` picks a
random exercise and writes its stub to `~/.reps/workspace/<id>.ps1`. The learner
implements it, and `Test-RePSExercise` runs the exercise's Pester tests against that file
in a child `pwsh` process (`Runner/Invoke-RePSTestRun.ps1`). Progress lives in
`~/.reps/progress.json` (override the folder with `$env:REPS_HOME`).

## Layout

| Path | Purpose |
| --- | --- |
| `rePS.psd1` / `rePS.psm1` | Manifest (exports, aliases, Pester 5.5 dependency) / loader |
| `Public/` | One exported function per file |
| `Private/` | Helpers: `Storage.ps1` (home, workspace, progress), `Exercises.ps1` (catalog, display) |
| `Runner/` | Child-process Pester runner |
| `Exercises/<Topic>/<id>/` | `exercise.psd1`, `stub.ps1`, `solution.ps1`, `tests.Tests.ps1` |
| `Tests/` | Module tests (`rePS.Tests.ps1`) and exercise schema tests (`Exercises.Tests.ps1`) |
| `scripts/` | `Test-Exercises.ps1` (behaviour checks), `New-Exercise.ps1`, `New-ExerciseCatalog.ps1` |

## Build and test

```powershell
./build.ps1                       # Analyze, Test, Build
./build.ps1 -Task Analyze         # PSScriptAnalyzer (errors fail the build)
./build.ps1 -Task TestModule      # Pester: module + schema
./build.ps1 -Task TestExercises   # every solution passes, every stub fails (this OS only)
./build.ps1 -Task Build           # build/rePS
```

Always run `./build.ps1 -Task Analyze, Test` before committing.

## Exercise rules

- `Id` equals the folder name: lowercase kebab-case, prefixed `core-`, `pipe-`, `func-` or `adv-`.
- `Topic` equals the parent folder. `Level` is 1-3. `Platforms` is a subset of Windows/Linux/MacOS.
- Test files start with `param([Parameter(Mandatory)][string]$SolutionPath)` and dot-source it in `BeforeAll`.
- The stub must fail at least one test, and the solution must pass all of them.
- The stub contains only function/class definitions and `throw 'Not implemented'` bodies. Avoid
  mandatory parameters the learner must change, because they cause interactive prompts.
- Test behaviour, not implementation. Use AST checks only when the technique is the lesson.
- Use `$TestDrive` for files. No network. Keep tests fast and deterministic.
- Do not edit `docs/exercises.md`. It is generated (and git-ignored).

## Conventions

- Approved verbs, `[CmdletBinding()]` on public functions, comment-based help with `.EXAMPLE`.
- `Write-Host` is allowed: the host is the UI of this tool (rule excluded in the build).
- Never change the progress JSON shape without handling old files in `Read-RePSProgress`.
- Bump `ModuleVersion` and add a `CHANGELOG.md` section for releases. CI checks that the tag matches.
