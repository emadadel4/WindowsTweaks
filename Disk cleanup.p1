Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
takeown /f C:\Windows\SoftwareDistribution /r /d y
icacls C:\Windows\SoftwareDistribution /grant administrators:F /t
Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\WinSxS\Backup\*" -Recurse -Force -ErrorAction SilentlyContinue
cleanmgr.exe /d C: /VERYLOWDISK /sagerun:1
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
wevtutil.exe clear-log "Microsoft-Windows-WindowsUpdateClient/Operational"
Remove-Item -Path "C:\Windows\Installer\$PatchCache$\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\Downloads\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue
