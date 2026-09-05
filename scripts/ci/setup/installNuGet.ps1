<#
.SYNOPSIS
    下载 NuGet.exe，在 Linux/macOS 上将其放入 PATH 供 vcpkg 使用，并将路径写入 GITHUB_ENV。

.DESCRIPTION
    从官方地址下载最新 NuGet.exe。
    在 Linux/macOS 上：将程序集保存为不带 .exe 后缀的 `nuget`，使 vcpkg 在
    VCPKG_FORCE_SYSTEM_BINARIES 模式下能通过 PATH 找到它，并由 vcpkg 自行以
    mono 调用（vcpkg 内部会为找到的 nuget 自动添加 mono 前缀）。
    同时将路径以 SYSTEM_NUGET_EXE 写入 $GITHUB_ENV，供 addNuGetSource.ps1 使用。

.PARAMETER NuGetUrl
    NuGet.exe 的下载地址，默认为官方最新版地址。

.PARAMETER Destination
    NuGet 程序集的保存路径。
    Linux/macOS 默认为 $HOME/.local/nuget（无 .exe 后缀）。
    Windows 默认为 $HOME/.local/nuget.exe。
#>
param(
    [string]$NuGetUrl    = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe',
    [string]$Destination = $(if ($IsWindows) { "$HOME/.local/nuget.exe" } else { "$HOME/.local/nuget" })
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$destDir = Split-Path -Parent $Destination
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

Write-Host ":: Downloading NuGet from $NuGetUrl..."
& curl -sL $NuGetUrl -o $Destination
Write-Host "   Saved to: $Destination"

if (-not $IsWindows) {
    # vcpkg 在 VCPKG_FORCE_SYSTEM_BINARIES 模式下会自动以 mono 调用找到的 nuget。
    # 文件本身必须是 CIL 程序集（不能是 shell 脚本），故直接保存无后缀文件并赋予可执行权限。
    & chmod +x $Destination

    # 将目录写入 GITHUB_PATH，使后续步骤的 PATH 包含该目录
    $githubPath = $env:GITHUB_PATH
    if ($githubPath) {
        $destDir | Out-File -FilePath $githubPath -Encoding utf8 -Append
        Write-Host ":: $destDir added to GITHUB_PATH"
    } else {
        $env:PATH = "${destDir}:$($env:PATH)"
        Write-Host ":: $destDir added to current PATH"
    }
}

$githubEnv = $env:GITHUB_ENV
if ($githubEnv) {
    "SYSTEM_NUGET_EXE=$Destination" | Out-File -FilePath $githubEnv -Encoding utf8 -Append
    Write-Host ":: SYSTEM_NUGET_EXE written to GITHUB_ENV"
} else {
    Write-Warning 'GITHUB_ENV is not set; skipping environment export.'
}
