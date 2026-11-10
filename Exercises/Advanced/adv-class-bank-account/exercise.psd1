@{
    Id           = 'adv-class-bank-account'
    Title        = 'Classes and methods'
    Topic        = 'Advanced'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('classes', 'exceptions')
    FunctionName = 'New-BankAccount'
    Author       = 'rePS'
    Prompt       = @'
Complete the BankAccount class in the workspace file:
  - Owner [string] and Balance [decimal] properties (Balance starts at 0)
  - Deposit([decimal]$amount): adds to Balance; amounts <= 0 throw [System.ArgumentException]
  - Withdraw([decimal]$amount): subtracts; amounts <= 0 throw [System.ArgumentException],
    and overdrawing throws [System.InvalidOperationException] (Balance unchanged)
  - ToString() returns "Owner: Balance", e.g. "Ada: 50"

The New-BankAccount factory function is already written. Tests use it.
'@
    Hints        = @(
        'Inside methods, refer to properties with $this.Balance.'
        'Methods with a return type must use return. A [void] method returns nothing.'
        'Throw typed exceptions with throw [System.InvalidOperationException]::new(''Insufficient funds'').'
    )
}
