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
# if ($env:MSI_SECRET) {
#    Connect-AzAccount -Identity
#      Write-Host "Authenticated to Azure using Managed Identity with client ID: $($env:MSI_SECRET)"
#      get-azcontext
#  } else {
#      Write-Host "No MSI_SECRET environment variable found. Skipping authentication."
#  }
# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias
if ($env:app_umi_client_id) {
    Connect-MgGraph -Identity -ClientId $env:app_umi_client_id
    Write-Host "Authenticated to Azure CLI using Managed Identity with client ID: $($env:app_umi_client_id)"
    Connect-AzAccount -Identity -AccountId $env:app_umi_client_id 
    Write-Host "Authenticated to Azure using Managed Identity with client ID: $($env:app_umi_client_id)"
    $graphtoken = (Get-MgContext).AccessToken
} else {
    #for debugging environement
    # User needs to be logged on to Azure CLI before running the function app
    #example: 
    #az config set core.login_experience_v2=off
    #az login --allow-no-subscription --use-device-code
    #az account set -s <subscription-id to use>  
    $aztoken = az account get-access-token --resource https://management.azure.com/ --query accessToken -o tsv 
    $accountid=az account show --query user.name -o tsv
    $subscriptionid=az account show --query id -o tsv  
    Connect-AzAccount -AccessToken $aztoken -AccountId $accountid -Subscription $subscriptionid  
  
}


