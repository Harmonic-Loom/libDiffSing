param (
    [Parameter(Mandatory = $true)]
    [string]$SourceDirList,

    [Parameter(Mandatory = $true)]
    [string]$TargetDir
)

# 拆分路径列表并获取首个路径
$parentDirs = $SourceDirList -split ';' | Where-Object { $_ -and (Test-Path $_) }
if ($parentDirs.Count -eq 0) {
    Write-Host "源目录列表为空或所有源目录不存在"
    return
}

if ($parentDirs.Count -gt 1) {
    $SourceDir = $parentDirs[0]
    Write-Host "检测到多个路径，仅使用第一个路径: $SourceDir"
}
else {
    $SourceDir = $parentDirs
    Write-Host "使用路径: $SourceDir"
}

# 创建目标目录（如不存在）
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 确保路径是完整路径
$SourceDir = (Resolve-Path $SourceDir).Path
$TargetDir = (Resolve-Path $TargetDir).Path

# 搜索所有匹配的文件
$extensions = @("*")
$childs = @("data/", "licenses/")

$count = 0
foreach ($child in $childs) {
    $fullPath = Join-Path $SourceDir $child

    if (Test-Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -Recurse -Include $extensions -File

        foreach ($file in $files) {
            # 获取相对路径
            $relativePath = $file.FullName.Substring($SourceDir.Length).TrimStart('\','/')
    
            # 目标文件的完整路径
            $destPath = Join-Path $TargetDir $relativePath

            # 创建目标文件夹（如果不存在）
            $destDir = Split-Path $destPath -Parent
            if (!(Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }

            # 拷贝文件
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-Host "已拷贝: $relativePath"
            $count++
        }
    }
}

Write-Host "完成拷贝，共处理 $count 个文件。"
