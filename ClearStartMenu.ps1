# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
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

Function UnpinStartMenuTiles {
	Write-Output "Unpinning all Start Menu tiles..."
	$errpref = $ErrorActionPreference #save actual preference
        $ErrorActionPreference = "silentlycontinue"
		If ([System.Environment]::OSVersion.Version.Build -ge 22000) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Type DWord -Value 0 | Out-Null -ErrorAction SilentlyContinue
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0 | Out-Null -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMorePrograms" | Out-Null -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMorePrograms" | Out-Null -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "LockedStartLayout" | Out-Null -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "StartLayoutFile" | Out-Null -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "LockedStartLayout" | Out-Null -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "StartLayoutFile" | Out-Null -ErrorAction SilentlyContinue
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Type DWord -Value 1 | Out-Null -ErrorAction SilentlyContinue
	} Else {
	Invoke-WebRequest -Uri "https://git.io/JL54C" -OutFile "$env:UserProfile\StartLayout.xml" -ErrorAction SilentlyContinue
	Import-StartLayout -layoutpath "$env:UserProfile\StartLayout.xml" -MountPath "$env:SystemDrive\"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "LockedStartLayout" -Type DWord -Value 1 | Out-Null -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "StartLayoutFile" -Type ExpandString -Value "%USERPROFILE%\StartLayout.xml" | Out-Null -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMorePrograms" -Type DWord -Value 0 | Out-Null -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMorePrograms" -Type DWord -Value 0 | Out-Null -ErrorAction SilentlyContinue
        Start-Sleep -s 3
        $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
        Start-Sleep -s 3
	function get-itemproperty2 {
  # get-childitem skips top level key, use get-item for that
  # set-alias gp2 get-itemproperty2
  param([parameter(ValueFromPipeline)]$key)
  process {
    $key.getvaluenames() | foreach-object {
      $value = $_
      [pscustomobject] @{
        Path = $Key -replace 'HKEY_CURRENT_USER',
          'HKCU:' -replace 'HKEY_LOCAL_MACHINE','HKLM:'
        Name = $Value
        Value = $Key.GetValue($Value)
        Type = $Key.GetValueKind($Value)
		}
      }
    }
  }
}
$YourInputStart = "02,00,00,00,e6,d9,21,ac,f8,e0,d6,01,00,00,00,00,43,42,01,00,c2,14,01,cb,32,0a,03,05,ce,ab,d3,e9,02,24,da,f4,03,44,c3,8a,01,66,82,e5,8b,b1,ae,fd,fd,bb,3c,00,05,a0,8f,fc,c1,03,24,8a,d0,03,44,80,99,01,66,b0,b5,99,dc,cd,b0,97,de,4d,00,05,86,91,cc,93,05,24,aa,a3,01,44,c3,84,01,66,9f,f7,9d,b1,87,cb,d1,ac,d4,01,00,c2,3c,01,c5,5a,01,00"
$hexifiedStart = $YourInputStart.Split(',') | ForEach-Object { "0x$_"}
Get-ChildItem -r "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" | get-itemproperty2 | Where-Object { $_ -like '*windows.data.unifiedtile.startglobalproperties*' } | set-itemproperty -value (([byte[]]$hexifiedStart))
Stop-Process -name explorer | Out-Null
	$ErrorActionPreference = $errpref #restore previous preference
}

$version = [System.Environment]::OSVersion.Version
if ($version.Major -eq 10 -and $version.Build -ge 22000) {
    ClearStartMenu
} elseif ($version.Major -eq 10) {
    UnpinStartMenuTiles
} else {
    "Older version or not recognized"
}