# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

    $qvalue= @{
        host   = "Dyn-*"
        ip     = $null
    }
    Push-OutputBinding -Name qcheck -Value $qvalue

<# 
$locations=(Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).Value | Where-Object {$_.displayname -Like "Dyn-*"  }
foreach ($location in $locations) {
    $name = ($location.displayname -split "dyn-")[-1]
    $currentvalue = $location.ipRanges[0].cidrAddress
    try {
        $currentip =([System.Net.Dns]::GetHostAddresses($name))[-1].IPAddressToString
       $currentip="$($currentip)/32"
   }
   catch {
       $currentip = $null
   }
    Write-Host "Checking location:  $($location.displayname -split "dyn-"), current value: $currentvalue, currentip: $currentip"
    if ($currentip -and $currentvalue -and ($currentvalue -ne $currentip)) {
        Write-Host "IP Address is different from the one in the database. Updating the location."
        # Update the database with the new IP address
        $body = @{
            "@odata.type" = "#microsoft.graph.ipNamedLocation"
            displayName= $location.displayName
            isTrusted = $location.isTrusted
            ipRanges= @(
                @{
                    "@odata.type"= "#microsoft.graph.iPv4CidrRange"
                    cidrAddress= "$($currentip)"
                }
            )
        }   
        $uri="https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$($location.id)"    
        Write-Host "URI: $uri"
        Write-Host "Body: $($body | ConvertTo-Json -Depth 10)"
        Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
    } else {
        Write-Host "IP Address is the same as the one in the database. No action needed."
    }
    
} #>