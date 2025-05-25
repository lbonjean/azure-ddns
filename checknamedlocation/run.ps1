using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

if ($name) {
    #$result = Resolve-DnsName -Name $name -Type A -ErrorAction SilentlyContinue
    $result = [System.Net.Dns]::GetHostAddresses($name)
    try {
        $result =([System.Net.Dns]::GetHostAddresses($name))[-1].IPAddressToString
    }
    catch {
        $result = $null
    }
    if ($result) {
        $body = "Resolved ip for $name is $result"
    } else {
        $body = "No A record found for $name"
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
