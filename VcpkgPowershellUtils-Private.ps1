function Recipe
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$filepath,
        [Parameter(Mandatory=$true)][ScriptBlock]$Action
    )

    Write-Verbose "Starting recipe for $filepath"

    if(!(Test-Path $filepath))
    {
        Write-Verbose "Invoking recipe for $filepath"
        $Action.Invoke()
    }
    if(!(Test-Path $filepath))
    {
        throw "failed $filepath"
    }
}

function checkExit
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][bool]$condition,
        [Parameter(Mandatory=$true)][String]$errorMessage
    )

    if (!$condition)
    {
        Write-Host "Error: $errorMessage"
        throw
    }
}

function checkWarn
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][bool]$condition,
        [Parameter(Mandatory=$true)][String]$errorMessage
    )

    if (!$condition)
    {
        Write-Warning "Error: $errorMessage"
    }
}

function vcpkgGetProcessByNameRegex
{
    param
    (
        [Parameter(Mandatory=$true)][String]$regex
    )

    # SilentlyContinue in case nothing is found
    return Get-Process -Name "$regex" -ErrorAction SilentlyContinue
}

function findProcessesLockingFile
{
Param(
    [Parameter(Mandatory=$true)][string]$filename
)
    $handleApp = "$scriptsDir\Handle\Handle.exe"
    $handleOut = Invoke-Expression ($handleApp + ' ' + $filename)
    $locks = $handleOut |?{$_ -match "(.+?)\s+pid: (\d+?)\s+type: File\s+(\w+?): (.+)\s*$"}|%{
        [PSCustomObject]@{
            'AppName' = $Matches[1]
            'PID' = $Matches[2]
            'FileHandle' = $Matches[3]
            'FilePath' = $Matches[4]
        }
    }

    return $locks
}


function DownloadAndUpdateVSInstaller
{
    $installerPath = "$scriptsDir\vs_Community.exe"
    Recipe $installerPath {
        Write-Host "Downloading VS Installer..."
        vcpkgDownloadFile "https://aka.ms/vs/15/release/vs_community.exe" $installerPath
        Write-Host "Downloading VS Installer... done."
    }

    Write-Host "Updating VS Installer..."
    $ec = vcpkgInvokeCommand $installerPath "--update --quiet --wait --norestart"
    checkExit ($ec -eq 0) "Updating VS installer... failed."
    Write-Host "Updating VS Installer... done."

    return $installerPath
}

function UnattendedVSinstall
{
    param(
        [Parameter(Mandatory=$true)][string]$installPath,
        [Parameter(Mandatory=$true)][string]$nickname
    )

    # References
    # https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community#desktop-development-with-c

    $installerPath = DownloadAndUpdateVSInstaller

    Write-Host "Installing Visual Studio..."
    $arguments = (
    "--installPath `"$installPath`"",
    "--add Microsoft.VisualStudio.Workload.NativeDesktop",
    "--add Microsoft.VisualStudio.Workload.Universal",
    "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add Microsoft.VisualStudio.Component.VC.Tools.ARM",
    "--add Microsoft.VisualStudio.Component.VC.Tools.ARM64",
    "--add Microsoft.VisualStudio.Component.VC.ATL",
    "--add Microsoft.VisualStudio.Component.VC.ATLMFC",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP.Native",
    "--add Microsoft.VisualStudio.ComponentGroup.UWP.VC",
    "--add Microsoft.Component.VC.Runtime.OSSupport",
    "--nickname $nickname",
    "--quiet",
    "--wait",
    "--norestart") -join " "

    $ec = vcpkgInvokeCommand $installerPath "$arguments"
    checkExit ($ec -eq 0) "Installing Visual Studio... failed."

    Write-Host "Installing Visual Studio... done."
}

function UnattendedVSupdate
{
    param(
        [Parameter(Mandatory=$true)][string]$installPath
    )

    $installerPath = DownloadAndUpdateVSInstaller

    Write-Host "Updating Visual Studio..."
    $arguments = (
    "update",
    "--installPath `"$installPath`"",
    "--quiet",
    "--wait",
    "--norestart") -join " "

    $ec = vcpkgInvokeCommand $installerPath "$arguments"
    checkExit ($ec -eq 0) "Updating Visual Studio... failed."

    for ($i=0; ($i -lt 3) -and ((vcpkgGetProcessByNameRegex "vs_installer*").Count -ne 0); $i++)
    {
        Write-Warning "VS Installer still running, waiting..."
        Start-Sleep -s 5
    }

    $remaining = vcpkgGetProcessByNameRegex "vs_installer*"
    if ($remaining.Count -ne 0)
    {
        Write-Warning "VS Installer still running, stopping it..."
        Write-Warning $remaining
        $remaining | Stop-Process
    }

    Write-Host "Updating Visual Studio... done."
}

function CreateTripletsForVS
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$vsInstallPath,
        [Parameter(Mandatory=$true)][String]$vsInstallNickname,
        [Parameter(Mandatory=$true)][String]$outputDir
    )

    $vsInstallPath = $vsInstallPath -replace "\\","/"
    $vsInstallNickname = $vsInstallNickname.ToLower()

    foreach ($architecture in @("x86", "x64"))
    {
        foreach ($linkage in @("dynamic", "static"))
        {
            @"
set(VCPKG_TARGET_ARCHITECTURE $architecture)
set(VCPKG_CRT_LINKAGE $linkage)
set(VCPKG_LIBRARY_LINKAGE $linkage)
set(VCPKG_VISUAL_STUDIO_PATH "$vsInstallPath")
"@ | Out-File -FilePath "$outputDir\$architecture-windows-$linkage-$vsInstallNickname.cmake" -Encoding ASCII
        }

        $linkage = "dynamic"
        @"
set(VCPKG_TARGET_ARCHITECTURE $architecture)
set(VCPKG_CRT_LINKAGE $linkage)
set(VCPKG_LIBRARY_LINKAGE $linkage)
set(VCPKG_VISUAL_STUDIO_PATH "$vsInstallPath")

set(VCPKG_CMAKE_SYSTEM_NAME WindowsStore)
set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
"@  | Out-File -FilePath "$outputDir\$architecture-uwp-$linkage-$vsInstallNickname.cmake" -Encoding ASCII

    }
}

function IsReparsePoint([string]$path)
{
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function unlinkOrDeleteDirectory([string]$path)
{
    Write-Host "Unlinking/deleting $path ..."
    if (IsReparsePoint $path)
    {
        Write-Host "Reparse point detected. Unlinking."
        cmd /c rmdir $path
    }
    else
    {
        Write-Host "Non-reparse point detected. Deleting."
        vcpkgRemoveItem $path
    }
    Write-Host "Unlinking/deleting $installpathedDirLocal ... done."
}

# Constants
$VISUAL_STUDIO_2017_STABLE_PATH = "C:\VS2017\Stable"
$VISUAL_STUDIO_2017_UNSTABLE_PATH = "C:\VS2017\Unstable"

$VISUAL_STUDIO_2017_STABLE_NICKNAME = "Stable"
$VISUAL_STUDIO_2017_UNSTABLE_NICKNAME = "Unstable"

$DEPLOYED_VERSION_FILENAME = "DEPLOYED_VERSION.txt"
