# Introduction

Write-Host "...Hi..."
Write-Host "You are using a script to check expiration of secrets in multiple keyvaults"
Write-Host "By using this script, you are not agreeing to any liability or licences :)"

# List of keyvaults.
$keyVaultNames = New-Object System.Collections.ArrayList
$ret = $keyVaultNames.Add("connect-me-dev")
$ret = $keyVaultNames.Add("connect-me-uat")
$ret = $keyVaultNames.Add("connect-me-prod")
$ret = $keyVaultNames.Add("connect-me-dev-keyvault")
$ret = $keyVaultNames.Add("connect-me-prod-keyvault")

# Login to Azure RM account if required
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
    Login-AzureRmAccount
}
Select-AzureRmSubscription -SubscriptionId "f994101e-d2c6-4668-8568-22881f4c5311"
Write-Host "Following keys are expiring this month."
Write-Host "KEYVAULT`t`t`t`tKEYNAME`t`t`t`tEXPIRATIONDATE"
Write-Host "--------`t`t`t`t-------`t`t`t`t--------------"
foreach ($keyVaultName in $keyVaultNames) {
    $secrets = Get-AzureKeyVaultSecret -VaultName $keyVaultName
    foreach ($secret in $secrets) {
        if ($secret.Expires -lt (Get-date).AddMonths(3)) {
            Write-Host $keyVaultName "`t`t`t`t" $secret.Name "`t`t`t`t" $secret.Expires
        }
    }
}