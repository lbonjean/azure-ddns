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

# make sure you are logged in to Azure CLI befor starting the function host
if (-not (az account show)) {
    Write-Host "You are not logged in to Azure CLI. Please log in first."
    exit 1
}
$token=ConvertTo-SecureString -string (az account get-access-token --scope="https://graph.microsoft.com/Directory.AccessAsUser.All" | ConvertFrom-Json).accessToken -AsPlainText
get-mgcontext
connect-mggraph -accessToken $token
