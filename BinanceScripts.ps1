$apiKey = Get-Content C:\Dell\Jorgen2.txt
$secret = Get-Content C:\Dell\Jorgen.txt

$timestamp = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
$message = "symbol=ICXBNB&timestamp=$timestamp"

$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)

$signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
$signature = -join ( $signature | %{"{0:x2}"-f $_})

$message = "?$message&signature=$signature"

$resource = "https://api.binance.com/api/v3/allOrders$message"
$allorders = Invoke-RestMethod -Method Get -Uri "$resource" -Header @{ "X-MBX-APIKEY" = $apiKey }

$allorders