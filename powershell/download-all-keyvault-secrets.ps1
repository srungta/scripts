# Introduction

Write-Host '...Hi...'
Write-Host 'You are using a script to create multiple secrets for secretname quickly'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly around Azure CLI.'

# Take the output path
$keyVaultName = Read-Host -Prompt 'Provide keyvault name :'

if ([string]::IsNullOrWhiteSpace($keyVaultName)) {
    Write-Host "Using default value 'xxx'."
    $keyVaultName = 'xxx'
} 

$OutputPath = Read-Host -Prompt 'Provide output path :'

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    Write-Host "Using default value 'templates/generate-password-and-write-to-file.-outputjson'."
    $OutputPath = './templates/generate-password-and-write-to-file-output.json'
} 

# Check if Azure Rm is available
$IsAzureInstalled = Get-Module AzureRm -list | Select-Object Name, Version, Path

if ($IsAzureInstalled) {
    Write-Host 'You already have Azure powershell installed. Skipping installation.'
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
    Install-Module AzureRM
    Import-Module AzureRM
}

        
# Login to Azure RM account if required
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
    Login-AzureRmAccount
}

# Get Azure subscriptions on this account
$AllSubscriptionsForThisAccount = Get-AzureRmSubscription

# Provide option to select a subscription
$i = 0
Write-Host 'You have the following subscriptions available.'
foreach ($subscription in $AllSubscriptionsForThisAccount) {
    Write-Host $i '.' $subscription.Name
    $i++
}
$SubscriptionIndex = Read-Host -Prompt 'Select subscription by index above'

if ([convert]::ToInt32($SubscriptionIndex, 10) -ge $i -or [convert]::ToInt32($SubscriptionIndex, 10) -lt 0) {
    Write-Host 'Trying to act coy, are we? rerun the script now. :P'
    Exit-PSSession
}

Select-AzureRmSubscription -SubscriptionName $AllSubscriptionsForThisAccount[$SubscriptionIndex].Name

$secrets = Get-AzureKeyVaultSecret -VaultName $keyVaultName
foreach ($secret in $secrets) {
    $value = Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name $secret.Name
    Write-Host $secret.Name ' : ' $value.SecretValueText
}

$content | ConvertTo-Json -depth 100 | Out-File $OutputPath