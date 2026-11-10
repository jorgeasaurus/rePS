function Format-LogMessage {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    "[$($Level.ToUpper())] $Message"
}
