Write-Output "INSTALL CHOCO APPS"
Write-Output "------------"
# Install Choco Apps
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
$chocoAvailable = $false
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $chocoAvailable = $true
    $installedStuff = choco list -i
} else {
    Write-Output "Chocolatey not found - skipping Chocolatey-based installations"
    $installedStuff = @()
}
if ($chocoAvailable) {
    if (($installedStuff -like "*7zip*").Count -eq 0) {
       Write-Output "Installing 7zip"
       choco install 7zip --confirm --accept-license -y
    } else { Write-Output "Detected 7zip"}
    if (($installedStuff -like "*gh*").Count -eq 0) {
        Write-Output "Installing gh"
        choco install gh --confirm --accept-license -y
    } else { Write-Output "Detected gh"}
    if (($installedStuff -like "*GitVersion.Portable*").Count -eq 0) {
        Write-Output "Installing GitVersion"
        choco install gitversion.portable --confirm --accept-license -y
    } else { Write-Output "Detected GitVersion"}
    if (($installedStuff -like "*nodejs*").Count -eq 0) {
        Write-Output "Installing nodejs"
        choco install nodejs --confirm --accept-license -y
    } else { Write-Output "Detected nodejs"}
} else {
    Write-Output "Skipping Chocolatey package installations (Chocolatey not available)"
}

Write-Output "------------"

# Install DotNetApps
Write-Output "INSTALL DotNetApps APPS"
Write-Output "------------"
$installedDotNetStuff = dotnet tool list -g
if (($installedDotNetStuff -like "*GitVersion.Tool*").Count -eq 0) {
    Write-Output "Installing GitVersion.Tool"
    if ($chocoAvailable) {
        choco install 7zip --confirm --accept-license -y
    }
} else { Write-Output "Detected GitVersion.Tool"}
dotnet tool install --global GitVersion.Tool
Write-Output "------------"


# Install NodeJs Apps
$npmAvailable = $false
if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmAvailable = $true
}
if ($npmAvailable) {
    if (((npm list -g tfx-cli) -join "," ).Contains("empty")) {
        Write-Output "Installing tfx-cli"
        npm i -g tfx-cli
    } else { Write-Output "Detected tfx-cli"}
} else {
    Write-Output "npm not found - skipping npm-based installations (tfx-cli)"
}


Write-Output "REFRESH ENVIRONMENT"
Write-Output "------------"
# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
if ($chocoAvailable) {
    # Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
    # variable and importing the Chocolatey profile module.
    # Note: Using `. $PROFILE` instead *may* work, but isn't guaranteed.
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    Update-SessionEnvironment
} else {
    Write-Output "Skipping Chocolatey environment refresh (Chocolatey not available)"
}
Write-Output "------------"
