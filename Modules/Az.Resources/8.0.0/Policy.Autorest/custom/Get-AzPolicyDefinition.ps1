
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
# ----------------------------------------------------------------------------------

<#
.Synopsis
Gets policy set definitions.
.Description
The **Get-AzPolicyDefinition** cmdlet gets a collection of policy set definitions or a specific policy set definition identified by name or ID.
.Notes
## RELATED LINKS

[New-AzPolicyDefinition](./New-AzPolicyDefinition.md)

[Remove-AzPolicyDefinition](./Remove-AzPolicyDefinition.md)

[Update-AzPolicyDefinition](./Update-AzPolicyDefinition.md)
.Link
https://learn.microsoft.com/powershell/module/az.resources/get-azpolicydefinition
#>
function Get-AzPolicyDefinition {
[OutputType([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IPolicyDefinition])]
[CmdletBinding(DefaultParameterSetName='Name')]
param(
    [Parameter(ParameterSetName='Name', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='ManagementGroupName', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='SubscriptionId', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Version', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='ListVersion', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('PolicyDefinitionName')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The name of the policy definition to get.
    ${Name},

    [Parameter(ParameterSetName='Id', Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Version', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='ListVersion', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('ResourceId')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The full Id of the policy definition to get.
    ${Id},

    [Parameter(ParameterSetName='ManagementGroupName', Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Builtin', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Custom', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Static', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The name of the management group.
    ${ManagementGroupName},

    [Parameter(ParameterSetName='SubscriptionId', Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Builtin', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Custom', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Static', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The ID of the target subscription.
    ${SubscriptionId},

    [Parameter(ParameterSetName='Builtin', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only built-in policy definitions.
    ${Builtin},

    [Parameter(ParameterSetName='Custom', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only custom policy definitions.
    ${Custom},

    [Parameter(ParameterSetName='Static', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only static policy definitions.
    ${Static},

    [Parameter(ParameterSetName='Version', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [ValidateNotNullOrEmpty()]
    [Alias('PolicyDefinitionVersion')]
    [System.String]
    # The policy definition version in #.#.# format.
    ${Version},

    [Parameter(ParameterSetName='ListVersion', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only custom policy definitions.
    ${ListVersion},

    [Parameter()]
    [Obsolete('This parameter is a temporary bridge to new types and formats and will be removed in a future release.')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return artifacts using legacy format placing policy-specific properties in a property bag object.
    ${BackwardCompatible} = $false,

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.String]
    # The filter to apply on the operation.
    # Valid values for $filter are: 'atExactScope()', 'policyType -eq {value}' or 'category eq '{value}''.
    # If $filter is not provided, no filtering is performed.
    # If $filter=atExactScope() is provided, the returned list only includes all policy definitions that at the given scope.
    # If $filter='policyType -eq {value}' is provided, the returned list only includes all policy definitions whose type match the {value}.
    # Possible policyType values are NotSpecified, Builtin, Custom, and Static.
    # If $filter='category -eq {value}' is provided, the returned list only includes all policy definitions whose category match the {value}.
    ${Filter},

    [Parameter()]
    [Alias('AzureRMContext', 'AzureCredential')]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Azure')]
    [System.Management.Automation.PSObject]
    # The credentials, account, tenant, and subscription used for communication with Azure.
    ${DefaultProfile},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

begin {
    # turn on console debug messages
    $writeln = ($PSCmdlet.MyInvocation.BoundParameters.Debug -as [bool]) -or ($PSCmdlet.MyInvocation.BoundParameters.Verbose -as [bool])

    if ($writeln) {
        Write-Host -ForegroundColor Cyan "begin:Get-AzPolicyDefinition(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # mapping table of generated cmdlet parameter sets
    if ($Version -or $ListVersion) {
        $mapping = @{
            NameSub = 'Az.Policy.private\Get-AzPolicyDefinitionVersion_Get';               # Name, SubscriptionId, Version
            NameMG = 'Az.Policy.private\Get-AzPolicyDefinitionVersion_Get1';               # Name, ManagementGroupName, Version
            MG = 'Az.Policy.private\Get-AzPolicyDefinitionVersion_List';                   # ManagementGroupName
            Sub = 'Az.Policy.private\Get-AzPolicyDefinitionVersion_List1';                 # SubscriptionId
            BuiltinId = 'Az.Policy.private\Get-AzPolicyDefinitionVersionBuilt_Get';        # Id
            BuiltinGet = 'Az.Policy.private\Get-AzPolicyDefinitionVersionBuilt_Get';       # Name
        }
    }
    else {
        $mapping = @{
            NameSub = 'Az.Policy.private\Get-AzPolicyDefinition_Get';                      # Name, SubscriptionId
            NameMG = 'Az.Policy.private\Get-AzPolicyDefinition_Get1';                      # Name, ManagementGroupName
            Sub = 'Az.Policy.private\Get-AzPolicyDefinition_List';                         # SubscriptionId
            MG = 'Az.Policy.private\Get-AzPolicyDefinition_List1';                         # ManagementGroupName
            BuiltinId = 'Az.Policy.private\Get-AzPolicyDefinitionBuilt_Get';               # Id
            BuiltinGet = 'Az.Policy.private\Get-AzPolicyDefinitionBuilt_Get';              # Name
        }
    }

    if ($ListVersion) {
        $mapping['NameSub'] = 'Az.Policy.private\Get-AzPolicyDefinitionVersion_List2';            # Name, SubscriptionId
        $mapping['NameMG'] = 'Az.Policy.private\Get-AzPolicyDefinitionVersion_List3';             # Name, ManagementGroup
        $mapping['BuiltinId'] = 'Az.Policy.private\Get-AzPolicyDefinitionVersionBuilt_List';      # Id
        $mapping['BuiltinGet'] = 'Az.Policy.private\Get-AzPolicyDefinitionVersionBuilt_List';     # Name
    }
}

process {
    if ($writeln) {
        Write-Host -ForegroundColor Cyan "process:Get-AzPolicyDefinition(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # ensure fallback try/catch is invoked if necessary
    $PSBoundParameters['ErrorAction'] = 'Stop'

    # handle disallowed cases not handled by PS parameter attributes
    if ($PSBoundParameters['SubscriptionId'] -and $PSBoundParameters['ManagementGroupName']) {
        throw 'Only ManagementGroupName or SubscriptionId can be provided, not both.'
    }

    if ($PSBoundParameters['Version'] -and !$PSBoundParameters['Name'] -and !$PSBoundParameters['Id']) {
        throw 'Version is only allowed if Name or Id  are provided.'
    }

    if ($PSBoundParameters['ListVersion'] -and !$PSBoundParameters['Name'] -and !$PSBoundParameters['Id']) {
        throw 'ListVersion is only allowed if Name or Id  are provided.'
    }

    # handle specific parameter sets
    $parameterSet = $PSCmdlet.ParameterSetName
    $calledParameterSet = 'Sub'

    switch ($parameterSet) {
        'Builtin' {
            $PSBoundParameters.Add('Filter', "policyType eq 'Builtin'")
        }
        'Custom' {
            $PSBoundParameters.Add('Filter', "policyType eq 'Custom'")
        }
        'Static' {
            $PSBoundParameters.Add('Filter', "policyType eq 'Static'")
        }
        default {
            if ($Id) {
                $parsed = ParsePolicyDefinitionId $Id   # function is imported from Helpers.psm1
                switch ($parsed.ScopeType)
                {
                    'subid' {
                        $PSBoundParameters['SubscriptionId'] = $parsed['SubscriptionId']
                        if ($parsed['Name']) {
                            $calledParameterSet = 'NameSub';
                            $PSBoundParameters['Name'] = $parsed['Name']
                        }
                    }
                    'mgname' {
                        $PSBoundParameters['ManagementGroupName'] = $parsed['ManagementGroupName']
                        $PSBoundParameters['Name'] = $parsed['Name']
                        $calledParameterSet = 'NameMG';
                    }
                    'builtin' {
                        $calledParameterSet = 'BuiltinId'
                        $PSBoundParameters['PolicyDefinitionName'] = $parsed['Name']
                    }
                }
            }
        }
    }

    # this check is needed because builtin Ids are special (no subId, no mgId)
    if ($calledParameterSet -ne 'BuiltinId') {
        # determine parameter set for call to generated cmdlet
        if ($PSBoundParameters['SubscriptionId']) {
            if ($PSBoundParameters['Name']) {
                $calledParameterSet = 'NameSub';
            }
            else {
                $calledParameterSet = 'Sub';
            }
        }
        elseif ($PSBoundParameters['ManagementGroupName']) {
            $PSBoundParameters['ManagementGroupId'] = $PSBoundParameters['ManagementGroupName']
            if ($PSBoundParameters['Name']) {
                $calledParameterSet = 'NameMG'
            }
            else {
                $calledParameterSet = 'MG'
            }
        }
        elseif ($parameterSet -ne 'Id') {
            $PSBoundParameters['SubscriptionId'] = (Get-SubscriptionId)
            if ($PSBoundParameters['Name']) {
                $calledParameterSet = 'NameSub'
            }
        }
    }

    if ($PSBoundParameters['Name']) {
        $PSBoundParameters['PolicyDefinitionName'] = $PSBoundParameters['Name']
        $null = $PSBoundParameters.Remove('Name')
    }

    if ($PSBoundParameters['Version']) {
        $PSBoundParameters['PolicyDefinitionVersion'] = $PSBoundParameters['Version']
        $null = $PSBoundParameters.Remove('Version')
    }

    # remove parameters not used by generated cmdlets
    $null = $PSBoundParameters.Remove('BackwardCompatible')
    $null = $PSBoundParameters.Remove('ManagementGroupName')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('Builtin')
    $null = $PSBoundParameters.Remove('Custom')
    $null = $PSBoundParameters.Remove('Static')
    $null = $PSBoundParameters.Remove('ListVersion')

    if ($writeln) {
        Write-Host -ForegroundColor Blue -> $mapping[$calledParameterSet]'(' $PSBoundParameters ')'
    }

    $cmdInfo = Get-Command -Name $mapping[$calledParameterSet]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.MessageAttributeHelper]::ProcessCustomAttributesAtRuntime($cmdInfo, $MyInvocation, $calledParameterSet, $PSCmdlet)
    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping[$calledParameterSet]), [System.Management.Automation.CommandTypes]::Cmdlet)
    $scriptCmd = {& $wrappedCmd @PSBoundParameters}

    # get output and fix up for backward compatibility
    try {
        $output = Invoke-Command -ScriptBlock $scriptCmd
    }
    catch {
        if (($_.Exception.Message -like '*PolicyDefinitionNotFound*') -and $PSBoundParameters.PolicyDefinitionName -and $PSBoundParameters.SubscriptionId) {

            # failed by name at subscription level, try builtins
            $null = $PSBoundParameters.Remove('SubscriptionId')
            $cmdInfo = Get-Command -Name $mapping['BuiltinGet']
            [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.MessageAttributeHelper]::ProcessCustomAttributesAtRuntime($cmdInfo, $MyInvocation, $calledParameterSet, $PSCmdlet)
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping['BuiltinGet']), [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters}

            if ($writeln) {
                Write-Host -ForegroundColor Blue -> $mapping['BuiltinGet']'(' $PSBoundParameters ')'
            }

            $output = Invoke-Command -ScriptBlock $scriptCmd
        }
        else {
            throw
        }
    }

    foreach ($item in $output) {
        # add property bag for backward compatibility with previous SDK cmdlets
        if ($BackwardCompatible) {
            $propertyBag = @{
                Description = $item.Description;
                DisplayName = $item.DisplayName;
                Metadata = ConvertObjectToPSObject $item.Metadata;
                Mode = $item.Mode;
                Parameters = ConvertObjectToPSObject $item.Parameter;
                PolicyRule = ConvertObjectToPSObject $item.PolicyRule;
                PolicyType = $item.PolicyType
            }

            $item | Add-Member -MemberType NoteProperty -Name 'Properties' -Value ([PSCustomObject]($propertyBag))
            $item | Add-Member -MemberType NoteProperty -Name 'ResourceId' -Value $item.Id
            $item | Add-Member -MemberType NoteProperty -Name 'ResourceName' -Value $item.Name
            $item | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value $item.Type
            $item | Add-Member -MemberType NoteProperty -Name 'PolicyDefinitionId' -Value $item.Id
        }

        # use PSCustomObject for JSON properties
        $item | Add-Member -MemberType NoteProperty -Name 'Metadata' -Value (ConvertObjectToPSObject $item.Metadata) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'Parameter' -Value (ConvertObjectToPSObject $item.Parameter) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'PolicyRule' -Value (ConvertObjectToPSObject $item.PolicyRule) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'Versions' -Value ([array]($item.Versions)) -Force
        $PSCmdlet.WriteObject($item)
    }
}

end {
}
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDjEQz5rLnX3N6V
# drs4q8bRrErI3NTcIbZaUyeLf/lxGqCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEICCEHorNE7w4Fgusp1WOGiLM
# K7unLE9kvvdO+GXBVv3gMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAsvzB4Ms5ZkUasd7JZRbO5P19Vw+X8Ivnte+HkiCRFQ+xOkn6UjKkEMsg
# vFdAQRG1KpQX5HLSguOrt+YIYbCzYuSlIAB8dybVOulszTmpfORBRF+PNjpUAIFA
# OXgJqb73MPALFVSvX+xhUByYSbkv38BGzRnlS4N7k5W7ZKsHzZiRWmZdLKiJqZrm
# u3dl9+QWNaRtOq2oHRpOm+Qmr8/G6iUEIV/G29vGDRXFo6V3ByVS/+Knm3IfCOBN
# Id8PEh5nFtv5FRPt+Jl6PKF9x8rbpQg6E68QVuEeNsWQpG4JpIhzpVNgCBX5ONsL
# n/JcxW1nx68oPj+QiV8zxKgr1XvhcaGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCD/gD5ZAyUxTZDqW53+zX9yXwSZvUTwAnxVNaXxZLo/PgIGaBjCj0/t
# GBMyMDI1MDUxNDA5MTkwNy4yMjNaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTkzNS0w
# M0UwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgy5ZOM1nOz0rgABAAACDDANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQz
# MDBaFw0yNjA0MjIxOTQzMDBaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTkzNS0wM0UwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDKAVYmPeRtga/U6jzqyqLD0MAool23gcBN58+Z/Xsk
# YwNJsZ+O+wVyQYl8dPTK1/BC2xAic1m+JvckqjVaQ32KmURsEZotirQY4PKVW+eX
# wRt3r6szgLuic6qoHlbXox/l0HJtgURkzDXWMkKmGSL7z8/crqcvmYqv8t/slAF4
# J+mpzb9tMFVmjwKXONVdRwg9Q3WaPZBC7Wvoi7PRIN2jgjSBnHYyAZSlstKNrpYb
# 6+Gu6oSFkQzGpR65+QNDdkP4ufOf4PbOg3fb4uGPjI8EPKlpwMwai1kQyX+fgcgC
# oV9J+o8MYYCZUet3kzhhwRzqh6LMeDjaXLP701SXXiXc2ZHzuDHbS/sZtJ3627cV
# pClXEIUvg2xpr0rPlItHwtjo1PwMCpXYqnYKvX8aJ8nawT9W8FUuuyZPG1852+q4
# jkVleKL7x+7el8ETehbdkwdhAXyXimaEzWetNNSmG/KfHAp9czwsL1vKr4Rgn+pI
# IkZHuomdf5e481K+xIWhLCPdpuV87EqGOK/jbhOnZEqwdvA0AlMaLfsmCemZmupe
# jaYuEk05/6cCUxgF4zCnkJeYdMAP+9Z4kVh7tzRFsw/lZSl2D7EhIA6Knj6RffH2
# k7YtSGSv86CShzfiXaz9y6sTu8SGqF6ObL/eu/DkivyVoCfUXWLjiSJsrS63D0EH
# HQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHUORSH/sB/rQ/beD0l5VxQ706GIMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDZMPr4gVmwwf4GMB5ZfHSr34uhug6yzu4H
# UT+JWMZqz9uhLZBoX5CPjdKJzwAVvYoNuLmS0+9lA5S74rvKqd/u9vp88VGk6U7g
# MceatdqpKlbVRdn2ZfrMcpI4zOc6BtuYrzJV4cEs1YmX95uiAxaED34w02BnfuPZ
# XA0edsDBbd4ixFU8X/1J0DfIUk1YFYPOrmwmI2k16u6TcKO0YpRlwTdCq9vO0eEI
# ER1SLmQNBzX9h2ccCvtgekOaBoIQ3ZRai8Ds1f+wcKCPzD4qDX3xNgvLFiKoA6ZS
# G9S/yOrGaiSGIeDy5N9VQuqTNjryuAzjvf5W8AQp31hV1GbUDOkbUdd+zkJWKX4F
# mzeeN52EEbykoWcJ5V9M4DPGN5xpFqXy9aO0+dR0UUYWuqeLhDyRnVeZcTEu0xgm
# o+pQHauFVASsVORMp8TF8dpesd+tqkkQ8VNvI20oOfnTfL+7ZgUMf7qNV0ll0Wo5
# nlr1CJva1bfk2Hc5BY1M9sd3blBkezyvJPn4j0bfOOrCYTwYsNsjiRl/WW18NOpi
# wqciwFlUNqtWCRMzC9r84YaUMQ82Bywk48d4uBon5ZA8pXXS7jwJTjJj5USeRl9v
# jT98PDZyCFO2eFSOFdDdf6WBo/WZUA2hGZ0q+J7j140fbXCfOUIm0j23HaAV0ckD
# S/nmC/oF1jCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNQ
# MIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkE5MzUtMDNFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDv
# u8hkhEMt5Z8Ldefls7z1LVU8pqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6851IjAiGA8yMDI1MDUxNDAxNDky
# MloYDzIwMjUwNTE1MDE0OTIyWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDrznUi
# AgEAMAoCAQACAgf4AgH/MAcCAQACAhL4MAoCBQDrz8aiAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAGqKRzQneQu/NMVBBZD34AVAYxeHGIkl30Pon+hp9Fkv
# DhCGYZpdT406LIVX740n14R4XF5FaWA+DhHan2IjMosA2r7+kQEImbpeQd4L+v6R
# a086HSGO3nDoa0sXi08uhcpvylcCsZ4zZcIskkhKC0keXkk4MMhug6026M+C5Q8B
# nt51TJL74iLZQDYzHmpDmuCRXOlh71fqd2x2IBfGtnO7PtcLdQIZsYS3VPpswx/k
# wTUTgrCaMLvDx5BRrBFObmOdlw6RQI+eQ8FCU3pz5caS6WE3BJzHC/SZjY9GNP6n
# WTZN0bUtaqrXZciP39hk5wX5CIRto/VVRSj4DS7NXhQxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgy5ZOM1nOz0rgABAAAC
# DDANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCDPYVrNKd7mwbC12H4wiT/yIyGrmqimyE4CD2plDtb9
# 8DCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EINUo17cFMZN46MI5NfIAg9Ux
# 5cO5xM9inre5riuOZ8ItMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIMuWTjNZzs9K4AAQAAAgwwIgQgqTuJPr9cTdZ28BTT4IpZ8gwg
# phKfz3xvQA+r7eOXgIAwDQYJKoZIhvcNAQELBQAEggIAMOCg2/9WsB0yRmT6MUrU
# kJPzAY4rdk0vC1koS8t0bm5GhTlzhG0rka6saDv6QOrmoayWKBvrqpETXzcCv9lQ
# P+ECmLNh+Qn8l8Idxxkx4YPBCESzirqiYtdAcoe+oMe/26fe3Yd7I/zcbj+yzFze
# J3DcavxtJqSTsAxjCNIJgsqmwjrk6xgXWaoh5iuFfJpvuU74sAc2HYd3rwdZlUka
# eh95DPfcR2l342b0pVM1lt8RuyDU6qXL0Es2kFSkOhyLRRBxjRk21ZMImFOvV9+H
# i8Os9ZjZSP6Qd7HmUbYMRxHCJXa8T7UbKG4QcUx8P3nR0qDiVGLdi+DdRNWrwc4z
# 38kA/wXKVXUtAkEfiEOCYEKQWVINHTMJUvb3MoDvGFhZlFLTKBobaPwxBtgPPQQN
# j2p04QL23x3dkSRK0FiOHO+zI8M37vo4M6ZzZF9ViaaOxR8zpB8b75IfMShM51xs
# 02EkaldjAN/PuodV2DBFKs42Jxm2QUTQBXyUEGnSW5nzZ4Iuf0VLAPngu17PWb9e
# gDvkuxxv5YMWpzr1wxZBSUB4tFjhJS9UEln8Pd2RfrZPA7qWzpXDbeakDxACwIyB
# RNZn1tW2KYhBgbnXVfe+eoUc3XtxwDgB3XAlmTSbKG/7I1LiVvlqr1JFjE9F5vx2
# QQzxUjKHZwk51XcPzNNDoZQ=
# SIG # End signature block
