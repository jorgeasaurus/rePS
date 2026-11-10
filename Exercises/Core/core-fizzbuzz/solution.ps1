function Get-FizzBuzz {
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 10000)]
        [int]$Max
    )

    foreach ($i in 1..$Max) {
        if ($i % 15 -eq 0) { 'FizzBuzz' }
        elseif ($i % 3 -eq 0) { 'Fizz' }
        elseif ($i % 5 -eq 0) { 'Buzz' }
        else { "$i" }
    }
}
