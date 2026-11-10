param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'BankAccount' {
    BeforeEach {
        $account = New-BankAccount -Owner 'Ada'
    }
    It 'starts with the owner and a zero balance' {
        $account.Owner | Should -Be 'Ada'
        $account.Balance | Should -Be 0
    }
    It 'deposits' {
        $account.Deposit(50)
        $account.Deposit(25.5)
        $account.Balance | Should -Be 75.5
    }
    It 'withdraws' {
        $account.Deposit(50)
        $account.Withdraw(20)
        $account.Balance | Should -Be 30
    }
    It 'rejects non-positive deposits with ArgumentException' {
        { $account.Deposit(0) } | Should -Throw -ExceptionType ([System.ArgumentException])
        { $account.Deposit(-5) } | Should -Throw -ExceptionType ([System.ArgumentException])
    }
    It 'rejects overdrafts with InvalidOperationException and keeps the balance' {
        $account.Deposit(10)
        { $account.Withdraw(11) } | Should -Throw -ExceptionType ([System.InvalidOperationException])
        $account.Balance | Should -Be 10
    }
    It 'rejects non-positive withdrawals' {
        { $account.Withdraw(0) } | Should -Throw -ExceptionType ([System.ArgumentException])
    }
    It 'overrides ToString' {
        $account.Deposit(50)
        $account.ToString() | Should -BeExactly 'Ada: 50'
        "$account" | Should -BeExactly 'Ada: 50'
    }
}
