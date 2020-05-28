# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
<#
.SYNOPSIS
Sets up the environment to run other vcpkg CI steps in an Azure Pipelines job.

.DESCRIPTION
This script maps network drives from infrastructure and cleans out anything that
might have been leftover from a previous run.

.PARAMETER ForceAllPortsToRebuildKey
A subdirectory / key to use to force a build without any previous run caching,
if necessary.
#>

[CmdletBinding()]
Param(
    [string]$ForceAllPortsToRebuildKey = ''
)

$StorageAccountName = $env:StorageAccountName
$StorageAccountKey = $env:StorageAccountKey

function Remove-DirectorySymlink {
    Param([string]$Path)
    if (Test-Path $Path) {
        [System.IO.Directory]::Delete($Path, $true)
    }
}

Write-Host 'Setting up archives mount'
if (-Not (Test-Path W:)) {
    net use W: "\\$StorageAccountName.file.core.windows.net\archives" /u:"AZURE\$StorageAccountName" $StorageAccountKey
}

Write-Host 'Creating downloads directory'
mkdir D:\downloads -ErrorAction SilentlyContinue

# Delete entries in the downloads folder, except:
#   those in the 'tools' folder
#   those last accessed in the last 30 days
Get-ChildItem -Path D:\downloads -Exclude "tools" `
    | Where-Object{ $_.LastAccessTime -lt (get-Date).AddDays(-30) } `
    | ForEach-Object{Remove-Item -Path $_ -Recurse -Force}

# Msys sometimes leaves a database lock file laying around, especially if there was a failed job
# which causes unrelated failures in jobs that run later on the machine.
# work around this by just removing the vcpkg installed msys2 if it exists
if( Test-Path D:\downloads\tools\msys2 )
{
    Write-Host "removing previously installed msys2"
    Remove-Item D:\downloads\tools\msys2 -Recurse -Force
}

Write-Host 'Setting up archives path...'
if ([string]::IsNullOrWhiteSpace($ForceAllPortsToRebuildKey))
{
    $archivesPath = 'W:\'
}
else
{
    $archivesPath = "W:\force\$ForceAllPortsToRebuildKey"
    if (-Not (Test-Path $fullPath)) {
        Write-Host 'Creating $archivesPath'
        mkdir $archivesPath
    }
}

Write-Host "Linking archives => $archivesPath"
if (-Not (Test-Path archives)) {
    cmd /c "mklink /D archives $archivesPath"
}

Write-Host 'Linking installed => E:\installed'
if (-Not (Test-Path E:\installed)) {
    mkdir E:\installed
}

if (-Not (Test-Path installed)) {
    cmd /c "mklink /D installed E:\installed"
}

Write-Host 'Linking downloads => D:\downloads'
if (-Not (Test-Path D:\downloads)) {
    mkdir D:\downloads
}

Write-Host "Installing Windows SDK 2004 (10.0.19041.0)..." -ForegroundColor Cyan

Write-Host "Downloading..."
$exePath = "$env:temp\winsdksetup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/p/?linkid=2120843', $exePath)
Write-Host "Installing..."
cmd /c start /wait $exePath /features + /quiet
Remove-Item $exePath
Write-Host "Installed" -ForegroundColor Green


Write-Host "Installing WDK 2004 (10.0.19041.0)..." -ForegroundColor Cyan
Write-Host "Downloading..."
$exePath = "$env:temp\wdksetup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/?linkid=2128854', $exePath)
Write-Host "Installing..."
cmd /c start /wait $exePath /features + /quiet
Remove-Item $exePath -Force -ErrorAction Ignore
$vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
#if (-not (Test-Path $vsPath)) {
#    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community"
#}
#if (-not (Test-Path $vsPath)) {
#  return
#}
Write-Host "Installing Visual Studio 2019 WDK extension..."
Start-Process "$vsPath\Common7\IDE\VSIXInstaller.exe" "/a /q /f /sp `"${env:ProgramFiles(x86)}\Windows Kits\10\Vsix\VS2019\WDK.vsix`"" -Wait
Write-Host "Installed" -ForegroundColor Green


$vsixPath = "$env:TEMP\llvm.vsix"
Write-Host "Downloading llvm.vsix..."
(New-Object Net.WebClient).DownloadFile('https://llvmextensions.gallerycdn.vsassets.io/extensions/llvmextensions/llvm-toolchain/1.0.359557/1556628491732/llvm.vsix', $vsixPath)
$vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
#if (-not (Test-Path $vsPath)) {
#    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community"
#}
#if (-not (Test-Path $vsPath)) {
#  return
#}
Write-Host "Installing LLVM extension..."
Start-Process "$vsPath\Common7\IDE\VSIXInstaller.exe" "/a /q /f /sp $vsixPath" -Wait
Remove-Item $vsixPath -Force -ErrorAction Ignore
Write-Host "Installed" -ForegroundColor Green
