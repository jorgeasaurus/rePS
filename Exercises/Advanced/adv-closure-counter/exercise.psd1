@{
    Id           = 'adv-closure-counter'
    Title        = 'Closures'
    Topic        = 'Advanced'
    Level        = 3
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('scriptblocks', 'closures', 'scope')
    FunctionName = 'New-Counter'
    Author       = 'rePS'
    Prompt       = @'
Write New-Counter so it returns a scriptblock. Each time the scriptblock is
invoked it returns the next number, starting at -Start and increasing by -Step.
Each counter keeps its own state.

    $a = New-Counter -Start 10 -Step 5
    & $a   # 10
    & $a   # 15
    $b = New-Counter
    & $b   # 0  ($a is unaffected)
'@
    Hints        = @(
        'A plain scriptblock looks variables up where it is invoked, not where it was created.'
        '.GetNewClosure() binds the scriptblock to a copy of the current variables.'
        'The copy is shallow: integers are copied, but a hashtable is still the same object. Keep the state in a hashtable so changes stick.'
    )
}
