param(
    [Parameter(Mandatory = $true)]
    [string]$VcpkgRoot,   # vcpkg 根目录，如 C:\vcpkg\installed
    [Parameter(Mandatory = $true)]
    [string]$OutputDir    # 输出目录，如 D:\licenses
)

# 确保输出目录存在
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# 在 vcpkg 根目录下递归查找所有 copyright 文件
$files = Get-ChildItem -Path $VcpkgRoot -Recurse -Filter "copyright" -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Host "⚠️ 未找到任何 copyright"
    exit
}

$copied = 0
foreach ($file in $files) {
    # 提取包名：通常路径为 installed\<triplet>\share\<包名>\copyright
    # 所以我们取上上级目录名作为包名
    $parentDir = Split-Path $file.DirectoryName -Leaf
    $grandParentDir = Split-Path (Split-Path $file.DirectoryName) -Leaf

    # 判断路径结构
    if ($grandParentDir -eq "share") {
        $packageName = $parentDir
    } else {
        # 兜底：直接用当前文件所在文件夹名
        $packageName = $parentDir
    }

    # 跳过以 vcpkg 开头的包
    if ($packageName -match '^vcpkg') {
        Write-Host "⏩ Skipped internal package: $packageName"
        continue
    }

    $targetFile = Join-Path $OutputDir "$packageName-LICENSE.txt"
    Copy-Item -Path $file.FullName -Destination $targetFile -Force
    $copied++
    Write-Host "✅ Copied: $packageName -> $targetFile"
}

Write-Host "`n🎉 已完成！共复制 $copied 个 license 文件到 $OutputDir"
