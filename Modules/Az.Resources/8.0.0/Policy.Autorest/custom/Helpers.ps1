
# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Code generated by Microsoft (R) AutoRest Code Generator.Changes may cause incorrect behavior and will be lost if the code
# is regenerated.
# ----------------------------------------------------------------------------------

# split policy ids into usable parts
function ParsePolicyId {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    # the resource Id of a policy definition
    param($resourceId, $policyType)

    # validate args
    if (!$resourceId) {
        throw 'ParsePolicyId(resourceId, policyType) argument error: resourceId must be provided.'
    }

    if (!$policyType) {
        # extract policyType
        $temp = $resourceId -split '/providers/Microsoft.Authorization/'
        if ($temp.Length -lt 2) {
            throw 'parsePolicy(resourceId, policyType) argument error: resourceId is not a Microsoft.Authorization resource type'
        }

        $policyType = ($temp[1] -split '/')[0]
    }

    if (!$policyType) {
        throw 'ParsePolicyId(resourceId, policyType) argument error: unable to find type name.'
    }

    $mark = "/providers/Microsoft.Authorization/$($policyType)/"
    $parts = $resourceId -split $mark
    $scope = $parts[0]
    $name = ''

    if ($parts.Length -gt 1) {
        $parts = $parts[1] -split '/'
        $name = $parts[0]
        if (($parts.Length -gt 2) -and ($parts[1] -eq 'versions')) {
            $parsedVersion = ParsePolicyVersion $parts[2]
        }
    }

    $scopeType = 'none'
    $subId = ''
    $mgName = ''
    $rgName = ''
    $resource = ''
    $resNamespace = ''
    $resType = ''
    $resName = ''

    if (!$scope) {
        $scopeType = 'builtin'
    }
    elseif ($scope -like '/providers/Microsoft.Management/managementGroups/*') {
        $scopeType = 'mgname'
        $mgName = ($scope -split '/providers/Microsoft.Management/managementGroups/')[1]
    }
    elseif ($scope -like '/subscriptions/*/resourceGroups/*/*') {
        $scopeType = 'resource'
        $temp = ($scope -split '/subscriptions/')[1]
        $temp = ($temp -split '/resourceGroups/')
        $subId = $temp[0]
        $temp = ($temp[1] -split '/providers/')
        $rgName = $temp[0]
        $temp = $temp[1] -split '/'
        if ($temp.Length -gt 2) {
            $resNamespace = $temp[0]
            $resType = $temp[1..($temp.Length-2)] -join '/'
            $resName = $temp[$temp.Length-1]
        }

        $resource = $scope
    }
    elseif ($scope -like '/subscriptions/*/resourceGroups/*') {
        $scopeType = 'rgname'
        $temp = ($scope -split '/subscriptions/')[1]
        $temp = ($temp -split '/resourceGroups/')
        $subId = $temp[0]
        $rgName = $temp[1]
    }
    elseif ($scope -like '/subscriptions/*') {
        $scopeType = 'subId'
        $subId = ($scope -split '/subscriptions/')[1]
    }

    $artifactRef = ''

    $artifact = $scope + $mark + $name
    if ($parsedVersion.VersionRef) {
        $artifactRef = "$artifact/versions/$($parsedVersion.VersionRef)"
    }

    return @{
        PolicyType = $policyType
        Scope = $scope
        ScopeType = $scopeType
        SubscriptionId = $subId
        ManagementGroupName = $mgName
        ResourceGroupName = $rgName
        Resource = $resource
        ResourceNamespace = $resNamespace
        ResourceType = $resType
        ResourceName = $resName
        Name = $name
        Artifact = $artifact
        ArtifactRef = $artifactRef
        Version = $parsedVersion.Version
        Major = $parsedVersion.Major
        Minor = $parsedVersion.Minor
        Patch = $parsedVersion.Patch
        Suffix = $parsedVersion.Suffix
        VersionRef = $parsedVersion.VersionRef
        VersionMajorRef = $parsedVersion.VersionMajorRef
        VersionMinorRef = $parsedVersion.VersionMinorRef
    }
}

# parse policy version with format: (ddd|*).(ddd|*).(ddd|*)[-suffix]
function ParsePolicyVersion {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    # the resource Id of a policy definition
    param($version)

    $parts = $version -split '\.'
    $major = $parts[0]
    $minor = ''
    if ($parts.Length -gt 1) {
        $minor = $parts[1]
    }

    $patch = ''
    $suffix = ''
    if ($parts.Length -gt 2) {
        $parts = $parts[2] -split '-'
        $patch = $parts[0]
        if ($parts.Length -gt 1) {
            $suffix = $parts[1]
        }
    }

    $versionMinorRef = ''
    $versionMajorRef = @($major,'*','*') -join '.'
    if ($minor -ne '*') {
        $versionMinorRef = @($major,$minor,'*') -join '.'
    }

    if ($suffix) {
        if ($versionMinorRef) {
            $versionMinorRef = $versionMinorRef + '-' + $suffix
        }

        $versionMajorRef = $versionMajorRef + '-' + $suffix
    }

    $versionRef = ''
    if ($versionMinorRef) {
        $versionRef = $versionMinorRef
    }
    else {
        $versionRef = $versionMajorRef
    }

    return @{
        Version = $version
        Major = $major
        Minor = $minor
        Patch = $patch
        Suffix = $suffix
        VersionRef = $versionRef
        VersionMajorRef = $versionMajorRef
        VersionMinorRef = $versionMinorRef
    }
}

# split policy definition resourceId into its parts (used externally)
function ParsePolicyDefinitionId {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    # the resource Id of a policy definition
    param($ResourceId)

    ParsePolicyId $ResourceId 'policyDefinitions'
}

# split policy set definition resourceId into its parts
function ParsePolicySetDefinitionId {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    # the resource Id of a policy set definition
    param($ResourceId)

    ParsePolicyId $ResourceId 'policySetDefinitions'
}

# split policy assignment resourceId into its parts
function ParsePolicyAssignmentId {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    # the resource Id of a policy set definition
    param($ResourceId)

    ParsePolicyId $ResourceId 'policyAssignments'
}

# split policy assignment resourceId into its parts
function ParsePolicyExemptionId {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    # the resource Id of a policy set definition
    param($resourceId)

    ParsePolicyId $ResourceId 'policyExemptions'
}

# Wrapper for JSON -> PSObject conversion that works on both Core and Desktop editions
function ConvertFrom-JsonSafe
{
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject,
        [switch]$AsHashtable = $false
    )

    if ($PSVersionTable.PSEdition -eq 'Core') {
        ConvertFrom-Json $InputObject -AsHashtable:$AsHashtable
    }
    elseif ($AsHashtable) {
        # ConvertFrom-Json on Windows Powershell doesn't support -AsHashtable parameter
        $converted = ConvertParameterInput ($InputObject | ConvertFrom-Json)
        if (($converted -is [array]) -and ($converted.Count -eq 1)) {
            return $converted[0]
        }
        else {
            return $converted
        }
    }
    else {
        ConvertFrom-Json $InputObject
    }
}

# convert the parameter object (could be either hashtable or PSCustomObject) to policy-formatted hashtable suitable for autorest serializers
function ConvertParameterObject
{
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param ($InputObject)

    $returnValue = @{}

    if ($InputObject -is [hashtable]) {
        foreach ($key in $InputObject.Keys) {
            $returnValue[$key] = @{ value = (ConvertParameterInput -InputObject $InputObject[$key]) }
        }
    }
    else {
        foreach ($property in $InputObject.PSObject.Properties) {
            $returnValue[$property.Name] = @{ value = (ConvertParameterInput -InputObject $InputObject.PSObject.Properties[$property.Name]) }
        }
    }

    return $returnValue
}

# Convert input parameter value to hashtable type expected by the autorest serializers
function ConvertParameterArray
{
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param ($InputObject)

    if ($InputObject -is [array])
    {
        $collection = @(
            foreach ($object in $InputObject) { ConvertParameterArray $object }
        )

        Write-Output -NoEnumerate $collection
    }
    elseif ($InputObject -is [hashtable])
    {
        return $InputObject
    }
    elseif ($InputObject -is [PSObject])
    {
        $hash = @{}

        foreach ($property in $InputObject.PSObject.Properties)
        {
            $hash[$property.Name] = (ConvertParameterArray $property.Value).PSObject.BaseObject
        }

        $hash
    }
    else {
        return $InputObject
    }
}

# convert various parameter input formats to policy-formatted hashtable suitable for autorest serializers
function ConvertParameterInput
{
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param ($InputObject)

    # traverse collections to ensure nested values are all processed
    if ($InputObject -is [hashtable]) {
        $returnValue = @{}
        foreach ($key in $InputObject.Keys) {
            $returnValue[$key] = (ConvertParameterInput $InputObject[$key])
        }

        return $returnValue
    }
    elseif ($InputObject -is [array]) {
        $returnValue = @()
        foreach ($object in $InputObject) {
            $returnValue += (ConvertParameterInput $object)
        }

        return ,$returnValue
    }
    elseif ($InputObject -is [PSObject])
    {
        $returnValue = @{}
        foreach ($property in $InputObject.PSObject.Properties) {
            $returnValue[$property.Name] = (ConvertParameterInput $property.Value)
        }

        return $returnValue
    }
    else {
        return $InputObject
    }
}

# Convert output hashtable object output by autorest serializers to PSCustomObject format for legacy support
function ConvertObjectToPSObject {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param($InputObject)

    if ($null -eq $InputObject) {
        return [PSCustomObject]$null
    }

    if ($InputObject -is [array]) {
        return ,@(foreach ($obj in $InputObject) { ConvertObjectToPSObject $obj })
    }

    if (!$InputObject.ToJsonString) {
        return [PSCustomObject]$InputObject
    }

    $jsonString = $InputObject.ToJsonString()
    if ($jsonString -is [array]) {
        $jsonString = "[$([System.String]::Join(',', $jsonString))]"
    }

    ConvertFrom-JsonSafe $jsonString
}

function GetPSObjectProperty {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param (
        [PSObject]$PropertyObject,
        [string]$PropertyPath
    )

    $propertyNames = $PropertyPath.Split('.')
    $tmpObject = $PropertyObject
    foreach ($propertyName in $propertyNames)
    {
        $propertyInfo = $tmpObject.PSObject.Properties[$propertyName]
        if ($propertyInfo)
        {
            if ($propertyInfo.Value -is [PSObject])
            {
                $tmpObject = [PSObject]$propertyInfo.Value
                continue
            }

            return $propertyInfo.Value
        }
    }

    return $tmpObject
}

# tests whether the given string is a Uri
function Test-Uri {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param([string]$Value)

    $uri = ''
    [System.Uri]::TryCreate($Value, [System.UriKind]::Absolute, [ref]$uri)
}

# issues a GET to the given address and returns the contents
function Get-UriContent {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param([string]$UriAddress)

    $response = Invoke-WebRequest $UriAddress -DisableKeepAlive -Method Get
    if ($response.StatusCode -eq 200) {
        return $response.Content
    }
}

# if the given string is a file path or URI, returns the contents of the file or web page
# otherwise returns the original string
function GetFileUriOrStringParameterValue {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param([string]$parameterValue)

    if (Test-Path $parameterValue) {
        Get-Content $parameterValue | Out-String
    }
    else {
        if (Test-Uri $parameterValue) {
            Get-UriContent $parameterValue
        }
        else {
            $parameterValue
        }
    }
}

function ResolvePolicyParameter {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [string]$ParameterName,
        [string]$ParameterValue,
        [bool]$Debug = $false
    )

    $policy = GetFileUriOrStringParameterValue $ParameterValue
    if ($debug) {
        Write-Host -ForegroundColor Cyan "Parameter ${ParameterName}:" $policy
    }

    $policyParameter = ConvertFrom-JsonSafe -AsHashtable $policy
    if ($policyParameter.properties) {
        return $policyParameter.properties
    } else {
        return $policyParameter
    }
}

function ResolvePolicyMetadataParameter {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        $MetadataValue,
        [bool]$Debug = $false
    )

    if ($metadataValue -is [hashtable]) {
        return $metadataValue
    }

    if ([System.String]::IsNullOrEmpty($metadataValue)) {
        return $metadataValue
    }

    $metadata = (GetFileUriOrStringParameterValue $metadataValue).Trim()
    if ($debug) {
        Write-Host -ForegroundColor Cyan Metadata: $metadata
    }

    if ($metadata -like '@{*') {
        # probably a PSCustomObject, try converting to hashtable
        return (Invoke-Expression($metadata.Replace('=',"='").Replace(';',"';").Replace('}',"'}")))
    }

    # otherwise it should be a JSON string
    if ($metadata -like '{*}') {
        return $metadata | ConvertFrom-JsonSafe -AsHashtable
    }

    throw "Unrecognized metadata format - value: [$($metadataValue)], type: [$($metadataValue.GetType())]"
}

# construct the full Id of a resource given the various parts (only used internally in this file)
function resolvePolicyArtifact {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [string]$name,
        [string]$subscriptionId,
        [string]$managementGroupName,
        [string]$id,
        [string]$policyType
    )

    $scope = ''
    $scopeType = 'none'
    $scopeName = ''
    $resourceId = '<invalid>'

    if ($id -and !$subscriptionId -and !$managementGroupName) {
        $resolved = ParsePolicyId $id $policyType
        $scope = $resolved.Scope
        $scopeType = $resolved.ScopeType
        switch ($scopeType) {
            'subId' {
                $subscriptionId = $resolved.SubscriptionId
                $scopeName = "subscription $($subscriptionId)"
            }
            'mgName' {
                $managementGroupName = $resolved.ManagementGroupName
                $scopeName = "management group $($managementGroupName)"
            }
            'rgname' {
                $subscriptionId = $resolved.SubscriptionId
                $scopeName = "resource group $($resolved.ResourceGroupName) (subId: $($subscriptionId))"
            }
            'resource' {
                $subscriptionId = $resolved.SubscriptionId
                $scopeName = "resource id $($resolved.Resource)"
            }
            'none' {
                $scopeName = "scope $($scope)"
            }
        }

        $name = $resolved.Name
        $resourceId = $id
    }
    else {
        if ($name) {
            if ($managementGroupName) {
                $scopeType = 'mgName'
                $scopeName = "management group $($managementGroupName)"
                $scope = "/providers/Microsoft.Management/managementGroups/$($managementGroupName)"
            }
            else {
                if (!$subscriptionId) {
                    $subscriptionId = (Get-SubscriptionId)
                }
                $scopeType = 'subId'
                $scopeName = "subscription $($subscriptionId)"
                $scope = "/subscriptions/$($subscriptionId)"
            }

            $resourceId = "$($scope)/providers/Microsoft.Authorization/$($policyType)/$($name)"
        }
    }

    return @{
        Scope = $scope;
        ScopeType = $scopeType
        ScopeName = $scopeName;
        Name = $name;
        SubscriptionId = $subscriptionId
        ManagementGroupName = $managementGroupName
        ResourceId = $resourceId
        ResourceGroupName = $resolved.ResourceGroupName
        ResourceNamespace = $resolved.ResourceNamespace
        ResourceType = $resolved.ResourceType
        ResourceName = $resolved.ResourceName
    }
}

function ResolvePolicyDefinition {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [string]$Name,
        [string]$SubscriptionId,
        [string]$ManagementGroupName,
        [string]$Id
    )

    resolvePolicyArtifact $Name $SubscriptionId $ManagementGroupName $Id 'policyDefinitions'
}

function ResolvePolicySetDefinition {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [string]$Name,
        [string]$SubscriptionId,
        [string]$ManagementGroupName,
        [string]$Id
    )

    resolvePolicyArtifact $Name $SubscriptionId $ManagementGroupName $Id 'policySetDefinitions'
}

function ResolvePolicyAssignment {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [string]$Name,
        [string]$Scope,
        [string]$Id
    )

    if ($Id) {
        $resourceId = $Id
    }
    elseif ($Scope) {
        $resourceId = "$($Scope)/providers/Microsoft.Authorization/policyAssignments/$($Name)"
    }
    else {
        $resourceId = "/subscriptions/$($(Get-SubscriptionId))/providers/Microsoft.Authorization/policyAssignments/$($Name)"
    }

    resolvePolicyArtifact $null $null $null $resourceId 'policyAssignments'
}

function ResolvePolicyExemption {
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.DoNotExportAttribute()]
    param(
        [string]$Name,
        [string]$Scope,
        [string]$Id
    )

    if ($Id) {
        $resourceId = $Id
    }
    elseif ($Scope) {
        $resourceId = "$($Scope)/providers/Microsoft.Authorization/policyExemptions/$($Name)"
    }
    else {
        $resourceId = "/subscriptions/$($(Get-SubscriptionId))/providers/Microsoft.Authorization/policyExemptions/$($Name)"
    }

    resolvePolicyArtifact $null $null $null $resourceId 'policyExemptions'
}

function LocationCompleter(
    $commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameter
)
{
    if ($global:AzPSPolicyCachedLocations.Count -le 0) {
        $response = Invoke-AzRestMethod -Uri "https://management.azure.com/subscriptions/$($(Get-SubscriptionId))/locations?api-version=2022-12-01" -Method GET
        $global:AzPSPolicyCachedLocations = ($response.Content | ConvertFrom-JsonSafe).value | Sort-Object -Property name | Select-Object -ExpandProperty name
    }

    # If you see the following error, it means your context access has expired
    #   The given key 'AzureAttestationServiceEndpointSuffix' was not present in the dictionary.
    $global:AzPSPolicyCachedLocations | Where-Object { $_ -like "$wordToComplete*" }
}

function Get-SubscriptionId {
    $script = Resolve-Path "$PSScriptRoot/../utils/Get-SubscriptionIdTestSafe.ps1"
    return . $script
}

function Get-ExtraParameters
(
    $DefaultProfile,
    $Break,
    $HttpPipelineAppend,
    $HttpPipelinePrepend,
    $Proxy,
    $ProxyCredential,
    $ProxyUseDefaultCredentials
) {
    $parms = @{}
    if ($PSBoundParameters['DefaultProfile']) {
        $parms['DefaultProfile'] = $PSBoundParameters['DefaultProfile']
    }

    if ($PSBoundParameters['Break']) {
        $parms['Break'] = $PSBoundParameters['Break']
    }

    if ($PSBoundParameters['HttpPipelineAppend']) {
        $parms['HttpPipelineAppend'] = $PSBoundParameters['HttpPipelineAppend']
    }

    if ($PSBoundParameters['HttpPipelinePrepend']) {
        $parms['HttpPipelinePrepend'] = $PSBoundParameters['HttpPipelinePrepend']
    }

    if ($PSBoundParameters['Proxy']) {
        $parms['Proxy'] = $PSBoundParameters['Proxy']
    }

    if ($PSBoundParameters['ProxyCredential']) {
        $parms['ProxyCredential'] = $PSBoundParameters['ProxyCredential']
    }

    if ($PSBoundParameters['ProxyUseDefaultCredentials']) {
        $parms['ProxyUseDefaultCredentials'] = $PSBoundParameters['ProxyUseDefaultCredentials']
    }

    return $parms
}

# register the location completer for New-AzPolicyAssignment
Register-ArgumentCompleter -CommandName New-AzPolicyAssignment -ParameterName Location -ScriptBlock ${function:LocationCompleter}

# cache Azure locations to be used by the location completer (Get-AzLocation is not available in this context, need to use REST)
$global:AzPSPolicyCachedLocations = @()
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBRWJHiPFSzVUmy
# YAzOthfFwcRPrdM1+OO8qiC/IkP3/KCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHLj33Iu4rfOCQUwaxlHI2d0
# FJWSMd6MlwXnZE/U8CVPMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAdkudrODbKh69+K6i+h7IPId2nWdQeztJkekBpBouFF1u+ptU8igjoQLB
# 6dzRrq/i3iQnL6AGIh4rSb+rsPAuqdKxQlfRgWFTHlQKnjcKwYMONN9zjbp+4cNs
# eGRmd8rm3XiqGOnvajmwUpASzW5aTxyb15FqwcXOmjuWxne/oRPUwSS8mpZlmJ+T
# EHMrgku/GMwgtoq0vtTP/9lQwHswrRYDLp6X37FVEiG0ziEnoZ5DVQfUMgm8LpmY
# X2YYilBnOuLcHz2FA0oZTzDVePyD3N8nD44hor97I87Mb4ZK0qv/FnI0k/3x9Z+G
# 4BxvOdcTp0bTlMnAR448PQgyBbou6aGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAUdzNRof6A9MUeZU1EPI09xcj2JxUE2OyXEX1FG+ZGxAIGaBKxZdPH
# GBMyMDI1MDUxNDA5MTkxMS4wMjJaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAgO7HlwAOGx0ygABAAACAzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NDZaFw0yNjA0MjIxOTQyNDZaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQChl0MH5wAnOx8Uh8RtidF0J0yaFDHJYHTpPvRR16X1
# KxGDYfT8PrcGjCLCiaOu3K1DmUIU4Rc5olndjappNuOgzwUoj43VbbJx5PFTY/a1
# Z80tpqVP0OoKJlUkfDPSBLFgXWj6VgayRCINtLsUasy0w5gysD7ILPZuiQjace5K
# xASjKf2MVX1qfEzYBbTGNEijSQCKwwyc0eavr4Fo3X/+sCuuAtkTWissU64k8rK6
# 0jsGRApiESdfuHr0yWAmc7jTOPNeGAx6KCL2ktpnGegLDd1IlE6Bu6BSwAIFHr7z
# OwIlFqyQuCe0SQALCbJhsT9y9iy61RJAXsU0u0TC5YYmTSbEI7g10dYx8Uj+vh9I
# nLoKYC5DpKb311bYVd0bytbzlfTRslRTJgotnfCAIGMLqEqk9/2VRGu9klJi1j9n
# VfqyYHYrMPOBXcrQYW0jmKNjOL47CaEArNzhDBia1wXdJANKqMvJ8pQe2m8/ciby
# DM+1BVZquNAov9N4tJF4ACtjX0jjXNDUMtSZoVFQH+FkWdfPWx1uBIkc97R+xRLu
# PjUypHZ5A3AALSke4TaRBvbvTBYyW2HenOT7nYLKTO4jw5Qq6cw3Z9zTKSPQ6D5l
# yiYpes5RR2MdMvJS4fCcPJFeaVOvuWFSQ/EGtVBShhmLB+5ewzFzdpf1UuJmuOQT
# TwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFLIpWUB+EeeQ29sWe0VdzxWQGJJ9MB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCQEMbesD6TC08R0oYCdSC452AQrGf/O89G
# Q54CtgEsbxzwGDVUcmjXFcnaJSTNedBKVXkBgawRonP1LgxH4bzzVj2eWNmzGIwO
# 1FlhldAPOHAzLBEHRoSZ4pddFtaQxoabU/N1vWyICiN60It85gnF5JD4MMXyd6pS
# 8eADIi6TtjfgKPoumWa0BFQ/aEzjUrfPN1r7crK+qkmLztw/ENS7zemfyx4kGRgw
# Y1WBfFqm/nFlJDPQBicqeU3dOp9hj7WqD0Rc+/4VZ6wQjesIyCkv5uhUNy2LhNDi
# 2leYtAiIFpmjfNk4GngLvC2Tj9IrOMv20Srym5J/Fh7yWAiPeGs3yA3QapjZTtfr
# 7NfzpBIJQ4xT/ic4WGWqhGlRlVBI5u6Ojw3ZxSZCLg3vRC4KYypkh8FdIWoKirji
# dEGlXsNOo+UP/YG5KhebiudTBxGecfJCuuUspIdRhStHAQsjv/dAqWBLlhorq2OC
# aP+wFhE3WPgnnx5pflvlujocPgsN24++ddHrl3O1FFabW8m0UkDHSKCh8QTwTkYO
# wu99iExBVWlbYZRz2qOIBjL/ozEhtCB0auKhfTLLeuNGBUaBz+oZZ+X9UAECoMhk
# ETjb6YfNaI1T7vVAaiuhBoV/JCOQT+RYZrgykyPpzpmwMNFBD1vdW/29q9nkTWoE
# hcEOO0L9NzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkRDMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDN
# rxRX/iz6ss1lBCXG8P1LFxD0e6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA685SVTAiGA8yMDI1MDUxMzIzMjA1
# M1oYDzIwMjUwNTE0MjMyMDUzWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrzlJV
# AgEAMAcCAQACAhQhMAcCAQACAhIxMAoCBQDrz6PVAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAIatFdQGyFjXtsCFG46bK62pAT5N+cdvokES3Se5v6S8itdJ
# ZZK24bgnvK1h+vtqQyYy+3to6XcytqOKd4MnqF9sBDkQw1Oxwrw5I6GD4DPDHzmr
# 00bxhsddqhP9FG2CPETboX6hX3X3t7PinWnOhnRB7JdsmqL9oWPLS82M46r1avz4
# MuD7ixa6Rp+doDBfmniLos8Fq1Z0E3bUQp6nQf6GaMJaqF4WW5sHbs+i+MDy13j0
# i4iaSAPX23d3SQfqRtkxIB53jVMWziwZ9PFf/ZSaGqIyPI7o7bqyzb/bvGtur5u7
# m0OX6fmI+/8vNFHO0wh4tyimO7M+PdB/RBTcB54xggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgO7HlwAOGx0ygABAAACAzAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCBCP2Auxj1YGW/9vpTgZMBO9At/+7sWMmT52WfuZiVpGTCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIEsD3RtxlvaTxFOZZnpQw0DksPmV
# duo5SyK9h9w++hMtMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAIDux5cADhsdMoAAQAAAgMwIgQgTrJAuh3T5m6hlleyqxz4eUHxL9L0
# jlkEN8Ue4wAAq4EwDQYJKoZIhvcNAQELBQAEggIAYXMUSH4XP65ahO/EU7eir6BY
# Gr1dZYaqX83WcsFqtHVHqlY6xJitUcDO4j9rLZPP/fyI379LzxOK+2dBDju5Haup
# Mg3iWRv8jhJ3bwFmdzG3v0QhSbjkerAjVSMv5bKAOpTpEFS04XWI9CB4ktHSEZbW
# grL2leOJJJCutiFO5VPtOwnWmgB2HbgNWlXmfH/qUZzWB4MLCP6yFIgWdZOSU/f3
# 0wLxeysV0W1PeXFEGRRTmT9Nat3MBepxbongokLxuimirCedHf5BnLMncpC7ZWFC
# 3srBKUAqHz19EiDYQATFVO/TPxuIw7UYw/EsXyX5vKGUr/XpjVOznnqS1Z+1zBcS
# Wyiicr+MrcJpdW4Bz5CKDAF/RiIplOvY9tVmMlRmsxFcUGJ4Ja42T6Dh2llMLial
# vEm/OBdl7+3QIPBvrSJMbNR3cqLjSeyFxAshfetBRW7sqmujx9pE2sbicfRpjg53
# KbOpohZBDnQANQDdBL5XHjJY0JcfDKCv+YtQHGvW0pTLwnKEGlGi3EKVq18GNmgm
# tcXH0XGAgmJH32EtlbxnUC1kPx3euoXwuZaTwMr9dYluW+zaySqvSdmWab8Q8sYF
# BMqY6WyN9SjVqWVJpgCMe1Dp7ybZ2dHvALt8F7ci3/U7b00J4TUlsyEsiAaWXA/9
# q9w1XT3qH9cJcTwFhrI=
# SIG # End signature block
