# Dns utilities
## Dynamic DNS updater
1. inadyn client
Implemented in function Get-DDnsUpdate
Client used in unifi devices.
inadyn -1n --force --loglevel=DEBUG --config=/run/ddns-eth8-inadyn.conf

2. Proximus internet box
Function prxinternetbox, configered @lubon
3. Watchguard devices

## update named locations

## Azure setup
- create function with managed identity in ...dns-rg
- assign dns permissions on RG to MI in order to allow updates
- create dns zone
- create users assigned managed identity
az identity create --name c0000-dns-updater --resource-group C0000-dns --location northeurope   

az ad sp show --id 00000003-0000-0000-c000-000000000000 --query "appRoles[?value=='Policy.ReadWrite.ConditionalAccess'].id | [0]"      
$body = "{'principalId':'ee7a6ed1-229c-4955-b584-d348bca16a26','resourceId':'f79779d2-dd10-4987-9ef4-0df42f29bed8','appRoleId':'01c0a623-fc9b-48e9-b794-0756f8e8f067'}"   
az rest --method post --uri https://graph.microsoft.com/v1.0/servicePrincipals/ee7a6ed1-229c-4955-b584-d348bca16a26/appRoleAssignments --body $body --headers "Content-Type=application/json" 
az functionapp identity assign --name c0000-dsn-flex --resource-group "C0000-dns" --identities '/subscriptions/581b4da9-cdaf-4cf0-8670-bc63030e183c/resourcegroups/C0000-dns/providers/Microsoft.ManagedIdentity/userAssignedIdentities/c0000-dns-updater'



# Azure DDNS
Provides an Inadyn compatible  DynDNS2 API to be hosted by an Azure Function which uses an underlying Microsoft Azure hosted DNS Zone to maintain the IP address for a single A record.

## Deploying the Provider
Within the Microsoft Azure Function portal:
1. Create a new Azure Function.
2. Open the Configuration pane, and add the following application settings:
    - _AppUsername_ - This is the username that will be required to use the public endpoint.
    - _AppPassword_ - This is the password that will be required to use the public endpoint. 
    - _DnsZoneRGName_ - This will need to contain the Resource Group Name for your DNS Zone.
3. Open the Identity pane, and enable a System or User Assigned identity. This identity __MUST__ have `DNS Zone Contributor` role for the DNS Zone the provider will be responsible for modifying.
4. Deploy this codebase into your Azure Function.

NOTE: Because this provider uses Basic authentication, a colon (:) will not be supported as a character in the _AppPassword_ application setting.

## Configuring the Inadyn Client
The following file will need to be updated on the network device at the location: `/etc/inadyn.conf`. If you are using a device such as a Unifi Dream Machine or Dream Machine Pro, the file will instead be located at: `/run/ddns_eth{?}_inadyn.conf`.

```conf
custom your-ddns.azurewebsites.net:1 {
    hostname    = "your.azuredomain.com"
    username    = "REDACTED"
    password    = "REDACTED"
    ddns-server = "your-ddns.azurewebsites.net"
    ddns-path   = "/nic/update?hostname=%h&myip=%i"
}
```

#### Provider Options
- _hostname_: This __MUST__ be the FQDN of the DNS entry to update.
- _username_: This __MUST__ match the username used in the _AppUsername_ application configuration setting.
- _password_: This __MUST__ match the password used in the _AppPassword_ application configuration setting.
- _ddns-server_: This is the location where the Azure Function has been deployed.
- _ddns-path_: DO NOT CHANGE!

## Testing
To test this, you will need to have command line access to the device running the `inadyn.service`.
```txt
inadyn -1n --force --loglevel=DEBUG --config=/etc/inadyn.conf
```

The following snippet shows what you should see on the Inadyn client logs when communicating with your DDNS service:
```log
inadyn[527119]: Sending alias table update to DDNS server: GET /nic/update?hostname=your.azuredomain.com&myip=REDACTED HTTP/1.0
inadyn[527119]: Host: your-ddns.azurewebsites.net
inadyn[527119]: Authorization: Basic REDACTED
inadyn[527119]: User-Agent: inadyn/2.9.1 https://github.com/troglobit/inadyn/issues
inadyn[527119]: Successfully sent HTTPS request!
inadyn[527119]: Successfully received HTTPS response (205/8191 bytes)!
inadyn[527119]: DDNS server response: HTTP/1.1 200 OK
Connection: close
Content-Type: text/plain; charset=utf-8
Date: Sun, 31 Dec 2023 02:16:13 GMT

good
inadyn[527119]: Successful alias table update for your.azuredomain.com => new IP# REDACTED
inadyn[527119]: Updating cache for your.azuredomain.com
```
