# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
write-host "PowerShell queue trigger function processed work item: $QueueItem"
write-host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
write-host "Running as: $(whoami)"
#
# #$locations=(Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).Value | Where-Object {$_.displayname -Like "Dyn-$($QueueItem)"  }
# if ($env:app_umi_client_id) {
#     #    Connect-MgGraph -Identity -ClientId $env:app_umi_client_id
#     #    $graphtoken= (Get-MgContext).AccessToken
# #    $resource = "https://graph.microsoft.com"
# #    $clientId = $env:app_umi_client_id
# #    $uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$resource&client_id=$clientId"
#     Connect-MgGraph -Identity -ClientId $clientId

# #    $response = Invoke-RestMethod -Uri $uri -Headers @{ Metadata = "true" }
# #    $graphtoken = $response.access_token
# }
# else {
# #    $graphToken = az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv
#     $graphToken = ConvertTo-SecureString -string (az account get-access-token --scope="https://graph.microsoft.com/Directory.AccessAsUser.All" | ConvertFrom-Json).accessToken -AsPlainText
#     connect-mggraph -AccessToken $graphToken
#     $graphtoken = (Get-MgContext).AccessToken
# }

    


$locations = (Invoke-MgGraphRequest -Method Get  -uri https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).value | Where-Object { $_.displayname -Like "$($QueueItem.host)" }
foreach ($location in $locations) {
    $name = ($location.displayname -split "dyn-")[-1]
    $currentvalue = $location.ipRanges[0].cidrAddress
    try {
        if ($QueueItem.ip) {
            $currentip = $QueueItem.ip
        }
        else {
            # Get the current IP address from DNS
            $currentip = ([System.Net.Dns]::GetHostAddresses($name))[-1].IPAddressToString
        }
        $currentip = "$($currentip)/32"

    }
    catch {
        $currentip = $null
    }
    write-host "Checking location:  $($location.displayname -split "dyn-"), current value: $currentvalue, currentip: $currentip"
    if ($currentip -and $currentvalue -and ($currentvalue -ne $currentip)) {
        write-host "IP Address is different from the one in the database. Updating the location."
        # Update the database with the new IP address
        $body = @{
            "@odata.type" = "#microsoft.graph.ipNamedLocation"
            displayName   = $location.displayName
            isTrusted     = $location.isTrusted
            ipRanges      = @(
                @{
                    "@odata.type" = "#microsoft.graph.iPv4CidrRange"
                    cidrAddress   = "$($currentip)"
                }
            )
        }   
        $uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$($location.id)"    
        write-host "URI: $uri"
        write-host "Body: $($body | ConvertTo-Json -Depth 10)"
        # Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
        #Invoke-webrequest  -Headers $headers -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
        # if ($env:app_umi_client_id) {
        #     Invoke-MgGraphRequest -Method Patch -Uri $uri -Body $body -ContentType "application/json"
        # }
        # else {
        #     # Use Invoke-RestMethod for non-MgGraph requests
        #     Invoke-RestMethod -Headers $graphheaders -Method Patch -Uri $uri -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
        # }
            Invoke-MgGraphRequest -Method Patch -Uri $uri -Body $body -ContentType "application/json"

        #        Invoke-RestMethod -Headers $graphheaders -Method Patch -Uri $uri -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
    }
    else {
        write-host "IP Address is the same as the one in the database. No action needed."
    }
    
}