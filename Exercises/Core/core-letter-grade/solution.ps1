function Get-LetterGrade {
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$Score
    )

    switch ($Score) {
        { $_ -ge 90 } { 'A'; break }
        { $_ -ge 80 } { 'B'; break }
        { $_ -ge 70 } { 'C'; break }
        { $_ -ge 60 } { 'D'; break }
        default { 'F' }
    }
}
