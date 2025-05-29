# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
Write-Warning "PowerShell queue trigger function processed work item: $QueueItem"
Write-Warning "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
write-warning "Running as: $(whoami)"
#
#$locations=(Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).Value | Where-Object {$_.displayname -Like "Dyn-$($QueueItem)"  }
if ($env:app_umi_client_id) {
    #    Connect-MgGraph -Identity -ClientId $env:app_umi_client_id
    #    $graphtoken= (Get-MgContext).AccessToken
    $resource = "https://graph.microsoft.com"
    $clientId = $env:app_umi_client_id
    Connect-MgGraph -Identity -ClientId $clientId
    $uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$resource&client_id=$clientId"

#    $response = Invoke-RestMethod -Uri $uri -Headers @{ Metadata = "true" }
#    $graphtoken = $response.access_token
}
else {
    $graphToken = az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv
}

#if (-not $graphtoken) {
#    write-error "No Graph token found. Please ensure you are logged in to Azure CLI or have set the app_umi_client_id environment variable."
#    Exit
#}
    

$graphheaders = @{
    Authorization  = "Bearer $graphtoken"
    "Content-Type" = "application/json"
}
if ($env:app_umi_client_id) {
        $locations = (Invoke-MgGraphRequest -Method Get  -uri https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).value | Where-Object { $_.displayname -Like "$($QueueItem.host)" }
}
    else{
        $locations = (Invoke-RestMethod -Headers $graphheaders -Method Get  -uri https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).value | Where-Object { $_.displayname -Like "$($QueueItem.host)" }

    }
#$locations = (Invoke-RestMethod -Headers $graphheaders -Method Get  -uri https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations).value | Where-Object { $_.displayname -Like "$($QueueItem.host)" }
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
    write-warning "Checking location:  $($location.displayname -split "dyn-"), current value: $currentvalue, currentip: $currentip"
    if ($currentip -and $currentvalue -and ($currentvalue -ne $currentip)) {
        write-warning "IP Address is different from the one in the database. Updating the location."
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
        write-warning "URI: $uri"
        write-warning "Body: $($body | ConvertTo-Json -Depth 10)"
        # Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
        #Invoke-webrequest  -Headers $headers -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
        if ($env:app_umi_client_id) {
            Invoke-MgGraphRequest -Method Patch -Uri $uri -Body $body -ContentType "application/json"
        }
        else {
            # Use Invoke-RestMethod for non-MgGraph requests
            Invoke-RestMethod -Headers $graphheaders -Method Patch -Uri $uri -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
        }
#        Invoke-RestMethod -Headers $graphheaders -Method Patch -Uri $uri -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
    }
    else {
        write-warning "IP Address is the same as the one in the database. No action needed."
    }
    
}