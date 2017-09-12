# Introduction

Write-Host '...Hi...'
Write-Host 'You are using Redis Cache Json Generator'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly around Azure CLI.'

# # Should we uninstall the modules 

# if ($UninstallModules -eq 'Y' -or $UninstallModules -eq 'y') {
#     set-variable -name UninstallModules -value TRUE
# }
# else {
#     set-variable -name UninstallModules -value FALSE
# }

# Check if PowerShellGet is installed
# $IsPowerShellGetInstalled = Get-Module PowerShellGet -list | Select-Object Name,Version,Path

# Give instructions to install powershellget
# https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget


# Check if Azure Rm is available

# Install Azure Rm if unavailable

# Login to Azure RM account
# Login-AzureRmAccount

# Get Azure subscriptions on this account
$AllAccounts = Get-AzureRmSubscription
$i = 0
foreach ($account in $AllAccounts) {
    Write-Host $i '.' $account.Name
    $i++
}
$AccountIndex = Read-Host -Prompt 'Select subscription by index above'


# Provide option to select a subscription
# It would be better if the user can select a number
Select-AzureRmSubscription -SubscriptionName $AllAccounts[$AccountIndex].Name

# Ge Redis account details
$AllRedisCaches = Get-AzureRmRedisCache

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
# Iterate through the cahces to get key
$OutputJson | ConvertTo-Json -Compress | Out-File -FilePath 'B:\a.json'


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
