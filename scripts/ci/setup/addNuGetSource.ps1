<#
.SYNOPSIS
    为所有平台配置 vcpkg 二进制缓存所需的 NuGet 源。

.PARAMETER VcpkgExe
    vcpkg 可执行文件的路径。

.PARAMETER FeedUrl
    NuGet feed 地址。

.PARAMETER Username
    NuGet 源的用户名。

.PARAMETER Token
    用于认证的 API Token（明文存储）。

.PARAMETER UseSystemNuGet
    若为 $true，则使用系统安装的 nuget（适用于 Linux ARM64）；
    否则通过 vcpkg fetch nuget 获取 nuget.exe（适用于 Windows、macOS、Linux x64）。
#>
param(
    [Parameter(Mandatory)][string]$VcpkgExe,
    [Parameter(Mandatory)][string]$FeedUrl,
    [Parameter(Mandatory)][string]$Username,
    [Parameter(Mandatory)][string]$Token,
    [switch]$UseSystemNuGet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-NuGet {
    param([string]$NuGetExe, [string[]]$Arguments)

    # Windows 直接调用；Linux/macOS 上的 CIL 程序集需要通过 mono 执行
    if ($IsWindows) {
        & $NuGetExe @Arguments
    } else {
        & mono $NuGetExe @Arguments
    }

    if ($LASTEXITCODE -ne 0) {
        throw "nuget exited with code $LASTEXITCODE"
    }
}


# 获取 nuget 路径
if ($UseSystemNuGet) {
    # 优先使用由 installNuGet.ps1 下载并写入环境变量 SYSTEM_NUGET_EXE 的 nuget.exe
    $nugetExe = $env:SYSTEM_NUGET_EXE
    if (-not $nugetExe) {
        $nugetExe = (Get-Command nuget -ErrorAction SilentlyContinue)?.Source
    }
    if (-not $nugetExe) { $nugetExe = "$HOME/.local/nuget" }
    Write-Host "Using system nuget: $nugetExe"
} else {
    $nugetExe = (& $VcpkgExe fetch nuget 2>&1) | Select-Object -Last 1
    Write-Host "Using vcpkg-fetched nuget: $nugetExe"
}

# 移除旧源（忽略不存在时的错误）
try {
    Invoke-NuGet $nugetExe @('sources', 'remove', '-Name', 'GitHubPackages')
} catch {
    Write-Host "No existing source 'GitHubPackages' to remove, continuing..."
}

# 添加新源
Invoke-NuGet $nugetExe @(
    'sources', 'add',
    '-Source', $FeedUrl,
    '-StorePasswordInClearText',
    '-Name', 'GitHubPackages',
    '-UserName', $Username,
    '-Password', $Token
)

# 设置 API Key
Invoke-NuGet $nugetExe @('setapikey', $Token, '-Source', $FeedUrl)

Write-Host "NuGet source 'GitHubPackages' configured successfully."
