# Introduction

Write-Host '...Hi...'
Write-Host 'You are using a script to get owners of an aad applciation'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly around Azure CLI.'

# Take the output path
$ObjectId = Read-Host -Prompt 'Enter object id :' 
# Check if the path is valid else ask for a file name

$IsAzureInstalled = Get-Module AzureAd -list | Select-Object Name, Version, Path

if ($IsAzureInstalled) {
    Write-Host 'You already have AzureAD powershell installed. Skipping installation.'
}
else {
    # Check if PowerShellGet is installed
    $IsPowerShellGetInstalled = Get-Module PowerShellGet  -list | Select-Object Name, Version, Path
    if ($IsPowerShellGetInstalled) {
        Write-Host 'You do not have Powershell get installed. Skipping installation.'
        # Give instructions to install powershellget
        Write-Host 'Visit https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget for more information'
        Exit-PSSession
    }    
    Write-Host 'You do not have Azure get installed. Initiating installation.'
    # Install Azure Rm if unavailable
    Install-Module AzureAD
    Import-Module AzureAD
}

        
# Login to Azure RM account if required
Try {
    $var = Get-AzureADTenantDetail 
} 
Catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] { 
    Write-Host "You're not connected.";
    $Credential = Get-Credential
    Connect-AzureAD -Credential $Credential
}


$Owners = Get-AzureADApplicationOwner -ObjectId $ObjectId
$i = 0
Write-Host 'You have the following owners available.'
foreach ($owner in $Owners) {
    Write-Host $i '.' $owner.DisplayName '<' $owner.UserPrincipalName '>' 
    $i++
}
