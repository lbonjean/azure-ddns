# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution
if ($env:MSI_SECRET) {
Connect-AzAccount -Identity
    #Write-Host "Authenticated to Azure using Managed Identity with client ID: $($env:MSI_SECRET)"
} else {
    #Write-Host "No MSI_SECRET environment variable found. Skipping authentication."
}
# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias
if ($env:app_umi_client_id) {
    #Connect-AzAccount -Identity -clientid $env:app_umi_client_id 
    Connect-MgGraph -Identity -ClientId $env:app_umi_client_id
    Write-Host "Authenticated to Graph using Managed Identity with client ID: $($env:app_umi_client_id)"
    Get-MgContext
} else {
    Write-Host "No app_umi_client_id environment variable found. Authenticating with default identity."
    Connect-MgGraph -Identity 
    # Connect-MgGraph -Identity # Uncomment this line if you want to connect without a specific client ID
}

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.