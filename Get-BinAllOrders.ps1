<#
.Synopsis
   Get my trades
.DESCRIPTION
   Get all trades for the selected symbol ( eg. VENBNB or ICXBNB )
.EXAMPLE
   Get-BinAllOrders -Symbol VENBNB
.EXAMPLE
   "VENBNB", "ICXBNB" | Get-BinAllOrders
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   Binance Exchange
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-BinAllOrders
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("sym")] 
        $Symbol,
        # Param1 help description
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [Alias("cancel")]
        [bool]
        $IncludeCanceled = $false
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()

            $message = "symbol=$symbol&timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/api/v3/allOrders$message"
            $allorders = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            if( $IncludeCanceled -ne $true )
            {
                $allorders = $allorders.Where{ $_.status -ne 'CANCELED'}
            }
            $allorders
        }
    }
    End
    {
    }
}