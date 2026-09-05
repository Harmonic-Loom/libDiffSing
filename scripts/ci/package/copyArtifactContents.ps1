param (
    [string]$pathList,     # 分号分隔的路径列表
    [string]$targetDir     # 要复制到的目标目录
)

# 拆分路径并清除空白项
$paths = @($pathList -split ';' | Where-Object { $_ -and (Test-Path $_) })

# 创建目标目录（如不存在）
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

# 多个目录
if ($paths.Count -ne 1) {
    foreach ($sourcePath in $paths) {
        if ((Test-Path -Path $sourcePath) -and (Test-Path -Path $sourcePath -PathType Container)) {
            $folderName = [System.IO.Path]::GetFileName($sourcePath)
            $destinationFolder = Join-Path -Path $targetDir -ChildPath $folderName

            # 复制文件夹到目标路径
            Write-Host "已将目录 $sourcePath 复制到 $destinationFolder"
            Copy-Item -Path $sourcePath -Destination $destinationFolder -Recurse -Force
        } else {
            Write-Host "$sourcePath 不存在或不是目录"
        }
    }
} else {
    # 单个目录
    $sourceDir = $paths[0]

    # 复制源目录中的所有内容到目标目录
    Copy-Item -Path "$sourceDir/*" -Destination $targetDir -Recurse -Force

    Write-Output "已将 $sourceDir 中的内容复制到 $targetDir"
} 
