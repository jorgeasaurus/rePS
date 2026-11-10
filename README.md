# rePS

[![CI/CD Pipeline](https://github.com/jorgeasaurus/rePS/actions/workflows/ci.yml/badge.svg)](https://github.com/jorgeasaurus/rePS/actions/workflows/ci.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/rePS?label=PSGallery)](https://www.powershellgallery.com/packages/rePS)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Practice reps for PowerShell.** Ask for a random exercise, solve it in your editor,
and let Pester tell you when you've got it.

It's inspired by [PSKoans](https://github.com/vexx32/PSKoans), but simpler: there is no
fixed path. Each exercise stands alone, so you can do one rep over coffee or review a
topic before an interview.

```powershell
Install-Module -Name rePS -Scope CurrentUser

reps     # random exercise -> ~/.reps/workspace/<id>.ps1, opened in VS Code
rept     # check it
reph     # hint
repsol   # reference solution
repp     # progress
```

Requires **PowerShell 7.2+**. Pester 5.5+ is installed as a dependency.

## What's inside

- **40 exercises** across four topics and three levels:

  | Topic | Covers |
  | --- | --- |
  | Core | strings, arrays, hashtables, switch, types, unrolling |
  | Pipeline | Where/Select/Sort/Group/Measure, calculated properties, CSV, joins |
  | Functions | parameters and validation, parameter sets, pipeline input, errors, `-WhatIf` |
  | Advanced | regex, JSON/XML, classes, closures, `ForEach-Object -Parallel`, generic collections |

- **Your code runs isolated.** Tests run in a child `pwsh` process, so nothing leaks into your session.
- **Progress tracking** in `~/.reps/progress.json`. `reps -Unseen` gives you something new,
  and `reps -Review` brings back what you failed.
- **OS-aware.** Windows-only exercises (registry) never show up on Linux or macOS.

Filters: `reps -Topic Functions -Level 2`, `reps -Tag regex`, `reps -Id core-fizzbuzz`.

Full docs: <https://jorgeasaurus.github.io/rePS/>

## Contributing exercises

Exercises are just folders, and adding one doesn't touch the module code. See
[CONTRIBUTING.md](CONTRIBUTING.md) and the [authoring guide](docs/authoring.md).

```powershell
./scripts/New-Exercise.ps1 -Id core-title-case -Topic Core -Level 1 -FunctionName ConvertTo-TitleCase
./build.ps1 -Task Test
```

## Development

```powershell
./build.ps1                    # install build deps, then Analyze + Test + Build
./build.ps1 -Task Analyze      # PSScriptAnalyzer
./build.ps1 -Task TestModule   # module + schema tests
./build.ps1 -Task TestExercises  # every solution passes, every stub fails
./build.ps1 -Task Build        # -> build/rePS
```

VS Code tasks (`Ctrl+Shift+P` → *Run Task*) wrap all of these.

### Releasing

1. Bump `ModuleVersion` in `rePS.psd1`.
2. Move the `[Unreleased]` notes in `CHANGELOG.md` under a new `## [x.y.z] - date` heading.
3. Tag and push: `git tag vX.Y.Z && git push origin vX.Y.Z`.

CI checks that the tag matches the manifest, publishes to the PowerShell Gallery
(the `PSGALLERY_API_KEY` repository secret is required), and creates a GitHub release
with the zip and the changelog section.

## License

[MIT](LICENSE)
