# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
function Windows11 {
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

                Write-Host " Replaced start menu for user $($startmenu.FullName.Split('\')[2])" -ForegroundColor Yellow
            }
            else {
                # Bin file doesn't exist, indicating the user is not running the correct version of Windows. Exit function
                Write-Host "Error: Unable to clear start menu, start2.bin file could not be found for user $($startmenu.FullName.Split('\')[2])" -ForegroundColor Red
                Write-Host ""
                return
            }
        }

        # Also apply start menu template to the default profile

        # Path to default profile
        $defaultProfile = "C:\Users\default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

        # Create folder if it doesn't exist
        if (-not(Test-Path $defaultProfile)) {
            New-Item $defaultProfile -ItemType Directory -Force | Out-Null
            Write-Host " Created LocalState folder for default user" -ForegroundColor Yellow
        }

        # Copy template to default profile
        Copy-Item -Path $startmenuTemplate -Destination $defaultProfile -Force
        Write-Host " Copied start menu template to default user folder" -ForegroundColor Yellow
        Write-Host ""
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

            Write-Host " Replaced start menu for user $([Environment]::UserName)" -ForegroundColor Yellow
            Write-Host ""
        }
        else {
            # Bin file doesn't exist, indicating the user is not running the correct version of Windows. Exit function
            Write-Host "Error: Unable to clear start menu, start2.bin file could not be found for user $([Environment]::UserName)" -ForegroundColor Red
            Write-Host ""
            return
        }
    }
}

function Windows10 {
    
    $START_MENU_LAYOUT = @"
    <LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
        <LayoutOptions StartTileGroupCellWidth="6" />
        <DefaultLayoutOverride>
            <StartLayoutCollection>
                <defaultlayout:StartLayout GroupCellWidth="6" />
            </StartLayoutCollection>
        </DefaultLayoutOverride>
    </LayoutModificationTemplate>
"@

    $layoutFile="C:\Windows\StartMenuLayout.xml"

    #Delete layout file if it already exists
    If(Test-Path $layoutFile)
    {
        Remove-Item $layoutFile
    }

    #Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

    $regAliases = @("HKLM", "HKCU")

    #Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        IF(!(Test-Path -Path $keyPath)) { 
            New-Item -Path $basePath -Name "Explorer"
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    #Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5

    #Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    #Restart Explorer and delete the layout file
    Stop-Process -name explorer

    # Uncomment the next line to make clean start menu default for all new users
    #Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

    Remove-Item $layoutFile
}

$version = [System.Environment]::OSVersion.Version
if ($version.Major -eq 10 -and $version.Build -ge 22000) {
    #Windows11
} elseif ($version.Major -eq 10) {
    Windows10
} else {
    "Older version or not recognized"
}