param (
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $true)]
    [string]$TargetDir
)

# 创建目标目录（如不存在）
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 确保路径是完整路径
$SourceDir = (Resolve-Path $SourceDir).Path
$TargetDir = (Resolve-Path $TargetDir).Path

# 搜索所有匹配的文件
$extensions = @("*.lib", "*.a")
$files = Get-ChildItem -Path $SourceDir -Recurse -Include $extensions -File

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
}

Write-Host "完成拷贝，共处理 $($files.Count) 个文件。"
