# Introduction

Write-Host '...Hi...'
Write-Host 'You are using Redis Cache Json Generator'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly around Azure CLI.'

# Should we uninstall the modules 
y

if ($UninstallModules -eq 'Y' -or $UninstallModules -eq 'y') {
    set-variable -name UninstallModules -value TRUE
}
else {
    set-variable -name UninstallModules -value FALSE
}

# Check if PowerShellGet is installed
$IsPowerShellGetInstalled = Get-Module PowerShellGet -list | Select-Object Name,Version,Path

# Give instructions to install powershellget
# https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget


# Check if Azure Rm is available

# Install Azure Rm if unavailable

# Login to Azure RM account
Login-AzureRmAccount

# Get Azure subscriptions on this account
Get-AzureRmSubscription | sort SubscriptionName | Select SubscriptionName

# Provide option to select a subscription
# It would be better if the user can select a number
Select-AzureRmSubscription -SubscriptionName ContosoSubscription

# Get Redis account details
Get-AzureRmRedisCache

# Iterate through the cahces to get key
Get-AzureRmRedisCacheKey -Name myCache -ResourceGroupName myGroup

# Save in the JSOn format supported by https://github.com/uglide/RedisDesktopManager/