
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
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
Deletes entity from service principal.
.Description
Deletes entity from service principal.
.Link
https://learn.microsoft.com/powershell/module/az.resources/remove-azadserviceprincipal
#>
function Remove-AzADServicePrincipal {
[OutputType([System.Boolean])]
[CmdletBinding(DefaultParameterSetName='ObjectIdParameterSet', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(ParameterSetName='ObjectIdParameterSet', Mandatory)]
    [Alias('ServicePrincipalId', 'Id', 'PrincipalId')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Path')]
    [System.String]
    # key: id of servicePrincipal
    ${ObjectId},

    [Parameter(ParameterSetName='ApplicationIdParameterSet', Mandatory)]
    [Alias('AppId')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Path')]
    [System.Guid]
    # key: application id
    ${ApplicationId},

    [Parameter(ParameterSetName='SPNParameterSet', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Path')]
    [System.String]
    [Alias('SPN')]
    # key: service principal name
    ${ServicePrincipalName},

    [Parameter(ParameterSetName='DisplayNameParameterSet', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Path')]
    [System.String]
    # key: display name
    ${DisplayName},

    [Parameter(ParameterSetName='InputObjectParameterSet', Mandatory, ValueFromPipeline)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Path')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphServicePrincipal]
    # key: service principal object
    ${InputObject},

    [Parameter(ParameterSetName='ApplicationObjectParameterSet', Mandatory, ValueFromPipeline)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Path')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.IMicrosoftGraphApplication]
    # key: application object
    ${ApplicationObject},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Header')]
    [System.String]
    # ETag
    ${IfMatch},

    [Parameter()]
    [Alias("AzContext", "AzureRmContext", "AzureCredential")]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Azure')]
    [System.Management.Automation.PSObject]
    # The credentials, account, tenant, and subscription used for communication with Azure.
    ${DefaultProfile},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Returns true when the command succeeds
    ${PassThru},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

process {
    $param = @{}
    switch ($PSCmdlet.ParameterSetName) {
        'ObjectIdParameterSet' {
            $PSBoundParameters['Id'] = $PSBoundParameters['ObjectId']
            $null = $PSBoundParameters.Remove('ObjectId')
            break
        }
        'ApplicationIdParameterSet' {
            try {
                $param['ApplicationId'] = $PSBoundParameters['ApplicationId']
                $PSBoundParameters['Id'] = (Get-AzADServicePrincipal @param).Id
            } catch {
                throw
            }
            $null = $PSBoundParameters.Remove('ApplicationId')
            break
        }
        'SPNParameterSet' {
            try {
                $param['ServicePrincipalName'] = $PSBoundParameters['ServicePrincipalName']
                $PSBoundParameters['Id'] = (Get-AzADServicePrincipal @param).Id
            } catch {
                throw
            }
            $null = $PSBoundParameters.Remove('ServicePrincipalName')
            break
        }
        'DisplayNameParameterSet' {
            try {
                $param['DisplayName'] = $PSBoundParameters['DisplayName']
                [System.Array]$list = Get-AzADServicePrincipal @param
                if(1 -lt $list.Count) {
                    Write-Error "More than one service principal found with display name '$($PSBoundParameters['DisplayName'])'. Please use the Get-AzADServicePrincipal cmdlet to get the object id of the desired service principal."
                    return
                } elseif (1 -eq $list.Count) {
                    $PSBoundParameters['Id'] = $list[0].Id
                } else {
                    Write-Error "Service principal with display name '$($PSBoundParameters['DisplayName'])' does not exist."
                    return
                }
            } catch {
                throw
            }
            $null = $PSBoundParameters.Remove('DisplayName')
            break
        }
        'InputObjectParameterSet' {
            $PSBoundParameters['Id'] = $PSBoundParameters['InputObject'].Id
            $null = $PSBoundParameters.Remove('InputObject')
            break
        }
        'ApplicationObjectParameterSet' {
            try {
                $param['-ApplicationId'] = $PSBoundParameters['ApplicationObject']
                $PSBoundParameters['Id'] = (Get-AzADServicePrincipal @param).Id
            } catch {
                throw
            }
            $null = $PSBoundParameters.Remove('ApplicationObject')
            break
        }
        default {
            break
        }
    }

    Az.MSGraph.internal\Remove-AzADServicePrincipal @PSBoundParameters
}
}

# SIG # Begin signature block
# MIIoQwYJKoZIhvcNAQcCoIIoNDCCKDACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB+6l9xrQBG4kwg
# 3/rxbMJOk/QTlcgA+wNQmJTUz5IF7KCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGiMwghofAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIOcVuzVFMIX7sAPCQP5F1eGM
# f5NEHAlNWtGDRqJN9gMdMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAR9oewbM494/GVS7i9kTJR9adeB1s8mIc0fmoeFPTnHz+LGyxTClRasaO
# RzAmsZKCBXh0T0dwmXU8HJiMmPnYqaQGYzo4djhERjJ5uzvS3Wo0rBoOmEJsxoYp
# 1HnYN66DwinaNRpnK8HYSaCfSAPH2f/pYUnQBxtkFUM7PQfoqm6dMpUxkQJjhEBx
# fhJdmzfpe/esx0m/op9GMgyWkFASCl3ryhscIwvPNxGIYX5gy1O+cExzPHrEq7/a
# 6junv9/ooeUytXtGua3LBMvcbaVS2TC7xmiWj1y9bvyk2iBsHam+UIofISPh2GeY
# NI6HVLDr8vfQiqU40xaLho91FEkV3aGCF60wghepBgorBgEEAYI3AwMBMYIXmTCC
# F5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFaBgsq
# hkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCCxvOLK+DEOQFOotWhBsy2vASCstp4xu1nhhTddA9p6SwIGaBLCmlcm
# GBMyMDI1MDUxNDA5MTkwOC40NjhaMASAAgH0oIHZpIHWMIHTMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# TjozNjA1LTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB91ggdQTK+8L0AAEAAAH3MA0G
# CSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI0
# MDcyNTE4MzEwNloXDTI1MTAyMjE4MzEwNlowgdMxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9w
# ZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjM2MDUt
# MDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0OdHTBNom6/uXKaEKP9r
# PITkT6QxF11tjzB0Nk1byDpPrFTHha3hxwSdTcr8Y0a3k6EQlwqy6ROz42e0R5eD
# W+dCoQapipDIFUOYp3oNuqwX/xepATEkY17MyXFx6rQW2NcWUJW3Qo2AuJ0HOtbl
# SpItQZPGmHnGqkt/DB45Fwxk6VoSvxNcQKhKETkuzrt8U6DRccQm1FdhmPKgDzgc
# fDPM5o+GnzbiMu6y069A4EHmLMmkecSkVvBmcZ8VnzFHTDkGLdpnDV5FXjVObAgb
# SM0cnqYSGfRp7VGHBRqyoscvR4bcQ+CV9pDjbJ6S5rZn1uA8hRhj09Hs33HRevt4
# oWAVYGItgEsG+BrCYbpgWMDEIVnAgPZEiPAaI8wBGemE4feEkuz7TAwgkRBcUzLg
# Q4uvPqRD1A+Jkt26+pDqWYSn0MA8j0zacQk9q/AvciPXD9It2ez+mqEzgFRRsJGL
# tcf9HksvK8Jsd6I5zFShlqi5bpzf1Y4NOiNOh5QwW1pIvA5irlal7qFhkAeeeZqm
# op8+uNxZXxFCQG3R3s5pXW89FiCh9rmXrVqOCwgcXFIJQAQkllKsI+UJqGq9rmRA
# BJz5lHKTFYmFwcM52KWWjNx3z6odwz2h+sxaxewToe9GqtDx3/aU+yqNRcB8w0tS
# XUf+ylN4uk5xHEpLpx+ZNNsCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBTfRqQzP3m9
# PZWuLf1p8/meFfkmmDAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBf
# BgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmww
# bAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0El
# MjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEAN0ajafILeL6S
# QIMIMAXM1Qd6xaoci2mOrpR8vKWyyTsL3b83A7XGLiAbQxTrqnXvVWWeNst5YQD8
# saO+UTgOLJdTdfUADhLXoK+RlwjfndimIJT9MH9tUYXLzJXKhZM09ouPwNsrn8YO
# LIpdAi5TPyN8Cl11OGZSlP9r8JnvomW00AoJ4Pl9rlg0G5lcQknAXqHa9nQdWp1Z
# xXqNd+0JsKmlR8tcANX33ClM9NnaClJExLQHiKeHUUWtqyLMl65TW6wRM7XlF7Y+
# PTnC8duNWn4uLng+ON/Z39GO6qBj7IEZxoq4o3avEh9ba43UU6TgzVZaBm8VaA0w
# SwUe/pqpTOYFWN62XL3gl/JC2pzfIPxP66XfRLIxafjBVXm8KVDn2cML9IvRK02s
# 941Y5+RR4gSAOhLiQQ6A03VNRup+spMa0k+XTPAi+2aMH5xa1Zjb/K8u9f9M05U0
# /bUMJXJDP++ysWpJbVRDiHG7szaca+r3HiUPjQJyQl2NiOcYTGV/DcLrLCBK2zG5
# 03FGb04N5Kf10XgAwFaXlod5B9eKh95PnXKx2LNBgLwG85anlhhGxxBQ5mFsJGkB
# n0PZPtAzZyfr96qxzpp2pH9DJJcjKCDrMmZziXazpa5VVN36CO1kDU4ABkSYTXOM
# 8RmJXuQm7mUF3bWmj+hjAJb4pz6hT5UwggdxMIIFWaADAgECAhMzAAAAFcXna54C
# m0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZp
# Y2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAxODMy
# MjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG9w0B
# AQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51
# yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cywBAY
# 6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9
# cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130/o5Tz9bshVZN
# 7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDua
# Rr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tnYN74
# kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2
# K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNOwTM5
# TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28MyTZk
# i1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9Q
# BXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3Pmri
# Lq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUC
# BBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9y
# eS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUA
# YgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU
# 1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2Ny
# bC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIw
# MTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0w
# Ni0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5yS/yp
# b+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulm
# ZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/SHUB2RjebYIM
# 9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECW
# OKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/LAl4
# FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3Uw
# xTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk2XPX
# fx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVX
# VAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/AsGC
# onsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU
# 5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEG
# ahC0HVUzWLOhcGbyoYIDVjCCAj4CAQEwggEBoYHZpIHWMIHTMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# TjozNjA1LTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaIjCgEBMAcGBSsOAwIaAxUAb28KDG/xXbNBjmM7/nqw3bgrEOaggYMw
# gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsF
# AAIFAOvOY8cwIhgPMjAyNTA1MTQwMDM1MTlaGA8yMDI1MDUxNTAwMzUxOVowdDA6
# BgorBgEEAYRZCgQBMSwwKjAKAgUA685jxwIBADAHAgEAAgIExjAHAgEAAgISXzAK
# AgUA68+1RwIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUAA4IBAQCXtze9Vm3WsfJZ
# Q0AlZT7H/FAgl5/d2gEAcHr3J3h6mbZpFG7FjxHDyc9aW9Gf7UmHTzgc5kNe+ZNG
# u5IETPLK55vR43cWsI11pUMvXHIjoRBaa9RunQJR54JaJHp6/bje+uHiPYXZ6uV2
# W5R9CmNOzedoimnIOaPYL/hvO5B/JUZwIv/+bAo/5ftWimlZyOyLXMvNUT3uklaK
# oyPTBfIZGr/O5Kmh4aAZkbyh/lwA/5CknvYmdxa94bUsuGaIBWgcpcFtV0HPoLpP
# e7R9al1oR7VLcKoPGXlezgMPpRCIpsrbSiqYWtFxmZna3e5JR9UCeYfsNPzOAnhP
# NipYTbJeMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAH3WCB1BMr7wvQAAQAAAfcwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQguANGM3uhJPqz
# Y2bSy/L8IruF6h9WtRA2/zBM3ydUYc0wgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHk
# MIG9BCAh2pjaa3ca0ecYuhu60uYHP/IKnPbedbVQJ5SoIH5Z4jCBmDCBgKR+MHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB91ggdQTK+8L0AAEAAAH3
# MCIEINQw5I/LjZZMgtbG/2/FmXa92THNBKwKBUBQZE7cIQbhMA0GCSqGSIb3DQEB
# CwUABIICAMABUKtWmvF8G/Dr4GISEu7QHizu9+EbG2RpKr8CE2cGSlgYAENDh3O+
# 2dMeAdK7j2qvABHd7PfUnsaKXWpVEdzmDTfGYn1BGxHo8EP+t0EM8dWzOzV6/9BD
# mHtdJ5Mh4OVVBbfThe5X9xdcmqQQFC7XXs0Xn6yXU7t2pnUOkPTBx/8UkUz7gjh8
# 2XBKVWbN0e174YSHw9c/XH3xXnbn+6GK2BErT/2wAE9xsWlWiyhG+eAi6DpPfn07
# r+cTV252mN82GWcP/JdxtlPIH8lyEJhTK/7/7krLn/PbdNurvpSfeJcC3wR73IB7
# H0Ze1qYVxL1bvn+5oddTiIDAuJ+WmI4qs294Xzz0AfvIrrtk3X58OkQJKbMHFn6A
# j1z8q+srew5UGcOqZ+Rfr/uYGZHiBG60BxweM+L1N/IFRCvjI5Eq6awT6yubN3JT
# K6WUbLBvX1DjTEJHVNTCqsdYQ1ga9Qq2ajrR6bsTBF1tA5ibmSoIBiNMIYn26C/c
# xdyW4AjIzWAJ11hilJPbuHwPZNMCyZ7+pksY23aj503dssIq7TxfbEGq0+/iNwBQ
# BcRkuc4O+anKtzgl98qldWKBaHozPiw0AETo/JMxjz6p/6amg6a5B6zAjWVybnd0
# rnJcCb9+lEfdxSkSHOCykWjzy5LNO7PkiSa4aLiH8T+77KU5pvco
# SIG # End signature block
