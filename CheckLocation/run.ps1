# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
# $QueueItem=@{
#     ipaddress="62.235.220.143"
#     locationName="lub-bgc.x.lubon.be"
# }
$ipaddress = $QueueItem.ipaddress
$locationName = $QueueItem.locationName
write-host "IP Address: $ipaddress"
write-host "Location Name: $locationName"
# Get the location information from the database
$currentvalue=(Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).Value | Where-Object {$_.displayname -eq $locationName}
$currentip=($currentvalue.ipranges[0].cidrAddress) -split "/"
$currentip=$currentip[0]

write-host "Current value: $($currentip)"
if ($currentip -eq $ipaddress) {
    Write-Host "IP Address is the same as the one in the database. No action needed."
} else {
    Write-Host "IP Address is different from the one in the database. Updating the location."
    # Update the database with the new IP address
    $body = @{
            "@odata.type" = "#microsoft.graph.ipNamedLocation"
            displayName= $currentvalue.displayName
            istrusted = $currentvalue.istrusted
            ipRanges= @(
                @{
                    "@odata.type"= "#microsoft.graph.iPv4CidrRange"
                    cidrAddress= "$($ipaddress)/32"
                }
        
            )
        }   
    $uri="https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$($currentvalue.id)"    
    write-host "URI: $uri"
    write-host "Body: $($body | ConvertTo-Json -Depth 10)"
    Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
}