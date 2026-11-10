@{
    Id           = 'pipe-compare-lists'
    Title        = 'Compare two lists'
    Topic        = 'Pipeline'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('compare-object')
    FunctionName = 'Compare-List'
    Author       = 'rePS'
    Prompt       = @'
Write Compare-List so it compares -Reference with -Difference and outputs one
object per difference with Value and Change properties:
  Change = 'Added'   when the item is only in -Difference
  Change = 'Removed' when the item is only in -Reference
Items in both are not output. Sort by Value.

    Compare-List -Reference 'a', 'b', 'c' -Difference 'b', 'c', 'd'
    # Value a Removed, Value d Added
'@
    Hints        = @(
        'Compare-Object -ReferenceObject -DifferenceObject does the heavy lifting.'
        'Each result has a SideIndicator: ''<='' means only in the reference, ''=>'' only in the difference.'
        'Use a switch or a hashtable lookup to turn the SideIndicator into Added/Removed.'
    )
}
