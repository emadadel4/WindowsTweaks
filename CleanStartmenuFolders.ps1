
$targetDirectory = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"

# Define the folders to exclude from deletion
$excludedFolders = @("Windows Administrative Tools", "Windows Ease of Access", "Windows PowerShell", "Windows System")

# Get all items in the target directory
$items = Get-ChildItem -Path $targetDirectory

# Loop through each item
foreach ($item in $items) {
    # Check if the item is not in the excluded folders list
    if ($item.PSIsContainer -and $excludedFolders -notcontains $item.Name) {
        # Remove the folder and its contents
        Remove-Item -Path $item.FullName -Recurse -Force
    }
    elseif (-not $item.PSIsContainer) {
        # Remove the file
        Remove-Item -Path $item.FullName -Force
    }
}
