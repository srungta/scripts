# Introduction

Write-Host '...Hi...'
Write-Host 'You are using a script to create multiple secrets for secretname quickly'
Write-Host 'By using this script, you are not agreeing to any liability or licences :)'
Write-Host 'This script may install a few powershell modules to work, mostly around Azure CLI.'

# Take the output path
$PathToJson = Read-Host -Prompt 'Provide path to the config json file :'

if ([string]::IsNullOrWhiteSpace($PathToJson)) {
    Write-Host "Using default value 'templates/generate-password-and-write-to-file.json'."
    $PathToJson = './templates/generate-password-and-write-to-file.json'
} 

$OutputPath = Read-Host -Prompt 'Provide output path :'

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    Write-Host "Using default value 'templates/generate-password-and-write-to-file.-outputjson'."
    $OutputPath = './templates/generate-password-and-write-to-file-output.json'
} 
$content = Get-Content -Raw -Path $PathToJson | ConvertFrom-Json

foreach ($application in $content) {
    Try {
        # Write-Host 'Creating password ' $application.secretName
        $Password = ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | sort {Get-Random})[0..20] -join ''
        Write-Host 'Creating password ' $application.secretName 'secret' $Password
        $application.secretValue = $Password
    }
    Catch {
        Write-Host 'Could not create application '
        Write-Host  $application.applicationName 
    }
}

$content | ConvertTo-Json -depth 100 | Out-File $OutputPath