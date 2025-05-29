# Only needed when refresh token is not present. This will bypass the need to Consent MS graph application, as Azure CLI is pre-consented application
az login --allow-no-subscription
 
# Get the best possible scope that works generally with most Graph Operations. Ensure that the logged-in user is limited to read-only AAD role, to ensure no write operations are possible (The scope allows write permissions)
$graphAccessUserAsAll = az account get-access-token --scope="https://graph.microsoft.com/Directory.AccessAsUser.All" | ConvertFrom-Json

This is the explanation
https://securecloud.blog/2023/05/26/avoiding-consent-to-ms-graph-powershell-with-azure-cli-a-step-towards-simpler-operations-and-adversary-simulation/
 it is not possible to connect with high priviledged scopes to ms graph trought the azure cli
 this makes a delegated connection possible based upon the RBAC permissions of the user

az config set core.login_experience_v2=off
az login --allow-no-subscription --use-device-code
az account set -s 581b4da9-cdaf-4cf0-8670-bc63030e183c  

(az account get-access-token --scope="https://graph.microsoft.com/Directory.AccessAsUser.All" | ConvertFrom-Json).accessToken | Set-Content -path ~/.graphplain
##$GraphToken=ConvertTo-SecureString -string (az account get-access-token --scope="https://graph.microsoft.com/Directory.AccessAsUser.All" | ConvertFrom-Json).accessToken -AsPlainText

connect-mgGraph -AccessToken $graphtoken

