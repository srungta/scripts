# Introduction

Write-Host '...Hi...'
Write-Host 'You are using Redis Cache Json Generator'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly around Azure CLI.'

# Take the output path
$OutputPath = Read-Host 'Enter the drop location for the final json file : '
# Check if the path is valid else ask for a file name

# Check if Azure Rm is available
$IsAzureInstalled = Get-Module Azure -list | Select-Object Name, Version, Path

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

# Login to Azure RM account
Login-AzureRmAccount

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

# Get Redis account details
$AllRedisCaches = Get-AzureRmRedisCache

# Iterate through the caches to get key and form the JSON

# Save in the JSOn format supported by https://github.com/uglide/RedisDesktopManager/

# Name               : modiot-ci-dev-confroom
# Id                 : /subscriptions/987e6029-fd7c-482b-81ad-7714e25061fe/resourceGroups/modiot-ci-dev/providers/Microsoft.Cache/Red
#                      is/modiot-ci-dev-confroom
# Location           : West US
# Type               : Microsoft.Cache/Redis
# HostName           : modiot-ci-dev-confroom.redis.cache.windows.net
# Port               : 6379
# ProvisioningState  : Succeeded
# SslPort            : 6380
# RedisConfiguration : {[maxmemory-reserved, 50], [maxclients, 1000], [maxfragmentationmemory-reserved, 50], [maxmemory-delta, 50]}
# EnableNonSslPort   : False
# RedisVersion       : 3.2.7
# Size               : 1GB
# Sku                : Standard
# ResourceGroupName  : modiot-ci-dev
# SubnetId           :
# StaticIP           :
# TenantSettings     :
# ShardCount         :

$OutputJson = '['
for ($i = 0; $i -lt $AllRedisCaches.Count; $i++) {
    $Cache = $AllRedisCaches[$i]
    $CacheKey = Get-AzureRmRedisCacheKey -Name $Cache.Name -ResourceGroupName $Cache.ResourceGroupName

    $temp = '{
        "auth": "' + $CacheKey.PrimaryKey + '",
        "host": "' + $Cache.HostName + '",
        "keys_pattern": "*",
        "name": "' + $Cache.HostName + '",
        "namespace_separator": ":",
        "port": ' + $Cache.SslPort + ',
        "ssh_port": 22,
        "ssl": true,
        "ssl_ca_cert_path": "",
        "ssl_local_cert_path": "",
        "ssl_private_key_path": "",
        "timeout_connect": 60000,
        "timeout_execute": 60000
    }'
    $OutputJson = $OutputJson + $temp
    if ($i -ne $AllRedisCaches.Count - 1) {
        $OutputJson = $OutputJson + ','
    }
}
$OutputJson = $OutputJson + ']'

$OutputJson | Out-File -FilePath $OutputPath 