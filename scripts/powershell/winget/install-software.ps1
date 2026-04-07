#Var for current folder
$currentDir = (pwd).Path

#Download dependencies
(New-Object System.Net.WebClient).DownloadFile('https://github.com/microsoft/winget-cli/releases/download/v1.28.190/DesktopAppInstaller_Dependencies.zip',"$currentDir\Dependencies.zip")
Expand-Archive "Dependencies.zip"; rm "Dependencies.zip"
mv "Dependencies\x64\Microsoft.VCLibs.140.00_14.0.33519.0_x64.appx" "$currentDir\VCLibs.appx"
mv "Dependencies\x64\Microsoft.WindowsAppRuntime.1.8_8000.616.304.0_x64.appx" "$currentDir\Xaml.appx"
Remove-Item -Recurse -Force ".\Dependencies"


(New-Object System.Net.WebClient).DownloadFile('https://github.com/microsoft/winget-cli/releases/download/v1.28.190/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle',"$currentDir\Winget.msixbundle")

(New-Object System.Net.WebClient).DownloadFile('https://github.com/microsoft/winget-cli/releases/download/v1.28.190/e53e159d00e04f729cc2180cffd1c02e_License1.xml',"$currentDir\License.xml")


(New-Object System.Net.WebClient).DownloadFile('https://cdn.winget.microsoft.com/cache/source.msix',"$currentDir\Sources.msix")

#install winget
Add-AppxPackage -Path ".\VCLibs.appx";
Add-AppxPackage -Path ".\Xaml.appx";
Add-AppxPackage -Path ".\Winget.msixbundle";
Add-AppxProvisionedPackage -Online -PackagePath ".\Winget.msixbundle" -LicensePath ".\License.xml";


#reset winget sources plus src tweaks
winget source reset --force;
winget source remove msstore;
winget update all --force;

#Add sources manually
Add-AppPackage -path ".\Sources.msix";

#Updating the existing system
winget upgrade --all --accept-package-agreements --accept-source-agreements;

#Installing base softwares
winget import --accept-package-agreements --accept-source-agreements -i ".\Applist.json";
