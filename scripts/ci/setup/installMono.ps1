<#
.SYNOPSIS
    在 macOS 或 Linux 上安装 Mono。
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($IsMacOS) {
    Write-Host ':: Installing mono via brew...'
    & brew install mono
} elseif ($IsLinux) {
    Write-Host ':: Installing mono-complete via apt...'
    & sudo apt update
    & sudo apt install -y mono-complete
} else {
    Write-Host ':: Mono installation is not required on this platform.'
    exit 0
}

& mono -V
