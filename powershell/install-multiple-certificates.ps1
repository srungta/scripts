# Imports the cetificate to CurrentUser/My store.
function Install-Certificate {
    param([string] $PfxFilePath, [SecureString] $Password)
    Add-Type -AssemblyName System.Security
    $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $Cert.Import($PfxFilePath, $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]"PersistKeySet")
    $Store = new-object system.security.cryptography.X509Certificates.X509Store -argumentlist "MY", CurrentUser
    $Store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::"ReadWrite")
    $Store.Add($Cert)
    $Store.Close()
}

# Introduction
Write-Host
Write-Host -ForegroundColor Yellow "...Hi..."
Write-Host -ForegroundColor Yellow "You are using a script to install multiple PFX certificates with the passwords in keyvault."
Write-Host -ForegroundColor Yellow "By using this script, you are not agreeing to any liability or licences :)"
Write-Host -ForegroundColor CYan "This script will install AzureRm Module if it is not installed already."
Write-Host -ForegroundColor Cyan "Preferably run this script in administrator mode."
Write-Host 

Write-Host -ForegroundColor Green "Pre requisites:"
Write-Host -ForegroundColor Green "1. Config file specifying the keyvault the certificates to install. This should ideally be alongside this script file."
Write-Host -ForegroundColor Green "2. PFX certificates to install. You can download them from the Certificates folder on the team sharepoint."

Write-Host
# Take the output path
$PathToConfigFile = Read-Host -Prompt "Provide path to the config json file (Press enter to use default) :" 
if ([string]::IsNullOrWhiteSpace($PathToConfigFile)) {
    Write-Host -ForegroundColor Yellow "Using default value "install-certificates-config.json"."
    $PathToConfigFile = "./install-certificates-config.json"
} 

Write-Host
# Take the output path
$CertificateFolder = Read-Host -Prompt "Full path to folder containing certificates without the trailing slash. eg. C:\certificates : " 
if ([string]::IsNullOrWhiteSpace($CertificateFolder)) {
    Write-Host -ForegroundColor Yellow "Using default value 'C:\certificates'."
    $CertificateFolder = "C:\certificates"
}

Write-Host    
# Check if Azure Rm is available
$IsAzureRmInstalled = Get-Module AzureRm -list | Select-Object Name, Version, Path
if ($IsAzureRmInstalled) {
    Write-Host -ForegroundColor Yellow "You already have Azure powershell installed. Skipping installation."
}
else {
    # Check if PowerShellGet is installed
    $IsPowerShellGetInstalled = Get-Module PowerShellGet  -list | Select-Object Name, Version, Path
    if ($IsPowerShellGetInstalled) {
        Write-Host -ForegroundColor Red "You do not have Powershell get installed. Skipping installation."
        # Give instructions to install powershellget
        Write-Host -ForegroundColor Cyan "Visit https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget for more information"
        Exit-PSSession
    }    
    Write-Host -ForegroundColor Cyan "You do not have AzureRm installed"
    Write-Host -ForegroundColor Cyan "Initiating installation."
    # Install Azure Rm if unavailable
    Install-Module AzureRM
    Import-Module AzureRM
}

Write-Host
# Login to Azure RM account if required
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
    Login-AzureRmAccount
}
# Get Azure subscriptions on this account
$AllSubscriptionsForThisAccount = Get-AzureRmSubscription
# Provide option to select a subscription
$i = 0
Write-Host -ForegroundColor Green "You have the following subscriptions available."
foreach ($subscription in $AllSubscriptionsForThisAccount) {
    Write-Host -ForegroundColor Green  $i "." $subscription.Name
    $i++
}
$SubscriptionIndex = Read-Host -Prompt "Select subscription by index above"
if ([convert]::ToInt32($SubscriptionIndex, 10) -ge $i -or [convert]::ToInt32($SubscriptionIndex, 10) -lt 0) {
    Write-Host "Trying to act coy, are we? rerun the script now. :P"
    Exit-PSSession
}
Select-AzureRmSubscription -SubscriptionName $AllSubscriptionsForThisAccount[$SubscriptionIndex].Name

Write-Host
# Read from config file
$Configuration = Get-Content -Raw -Path $PathToConfigFile | ConvertFrom-Json
$KeyVaultName = $Configuration.keyvaultName
$Certificates = $Configuration.certificates
foreach ($Certificate in $Certificates) {
    Write-Host -ForegroundColor Yellow  "Installing certificate " $Certificate.certificateName
    $CertificatePath = "$CertificateFolder\$($Certificate.certificateName).pfx"
    $Password = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $Certificate.certificatePasswordSecretName
    $SecurePassword = ConvertTo-SecureString -String $Password.SecretValueText -Force -AsPlainText
    Install-Certificate -PfxFilePath $CertificatePath -Password $SecurePassword
}
Write-Host -ForegroundColor Cyan "Installation Complete."
