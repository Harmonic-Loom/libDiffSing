param (
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $true)]
    [string]$LibPath,

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

# 便利SourceDir下的所有目录
$count = 0
$paths = Get-ChildItem -Path $SourceDir -Directory
foreach ($path in $paths) {
    $fullLibPath = Join-Path $path.FullName $LibPath
    if (Test-Path $fullLibPath) {
        # 搜索所有匹配的文件
        $extensions = @("*.so", "*.dylib", "*.dll", "*.pdb")
        $files = Get-ChildItem -Path $fullLibPath -Recurse -Include $extensions -File

        foreach ($file in $files) {
            # 获取相对路径
            $relativePath = $file.FullName.Substring($fullLibPath.Length).TrimStart('\','/')
    
            # 目标文件的完整路径
            $destPath = Join-Path $TargetDir $relativePath

            # 创建目标文件夹（如果不存在）
            $destDir = Split-Path $destPath -Parent
            if (!(Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }

            # 拷贝文件
            Write-Host "拷贝文件: $($file.FullName) -> $destPath"
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            $count++
        }
    }
}

Write-Host "完成拷贝，共处理 $count 个文件。"
