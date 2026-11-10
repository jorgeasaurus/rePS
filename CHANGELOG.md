# Changelog

All notable changes to rePS are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

Release notes for each GitHub release are taken from the section matching the
module version, so keep the `## [x.y.z] - date` heading format.

## [Unreleased]

## [0.1.0] - 2026-11-10

### Added

- `Start-RePSExercise` (`reps`): random or specific exercise, filtered by topic, level, tag, unseen or review; writes a stub to `~/.reps/workspace` and opens it in VS Code.
- `Test-RePSExercise` (`rept`): runs the exercise's Pester tests in an isolated `pwsh` process and records the result.
- `Get-RePSHint` (`reph`) and `Show-RePSSolution` (`repsol`): progressive hints and the reference solution (marks a later pass as Assisted).
- `Get-RePSExercise`, `Get-RePSProgress` (`repp`) and `Reset-RePSProgress`: browse the catalog and manage progress in `~/.reps/progress.json`.
- 40 exercises across Core, Pipeline, Functions and Advanced topics, levels 1-3, with OS filtering for platform-specific exercises.
- Build (InvokeBuild), CI on Windows, Linux and macOS, exercise validation (solutions pass, stubs fail), tag-based release to PSGallery and GitHub, MkDocs site.
- Update notices: a background check of the PowerShell Gallery at import (weekly by default, modelled on tiPS) and a once-per-session notice from `reps` when a newer version exists. `Get-RePSConfiguration` / `Set-RePSConfiguration -UpdateCheck Never|Daily|Weekly|BiWeekly|Monthly`; skipped in CI or with `REPS_NO_UPDATE_CHECK`.
- `scripts/New-Exercise.ps1` scaffolder, exercise catalog generator, issue forms and contributor guide.
