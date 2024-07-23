
function ClearStartMenu {
    param (
        $message,
        $url = "https://github.com/emadadel4/ITT/raw/main/Assets/files/start2.bin",
        $applyToAllUsers = $True
    )

    Write-Output $message

    # Path to download start menu template
    $startmenuTemplate = "$PSScriptRoot/start2.bin"

    # Download the start2.bin file
    try {
        Invoke-WebRequest -Uri $url -OutFile $startmenuTemplate
    }
    catch {
        Write-Host "Error: Unable to download start2.bin from the provided URL" -ForegroundColor Red
        Write-Output ""
        return
    }

    if ($applyToAllUsers) {
        # Remove startmenu pinned apps for all users
        # Get all user profile folders
        $usersStartMenu = Get-ChildItem -Path "C:\Users\*\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

        # Copy Start menu to all users folders
        ForEach ($startmenu in $usersStartMenu) {
            $startmenuBinFile = $startmenu.FullName + "\start2.bin"
            $backupBinFile = $startmenuBinFile + ".bak"

            # Check if bin file exists
            if (Test-Path $startmenuBinFile) {
                # Backup current startmenu file
                Move-Item -Path $startmenuBinFile -Destination $backupBinFile -Force

                # Copy template file
                Copy-Item -Path $startmenuTemplate -Destination $startmenu -Force

                Write-Output "Replaced start menu for user $($startmenu.FullName.Split('\')[2])"
            }
            else {
                # Bin file doesn't exist, indicating the user is not running the correct version of Windows. Exit function
                Write-Host "Error: Unable to clear start menu, start2.bin file could not be found for user $($startmenu.FullName.Split('\')[2])" -ForegroundColor Red
                Write-Output ""
                return
            }
        }

        # Also apply start menu template to the default profile

        # Path to default profile
        $defaultProfile = "C:\Users\default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

        # Create folder if it doesn't exist
        if (-not(Test-Path $defaultProfile)) {
            New-Item $defaultProfile -ItemType Directory -Force | Out-Null
            Write-Output "Created LocalState folder for default user"
        }

        # Copy template to default profile
        Copy-Item -Path $startmenuTemplate -Destination $defaultProfile -Force
        Write-Output "Copied start menu template to default user folder"
        Write-Output ""
    }
    else {
        # Only remove startmenu pinned apps for current logged in user
        $startmenuBinFile = "C:\Users\$([Environment]::UserName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
        $backupBinFile = $startmenuBinFile + ".bak"

        # Check if bin file exists
        if (Test-Path $startmenuBinFile) {
            # Backup current startmenu file
            Move-Item -Path $startmenuBinFile -Destination $backupBinFile -Force

            # Copy template file
            Copy-Item -Path $startmenuTemplate -Destination $startmenuBinFile -Force

            Write-Output "Replaced start menu for user $([Environment]::UserName)"
            Write-Output ""
        }
        else {
            # Bin file doesn't exist, indicating the user is not running the correct version of Windows. Exit function
            Write-Host "Error: Unable to clear start menu, start2.bin file could not be found for user $([Environment]::UserName)" -ForegroundColor Red
            Write-Output ""
            return
        }
    }
}
ClearStartMenu