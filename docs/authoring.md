# Writing exercises

Exercises are plain folders, so contributing one needs no knowledge of the module internals.

```text
Exercises/
  <Topic>/                 Core | Pipeline | Functions | Advanced
    <id>/                  lowercase kebab-case, prefixed by topic (core-, pipe-, func-, adv-)
      exercise.psd1        metadata, brief and hints
      stub.ps1             what the learner starts with
      solution.ps1         one reference solution
      tests.Tests.ps1      Pester 5 tests, run against stub/solution/learner file
```

## Quick start

```powershell
./scripts/New-Exercise.ps1 -Id core-title-case -Topic Core -Level 1 -FunctionName ConvertTo-TitleCase
# fill in the TODOs
./build.ps1 -Task Test
```

## exercise.psd1

```powershell
@{
    Id           = 'core-title-case'           # must equal the folder name
    Title        = 'Title case'                # short, shown in lists
    Topic        = 'Core'                      # must equal the parent folder
    Level        = 1                           # 1 beginner, 2 intermediate, 3 advanced
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('strings')                # lowercase, kebab-case
    FunctionName = 'ConvertTo-TitleCase'       # must be defined in stub and solution
    Author       = 'your-github-handle'        # optional
    Prompt       = @'
What to build, with an example call and its output.
'@
    Hints        = @(                          # 1-5, gentle to specific
        'First nudge'
        'More specific'
    )
}
```

## tests.Tests.ps1

Every test file starts with exactly this header. The runner passes in the path of the
file being tested:

```powershell
param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}
```

## Rules CI enforces

| Rule | Why |
| --- | --- |
| `solution.ps1` passes every test | The exercise is solvable |
| `stub.ps1` fails at least one test | The tests actually check something |
| The stub contains only function and class definitions | It's dot-sourced, so top-level code would run on load |
| All three `.ps1` files parse | |
| The schema above is valid and the `Id` is unique | |
| Solutions pass PSScriptAnalyzer (stubs are exempt) | Solutions are teaching material |

These are checked on Windows, Linux **and** macOS. An exercise limited with `Platforms`
is only checked on those OSes.

## Writing good exercises

- **Test behaviour, not implementation.** Learners will find other valid solutions. Only
  inspect the AST (see `adv-foreach-parallel`) when the technique itself is the lesson.
- **Teach one thing.** Name the lesson in the title and tags. Point out the trap in the prompt.
- **Cover the edge cases a real script would hit**: empty input, a single item, `$null`,
  case sensitivity.
- **Keep tests deterministic and fast.** Use `$TestDrive` for files, no network, and stay
  well under a second unless timing is what you're testing.
- **Make the stub's parameters friendly.** A mandatory parameter the learner has to
  change will prompt for input when the stub is run. Leave it non-mandatory in the stub.
- **Hints climb from a nudge to nearly the answer**, so the solution is a last resort.
