#Requires -Modules Pester
<#
    Schema checks for every exercise folder. Behavioural checks (solution passes, stub fails)
    live in scripts/Test-Exercises.ps1 and run as the TestExercises build task.
#>

BeforeDiscovery {
    $exercisesRoot = Join-Path $PSScriptRoot '..' 'Exercises'
    $script:exerciseCases = foreach ($manifest in Get-ChildItem -Path $exercisesRoot -Filter 'exercise.psd1' -Recurse -File) {
        @{
            Name   = $manifest.Directory.Name
            Folder = $manifest.Directory.FullName
            Topic  = $manifest.Directory.Parent.Name
            Path   = $manifest.FullName
        }
    }
}

Describe 'Exercise catalog' {
    BeforeAll {
        $exercisesRoot = Join-Path $PSScriptRoot '..' 'Exercises'
        $all = Get-ChildItem -Path $exercisesRoot -Filter 'exercise.psd1' -Recurse -File |
            ForEach-Object { Import-PowerShellDataFile -LiteralPath $_.FullName }
    }
    It 'has exercises' {
        @($all).Count | Should -BeGreaterThan 0
    }
    It 'has unique ids' {
        $dupes = $all | Group-Object Id | Where-Object Count -GT 1
        $dupes.Name | Should -BeNullOrEmpty
    }
    It 'has unique function names within a topic' {
        $dupes = $all | Group-Object { "$($_.Topic)/$($_.FunctionName)" } | Where-Object Count -GT 1
        $dupes.Name | Should -BeNullOrEmpty
    }
}

Describe 'Exercise <Name>' -ForEach $exerciseCases {
    BeforeAll {
        $data = Import-PowerShellDataFile -LiteralPath $Path
        $required = 'Id', 'Title', 'Topic', 'Level', 'Platforms', 'Tags', 'FunctionName', 'Prompt', 'Hints'
        $allowed = $required + 'Author'
    }

    It 'has all required keys' {
        foreach ($key in $required) { $data.Keys | Should -Contain $key -Because "exercise.psd1 needs '$key'" }
    }
    It 'has no unknown keys' {
        foreach ($key in $data.Keys) { $allowed | Should -Contain $key -Because "'$key' is not a known exercise key" }
    }
    It 'uses the folder name as Id' {
        $data.Id | Should -BeExactly $Name
    }
    It 'uses a lowercase kebab-case Id' {
        $data.Id | Should -MatchExactly '^[a-z0-9]+(-[a-z0-9]+)+$'
    }
    It 'lives in the folder of its Topic' {
        $data.Topic | Should -BeExactly $Topic
        $data.Topic | Should -BeIn @('Core', 'Pipeline', 'Functions', 'Advanced')
    }
    It 'has Level 1-3' {
        $data.Level | Should -BeOfType [int]
        $data.Level | Should -BeIn 1, 2, 3
    }
    It 'declares valid Platforms' {
        @($data.Platforms).Count | Should -BeGreaterThan 0
        foreach ($p in $data.Platforms) { $p | Should -BeIn @('Windows', 'Linux', 'MacOS') }
    }
    It 'has lowercase tags' {
        @($data.Tags).Count | Should -BeGreaterThan 0
        foreach ($t in $data.Tags) { $t | Should -MatchExactly '^[a-z0-9-]+$' }
    }
    It 'has a non-trivial prompt and 1-5 hints' {
        $data.Prompt.Trim().Length | Should -BeGreaterThan 40
        @($data.Hints).Count | Should -BeIn (1..5)
    }
    It 'has stub.ps1, solution.ps1 and tests.Tests.ps1' {
        foreach ($file in 'stub.ps1', 'solution.ps1', 'tests.Tests.ps1') {
            Join-Path $Folder $file | Should -Exist
        }
    }
    It '<_> parses without errors' -ForEach @('stub.ps1', 'solution.ps1', 'tests.Tests.ps1') {
        $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $Folder $_), [ref]$null, [ref]$errors)
        $errors | Should -BeNullOrEmpty
    }
    It '<_> defines the FunctionName' -ForEach @('stub.ps1', 'solution.ps1') {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $Folder $_), [ref]$null, [ref]$null)
        $functions = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true).Name
        $functions | Should -Contain $data.FunctionName
    }
    It 'tests take a mandatory SolutionPath parameter' {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $Folder 'tests.Tests.ps1'), [ref]$null, [ref]$null)
        $ast.ParamBlock.Parameters.Name.VariablePath.UserPath | Should -Contain 'SolutionPath'
    }
    It 'stub has no top-level code besides definitions' {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $Folder 'stub.ps1'), [ref]$null, [ref]$null)
        $other = $ast.EndBlock.Statements | Where-Object {
            $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] -and
            $_ -isnot [System.Management.Automation.Language.TypeDefinitionAst]
        }
        $other | Should -BeNullOrEmpty -Because 'stubs are dot-sourced by the tests; top-level code would run on load'
    }
}
