param (
    [string]$baseDir,
    [string]$pattern
)

# 确保基础目录存在
if (-not (Test-Path $baseDir)) {
    Write-Error "目录不存在：$baseDir"
    exit 1
}

# 获取匹配的子目录
$matchedDirs = Get-ChildItem -Path $baseDir -Directory -Filter $pattern | ForEach-Object {
    $_.FullName
}

# 以分号拼接输出
$joined = ($matchedDirs -join ";")
Write-Output $joined
