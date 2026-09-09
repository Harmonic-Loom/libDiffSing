<#
.SYNOPSIS
	在 Windows/Linux x64 上下载并安装 CUDA 12.8、cuDNN 9.x 与 TensorRT 10.9 开发库。
	- CUDA 和 cuDNN 从 conda（micromamba）安装
	- TensorRT 从 NVIDIA 官方下载安装

.DESCRIPTION
	- Windows: win-64
	- Linux: linux-64
	- 仅支持 x64 架构。
	- 安装到指定前缀目录，不会修改系统级 CUDA。
	- 如在 GitHub Actions 中运行，会把关键环境变量写入 GITHUB_ENV。

.PARAMETER InstallPrefix
	安装前缀目录。

.PARAMETER CudaSpec
	CUDA 包版本约束，默认 12.8.*。

.PARAMETER CudnnSpec
	cuDNN 包版本约束，默认 >=9,<10。

.PARAMETER TensorRtVersion
	TensorRT 版本（从 NVIDIA 官方下载），默认 10.9.0.34。

.PARAMETER Force
	强制重建环境（先删除安装目录）。

.EXAMPLE
	./scripts/ci/setup/installNvidiaDevLibs.ps1

.EXAMPLE
	./scripts/ci/setup/installNvidiaDevLibs.ps1 -InstallPrefix "C:/nvidia/dev" -Force

.EXAMPLE
	./scripts/ci/setup/installNvidiaDevLibs.ps1 -TensorRtVersion "10.8.0"
#>
param(
	[string]$InstallPrefix = $(if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) { 'C:/nvidia/dev' } else { '/opt/nvidia/dev' }),
	[string]$CudaSpec = 'cuda-toolkit=12.8.*',
	[string]$CudnnSpec = 'cudnn>=9,<10',
	[string]$TensorRtVersion = '10.9.0.34',
	[switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Check platform once at the beginning
$script:PlatformIsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
$script:PlatformIsLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)

function Assert-SupportedPlatform {
	if (-not ($script:PlatformIsWindows -or $script:PlatformIsLinux)) {
		throw "仅支持 Windows 或 Linux，当前平台不受支持。"
	}

	if ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -ne [System.Runtime.InteropServices.Architecture]::X64) {
		throw "仅支持 x64，当前架构: $([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture)"
	}
}

function Invoke-DownloadFile {
	param(
		[Parameter(Mandatory)][string]$Url,
		[Parameter(Mandatory)][string]$OutputPath
	)

	Write-Host ":: Downloading $Url"
	$parent = Split-Path -Parent $OutputPath
	if (-not (Test-Path $parent)) {
		New-Item -ItemType Directory -Path $parent | Out-Null
	}

	Invoke-WebRequest -Uri $Url -OutFile $OutputPath
	if (-not (Test-Path $OutputPath)) {
		throw "下载失败: $Url"
	}
}

function Get-MicromambaExe {
	param([Parameter(Mandatory)][string]$WorkDir)

	$platform = if ($script:PlatformIsWindows) { 'win-64' } else { 'linux-64' }
	$archive = Join-Path $WorkDir "micromamba-$platform.tar.bz2"
	$extract = Join-Path $WorkDir 'micromamba'
	$url = "https://micro.mamba.pm/api/micromamba/$platform/latest"

	Invoke-DownloadFile -Url $url -OutputPath $archive

	if (Test-Path $extract) {
		Remove-Item -Recurse -Force $extract
	}
	New-Item -ItemType Directory -Path $extract | Out-Null

	& tar -xjf $archive -C $extract
	if ($LASTEXITCODE -ne 0) {
		throw "解压 micromamba 失败。"
	}

	$exe = if ($script:PlatformIsWindows) {
		Join-Path $extract 'Library/bin/micromamba.exe'
	} else {
		Join-Path $extract 'bin/micromamba'
	}

	if (-not (Test-Path $exe)) {
		throw "未找到 micromamba 可执行文件: $exe"
	}

	return $exe
}

function Install-TensorRT {
	param(
		[Parameter(Mandatory)][string]$Version,
		[Parameter(Mandatory)][string]$Prefix,
		[Parameter(Mandatory)][string]$WorkDir
	)

	# Extract major.minor.patch from version like "10.9.0.34"
	$versionParts = $Version -split '\.'
	$versionPath = "$($versionParts[0]).$($versionParts[1]).$($versionParts[2])"

	$platform = if ($script:PlatformIsWindows) { 'Windows.win10' } else { 'Linux.x86_64-gnu' }
	$archiveName = "TensorRT-$Version.$platform.cuda-12.8"
	$archiveExt = if ($script:PlatformIsWindows) { 'zip' } else { 'tar.gz' }
	$archiveFile = "$archiveName.$archiveExt"
	$archivePath = Join-Path $WorkDir $archiveFile

	$url = if ($script:PlatformIsWindows) {
		"https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/$versionPath/zip/$archiveFile"
	} else {
		"https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/$versionPath/tars/$archiveFile"
	}

	Write-Host ":: Downloading TensorRT from $url"
	Invoke-DownloadFile -Url $url -OutputPath $archivePath

	$extractPath = Join-Path $WorkDir 'tensorrt-extract'
	if (Test-Path $extractPath) {
		Remove-Item -Recurse -Force $extractPath
	}
	New-Item -ItemType Directory -Path $extractPath | Out-Null

	Write-Host ":: Extracting TensorRT"
	if ($script:PlatformIsWindows) {
		Expand-Archive -Path $archivePath -DestinationPath $extractPath
	} else {
		& tar -xzf $archivePath -C $extractPath
		if ($LASTEXITCODE -ne 0) {
			throw "解压 TensorRT 失败。"
		}
	}

	$tensorrtRoot = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1
	if (-not $tensorrtRoot) {
		throw "未找到 TensorRT 提取目录"
	}

	Write-Host ":: Installing TensorRT to $Prefix"
	if ($script:PlatformIsWindows) {
		$srcBin = Join-Path $tensorrtRoot.FullName 'bin'
		$srcLib = Join-Path $tensorrtRoot.FullName 'lib'
		$srcInclude = Join-Path $tensorrtRoot.FullName 'include'

		$dstBin = Join-Path $Prefix 'Library/bin'
		$dstLib = Join-Path $Prefix 'Library/lib'
		$dstInclude = Join-Path $Prefix 'Library/include'
	} else {
		$srcBin = Join-Path $tensorrtRoot.FullName 'bin'
		$srcLib = Join-Path $tensorrtRoot.FullName 'lib'
		$srcInclude = Join-Path $tensorrtRoot.FullName 'include'

		$dstBin = Join-Path $Prefix 'bin'
		$dstLib = Join-Path $Prefix 'lib'
		$dstInclude = Join-Path $Prefix 'include'
	}

	foreach ($dir in @($dstBin, $dstLib, $dstInclude)) {
		if (-not (Test-Path $dir)) {
			New-Item -ItemType Directory -Path $dir -Force | Out-Null
		}
	}

	if (Test-Path $srcBin) {
		Copy-Item -Path "$srcBin/*" -Destination $dstBin -Recurse -Force
		Write-Host ":: Copied TensorRT bin files"
	}
	if (Test-Path $srcLib) {
		Copy-Item -Path "$srcLib/*" -Destination $dstLib -Recurse -Force
		Write-Host ":: Copied TensorRT lib files"
	}
	if (Test-Path $srcInclude) {
		Copy-Item -Path "$srcInclude/*" -Destination $dstInclude -Recurse -Force
		Write-Host ":: Copied TensorRT include files"
	}

	Remove-Item -Recurse -Force $extractPath
	Write-Host ":: TensorRT 安装完成"
}

function Export-EnvForCurrentSession {
	param([Parameter(Mandatory)][string]$Prefix)

	if ($script:PlatformIsWindows) {
		$bin = Join-Path $Prefix 'Library/bin'
		$lib = Join-Path $Prefix 'Library/lib'
		$include = Join-Path $Prefix 'Library/include'
	} else {
		$bin = Join-Path $Prefix 'bin'
		$lib = Join-Path $Prefix 'lib'
		$include = Join-Path $Prefix 'include'
	}

	if (-not (Test-Path $bin)) { throw "未找到 bin 目录: $bin" }
	if (-not (Test-Path $lib)) { throw "未找到 lib 目录: $lib" }
	if (-not (Test-Path $include)) { throw "未找到 include 目录: $include" }

	if ($script:PlatformIsWindows) {
		$env:PATH = "$bin;$($env:PATH)"
	} else {
		$env:PATH = "${bin}:$($env:PATH)"
		$env:LD_LIBRARY_PATH = "${lib}:$($env:LD_LIBRARY_PATH)"
	}

	$env:CUDA_PATH = $Prefix
	$env:CUDNN_ROOT = $Prefix
	$env:TENSORRT_ROOT = $Prefix

	if ($env:GITHUB_ENV) {
		"CUDA_PATH=$Prefix" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		"CUDNN_ROOT=$Prefix" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		"TENSORRT_ROOT=$Prefix" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

		if ($script:PlatformIsWindows) {
			"PATH=$bin;$env:PATH" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		} else {
			"PATH=${bin}:$env:PATH" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
			"LD_LIBRARY_PATH=${lib}:$env:LD_LIBRARY_PATH" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		}

		Write-Host ':: 环境变量已写入 GITHUB_ENV'
	}
}

Assert-SupportedPlatform

$prefix = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallPrefix)
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'nvidia-devlibs-install'

if ($Force -and (Test-Path $prefix)) {
	Write-Host ":: Removing existing prefix: $prefix"
	Remove-Item -Recurse -Force $prefix
}

if (-not (Test-Path $tempRoot)) {
	New-Item -ItemType Directory -Path $tempRoot | Out-Null
}

$micromamba = Get-MicromambaExe -WorkDir $tempRoot

Write-Host ":: Installing CUDA and cuDNN to $prefix"
& $micromamba create --yes --prefix $prefix -c nvidia -c conda-forge $CudaSpec $CudnnSpec
if ($LASTEXITCODE -ne 0) {
	throw "micromamba create 失败，退出码: $LASTEXITCODE"
}

Write-Host ":: Installing TensorRT $TensorRtVersion"
Install-TensorRT -Version $TensorRtVersion -Prefix $prefix -WorkDir $tempRoot

Export-EnvForCurrentSession -Prefix $prefix

Write-Host ':: CUDA/cuDNN/TensorRT 开发库安装完成。'
& $micromamba list --prefix $prefix | Select-String -Pattern 'cuda-toolkit|cudnn' | ForEach-Object { Write-Host $_ }
Write-Host ":: TensorRT version: $TensorRtVersion"
