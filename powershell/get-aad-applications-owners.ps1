# Introduction

Write-Host "``...Hi...``"
Write-Host "``You are using a script to get owners of aad applications quickly``"
Write-Host "``By using this script, you are not agreeing to any liability or licences :)``"
Write-Host "``This script may install a few powershell modules to work, mostly around Azure CLI.``"
Write-Host 
# Take the output path
$PathToJson = Read-Host -Prompt "The name of the applications starts with : " 
if ([string]::IsNullOrWhiteSpace($PathToJson)) {
    Write-Host "Using default value "test"."
    $PathToJson = "test"
} 
Write-Host "The name of the applications starts with **$PathToJson**"
# Check if Azure Rm is available
$IsAzureInstalled = Get-Module AzureRm -list | Select-Object Name, Version, Path

if ($IsAzureInstalled) {
    Write-Host "You already have Azure powershell installed. Skipping installation."
}
else {
    # Check if PowerShellGet is installed
    $IsPowerShellGetInstalled = Get-Module PowerShellGet  -list | Select-Object Name, Version, Path
    if ($IsPowerShellGetInstalled) {
        Write-Host "``You do not have Powershell get installed. Skipping installation.``"
        # Give instructions to install powershellget
        Write-Host "``Visit https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget for more information``"
        Exit-PSSession
    }    
    Write-Host "``You do not have Azure get installed. Initiating installation.``"
    # Install Azure Rm if unavailable
    Install-Module AzureRM
    Import-Module AzureRM
}
       
# Login to Azure RM account if required
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
    Login-AzureRmAccount
}


$IsAzureInstalled = Get-Module AzureAd -list | Select-Object Name, Version, Path

if ($IsAzureInstalled) {
    Write-Host "``You already have AzureAD powershell installed. Skipping installation.``"
}
else {
    # Check if PowerShellGet is installed
    $IsPowerShellGetInstalled = Get-Module PowerShellGet  -list | Select-Object Name, Version, Path
    if ($IsPowerShellGetInstalled) {
        Write-Host "``You do not have Powershell get installed. Skipping installation.``"
        # Give instructions to install powershellget
        Write-Host "``Visit https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget for more information``"
        Exit-PSSession
    }    
    Write-Host "``You do not have AzureAD get installed. Initiating installation.``"
    # Install Azure Rm if unavailable
    Install-Module AzureAD
    Import-Module AzureAD
}
        
# Login to Azure RM account if required
Try {
    $var = Get-AzureADTenantDetail 
} 
Catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] { 
    Write-Host "``You are not connected.``"
    Write-Host
    $Credential = Get-Credential
    Connect-AzureAD -Credential $Credential
}

# Get Azure subscriptions on this account
$AllSubscriptionsForThisAccount = Get-AzureRmSubscription

# Provide option to select a subscription
$i = 0
Write-Host
Write-Host "You have the following subscriptions available."
foreach ($subscription in $AllSubscriptionsForThisAccount) {
    Write-Host "$i." $subscription.Name
    $i++
}
$SubscriptionIndex = Read-Host -Prompt "Select subscription by index above"

if ([convert]::ToInt32($SubscriptionIndex, 10) -ge $i -or [convert]::ToInt32($SubscriptionIndex, 10) -lt 0) {
    Write-Host "Trying to act coy, are we? rerun the script now. :P"
    Exit-PSSession
}

Select-AzureRmSubscription -SubscriptionName $AllSubscriptionsForThisAccount[$SubscriptionIndex].Name

$ExistingApplications = Get-AzureRmADApplication -DisplayNameStartWith $PathToJson
if ($ExistingApplications.Count -eq 0) {     
    Write-Host
    Write-Host "No aad applications found for " $PathToJson
}
else {
    Write-Host "----------------------------------------------"
    Write-Host "There are " $ExistingApplications.Count " applications..."
    Write-Host "Gettings owners of the application..."
    Write-Host "----------------------------------------------"
    # SHow current owners
    foreach ($application in $ExistingApplications) {
        Write-Host
        Write-Host
        Write-Host "**["  $application.DisplayName "]**" 
        Write-Host "_$($application.ApplicationId)_"
        $Owners = Get-AzureADApplicationOwner -ObjectId $application.ObjectId    
        foreach ($owner in $Owners) {
            Write-Host "-" $owner.DisplayName "<" $owner.UserPrincipalName ">" 
        }
    }
}