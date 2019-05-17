# Introduction

Write-Host '...Hi...'
Write-Host 'You are using a script to activate your PIM role in Azure'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly from Azure CLI.'


# Check if Azure Rm is available
$IsAzureInstalled = Get-Module Microsoft.Azure.ActiveDirectory.PIM.PSModule -list | Select-Object Name, Version, Path

if ($IsAzureInstalled) {
    Write-Host 'You already have Azure powershell installed. Skipping installation.'
}
else {
    Write-Host 'You do not have Azure get installed. Initiating installation.'
    # Install Azure Rm if unavailable
    Install-Module Microsoft.Azure.ActiveDirectory.PIM.PSModule
}

Connect-PimService
$AllRoles = Get-PrivilegedRoleAssignment


# Provide option to select a subscription
$i = 0
Write-Host 'You have the following roles available.'
foreach ($role in $AllRoles) {
    Write-Host $i '.' $role.Name
    $i++
}
$RoleIndex = Read-Host -Prompt 'Select role by index above'

if ([convert]::ToInt32($RoleIndex, 10) -ge $i -or [convert]::ToInt32($RoleIndex, 10) -lt 0) {
    Write-Host 'Trying to act coy, are we? rerun the script now. :P'
    Exit-PSSession
}

# Take the output path
$ActivationReason = Read-Host -Prompt 'Provide reason for activating the role :' 
if ([string]::IsNullOrWhiteSpace($ActivationReason)) {
    Write-Host "Using default value 'Activating role for development related activity.'."
    $ActivationReason = 'Activating role for development related activity.'
} 

Enable-PrivilegedRoleAssignment -Duration 8 –RoleAssignment $AllRoles[$RoleIndex] –Reason $ActivationReason
Get-PrivilegedRoleAssignment