param(
    [Parameter(Mandatory = $true)]
    [string]$PresetName,

    [string]$CMakePresetsPath = "CMakePresets.json"
)

# 读取 CMakePresets.json
if (-not (Test-Path $CMakePresetsPath)) {
    Write-Error "未找到 $CMakePresetsPath"
    exit 1
}

$presetsJson = Get-Content $CMakePresetsPath -Raw | ConvertFrom-Json

# 辅助：从配置 preset 列表中查找给定 preset 名称的缓存变量值
function Get-CacheVarFromPresets($presets, $presetName, $varName) {
    $p = $presets | Where-Object { $_.name -eq $presetName }
    if ($p -and $p.cacheVariables -and $p.cacheVariables.PSObject.Properties.Name -contains $varName) {
        return $p.cacheVariables.$varName
    }
    return $null
}
function Get-PresetByName($name) {
    return $presetsJson.configurePresets | Where-Object { $_.name -eq $name }
}

# 查找当前 preset
$preset = Get-PresetByName $PresetName
if (-not $preset) {
    Write-Error "未找到 preset: $PresetName"
    exit 1
}

# 递归继承
$cache = @{}
function Resolve-Preset($p) {
    if ($p.inherits) {
        $base = Get-PresetByName $p.inherits
        if ($base) {
            Resolve-Preset $base
        }
    }
    if ($p.cacheVariables) {
        foreach ($kv in $p.cacheVariables.PSObject.Properties) {
            $cache[$kv.Name] = $kv.Value
        }
    }
}
Resolve-Preset $preset

Write-Host "解析后的缓存变量:"
$cache.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key): $($_.Value)" }

# 通用获取 cache 变量（优先从解析后的 $cache，失败则在常见隐藏 preset 中查找）
function Get-CacheValue([string]$name) {
    if ($cache.ContainsKey($name)) { return $cache[$name] }
    $fallbackPresets = @("ios-default", "osx-default", "osx-x64-default", "osx-xcode-default")
    foreach ($pn in $fallbackPresets) {
        $v = Get-CacheVarFromPresets $presetsJson.configurePresets $pn $name
        if ($v) { return $v }
    }
    return $null
}

# 如果解析后的 cache 中存在 CMAKE_OSX_DEPLOYMENT_TARGET，则传递给 vcpkg；否则不传递
$deploymentTarget = $null
if ($cache.ContainsKey("CMAKE_OSX_DEPLOYMENT_TARGET")) {
    $deploymentTarget = $cache["CMAKE_OSX_DEPLOYMENT_TARGET"]
}

if ($deploymentTarget) {
    # 仅在明确由当前 preset（及其继承链）提供该变量时才导出并传递给 vcpkg
    $env:CMAKE_OSX_DEPLOYMENT_TARGET = $deploymentTarget
    $env:VCPKG_ENV_PASSTHROUGH = "CMAKE_OSX_DEPLOYMENT_TARGET"
    Write-Host "使用 CMAKE_OSX_DEPLOYMENT_TARGET: $deploymentTarget"
} else {
    Write-Host "未在当前 preset 的 cache 中找到 CMAKE_OSX_DEPLOYMENT_TARGET，跳过传递给 vcpkg"
}

# 解析 ${sourceDir} 与 $env{VAR}
function Resolve-PathVars([string]$path, [string]$sourceDir) {
    if (-not $path) { return $null }

    # 替换 ${sourceDir}
    $output = $path -replace '\$\{sourceDir\}', [Regex]::Escape($sourceDir)

    # 替换 $env{VAR}
    $output = [Regex]::Replace($output, '\$env\{([^}]+)\}', {
        param($m)
        $envVar = $m.Groups[1].Value
        return [Environment]::GetEnvironmentVariable($envVar)
    })

    return $output
}

# 获取 sourceDir = CMakePresets.json 所在路径
$sourceDir = Split-Path -Parent (Resolve-Path $CMakePresetsPath)
Write-Host "CMakePresets.json 所在路径: $sourceDir"

# 替换 ${sourceDir} 和 $env{}
$vcpkgToolchainFixed = Resolve-PathVars (Get-CacheValue "CMAKE_TOOLCHAIN_FILE") $sourceDir
Write-Host "解析后的 CMAKE_TOOLCHAIN_FILE: $vcpkgToolchainFixed"

$vcpkgRoot = ""
if ($vcpkgToolchainFixed -match "(.+)/vcpkg/scripts/buildsystems/vcpkg.cmake") {
    $vcpkgRoot = $Matches[1] + "/vcpkg"
}

Write-Host "解析后的 vcpkg 根目录: $vcpkgRoot"

if (-not $vcpkgRoot -or -not (Test-Path $vcpkgRoot)) {
    Write-Error "无法解析 vcpkg 根目录"
    exit 1
}

$triplet = Get-CacheValue "VCPKG_TARGET_TRIPLET"
if (-not $triplet) {
    Write-Error "未在 preset 中找到 VCPKG_TARGET_TRIPLET"
    exit 1
}

# 执行清单安装
$vcpkgExe = Join-Path $vcpkgRoot "vcpkg.exe"
if (-not (Test-Path $vcpkgExe)) {
    $vcpkgExe = Join-Path $vcpkgRoot "vcpkg"
}
if (-not (Test-Path $vcpkgExe)) {
    Write-Error "未找到 vcpkg 可执行文件"
    exit 1
}

Write-Host "Preset: $PresetName"
Write-Host "Triplet: $triplet"
Write-Host "VCPKG Root: $vcpkgRoot"

# 构造命令
$cmd = "& `"$vcpkgExe`" install --triplet=$triplet"
Write-Host "执行命令: $cmd"
Invoke-Expression $cmd
