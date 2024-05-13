Write-Host "Deleting registry keys for removing standard folders..."

$folders = @(
    "{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
    "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
    "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
    "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
    "{088e3905-0323-4b02-9826-5d99428e115f}",
    "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
    "{d3162b92-9365-467a-956b-92703aca08af}"
)

foreach ($folder in $folders) {
    $registryPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\$folder"
    $wowRegistryPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\$folder"

    if (Test-Path $registryPath) {
        Remove-Item -Path $registryPath -Force
    }else
    {
        Clear-Host
        Write-Host "It has already been deleted, you good to go :)"
    }

    if (Test-Path $wowRegistryPath) 
    {
        Remove-Item -Path $wowRegistryPath -Force
    }
    else
    {
        Clear-Host
        Write-Host "It has already been deleted, you good to go :)"
    }
}

