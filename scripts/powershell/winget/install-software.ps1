#Var for current folder
$currentDir = $PSScriptRoot

$srcDir = "${currentDir}\src"
$tmpDir = "${srcDir}\tmp"

$repo = "microsoft/winget-cli"
$releaseLatest = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"
$versionLatest = $releaseLatest.tag_name

$assets = $releaseLatest.assets

Write-Host "Latest release tag: $versionLatest"


$dirsToCreate = @($srcDir, $tmpDir)


#################################
# CLEANING UP PREVIOUS INSTALLS #
#################################


# Clean previous installs
if (Test-Path -Path "${srcDir}" -PathType Container){
    Write-Host "Clearing previous sources dir..."
	Remove-Item -Recurse -Force $srcDir
    Write-Host "Sources dir cleared."
}

foreach ($dir in $dirsToCreate){
	New-Item -ItemType Directory $dir
    Write-Host "Created new sources directory: $dir"
}


############################
# DOWNLOADING DEPENDENCIES #
############################



#Download dependencies
(New-Object System.Net.WebClient).DownloadFile("$($assets[3].browser_download_url)","$tmpDir\Dependencies.zip")
Expand-Archive "${tmpDir}\Dependencies.zip" -DestinationPath "${tmpDir}\";
mv "${tmpDir}\x64\Microsoft.VCLibs.*.UWPDesktop_*_x64.appx" "$srcDir\VCLibs_UWPDesktop.appx"
mv "${tmpDir}\x64\Microsoft.VCLibs.*_x64.appx" "$srcDir\VCLibs.appx"
mv "${tmpDir}\x64\Microsoft.WindowsAppRuntime.*_x64.appx" "$srcDir\Xaml.appx"



#Winget msix download
(New-Object System.Net.WebClient).DownloadFile("$($assets[5].browser_download_url)","$srcDir\Winget.msixbundle")

#License download
(New-Object System.Net.WebClient).DownloadFile("$($assets[4].browser_download_url)","$srcDir\License.xml")

#Sources Download
(New-Object System.Net.WebClient).DownloadFile('https://cdn.winget.microsoft.com/cache/source.msix',"$srcDir\Sources.msix")

try{
    Remove-Item -Recurse -Force $tmpDir
    Write-Host "Temp dir removed."
}catch {
    Write-Error "Error while removing the temp dir: $($_.Exception.Message)"
}

################################
# INSTALLING APPS USING WINGET #
################################

#install winget
Add-AppxPackage -Path "${srcDir}\VCLibs.appx";
Add-AppxPackage -Path "${srcDir}\VCLibs_UWPDesktop.appx";
Add-AppxPackage -Path "${srcDir}\Xaml.appx";
Add-AppxPackage -Path "${srcDir}\Winget.msixbundle";
Add-AppxProvisionedPackage -Online -PackagePath "${srcDir}\Winget.msixbundle" -LicensePath "${srcDir}\License.xml";

#reset winget sources plus src tweaks
winget source reset --force;
winget source remove msstore;
winget update all --force;

#Add sources manually
Add-AppPackage -path "${srcDir}\Sources.msix";

#Updating the existing system
winget upgrade --all --accept-package-agreements --accept-source-agreements;

#Installing softwares
winget import --accept-package-agreements --accept-source-agreements -i "${currentDir}\Applist.json"

#Restricting back script policy
Set-ExecutionPolicy Restricted;
