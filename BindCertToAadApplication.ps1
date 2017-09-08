$CertPath = Read-Host 'Enter path to certificate [c:\mycert.pfx] :'
$CertPassword = Read-Host 'Enter password of certificate [mysecurestring] :'

$PFX = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2Collection'
$PFX.Import($CertPath, $CertPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)

$RawCertData = $PFX.GetRawCertData()
$Base64Value = [System.Convert]::ToBase64String($RawCertData)
$RawCertData = $PFX.GetCertHash()
$Base64Thumbprint = [System.Convert]::ToBase64String($RawCertData)
$KeyId = [System.Guid]::NewGuid().ToString()


$OutputJson= @"
"keyCredentials": [
   {
        "customKeyIdentifier": "$Base64Thumbprint",
        "keyId": "$KeyId",
        "type": "AsymmetricX509Cert",
        "usage": "Verify",
        "value":  "$Base64Value"
    }
],
"@


$OutputFilePath = Read-Host 'Enter output path to creds [b:\] :'
$OutputFilePath = $OutputFilePath + "keyCred.txt"
$OutputJson | out-file -filepath $OutputFilePath
Write-Host "KeyCreds for AAD created at $OutputFilePath"

#########################################################################
# Download the manifest file of your Azure AAD application.             #
# Add the JSON generated in keycreds file to keyCredentials array       #
# Upload the manifest back in your Azure portal.                        #
#########################################################################
# {
#     "appId": "-----",                                                 
#     "appRoles": [],
#     "availableToOtherTenants": false,
#     "displayName": "-----",
#     "errorUrl": null,
#     "groupMembershipClaims": null,
#     "homepage": "----",
#     "identifierUris": [
#       "----"
#     ],
#     "keyCredentials": [    <----------------INSERT HERE
#       {
#         "customKeyIdentifier": "---",
#         "endDate": "---",
#         "keyId": "---",
#         "startDate": "---",
#         "type": "AsymmetricX509Cert",
#         "usage": "Verify",
#         "value": null
#       }
#     ],
#     "knownClientApplications": [],
#     "logoutUrl": null,
#     ....
#
#########################################################################
