class BankAccount {
    [string]$Owner
    [decimal]$Balance = 0

    BankAccount([string]$owner) {
        $this.Owner = $owner
    }

    [void] Deposit([decimal]$amount) {
        # TODO: validate and add to Balance
        throw 'Not implemented'
    }

    [void] Withdraw([decimal]$amount) {
        # TODO: validate (positive, enough funds) and subtract
        throw 'Not implemented'
    }

    # TODO: override ToString() to return "Owner: Balance"
}

function New-BankAccount {
    param(
        [Parameter(Mandatory)]
        [string]$Owner
    )

    [BankAccount]::new($Owner)
}
