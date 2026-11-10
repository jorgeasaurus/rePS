@{
    Id           = 'core-fizzbuzz'
    Title        = 'FizzBuzz'
    Topic        = 'Core'
    Level        = 1
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('loops', 'conditionals')
    FunctionName = 'Get-FizzBuzz'
    Author       = 'rePS'
    Prompt       = @'
Write Get-FizzBuzz so it outputs one string per number from 1 to -Max:
  - "FizzBuzz" for multiples of both 3 and 5
  - "Fizz" for multiples of 3
  - "Buzz" for multiples of 5
  - otherwise the number itself, as a string

    Get-FizzBuzz -Max 5   # '1','2','Fizz','4','Buzz'
'@
    Hints        = @(
        'The range operator 1..$Max gives you every number.'
        'The modulus operator % returns the remainder: 9 % 3 is 0.'
        'Check the "both" case first, or build the string up: $s = ''''; if (...) { $s += ''Fizz'' } ...'
    )
}
