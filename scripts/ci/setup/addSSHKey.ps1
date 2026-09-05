param(
  [Parameter(Mandatory)][string]$PrivateKey,
  [Parameter(Mandatory)][string[]]$Hosts = @("github.com")
)

# 获取用户 .ssh 目录
$userDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$sshDir = Join-Path $userDir ".ssh"

# 创建目录（若不存在）
if (-not (Test-Path $sshDir)) {
  New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

# 写入私钥文件
$keyPath = Join-Path $sshDir "id_rsa"
$PrivateKey | Out-File -FilePath $keyPath -Encoding ascii -NoNewline

# 移除 CRLF 换行符
(Get-Content $keyPath) | Set-Content -Path $keyPath -Force -NoNewline
Add-Content -Path $keyPath -Value "`n"

# 设置私钥权限
if (-not $IsWindows) { chmod 600 $keyPath }

# 设置 known_hosts
$knownHosts = Join-Path $sshDir "known_hosts"
foreach ($hostItem in $Hosts) {
  ssh-keyscan $hostItem 2>$null | Out-File -FilePath $knownHosts -Encoding ascii -Append
}

if (-not $IsWindows) { chmod 644 $knownHosts }

Write-Output "SSH 配置完成："
Write-Output "  私钥： $keyPath"
Write-Output "  known_hosts： $knownHosts"