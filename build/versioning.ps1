Write-Output "Detect Version"
Write-Output "--------------"

$IsLocal = $False
Write-Output "Azure DevOps Build ID: $($Env:Build_BuildId)"
Write-Output "GitHub Run ID: $($github.run_id)"
$IsGitHubAction = $False
$IsAzureDevOps = $False
$IsLocal = $True
if ($Env:Build_BuildId -ne $Null)
{
    $IsAzureDevOps = $True
}
if ($github.run_id -ne $Null)
{
    $IsGitHubAction = $True
}
if ($IsAzureDevOps -and $IsGitHubAction)
{
    $IsLocal = $False
}
Write-Output "IsGitHubAction: $IsGitHubAction"
Write-Output "IsAzureDevOps: $IsAzureDevOps"
Write-Output "IsLocal: $IsLocal"

# Install GitVersion
if (($installedStuff -like "*GitVersion.Portable*").Count -eq 0) {
    Write-Output "Installing GitVersion"
    choco install gitversion.portable --confirm --accept-license -y
} else { Write-Output "Detected GitVersion"}

# Get Version Numbers
try {
    $versionInfoJson = gitversion
} catch {
    Write-Output "gitversion failed, falling back to default version"
    $versionInfoJson = '{"SemVer":"1.0.0","NuGetVersion":"1.0.0","Major":"1","Minor":"0","Patch":"0"}'
}
If ($IsLocal) {
    $versionInfoJson = $versionInfoJson | foreach {$_.replace("Preview","Local")}
    $versionInfoJson = $versionInfoJson | foreach {$_.replace("preview","Local")}
}
$versionInfo = $versionInfoJson | ConvertFrom-Json
$versionInfo | ConvertTo-Json |  Set-Content -Path ".\output\GitVersion.json"
$properties =  $versionInfo.PSObject.Properties
foreach ($property in $properties) {
    Write-Output "$($property.Name): $($property.Value)"
}
Write-Output "--------------"
If ($IsAzureDevOps)
{
    $properties =  $versionInfo.PSObject.Properties
    foreach ($property in $properties) {
        Write-Output "##vso[task.setvariable variable=$($property.Name);isOutput=true;issecret=false;]$($property.Value)"
        Write-Output "##vso[task.setvariable variable=GitVersion_$($property.Name);isOutput=true;issecret=false;]$($property.Value)"
        Write-Output "##vso[task.setvariable variable=$($property.Name);isOutput=false;issecret=false;]$($property.Value)"
        Write-Output "##vso[task.setvariable variable=GitVersion_$($property.Name);isOutput=false;issecret=false;]$($property.Value)"
      }
}
