param (
    [string]$path
)

if (-Not (Test-Path -Path $path -PathType Container)) {
    Write-Host "The specified path does not exist or is not a directory."
    exit
}

# Powershell script to print the folders and their sizes in MB
# Usage: .\Analyse.ps1
function Get-FolderSize {
    param (
        [string]$folder
    )
    $folder = $folder.TrimEnd("\")
    $objFSO = New-Object -ComObject Scripting.FileSystemObject
    $objFolder = $objFSO.GetFolder($folder)
    $objFolder.Size / 1MB
}
Write-Host "Folder - Size (MB)"


$folders = Get-ChildItem -Directory -Path $path -Recurse
Write-Host "Total folders: $($folders.Count)"
# Use Get-FolderSize to get the size for each folder and then print the folders and their sizes in decreasing order
$folderSizes = @()

foreach ($folder in $folders) {
    $size = Get-FolderSize $folder.FullName
    $folderSizes += [PSCustomObject]@{
        Folder = $folder.FullName
        SizeMB = $size
    }
}

$folderSizes = $folderSizes | Sort-Object -Property SizeMB -Descending

foreach ($folderSize in $folderSizes) {
    $size = $folderSize.SizeMB
    if ($size -lt 1) {
        $size = 0
    }
    else {
        $size = [math]::Round($size, 2)
        Write-Host "$size MB `t`t $($folderSize.Folder)"
    }
}