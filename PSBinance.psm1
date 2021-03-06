<#
.Synopsis
   Get my orders
.DESCRIPTION
   Get all orders for the selected symbol ( eg. VENBNB or ICXBNB )
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
        # Trading symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("sym")] 
        $Symbol,
        # Include canceled orders
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

<#
.Synopsis
   Get my trades
.DESCRIPTION
   Get all trades for the selected symbol ( eg. VENBNB or ICXBNB )
.EXAMPLE
   Get-BinAllTrades -Symbol VENBNB
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
function Get-BinAllTrades
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Trading symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("sym")] 
        $Symbol,
        # Order ID
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [Alias("order")] 
        $OrderID
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

            $resource = "https://api.binance.com/api/v3/myTrades$message"
            $alltrades = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            if( $OrderID -ne $null )
            {
                $alltrades = $alltrades.Where{ $_.orderid -eq $OrderID }
            }
            $alltrades
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get deposit history
.DESCRIPTION
   Get deposit history
.EXAMPLE
   Get-BinDeposits
.EXAMPLE
   Get-BinDeposits LTC | select -ExpandProperty depositlist
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
function Get-BinDeposits
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Asset symbol
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("symbol")] 
        $Asset
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()

            if( $Asset -eq $null)
            {
                $message = "timestamp=$($currenttime)"
            }
            else
            {
                $message = "asset=$asset&timestamp=$($currenttime)"
            }

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/wapi/v3/depositHistory.html$message"
            $deposits = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $deposits
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get account
.DESCRIPTION
   Get account data
.EXAMPLE
   Get-BinAccount
.EXAMPLE
   Get-BinAccount | select -ExpandProperty balances
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
function Get-BinAccount
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
            $message = "timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/api/v3/account$message"
            $account = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $account
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Ping binance
.DESCRIPTION
   Test connectivity to Binance Rest API
.EXAMPLE
   Test-BinPing
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
function Test-BinPing
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $resource = "https://api.binance.com/api/v1/ping"
            Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get Binance servertime
.DESCRIPTION
   Test connectivity to the Rest API and get the current server time.
.EXAMPLE
   Get-BinTime
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
function Get-BinTime
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $resource = "https://api.binance.com/api/v1/time"
            $servertime = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $servertime
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get Binance Exchange info
.DESCRIPTION
   Current exchange trading rules and symbol information.
.EXAMPLE
   Get-BinExchange
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
function Get-BinExchange
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $resource = "https://api.binance.com/api/v1/exchangeInfo"
            $exchange = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $exchange
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get Binance Order book
.DESCRIPTION
   Get order book for selected symbol.
.EXAMPLE
   Get-BinExchange
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
function Get-BinOrderBook
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Asset symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Limit resultset
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet( 5, 10, 20, 50, 100, 500, 1000)]
        [int16]
        $limit = 100
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $message = "?symbol=$symbol&limit=$limit"

            $resource = "https://api.binance.com/api/v1/depth$message"
            $orderbook = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $orderbook
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get Binance Trades
.DESCRIPTION
   Get recent trades for selected symbol.
.EXAMPLE
   Get-BinTrades
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
function Get-BinTrades
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Asset symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Limit resultset
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,500)]
        [int16]
        $limit = 500
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $message = "?symbol=$symbol&limit=$limit"

            $resource = "https://api.binance.com/api/v1/trades$message"
            $trades = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $trades
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Place Sell Order
.DESCRIPTION
   Set a sell order for selected symbol.
.EXAMPLE
   Set-BinSellOrder
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
function Set-BinSellOrder
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Asset symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Quantity
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [int16]
        $quantity,
        # price
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [int16]
        $price
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
            $message = "symbol=$symbol&side=SELL&type=LIMIT&timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"
            $message = "?symbol=$symbol&limit=$limit"

            $resource = "https://api.binance.com/api/v1/trades$message"
            $trades = #Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $trades
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Place Buy Order
.DESCRIPTION
   Set a sell order for selected symbol.
.EXAMPLE
   Set-BinBuyOrder
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
function Set-BinBuyOrder
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Asset symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Quantity
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        $quantity,
        # price
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNull()]
        $price
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
            $message = "symbol=$symbol&side=BUY&type=LIMIT&quantity=$quantity&price=$price&&timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/api/v1/trades$message"
            $trades = Invoke-RestMethod -Method Post -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $trades
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get open Ordera
.DESCRIPTION
   Get the open orders for selected symbol.
.EXAMPLE
   Get-BinOpenOrder
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
function Get-BinOpenOrder
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String[]])]
    Param
    (
        # Trade symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol
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

            $resource = "https://api.binance.com/api/v3/openOrders$message"
            $openorders = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $openorders
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Remove open Order
.DESCRIPTION
   Remove  open orders for selected symbol.
.EXAMPLE
   Get-BinOpenOrder XVGETH | %{ Remove-BinOpenOrder $_.symbol $_.orderid}
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
function Remove-BinOpenOrder
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Trade symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Trade symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        $orderID
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
            $message = "symbol=$symbol&orderId=$orderID&timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/api/v3/order$message"

            $removeOrder = Invoke-RestMethod -Method Delete -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $removeOrder
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Query order
.DESCRIPTION
   Check an order's status.
.EXAMPLE
   Get-BinOrderStatus
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
function Get-BinOrderStatus
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String[]])]
    Param
    (
        # Trade symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Order ID
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        $OrderID
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
            $message = "symbol=$symbol&orderId=$orderID&timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/api/v3/order$message"
            $openorders = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $openorders
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Place Buy Order
.DESCRIPTION
   Set a sell order for selected symbol.
.EXAMPLE
   Set-BinBuyOrder
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
function Test-BinBuyOrder
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Asset symbol
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $Symbol,
        # Quantity
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        $quantity,
        # price
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNull()]
        $price
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $currenttime = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
            $message = "symbol=$symbol&side=BUY&type=LIMIT&timeInForce=GTC&quantity=$quantity&price=$price&&timestamp=$($currenttime)"

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

            $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
            $signature = -join ( $signature | ForEach-Object{"{0:x2}"-f $_})

            $message = "?$message&signature=$signature"

            $resource = "https://api.binance.com/api/v3/order/test$message"
            $trades = Invoke-RestMethod -Method Post -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }
            $trades
        }
    }
    End
    {
    }
}


<#

remove-module psbinance ; import-module .\psbinance.psm1

#>
