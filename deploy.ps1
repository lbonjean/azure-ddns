#Get a random number between 100 and 300 to more easily be able to distinguish between several trials
$rand = Get-Random -Minimum 300 -Maximum 500

#Set values
$subscription="581b4da9-cdaf-4cf0-8670-bc63030e183c"
$location = "northeurope"

#define variables
$gitrepo="https://github.com/lbonjean/azure-ddns"
$resourceGroup = "cxn-dnstools-$rand-rg"
$storage = "cxndnstools$rand"
#$functionapp = "cxn-dnstools-$rand-fapp"
$functionapp = "C0000-dns"
$umi="cxn-dnstools-$rand-umi"



$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
$appPassword=-join ((1..16) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })   
$appUsername=-join ((1..16) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })   
$DnsZoneRGName="C0000-dns"


#set correct subscription
az account set --subscription $subscription
#register resource provider 
az provider register --namespace Microsoft.Web
#create group
az group create -n $resourceGroup -l $location

#create storage account
az storage account create `
    -n $storage `
    -l $location `
    -g $resourceGroup `
    --sku Standard_LRS
    
#create function
az functionapp create `
    -n $functionapp `
    --storage-account $storage `
    --flexconsumption-location $location `
    --runtime powershell `
    -g $resourceGroup `
    --functions-version 4

#az functionapp deployment source config --branch main --manual-integration --name $functionapp --repo-url $gitrepo --resource-group $resourceGroup
az webapp cors add --resource-group $resourcegroup --name $functionapp --allowed-origins 'https://portal.azure.com'    
#Create system-assigned Managed identity    
az identity create --name $umi --resource-group $resourceGroup --location $location 


$principalid=$(az identity show --name $umi --resource-group $resourcegroup --query principalId --output tsv)
$principalclientid=$(az identity show --name $umi --resource-group $resourcegroup --query clientId --output tsv)
$principalidcomplete=$(az identity show --name $umi --resource-group $resourcegroup --query id --output tsv)
az functionapp identity assign -n $functionapp -g $resourceGroup --identities $principalidcomplete
az functionapp config appsettings set --resource-group $resourcegroup --name $functionapp  --settings app_umi_client_id=$principalclientid
az functionapp config appsettings set --resource-group $resourcegroup --name $functionapp  --settings AppUsername=$appUsername
az functionapp config appsettings set --resource-group $resourcegroup --name $functionapp  --settings AppPassword=$appPassword
az functionapp config appsettings set --resource-group $resourcegroup --name $functionapp  --settings DnsZoneRGName=$DnsZoneRGName


#Get Graph Api service provider 
az ad sp list --query "[?appDisplayName=='Microsoft Graph'].{Name:appDisplayName, Id:appId}" --output table --all

#Save that as $graphID
#$graphId = az ad sp list --query "[?appDisplayName=='Microsoft Graph'].appId | [0]" --all 

#Set values
#$webAppName = "cxn-dnstools-$rand-"
#$principalId = $(az resource list -n $umi --query [*].Id --out tsv)

$graphResourceId = $(az ad sp list --display-name "Microsoft Graph" --query [0].id --out tsv)


#Get appRoleIds for Team.Create, Group.ReadWrite.All, Directory.ReadWrite.All, Group.Create, Sites.Manage.All, Sites.ReadWrite.All
$appRoleIds = $(az ad sp show --id $graphResourceId --query "appRoles[?value=='Policy.Read.All'].id | [0]" --output tsv), $(az ad sp show --id $graphResourceId --query "appRoles[?value=='Policy.ReadWrite.ConditionalAccess'].id | [0]" --output tsv)

#Loop over all appRoleIds and assign the permissions
foreach ($appRoleId in $appRoleIds) { $body = "{'principalId':'$principalId','resourceId':'$graphResourceId','appRoleId':'$appRoleId'}"; az rest --method post --uri https://graph.microsoft.com/v1.0/servicePrincipals/$principalId/appRoleAssignments --body $body --headers Content-Type=application/json }
