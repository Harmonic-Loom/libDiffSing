param (
    [string]$frameworkParentDirs,  # 以分号分隔的上层目录列表
    [string]$outputPath            # 输出的 .xcframework 路径
)

# 拆分路径列表并收集所有 .framework 路径
$frameworkDirs = @()

$parentDirs = $frameworkParentDirs -split ';' | Where-Object { $_ -and (Test-Path $_) }
foreach ($dir in $parentDirs) {
    $frameworks = Get-ChildItem -Path $dir -Directory -Filter "*.framework" -Recurse
    foreach ($fw in $frameworks) {
        $frameworkDirs += $fw.FullName
    }
}

if ($frameworkDirs.Count -eq 0) {
    Write-Error "未在指定路径中找到任何 .framework"
    exit 1
}

# 构建 xcodebuild 参数
$inputs = @()
foreach ($fw in $frameworkDirs) {
    $inputs += "-framework"
    $inputs += "`"$fw`""
}

# 清理旧输出
if (Test-Path $outputPath) {
    Remove-Item -Recurse -Force $outputPath
}

# 构建命令并执行
$cmd = "xcodebuild -create-xcframework $($inputs -join ' ') -output `"$outputPath`""
Write-Host "执行命令：`n$cmd`n"
Invoke-Expression $cmd
