class BankAccount {
    [string]$Owner
    [decimal]$Balance = 0

    BankAccount([string]$owner) {
        $this.Owner = $owner
    }

    [void] Deposit([decimal]$amount) {
        if ($amount -le 0) { throw [System.ArgumentException]::new('Deposit amount must be positive.') }
        $this.Balance += $amount
    }

    [void] Withdraw([decimal]$amount) {
        if ($amount -le 0) { throw [System.ArgumentException]::new('Withdrawal amount must be positive.') }
        if ($amount -gt $this.Balance) { throw [System.InvalidOperationException]::new('Insufficient funds.') }
        $this.Balance -= $amount
    }

    [string] ToString() {
        return "$($this.Owner): $($this.Balance)"
    }
}

function New-BankAccount {
    param(
        [Parameter(Mandatory)]
        [string]$Owner
    )

    [BankAccount]::new($Owner)
}
