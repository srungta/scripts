Get-Module azure | format-table version
Login-AzureRmAccount
Get-AzureRmSubscription | sort SubscriptionName | Select SubscriptionName
Select-AzureRmSubscription -SubscriptionName ContosoSubscription
Get-AzureRmRedisCache
Get-AzureRmRedisCacheKey -Name myCache -ResourceGroupName myGroup
# Put in json