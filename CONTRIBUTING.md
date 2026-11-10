# Contributing to rePS

Thanks for helping! New exercises are the most valuable contribution.

## Adding an exercise

1. Open a [New exercise](https://github.com/jorgeasaurus/rePS/issues/new?template=new-exercise.yml)
   issue first if you want feedback on the idea (optional for small ones).
2. Scaffold it:

   ```powershell
   ./scripts/New-Exercise.ps1 -Id pipe-my-idea -Topic Pipeline -Level 2 -FunctionName Get-MyThing
   ```

3. Fill in `exercise.psd1`, `stub.ps1`, `solution.ps1` and `tests.Tests.ps1`.
4. Validate locally:

   ```powershell
   ./build.ps1 -Task Analyze, Test
   ```

5. Open a PR. CI runs the same checks on Windows, Linux and macOS.

The full rules and style guide are in [docs/authoring.md](docs/authoring.md).

## Changing the module

- Keep public functions in `Public/` (one per file, named after the function) and
  helpers in `Private/`.
- New public functions must be added to `FunctionsToExport` in `rePS.psd1` and need
  comment-based help with an example. The tests check both.
- Add or update tests in `Tests/rePS.Tests.ps1`.
- Note user-visible changes under `## [Unreleased]` in `CHANGELOG.md`.

## Development setup

PowerShell 7.2+. `./build.ps1 -NoBuild` installs InvokeBuild, Pester and
PSScriptAnalyzer. In VS Code, every build step is available as a task.
