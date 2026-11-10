function Get-NumberStatistic {
    param(
        [Parameter(Mandatory)]
        [double[]]$Numbers
    )

    $m = $Numbers | Measure-Object -Sum -Minimum -Maximum -Average
    [pscustomobject]@{
        Count   = $m.Count
        Sum     = $m.Sum
        Minimum = $m.Minimum
        Maximum = $m.Maximum
        Average = $m.Average
    }
}
